Attribute VB_Name = "Repo_PreOS"
Option Explicit

' Repositório da aba PRE_OS — V10
' Usa Const_Colunas para mapeamento. Sem Select/ActiveCell.

Private Const STATUS_PREOS_AGUARDANDO_ACEITE As String = "AGUARDANDO_ACEITE"
Private Const STATUS_PREOS_CONVERTIDA_OS As String = "CONVERTIDA_OS"

' Insere nova Pré-OS. Gera PREOS_ID automaticamente.
Public Function Inserir(ByRef p As TPreOS) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        Inserir = res
        Exit Function
    End If

    ' Gerar ID
    p.PREOS_ID = ProximoId(SHEET_PREOS)

    ' Encontrar próxima linha vazia
    linha = UltimaLinhaAba(SHEET_PREOS) + 1

    ' Gravar todos os campos
    ws.Cells(linha, COL_PREOS_ID).Value = p.PREOS_ID
    ws.Cells(linha, COL_PREOS_ENT_ID).Value = p.ENT_ID
    ws.Cells(linha, COL_PREOS_COD_SERV).Value = p.ATIV_ID & "|" & p.SERV_ID
    ws.Cells(linha, COL_PREOS_EMP_ID).Value = p.EMP_ID
    ws.Cells(linha, COL_PREOS_DT_EMISSAO).Value = p.DT_GERACAO
    ws.Cells(linha, COL_PREOS_DT_LIMITE).Value = p.DT_LIMITE_ACEITE
    ws.Cells(linha, COL_PREOS_ATIV_ID).Value = p.ATIV_ID
    ' COL_PREOS_DT_EM_OS fica vazio (será preenchido ao converter em OS)
    ws.Cells(linha, COL_PREOS_QT_EST).Value = p.QT_ESTIMADA
    ws.Cells(linha, COL_PREOS_VL_EST).Value = p.VALOR_ESTIMADO
    ws.Cells(linha, COL_PREOS_VL_UNIT).Value = p.VALOR_UNIT
    ws.Cells(linha, COL_PREOS_STATUS).Value = p.STATUS_PREOS
    ws.Cells(linha, COL_PREOS_MOTIVO).Value = p.MOTIVO_STATUS
    ' COL_PREOS_OS_ID fica vazio

    res.Sucesso = True
    res.Mensagem = "Pre-OS inserida com sucesso."
    res.IdGerado = p.PREOS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao inserir Pre-OS: " & Err.Description
    res.CodigoErro = Err.Number
    Inserir = res
End Function

' Busca Pré-OS por ID. Retorna struct preenchida.
Public Function BuscarPorId(ByVal PREOS_ID As String) As TPreOS
    Dim p As TPreOS
    Dim ws As Worksheet
    Dim i As Long

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(CStr(ws.Cells(i, COL_PREOS_ID).Value), PREOS_ID) Then
            p.PREOS_ID = CStr(ws.Cells(i, COL_PREOS_ID).Value)
            p.ENT_ID = CStr(ws.Cells(i, COL_PREOS_ENT_ID).Value)
            p.ATIV_ID = CStr(ws.Cells(i, COL_PREOS_ATIV_ID).Value)
            p.SERV_ID = ExtrairServId(CStr(ws.Cells(i, COL_PREOS_COD_SERV).Value), p.ATIV_ID)
            p.EMP_ID = CStr(ws.Cells(i, COL_PREOS_EMP_ID).Value)
            p.DT_GERACAO = ws.Cells(i, COL_PREOS_DT_EMISSAO).Value
            p.DT_LIMITE_ACEITE = ws.Cells(i, COL_PREOS_DT_LIMITE).Value
            p.QT_ESTIMADA = CDbl(Val(ws.Cells(i, COL_PREOS_QT_EST).Value))
            p.VALOR_ESTIMADO = CCur(Val(ws.Cells(i, COL_PREOS_VL_EST).Value))
            p.VALOR_UNIT = CCur(Val(ws.Cells(i, COL_PREOS_VL_UNIT).Value))
            p.STATUS_PREOS = CStr(ws.Cells(i, COL_PREOS_STATUS).Value)
            p.MOTIVO_STATUS = CStr(ws.Cells(i, COL_PREOS_MOTIVO).Value)
            Exit For
        End If
    Next i

fim:
    BuscarPorId = p
End Function

Private Function ExtrairServId(ByVal codServ As String, ByVal ativId As String) As String
    Dim p As Long
    Dim s As String
    Dim a As String

    s = Trim$(CStr(codServ))
    a = Trim$(CStr(ativId))
    If s = "" Then Exit Function

    p = InStr(1, s, "|", vbBinaryCompare)
    If p > 1 Then
        ExtrairServId = Trim$(Mid$(s, p + 1))
        Exit Function
    End If

    If a <> "" Then
        If Left$(s, Len(a)) = a Then
            ExtrairServId = Mid$(s, Len(a) + 1)
            Exit Function
        End If
    End If

    If Len(s) >= 4 Then ExtrairServId = Mid$(s, 4)
End Function

' Verifica se existe Pre-OS com status AGUARDANDO_ACEITE para a mesma empresa e atividade.
' Usado por Svc_Rodizio para pular empresa sem punicao (evitar dupla indicacao simultanea).
Public Function TemPreOSPendenteNaAtividade( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String _
) As Boolean
    Dim ws As Worksheet
    Dim i As Long
    Dim empIdCel As String
    Dim ativIdCel As String
    Dim statusCel As String

    TemPreOSPendenteNaAtividade = False
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        empIdCel = Trim$(CStr(ws.Cells(i, COL_PREOS_EMP_ID).Value))
        ativIdCel = Trim$(CStr(ws.Cells(i, COL_PREOS_ATIV_ID).Value))
        statusCel = Trim$(UCase$(CStr(ws.Cells(i, COL_PREOS_STATUS).Value)))

        If IdsIguais(empIdCel, EMP_ID) And IdsIguais(ativIdCel, ATIV_ID) And statusCel = STATUS_PREOS_AGUARDANDO_ACEITE Then
            TemPreOSPendenteNaAtividade = True
            Exit Function
        End If
    Next i

fim:
End Function

' IdsIguais removida — usar Util_Planilha.IdsIguais (V12-CLEAN).

' Atualiza status e motivo de uma Pré-OS.
Public Function AtualizarStatus( _
    ByVal PREOS_ID As String, _
    ByVal NovoStatus As String, _
    Optional ByVal motivo As String = "", _
    Optional ByVal OS_ID As String = "" _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        AtualizarStatus = res
        Exit Function
    End If

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(CStr(ws.Cells(i, COL_PREOS_ID).Value), PREOS_ID) Then
            ws.Cells(i, COL_PREOS_STATUS).Value = NovoStatus
            If motivo <> "" Then ws.Cells(i, COL_PREOS_MOTIVO).Value = motivo
            If OS_ID <> "" Then ws.Cells(i, COL_PREOS_OS_ID).Value = OS_ID
            If Trim$(UCase$(NovoStatus)) = STATUS_PREOS_CONVERTIDA_OS Then
                ws.Cells(i, COL_PREOS_DT_EM_OS).Value = Now
            End If

            res.Sucesso = True
            res.Mensagem = "Status atualizado para " & NovoStatus
            res.IdGerado = PREOS_ID
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            AtualizarStatus = res
            Exit Function
        End If
    Next i

    res.Sucesso = False
    res.Mensagem = "Pre-OS ID " & PREOS_ID & " nao encontrada."
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    AtualizarStatus = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao atualizar Pre-OS: " & Err.Description
    res.CodigoErro = Err.Number
    AtualizarStatus = res
End Function


