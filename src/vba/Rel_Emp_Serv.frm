VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Rel_Emp_Serv 
   Caption         =   "Relatorio de Empresas Credenciadas por Servico"
   ClientHeight    =   3479
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   13454
   OleObjectBlob   =   "Rel_Emp_Serv.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Rel_Emp_Serv"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False




Private Sub UserForm_Initialize()
    Me.Caption = Rel_TituloExibicao("RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO")
End Sub

Private Sub SV_CR_Lista_Click()
    On Error GoTo erro_carregamento

    Dim wsCred As Worksheet
    Dim wsRel As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim linhaOut As Long
    Dim ativId As String
    Dim servId As String
    Dim codAtivServ As String
    Dim totalRegistros As Long

    If SV_CR_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma atividade/serviço para gerar o relatório.", vbExclamation, "Relatório"
        Exit Sub
    End If

    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    Set wsRel = ThisWorkbook.Sheets(SHEET_RELATORIO)

    ativId = Pad3Rel(SafeListColumn(SV_CR_Lista, 1))
    servId = Pad3Rel(SafeListColumn(SV_CR_Lista, 0))
    codAtivServ = ativId & servId

    wsRel.Range("A:D").ClearContents
    wsRel.Cells(1, 1).Value = "COD.EMP"
    wsRel.Cells(1, 2).Value = "N CNPJ"
    wsRel.Cells(1, 3).Value = "RAZ" & ChrW(195) & "O SOCIAL"
    wsRel.Cells(1, 4).Value = "STATUS CRED"
    linhaOut = LINHA_DADOS

    ultima = UltimaLinhaAba(SHEET_CREDENCIADOS)
    If ultima >= LINHA_DADOS Then
        For i = LINHA_DADOS To ultima
            If CodAtivServIgual(wsCred.Cells(i, COL_CRED_COD_ATIV_SERV).Value, codAtivServ) Then
                wsRel.Cells(linhaOut, 1).Value = SafeCell(wsCred.Cells(i, COL_CRED_EMP_ID).Value)
                wsRel.Cells(linhaOut, 2).Value = SafeCell(wsCred.Cells(i, COL_CRED_CNPJ).Value)
                wsRel.Cells(linhaOut, 3).Value = SafeCell(wsCred.Cells(i, COL_CRED_RAZAO).Value)
                wsRel.Cells(linhaOut, 4).Value = SafeCell(wsCred.Cells(i, COL_CRED_STATUS).Value)
                linhaOut = linhaOut + 1
            End If
        Next i
    End If

    totalRegistros = linhaOut - LINHA_DADOS
    If totalRegistros <= 0 Then
        wsRel.Range("A:D").ClearContents
        MsgBox "Não há empresas credenciadas para a atividade/serviço selecionado.", vbInformation, "Relatório"
        Exit Sub
    End If

    On Error Resume Next
    wsRel.Columns("A:D").AutoFit
    Err.Clear
    On Error GoTo erro_carregamento
    Call Rel_ConfigurarPagina(wsRel, "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO", "D", False, xlPortrait)

    If MsgBox("Relatório gerado com " & CStr(totalRegistros) & " registro(s)." & vbCrLf & _
              "Identificação sugerida: " & Rel_NomeArquivoSugerido("RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO") & vbCrLf & _
              "Deseja imprimir agora? (Nao = visualizar na tela)", vbQuestion + vbYesNo, "Relatório") = vbYes Then
        If Application.Dialogs(xlDialogPrinterSetup).Show Then
            wsRel.PrintOut
            MsgBox "Relatório impresso com sucesso.", vbInformation, "Relatório"
        Else
            wsRel.PrintPreview
        End If
    Else
        wsRel.PrintPreview
    End If

    wsRel.Range("A1:D" & CStr(linhaOut - 1)).ClearContents
    Unload Me
    Exit Sub

erro_carregamento:
    MsgBox "Erro ao gerar relatório de empresas por serviço: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Function SafeListColumn(ByVal lb As Object, ByVal col As Long) As String
    On Error GoTo falha
    If lb.ListIndex < 0 Then Exit Function
    If col < 0 Or col >= lb.ColumnCount Then Exit Function
    SafeListColumn = Trim$(CStr(lb.List(lb.ListIndex, col)))
    Exit Function
falha:
    SafeListColumn = ""
End Function

Private Function SafeCell(ByVal v As Variant) As String
    If IsError(v) Or IsNull(v) Or IsEmpty(v) Then
        SafeCell = ""
    Else
        SafeCell = Trim$(CStr(v))
    End If
End Function

Private Function Pad3Rel(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    If s = "" Then
        Pad3Rel = ""
    ElseIf IsNumeric(s) Then
        Pad3Rel = Format$(CLng(Val(s)), "000")
    Else
        Pad3Rel = s
    End If
End Function

Private Function NormalizeCodAtivServ(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    s = Replace(s, " ", "")
    If s = "" Then
        NormalizeCodAtivServ = ""
    ElseIf IsNumeric(s) Then
        NormalizeCodAtivServ = Format$(CLng(Val(s)), "000000")
    Else
        NormalizeCodAtivServ = UCase$(s)
    End If
End Function

Private Function CodAtivServIgual(ByVal origem As Variant, ByVal alvo As String) As Boolean
    CodAtivServIgual = (NormalizeCodAtivServ(origem) = NormalizeCodAtivServ(alvo))
End Function


