Attribute VB_Name = "Util_Sanear_Contadores"
Option Explicit

' ============================================================
' Util_Sanear_Contadores
'
' Saneamento idempotente do contador AR1 (coluna 44) das 7 abas
' que usam Util_Planilha.ProximoId. Corrige o bug observado na
' Onda 38.2.1-AR1: workbook restaurado de backup pre-38.2 veio
' com <aba>!AR1 dessincronizado do max(ID) real das linhas de
' dados, fazendo cadastro novo pegar ID 001 e duplicar.
'
' Para EMPRESAS e ENTIDADE, considera TAMBEM as abas pareadas
' EMPRESAS_INATIVAS e ENTIDADE_INATIVOS no calculo de max(ID),
' cobrindo o cenario em que a empresa/entidade de maior ID foi
' inabilitada. Empresas/entidades inabilitadas NAO tem AR1
' proprio (nao usam ProximoId), entao sao apenas fontes de
' leitura para o calculo.
'
' Idempotente: rodar varias vezes produz o mesmo estado.
' Mauricio executa via Imediato apos import:
'     SanearContadoresAR1
'
' Onda 38.2.1-AR1, 2026-05-26
' ============================================================

' ------------------------------------------------------------
' SanearContadoresAR1
' Ponto de entrada Public. Sem argumentos. Sem retorno.
' Loga via Debug.Print o resultado por aba.
' ------------------------------------------------------------
Public Sub SanearContadoresAR1()
    Dim totalOk As Long
    Dim totalFalhas As Long

    totalOk = 0
    totalFalhas = 0

    Debug.Print "[SanearContadoresAR1] INICIO " & Format$(Now, "yyyy-mm-dd hh:nn:ss")

    If SanearAR1EmAbaPareada("EMPRESAS", Array("EMPRESAS", "EMPRESAS_INATIVAS")) Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaPareada("ENTIDADE", Array("ENTIDADE", "ENTIDADE_INATIVOS")) Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaSimples("ATIVIDADES") Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaSimples("CAD_SERV") Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaSimples("PRE_OS") Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaSimples("CAD_OS") Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    If SanearAR1EmAbaSimples("CREDENCIADOS") Then
        totalOk = totalOk + 1
    Else
        totalFalhas = totalFalhas + 1
    End If

    Debug.Print "[SanearContadoresAR1] FIM ok=" & totalOk & " falhas=" & totalFalhas
End Sub

' ------------------------------------------------------------
' SanearAR1EmAbaSimples - caso geral (1 aba source = aba target)
' ------------------------------------------------------------
Private Function SanearAR1EmAbaSimples(ByVal nomeAba As String) As Boolean
    SanearAR1EmAbaSimples = SanearAR1EmAbaPareada(nomeAba, Array(nomeAba))
End Function

' ------------------------------------------------------------
' SanearAR1EmAbaPareada
'   - target: aba que recebe o AR1 atualizado
'   - sources: lista de abas que contribuem para max(ID)
' Inativas (EMPRESAS_INATIVAS, ENTIDADE_INATIVOS) entram como
' sources mas nao como target.
' ------------------------------------------------------------
Private Function SanearAR1EmAbaPareada( _
    ByVal targetAba As String, _
    ByVal sources As Variant _
) As Boolean
    Dim wsTarget As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean
    Dim valorAnterior As Long
    Dim maxId As Long
    Dim parcial As Long
    Dim i As Long
    Dim srcNome As String
    Dim detalhes As String

    On Error GoTo falha

    Set wsTarget = ThisWorkbook.Sheets(targetAba)
    valorAnterior = CLng(Val(wsTarget.Cells(1, COL_CONTADOR_AR).Value))

    maxId = 0
    detalhes = ""
    For i = LBound(sources) To UBound(sources)
        srcNome = CStr(sources(i))
        parcial = MaxIdNaColunaA(srcNome)
        If parcial > maxId Then maxId = parcial
        If detalhes <> "" Then detalhes = detalhes & ", "
        detalhes = detalhes & srcNome & "=" & parcial
    Next i

    If Not Util_PrepararAbaParaEscrita(wsTarget, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "SanearAR1EmAbaPareada", _
            "Nao foi possivel preparar a aba '" & targetAba & "' para escrita."
    End If
    abaPreparada = True

    wsTarget.Cells(1, COL_CONTADOR_AR).Value = maxId
    Util_RestaurarProtecaoAba wsTarget, estavaProtegida, senhaProtecao
    abaPreparada = False

    Debug.Print "[SanearContadoresAR1] " & targetAba & "!AR1 " & _
        valorAnterior & " -> " & maxId & " (sources: " & detalhes & ")"

    SanearAR1EmAbaPareada = True
    Exit Function

falha:
    Dim numeroErro As Long
    Dim mensagemErro As String
    numeroErro = Err.Number
    mensagemErro = Err.Description
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba wsTarget, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Debug.Print "[SanearContadoresAR1] FALHA em " & targetAba & ": #" & _
        numeroErro & " " & mensagemErro
    SanearAR1EmAbaPareada = False
End Function

' ------------------------------------------------------------
' MaxIdNaColunaA
' Le coluna A (COL_*_ID = 1 para todas as 7 abas alvo) de
' LINHA_DADOS ate UltimaLinhaAba. Retorna max(CLng(Val(...))).
' Aba inexistente retorna 0 sem erro fatal.
' ------------------------------------------------------------
Private Function MaxIdNaColunaA(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim r As Long
    Dim val_ As Long
    Dim maxId As Long

    On Error GoTo aba_indisponivel

    Set ws = ThisWorkbook.Sheets(nomeAba)
    ultLinha = UltimaLinhaAba(nomeAba)
    maxId = 0
    If ultLinha < LINHA_DADOS Then
        MaxIdNaColunaA = 0
        Exit Function
    End If
    For r = LINHA_DADOS To ultLinha
        val_ = CLng(Val(ws.Cells(r, 1).Value))
        If val_ > maxId Then maxId = val_
    Next r
    MaxIdNaColunaA = maxId
    Exit Function

aba_indisponivel:
    Debug.Print "[SanearContadoresAR1] aba '" & nomeAba & _
        "' indisponivel (#" & Err.Number & "); tratada como max=0"
    MaxIdNaColunaA = 0
End Function


