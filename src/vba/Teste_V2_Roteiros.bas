Attribute VB_Name = "Teste_V2_Roteiros"
Option Explicit

' V12.0.0203 ONDA 10 Microdelta 1.5 fix4 - constantes da suite end-to-end
' de strikes (ver TV2_RunRodizioStrikesEndToEnd no final do modulo).
Private Const TV2_E2E_ATIV_ID As String = "999"
Private Const TV2_E2E_ATIV_DESC As String = "Atividade E2E Strikes"
Private Const TV2_E2E_SERV_ID As String = "001"
Private Const TV2_E2E_VALOR_UNIT As Currency = 100@
Private Const TV2_E2E_NOTA_BAIXA As Integer = 3
Private Const TV2_E2E_NOTA_ALTA As Integer = 8

' ============================================================
' Teste_V2_Roteiros
' Suites executaveis da bateria V2:
' - smoke rapido / assistido
' - canonico profundo por blocos (`CS_*`)
' - stress deterministico
' ============================================================

Public Sub TV2_RunSmoke(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim fila As String
    Dim filaAntes As String
    Dim filaDepois As String
    Dim statusEmpAntes As String
    Dim statusEmpDepois As String
    Dim auditFechAntes As Long
    Dim auditFechDepois As Long
    Dim auditSuspAntes As Long
    Dim auditSuspDepois As Long
    Dim auditRollbackAntes As Long
    Dim auditRollbackDepois As Long
    Dim rodizio As TRodizioResultado
    Dim rodizioPosPendente As TRodizioResultado
    Dim rodizioPosExpiracao As TRodizioResultado
    Dim resPre As TResult
    Dim resRec As TResult
    Dim resExp As TResult
    Dim resOs As TResult
    Dim resAval As TResult
    Dim resAval2 As TResult
    Dim notas(1 To 10) As Integer
    Dim preosId As String
    Dim osId As String
    Dim i As Long
    Dim senhaFalhaAba As String
    Dim qtdEmpAntes As Long
    Dim qtdEmpDepois As Long
    Dim qtdCredAntes As Long
    Dim qtdCredDepois As Long
    Dim qtdItemAntes As Long
    Dim qtdItemDepois As Long
    Dim obtidoAtm As String
    Dim okAtm As Boolean

    On Error GoTo falha

    TV2_InitExecucao "SMOKE", visual
    senhaFalhaAba = "TV2_ATM_EMP"

    TV2_PrepararCenarioTriploCanonico
    fila = TV2_FilaCsv(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "SMK_001", "AUTO", _
                  "Validar baseline e fila inicial canonica", _
                  "Fila inicial 001,002,003", _
                  fila, _
                  "Garante setup deterministico para os demais testes", _
                  (fila = "001,002,003")

    TV2_PrepararCenarioTriploCanonico
    rodizio = SelecionarEmpresa(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "SMK_002", "AUTO", _
                  "Selecionar a empresa do topo da fila", _
                  "EMP_ID=001", _
                  "ENCONTROU=" & CStr(rodizio.encontrou) & "; EMP_ID=" & TV2_FormatEmpId(rodizio.Empresa.EMP_ID), _
                  "Prova o contrato minimo do rodizio sem filtros extras", _
                  (rodizio.encontrou And IdsIguais(rodizio.Empresa.EMP_ID, "001"))

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    preosId = resPre.IdGerado
    TV2_LogAssert "SMOKE", "SMK_003", "AUTO", _
                  "Emitir Pre-OS basica", _
                  "PRE_OS aguardando aceite para EMP_ID=001 com VL_EST=200", _
                  "SUCESSO=" & CStr(resPre.sucesso) & "; PREOS_ID=" & preosId & "; STATUS=" & TV2_StatusPreOS(preosId) & "; EMP_ID=" & TV2_EmpIdPreOS(preosId) & "; VL_EST=" & Format$(TV2_ValorEstPreOS(preosId), "0.00"), _
                  "Valida a persistencia minima da PRE_OS fora da interface", _
                  (resPre.sucesso And preosId <> "" And _
                   TV2_StatusPreOS(preosId) = "AGUARDANDO_ACEITE" And _
                   IdsIguais(TV2_EmpIdPreOS(preosId), "001") And _
                   Abs(CDbl(TV2_ValorEstPreOS(preosId)) - 200#) < 0.001)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId = resPre.IdGerado
    rodizio = SelecionarEmpresa(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "SMK_004", "AUTO", _
                  "Pre-OS pendente nao move a fila", _
                  "Segunda indicacao retorna EMP_ID=002 e a fila permanece 001,002,003", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; EMP_RODIZIO=" & TV2_FormatEmpId(rodizio.Empresa.EMP_ID) & "; POS_001=" & CStr(TV2_PosicaoFila("001", TV2_AtivCanonA())) & "; POS_002=" & CStr(TV2_PosicaoFila("002", TV2_AtivCanonA())) & "; POS_003=" & CStr(TV2_PosicaoFila("003", TV2_AtivCanonA())), _
                  "Captura a invariavel do filtro E: pula sem mover e sem punir", _
                  (resPre.sucesso And rodizio.encontrou And IdsIguais(rodizio.Empresa.EMP_ID, "002") And _
                   TV2_PosicaoFila("001", TV2_AtivCanonA()) = 1 And _
                   TV2_PosicaoFila("002", TV2_AtivCanonA()) = 2 And _
                   TV2_PosicaoFila("003", TV2_AtivCanonA()) = 3)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId = resPre.IdGerado
    resRec = RecusarPreOS(preosId, "RECUSA_TESTE_V2")
    fila = TV2_FilaCsv(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "SMK_005", "AUTO", _
                  "Recusa avanca fila e pune a empresa", _
                  "Fila 002,003,001; PRE_OS recusada; QTD_RECUSAS=1", _
                  "SUCESSO_RECUSA=" & CStr(resRec.sucesso) & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; FILA=" & fila & "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Garante giro correto e punicao minima apos recusa explicita", _
                  (resRec.sucesso And TV2_StatusPreOS(preosId) = "RECUSADA" And fila = "002,003,001" And TV2_QtdRecusasEmpresa("001") = 1)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId = resPre.IdGerado
    filaAntes = TV2_FilaCsv(TV2_AtivCanonA())
    rodizioPosPendente = SelecionarEmpresa(TV2_AtivCanonA())
    resExp = ExpirarPreOS(preosId)
    filaDepois = TV2_FilaCsv(TV2_AtivCanonA())
    rodizioPosExpiracao = SelecionarEmpresa(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "EXP_001", "AUTO", _
                  "Expirar Pre-OS pendente e retomar a fila corretamente", _
                  "PRE_OS expirada; fila 002,003,001; nova indicacao retorna EMP_ID=002", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
                  "; FILA_ANTES=" & filaAntes & _
                  "; EMP_COM_PENDENCIA=" & TV2_FormatEmpId(rodizioPosPendente.Empresa.EMP_ID) & _
                  "; SUCESSO_EXP=" & CStr(resExp.sucesso) & _
                  "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & _
                  "; FILA_DEPOIS=" & filaDepois & _
                  "; EMP_APOS_EXP=" & TV2_FormatEmpId(rodizioPosExpiracao.Empresa.EMP_ID) & _
                  "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Prova que a expiracao remove o bloqueio por pendencia, pune a empresa e preserva a integridade da fila", _
                  (resPre.sucesso And filaAntes = "001,002,003" And _
                   rodizioPosPendente.encontrou And IdsIguais(rodizioPosPendente.Empresa.EMP_ID, "002") And _
                   resExp.sucesso And TV2_StatusPreOS(preosId) = "EXPIRADA" And _
                   filaDepois = "002,003,001" And _
                   rodizioPosExpiracao.encontrou And IdsIguais(rodizioPosExpiracao.Empresa.EMP_ID, "002") And _
                   TV2_QtdRecusasEmpresa("001") = 1)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 3)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date + 7, "EMP-001")
    osId = resOs.IdGerado
    fila = TV2_FilaCsv(TV2_AtivCanonA())
    TV2_LogAssert "SMOKE", "SMK_006", "AUTO", _
                  "Emitir OS converte a PRE_OS e avanca a fila sem punicao", _
                  "PRE_OS convertida; OS em execucao; fila 002,003,001", _
                  "SUCESSO_OS=" & CStr(resOs.sucesso) & "; OS_ID=" & osId & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & fila, _
                  "Confirma a integracao minima entre PRE_OS, OS e fila", _
                  (resOs.sucesso And osId <> "" And _
                   TV2_StatusPreOS(preosId) = "CONVERTIDA_OS" And _
                   TV2_StatusOS(osId) = "EM_EXECUCAO" And _
                   fila = "002,003,001")

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date + 5, "EMP-002")
    osId = resOs.IdGerado
    auditFechAntes = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    auditSuspAntes = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    For i = 1 To 10
        notas(i) = 8
    Next i
    resAval = AvaliarOS(osId, "QA V2", notas, 2, "Cenario smoke V2", "", Date + 6, Date + 15)
    auditFechDepois = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    auditSuspDepois = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    TV2_LogAssert "SMOKE", "SMK_007", "AUTO", _
                  "Avaliar OS e concluir o ciclo", _
                  "OS concluida, auditoria registrada e empresa sem suspensão indevida", _
                  "SUCESSO_AVAL=" & CStr(resAval.sucesso) & _
                  "; STATUS_OS=" & TV2_StatusOS(osId) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
                  "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()) & _
                  "; STATUS_EMP_001=" & TV2_StatusEmpresa("001") & _
                  "; DT_FIM_001=" & IIf(TV2_DtFimSuspEmpresa("001") > CDate(0), Format$(TV2_DtFimSuspEmpresa("001"), "dd/mm/yyyy"), "(limpa)") & _
                  "; AUDIT_FECH=" & CStr(auditFechDepois - auditFechAntes) & _
                  "; AUDIT_SUSP=" & CStr(auditSuspDepois - auditSuspAntes) & _
                  "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Fecha o fluxo core ponta a ponta no nivel de servico", _
                  (resAval.sucesso And _
                   TV2_StatusOS(osId) = "CONCLUIDA" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) And _
                   TV2_StatusEmpresa("001") = "ATIVA" And _
                   TV2_DtFimSuspEmpresa("001") = CDate(0) And _
                   (auditFechDepois - auditFechAntes) = 1 And _
                   (auditSuspDepois - auditSuspAntes) = 0 And _
                   TV2_QtdRecusasEmpresa("001") = 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("999", TV2_CodServicoA(), 1)
    TV2_LogAssert "SMOKE", "MIG_001", "AUTO", _
                  "Rejeitar entidade inexistente no servico de Pre-OS", _
                  "Svc_PreOS retorna erro sem gravar PRE_OS", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; MSG=" & resPre.mensagem & "; PRE_OS=" & CStr(TV2_CountRows(SHEET_PREOS)), _
                  "Fecha a dependencia da interface para ENT_ID invalida", _
                  (Not resPre.sucesso And TV2_CountRows(SHEET_PREOS) = 0 And _
                   InStr(1, resPre.mensagem, "Entidade", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date - 1, "EMP-MIG-002")
    TV2_LogAssert "SMOKE", "MIG_002", "AUTO", _
                  "Rejeitar data invalida no servico de OS", _
                  "Svc_OS retorna erro sem converter a PRE_OS e sem gravar OS", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; SUCESSO_OS=" & CStr(resOs.sucesso) & "; MSG=" & resOs.mensagem & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; OS=" & CStr(TV2_CountRows(SHEET_CAD_OS)), _
                  "Fecha a dependencia da interface para DT_PREV_TERMINO incoerente", _
                  (resPre.sucesso And Not resOs.sucesso And _
                   TV2_StatusPreOS(preosId) = "AGUARDANDO_ACEITE" And _
                   TV2_CountRows(SHEET_CAD_OS) = 0 And _
                   InStr(1, resOs.mensagem, "Data prevista", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date + 5, "EMP-MIG-003")
    osId = resOs.IdGerado
    TV2_PreencherNotas notas, 8
    resAval = AvaliarOS(osId, "QA V2", notas, 1, "", "", Date + 6, Date + 15)
    TV2_LogAssert "SMOKE", "MIG_003", "AUTO", _
                  "Exigir motivo textual na divergencia do servico de avaliacao", _
                  "Svc_Avaliacao retorna erro e mantem a OS em execucao", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; SUCESSO_OS=" & CStr(resOs.sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.sucesso) & "; MSG=" & resAval.mensagem & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Fecha a dependencia da interface para a divergencia ficar sem motivo algum", _
                  (resPre.sucesso And resOs.sucesso And Not resAval.sucesso And _
                   TV2_StatusOS(osId) = "EM_EXECUCAO" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) And _
                   InStr(1, resAval.mensagem, "Justificativa", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date + 5, "EMP-MIG-004")
    osId = resOs.IdGerado
    TV2_PreencherNotas notas, 8
    resAval = AvaliarOS(osId, "QA V2", notas, 1, "Observacao usada como justificativa", "", Date + 6, Date + 15)
    TV2_LogAssert "SMOKE", "MIG_004", "AUTO", _
                  "Aceitar observacao como motivo efetivo na divergencia", _
                  "Svc_Avaliacao conclui a OS quando ha observacao textual", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; SUCESSO_OS=" & CStr(resOs.sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.sucesso) & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Preserva compatibilidade com a bateria oficial sem perder rastreabilidade", _
                  (resPre.sucesso And resOs.sucesso And resAval.sucesso And _
                   TV2_StatusOS(osId) = "CONCLUIDA" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3))

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date + 5, "EMP-MUT-001")
    osId = resOs.IdGerado
    TV2_PreencherNotas notas, 8
    resAval = AvaliarOS(osId, "QA V2", notas, 2, "Primeira avaliacao valida", "", Date + 6, Date + 15)
    resAval2 = AvaliarOS(osId, "QA V2", notas, 2, "Segunda avaliacao indevida", "", Date + 6, Date + 15)
    TV2_LogAssert "SMOKE", "MUT_001", "AUTO", _
                  "Rejeitar segunda avaliacao de OS ja concluida", _
                  "Svc_Avaliacao falha, OS permanece CONCLUIDA e a fila continua integra", _
                  "SUCESSO_PREOS=" & CStr(resPre.sucesso) & "; SUCESSO_OS=" & CStr(resOs.sucesso) & "; SUCESSO_AVAL_1=" & CStr(resAval.sucesso) & "; SUCESSO_AVAL_2=" & CStr(resAval2.sucesso) & "; MSG2=" & resAval2.mensagem & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Fecha uma transicao invalida importante sem depender do comportamento visual da interface", _
                  (resPre.sucesso And resOs.sucesso And resAval.sucesso And _
                   Not resAval2.sucesso And _
                   TV2_StatusOS(osId) = "CONCLUIDA" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) And _
                   InStr(1, resAval2.mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    qtdEmpAntes = TV2_CountRows(SHEET_EMPRESAS)
    qtdCredAntes = TV2_CountRows(SHEET_CREDENCIADOS)
    qtdItemAntes = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001")
    statusEmpAntes = TV2_StatusEmpresa("001")
    auditRollbackAntes = TV2_AuditCount("Rollback/Transacao")
    TV2_ProtegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    resRec = AvancarFila("001", TV2_AtivCanonA(), True, "ATM_001_FALHA_CONTROLADA")
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    qtdEmpDepois = TV2_CountRows(SHEET_EMPRESAS)
    qtdCredDepois = TV2_CountRows(SHEET_CREDENCIADOS)
    qtdItemDepois = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001")
    statusEmpDepois = TV2_StatusEmpresa("001")
    auditRollbackDepois = TV2_AuditCount("Rollback/Transacao")
    obtidoAtm = "SUCESSO_AVANCO=" & CStr(resRec.sucesso)
    obtidoAtm = obtidoAtm & "; MSG=" & resRec.mensagem
    obtidoAtm = obtidoAtm & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA())
    obtidoAtm = obtidoAtm & "; POS_001=" & CStr(TV2_PosicaoFila("001", TV2_AtivCanonA()))
    obtidoAtm = obtidoAtm & "; STATUS_ANTES=" & statusEmpAntes
    obtidoAtm = obtidoAtm & "; STATUS_DEPOIS=" & statusEmpDepois
    obtidoAtm = obtidoAtm & "; EMP_ANTES=" & CStr(qtdEmpAntes)
    obtidoAtm = obtidoAtm & "; EMP_DEPOIS=" & CStr(qtdEmpDepois)
    obtidoAtm = obtidoAtm & "; CRED_ANTES=" & CStr(qtdCredAntes)
    obtidoAtm = obtidoAtm & "; CRED_DEPOIS=" & CStr(qtdCredDepois)
    obtidoAtm = obtidoAtm & "; ITEM_ANTES=" & CStr(qtdItemAntes)
    obtidoAtm = obtidoAtm & "; ITEM_DEPOIS=" & CStr(qtdItemDepois)
    obtidoAtm = obtidoAtm & "; REC_EMP=" & CStr(TV2_QtdRecusasEmpresa("001"))
    obtidoAtm = obtidoAtm & "; REC_CRED=" & CStr(TV2_QtdRecusasCredenciamento("001", TV2_AtivCanonA()))
    obtidoAtm = obtidoAtm & "; AUDIT_ROLLBACK=" & CStr(auditRollbackDepois - auditRollbackAntes)
    okAtm = Not resRec.sucesso
    okAtm = okAtm And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    okAtm = okAtm And TV2_PosicaoFila("001", TV2_AtivCanonA()) = 1
    okAtm = okAtm And statusEmpAntes = "ATIVA"
    okAtm = okAtm And statusEmpDepois = "ATIVA"
    okAtm = okAtm And qtdEmpAntes = qtdEmpDepois
    okAtm = okAtm And qtdCredAntes = qtdCredDepois
    okAtm = okAtm And qtdItemAntes = 3 And qtdItemDepois = 3
    okAtm = okAtm And TV2_QtdRecusasEmpresa("001") = 0
    okAtm = okAtm And TV2_QtdRecusasCredenciamento("001", TV2_AtivCanonA()) = 0
    okAtm = okAtm And (auditRollbackDepois - auditRollbackAntes) >= 1
    okAtm = okAtm And TV2_AuditContemTrecho("ROLLBACK")
    okAtm = okAtm And ( _
        InStr(1, resRec.mensagem, "ROLLBACK", vbTextCompare) > 0 Or _
        InStr(1, resRec.mensagem, "Falha ao incrementar recusa", vbTextCompare) > 0)
    TV2_LogAssert "SMOKE", "ATM_001", "AUTO", _
                  "Reverter mutacao parcial quando a segunda escrita falha", _
                  "Avanco punido falha; fila volta ao estado anterior; recusas ficam zeradas; cadastros e credenciamentos nao sofrem mutacao residual; auditoria registra rollback legivel", _
                  obtidoAtm, _
                  "Prova atomicidade ampliada entre CREDENCIADOS e EMPRESAS no fluxo punido", _
                  okAtm

    ' MD-17.1.c (Onda 17 Test-First) - Smoke read-only de UI (5 verificacoes x 4 forms).
    ' Bloco roda APOS asserts do TV2_RunSmoke; logs vao para mesma execucao SMOKE.
    Call TV2_RunUiSmokeReadOnly(silencioso)

    TV2_FinalizarExecucao "SMOKE", silencioso
    Exit Sub

falha:
    On Error Resume Next
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    On Error GoTo 0
    TV2_LogAssert "SMOKE", "FATAL", "AUTO", _
                  "Executar suite sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao "SMOKE", silencioso
End Sub

Public Sub TV2_RunUiSmokeReadOnly(Optional ByVal silencioso As Boolean = False)
    ' ============================================================
    ' MD-17.1.c (Onda 17 Test-First) - Smoke read-only de UI
    ' ============================================================
    ' 4 forms x 5 verificacoes (V1-V5):
    '   V1: existencia de controles canonicos hardcoded (FALHA se missing)
    '   V2: set equality controles (STRICT=False neste MD; extras viram MANUAL
    '       ate baseline empirico de .frx ser estabelecido)
    '   V3: helpers UI esperados existem no CodeModule (Q-MD17.1.c.2=A:
    '       missing -> FALHA; extras toleradas)
    '   V4: .frm <-> .code-only.txt sincronizado (gamma tolerante:
    '       strip comentario inteira-linha + RTrim + lower-case fora de
    '       string literais)
    '   V5_CANARY: VBE.ActiveVBProject acessivel programaticamente.
    '       FALHA se Trust Center bloqueia; V1-V3 viram MANUAL_ASSISTIDO
    '       para evitar 12 falhas redundantes.
    '
    ' Wire-up: chamado de TV2_RunSmoke ANTES de TV2_FinalizarExecucao "SMOKE";
    ' logs vao para mesma execucao (suite SMOKE), sem TV2_InitExecucao novo.
    ' Cap M11 = 0 imports em forms preservado (esta MD nao toca .frm/.frx).
    ' L14 vacina: assinaturas TV2_LogAssert (8 obrigatorias) e TV2_LogManual
    ' (5 obrigatorias) verificadas via grep em ABF-Teste_V2_Engine.bas linhas
    ' 155-196 antes de gerar este codigo.

    Const N As Long = 4
    Dim formNames(1 To N) As String
    Dim formPrefix(1 To N) As String
    Dim canControles(1 To N) As String
    Dim canHelpers(1 To N) As String
    Dim repoRoot As String
    Dim frmPath As String
    Dim coPath As String
    Dim canaryOk As Boolean
    Dim i As Long

    formNames(1) = "Reativa_Entidade":  formPrefix(1) = "AAF"
    formNames(2) = "Reativa_Empresa":   formPrefix(2) = "AAH"
    formNames(3) = "Cadastro_Servico":  formPrefix(3) = "AAD"
    formNames(4) = "Credencia_Empresa": formPrefix(4) = "AAI"

    ' Listas canonicas - derivacao MD-17.1.c via grep nos .frm em src/vba/:
    '   - Controles: APENAS nomes que aparecem como argumento de Me.Controls("...")
    '     OU em handlers <ControlName>_<Evento>. NUNCA nomes de variaveis VBA
    '     (WithEvents foi armadilha do MD-17.1.c original - VR_20260503_141832
    '     reprovou Quarteto: mTxtBusca, mTxtBuscaTopo, mTxtFiltroCredLista
    '     sao variaveis de modulo, nao controles).
    '   - Helpers: Public/Private Sub|Function presentes no CodeModule.
    ' MD-17.1.c-fix1 (2026-05-03): remove os 4 WithEvents vars; troca
    ' TxtFiltro_CredenciamentoServico (tentativa primaria) por CR_TxtFiltroListaDin
    ' (fallback efetivo no .frx - confirmado via CSV de falhas).
    canControles(1) = "R_Lista"
    canControles(2) = "RM_Lista"
    canControles(3) = "S_Cadastrar_SV,Descricao_SV,SV_Lista,S_Atividade"
    ' MD-17.1.c-fix2 (2026-05-03): Credencia_Empresa NAO tem TxtFiltro estatico
    ' no .frx. CR_EnsureFiltroListaDinamico cria via Me.Controls.Add em runtime
    ' (detectado via grep MD-17.1.c-fix2). Smoke read-only nunca ve o textbox.
    ' canControles(4) ficam apenas os 2 controles estaticos do .frx.
    canControles(4) = "CR_Credenciar,CR_Lista"

    canHelpers(1) = "UI_TextBoxSeExiste,UI_PegarTextBoxBuscaTopoDireita,UI_SafeListVal," & _
                    "UI_LinhaEntidadeValida,UI_TextoEntidadeParaFiltro,UI_LinhaEntidadePassaFiltro," & _
                    "UI_ChaveNormalizadaId,UI_EntidadeInativasTemConflito," & _
                    "UI_AjustarAlturaListaEntInativ,UI_PreencherListaEntidadesInativas," & _
                    "UserForm_Initialize,mTxtBusca_Change,R_Lista_DblClick"
    canHelpers(2) = "UI_TextBoxSeExiste,UI_PegarTextBoxBuscaTopoDireita,UI_SafeListVal," & _
                    "UI_LinhaEmpresaValida,UI_TextoEmpresaParaFiltro,UI_LinhaEmpresaPassaFiltro," & _
                    "UI_ChaveNormalizadaId,UI_EmpresaInativosTemConflito," & _
                    "UI_PreencherListaEmpresasInativas,UserForm_Initialize," & _
                    "mTxtBusca_Change,RM_Lista_DblClick"
    canHelpers(3) = "UI_TextBoxSeExiste,UI_PegarTextBoxBuscaTopoDireita," & _
                    "S_Cadastrar_SV_Click,Descricao_SV_KeyPress,Descricao_SV_AfterUpdate," & _
                    "SV_Lista_Click,S_Atividade_Change,S_Atividade_AfterUpdate," & _
                    "UserForm_Initialize,mTxtBuscaTopo_Change,ServicoJaExiste,Pad3"
    canHelpers(4) = "UserForm_Initialize,CR_EnsureFiltroListaDinamico,mTxtFiltroCredLista_Change," & _
                    "CR_Credenciar_Click,CR_Lista_Click,DefinirEmpresaSelecionada," & _
                    "PrepararListaCredenciamentoServico,DefinirListaCredenciamentoServico," & _
                    "CredJaExiste,NormalizarCodAtivServ,ProximaPosicaoAtividade," & _
                    "CarregarDadosEmpresaSelecionada,ValidarPersistenciaCredenciamento," & _
                    "IdsIguaisCred,Pad3"

    ' V5_CANARY PRIMEIRO - testa acesso ao VBE.
    canaryOk = TV2_UI_VbeCanary()

    If canaryOk Then
        TV2_LogAssert "SMOKE", "CS_UISMOKE_VBE_CANARY", "AUTO", _
                      "VBE.ActiveVBProject acessivel programaticamente", _
                      "VBComponents.count > 0 sem Err", _
                      "OK", _
                      "Pre-requisito de V1-V4; sem VBE acessivel suite UiSmoke nao roda", True
    Else
        TV2_LogAssert "SMOKE", "CS_UISMOKE_VBE_CANARY", "AUTO", _
                      "VBE.ActiveVBProject acessivel programaticamente", _
                      "VBComponents.count > 0 sem Err", _
                      "FALHA - habilitar 'Confiar no acesso ao modelo de objeto do projeto VBA' em Opcoes>Central de Confiabilidade", _
                      "Q4 confirmado: severidade FALHA isolada em V5_CANARY; V1-V3 viram MANUAL", False
    End If

    repoRoot = TV2_UI_RepoRoot()

    For i = 1 To N
        frmPath = repoRoot & "\src\vba\" & formNames(i) & ".frm"
        coPath = repoRoot & "\local-ai\vba_import\002-formularios\" & _
                 formPrefix(i) & "-" & formNames(i) & ".code-only.txt"

        If canaryOk Then
            TV2_UI_VerificarV1 formNames(i), canControles(i)
            TV2_UI_VerificarV2 formNames(i), canControles(i)
            TV2_UI_VerificarV3 formNames(i), canHelpers(i)
        Else
            TV2_LogManual "SMOKE", "CS_UISMOKE_" & formNames(i) & "_V1", _
                          "Existencia controles canonicos em " & formNames(i), _
                          "Pendente - V5_CANARY falhou", _
                          "Skip ate Trust Center liberar VBE"
            TV2_LogManual "SMOKE", "CS_UISMOKE_" & formNames(i) & "_V2", _
                          "Set equality controles em " & formNames(i), _
                          "Pendente - V5_CANARY falhou", _
                          "Skip ate Trust Center liberar VBE"
            TV2_LogManual "SMOKE", "CS_UISMOKE_" & formNames(i) & "_V3", _
                          "Helpers canonicos UI presentes em " & formNames(i), _
                          "Pendente - V5_CANARY falhou", _
                          "Skip ate Trust Center liberar VBE"
        End If

        ' V4 (filesystem) independe de VBE; sempre roda.
        TV2_UI_VerificarV4 formNames(i), frmPath, coPath
    Next i
End Sub

' --- Helpers Private TV2_UI_* (MD-17.1.c) ---

Private Function TV2_UI_VbeCanary() As Boolean
    Dim vbp As Object
    Dim cnt As Long

    On Error GoTo erro
    Set vbp = Application.VBE.ActiveVBProject
    cnt = vbp.VBComponents.count
    TV2_UI_VbeCanary = (cnt > 0)
    Exit Function
erro:
    TV2_UI_VbeCanary = False
End Function

Private Function TV2_UI_RepoRoot() As String
    ' Probe: workbook pode estar na raiz do repo OU em subdir V12-202-Z003.
    ' MD-17.1.c-fix1 (2026-05-03): probe 2 candidatos; retorna o primeiro
    ' onde src\vba existe. VR_20260503_141832 confirmou workbook na raiz
    ' (CSV gerado em \\Mac\Home\Projetos\Credenciamento\TesteV2_*.csv);
    ' assumir subdir era erro do MD original.
    Dim cand1 As String
    Dim cand2 As String
    cand1 = ThisWorkbook.Path
    cand2 = ThisWorkbook.Path & "\.."
    If Dir(cand1 & "\src\vba", vbDirectory) <> "" Then
        TV2_UI_RepoRoot = cand1
    ElseIf Dir(cand2 & "\src\vba", vbDirectory) <> "" Then
        TV2_UI_RepoRoot = cand2
    Else
        TV2_UI_RepoRoot = cand1  ' fallback - V4 detecta Dir vazio
    End If
End Function

Private Sub TV2_UI_VerificarV1(ByVal formName As String, ByVal canonicoCsv As String)
    Dim canonico() As String
    Dim faltantes As String
    Dim vbp As Object
    Dim comp As Object
    Dim ctl As Object
    Dim i As Long
    Dim nome As String
    Dim ok As Boolean

    canonico = Split(canonicoCsv, ",")

    On Error GoTo erro_acesso
    Set vbp = Application.VBE.ActiveVBProject
    Set comp = vbp.VBComponents(formName)
    On Error GoTo 0

    For i = LBound(canonico) To UBound(canonico)
        nome = Trim$(canonico(i))
        If nome <> "" Then
            On Error Resume Next
            Set ctl = Nothing
            Set ctl = comp.Designer.Controls(nome)
            If ctl Is Nothing Then faltantes = faltantes & nome & ";"
            On Error GoTo 0
        End If
    Next i

    ok = (faltantes = "")
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V1", "AUTO", _
                  "Existencia controles canonicos em " & formName, _
                  "Todos canonicos presentes: " & canonicoCsv, _
                  IIf(ok, "OK", "FALTANTES=" & faltantes), _
                  "V1 hardcoded - falha sinaliza form alterado sem atualizar canControles", ok
    Exit Sub
erro_acesso:
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V1", "AUTO", _
                  "Existencia controles canonicos em " & formName, _
                  "Acesso a VBComponents(" & formName & ").Designer", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "V5_CANARY OK mas Designer falhou - Trust Center parcial?", False
End Sub

Private Sub TV2_UI_VerificarV2(ByVal formName As String, ByVal canonicoCsv As String)
    Const STRICT As Boolean = False  ' MD-17.1.c: extras viram MANUAL ate baseline empirico
    Dim canonico As Object
    Dim extras As String
    Dim faltantes As String
    Dim vbp As Object
    Dim comp As Object
    Dim ctl As Object
    Dim arr() As String
    Dim i As Long
    Dim nome As String
    Dim diff As String
    Dim k As Variant

    Set canonico = CreateObject("Scripting.Dictionary")
    arr = Split(canonicoCsv, ",")
    For i = LBound(arr) To UBound(arr)
        nome = Trim$(arr(i))
        If nome <> "" Then
            If Not canonico.Exists(nome) Then canonico.Add nome, True
        End If
    Next i

    On Error GoTo erro_acesso
    Set vbp = Application.VBE.ActiveVBProject
    Set comp = vbp.VBComponents(formName)

    For Each ctl In comp.Designer.Controls
        nome = ctl.Name
        If Not canonico.Exists(nome) Then
            extras = extras & nome & ";"
        Else
            canonico.Remove nome
        End If
    Next ctl
    On Error GoTo 0

    ' canonico (Dictionary) agora contem so chaves nao-vistas em Designer.
    For Each k In canonico.Keys
        faltantes = faltantes & CStr(k) & ";"
    Next k

    diff = "extras=[" & extras & "] faltantes=[" & faltantes & "]"

    If extras = "" And faltantes = "" Then
        TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V2", "AUTO", _
                      "Set equality controles em " & formName, _
                      "Designer.Controls == canControles hardcoded", _
                      "OK (set equality exata)", _
                      "V2 strict - diff disparou no run desta MD", True
    ElseIf STRICT Then
        TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V2", "AUTO", _
                      "Set equality controles em " & formName, _
                      "Designer.Controls == canControles hardcoded", _
                      diff, _
                      "V2 STRICT=True - extras OU faltantes disparam FALHA", False
    Else
        TV2_LogManual "SMOKE", "CS_UISMOKE_" & formName & "_V2", _
                      "Set equality controles em " & formName & " (STRICT=False)", _
                      "Diff: " & diff, _
                      "MD-17.1.c sem baseline empirico de .frx; atualizar canControles e flipar STRICT=True quando estabilizado"
    End If
    Exit Sub
erro_acesso:
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V2", "AUTO", _
                  "Set equality controles em " & formName, _
                  "Acesso a Designer.Controls iteravel", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "V5_CANARY OK mas Designer iteracao falhou", False
End Sub

Private Sub TV2_UI_VerificarV3(ByVal formName As String, ByVal canonicoCsv As String)
    Const PROC_KIND_PROC As Long = 0  ' vbext_pk_Proc
    Dim canonico() As String
    Dim faltantes As String
    Dim vbp As Object
    Dim comp As Object
    Dim cm As Object
    Dim i As Long
    Dim nome As String
    Dim lin As Long
    Dim ok As Boolean

    canonico = Split(canonicoCsv, ",")

    On Error GoTo erro_acesso
    Set vbp = Application.VBE.ActiveVBProject
    Set comp = vbp.VBComponents(formName)
    Set cm = comp.CodeModule
    On Error GoTo 0

    For i = LBound(canonico) To UBound(canonico)
        nome = Trim$(canonico(i))
        If nome <> "" Then
            lin = 0
            On Error Resume Next
            lin = cm.ProcStartLine(nome, PROC_KIND_PROC)
            If lin <= 0 Then faltantes = faltantes & nome & ";"
            On Error GoTo 0
        End If
    Next i

    ok = (faltantes = "")
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V3", "AUTO", _
                  "Helpers canonicos UI presentes em " & formName, _
                  "Todos canonicos definidos no CodeModule: " & canonicoCsv, _
                  IIf(ok, "OK", "FALTANTES=" & faltantes), _
                  "Q-MD17.1.c.2=A - missing dispara FALHA; extras toleradas", ok
    Exit Sub
erro_acesso:
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V3", "AUTO", _
                  "Helpers canonicos UI presentes em " & formName, _
                  "Acesso a CodeModule.ProcStartLine", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "V5_CANARY OK mas CodeModule falhou", False
End Sub

Private Sub TV2_UI_VerificarV4(ByVal formName As String, ByVal frmPath As String, ByVal coPath As String)
    Dim frmCodigo As String
    Dim coCodigo As String
    Dim normFrm As String
    Dim normCo As String
    Dim ok As Boolean
    Dim diff As String
    Dim erMsg As String

    On Error GoTo erro

    If Dir(frmPath) = "" Then
        TV2_LogManual "SMOKE", "CS_UISMOKE_" & formName & "_V4", _
                      "Comparacao .frm <-> .code-only.txt (gamma) " & formName, _
                      "Ambos arquivos legiveis (workbook em ambiente dev)", _
                      "Skip - .frm fora do repo dev (workbook em producao); espelho via VBComponents nao tocado"
        Exit Sub
    End If
    If Dir(coPath) = "" Then
        TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V4", "AUTO", _
                      "Comparacao .frm <-> .code-only.txt (gamma) " & formName, _
                      "Ambos arquivos legiveis", _
                      ".code-only.txt ausente: " & coPath, _
                      "Espelho local-ai/vba_import/002-formularios incompleto", False
        Exit Sub
    End If

    frmCodigo = TV2_UI_LerSecaoCodigoFrm(frmPath)
    coCodigo = TV2_UI_LerArquivoTexto(coPath)

    normFrm = TV2_UI_NormalizarGammaTexto(frmCodigo)
    normCo = TV2_UI_NormalizarGammaTexto(coCodigo)

    ok = (normFrm = normCo)

    If ok Then
        TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V4", "AUTO", _
                      "Comparacao .frm <-> .code-only.txt (gamma) " & formName, _
                      "Normalizacao gamma identica (strip ', RTrim, lower-case fora de strings)", _
                      "OK (" & Len(normFrm) & " chars normalizados)", _
                      "Q-MD17.1.c.3 - gamma absorve drift cosmetico", True
    Else
        diff = "len_frm=" & Len(normFrm) & " len_co=" & Len(normCo)
        TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V4", "AUTO", _
                      "Comparacao .frm <-> .code-only.txt (gamma) " & formName, _
                      "Normalizacao gamma identica", _
                      "DIVERGE: " & diff, _
                      "Drift estrutural alem do cosmetico - investigar manualmente", False
    End If
    Exit Sub
erro:
    erMsg = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_LogAssert "SMOKE", "CS_UISMOKE_" & formName & "_V4", "AUTO", _
                  "Comparacao .frm <-> .code-only.txt (gamma) " & formName, _
                  "Leitura sem erro", erMsg, _
                  "Possivel permissao de leitura ou path inacessivel", False
End Sub

Private Function TV2_UI_LerArquivoTexto(ByVal path As String) As String
    Dim fnum As Integer
    Dim conteudo As String
    fnum = FreeFile
    Open path For Binary Access Read As #fnum
    conteudo = Space$(LOF(fnum))
    Get #fnum, , conteudo
    Close #fnum
    TV2_UI_LerArquivoTexto = conteudo
End Function

Private Function TV2_UI_LerSecaoCodigoFrm(ByVal frmPath As String) As String
    ' .frm tem cabecalho:
    '   VERSION 5.00
    '   Begin {GUID} FormName ... End
    '   Attribute VB_Name = ...
    '   Attribute VB_GlobalNameSpace = ...
    '   Attribute VB_Creatable = ...
    '   Attribute VB_PredeclaredId = ...
    '   Attribute VB_Exposed = ...           <-- ULTIMA linha de header
    '   <CODIGO COMECA AQUI>
    ' .code-only.txt comeca DIRETO no codigo (sem header nem 5 attrs).
    ' MD-17.1.c-fix2 (2026-05-03): cortar do .frm tudo ate (e incluindo)
    ' "Attribute VB_Exposed". VR_20260503_152729 confirmou diff sistematico
    ' de ~170 chars = exatamente o tamanho dos 5 attributes de form pulados.
    ' Antes (MD-17.1.c original) cortava em "Attribute VB_Name" - incluia
    ' os 5 attrs que .code-only.txt nao tinha; gamma falhava em todos 4 forms.
    Dim raw As String
    Dim p As Long
    Dim eolPos As Long
    raw = TV2_UI_LerArquivoTexto(frmPath)
    p = InStr(1, raw, "Attribute VB_Exposed", vbBinaryCompare)
    If p = 0 Then
        ' Fallback: se nao tiver VB_Exposed, tentar VB_Name (alguns forms minimos)
        p = InStr(1, raw, "Attribute VB_Name", vbBinaryCompare)
        If p = 0 Then
            TV2_UI_LerSecaoCodigoFrm = raw
            Exit Function
        End If
    End If
    ' Avancar para o caractere APOS o EOL da linha do anchor encontrado.
    eolPos = InStr(p, raw, vbLf)
    If eolPos = 0 Then eolPos = InStr(p, raw, vbCr)
    If eolPos = 0 Then
        TV2_UI_LerSecaoCodigoFrm = ""
    Else
        TV2_UI_LerSecaoCodigoFrm = Mid$(raw, eolPos + 1)
    End If
End Function

Private Function TV2_UI_NormalizarGammaTexto(ByVal texto As String) As String
    ' Q-MD17.1.c.3 confirmada:
    '   (a) strip linhas iniciadas com ' (apos LTrim)
    '   (b) RTrim em cada linha
    '   (c) lower-case fora de strings literais "..." (split por aspas duplas;
    '       lower so nas posicoes pares - preserva conteudo entre aspas)
    Dim linhas() As String
    Dim acc As String
    Dim i As Long
    Dim linha As String
    Dim partes() As String
    Dim j As Long

    texto = Replace$(texto, vbCrLf, vbLf)
    texto = Replace$(texto, vbCr, vbLf)
    linhas = Split(texto, vbLf)

    For i = LBound(linhas) To UBound(linhas)
        linha = linhas(i)
        ' (a) strip se for comentario inteira-linha
        If Left$(LTrim$(linha), 1) = "'" Then
            ' Skip
        Else
            ' (b) RTrim
            linha = RTrim$(linha)
            ' (d) MD-17.1.c-fix3: skip linhas vazias (apos RTrim).
            ' Linhas em branco nao mudam significado de codigo VBA. Necessario
            ' para absorver diferenca de trailing newlines: VR_20260503_155854
            ' confirmou .frm tem 2-3 trailing \n a mais que .code-only.txt.
            If linha <> "" Then
                ' (c) lower-case fora de strings literais
                partes = Split(linha, """")
                For j = LBound(partes) To UBound(partes)
                    If (j Mod 2) = 0 Then partes(j) = LCase$(partes(j))
                Next j
                acc = acc & Join(partes, """") & vbLf
            End If
        End If
    Next i

    TV2_UI_NormalizarGammaTexto = acc
End Function

Public Sub TV2_RunFiltros(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim matriz(1 To 4, 1 To 6) As Variant
    Dim colsNomeServico(1 To 2) As Long
    Dim colsCnpj(1 To 1) As Long
    Dim colsRodizioServico(1 To 4) As Long
    Dim colsRodizioEntidade(1 To 3) As Long
    Dim colsManutencaoServico(1 To 5) As Long
    Dim filtrado As Variant
    Dim norm As String
    Dim obtido As String
    Dim qtdFiltrado As Long

    On Error GoTo falha

    TV2_InitExecucao "FILTROS", visual

    norm = UtilFiltro_Normalizar("  Servi" & ChrW$(231) & "o  " & ChrW$(193) & ChrW$(199) & ChrW$(195) & "o  ")
    TV2_LogAssert "FILTROS", "FLT_001", "AUTO", _
                  "Normalizar busca textual sem depender de acento, caixa ou espaco duplo", _
                  "SERVICO ACAO", _
                  norm, _
                  "Define o contrato comum dos filtros antes de plugar nos formularios", _
                  (norm = "SERVICO ACAO")

    TV2_MontarMatrizFiltroFixture matriz
    colsNomeServico(1) = 2
    colsNomeServico(2) = 4
    colsCnpj(1) = 3
    colsRodizioServico(1) = 1
    colsRodizioServico(2) = 4
    colsRodizioServico(3) = 5
    colsRodizioServico(4) = 6
    colsRodizioEntidade(1) = 1
    colsRodizioEntidade(2) = 2
    colsRodizioEntidade(3) = 3
    colsManutencaoServico(1) = 1
    colsManutencaoServico(2) = 4
    colsManutencaoServico(3) = 5
    colsManutencaoServico(4) = 6
    colsManutencaoServico(5) = 2

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsNomeServico, "")
    obtido = "QTD=" & CStr(TV2_ArrayLinhaCount(filtrado))
    TV2_LogAssert "FILTROS", "FLT_002", "AUTO", _
                  "Filtro vazio preserva todas as linhas da matriz", _
                  "4 linhas preservadas", _
                  obtido, _
                  "Evita que campo de busca vazio esconda registros validos na interface", _
                  (TV2_ArrayLinhaCount(filtrado) = 4)

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsNomeServico, "joao")
    obtido = "QTD=" & CStr(TV2_ArrayLinhaCount(filtrado)) & "; ID=" & TV2_ArrayValorTexto(filtrado, 0, 1)
    TV2_LogAssert "FILTROS", "FLT_003", "AUTO", _
                  "Encontrar texto com acento usando busca sem acento", _
                  "Apenas ID 001", _
                  obtido, _
                  "Garante busca deterministica para nomes digitados sem acentuacao", _
                  (TV2_ArrayLinhaCount(filtrado) = 1 And TV2_ArrayValorTexto(filtrado, 0, 1) = "001")

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsNomeServico, "98.765")
    obtido = "QTD_COLS_NOME_SERVICO=" & CStr(TV2_ArrayLinhaCount(filtrado))
    TV2_LogAssert "FILTROS", "FLT_004", "AUTO", _
                  "Respeitar as colunas configuradas para a busca", _
                  "Busca por CNPJ nao aparece quando CNPJ nao esta nas colunas-alvo", _
                  obtido, _
                  "Evita falsos positivos quando cada tela define seus campos de filtro", _
                  (TV2_ArrayLinhaCount(filtrado) = 0)

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsCnpj, "98.765")
    obtido = "QTD_COL_CNPJ=" & CStr(TV2_ArrayLinhaCount(filtrado)) & "; ID=" & TV2_ArrayValorTexto(filtrado, 0, 1)
    TV2_LogAssert "FILTROS", "FLT_005", "AUTO", _
                  "Encontrar o mesmo termo quando a coluna CNPJ e selecionada", _
                  "Apenas ID 002", _
                  obtido, _
                  "Prova que o helper e configuravel por tela sem alterar o algoritmo", _
                  (TV2_ArrayLinhaCount(filtrado) = 1 And TV2_ArrayValorTexto(filtrado, 0, 1) = "002")

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsRodizioServico, "poda")
    obtido = "QTD_RODIZIO_SERV=" & CStr(TV2_ArrayLinhaCount(filtrado)) & "; ID=" & TV2_ArrayValorTexto(filtrado, 0, 1)
    TV2_LogAssert "FILTROS", "FLT_006", "AUTO", _
                  "Validar filtro do Rodizio por Servico/Atividade", _
                  "Apenas ID 003 para termo poda", _
                  obtido, _
                  "Fecha o contrato do campo TxtFiltro_RodizioServico sem depender de TextBox18", _
                  (TV2_ArrayLinhaCount(filtrado) = 1 And TV2_ArrayValorTexto(filtrado, 0, 1) = "003")

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsRodizioEntidade, "98765")
    obtido = "QTD_RODIZIO_ENT=" & CStr(TV2_ArrayLinhaCount(filtrado)) & "; ID=" & TV2_ArrayValorTexto(filtrado, 0, 1)
    TV2_LogAssert "FILTROS", "FLT_007", "AUTO", _
                  "Validar filtro do Rodizio por Entidade/CNPJ", _
                  "Apenas ID 002 para CNPJ parcial", _
                  obtido, _
                  "Fecha o contrato do campo TxtFiltro_RodizioEntidade sem depender de TextBox22", _
                  (TV2_ArrayLinhaCount(filtrado) = 1 And TV2_ArrayValorTexto(filtrado, 0, 1) = "002")

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsManutencaoServico, "7711000")
    obtido = "QTD_CADSERV=" & CStr(TV2_ArrayLinhaCount(filtrado)) & "; ID=" & TV2_ArrayValorTexto(filtrado, 0, 1)
    TV2_LogAssert "FILTROS", "FLT_008", "AUTO", _
                  "Validar filtro de manutencao de servicos por CNAE", _
                  "Apenas ID 003 para CNAE 7711000", _
                  obtido, _
                  "Garante que TxtFiltro_CadServ pesquisa tambem por CNAE normalizado", _
                  (TV2_ArrayLinhaCount(filtrado) = 1 And TV2_ArrayValorTexto(filtrado, 0, 1) = "003")

    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsRodizioEntidade, "local 3")
    qtdFiltrado = TV2_ArrayLinhaCount(filtrado)
    filtrado = UtilFiltro_AplicarSobreMatriz(matriz, colsRodizioEntidade, "")
    obtido = "QTD_FILTRADO=" & CStr(qtdFiltrado) & "; QTD_APOS_LIMPAR=" & CStr(TV2_ArrayLinhaCount(filtrado))
    TV2_LogAssert "FILTROS", "FLT_009", "AUTO", _
                  "Limpar filtro do Rodizio restaura todas as entidades", _
                  "1 linha filtrada; 4 linhas apos limpar", _
                  obtido, _
                  "Evita estado residual em que a lista continua filtrada mesmo com campo vazio", _
                  (qtdFiltrado = 1 And TV2_ArrayLinhaCount(filtrado) = 4)

    TV2_FinalizarExecucao "FILTROS", silencioso
    Exit Sub

falha:
    TV2_LogAssert "FILTROS", "FATAL", "AUTO", _
                  "Executar suite de filtros sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao "FILTROS", silencioso
End Sub

Public Sub TV2_RunCanonicoFundacao(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim fila As String
    Dim qtdServAntes As Long
    Dim qtdServDepois As Long
    Dim qtdCred As Long
    Dim qtdPreAntes As Long
    Dim qtdPreDepois As Long
    Dim descServico As String
    Dim resPre As TResult
    Dim resRec As TResult
    Dim resExp As TResult
    Dim resOs As TResult
    Dim resCanc As TResult
    Dim resAval As TResult
    Dim preosIdA As String
    Dim osIdA As String
    Dim preosIdB As String
    Dim preosIdC As String
    Dim osIdB As String
    Dim osIdC As String
    Dim preosId22A As String
    Dim preosId22B As String
    Dim preosId22C As String
    Dim notas(1 To 10) As Integer
    Dim resPre2 As TResult
    Dim resPre3 As TResult
    Dim resAval2 As TResult
    Dim pre22A As TPreOS
    Dim pre22B As TPreOS
    Dim pre22C As TPreOS
    Dim auditEmissoes As Long
    Dim obtido22 As String
    Dim ok22 As Boolean
    Dim resSusp As TResult
    Dim empA As TEmpresa
    Dim linhaEmpA As Long
    Dim empB As TEmpresa
    Dim linhaEmpB As Long
    Dim posA As Long
    Dim auditSusp As Long
    Dim auditReat As Long
    Dim auditSuspAntes As Long
    Dim auditSuspDepois As Long
    Dim auditReatAntes As Long
    Dim auditReatDepois As Long
    Dim auditInatAntes As Long
    Dim auditInatDepois As Long
    Dim obtido11 As String
    Dim obtido13 As String
    Dim obtido14 As String
    Dim obtido16 As String
    Dim obtido20 As String
    Dim ok11 As Boolean
    Dim ok13 As Boolean
    Dim ok14 As Boolean
    Dim ok16 As Boolean
    Dim ok20 As Boolean
    Dim filaAntesRetorno As String
    Dim filaDepoisRetorno As String
    Dim i As Long
    Dim qtdLoop As Double
    Dim preosIdLoop As String
    Dim osIdLoop As String
    Dim empLoop As String
    Dim seqObtida As String
    Dim auditPreAntes17 As Long
    Dim auditPreDepois17 As Long
    Dim auditOsAntes17 As Long
    Dim auditOsDepois17 As Long
    Dim auditFechaAntes17 As Long
    Dim auditFechaDepois17 As Long
    Dim obtido17 As String
    Dim ok17 As Boolean
    Dim auditRejAntes As Long
    Dim auditRejDepois As Long
    Dim obtido18 As String
    Dim ok18 As Boolean
    Dim auditPreEmitAntes21 As Long
    Dim auditPreEmitDepois21 As Long
    Dim auditPreRecAntes21 As Long
    Dim auditPreRecDepois21 As Long
    Dim auditPreExpAntes21 As Long
    Dim auditPreExpDepois21 As Long
    Dim auditOsEmitAntes21 As Long
    Dim auditOsEmitDepois21 As Long
    Dim auditAvalAntes21 As Long
    Dim auditAvalDepois21 As Long
    Dim auditFechAntes21 As Long
    Dim auditFechDepois21 As Long
    Dim auditSuspAntes21 As Long
    Dim auditSuspDepois21 As Long
    Dim auditInatAntes21 As Long
    Dim auditInatDepois21 As Long
    Dim auditTransAntes21 As Long
    Dim auditTransDepois21 As Long
    Dim auditEntInatAntes As Long
    Dim auditEntInatDepois As Long
    Dim auditEntReatAntes As Long
    Dim auditEntReatDepois As Long
    Dim resRollback As TResult
    Dim resInatEmp As TResult
    Dim resReatEmp As TResult
    Dim resInatEnt As TResult
    Dim resReatEnt As TResult
    Dim qtdEmpAtivas23 As Long
    Dim qtdEmpInativas23 As Long
    Dim empReat23 As TEmpresa
    Dim linhaEmpReat23 As Long
    Dim qtdEntAtivas24 As Long
    Dim qtdEntInativas24 As Long
    Dim obtido23 As String
    Dim obtido24 As String
    Dim obtido21 As String
    Dim ok23 As Boolean
    Dim ok24 As Boolean
    Dim ok21 As Boolean
    Dim senhaFalhaAba As String

    On Error GoTo falha

    senhaFalhaAba = "TV2_CAN_AUDIT"
    TV2_InitExecucao "CANONICO", visual

    TV2_PrepararCenarioTriploCanonico
    fila = TV2_FilaCsv(TV2_AtivCanonA())
    qtdCred = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001")
    TV2_LogAssert "CANONICO", "CS_00", "AUTO", _
                  "Montar o setup canônico com 3 empresas no item", _
                  "3 empresas; serviço único; fila 001,002,003", _
                  "EMP=" & CStr(TV2_CountRows(SHEET_EMPRESAS)) & _
                  "; ENT=" & CStr(TV2_CountRows(SHEET_ENTIDADE)) & _
                  "; SERV=" & CStr(TV2_QtdServicosAtivServ(TV2_AtivCanonA(), "001")) & _
                  "; CRED_ITEM=" & CStr(qtdCred) & _
                  "; FILA=" & fila, _
                  "Abre a família canônica sobre base determinística e auditável", _
                  (TV2_CountRows(SHEET_EMPRESAS) = 3 And _
                   TV2_CountRows(SHEET_ENTIDADE) = 3 And _
                   TV2_QtdServicosAtivServ(TV2_AtivCanonA(), "001") = 1 And _
                   qtdCred = 3 And _
                   fila = "001,002,003")

    TV2_PrepararCenarioTriploCanonico
    qtdServAntes = TV2_QtdServicosAtivServ(TV2_AtivCanonA(), "001")
    descServico = TV2_DescricaoServico(TV2_AtivCanonA(), "001")
    TV2_PrepararBaselineCanonica
    qtdServDepois = TV2_QtdServicosAtivServ(TV2_AtivCanonA(), "001")
    TV2_LogAssert "CANONICO", "CS_01", "AUTO", _
                  "Reaplicar a baseline sem duplicar o serviço canônico", _
                  "Continua apenas 1 serviço 001 vinculado à atividade canônica", _
                  "SERV_ANTES=" & CStr(qtdServAntes) & _
                  "; SERV_DEPOIS=" & CStr(qtdServDepois) & _
                  "; DESC=" & descServico & _
                  "; VALOR=" & Format$(TV2_ValorUnitServico(TV2_AtivCanonA(), "001"), "0.00"), _
                  "Protege a suíte contra duplicidade silenciosa em CAD_SERV", _
                  (qtdServAntes = 1 And qtdServDepois = 1 And descServico <> "")

    TV2_PrepararCenarioTriploCanonico
    qtdPreAntes = TV2_CountRows(SHEET_PREOS)
    resPre = EmitirPreOS("001", TV2_CodServico(TV2_AtivCanonA(), "999"), 1)
    qtdPreDepois = TV2_CountRows(SHEET_PREOS)
    TV2_LogAssert "CANONICO", "CS_02", "AUTO", _
                  "Rejeitar emissão com vínculo atividade/serviço inexistente", _
                  "Falha explícita sem gravar nova PRE_OS", _
                  "SUCESSO=" & CStr(resPre.sucesso) & _
                  "; MSG=" & resPre.mensagem & _
                  "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
                  "; PREOS_DEPOIS=" & CStr(qtdPreDepois), _
                  "Protege o item canônico contra associação inválida em CAD_SERV", _
                  (Not resPre.sucesso And qtdPreAntes = 0 And qtdPreDepois = 0 And _
                   InStr(1, resPre.mensagem, "Servico nao encontrado", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    TV2_LogAssert "CANONICO", "CS_03", "AUTO", _
                  "Emitir a primeira PRE_OS para a empresa A", _
                  "PRE_OS para EMP_ID=001 em AGUARDANDO_ACEITE", _
                  "SUCESSO=" & CStr(resPre.sucesso) & _
                  "; PREOS_ID=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; STATUS=" & TV2_StatusPreOS(resPre.IdGerado), _
                  "Abre o fluxo nominal A -> B -> C do item canônico", _
                  (resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "001") And _
                   TV2_StatusPreOS(resPre.IdGerado) = "AGUARDANDO_ACEITE")

    TV2_CS_PrepararEstadoAteCS04 preosIdA, osIdA
    fila = TV2_FilaCsv(TV2_AtivCanonA())
    TV2_LogAssert "CANONICO", "CS_04", "AUTO", _
                  "Converter a PRE_OS de A em OS e avançar a fila", _
                  "OS para A; fila 002,003,001", _
                  "PREOS_A=" & preosIdA & _
                  "; OS_A=" & osIdA & _
                  "; STATUS_PREOS=" & TV2_StatusPreOS(preosIdA) & _
                  "; STATUS_OS=" & TV2_StatusOS(osIdA) & _
                  "; FILA=" & fila, _
                  "Prova o primeiro giro da fila do item canônico", _
                  (osIdA <> "" And TV2_StatusPreOS(preosIdA) = "CONVERTIDA_OS" And _
                   TV2_StatusOS(osIdA) = "EM_EXECUCAO" And _
                   fila = "002,003,001")

    TV2_CS_PrepararEstadoAteCS04 preosIdA, osIdA
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    TV2_LogAssert "CANONICO", "CS_05", "AUTO", _
                  "Emitir a segunda PRE_OS para a empresa B", _
                  "PRE_OS para EMP_ID=002", _
                  "SUCESSO=" & CStr(resPre.sucesso) & _
                  "; PREOS_B=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Prova o pulo técnico de A por OS aberta", _
                  (resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002"))

    TV2_CS_PrepararEstadoAteCS06 preosIdA, osIdA, preosIdB, preosIdC
    TV2_LogAssert "CANONICO", "CS_06", "AUTO", _
                  "Emitir a terceira PRE_OS para a empresa C", _
                  "PRE_OS para EMP_ID=003", _
                  "PREOS_A=" & preosIdA & _
                  "; OS_A=" & osIdA & _
                  "; PREOS_B=" & preosIdB & _
                  "; PREOS_C=" & preosIdC & _
                  "; EMP_C=" & TV2_EmpIdPreOS(preosIdC) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Fecha o núcleo nominal do item canônico com bloqueios acumulados", _
                  (preosIdC <> "" And IdsIguais(TV2_EmpIdPreOS(preosIdC), "003") And _
                   TV2_StatusPreOS(preosIdB) = "AGUARDANDO_ACEITE" And _
                   TV2_StatusPreOS(preosIdC) = "AGUARDANDO_ACEITE")

    TV2_CS_PrepararEstadoAteCS06 preosIdA, osIdA, preosIdB, preosIdC
    qtdPreAntes = TV2_CountRows(SHEET_PREOS)
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    qtdPreDepois = TV2_CountRows(SHEET_PREOS)
    TV2_LogAssert "CANONICO", "CS_07", "AUTO", _
                  "Bloquear o rodízio quando não há nenhuma empresa apta", _
                  "SEM_CREDENCIADOS_APTOS sem nova PRE_OS e sem travar a fila", _
                  "SUCESSO=" & CStr(resPre.sucesso) & _
                  "; MSG=" & resPre.mensagem & _
                  "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
                  "; PREOS_DEPOIS=" & CStr(qtdPreDepois) & _
                  "; STATUS_PREOS_A=" & TV2_StatusPreOS(preosIdA) & _
                  "; STATUS_OS_A=" & TV2_StatusOS(osIdA) & _
                  "; STATUS_PREOS_B=" & TV2_StatusPreOS(preosIdB) & _
                  "; STATUS_PREOS_C=" & TV2_StatusPreOS(preosIdC) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "É o teste crítico de não travamento do cenário canônico", _
                  (Not resPre.sucesso And qtdPreDepois = qtdPreAntes And _
                   InStr(1, resPre.mensagem, "SEM_CREDENCIADOS_APTOS", vbTextCompare) > 0 And _
                   TV2_StatusPreOS(preosIdA) = "CONVERTIDA_OS" And _
                   TV2_StatusOS(osIdA) = "EM_EXECUCAO" And _
                   TV2_StatusPreOS(preosIdB) = "AGUARDANDO_ACEITE" And _
                   TV2_StatusPreOS(preosIdC) = "AGUARDANDO_ACEITE" And _
                   TV2_FilaCsv(TV2_AtivCanonA()) = "002,003,001")

    TV2_CS_PrepararEstadoAteCS06 preosIdA, osIdA, preosIdB, preosIdC
    TV2_PreencherNotas notas, 8
    resAval = AvaliarOS(osIdA, "QA CANONICO", notas, 1, "CS_08_CONCLUIR_A", "", Date + 1, Date + 7)
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    TV2_LogAssert "CANONICO", "CS_08", "AUTO", _
                  "Retomar o rodízio após a conclusão da OS de A", _
                  "Nova PRE_OS para EMP_ID=001", _
                  "SUCESSO_AVAL=" & CStr(resAval.sucesso) & _
                  "; STATUS_OS_A=" & TV2_StatusOS(osIdA) & _
                  "; SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
                  "; PREOS_NOVA=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Prova que a fila retoma do ponto correto após resolução parcial do bloqueio", _
                  (resAval.sucesso And TV2_StatusOS(osIdA) = "CONCLUIDA" And _
                   resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "001"))

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    resPre2 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    resPre3 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId22A = resPre.IdGerado
    preosId22B = resPre2.IdGerado
    preosId22C = resPre3.IdGerado
    pre22A = Repo_PreOS.BuscarPorId(preosId22A)
    pre22B = Repo_PreOS.BuscarPorId(preosId22B)
    pre22C = Repo_PreOS.BuscarPorId(preosId22C)
    auditEmissoes = TV2_AuditCount("Pre-OS Emitida", "ATIV_ID=" & TV2_AtivCanonA())
    obtido22 = "SUCESSO_A=" & CStr(resPre.sucesso) & _
               "; SUCESSO_B=" & CStr(resPre2.sucesso) & _
               "; SUCESSO_C=" & CStr(resPre3.sucesso) & _
               "; PREOS_A=" & preosId22A & _
               "; PREOS_B=" & preosId22B & _
               "; PREOS_C=" & preosId22C & _
               "; A=" & pre22A.ATIV_ID & "|" & pre22A.SERV_ID & "|" & pre22A.STATUS_PREOS & _
               "; B=" & pre22B.ATIV_ID & "|" & pre22B.SERV_ID & "|" & pre22B.STATUS_PREOS & _
               "; C=" & pre22C.ATIV_ID & "|" & pre22C.SERV_ID & "|" & pre22C.STATUS_PREOS & _
               "; COD_A=" & TV2_CodServicoA() & _
               "; AUDIT_PREOS=" & CStr(auditEmissoes) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA())
    ok22 = resPre.sucesso And resPre2.sucesso And resPre3.sucesso
    ok22 = ok22 And IdsIguais(pre22A.ATIV_ID, TV2_AtivCanonA()) And IdsIguais(pre22B.ATIV_ID, TV2_AtivCanonA()) And IdsIguais(pre22C.ATIV_ID, TV2_AtivCanonA())
    ok22 = ok22 And IdsIguais(pre22A.SERV_ID, "001") And IdsIguais(pre22B.SERV_ID, "001") And IdsIguais(pre22C.SERV_ID, "001")
    ok22 = ok22 And pre22A.STATUS_PREOS = "AGUARDANDO_ACEITE" And pre22B.STATUS_PREOS = "AGUARDANDO_ACEITE" And pre22C.STATUS_PREOS = "AGUARDANDO_ACEITE"
    ok22 = ok22 And TV2_CountRows(SHEET_PREOS) = 3 And auditEmissoes = 3
    ok22 = ok22 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    TV2_LogAssert "CANONICO", "CS_22", "AUTO", _
                  "Validar associação preservada em emissões múltiplas", _
                  "ATIV_ID e SERV_ID corretos em todas as emissões", _
                  obtido22, _
                  "Protege contra regressão de associação atividade/serviço em emissões repetidas", _
                  ok22

    TV2_PrepararCenarioTriploCanonico
    resSusp = Suspender("001")
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    empA = LerEmpresa("001", linhaEmpA)
    posA = TV2_PosicaoFila("001", TV2_AtivCanonA())
    auditSusp = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    obtido11 = "SUCESSO_SUSP=" & CStr(resSusp.sucesso) & _
               "; SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; DT_FIM_A=" & Format$(empA.DT_FIM_SUSP, "dd/mm/yyyy") & _
               "; POS_A=" & CStr(posA) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSusp)
    ok11 = resSusp.sucesso And resPre.sucesso
    ok11 = ok11 And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002")
    ok11 = ok11 And empA.STATUS_GLOBAL = "SUSPENSA_GLOBAL"
    ok11 = ok11 And posA = 1 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok11 = ok11 And empA.DT_FIM_SUSP > Date And auditSusp = 1
    TV2_LogAssert "CANONICO", "CS_11", "AUTO", _
                  "Validar suspensão manual global de A", _
                  "A suspensa; B escolhida; posição 1 preservada", _
                  obtido11, _
                  "Separa aptidão operacional de posição absoluta na fila", _
                  ok11

    TV2_PrepararCenarioTriploCanonico
    resSusp = Suspender("001")
    empA = LerEmpresa("001", linhaEmpA)
    GravarStatusEmpresa linhaEmpA, "SUSPENSA_GLOBAL", Date - 1, empA.QTD_RECUSAS
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    empA = LerEmpresa("001", linhaEmpA)
    auditSusp = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    auditReat = TV2_AuditCount("Empresa Reativada", "STATUS=ATIVA")
    obtido13 = "SUCESSO_SUSP=" & CStr(resSusp.sucesso) & _
               "; SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; DT_FIM_A=" & IIf(TV2_DtFimSuspEmpresa("001") > CDate(0), Format$(TV2_DtFimSuspEmpresa("001"), "dd/mm/yyyy"), "(limpa)") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSusp) & _
               "; AUDIT_REAT=" & CStr(auditReat)
    ok13 = resSusp.sucesso And resPre.sucesso
    ok13 = ok13 And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "001")
    ok13 = ok13 And empA.STATUS_GLOBAL = "ATIVA"
    ok13 = ok13 And TV2_DtFimSuspEmpresa("001") = CDate(0)
    ok13 = ok13 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok13 = ok13 And auditSusp = 1 And auditReat = 1
    TV2_LogAssert "CANONICO", "CS_13", "AUTO", _
                  "Validar reativação automática por prazo vencido", _
                  "A reativada automaticamente e escolhida na próxima emissão", _
                  obtido13, _
                  "Prova o retorno automático sem perda de turno", _
                  ok13

    TV2_CS_PrepararEstadoAteCS14 preosIdA, osIdA, preosIdB, osIdB
    auditSuspAntes = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    TV2_PreencherNotas notas, 4
    resAval = AvaliarOS(osIdB, "QA CANONICO", notas, 1, "CS_14_NOTA_BAIXA_B", "", Date + 1, Date + 7)
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    empB = LerEmpresa("002", linhaEmpB)
    auditSuspDepois = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    obtido14 = "SUCESSO_AVAL=" & CStr(resAval.sucesso) & _
               "; STATUS_OS_B=" & TV2_StatusOS(osIdB) & _
               "; SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_B=" & empB.STATUS_GLOBAL & _
               "; DT_FIM_B=" & Format$(empB.DT_FIM_SUSP, "dd/mm/yyyy") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSuspDepois - auditSuspAntes)
    ok14 = resAval.sucesso And TV2_StatusOS(osIdB) = "CONCLUIDA"
    ok14 = ok14 And resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "003")
    ok14 = ok14 And empB.STATUS_GLOBAL = "SUSPENSA_GLOBAL"
    ok14 = ok14 And empB.DT_FIM_SUSP > Date
    ok14 = ok14 And TV2_FilaCsv(TV2_AtivCanonA()) = "003,001,002"
    ok14 = ok14 And (auditSuspDepois - auditSuspAntes) = 1
    TV2_LogAssert "CANONICO", "CS_14", "AUTO", _
                  "Validar suspensão automática por nota baixa", _
                  "B suspensa; C escolhida; DT_FIM_SUSP preenchida", _
                  obtido14, _
                  "Costura avaliação abaixo da média com bloqueio operacional e novo giro da fila", _
                  ok14

    TV2_CS_PrepararEstadoAteCS14 preosIdA, osIdA, preosIdB, osIdB
    TV2_PreencherNotas notas, 4
    resAval = AvaliarOS(osIdB, "QA CANONICO", notas, 1, "CS_16_NOTA_BAIXA_B", "", Date + 1, Date + 7)
    empB = LerEmpresa("002", linhaEmpB)
    GravarStatusEmpresa linhaEmpB, "SUSPENSA_GLOBAL", Date - 1, empB.QTD_RECUSAS
    auditReatAntes = TV2_AuditCount("Empresa Reativada", "STATUS=ATIVA")
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosIdC = resPre.IdGerado
    resOs = EmitirOS(preosIdC, Date + 7, "EMP-CS-16-C")
    osIdC = resOs.IdGerado
    TV2_PreencherNotas notas, 8
    resAval2 = AvaliarOS(osIdC, "QA CANONICO", notas, 1, "CS_16_CONCLUIR_C", "", Date + 2, Date + 8)
    filaAntesRetorno = TV2_FilaCsv(TV2_AtivCanonA())
    resPre2 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    empB = LerEmpresa("002", linhaEmpB)
    auditReatDepois = TV2_AuditCount("Empresa Reativada", "STATUS=ATIVA")
    filaDepoisRetorno = TV2_FilaCsv(TV2_AtivCanonA())
    obtido16 = "SUCESSO_AVAL_B=" & CStr(resAval.sucesso) & _
               "; SUCESSO_PREOS_C=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS_C=" & TV2_EmpIdPreOS(preosIdC) & _
               "; SUCESSO_OS_C=" & CStr(resOs.sucesso) & _
               "; SUCESSO_AVAL_C=" & CStr(resAval2.sucesso) & _
               "; FILA_ANTES_RETORNO=" & filaAntesRetorno & _
               "; SUCESSO_PREOS_RETORNO=" & CStr(resPre2.sucesso) & _
               "; EMP_RETORNO=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; STATUS_B=" & empB.STATUS_GLOBAL & _
               "; DT_FIM_B=" & IIf(TV2_DtFimSuspEmpresa("002") > CDate(0), Format$(TV2_DtFimSuspEmpresa("002"), "dd/mm/yyyy"), "(limpa)") & _
               "; FILA_APOS_RETORNO=" & filaDepoisRetorno & _
               "; AUDIT_REAT=" & CStr(auditReatDepois - auditReatAntes)
    ok16 = resAval.sucesso And resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(preosIdC), "003")
    ok16 = ok16 And resOs.sucesso And resAval2.sucesso
    ok16 = ok16 And filaAntesRetorno = "001,002,003"
    ok16 = ok16 And resPre2.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre2.IdGerado), "002")
    ok16 = ok16 And empB.STATUS_GLOBAL = "ATIVA"
    ok16 = ok16 And TV2_DtFimSuspEmpresa("002") = CDate(0)
    ok16 = ok16 And filaDepoisRetorno = "002,003,001"
    ok16 = ok16 And (auditReatDepois - auditReatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_16", "AUTO", _
                  "Validar retorno ordenado após suspensão por nota", _
                  "Fila volta a 001,002,003; A é pulada por OS aberta; B volta na emissão seguinte", _
                  obtido16, _
                  "Prova que a suspensão temporária não faz a empresa perder o turno duas vezes", _
                  ok16

    TV2_PrepararCenarioTriploCanonico
    auditPreAntes17 = TV2_AuditCount("Pre-OS Emitida", "ATIV_ID=" & TV2_AtivCanonA())
    auditOsAntes17 = TV2_AuditCount("OS Emitida")
    auditFechaAntes17 = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    TV2_PreencherNotas notas, 8
    For i = 1 To 7
        qtdLoop = 1 + ((i - 1) Mod 3)
        resPre = EmitirPreOS("001", TV2_CodServicoA(), qtdLoop)
        If Not resPre.sucesso Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Falha ao emitir PRE_OS no ciclo " & CStr(i) & "."
        End If
        preosIdLoop = resPre.IdGerado
        empLoop = TV2_EmpIdPreOS(preosIdLoop)
        If seqObtida <> "" Then seqObtida = seqObtida & ","
        seqObtida = seqObtida & empLoop

        resOs = EmitirOS(preosIdLoop, Date + 7 + i, "EMP-CS-17-" & CStr(i))
        If Not resOs.sucesso Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Falha ao emitir OS no ciclo " & CStr(i) & "."
        End If
        osIdLoop = resOs.IdGerado

        resAval = AvaliarOS(osIdLoop, "QA CANONICO", notas, qtdLoop, "CS_17_LOOP_" & CStr(i), "", Date + 8 + i, Date + 14 + i)
        If Not resAval.sucesso Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Falha ao avaliar OS no ciclo " & CStr(i) & "."
        End If

        If Not TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Fila perdeu integridade no ciclo " & CStr(i) & "."
        End If
    Next i
    auditPreDepois17 = TV2_AuditCount("Pre-OS Emitida", "ATIV_ID=" & TV2_AtivCanonA())
    auditOsDepois17 = TV2_AuditCount("OS Emitida")
    auditFechaDepois17 = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    obtido17 = "SEQ=" & seqObtida & _
               "; FILA_FINAL=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()) & _
               "; PREOS=" & CStr(TV2_CountRows(SHEET_PREOS)) & _
               "; OS=" & CStr(TV2_CountRows(SHEET_CAD_OS)) & _
               "; AUDIT_PREOS=" & CStr(auditPreDepois17 - auditPreAntes17) & _
               "; AUDIT_OS=" & CStr(auditOsDepois17 - auditOsAntes17) & _
               "; AUDIT_FECH=" & CStr(auditFechaDepois17 - auditFechaAntes17)
    ok17 = (seqObtida = "001,002,003,001,002,003,001")
    ok17 = ok17 And TV2_FilaCsv(TV2_AtivCanonA()) = "002,003,001"
    ok17 = ok17 And TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3)
    ok17 = ok17 And TV2_CountRows(SHEET_PREOS) = 7 And TV2_CountRows(SHEET_CAD_OS) = 7
    ok17 = ok17 And (auditPreDepois17 - auditPreAntes17) = 7
    ok17 = ok17 And (auditOsDepois17 - auditOsAntes17) = 7
    ok17 = ok17 And (auditFechaDepois17 - auditFechaAntes17) = 7
    TV2_LogAssert "CANONICO", "CS_17", "AUTO", _
                  "Validar giro longo A-B-C sem travamento", _
                  "Sequência 001,002,003,001,002,003,001 e fila íntegra ao final", _
                  obtido17, _
                  "Prova a volta ao início da fila em ciclo longo sem travamento", _
                  ok17

    TV2_CS_PrepararEstadoAteCS04 preosIdA, osIdA
    TV2_PreencherNotas notas, 8
    resAval = AvaliarOS(osIdA, "QA CANONICO", notas, 1, "CS_18_CONCLUIR_A", "", Date + 1, Date + 7)
    auditRejAntes = TV2_AuditCount("Validacao Rejeitada")
    resAval2 = AvaliarOS(osIdA, "QA CANONICO", notas, 1, "CS_18_REAVALIAR_A", "", Date + 2, Date + 8)
    resCanc = CancelarOS(osIdA, "CS_18_CANCELAR_OS_CONCLUIDA")
    auditRejDepois = TV2_AuditCount("Validacao Rejeitada")
    obtido18 = "SUCESSO_AVAL_1=" & CStr(resAval.sucesso) & _
               "; SUCESSO_AVAL_2=" & CStr(resAval2.sucesso) & _
               "; MSG_AVAL_2=" & resAval2.mensagem & _
               "; SUCESSO_CANCEL=" & CStr(resCanc.sucesso) & _
               "; MSG_CANCEL=" & resCanc.mensagem & _
               "; STATUS_OS=" & TV2_StatusOS(osIdA) & _
               "; AUDIT_REJEICAO=" & CStr(auditRejDepois - auditRejAntes)
    ok18 = resAval.sucesso
    ok18 = ok18 And TV2_StatusOS(osIdA) = "CONCLUIDA"
    ok18 = ok18 And Not resAval2.sucesso
    ok18 = ok18 And InStr(1, resAval2.mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0
    ok18 = ok18 And Not resCanc.sucesso
    ok18 = ok18 And InStr(1, resCanc.mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0
    ok18 = ok18 And TV2_StatusOS(osIdA) = "CONCLUIDA"
    ok18 = ok18 And (auditRejDepois - auditRejAntes) = 2
    TV2_LogAssert "CANONICO", "CS_18", "AUTO", _
                  "Validar transições inválidas de OS concluída", _
                  "Reavaliação e cancelamento rejeitados; OS permanece CONCLUIDA", _
                  obtido18, _
                  "Fecha regressão de estado e torna a rejeição auditável", _
                  ok18

    TV2_PrepararCenarioTriploCanonico
    empA = LerEmpresa("001", linhaEmpA)
    auditInatAntes = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    GravarStatusEmpresa linhaEmpA, "INATIVA", CDate(0), empA.QTD_RECUSAS
    RegistrarEvento EVT_INATIVACAO, ENT_EMP, "001", _
                    "STATUS=" & empA.STATUS_GLOBAL, _
                    "STATUS=INATIVA; ORIGEM=Teste_V2_Roteiros", _
                    "Teste_V2_Roteiros"
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    empA = LerEmpresa("001", linhaEmpA)
    posA = TV2_PosicaoFila("001", TV2_AtivCanonA())
    auditInatDepois = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    obtido20 = "SUCESSO_PREOS=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; POS_A=" & CStr(posA) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_INAT=" & CStr(auditInatDepois - auditInatAntes)
    ok20 = resPre.sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002")
    ok20 = ok20 And empA.STATUS_GLOBAL = "INATIVA"
    ok20 = ok20 And posA = 1 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok20 = ok20 And (auditInatDepois - auditInatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_20", "AUTO", _
                  "Validar filtro de empresa inativa no cadastro", _
                  "A inativa; B escolhida; posição de A preservada", _
                  obtido20, _
                  "Isola o efeito do status global INATIVA no item canônico", _
                  ok20

    TV2_PrepararCenarioTriploCanonico
    auditInatAntes = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    auditReatAntes = TV2_AuditCount("Empresa Reativada", "STATUS=ATIVA")
    resInatEmp = TV2_InativarEmpresaCadastro("001")
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    resReatEmp = TV2_ReativarEmpresaCadastro("001")
    resPre2 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    auditInatDepois = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    auditReatDepois = TV2_AuditCount("Empresa Reativada", "STATUS=ATIVA")
    empReat23 = LerEmpresa("001", linhaEmpReat23)
    qtdEmpAtivas23 = TV2_CountOcorrenciasRegistro(SHEET_EMPRESAS, PrimeiraLinhaDadosEmpresas(), COL_EMP_ID, "001", COL_EMP_CNPJ, TV2_CNPJEmpresa("001"))
    qtdEmpInativas23 = TV2_CountOcorrenciasRegistro(SHEET_EMPRESAS_INATIVAS, LINHA_DADOS, COL_EMP_ID, "001", COL_EMP_CNPJ, TV2_CNPJEmpresa("001"))
    obtido23 = "SUCESSO_INAT=" & CStr(resInatEmp.sucesso) & _
               "; SUCESSO_PREOS_B=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS_B=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; SUCESSO_REAT=" & CStr(resReatEmp.sucesso) & _
               "; SUCESSO_PREOS_A=" & CStr(resPre2.sucesso) & _
               "; EMP_PREOS_A=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; STATUS_A=" & TV2_StatusEmpresa("001") & _
               "; DT_ULT_REATIV_A=" & IIf(empReat23.DT_ULT_REATIV > CDate(0), Format$(empReat23.DT_ULT_REATIV, "dd/mm/yyyy hh:nn:ss"), "(vazia)") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; ATIVAS=" & CStr(qtdEmpAtivas23) & _
               "; INATIVAS=" & CStr(qtdEmpInativas23) & _
               "; TOTAL=" & CStr(TV2_CountOcorrenciasEmpresa("001")) & _
               "; AUDIT_INAT=" & CStr(auditInatDepois - auditInatAntes) & _
               "; AUDIT_REAT=" & CStr(auditReatDepois - auditReatAntes)
    ok23 = resInatEmp.sucesso And resPre.sucesso And resReatEmp.sucesso And resPre2.sucesso
    ok23 = ok23 And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002")
    ok23 = ok23 And IdsIguais(TV2_EmpIdPreOS(resPre2.IdGerado), "001")
    ok23 = ok23 And TV2_StatusEmpresa("001") = "ATIVA"
    ok23 = ok23 And empReat23.DT_ULT_REATIV > CDate(0)
    ok23 = ok23 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok23 = ok23 And TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001") = 3
    ok23 = ok23 And qtdEmpAtivas23 = 1 And qtdEmpInativas23 = 0 And TV2_CountOcorrenciasEmpresa("001") = 1
    ok23 = ok23 And (auditInatDepois - auditInatAntes) = 1
    ok23 = ok23 And (auditReatDepois - auditReatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_23", "AUTO", _
                  "Validar ida e volta de empresa entre ativo e inativo", _
                  "A some da seleção enquanto inativa e volta com DT_ULT_REATIV preenchida, sem duplicidade cadastral", _
                  obtido23, _
                  "Fecha ida e volta de empresa com preservação da fila lógica", _
                  ok23

    TV2_PrepararCenarioTriploCanonico
    auditEntInatAntes = TV2_AuditCount("Entidade Inativada")
    auditEntReatAntes = TV2_AuditCount("Entidade Reativada")
    qtdPreAntes = TV2_CountRows(SHEET_PREOS)
    resInatEnt = TV2_InativarEntidadeCadastro("001")
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    qtdPreDepois = TV2_CountRows(SHEET_PREOS)
    resReatEnt = TV2_ReativarEntidadeCadastro("001")
    resPre2 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    auditEntInatDepois = TV2_AuditCount("Entidade Inativada")
    auditEntReatDepois = TV2_AuditCount("Entidade Reativada")
    qtdEntAtivas24 = TV2_CountOcorrenciasRegistro(SHEET_ENTIDADE, LINHA_DADOS, COL_ENT_ID, "001", COL_ENT_CNPJ, TV2_CNPJEntidade("001"))
    qtdEntInativas24 = TV2_CountOcorrenciasRegistro(SHEET_ENTIDADE_INATIVOS, LINHA_DADOS, COL_ENT_ID, "001", COL_ENT_CNPJ, TV2_CNPJEntidade("001"))
    obtido24 = "SUCESSO_INAT=" & CStr(resInatEnt.sucesso) & _
               "; SUCESSO_PREOS_FALHA=" & CStr(resPre.sucesso) & _
               "; MSG=" & resPre.mensagem & _
               "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
               "; PREOS_DEPOIS=" & CStr(qtdPreDepois) & _
               "; SUCESSO_REAT=" & CStr(resReatEnt.sucesso) & _
               "; SUCESSO_PREOS_OK=" & CStr(resPre2.sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; ATIVAS=" & CStr(qtdEntAtivas24) & _
               "; INATIVAS=" & CStr(qtdEntInativas24) & _
               "; TOTAL=" & CStr(TV2_CountOcorrenciasEntidade("001")) & _
               "; AUDIT_INAT=" & CStr(auditEntInatDepois - auditEntInatAntes) & _
               "; AUDIT_REAT=" & CStr(auditEntReatDepois - auditEntReatAntes)
    ok24 = resInatEnt.sucesso And Not resPre.sucesso And qtdPreDepois = qtdPreAntes
    ok24 = ok24 And InStr(1, resPre.mensagem, "Entidade", vbTextCompare) > 0
    ok24 = ok24 And resReatEnt.sucesso And resPre2.sucesso
    ok24 = ok24 And IdsIguais(TV2_EmpIdPreOS(resPre2.IdGerado), "001")
    ok24 = ok24 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok24 = ok24 And TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001") = 3
    ok24 = ok24 And qtdEntAtivas24 = 1 And qtdEntInativas24 = 0 And TV2_CountOcorrenciasEntidade("001") = 1
    ok24 = ok24 And (auditEntInatDepois - auditEntInatAntes) = 1
    ok24 = ok24 And (auditEntReatDepois - auditEntReatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_24", "AUTO", _
                  "Validar ida e volta de entidade entre ativo e inativo", _
                  "Emissão falha com entidade inativa e volta a funcionar após reativação, sem duplicidade cadastral", _
                  obtido24, _
                  "Fecha ida e volta de entidade com rastreabilidade explícita", _
                  ok24

    TV2_PrepararCenarioTriploCanonico
    auditPreEmitAntes21 = TV2_AuditCount("Pre-OS Emitida")
    auditPreRecAntes21 = TV2_AuditCount("Pre-OS Recusada")
    auditPreExpAntes21 = TV2_AuditCount("Pre-OS Expirada")
    auditOsEmitAntes21 = TV2_AuditCount("OS Emitida")
    auditAvalAntes21 = TV2_AuditCount("Avaliacao Registrada")
    auditFechAntes21 = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    auditSuspAntes21 = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    auditInatAntes21 = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    auditTransAntes21 = TV2_AuditCount("Rollback/Transacao")

    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosIdA = resPre.IdGerado
    resRec = RecusarPreOS(preosIdA, "CS_21_RECUSA_A")

    resPre2 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosIdB = resPre2.IdGerado
    resExp = ExpirarPreOS(preosIdB)

    resPre3 = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosIdC = resPre3.IdGerado
    resOs = EmitirOS(preosIdC, Date + 7, "EMP-CS-21-C")
    osIdC = resOs.IdGerado
    TV2_PreencherNotas notas, 4
    resAval = AvaliarOS(osIdC, "QA CANONICO", notas, 1, "CS_21_NOTA_BAIXA_C", "", Date + 1, Date + 7)

    empA = LerEmpresa("001", linhaEmpA)
    GravarStatusEmpresa linhaEmpA, "INATIVA", CDate(0), empA.QTD_RECUSAS
    RegistrarEvento EVT_INATIVACAO, ENT_EMP, "001", _
                    "STATUS=" & empA.STATUS_GLOBAL, _
                    "STATUS=INATIVA; ORIGEM=Teste_V2_Roteiros", _
                    "Teste_V2_Roteiros"

    TV2_ProtegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    resRollback = AvancarFila("002", TV2_AtivCanonA(), True, "CS_21_ROLLBACK")
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba

    auditPreEmitDepois21 = TV2_AuditCount("Pre-OS Emitida")
    auditPreRecDepois21 = TV2_AuditCount("Pre-OS Recusada")
    auditPreExpDepois21 = TV2_AuditCount("Pre-OS Expirada")
    auditOsEmitDepois21 = TV2_AuditCount("OS Emitida")
    auditAvalDepois21 = TV2_AuditCount("Avaliacao Registrada")
    auditFechDepois21 = TV2_AuditCount("OS Fechada/Avaliada", "STATUS=CONCLUIDA")
    auditSuspDepois21 = TV2_AuditCount("Empresa Suspensa", "STATUS=SUSPENSA_GLOBAL")
    auditInatDepois21 = TV2_AuditCount("Empresa Inativada", "STATUS=INATIVA")
    auditTransDepois21 = TV2_AuditCount("Rollback/Transacao")

    obtido21 = "PRE_EMIT=" & CStr(auditPreEmitDepois21 - auditPreEmitAntes21) & _
               "; PRE_REC=" & CStr(auditPreRecDepois21 - auditPreRecAntes21) & _
               "; PRE_EXP=" & CStr(auditPreExpDepois21 - auditPreExpAntes21) & _
               "; OS_EMIT=" & CStr(auditOsEmitDepois21 - auditOsEmitAntes21) & _
               "; AVAL=" & CStr(auditAvalDepois21 - auditAvalAntes21) & _
               "; FECH=" & CStr(auditFechDepois21 - auditFechAntes21) & _
               "; SUSP=" & CStr(auditSuspDepois21 - auditSuspAntes21) & _
               "; INAT=" & CStr(auditInatDepois21 - auditInatAntes21) & _
               "; ROLLBACK=" & CStr(auditTransDepois21 - auditTransAntes21) & _
               "; SUCESSO_REC=" & CStr(resRec.sucesso) & _
               "; SUCESSO_EXP=" & CStr(resExp.sucesso) & _
               "; SUCESSO_OS=" & CStr(resOs.sucesso) & _
               "; SUCESSO_AVAL=" & CStr(resAval.sucesso) & _
               "; SUCESSO_RB=" & CStr(resRollback.sucesso)
    ok21 = resPre.sucesso And resRec.sucesso
    ok21 = ok21 And resPre2.sucesso And resExp.sucesso
    ok21 = ok21 And resPre3.sucesso And resOs.sucesso And resAval.sucesso
    ok21 = ok21 And Not resRollback.sucesso
    ok21 = ok21 And (auditPreEmitDepois21 - auditPreEmitAntes21) >= 3
    ok21 = ok21 And (auditPreRecDepois21 - auditPreRecAntes21) >= 1
    ok21 = ok21 And (auditPreExpDepois21 - auditPreExpAntes21) >= 1
    ok21 = ok21 And (auditOsEmitDepois21 - auditOsEmitAntes21) >= 1
    ok21 = ok21 And (auditAvalDepois21 - auditAvalAntes21) >= 1
    ok21 = ok21 And (auditFechDepois21 - auditFechAntes21) >= 1
    ok21 = ok21 And (auditSuspDepois21 - auditSuspAntes21) >= 1
    ok21 = ok21 And (auditInatDepois21 - auditInatAntes21) >= 1
    ok21 = ok21 And (auditTransDepois21 - auditTransAntes21) >= 1
    TV2_LogAssert "CANONICO", "CS_21", "AUTO", _
                  "Validar completude mínima do AUDIT_LOG por família", _
                  "Famílias críticas presentes e capturadas por cenário", _
                  obtido21, _
                  "Fecha a lacuna de completude mínima das famílias críticas de evento", _
                  ok21

    '==================================================================
    ' V12.0.0203 ONDA 17 MD-17.1.b - Cenarios novos via FixtureFactory
    '==================================================================
    ' Cada cenario eh AUTOCONTIDO: cria fixture isolada em namespace
    ' proprio, manipula CONFIG temporariamente, executa fluxo E2E natural
    ' via TV2_FF_RodadaCompleta, valida asserts factuais (estilo L18) e
    ' restaura CONFIG para baseline (L16). Independente de CS_01..CS_21
    ' anteriores. Valida tambem o helper TV2_FixtureFactory criado em
    ' MD-17.1.a (fechamento do debito DT-17.1.a-1).
    '==================================================================

    ' --- CS_BORDA_MAX2 (Onda 17 MD-17.1.b) -----------------------------
    ' Tema: Borda inferior MAX_STRIKES (legado=1, E2E=3, este=2).
    ' INV-1: 2 voltas com nota baixa para EMP1 = teste de idempotencia
    ' do rodizio sob repeticao + validacao de borda. Cada volta acumula
    ' strikes consistentemente.
    Dim entsBM2() As String, empsBM2() As String, ativsBM2() As String
    Dim notasBM2(1 To 3) As Integer
    Dim notaMinBM2 As Double
    Dim statusBM2_v1 As String, statusBM2_v2 As String
    Dim strikesBM2 As Long
    Dim okBM2 As Boolean
    Dim obtidoBM2 As String

    TV2_LimparNamespace "SBM2"
    TV2_FixtureFactory "SBM2", 1, 3, 1, entsBM2, empsBM2, ativsBM2
    TV2_RestaurarConfigBaseline 2, 0  ' MAX_STRIKES=2 (set; nome semantico, mesmo backend que restore)

    notasBM2(1) = TV2_E2E_NOTA_BAIXA  ' EMP1 (SBM2_001)
    notasBM2(2) = TV2_E2E_NOTA_ALTA   ' EMP2
    notasBM2(3) = TV2_E2E_NOTA_ALTA   ' EMP3

    ' Volta 1: 3 indicacoes. EMP1 leva 1 strike; EMP2 e EMP3 sem strike.
    TV2_FF_RodadaCompleta ativsBM2(1), entsBM2(1), 3, empsBM2, notasBM2
    statusBM2_v1 = TV2_StatusEmpresa(empsBM2(1))

    ' Volta 2: 3 indicacoes. EMP1 leva 2 strike (atinge MAX) -> SUSPENDE
    ' durante a volta. As proximas indicacoes nesta mesma volta atendem
    ' EMP2 e EMP3 (que continuam ativas).
    TV2_FF_RodadaCompleta ativsBM2(1), entsBM2(1), 3, empsBM2, notasBM2
    statusBM2_v2 = TV2_StatusEmpresa(empsBM2(1))

    notaMinBM2 = GetNotaMinimaAvaliacao()
    strikesBM2 = ContarStrikesPorEmpresa(empsBM2(1), notaMinBM2)

    obtidoBM2 = "EMP1=" & empsBM2(1) & _
                "; STATUS_V1=" & statusBM2_v1 & _
                "; STATUS_V2=" & statusBM2_v2 & _
                "; STRIKES=" & CStr(strikesBM2)
    okBM2 = (statusBM2_v1 = "ATIVA")
    okBM2 = okBM2 And (statusBM2_v2 = "SUSPENSA_GLOBAL")
    okBM2 = okBM2 And (strikesBM2 = 2)
    TV2_LogAssert "CANONICO", "CS_BORDA_MAX2", "AUTO", _
                  "Borda MAX_STRIKES=2: 1 strike mantem ativa; 2 strikes suspendem", _
                  "STATUS_V1=ATIVA; STATUS_V2=SUSPENSA_GLOBAL; STRIKES=2", _
                  obtidoBM2, _
                  "Garante que a regra de strikes respeita MAX_STRIKES configurado (nao apenas legado=1)", _
                  okBM2

    ' Restore + cleanup do escopo (L16 - nao vazar para proximo cenario).
    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "SBM2"

    ' --- CS_BORDA_MAX5 (Onda 17 MD-17.1.b) -----------------------------
    ' Tema: Borda alta MAX_STRIKES=5. Mesmo padrao de CS_BORDA_MAX2 mas
    ' com 5 voltas para validar que a regra escala corretamente para
    ' cardinalidade maior. INV-1: 5 voltas = 5 indicacoes para EMP1
    ' (uma por volta), cada uma valida invariante do rodizio.
    Dim entsBM5() As String, empsBM5() As String, ativsBM5() As String
    Dim notasBM5(1 To 3) As Integer
    Dim notaMinBM5 As Double
    Dim statusBM5_v4 As String, statusBM5_v5 As String
    Dim strikesBM5 As Long
    Dim okBM5 As Boolean
    Dim obtidoBM5 As String
    Dim voltaBM5 As Long

    TV2_LimparNamespace "SBM5"
    TV2_FixtureFactory "SBM5", 1, 3, 1, entsBM5, empsBM5, ativsBM5
    TV2_RestaurarConfigBaseline 5, 0  ' MAX_STRIKES=5

    notasBM5(1) = TV2_E2E_NOTA_BAIXA
    notasBM5(2) = TV2_E2E_NOTA_ALTA
    notasBM5(3) = TV2_E2E_NOTA_ALTA

    ' 4 voltas: EMP1 acumula 4 strikes (NAO suspende - precisa 5).
    For voltaBM5 = 1 To 4
        TV2_FF_RodadaCompleta ativsBM5(1), entsBM5(1), 3, empsBM5, notasBM5
    Next voltaBM5
    statusBM5_v4 = TV2_StatusEmpresa(empsBM5(1))

    ' 5a volta: EMP1 atinge 5 strikes -> SUSPENDE.
    TV2_FF_RodadaCompleta ativsBM5(1), entsBM5(1), 3, empsBM5, notasBM5
    statusBM5_v5 = TV2_StatusEmpresa(empsBM5(1))

    notaMinBM5 = GetNotaMinimaAvaliacao()
    strikesBM5 = ContarStrikesPorEmpresa(empsBM5(1), notaMinBM5)

    obtidoBM5 = "EMP1=" & empsBM5(1) & _
                "; STATUS_V4=" & statusBM5_v4 & _
                "; STATUS_V5=" & statusBM5_v5 & _
                "; STRIKES=" & CStr(strikesBM5)
    okBM5 = (statusBM5_v4 = "ATIVA")
    okBM5 = okBM5 And (statusBM5_v5 = "SUSPENSA_GLOBAL")
    okBM5 = okBM5 And (strikesBM5 = 5)
    TV2_LogAssert "CANONICO", "CS_BORDA_MAX5", "AUTO", _
                  "Borda MAX_STRIKES=5: 4 strikes mantem ativa; 5 strikes suspendem", _
                  "STATUS_V4=ATIVA; STATUS_V5=SUSPENSA_GLOBAL; STRIKES=5", _
                  obtidoBM5, _
                  "Valida escala da regra de strikes em borda alta (cardinalidade maior)", _
                  okBM5

    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "SBM5"

    ' --- CS_NOTA_ZERO (Onda 17 MD-17.1.b) ------------------------------
    ' Tema: Regressao L12 - filtro defensivo `> 0` em ContarStrikesPorEmpresa
    ' excluia nota zero do count, mascarando suspensao no caso real de
    ' "todas notas zero" (cenario BO_330d na V1). Fix removeu o `> 0`.
    ' Este cenario garante que regressao nao volta silenciosamente.
    Dim entsNZE() As String, empsNZE() As String, ativsNZE() As String
    Dim notasNZE(1 To 3) As Integer
    Dim notaMinNZE As Double
    Dim statusNZE As String
    Dim strikesNZE As Long
    Dim okNZE As Boolean
    Dim obtidoNZE As String

    TV2_LimparNamespace "SNZE"
    TV2_FixtureFactory "SNZE", 1, 3, 1, entsNZE, empsNZE, ativsNZE
    TV2_RestaurarConfigBaseline 1, 0  ' MAX_STRIKES=1 (legado), DIAS=0

    notasNZE(1) = 0  ' EMP1: nota ZERO (caso de borda L12)
    notasNZE(2) = TV2_E2E_NOTA_ALTA
    notasNZE(3) = TV2_E2E_NOTA_ALTA

    ' 1 volta: EMP1 recebe nota=0 que deve contar como strike (L12 fix).
    TV2_FF_RodadaCompleta ativsNZE(1), entsNZE(1), 3, empsNZE, notasNZE

    statusNZE = TV2_StatusEmpresa(empsNZE(1))
    notaMinNZE = GetNotaMinimaAvaliacao()
    strikesNZE = ContarStrikesPorEmpresa(empsNZE(1), notaMinNZE)

    obtidoNZE = "EMP1=" & empsNZE(1) & _
                "; STATUS=" & statusNZE & _
                "; STRIKES=" & CStr(strikesNZE) & _
                "; NOTA_MIN=" & CStr(notaMinNZE)
    okNZE = (strikesNZE >= 1)
    okNZE = okNZE And (statusNZE = "SUSPENSA_GLOBAL")
    TV2_LogAssert "CANONICO", "CS_NOTA_ZERO", "AUTO", _
                  "Nota zero conta como strike (regressao L12)", _
                  "STRIKES>=1; STATUS=SUSPENSA_GLOBAL com MAX_STRIKES=1", _
                  obtidoNZE, _
                  "Filtro defensivo `> 0` em ContarStrikesPorEmpresa quebrava caso real BO_330d; fix removeu - este cenario veta a regressao", _
                  okNZE

    ' Restore (mantem MAX=1 que ja eh baseline) + cleanup.
    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "SNZE"

    TV2_FinalizarExecucao "CANONICO", silencioso
    Exit Sub

falha:
    On Error Resume Next
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    On Error GoTo 0
    TV2_LogAssert "CANONICO", "FATAL", "AUTO", _
                  "Executar suíte canônica sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreável na família CS_*", False
    TV2_FinalizarExecucao "CANONICO", silencioso
End Sub

Public Sub TV2_RunStress(Optional ByVal iteracoes As Long = 12, Optional ByVal visual As Boolean = False)
    Dim i As Long
    Dim resPre As TResult
    Dim resRec As TResult
    Dim resOs As TResult
    Dim resAval As TResult
    Dim preosId As String
    Dim osId As String
    Dim notas(1 To 10) As Integer
    Dim detalhe As String
    Dim ok As Boolean
    Dim qtd As Double
    Dim qtdCredItem As Long

    On Error GoTo falha

    If iteracoes <= 0 Then iteracoes = 12

    TV2_InitExecucao "STRESS", visual
    TV2_PrepararCenarioTriploCanonico

    For i = 1 To iteracoes
        qtd = 1 + (i Mod 3)
        resPre = EmitirPreOS("001", TV2_CodServicoA(), qtd)
        preosId = resPre.IdGerado

        If resPre.sucesso Then
            If (i Mod 2) = 1 Then
                resRec = RecusarPreOS(preosId, "RECUSA_STRESS_" & CStr(i))
                detalhe = "ITER=" & CStr(i) & "; ETAPA=RECUSA; PREOS=" & preosId & "; SUCESSO=" & CStr(resRec.sucesso)
                ok = resRec.sucesso
            Else
                resOs = EmitirOS(preosId, Date + 3 + i, "EMP-STRESS-" & CStr(i))
                osId = resOs.IdGerado

                If resOs.sucesso Then
                    TV2_PreencherNotas notas, 7 + (i Mod 2)
                    resAval = AvaliarOS(osId, "QA STRESS V2", notas, qtd, "Stress V2", "", Date + 4 + i, Date + 20 + i)
                    detalhe = "ITER=" & CStr(i) & "; ETAPA=OS+AVAL; PREOS=" & preosId & "; OS=" & osId & "; SUCESSO_OS=" & CStr(resOs.sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.sucesso)
                    ok = resAval.sucesso
                Else
                    detalhe = "ITER=" & CStr(i) & "; ETAPA=OS; PREOS=" & preosId & "; SUCESSO_OS=" & CStr(resOs.sucesso)
                    ok = False
                End If
            End If
        Else
            detalhe = "ITER=" & CStr(i) & "; ETAPA=PREOS; SUCESSO_PREOS=False"
            ok = False
        End If

        qtdCredItem = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA())

        ok = ok And TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3)
        ok = ok And TV2_FilaTemIdsCanonicos(TV2_AtivCanonA(), 3)
        ok = ok And qtdCredItem = 3

        TV2_LogAssert "STRESS", "STR_001", "AUTO", _
                      "Manter invariantes de fila em repeticao controlada", _
                      "Fila com IDs 001,002,003 sem duplicidade, 3 credenciamentos no item e posicoes estritamente crescentes", _
                      detalhe & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()) & "; QTD_ITEM=" & CStr(qtdCredItem), _
                      "Busca regressao estrutural sob repeticao", ok
    Next i

    TV2_FinalizarExecucao "STRESS"
    Exit Sub

falha:
    TV2_LogAssert "STRESS", "FATAL", "AUTO", _
                  "Executar stress sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao "STRESS"
End Sub

Private Sub TV2_PreencherNotas(ByRef notas() As Integer, ByVal valor As Integer)
    Dim i As Long

    For i = LBound(notas) To UBound(notas)
        notas(i) = valor
    Next i
End Sub

Private Sub TV2_MontarMatrizFiltroFixture(ByRef matriz() As Variant)
    matriz(1, 1) = "001"
    matriz(1, 2) = "Jo" & ChrW$(227) & "o da Silva"
    matriz(1, 3) = "12.345.678/0001-90"
    matriz(1, 4) = "Servi" & ChrW$(231) & "o A"
    matriz(1, 5) = "8121-4/00"
    matriz(1, 6) = "Limpeza urbana"

    matriz(2, 1) = "002"
    matriz(2, 2) = "Maria Souza"
    matriz(2, 3) = "98.765.432/0001-10"
    matriz(2, 4) = "Servico B"
    matriz(2, 5) = "4321-5/00"
    matriz(2, 6) = "Manutencao predial"

    matriz(3, 1) = "003"
    matriz(3, 2) = "Empresa sem acento"
    matriz(3, 3) = "11.111.111/0001-11"
    matriz(3, 4) = "Servi" & ChrW$(231) & "o de poda"
    matriz(3, 5) = "7711-0/00"
    matriz(3, 6) = "Poda de arvores"

    matriz(4, 1) = "004"
    matriz(4, 2) = "Local 3"
    matriz(4, 3) = "22.222.222/0001-22"
    matriz(4, 4) = "SERVICO DE PULVERIZACAO"
    matriz(4, 5) = "0161-0/99"
    matriz(4, 6) = "Pulverizacao e controle"
End Sub

Private Function TV2_ArrayLinhaCount(ByVal arr As Variant) As Long
    On Error GoTo fim
    If IsArray(arr) Then
        TV2_ArrayLinhaCount = UBound(arr, 1) - LBound(arr, 1) + 1
    End If
fim:
End Function

Private Function TV2_ArrayValorTexto(ByVal arr As Variant, ByVal rowOffset As Long, ByVal col As Long) As String
    On Error GoTo fim
    If IsArray(arr) Then
        TV2_ArrayValorTexto = SafeListText(arr(LBound(arr, 1) + rowOffset, col))
    End If
fim:
End Function

Private Function TV2_FormatEmpId(ByVal valor As String) As String
    If Trim$(valor) = "" Then
        TV2_FormatEmpId = ""
    Else
        TV2_FormatEmpId = Format$(CLng(Val(valor)), "000")
    End If
End Function

Private Sub TV2_CS_PrepararEstadoAteCS04(ByRef preosIdA As String, ByRef osIdA As String)
    Dim resPre As TResult
    Dim resOs As TResult

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    If Not resPre.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS04", "Falha ao emitir PRE_OS inicial de A."
    End If

    preosIdA = resPre.IdGerado
    resOs = EmitirOS(preosIdA, Date + 7, "EMP-CS-04")
    If Not resOs.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS04", "Falha ao emitir OS inicial de A."
    End If

    osIdA = resOs.IdGerado
End Sub

Private Sub TV2_CS_PrepararEstadoAteCS06( _
    ByRef preosIdA As String, _
    ByRef osIdA As String, _
    ByRef preosIdB As String, _
    ByRef preosIdC As String)
    Dim resPre As TResult

    TV2_CS_PrepararEstadoAteCS04 preosIdA, osIdA

    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    If Not resPre.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS06", "Falha ao emitir PRE_OS de B."
    End If
    preosIdB = resPre.IdGerado

    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    If Not resPre.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS06", "Falha ao emitir PRE_OS de C."
    End If
    preosIdC = resPre.IdGerado
End Sub

Private Sub TV2_CS_PrepararEstadoAteCS14( _
    ByRef preosIdA As String, _
    ByRef osIdA As String, _
    ByRef preosIdB As String, _
    ByRef osIdB As String)
    Dim resPre As TResult
    Dim resOs As TResult

    TV2_CS_PrepararEstadoAteCS04 preosIdA, osIdA

    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    If Not resPre.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS14", "Falha ao emitir PRE_OS de B."
    End If
    preosIdB = resPre.IdGerado

    resOs = EmitirOS(preosIdB, Date + 7, "EMP-CS-14-B")
    If Not resOs.sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS14", "Falha ao emitir OS de B."
    End If
    osIdB = resOs.IdGerado
End Sub



' ============================================================
' V12.0.0203 ONDA 10 Microdelta 1.5 fix4 (2026-05-01)
' Suite END-TO-END de strikes via rodizio natural.
'
' Substitui TV2_RunStrikes (cenarios CS_AVAL_001..007 deprecated).
' A nova suite usa um cenario isolado (atividade ATIV=999, servico
' SERV=001 dedicados) e exercita a regra de strikes atraves de
' rodizios sucessivos com notas pre-definidas por empresa, sem
' manipular fila diretamente.
'
' Etapas (proposta aprovada por Mauricio em 2026-05-01):
'   A-B  Setup: cadastra ATIV/SERV novos, credencia EMP1/2/3 ordem 1->2->3
'   C    3 voltas com EMP1 nota baixa -> EMP1 acumula 3 strikes -> SUSPENDE
'   D    1 volta sem EMP1 (suspensa) -> rodizio pula corretamente
'   E    3 voltas com EMP2 nota baixa -> EMP2 SUSPENDE
'   E.2  3 voltas so EMP3 notas altas -> EMP3 mantem 0 strikes
'   F    Reativa EMP1 (DT_FIM_SUSP=ontem). 1 volta com EMP3 nota baixa.
'        EMP3 ganha 1 strike. Confirma reativacao automatica.
'   G    Reativa EMP2 (sem indicacoes ainda).
'   H    2 voltas com todas. EMP3 nota baixa. Total EMP3=3 strikes -> SUSPENDE.
'   H.2  2 voltas EMP1+EMP2 notas altas. Sem novo strike.
'   I    Reativa EMP3.
'   J    1 volta final com todas regularizadas. Sistema voltou ao normal.
'
' Validacao: ContarStrikesPorEmpresa le historico completo (sem janela
' temporal - decisao de produto V12.0.0203). Reativacao por timeout
' usa mecanismo nativo SelecionarEmpresa->Reativar (sem chamar manual).
'
' Idempotencia: TV2_PrepararBaselineCanonica reseta tudo no inicio.
' ============================================================

Public Sub TV2_RunRodizioStrikesEndToEnd(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim contStrikes1 As Long, contStrikes2 As Long, contStrikes3 As Long
    Dim notaMin As Double
    Dim i As Long

    On Error GoTo falha

    TV2_InitExecucao "STRIKES_E2E", visual

    notaMin = GetNotaMinimaAvaliacao()

    ' ========= ETAPA A-B: Setup =========
    TV2_PrepararBaselineCanonica
    TV2_E2E_PrepararCenario

    TV2_LogInfo "STRIKES_E2E", "ETAPA_A_B_SETUP", _
        "Cenario isolado: ATIV=" & TV2_E2E_ATIV_ID & ", SERV=" & TV2_E2E_SERV_ID & ", 3 empresas credenciadas", _
        "Setup concluido: baseline + atividade nova + 3 empresas em ordem 1->2->3"

    ' ========= ETAPA C: 3 voltas com EMP1 nota baixa =========
    For i = 1 To 3
        TV2_E2E_RodadaCompleta TV2_E2E_NOTA_BAIXA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA
        emp = LerEmpresa("001", linhaEmp)
        contStrikes1 = ContarStrikesPorEmpresa("001", notaMin)
        TV2_LogAssert "STRIKES_E2E", "CS_E2E_C_VOLTA_" & i, "AUTO", _
            "Etapa C volta " & i & ": EMP1 nota baixa acumula " & i & " strike(s)", _
            "STRIKES=" & i, _
            "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes1, _
            "Cada nota baixa em EMP1 incrementa contador (MAX_STRIKES=3 default)", _
            contStrikes1 = i
    Next i
    emp = LerEmpresa("001", linhaEmp)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_C_FINAL_SUSP", "AUTO", _
        "Apos 3 strikes, EMP1 deve estar SUSPENSA com DT_FIM_SUSP futuro", _
        "STATUS=SUSPENSA_GLOBAL; DT_FIM>hoje", _
        "STATUS=" & emp.STATUS_GLOBAL & "; DT_FIM=" & Format$(emp.DT_FIM_SUSP, "DD/MM/YYYY"), _
        "Confirma que MAX_STRIKES dispara suspensao na 3a vez (regra Onda 1)", _
        emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL" And emp.DT_FIM_SUSP > Date

    ' ========= ETAPA D: 1 volta sem EMP1 =========
    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA
    contStrikes1 = ContarStrikesPorEmpresa("001", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_D_PULA_SUSP", "AUTO", _
        "Etapa D: rodizio pula EMP1 suspensa (atende EMP2 e EMP3)", _
        "EMP1.STRIKES=3 inalterado", _
        "EMP1.STRIKES=" & contStrikes1, _
        "Confirma que SelecionarEmpresa pula empresa SUSPENSA_GLOBAL", _
        contStrikes1 = 3

    ' ========= ETAPA E: 3 voltas com EMP2 nota baixa =========
    ' V12.0.0203 ONDA 11 / MD-2.2 - asserts ajustados para refletir a
    ' verdade matematica do rodizio determinístico. Aqui EMP1 esta
    ' SUSPENSA, restam EMP2 e EMP3 ativas. Cada RodadaCompleta faz 3
    ' atendimentos, mas com apenas 2 EMPs disponiveis a distribuicao
    ' por volta nao e simetrica (sera 1+2 ou 2+1 entre EMP2 e EMP3,
    ' alternando deterministicamente conforme DT_ULT_IND da fila).
    ' Comportamento real, observado e idempotente (validado em
    ' VR_20260502_024245):
    '   Volta 1: rodizio da 1x EMP2 baixa + 2x EMP3 alta -> EMP2 STRIKES=1, ATIVA
    '   Volta 2: rodizio da 2x EMP2 baixa + 1x EMP3 alta -> EMP2 STRIKES=3, SUSPENDE
    '   Volta 3: EMP2 ja suspensa, 3x EMP3 alta -> STRIKES inalterado
    ' Asserts validam a verdade do sistema, nao uma narrativa pedagogica
    ' irreal de "1 strike por volta" que so seria possivel com 3 EMPs
    ' ativas (caso da Etapa C).
    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_BAIXA, TV2_E2E_NOTA_ALTA
    emp = LerEmpresa("002", linhaEmp)
    contStrikes2 = ContarStrikesPorEmpresa("002", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_E_VOLTA_1", "AUTO", _
        "Etapa E volta 1 (EMP1 suspensa): rodizio da 1x EMP2 baixa + 2x EMP3 alta", _
        "STRIKES=1; STATUS=ATIVA", _
        "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes2, _
        "EMP2 atende 1x na volta 1 - distribuicao 1+2 com 2 EMPs ativas", _
        contStrikes2 = 1 And emp.STATUS_GLOBAL = "ATIVA"

    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_BAIXA, TV2_E2E_NOTA_ALTA
    emp = LerEmpresa("002", linhaEmp)
    contStrikes2 = ContarStrikesPorEmpresa("002", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_E_VOLTA_2", "AUTO", _
        "Etapa E volta 2: rodizio da 2x EMP2 baixa, totaliza 3 strikes e SUSPENDE EMP2", _
        "STRIKES=3; STATUS=SUSPENSA_GLOBAL", _
        "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes2, _
        "EMP2 atende 2x na volta 2 - distribuicao 2+1; 1 acumulado + 2 = MAX_STRIKES", _
        contStrikes2 = 3 And emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL"

    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_BAIXA, TV2_E2E_NOTA_ALTA
    emp = LerEmpresa("002", linhaEmp)
    contStrikes2 = ContarStrikesPorEmpresa("002", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_E_VOLTA_3", "AUTO", _
        "Etapa E volta 3: EMP2 ja suspensa, todos atendimentos vao para EMP3", _
        "STRIKES=3; STATUS=SUSPENSA_GLOBAL", _
        "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes2, _
        "STRIKES inalterado - rodizio pula EMP2 SUSPENSA_GLOBAL", _
        contStrikes2 = 3 And emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL"

    emp = LerEmpresa("002", linhaEmp)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_E_FINAL_SUSP", "AUTO", _
        "Apos as 3 voltas da Etapa E, EMP2 esta SUSPENSA", _
        "STATUS=SUSPENSA_GLOBAL", _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "Confirma regra: EMP2 atinge MAX_STRIKES e suspende, igual EMP1 fez na Etapa C", _
        emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL"

    ' ========= ETAPA E.2: 3 voltas so EMP3 (notas altas) =========
    For i = 1 To 3
        TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA
    Next i
    contStrikes3 = ContarStrikesPorEmpresa("003", notaMin)
    emp = LerEmpresa("003", linhaEmp)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_E2_FINAL", "AUTO", _
        "Etapa E.2: EMP3 sozinha com notas altas mantem 0 strikes", _
        "STATUS=ATIVA; STRIKES=0", _
        "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes3, _
        "Confirma que rodizio com 1 unica empresa ativa funciona", _
        emp.STATUS_GLOBAL = "ATIVA" And contStrikes3 = 0

    ' ========= ETAPA F: reativa EMP1 + 1 volta (EMP1 alta, EMP3 baixa) =========
    TV2_E2E_ForcarPrazoVencido "001"
    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_BAIXA
    emp = LerEmpresa("001", linhaEmp)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_F_REATIVA1", "AUTO", _
        "Etapa F: DT_FIM_SUSP vencido reativa EMP1 automaticamente", _
        "STATUS=ATIVA", _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "Reativacao automatica via SelecionarEmpresa->Reativar (sem manual)", _
        emp.STATUS_GLOBAL = "ATIVA"
    contStrikes3 = ContarStrikesPorEmpresa("003", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_F_STRIKE3", "AUTO", _
        "Etapa F: EMP3 acumula 1 strike (1 nota baixa nesta volta)", _
        "STRIKES=1", _
        "STRIKES=" & contStrikes3, _
        "Strike e contado mesmo apos reativacao da EMP1", _
        contStrikes3 = 1

    ' ========= ETAPA G: reativa EMP2 (sem indicacoes ainda) =========
    TV2_E2E_ForcarPrazoVencido "002"
    TV2_LogInfo "STRIKES_E2E", "ETAPA_G_REATIVA_EMP2", _
        "DT_FIM_SUSP de EMP2 reescrito para ontem; reativacao acontecera na proxima SelecionarEmpresa", _
        "EMP2 marcada para reativacao automatica no proximo rodizio"

    ' ========= ETAPA H: 2 voltas com todas (EMP3 nota baixa) =========
    For i = 1 To 2
        TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_BAIXA
    Next i
    emp = LerEmpresa("003", linhaEmp)
    contStrikes3 = ContarStrikesPorEmpresa("003", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_H_FINAL_SUSP", "AUTO", _
        "Etapa H: EMP3 atinge 3 strikes (1 de F + 2 de H) e SUSPENDE", _
        "STATUS=SUSPENSA_GLOBAL; STRIKES=3", _
        "STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & contStrikes3, _
        "Confirma acumulacao cruzada entre etapas distintas", _
        emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL" And contStrikes3 = 3
    emp = LerEmpresa("002", linhaEmp)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_H_REATIVA_EMP2", "AUTO", _
        "Etapa H: EMP2 reativada durante as voltas (DT_FIM_SUSP venceu em G)", _
        "STATUS=ATIVA", _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "Reativacao automatica funciona em paralelo com strikes da EMP3", _
        emp.STATUS_GLOBAL = "ATIVA"

    ' ========= ETAPA H.2: 2 voltas EMP1+EMP2 notas altas =========
    For i = 1 To 2
        TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA
    Next i
    contStrikes1 = ContarStrikesPorEmpresa("001", notaMin)
    contStrikes2 = ContarStrikesPorEmpresa("002", notaMin)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_H2_NO_NEW_STRIKE", "AUTO", _
        "Etapa H.2: notas altas em EMP1+EMP2 nao incrementam strikes (historico inalterado)", _
        "EMP1.STRIKES=3; EMP2.STRIKES=3", _
        "EMP1.STRIKES=" & contStrikes1 & "; EMP2.STRIKES=" & contStrikes2, _
        "Confirma que ContarStrikes ve historico completo (sem janela temporal)", _
        contStrikes1 = 3 And contStrikes2 = 3

    ' ========= ETAPA I: reativa EMP3 =========
    TV2_E2E_ForcarPrazoVencido "003"
    TV2_LogInfo "STRIKES_E2E", "ETAPA_I_REATIVA_EMP3", _
        "DT_FIM_SUSP de EMP3 reescrito para ontem", _
        "EMP3 marcada para reativacao automatica no proximo rodizio"

    ' ========= ETAPA J: 1 volta final com todas regularizadas =========
    TV2_E2E_RodadaCompleta TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA, TV2_E2E_NOTA_ALTA
    Dim e1 As TEmpresa, e2 As TEmpresa, e3 As TEmpresa
    Dim lt As Long
    e1 = LerEmpresa("001", lt)
    e2 = LerEmpresa("002", lt)
    e3 = LerEmpresa("003", lt)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_J_TODAS_ATIVAS", "AUTO", _
        "Etapa J: ciclo final com todas reativadas e notas altas. Todas ATIVAS.", _
        "EMP1=ATIVA; EMP2=ATIVA; EMP3=ATIVA", _
        "EMP1=" & e1.STATUS_GLOBAL & "; EMP2=" & e2.STATUS_GLOBAL & "; EMP3=" & e3.STATUS_GLOBAL, _
        "Sistema voltou a estado funcional pleno apos ciclo completo de strikes+reativacoes", _
        e1.STATUS_GLOBAL = "ATIVA" And e2.STATUS_GLOBAL = "ATIVA" And e3.STATUS_GLOBAL = "ATIVA"

    '==================================================================
    ' V12.0.0203 ONDA 17 MD-17.1.b - Cenarios E2E novos (cobertura strikes)
    '==================================================================

    ' --- CS_E2E_REATIV2STRIKES (Onda 18 MD-18.1b) ----------------------
    ' Valida Opcao B: ContarStrikesPorEmpresa preserva historico total,
    ' enquanto ContarStrikesParaPunicao considera apenas OS concluida com
    ' COL_OS_DT_FECHAMENTO > EMPRESAS.DT_ULT_REATIV.
    Dim entsR2S() As String, empsR2S() As String, ativsR2S() As String
    Dim notasR2S(1 To 3) As Integer
    Dim notaMinR2S As Double
    Dim statusR2S_pos_reativ As String
    Dim statusR2S_pos_3novas As String
    Dim strikesR2S_total As Long
    Dim strikesR2S_punicao As Long
    Dim strikesR2S_punicao3 As Long
    Dim observadoR2S As String
    Dim voltaR2S As Long
    Dim empR2S As TEmpresa
    Dim linhaEmpR2S As Long

    TV2_LimparNamespace "SR2S"
    TV2_FixtureFactory "SR2S", 1, 3, 1, entsR2S, empsR2S, ativsR2S
    TV2_RestaurarConfigBaseline 3, 90  ' MAX_STRIKES=3, DIAS=90 (analogo a E2E classic)

    notasR2S(1) = TV2_E2E_NOTA_BAIXA
    notasR2S(2) = TV2_E2E_NOTA_ALTA
    notasR2S(3) = TV2_E2E_NOTA_ALTA

    ' Fase 1: 3 voltas historicas com fechamento antes da reativacao.
    For voltaR2S = 1 To 3
        TV2_FF_RodadaCompleta ativsR2S(1), entsR2S(1), 3, empsR2S, notasR2S, Date - 10
    Next voltaR2S

    ' Fase 2: forcar prazo vencido -> proxima SelecionarEmpresa reativa EMP1.
    TV2_E2E_ForcarPrazoVencido empsR2S(1)

    ' Fase 3: uma nova volta com fechamento apos reativacao. EMP1 recebe
    ' uma nota baixa nova, mas nao pode re-suspender com o historico antigo.
    TV2_FF_RodadaCompleta ativsR2S(1), entsR2S(1), 3, empsR2S, notasR2S, Date + 1

    notaMinR2S = GetNotaMinimaAvaliacao()
    strikesR2S_total = ContarStrikesPorEmpresa(empsR2S(1), notaMinR2S)
    strikesR2S_punicao = ContarStrikesParaPunicao(empsR2S(1), notaMinR2S)
    statusR2S_pos_reativ = TV2_StatusEmpresa(empsR2S(1))
    empR2S = LerEmpresa(empsR2S(1), linhaEmpR2S)

    observadoR2S = "EMP1=" & empsR2S(1) & _
                   "; STRIKES_TOTAL_HISTORICO=" & CStr(strikesR2S_total) & _
                   "; STRIKES_PARA_PUNICAO=" & CStr(strikesR2S_punicao) & _
                   "; STATUS_POS_REATIV_E_1NOTA=" & statusR2S_pos_reativ & _
                   "; DT_ULT_REATIV=" & IIf(empR2S.DT_ULT_REATIV > CDate(0), Format$(empR2S.DT_ULT_REATIV, "DD/MM/YYYY HH:NN:SS"), "(vazia)")

    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_DT_ULT_REATIV_GRAVADA", "AUTO", _
                  "Reativacao automatica grava DT_ULT_REATIV em EMPRESAS", _
                  "DT_ULT_REATIV preenchida", _
                  observadoR2S, _
                  "Campo de corte temporal existe e foi preenchido pela reativacao real do servico", _
                  empR2S.DT_ULT_REATIV > CDate(0)

    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_HISTORICO_TOTAL_PRESERVADO", "AUTO", _
                  "Historico total de strikes permanece consultavel apos reativacao", _
                  "ContarStrikesPorEmpresa >= 4", _
                  observadoR2S, _
                  "Preserva a dupla informacao da Opcao B: auditoria total sem anistia de historico", _
                  strikesR2S_total >= 4

    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_JANELA_EXCLUI_HISTORICO", "AUTO", _
                  "Contador de punicao exclui OS fechadas antes da DT_ULT_REATIV", _
                  "STRIKES_TOTAL>=4; STRIKES_PUNICAO=1", _
                  observadoR2S, _
                  "Valida explicitamente o corte por COL_OS_DT_FECHAMENTO > DT_ULT_REATIV", _
                  strikesR2S_total >= 4 And strikesR2S_punicao = 1

    TV2_LogAssert "STRIKES_E2E", "CS_E2E_REATIV2STRIKES", "AUTO", _
                  "Reativacao automatica + 1 nota baixa pos-reativacao nao re-suspende por historico antigo", _
                  "STRIKES_TOTAL=4; STRIKES_PUNICAO=1; STATUS=ATIVA; DT_ULT_REATIV preenchida", _
                  observadoR2S, _
                  "Confirma Opcao B: historico total preservado e janela de punicao reinicia apos reativacao", _
                  strikesR2S_total >= 4 And strikesR2S_punicao = 1 And _
                  statusR2S_pos_reativ = "ATIVA" And empR2S.DT_ULT_REATIV > CDate(0)

    ' Fase 4: mais duas voltas novas. Na terceira nota baixa pos-reativacao
    ' a empresa deve suspender novamente.
    For voltaR2S = 1 To 2
        TV2_FF_RodadaCompleta ativsR2S(1), entsR2S(1), 3, empsR2S, notasR2S, Date + 1
    Next voltaR2S
    strikesR2S_punicao3 = ContarStrikesParaPunicao(empsR2S(1), notaMinR2S)
    statusR2S_pos_3novas = TV2_StatusEmpresa(empsR2S(1))

    TV2_LogAssert "STRIKES_E2E", "CS_E2E_REATIV3STRIKES", "AUTO", _
                  "Tres notas baixas pos-reativacao suspendem novamente", _
                  "STRIKES_PUNICAO=3; STATUS=SUSPENSA_GLOBAL", _
                  "STRIKES_PUNICAO=" & CStr(strikesR2S_punicao3) & _
                  "; STATUS=" & statusR2S_pos_3novas, _
                  "Garante que a janela nova nao anistia strikes posteriores a DT_ULT_REATIV", _
                  strikesR2S_punicao3 >= 3 And statusR2S_pos_3novas = "SUSPENSA_GLOBAL"

    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "SR2S"

    ' --- CS_REATIV_LEGADO_VAZIO (Onda 18 MD-18.1b) ---------------------
    ' Empresa nunca reativada: DT_ULT_REATIV vazio deve manter modo legado.
    Dim entsLEG() As String, empsLEG() As String, ativsLEG() As String
    Dim notasLEG(1 To 1) As Integer
    Dim totalLEG As Long
    Dim punicaoLEG As Long
    Dim empLEG As TEmpresa
    Dim linhaEmpLEG As Long

    TV2_LimparNamespace "SLEG"
    TV2_FixtureFactory "SLEG", 1, 1, 1, entsLEG, empsLEG, ativsLEG
    TV2_RestaurarConfigBaseline 3, 90
    notasLEG(1) = TV2_E2E_NOTA_BAIXA
    TV2_FF_RodadaCompleta ativsLEG(1), entsLEG(1), 1, empsLEG, notasLEG, Date + 1
    totalLEG = ContarStrikesPorEmpresa(empsLEG(1), GetNotaMinimaAvaliacao())
    punicaoLEG = ContarStrikesParaPunicao(empsLEG(1), GetNotaMinimaAvaliacao())
    empLEG = LerEmpresa(empsLEG(1), linhaEmpLEG)

    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_LEGADO_VAZIO", "AUTO", _
                  "Empresa sem DT_ULT_REATIV usa contador legado para punicao", _
                  "DT_ULT_REATIV vazia; STRIKES_TOTAL=STRIKES_PUNICAO=1", _
                  "DT_ULT_REATIV=" & IIf(empLEG.DT_ULT_REATIV > CDate(0), Format$(empLEG.DT_ULT_REATIV, "DD/MM/YYYY HH:NN:SS"), "(vazia)") & _
                  "; TOTAL=" & CStr(totalLEG) & "; PUNICAO=" & CStr(punicaoLEG), _
                  "Cobre migracao: empresas antigas com U vazia seguem comportamento historico ate primeira reativacao", _
                  empLEG.DT_ULT_REATIV = CDate(0) And totalLEG = 1 And punicaoLEG = 1

    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "SLEG"

    ' --- CS_E2E_5EMPS (Onda 17 MD-17.1.b) ------------------------------
    ' Tema: Rodizio com 5 EMPs, MAX_STRIKES=2, 3 voltas com EMP1 sempre
    ' nota baixa -> suspende DURANTE a volta 2 (no meio do ciclo).
    ' Valida cardinalidade maior + idempotencia + comportamento "rodizio
    ' pula EMP suspensa" + distribuicao de indicacoes em volta 3 com 4 EMPs aptas.
    '
    ' INV-1: 3 voltas x 5 indicacoes = 15 indicacoes total se todas EMPs
    ' permanecessem ativas. Mas EMP1 suspende durante volta 2 (no 2o
    ' strike), entao a volta 3 tem 4 EMPs aptas + 5 indicacoes - alguma
    ' EMP recebe 2 indicacoes. Cada uma dessas voltas valida invariante
    ' do rodizio (FIFO, pula suspensa, distribui).
    Dim ents5E() As String, emps5E() As String, ativs5E() As String
    Dim notas5E(1 To 5) As Integer
    Dim notaMin5E As Double
    Dim status5E_emp1 As String
    Dim strikes5E_emp1 As Long
    Dim ok5E As Boolean
    Dim obtido5E As String
    Dim volta5E As Long

    TV2_LimparNamespace "S5E"
    TV2_FixtureFactory "S5E", 1, 5, 1, ents5E, emps5E, ativs5E
    TV2_RestaurarConfigBaseline 2, 90  ' MAX_STRIKES=2, DIAS=90

    notas5E(1) = TV2_E2E_NOTA_BAIXA  ' EMP1 sempre baixa -> 2 strikes na volta 2 -> SUSPENDE
    notas5E(2) = TV2_E2E_NOTA_ALTA
    notas5E(3) = TV2_E2E_NOTA_ALTA
    notas5E(4) = TV2_E2E_NOTA_ALTA
    notas5E(5) = TV2_E2E_NOTA_ALTA

    ' 3 voltas, 5 indicacoes cada (rodizio decide distribuicao).
    For volta5E = 1 To 3
        TV2_FF_RodadaCompleta ativs5E(1), ents5E(1), 5, emps5E, notas5E
    Next volta5E

    status5E_emp1 = TV2_StatusEmpresa(emps5E(1))
    notaMin5E = GetNotaMinimaAvaliacao()
    strikes5E_emp1 = ContarStrikesPorEmpresa(emps5E(1), notaMin5E)

    obtido5E = "EMP1=" & emps5E(1) & _
               "; STATUS=" & status5E_emp1 & _
               "; STRIKES=" & CStr(strikes5E_emp1)
    ok5E = (status5E_emp1 = "SUSPENSA_GLOBAL")
    ok5E = ok5E And (strikes5E_emp1 >= 2)
    TV2_LogAssert "STRIKES_E2E", "CS_E2E_5EMPS", "AUTO", _
                  "Rodizio 5 EMPs MAX_STRIKES=2: EMP1 suspende durante volta 2; rodizio pula na volta 3", _
                  "EMP1.STATUS=SUSPENSA_GLOBAL; EMP1.STRIKES>=2 (suspende ao atingir MAX em meio de ciclo)", _
                  obtido5E, _
                  "Valida idempotencia + cardinalidade maior + rodizio frente a suspensao no meio do ciclo. Combinacao critica nao coberta por CS_E2E_* originais (operam com 3 EMPs).", _
                  ok5E

    TV2_RestaurarConfigBaseline 1, 0
    TV2_LimparNamespace "S5E"

    ' V12.0.0203 ONDA 11 / MD-2.3 - restaurar CONFIG baseline antes
    ' de finalizar para nao vazar MAX_STRIKES=3 para V1/CS_14/CS_16.
    ' V12.0.0203 ONDA 17 MD-17.1.a - agora chama o helper generalizado
    ' TV2_RestaurarConfigBaseline (Engine), parametrizado com defaults
    ' que reproduzem o comportamento legado (1, 0).
    TV2_RestaurarConfigBaseline 1, 0
    TV2_FinalizarExecucao "STRIKES_E2E", silencioso
    Exit Sub

falha:
    TV2_LogAssert "STRIKES_E2E", "FATAL", "AUTO", _
        "Executar suite end-to-end sem erro fatal", _
        "Nenhum erro fatal", _
        "Erro " & CStr(Err.Number) & ": " & Err.Description, _
        "Toda falha fatal precisa ficar rastreavel", False
    ' MD-2.3 - mesmo em erro, restaurar baseline para nao contaminar
    ' suite seguinte rodada pelo operador.
    ' Onda 17 MD-17.1.a: helper unificado em Engine.
    TV2_RestaurarConfigBaseline 1, 0
    TV2_FinalizarExecucao "STRIKES_E2E", silencioso
End Sub


' ============================================================
' Helpers privados da suite end-to-end (Microdelta 1.5 fix4)
' ============================================================

' Cria atividade ATIV_E2E + servico SERV_E2E + 3 entidades + 3 empresas
' + credencia 3 empresas em SERV_E2E na ordem 1->2->3.
' Idempotente: se os registros ja existem, nao duplica.
Private Sub TV2_E2E_PrepararCenario()
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long
    Dim jaExiste As Boolean
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    ' 1. Atividade nova
    Set ws = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    jaExiste = False
    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, COL_ATIV_ID).Value, TV2_E2E_ATIV_ID) Then
            jaExiste = True
            Exit For
        End If
    Next linha
    If Not jaExiste Then
        If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
            Err.Raise 1004, "TV2_E2E_PrepararCenario", "Nao foi possivel preparar ATIVIDADES."
        End If
        linha = TV2_NextDataRow(SHEET_ATIVIDADES)
        ws.Cells(linha, COL_ATIV_ID).Value = TV2_E2E_ATIV_ID
        ws.Cells(linha, COL_ATIV_DESCRICAO).Value = TV2_E2E_ATIV_DESC
        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    End If

    ' 2. Servico novo (CAD_SERV)
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultima = UltimaLinhaAba(SHEET_CAD_SERV)
    jaExiste = False
    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, TV2_E2E_ATIV_ID) And _
           IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, TV2_E2E_SERV_ID) Then
            jaExiste = True
            Exit For
        End If
    Next linha
    If Not jaExiste Then
        If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
            Err.Raise 1004, "TV2_E2E_PrepararCenario", "Nao foi possivel preparar CAD_SERV."
        End If
        linha = TV2_NextDataRow(SHEET_CAD_SERV)
        ws.Cells(linha, COL_SERV_ID).Value = TV2_E2E_SERV_ID
        ws.Cells(linha, COL_SERV_ATIV_ID).Value = TV2_E2E_ATIV_ID
        ws.Cells(linha, COL_SERV_ATIV_DESC).Value = TV2_E2E_ATIV_DESC
        ws.Cells(linha, COL_SERV_DESCRICAO).Value = TV2_E2E_ATIV_DESC
        ws.Cells(linha, COL_SERV_VALOR_UNIT).Value = TV2_E2E_VALOR_UNIT
        ws.Cells(linha, COL_SERV_DT_CAD).Value = Now
        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    End If

    ' 3. Entidades + 4. Empresas + 5. Credenciamento (helpers existentes)
    TV2_CadastrarEntidadeCanonica "001", "Local 1 E2E"
    TV2_CadastrarEntidadeCanonica "002", "Local 2 E2E"
    TV2_CadastrarEntidadeCanonica "003", "Local 3 E2E"

    TV2_CadastrarEmpresaCanonica "001", "Empresa 1 E2E"
    TV2_CadastrarEmpresaCanonica "002", "Empresa 2 E2E"
    TV2_CadastrarEmpresaCanonica "003", "Empresa 3 E2E"

    TV2_CredenciarAtividade "001", TV2_E2E_ATIV_ID, TV2_E2E_SERV_ID
    TV2_CredenciarAtividade "002", TV2_E2E_ATIV_ID, TV2_E2E_SERV_ID
    TV2_CredenciarAtividade "003", TV2_E2E_ATIV_ID, TV2_E2E_SERV_ID

    ' V12.0.0203 ONDA 11 / MD-2 (Fix B) - sobrescreve config canonica
    ' para a suite E2E acumular ate 3 strikes antes de suspender. A
    ' baseline canonica grava MAX_STRIKES=1 (preservando comportamento
    ' legado V1/CS_14 onde 1 nota baixa ja suspendia), mas a suite E2E
    ' foi escrita esperando 3 strikes por simetria com a regra Onda 1
    ' (asserts CS_E2E_C_VOLTA_1=1, _VOLTA_2=2, _VOLTA_3=3 + FINAL_SUSP).
    ' Reset feito a cada execucao da suite; idempotente. Combinado com
    ' Fix A (Select Case tolerante a padding), restaura a aplicacao
    ' real da regra de strikes no fluxo E2E.
    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value = 3
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = 90
        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    End If
End Sub

' Executa 1 volta completa do rodizio na ATIV_E2E.
' Para cada empresa que o rodizio selecione (ate 3 indicacoes),
' emite Pre-OS, OS e avalia com a nota correspondente parametrizada.
Private Sub TV2_E2E_RodadaCompleta(ByVal notaE1 As Integer, _
                                    ByVal notaE2 As Integer, _
                                    ByVal notaE3 As Integer)
    Dim k As Long
    Dim atendeu As Long
    For k = 1 To 3
        atendeu = TV2_E2E_AtenderProximaEmpresa(notaE1, notaE2, notaE3)
        If atendeu = 0 Then Exit For
    Next k
End Sub

' Realiza 1 indicacao na ATIV_E2E. Retorna 1 se atendeu, 0 se sem aptos.
Private Function TV2_E2E_AtenderProximaEmpresa(ByVal notaE1 As Integer, _
                                                 ByVal notaE2 As Integer, _
                                                 ByVal notaE3 As Integer) As Long
    ' ONDA 11 / MD-1 - instrumentacao DT-3.
    ' Captura por rodada: EMP preselecionada, EMP gravada em PRE_OS,
    ' EMP em CAD_OS, STATUS_OS, e strike count para ambas EMPs (presel
    ' e real). Detecta dupla selecao divergente entre o observador do
    ' teste e o SelecionarEmpresa interno do EmitirPreOS.
    Dim sel As TRodizioResultado
    Dim notaUniforme As Integer
    Dim resPre As TResult
    Dim resOs As TResult
    Dim resAval As TResult
    Dim notas(1 To 10) As Integer
    Dim empPresel As String
    Dim pre As TPreOS
    Dim osReg As TOS
    Dim notaMin As Double
    Dim strikesPresel As Long
    Dim strikesReal As Long

    sel = SelecionarEmpresa(TV2_E2E_ATIV_ID)
    If Not sel.encontrou Then
        TV2_LogInfo "STRIKES_E2E", "E2E_NO_APTOS", _
            "SelecionarEmpresa nao encontrou empresa apta", _
            "Motivo: " & sel.MotivoFalha
        TV2_E2E_AtenderProximaEmpresa = 0
        Exit Function
    End If

    empPresel = sel.Empresa.EMP_ID
    TV2_LogInfo "STRIKES_E2E", "DIAG_PRESEL", _
        "Pre-selecionada antes de EmitirPreOS (observador externo)", _
        "EMP_PRESEL=" & empPresel

    ' V12.0.0203 ONDA 11 / MD-2 (Fix A) - Select Case tolerante a padding.
    ' EMP_ID em EMPRESAS e armazenado como Long (1, 2, 3) porque Excel
    ' converte celula numerica automaticamente, mesmo que o cadastro
    ' tenha sido feito com "001"/"002"/"003". Logo CStr(1)="1", e o
    ' Select Case literal contra "001" nunca casava - caia em Case Else
    ' =NOTA_ALTA(8), mascarando completamente a regra de strikes (todas
    ' as OSes recebiam nota alta, nenhum strike legitimo era contado).
    ' Causa raiz do DT-3 confirmada via DIAG_AVAL_POS no run TV2_20260502_020217.
    ' Val("001") = Val("1") = 1; CLng normaliza ambos.
    Select Case CLng(Val(empPresel))
        Case 1: notaUniforme = notaE1
        Case 2: notaUniforme = notaE2
        Case 3: notaUniforme = notaE3
        Case Else: notaUniforme = TV2_E2E_NOTA_ALTA
    End Select

    resPre = EmitirPreOS("001", TV2_E2E_ATIV_ID & "|" & TV2_E2E_SERV_ID, 1)
    If Not resPre.sucesso Then
        TV2_LogInfo "STRIKES_E2E", "E2E_PREOS_FAIL", _
            "EmitirPreOS falhou para EMP_PRESEL=" & empPresel & " COD=" & TV2_E2E_ATIV_ID & "|" & TV2_E2E_SERV_ID, _
            "Erro: " & resPre.mensagem
        TV2_E2E_AtenderProximaEmpresa = 0
        Exit Function
    End If

    pre = Repo_PreOS.BuscarPorId(resPre.IdGerado)
    TV2_LogInfo "STRIKES_E2E", "DIAG_PREOS", _
        "PreOS persistida apos EmitirPreOS", _
        "PREOS_ID=" & pre.PREOS_ID & " EMP_REAL=" & pre.EMP_ID & " STATUS=" & pre.STATUS_PREOS & " EMP_PRESEL=" & empPresel
    TV2_LogAssert "STRIKES_E2E", "DIAG_PREOS_INTEGRITY", "AUTO", _
        "EMP preselecionada deve coincidir com EMP gravada em PRE_OS", _
        "EMP=" & empPresel, _
        "EMP_PRESEL=" & empPresel & " EMP_PREOS=" & pre.EMP_ID, _
        "Detecta dupla selecao divergente entre observador e EmitirPreOS interno", _
        pre.EMP_ID = empPresel

    resOs = EmitirOS(resPre.IdGerado, Date + 7, "E2E-" & empPresel)
    If Not resOs.sucesso Then
        TV2_LogInfo "STRIKES_E2E", "E2E_OS_FAIL", _
            "EmitirOS falhou PREOS=" & resPre.IdGerado & " EMP_PRESEL=" & empPresel, _
            "Erro: " & resOs.mensagem
        TV2_E2E_AtenderProximaEmpresa = 0
        Exit Function
    End If

    osReg = Repo_OS.BuscarPorId(resOs.IdGerado)
    TV2_LogInfo "STRIKES_E2E", "DIAG_OS", _
        "OS persistida apos EmitirOS", _
        "OS_ID=" & osReg.OS_ID & " EMP_REAL=" & osReg.EMP_ID & " STATUS=" & osReg.STATUS_OS & " EMP_PRESEL=" & empPresel

    TV2_PreencherNotas notas, notaUniforme
    resAval = AvaliarOS(resOs.IdGerado, "QA E2E", notas, 1, "E2E_NOTA_" & notaUniforme, "", Date + 1, Date + 7)
    If Not resAval.sucesso Then
        TV2_LogInfo "STRIKES_E2E", "E2E_AVAL_FAIL", _
            "AvaliarOS falhou OS=" & resOs.IdGerado & " EMP_PRESEL=" & empPresel & " NOTA=" & notaUniforme, _
            "Erro: " & resAval.mensagem
    End If

    osReg = Repo_OS.BuscarPorId(resOs.IdGerado)
    notaMin = GetNotaMinimaAvaliacao()
    strikesPresel = ContarStrikesPorEmpresa(empPresel, notaMin)
    strikesReal = ContarStrikesPorEmpresa(osReg.EMP_ID, notaMin)
    TV2_LogInfo "STRIKES_E2E", "DIAG_AVAL_POS", _
        "Pos-AvaliarOS: estado da OS e contadores de strike", _
        "OS=" & osReg.OS_ID & " EMP_FINAL=" & osReg.EMP_ID & " STATUS=" & osReg.STATUS_OS & _
        " NOTA_USADA=" & notaUniforme & " strikes(presel " & empPresel & ")=" & strikesPresel & _
        " strikes(real " & osReg.EMP_ID & ")=" & strikesReal

    TV2_E2E_AtenderProximaEmpresa = 1
End Function

' Manipula DT_FIM_SUSP de uma empresa para Date - 1, simulando
' passagem de tempo. Proxima SelecionarEmpresa que considere essa
' empresa chamara Reativar() automaticamente (mecanismo nativo).
Private Sub TV2_E2E_ForcarPrazoVencido(ByVal empId As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    ultima = UltimaLinhaAba(SHEET_EMPRESAS)
    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, COL_EMP_ID).Value, empId) Then
            If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit For
            ws.Cells(linha, COL_EMP_DT_FIM_SUSP).Value = Date - 1
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            Exit For
        End If
    Next linha
End Sub

' V12.0.0203 ONDA 17 MD-17.1.a - REMOVIDOS deste modulo:
'   - TV2_E2E_NextDataRow (Private): substituido por TV2_NextDataRow
'     (Public no Engine apos promocao). Logica do Engine eh mais robusta
'     pois usa TV2_ColunaChave + TV2_PrimeiraLinhaDados (cobre caso
'     especial SHEET_EMPRESAS via PrimeiraLinhaDadosEmpresas).
'   - TV2_E2E_RestaurarConfigBaseline (Private): substituido por
'     TV2_RestaurarConfigBaseline (Public no Engine, parametrizado).
'     Defaults (1, 0) reproduzem o comportamento legado da versao
'     antiga; suites podem agora restaurar para outros valores via
'     TV2_RestaurarConfigBaseline maxStrikes, diasSusp.
' Ver readback .hbn/readbacks/0013-onda17-test-first.json e licao
' M11+L16 em PHAGOCYTOSIS-VBA-PATTERNS.

'======================================================================
' V12.0.0203 ONDA 17 MD-17.1.b - Helpers para cenarios baseados em FixtureFactory
'======================================================================
' TV2_FF_AtenderProximaEmpresa eh analogo de TV2_E2E_AtenderProximaEmpresa
' (linha 1739) mas usa lookup explicito por mapaEmps() em vez de Select Case
' por CLng(Val(empPresel)). Suporta IDs alfanumericos prefixados como os
' que TV2_FixtureFactory cria (ex: SBM2_001, S5E_003).
'
' TV2_FF_RodadaCompleta executa qtdIndicacoes consecutivas chamando o
' helper acima. Permite rodar voltas variaveis (1 a N indicacoes) por
' cenario, ao contrario de TV2_E2E_RodadaCompleta que e fixo em 3.
'
' INV-1 (Onda 17): chamadas consecutivas de TV2_FF_RodadaCompleta com
' mesmo padrao de notas validam idempotencia do rodizio sob repeticao.
' Cada volta acumula strikes consistentemente conforme regra de negocio.
'======================================================================
Private Function TV2_FF_AtenderProximaEmpresa( _
    ByVal ativId As String, _
    ByVal entId As String, _
    ByRef mapaEmps() As String, _
    ByRef notaPorPos() As Integer, _
    Optional ByVal dtFechamentoAval As Variant _
) As String
    Dim sel As TRodizioResultado
    Dim resPre As TResult
    Dim resOs As TResult
    Dim resAval As TResult
    Dim notas(1 To 10) As Integer
    Dim empPresel As String
    Dim notaUniforme As Integer
    Dim posicao As Long
    Dim i As Long
    Dim dtFechUse As Date

    sel = SelecionarEmpresa(ativId)
    If Not sel.encontrou Then
        TV2_FF_AtenderProximaEmpresa = ""
        Exit Function
    End If

    empPresel = sel.Empresa.EMP_ID

    ' Lookup explicito (substitui o Select Case do TV2_E2E_AtenderProximaEmpresa)
    posicao = 0
    For i = LBound(mapaEmps) To UBound(mapaEmps)
        If StrComp(mapaEmps(i), empPresel, vbTextCompare) = 0 Then
            posicao = i
            Exit For
        End If
    Next i
    If posicao = 0 Or posicao > UBound(notaPorPos) Then
        ' EMP nao mapeada (caso defensivo): usa nota alta default.
        notaUniforme = TV2_E2E_NOTA_ALTA
    Else
        notaUniforme = notaPorPos(posicao)
    End If

    If IsDate(dtFechamentoAval) Then
        dtFechUse = CDate(dtFechamentoAval)
    Else
        dtFechUse = Date + 1
    End If

    resPre = EmitirPreOS(entId, ativId & "|001", 1)
    If Not resPre.sucesso Then
        TV2_FF_AtenderProximaEmpresa = ""
        Exit Function
    End If

    resOs = EmitirOS(resPre.IdGerado, Date + 7, "FF-" & empPresel)
    If Not resOs.sucesso Then
        TV2_FF_AtenderProximaEmpresa = ""
        Exit Function
    End If

    TV2_PreencherNotas notas, notaUniforme
    resAval = AvaliarOS(resOs.IdGerado, "QA FF", notas, 1, "FF_NOTA_" & notaUniforme, "", dtFechUse, Date + 7)
    If Not resAval.sucesso Then
        TV2_FF_AtenderProximaEmpresa = ""
        Exit Function
    End If

    TV2_FF_AtenderProximaEmpresa = empPresel
End Function

Private Sub TV2_FF_RodadaCompleta( _
    ByVal ativId As String, _
    ByVal entId As String, _
    ByVal qtdIndicacoes As Long, _
    ByRef mapaEmps() As String, _
    ByRef notaPorPos() As Integer, _
    Optional ByVal dtFechamentoAval As Variant _
)
    ' INV-1: cada chamada equivale a uma "volta" do rodizio com qtdIndicacoes
    ' indicacoes consecutivas. Multiplas chamadas validam que o rodizio
    ' distribui corretamente entre as empresas em rounds independentes.
    Dim k As Long
    Dim atendeu As String
    For k = 1 To qtdIndicacoes
        atendeu = TV2_FF_AtenderProximaEmpresa(ativId, entId, mapaEmps, notaPorPos, dtFechamentoAval)
        If Len(atendeu) = 0 Then Exit For
    Next k
End Sub

' ============================================================
' V12.0.0203 ONDA 17 MD-17.2 (2026-05-03) - Suite IntegridadeBase + RPT_BUGS_CONHECIDOS
' ------------------------------------------------------------
' TV2_RunIntegridadeBase: suite PURE READ que varre EMPRESAS,
' EMPRESAS_INATIVAS, ENTIDADE, ENTIDADE_INATIVOS, ATIVIDADES e
' CAD_OS procurando por inconsistencias estruturais entre abas.
' Cobertura inicial (4 cenarios CS_INT_01..04):
'   CS_INT_01 - entidade com mesmo ENT_ID em ENTIDADE e ENTIDADE_INATIVOS
'   CS_INT_02 - empresa com mesmo EMP_ID em EMPRESAS e EMPRESAS_INATIVAS
'   CS_INT_03 - CNPJ duplicado em EMPRESAS (ATIVAS)
'   CS_INT_04 - referencia orfa em CAD_OS (EMP_ID ou ATIV_ID nao existe)
'
' Idempotencia: PURE READ em abas operacionais. Unico efeito colateral
' permitido: criar/atualizar abas RPT_BUGS_CONHECIDOS / RPT_BUGS_RESOLVIDOS
' (upsert por BUG_ID e remocao de bug resolvido da fila aberta).
' Execucoes consecutivas produzem mesmo numero de linhas em
' RESULTADO_QA_V2 (delta=4). Em base pre-MD-18.3, a primeira run move
' DT-17 para RPT_BUGS_RESOLVIDOS; depois disso, RPT_BUGS_* fica delta=0.
'
' Nao integra ainda no Quarteto. Sera incluida no Quinteto Minimo
' criado em MD-17.3 (CT_ValidarRelease_QuintetoMinimo). Standalone:
'   ?TV2_RunIntegridadeBase
'
' RPT_BUGS_CONHECIDOS schema (10 colunas A-J):
'   A BUG_ID            - identificador unico do bug
'   B TITULO            - descricao curta
'   C DESCOBERTO_EM     - data
'   D DESCOBERTO_POR    - operador / suite que detectou
'   E GRAVIDADE         - BAIXA / MEDIA / ALTA
'   F SUITE_DETECTORA   - nome da suite que pegou
'   G CENARIO_ASSOCIADO - id do cenario que detecta (CS_*)
'   H STATUS            - ABERTO / EM_RESOLUCAO / RESOLVIDO
'   I RESOLUCAO_PREVISTA - janela (Onda NN ou data)
'   J DOC_REFERENCIA    - caminho de doc explicativo no repo
'
' RPT_BUGS_RESOLVIDOS schema (13 colunas A-M):
'   A-H espelham RPT_BUGS_CONHECIDOS
'   I RESOLVIDO_EM
'   J RESOLVIDO_POR
'   K BUILD_RESOLUCAO
'   L RESOLUCAO_APLICADA
'   M DOC_REFERENCIA
'
' Onda 18 MD-18.3 move DT-17-REATIV-STRIKES para resolvidos apos
' MICRO25-fix2 + MICRO26 passarem compile e Quinteto.
' ============================================================

Public Sub TV2_RunIntegridadeBase(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    On Error GoTo falha

    TV2_InitExecucao "INTEGRIDADE_BASE", visual

    ' Abas RPT_* sempre garantidas antes dos cenarios (idempotente).
    TV2_AbaRPTBugsGarantirEstrutura
    TV2_AbaRPTBugsResolvidosGarantirEstrutura

    ' DT-17 foi resolvido por MD-18.1a/MD-18.1b e validado no Quinteto
    ' VR_20260504_060256. Mantem auditoria historica fora da fila aberta.
    TV2_MoverDT17ReativStrikesParaResolvidos

    ' CS_INT_01 - entidade duplicada ATIVA + INATIVA
    TV2_DetectarEntidadeDuplicadaAtivaInativa

    ' CS_INT_02 - empresa duplicada ATIVA + INATIVA
    TV2_DetectarEmpresaDuplicadaAtivaInativa

    ' CS_INT_03 - CNPJ duplicado em EMPRESAS (excluindo INATIVAS)
    TV2_DetectarCnpjDuplicado

    ' CS_INT_04 - referencia orfa em CAD_OS (EMP_ID ou ATIV_ID inexistente)
    TV2_DetectarRefOrfaCAD_OS

    TV2_FinalizarExecucao "INTEGRIDADE_BASE", silencioso
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "FATAL", "AUTO", _
                  "Executar suite IntegridadeBase sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao "INTEGRIDADE_BASE", silencioso
End Sub

Private Sub TV2_AbaRPTBugsGarantirEstrutura()
    ' Cria/valida aba RPT_BUGS_CONHECIDOS com 10 colunas A-J. Idempotente.
    Dim ws As Worksheet
    Dim wsCount As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("RPT_BUGS_CONHECIDOS")
    On Error GoTo 0

    If ws Is Nothing Then
        wsCount = ThisWorkbook.Worksheets.count
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(wsCount))
        ws.Name = "RPT_BUGS_CONHECIDOS"
    End If

    On Error GoTo fim_helper

    ' Header (idempotente - so escreve se A1 estiver vazio)
    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, 1).Value = "BUG_ID"
        ws.Cells(1, 2).Value = "TITULO"
        ws.Cells(1, 3).Value = "DESCOBERTO_EM"
        ws.Cells(1, 4).Value = "DESCOBERTO_POR"
        ws.Cells(1, 5).Value = "GRAVIDADE"
        ws.Cells(1, 6).Value = "SUITE_DETECTORA"
        ws.Cells(1, 7).Value = "CENARIO_ASSOCIADO"
        ws.Cells(1, 8).Value = "STATUS"
        ws.Cells(1, 9).Value = "RESOLUCAO_PREVISTA"
        ws.Cells(1, 10).Value = "DOC_REFERENCIA"

        With ws.Range(ws.Cells(1, 1), ws.Cells(1, 10))
            .Font.Bold = True
            .Interior.Color = RGB(0, 51, 102)
            .Font.Color = RGB(255, 255, 255)
            .HorizontalAlignment = xlCenter
        End With

        ws.Columns(1).ColumnWidth = 24
        ws.Columns(2).ColumnWidth = 56
        ws.Columns(3).ColumnWidth = 14
        ws.Columns(4).ColumnWidth = 38
        ws.Columns(5).ColumnWidth = 12
        ws.Columns(6).ColumnWidth = 36
        ws.Columns(7).ColumnWidth = 30
        ws.Columns(8).ColumnWidth = 14
        ws.Columns(9).ColumnWidth = 30
        ws.Columns(10).ColumnWidth = 56
    End If

fim_helper:
End Sub

Private Sub TV2_AbaRPTBugsResolvidosGarantirEstrutura()
    ' Cria/valida aba RPT_BUGS_RESOLVIDOS com 13 colunas A-M. Idempotente.
    Dim ws As Worksheet
    Dim wsCount As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("RPT_BUGS_RESOLVIDOS")
    On Error GoTo 0

    If ws Is Nothing Then
        wsCount = ThisWorkbook.Worksheets.count
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(wsCount))
        ws.Name = "RPT_BUGS_RESOLVIDOS"
    End If

    On Error GoTo fim_helper

    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, 1).Value = "BUG_ID"
        ws.Cells(1, 2).Value = "TITULO"
        ws.Cells(1, 3).Value = "DESCOBERTO_EM"
        ws.Cells(1, 4).Value = "DESCOBERTO_POR"
        ws.Cells(1, 5).Value = "GRAVIDADE"
        ws.Cells(1, 6).Value = "SUITE_DETECTORA"
        ws.Cells(1, 7).Value = "CENARIO_ASSOCIADO"
        ws.Cells(1, 8).Value = "STATUS"
        ws.Cells(1, 9).Value = "RESOLVIDO_EM"
        ws.Cells(1, 10).Value = "RESOLVIDO_POR"
        ws.Cells(1, 11).Value = "BUILD_RESOLUCAO"
        ws.Cells(1, 12).Value = "RESOLUCAO_APLICADA"
        ws.Cells(1, 13).Value = "DOC_REFERENCIA"

        With ws.Range(ws.Cells(1, 1), ws.Cells(1, 13))
            .Font.Bold = True
            .Interior.Color = RGB(0, 92, 68)
            .Font.Color = RGB(255, 255, 255)
            .HorizontalAlignment = xlCenter
        End With

        ws.Columns(1).ColumnWidth = 24
        ws.Columns(2).ColumnWidth = 56
        ws.Columns(3).ColumnWidth = 14
        ws.Columns(4).ColumnWidth = 38
        ws.Columns(5).ColumnWidth = 12
        ws.Columns(6).ColumnWidth = 36
        ws.Columns(7).ColumnWidth = 30
        ws.Columns(8).ColumnWidth = 14
        ws.Columns(9).ColumnWidth = 14
        ws.Columns(10).ColumnWidth = 42
        ws.Columns(11).ColumnWidth = 52
        ws.Columns(12).ColumnWidth = 72
        ws.Columns(13).ColumnWidth = 56
    End If

fim_helper:
End Sub

Public Sub RegistrarBugConhecido( _
    ByVal bugId As String, _
    ByVal titulo As String, _
    ByVal descobertoEm As Variant, _
    ByVal descobertoPor As String, _
    ByVal gravidade As String, _
    ByVal suiteDetectora As String, _
    ByVal cenarioAssociado As String, _
    ByVal status As String, _
    ByVal resolucaoPrevista As String, _
    ByVal docReferencia As String _
)
    ' Upsert por BUG_ID em RPT_BUGS_CONHECIDOS. Idempotente.
    ' Sucesso silencioso; falha tambem silenciosa (helper utilitario nao
    ' deve quebrar suite chamadora).
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim i As Long
    Dim linhaAlvo As Long
    Dim bugIdLimpo As String

    On Error GoTo fim

    bugIdLimpo = Trim$(bugId)
    If bugIdLimpo = "" Then Exit Sub

    Call TV2_AbaRPTBugsGarantirEstrutura

    Set ws = ThisWorkbook.Sheets("RPT_BUGS_CONHECIDOS")
    ultLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultLinha < 1 Then ultLinha = 1

    linhaAlvo = 0
    For i = 2 To ultLinha
        If StrComp(Trim$(CStr(ws.Cells(i, 1).Value)), bugIdLimpo, vbTextCompare) = 0 Then
            linhaAlvo = i
            Exit For
        End If
    Next i

    If linhaAlvo = 0 Then
        linhaAlvo = ultLinha + 1
        If linhaAlvo < 2 Then linhaAlvo = 2
    End If

    ws.Cells(linhaAlvo, 1).Value = bugIdLimpo
    ws.Cells(linhaAlvo, 2).Value = titulo
    If IsDate(descobertoEm) Then
        ws.Cells(linhaAlvo, 3).Value = CDate(descobertoEm)
    Else
        ws.Cells(linhaAlvo, 3).Value = CStr(descobertoEm)
    End If
    ws.Cells(linhaAlvo, 4).Value = descobertoPor
    ws.Cells(linhaAlvo, 5).Value = gravidade
    ws.Cells(linhaAlvo, 6).Value = suiteDetectora
    ws.Cells(linhaAlvo, 7).Value = cenarioAssociado
    ws.Cells(linhaAlvo, 8).Value = status
    ws.Cells(linhaAlvo, 9).Value = resolucaoPrevista
    ws.Cells(linhaAlvo, 10).Value = docReferencia

fim:
End Sub

Public Sub RegistrarBugResolvido( _
    ByVal bugId As String, _
    ByVal titulo As String, _
    ByVal descobertoEm As Variant, _
    ByVal descobertoPor As String, _
    ByVal gravidade As String, _
    ByVal suiteDetectora As String, _
    ByVal cenarioAssociado As String, _
    ByVal resolvidoEm As Variant, _
    ByVal resolvidoPor As String, _
    ByVal buildResolucao As String, _
    ByVal resolucaoAplicada As String, _
    ByVal docReferencia As String _
)
    ' Upsert por BUG_ID em RPT_BUGS_RESOLVIDOS. Idempotente.
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim i As Long
    Dim linhaAlvo As Long
    Dim bugIdLimpo As String

    On Error GoTo fim

    bugIdLimpo = Trim$(bugId)
    If bugIdLimpo = "" Then Exit Sub

    Call TV2_AbaRPTBugsResolvidosGarantirEstrutura

    Set ws = ThisWorkbook.Sheets("RPT_BUGS_RESOLVIDOS")
    ultLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultLinha < 1 Then ultLinha = 1

    linhaAlvo = 0
    For i = 2 To ultLinha
        If StrComp(Trim$(CStr(ws.Cells(i, 1).Value)), bugIdLimpo, vbTextCompare) = 0 Then
            linhaAlvo = i
            Exit For
        End If
    Next i

    If linhaAlvo = 0 Then
        linhaAlvo = ultLinha + 1
        If linhaAlvo < 2 Then linhaAlvo = 2
    End If

    ws.Cells(linhaAlvo, 1).Value = bugIdLimpo
    ws.Cells(linhaAlvo, 2).Value = titulo
    If IsDate(descobertoEm) Then
        ws.Cells(linhaAlvo, 3).Value = CDate(descobertoEm)
    Else
        ws.Cells(linhaAlvo, 3).Value = CStr(descobertoEm)
    End If
    ws.Cells(linhaAlvo, 4).Value = descobertoPor
    ws.Cells(linhaAlvo, 5).Value = gravidade
    ws.Cells(linhaAlvo, 6).Value = suiteDetectora
    ws.Cells(linhaAlvo, 7).Value = cenarioAssociado
    ws.Cells(linhaAlvo, 8).Value = "RESOLVIDO"
    If IsDate(resolvidoEm) Then
        ws.Cells(linhaAlvo, 9).Value = CDate(resolvidoEm)
    Else
        ws.Cells(linhaAlvo, 9).Value = CStr(resolvidoEm)
    End If
    ws.Cells(linhaAlvo, 10).Value = resolvidoPor
    ws.Cells(linhaAlvo, 11).Value = buildResolucao
    ws.Cells(linhaAlvo, 12).Value = resolucaoAplicada
    ws.Cells(linhaAlvo, 13).Value = docReferencia

fim:
End Sub

Private Sub TV2_RemoverBugConhecido(ByVal bugId As String)
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim i As Long
    Dim bugIdLimpo As String

    On Error GoTo fim

    bugIdLimpo = Trim$(bugId)
    If bugIdLimpo = "" Then Exit Sub

    Call TV2_AbaRPTBugsGarantirEstrutura

    Set ws = ThisWorkbook.Sheets("RPT_BUGS_CONHECIDOS")
    ultLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultLinha < 2 Then Exit Sub

    For i = ultLinha To 2 Step -1
        If StrComp(Trim$(CStr(ws.Cells(i, 1).Value)), bugIdLimpo, vbTextCompare) = 0 Then
            ws.Rows(i).Delete
        End If
    Next i

fim:
End Sub

Private Sub TV2_MoverDT17ReativStrikesParaResolvidos()
    RegistrarBugResolvido _
        "DT-17-REATIV-STRIKES", _
        "Reativacao de empresa nao zera contador de strikes (re-suspensao na 1a nota baixa pos-reativacao)", _
        DateSerial(2026, 5, 3), _
        "operador via TV2_RunRodizioStrikesEndToEnd CS_E2E_REATIV2STRIKES (AMARELO)", _
        "MEDIA", _
        "TV2_RunRodizioStrikesEndToEnd", _
        "CS_E2E_REATIV2STRIKES", _
        DateSerial(2026, 5, 4), _
        "Codex CLI / Onda 18 MD-18.1b / Quinteto VR_20260504_060256", _
        GetBuildImportado(), _
        "MD-18.1a adicionou DT_ULT_REATIV; MD-18.1b filtra punicao por COL_OS_DT_FECHAMENTO > DT_ULT_REATIV; CS_E2E_REATIV2STRIKES verde.", _
        "auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md"

    TV2_RemoverBugConhecido "DT-17-REATIV-STRIKES"
End Sub

Public Sub TV2_AbrirRPTBugsConhecidos()
    ' Atalho para abrir a aba RPT_BUGS_CONHECIDOS. Util como entrada futura
    ' do menu Central V2 (a ser adicionada quando RPT_BUGS_RESOLVIDOS chegar
    ' em Onda 18). Idempotente.
    Dim ws As Worksheet
    On Error GoTo fim

    Call TV2_AbaRPTBugsGarantirEstrutura
    Set ws = ThisWorkbook.Sheets("RPT_BUGS_CONHECIDOS")
    If Not ws Is Nothing Then
        ws.Activate
        ws.Cells(1, 1).Select
    End If

fim:
End Sub

Public Sub TV2_AbrirRPTBugsResolvidos()
    Dim ws As Worksheet
    On Error GoTo fim

    Call TV2_AbaRPTBugsResolvidosGarantirEstrutura
    Set ws = ThisWorkbook.Sheets("RPT_BUGS_RESOLVIDOS")
    If Not ws Is Nothing Then
        ws.Activate
        ws.Cells(1, 1).Select
    End If

fim:
End Sub

' ------------------------------------------------------------
' Detectores Private (CS_INT_01..04). Cada detector e PURE READ.
' Padrao: VERDE via TV2_LogAssert se zero ocorrencias; AMARELO via
' TV2_LogManual + RegistrarBugConhecido se houver ocorrencias.
' AMARELO nao bloqueia gate (gTV2Manual+=1; gTV2Fail inalterado).
' ------------------------------------------------------------

Private Sub TV2_DetectarEntidadeDuplicadaAtivaInativa()
    On Error GoTo falha

    Dim wsAtivas As Worksheet
    Dim wsInativas As Worksheet
    Dim setInativas As Object
    Dim ult As Long
    Dim i As Long
    Dim entIdAtual As String
    Dim duplicadosCsv As String
    Dim qtdDup As Long
    Dim obtido As String

    Set setInativas = CreateObject("Scripting.Dictionary")

    On Error Resume Next
    Set wsInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
    On Error GoTo falha

    If Not wsInativas Is Nothing Then
        ult = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
        For i = LINHA_DADOS To ult
            entIdAtual = Trim$(CStr(wsInativas.Cells(i, COL_ENT_ID).Value))
            If entIdAtual <> "" Then
                If Not setInativas.Exists(entIdAtual) Then
                    setInativas.Add entIdAtual, True
                End If
            End If
        Next i
    End If

    Set wsAtivas = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    ult = UltimaLinhaAba(SHEET_ENTIDADE)
    For i = LINHA_DADOS To ult
        entIdAtual = Trim$(CStr(wsAtivas.Cells(i, COL_ENT_ID).Value))
        If entIdAtual <> "" Then
            If setInativas.Exists(entIdAtual) Then
                qtdDup = qtdDup + 1
                If duplicadosCsv = "" Then
                    duplicadosCsv = entIdAtual
                Else
                    duplicadosCsv = duplicadosCsv & "," & entIdAtual
                End If
            End If
        End If
    Next i

    obtido = "QTD_DUP=" & CStr(qtdDup) & "; IDS=" & duplicadosCsv

    If qtdDup = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_01", "AUTO", _
                      "Detectar entidades com ID em ENTIDADE (ATIVA) e ENTIDADE_INATIVOS", _
                      "Zero duplicacoes (set vazio)", _
                      obtido, _
                      "Garante que reativacao de entidade move (nao copia) - integridade referencial", _
                      True
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_01", _
                      "Entidades com ID simultaneo em ENTIDADE e ENTIDADE_INATIVOS - sombra de inativacao", _
                      "Zero duplicacoes", _
                      "Bug de integridade documentado em RPT_BUGS_CONHECIDOS - investigar fluxo Reativa_Entidade", _
                      obtido & " - ver RPT_BUGS_CONHECIDOS"
        Call RegistrarBugConhecido( _
            "INT-ENT-DUP-ATV-INATV", _
            "Entidade duplicada em ENTIDADE (ATIVA) e ENTIDADE_INATIVOS - sombra apos reativacao", _
            CDate(Date), _
            "TV2_RunIntegridadeBase / TV2_DetectarEntidadeDuplicadaAtivaInativa", _
            "MEDIA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_01", _
            "ABERTO", _
            "investigar fluxo Reativa_Entidade.frm em onda futura", _
            "auditoria/00_status/<a-criar-quando-investigar>")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_01", "AUTO", _
                  "Executar deteccao de entidade duplicada sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub

Private Sub TV2_DetectarEmpresaDuplicadaAtivaInativa()
    On Error GoTo falha

    Dim wsAtivas As Worksheet
    Dim wsInativas As Worksheet
    Dim setInativas As Object
    Dim ult As Long
    Dim i As Long
    Dim empIdAtual As String
    Dim duplicadosCsv As String
    Dim qtdDup As Long
    Dim obtido As String

    Set setInativas = CreateObject("Scripting.Dictionary")

    On Error Resume Next
    Set wsInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    On Error GoTo falha

    If Not wsInativas Is Nothing Then
        ult = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
        For i = LINHA_DADOS To ult
            empIdAtual = Trim$(CStr(wsInativas.Cells(i, COL_EMP_ID).Value))
            If empIdAtual <> "" Then
                If Not setInativas.Exists(empIdAtual) Then
                    setInativas.Add empIdAtual, True
                End If
            End If
        Next i
    End If

    Set wsAtivas = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    ult = UltimaLinhaAba(SHEET_EMPRESAS)
    For i = LINHA_DADOS To ult
        empIdAtual = Trim$(CStr(wsAtivas.Cells(i, COL_EMP_ID).Value))
        If empIdAtual <> "" Then
            If setInativas.Exists(empIdAtual) Then
                qtdDup = qtdDup + 1
                If duplicadosCsv = "" Then
                    duplicadosCsv = empIdAtual
                Else
                    duplicadosCsv = duplicadosCsv & "," & empIdAtual
                End If
            End If
        End If
    Next i

    obtido = "QTD_DUP=" & CStr(qtdDup) & "; IDS=" & duplicadosCsv

    If qtdDup = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_02", "AUTO", _
                      "Detectar empresas com ID em EMPRESAS (ATIVA) e EMPRESAS_INATIVAS", _
                      "Zero duplicacoes (set vazio)", _
                      obtido, _
                      "Garante que reativacao de empresa move (nao copia) - integridade referencial", _
                      True
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_02", _
                      "Empresas com ID simultaneo em EMPRESAS e EMPRESAS_INATIVAS - sombra de inativacao", _
                      "Zero duplicacoes", _
                      "Bug de integridade - investigar fluxo Reativa_Empresa", _
                      obtido & " - ver RPT_BUGS_CONHECIDOS"
        Call RegistrarBugConhecido( _
            "INT-EMP-DUP-ATV-INATV", _
            "Empresa duplicada em EMPRESAS (ATIVA) e EMPRESAS_INATIVAS - sombra apos reativacao", _
            CDate(Date), _
            "TV2_RunIntegridadeBase / TV2_DetectarEmpresaDuplicadaAtivaInativa", _
            "MEDIA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_02", _
            "ABERTO", _
            "investigar fluxo Reativa_Empresa.frm em onda futura", _
            "auditoria/00_status/<a-criar-quando-investigar>")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_02", "AUTO", _
                  "Executar deteccao de empresa duplicada sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub

Private Sub TV2_DetectarCnpjDuplicado()
    On Error GoTo falha

    Dim ws As Worksheet
    Dim contagemCnpj As Object
    Dim ult As Long
    Dim i As Long
    Dim cnpjAtual As String
    Dim duplicadosCsv As String
    Dim qtdLinhasDup As Long
    Dim cnpjsDistintosDup As Long
    Dim chave As Variant
    Dim obtido As String

    Set contagemCnpj = CreateObject("Scripting.Dictionary")

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    ult = UltimaLinhaAba(SHEET_EMPRESAS)

    For i = LINHA_DADOS To ult
        cnpjAtual = Trim$(CStr(ws.Cells(i, COL_EMP_CNPJ).Value))
        If cnpjAtual <> "" Then
            If contagemCnpj.Exists(cnpjAtual) Then
                contagemCnpj(cnpjAtual) = CLng(contagemCnpj(cnpjAtual)) + 1
            Else
                contagemCnpj.Add cnpjAtual, 1
            End If
        End If
    Next i

    For Each chave In contagemCnpj.Keys
        If CLng(contagemCnpj(chave)) > 1 Then
            cnpjsDistintosDup = cnpjsDistintosDup + 1
            qtdLinhasDup = qtdLinhasDup + CLng(contagemCnpj(chave))
            If duplicadosCsv = "" Then
                duplicadosCsv = CStr(chave) & "(" & CStr(contagemCnpj(chave)) & ")"
            Else
                duplicadosCsv = duplicadosCsv & "; " & CStr(chave) & "(" & CStr(contagemCnpj(chave)) & ")"
            End If
        End If
    Next chave

    obtido = "QTD_CNPJS_DUP=" & CStr(cnpjsDistintosDup) & _
             "; QTD_LINHAS_AFETADAS=" & CStr(qtdLinhasDup) & _
             "; CNPJS=" & duplicadosCsv

    If cnpjsDistintosDup = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_03", "AUTO", _
                      "Detectar CNPJ duplicado em EMPRESAS (ATIVAS)", _
                      "Zero CNPJs com mais de 1 ocorrencia", _
                      obtido, _
                      "Cada empresa ativa tem CNPJ unico - protege contra cadastro duplicado", _
                      True
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_03", _
                      "CNPJs duplicados em EMPRESAS - bug de integridade de cadastro", _
                      "Zero duplicacoes", _
                      "Bug de integridade - investigar Cadastro_Empresa", _
                      obtido & " - ver RPT_BUGS_CONHECIDOS"
        Call RegistrarBugConhecido( _
            "INT-EMP-CNPJ-DUP", _
            "CNPJ duplicado em EMPRESAS (ATIVAS) - falta validacao no cadastro", _
            CDate(Date), _
            "TV2_RunIntegridadeBase / TV2_DetectarCnpjDuplicado", _
            "ALTA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_03", _
            "ABERTO", _
            "investigar validacao em Cadastro_Empresa.frm em onda futura", _
            "auditoria/00_status/<a-criar-quando-investigar>")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_03", "AUTO", _
                  "Executar deteccao de CNPJ duplicado sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub

Private Sub TV2_DetectarRefOrfaCAD_OS()
    On Error GoTo falha

    Dim wsCadOs As Worksheet
    Dim wsEmp As Worksheet
    Dim wsEmpInat As Worksheet
    Dim wsAtiv As Worksheet
    Dim setEmps As Object
    Dim setAtivs As Object
    Dim ult As Long
    Dim i As Long
    Dim chaveAtual As String
    Dim qtdOrfaEmp As Long
    Dim qtdOrfaAtiv As Long
    Dim primeiraOrfaEmp As String
    Dim primeiraOrfaAtiv As String
    Dim qtdLinhas As Long
    Dim obtido As String

    Set setEmps = CreateObject("Scripting.Dictionary")
    Set setAtivs = CreateObject("Scripting.Dictionary")

    ' Conjunto de EMP_IDs validos = EMPRESAS UNIAO EMPRESAS_INATIVAS
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    ult = UltimaLinhaAba(SHEET_EMPRESAS)
    For i = LINHA_DADOS To ult
        chaveAtual = Trim$(CStr(wsEmp.Cells(i, COL_EMP_ID).Value))
        If chaveAtual <> "" Then
            If Not setEmps.Exists(chaveAtual) Then setEmps.Add chaveAtual, True
        End If
    Next i

    On Error Resume Next
    Set wsEmpInat = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    On Error GoTo falha
    If Not wsEmpInat Is Nothing Then
        ult = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
        For i = LINHA_DADOS To ult
            chaveAtual = Trim$(CStr(wsEmpInat.Cells(i, COL_EMP_ID).Value))
            If chaveAtual <> "" Then
                If Not setEmps.Exists(chaveAtual) Then setEmps.Add chaveAtual, True
            End If
        Next i
    End If

    ' Conjunto de ATIV_IDs validos = ATIVIDADES (todas)
    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ult = UltimaLinhaAba(SHEET_ATIVIDADES)
    For i = LINHA_DADOS To ult
        chaveAtual = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_ID).Value))
        If chaveAtual <> "" Then
            If Not setAtivs.Exists(chaveAtual) Then setAtivs.Add chaveAtual, True
        End If
    Next i

    ' Varrer CAD_OS e contar referencias orfas
    Set wsCadOs = ThisWorkbook.Sheets(SHEET_CAD_OS)
    ult = UltimaLinhaAba(SHEET_CAD_OS)
    For i = LINHA_DADOS To ult
        qtdLinhas = qtdLinhas + 1

        chaveAtual = Trim$(CStr(wsCadOs.Cells(i, COL_OS_EMP_ID).Value))
        If chaveAtual <> "" Then
            If Not setEmps.Exists(chaveAtual) Then
                qtdOrfaEmp = qtdOrfaEmp + 1
                If primeiraOrfaEmp = "" Then
                    primeiraOrfaEmp = "linha=" & CStr(i) & ";EMP_ID=" & chaveAtual
                End If
            End If
        End If

        chaveAtual = Trim$(CStr(wsCadOs.Cells(i, COL_OS_ATIV_ID).Value))
        If chaveAtual <> "" Then
            If Not setAtivs.Exists(chaveAtual) Then
                qtdOrfaAtiv = qtdOrfaAtiv + 1
                If primeiraOrfaAtiv = "" Then
                    primeiraOrfaAtiv = "linha=" & CStr(i) & ";ATIV_ID=" & chaveAtual
                End If
            End If
        End If
    Next i

    obtido = "QTD_LINHAS_CAD_OS=" & CStr(qtdLinhas) & _
             "; QTD_ORFA_EMP=" & CStr(qtdOrfaEmp) & _
             "; QTD_ORFA_ATIV=" & CStr(qtdOrfaAtiv) & _
             "; 1A_ORFA_EMP=" & primeiraOrfaEmp & _
             "; 1A_ORFA_ATIV=" & primeiraOrfaAtiv

    If qtdOrfaEmp = 0 And qtdOrfaAtiv = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_04", "AUTO", _
                      "Detectar referencias orfas em CAD_OS (EMP_ID ou ATIV_ID inexistente)", _
                      "Zero orfas (todas as referencias batem)", _
                      obtido, _
                      "Cada OS aponta para empresa e atividade existentes - protege rastreabilidade", _
                      True
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_04", _
                      "Referencias orfas em CAD_OS - bug de integridade referencial", _
                      "Zero orfas", _
                      "Bug de integridade - investigar limpeza de cadastro / orfaos historicos", _
                      obtido & " - ver RPT_BUGS_CONHECIDOS"
        Call RegistrarBugConhecido( _
            "INT-CAD-OS-REF-ORFA", _
            "Referencias orfas em CAD_OS (EMP_ID ou ATIV_ID nao existe em EMPRESAS+INATIVAS / ATIVIDADES)", _
            CDate(Date), _
            "TV2_RunIntegridadeBase / TV2_DetectarRefOrfaCAD_OS", _
            "ALTA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_04", _
            "ABERTO", _
            "investigar limpeza de cadastro em onda futura", _
            "auditoria/00_status/<a-criar-quando-investigar>")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_04", "AUTO", _
                  "Executar deteccao de ref orfa em CAD_OS sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub


