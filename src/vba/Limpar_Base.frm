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




Private Sub CommandButton1_Click()

  If Cod_Senha <> Util_SenhaProtecaoPadrao() Then
    MsgBox "A senha est" & ChrW(225) & " incorreta!"
    Cod_Senha = ""
    Cod_Senha.SetFocus
    Me.Hide
    Exit Sub
  Else
    Me.Hide
    Call Limpa_Base
  End If
  Cod_Senha = ""
End Sub


