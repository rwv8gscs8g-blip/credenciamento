Attribute VB_Name = "Importar_Agora"
Option Explicit

Public Sub IMPORTAR_CNAE_AGORA()
    '
    ' Macro simples. Abre CSV, grava na aba ATIVIDADES.
    ' Apos importar, LIMPA a aba CAD_SERV (servicos devem ser cadastrados manualmente).
    ' Zero dependencias. Funciona sozinha.
    '
    Dim caminho As String
    Dim ff As Integer
    Dim linha As String
    Dim partes() As String
    Dim ws As Worksheet
    Dim r As Long
    Dim cnaeRaw As String
    Dim digits As String
    Dim i As Long
    Dim c As String

    ' 1. Pedir arquivo
    caminho = Application.GetOpenFilename("CSV (*.csv),*.csv", , "Selecione o CSV de CNAE")
    If caminho = "Falso" Or caminho = "False" Or caminho = "" Then
        MsgBox "Cancelado.", vbInformation
        Exit Sub
    End If

    ' 2. Preparar aba ATIVIDADES
    Set ws = ThisWorkbook.Sheets("ATIVIDADES")
    Util_DesprotegerAbaComTentativas ws
    On Error Resume Next
    ws.Unprotect
    On Error GoTo 0

    ' 3. Limpar dados antigos (linha 2 em diante)
    If ws.Cells(2, 1).Value <> "" Then
        ws.Range(ws.Cells(2, 1), ws.Cells(ws.Rows.Count, 3)).Clear
    End If

    ' 4. Ler CSV linha a linha
    r = 2
    ff = FreeFile
    Open caminho For Input As #ff

    ' Pular cabecalho
    If Not EOF(ff) Then Line Input #ff, linha

    Do While Not EOF(ff)
        Line Input #ff, linha
        If Len(Trim(linha)) > 0 Then
            partes = Split(linha, ",")
            If UBound(partes) >= 2 Then
                ' Coluna A = ID (texto)
                ws.Cells(r, 1).NumberFormat = "@"
                ws.Cells(r, 1).Value = Format(Val(partes(0)), "000")

                ' Coluna B = CNAE normalizado (DDDD-D/DD)
                cnaeRaw = Trim(partes(1))
                digits = ""
                For i = 1 To Len(cnaeRaw)
                    c = Mid(cnaeRaw, i, 1)
                    If c >= "0" And c <= "9" Then digits = digits & c
                Next i
                If Len(digits) = 7 Then
                    ws.Cells(r, 2).NumberFormat = "@"
                    ws.Cells(r, 2).Value = Left(digits, 4) & "-" & Mid(digits, 5, 1) & "/" & Right(digits, 2)
                Else
                    ws.Cells(r, 2).NumberFormat = "@"
                    ws.Cells(r, 2).Value = cnaeRaw
                End If

                ' Coluna C = DESCRICAO
                ws.Cells(r, 3).Value = Trim(partes(2))

                r = r + 1
            End If
        End If
    Loop
    Close #ff

    ' 5. Atualizar contador na coluna AR (44)
    ws.Cells(1, 44).Value = r - 2

    ' 6. Reproteger ATIVIDADES
    On Error Resume Next
    ws.Protect Password:=Util_SenhaProtecaoPadrao()
    On Error GoTo 0

    ' 7. Limpar CAD_SERV (servicos devem ser cadastrados manualmente)
    Call LimparCadServAposImportacao

    MsgBox "Importacao concluida!" & vbCrLf & (r - 2) & " atividades importadas." & vbCrLf & _
           "CAD_SERV foi limpa. Cadastre servicos manualmente.", vbInformation
End Sub

Public Sub LIMPAR_CADSERV_LEGADO_AGORA()
    '
    ' Limpa TODOS os dados da aba CAD_SERV.
    ' Use quando CAD_SERV contem dados lixo (ex: atividades duplicadas como servicos).
    ' Servicos devem ser cadastrados manualmente via formulario "Cadastrar Servico".
    '
    Dim resp As Long

    resp = MsgBox("ATENCAO: Isso vai APAGAR todos os dados da aba CAD_SERV." & vbCrLf & _
                  "Servicos deverao ser recadastrados manualmente." & vbCrLf & vbCrLf & _
                  "Deseja continuar?", vbExclamation + vbYesNo, "Limpar CAD_SERV (Legado)")

    If resp <> vbYes Then
        MsgBox "Cancelado.", vbInformation
        Exit Sub
    End If

    Call LimparCadServAposImportacao

    MsgBox "CAD_SERV foi limpa com sucesso." & vbCrLf & _
           "Cadastre servicos pelo formulario 'Cadastrar Servico'.", vbInformation
End Sub

Private Sub LimparCadServAposImportacao()
    '
    ' Limpa a aba CAD_SERV inteira (dados a partir da linha 2).
    ' Zera o contador AR.
    '
    Dim wsServ As Worksheet
    Dim ultimaServ As Long

    On Error Resume Next
    Set wsServ = ThisWorkbook.Sheets("CAD_SERV")
    If wsServ Is Nothing Then Exit Sub

    Util_DesprotegerAbaComTentativas wsServ
    wsServ.Unprotect
    On Error GoTo 0

    ultimaServ = wsServ.Cells(wsServ.Rows.Count, 1).End(xlUp).Row
    If ultimaServ >= 2 Then
        wsServ.Range(wsServ.Cells(2, 1), wsServ.Cells(ultimaServ, 9)).ClearContents
    End If

    ' Zerar contador
    On Error Resume Next
    wsServ.Cells(1, 44).Value = 0
    On Error GoTo 0

    ' Reproteger
    On Error Resume Next
    wsServ.Protect Password:=Util_SenhaProtecaoPadrao()
    On Error GoTo 0
End Sub
