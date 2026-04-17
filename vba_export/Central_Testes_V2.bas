Attribute VB_Name = "Central_Testes_V2"
Option Explicit

' ============================================================
' Central_Testes_V2
' Proposito: entrada isolada para a nova bateria V2.
' Nao altera a Central legada; pode ser importada e executada em paralelo.
' ============================================================

Public Sub CT2_AbrirCentral()
    On Error GoTo falha

    Dim op As String

    op = Trim$(InputBox( _
        "=== CENTRAL DE TESTES V2 ===" & vbCrLf & vbCrLf & _
        "[1] Smoke rapido" & vbCrLf & _
        "[2] Smoke assistido" & vbCrLf & _
        "[3] Stress deterministico" & vbCrLf & _
        "[4] Gerar catalogo semantico" & vbCrLf & _
        "[5] Abrir RESULTADO_QA_V2" & vbCrLf & _
        "[6] Abrir CATALOGO_CENARIOS_V2" & vbCrLf & vbCrLf & _
        "Digite o numero:", _
        "Central de Testes V2", "1"))

    If op = "" Then Exit Sub

    Select Case op
        Case "1"
            CT2_ExecutarSmokeRapido
        Case "2"
            CT2_ExecutarSmokeAssistido
        Case "3"
            CT2_ExecutarStress
        Case "4"
            TV2_GerarCatalogoBase
            TV2_AbrirCatalogo
        Case "5"
            TV2_AbrirResultado
        Case "6"
            TV2_AbrirCatalogo
        Case Else
            MsgBox "Opcao invalida.", vbInformation, "Central V2"
    End Select
    Exit Sub

falha:
    MsgBox "Erro na Central de Testes V2: " & Err.Description, vbExclamation, "Central V2"
End Sub

Public Sub CT2_ExecutarSmokeRapido()
    TV2_RunSmoke False
End Sub

Public Sub CT2_ExecutarSmokeAssistido()
    TV2_RunSmoke True
End Sub

Public Sub CT2_ExecutarStress()
    TV2_RunStress 12, False
End Sub

Public Sub CT2_ExecutarStressAssistido()
    TV2_RunStress 12, True
End Sub
