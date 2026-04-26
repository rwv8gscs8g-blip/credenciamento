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

    TV2_PrepararNavegacaoHumana

    op = Trim$(InputBox( _
        "=== CENTRAL DE TESTES V2 ===" & vbCrLf & vbCrLf & _
        "[1] Smoke rapido (~2 min)" & vbCrLf & _
        "[2] Smoke assistido (~3 min)" & vbCrLf & _
        "[3] Stress deterministico (~3 min)" & vbCrLf & _
        "[4] Stress assistido (~5 min)" & vbCrLf & _
        "[5] Suite canonica (fundacao, ~3 min)" & vbCrLf & _
        "[6] Abrir roteiro assistido V2" & vbCrLf & _
        "[7] Abrir RESULTADO_QA_V2" & vbCrLf & _
        "[8] Abrir CATALOGO_CENARIOS_V2" & vbCrLf & _
        "[9] Abrir HISTORICO_QA_V2" & vbCrLf & _
        "[10] Abrir TESTE_TRILHA" & vbCrLf & _
        "[11] Abrir AUDIT_TESTES" & vbCrLf & _
        "[12] Validacao release: V1 + Smoke + Canonico (~10 min)" & vbCrLf & _
        "[13] Filtros deterministicos (~1 min)" & vbCrLf & vbCrLf & _
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
            CT2_ExecutarStressAssistido
        Case "5"
            CT2_ExecutarCanonicoFundacao
        Case "6"
            TV2_AbrirRoteiroAssistido
        Case "7"
            TV2_AbrirResultado
        Case "8"
            TV2_AbrirCatalogo
        Case "9"
            TV2_AbrirHistorico
        Case "10"
            TV2_AbrirTrilha
        Case "11"
            TV2_AbrirAuditTestes
        Case "12"
            CT_ValidarRelease_TrioMinimo
        Case "13"
            CT2_ExecutarFiltrosDeterministicos
        Case Else
            MsgBox "Opcao invalida.", vbInformation, "Central V2"
    End Select
    Exit Sub

falha:
    MsgBox "Erro na Central de Testes V2: " & Err.Description, vbExclamation, "Central V2"
End Sub

Public Sub CT2_ExecutarSmokeRapido()
    TV2_PrepararNavegacaoHumana
    TV2_RunSmoke False
End Sub

Public Sub CT2_ExecutarSmokeAssistido()
    TV2_PrepararNavegacaoHumana
    TV2_RunSmoke True
End Sub

Public Sub CT2_ExecutarStress()
    TV2_PrepararNavegacaoHumana
    TV2_RunStress 12, False
End Sub

Public Sub CT2_ExecutarStressAssistido()
    TV2_PrepararNavegacaoHumana
    TV2_RunStress 12, True
End Sub

Public Sub CT2_ExecutarCanonicoFundacao()
    TV2_PrepararNavegacaoHumana
    TV2_RunCanonicoFundacao False
End Sub

Public Sub CT2_ExecutarFiltrosDeterministicos()
    TV2_PrepararNavegacaoHumana
    TV2_RunFiltros False
End Sub
