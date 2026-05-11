VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Limpar_Base 
   Caption         =   "Limpar Base"
   ClientHeight    =   2072
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   4564
   OleObjectBlob   =   "Limpar_Base.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Limpar_Base"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private mLimpezaEmAndamento As Boolean

Private Sub UserForm_Initialize()
On Error Resume Next
  Cod_Senha.PasswordChar = "*"
On Error GoTo 0
End Sub

Private Sub CommandButton1_Click()
On Error GoTo erro_limpeza

  If Not MLB_SenhaLimpezaValida(CStr(Cod_Senha.Value)) Then
    Call MLB_RegistrarTentativaLimpeza(False, "senha invalida")
    MsgBox "A senha est" & ChrW$(225) & " incorreta!"
    Cod_Senha = ""
    Cod_Senha.SetFocus
    Exit Sub
  Else
    If mLimpezaEmAndamento Then
      MsgBox "Limpeza da base ja em andamento. Aguarde a conclusao.", vbInformation, "Limpar Base"
      Exit Sub
    End If
    mLimpezaEmAndamento = True
    Me.Hide
    Call Limpa_Base
    Call MLB_RegistrarTentativaLimpeza(True, "limpeza solicitada via form")
  End If
  mLimpezaEmAndamento = False
  Cod_Senha = ""
  Exit Sub

erro_limpeza:
  mLimpezaEmAndamento = False
  Cod_Senha = ""
  MsgBox "Erro ao limpar base: " & Err.Description, vbCritical, "Limpar Base"
End Sub


