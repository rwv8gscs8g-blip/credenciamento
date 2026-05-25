Attribute VB_Name = "Util_Evolucao"
Option Explicit

' ============================================================
' Util_Evolucao - Onda 16 MD-16.3 (V12.0.0203)
' Tracking historico de duracao das suites V2 ao longo do tempo.
' Sheet alvo: EVOLUCAO_TESTES (criada lazy).
' Schema (1 linha por execucao por suite):
'   A EXECUCAO_ID | B SUITE | C DT_EXEC | D DURACAO_MS | E OK | F FALHA
'   G MEDIA_5_MS | H DELTA_PCT | I REGRESSAO?
' Indicador de regressao: DURACAO_MS > MEDIA_5_MS * EVOL_FATOR_REGRESSAO.
' Hook automatico em TV2_FinalizarExecucao via Util_Evolucao_RegistrarExecucao.
' ============================================================

Public Const EVOL_SHEET As String = "EVOLUCAO_TESTES"
Public Const EVOL_FATOR_REGRESSAO As Double = 1.5
Public Const EVOL_JANELA_MEDIA As Long = 5

Public Const EVOL_COL_EXECUCAO_ID As Long = 1
Public Const EVOL_COL_SUITE As Long = 2
Public Const EVOL_COL_DT_EXEC As Long = 3
Public Const EVOL_COL_DURACAO_MS As Long = 4
Public Const EVOL_COL_OK As Long = 5
Public Const EVOL_COL_FALHA As Long = 6
Public Const EVOL_COL_MEDIA_5_MS As Long = 7
Public Const EVOL_COL_DELTA_PCT As Long = 8
Public Const EVOL_COL_REGRESSAO As Long = 9

' Hook chamado por TV2_FinalizarExecucao para registrar 1 linha de
' evolucao temporal. Idempotente: apenas append; nao sobrescreve linhas
' existentes. Se sheet nao existe, cria.
Public Sub Util_Evolucao_RegistrarExecucao( _
    ByVal execucaoId As String, _
    ByVal suite As String, _
    ByVal duracaoMs As Long, _
    ByVal ok As Long, _
    ByVal falha As Long _
)
    On Error GoTo falhaProc

    Dim ws As Worksheet
    Dim nr As Long
    Dim media5 As Long
    Dim deltaPct As Double
    Dim regressao As Boolean

    Set ws = Util_Evolucao_EnsureSheet()
    nr = Util_Evolucao_NextRow(ws)
    media5 = Util_Evolucao_CalcularMedia5(suite)

    If media5 > 0 Then
        deltaPct = ((CDbl(duracaoMs) - CDbl(media5)) / CDbl(media5)) * 100#
        regressao = (CDbl(duracaoMs) > CDbl(media5) * EVOL_FATOR_REGRESSAO)
    Else
        deltaPct = 0
        regressao = False
    End If

    ws.Cells(nr, EVOL_COL_EXECUCAO_ID).Value = execucaoId
    ws.Cells(nr, EVOL_COL_SUITE).Value = suite
    ws.Cells(nr, EVOL_COL_DT_EXEC).Value = Now
    ws.Cells(nr, EVOL_COL_DURACAO_MS).Value = duracaoMs
    ws.Cells(nr, EVOL_COL_OK).Value = ok
    ws.Cells(nr, EVOL_COL_FALHA).Value = falha
    ws.Cells(nr, EVOL_COL_MEDIA_5_MS).Value = media5
    ws.Cells(nr, EVOL_COL_DELTA_PCT).Value = deltaPct
    ws.Cells(nr, EVOL_COL_REGRESSAO).Value = regressao

    Util_Evolucao_FormatarSheet ws
    Exit Sub

falhaProc:
    ' Hook de evolucao nao pode quebrar a suite chamadora. Falha silenciosa.
End Sub

' Calcula media movel das ultimas EVOL_JANELA_MEDIA execucoes da mesma
' suite. Retorna 0 se nao houver historico (primeira execucao).
Public Function Util_Evolucao_CalcularMedia5(ByVal suite As String) As Long
    On Error GoTo falhaProc

    Dim ws As Worksheet
    Dim ultima As Long
    Dim r As Long
    Dim soma As Double
    Dim cont As Long

    Set ws = Util_Evolucao_EnsureSheet()
    ultima = ws.Cells(ws.Rows.count, EVOL_COL_EXECUCAO_ID).End(xlUp).row
    If ultima < 2 Then
        Util_Evolucao_CalcularMedia5 = 0
        Exit Function
    End If

    soma = 0#
    cont = 0
    For r = ultima To 2 Step -1
        If StrComp(CStr(ws.Cells(r, EVOL_COL_SUITE).Value), suite, vbTextCompare) = 0 Then
            soma = soma + CDbl(Val(ws.Cells(r, EVOL_COL_DURACAO_MS).Value))
            cont = cont + 1
            If cont >= EVOL_JANELA_MEDIA Then Exit For
        End If
    Next r

    If cont = 0 Then
        Util_Evolucao_CalcularMedia5 = 0
    Else
        Util_Evolucao_CalcularMedia5 = CLng(soma / CDbl(cont))
    End If
    Exit Function

falhaProc:
    Util_Evolucao_CalcularMedia5 = 0
End Function

' Handler da opcao [21] da Central V2: garantir sheet, formatar e abrir.
Public Sub Util_Evolucao_AbrirEMostrar()
    On Error GoTo falhaProc
    Dim ws As Worksheet
    Set ws = Util_Evolucao_EnsureSheet()
    Util_Evolucao_FormatarSheet ws
    ws.Activate
    ws.Range("A1").Select
    Exit Sub

falhaProc:
    MsgBox "Erro ao abrir EVOLUCAO_TESTES: " & Err.Description, _
           vbExclamation, "Evolucao Testes"
End Sub

' Cria sheet com schema canonico se ausente; idempotente.
Private Function Util_Evolucao_EnsureSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(EVOL_SHEET)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = EVOL_SHEET
    End If

    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, EVOL_COL_EXECUCAO_ID).Value = "EXECUCAO_ID"
        ws.Cells(1, EVOL_COL_SUITE).Value = "SUITE"
        ws.Cells(1, EVOL_COL_DT_EXEC).Value = "DT_EXEC"
        ws.Cells(1, EVOL_COL_DURACAO_MS).Value = "DURACAO_MS"
        ws.Cells(1, EVOL_COL_OK).Value = "OK"
        ws.Cells(1, EVOL_COL_FALHA).Value = "FALHA"
        ws.Cells(1, EVOL_COL_MEDIA_5_MS).Value = "MEDIA_5_MS"
        ws.Cells(1, EVOL_COL_DELTA_PCT).Value = "DELTA_PCT"
        ws.Cells(1, EVOL_COL_REGRESSAO).Value = "REGRESSAO?"
    End If

    Set Util_Evolucao_EnsureSheet = ws
End Function

Private Function Util_Evolucao_NextRow(ByVal ws As Worksheet) As Long
    Dim ultima As Long
    ultima = ws.Cells(ws.Rows.count, EVOL_COL_EXECUCAO_ID).End(xlUp).row
    If ultima < 1 Then
        Util_Evolucao_NextRow = 2
    Else
        Util_Evolucao_NextRow = ultima + 1
    End If
End Function

' Aplica AutoFit, AutoFilter e cor condicional na coluna REGRESSAO?
' (vermelha se TRUE) e DURACAO_MS (vermelha quando regressao).
Private Sub Util_Evolucao_FormatarSheet(ByVal ws As Worksheet)
    Dim ultima As Long
    Dim r As Long
    Dim deltaPct As Double

    On Error Resume Next

    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:I").EntireColumn.AutoFit

    ws.Columns(EVOL_COL_DELTA_PCT).NumberFormat = "0.0;[Red]-0.0;0.0"

    ultima = ws.Cells(ws.Rows.count, EVOL_COL_EXECUCAO_ID).End(xlUp).row
    If ultima >= 1 Then
        If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, EVOL_COL_REGRESSAO)).AutoFilter
    End If

    ' Cor condicional na coluna REGRESSAO? e DURACAO_MS:
    '   regressao TRUE => vermelho em ambas as colunas (visibilidade)
    '   regressao FALSE => limpar cor (mantem default)
    For r = 2 To ultima
        If CBool(ws.Cells(r, EVOL_COL_REGRESSAO).Value) Then
            ws.Cells(r, EVOL_COL_REGRESSAO).Interior.Color = RGB(255, 199, 206)
            ws.Cells(r, EVOL_COL_DURACAO_MS).Interior.Color = RGB(255, 199, 206)
            ws.Cells(r, EVOL_COL_DELTA_PCT).Interior.Color = RGB(255, 199, 206)
        Else
            ws.Cells(r, EVOL_COL_REGRESSAO).Interior.ColorIndex = xlNone
            ws.Cells(r, EVOL_COL_DURACAO_MS).Interior.ColorIndex = xlNone
            ws.Cells(r, EVOL_COL_DELTA_PCT).Interior.ColorIndex = xlNone
        End If
    Next r

    On Error GoTo 0
End Sub


