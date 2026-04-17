VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Reativa_Entidade 
   Caption         =   "REATIVA ENTIDADE"
   ClientHeight    =   5040
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14280
   OleObjectBlob   =   "Reativa_Entidade.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Reativa_Entidade"
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

Private Function UI_LinhaEntidadeValida(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long) As Boolean
    UI_LinhaEntidadeValida = (Trim$(UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_ID).Value)) <> "" Or _
                              Trim$(UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CNPJ).Value)) <> "" Or _
                              Trim$(UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_NOME).Value)) <> "")
End Function

Private Function UI_TextoEntidadeParaFiltro(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long) As String
    UI_TextoEntidadeParaFiltro = UCase$( _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_ID).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CNPJ).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_NOME).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_TEL_CEL).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CONT1_NOME).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CONT1_FONE).Value))
End Function

Private Function UI_LinhaEntidadePassaFiltro(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long, ByVal filtroU As String) As Boolean
    If filtroU = "" Then
        UI_LinhaEntidadePassaFiltro = True
    Else
        UI_LinhaEntidadePassaFiltro = (InStr(1, UI_TextoEntidadeParaFiltro(wsEntInativas, linhaAtual), filtroU, vbBinaryCompare) > 0)
    End If
End Function

Private Sub UI_PreencherListaEntidadesInativas(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEntInativas As Worksheet
Dim total As Long
Dim idx As Long
Dim linhaAtual As Long
Dim colunaAtual As Long
Dim filtroU As String
Dim arrayitems() As Variant

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsEntInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
NLinhas = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
Set lst = Me.Controls("R_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .ColumnCount = 22
    .ColumnWidths = EntidadeLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then Exit Sub

For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEntidadeValida(wsEntInativas, linhaAtual) Then
        If UI_LinhaEntidadePassaFiltro(wsEntInativas, linhaAtual, filtroU) Then
            total = total + 1
        End If
    End If
Next linhaAtual

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 22)
idx = 1
For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEntidadeValida(wsEntInativas, linhaAtual) Then
        If UI_LinhaEntidadePassaFiltro(wsEntInativas, linhaAtual, filtroU) Then
            For colunaAtual = 1 To 22
                arrayitems(idx, colunaAtual) = UI_SafeListVal(wsEntInativas.Cells(linhaAtual, colunaAtual).Value)
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
    ' PreenchimentoEntidadeInativa usa ControleFormulario("Reativa_Entidade", "R_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra R_Lista corretamente.
    ' V12.0.0110: TextBox de busca precisa existir no designer; o codigo apenas conecta ao controle.
    Set mTxtBusca = UI_TextBoxSeExiste("TxtFiltro_ReativaEntidade")
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    Call UI_PreencherListaEntidadesInativas(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
On Error GoTo fim
    If mTxtBusca Is Nothing Then Exit Sub
    Call UI_PreencherListaEntidadesInativas(CStr(mTxtBusca.Text))
fim:
End Sub

Private Sub R_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell + Selection (proibidos; formulario modal).
    ' Usa referencia direta via .Find, .Copy Destination:= e .Delete.
    Dim wsInativas As Worksheet
    Dim wsEntidade As Worksheet
    Dim linhaDestino As Long
    Dim linhaReativAtual As Long
    Dim linhaFinalInativas As Long
    Dim estProt As Boolean
    Dim Senha As String
    Dim entidadeIdReativ As String
    Dim cnpjReativ As String
    Dim linhaDuplicada As Long

    entidadeIdReativ = Trim$(CStr(R_Lista.Column(0)))
    If entidadeIdReativ = "" Then Exit Sub

    Set wsInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
    Set wsEntidade = ThisWorkbook.Sheets(SHEET_ENTIDADE)

    ' V12.0.0007: loop normalizado em vez de Range.Find (elimina mismatch de tipo "001" texto vs 1 numerico).
    ' CLng(Val("0" & CStr(x))) converte "001", "1" e 1 ao mesmo valor Long = 1.
    linhaFinalInativas = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
    Set EncontrarID = Nothing
    For linhaReativAtual = LINHA_DADOS To linhaFinalInativas
        If Trim$(CStr(wsInativas.Cells(linhaReativAtual, COL_ENT_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsInativas.Cells(linhaReativAtual, COL_ENT_ID).Value)))) = CLng(Val("0" & entidadeIdReativ)) Then
                Set EncontrarID = wsInativas.Cells(linhaReativAtual, COL_ENT_ID)
                Exit For
            End If
        End If
    Next linhaReativAtual
    If EncontrarID Is Nothing Then
        MsgBox "Entidade n" & ChrW(227) & "o encontrada nas inativas.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    cnpjReativ = Trim$(CStr(wsInativas.Cells(EncontrarID.row, COL_ENT_CNPJ).Value))
    linhaDuplicada = Util_LinhaDuplicadaIdOuDocumento( _
                        wsEntidade, _
                        LINHA_DADOS, _
                        COL_ENT_ID, _
                        entidadeIdReativ, _
                        COL_ENT_CNPJ, _
                        cnpjReativ)
    If linhaDuplicada > 0 Then
        MsgBox "Reativa" & ChrW(231) & ChrW(227) & "o bloqueada: j" & ChrW(225) & " existe entidade ativa com o mesmo ID ou CNPJ na aba ENTIDADE." & vbCrLf & _
               "Linha ativa: " & CStr(linhaDuplicada) & vbCrLf & _
               "Fa" & ChrW(231) & "a o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja REATIVAR esta Entidade?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    ' Copiar linha para aba de entidades ativas
    linhaDestino = wsEntidade.Cells(wsEntidade.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEntidade, estProt, Senha)
    EncontrarID.EntireRow.Copy Destination:=wsEntidade.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEntidade, estProt, Senha)
    Application.CutCopyMode = False

    ' Remover linha da aba de inativas
    Call Util_PrepararAbaParaEscrita(wsInativas, estProt, Senha)
    If Not Util_ExcluirLinhaSegura(wsInativas, EncontrarID.row) Then
        Err.Raise 1004, "Reativar_Entidade", "Nao foi possivel excluir a linha da entidade na aba ENTIDADE_INATIVOS."
    End If
    Call Util_RestaurarProtecaoAba(wsInativas, estProt, Senha)

    Call ClassificaEntidade
    MsgBox "Entidade Reativada com sucesso!", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao reativar entidade: " & Err.Description, vbCritical, "Erro"
End Sub


