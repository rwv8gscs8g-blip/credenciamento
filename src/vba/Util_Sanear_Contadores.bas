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
' Onda 38.2.1-AR1-FIX2-PERF (2026-05-26): guarda monotonica em
' SanearAR1EmAbaPareada (AR1 nunca decresce) + envelopa
' SanearContadoresAR1 com Util_Excel_Performance. MaxIdNaColunaA
' Private removido - chama Util_MaxIdNaColunaA Public em Util_Planilha.
' ============================================================

' ------------------------------------------------------------
' SanearContadoresAR1
' Ponto de entrada Public. Sem argumentos. Sem retorno.
' Loga via Debug.Print o resultado por aba.
' ------------------------------------------------------------
Public Sub SanearContadoresAR1()
    Dim totalOk As Long
    Dim totalFalhas As Long
    Dim estadoExcel As Variant

    totalOk = 0
    totalFalhas = 0

    ' Onda 38.2.2 (Codex item 69): handler ANTES de Util_IniciarBlocoRapido
    ' garante restauracao de TEstadoExcel mesmo se a chamada de inicio falhar
    ' (cenario teorico mas defensivo). estadoExcel comeca vazio; o handler
    ' ainda assim chama Util_FinalizarBlocoRapido que e tolerante a estado
    ' vazio/parcial (TEstadoExcel inicializado por VBA como zerado).
    On Error GoTo handler
    estadoExcel = Util_IniciarBlocoRapido()

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
    Util_FinalizarBlocoRapido estadoExcel
    Exit Sub

handler:
    Util_FinalizarBlocoRapido estadoExcel
    Debug.Print "[SanearContadoresAR1] FALHA INESPERADA: #" & Err.Number & " " & Err.Description
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
        parcial = Util_MaxIdNaColunaA(srcNome)
        If parcial > maxId Then maxId = parcial
        If detalhes <> "" Then detalhes = detalhes & ", "
        detalhes = detalhes & srcNome & "=" & parcial
    Next i

    ' Guarda monotonica (Onda 38.2.1-AR1-FIX2-PERF): AR1 nunca decresce.
    ' Cobre o caso F5: linhas deletadas manualmente da coluna A fazem
    ' max(dados) < AR1; preservar AR1 evita reuso de IDs historicos.
    If maxId < valorAnterior Then maxId = valorAnterior

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

' MaxIdNaColunaA Private removido na Onda 38.2.1-AR1-FIX2-PERF.
' Funcionalidade promovida para Public Util_MaxIdNaColunaA em
' Util_Planilha.bas (reutilizada por Util_Planilha.ProximoId para
' defesa em profundidade contra AR1 dessincronizado).


