VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Reativa_Empresa 
   Caption         =   "REATIVA EMPRESA"
   ClientHeight    =   4907
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14539
   OleObjectBlob   =   "Reativa_Empresa.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Reativa_Empresa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private WithEvents mTxtBusca As MSForms.TextBox
Attribute mTxtBusca.VB_VarHelpID = -1

Private Function UI_TextBoxSeExiste(ByVal nome As String) As MSForms.TextBox
    On Error Resume Next
    Set UI_TextBoxSeExiste = Me.Controls(nome)
    On Error GoTo 0
End Function

Private Function UI_PegarTextBoxBuscaTopoDireita() As MSForms.TextBox
    Dim ctl As Object
    Dim melhor As MSForms.TextBox
    Dim leftMax As Double

    On Error GoTo fim

    leftMax = -1
    For Each ctl In Me.Controls
        If TypeName(ctl) = "TextBox" Then
            If ctl.Top <= 20 And ctl.Height <= 22 Then
                If CDbl(ctl.Left) > leftMax Then
                    leftMax = CDbl(ctl.Left)
                    Set melhor = ctl
                End If
            End If
        End If
    Next ctl

    Set UI_PegarTextBoxBuscaTopoDireita = melhor
    Exit Function
fim:
End Function

Private Function UI_SafeListVal(ByVal valor As Variant) As String
    If IsError(valor) Then Exit Function
    If IsNull(valor) Then Exit Function
    If IsEmpty(valor) Then Exit Function

    On Error Resume Next
    UI_SafeListVal = CStr(valor)
    If Err.Number <> 0 Then UI_SafeListVal = ""
    On Error GoTo 0
End Function

Private Function UI_LinhaEmpresaValida(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long) As Boolean
    UI_LinhaEmpresaValida = (Trim$(UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_ID).Value)) <> "" Or _
                             Trim$(UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_CNPJ).Value)) <> "" Or _
                             Trim$(UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_RAZAO).Value)) <> "")
End Function

Private Function UI_TextoEmpresaParaFiltro(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long) As String
    UI_TextoEmpresaParaFiltro = UCase$( _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_ID).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_CNPJ).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_RAZAO).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_RESPONSAVEL).Value))
End Function

Private Function UI_LinhaEmpresaPassaFiltro(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long, ByVal filtroU As String) As Boolean
    If filtroU = "" Then
        UI_LinhaEmpresaPassaFiltro = True
    Else
        UI_LinhaEmpresaPassaFiltro = (InStr(1, UI_TextoEmpresaParaFiltro(wsEmpInativas, linhaAtual), filtroU, vbBinaryCompare) > 0)
    End If
End Function

Private Sub UI_PreencherListaEmpresasInativas(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEmpInativas As Worksheet
Dim total As Long
Dim idx As Long
Dim linhaAtual As Long
Dim colunaAtual As Long
Dim filtroU As String
Dim arrayitems() As Variant

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsEmpInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
NLinhas = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
Set lst = Me.Controls("RM_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .ColumnCount = 19
    .ColumnWidths = EmpresaLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then Exit Sub

For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEmpresaValida(wsEmpInativas, linhaAtual) Then
        If UI_LinhaEmpresaPassaFiltro(wsEmpInativas, linhaAtual, filtroU) Then
            total = total + 1
        End If
    End If
Next linhaAtual

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 19)
idx = 1
For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEmpresaValida(wsEmpInativas, linhaAtual) Then
        If UI_LinhaEmpresaPassaFiltro(wsEmpInativas, linhaAtual, filtroU) Then
            For colunaAtual = 1 To 19
                arrayitems(idx, colunaAtual) = UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, colunaAtual).Value)
            Next colunaAtual
            idx = idx + 1
        End If
    End If
Next linhaAtual

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub

Private Sub UserForm_Initialize()
On Error GoTo fim
    ' V12.0.0006: formulario popula a propria lista ao inicializar.
    ' PreenchimentoEmpresa_Inativo usa ControleFormulario("Reativa_Empresa", "RM_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra RM_Lista corretamente.
    ' V12.0.0108: TextBox de busca precisa existir no designer; o codigo apenas conecta ao controle.
    Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    Call UI_PreencherListaEmpresasInativas(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
On Error GoTo fim
    If mTxtBusca Is Nothing Then Exit Sub
    Call UI_PreencherListaEmpresasInativas(CStr(mTxtBusca.Text))
fim:
End Sub

Private Sub RM_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell + Selection (proibidos; formulario modal).
    ' Usa referencia direta via .Find, .Copy Destination:=, .Delete e loop por Cells(i, col).
    Dim wsInativas As Worksheet
    Dim wsEmpresas As Worksheet
    Dim wsCred As Worksheet
    Dim linhaDestino As Long
    Dim linhaCredAtual As Long
    Dim ultimaLinhaCred As Long
    Dim linhaReativAtual As Long
    Dim linhaFinalInativas As Long
    Dim estProt As Boolean
    Dim Senha As String
    Dim empresaIdReativ As String
    Dim cnpjReativ As String
    Dim linhaDuplicada As Long

    empresaIdReativ = Trim$(CStr(RM_Lista.Column(0)))
    If empresaIdReativ = "" Then Exit Sub

    Set wsInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    Set wsEmpresas = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    ' V12.0.0007: loop normalizado em vez de Range.Find (elimina mismatch de tipo "001" texto vs 1 numerico).
    linhaFinalInativas = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
    Set EncontrarID = Nothing
    For linhaReativAtual = LINHA_DADOS To linhaFinalInativas
        If Trim$(CStr(wsInativas.Cells(linhaReativAtual, COL_EMP_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsInativas.Cells(linhaReativAtual, COL_EMP_ID).Value)))) = CLng(Val("0" & empresaIdReativ)) Then
                Set EncontrarID = wsInativas.Cells(linhaReativAtual, COL_EMP_ID)
                Exit For
            End If
        End If
    Next linhaReativAtual
    If EncontrarID Is Nothing Then
        MsgBox "Empresa n" & ChrW(227) & "o encontrada nas inativas.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    cnpjReativ = Trim$(CStr(wsInativas.Cells(EncontrarID.row, COL_EMP_CNPJ).Value))
    linhaDuplicada = Util_LinhaDuplicadaIdOuDocumento( _
                        wsEmpresas, _
                        PrimeiraLinhaDadosEmpresas(), _
                        COL_EMP_ID, _
                        empresaIdReativ, _
                        COL_EMP_CNPJ, _
                        cnpjReativ)
    If linhaDuplicada > 0 Then
        MsgBox "Reativa" & ChrW(231) & ChrW(227) & "o bloqueada: j" & ChrW(225) & " existe empresa ativa com o mesmo ID ou CNPJ na aba EMPRESAS." & vbCrLf & _
               "Linha ativa: " & CStr(linhaDuplicada) & vbCrLf & _
               "Fa" & ChrW(231) & "a o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja REATIVAR esta Empresa?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    ' Copiar linha para aba de empresas ativas
    linhaDestino = wsEmpresas.Cells(wsEmpresas.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEmpresas, estProt, Senha)
    EncontrarID.EntireRow.Copy Destination:=wsEmpresas.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEmpresas, estProt, Senha)
    Application.CutCopyMode = False

    ' Remover linha da aba de inativas
    Call Util_PrepararAbaParaEscrita(wsInativas, estProt, Senha)
    If Not Util_ExcluirLinhaSegura(wsInativas, EncontrarID.row) Then
        Err.Raise 1004, "Reativar_Empresa", "Nao foi possivel excluir a linha da empresa na aba EMPRESAS_INATIVAS."
    End If
    Call Util_RestaurarProtecaoAba(wsInativas, estProt, Senha)

    ' V12.0.0007: desproteger CREDENCIADOS antes do sort + limpeza do flag de inativo.
    ' Comparacao de ID normalizada (CLng/Val) para cobrir "001" texto vs 1 numerico.
    ultimaLinhaCred = UltimaLinhaAba(SHEET_CREDENCIADOS)
    If ultimaLinhaCred >= LINHA_DADOS Then
        Call Util_PrepararAbaParaEscrita(wsCred, estProt, Senha)
        Call ClassificaCredenciadoInativo
        For linhaCredAtual = LINHA_DADOS To ultimaLinhaCred
            If Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)) <> "" Then
                If CLng(Val("0" & Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)))) = CLng(Val("0" & Trim$(empresaIdReativ))) Then
                    wsCred.Cells(linhaCredAtual, COL_CRED_ATIV_ID).Value = ""
                End If
            End If
        Next linhaCredAtual
        Call Util_RestaurarProtecaoAba(wsCred, estProt, Senha)
    End If

    MsgBox "Empresa Reativada com sucesso!", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao reativar empresa: " & Err.Description, vbCritical, "Erro"
End Sub


