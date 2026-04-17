Attribute VB_Name = "Svc_PreOS"
Option Explicit

' Serviço de Pré-OS — V10
' Implementa: EmitirPreOS, RecusarPreOS, ExpirarPreOS.
' Integrado com Svc_Rodizio (SelecionarEmpresa, AvancarFila).
' Sem Select/ActiveCell/On Error Resume Next silencioso.
' Referência: doc/Time_AI/001-Sprint0-Contrato-de-Dados-V10.md (seção 2.7)
'
' POLÍTICA DE AvancarFila:
'   RecusarPreOS/ExpirarPreOS: AvancarFila chamado ANTES de gravar PRE_OS.
'   Falha de AvancarFila → Sucesso=False, PRE_OS inalterada (BLOQUEANTE).

' ============================================================
' CONSTANTES DE STATUS
' ============================================================
Private Const STATUS_AGUARDANDO As String = "AGUARDANDO_ACEITE"
Private Const STATUS_RECUSADA   As String = "RECUSADA"
Private Const STATUS_EXPIRADA   As String = "EXPIRADA"
Private Const STATUS_CONVERTIDA As String = "CONVERTIDA_OS"

' ============================================================
' SEÇÃO 1: EMISSÃO
' ============================================================

' EmitirPreOS — emite Pré-OS via rodízio para uma atividade.
'
' Parâmetros:
'   ENT_ID      : ID da entidade demandante (FK → ENTIDADE)
'   COD_SERVICO : "ATIV_ID|SERV_ID" (preferencial) ou legado "AAASSS"
'   QT_ESTIMADA : quantidade estimada do serviço
'
' Fluxo:
'   1. Validar/PARSE COD_SERVICO — critério 1
'   2. Extrair ATIV_ID e SERV_ID
'   3. Buscar VALOR_UNIT em CAD_SERV (filtro ATIV_ID + SERV_ID) — critério 2
'   4. Chamar SelecionarEmpresa(ATIV_ID) — critério 3
'   5. Ler DIAS_DECISAO de GetConfig()
'   6. Gerar PREOS_ID via ProximoId(SHEET_PREOS) — critério 8
'   7. Gravar linha na aba PRE_OS — critérios 4-7
'   8. Auditoria EVT_PREOS_EMITIDA — critério 9
'
' Nota: NÃO chama AvancarFila — o avanço ocorre somente em
'       RecusarPreOS, ExpirarPreOS (punidos) e EmitirOS (aceite).
'
Public Function EmitirPreOS( _
    ByVal ENT_ID As String, _
    ByVal COD_SERVICO As String, _
    ByVal QT_ESTIMADA As Double _
) As TResult
    Dim res As TResult
    Dim ATIV_ID As String
    Dim SERV_ID As String
    Dim valorUnit As Currency
    Dim valorEst As Currency
    Dim cfg As TConfig
    Dim rodizio As TRodizioResultado
    Dim ws As Worksheet
    Dim linha As Long
    Dim preosId As String
    Dim dtLimite As Date
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    ' 1. Validar e extrair IDs do código (critério 1)
    If Not ExtrairIdsCodServico(COD_SERVICO, ATIV_ID, SERV_ID) Then
        res.Sucesso = False
        res.Mensagem = "COD_SERVICO invalido: " & COD_SERVICO
        EmitirPreOS = res
        Exit Function
    End If

    If Not EntidadeAtivaExiste(ENT_ID) Then
        res.Sucesso = False
        res.Mensagem = "Entidade inexistente ou inativa: ENT_ID=" & ENT_ID
        EmitirPreOS = res
        Exit Function
    End If

    If QT_ESTIMADA <= 0 Then
        res.Sucesso = False
        res.Mensagem = "QT_ESTIMADA deve ser maior que zero."
        EmitirPreOS = res
        Exit Function
    End If

    ' 2. Buscar VALOR_UNIT em CAD_SERV (critério 2)
    If Not BuscarValorServico(ATIV_ID, SERV_ID, valorUnit) Then
        res.Sucesso = False
        res.Mensagem = "Servico nao encontrado em CAD_SERV: ATIV=" & ATIV_ID & " SERV=" & SERV_ID
        EmitirPreOS = res
        Exit Function
    End If

    ' 3. Executar rodízio (critério 3)
    rodizio = SelecionarEmpresa(ATIV_ID)
    If Not rodizio.encontrou Then
        res.Sucesso = False
        Select Case UCase$(Trim$(rodizio.MotivoFalha))
            Case "SEM_CREDENCIADOS_CADASTRADOS", "SEM_CREDENCIADOS_APTOS"
                res.Mensagem = "Nao ha empresas credenciadas aptas para esta atividade. Credencie ao menos uma empresa na atividade selecionada."
            Case Else
                res.Mensagem = "Rodizio sem empresa apta: " & rodizio.MotivoFalha
        End Select
        If InStr(1, UCase$(rodizio.MotivoFalha), "SEM_CREDENCIADOS_APTOS", vbTextCompare) > 0 Then
            res.Mensagem = "Nao ha empresas credenciadas aptas para esta atividade. " & rodizio.MotivoFalha
        End If
        EmitirPreOS = res
        Exit Function
    End If

    ' 4. Calcular campos derivados (critérios 5-7)
    cfg = GetConfig()
    dtLimite = DateAdd("d", cfg.DIAS_DECISAO, Date)
    valorEst = valorUnit * QT_ESTIMADA

    ' 5. Gravar linha PRE_OS (critérios 4-8)
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        EmitirPreOS = res
        Exit Function
    End If
    preosId = ProximoId(SHEET_PREOS)
    linha = UltimaLinhaAba(SHEET_PREOS) + 1

    ws.Cells(linha, COL_PREOS_ID).Value = preosId
    ws.Cells(linha, COL_PREOS_ENT_ID).Value = ENT_ID
    ws.Cells(linha, COL_PREOS_COD_SERV).Value = ATIV_ID & "|" & SERV_ID
    ws.Cells(linha, COL_PREOS_EMP_ID).Value = rodizio.Empresa.EMP_ID
    ws.Cells(linha, COL_PREOS_DT_EMISSAO).Value = Now
    ws.Cells(linha, COL_PREOS_DT_LIMITE).Value = dtLimite
    ws.Cells(linha, COL_PREOS_ATIV_ID).Value = ATIV_ID
    ws.Cells(linha, COL_PREOS_DT_EM_OS).Value = ""
    ws.Cells(linha, COL_PREOS_QT_EST).Value = QT_ESTIMADA
    ws.Cells(linha, COL_PREOS_VL_EST).Value = valorEst
    ws.Cells(linha, COL_PREOS_VL_UNIT).Value = valorUnit
    ws.Cells(linha, COL_PREOS_STATUS).Value = STATUS_AGUARDANDO
    ws.Cells(linha, COL_PREOS_MOTIVO).Value = ""
    ws.Cells(linha, COL_PREOS_OS_ID).Value = ""

    ' 6. Auditoria (critério 9)
    Audit_Log.RegistrarEvento _
        EVT_PREOS_EMITIDA, ENT_PREOS, preosId, _
        "", _
        "STATUS=AGUARDANDO_ACEITE; EMP_ID=" & rodizio.Empresa.EMP_ID & _
        "; ATIV_ID=" & ATIV_ID & "; ENT_ID=" & ENT_ID & _
        "; QT=" & CStr(QT_ESTIMADA) & "; VL_EST=" & CStr(valorEst) & _
        "; DT_LIMITE=" & Format$(dtLimite, "DD/MM/YYYY"), _
        "Svc_PreOS"

    res.Sucesso = True
    res.Mensagem = "Pre-OS emitida. PREOS_ID=" & preosId & _
                   "; EMP_ID=" & rodizio.Empresa.EMP_ID & _
                   "; DT_LIMITE=" & Format$(dtLimite, "DD/MM/YYYY")
    res.IdGerado = preosId   ' critério 10
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    EmitirPreOS = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em EmitirPreOS: " & Err.Description
    res.CodigoErro = Err.Number
    EmitirPreOS = res
End Function

' ============================================================
' SEÇÃO 2: RECUSA E EXPIRAÇÃO
' ============================================================

' RecusarPreOS — registra recusa explícita da empresa/gestor.
'
' POLÍTICA AvancarFila: chamado ANTES de gravar PRE_OS.
'   Se AvancarFila falhar → Sucesso=False, PRE_OS inalterada (critério 46).
'
Public Function RecusarPreOS( _
    ByVal PREOS_ID As String, _
    ByVal motivo As String _
) As TResult
    Dim res As TResult
    Dim linhaPreOS As Long
    Dim empId As String
    Dim ativId As String
    Dim statusAtual As String
    Dim ws As Worksheet
    Dim resAv As TResult
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    ' 1. Localizar PRE_OS (critério 11)
    LerPreOS PREOS_ID, linhaPreOS, empId, ativId, statusAtual

    If linhaPreOS = 0 Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao encontrada: PREOS_ID=" & PREOS_ID
        RecusarPreOS = res
        Exit Function
    End If

    ' 2. Validar status (critério 12)
    If statusAtual <> STATUS_AGUARDANDO Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao pode ser recusada. STATUS=" & statusAtual
        RecusarPreOS = res
        Exit Function
    End If

    ' 3. AvancarFila ANTES de gravar PRE_OS (critérios 14 e 46)
    resAv = AvancarFila(empId, ativId, True, "RECUSA_EXPLICITA")
    If Not resAv.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao avançar fila: " & resAv.Mensagem & _
                       " | PRE_OS nao alterada. Tente novamente."
        RecusarPreOS = res
        Exit Function
    End If

    ' 4. Gravar STATUS e Motivo (critério 13)
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        RecusarPreOS = res
        Exit Function
    End If
    ws.Cells(linhaPreOS, COL_PREOS_STATUS).Value = STATUS_RECUSADA
    ws.Cells(linhaPreOS, COL_PREOS_MOTIVO).Value = motivo

    ' 5. Auditoria (critério 15)
    Audit_Log.RegistrarEvento _
        EVT_PREOS_RECUSADA, ENT_PREOS, PREOS_ID, _
        "STATUS=AGUARDANDO_ACEITE", _
        "STATUS=RECUSADA; MOTIVO=" & motivo & _
        "; EMP_ID=" & empId & "; ATIV_ID=" & ativId, _
        "Svc_PreOS"

    res.Sucesso = True
    res.Mensagem = "Pre-OS " & PREOS_ID & " recusada. EMP_ID=" & empId
    res.IdGerado = PREOS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    RecusarPreOS = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em RecusarPreOS: " & Err.Description
    res.CodigoErro = Err.Number
    RecusarPreOS = res
End Function

' ExpirarPreOS — marca Pré-OS como EXPIRADA por prazo vencido.
'
' POLÍTICA AvancarFila: chamado ANTES de gravar PRE_OS (critério 47).
'
Public Function ExpirarPreOS(ByVal PREOS_ID As String) As TResult
    Dim res As TResult
    Dim linhaPreOS As Long
    Dim empId As String
    Dim ativId As String
    Dim statusAtual As String
    Dim ws As Worksheet
    Dim resAv As TResult
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    LerPreOS PREOS_ID, linhaPreOS, empId, ativId, statusAtual

    If linhaPreOS = 0 Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao encontrada: PREOS_ID=" & PREOS_ID
        ExpirarPreOS = res
        Exit Function
    End If

    If statusAtual <> STATUS_AGUARDANDO Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao pode ser expirada. STATUS=" & statusAtual
        ExpirarPreOS = res
        Exit Function
    End If

    ' AvancarFila ANTES de gravar PRE_OS (critérios 18 e 47)
    resAv = AvancarFila(empId, ativId, True, "PRAZO_EXPIRADO")
    If Not resAv.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao avançar fila: " & resAv.Mensagem & _
                       " | PRE_OS nao alterada. Tente novamente."
        ExpirarPreOS = res
        Exit Function
    End If

    ' Gravar STATUS (critério 17)
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        ExpirarPreOS = res
        Exit Function
    End If
    ws.Cells(linhaPreOS, COL_PREOS_STATUS).Value = STATUS_EXPIRADA
    ws.Cells(linhaPreOS, COL_PREOS_MOTIVO).Value = "PRAZO_EXPIRADO"

    ' Auditoria (critério 19)
    Audit_Log.RegistrarEvento _
        EVT_PREOS_EXPIRADA, ENT_PREOS, PREOS_ID, _
        "STATUS=AGUARDANDO_ACEITE", _
        "STATUS=EXPIRADA; MOTIVO=PRAZO_EXPIRADO; EMP_ID=" & empId & _
        "; ATIV_ID=" & ativId, _
        "Svc_PreOS"

    res.Sucesso = True
    res.Mensagem = "Pre-OS " & PREOS_ID & " expirada. EMP_ID=" & empId
    res.IdGerado = PREOS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    ExpirarPreOS = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em ExpirarPreOS: " & Err.Description
    res.CodigoErro = Err.Number
    ExpirarPreOS = res
End Function

' ============================================================
' SEÇÃO 3: HELPERS PRIVADOS
' ============================================================

Private Sub LerPreOS( _
    ByVal PREOS_ID As String, _
    ByRef linhaOut As Long, _
    ByRef empIDOut As String, _
    ByRef ativIDOut As String, _
    ByRef statusOut As String _
)
    Dim ws As Worksheet
    Dim i As Long

    linhaOut = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(i, COL_PREOS_ID).Value, PREOS_ID) Then
            linhaOut = i
            empIDOut = CStr(ws.Cells(i, COL_PREOS_EMP_ID).Value)
            ativIDOut = CStr(ws.Cells(i, COL_PREOS_ATIV_ID).Value)
            statusOut = CStr(ws.Cells(i, COL_PREOS_STATUS).Value)
            Exit For
        End If
    Next i

fim:
End Sub

Private Function BuscarValorServico( _
    ByVal ATIV_ID As String, _
    ByVal SERV_ID As String, _
    ByRef valorOut As Currency _
) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    BuscarValorServico = False
    valorOut = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguais(ws.Cells(i, COL_SERV_ID).Value, SERV_ID) And _
           IdsIguais(ws.Cells(i, COL_SERV_ATIV_ID).Value, ATIV_ID) Then
            valorOut = CCur(Val(ws.Cells(i, COL_SERV_VALOR_UNIT).Value))
            BuscarValorServico = True
            Exit For
        End If
    Next i

fim:
End Function

Private Function EntidadeAtivaExiste(ByVal entId As String) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    EntidadeAtivaExiste = False
    If Trim$(entId) = "" Then Exit Function
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
        If IdsIguais(ws.Cells(i, COL_ENT_ID).Value, entId) Then
            EntidadeAtivaExiste = True
            Exit Function
        End If
    Next i

fim:
End Function

Private Function ExtrairIdsCodServico( _
    ByVal COD_SERVICO As String, _
    ByRef ATIV_ID As String, _
    ByRef SERV_ID As String _
) As Boolean
    Dim s As String
    Dim p As Long

    ExtrairIdsCodServico = False
    ATIV_ID = ""
    SERV_ID = ""

    s = Trim$(CStr(COD_SERVICO))
    If s = "" Then Exit Function

    ' Novo padrão: ATIV|SERV
    p = InStr(1, s, "|", vbBinaryCompare)
    If p > 1 Then
        ATIV_ID = Trim$(Left$(s, p - 1))
        SERV_ID = Trim$(Mid$(s, p + 1))
        ExtrairIdsCodServico = (ATIV_ID <> "" And SERV_ID <> "")
        Exit Function
    End If

    ' Legado: AAASSS
    If Len(s) >= 6 Then
        ATIV_ID = Left$(s, 3)
        SERV_ID = Mid$(s, 4)
        ExtrairIdsCodServico = (ATIV_ID <> "" And SERV_ID <> "")
    End If
End Function

' IdsEquivalentes removida — usar Util_Planilha.IdsIguais (V12-CLEAN).



