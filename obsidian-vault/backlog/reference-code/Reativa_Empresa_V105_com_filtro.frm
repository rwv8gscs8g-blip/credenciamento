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
            ' Heurística: campo pequeno no topo e o mais à direita possível.
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
    ' PreenchimentoEmpresa_Inativo usa ControleFormulario("Reativa_Empresa", "RM_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra RM_Lista corretamente.
    ' Nome físico confirmado em VBE: TextBox16 (campo topo-direita)
    Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    Call PreenchimentoEmpresa_Inativo(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
    On Error GoTo fim
    Call PreenchimentoEmpresa_Inativo(CStr(mTxtBusca.Text))
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

    If MsgBox("Tem certeza que deseja REATIVAR esta Empresa?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    ' Copiar linha para aba de empresas ativas
    linhaDestino = wsEmpresas.Cells(wsEmpresas.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEmpresas, estProt, Senha)
    EncontrarID.EntireRow.Copy Destination:=wsEmpresas.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEmpresas, estProt, Senha)
    Application.CutCopyMode = False

    ' Remover linha da aba de inativas
    Call Util_PrepararAbaParaEscrita(wsInativas, estProt, Senha)
    EncontrarID.EntireRow.Delete
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


