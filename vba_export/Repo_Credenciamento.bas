Attribute VB_Name = "Repo_Credenciamento"
Option Explicit

' Repositório da aba CREDENCIADOS — V10
' Gerencia fila de rodízio por atividade.
' Usa Const_Colunas. Sem Select/ActiveCell/On Error Resume Next silencioso.
' Nota: helpers de EMPRESAS aqui são temporários até Repo_Empresa existir (Sprint 4).

' ============================================================
' SEÇÃO 1: OPERAÇÕES NA ABA CREDENCIADOS
' ============================================================

' Retorna todos os credenciamentos de uma atividade, ordenados por POSICAO_FILA.
' Se não houver registros, retorna array de 1 elemento com CRED_ID="" (sentinela).
' O chamador deve verificar: If fila(LBound(fila)).CRED_ID = "" Then → fila vazia.
Public Function BuscarFila(ByVal ATIV_ID As String) As TCredenciamento()
    Dim ws As Worksheet
    Dim resultado() As TCredenciamento
    Dim count As Long
    Dim i As Long
    Dim ult As Long
    Dim temp As TCredenciamento
    Dim j As Long

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    ult = UltimaLinhaAba(SHEET_CREDENCIADOS)
    count = 0

    ' Primeira passagem: contar registros válidos
    For i = LINHA_DADOS To ult
        If IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            count = count + 1
        End If
    Next i

    If count = 0 Then
        ' Retornar sentinela (array vazio não é suportado em VBA com UDT)
        ReDim resultado(1 To 1)
        resultado(1).CRED_ID = ""
        BuscarFila = resultado
        Exit Function
    End If

    ReDim resultado(1 To count)
    count = 0

    ' Segunda passagem: preencher array
    For i = LINHA_DADOS To ult
        If IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            count = count + 1
            resultado(count) = LerCredenciamento(ws, i)
        End If
    Next i

    ' Ordenação por POSICAO_FILA (bubble sort — fila tipicamente pequena)
    Dim trocou As Boolean
    Do
        trocou = False
        For j = 1 To count - 1
            If resultado(j).POSICAO_FILA > resultado(j + 1).POSICAO_FILA Then
                temp = resultado(j)
                resultado(j) = resultado(j + 1)
                resultado(j + 1) = temp
                trocou = True
            End If
        Next j
    Loop While trocou

    BuscarFila = resultado
    Exit Function

Erro:
    ReDim resultado(1 To 1)
    resultado(1).CRED_ID = ""
    BuscarFila = resultado
End Function

' Busca credenciamento específico por EMP_ID + ATIV_ID.
' Retorna a linha da planilha em linhaOut (0 = não encontrado).
Public Function BuscarPorEmpresaAtividade( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    ByRef linhaOut As Long _
) As TCredenciamento
    Dim ws As Worksheet
    Dim cred As TCredenciamento
    Dim i As Long

    linhaOut = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(i, COL_CRED_EMP_ID).Value, EMP_ID) And _
           IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            linhaOut = i
            cred = LerCredenciamento(ws, i)
            Exit For
        End If
    Next i

fim:
    BuscarPorEmpresaAtividade = cred
End Function

' Move empresa para o fim da fila da atividade.
' Calcula a nova POSICAO_FILA = MAX_POSICAO_ATUAL + 1.
' Atualiza DT_ULTIMA_INDICACAO se dtIndicacao for fornecida (> 0).
Public Function MoverFinal( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    Optional ByVal dtIndicacao As Date = 0 _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim linhaAlvo As Long
    Dim novaPos As Long
    Dim cred As TCredenciamento

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    cred = BuscarPorEmpresaAtividade(EMP_ID, ATIV_ID, linhaAlvo)

    If linhaAlvo = 0 Then
        res.Sucesso = False
        res.Mensagem = "Credenciamento nao encontrado: EMP=" & EMP_ID & " ATIV=" & ATIV_ID
        MoverFinal = res
        Exit Function
    End If

    novaPos = MaxPosicaoFila(ATIV_ID) + 1
    ws.Cells(linhaAlvo, COL_CRED_POSICAO).Value = novaPos

    If dtIndicacao > 0 Then
        ws.Cells(linhaAlvo, COL_CRED_DT_ULT_IND).Value = dtIndicacao
    End If

    res.Sucesso = True
    res.Mensagem = "Empresa EMP_ID=" & EMP_ID & " movida para posicao " & novaPos & " na fila ATIV=" & ATIV_ID
    res.IdGerado = EMP_ID
    MoverFinal = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em MoverFinal: " & Err.Description
    res.CodigoErro = Err.Number
    MoverFinal = res
End Function

' Incrementa QTD_RECUSAS_ATIV em CREDENCIADOS (+1).
' Incrementa QTD_RECUSAS_GLOBAL em EMPRESAS (+1).
' Retorna os novos valores em res.Mensagem (para Svc_Rodizio verificar suspensão).
' res.IdGerado = novo valor de QTD_RECUSAS_GLOBAL (String).
Public Function IncrementarRecusa( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String _
) As TResult
    Dim res As TResult
    Dim wsCred As Worksheet
    Dim wsEmp As Worksheet
    Dim i As Long
    Dim linhaEmp As Long
    Dim novaRecusaAtiv As Long
    Dim novaRecusaGlobal As Long
    Dim achouCred As Boolean
    Dim achouEmp As Boolean

    On Error GoTo Erro

    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    achouCred = False
    achouEmp = False

    ' Incrementar QTD_RECUSAS_ATIV em CREDENCIADOS
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(wsCred.Cells(i, COL_CRED_EMP_ID).Value, EMP_ID) And _
           IdsIguais(wsCred.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            achouCred = True
            novaRecusaAtiv = CLng(Val(wsCred.Cells(i, COL_CRED_RECUSAS).Value)) + 1
            wsCred.Cells(i, COL_CRED_RECUSAS).Value = novaRecusaAtiv
            Exit For
        End If
    Next i

    ' Incrementar QTD_RECUSAS_GLOBAL em EMPRESAS
    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(wsEmp.Cells(i, COL_EMP_ID).Value, EMP_ID) Then
            achouEmp = True
            linhaEmp = i
            novaRecusaGlobal = CLng(Val(wsEmp.Cells(i, COL_EMP_QTD_RECUSAS).Value)) + 1
            wsEmp.Cells(i, COL_EMP_QTD_RECUSAS).Value = novaRecusaGlobal
            wsEmp.Cells(i, COL_EMP_DT_ULT_ALT).Value = Now
            Exit For
        End If
    Next i

    ' Validar que ambos os registros foram encontrados
    If Not achouCred Or Not achouEmp Then
        res.Sucesso = False
        If Not achouCred And Not achouEmp Then
            res.Mensagem = "Credenciamento e empresa nao encontrados: EMP=" & EMP_ID & " ATIV=" & ATIV_ID
        ElseIf Not achouCred Then
            res.Mensagem = "Credenciamento nao encontrado: EMP=" & EMP_ID & " ATIV=" & ATIV_ID
        Else
            res.Mensagem = "Empresa nao encontrada: EMP=" & EMP_ID
        End If
        IncrementarRecusa = res
        Exit Function
    End If

    res.Sucesso = True
    res.Mensagem = "Recusas: ATIV=" & novaRecusaAtiv & " GLOBAL=" & novaRecusaGlobal
    res.IdGerado = CStr(novaRecusaGlobal)   ' Svc_Rodizio usa para verificar suspensão
    IncrementarRecusa = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em IncrementarRecusa: " & Err.Description
    res.CodigoErro = Err.Number
    IncrementarRecusa = res
End Function

' ============================================================
' SEÇÃO 2: HELPERS PRIVADOS
' ============================================================
' NOTA V12-CLEAN: LerEmpresa e GravarStatusEmpresa movidas para Repo_Empresa.bas.

' Retorna a maior POSICAO_FILA existente para uma atividade.
' Retorna 0 se nenhum registro existir.
Private Function MaxPosicaoFila(ByVal ATIV_ID As String) As Long
    Dim ws As Worksheet
    Dim i As Long
    Dim maxPos As Long
    Dim pos As Long

    maxPos = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            pos = CLng(Val(ws.Cells(i, COL_CRED_POSICAO).Value))
            If pos > maxPos Then maxPos = pos
        End If
    Next i

fim:
    MaxPosicaoFila = maxPos
End Function

' IdsIguais removida — usar Util_Planilha.IdsIguais (V12-CLEAN).

' Preenche um TCredenciamento a partir de uma linha da aba CREDENCIADOS.
Private Function LerCredenciamento(ByVal ws As Worksheet, ByVal linha As Long) As TCredenciamento
    Dim c As TCredenciamento
    c.CRED_ID = CStr(ws.Cells(linha, COL_CRED_ID).Value)
    c.EMP_ID = CStr(ws.Cells(linha, COL_CRED_EMP_ID).Value)
    c.ATIV_ID = CStr(ws.Cells(linha, COL_CRED_ATIV_ID).Value)
    c.COD_SERVICO = CStr(ws.Cells(linha, COL_CRED_COD_ATIV_SERV).Value)
    c.STATUS_CRED = CStr(ws.Cells(linha, COL_CRED_STATUS).Value)
    c.POSICAO_FILA = CLng(Val(ws.Cells(linha, COL_CRED_POSICAO).Value))
    c.QTD_RECUSAS = CLng(Val(ws.Cells(linha, COL_CRED_RECUSAS).Value))
    c.QTD_EXPIRACOES = CLng(Val(ws.Cells(linha, COL_CRED_EXPIRACOES).Value))

    Dim rawDt As Variant
    rawDt = ws.Cells(linha, COL_CRED_DT_ULT_IND).Value
    If IsDate(rawDt) Then
        c.DT_ULTIMA_IND = CDate(rawDt)
    Else
        c.DT_ULTIMA_IND = CDate(0)
    End If

    Dim rawDtCred As Variant
    rawDtCred = ws.Cells(linha, COL_CRED_DT_CRED).Value
    If IsDate(rawDtCred) Then
        c.DT_CRED = CDate(rawDtCred)
    Else
        c.DT_CRED = CDate(0)
    End If

    LerCredenciamento = c
End Function


