Attribute VB_Name = "Teste_Validacao_Release"
Option Explicit

' Orquestrador minimo de homologacao da release:
' V1 rapida + V2 Smoke + V2 Canonica, com evidencia copiavel para IA/humano.

Private Const VR_SHEET As String = "VALIDACAO_RELEASE"
Private Const VR_RELEASE_ALVO As String = "V12.0.0203"
Private Const VR_STATUS_OK As String = "OK"
Private Const VR_STATUS_FAIL As String = "FALHA"

Public Sub CT_ValidarRelease_TrioMinimo()
    Dim ws As Worksheet
    Dim validacaoId As String
    Dim statusGeral As String
    Dim csvResumo As String
    Dim msgFinal As String
    Dim estiloMsg As Long

    On Error GoTo falha

    validacaoId = "VR_" & Format$(Now, "yyyymmdd_hhnnss")
    Set ws = VR_PrepararSheet(validacaoId)

    Application.StatusBar = "Validacao release: V1 rapida"
    BA_SetModoExecucaoVisual False
    RunBateriaOficial True
    VR_RegistrarEtapaV1 ws, validacaoId, 7

    Application.StatusBar = "Validacao release: V2 Smoke"
    TV2_RunSmoke False, True
    VR_RegistrarEtapaV2 ws, validacaoId, 8, "V2_SMOKE", TV2_ExecucaoAtualId()

    Application.StatusBar = "Validacao release: V2 Canonica"
    TV2_RunCanonicoFundacao False, True
    VR_RegistrarEtapaV2 ws, validacaoId, 9, "V2_CANONICO", TV2_ExecucaoAtualId()

    statusGeral = VR_StatusGeral(ws)
    csvResumo = VR_ExportarResumoCSV(ws, validacaoId, statusGeral)
    VR_EscreverResumoIA ws, validacaoId, statusGeral, csvResumo
    VR_FormatarSheet ws, statusGeral

    Application.StatusBar = False
    ws.Activate
    ws.Range("A1").Select

    msgFinal = "Validacao consolidada concluida." & vbCrLf & _
               "ID: " & validacaoId & vbCrLf & _
               "Resultado: " & statusGeral & vbCrLf & vbCrLf & _
               "CSV resumo:" & vbCrLf & csvResumo
    If statusGeral = "APROVADO" Then
        estiloMsg = vbInformation
    Else
        estiloMsg = vbExclamation
    End If
    MsgBox msgFinal, estiloMsg, "Validacao Release"
    Exit Sub

falha:
    Application.StatusBar = False
    MsgBox "Erro na validacao consolidada: " & Err.Description & vbCrLf & _
           "Codigo: " & CStr(Err.Number) & vbCrLf & _
           "Origem: " & Err.Source, _
           vbCritical, "Validacao Release"
End Sub

Public Sub VR_ValidarReleaseTrioMinimo()
    CT_ValidarRelease_TrioMinimo
End Sub

Public Sub VR_AbrirValidacaoRelease()
    Dim ws As Worksheet
    Set ws = VR_EnsureSheet()
    ws.Activate
    ws.Range("A1").Select
End Sub

Private Function VR_PrepararSheet(ByVal validacaoId As String) As Worksheet
    Dim ws As Worksheet

    Set ws = VR_EnsureSheet()
    On Error Resume Next
    If ws.ProtectContents Then ws.Unprotect Password:="sebrae2024"
    ws.Cells.UnMerge
    ws.Cells.Clear
    On Error GoTo 0

    ws.Cells(1, 1).Value = "VALIDACAO RELEASE - TRIO MINIMO"
    ws.Cells(2, 1).Value = "VALIDACAO_ID"
    ws.Cells(2, 2).Value = validacaoId
    ws.Cells(3, 1).Value = "BUILD"
    ws.Cells(3, 2).Value = VR_BuildImportado()
    ws.Cells(4, 1).Value = "RELEASE_ALVO"
    ws.Cells(4, 2).Value = VR_RELEASE_ALVO

    ws.Cells(6, 1).Value = "VALIDACAO_ID"
    ws.Cells(6, 2).Value = "BUILD"
    ws.Cells(6, 3).Value = "DATA_HORA"
    ws.Cells(6, 4).Value = "ETAPA"
    ws.Cells(6, 5).Value = "EXECUCAO_ID"
    ws.Cells(6, 6).Value = "OK"
    ws.Cells(6, 7).Value = "FALHA"
    ws.Cells(6, 8).Value = "MANUAL"
    ws.Cells(6, 9).Value = "STATUS"
    ws.Cells(6, 10).Value = "CSV_FALHAS"
    ws.Cells(6, 11).Value = "PRIMEIRA_FALHA"
    ws.Cells(6, 12).Value = "ACAO_IA"

    Set VR_PrepararSheet = ws
End Function

Private Function VR_EnsureSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(VR_SHEET)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = VR_SHEET
    End If

    Set VR_EnsureSheet = ws
End Function

Private Sub VR_RegistrarEtapaV1(ByVal ws As Worksheet, ByVal validacaoId As String, ByVal linha As Long)
    Dim execId As String
    Dim ok As Long
    Dim falha As Long
    Dim manual As Long
    Dim csvFalhas As String
    Dim primeiraFalha As String
    Dim acao As String

    execId = BA_UltimaExecucaoId()
    ok = BA_UltimoOk()
    falha = BA_UltimoFail()
    manual = BA_UltimoManual()

    If falha > 0 Then
        csvFalhas = BA_UltimoCsvFalhas()
        If csvFalhas = "" Then csvFalhas = CTR_ExportarTesteOficialFalhasCSV()
        primeiraFalha = VR_PrimeiraFalhaV1(execId)
        acao = "Corrigir a falha da V1 indicada em PRIMEIRA_FALHA e reexecutar o trio minimo."
    Else
        csvFalhas = "NAO_EXPORTADO"
        primeiraFalha = ""
        acao = "Sem acao corretiva."
    End If

    VR_EscreverLinha ws, linha, validacaoId, "V1_RAPIDA", execId, ok, falha, manual, csvFalhas, primeiraFalha, acao
End Sub

Private Sub VR_RegistrarEtapaV2(ByVal ws As Worksheet, ByVal validacaoId As String, ByVal linha As Long, ByVal etapa As String, ByVal execId As String)
    Dim ok As Long
    Dim falha As Long
    Dim manual As Long
    Dim csvFalhas As String
    Dim primeiraFalha As String
    Dim acao As String

    ok = TV2_UltimoOk()
    falha = TV2_UltimoFail()
    manual = TV2_UltimoManual()

    If falha > 0 Then
        csvFalhas = VR_CsvFalhasV2(execId)
        If csvFalhas = "" Then csvFalhas = TV2_ExportarFalhasCSV(execId)
        primeiraFalha = VR_PrimeiraFalhaV2(execId)
        acao = "Corrigir o cenario V2 indicado em PRIMEIRA_FALHA e reexecutar o trio minimo."
    Else
        csvFalhas = "NAO_EXPORTADO"
        primeiraFalha = ""
        acao = "Sem acao corretiva."
    End If

    VR_EscreverLinha ws, linha, validacaoId, etapa, execId, ok, falha, manual, csvFalhas, primeiraFalha, acao
End Sub

Private Sub VR_EscreverLinha( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal validacaoId As String, _
    ByVal etapa As String, _
    ByVal execId As String, _
    ByVal ok As Long, _
    ByVal falha As Long, _
    ByVal manual As Long, _
    ByVal csvFalhas As String, _
    ByVal primeiraFalha As String, _
    ByVal acao As String)

    ws.Cells(linha, 1).Value = validacaoId
    ws.Cells(linha, 2).Value = VR_BuildImportado()
    ws.Cells(linha, 3).Value = Now
    ws.Cells(linha, 4).Value = etapa
    ws.Cells(linha, 5).Value = execId
    ws.Cells(linha, 6).Value = ok
    ws.Cells(linha, 7).Value = falha
    ws.Cells(linha, 8).Value = manual
    ws.Cells(linha, 9).Value = IIf(falha = 0, VR_STATUS_OK, VR_STATUS_FAIL)
    ws.Cells(linha, 10).Value = csvFalhas
    ws.Cells(linha, 11).Value = primeiraFalha
    ws.Cells(linha, 12).Value = acao
End Sub

Private Function VR_StatusGeral(ByVal ws As Worksheet) As String
    If UCase$(Trim$(CStr(ws.Cells(7, 9).Value))) = VR_STATUS_OK And _
       UCase$(Trim$(CStr(ws.Cells(8, 9).Value))) = VR_STATUS_OK And _
       UCase$(Trim$(CStr(ws.Cells(9, 9).Value))) = VR_STATUS_OK Then
        VR_StatusGeral = "APROVADO"
    Else
        VR_StatusGeral = "REPROVADO"
    End If
End Function

Private Sub VR_EscreverResumoIA(ByVal ws As Worksheet, ByVal validacaoId As String, ByVal statusGeral As String, ByVal csvResumo As String)
    Dim bloco As String

    bloco = "VALIDACAO_RELEASE=" & validacaoId & vbLf
    bloco = bloco & "BUILD=" & VR_BuildImportado() & vbLf
    bloco = bloco & VR_LinhaResumoIA(ws, 7) & vbLf
    bloco = bloco & VR_LinhaResumoIA(ws, 8) & vbLf
    bloco = bloco & VR_LinhaResumoIA(ws, 9) & vbLf
    bloco = bloco & "RESULTADO=" & statusGeral & vbLf
    bloco = bloco & "CSV_RESUMO=" & csvResumo

    ws.Cells(12, 1).Value = "BLOCO_COPIAVEL_PARA_IA"
    ws.Cells(13, 1).Value = bloco
    ws.Range(ws.Cells(13, 1), ws.Cells(13, 12)).Merge
    ws.Cells(13, 1).WrapText = True
    ws.Rows(13).RowHeight = 110
End Sub

Private Function VR_LinhaResumoIA(ByVal ws As Worksheet, ByVal linha As Long) As String
    Dim s As String

    s = CStr(ws.Cells(linha, 4).Value) & "=" & CStr(ws.Cells(linha, 9).Value)
    s = s & "; EXECUCAO=" & CStr(ws.Cells(linha, 5).Value)
    s = s & "; OK=" & CStr(ws.Cells(linha, 6).Value)
    s = s & "; FALHA=" & CStr(ws.Cells(linha, 7).Value)
    s = s & "; MANUAL=" & CStr(ws.Cells(linha, 8).Value)
    If CStr(ws.Cells(linha, 9).Value) <> VR_STATUS_OK Then
        s = s & "; PRIMEIRA_FALHA=" & VR_TextoCurto(CStr(ws.Cells(linha, 11).Value), 280)
        s = s & "; CSV_FALHAS=" & CStr(ws.Cells(linha, 10).Value)
    End If

    VR_LinhaResumoIA = s
End Function

Private Function VR_PrimeiraFalhaV1(ByVal execId As String) As String
    Dim ws As Worksheet
    Dim ult As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("RESULTADO_QA")
    On Error GoTo 0
    If ws Is Nothing Then Exit Function

    ult = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For r = 7 To ult
        If Trim$(CStr(ws.Cells(r, 1).Value)) = execId Then
            If UCase$(Trim$(CStr(ws.Cells(r, 7).Value))) = VR_STATUS_FAIL Then
                VR_PrimeiraFalhaV1 = "TESTE=" & CStr(ws.Cells(r, 3).Value) & _
                    "; ESPERADO=" & CStr(ws.Cells(r, 5).Value) & _
                    "; OBTIDO=" & CStr(ws.Cells(r, 6).Value) & _
                    "; IMPORTANCIA=" & CStr(ws.Cells(r, 8).Value)
                Exit Function
            End If
        End If
    Next r
End Function

Private Function VR_PrimeiraFalhaV2(ByVal execId As String) As String
    Dim ws As Worksheet
    Dim ult As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("RESULTADO_QA_V2")
    On Error GoTo 0
    If ws Is Nothing Then Exit Function

    ult = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For r = 2 To ult
        If Trim$(CStr(ws.Cells(r, 1).Value)) = execId Then
            If UCase$(Trim$(CStr(ws.Cells(r, 8).Value))) = VR_STATUS_FAIL Then
                VR_PrimeiraFalhaV2 = "CENARIO=" & CStr(ws.Cells(r, 3).Value) & _
                    "; OBJETIVO=" & CStr(ws.Cells(r, 5).Value) & _
                    "; ESPERADO=" & CStr(ws.Cells(r, 6).Value) & _
                    "; OBTIDO=" & CStr(ws.Cells(r, 7).Value) & _
                    "; SIGNIFICADO=" & CStr(ws.Cells(r, 9).Value)
                Exit Function
            End If
        End If
    Next r
End Function

Private Function VR_CsvFalhasV2(ByVal execId As String) As String
    Dim ws As Worksheet
    Dim ult As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("HISTORICO_QA_V2")
    On Error GoTo 0
    If ws Is Nothing Then Exit Function

    ult = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For r = ult To 2 Step -1
        If Trim$(CStr(ws.Cells(r, 1).Value)) = execId Then
            VR_CsvFalhasV2 = Trim$(CStr(ws.Cells(r, 8).Value))
            Exit Function
        End If
    Next r
End Function

Private Function VR_ExportarResumoCSV(ByVal ws As Worksheet, ByVal validacaoId As String, ByVal statusGeral As String) As String
    Dim pasta As String
    Dim caminho As String
    Dim fNum As Integer
    Dim r As Long

    On Error GoTo falha

    pasta = VR_PastaSaida()
    caminho = pasta & Application.PathSeparator & "ValidacaoRelease_V12_0_0203_" & validacaoId & ".csv"

    fNum = FreeFile
    Open caminho For Output As #fNum
    Print #fNum, "VALIDACAO_ID;BUILD;DATA_HORA;ETAPA;EXECUCAO_ID;OK;FALHA;MANUAL;STATUS;CSV_FALHAS;PRIMEIRA_FALHA;ACAO_IA"

    For r = 7 To 9
        Print #fNum, VR_CsvLinha(ws, r)
    Next r

    Print #fNum, VR_CsvCell(validacaoId) & ";" & VR_CsvCell(VR_BuildImportado()) & ";" & _
        VR_CsvCell(Format$(Now, "dd/mm/yyyy hh:nn:ss")) & ";GERAL;;;;;" & _
        VR_CsvCell(statusGeral) & ";;;" & VR_CsvCell("Usar este CSV como evidencia textual da validacao.")

    Close #fNum
    VR_ExportarResumoCSV = caminho
    Exit Function

falha:
    On Error Resume Next
    If fNum <> 0 Then Close #fNum
    VR_ExportarResumoCSV = ""
End Function

Private Function VR_CsvLinha(ByVal ws As Worksheet, ByVal r As Long) As String
    Dim c As Long
    Dim linhaCsv As String

    For c = 1 To 12
        If c > 1 Then linhaCsv = linhaCsv & ";"
        linhaCsv = linhaCsv & VR_CsvCell(ws.Cells(r, c).Value)
    Next c

    VR_CsvLinha = linhaCsv
End Function

Private Function VR_CsvCell(ByVal valor As Variant) As String
    Dim s As String

    If IsDate(valor) Then
        s = Format$(CDate(valor), "dd/mm/yyyy hh:nn:ss")
    Else
        s = CStr(valor)
    End If

    s = Trim$(Replace$(Replace$(s, vbCr, " "), vbLf, " "))
    s = Replace$(s, """", """""")
    If InStr(1, s, ";", vbBinaryCompare) > 0 Or InStr(1, s, """", vbBinaryCompare) > 0 Then
        VR_CsvCell = """" & s & """"
    Else
        VR_CsvCell = s
    End If
End Function

Private Function VR_PastaSaida() As String
    Dim base As String
    Dim sep As String
    Dim pasta As String

    sep = Application.PathSeparator
    base = Trim$(ThisWorkbook.Path)
    If Len(base) = 0 Then base = Environ$("TEMP")

    pasta = base & sep & "auditoria"
    VR_MkDirIfMissing pasta
    pasta = pasta & sep & "evidencias"
    VR_MkDirIfMissing pasta
    pasta = pasta & sep & VR_RELEASE_ALVO
    VR_MkDirIfMissing pasta

    VR_PastaSaida = pasta
End Function

Private Sub VR_MkDirIfMissing(ByVal pasta As String)
    On Error Resume Next
    If Len(Dir$(pasta, vbDirectory)) = 0 Then MkDir pasta
    On Error GoTo 0
End Sub

Private Function VR_BuildImportado() As String
    On Error GoTo falha
    VR_BuildImportado = AppRelease_BuildImportado()
    If Trim$(VR_BuildImportado) = "" Then VR_BuildImportado = "BUILD_NAO_INFORMADO"
    Exit Function

falha:
    VR_BuildImportado = "BUILD_NAO_INFORMADO"
End Function

Private Function VR_TextoCurto(ByVal texto As String, ByVal tamanhoMax As Long) As String
    If Len(texto) <= tamanhoMax Then
        VR_TextoCurto = texto
    Else
        VR_TextoCurto = Left$(texto, tamanhoMax - 3) & "..."
    End If
End Function

Private Sub VR_FormatarSheet(ByVal ws As Worksheet, ByVal statusGeral As String)
    Dim r As Long

    On Error Resume Next

    With ws.Range(ws.Cells(1, 1), ws.Cells(1, 12))
        .Merge
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
    End With

    With ws.Range(ws.Cells(6, 1), ws.Cells(6, 12))
        .Font.Bold = True
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .HorizontalAlignment = xlCenter
    End With

    For r = 7 To 9
        If UCase$(Trim$(CStr(ws.Cells(r, 9).Value))) = VR_STATUS_OK Then
            ws.Cells(r, 9).Interior.Color = RGB(198, 239, 206)
        Else
            ws.Range(ws.Cells(r, 1), ws.Cells(r, 12)).Interior.Color = RGB(255, 199, 206)
        End If
    Next r

    ws.Cells(11, 1).Value = "RESULTADO_GERAL"
    ws.Cells(11, 2).Value = statusGeral
    ws.Cells(11, 2).Font.Bold = True
    If statusGeral = "APROVADO" Then
        ws.Cells(11, 2).Interior.Color = RGB(198, 239, 206)
    Else
        ws.Cells(11, 2).Interior.Color = RGB(255, 199, 206)
    End If

    ws.Columns(1).ColumnWidth = 23
    ws.Columns(2).ColumnWidth = 16
    ws.Columns(3).ColumnWidth = 19
    ws.Columns(4).ColumnWidth = 16
    ws.Columns(5).ColumnWidth = 24
    ws.Columns(6).ColumnWidth = 8
    ws.Columns(7).ColumnWidth = 8
    ws.Columns(8).ColumnWidth = 8
    ws.Columns(9).ColumnWidth = 12
    ws.Columns(10).ColumnWidth = 42
    ws.Columns(11).ColumnWidth = 70
    ws.Columns(12).ColumnWidth = 42
    ws.Range(ws.Cells(6, 1), ws.Cells(9, 12)).AutoFilter
    ws.Range(ws.Cells(1, 1), ws.Cells(13, 12)).Borders.LineStyle = xlContinuous
    ws.Cells.WrapText = True
    On Error GoTo 0
End Sub
