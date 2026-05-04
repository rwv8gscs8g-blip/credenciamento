Attribute VB_Name = "Auto_Open"
Option Explicit

' =============================================================================
' Auto_Open.bas - Inicialização do sistema ao abrir o workbook
' Este módulo é chamado automaticamente pelo Excel ao abrir o arquivo.
' =============================================================================

Private Sub InicializarSistema()
    ' Proteger abas críticas com UserInterfaceOnly
    Dim frm As Object
    Dim qtdCnae As Long

    On Error Resume Next
    Call ProtegerAbasCriticas
    qtdCnae = CargaInicialCNAE_SeNecessario(False)
    On Error GoTo 0

    ' Mostrar o menu principal
    For Each frm In VBA.UserForms
        If TypeName(frm) = "Menu_Principal" Then
            If Not frm.Visible Then frm.Show
            Exit Sub
        End If
    Next frm

    Set frm = VBA.UserForms.Add("Menu_Principal")
    frm.Show
End Sub

Public Sub Auto_Open()
    InicializarSistema
End Sub

Public Sub IniciarSistema()
    InicializarSistema
End Sub

Public Sub AbrirMenu()
    ' Atalho manual para abrir o menu (pode ser atribuído a um botão)
    InicializarSistema
End Sub


