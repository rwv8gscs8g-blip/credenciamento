VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Fundo_Branco 
   ClientHeight    =   3045
   ClientLeft      =   105
   ClientTop       =   448
   ClientWidth     =   4592
   OleObjectBlob   =   "Fundo_Branco.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Fundo_Branco"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False




Private Sub UserForm_Activate()
    Dim frmMenu As Object
    ' Ao ativar o fundo, exibe o Menu_Principal uma vez e encerra este formulário,
    ' evitando que o usuário fique preso em uma cadeia de telas.
    For Each frmMenu In VBA.UserForms
        If TypeName(frmMenu) = "Menu_Principal" Then
            If Not frmMenu.Visible Then frmMenu.Show
            Unload Me
            Exit Sub
        End If
    Next frmMenu

    Set frmMenu = VBA.UserForms.Add("Menu_Principal")
    frmMenu.Show
    Unload Me
End Sub


Private Sub UserForm_Layout()
    
    Me.Height = Application.Height 'altura
    Me.Width = Application.Width    'largura
    Me.Left = Application.Left      'esquerda
    Me.Top = Application.Top
    
End Sub


