Attribute VB_Name = "Svc_Rodizio"
Option Explicit

' Serviço de Rodízio Centralizado - V10
' Implementa: SelecionarEmpresa, AvancarFila, Suspender, Reativar.
' Sem Select/ActiveCell/On Error Resume Next silencioso.
' Referência: doc/Time_AI/001-Sprint0-Maquina-de-Estados.md (seção 4 - Algoritmo)

' ============================================================
' CONSTANTES DE STATUS (evitar strings literais espalhadas)
' ============================================================
Private Const STATUS_EMP_ATIVA As String = "ATIVA"
Private Const STATUS_EMP_SUSPENSA As String = "SUSPENSA_GLOBAL"
Private Const STATUS_EMP_INATIVA As String = "INATIVA"
Private Const STATUS_CRED_ATIVO As String = "ATIVO"
Private Const MOTIVO_SEM_CREDENCIADOS As String = "SEM_CREDENCIADOS_APTOS"
Private Const MOTIVO_OS_ABERTA As String = "OS_ABERTA_NA_ATIVIDADE"

' ============================================================
' SEÇÃO 1: SELEÇÃO (Algoritmo Central de Rodízio)
' ============================================================

' SelecionarEmpresa - executa o algoritmo de rodízio para uma atividade.
'
' Algoritmo (conforme Máquina de Estados v1.0):
'   1. Buscar fila da atividade (CREDENCIADOS ordenados por POSICAO_FILA)
'   2. Para cada empresa na fila:
'      a. STATUS_CRED <> ATIVO → pular (sem punição)
'      b. STATUS_GLOBAL = SUSPENSA_GLOBAL → verificar reativação automática
'         - Se DT_FIM_SUSPENSAO <= Hoje → reativar e continuar avaliação
'         - Senão → pular (sem punição)
'      c. TemOSAbertaNaAtividade → mover para fim da fila SEM punição, pular
'      d. Empresa apta → registrar indicação (DT_ULTIMA_IND), retornar
'   3. Nenhuma apta → retornar Encontrou=False
'
' Nota: O avanço de fila definitivo (após aceite/recusa/expiração)
'       é responsabilidade de Svc_PreOS (Sprint 3), via AvancarFila().
'
Public Function SelecionarEmpresa(ByVal ATIV_ID As String) As TRodizioResultado
    Dim resultado As TRodizioResultado
    Dim fila() As TCredenciamento
    Dim cred As TCredenciamento
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim resOp As TResult
    Dim i As Long
    Dim cntFiltroA As Long
    Dim cntFiltroB As Long
    Dim cntFiltroC As Long
    Dim cntFiltroD As Long
    Dim cntFiltroE As Long
    Dim cntSemEmpresa As Long

    On Error GoTo Erro

    resultado.encontrou = False
    resultado.MotivoFalha = MOTIVO_SEM_CREDENCIADOS

    fila = BuscarFila(ATIV_ID)

    ' Verificar se a fila está vazia (sentinela: CRED_ID = "")
    If fila(LBound(fila)).CRED_ID = "" Then
        resultado.MotivoFalha = "SEM_CREDENCIADOS_CADASTRADOS"
        SelecionarEmpresa = resultado
        Exit Function
    End If

    For i = LBound(fila) To UBound(fila)
        cred = fila(i)

        ' FILTRO A: Credenciamento inativo/suspenso localmente → pular
        If cred.STATUS_CRED <> STATUS_CRED_ATIVO Then
            cntFiltroA = cntFiltroA + 1
            GoTo ProximaEmpresa
        End If

        ' Ler dados atuais da empresa na planilha
        emp = LerEmpresa(cred.EMP_ID, linhaEmp)

        If linhaEmp = 0 Then
            cntSemEmpresa = cntSemEmpresa + 1
            GoTo ProximaEmpresa  ' empresa não encontrada
        End If

        ' FILTRO B: Empresa suspensa globalmente
        If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
            ' Verificar reativação automática
            If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
                ' Reativar automaticamente - empresa volta a participar
                resOp = Reativar(cred.EMP_ID)
                If Not resOp.sucesso Then
                    cntFiltroB = cntFiltroB + 1
                    GoTo ProximaEmpresa
                End If
                ' Reler dados após reativação
                emp = LerEmpresa(cred.EMP_ID, linhaEmp)
            Else
                ' Ainda suspensa → pular sem punição
                cntFiltroB = cntFiltroB + 1
                GoTo ProximaEmpresa
            End If
        End If

        ' FILTRO C: Empresa inativa → pular
        If emp.STATUS_GLOBAL = STATUS_EMP_INATIVA Then
            cntFiltroC = cntFiltroC + 1
            GoTo ProximaEmpresa
        End If

        ' FILTRO D: Empresa tem OS aberta nesta atividade → pular SEM punição, mover para fim
        If TemOSAbertaNaAtividade(cred.EMP_ID, ATIV_ID) Then
            resOp = MoverFinal(cred.EMP_ID, ATIV_ID)
            ' Sem auditoria aqui - não é punição, é skip técnico
            cntFiltroD = cntFiltroD + 1
            GoTo ProximaEmpresa
        End If

        ' FILTRO E: Empresa tem Pre-OS pendente (AGUARDANDO_ACEITE) nesta atividade → pular SEM punição, SEM mover
        If TemPreOSPendenteNaAtividade(cred.EMP_ID, ATIV_ID) Then
            cntFiltroE = cntFiltroE + 1
            GoTo ProximaEmpresa
        End If

        ' EMPRESA APTA: selecionar
        resultado.encontrou = True
        resultado.MotivoFalha = ""
        resultado.Empresa = emp
        resultado.Credenciamento = cred

        ' Registrar indicação: atualizar DT_ULTIMA_IND sem mover na fila
        ' (a empresa permanece no topo até aceitar/recusar - Svc_PreOS avança depois)
        RegistrarIndicacao cred.EMP_ID, ATIV_ID, Now

        ' Nota: NÃO gravar auditoria aqui. A auditoria de emissão de Pré-OS
        ' é responsabilidade de Svc_PreOS.EmitirPreOS() (Sprint 3).
        ' SelecionarEmpresa é apenas a seleção do candidato.

        SelecionarEmpresa = resultado
        Exit Function

ProximaEmpresa:
    Next i

    ' Nenhuma empresa apta encontrada
    resultado.encontrou = False
    resultado.MotivoFalha = MontarMotivoSemAptos(cntFiltroA, cntFiltroB, cntFiltroC, cntFiltroD, cntFiltroE, cntSemEmpresa)
    SelecionarEmpresa = resultado
    Exit Function

Erro:
    resultado.encontrou = False
    resultado.MotivoFalha = "ERRO_INTERNO: " & Err.Description
    SelecionarEmpresa = resultado
End Function

' ============================================================
' SEÇÃO 2: AVANÇO DE FILA (chamado por Svc_PreOS no Sprint 3)
' ============================================================

' AvancarFila - move empresa para o fim da fila após aceite, recusa ou expiração.
'
' Parâmetros:
'   EMP_ID   : empresa a mover
'   ATIV_ID  : atividade (fila específica)
'   IsPunido : True  = recusa ou expiração → incrementar QTD_RECUSAS e verificar suspensão
'              False = aceite ou OS aberta → apenas mover, sem punição
'   Motivo   : string descritiva para auditoria (ex.: "RECUSA_EXPLICITA", "PRAZO_EXPIRADO",
'              "ACEITE_OS_EMITIDA", "OS_ABERTA_NA_ATIVIDADE")
'
Public Function AvancarFila( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    ByVal IsPunido As Boolean, _
    ByVal motivo As String _
) As TResult
    Dim res As TResult
    Dim resMove As TResult
    Dim resRec As TResult
    Dim resRollbackFila As TResult
    Dim cfg As TConfig
    Dim resSusp As TResult
    Dim novaRecusaGlobal As Long
    Dim tipoEvento As Long
    Dim linhaCredOriginal As Long
    Dim credOriginal As TCredenciamento
    Dim posicaoOriginal As Long

    On Error GoTo Erro

    credOriginal = BuscarPorEmpresaAtividade(EMP_ID, ATIV_ID, linhaCredOriginal)
    If linhaCredOriginal > 0 Then posicaoOriginal = credOriginal.POSICAO_FILA

    ' 1. Mover para o fim da fila
    resMove = MoverFinal(EMP_ID, ATIV_ID, Now)

    If Not resMove.sucesso Then
        res.sucesso = False
        res.mensagem = "Falha ao mover fila: " & resMove.mensagem
        AvancarFila = res
        Exit Function
    End If

    ' 2. Se punido: incrementar contadores e verificar suspensão
    If IsPunido Then
        resRec = IncrementarRecusa(EMP_ID, ATIV_ID)

        If Not resRec.sucesso Then
            If linhaCredOriginal > 0 Then
                resRollbackFila = RestaurarPosicaoFila(EMP_ID, ATIV_ID, posicaoOriginal, credOriginal.DT_ULTIMA_IND)
                RegistrarEvento _
                    EVT_TRANSACAO, ENT_CRED, EMP_ID, _
                    "EMP=" & EMP_ID & "; ATIV=" & ATIV_ID & "; POS_ANTES=" & CStr(posicaoOriginal), _
                    "ROLLBACK_FILA=" & IIf(resRollbackFila.sucesso, "OK", "FALHOU") & _
                    "; MOTIVO=INCREMENTAR_RECUSA_FALHOU; MSG=" & resRec.mensagem, _
                    "Svc_Rodizio"
            End If
            res.sucesso = False
            res.mensagem = "Falha ao incrementar recusa: " & resRec.mensagem
            AvancarFila = res
            Exit Function
        End If

        If resRec.sucesso Then
            ' Evita depender de campos de TResult em projetos antigos; lê o valor persistido.
            Dim empTmp As TEmpresa
            Dim linhaEmpTmp As Long
            empTmp = LerEmpresa(EMP_ID, linhaEmpTmp)
            If linhaEmpTmp > 0 Then
                novaRecusaGlobal = empTmp.QTD_RECUSAS
            Else
                novaRecusaGlobal = 0
            End If

            cfg = GetConfig()

            If novaRecusaGlobal >= cfg.MAX_RECUSAS Then
                resSusp = Suspender(EMP_ID)
                ' Suspensão registra sua própria auditoria
            End If

            ' Auditoria do avanço com punição (dentro do If Sucesso)
            ' Selecionar evento correto: RECUSADA vs EXPIRADA
            If InStr(1, motivo, "EXPIRAD", vbTextCompare) > 0 Then
                tipoEvento = EVT_PREOS_EXPIRADA
            Else
                tipoEvento = EVT_PREOS_RECUSADA
            End If

            RegistrarEvento _
                tipoEvento, ENT_CRED, EMP_ID, _
                "QTD_RECUSAS_ANTERIOR=" & CStr(novaRecusaGlobal - 1), _
                "MOTIVO=" & motivo & "; QTD_RECUSAS_GLOBAL=" & novaRecusaGlobal & "; ATIV=" & ATIV_ID, _
                "Svc_Rodizio"
        End If
    End If

    res.sucesso = True
    res.mensagem = "Fila avancada. EMP=" & EMP_ID & " ATIV=" & ATIV_ID & " PUNIDO=" & CStr(IsPunido)
    res.IdGerado = EMP_ID
    AvancarFila = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro em AvancarFila: " & Err.Description
    res.CodigoErro = Err.Number
    AvancarFila = res
End Function

' ============================================================
' SEÇÃO 3: SUSPENSÃO E REATIVAÇÃO
' ============================================================

' Suspender - coloca empresa em SUSPENSA_GLOBAL.
' Chamada automaticamente por AvancarFila quando MAX_RECUSAS é atingido.
' Pode também ser chamada manualmente pelo gestor (futuro Sprint 4).
'
Public Function Suspender( _
    ByVal EMP_ID As String, _
    Optional ByVal diasSuspensao As Long = 0, _
    Optional ByVal motivo As String = "" _
) As TResult
    Dim res As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim cfg As TConfig
    Dim dtFimSusp As Date
    Dim base As String
    Dim baseTexto As String

    On Error GoTo Erro

    emp = LerEmpresa(EMP_ID, linhaEmp)

    If linhaEmp = 0 Then
        res.sucesso = False
        res.mensagem = "Empresa nao encontrada: EMP_ID=" & EMP_ID
        Suspender = res
        Exit Function
    End If

    If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
        ' Já suspensa: não fazer nada (idempotente)
        res.sucesso = True
        res.mensagem = "Empresa ja estava suspensa."
        Suspender = res
        Exit Function
    End If

    ' V12.0.0203 ONDA 1 - Suspensao em dias quando informado;
    ' fallback historico em meses (PERIODO_SUSPENSAO_MESES) quando nao.
    ' Compatibilidade: chamadores antigos sem parametros continuam usando meses.
    If diasSuspensao > 0 Then
        dtFimSusp = DateAdd("d", diasSuspensao, Date)
        base = "DIAS"
        baseTexto = "DIAS=" & CStr(diasSuspensao)
    Else
        cfg = GetConfig()
        dtFimSusp = DateAdd("m", cfg.PERIODO_SUSPENSAO_MESES, Date)
        base = "MESES"
        baseTexto = "MESES=" & cfg.PERIODO_SUSPENSAO_MESES
    End If

    ' Gravar status de suspensão
    GravarStatusEmpresa linhaEmp, STATUS_EMP_SUSPENSA, dtFimSusp, -1

    ' Auditoria
    RegistrarEvento _
        EVT_SUSPENSAO, ENT_EMP, EMP_ID, _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "STATUS=SUSPENSA_GLOBAL; DT_FIM_SUSP=" & Format$(dtFimSusp, "DD/MM/YYYY") & _
        "; BASE=" & base & "; " & baseTexto & _
        IIf(Trim$(motivo) = "", "", "; MOTIVO=" & motivo), _
        "Svc_Rodizio"

    res.sucesso = True
    res.mensagem = "Empresa EMP_ID=" & EMP_ID & " suspensa ate " & Format$(dtFimSusp, "DD/MM/YYYY") & _
                   " (BASE=" & base & ")"
    res.IdGerado = EMP_ID
    Suspender = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro em Suspender: " & Err.Description
    res.CodigoErro = Err.Number
    Suspender = res
End Function

' Reativar - reverte suspensão global de uma empresa.
' Chamada automaticamente por SelecionarEmpresa quando DT_FIM_SUSPENSAO <= Hoje.
' Pode também ser chamada pelo gestor antes do prazo (futuro Sprint 4).
'
Public Function Reativar(ByVal EMP_ID As String) As TResult
    Dim res As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long

    On Error GoTo Erro

    emp = LerEmpresa(EMP_ID, linhaEmp)

    If linhaEmp = 0 Then
        res.sucesso = False
        res.mensagem = "Empresa nao encontrada: EMP_ID=" & EMP_ID
        Reativar = res
        Exit Function
    End If

    Reativar = ReativarLinhaEmpresa(linhaEmp, "Svc_Rodizio")
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro em Reativar: " & Err.Description
    res.CodigoErro = Err.Number
    Reativar = res
End Function

Public Function ReativarLinhaEmpresa( _
    ByVal linhaEmp As Long, _
    Optional ByVal origem As String = "Svc_Rodizio" _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim empId As String
    Dim idAuditoria As String
    Dim statusAnterior As String
    Dim qtdRecusasAnterior As Long
    Dim dtReativ As Date
    Dim dtGravada As Variant

    On Error GoTo Erro

    If linhaEmp < PrimeiraLinhaDadosEmpresas() Then
        res.sucesso = False
        res.mensagem = "Linha invalida para reativacao: " & CStr(linhaEmp)
        ReativarLinhaEmpresa = res
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If linhaEmp > UltimaLinhaAba(SHEET_EMPRESAS) Then
        res.sucesso = False
        res.mensagem = "Linha fora da aba EMPRESAS: " & CStr(linhaEmp)
        ReativarLinhaEmpresa = res
        Exit Function
    End If

    empId = Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_ID).Value))
    idAuditoria = empId
    If Len(idAuditoria) = 0 Then idAuditoria = Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_CNPJ).Value))
    If Len(idAuditoria) = 0 Then idAuditoria = "LINHA=" & CStr(linhaEmp)

    statusAnterior = Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value))
    qtdRecusasAnterior = CLng(Val("0" & Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_QTD_RECUSAS).Value))))
    dtReativ = Now

    ' Reativacao centralizada tambem para fluxos UI que movem a linha
    ' de EMPRESAS_INATIVAS para EMPRESAS antes de chamar o servico.
    GravarStatusEmpresa linhaEmp, STATUS_EMP_ATIVA, CDate(0), 0, dtReativ

    If Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value)) <> STATUS_EMP_ATIVA Then
        Err.Raise 1004, "ReativarLinhaEmpresa", "STATUS_GLOBAL nao foi gravado como ATIVA."
    End If

    If CLng(Val("0" & Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_QTD_RECUSAS).Value)))) <> 0 Then
        Err.Raise 1004, "ReativarLinhaEmpresa", "QTD_RECUSAS_GLOBAL nao foi zerado."
    End If

    dtGravada = ws.Cells(linhaEmp, COL_EMP_DT_ULT_REATIV).Value
    If Not IsDate(dtGravada) Then
        Err.Raise 1004, "ReativarLinhaEmpresa", "DT_ULT_REATIV nao foi gravada."
    End If
    If CDate(dtGravada) <= CDate(0) Then
        Err.Raise 1004, "ReativarLinhaEmpresa", "DT_ULT_REATIV ficou vazia."
    End If

    RegistrarEvento _
        EVT_REATIVACAO, ENT_EMP, idAuditoria, _
        "STATUS=" & statusAnterior & "; QTD_RECUSAS=" & CStr(qtdRecusasAnterior), _
        "STATUS=ATIVA; QTD_RECUSAS_GLOBAL=0; DT_FIM_SUSP=(limpa); DT_ULT_REATIV=" & _
            Format$(CDate(dtGravada), "DD/MM/YYYY HH:NN:SS"), _
        origem

    res.sucesso = True
    res.mensagem = "Empresa " & idAuditoria & " reativada."
    res.IdGerado = empId
    ReativarLinhaEmpresa = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro em ReativarLinhaEmpresa: " & Err.Description
    res.CodigoErro = Err.Number
    ReativarLinhaEmpresa = res
End Function

' ============================================================
' SEÇÃO 4: HELPERS PRIVADOS
' ============================================================

' Registra a data de indicação na linha do credenciamento sem mover a posição.
' Chamado quando uma empresa é selecionada pelo rodízio.
Private Sub RegistrarIndicacao( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    ByVal dtIndicacao As Date _
)
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then GoTo fim
    abaPreparada = True

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(i, COL_CRED_EMP_ID).Value, EMP_ID) And _
           IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            ws.Cells(i, COL_CRED_DT_ULT_IND).Value = dtIndicacao
            Exit For
        End If
    Next i

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    abaPreparada = False

fim:
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
End Sub

' IdsIguais removida - usar Util_Planilha.IdsIguais (V12-CLEAN).

Private Function MontarMotivoSemAptos( _
    ByVal cntA As Long, _
    ByVal cntB As Long, _
    ByVal cntC As Long, _
    ByVal cntD As Long, _
    ByVal cntE As Long, _
    ByVal cntSemEmp As Long _
) As String
    Dim motivo As String

    motivo = MOTIVO_SEM_CREDENCIADOS & _
             ";A=" & CStr(cntA) & _
             ";B=" & CStr(cntB) & _
             ";C=" & CStr(cntC) & _
             ";D=" & CStr(cntD) & _
             ";E=" & CStr(cntE) & _
             ";SEM_EMP=" & CStr(cntSemEmp)

    If cntE > 0 Then
        If (cntA + cntB + cntC + cntD + cntSemEmp) = 0 Then
            motivo = motivo & ";BLOQUEIO=PREOS_PENDENTE"
        Else
            motivo = motivo & ";BLOQUEIO=MISTO;DETALHE=PREOS_PENDENTE_PRESENTE"
        End If
    End If
    MontarMotivoSemAptos = motivo
End Function


