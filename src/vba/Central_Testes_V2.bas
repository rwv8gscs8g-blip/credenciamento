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
    Dim buildLabel As String
    Dim prompt As String

    TV2_PrepararNavegacaoHumana

    buildLabel = AppRelease_BuildImportado()
    If Trim$(buildLabel) = "" Then buildLabel = "BUILD_NAO_INFORMADO"

    ' V12.0.0203 ONDA 16 MD-16.3 fix1 (2026-05-02) - prompt acumulado em
    ' variavel local em vez de 25+ line continuations consecutivas no
    ' InputBox. Causa raiz do erro 40192 no Importador V3 era exatamente
    ' o limite de ~25 line continuations da gramatica VBA. Padrao novo:
    ' construir prompt aos pedacos via &= para qualquer InputBox/MsgBox
    ' com mais de ~15 linhas de texto. (Licao L19 oficial.)
    ' V12.0.0203 ONDA 17 MD-17.1.e (2026-05-03) - menu renumerado para
    ' fluxo semantico (Gates -> V1 -> V2 -> Visualizacao -> Utilitarios)
    ' + remocao de [2]/[4]/[6] assistidos da mensagem (status bar L26/L27
    ' ja entregue resolveu funcao pedagogica). Subs CT2_ExecutarSmokeAssistido
    ' / CT2_ExecutarStressAssistido / TV2_AbrirRoteiroAssistido continuam
    ' Public callable do VBE - apenas saem da mensagem visivel.
    ' V12.0.0203 ONDA 17 MD-17.3 / Bloco A (2026-05-03) - Quinteto Minimo
    ' entra como [1] OFICIAL (V1+V2_Smoke+V2_Canonica+E2E_Strikes+IntegridadeBase).
    ' Quarteto vira [2] (gate intermediario rapido), Trio vira [3] legado.
    ' Renumeracao geral +1 nas opcoes 4-17 (era 3-16). Default InputBox = "1".
    ' V12.0.0204 ONDA 23 MD-23.1 (2026-05-07) - adiciona [10] V2 Adversarial
    ' UI. MD-23.2 adiciona [11] V2 Transacao Interrupt. MD-23.3 adiciona
    ' [12] V2 Boundary Dates; Visualizacao passa para [13-18] e Utilitarios
    ' para [19-20].
    ' V12.0.0204 ONDA 23 MD-23.5 (2026-05-09) - Sexteto vira [1]
    ' OFICIAL; Quinteto/Quarteto/Trio descem para [2]/[3]/[4].
    prompt = "=== CENTRAL DE TESTES V2 ===" & vbCrLf
    prompt = prompt & "Build: " & buildLabel & vbCrLf
    prompt = prompt & "Gate oficial vigente: [1] Sexteto Minimo" & vbCrLf & vbCrLf
    prompt = prompt & ">> GATES DE RELEASE (rodar antes de homologar)" & vbCrLf
    prompt = prompt & "[1] Sexteto Minimo   (Quinteto + bloco adversarial Onda 23)  *** OFICIAL ***" & vbCrLf
    prompt = prompt & "[2] Quinteto Minimo  (V1 + V2 Smoke + V2 Canonica + V2 E2E Strikes + V2 IntegridadeBase)  -- compatibilidade" & vbCrLf
    prompt = prompt & "[3] Quarteto Minimo  (V1 + V2 Smoke + V2 Canonica + V2 E2E Strikes)  -- gate intermediario rapido" & vbCrLf
    prompt = prompt & "[4] Trio Minimo      (V1 + V2 Smoke + V2 Canonica)  -- legado" & vbCrLf & vbCrLf
    prompt = prompt & ">> BATERIA V1 (executavel direto)" & vbCrLf
    prompt = prompt & "[5] V1 - Bateria Oficial completa (~5 min)" & vbCrLf & vbCrLf
    prompt = prompt & ">> BATERIA V2 (suites parciais)" & vbCrLf
    prompt = prompt & "[6] V2 Smoke rapido            (~30 s)" & vbCrLf
    prompt = prompt & "[7] V2 Suite Canonica           (~3 min)" & vbCrLf
    prompt = prompt & "[8] V2 Stress deterministico    (~3 min)" & vbCrLf
    prompt = prompt & "[9] V2 Filtros deterministicos  (~1 min)" & vbCrLf
    prompt = prompt & "[10] V2 E2E Strikes             (~2 min)" & vbCrLf & vbCrLf
    prompt = prompt & "[11] V2 Adversarial UI          (~30 s)" & vbCrLf
    prompt = prompt & "[12] V2 Transacao Interrupt     (~30 s)" & vbCrLf
    prompt = prompt & "[13] V2 Boundary Dates          (~30 s)" & vbCrLf & vbCrLf
    prompt = prompt & ">> VISUALIZACAO (abrir aba)" & vbCrLf
    prompt = prompt & "[14] RESULTADO_QA_V2" & vbCrLf
    prompt = prompt & "[15] CATALOGO_CENARIOS_V2" & vbCrLf
    prompt = prompt & "[16] HISTORICO_QA_V2" & vbCrLf
    prompt = prompt & "[17] TESTE_TRILHA" & vbCrLf
    prompt = prompt & "[18] AUDIT_TESTES" & vbCrLf
    prompt = prompt & "[19] EVOLUCAO_TESTES (regressao + media movel)" & vbCrLf & vbCrLf
    prompt = prompt & ">> UTILITARIOS" & vbCrLf
    prompt = prompt & "[20] Roteiro Assistido V2 (navegacao guiada)" & vbCrLf
    prompt = prompt & "[21] Limpar testes antigos" & vbCrLf & vbCrLf
    prompt = prompt & "Digite o numero:"

    op = Trim$(InputBox(prompt, "Central de Testes V2", "1"))

    If op = "" Then Exit Sub

    Select Case op
        Case "1"
            CT_ValidarRelease_SextetoMinimo
        Case "2"
            CT_ValidarRelease_QuintetoMinimo
        Case "3"
            CT_ValidarRelease_QuartetoMinimo
        Case "4"
            CT_ValidarRelease_TrioMinimo
        Case "5"
            CT2_ExecutarBateriaV1
        Case "6"
            CT2_ExecutarSmokeRapido
        Case "7"
            CT2_ExecutarCanonicoFundacao
        Case "8"
            CT2_ExecutarStress
        Case "9"
            CT2_ExecutarFiltrosDeterministicos
        Case "10"
            CT2_ExecutarStrikes
        Case "11"
            CT2_ExecutarAdversarialUI
        Case "12"
            CT2_ExecutarTransactionInterrupt
        Case "13"
            CT2_ExecutarBoundaryDates
        Case "14"
            TV2_AbrirResultado
        Case "15"
            TV2_AbrirCatalogo
        Case "16"
            TV2_AbrirHistorico
        Case "17"
            TV2_AbrirTrilha
        Case "18"
            TV2_AbrirAuditTestes
        Case "19"
            Util_Evolucao_AbrirEMostrar
        Case "20"
            TV2_AbrirRoteiroAssistido
        Case "21"
            CT2_ExecutarLimparTestes
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

' V12.0.0203 ONDA 10 Microdelta 1.5 fix4 - opcao end-to-end strikes
' chama TV2_RunRodizioStrikesEndToEnd (cenarios CS_E2E_*), que substitui
' TV2_RunStrikes (deprecated). A nova suite usa rodizio natural sem
' manipular fila e e idempotente por design.
' (Renumerada na MD-17.1.e: era [14] no menu antigo, agora [8].)
Public Sub CT2_ExecutarStrikes()
    TV2_PrepararNavegacaoHumana
    TV2_RunRodizioStrikesEndToEnd False
End Sub

Public Sub CT2_ExecutarAdversarialUI()
    TV2_PrepararNavegacaoHumana
    TV2_RunAdversarial_UI False
End Sub

Public Sub CT2_ExecutarTransactionInterrupt()
    TV2_PrepararNavegacaoHumana
    TV2_RunTransaction_Interrupt False
End Sub

Public Sub CT2_ExecutarBoundaryDates()
    TV2_PrepararNavegacaoHumana
    TV2_RunBoundary_Dates False
End Sub

' V12.0.0203 ONDA 17 MD-17.1.e (2026-05-03) - novas Subs Public para
' atalhos do menu renumerado: [3] V1 Bateria + [16] Limpar testes antigos.
' Mantem o padrao "uma porta de entrada" (Central V2) sem precisar abrir
' Central V1. CT2_ExecutarLimparTestes delega para wrapper Public
' CT_LimparTestesAntigos em Central_Testes.bas (que adiciona MsgBox de
' confirmacao antes de chamar a Private CT_LimparArtefatosTesteV1
' ja existente desde Onda 10).

Public Sub CT2_ExecutarBateriaV1()
    TV2_PrepararNavegacaoHumana
    RunBateriaOficial
End Sub

Public Sub CT2_ExecutarLimparTestes()
    CT_LimparTestesAntigos
End Sub


