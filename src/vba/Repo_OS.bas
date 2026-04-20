Attribute VB_Name = "Repo_OS"
Option Explicit

' Repositório da aba CAD_OS — V10
' Usa Const_Colunas para mapeamento. Sem Select/ActiveCell.

Private Const STATUS_OS_EM_EXECUCAO As String = "EM_EXECUCAO"

' Insere nova OS. Gera OS_ID automaticamente.
Public Function Inserir(ByRef O As TOS) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        Inserir = res
        Exit Function
    End If

    O.OS_ID = ProximoId(SHEET_CAD_OS)
    linha = UltimaLinhaAba(SHEET_CAD_OS) + 1

    ws.Cells(linha, COL_OS_ID).Value = O.OS_ID
    ws.Cells(linha, COL_OS_ENT_ID).Value = O.ENT_ID
    ws.Cells(linha, COL_OS_COD_SERV).Value = O.ATIV_ID & "|" & O.SERV_ID
    ws.Cells(linha, COL_OS_EMP_ID).Value = O.EMP_ID
    ws.Cells(linha, COL_OS_EMPENHO).Value = O.NUM_EMPENHO
    ws.Cells(linha, COL_OS_DT_EMISSAO).Value = O.DT_EMISSAO
    ws.Cells(linha, COL_OS_DT_PREV_FIM).Value = O.DT_PREV_TERMINO
    ' DT_FECHAMENTO vazio
    ws.Cells(linha, COL_OS_QT_EST).Value = O.QT_ESTIMADA
    ws.Cells(linha, COL_OS_VL_TOTAL).Value = O.VALOR_TOTAL_OS
    ' QT_EXEC, VL_EXEC, DT_PAGTO, NOTAS vazias
    ws.Cells(linha, COL_OS_ATIV_ID).Value = O.ATIV_ID
    ws.Cells(linha, COL_OS_PREOS_ID).Value = O.PREOS_ID
    ws.Cells(linha, COL_OS_STATUS).Value = O.STATUS_OS
    ws.Cells(linha, COL_OS_VL_UNIT).Value = O.VALOR_UNIT
    ' JUSTIF_DIVERGENCIA vazio

    res.Sucesso = True
    res.Mensagem = "OS inserida com sucesso."
    res.IdGerado = O.OS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao inserir OS: " & Err.Description
    res.CodigoErro = Err.Number
    Inserir = res
End Function

' Busca OS por ID.
Public Function BuscarPorId(ByVal OS_ID As String) As TOS
    Dim O As TOS
    Dim ws As Worksheet
    Dim i As Long

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, OS_ID) Then
            O.OS_ID = CStr(ws.Cells(i, COL_OS_ID).Value)
            O.ENT_ID = CStr(ws.Cells(i, COL_OS_ENT_ID).Value)
            O.ATIV_ID = CStr(ws.Cells(i, COL_OS_ATIV_ID).Value)
            O.SERV_ID = ExtrairServId(CStr(ws.Cells(i, COL_OS_COD_SERV).Value), O.ATIV_ID)
            O.EMP_ID = CStr(ws.Cells(i, COL_OS_EMP_ID).Value)
            O.NUM_EMPENHO = CStr(ws.Cells(i, COL_OS_EMPENHO).Value)
            O.DT_EMISSAO = ws.Cells(i, COL_OS_DT_EMISSAO).Value
            O.DT_PREV_TERMINO = ws.Cells(i, COL_OS_DT_PREV_FIM).Value
            O.QT_ESTIMADA = CDbl(Val(ws.Cells(i, COL_OS_QT_EST).Value))
            O.QT_CONFIRMADA = CDbl(Val(ws.Cells(i, COL_OS_QT_EXEC).Value))
            O.VALOR_UNIT = CCur(Val(ws.Cells(i, COL_OS_VL_UNIT).Value))
            O.VALOR_TOTAL_OS = CCur(Val(ws.Cells(i, COL_OS_VL_TOTAL).Value))
            O.PREOS_ID = CStr(ws.Cells(i, COL_OS_PREOS_ID).Value)
            O.STATUS_OS = CStr(ws.Cells(i, COL_OS_STATUS).Value)
            O.JUSTIF_DIVERGENCIA = CStr(ws.Cells(i, COL_OS_JUSTIF_DIV).Value)
            O.DT_FECHAMENTO = ws.Cells(i, COL_OS_DT_FECHAMENTO).Value
            Exit For
        End If
    Next i

fim:
    BuscarPorId = O
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

' Atualiza registro de OS existente.
Public Function Atualizar(ByRef O As TOS) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        Atualizar = res
        Exit Function
    End If

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, O.OS_ID) Then
            ws.Cells(i, COL_OS_DT_FECHAMENTO).Value = O.DT_FECHAMENTO
            ws.Cells(i, COL_OS_QT_EXEC).Value = O.QT_CONFIRMADA
            ws.Cells(i, COL_OS_VL_EXEC).Value = O.QT_CONFIRMADA * O.VALOR_UNIT
            ws.Cells(i, COL_OS_STATUS).Value = O.STATUS_OS
            ws.Cells(i, COL_OS_JUSTIF_DIV).Value = O.JUSTIF_DIVERGENCIA
            ws.Cells(i, COL_OS_OBSERVACOES).Value = ""

            res.Sucesso = True
            res.Mensagem = "OS atualizada com sucesso."
            res.IdGerado = O.OS_ID
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            Atualizar = res
            Exit Function
        End If
    Next i

    res.Sucesso = False
    res.Mensagem = "OS ID " & O.OS_ID & " nao encontrada."
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Atualizar = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao atualizar OS: " & Err.Description
    res.CodigoErro = Err.Number
    Atualizar = res
End Function

' Verifica se empresa tem OS aberta (EM_EXECUCAO) em uma atividade.
Public Function TemOSAbertaNaAtividade( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String _
) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    On Error GoTo fim

    TemOSAbertaNaAtividade = False
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_EMP_ID).Value, EMP_ID) And _
           IdsIguais(ws.Cells(i, COL_OS_ATIV_ID).Value, ATIV_ID) And _
           Trim$(UCase$(CStr(ws.Cells(i, COL_OS_STATUS).Value))) = STATUS_OS_EM_EXECUCAO Then
            TemOSAbertaNaAtividade = True
            Exit Function
        End If
    Next i

fim:
End Function

' IdsIguais removida — usar Util_Planilha.IdsIguais (V12-CLEAN).


