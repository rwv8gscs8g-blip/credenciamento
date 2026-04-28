Attribute VB_Name = "Repo_Avaliacao"
Option Explicit

' Repositório de Avaliação — V10
' Persiste avaliação na linha correspondente da aba CAD_OS.
' Sem Select/ActiveCell/On Error Resume Next silencioso.

Private Const STATUS_OS_CONCLUIDA As String = "CONCLUIDA"

Public Function Inserir( _
    ByRef a As TAvaliacao, _
    ByVal QtExecutada As Double, _
    ByVal valorExecutado As Currency, _
    ByVal justifDiv As String, _
    Optional ByVal dtFechamento As Variant, _
    Optional ByVal DtPagto As Variant, _
    Optional ByVal numEmpenho As String = "" _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim linhaOS As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    linhaOS = 0
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, a.OS_ID) Then
            linhaOS = i
            Exit For
        End If
    Next i

    If linhaOS = 0 Then
        res.Sucesso = False
        res.Mensagem = "OS nao encontrada em CAD_OS: OS_ID=" & a.OS_ID
        Inserir = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        Inserir = res
        Exit Function
    End If

    ws.Cells(linhaOS, COL_OS_NOTA_01).Value = a.notas(1)
    ws.Cells(linhaOS, COL_OS_NOTA_02).Value = a.notas(2)
    ws.Cells(linhaOS, COL_OS_NOTA_03).Value = a.notas(3)
    ws.Cells(linhaOS, COL_OS_NOTA_04).Value = a.notas(4)
    ws.Cells(linhaOS, COL_OS_NOTA_05).Value = a.notas(5)
    ws.Cells(linhaOS, COL_OS_NOTA_06).Value = a.notas(6)
    ws.Cells(linhaOS, COL_OS_NOTA_07).Value = a.notas(7)
    ws.Cells(linhaOS, COL_OS_NOTA_08).Value = a.notas(8)
    ws.Cells(linhaOS, COL_OS_NOTA_09).Value = a.notas(9)
    ws.Cells(linhaOS, COL_OS_NOTA_10).Value = a.notas(10)

    ws.Cells(linhaOS, COL_OS_MEDIA).Value = a.MEDIA_NOTAS
    ws.Cells(linhaOS, COL_OS_OBSERVACOES).Value = a.Observacao
    ws.Cells(linhaOS, COL_OS_STATUS).Value = STATUS_OS_CONCLUIDA
    If IsDate(dtFechamento) Then
        ws.Cells(linhaOS, COL_OS_DT_FECHAMENTO).Value = CDate(dtFechamento)
    Else
        ws.Cells(linhaOS, COL_OS_DT_FECHAMENTO).Value = a.DT_AVAL
    End If
    ws.Cells(linhaOS, COL_OS_QT_EXEC).Value = QtExecutada
    ws.Cells(linhaOS, COL_OS_VL_EXEC).Value = valorExecutado
    If IsDate(DtPagto) Then
        ws.Cells(linhaOS, COL_OS_DT_PAGTO).Value = CDate(DtPagto)
    End If
    If Trim$(numEmpenho) <> "" Then
        ws.Cells(linhaOS, COL_OS_EMPENHO).Value = Trim$(numEmpenho)
    End If
    ws.Cells(linhaOS, COL_OS_JUSTIF_DIV).Value = justifDiv

    res.Sucesso = True
    res.Mensagem = "Avaliacao gravada. OS_ID=" & a.OS_ID & _
                   "; MEDIA=" & Format$(a.MEDIA_NOTAS, "0.00")
    res.IdGerado = a.OS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em Repo_Avaliacao.Inserir: " & Err.Description
    res.CodigoErro = Err.Number
    Inserir = res
End Function

Public Function RepoAvaliacaoInserir( _
    ByRef a As TAvaliacao, _
    ByVal QtExecutada As Double, _
    ByVal valorExecutado As Currency, _
    ByVal justifDiv As String, _
    Optional ByVal dtFechamento As Variant, _
    Optional ByVal DtPagto As Variant, _
    Optional ByVal numEmpenho As String = "" _
) As TResult
    RepoAvaliacaoInserir = Inserir(a, QtExecutada, valorExecutado, justifDiv, dtFechamento, DtPagto, numEmpenho)
End Function

' IdsIguais removida — usar Util_Planilha.IdsIguais (V12-CLEAN).

' V12.0.0203 ONDA 1 — Conta avaliacoes registradas para uma empresa
' cuja media de notas seja estritamente menor que `notaCorte`.
' A varredura usa SHEET_CAD_OS, COL_OS_EMP_ID e COL_OS_MEDIA.
' Apenas linhas com OS no STATUS_OS_CONCLUIDA sao consideradas
' (avaliar() so persiste media quando finaliza a OS).
' A funcao e idempotente e nao altera nenhuma aba.
Public Function ContarStrikesPorEmpresa( _
    ByVal EMP_ID As String, _
    ByVal notaCorte As Double _
) As Long
    Dim ws As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim mediaCelula As Variant
    Dim mediaVal As Double
    Dim statusVal As String
    Dim qtd As Long

    On Error GoTo falha

    If Trim$(EMP_ID) = "" Then
        ContarStrikesPorEmpresa = 0
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    ultima = UltimaLinhaAba(SHEET_CAD_OS)
    If ultima < LINHA_DADOS Then
        ContarStrikesPorEmpresa = 0
        Exit Function
    End If

    For i = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(i, COL_OS_EMP_ID).Value, EMP_ID) Then
            statusVal = Trim$(CStr(ws.Cells(i, COL_OS_STATUS).Value))
            If statusVal = STATUS_OS_CONCLUIDA Then
                mediaCelula = ws.Cells(i, COL_OS_MEDIA).Value
                If IsNumeric(mediaCelula) Then
                    mediaVal = CDbl(mediaCelula)
                    If mediaVal > 0# And mediaVal < notaCorte Then
                        qtd = qtd + 1
                    End If
                End If
            End If
        End If
    Next i

    ContarStrikesPorEmpresa = qtd
    Exit Function

falha:
    ContarStrikesPorEmpresa = 0
End Function

