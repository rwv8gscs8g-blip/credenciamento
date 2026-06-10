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
    Me.caption = Rel_TituloExibicao("RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO")
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
    Dim estRel As Boolean
    Dim senRel As String
    Dim relPreparado As Boolean
    Dim errMsg As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim empId As String
    Dim statusCred As String
    Dim statusGlobal As String
    Dim diasRestantes As Long
    Dim retornoPrevisto As String
    Dim disponibilidadeOperacional As String
    Dim descAtiv As String
    Dim descServ As String
    Dim linhaHeader As Long
    Dim linhaDados As Long
    Dim strikesNota As String
    Dim strikesRecusa As String
    Dim diagnosticoSistema As String

    If SV_CR_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma atividade/serviço para gerar o relatório.", vbExclamation, "Relatório"
        Exit Sub
    End If

    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    Set wsRel = ThisWorkbook.Sheets(SHEET_RELATORIO)
    If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
        MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
        Exit Sub
    End If
    relPreparado = True

    ativId = Pad3Rel(SafeListColumn(SV_CR_Lista, 1))
    servId = Pad3Rel(SafeListColumn(SV_CR_Lista, 0))
    descAtiv = SafeListColumn(SV_CR_Lista, 2)
    descServ = SafeListColumn(SV_CR_Lista, 3)
    If descAtiv = "" Then descAtiv = "ATIVIDADE " & ativId
    If descServ = "" Then descServ = "SERVICO " & servId
    codAtivServ = ativId & servId

    wsRel.Cells.Clear
    wsRel.PageSetup.PrintArea = ""
    wsRel.Cells(1, 1).Value = "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO"
    wsRel.Cells(2, 1).Value = "ATIVIDADE"
    wsRel.Cells(2, 2).Value = ativId & " - " & descAtiv
    wsRel.Cells(3, 1).Value = "SERVICO"
    wsRel.Cells(3, 2).Value = servId & " - " & descServ
    wsRel.Cells(3, 5).Value = "COD_ATIV_SERV"
    wsRel.Cells(3, 6).Value = codAtivServ
    With wsRel.Range("A1:K1")
        .Merge
        .Font.Bold = True
        .Font.Size = 12
        .Interior.Color = RGB(217, 225, 242)
        .HorizontalAlignment = xlCenter
    End With
    wsRel.Range("A2:F3").Font.Bold = True

    linhaHeader = 5
    linhaDados = linhaHeader + 1
    wsRel.Cells(linhaHeader, 1).Value = "COD.EMP"
    wsRel.Cells(linhaHeader, 2).Value = "N CNPJ"
    wsRel.Cells(linhaHeader, 3).Value = "RAZ" & ChrW(195) & "O SOCIAL"
    wsRel.Cells(linhaHeader, 4).Value = "STATUS CRED"
    wsRel.Cells(linhaHeader, 5).Value = "STATUS EMPRESA"
    wsRel.Cells(linhaHeader, 6).Value = "DIAS RESTANTES"
    wsRel.Cells(linhaHeader, 7).Value = "SUSPENSA ATE"
    wsRel.Cells(linhaHeader, 8).Value = "DISPONIBILIDADE ATUAL"
    wsRel.Cells(linhaHeader, 9).Value = "STRIKES NOTA BAIXA"
    wsRel.Cells(linhaHeader, 10).Value = "STRIKES RECUSA/PRAZO"
    wsRel.Cells(linhaHeader, 11).Value = "RESUMO OPERACIONAL"
    linhaOut = linhaDados

    ultima = UltimaLinhaAba(SHEET_CREDENCIADOS)
    If ultima >= LINHA_DADOS Then
        For i = LINHA_DADOS To ultima
            If CodAtivServIgual(wsCred.Cells(i, COL_CRED_COD_ATIV_SERV).Value, codAtivServ) Then
                empId = SafeCell(wsCred.Cells(i, COL_CRED_EMP_ID).Value)
                statusCred = SafeCell(wsCred.Cells(i, COL_CRED_STATUS).Value)
                emp = LerEmpresa(empId, linhaEmp)
                If linhaEmp > 0 Then
                    statusGlobal = emp.STATUS_GLOBAL
                    diasRestantes = RRS_DiasRestantesSuspensao(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)
                    retornoPrevisto = RRS_SuspensaAteTexto(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)
                    disponibilidadeOperacional = RRS_DisponibilidadeOperacionalEmpresa(emp.EMP_ID, statusCred, ativId)
                    strikesNota = RRS_StrikesNotaBaixaTexto(emp.EMP_ID, emp.STATUS_GLOBAL)
                    strikesRecusa = RRS_StrikesRecusaPrazoTexto(emp.EMP_ID)
                    diagnosticoSistema = RRS_DiagnosticoOperacionalEmpresa(emp.EMP_ID, statusCred, ativId)
                Else
                    statusGlobal = "EMPRESA_NAO_ENCONTRADA"
                    diasRestantes = 0
                    retornoPrevisto = ""
                    disponibilidadeOperacional = "EMPRESA NAO ENCONTRADA"
                    strikesNota = "0"
                    strikesRecusa = "0"
                    diagnosticoSistema = "Empresa nao encontrada no cadastro."
                End If

                wsRel.Cells(linhaOut, 1).Value = empId
                wsRel.Cells(linhaOut, 2).Value = SafeCell(wsCred.Cells(i, COL_CRED_CNPJ).Value)
                wsRel.Cells(linhaOut, 3).Value = SafeCell(wsCred.Cells(i, COL_CRED_RAZAO).Value)
                wsRel.Cells(linhaOut, 4).Value = statusCred
                wsRel.Cells(linhaOut, 5).Value = RRS_StatusGlobalHumano(statusGlobal)
                wsRel.Cells(linhaOut, 6).Value = diasRestantes
                wsRel.Cells(linhaOut, 7).Value = retornoPrevisto
                wsRel.Cells(linhaOut, 8).Value = disponibilidadeOperacional
                wsRel.Cells(linhaOut, 9).Value = strikesNota
                wsRel.Cells(linhaOut, 10).Value = strikesRecusa
                wsRel.Cells(linhaOut, 11).Value = diagnosticoSistema
                linhaOut = linhaOut + 1
            End If
        Next i
    End If

    totalRegistros = linhaOut - linhaDados
    If totalRegistros <= 0 Then
        wsRel.Cells.Clear
        wsRel.PageSetup.PrintArea = ""
        Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
        relPreparado = False
        MsgBox "Não há empresas credenciadas para a atividade/serviço selecionado.", vbInformation, "Relatório"
        Exit Sub
    End If

    On Error Resume Next
    wsRel.Columns("A:K").AutoFit
    Err.Clear
    On Error GoTo erro_carregamento
    Call Rel_FormatarCabecalho(wsRel, 11, linhaHeader)
    Call Rel_FormatarDados(wsRel, linhaDados, linhaOut - 1, 11)
    Call Rel_ConfigurarPagina(wsRel, "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO", "K", False, xlLandscape)
    Call Rel_DefinirAreaImpressao(wsRel, wsRel.Range("A1:K" & CStr(linhaOut - 1)))

    If MsgBox("Relatório gerado com " & CStr(totalRegistros) & " registro(s)." & vbCrLf & _
              "Identificação sugerida: " & Rel_NomeArquivoSugerido("RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO") & vbCrLf & _
              "Deseja imprimir agora? (Nao = cancelar)", vbQuestion + vbYesNo, "Relatório") = vbYes Then
        If Application.Dialogs(xlDialogPrinterSetup).Show Then
            wsRel.PrintOut
            MsgBox "Relatório impresso com sucesso.", vbInformation, "Relatório"
        Else
            MsgBox "Impressão cancelada.", vbInformation, "Relatório"
        End If
    Else
        MsgBox "Relatório cancelado.", vbInformation, "Relatório"
    End If

    wsRel.Cells.Clear
    wsRel.PageSetup.PrintArea = ""
    Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    relPreparado = False
    Unload Me
    Exit Sub

erro_carregamento:
    errMsg = Err.Description
    On Error Resume Next
    If Not wsRel Is Nothing Then
        wsRel.PageSetup.PrintArea = ""
        wsRel.Cells.Clear
        If relPreparado Then Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    End If
    On Error GoTo 0
    If errMsg = "" Then errMsg = "Erro não identificado."
    MsgBox "Erro ao gerar relatório de empresas por serviço: " & errMsg, vbCritical, "Relatório"
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


