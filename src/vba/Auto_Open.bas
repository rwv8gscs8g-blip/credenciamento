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
    AutoOpen_VerificarBackfillDtUltReativ

    ' Mostrar o menu principal
    For Each frm In VBA.UserForms
        If typeName(frm) = "Menu_Principal" Then
            If Not frm.Visible Then frm.Show
            Exit Sub
        End If
    Next frm

    Set frm = VBA.UserForms.Add("Menu_Principal")
    frm.Show
End Sub

Private Sub AutoOpen_VerificarBackfillDtUltReativ()
    Dim res As TResult
    Dim qtdPendentes As Long
    Dim detalhes As String

    On Error GoTo fim
    res = RepoEmpresa_DtUltReativBackfillResumo(qtdPendentes, detalhes)
    If res.sucesso And qtdPendentes > 0 Then
        Application.StatusBar = "Credenciamento: " & CStr(qtdPendentes) & _
            " empresa(s) com DT_ULT_REATIV pendente de backfill assistido."
    End If

fim:
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


