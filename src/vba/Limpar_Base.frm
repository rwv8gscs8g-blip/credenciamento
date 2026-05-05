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

Private Sub CommandButton1_Click()
On Error GoTo erro_limpeza

  If Cod_Senha <> "sebrae2024" Then
    MsgBox "A senha est" & ChrW$(225) & " incorreta!"
    Cod_Senha = ""
    Cod_Senha.SetFocus
    Me.Hide
    Exit Sub
  Else
    If mLimpezaEmAndamento Then
      MsgBox "Limpeza da base ja em andamento. Aguarde a conclusao.", vbInformation, "Limpar Base"
      Exit Sub
    End If
    mLimpezaEmAndamento = True
    Me.Hide
    Call Limpa_Base
  End If
  mLimpezaEmAndamento = False
  Cod_Senha = ""
  Exit Sub

erro_limpeza:
  mLimpezaEmAndamento = False
  Cod_Senha = ""
  MsgBox "Erro ao limpar base: " & Err.Description, vbCritical, "Limpar Base"
End Sub


