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



Option Explicit

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

Private Sub UserForm_Initialize()
On Error GoTo fim
    ' V12.0.0006: formulario popula a propria lista ao inicializar.
    ' PreenchimentoEntidadeInativa usa ControleFormulario("Reativa_Entidade", "R_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra R_Lista corretamente.
    ' Nome físico confirmado em VBE: TextBox16 (campo topo-direita)
    Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    Call PreenchimentoEntidadeInativa(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
    On Error GoTo fim
    Call PreenchimentoEntidadeInativa(CStr(mTxtBusca.Text))
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

    If MsgBox("Tem certeza que deseja REATIVAR esta Entidade?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    ' Copiar linha para aba de entidades ativas
    linhaDestino = wsEntidade.Cells(wsEntidade.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEntidade, estProt, Senha)
    EncontrarID.EntireRow.Copy Destination:=wsEntidade.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEntidade, estProt, Senha)
    Application.CutCopyMode = False

    ' Remover linha da aba de inativas
    Call Util_PrepararAbaParaEscrita(wsInativas, estProt, Senha)
    EncontrarID.EntireRow.Delete
    Call Util_RestaurarProtecaoAba(wsInativas, estProt, Senha)

    Call ClassificaEntidade
    MsgBox "Entidade Reativada com sucesso!", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao reativar entidade: " & Err.Description, vbCritical, "Erro"
End Sub


