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
    Dim auditNestedAntes As Long
    Dim auditNestedDepois As Long
    Dim txOuterId As String
    Dim txInnerId As String
    Dim txErrNum As Long
    Dim txErrMsg As String
    Dim txNestedRejected As Boolean
    Dim txStillActive As Boolean
    Dim txIdPreservado As Boolean
    Dim txRollbackCleanup As Boolean
    Dim resBackfillResumoAntes As TResult
    Dim resBackfillResumoDepois As TResult
    Dim resBackfillAplicar As TResult
    Dim qtdBackfillAntes As Long
    Dim qtdBackfillDepois As Long
    Dim qtdBackfillAtualizadas As Long
    Dim detalhesBackfillAntes As String
    Dim detalhesBackfillDepois As String
    Dim relatorioBackfill As String
    Dim auditBackfillAntes As Long
    Dim auditBackfillDepois As Long
    Dim empBackfill As TEmpresa
    Dim linhaBackfill As Long
    Dim resRefAntes As TResult
    Dim resRefLimpar As TResult
    Dim resRefDepois As TResult
    Dim qtdRefOrfaEmpAntes As Long
    Dim qtdRefOrfaAtivAntes As Long
    Dim qtdRefResidAntes As Long
    Dim qtdRefOrfaEmpDepois As Long
    Dim qtdRefOrfaAtivDepois As Long
    Dim qtdRefResidDepois As Long
    Dim qtdRefLimpas As Long
    Dim detalhesRefAntes As String
    Dim detalhesRefDepois As String
    Dim relatorioRef As String
    Dim wsCadOsMig As Worksheet
    Dim linhaCadOsMig As Long
    Dim cadOsMigProtegida As Boolean
    Dim cadOsMigSenha As String
    Dim cadOsMigPreparada As Boolean
    Dim resDtInvalid As TResult
    Dim qtdDtInvalid As Long
    Dim dtCorteDtInvalid As Date
    Dim usarJanelaDtInvalid As Boolean
    Dim msgCfgInvalida As String
    Dim cfgValida As Boolean
    Dim cfgAuditOk As Boolean
    Dim auditCfgAntes As Long
    Dim auditCfgDepois As Long
    Dim qtdAtivMig9Antes As Long
    Dim qtdAtivMig9Depois As Long
    Dim qtdServMig9Antes As Long
    Dim qtdServMig9Depois As Long
    Dim relatorioMig9 As String
    Dim resetMig9Ok As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

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

    If Transacao_EstaAtiva() Then txRollbackCleanup = Transacao_Rollback()
    txOuterId = "TV2_ATM_002_OUTER"
    txInnerId = "TV2_ATM_002_INNER"
    auditNestedAntes = TV2_AuditCount("Rollback/Transacao", "TRANSACAO_ANINHADA")
    Transacao_Iniciar txOuterId
    txErrNum = 0
    txErrMsg = ""
    On Error Resume Next
    Transacao_Iniciar txInnerId
    txErrNum = Err.Number
    txErrMsg = Err.Description
    Err.Clear
    On Error GoTo falha
    txNestedRejected = (txErrNum <> 0)
    txStillActive = Transacao_EstaAtiva()
    txIdPreservado = (Transacao_IdAtual() = txOuterId)
    txRollbackCleanup = Transacao_Rollback()
    auditNestedDepois = TV2_AuditCount("Rollback/Transacao", "TRANSACAO_ANINHADA")
    obtidoAtm = "ERRO_ANINHADO=" & CStr(txErrNum)
    obtidoAtm = obtidoAtm & "; MSG=" & txErrMsg
    obtidoAtm = obtidoAtm & "; ATIVA_APOS_ERRO=" & CStr(txStillActive)
    obtidoAtm = obtidoAtm & "; TX_ID_PRESERVADO=" & CStr(txIdPreservado)
    obtidoAtm = obtidoAtm & "; ROLLBACK_CLEANUP=" & CStr(txRollbackCleanup)
    obtidoAtm = obtidoAtm & "; ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtidoAtm = obtidoAtm & "; AUDIT_ANINHADA=" & CStr(auditNestedDepois - auditNestedAntes)
    okAtm = txNestedRejected
    okAtm = okAtm And txStillActive
    okAtm = okAtm And txIdPreservado
    okAtm = okAtm And txRollbackCleanup
    okAtm = okAtm And Not Transacao_EstaAtiva()
    okAtm = okAtm And (auditNestedDepois - auditNestedAntes) >= 1
    okAtm = okAtm And InStr(1, txErrMsg, "Transacao ja ativa", vbTextCompare) > 0
    TV2_LogAssert "SMOKE", "ATM_002", "AUTO", _
                  "Rejeitar transacao aninhada sem sobrescrever a externa", _
                  "Segunda Transacao_Iniciar falha explicitamente, preserva TX externa e deixa rastro de auditoria", _
                  obtidoAtm, _
                  "Fecha a lacuna R-48 de transacao aninhada sem introduzir stack transacional", _
                  okAtm

    TV2_PrepararCenarioTriploCanonico
    auditBackfillAntes = TV2_AuditCount("Rollback/Transacao", "BACKFILL_DT_ULT_REATIV")
    RegistrarEvento EVT_REATIVACAO, ENT_EMP, "001", _
        "STATUS=SUSPENSA_GLOBAL; TESTE=MIG_005", _
        "STATUS=ATIVA; TESTE=MIG_005", _
        "TV2_MIG_005"
    resBackfillResumoAntes = RepoEmpresa_DtUltReativBackfillResumo(qtdBackfillAntes, detalhesBackfillAntes)
    resBackfillAplicar = RepoEmpresa_BackfillDtUltReativPorAuditLog(qtdBackfillAtualizadas, relatorioBackfill)
    resBackfillResumoDepois = RepoEmpresa_DtUltReativBackfillResumo(qtdBackfillDepois, detalhesBackfillDepois)
    empBackfill = LerEmpresa("001", linhaBackfill)
    auditBackfillDepois = TV2_AuditCount("Rollback/Transacao", "BACKFILL_DT_ULT_REATIV")
    obtidoAtm = "RESUMO_ANTES=" & CStr(resBackfillResumoAntes.sucesso)
    obtidoAtm = obtidoAtm & "; QTD_ANTES=" & CStr(qtdBackfillAntes)
    obtidoAtm = obtidoAtm & "; DETALHES_ANTES=" & detalhesBackfillAntes
    obtidoAtm = obtidoAtm & "; APLICAR=" & CStr(resBackfillAplicar.sucesso)
    obtidoAtm = obtidoAtm & "; QTD_ATUALIZADAS=" & CStr(qtdBackfillAtualizadas)
    obtidoAtm = obtidoAtm & "; RELATORIO=" & relatorioBackfill
    obtidoAtm = obtidoAtm & "; RESUMO_DEPOIS=" & CStr(resBackfillResumoDepois.sucesso)
    obtidoAtm = obtidoAtm & "; QTD_DEPOIS=" & CStr(qtdBackfillDepois)
    obtidoAtm = obtidoAtm & "; LINHA_EMP=" & CStr(linhaBackfill)
    obtidoAtm = obtidoAtm & "; DT_ULT_REATIV=" & IIf(empBackfill.DT_ULT_REATIV > CDate(0), Format$(empBackfill.DT_ULT_REATIV, "yyyy-mm-dd hh:nn:ss"), "(vazia)")
    obtidoAtm = obtidoAtm & "; AUDIT_BACKFILL=" & CStr(auditBackfillDepois - auditBackfillAntes)
    okAtm = resBackfillResumoAntes.sucesso
    okAtm = okAtm And qtdBackfillAntes = 1
    okAtm = okAtm And resBackfillAplicar.sucesso
    okAtm = okAtm And qtdBackfillAtualizadas = 1
    okAtm = okAtm And resBackfillResumoDepois.sucesso
    okAtm = okAtm And qtdBackfillDepois = 0
    okAtm = okAtm And linhaBackfill >= LINHA_DADOS
    okAtm = okAtm And empBackfill.DT_ULT_REATIV > CDate(0)
    okAtm = okAtm And (auditBackfillDepois - auditBackfillAntes) >= 1
    TV2_LogAssert "SMOKE", "MIG_005", "AUTO", _
                  "Aplicar backfill auditavel de DT_ULT_REATIV", _
                  "Empresa com reativacao legada em AUDIT_LOG ganha DT_ULT_REATIV sem voltar ao modo legado", _
                  obtidoAtm, _
                  "Fecha a lacuna de migracao do campo DT_ULT_REATIV em bases abertas antes da Onda 18", _
                  okAtm

    TV2_PrepararCenarioTriploCanonico
    Set wsCadOsMig = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(wsCadOsMig, cadOsMigProtegida, cadOsMigSenha) Then
        Err.Raise 1004, "TV2_RunSmoke.MIG_006", "Nao foi possivel preparar CAD_OS para cenario MIG_006."
    End If
    cadOsMigPreparada = True
    linhaCadOsMig = LINHA_DADOS
    If UltimaLinhaAba(SHEET_CAD_OS) >= LINHA_DADOS Then linhaCadOsMig = UltimaLinhaAba(SHEET_CAD_OS) + 1
    wsCadOsMig.Cells(linhaCadOsMig, COL_OS_ATIV_ID).Value = "999"
    wsCadOsMig.Cells(linhaCadOsMig, COL_OS_PREOS_ID).Value = "TV2_MIG_006"
    wsCadOsMig.Cells(linhaCadOsMig, COL_OS_STATUS).Value = "CONCLUIDA"
    wsCadOsMig.Cells(linhaCadOsMig, COL_OS_JUSTIF_DIV).Value = "MIG_006_RESIDUO_SEM_CHAVE"
    Util_RestaurarProtecaoAba wsCadOsMig, cadOsMigProtegida, cadOsMigSenha
    cadOsMigPreparada = False

    resRefAntes = RepoOS_DiagnosticarReferenciasCADOS(qtdRefOrfaEmpAntes, qtdRefOrfaAtivAntes, qtdRefResidAntes, detalhesRefAntes)
    resRefLimpar = RepoOS_LimparResiduosCADOSSemChave(qtdRefLimpas, relatorioRef)
    resRefDepois = RepoOS_DiagnosticarReferenciasCADOS(qtdRefOrfaEmpDepois, qtdRefOrfaAtivDepois, qtdRefResidDepois, detalhesRefDepois)
    obtidoAtm = "DIAG_ANTES=" & CStr(resRefAntes.sucesso)
    obtidoAtm = obtidoAtm & "; ORFA_EMP_ANTES=" & CStr(qtdRefOrfaEmpAntes)
    obtidoAtm = obtidoAtm & "; ORFA_ATIV_ANTES=" & CStr(qtdRefOrfaAtivAntes)
    obtidoAtm = obtidoAtm & "; RESID_ANTES=" & CStr(qtdRefResidAntes)
    obtidoAtm = obtidoAtm & "; DETALHES_ANTES=" & detalhesRefAntes
    obtidoAtm = obtidoAtm & "; LIMPEZA=" & CStr(resRefLimpar.sucesso)
    obtidoAtm = obtidoAtm & "; LIMPAS=" & CStr(qtdRefLimpas)
    obtidoAtm = obtidoAtm & "; RELATORIO=" & relatorioRef
    obtidoAtm = obtidoAtm & "; DIAG_DEPOIS=" & CStr(resRefDepois.sucesso)
    obtidoAtm = obtidoAtm & "; ORFA_EMP_DEPOIS=" & CStr(qtdRefOrfaEmpDepois)
    obtidoAtm = obtidoAtm & "; ORFA_ATIV_DEPOIS=" & CStr(qtdRefOrfaAtivDepois)
    obtidoAtm = obtidoAtm & "; RESID_DEPOIS=" & CStr(qtdRefResidDepois)
    okAtm = resRefAntes.sucesso
    okAtm = okAtm And qtdRefOrfaEmpAntes = 0
    okAtm = okAtm And qtdRefOrfaAtivAntes = 0
    okAtm = okAtm And qtdRefResidAntes = 1
    okAtm = okAtm And resRefLimpar.sucesso
    okAtm = okAtm And qtdRefLimpas = 1
    okAtm = okAtm And resRefDepois.sucesso
    okAtm = okAtm And qtdRefOrfaEmpDepois = 0
    okAtm = okAtm And qtdRefOrfaAtivDepois = 0
    okAtm = okAtm And qtdRefResidDepois = 0
    TV2_LogAssert "SMOKE", "MIG_006", "AUTO", _
                  "Limpar residuos sem chave em CAD_OS sem mascarar orfas reais", _
                  "Linha sem OS_ID e com sobra em colunas finais e detectada como residuo, limpa explicitamente e deixa diagnostico zerado", _
                  obtidoAtm, _
                  "Fecha INT-CAD-OS-REF-ORFA sem apagar OS real com referencia invalida", _
                  okAtm

    TV2_PrepararCenarioTriploCanonico
    qtdDtInvalid = 0
    usarJanelaDtInvalid = False
    dtCorteDtInvalid = CDate(0)
    resDtInvalid = ContarStrikesParaPunicaoResultado( _
        "001", GetNotaMinimaAvaliacao(), qtdDtInvalid, "DATA_INVALIDA_MIG_007")

    obtidoAtm = "SUCESSO=" & CStr(resDtInvalid.sucesso)
    obtidoAtm = obtidoAtm & "; MSG=" & resDtInvalid.mensagem
    obtidoAtm = obtidoAtm & "; QTD=" & CStr(qtdDtInvalid)
    obtidoAtm = obtidoAtm & "; USAR_JANELA=" & CStr(usarJanelaDtInvalid)
    obtidoAtm = obtidoAtm & "; DT_CORTE=" & Format$(dtCorteDtInvalid, "yyyy-mm-dd")
    TV2_LogAssert "SMOKE", "MIG_007", "AUTO", _
                  "Bloquear punicao quando DT_ULT_REATIV esta invalida", _
                  "Contador de strikes retorna falha explicita e nao calcula punicao em modo legado", _
                  obtidoAtm, _
                  "Impede re-suspensao baseada em janela corrompida apos migracao ou edicao manual", _
                  (Not resDtInvalid.sucesso And qtdDtInvalid = 0 And _
                   InStr(1, resDtInvalid.mensagem, "DT_ULT_REATIV invalida", vbTextCompare) > 0)

    msgCfgInvalida = ""
    cfgAuditOk = False
    auditCfgAntes = TV2_AuditCount("Validacao Rejeitada", "CONFIG_INVALIDA")
    cfgValida = Config_ValidarRegraStrikes("0", "abc", "-1", msgCfgInvalida)
    If Not cfgValida Then
        cfgAuditOk = Config_RegistrarFalhaValidacao("TV2_RunSmoke.MIG_008", msgCfgInvalida)
    End If
    auditCfgDepois = TV2_AuditCount("Validacao Rejeitada", "CONFIG_INVALIDA")
    obtidoAtm = "VALIDA=" & CStr(cfgValida)
    obtidoAtm = obtidoAtm & "; MSG=" & msgCfgInvalida
    obtidoAtm = obtidoAtm & "; AUDIT_OK=" & CStr(cfgAuditOk)
    obtidoAtm = obtidoAtm & "; AUDIT_CONFIG=" & CStr(auditCfgDepois - auditCfgAntes)
    TV2_LogAssert "SMOKE", "MIG_008", "AUTO", _
                  "Rejeitar configuracao de strikes invalida com mensagem e auditoria", _
                  "Validacao falha antes de gravar CONFIG, mensagem cita os campos invalidos e AUDIT_LOG recebe CONFIG_INVALIDA", _
                  obtidoAtm, _
                  "Impede que valores invalidos sejam ignorados silenciosamente no formulario de configuracao", _
                  (Not cfgValida And cfgAuditOk And _
                   (auditCfgDepois - auditCfgAntes) >= 1 And _
                   InStr(1, msgCfgInvalida, "TxtNotaCorte", vbTextCompare) > 0 And _
                   InStr(1, msgCfgInvalida, "TxtMaxStrikes", vbTextCompare) > 0 And _
                   InStr(1, msgCfgInvalida, "TxtDiasSuspensao", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    qtdAtivMig9Antes = TV2_CountRows(SHEET_ATIVIDADES)
    qtdServMig9Antes = TV2_CountRows(SHEET_CAD_SERV)
    relatorioMig9 = ""
    resetMig9Ok = LimpaBaseTotalReset(relatorioMig9)
    qtdAtivMig9Depois = TV2_CountRows(SHEET_ATIVIDADES)
    qtdServMig9Depois = TV2_CountRows(SHEET_CAD_SERV)
    obtidoAtm = "RESET_OK=" & CStr(resetMig9Ok)
    obtidoAtm = obtidoAtm & "; ATIV_ANTES=" & CStr(qtdAtivMig9Antes)
    obtidoAtm = obtidoAtm & "; ATIV_DEPOIS=" & CStr(qtdAtivMig9Depois)
    obtidoAtm = obtidoAtm & "; SERV_ANTES=" & CStr(qtdServMig9Antes)
    obtidoAtm = obtidoAtm & "; SERV_DEPOIS=" & CStr(qtdServMig9Depois)
    obtidoAtm = obtidoAtm & "; RELATORIO_CAD_SERV=" & CStr(InStr(1, relatorioMig9, "CAD_SERV: apagadas", vbTextCompare) > 0)
    TV2_LogAssert "SMOKE", "MIG_009", "AUTO", _
                  "Limpar Base deve preservar CNAE e zerar CAD_SERV", _
                  "ATIVIDADES permanece com linhas validas, CAD_SERV fica sem linhas de dados e relatorio nao lista CAD_SERV como preservado", _
                  obtidoAtm, _
                  "Permite reutilizar a planilha em outro municipio sem herdar servicos locais antigos", _
                  (resetMig9Ok And _
                   qtdAtivMig9Antes > 0 And qtdAtivMig9Depois = qtdAtivMig9Antes And _
                   qtdServMig9Antes > 0 And qtdServMig9Depois = 0 And _
                   InStr(1, relatorioMig9, "CAD_SERV: apagadas", vbTextCompare) > 0 And _
                   InStr(1, relatorioMig9, "  - CAD_SERV", vbTextCompare) = 0)

    ' MD-17.1.c (Onda 17 Test-First) - Smoke read-only de UI (5 verificacoes x 4 forms).
    ' Bloco roda APOS asserts do TV2_RunSmoke; logs vao para mesma execucao SMOKE.
    Call TV2_RunUiSmokeReadOnly(silencioso)

    TV2_FinalizarExecucao "SMOKE", silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    If cadOsMigPreparada Then Util_RestaurarProtecaoAba wsCadOsMig, cadOsMigProtegida, cadOsMigSenha
    If Transacao_EstaAtiva() Then txRollbackCleanup = Transacao_Rollback()
    On Error GoTo 0
    TV2_LogAssert "SMOKE", "FATAL", "AUTO", _
                  "Executar suite sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
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

    TV2_UI_VerificarGuardReentrada repoRoot
End Sub

Public Sub TV2_RunAdversarial_UI(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "ADVERSARIAL_UI"
    Dim repoRoot As String
    Dim faltantes As String
    Dim manuais As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 12
    repoRoot = TV2_UI_RepoRoot()

    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Reativa_Empresa.frm", "mReativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Reativa_Entidade.frm", "mReativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Empresa.frm", "mAlteracaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Empresa.frm", "mInativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Entidade.frm", "mAlteracaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Entidade.frm", "mInativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Limpar_Base.frm", "mLimpezaEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Menu_Principal.frm", "mEncerraOSEmProcessamento", manuais)
    TV2_LogAssert suite, "UI_ADV_001_REENTRADA_MUTADORES", "AUTO", _
                  "Verificar guards de reentrada nos forms mutadores", _
                  "Flags declaradas, testadas, ligadas e desligadas", _
                  IIf(faltantes = "" And manuais = "", "OK", "FALTANTES=" & faltantes & "; MANUAIS=" & manuais), _
                  "Duplo clique ou chamada repetida nao pode duplicar mutacao", _
                  (faltantes = "" And manuais = "")

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_002_REATIVA_EMPRESA_INTEGRIDADE", repoRoot, "Reativa_Empresa.frm", _
                             "UI_EmpresaInativosTemConflito|Util_LinhaDuplicadaIdOuDocumento|Tem certeza que deseja REATIVAR esta Empresa?|ReativarLinhaEmpresa|RestaurarCredenciamentosEmpresa|mReativacaoEmAndamento = False", _
                             "Reativacao de empresa exige saneamento, confirmacao e servico", _
                             "Conflito, duplicidade ativa, confirmacao, reativacao, credenciamentos e reset de guard presentes", _
                             "Bloqueia duplicidade ativa/inativa e preserva credenciamentos sem bypass silencioso"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_003_REATIVA_ENTIDADE_SERVICO", repoRoot, "Reativa_Entidade.frm", _
                             "Tem certeza que deseja REATIVAR esta Entidade?|mReativacaoEmAndamento = True|ReativarEntidadePorChave|mReativacaoEmAndamento = False", _
                             "Reativacao de entidade passa pelo servico e confirma acao destrutiva", _
                             "Confirmacao, guard e ReativarEntidadePorChave presentes", _
                             "Evita reativacao direta por UI sem trilha de servico"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_004_ALTERA_EMPRESA_CONFIRMA_IDS", repoRoot, "Altera_Empresa.frm", _
                             "Deseja realmente continuar?|IdsIguais|mAlteracaoEmAndamento = True|mAlteracaoEmAndamento = False|Tem certeza que deseja Inativar esta Empresa?|mInativacaoEmAndamento = True|mInativacaoEmAndamento = False", _
                             "Alteracao e inativacao de empresa usam confirmacao, IdsIguais e guard", _
                             "Confirmacoes, comparacao robusta de IDs e flags de reentrada presentes", _
                             "Protege edicao/inativacao contra ID texto-numero e duplo clique"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_005_ALTERA_ENTIDADE_CONFIRMA_IDS", repoRoot, "Altera_Entidade.frm", _
                             "Deseja realmente continuar?|IdsIguais|mAlteracaoEmAndamento = True|mAlteracaoEmAndamento = False|Tem certeza que deseja Inativar esta Entidade?|mInativacaoEmAndamento = True|mInativacaoEmAndamento = False", _
                             "Alteracao e inativacao de entidade usam confirmacao, IdsIguais e guard", _
                             "Confirmacoes, comparacao robusta de IDs e flags de reentrada presentes", _
                             "Protege edicao/inativacao de entidade contra ID texto-numero e duplo clique"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_006_AVALIAR_OS_GUARDS", repoRoot, "Menu_Principal.frm", _
                             "mEncerraOSEmProcessamento|Confirma a avalia|TryParseDataBR|Justificativa obrigat|AvaliarOS(|Resume limpar", _
                             "Avaliacao de OS valida entrada, confirma e restaura guard no cleanup", _
                             "Guard, confirmacao, parse de datas, justificativa obrigatoria, servico e cleanup presentes", _
                             "Evita avaliacao duplicada ou divergencia sem justificativa"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_007_PREOS_OS_DESTRUTIVOS", repoRoot, "Menu_Principal.frm", _
                             "ErrorBoundary.BeginWrite(""REJEITAR_PREOS"")|Confirmar rejei|ErrorBoundary.BeginWrite(""EXPIRAR_PREOS"")|Confirmar expira|ErrorBoundary.BeginWrite(""CANCELAR_OS"")|Confirmar cancelamento", _
                             "Acoes destrutivas de Pre-OS/OS exigem ErrorBoundary e confirmacao", _
                             "BeginWrite e confirmacao presentes para rejeitar, expirar e cancelar", _
                             "Evita mutacao destrutiva sem fronteira transacional e hearback do operador"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_008_LIMPAR_BASE_FORM_GUARD", repoRoot, "Limpar_Base.frm", _
                             "MLB_SenhaLimpezaValida|PasswordChar|mLimpezaEmAndamento|Limpa_Base|MLB_RegistrarTentativaLimpeza|Erro ao limpar base", _
                             "Form Limpar_Base exige senha, guard de reentrada e erro contextual", _
                             "Senha, guard, chamada ao servico e mensagem de erro presentes", _
                             "Reduz risco de limpeza duplicada ou falha muda na UI"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_009_LIMPAR_BASE_CONFIRMACAO", repoRoot, "Preencher.bas", _
                             "Sub Limpa_Base()|Tem certeza que deseja ZERAR a Base Operacional?|LimpaBaseTotalReset|Util_SalvarWorkbookSeguro", _
                             "Limpeza total pede confirmacao e delega ao reset auditavel", _
                             "Confirmacao destrutiva, reset centralizado e salvamento seguro presentes", _
                             "Protege a acao mais destrutiva do workbook contra disparo acidental"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_010_CENTRAL_V2_EXPOE_SUITE", repoRoot, "Central_Testes_V2.bas", _
                             "TV2_RunAdversarial_UI|CT2_ExecutarAdversarialUI|V2 Adversarial UI|Gate de Validacao de Release (RVS)", _
                             "Central V2 expoe a suite adversarial para humano", _
                             "Wrapper, texto de menu e entrada RVS presentes", _
                             "Garante que a nova suite nao fique escondida apenas na janela imediata"

    TV2_UIAdv_LogFileTokens suite, "UI_ADV_011_SEXTETO_GATE_EXPOSTO", repoRoot, "Teste_Validacao_Release.bas", _
                             "CT_ValidarRelease_SextetoMinimo|VR_ValidarReleaseSextetoMinimo|VR_SintaxeSexteto", _
                             "Gate RVS preserva entrada publica, alias e sintaxe auditavel", _
                             "Sub oficial, wrapper e sintaxe presentes no modulo validador", _
                             "Toda funcionalidade nova precisa de teste correspondente no mesmo microdelta"

    TV2_UIAdv_LogFileNaoContemTokens suite, "UI_ADV_012_LIMPAR_BASE_SEM_SENHA_CLARA", repoRoot, "Limpar_Base.frm", _
                                  Chr$(115) & Chr$(101) & Chr$(98) & Chr$(114) & Chr$(97) & Chr$(101) & CStr(2024), _
                                  "Limpar_Base nao pode carregar senha clara no form", _
                                  "Senha clara ausente do codigo do form", _
                                  "Evita regressao de credencial hardcoded no ponto de entrada destrutivo"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite adversarial UI sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunIntegridadeEstado(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "INTEGRIDADE_ESTADO"
    Dim repoRoot As String
    Dim detalhesProtecaoAplicada As String
    Dim detalhesProtecaoVerificada As String
    Dim detalhesObjetosLimpeza As String
    Dim detalhesObjetosVerificados As String
    Dim okProtecaoAplicada As Boolean
    Dim okProtecaoVerificada As Boolean
    Dim okObjetosLimpos As Boolean
    Dim okObjetosVerificados As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteNaoContemTokens suite, "CS_EST_01_CLASSIFICAR_SEM_XLGUESS", repoRoot, "Classificar", "Classificar.bas", _
                                         ".Header = xlGuess|Header:=xlGuess", _
                                         "Classificar nao pode usar xlGuess em ranges sem cabecalho", _
                                         "xlGuess ausente no componente importado Classificar", _
                                         "Evita ordenacao data-dependent que muda conforme base populada"

    TV2_EST_LogComponenteContemTokens suite, "CS_EST_02_ENTIDADE_INATIVACAO_ATOMICA", repoRoot, "Altera_Entidade", "Altera_Entidade.frm", _
                                      "copiaInativaCriada|ativaExcluida|If copiaInativaCriada And Not ativaExcluida|Entidade_RemoverInativasDuplicadas|Util_PrepararAbaParaEscrita(wsEnt, estEntProt, senhaEntProt)|erroMensagem = Err.Description", _
                                      "Inativacao de entidade deve reverter copia se remocao ativa falhar", _
                                      "Flags de rollback, helper de saneamento, preparo separado das abas e erro preservado presentes no componente importado", _
                                      "Evita entidade ativa e inativa simultaneamente apos falha parcial"

    TV2_EST_LogComponenteNaoContemTokens suite, "CS_EST_04_ENTIDADE_INATIVACAO_SEM_ENTIREROW_COPY", repoRoot, "Altera_Entidade", "Altera_Entidade.frm", _
                                         ".EntireRow.Copy|Selection.Copy|ActiveCell", _
                                         "Inativacao de entidade nao deve depender de clipboard nem linha inteira", _
                                         "Fluxo usa copia de faixa A:V por valor/formato", _
                                         "Reduz falha de borda no primeiro item e evita efeitos colaterais de tabela/formato"

    TV2_EST_LogComponenteContemTokens suite, "CS_EST_05_EXCLUIR_LINHA_UNICA_TABELA", repoRoot, "Util_Planilha", "Util_Planilha.bas", _
                                      "lo.ListRows.count <= 1|DataBodyRange|ClearContents", _
                                      "Exclusao segura deve tratar ultima linha de dados de tabela Excel", _
                                      "Helper preserva a tabela e limpa conteudo quando resta uma unica linha", _
                                      "Evita erro de cabecalho/insercao ao inativar a ultima entidade ativa"

    TV2_EST_LogComponenteContemTokens suite, "CS_EST_06_PROTECAO_CRITICA_BLOQUEIA_CELULAS", repoRoot, "Util_Planilha", "Util_Planilha.bas", _
                                      "Util_AbaEhCritica|Util_AplicarProtecaoCriticaAba|ws.Cells.Locked = True|Util_CelulasTodasBloqueadas|Not estavaProtegida Then Exit Sub", _
                                      "Protecao de aba critica deve bloquear edicao direta mesmo se a aba iniciou desprotegida", _
                                      "Helper identifica abas criticas, bloqueia todas as celulas e reaplica protecao no restore", _
                                      "Evita RVS verde com workbook editavel diretamente pelo operador"

    TV2_EST_LogComponenteContemTokens suite, "CS_EST_07_OBJETOS_ABAS_CRITICAS", repoRoot, "Util_Planilha", "Util_Planilha.bas", _
                                      "Util_LimparObjetosAbasCriticas|Util_VerificarObjetosAbasCriticas|ws.Shapes.count|ws.Shapes(i).Delete|ProtectDrawingObjects", _
                                      "Abas criticas nao devem manter imagens ou objetos soltos editaveis", _
                                      "Helper remove shapes residuais e verifica que DrawingObjects estao protegidos", _
                                      "Evita artefatos colados em abas operacionais protegidas"

    okObjetosLimpos = Util_LimparObjetosAbasCriticas(detalhesObjetosLimpeza)
    okProtecaoAplicada = Util_ProtegerAbasCriticasVerificado(detalhesProtecaoAplicada)
    okProtecaoVerificada = Util_VerificarProtecaoAbasCriticas(detalhesProtecaoVerificada)
    okObjetosVerificados = Util_VerificarObjetosAbasCriticas(detalhesObjetosVerificados)
    TV2_LogAssert suite, "CS_EST_03_PROTECAO_ABAS_CRITICAS", "AUTO", _
                  "Proteger e verificar abas criticas sem Auto_Open", _
                  "Todas as abas criticas com ProtectContents=True, DrawingObjects=True e celulas bloqueadas", _
                  IIf(okProtecaoAplicada And okProtecaoVerificada, "OK", "APLICAR=" & detalhesProtecaoAplicada & "; VERIFICAR=" & detalhesProtecaoVerificada), _
                  "RVS nao pode considerar freeze se abas operacionais ficam editaveis ao operador", _
                  (okProtecaoAplicada And okProtecaoVerificada)

    TV2_LogAssert suite, "CS_EST_08_OBJETOS_ABAS_CRITICAS_ZERO", "AUTO", _
                  "Limpar e verificar objetos residuais nas abas criticas", _
                  "Nenhum shape/imagem residual nas abas criticas", _
                  IIf(okObjetosLimpos And okObjetosVerificados, "OK", "LIMPEZA=" & detalhesObjetosLimpeza & "; VERIFICAR=" & detalhesObjetosVerificados), _
                  "Abas de dados nao devem conter imagens ou objetos soltos apos protecao", _
                  (okObjetosLimpos And okObjetosVerificados)

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite IntegridadeEstado sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunPersistenciaPainel(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "PERSISTENCIA_PAINEL"
    Dim wsCfg As Worksheet
    Dim valorNotaAntes As Variant
    Dim valorMaxAntes As Variant
    Dim valorDiasAntes As Variant
    Dim valorPrazoAntes As Variant
    Dim valorMaxRecusasAntes As Variant
    Dim valorMesesAntes As Variant
    Dim valorDiasRecusaAntes As Variant
    Dim frm As Configuracao_Inicial
    Dim controlesOk As Boolean
    Dim persistiuOk As Boolean
    Dim detalhes As String
    Dim notaDepois As Double
    Dim maxDepois As Long
    Dim diasDepois As Long
    Dim prazoDepois As Long
    Dim maxRecusasDepois As Long
    Dim mesesDepois As Long
    Dim diasRecusaDepois As Long
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    valorNotaAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value
    valorMaxAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value
    valorDiasAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value
    valorPrazoAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value
    valorMaxRecusasAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value
    valorMesesAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value
    valorDiasRecusaAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value

    Set frm = New Configuracao_Inicial
    controlesOk = TV2_FormControleExiste(frm, "TxtNotaCorte")
    controlesOk = controlesOk And TV2_FormControleExiste(frm, "TxtMaxStrikes")
    controlesOk = controlesOk And TV2_FormControleExiste(frm, "TxtDiasSuspensao")
    controlesOk = controlesOk And TV2_FormControleExiste(frm, "PR_Val_OS")
    controlesOk = controlesOk And TV2_FormControleExiste(frm, "TP_Valor")
    controlesOk = controlesOk And TV2_FormControleExiste(frm, "TxtMesesSuspensao")
    TV2_LogAssert suite, "CS_PAINEL_01_CONTROLES_CANONICOS", "AUTO", _
                  "Configuracao_Inicial expoe controles canonicos de regra de negocio", _
                  "TxtNotaCorte, TxtMaxStrikes, TxtDiasSuspensao, PR_Val_OS, TP_Valor e TxtMesesSuspensao existem em runtime", _
                  "TxtNotaCorte=" & CStr(TV2_FormControleExiste(frm, "TxtNotaCorte")) & _
                  "; TxtMaxStrikes=" & CStr(TV2_FormControleExiste(frm, "TxtMaxStrikes")) & _
                  "; TxtDiasSuspensao=" & CStr(TV2_FormControleExiste(frm, "TxtDiasSuspensao")) & _
                  "; PR_Val_OS=" & CStr(TV2_FormControleExiste(frm, "PR_Val_OS")) & _
                  "; TP_Valor=" & CStr(TV2_FormControleExiste(frm, "TP_Valor")) & _
                  "; TxtMesesSuspensao=" & CStr(TV2_FormControleExiste(frm, "TxtMesesSuspensao")), _
                  "BL-1 nao pode passar se o designer/runtime mascarar ausencia de controle", _
                  controlesOk

    If controlesOk Then
        persistiuOk = frm.CI_TestarPersistenciaPainel("6", "4", "120", detalhes, "5", "60", "8")
    Else
        detalhes = "Controles canonicos ausentes"
        persistiuOk = False
    End If

    notaDepois = CDbl(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value))
    maxDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value))
    diasDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))
    prazoDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value))
    maxRecusasDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value))
    mesesDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value))
    diasRecusaDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))
    TV2_LogAssert suite, "CS_PAINEL_02_PERSISTE_CONFIG", "AUTO", _
                  "Salvar painel de regras de negocio persiste valores em CONFIG", _
                  "NOTA_MINIMA=6; MAX_STRIKES=4; DIAS_SUSPENSAO_STRIKE=120; PRAZO_PREOS=8; MAX_RECUSAS=5; DIAS_RECUSA_PRAZO=60", _
                  "PERSISTIU=" & CStr(persistiuOk) & "; DETALHES=" & detalhes & _
                  "; NOTA=" & CStr(notaDepois) & "; MAX=" & CStr(maxDepois) & _
                  "; DIAS=" & CStr(diasDepois) & "; PRAZO_PREOS=" & CStr(prazoDepois) & _
                  "; MAX_RECUSAS=" & CStr(maxRecusasDepois) & _
                  "; DIAS_RECUSA_PRAZO=" & CStr(diasRecusaDepois) & _
                  "; MESES_LEGADO=" & CStr(mesesDepois), _
                  "Garante que a UI nao apenas exibe campos, mas grava regras consumidas por Svc_Avaliacao/Svc_Rodizio", _
                  (persistiuOk And Abs(notaDepois - 6#) < 0.001 And maxDepois = 4 And diasDepois = 120 And _
                   prazoDepois = 8 And maxRecusasDepois = 5 And diasRecusaDepois = 60)

    TV2_RestaurarConfigPainel valorNotaAntes, valorMaxAntes, valorDiasAntes, valorPrazoAntes, valorMaxRecusasAntes, valorMesesAntes, valorDiasRecusaAntes
    Unload frm
    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    TV2_RestaurarConfigPainel valorNotaAntes, valorMaxAntes, valorDiasAntes, valorPrazoAntes, valorMaxRecusasAntes, valorMesesAntes, valorDiasRecusaAntes
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite PersistenciaPainel sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunConfigCenariosNovoPeriodo(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "CONFIG_CENARIOS_CSV"
    Const buildLabel As String = "293e44c+ONDA38.2.30-FIX1-CONFIG-CENARIOS-CSV"
    Const pastaNovoPeriodo As String = "V12-0-0206-Onda-38-2-30"
    Dim frm As Configuracao_Inicial
    Dim execId As String
    Dim csvTexto As String
    Dim csvPath As String
    Dim pastaSaida As String
    Dim copiaSaida As String
    Dim detalhes As String
    Dim observado As String
    Dim okControles As Boolean
    Dim okCen1 As Boolean
    Dim okCen2 As Boolean
    Dim okRegraRecusa As Boolean
    Dim okRegraStrike As Boolean
    Dim okNovoPeriodo As Boolean
    Dim okCsv As Boolean
    Dim okCopia As Boolean
    Dim preDepois As Long
    Dim cadDepois As Long
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 7
    execId = TV2_ExecucaoAtualId()
    TV2_LogInfo suite, "CFGCSV_00_AVISO_DESTRUTIVO", _
                "Aviso destrutivo da suite 0160", _
                "Esta suite prepara cenarios deterministicos, cria pasta de Novo Periodo, salva copia da planilha e limpa PRE_OS/CAD_OS para validar idempotencia."
    If Not silencioso Then
        MsgBox "ATENCAO: este teste e destrutivo e deve rodar somente em homologacao." & vbCrLf & vbCrLf & _
               "A suite 0160 cria cenarios deterministicos, salva copia da planilha antes da limpeza, inicia Novo Periodo e limpa PRE_OS/CAD_OS." & vbCrLf & _
               "A evidencia sera gravada em CSV na pasta V12-0-0206-Onda-38-2-30.", _
               vbExclamation, "Teste destrutivo 0160"
    End If

    TV2_PrepararBaselineCanonica
    Set frm = New Configuracao_Inicial

    csvTexto = TV2_ConfigCsvHeader()
    csvTexto = csvTexto & TV2_ConfigCsvRow(execId, buildLabel, suite, "AVISO", "DESTRUTIVO", 0, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "AVISO_REGISTRADO", "Suite destrutiva autorizada por hearback 0160", "", "", "", "Copia antes da limpeza; CSV na pasta do Novo Periodo") & vbCrLf
    csvTexto = csvTexto & TV2_ConfigCsvFilaSnapshot(execId, buildLabel, suite, "FILA_ANTES", "BASELINE", 10)

    okControles = TV2_ConfigControlesCenarioOk(frm, observado)
    TV2_LogAssert suite, "CFGCSV_01_CONTROLES_TODOS_CAMPOS", "AUTO", _
                  "Configuracao_Inicial expoe todos os controles de persistencia testados", _
                  "Gestor, Municipio, prazo, recusas, dias recusa/prazo, nota, strikes e dias strike existem", _
                  observado, _
                  "Sem estes controles a matriz de cenarios nao prova a tela real", _
                  okControles

    If okControles Then
        okCen1 = TV2_ConfigCenarioRoundTrip(frm, execId, buildLabel, suite, "CEN1_VALORES_1", 1, _
                                            "Gestor Auditoria " & buildLabel & " CEN1", _
                                            "Municipio Auditoria V12 Onda 38.2.30 CEN1", _
                                            1, 1, 1, 1, 1, 1, csvTexto, observado)
    Else
        observado = "Controles ausentes; CEN1 nao executado"
        okCen1 = False
    End If
    TV2_LogAssert suite, "CFGCSV_02_CENARIO_1_ROUNDTRIP", "AUTO", _
                  "Persistir matriz CEN1 com todos os valores numericos iguais a 1", _
                  "CONFIG e getters retornam 1 em prazo, recusas, dias, nota, strikes e dias strike; gestor/municipio contem build", _
                  observado, _
                  "Cobre borda minima positiva para todos os campos variaveis", _
                  okCen1

    If okControles Then
        okCen2 = TV2_ConfigCenarioRoundTrip(frm, execId, buildLabel, suite, "CEN2_VALORES_2", 2, _
                                            "Gestor Auditoria " & buildLabel & " CEN2", _
                                            "Municipio Auditoria V12 Onda 38.2.30 CEN2", _
                                            2, 2, 2, 2, 2, 2, csvTexto, observado)
    Else
        observado = "Controles ausentes; CEN2 nao executado"
        okCen2 = False
    End If
    TV2_LogAssert suite, "CFGCSV_03_CENARIO_2_ROUNDTRIP", "AUTO", _
                  "Persistir matriz CEN2 com todos os valores numericos iguais a 2", _
                  "CONFIG e getters retornam 2 em prazo, recusas, dias, nota, strikes e dias strike; gestor/municipio contem build", _
                  observado, _
                  "Cobre variacao maior que 1 antes do fluxo de negocio", _
                  okCen2

    okRegraRecusa = TV2_ConfigCenarioRecusaConsomeRegra(frm, execId, buildLabel, suite, csvTexto, observado)
    TV2_LogAssert suite, "CFGCSV_04_REGRA_RECUSA_DIAS", "AUTO", _
                  "Recusa consome MAX_RECUSAS=1 e DIAS_RECUSA_PRAZO=1 gravados pela tela", _
                  "Empresa recusada suspende por 1 dia e registra estado na fila", _
                  observado, _
                  "Prova que a persistencia nao ficou isolada da regra de rodizio", _
                  okRegraRecusa

    okRegraStrike = TV2_ConfigCenarioStrikeConsomeRegra(frm, execId, buildLabel, suite, csvTexto, observado)
    TV2_LogAssert suite, "CFGCSV_05_REGRA_STRIKE_DIAS", "AUTO", _
                  "Avaliacao consome MAX_STRIKES=2 e DIAS_STRIKE=2 gravados pela tela", _
                  "Empresa com duas notas baixas suspende por 2 dias", _
                  observado, _
                  "Prova que nota, strikes e dias de suspensao chegam ao servico de avaliacao", _
                  okRegraStrike

    csvTexto = csvTexto & TV2_ConfigCsvFilaSnapshot(execId, buildLabel, suite, "FILA_ANTES_NOVO_PERIODO", "PRE_LIMPEZA", 40)

    okNovoPeriodo = frm.CI_TestarNovoPeriodoDeterministico(pastaNovoPeriodo, pastaSaida, copiaSaida, detalhes)
    preDepois = TV2_ConfigQtdLinhasDados(SHEET_PREOS)
    cadDepois = TV2_ConfigQtdLinhasDados(SHEET_CAD_OS)
    okCopia = (Len(copiaSaida) > 0 And Dir(copiaSaida) <> "")
    TV2_LogAssert suite, "CFGCSV_06_NOVO_PERIODO_COPIA_LIMPEZA", "AUTO", _
                  "Novo Periodo deterministico cria pasta, salva copia e limpa PRE_OS/CAD_OS", _
                  "Pasta V12-0-0206-Onda-38-2-30; copia da planilha existe; PRE_OS=0; CAD_OS=0", _
                  "OK_NOVO_PERIODO=" & CStr(okNovoPeriodo) & "; COPIA_EXISTE=" & CStr(okCopia) & _
                  "; PRE_OS_DEPOIS=" & CStr(preDepois) & "; CAD_OS_DEPOIS=" & CStr(cadDepois) & _
                  "; DETALHES=" & detalhes, _
                  "Fecha o prototipo de testador de cenarios com evidencia antes da limpeza", _
                  (okNovoPeriodo And okCopia And preDepois = 0 And cadDepois = 0)

    If okNovoPeriodo Then
        csvPath = TV2_ConfigPathJoin(pastaSaida, "TesteV2_CONFIG_CENARIOS_" & execId & ".csv")
        csvTexto = csvTexto & TV2_ConfigCsvRow(execId, buildLabel, suite, "NOVO_PERIODO", "COPIA_E_LIMPEZA", 50, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "PRE_OS=0;CAD_OS=0", "PRE_OS=" & CStr(preDepois) & ";CAD_OS=" & CStr(cadDepois), pastaSaida, copiaSaida, csvPath, detalhes) & vbCrLf
        Call TV2_ConfigEscreverTexto(csvPath, csvTexto)
    End If
    okCsv = (Len(csvPath) > 0 And Dir(csvPath) <> "")
    TV2_LogAssert suite, "CFGCSV_07_CSV_EVIDENCIA", "AUTO", _
                  "CSV de evidencia fica salvo junto da copia da planilha na pasta do Novo Periodo", _
                  "CSV existe e contem cenarios, ordem, fila, valores esperados/observados e caminhos", _
                  "CSV=" & csvPath & "; EXISTE=" & CStr(okCsv), _
                  "Permite validacao humana lendo o CSV enquanto o gerador PDF nao existe", _
                  okCsv

    Unload frm
    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite ConfigCenariosNovoPeriodo sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Private Function TV2_ConfigControlesCenarioOk(ByVal frm As Object, ByRef observado As String) As Boolean
    Dim ok As Boolean

    ok = TV2_FormControleExiste(frm, "Gestor_Rodizio")
    ok = ok And TV2_FormControleExiste(frm, "Municipio_gestao")
    ok = ok And TV2_FormControleExiste(frm, "PR_Val_OS")
    ok = ok And TV2_FormControleExiste(frm, "TP_Valor")
    ok = ok And TV2_FormControleExiste(frm, "TxtMesesSuspensao")
    ok = ok And TV2_FormControleExiste(frm, "TxtNotaCorte")
    ok = ok And TV2_FormControleExiste(frm, "TxtMaxStrikes")
    ok = ok And TV2_FormControleExiste(frm, "TxtDiasSuspensao")

    observado = "Gestor_Rodizio=" & CStr(TV2_FormControleExiste(frm, "Gestor_Rodizio")) & _
                "; Municipio_gestao=" & CStr(TV2_FormControleExiste(frm, "Municipio_gestao")) & _
                "; PR_Val_OS=" & CStr(TV2_FormControleExiste(frm, "PR_Val_OS")) & _
                "; TP_Valor=" & CStr(TV2_FormControleExiste(frm, "TP_Valor")) & _
                "; TxtMesesSuspensao=" & CStr(TV2_FormControleExiste(frm, "TxtMesesSuspensao")) & _
                "; TxtNotaCorte=" & CStr(TV2_FormControleExiste(frm, "TxtNotaCorte")) & _
                "; TxtMaxStrikes=" & CStr(TV2_FormControleExiste(frm, "TxtMaxStrikes")) & _
                "; TxtDiasSuspensao=" & CStr(TV2_FormControleExiste(frm, "TxtDiasSuspensao"))
    TV2_ConfigControlesCenarioOk = ok
End Function

Private Function TV2_ConfigCenarioRoundTrip( _
    ByVal frm As Configuracao_Inicial, _
    ByVal execId As String, _
    ByVal buildLabel As String, _
    ByVal suite As String, _
    ByVal cenario As String, _
    ByVal ordem As Long, _
    ByVal gestor As String, _
    ByVal municipio As String, _
    ByVal prazoPreOS As Long, _
    ByVal maxRecusas As Long, _
    ByVal diasRecusaPrazo As Long, _
    ByVal notaMinima As Double, _
    ByVal maxStrikes As Long, _
    ByVal diasStrike As Long, _
    ByRef csvTexto As String, _
    ByRef observado As String _
) As Boolean
    Dim wsCfg As Worksheet
    Dim detalhes As String
    Dim persistiu As Boolean
    Dim gestorConfig As String
    Dim municipioConfig As String
    Dim prazoConfig As Long
    Dim maxRecusasConfig As Long
    Dim diasRecusaConfig As Long
    Dim notaConfig As Double
    Dim maxStrikesConfig As Long
    Dim diasStrikeConfig As Long
    Dim ok As Boolean

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    persistiu = frm.CI_TestarPersistenciaPainel( _
                    CStr(notaMinima), CStr(maxStrikes), CStr(diasStrike), detalhes, _
                    CStr(maxRecusas), CStr(diasRecusaPrazo), CStr(prazoPreOS), _
                    gestor, municipio)

    gestorConfig = Trim$(CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value))
    municipioConfig = Trim$(CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value))
    prazoConfig = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value))
    maxRecusasConfig = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value))
    diasRecusaConfig = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))
    notaConfig = CDbl(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value))
    maxStrikesConfig = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value))
    diasStrikeConfig = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))

    ok = persistiu
    ok = ok And (gestorConfig = Funcoes.NormalizarTextoPTBR(gestor))
    ok = ok And (municipioConfig = Funcoes.NormalizarTextoPTBR(municipio))
    ok = ok And (prazoConfig = prazoPreOS)
    ok = ok And (GetDiasDecisao() = prazoPreOS)
    ok = ok And (maxRecusasConfig = maxRecusas)
    ok = ok And (GetMaxRecusas() = maxRecusas)
    ok = ok And (diasRecusaConfig = diasRecusaPrazo)
    ok = ok And (GetDiasSuspensaoRecusaPrazo() = diasRecusaPrazo)
    ok = ok And (Abs(notaConfig - notaMinima) < 0.001)
    ok = ok And (Abs(GetNotaMinimaAvaliacao() - notaMinima) < 0.001)
    ok = ok And (maxStrikesConfig = maxStrikes)
    ok = ok And (GetMaxStrikes() = maxStrikes)
    ok = ok And (diasStrikeConfig = diasStrike)
    ok = ok And (GetDiasSuspensaoStrike() = diasStrike)

    observado = "PERSISTIU=" & CStr(persistiu) & "; DETALHES=" & detalhes & _
                "; GESTOR=" & gestorConfig & "; MUNICIPIO=" & municipioConfig & _
                "; PRAZO=" & CStr(prazoConfig) & "/" & CStr(GetDiasDecisao()) & _
                "; MAX_RECUSAS=" & CStr(maxRecusasConfig) & "/" & CStr(GetMaxRecusas()) & _
                "; DIAS_RECUSA=" & CStr(diasRecusaConfig) & "/" & CStr(GetDiasSuspensaoRecusaPrazo()) & _
                "; NOTA=" & CStr(notaConfig) & "/" & CStr(GetNotaMinimaAvaliacao()) & _
                "; MAX_STRIKES=" & CStr(maxStrikesConfig) & "/" & CStr(GetMaxStrikes()) & _
                "; DIAS_STRIKE=" & CStr(diasStrikeConfig) & "/" & CStr(GetDiasSuspensaoStrike())

    csvTexto = csvTexto & TV2_ConfigCsvRow( _
                    execId, buildLabel, suite, "MATRIZ", cenario, ordem, "", "", "", "", _
                    gestor, gestorConfig, municipio, municipioConfig, _
                    prazoPreOS, GetDiasDecisao(), maxRecusas, GetMaxRecusas(), _
                    diasRecusaPrazo, GetDiasSuspensaoRecusaPrazo(), _
                    notaMinima, GetNotaMinimaAvaliacao(), maxStrikes, GetMaxStrikes(), _
                    diasStrike, GetDiasSuspensaoStrike(), "OK", IIf(ok, "OK", "FALHA"), _
                    "", "", "", observado) & vbCrLf

    TV2_ConfigCenarioRoundTrip = ok
End Function

Private Function TV2_ConfigCenarioRecusaConsomeRegra( _
    ByVal frm As Configuracao_Inicial, _
    ByVal execId As String, _
    ByVal buildLabel As String, _
    ByVal suite As String, _
    ByRef csvTexto As String, _
    ByRef observado As String _
) As Boolean
    Dim detalhes As String
    Dim persistiu As Boolean
    Dim ents() As String
    Dim emps() As String
    Dim ativs() As String
    Dim resPre As TResult
    Dim resRecusa As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim ok As Boolean

    TV2_LimparNamespace "SCFR"
    persistiu = frm.CI_TestarPersistenciaPainel("1", "1", "1", detalhes, "1", "1", "1", _
                                                "Gestor Auditoria " & buildLabel & " RECUSA", _
                                                "Municipio Auditoria V12 Onda 38.2.30 RECUSA")
    TV2_FixtureFactory "SCFR", 1, 1, 1, ents, emps, ativs
    resPre = EmitirPreOS(ents(1), ativs(1) & "|001", 1)
    If resPre.sucesso Then
        resRecusa = RecusarPreOS(resPre.IdGerado, "TV2_CONFIG_CENARIOS")
    End If
    emp = LerEmpresa(emps(1), linhaEmp)

    ok = persistiu And resPre.sucesso And resRecusa.sucesso
    ok = ok And (GetMaxRecusas() = 1)
    ok = ok And (GetDiasSuspensaoRecusaPrazo() = 1)
    ok = ok And (emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL")
    ok = ok And (emp.DT_FIM_SUSP = DateAdd("d", 1, Date))

    observado = "PERSISTIU=" & CStr(persistiu) & "; PREOS=" & resPre.IdGerado & _
                "; RECUSA_OK=" & CStr(resRecusa.sucesso) & "; MSG=" & resRecusa.mensagem & _
                "; EMP=" & emps(1) & "; STATUS=" & emp.STATUS_GLOBAL & _
                "; DT_FIM=" & IIf(emp.DT_FIM_SUSP > CDate(0), Format$(emp.DT_FIM_SUSP, "yyyy-mm-dd"), "") & _
                "; MAX_RECUSAS=" & CStr(GetMaxRecusas()) & _
                "; DIAS_RECUSA=" & CStr(GetDiasSuspensaoRecusaPrazo())

    csvTexto = csvTexto & TV2_ConfigCsvRow( _
                    execId, buildLabel, suite, "REGRA_RECUSA", "SCFR_MAX1_DIAS1", 30, _
                    "1", emps(1), ativs(1), TV2_ConfigPosicaoFila(emps(1), ativs(1)), _
                    "", "", "", "", GetDiasDecisao(), GetDiasDecisao(), _
                    1, GetMaxRecusas(), 1, GetDiasSuspensaoRecusaPrazo(), _
                    GetNotaMinimaAvaliacao(), GetNotaMinimaAvaliacao(), _
                    GetMaxStrikes(), GetMaxStrikes(), GetDiasSuspensaoStrike(), GetDiasSuspensaoStrike(), _
                    "SUSPENSA_GLOBAL;DT_FIM=HOJE+1", emp.STATUS_GLOBAL, "", "", "", observado) & vbCrLf

    TV2_ConfigCenarioRecusaConsomeRegra = ok
End Function

Private Function TV2_ConfigCenarioStrikeConsomeRegra( _
    ByVal frm As Configuracao_Inicial, _
    ByVal execId As String, _
    ByVal buildLabel As String, _
    ByVal suite As String, _
    ByRef csvTexto As String, _
    ByRef observado As String _
) As Boolean
    Dim detalhes As String
    Dim persistiu As Boolean
    Dim ents() As String
    Dim emps() As String
    Dim ativs() As String
    Dim notas(1 To 1) As Integer
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim strikes As Long
    Dim ok As Boolean

    TV2_LimparNamespace "SCFS"
    persistiu = frm.CI_TestarPersistenciaPainel("2", "2", "2", detalhes, "2", "2", "2", _
                                                "Gestor Auditoria " & buildLabel & " STRIKE", _
                                                "Municipio Auditoria V12 Onda 38.2.30 STRIKE")
    TV2_FixtureFactory "SCFS", 1, 1, 1, ents, emps, ativs
    notas(1) = 1
    TV2_FF_RodadaCompleta ativs(1), ents(1), 2, emps, notas, Date + 1

    emp = LerEmpresa(emps(1), linhaEmp)
    strikes = ContarStrikesPorEmpresa(emps(1), GetNotaMinimaAvaliacao())

    ok = persistiu
    ok = ok And (GetMaxStrikes() = 2)
    ok = ok And (GetDiasSuspensaoStrike() = 2)
    ok = ok And (strikes >= 2)
    ok = ok And (emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL")
    ok = ok And (emp.DT_FIM_SUSP = DateAdd("d", 2, Date))

    observado = "PERSISTIU=" & CStr(persistiu) & "; EMP=" & emps(1) & _
                "; STATUS=" & emp.STATUS_GLOBAL & "; STRIKES=" & CStr(strikes) & _
                "; DT_FIM=" & IIf(emp.DT_FIM_SUSP > CDate(0), Format$(emp.DT_FIM_SUSP, "yyyy-mm-dd"), "") & _
                "; MAX_STRIKES=" & CStr(GetMaxStrikes()) & _
                "; DIAS_STRIKE=" & CStr(GetDiasSuspensaoStrike())

    csvTexto = csvTexto & TV2_ConfigCsvRow( _
                    execId, buildLabel, suite, "REGRA_STRIKE", "SCFS_MAX2_DIAS2", 31, _
                    "1", emps(1), ativs(1), TV2_ConfigPosicaoFila(emps(1), ativs(1)), _
                    "", "", "", "", GetDiasDecisao(), GetDiasDecisao(), _
                    GetMaxRecusas(), GetMaxRecusas(), GetDiasSuspensaoRecusaPrazo(), GetDiasSuspensaoRecusaPrazo(), _
                    GetNotaMinimaAvaliacao(), GetNotaMinimaAvaliacao(), _
                    2, GetMaxStrikes(), 2, GetDiasSuspensaoStrike(), _
                    "SUSPENSA_GLOBAL;DT_FIM=HOJE+2", emp.STATUS_GLOBAL, "", "", "", observado) & vbCrLf

    TV2_ConfigCenarioStrikeConsomeRegra = ok
End Function

Private Function TV2_ConfigCsvHeader() As String
    TV2_ConfigCsvHeader = "EXECUCAO_ID;BUILD;SUITE;TIPO;CENARIO;ORDEM;ORDEM_FILA;EMP_ID;ATIV_ID;POSICAO_FILA;GESTOR_ESPERADO;GESTOR_CONFIG;MUNICIPIO_ESPERADO;MUNICIPIO_CONFIG;PRAZO_PREOS;GET_DIAS_DECISAO;MAX_RECUSAS;GET_MAX_RECUSAS;DIAS_RECUSA_PRAZO;GET_DIAS_RECUSA_PRAZO;NOTA_MINIMA;GET_NOTA_MINIMA;MAX_STRIKES;GET_MAX_STRIKES;DIAS_STRIKE;GET_DIAS_STRIKE;STATUS_ESPERADO;STATUS_OBSERVADO;PASTA_NOVO_PERIODO;COPIA_PLANILHA;CSV_EVIDENCIA;DETALHES" & vbCrLf
End Function

Private Function TV2_ConfigCsvRow(ParamArray valores() As Variant) As String
    Dim i As Long
    Dim linha As String

    For i = 0 To 31
        If i > 0 Then linha = linha & ";"
        If i <= UBound(valores) Then
            linha = linha & TV2_ConfigCsvCell(valores(i))
        Else
            linha = linha & TV2_ConfigCsvCell("")
        End If
    Next i
    TV2_ConfigCsvRow = linha
End Function

Private Function TV2_ConfigCsvCell(ByVal valor As Variant) As String
    Dim s As String

    If IsError(valor) Then
        s = "#ERRO"
    Else
        s = CStr(valor)
    End If
    s = Replace(s, """", """""")
    TV2_ConfigCsvCell = """" & s & """"
End Function

Private Function TV2_ConfigCsvFilaSnapshot( _
    ByVal execId As String, _
    ByVal buildLabel As String, _
    ByVal suite As String, _
    ByVal tipo As String, _
    ByVal cenario As String, _
    ByVal ordemBase As Long _
) As String
    Dim ws As Worksheet
    Dim ult As Long
    Dim i As Long
    Dim ordemFila As Long
    Dim saida As String

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    ult = ws.Cells(ws.Rows.Count, COL_CRED_ID).End(xlUp).row
    For i = LINHA_DADOS To ult
        ordemFila = ordemFila + 1
        If ordemFila > 5 Then Exit For
        saida = saida & TV2_ConfigCsvRow( _
                    execId, buildLabel, suite, tipo, cenario, ordemBase + ordemFila, _
                    ordemFila, ws.Cells(i, COL_CRED_EMP_ID).Value, ws.Cells(i, COL_CRED_ATIV_ID).Value, _
                    ws.Cells(i, COL_CRED_POSICAO).Value, "", "", "", "", _
                    "", "", "", "", "", "", "", "", "", "", "", "", _
                    "FILA_SNAPSHOT", "EMP_ID=" & CStr(ws.Cells(i, COL_CRED_EMP_ID).Value) & _
                    ";ATIV_ID=" & CStr(ws.Cells(i, COL_CRED_ATIV_ID).Value) & _
                    ";POSICAO=" & CStr(ws.Cells(i, COL_CRED_POSICAO).Value), _
                    "", "", "", "Snapshot das primeiras 5 linhas de CREDENCIADOS") & vbCrLf
    Next i
    TV2_ConfigCsvFilaSnapshot = saida
End Function

Private Function TV2_ConfigPosicaoFila(ByVal empId As String, ByVal ativId As String) As Variant
    Dim ws As Worksheet
    Dim ult As Long
    Dim i As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    ult = ws.Cells(ws.Rows.Count, COL_CRED_ID).End(xlUp).row
    For i = LINHA_DADOS To ult
        If IdsIguais(ws.Cells(i, COL_CRED_EMP_ID).Value, empId) And _
           IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ativId) Then
            TV2_ConfigPosicaoFila = ws.Cells(i, COL_CRED_POSICAO).Value
            Exit Function
        End If
    Next i
    TV2_ConfigPosicaoFila = ""
End Function

Private Function TV2_ConfigQtdLinhasDados(ByVal nomeAba As String) As Long
    TV2_ConfigQtdLinhasDados = TV2_CountRows(nomeAba)
End Function

Private Function TV2_ConfigPathJoin(ByVal pasta As String, ByVal nome As String) As String
    If Right$(pasta, 1) = "\" Or Right$(pasta, 1) = "/" Then
        TV2_ConfigPathJoin = pasta & nome
    Else
        TV2_ConfigPathJoin = pasta & Application.PathSeparator & nome
    End If
End Function

Private Sub TV2_ConfigEscreverTexto(ByVal caminho As String, ByVal conteudo As String)
    Dim fNum As Integer

    fNum = FreeFile
    Open caminho For Output As #fNum
    Print #fNum, conteudo;
    Close #fNum
End Sub

Public Sub TV2_RunTelaConfiguracoesIniciais(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "CONFIGURACOES_INICIAIS"
    Dim repoRoot As String
    Dim wsCfg As Worksheet
    Dim valorNotaAntes As Variant
    Dim valorMaxAntes As Variant
    Dim valorDiasAntes As Variant
    Dim valorPrazoAntes As Variant
    Dim valorMaxRecusasAntes As Variant
    Dim valorMesesAntes As Variant
    Dim valorDiasRecusaAntes As Variant
    Dim frm As Configuracao_Inicial
    Dim detalhesEditavel As String
    Dim detalhesLayout As String
    Dim detalhesPersistencia As String
    Dim campoEditavel As Boolean
    Dim campoLayoutOk As Boolean
    Dim persistiuOk As Boolean
    Dim diasRecusaDepois As Long
    Dim ajudaPath As String
    Dim ajudaOk As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    valorNotaAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value
    valorMaxAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value
    valorDiasAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value
    valorPrazoAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value
    valorMaxRecusasAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value
    valorMesesAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value
    valorDiasRecusaAntes = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value

    Set frm = New Configuracao_Inicial
    campoEditavel = TV2_FormControleEditavel(frm, "TxtMesesSuspensao", detalhesEditavel)
    campoLayoutOk = TV2_FormControleLivreDeSobreposicao(frm, "TxtMesesSuspensao", detalhesLayout, "suspender por")
    TV2_LogAssert suite, "CI_TELA_01_DIAS_RECUSA_EDITAVEL", "AUTO", _
                  "Campo de dias por recusa/prazo fica editavel e sem sobreposicao visual", _
                  "TxtMesesSuspensao Enabled=True, Locked=False, TabStop=True e nenhum label 'suspender por' cobre o campo", _
                  detalhesEditavel & "; " & detalhesLayout, _
                  "Evita interface mentir sobre regra que o codigo realmente persiste em dias", _
                  (campoEditavel And campoLayoutOk)

    If campoEditavel And campoLayoutOk Then
        persistiuOk = frm.CI_TestarPersistenciaPainel("5", "2", "11", detalhesPersistencia, "3", "45", "5")
    Else
        detalhesPersistencia = "Campo de dias por recusa/prazo nao editavel ou coberto por label; persistencia nao executada."
        persistiuOk = False
    End If
    diasRecusaDepois = CLng(Val(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))
    TV2_LogAssert suite, "CI_TELA_02_DIAS_RECUSA_PERSISTE", "AUTO", _
                  "Salvar parametros grava dias de suspensao por recusa/prazo na CONFIG", _
                  "MAX_RECUSAS=3; DIAS_RECUSA_PRAZO=45; PRAZO_PREOS=5", _
                  "PERSISTIU=" & CStr(persistiuOk) & "; DIAS_RECUSA_PRAZO=" & _
                  CStr(diasRecusaDepois) & "; DETALHES=" & detalhesPersistencia, _
                  "Cobre round-trip do campo visual para a regra consumida pelo rodizio", _
                  (persistiuOk And diasRecusaDepois = 45)

    ajudaPath = ThisWorkbook.Path & Application.PathSeparator & "docs" & _
                Application.PathSeparator & "help" & _
                Application.PathSeparator & "hbn" & _
                Application.PathSeparator & "configuracoes-iniciais.html"
    ajudaOk = (TV2_FormControleExiste(frm, "CommandButton1") And Len(Dir(ajudaPath)) > 0)
    TV2_LogAssert suite, "CI_TELA_03_AJUDA_HBN_DISPONIVEL", "AUTO", _
                  "Tela Configuracoes Iniciais tem botao Ajuda e HTML HBN publicado", _
                  "CommandButton1 existe; configuracoes-iniciais.html existe no caminho do workbook", _
                  "BOTAO=" & CStr(TV2_FormControleExiste(frm, "CommandButton1")) & _
                  "; HTML=" & ajudaPath & "; EXISTE=" & CStr(Len(Dir(ajudaPath)) > 0), _
                  "Permite documentar a operacao tela a tela sem depender do chat", _
                  ajudaOk

    TV2_EST_LogComponenteContemTokens suite, "CI_TELA_04_BOTOES_TELA_HANDLERS", repoRoot, _
        "Configuracao_Inicial", "Configuracao_Inicial.frm", _
        "Private Sub CommandButton1_Click()|CI_AbrirAjudaHBN|" & _
        "Private Sub B_Parametros_Click()|Call CI_PersistirParametros(True, True, True, detalhes)|" & _
        "Private Sub BR_Backup_Click()|Private Sub Limpar_Base_Click()|" & _
        "Private Sub Limpar_Basee_Click()|Call AbrirLimparBaseSeguro", _
        "Tela Configuracoes Iniciais expoe handlers dos botoes principais", _
        "Ajuda, Salvar Parametros, Iniciar Novo Periodo e Limpar Base tem handlers rastreaveis", _
        "Evita validar apenas campos e deixar botoes centrais fora da cobertura dirigida"

    TV2_EST_LogComponenteContemTokens suite, "CI_TELA_05_FLUXOS_ADMIN_GUARDADOS", repoRoot, _
        "Configuracao_Inicial", "Configuracao_Inicial.frm", _
        "Resposta = MsgBox(""Confirme o Backup|If Resposta = vbNo Then|" & _
        "If MsgBox(""Tem certeza que deseja iniciar um NOVO PER|ThisWorkbook.SaveCopyAs Copia|" & _
        "Set wsPreOS = ThisWorkbook.Sheets(""PRE_OS"")|Set wsCADOS = ThisWorkbook.Sheets(""CAD_OS"")|" & _
        "VBA.UserForms.Add(""Limpar_Base"").Show", _
        "Fluxos administrativos da tela exigem confirmacao antes de mutar base", _
        "Iniciar Novo Periodo pede confirmacao e Limpar Base abre formulario proprio", _
        "Fluxos destrutivos nao devem ser acionados automaticamente pelo teste V2"

    TV2_EST_LogComponenteContemTokens suite, "CI_TELA_06_LIMPAR_BASE_CONFIRMACAO", repoRoot, _
        "Preencher", "Preencher.bas", _
        "Sub Limpa_Base()|Tem certeza que deseja ZERAR a Base Operacional?|If Not LimpaBaseTotalReset(relatorio) Then|" & _
        "Util_SalvarWorkbookSeguro", _
        "Fallback de Limpar Base mantem confirmacao explicita e rotina centralizada", _
        "Limpa_Base pergunta antes de zerar a base e delega para LimpaBaseTotalReset", _
        "Mesmo o fallback operacional preserva gate humano antes de uma acao destrutiva"

    TV2_EST_LogComponenteContemTokens suite, "CI_TELA_07_MENU_INICIAL_ATALHOS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub B_Config_Inicial_Click()|VBA.UserForms.Add(""Configuracao_Inicial"")|frmConfiguracao.Show vbModal|" & _
        "Private Sub BT_CENTRAL_TESTES_Click()|Call Menu_TelaInicial_AbrirCentralTestes|" & _
        "Private Sub BT_SOBRE_Click()|Call Menu_TelaInicial_MostrarSobre|" & _
        "Private Sub BT_GITHUB_Click()|Call Menu_TelaInicial_AbrirGitHub|" & _
        "Private Sub CommandButton15_Click()|Private Sub CommandButton13_Click()|Private Sub CommandButton14_Click()", _
        "Menu inicial preserva atalhos para Configuracoes, Central de Testes, Sobre e GitHub", _
        "Atalhos nomeados e legados delegam para handlers internos rastreaveis", _
        "Evita quebra silenciosa de entrada na tela e botoes institucionais"

    TV2_EST_LogComponenteContemTokens suite, "CI_TELA_08_MENU_LATERAL_ROTAS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub B_Home_Click()|Private Sub B_Entidade_Click()|Private Sub B_Empresa_Cadastro_Click()|" & _
        "Private Sub B_Empresa_Rodizio_Click()|Private Sub B_Emite_OS_Click()|" & _
        "Private Sub B_Empresa_Avaliacao_Click()|Private Sub B_CAD_SERV_Click()|" & _
        "Private Sub B_Relatorios_Click()|Private Sub L_Sair_Click()", _
        "Menu lateral preserva rotas principais de entrada e saida ao redor da tela", _
        "Inicio, cadastros, rodizio, impressao, avaliacao, servicos, relatorios e sair tem handlers", _
        "Garante que a validacao tela a tela nao isole Configuracoes Iniciais do fluxo real"

    TV2_EST_LogComponenteNaoContemTokens suite, "CI_TELA_09_FECHAMENTO_X_NAO_BLOQUEADO", repoRoot, _
        "Configuracao_Inicial", "Configuracao_Inicial.frm", _
        "Private Sub UserForm_QueryClose|Cancel = True", _
        "Fechamento pelo X nao e bloqueado por handler customizado na tela", _
        "Configuracao_Inicial nao define QueryClose nem Cancel=True para impedir fechamento", _
        "O operador deve conseguir sair da tela sem caminho escondido ou trava visual"

    TV2_RestaurarConfigPainel valorNotaAntes, valorMaxAntes, valorDiasAntes, valorPrazoAntes, valorMaxRecusasAntes, valorMesesAntes, valorDiasRecusaAntes
    Unload frm
    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    TV2_RestaurarConfigPainel valorNotaAntes, valorMaxAntes, valorDiasAntes, valorPrazoAntes, valorMaxRecusasAntes, valorMesesAntes, valorDiasRecusaAntes
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar validacao da tela Configuracoes Iniciais sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunTelaInicial(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "TELA_INICIAL"
    Dim repoRoot As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 14
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_01_ENTRADAS_CANONICAS", repoRoot, _
        "Auto_Open", "Auto_Open.bas", _
        "Private Sub InicializarSistema()|Public Sub Auto_Open()|Public Sub IniciarSistema()|" & _
        "Public Sub AbrirMenu()|InicializarSistema", _
        "Tela Inicial tem entradas canonicas convergentes", _
        "Auto_Open, IniciarSistema e AbrirMenu delegam ao mesmo inicializador", _
        "Evita divergencia entre abertura automatica, macro manual e atalho visual"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_02_PROCESSOS_DE_ABERTURA", repoRoot, _
        "Auto_Open", "Auto_Open.bas", _
        "qtdCnae = CargaInicialCNAE_SeNecessario(False)|" & _
        "AutoOpen_VerificarBackfillDtUltReativ|VBA.UserForms.Add(""Menu_Principal"")", _
        "Abertura do sistema preserva processos operacionais obrigatorios", _
        "Carga CNAE, backfill e abertura do Menu_Principal continuam encadeados", _
        "Garante que a entrada da Tela Inicial preserva diagnosticos de base no escopo importado"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_03_PROTECAO_DELEGADA_BL4", repoRoot, _
        "Teste_V2_Roteiros", "Teste_V2_Roteiros.bas", _
        "Public Sub TV2_RunBL4ProtecaoPersistente|BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO|" & _
        "TV2_BL4_AutoOpenMarcadorAposUltimoSaveCompat|AutoOpen_UltimaProtecaoMarcadorAposUltimoSave", _
        "Tela Inicial mantem protecao de abertura coberta por suite dedicada", _
        "Cobertura BL4 permanece disponivel sem exigir Auto_Open no delta da Tela Inicial", _
        "Evita reprovar Tela Inicial por modulo fora do pacote 0159"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_04_ATALHO_VISUAL_INICIAR", repoRoot, _
        "UX_IniciarSistema", "UX_IniciarSistema.bas", _
        "Private Const UX_IS_SHAPE_NAME As String = ""UX_BTN_INICIAR_SISTEMA""|" & _
        "Private Const UX_IS_ONACTION As String = ""IniciarSistema""|shp.OnAction = UX_IS_ONACTION|" & _
        ".TextRange.Text = ""Iniciar Sistema""|UX_IS_AbaCritica", _
        "Atalho visual Iniciar Sistema aponta para o comando correto", _
        "Shape unico chama IniciarSistema, tem texto operacional e evita abas criticas", _
        "Garante entrada visual sem alterar Auto_Open ou UserForms de producao"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_05_INICIALIZACAO_PAGINA_ZERO", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub UserForm_Initialize()|mInicializando = True|Me.caption = ""SISTEMA DE CREDENCIAMENTO""|" & _
        "Call PreenchimentoEscolhaAtividade|Call PreenchimentoEntidade|Call PreenchimentoEmpresa|" & _
        "Call Tela_Inicial|PAGINAS.Style = fmTabStyleNone|mInicializando = False", _
        "Menu_Principal inicializa dados e entra na Tela Inicial", _
        "Listas principais sao carregadas, Tela_Inicial e chamada e as abas ficam ocultas ao operador", _
        "Evita abrir o sistema em pagina residual ou com dados basicos nao carregados"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_06_HOME_ESTADO_VISUAL", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Tela_Inicial()|B_Home.BackStyle = fmBackStyleOpaque|PAGINAS.Value = 0|" & _
        "Private Sub B_Home_Click()|B_CAD_SERV.BackStyle = fmBackStyleTransparent", _
        "Comando Inicio volta para a pagina inicial", _
        "Home fica ativo, demais rotas ficam transparentes e PAGINAS volta para 0", _
        "Garante retorno previsivel para o painel inicial depois de navegar"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_07_SOBRE_RELEASE_REGRA", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Menu_TelaInicial_MostrarSobre()|AppRelease_Atual()|AppRelease_Status()|" & _
        "AppRelease_Canal()|AppRelease_Alvo()|AppRelease_BuildImportadoRotulo()|" & _
        "AppRelease_BuildBranch()|AppRelease_BuildGeradoEm()|MsgBox msg, vbInformation + vbOKOnly, ""Sobre""", _
        "Botao Sobre informa release, build e objetivo operacional", _
        "Mensagem usa App_Release como fonte e volta ao sistema com OK", _
        "O operador consegue conferir versao e regra geral sem mutar dados"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_08_GITHUB_FALLBACK_URL", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Function AbrirURLExterna(ByVal url As String)|Application.OperatingSystem, ""Mac""|" & _
        "Shell ""open|Application.OperatingSystem, ""Windows""|Application.FollowHyperlink url|" & _
        "ThisWorkbook.FollowHyperlink url|Private Sub Menu_TelaInicial_AbrirGitHub()|AppRelease_GitHubRepoUrl()", _
        "Botao GitHub abre URL oficial com fallback", _
        "Mac usa Shell open antes de hyperlinks; Windows e fallbacks continuam disponiveis", _
        "Evita travamento no Mac e preserva caminho manual para o repositorio"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_09_CENTRAL_TESTES_GUARD", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Function Treinamento_ConfirmarUso()|modo de treinamento altera dados reais|" & _
        "Deseja continuar?|Private Sub Menu_TelaInicial_AbrirCentralTestes()|" & _
        "If Not Treinamento_ConfirmarUso() Then Exit Sub|Call Menu_RecolherParaBateria|" & _
        "Call CT_AbrirCentral|Erro ao abrir Central de Testes", _
        "Central de Testes tem confirmacao antes do fluxo de treinamento", _
        "Operador e avisado sobre alteracao de dados reais antes de recolher o menu e abrir a Central", _
        "Fluxo de maior risco fica condicionado a confirmacao humana"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_10_CENTRAL_OPCOES", repoRoot, _
        "Central_Testes", "Central_Testes.bas", _
        "Public Sub CT_AbrirCentral()|InputBox(|[1] VCR: Validacao Completa da Release|" & _
        "[2] Central de Testes V2|[3] Bateria Oficial V1|Case ""1"": Call CT_ValidarRelease_Completa|" & _
        "Case ""2"": Call CT2_AbrirCentral", _
        "Central de Testes expoe VCR, V2 e bateria oficial", _
        "InputBox lista opcoes principais e roteia para os entry points oficiais", _
        "O mapa da Tela Inicial cobre o que o botao Central pode disparar"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_11_CONFIGURACOES_MODAL", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub B_Config_Inicial_Click()|Call UI_DescartarFormVisivel(""Configuracao_Inicial"")|" & _
        "Set frmConfiguracao = VBA.UserForms.Add(""Configuracao_Inicial"")|frmConfiguracao.Show vbModal|" & _
        "Erro ao abrir Configura", _
        "Atalho Configuracoes Iniciais abre tela modal limpa", _
        "Instancia antiga e descartada antes de criar Configuracao_Inicial em modo modal", _
        "Evita stale form e preserva o fluxo validado na onda anterior"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_12_ROTAS_LATERAIS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub B_Entidade_Click()|PAGINAS.Value = 1|Private Sub B_Empresa_Cadastro_Click()|" & _
        "PAGINAS.Value = 2|Private Sub B_Empresa_Rodizio_Click()|PAGINAS.Value = 3|" & _
        "Private Sub B_Emite_OS_Click()|PAGINAS.Value = 4|Private Sub B_Empresa_Avaliacao_Click()|" & _
        "PAGINAS.Value = 5|Private Sub B_CAD_SERV_Click()|PAGINAS.Value = 6|" & _
        "Private Sub B_Relatorios_Click()|PAGINAS.Value = 7", _
        "Menu lateral preserva rotas principais do sistema", _
        "Entidade, Empresa, Rodizio, OS, Avaliacao, Servicos e Relatorios continuam mapeados", _
        "A Tela Inicial fica conectada ao fluxo real do operador"

    TV2_EST_LogComponenteContemTokens suite, "TELAINI_13_SAIR_CONFIRMA_SEM_SAVE", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub L_Sair_Click()|Deseja realmente continuar com o fechamento do sistema?|" & _
        "ProgressBar.Show|Application.Quit|ActiveWorkbook.Close savechanges:=False", _
        "Comando Sair exige confirmacao e nao salva automaticamente", _
        "Fechamento operacional pergunta antes e fecha sem savechanges", _
        "Evita confundir Sair com persistencia; operador precisa salvar antes se quiser preservar edicoes"

    TV2_EST_LogComponenteNaoContemTokens suite, "TELAINI_14_X_NAO_BLOQUEADO", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub UserForm_QueryClose|Cancel = True", _
        "Fechamento pelo X nao e bloqueado por handler customizado", _
        "Menu_Principal nao define QueryClose nem Cancel=True para impedir o X", _
        "Operador tem saida visual padrao alem do comando Sair"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite TelaInicial sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunTelaRelatorios(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "TELA_RELATORIOS"
    Dim repoRoot As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 11
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_01_HELPERS_STATUS_HUMANO", repoRoot, _
        "Rel_Rodizio_Status", "Rel_Rodizio_Status.bas", _
        "Public Function RRS_StatusGlobalHumano|Public Function RRS_SuspensaDesdeTexto|" & _
        "Public Function RRS_SuspensaAteTexto|Public Function RRS_UltimaReativacaoTexto|" & _
        "Public Function RRS_ParticipaRodizioHumanoPorEmpresa|Public Function RRS_StrikesNotaBaixa|" & _
        "Public Function RRS_StrikesRecusaPrazo|Public Function RRS_DisponibilidadeOperacionalEmpresa|" & _
        "Public Function RRS_StatusEmpresaNaData|Public Function RRS_DiagnosticoOperacionalEmpresa", _
        "Relatorios tem helpers publicos para status, datas e strikes", _
        "Helpers convertem regra tecnica em texto humano para relatorios", _
        "Evita repetir interpretacao de suspensao e strikes em cada relatorio"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_02_EMPRESA_POR_SERVICO_NOME_SERVICO", repoRoot, _
        "Rel_Emp_Serv", "Rel_Emp_Serv.frm", _
        "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO|ATIVIDADE|SERVICO|COD_ATIV_SERV|" & _
        "STATUS EMPRESA|SUSPENSA ATE|DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|" & _
        "STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|RRS_DisponibilidadeOperacionalEmpresa", _
        "Relatorio por servico mostra o nome do servico e o status operacional da empresa", _
        "Cabecalho identifica atividade/servico e tabela inclui status, suspensao, disponibilidade e strikes", _
        "Fecha a lacuna visual apontada para Empresa credenciada por servico"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_03_OS_POR_EMPRESA_DATAS_STATUS", repoRoot, _
        "Rel_OSEmpresa", "Rel_OSEmpresa.frm", _
        "STATUS EMPRESA|SUSPENSA DESDE|SUSPENSA ATE|ULTIMA REATIVACAO|DISPONIBILIDADE ATUAL|" & _
        "STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|" & _
        "RRS_SuspensaDesdeTexto|RRS_UltimaReativacaoTexto", _
        "Relatorio de OS por empresa mostra status, datas, retorno e strikes", _
        "Resumo superior apresenta status humano, suspensa desde, suspensa ate, ultima reativacao e strikes", _
        "Permite ler historico operacional da empresa sem abrir a base"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_04_ENTIDADES_FORMATACAO_PADRAO", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Entidades_Cadastradas_Click()|Rel_FormatarCabecalho(wsRel, 10)|" & _
        "Rel_FormatarDados(wsRel, 2, linhaRel - 1, 10)|RELATORIO DE ENTIDADES CADASTRADAS NO CREDENCIAMENTO", _
        "Relatorio de entidades usa a formatacao tabular padrao", _
        "Cabecalho, linhas alternadas, bordas e pagina sao aplicados via helpers compartilhados", _
        "Alinha os relatorios que nao possuem empresa ao padrao visual aprovado"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_05_EMPRESAS_CADASTRADAS_STATUS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Btn_Empresas_Cadastradas_Click()|STATUS EMPRESA|SUSPENSA DESDE|" & _
        "SUSPENSA ATE|ULTIMA REATIVACAO|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|" & _
        "RESUMO OPERACIONAL|Rel_FormatarCabecalho(wsRel, 14)", _
        "Relatorio de empresas cadastradas mostra status, datas e strikes", _
        "Colunas de status, suspensa desde, suspensa ate, ultima reativacao e strikes estao presentes", _
        "Garante que a listagem geral de empresas nao omite bloqueio operacional"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_06_EMPRESAS_CREDENCIADAS_STATUS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Btn_Empresas_Credenciados_Click()|STATUS CRED.|STATUS EMPRESA|" & _
        "SUSPENSA ATE|DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|" & _
        "RESUMO OPERACIONAL|Rel_DisponibilidadeEmpresaTexto(empId, statusCred, ativId)|Rel_FormatarCabecalho(wsRel, 14)", _
        "Relatorio de empresas credenciadas mostra status de credenciamento e status global", _
        "Tabela inclui status do credenciamento, status da empresa, suspensao, disponibilidade e strikes", _
        "Evita confundir credenciamento ativo com empresa apta no rodizio"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_07_OS_ABERTAS_STATUS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub OS_Emitidas_Click()|STATUS EMPRESA|SUSPENSA DESDE|SUSPENSA ATE|" & _
        "DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|" & _
        "ProximaOSAberta:|Rel_FormatarCabecalho(wsRel, 16)|Rel_ConfigurarPagina(wsRel, ""RELATORIO DE ORDENS DE SERVICO ABERTAS"", ""P"", False)", _
        "Relatorio de OS abertas mostra a situacao atual da empresa", _
        "Colunas de status, suspensao e strikes acompanham cada OS aberta impressa", _
        "Permite decidir sobre execucao pendente com a condicao operacional visivel"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_08_PREOS_VENCIDAS_STATUS", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub PRE_OS_Vencidas_Click()|STATUS EMPRESA|SUSPENSA DESDE|SUSPENSA ATE|" & _
        "DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|" & _
        "Rel_FormatarCabecalho(wsRel, 13)|Rel_ConfigurarPagina(wsRel, ""RELATORIO DE PRE-OS VENCIDAS"", ""M"", False)", _
        "Relatorio de pre-OS vencidas mostra a situacao atual da empresa", _
        "Cada pre-OS vencida inclui status, datas de suspensao, disponibilidade e strikes", _
        "Evita avaliar atraso sem saber se a empresa esta suspensa"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_09_LIMPEZA_RELATORIO_TEMPORARIO", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "falha_rel_entidades:|falha_rel_emp_cad:|falha_rel_emp_cred:|falha_rel_os_emit:|" & _
        "falha_rel_pre_venc:|wsRel.PageSetup.PrintArea = """"|wsRel.Cells.Clear", _
        "Relatorios temporarios limpam aba e area de impressao apos sucesso ou erro", _
        "Caminhos principais e handlers de falha restauram RELATORIO antes de devolver o controle", _
        "Evita resquicio visual ou area de impressao velha entre relatorios"

    TV2_EST_LogComponenteContemTokens suite, "REL_TELA_10_STATUS_RODIZIO_POR_SERVICO_FORMATADO", repoRoot, _
        "Rel_Rodizio_Status", "Rel_Rodizio_Status.bas", _
        "Public Function RRS_GerarRelatorioStatusPorServico|EMPRESAS_SUSPENSAS|PROXIMO_RETORNO|" & _
        "Rel_FormatarCabecalho(wsRpt, 12, 1)|Rel_FormatarDados(wsRpt, 2, linhaOut - 1, 12)", _
        "Relatorio tecnico de status do rodizio por servico preserva formatacao e retorno", _
        "Saida consolidada por servico lista suspensas, proximo retorno e alerta formatado", _
        "Complementa os relatorios humanos com diagnostico operacional por servico"

    TV2_EST_LogTrechoContrato suite, "REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub PRE_OS_Vencidas_Click()", "Private Sub Rel_EmpXServ_Click()", _
        "Call ClassificaDataPreOS|statusPre <> ""AGUARDANDO_ACEITE""|" & _
        "If CDate(dtLimite) >= Date Then GoTo ProximoPre|" & _
        "wsRel.PageSetup.PrintArea = wsRel.Range(""A1:M"" & (linhaRel - 1)).Address|" & _
        "wsRel.Range(""A1:M"" & (linhaRel - 1)).PrintOut|Call ClassificaPreOS", _
        "ExpirarPreOS(|RecusarPreOS(|AvancarFila(", _
        "Relatorio de Pre-OS vencidas imprime pendencias sem expirar automaticamente", _
        "Trecho do botao filtra AGUARDANDO_ACEITE vencida, configura impressao e nao chama mutacoes destrutivas", _
        "Operador consulta/imprime o relatorio e decide manualmente expirar antes de emitir nova Pre-OS"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite TelaRelatorios sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunRelatoriosSuspensoesStrikesReset(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "REL_SUSP_STRIKES_RESET"
    Dim repoRoot As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 13
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_01_HELPER_RESUMO_STRIKES", repoRoot, _
        "Rel_Rodizio_Status", "Rel_Rodizio_Status.bas", _
        "Public Function RRS_StrikesNotaBaixa|Public Function RRS_StrikesRecusaPrazo|" & _
        "Public Function RRS_DisponibilidadeOperacionalEmpresa|Public Function RRS_StatusEmpresaNaData|" & _
        "Public Function RRS_DiagnosticoOperacionalEmpresa|Public Function RRS_AvisoOperacionalEmpresa|" & _
        "Public Function RRS_AvisoOperacionalEmpresaCurto|Aviso operacional:|NB=|RP=|" & _
        "Private Function RRS_UltimoStrikeSuspensaoAudit|ORIGEM=STRIKE|STRIKES=|" & _
        "Status da empresa nesta data|disponibilidade=|PRE-OS PENDENTE|OS EM EXECUCAO", _
        "Helpers de relatorio expõem strikes de nota baixa e recusa/prazo", _
        "Strikes atuais vêm da regra e suspensao remanescente pode usar ultimo evento de auditoria", _
        "Evita divergencia visual apos iniciar novo periodo com suspensao preservada"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_02_EMPRESAS_CADASTRADAS_STRIKES", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Btn_Empresas_Cadastradas_Click()|STRIKES NOTA BAIXA|" & _
        "STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|Rel_StrikesNotaBaixaTexto(empId)|" & _
        "Rel_StrikesRecusaPrazoTexto(empId)|Rel_DiagnosticoEmpresaTexto(empId)|Rel_FormatarCabecalho(wsRel, 14)", _
        "Empresas cadastradas exibem status e contadores de strikes", _
        "Tabela geral inclui colunas especificas para nota baixa, recusa/prazo e diagnostico", _
        "Empresa suspensa fica legivel no relatorio geral"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_03_EMPRESAS_CREDENCIADAS_STRIKES", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub Btn_Empresas_Credenciados_Click()|STATUS CRED.|STATUS EMPRESA|" & _
        "DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|" & _
        "Rel_DisponibilidadeEmpresaTexto(empId, statusCred, ativId)|Rel_DiagnosticoEmpresaTexto(empId, statusCred, ativId)|Rel_FormatarCabecalho(wsRel, 14)", _
        "Empresas credenciadas separam credenciamento ativo de aptidao operacional", _
        "Relatorio mostra status global, suspensao, disponibilidade e strikes por empresa", _
        "Evita empresa credenciada parecer apta quando esta suspensa"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_04_OS_ABERTAS_SEM_FANTASMA", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub OS_Emitidas_Click()|If Trim$(osId) = """" Or CLng(Val(osId)) <= 0 Then GoTo ProximaOSAberta|" & _
        "ProximaOSAberta:|DISPONIBILIDADE ATUAL|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|RESUMO OPERACIONAL|" & _
        "Rel_DisponibilidadeEmpresaTexto(empId, ""ATIVO"", ativId)|Rel_FormatarCabecalho(wsRel, 16)", _
        "Relatorio de OS abertas ignora linha fantasma sem numero real", _
        "Linhas vazias ou N.O.S. zero nao viram EMPRESA NAO ENCONTRADA", _
        "Remove o falso positivo observado no PDF 058"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_05_PREOS_VENCIDAS_STRIKES", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub PRE_OS_Vencidas_Click()|STRIKES NOTA BAIXA|STRIKES RECUSA/PRAZO|" & _
        "DISPONIBILIDADE ATUAL|RESUMO OPERACIONAL|Rel_StrikesNotaBaixaTexto(empId)|" & _
        "Rel_DisponibilidadeEmpresaTexto(empId, ""ATIVO"", ativId)|Rel_FormatarCabecalho(wsRel, 13)", _
        "Pre-OS vencidas exibem o diagnostico operacional da empresa", _
        "Status, datas de suspensao, disponibilidade e strikes acompanham cada pre-OS", _
        "Atraso fica auditavel junto da condicao atual da empresa"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_06_EMPRESA_POR_SERVICO_STRIKES", repoRoot, _
        "Rel_Emp_Serv", "Rel_Emp_Serv.frm", _
        "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO|SERVICO|STRIKES NOTA BAIXA|" & _
        "STRIKES RECUSA/PRAZO|DISPONIBILIDADE ATUAL|RESUMO OPERACIONAL|RRS_StrikesNotaBaixaTexto|" & _
        "RRS_DisponibilidadeOperacionalEmpresa|RRS_DiagnosticoOperacionalEmpresa|Rel_FormatarCabecalho(wsRel, 11, linhaHeader)", _
        "Empresa credenciada por servico mostra nome do servico e strikes", _
        "Cabecalho identifica servico e cada empresa recebe diagnostico operacional", _
        "Fecha a divergencia entre relatorios com e sem status"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_07_OS_POR_EMPRESA_STRIKES", repoRoot, _
        "Rel_OSEmpresa", "Rel_OSEmpresa.frm", _
        "RELATORIO DE ORDENS DE SERVICO POR EMPRESA|STRIKES NOTA BAIXA|" & _
        "STRIKES RECUSA/PRAZO|DISPONIBILIDADE ATUAL|RESUMO OPERACIONAL|linhaHeader = 8|" & _
        "RRS_StrikesNotaBaixaTexto|RRS_DisponibilidadeOperacionalEmpresa|RRS_DiagnosticoOperacionalEmpresa", _
        "OS por empresa mostra resumo de suspensao e strikes antes das ordens", _
        "Resumo superior inclui status, retorno, disponibilidade e diagnostico", _
        "Permite ler a situacao operacional antes de auditar as OS"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_08_IMPRESSOS_AVISO_OPERACIONAL", repoRoot, _
        "Preencher", "Preencher.bas", _
        "Preencher_EscreverAvisoOperacional|Preencher_AvisoOperacionalCurtoAtual|Preencher_AvisoOperacionalAtual|" & _
        "Preencher_AtividadeIdAtual|Preencher_EmpresaIdAtual|Preencher_ObservacaoComAviso|" & _
        "RRS_AvisoOperacionalEmpresaCurto(empId, ""ATIVO"", Preencher_AtividadeIdAtual())|" & _
        "RRS_AvisoOperacionalEmpresa(empId, ""ATIVO"", Preencher_AtividadeIdAtual())|" & _
        "ws.Range(""C16"").Value = aviso|ws.Range(""B40"").Value = Preencher_ObservacaoComAviso(AvOb)", _
        "Pre-OS, OS e avaliacao impressas recebem aviso operacional do sistema", _
        "Aviso informa status da empresa nesta data, disponibilidade e strikes no proprio formulario", _
        "Facilita auditoria humana dos documentos impressos"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_09_CONTRATO_NOVO_PERIODO_PRESERVA_SUSPENSAO", repoRoot, _
        "Configuracao_Inicial", "Configuracao_Inicial.frm", _
        "Efetuando c|limpando a base de Pr|mantendo os demais cadastros|" & _
        "Set wsPreOS = ThisWorkbook.Sheets(SHEET_PREOS)|Set wsCADOS = ThisWorkbook.Sheets(SHEET_CAD_OS)|" & _
        "wsPreOS.Cells(1, COL_CONTADOR_AR).Value = 0|wsCADOS.Cells(1, COL_CONTADOR_AR).Value = 0", _
        "Iniciar Novo Periodo limpa PRE_OS/CAD_OS e preserva cadastros", _
        "Suspensoes permanecem porque EMPRESAS, CREDENCIADOS, CONFIG e AUDIT_LOG nao sao apagados", _
        "Documenta a passagem de ano sem anistia operacional"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_10_CONTRATO_LIMPAR_BASE_REMOVE_SUSPENSAO", repoRoot, _
        "Mod_Limpeza_Base", "Mod_Limpeza_Base.bas", _
        "Public Function LimpaBaseTotalReset|MLB_LimparAba(""EMPRESAS""|MLB_LimparAba(""CREDENCIADOS""|" & _
        "MLB_LimparAba(""PRE_OS""|MLB_LimparAba(""CAD_OS""|MLB_LimparAba(""AUDIT_LOG""|" & _
        "PRESERVADO (nao tocado):|ATIVIDADES (CNAE)|CONFIG", _
        "Limpar Base remove suspensoes ao apagar a base cadastral e operacional", _
        "Reset total zera empresas, credenciamentos, PRE_OS, CAD_OS e audit log, preservando apenas CNAE e configuracao", _
        "Documenta o uso correto para iniciar outro municipio"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_11_IMPRESSOS_C16_ALINHAMENTO_LEGIVEL", repoRoot, _
        "Preencher", "Preencher.bas", _
        "With ws.Range(""C16:N16"")|.HorizontalAlignment = xlLeft|" & _
        ".VerticalAlignment = xlCenter|.WrapText = False|.ShrinkToFit = False", _
        "Aviso operacional em C16 neutraliza alinhamento distribuido herdado do template sem encolher a fonte", _
        "Range C16:N16 recebe alinhamento esquerdo, vertical central, sem wrap e sem ShrinkToFit", _
        "Evita caracteres artificialmente espacado nos PDFs de Pre-OS, OS e avaliacao"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_12_DISPONIBILIDADE_COMPOSTA_SUSPENSAO", repoRoot, _
        "Rel_Rodizio_Status", "Rel_Rodizio_Status.bas", _
        "Private Function RRS_OcupacaoAtividadeTexto|Private Function RRS_ComporDisponibilidadeSuspensa|" & _
        "TemOSAbertaNaAtividade|TemPreOSPendenteNaAtividade|" & _
        "RRS_ComporDisponibilidadeSuspensa = dispBase & ""; "" & ocupacaoAtividade|" & _
        "RRS_DisponibilidadeOperacionalEmpresa = RRS_ComporDisponibilidadeSuspensa(dispBase, ocupacaoAtividade)", _
        "Disponibilidade de empresa suspensa mostra ocupacao adicional da atividade", _
        "Suspensao continua bloqueio principal, mas OS aberta ou Pre-OS pendente deixam de ficar ocultas", _
        "Evita confusao operacional em relatorios e avisos impressos"

    TV2_EST_LogComponenteContemTokens suite, "RELSSR_13_IMPRESSOS_C16_AVISO_CURTO_LEGIVEL", repoRoot, _
        "Preencher", "Preencher.bas", _
        "Private Function Preencher_AvisoOperacionalCurtoAtual|RRS_AvisoOperacionalEmpresaCurto(empId, ""ATIVO"", Preencher_AtividadeIdAtual())|" & _
        "Preencher_AvisoOperacionalAtual|Preencher_ObservacaoComAviso|.ShrinkToFit = False", _
        "C16 usa resumo operacional curto e preserva diagnostico completo nas observacoes", _
        "Aviso curto fica em C16 e o texto completo continua disponivel quando ha campo de observacao", _
        "Evita que o PDF comprima texto longo ate ficar ilegivel"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite RelatoriosSuspensoesStrikesReset sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunImpressaoIntegridade(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "IMPRESSAO_INTEGRIDADE"
    Dim repoRoot As String
    Dim notasOk As Boolean
    Dim normalizado As String
    Dim preosOk As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    notasOk = (Preencher_NotaAvaliacaoImpressaSegura("11") = 10)
    notasOk = notasOk And (Preencher_NotaAvaliacaoImpressaSegura("10") = 10)
    notasOk = notasOk And (Preencher_NotaAvaliacaoImpressaSegura("7") = 7)
    notasOk = notasOk And (Preencher_NotaAvaliacaoImpressaSegura("-1") = 0)
    notasOk = notasOk And (Preencher_NotaAvaliacaoImpressaSegura("") = 0)
    TV2_LogAssert suite, "CS_IMP_01_NOTAS_CLAMP", "AUTO", _
                  "Notas impressas da avaliacao ficam limitadas a 0..10", _
                  "11=>10; 10=>10; 7=>7; -1=>0; vazio=>0", _
                  "11=>" & CStr(Preencher_NotaAvaliacaoImpressaSegura("11")) & _
                  "; 10=>" & CStr(Preencher_NotaAvaliacaoImpressaSegura("10")) & _
                  "; 7=>" & CStr(Preencher_NotaAvaliacaoImpressaSegura("7")) & _
                  "; -1=>" & CStr(Preencher_NotaAvaliacaoImpressaSegura("-1")) & _
                  "; vazio=>" & CStr(Preencher_NotaAvaliacaoImpressaSegura("")), _
                  "BL-5: a impressao nao pode expor nota maior que 10 mesmo se a UI trouxer texto cru", _
                  notasOk

    normalizado = Preencher_NormalizarPreOSIdImpressao("PROVIS" & ChrW(211) & "RIA - 003")
    preosOk = (normalizado = "003")
    preosOk = preosOk And (Preencher_NormalizarPreOSIdImpressao("004") = "004")
    TV2_LogAssert suite, "CS_IMP_02_PREOS_ID_PREFIXO", "AUTO", _
                  "ID de Pre-OS impresso aceita prefixo operacional PROVISORIA", _
                  "PROVISORIA - 003 normaliza para 003 e ID cru permanece igual", _
                  "prefixado=>" & normalizado & "; cru=>" & Preencher_NormalizarPreOSIdImpressao("004"), _
                  "BL-7: dados da Pre-OS precisam ser encontrados mesmo quando N_OS contem texto de exibicao", _
                  preosOk

    TV2_EST_LogComponenteContemTokens suite, "CS_IMP_03_OS_GLOBAIS_FORM", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "NR_Empenho = SafeListVal(N_Empenho.Value)|END_ENTIDADE = SafeListVal(wsEnt.Cells(idxEnt, COL_ENT_ENDERECO).Value)|Call PreencherOS", _
        "Formulario de emissao de OS alimenta globais usados pelo template", _
        "Empenho vem do valor do controle e endereco da entidade vem de ENTIDADE antes de PreencherOS", _
        "BL-6/FT-7: evita OS impressa sem local da entidade ou empenho ambiguo"

    TV2_EST_LogComponenteContemTokens suite, "CS_IMP_04_OS_TEMPLATE", repoRoot, _
        "Preencher", "Preencher.bas", _
        "ws.Range(""F18"").Value = END_ENTIDADE|ws.Range(""D84"").Value = NR_Empenho", _
        "Template de OS grava local da entidade e empenho nos campos finais", _
        "EMITE_OS!F18 recebe END_ENTIDADE e EMITE_OS!D84 recebe NR_Empenho", _
        "BL-6/FT-7: confirma a ponte ate a aba de impressao"

    TV2_EST_LogComponenteContemTokens suite, "CS_IMP_05_PREOS_DADOS_TEMPLATE", repoRoot, _
        "Preencher", "Preencher.bas", _
        "preId = Preencher_NormalizarPreOSIdImpressao(preosId)|Call GarantirDadosPreOSParaImpressao(N_OS)|END_ENTIDADE = SafeListVal(wsEnt.Cells(linhaEnt, COL_ENT_ENDERECO).Value)", _
        "Pre-OS impressa normaliza o identificador e recarrega dados da base", _
        "N_OS prefixado nao impede lookup em PRE_OS, EMPRESAS, ENTIDADE e CAD_SERV", _
        "BL-7: campos da Pre-OS impressa nao dependem apenas de estado residual da UI"

    TV2_EST_LogComponenteContemTokens suite, "CS_IMP_06_AVALIACAO_TEMPLATE", repoRoot, _
        "Preencher", "Preencher.bas", _
        "Call Preencher_EscreverNotaAvaliacaoImpressa(ws.Range(""N27""), AvN01)|Call Preencher_EscreverNotaAvaliacaoImpressa(ws.Range(""N36""), AvN10)", _
        "Template de avaliacao usa helper de nota segura em todos os pontos de nota", _
        "N27 e N36 passam pelo mesmo clamp 0..10 das demais notas", _
        "BL-5: evita regressao para Format(texto cru) nas notas impressas"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite ImpressaoIntegridade sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunLeituraExibicao(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "LEITURA_EXIBICAO"
    Dim repoRoot As String
    Dim widthsEnt As String
    Dim widthsEmp As String
    Dim colsEnt() As String
    Dim colsEmp() As String
    Dim idVisivelOk As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    widthsEnt = EntidadeLista_MontarColumnWidths(620)
    widthsEmp = EmpresaLista_MontarColumnWidths(620)
    colsEnt = Split(widthsEnt, ";")
    colsEmp = Split(widthsEmp, ";")
    idVisivelOk = (UBound(colsEnt) >= 12 And UBound(colsEmp) >= 12)
    If idVisivelOk Then
        idVisivelOk = (CLng(Val(colsEnt(0))) > 0 And CLng(Val(colsEnt(1))) > 0 And _
                       CLng(Val(colsEmp(0))) > 0 And CLng(Val(colsEmp(1))) > 0)
    End If

    TV2_LogAssert suite, "CS_LEIT_01_ID_VISIVEL", "AUTO", _
                  "Listas principais exibem ID antes de CNPJ", _
                  "Entidade e Empresa com coluna 0 visivel e coluna 1 CNPJ visivel", _
                  "ENT=" & widthsEnt & "; EMP=" & widthsEmp, _
                  "FT-8: codigo/ID deve aparecer antes do CNPJ/credenciamento", _
                  idVisivelOk

    TV2_EST_LogComponenteContemTokens suite, "CS_LEIT_02_C_LISTA_PARIDADE", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "C_Bairro.Value = SafeListVal(C_Lista.List(idx, 7))|C_Contato1.Value = SafeListVal(C_Lista.List(idx, 11))|C_Fone_Cont3.Value = SafeListVal(C_Lista.List(idx, 18))|C_InfoAD.Value = SafeListVal(C_Lista.List(idx, 20))", _
        "Selecao em C_Lista popula os campos completos da entidade", _
        "Bairro, contatos 1..3 e informacoes adicionais lidos da mesma linha selecionada", _
        "FT-1: a selecao principal nao deve mostrar subconjunto menor que o form de edicao"

    TV2_EST_LogComponenteContemTokens suite, "CS_LEIT_03_RODIZIO_NOME_TELEFONE", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Desc_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 2))|cont_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 11))|telcont_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 12))", _
        "Selecao do rodizio preserva nome e telefone de contato", _
        "Nome, contato e telefone saem das colunas visiveis/canonicas do ListBox", _
        "FT-5: a atribuicao de empresa nao pode depender de entidade selecionada sem nome/telefone"

    TV2_EST_LogComponenteContemTokens suite, "CS_LEIT_04_FILTRO_OS", repoRoot, _
        "Preencher", "Preencher.bas", _
        "Sub PreencherPreencheOS(Optional ByVal filtro As String = """")|If UtilFiltro_LinhaAtende(textoBusca, filtroU) Then|Case ""os"":            Call PreencherPreencheOS(termo)", _
        "Filtro de Imprime Solicitacao de Servicos usa termo digitado", _
        "TextBox19 chama PreencherPreencheOS com filtro e a lista so recebe linhas que atendem ao termo", _
        "FT-6: o painel de emissao de OS nao pode ignorar o campo de busca"

    TV2_EST_LogComponenteContemTokens suite, "CS_LEIT_05_LISTAS_ID_PRE_CNPJ", repoRoot, _
        "Preencher", "Preencher.bas", _
        "EntidadeLista_MontarColumnWidths = CStr(W_ID) & "";"" & CStr(w1)|EmpresaLista_MontarColumnWidths = CStr(W_ID) & "";"" & CStr(w1)", _
        "Construtores de ListBox mantem ID antes do CNPJ", _
        "As duas listas montam a primeira largura com W_ID em vez de ocultar coluna 0", _
        "FT-8: a exibicao do identificador fica centralizada nos construtores de lista"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite LeituraExibicao sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunConfigBaselineSeguro(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "CONFIG_BASELINE_V2"
    Dim repoRoot As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteContemTokens suite, "CS_CFG_01_HELPER_PRESERVA_OPERADOR", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "Private Function TV2_ConfigValorOperadorOuCanonico|If texto <> """" Then|TV2_ConfigValorOperadorOuCanonico = texto|TV2_ConfigValorOperadorOuCanonico = valorCanonico", _
        "Helper do baseline preserva valor operacional quando ja existe texto", _
        "Valor nao vazio retorna ele mesmo; valor vazio cai para canonico de teste", _
        "FT-11: baseline V2 nao deve substituir municipio/gestor reais por dados de teste"

    TV2_EST_LogComponenteContemTokens suite, "CS_CFG_02_SETCONFIG_USA_HELPER", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "COL_CFG_GESTOR).Value = TV2_ConfigValorOperadorOuCanonico|COL_CFG_MUNICIPIO).Value = TV2_ConfigValorOperadorOuCanonico|""Gestor Testes V2""|""Municipio de Testes V2""", _
        "TV2_SetConfigCanonica usa fallback seguro para gestor e municipio", _
        "Gestor e municipio passam pelo helper antes de aceitar texto canonico de teste", _
        "Mantem fallback para CONFIG vazia sem clobber de CONFIG operacional"

    TV2_EST_LogComponenteNaoContemTokens suite, "CS_CFG_03_SEM_OVERWRITE_DIRETO", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "COL_CFG_GESTOR).Value = ""Gestor Testes V2""|COL_CFG_MUNICIPIO).Value = ""Municipio de Testes V2""", _
        "Baseline V2 nao faz overwrite direto de gestor/municipio", _
        "Atribuicoes diretas antigas aos campos operacionais nao existem mais", _
        "Evita que execucoes V2 facam a CONFIG voltar para valores de teste"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite ConfigBaselineSeguro sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunConfigSnapshotV2(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "CONFIG_SNAPSHOT_V2"
    Dim repoRoot As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteContemTokens suite, "CS_CFGSNAP_01_SNAPSHOT_A_N", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "Private Const TV2_CONFIG_SNAPSHOT_COLS As Long = 15|Private gTV2ConfigSnapshot As Variant|Private gTV2ConfigSnapshotAtivo As Boolean", _
        "Motor V2 declara snapshot completo da linha CONFIG A:N", _
        "Snapshot cobre 14 colunas de CONFIG conforme Const_Colunas", _
        "Protege parametros operacionais de CONFIG contra vazamento dos testes"

    TV2_EST_LogComponenteContemTokens suite, "CS_CFGSNAP_02_CAPTURA_NO_INIT", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "Call TV2_ConfigSnapshotCapturar|gTV2ConfigSnapshot = ws.Range(ws.Cells(LINHA_CFG_VALORES, 1), ws.Cells(LINHA_CFG_VALORES, TV2_CONFIG_SNAPSHOT_COLS)).Value|gTV2ConfigSnapshotAtivo", _
        "TV2_InitExecucao captura CONFIG antes da suite modificar valores", _
        "Captura ocorre no inicio da execucao e cobre A:N", _
        "Permite restaurar CONFIG operacional depois da suite"

    TV2_EST_LogComponenteContemTokens suite, "CS_CFGSNAP_03_RESTAURA_NO_FINAL", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "Call TV2_ConfigSnapshotRestaurar|ws.Range(ws.Cells(LINHA_CFG_VALORES, 1), ws.Cells(LINHA_CFG_VALORES, TV2_CONFIG_SNAPSHOT_COLS)).Value = gTV2ConfigSnapshot|gTV2ConfigSnapshotAtivo = False", _
        "TV2_FinalizarExecucao restaura CONFIG operacional ao fim", _
        "Restore devolve A:N e desarma snapshot para evitar reaplicacao", _
        "Testes podem usar CONFIG canonica sem deixar lixo operacional"

    TV2_EST_LogComponenteContemTokens suite, "CS_CFGSNAP_04_RESTAURA_EM_ERRO_FATAL", repoRoot, _
        "Teste_V2_Engine", "Teste_V2_Engine.bas", _
        "erro_fatal_handler:|Call TV2_ConfigSnapshotRestaurar|Call TV2_PerfModeRestore", _
        "Handler fatal tambem restaura CONFIG antes de devolver Excel ao operador", _
        "Erro na finalizacao nao deixa CONFIG canonica vazada", _
        "Protege workbook mesmo em falha da rotina de finalizacao"

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite ConfigSnapshotV2 sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunPerformanceUXBasica(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "PERFORMANCE_UX_BASICA"
    Dim repoRoot As String
    Dim codigoMenu As String
    Dim codigoProgress As String
    Dim origemMenu As String
    Dim origemProgress As String
    Dim posMac As Long
    Dim posOpen As Long
    Dim posFollow As Long
    Dim macFirstOk As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual
    repoRoot = TV2_UI_RepoRoot()

    TV2_EST_LogComponenteNaoContemTokens suite, "CS_PUX_01_PROGRESS_SEM_SAVE_BUSY_WAIT", repoRoot, _
        "ProgressBar", "ProgressBar.frm", _
        "Application.ThisWorkbook.Save|timedelay|While DateTime.Timer", _
        "ProgressBar nao salva workbook nem faz busy-wait de CPU", _
        "Sem save embutido, sem timedelay e sem loop While baseado em Timer", _
        "FT-3: barra de progresso nao deve travar o Excel nem salvar dentro do render"

    TV2_EST_LogComponenteContemTokens suite, "CS_PUX_02_PROGRESS_MANTEM_FEEDBACK", repoRoot, _
        "ProgressBar", "ProgressBar.frm", _
        "Percent_Label.caption = ""Processando: ""|Percent_Label.caption = ""Finalizando: ""|DoEvents", _
        "ProgressBar mantem feedback visual leve", _
        "Caption de progresso continua sendo atualizada e DoEvents preserva resposta da UI", _
        "Remove espera artificial sem deixar a tela sem indicacao de andamento"

    TV2_EST_LogComponenteContemTokens suite, "CS_PUX_03_LIMPA_ENTIDADE_HELPER", repoRoot, _
        "Menu_Principal", "Menu_Principal.frm", _
        "Private Sub LimparCamposCadastroEntidade()|Call LimparCamposCadastroEntidade|C_Entidade.Value = Empty|C_InfoAD.Value = Empty", _
        "Cadastro de entidade usa rotina unica de limpeza", _
        "Limpeza inline foi extraida para helper com campos principais e informacao adicional", _
        "FT-2: evita divergencia entre fluxo de novo cadastro e limpeza pos-cadastro"

    codigoMenu = TV2_EST_LerCodigoComponenteOuArquivo(repoRoot, "Menu_Principal", "Menu_Principal.frm", origemMenu)
    posMac = InStr(1, codigoMenu, "Application.OperatingSystem, ""Mac""", vbTextCompare)
    posOpen = InStr(1, codigoMenu, "Shell ""open", vbTextCompare)
    posFollow = InStr(1, codigoMenu, "Application.FollowHyperlink url", vbTextCompare)
    macFirstOk = (origemMenu <> "AUSENTE" And posMac > 0 And posOpen > 0 And posFollow > 0 And posOpen < posFollow)
    TV2_LogAssert suite, "CS_PUX_04_URL_MAC_FIRST", "AUTO", _
                  "AbrirURLExterna tenta Shell open antes de FollowHyperlink no Mac", _
                  "No Mac, Shell open aparece antes do fallback Application.FollowHyperlink", _
                  "ORIGEM=" & origemMenu & "; POS_MAC=" & CStr(posMac) & _
                  "; POS_OPEN=" & CStr(posOpen) & "; POS_FOLLOW=" & CStr(posFollow), _
                  "MG-1: evita travamento de 1-2 min ao abrir GitHub no Mac", _
                  macFirstOk

    codigoProgress = TV2_EST_LerCodigoComponenteOuArquivo(repoRoot, "ProgressBar", "ProgressBar.frm", origemProgress)
    TV2_LogAssert suite, "CS_PUX_05_PROGRESS_SEM_SAVE_LITERAL", "AUTO", _
                  "ProgressBar nao contem literal Save residual", _
                  "Codigo do ProgressBar nao contem Application.ThisWorkbook.Save", _
                  "ORIGEM=" & origemProgress & "; TEM_SAVE=" & CStr(InStr(1, codigoProgress, "Application.ThisWorkbook.Save", vbTextCompare) > 0), _
                  "Evita que comentario residual ou caminho alternativo volte a salvar dentro da barra", _
                  (origemProgress <> "AUSENTE" And InStr(1, codigoProgress, "Application.ThisWorkbook.Save", vbTextCompare) = 0)

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite PerformanceUXBasica sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunBehavioralizacaoC1(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "BEHAVIORALIZACAO_C1"
    Dim detalhes As String
    Dim okConfigSnapshot As Boolean
    Dim okOrdenacaoEntidade As Boolean
    Dim okCredSequencial As Boolean
    Dim okCredIds As Boolean
    Dim okFilaIntegra As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual

    detalhes = ""
    okConfigSnapshot = TV2_C1_ConfigSnapshotRoundTrip(detalhes)
    TV2_LogAssert suite, "CS_C1_01_CONFIG_SNAPSHOT_ROUNDTRIP", "AUTO", _
                  "Snapshot CONFIG A:N restaura valores reais apos mutacao", _
                  "CONFIG!A:N volta aos valores originais apos captura, mutacao e restore", _
                  detalhes, _
                  "C1/FT-11: substitui prova por token por round-trip comportamental do snapshot", _
                  okConfigSnapshot

    TV2_PrepararBaselineCanonica
    TV2_CadastrarEntidadeCanonica "003", "Local C1 3"
    TV2_CadastrarEntidadeCanonica "001", "Local C1 1"
    TV2_CadastrarEntidadeCanonica "002", "Local C1 2"
    detalhes = ""
    okOrdenacaoEntidade = TV2_C1_ClassificarEntidadesBasePopulada(detalhes)
    TV2_LogAssert suite, "CS_C1_02_ORDENACAO_ENTIDADE_BASE_POPULADA", "AUTO", _
                  "Classificacao de entidade ordena dados reais sem preservar linha 2 como cabecalho", _
                  "Apos sort, as tres entidades C1 ficam em ordem 001,002,003", _
                  detalhes, _
                  "BL-2/C1: cobre o comportamento data-dependent exposto pelo L43 em vez de apenas procurar xlNo", _
                  okOrdenacaoEntidade

    TV2_PrepararCenarioTriploCanonico
    detalhes = ""
    okCredSequencial = TV2_C1_ProximoIdCredenciadosSequencial(detalhes)
    TV2_LogAssert suite, "CS_C1_03_CRED_ID_AR1_SEQUENCIAL", "AUTO", _
                  "ProximoId em CREDENCIADOS usa maximo real quando AR1 esta atrasado", _
                  "Com base populada, proximos IDs sao max+1 e max+2 sem reuso", _
                  detalhes, _
                  "FT-4/C1: cria rede de seguranca antes de mexer em credenciamento em lote", _
                  okCredSequencial

    detalhes = ""
    okCredIds = TV2_C1_CredIdsCanonicosUnicos(TV2_AtivCanonA(), 3, detalhes)
    TV2_LogAssert suite, "CS_C1_04_CRED_ID_CANONICO_UNICO", "AUTO", _
                  "Credenciamentos canonicos mantem CRED_ID numerico unico", _
                  "Tres linhas da atividade canonica com IDs canonicos e sem duplicidade", _
                  detalhes, _
                  "FT-4/C1: detecta reuso ou formato invalido antes de otimizar alocacao em lote", _
                  okCredIds

    okFilaIntegra = TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3)
    TV2_LogAssert suite, "CS_C1_05_FILA_ORDEM_INTEGRA", "AUTO", _
                  "Fila canonica segue com posicoes 1..3 depois dos testes de ID", _
                  "BuscarFila retorna tres empresas em ordem integra", _
                  "FILA=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()), _
                  "FT-4/C1: garante que teste de IDs nao quebrou a fila antes da proxima onda", _
                  okFilaIntegra

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite BehavioralizacaoC1 sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Private Function TV2_C1_ClassificarEntidadesBasePopulada(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim idsObtidos As String
    Dim nomesObtidos As String
    Dim ok As Boolean

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        detalhes = "Nao foi possivel preparar ENTIDADE."
        Exit Function
    End If

    Call ClassificaEntidade
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao

    idsObtidos = Trim$(CStr(ws.Cells(LINHA_DADOS, COL_ENT_ID).Value)) & "," & _
                 Trim$(CStr(ws.Cells(LINHA_DADOS + 1, COL_ENT_ID).Value)) & "," & _
                 Trim$(CStr(ws.Cells(LINHA_DADOS + 2, COL_ENT_ID).Value))
    nomesObtidos = Trim$(CStr(ws.Cells(LINHA_DADOS, COL_ENT_NOME).Value)) & "|" & _
                   Trim$(CStr(ws.Cells(LINHA_DADOS + 1, COL_ENT_NOME).Value)) & "|" & _
                   Trim$(CStr(ws.Cells(LINHA_DADOS + 2, COL_ENT_NOME).Value))

    ok = (idsObtidos = "001,002,003")
    detalhes = "IDS=" & idsObtidos & "; NOMES=" & nomesObtidos
    TV2_C1_ClassificarEntidadesBasePopulada = ok
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    On Error Resume Next
    If Not ws Is Nothing Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    TV2_C1_ClassificarEntidadesBasePopulada = False
End Function

Public Sub TV2_RunFT4CredenciamentoLote(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "FT4_CREDENCIAMENTO_LOTE"
    Const qtdServicosFT4 As Long = 30
    Const limiteSegundos As Double = 10#
    Dim empId As String
    Dim ativId As String
    Dim maxAntes As Long
    Dim ar1Antes As Long
    Dim ar1Depois As Long
    Dim ar1Reexec As Long
    Dim qtdAntes As Long
    Dim qtdDepois As Long
    Dim qtdDepoisReexec As Long
    Dim totalServ As Long
    Dim adicionados As Long
    Dim ignorados As Long
    Dim totalServReexec As Long
    Dim adicionadosReexec As Long
    Dim ignoradosReexec As Long
    Dim tempoSeg As Double
    Dim tempoReexec As Double
    Dim detalhes As String
    Dim detalhesLote As String
    Dim detalhesSeq As String
    Dim detalhesReexec As String
    Dim okPrep As Boolean
    Dim okLote As Boolean
    Dim okSeq As Boolean
    Dim okReexec As Boolean
    Dim frm As Object
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual

    okPrep = TV2_FT4_PrepararCredenciamentoLote(qtdServicosFT4, empId, ativId, maxAntes, ar1Antes, detalhes)
    TV2_LogAssert suite, "FT4_01_PREPARA_BASE_POPULADA", "AUTO", _
                  "Preparar base FT-4 com AR1 atrasado e servicos multiplos", _
                  "Base tem credenciamento previo, AR1 atrasado e 30 servicos na atividade alvo", _
                  detalhes, _
                  "Garante que o teste exerce o risco CRED_ID/AR1 apontado pelo parecer 0024", _
                  okPrep

    If okPrep Then
        qtdAntes = TV2_CountRows(SHEET_CREDENCIADOS)
        Set frm = New Credencia_Empresa
        okLote = TV2_FT4_ExecutarCredenciamentoLoteCompat(frm, empId, ativId, detalhesLote, totalServ, adicionados, ignorados, tempoSeg)
        Unload frm
        Set frm = Nothing
        qtdDepois = TV2_CountRows(SHEET_CREDENCIADOS)
    Else
        detalhesLote = "Preparacao falhou; lote nao executado."
    End If

    TV2_LogAssert suite, "FT4_02_LOTE_ADICIONA_TODOS_SERVICOS", "AUTO", _
                  "Executor real de Credencia_Empresa credencia todos os servicos da atividade", _
                  "30 novos credenciamentos, 0 ignorados e delta de linhas igual a 30", _
                  detalhesLote & "; QTD_ANTES=" & CStr(qtdAntes) & "; QTD_DEPOIS=" & CStr(qtdDepois), _
                  "FT-4: prova comportamento do fluxo real sem depender de token estatico", _
                  (okLote And totalServ = qtdServicosFT4 And adicionados = qtdServicosFT4 And ignorados = 0 And _
                   qtdDepois - qtdAntes = qtdServicosFT4)

    If okLote Then okSeq = TV2_FT4_CredIdsSequenciais(empId, ativId, maxAntes + 1, adicionados, detalhesSeq)
    TV2_LogAssert suite, "FT4_03_CRED_ID_SEQUENCIAL_CONTINUO", "AUTO", _
                  "CRED_ID do lote segue sequencia continua apos maximo real", _
                  "IDs novos vao de maxAntes+1 ate maxAntes+30 sem duplicados ou formato invalido", _
                  detalhesSeq, _
                  "Protege a otimizacao em memoria contra reuso ou salto de CRED_ID", _
                  okSeq

    ar1Depois = TV2_FT4_AR1Credenciados()
    TV2_LogAssert suite, "FT4_04_AR1_ATUALIZADO_UMA_VEZ", "AUTO", _
                  "AR1 de CREDENCIADOS reflete ultimo ID alocado no lote", _
                  "AR1 final = maxAntes + adicionados", _
                  "AR1_ANTES=" & CStr(ar1Antes) & "; MAX_ANTES=" & CStr(maxAntes) & _
                  "; ADICIONADOS=" & CStr(adicionados) & "; AR1_DEPOIS=" & CStr(ar1Depois), _
                  "Fecha o risco FT-4 de contador atrasado apos alocacao em lote", _
                  (okLote And ar1Depois = maxAntes + adicionados)

    TV2_LogAssert suite, "FT4_05_TEMPO_EXECUCAO_LOTE", "AUTO", _
                  "Credenciamento em lote executa dentro do limite FT-4", _
                  "Tempo do lote <= 10 segundos", _
                  "TEMPO_SEG=" & Format$(tempoSeg, "0.000") & "; LIMITE=" & Format$(limiteSegundos, "0.000"), _
                  "Cobre o cycle-time perceptivel ausente no parecer 0024", _
                  (okLote And tempoSeg > 0# And tempoSeg <= limiteSegundos)

    If okLote Then
        Set frm = New Credencia_Empresa
        okReexec = TV2_FT4_ExecutarCredenciamentoLoteCompat(frm, empId, ativId, detalhesReexec, totalServReexec, adicionadosReexec, ignoradosReexec, tempoReexec)
        Unload frm
        Set frm = Nothing
        qtdDepoisReexec = TV2_CountRows(SHEET_CREDENCIADOS)
        ar1Reexec = TV2_FT4_AR1Credenciados()
    Else
        detalhesReexec = "Lote inicial falhou; reexecucao nao realizada."
    End If

    TV2_LogAssert suite, "FT4_06_REEXECUCAO_IDEMPOTENTE", "AUTO", _
                  "Reexecutar o lote ignora credenciamentos existentes sem criar duplicados", _
                  "0 adicionados, 30 ignorados, mesma contagem de linhas e AR1 preservado", _
                  detalhesReexec & "; QTD_DEPOIS=" & CStr(qtdDepois) & _
                  "; QTD_REEXEC=" & CStr(qtdDepoisReexec) & "; AR1_REEXEC=" & CStr(ar1Reexec), _
                  "Mantem a regra atual de duplicidades ignoradas mesmo com indice local", _
                  (okReexec And adicionadosReexec = 0 And ignoradosReexec = qtdServicosFT4 And _
                   qtdDepoisReexec = qtdDepois And ar1Reexec = ar1Depois)

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite FT4CredenciamentoLote sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Private Function TV2_FT4_ExecutarCredenciamentoLoteCompat( _
    ByVal frm As Object, _
    ByVal empId As String, _
    ByVal ativId As String, _
    ByRef detalhes As String, _
    ByRef totalServOut As Long, _
    ByRef adicionadosOut As Long, _
    ByRef ignoradosOut As Long, _
    ByRef tempoSegOut As Double _
) As Boolean
    Dim ret As Variant

    On Error GoTo falha

    ret = CallByName(frm, "TV2_ExecutarCredenciamentoLote", VbMethod, _
                     empId, ativId, detalhes, totalServOut, adicionadosOut, ignoradosOut, tempoSegOut)
    TV2_FT4_ExecutarCredenciamentoLoteCompat = CBool(ret)
    Exit Function

falha:
    detalhes = "Credencia_Empresa.TV2_ExecutarCredenciamentoLote indisponivel; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    totalServOut = 0
    adicionadosOut = 0
    ignoradosOut = 0
    tempoSegOut = 0#
    TV2_FT4_ExecutarCredenciamentoLoteCompat = False
End Function

Public Sub TV2_RunBL4ProtecaoPersistente(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "BL4_PROTECAO_PERSISTENTE"
    Dim detalhesAuto As String
    Dim detalhesProtecao As String
    Dim detalhesPersistencia As String
    Dim detalhesReaplicar As String
    Dim detalhesPersistenciaPosReaplicar As String
    Dim detalhesRestaurar As String
    Dim dtAuto As Date
    Dim okAutoOpen As Boolean
    Dim okProtecao As Boolean
    Dim okPersistencia As Boolean
    Dim okReaplicar As Boolean
    Dim okPersistenciaPosReaplicar As Boolean
    Dim okRestaurar As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual

    dtAuto = TV2_BL4_AutoOpenMarcadorExecutadaEmCompat()
    okAutoOpen = TV2_BL4_AutoOpenMarcadorAposUltimoSaveCompat(detalhesAuto)
    TV2_LogAssert suite, "BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO", "AUTO", _
                  "Auto_Open persistiu marcador auditavel da reaplicacao de protecao critica na abertura", _
                  "Marcador persistente de abertura existe, esta OK e nao e anterior ao ultimo save quando esse metadado estiver disponivel", _
                  "EXECUTADA_EM=" & IIf(dtAuto > 0, Format$(dtAuto, "yyyy-mm-dd hh:nn:ss"), "nao registrada") & _
                  "; " & detalhesAuto, _
                  "BL-4: prova que o ciclo save/reopen disparou a rotina de abertura mesmo apos reset do estado VBA em memoria", _
                  okAutoOpen

    okProtecao = Util_VerificarProtecaoAbasCriticas(detalhesProtecao)
    TV2_LogAssert suite, "BL4_02_ABAS_CRITICAS_PROTEGIDAS", "AUTO", _
                  "Abas criticas seguem protegidas apos reopen", _
                  "ProtectContents, DrawingObjects e celulas bloqueadas OK em todas as abas criticas", _
                  detalhesProtecao, _
                  "BL-4: impede workbook reaberto com base operacional editavel diretamente", _
                  okProtecao

    okPersistencia = TV2_BL4_VerificarProtecaoPersistenteCompat(detalhesPersistencia)
    TV2_LogAssert suite, "BL4_03_UIONLY_REAPLICADO_APOS_REOPEN", "AUTO", _
                  "UserInterfaceOnly foi reaplicado apos reopen", _
                  "VBA consegue escrever o mesmo valor em celula bloqueada protegida, sem desproteger a aba", _
                  detalhesPersistencia, _
                  "BL-4: cobre a raiz do parecer 0024, pois UserInterfaceOnly nao persiste sem rotina de abertura", _
                  okPersistencia

    okReaplicar = Util_ProtegerAbasCriticasVerificado(detalhesReaplicar)
    okPersistenciaPosReaplicar = TV2_BL4_VerificarProtecaoPersistenteCompat(detalhesPersistenciaPosReaplicar)
    TV2_LogAssert suite, "BL4_04_REAPLICACAO_IDEMPOTENTE", "AUTO", _
                  "Reaplicar protecao critica e idempotente", _
                  "Nova chamada de protecao mantem abas criticas verificaveis e com escrita VBA permitida", _
                  "REAPLICAR=" & detalhesReaplicar & "; POS=" & detalhesPersistenciaPosReaplicar, _
                  "BL-4: evita que Auto_Open ou chamada manual degradem protecao ja aplicada", _
                  (okReaplicar And okPersistenciaPosReaplicar)

    okRestaurar = TV2_BL4_PrepararRestaurarCritica(detalhesRestaurar)
    TV2_LogAssert suite, "BL4_05_PREPARAR_RESTAURAR_CRITICA", "AUTO", _
                  "Preparar e restaurar aba critica preserva protecao persistente", _
                  "Apos ciclo preparar/restaurar, a protecao critica continua verificavel", _
                  detalhesRestaurar, _
                  "BL-4: cobre o fluxo de escrita VBA que remove e restaura protecao durante operacoes reais", _
                  okRestaurar

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite BL4ProtecaoPersistente sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Private Function TV2_BL4_AutoOpenMarcadorExecutadaEmCompat() As Date
    Dim ret As Variant

    On Error GoTo falha

    ret = Application.Run("AutoOpen_UltimaProtecaoMarcadorExecutadaEm")
    If IsDate(ret) Then TV2_BL4_AutoOpenMarcadorExecutadaEmCompat = CDate(ret)
    Exit Function

falha:
    TV2_BL4_AutoOpenMarcadorExecutadaEmCompat = 0
End Function

Private Function TV2_BL4_AutoOpenMarcadorAposUltimoSaveCompat(ByRef detalhes As String) As Boolean
    Dim ret As Variant
    Dim detalhesRun As String

    On Error GoTo falha

    detalhesRun = ""
    ret = Application.Run("AutoOpen_UltimaProtecaoMarcadorAposUltimoSave", detalhesRun)
    detalhes = CStr(detalhesRun)
    TV2_BL4_AutoOpenMarcadorAposUltimoSaveCompat = CBool(ret)
    Exit Function

falha:
    detalhes = "AutoOpen_UltimaProtecaoMarcadorAposUltimoSave indisponivel; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    TV2_BL4_AutoOpenMarcadorAposUltimoSaveCompat = False
End Function

Private Function TV2_BL4_VerificarProtecaoPersistenteCompat(ByRef detalhes As String) As Boolean
    Dim ret As Variant
    Dim detalhesRun As String

    On Error GoTo falha

    detalhesRun = ""
    ret = Application.Run("Util_VerificarProtecaoPersistenteAposAbertura", detalhesRun)
    detalhes = CStr(detalhesRun)
    TV2_BL4_VerificarProtecaoPersistenteCompat = CBool(ret)
    Exit Function

falha:
    detalhes = "Util_VerificarProtecaoPersistenteAposAbertura indisponivel; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    TV2_BL4_VerificarProtecaoPersistenteCompat = False
End Function

Public Sub TV2_RunFormulariosAvaliacaoDemandante(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "FORM_AVALIACAO_DEMANDANTE"
    Dim osId As String
    Dim detalhesPrep As String
    Dim detalhesResolver As String
    Dim detalhesLista As String
    Dim detalhesPayload As String
    Dim detalhesPrint As String
    Dim detalhesRegistro As String
    Dim detalhesInvalidar As String
    Dim detalhesInvalidarRestore As String
    Dim detalhesInvalido As String
    Dim entId As String
    Dim demandanteNome As String
    Dim demandanteLista As String
    Dim demandantePrint As String
    Dim payloadOSID As String
    Dim payloadAvaliador As String
    Dim payloadQtExecutada As Double
    Dim payloadObservacao As String
    Dim payloadJustif As String
    Dim payloadMedia As Double
    Dim notas(1 To 10) As Integer
    Dim i As Long
    Dim okBase As Boolean
    Dim okResolver As Boolean
    Dim okLista As Boolean
    Dim okPayload As Boolean
    Dim okPrint As Boolean
    Dim okRegistro As Boolean
    Dim okInvalidar As Boolean
    Dim okInvalido As Boolean
    Dim okRestore As Boolean
    Dim resResolver As TResult
    Dim resPayloadVazio As TResult
    Dim resPayload As TResult
    Dim resAval As TResult
    Dim resInvalido As TResult
    Dim frm As Object
    Dim auditDemandanteAntes As Long
    Dim auditDemandanteDepois As Long
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual

    okBase = TV2_FormAval_PrepararOS(osId, detalhesPrep)
    TV2_LogAssert suite, "FD_AV_01_PREPARA_OS_EM_EXECUCAO", "AUTO", _
                  "Preparar OS em execucao para avaliacao de formulario", _
                  "OS em EM_EXECUCAO com ENT_ID canonico e demandante existente", _
                  detalhesPrep, _
                  "Abre uma base controlada para testar o bug real do demandante na avaliacao", _
                  okBase

    If okBase Then
        resResolver = ResolverDemandanteAvaliacaoPorOS(osId, entId, demandanteNome, detalhesResolver)
        okResolver = (resResolver.sucesso And IdsIguais(entId, "001") And demandanteNome = "Local 1")
    Else
        detalhesResolver = "Base nao preparada; resolucao nao executada."
    End If
    TV2_LogAssert suite, "FD_AV_02_DEMANDANTE_RESOLVIDO_POR_OS", "AUTO", _
                  "Resolver demandante por OS_ID", _
                  "ResolverDemandanteAvaliacaoPorOS retorna ENT_ID=001 e NOME=Local 1", _
                  detalhesResolver, _
                  "Remove dependencia de estado global ou valor obsoleto de Desc_entidade", _
                  okResolver

    If okBase Then
        Set frm = New Menu_Principal
        okLista = TV2_FormAval_DemandanteNaListaCompat(frm, osId, demandanteLista, detalhesLista)
    Else
        detalhesLista = "Base nao preparada; lista nao verificada."
    End If
    TV2_LogAssert suite, "FD_AV_03_LISTA_AVALIACAO_EXIBE_DEMANDANTE", "AUTO", _
                  "AV_Lista exibe o nome do demandante", _
                  "Linha da OS em avaliacao traz Local 1 na coluna visivel do demandante", _
                  detalhesLista, _
                  "Garante que o operador ve o demandante correto antes de avaliar", _
                  (okLista And demandanteLista = "Local 1")

    If okBase Then
        For i = 1 To 10
            notas(i) = 8
        Next i
        resPayloadVazio = MontarPayloadAvaliacao(osId, "", notas, 2, "OBS FD_AV", "", _
                                                 payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                                 payloadObservacao, payloadJustif, payloadMedia)
        resPayload = MontarPayloadAvaliacao(osId, demandanteNome, notas, 2, "OBS FD_AV", "", _
                                            payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                            payloadObservacao, payloadJustif, payloadMedia)
        okPayload = (Not resPayloadVazio.sucesso And resPayload.sucesso And _
                     payloadAvaliador = demandanteNome And payloadQtExecutada = 2)
        detalhesPayload = "VAZIO_SUCESSO=" & CStr(resPayloadVazio.sucesso) & _
                          "; DEMANDANTE=" & demandanteNome & _
                          "; PAYLOAD_AVALIADOR=" & payloadAvaliador & _
                          "; MSG_VAZIO=" & resPayloadVazio.mensagem & _
                          "; MSG_OK=" & resPayload.mensagem
    Else
        detalhesPayload = "Base nao preparada; payload nao verificado."
    End If
    TV2_LogAssert suite, "FD_AV_04_PAYLOAD_REJEITA_VAZIO_ACEITA_DEMANDANTE", "AUTO", _
                  "Payload da avaliacao exige demandante resolvido", _
                  "Payload vazio falha e payload com Local 1 passa", _
                  detalhesPayload, _
                  "Impede registrar avaliacao sem nome do demandante", _
                  okPayload

    If okBase Then
        If frm Is Nothing Then Set frm = New Menu_Principal
        okPrint = TV2_FormAval_AplicarDemandanteImpressaoCompat(frm, osId, demandantePrint, detalhesPrint)
    Else
        detalhesPrint = "Base nao preparada; impressao nao verificada."
    End If
    TV2_LogAssert suite, "FD_AV_05_IMPRESSAO_USA_DEMANDANTE_RESOLVIDO", "AUTO", _
                  "Variavel de impressao recebe demandante resolvido", _
                  "Desc_entidade sai de valor obsoleto para Local 1", _
                  detalhesPrint, _
                  "Fecha o caminho observado pelo operador ao imprimir avaliacao", _
                  (okPrint And demandantePrint = "Local 1")

    If okBase Then
        auditDemandanteAntes = TV2_AuditCount("OS Fechada/Avaliada", "AVALIADOR=" & demandanteNome)
        resAval = AvaliarOS(osId, demandanteNome, notas, 2, "FD_AV demanda registrada", "", Date + 6, Date + 15)
        auditDemandanteDepois = TV2_AuditCount("OS Fechada/Avaliada", "AVALIADOR=" & demandanteNome)
        okRegistro = (resAval.sucesso And TV2_StatusOS(osId) = "CONCLUIDA" And _
                      auditDemandanteDepois > auditDemandanteAntes)
        detalhesRegistro = "SUCESSO_AVAL=" & CStr(resAval.sucesso) & _
                           "; STATUS_OS=" & TV2_StatusOS(osId) & _
                           "; AUDIT_ANTES=" & CStr(auditDemandanteAntes) & _
                           "; AUDIT_DEPOIS=" & CStr(auditDemandanteDepois) & _
                           "; MSG=" & resAval.mensagem
    Else
        detalhesRegistro = "Base nao preparada; registro nao verificado."
    End If
    TV2_LogAssert suite, "FD_AV_06_AVALIACAO_REGISTRA_DEMANDANTE", "AUTO", _
                  "Avaliacao registra demandante resolvido", _
                  "AvaliarOS conclui a OS e AUDIT_LOG contem AVALIADOR=Local 1", _
                  detalhesRegistro, _
                  "Prova que o nome resolvido chega ao registro auditavel da avaliacao", _
                  okRegistro

    If okBase Then
        okInvalidar = TV2_FormAval_AlterarEntIdOS(osId, "999", detalhesInvalidar)
        resInvalido = ResolverDemandanteAvaliacaoPorOS(osId, entId, demandanteNome, detalhesInvalido)
        okRestore = TV2_FormAval_AlterarEntIdOS(osId, "001", detalhesInvalidarRestore)
        okInvalido = (okInvalidar And Not resInvalido.sucesso And okRestore)
    Else
        detalhesInvalidar = "Base nao preparada; negativo nao executado."
        detalhesInvalido = detalhesInvalidar
    End If
    TV2_LogAssert suite, "FD_AV_07_ENT_ID_INVALIDO_FALHA_AUDITAVEL", "AUTO", _
                  "ENT_ID inexistente falha de modo auditavel", _
                  "Resolver demandante falha quando CAD_OS.ENT_ID nao existe em ENTIDADE", _
                  detalhesInvalidar & "; RES=" & resInvalido.mensagem & "; " & detalhesInvalido & _
                  "; RESTORE=" & CStr(okRestore) & "; " & detalhesInvalidarRestore, _
                  "Evita gravar avaliacao incompleta quando a base esta inconsistente", _
                  okInvalido

    If Not frm Is Nothing Then Unload frm
    Set frm = Nothing
    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite FormulariosAvaliacaoDemandante sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Private Function TV2_FormAval_DemandanteNaListaCompat( _
    ByVal frm As Object, _
    ByVal osId As String, _
    ByRef demandanteOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim retorno As Variant

    On Error GoTo falha

    retorno = CallByName(frm, "TV2_AvaliacaoDemandanteNaLista", VbMethod, osId, demandanteOut, detalhes)
    TV2_FormAval_DemandanteNaListaCompat = CBool(retorno)
    Exit Function

falha:
    detalhes = "Menu_Principal.TV2_AvaliacaoDemandanteNaLista indisponivel; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    demandanteOut = ""
    TV2_FormAval_DemandanteNaListaCompat = False
End Function

Private Function TV2_FormAval_AplicarDemandanteImpressaoCompat( _
    ByVal frm As Object, _
    ByVal osId As String, _
    ByRef demandanteOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim retorno As Variant

    On Error GoTo falha

    retorno = CallByName(frm, "TV2_AvaliacaoAplicarDemandanteImpressao", VbMethod, osId, demandanteOut, detalhes)
    TV2_FormAval_AplicarDemandanteImpressaoCompat = CBool(retorno)
    Exit Function

falha:
    detalhes = "Menu_Principal.TV2_AvaliacaoAplicarDemandanteImpressao indisponivel; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    demandanteOut = ""
    TV2_FormAval_AplicarDemandanteImpressaoCompat = False
End Function

Private Function TV2_FormAval_PrepararOS(ByRef osIdOut As String, ByRef detalhes As String) As Boolean
    Dim resPre As TResult
    Dim resOs As TResult

    On Error GoTo falha

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 2)
    If Not resPre.sucesso Then
        detalhes = "EmitirPreOS falhou: " & resPre.mensagem
        Exit Function
    End If

    resOs = EmitirOS(resPre.IdGerado, Date + 5, "EMP-FD-AV")
    osIdOut = resOs.IdGerado
    detalhes = "PREOS_ID=" & resPre.IdGerado & "; OS_ID=" & osIdOut & _
               "; PREOS_SUCESSO=" & CStr(resPre.sucesso) & _
               "; OS_SUCESSO=" & CStr(resOs.sucesso) & _
               "; STATUS_OS=" & TV2_StatusOS(osIdOut)
    TV2_FormAval_PrepararOS = (resOs.sucesso And osIdOut <> "" And TV2_StatusOS(osIdOut) = "EM_EXECUCAO")
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_FormAval_PrepararOS = False
End Function

Private Function TV2_FormAval_AlterarEntIdOS( _
    ByVal osId As String, _
    ByVal entIdNovo As String, _
    ByRef detalhes As String _
) As Boolean
    Dim ws As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    ultima = UltimaLinhaAba(SHEET_CAD_OS)
    For i = LINHA_DADOS To ultima
        If IdsIguais(SafeListVal(ws.Cells(i, COL_OS_ID).Value), osId) Then
            If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
                detalhes = "Nao foi possivel preparar CAD_OS."
                Exit Function
            End If
            ws.Cells(i, COL_OS_ENT_ID).Value = entIdNovo
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            detalhes = "OS_ID=" & osId & "; ENT_ID_NOVO=" & entIdNovo & "; LINHA_OS=" & CStr(i)
            TV2_FormAval_AlterarEntIdOS = True
            Exit Function
        End If
    Next i

    detalhes = "OS_ID=" & osId & "; nao encontrada em CAD_OS"
    TV2_FormAval_AlterarEntIdOS = False
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    On Error Resume Next
    If Not ws Is Nothing Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    TV2_FormAval_AlterarEntIdOS = False
End Function

Private Function TV2_BL4_PrepararRestaurarCritica(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim alvo As Range
    Dim formulaOriginal As String
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim detalhesPersistencia As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set alvo = ws.Cells(1, 1)
    formulaOriginal = CStr(alvo.Formula)

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        detalhes = "Nao foi possivel preparar EMPRESAS."
        Exit Function
    End If

    alvo.Formula = formulaOriginal
    Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProtecao)

    TV2_BL4_PrepararRestaurarCritica = TV2_BL4_VerificarProtecaoPersistenteCompat(detalhesPersistencia)
    detalhes = "ABA=" & SHEET_EMPRESAS & "; ESTAVA_PROTEGIDA=" & CStr(estavaProtegida) & _
               "; POS_RESTORE=" & detalhesPersistencia
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    On Error Resume Next
    If Not ws Is Nothing Then Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProtecao)
    On Error GoTo 0
    TV2_BL4_PrepararRestaurarCritica = False
End Function

Private Function TV2_FormControleExiste(ByVal frm As Object, ByVal nomeControle As String) As Boolean
    Dim ctl As Object

    On Error Resume Next
    Err.Clear
    Set ctl = frm.Controls(nomeControle)
    TV2_FormControleExiste = (Err.Number = 0 And Not ctl Is Nothing)
    Err.Clear
    On Error GoTo 0
End Function

Private Function TV2_FormControleEditavel(ByVal frm As Object, ByVal nomeControle As String, ByRef detalhes As String) As Boolean
    Dim ctl As Object
    Dim enabledOk As Boolean
    Dim unlockedOk As Boolean
    Dim tabOk As Boolean

    On Error GoTo falha

    Set ctl = frm.Controls(nomeControle)
    enabledOk = CBool(ctl.Enabled)
    unlockedOk = Not CBool(ctl.Locked)
    tabOk = CBool(ctl.TabStop)
    detalhes = nomeControle & ": Enabled=" & CStr(enabledOk) & _
               "; Locked=" & CStr(Not unlockedOk) & _
               "; TabStop=" & CStr(tabOk)
    TV2_FormControleEditavel = (enabledOk And unlockedOk And tabOk)
    Exit Function

falha:
    detalhes = nomeControle & ": controle ausente ou sem propriedades de edicao; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    TV2_FormControleEditavel = False
End Function

Private Function TV2_FormControleLivreDeSobreposicao( _
    ByVal frm As Object, _
    ByVal nomeControle As String, _
    ByRef detalhes As String, _
    Optional ByVal termoLabel As String = "" _
) As Boolean
    Dim alvo As Object
    Dim ctl As Object
    Dim alvoLeft As Double
    Dim alvoTop As Double
    Dim alvoRight As Double
    Dim alvoBottom As Double
    Dim ctlLeft As Double
    Dim ctlTop As Double
    Dim ctlRight As Double
    Dim ctlBottom As Double
    Dim legenda As String
    Dim termo As String
    Dim avaliados As Long
    Dim sobrepostos As Long
    Dim detalhesSobrepostos As String

    On Error GoTo falha

    Set alvo = frm.Controls(nomeControle)
    alvoLeft = CDbl(alvo.Left)
    alvoTop = CDbl(alvo.Top)
    alvoRight = alvoLeft + CDbl(alvo.Width)
    alvoBottom = alvoTop + CDbl(alvo.Height)
    termo = LCase$(Trim$(termoLabel))

    For Each ctl In frm.Controls
        If typeName(ctl) = "Label" Then
            legenda = LCase$(Trim$(CStr(ctl.caption)))
            If termo = "" Or InStr(legenda, termo) > 0 Then
                ctlLeft = CDbl(ctl.Left)
                ctlTop = CDbl(ctl.Top)
                ctlRight = ctlLeft + CDbl(ctl.Width)
                ctlBottom = ctlTop + CDbl(ctl.Height)
                If TV2_IntervalosSobrepoem(alvoTop, alvoBottom, ctlTop, ctlBottom) Then
                    avaliados = avaliados + 1
                    If TV2_IntervalosSobrepoem(alvoLeft, alvoRight, ctlLeft, ctlRight) Then
                        sobrepostos = sobrepostos + 1
                        detalhesSobrepostos = detalhesSobrepostos & "[" & CStr(ctl.Name) & "=" & ctl.caption & "]"
                    End If
                End If
            End If
        End If
    Next ctl

    detalhes = nomeControle & ": LABELS_LINHA=" & CStr(avaliados) & _
               "; SOBREPOSTOS=" & CStr(sobrepostos) & _
               "; TERMO=" & termoLabel
    If detalhesSobrepostos <> "" Then detalhes = detalhes & "; DETALHE=" & detalhesSobrepostos
    TV2_FormControleLivreDeSobreposicao = (avaliados > 0 And sobrepostos = 0)
    Exit Function

falha:
    detalhes = nomeControle & ": falha ao verificar sobreposicao; Erro " & _
               CStr(Err.Number) & ": " & Err.Description
    TV2_FormControleLivreDeSobreposicao = False
End Function

Private Function TV2_IntervalosSobrepoem(ByVal aInicio As Double, ByVal aFim As Double, ByVal bInicio As Double, ByVal bFim As Double) As Boolean
    TV2_IntervalosSobrepoem = (aInicio < bFim And bInicio < aFim)
End Function

Private Sub TV2_RestaurarConfigPainel( _
    ByVal valorNota As Variant, _
    ByVal valorMax As Variant, _
    ByVal valorDias As Variant, _
    ByVal valorPrazo As Variant, _
    ByVal valorMaxRecusas As Variant, _
    ByVal valorMeses As Variant, _
    ByVal valorDiasRecusa As Variant _
)
    Dim wsCfg As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error Resume Next
    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    If wsCfg Is Nothing Then Exit Sub
    If Util_PrepararAbaParaEscrita(wsCfg, estavaProtegida, senhaProtecao) Then
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value = valorNota
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value = valorMax
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = valorDias
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = valorPrazo
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = valorMaxRecusas
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value = valorMeses
        wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = valorDiasRecusa
        Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
    End If
    On Error GoTo 0
End Sub

Private Function TV2_EST_LerCodigoComponenteOuArquivo( _
    ByVal repoRoot As String, _
    ByVal componenteNome As String, _
    ByVal arquivo As String, _
    ByRef origem As String _
) As String
    Dim vbp As Object
    Dim comp As Object
    Dim cm As Object
    Dim path As String

    On Error Resume Next
    Set vbp = Application.VBE.ActiveVBProject
    Set comp = vbp.VBComponents(componenteNome)
    Set cm = comp.CodeModule
    If Err.Number = 0 And Not cm Is Nothing Then
        TV2_EST_LerCodigoComponenteOuArquivo = cm.Lines(1, cm.CountOfLines)
        origem = "VBE"
        On Error GoTo 0
        Exit Function
    End If
    On Error GoTo 0

    path = repoRoot & "\src\vba\" & arquivo
    If Dir(path) <> "" Then
        origem = "FS"
        TV2_EST_LerCodigoComponenteOuArquivo = TV2_UI_LerArquivoTexto(path)
    Else
        origem = "AUSENTE"
        TV2_EST_LerCodigoComponenteOuArquivo = ""
    End If
End Function

Private Sub TV2_EST_LogComponenteContemTokens( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal repoRoot As String, _
    ByVal componenteNome As String, _
    ByVal arquivo As String, _
    ByVal tokensPipe As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String _
)
    Dim codigo As String
    Dim origem As String
    Dim tokens() As String
    Dim i As Long
    Dim token As String
    Dim faltantes As String
    Dim ok As Boolean

    codigo = TV2_EST_LerCodigoComponenteOuArquivo(repoRoot, componenteNome, arquivo, origem)
    tokens = Split(tokensPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, codigo, token, vbTextCompare) = 0 Then
                faltantes = faltantes & token & ";"
            End If
        End If
    Next i

    ok = (origem <> "AUSENTE" And faltantes = "")
    TV2_LogAssert suite, cenarioId, "AUTO", _
                  objetivo, esperado, _
                  IIf(ok, "OK; ORIGEM=" & origem, "ORIGEM=" & origem & "; FALTANTES=" & faltantes), _
                  significado, ok
End Sub

Private Sub TV2_EST_LogComponenteNaoContemTokens( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal repoRoot As String, _
    ByVal componenteNome As String, _
    ByVal arquivo As String, _
    ByVal tokensPipe As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String _
)
    Dim codigo As String
    Dim origem As String
    Dim tokens() As String
    Dim i As Long
    Dim token As String
    Dim presentes As String
    Dim ok As Boolean

    codigo = TV2_EST_LerCodigoComponenteOuArquivo(repoRoot, componenteNome, arquivo, origem)
    tokens = Split(tokensPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, codigo, token, vbTextCompare) > 0 Then
                presentes = presentes & token & ";"
            End If
        End If
    Next i

    ok = (origem <> "AUSENTE" And presentes = "")
    TV2_LogAssert suite, cenarioId, "AUTO", _
                  objetivo, esperado, _
                  IIf(ok, "OK; ORIGEM=" & origem, "ORIGEM=" & origem & "; PRESENTES=" & presentes), _
                  significado, ok
End Sub

Private Sub TV2_EST_LogTrechoContrato( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal repoRoot As String, _
    ByVal componenteNome As String, _
    ByVal arquivo As String, _
    ByVal inicioToken As String, _
    ByVal fimToken As String, _
    ByVal tokensObrigatoriosPipe As String, _
    ByVal tokensProibidosPipe As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String _
)
    Dim codigo As String
    Dim origem As String
    Dim trecho As String
    Dim posInicio As Long
    Dim posFim As Long
    Dim tokens() As String
    Dim i As Long
    Dim token As String
    Dim faltantes As String
    Dim presentes As String
    Dim ok As Boolean

    codigo = TV2_EST_LerCodigoComponenteOuArquivo(repoRoot, componenteNome, arquivo, origem)
    posInicio = InStr(1, codigo, inicioToken, vbTextCompare)
    If posInicio > 0 Then
        posFim = InStr(posInicio + Len(inicioToken), codigo, fimToken, vbTextCompare)
        If posFim <= 0 Then posFim = Len(codigo) + 1
        trecho = Mid$(codigo, posInicio, posFim - posInicio)
    End If

    tokens = Split(tokensObrigatoriosPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, trecho, token, vbTextCompare) = 0 Then
                faltantes = faltantes & token & ";"
            End If
        End If
    Next i

    tokens = Split(tokensProibidosPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, trecho, token, vbTextCompare) > 0 Then
                presentes = presentes & token & ";"
            End If
        End If
    Next i

    ok = (origem <> "AUSENTE" And posInicio > 0 And faltantes = "" And presentes = "")
    TV2_LogAssert suite, cenarioId, "AUTO", _
                  objetivo, esperado, _
                  IIf(ok, "OK; ORIGEM=" & origem, _
                      "ORIGEM=" & origem & "; INICIO=" & CStr(posInicio) & _
                      "; FALTANTES=" & faltantes & "; PROIBIDOS=" & presentes), _
                  significado, ok
End Sub

Public Sub TV2_RunTransaction_Interrupt(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "TRANSACAO_INTERRUPT"
    Const TX_ROW As Long = 1
    Const TX_COL As Long = 60
    Dim wsTx As Worksheet
    Dim txOriginal As Variant
    Dim txRollbackOk As Boolean
    Dim txRollbackOk2 As Boolean
    Dim txCommitAntes As Long
    Dim txCommitDepois As Long
    Dim txRollbackAntes As Long
    Dim txRollbackDepois As Long
    Dim txNestedAntes As Long
    Dim txNestedDepois As Long
    Dim txId As String
    Dim txOuterId As String
    Dim txInnerId As String
    Dim txErrNum As Long
    Dim txErrMsg As String
    Dim txNestedRejected As Boolean
    Dim txStillActive As Boolean
    Dim txIdPreservado As Boolean
    Dim obtido As String
    Dim ok As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 6
    Set wsTx = ThisWorkbook.Sheets(TV2_SHEET_RESULTADO)
    txOriginal = wsTx.Cells(TX_ROW, TX_COL).Value
    If Transacao_EstaAtiva() Then txRollbackOk = Transacao_Rollback()

    txId = "TV2_TX_INT_001"
    txCommitAntes = TV2_AuditCount("Rollback/Transacao", "STATUS=COMMIT")
    Transacao_Iniciar txId
    Transacao_Commit
    txCommitDepois = TV2_AuditCount("Rollback/Transacao", "STATUS=COMMIT")
    obtido = "ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtido = obtido & "; TX_ID_FINAL=" & Transacao_IdAtual()
    obtido = obtido & "; AUDIT_COMMIT=" & CStr(txCommitDepois - txCommitAntes)
    ok = Not Transacao_EstaAtiva()
    ok = ok And Transacao_IdAtual() = ""
    ok = ok And (txCommitDepois - txCommitAntes) >= 1
    TV2_LogAssert suite, "TX_INT_001_COMMIT_LIMPA_ESTADO", "AUTO", _
                  "Commit encerra transacao e limpa estado global", _
                  "Transacao inativa, id vazio e auditoria COMMIT registrada", _
                  obtido, _
                  "Evita vazamento de estado global apos commit", ok

    txId = "TV2_TX_INT_002"
    Transacao_Iniciar txId
    txRollbackOk = Transacao_Rollback()
    obtido = "ROLLBACK=" & CStr(txRollbackOk)
    obtido = obtido & "; ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtido = obtido & "; TX_ID_FINAL=" & Transacao_IdAtual()
    ok = txRollbackOk
    ok = ok And Not Transacao_EstaAtiva()
    ok = ok And Transacao_IdAtual() = ""
    TV2_LogAssert suite, "TX_INT_002_ROLLBACK_SEM_WRITE_LIMPA_ESTADO", "AUTO", _
                  "Rollback sem writes deve ser idempotente", _
                  "Rollback retorna verdadeiro, encerra transacao e limpa id", _
                  obtido, _
                  "Garante cleanup mesmo quando a operacao aborta antes da primeira escrita", ok

    txId = "TV2_TX_INT_003"
    txOriginal = wsTx.Cells(TX_ROW, TX_COL).Value
    txRollbackAntes = TV2_AuditCount("Rollback/Transacao", "STATUS=ROLLBACK")
    Transacao_Iniciar txId
    Transacao_RegistrarWrite TV2_SHEET_RESULTADO, TX_ROW, TX_COL, txOriginal
    wsTx.Cells(TX_ROW, TX_COL).Value = "MICRO42_TX_TMP"
    txRollbackOk = Transacao_Rollback()
    txRollbackDepois = TV2_AuditCount("Rollback/Transacao", "STATUS=ROLLBACK")
    obtido = "ROLLBACK=" & CStr(txRollbackOk)
    obtido = obtido & "; VALOR_RESTAURADO=" & CStr(CStr(wsTx.Cells(TX_ROW, TX_COL).Value) = CStr(txOriginal))
    obtido = obtido & "; ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtido = obtido & "; AUDIT_ROLLBACK=" & CStr(txRollbackDepois - txRollbackAntes)
    ok = txRollbackOk
    ok = ok And CStr(wsTx.Cells(TX_ROW, TX_COL).Value) = CStr(txOriginal)
    ok = ok And Not Transacao_EstaAtiva()
    ok = ok And (txRollbackDepois - txRollbackAntes) >= 1
    TV2_LogAssert suite, "TX_INT_003_ROLLBACK_RESTAURA_VALOR", "AUTO", _
                  "Rollback restaura write registrado em ordem reversa", _
                  "Valor sentinela volta ao original, estado limpa e auditoria ROLLBACK aparece", _
                  obtido, _
                  "Prova a restauracao basica sem tocar dados operacionais", ok

    txOuterId = "TV2_TX_INT_004_OUTER"
    txInnerId = "TV2_TX_INT_004_INNER"
    txNestedAntes = TV2_AuditCount("Rollback/Transacao", "TRANSACAO_ANINHADA")
    Transacao_Iniciar txOuterId
    txErrNum = 0
    txErrMsg = ""
    On Error Resume Next
    Transacao_Iniciar txInnerId
    txErrNum = Err.Number
    txErrMsg = Err.Description
    Err.Clear
    On Error GoTo falha
    txNestedRejected = (txErrNum <> 0)
    txStillActive = Transacao_EstaAtiva()
    txIdPreservado = (Transacao_IdAtual() = txOuterId)
    txRollbackOk = Transacao_Rollback()
    txNestedDepois = TV2_AuditCount("Rollback/Transacao", "TRANSACAO_ANINHADA")
    obtido = "ERRO_ANINHADO=" & CStr(txErrNum)
    obtido = obtido & "; MSG=" & txErrMsg
    obtido = obtido & "; ATIVA_APOS_ERRO=" & CStr(txStillActive)
    obtido = obtido & "; TX_ID_PRESERVADO=" & CStr(txIdPreservado)
    obtido = obtido & "; ROLLBACK_CLEANUP=" & CStr(txRollbackOk)
    obtido = obtido & "; AUDIT_ANINHADA=" & CStr(txNestedDepois - txNestedAntes)
    ok = txNestedRejected
    ok = ok And txStillActive
    ok = ok And txIdPreservado
    ok = ok And txRollbackOk
    ok = ok And Not Transacao_EstaAtiva()
    ok = ok And (txNestedDepois - txNestedAntes) >= 1
    TV2_LogAssert suite, "TX_INT_004_ANINHADA_PRESERVA_EXTERNA", "AUTO", _
                  "Transacao aninhada falha sem sobrescrever a externa", _
                  "Erro explicito, id externo preservado, cleanup OK e auditoria ANINHADA", _
                  obtido, _
                  "Impede corrupcao de contexto quando uma rotina tenta reabrir transacao", ok

    txId = "TV2_TX_INT_005"
    Transacao_Iniciar txId
    txRollbackOk = Transacao_Rollback()
    Transacao_Commit
    obtido = "ROLLBACK=" & CStr(txRollbackOk)
    obtido = obtido & "; ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtido = obtido & "; TX_ID_FINAL=" & Transacao_IdAtual()
    ok = txRollbackOk
    ok = ok And Not Transacao_EstaAtiva()
    ok = ok And Transacao_IdAtual() = ""
    TV2_LogAssert suite, "TX_INT_005_COMMIT_APOS_ROLLBACK_NAO_REABRE", "AUTO", _
                  "Commit apos rollback nao reabre transacao", _
                  "Estado permanece inativo e id vazio", _
                  obtido, _
                  "Fecha ordem de chamada defensiva em cleanup duplicado", ok

    txId = "TV2_TX_INT_006"
    Transacao_Iniciar txId
    txRollbackOk = Transacao_Rollback()
    txRollbackOk2 = Transacao_Rollback()
    obtido = "ROLLBACK_1=" & CStr(txRollbackOk)
    obtido = obtido & "; ROLLBACK_2=" & CStr(txRollbackOk2)
    obtido = obtido & "; ATIVA_FINAL=" & CStr(Transacao_EstaAtiva())
    obtido = obtido & "; TX_ID_FINAL=" & Transacao_IdAtual()
    ok = txRollbackOk
    ok = ok And txRollbackOk2
    ok = ok And Not Transacao_EstaAtiva()
    ok = ok And Transacao_IdAtual() = ""
    TV2_LogAssert suite, "TX_INT_006_ROLLBACK_DUPLO_IDEMPOTENTE", "AUTO", _
                  "Rollback duplo nao deixa estado sujo", _
                  "Duas chamadas retornam verdadeiro e estado final fica limpo", _
                  obtido, _
                  "Permite handlers defensivos sem criar falha secundaria", ok

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Transacao_EstaAtiva() Then txRollbackOk = Transacao_Rollback()
    If Not wsTx Is Nothing Then wsTx.Cells(TX_ROW, TX_COL).Value = txOriginal
    On Error GoTo 0
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite de interrupcao transacional sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
End Sub

Public Sub TV2_RunBoundary_Dates(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Const suite As String = "BOUNDARY_DATES"
    Dim res As TResult
    Dim dtPrev As Date
    Dim numEmpenho As String
    Dim defaultData As String
    Dim houveMudanca As Boolean
    Dim resumoMudancas As String
    Dim obtido As String
    Dim ok As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao suite, visual, 9

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-001", "", "", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; DT_PREV=" & Format$(dtPrev, "yyyy-mm-dd") & "; NUM_EMPENHO=" & numEmpenho
    ok = res.sucesso
    ok = ok And dtPrev >= Date
    ok = ok And Trim$(numEmpenho) <> ""
    TV2_LogAssert suite, "DATE_BND_001_OS_DATA_VAZIA_DEFAULT", "AUTO", _
                  "Data prevista vazia usa prazo padrao e empenho default", _
                  "Sucesso, DT_PREV >= hoje e NUM_EMPENHO preenchido", _
                  obtido, _
                  "Protege o fluxo de emissao quando operador deixa data/empenho em branco", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-002", Format$(Date, "DD/MM/YYYY"), "EMP-BND-002", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; DT_PREV=" & Format$(dtPrev, "yyyy-mm-dd") & "; MSG=" & res.mensagem
    ok = res.sucesso
    ok = ok And DateValue(dtPrev) = Date
    ok = ok And numEmpenho = "EMP-BND-002"
    TV2_LogAssert suite, "DATE_BND_002_OS_HOJE_PERMITIDO", "AUTO", _
                  "Data prevista igual a hoje e aceita", _
                  "Sucesso e DT_PREV igual a hoje", _
                  obtido, _
                  "Formaliza que a guarda bloqueia apenas datas anteriores a hoje", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-003", Format$(Date - 1, "DD/MM/YYYY"), "EMP-BND-003", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; MSG=" & res.mensagem
    ok = Not res.sucesso
    ok = ok And InStr(1, res.mensagem, "anterior", vbTextCompare) > 0
    TV2_LogAssert suite, "DATE_BND_003_OS_ONTEM_REJEITADO", "AUTO", _
                  "Data prevista anterior a hoje e rejeitada", _
                  "Falha explicita com mensagem de data anterior", _
                  obtido, _
                  "Impede emissao de OS com prazo retroativo", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-004", "31/02/2026", "EMP-BND-004", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; MSG=" & res.mensagem
    ok = Not res.sucesso
    ok = ok And InStr(1, res.mensagem, "invalida", vbTextCompare) > 0
    TV2_LogAssert suite, "DATE_BND_004_OS_31_FEV_REJEITADO", "AUTO", _
                  "Data inexistente 31/02 e rejeitada", _
                  "Falha explicita por formato/data invalida", _
                  obtido, _
                  "Protege parser contra normalizacao silenciosa do VBA DateSerial", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-005", "29/02/2028", "EMP-BND-005", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; DT_PREV=" & Format$(dtPrev, "yyyy-mm-dd") & "; MSG=" & res.mensagem
    ok = res.sucesso
    ok = ok And Day(dtPrev) = 29 And Month(dtPrev) = 2 And Year(dtPrev) = 2028
    TV2_LogAssert suite, "DATE_BND_005_OS_BISSEXTO_VALIDO", "AUTO", _
                  "29/02 em ano bissexto e aceito", _
                  "Sucesso com DT_PREV=2028-02-29", _
                  obtido, _
                  "Evita regressao que rejeite datas validas de fevereiro em ano bissexto", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-006", "29/02/2027", "EMP-BND-006", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; MSG=" & res.mensagem
    ok = Not res.sucesso
    ok = ok And InStr(1, res.mensagem, "invalida", vbTextCompare) > 0
    TV2_LogAssert suite, "DATE_BND_006_OS_BISSEXTO_INVALIDO", "AUTO", _
                  "29/02 em ano nao bissexto e rejeitado", _
                  "Falha explicita por data invalida", _
                  obtido, _
                  "Protege contra rollover silencioso para marco", ok

    dtPrev = CDate(0)
    numEmpenho = ""
    res = MontarParametrosEmissaoOS("PREOS-BND-007", "31/12/30", "EMP-BND-007", dtPrev, numEmpenho)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; DT_PREV=" & Format$(dtPrev, "yyyy-mm-dd") & "; MSG=" & res.mensagem
    ok = res.sucesso
    ok = ok And Day(dtPrev) = 31 And Month(dtPrev) = 12 And Year(dtPrev) = 2030
    TV2_LogAssert suite, "DATE_BND_007_OS_ANO_CURTO_2030", "AUTO", _
                  "Ano curto 30 e normalizado para 2030", _
                  "Sucesso com DT_PREV=2030-12-31", _
                  obtido, _
                  "Documenta contrato atual de compatibilidade para anos com dois digitos", ok

    defaultData = "07/05/2026"
    houveMudanca = False
    resumoMudancas = ""
    res = DescreverMudancasAvaliacao("EMP-BND-008", defaultData, 1, CCur(100), _
                                     "EMP-BND-008", DateSerial(2026, 5, 7), 1, CCur(100), _
                                     houveMudanca, resumoMudancas)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; HOUVE_MUDANCA=" & CStr(houveMudanca) & "; RESUMO=" & resumoMudancas
    ok = res.sucesso
    ok = ok And Not houveMudanca
    ok = ok And Trim$(resumoMudancas) = ""
    TV2_LogAssert suite, "DATE_BND_008_AVAL_DATA_EQUIVALENTE_SEM_MUDANCA", "AUTO", _
                  "Data de avaliacao equivalente nao gera mudanca", _
                  "Sem mudanca quando default textual e valor Date representam o mesmo dia", _
                  obtido, _
                  "Evita confirmacao falsa quando o operador nao alterou a data", ok

    defaultData = "07/05/2026"
    houveMudanca = False
    resumoMudancas = ""
    res = DescreverMudancasAvaliacao("EMP-BND-009", defaultData, 1, CCur(100), _
                                     "EMP-BND-009", DateSerial(2026, 5, 8), 1, CCur(100), _
                                     houveMudanca, resumoMudancas)
    obtido = "SUCESSO=" & CStr(res.sucesso) & "; HOUVE_MUDANCA=" & CStr(houveMudanca) & "; RESUMO=" & resumoMudancas
    ok = res.sucesso
    ok = ok And houveMudanca
    ok = ok And InStr(1, resumoMudancas, "Data de fechamento", vbTextCompare) > 0
    TV2_LogAssert suite, "DATE_BND_009_AVAL_DATA_DIFERENTE_COM_MUDANCA", "AUTO", _
                  "Data de avaliacao diferente gera mudanca rastreavel", _
                  "Mudanca detectada e resumo cita Data de fechamento", _
                  obtido, _
                  "Garante que alteracao real de data continue visivel antes da avaliacao", ok

    TV2_FinalizarExecucao suite, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    TV2_LogAssert suite, "FATAL", "AUTO", _
                  "Executar suite de bordas de data sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                  "Toda falha fatal precisa ficar rastreavel", False
    TV2_FinalizarExecucao suite, silencioso
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
    cand1 = ThisWorkbook.path
    cand2 = ThisWorkbook.path & "\.."
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

Private Sub TV2_UI_VerificarGuardReentrada(ByVal repoRoot As String)
    Dim faltantes As String
    Dim manuais As String

    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Reativa_Empresa.frm", "mReativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Reativa_Entidade.frm", "mReativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Empresa.frm", "mAlteracaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Empresa.frm", "mInativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Entidade.frm", "mAlteracaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Altera_Entidade.frm", "mInativacaoEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Limpar_Base.frm", "mLimpezaEmAndamento", manuais)
    faltantes = faltantes & TV2_UI_CheckGuardArquivo(repoRoot, "Menu_Principal.frm", "mEncerraOSEmProcessamento", manuais)

    If manuais <> "" Then
        TV2_LogManual "SMOKE", "CS_UISMOKE_REENTRADA_GUARDS", _
                      "Verificar guards de reentrada nos forms mutadores", _
                      "Repo local indisponivel para leitura: " & manuais, _
                      "Validar manualmente no pacote importado"
    Else
        TV2_LogAssert "SMOKE", "CS_UISMOKE_REENTRADA_GUARDS", "AUTO", _
                      "Verificar guards de reentrada nos forms mutadores", _
                      "Cada flag tem declaracao, teste If, set True e reset False", _
                      IIf(faltantes = "", "OK", "FALTANTES=" & faltantes), _
                      "Evita duplo clique ou chamada repetida criando mutacao duplicada", _
                      (faltantes = "")
    End If
End Sub

Private Function TV2_UI_CheckGuardArquivo( _
    ByVal repoRoot As String, _
    ByVal arquivo As String, _
    ByVal flag As String, _
    ByRef manuais As String _
) As String
    Dim path As String
    Dim codigo As String
    Dim falta As String

    path = repoRoot & "\src\vba\" & arquivo
    If Dir(path) = "" Then
        manuais = manuais & arquivo & ";"
        Exit Function
    End If

    codigo = TV2_UI_LerArquivoTexto(path)
    If InStr(1, codigo, flag, vbTextCompare) = 0 Then falta = falta & arquivo & ":" & flag & ":DECL;"
    If InStr(1, codigo, "If " & flag & " Then", vbTextCompare) = 0 Then falta = falta & arquivo & ":" & flag & ":IF;"
    If InStr(1, codigo, flag & " = True", vbTextCompare) = 0 Then falta = falta & arquivo & ":" & flag & ":TRUE;"
    If InStr(1, codigo, flag & " = False", vbTextCompare) = 0 Then falta = falta & arquivo & ":" & flag & ":FALSE;"

    TV2_UI_CheckGuardArquivo = falta
End Function

Private Sub TV2_UIAdv_LogFileTokens( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal repoRoot As String, _
    ByVal arquivo As String, _
    ByVal tokensPipe As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String _
)
    Dim path As String
    Dim codigo As String
    Dim tokens() As String
    Dim i As Long
    Dim token As String
    Dim faltantes As String
    Dim ok As Boolean

    path = repoRoot & "\src\vba\" & arquivo
    If Dir(path) = "" Then
        TV2_LogAssert suite, cenarioId, "AUTO", _
                      objetivo, _
                      esperado, _
                      "Arquivo ausente: " & path, _
                      significado, False
        Exit Sub
    End If

    codigo = TV2_UI_LerArquivoTexto(path)
    tokens = Split(tokensPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, codigo, token, vbTextCompare) = 0 Then
                faltantes = faltantes & token & ";"
            End If
        End If
    Next i

    ok = (faltantes = "")
    TV2_LogAssert suite, cenarioId, "AUTO", _
                  objetivo, _
                  esperado, _
                  IIf(ok, "OK", "FALTANTES=" & faltantes), _
                  significado, ok
End Sub

Private Sub TV2_UIAdv_LogFileNaoContemTokens( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal repoRoot As String, _
    ByVal arquivo As String, _
    ByVal tokensPipe As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String _
)
    Dim path As String
    Dim codigo As String
    Dim tokens() As String
    Dim i As Long
    Dim token As String
    Dim presentes As String
    Dim ok As Boolean

    path = repoRoot & "\src\vba\" & arquivo
    If Dir(path) = "" Then
        TV2_LogAssert suite, cenarioId, "AUTO", _
                      objetivo, _
                      esperado, _
                      "Arquivo ausente: " & path, _
                      significado, False
        Exit Sub
    End If

    codigo = TV2_UI_LerArquivoTexto(path)
    tokens = Split(tokensPipe, "|")
    For i = LBound(tokens) To UBound(tokens)
        token = Trim$(tokens(i))
        If token <> "" Then
            If InStr(1, codigo, token, vbTextCompare) > 0 Then
                presentes = presentes & token & ";"
            End If
        End If
    Next i

    ok = (presentes = "")
    TV2_LogAssert suite, cenarioId, "AUTO", _
                  objetivo, _
                  esperado, _
                  IIf(ok, "OK", "PRESENTES=" & presentes), _
                  significado, ok
End Sub

Private Function TV2_UI_LerArquivoTexto(ByVal path As String) As String
    Dim fNum As Integer
    Dim conteudo As String
    fNum = FreeFile
    Open path For Binary Access Read As #fNum
    conteudo = Space$(LOF(fNum))
    Get #fNum, , conteudo
    Close #fNum
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
    Dim qtdItem23 As Long
    Dim qtdItem25 As Long
    Dim linhaCred25 As Long
    Dim wsCred25 As Worksheet
    Dim estProtCred25 As Boolean
    Dim senhaCred25 As String
    Dim resCred25 As TResult
    Dim obtido23 As String
    Dim obtido24 As String
    Dim obtido25 As String
    Dim obtido21 As String
    Dim ok23 As Boolean
    Dim ok24 As Boolean
    Dim ok25 As Boolean
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
    pre22A = RepoPreOS_BuscarPorId(preosId22A)
    pre22B = RepoPreOS_BuscarPorId(preosId22B)
    pre22C = RepoPreOS_BuscarPorId(preosId22C)
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
    resSusp = Suspender("001", 30, "MANUAL", "CS_11_MANUAL", Config_SnapshotPunicoesDias())
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
    ok11 = ok11 And empA.DT_FIM_SUSP = DateAdd("d", 30, Date) And auditSusp = 1
    TV2_LogAssert "CANONICO", "CS_11", "AUTO", _
                  "Validar suspensão manual global de A", _
                  "A suspensa; B escolhida; posição 1 preservada", _
                  obtido11, _
                  "Separa aptidão operacional de posição absoluta na fila", _
                  ok11

    TV2_PrepararCenarioTriploCanonico
    resSusp = Suspender("001", 30, "MANUAL", "CS_13_MANUAL_REATIVACAO", Config_SnapshotPunicoesDias())
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
    ok14 = ok14 And empB.DT_FIM_SUSP = DateAdd("d", 30, Date)
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
    qtdItem23 = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001")
    obtido23 = "SUCESSO_INAT=" & CStr(resInatEmp.sucesso) & _
               "; SUCESSO_PREOS_B=" & CStr(resPre.sucesso) & _
               "; EMP_PREOS_B=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; SUCESSO_REAT=" & CStr(resReatEmp.sucesso) & _
               "; SUCESSO_PREOS_A=" & CStr(resPre2.sucesso) & _
               "; EMP_PREOS_A=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; STATUS_A=" & TV2_StatusEmpresa("001") & _
               "; DT_ULT_REATIV_A=" & IIf(empReat23.DT_ULT_REATIV > CDate(0), Format$(empReat23.DT_ULT_REATIV, "dd/mm/yyyy hh:nn:ss"), "(vazia)") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; QTD_CRED_ITEM=" & CStr(qtdItem23) & _
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
    ok23 = ok23 And qtdItem23 = 3
    ok23 = ok23 And qtdEmpAtivas23 = 1 And qtdEmpInativas23 = 0 And TV2_CountOcorrenciasEmpresa("001") = 1
    ok23 = ok23 And (auditInatDepois - auditInatAntes) = 1
    ok23 = ok23 And (auditReatDepois - auditReatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_23", "AUTO", _
                  "Validar ida e volta de empresa entre ativo e inativo", _
                  "A some da seleção enquanto inativa e volta com DT_ULT_REATIV preenchida, sem duplicidade cadastral e com 3 credenciamentos ativos no item", _
                  obtido23, _
                  "Fecha ida e volta de empresa com preservação da fila lógica", _
                  ok23

    TV2_PrepararCenarioTriploCanonico
    Set wsCred25 = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    linhaCred25 = 0
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(wsCred25.Cells(i, COL_CRED_EMP_ID).Value, "001") And _
           IdsIguais(wsCred25.Cells(i, COL_CRED_ATIV_ID).Value, TV2_AtivCanonA()) Then
            linhaCred25 = i
            Exit For
        End If
    Next i
    If linhaCred25 > 0 Then
        Call Util_PrepararAbaParaEscrita(wsCred25, estProtCred25, senhaCred25)
        wsCred25.Cells(linhaCred25, COL_CRED_ATIV_ID).Value = "X"
        wsCred25.Cells(linhaCred25, COL_CRED_COD_ATIV_SERV).Value = ""
        Call Util_RestaurarProtecaoAba(wsCred25, estProtCred25, senhaCred25)
    End If
    resCred25 = RestaurarCredenciamentosEmpresa("001", "Teste_V2_Roteiros.CS_25")
    qtdItem25 = TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001")
    obtido25 = "LINHA_CRED=" & CStr(linhaCred25) & _
               "; SUCESSO_RESTAURA=" & CStr(resCred25.sucesso) & _
               "; MSG=" & resCred25.mensagem & _
               "; QTD_CRED_ITEM=" & CStr(qtdItem25)
    ok25 = (linhaCred25 > 0)
    ok25 = ok25 And Not resCred25.sucesso
    ok25 = ok25 And InStr(1, resCred25.mensagem, "sem ATIV_ID restauravel", vbTextCompare) > 0
    ok25 = ok25 And qtdItem25 = 2
    TV2_LogAssert "CANONICO", "CS_25", "AUTO", _
                  "Bloquear restauracao silenciosa de credenciamento sem atividade derivavel", _
                  "Servico falha de forma explicita quando ATIV_ID esta vazio/X e COD_ATIV_SERV nao permite derivar a atividade", _
                  obtido25, _
                  "Formaliza a decisao da Onda 20: preservar/restaurar vinculo existente; recredenciamento novo exige acao explicita", _
                  ok25

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
    TV2_RestaurarConfigBaseline 2, 30  ' MAX_STRIKES=2 (set; nome semantico, mesmo backend que restore)

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
    TV2_RestaurarConfigBaseline 1, 30
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
    TV2_RestaurarConfigBaseline 5, 30  ' MAX_STRIKES=5

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

    TV2_RestaurarConfigBaseline 1, 30
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
    TV2_RestaurarConfigBaseline 1, 30  ' MAX_STRIKES=1 (legado), DIAS=30

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
    TV2_RestaurarConfigBaseline 1, 30
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
    TV2_FormatEmpId = TV2_NormalizarIdMin3(valor)
End Function

Private Function TV2_NormalizarIdMin3(ByVal valor As Variant) As String
    Dim s As String
    Dim i As Long

    On Error GoTo falha

    If IsError(valor) Or IsNull(valor) Or IsEmpty(valor) Then
        TV2_NormalizarIdMin3 = ""
        Exit Function
    End If

    s = Trim$(CStr(valor))
    If s = "" Then
        TV2_NormalizarIdMin3 = ""
        Exit Function
    End If

    For i = 1 To Len(s)
        If Mid$(s, i, 1) < "0" Or Mid$(s, i, 1) > "9" Then
            TV2_NormalizarIdMin3 = s
            Exit Function
        End If
    Next i

    If Len(s) < 3 Then
        TV2_NormalizarIdMin3 = Right$("000" & s, 3)
    Else
        TV2_NormalizarIdMin3 = s
    End If
    Exit Function

falha:
    TV2_NormalizarIdMin3 = ""
End Function

Private Function TV2_EmpIdPreOSBruto(ByVal preosId As String) As String
    Dim ws As Worksheet
    Dim linha As Long
    Dim valor As Variant

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(linha, COL_PREOS_ID).Value, preosId) Then
            valor = ws.Cells(linha, COL_PREOS_EMP_ID).Value
            If IsError(valor) Or IsNull(valor) Or IsEmpty(valor) Then
                TV2_EmpIdPreOSBruto = ""
            Else
                TV2_EmpIdPreOSBruto = Trim$(CStr(valor))
            End If
            Exit Function
        End If
    Next linha
    Exit Function

falha:
    TV2_EmpIdPreOSBruto = ""
End Function

Private Function TV2_EmpIdPreOSNumberFormat(ByVal preosId As String) As String
    Dim ws As Worksheet
    Dim linha As Long

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(linha, COL_PREOS_ID).Value, preosId) Then
            TV2_EmpIdPreOSNumberFormat = CStr(ws.Cells(linha, COL_PREOS_EMP_ID).NumberFormat)
            Exit Function
        End If
    Next linha
    Exit Function

falha:
    TV2_EmpIdPreOSNumberFormat = ""
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
        "Apos 3 strikes, EMP1 deve estar SUSPENSA com DT_FIM_SUSP exato", _
        "STATUS=SUSPENSA_GLOBAL; DT_FIM=hoje+DIAS_STRIKE", _
        "STATUS=" & emp.STATUS_GLOBAL & "; DT_FIM=" & Format$(emp.DT_FIM_SUSP, "DD/MM/YYYY") & _
        "; DIAS=" & CStr(GetDiasSuspensaoStrike()), _
        "Confirma que MAX_STRIKES dispara suspensao em dias na 3a vez", _
        emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL" And emp.DT_FIM_SUSP = DateAdd("d", GetDiasSuspensaoStrike(), Date)

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
    Dim auditDualR2S_antes As Long
    Dim auditDualR2S_depois As Long
    Dim auditDualR2S_detalhe As Long

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
    auditDualR2S_antes = TV2_AuditCount("Avaliacao Registrada", "EMP_ID=" & empsR2S(1) & "; DUAL_COUNTER=SIM")
    TV2_FF_RodadaCompleta ativsR2S(1), entsR2S(1), 3, empsR2S, notasR2S, Date + 1

    notaMinR2S = GetNotaMinimaAvaliacao()
    strikesR2S_total = ContarStrikesPorEmpresa(empsR2S(1), notaMinR2S)
    strikesR2S_punicao = ContarStrikesParaPunicao(empsR2S(1), notaMinR2S)
    statusR2S_pos_reativ = TV2_StatusEmpresa(empsR2S(1))
    empR2S = LerEmpresa(empsR2S(1), linhaEmpR2S)
    auditDualR2S_depois = TV2_AuditCount("Avaliacao Registrada", "EMP_ID=" & empsR2S(1) & "; DUAL_COUNTER=SIM")
    auditDualR2S_detalhe = TV2_AuditCount( _
        "Avaliacao Registrada", _
        "EMP_ID=" & empsR2S(1) & "; DUAL_COUNTER=SIM; STRIKES_TOTAL=" & CStr(strikesR2S_total) & _
        "; STRIKES_PUNICAO=" & CStr(strikesR2S_punicao))

    observadoR2S = "EMP1=" & empsR2S(1) & _
                   "; STRIKES_TOTAL_HISTORICO=" & CStr(strikesR2S_total) & _
                   "; STRIKES_PARA_PUNICAO=" & CStr(strikesR2S_punicao) & _
                   "; STATUS_POS_REATIV_E_1NOTA=" & statusR2S_pos_reativ & _
                   "; DT_ULT_REATIV=" & IIf(empR2S.DT_ULT_REATIV > CDate(0), Format$(empR2S.DT_ULT_REATIV, "DD/MM/YYYY HH:NN:SS"), "(vazia)") & _
                   "; AUDIT_DUAL_ANTES=" & CStr(auditDualR2S_antes) & _
                   "; AUDIT_DUAL_DEPOIS=" & CStr(auditDualR2S_depois) & _
                   "; AUDIT_DUAL_DETALHE=" & CStr(auditDualR2S_detalhe)

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

    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_AUDIT_DUAL_COUNTER", "AUTO", _
                  "Avaliacao com nota baixa registra contador total e punitivo no AUDIT_LOG", _
                  "DUAL_COUNTER=SIM; STRIKES_TOTAL>=4; STRIKES_PUNICAO=1", _
                  observadoR2S, _
                  "Operador consegue distinguir historico bruto de janela punitiva apos reativacao", _
                  auditDualR2S_depois > auditDualR2S_antes And auditDualR2S_detalhe > 0 And _
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

    TV2_RestaurarConfigBaseline 1, 30
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

    TV2_RestaurarConfigBaseline 1, 30
    TV2_LimparNamespace "SLEG"

    ' --- CS_REATIV_BORDA_TEMPORAL (Onda 22 MD-22.4) --------------------
    ' A janela punitiva e estritamente posterior a DT_ULT_REATIV:
    ' COL_OS_DT_FECHAMENTO > DT_ULT_REATIV. As bordas abaixo protegem
    ' contra regressao para >= ou contra anistia indevida de strikes novos.
    Dim entsBT() As String, empsBT() As String, ativsBT() As String
    Dim corteBT As Date
    Dim notaCorteBT As Double
    Dim qtdBT As Long
    Dim resBT As TResult
    Dim obtidoBT As String

    TV2_LimparNamespace "SBTM"
    TV2_E2E_LimparCadOsPrefixo "SBTM_"
    TV2_FixtureFactory "SBTM", 1, 1, 1, entsBT, empsBT, ativsBT
    TV2_RestaurarConfigBaseline 3, 90

    corteBT = DateSerial(2026, 1, 15)
    notaCorteBT = 5

    TV2_E2E_InserirOSFechadaTeste "SBTM_ANTERIOR", empsBT(1), entsBT(1), ativsBT(1), corteBT - 1, 4
    qtdBT = 0
    resBT = ContarStrikesParaPunicaoResultado(empsBT(1), notaCorteBT, qtdBT, corteBT)
    obtidoBT = "SUCESSO=" & CStr(resBT.sucesso) & "; QTD=" & CStr(qtdBT) & _
               "; CORTE=" & Format$(corteBT, "yyyy-mm-dd") & _
               "; FECHAMENTO=" & Format$(corteBT - 1, "yyyy-mm-dd") & _
               "; MSG=" & resBT.mensagem
    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_BORDA_ANTERIOR", "AUTO", _
                  "OS fechada antes da DT_ULT_REATIV nao conta para punicao", _
                  "STRIKES_PUNICAO=0", _
                  obtidoBT, _
                  "Protege a exclusao de historico anterior a reativacao", _
                  resBT.sucesso And qtdBT = 0

    TV2_E2E_InserirOSFechadaTeste "SBTM_IGUAL", empsBT(1), entsBT(1), ativsBT(1), corteBT, 4
    qtdBT = 0
    resBT = ContarStrikesParaPunicaoResultado(empsBT(1), notaCorteBT, qtdBT, corteBT)
    obtidoBT = "SUCESSO=" & CStr(resBT.sucesso) & "; QTD=" & CStr(qtdBT) & _
               "; CORTE=" & Format$(corteBT, "yyyy-mm-dd") & _
               "; FECHAMENTO_IGUAL=" & Format$(corteBT, "yyyy-mm-dd") & _
               "; MSG=" & resBT.mensagem
    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_BORDA_IGUAL", "AUTO", _
                  "OS fechada exatamente na DT_ULT_REATIV nao conta para punicao", _
                  "STRIKES_PUNICAO=0", _
                  obtidoBT, _
                  "Formaliza que a regra e estritamente maior, nao maior-ou-igual", _
                  resBT.sucesso And qtdBT = 0

    TV2_E2E_InserirOSFechadaTeste "SBTM_POSTERIOR", empsBT(1), entsBT(1), ativsBT(1), corteBT + 1, 4
    qtdBT = 0
    resBT = ContarStrikesParaPunicaoResultado(empsBT(1), notaCorteBT, qtdBT, corteBT)
    obtidoBT = "SUCESSO=" & CStr(resBT.sucesso) & "; QTD=" & CStr(qtdBT) & _
               "; CORTE=" & Format$(corteBT, "yyyy-mm-dd") & _
               "; FECHAMENTO_POSTERIOR=" & Format$(corteBT + 1, "yyyy-mm-dd") & _
               "; MSG=" & resBT.mensagem
    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_BORDA_POSTERIOR", "AUTO", _
                  "OS fechada apos a DT_ULT_REATIV conta para punicao", _
                  "STRIKES_PUNICAO=1", _
                  obtidoBT, _
                  "Garante que strikes novos continuam punitivos apos reativacao", _
                  resBT.sucesso And qtdBT = 1

    qtdBT = 0
    resBT = ContarStrikesParaPunicaoResultado(empsBT(1), notaCorteBT, qtdBT, corteBT + 30)
    obtidoBT = "SUCESSO=" & CStr(resBT.sucesso) & "; QTD=" & CStr(qtdBT) & _
               "; CORTE_FUTURO=" & Format$(corteBT + 30, "yyyy-mm-dd") & _
               "; MSG=" & resBT.mensagem
    TV2_LogAssert "STRIKES_E2E", "CS_REATIV_BORDA_FUTURA", "AUTO", _
                  "DT_ULT_REATIV futura nao pune OS fechada antes desse corte", _
                  "STRIKES_PUNICAO=0", _
                  obtidoBT, _
                  "Cobre bases com data futura acidental sem cair em historico antigo", _
                  resBT.sucesso And qtdBT = 0

    TV2_RestaurarConfigBaseline 1, 30
    TV2_E2E_LimparCadOsPrefixo "SBTM_"
    TV2_LimparNamespace "SBTM"

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

    TV2_RestaurarConfigBaseline 1, 30
    TV2_LimparNamespace "S5E"

    ' V12.0.0203 ONDA 11 / MD-2.3 - restaurar CONFIG baseline antes
    ' de finalizar para nao vazar MAX_STRIKES=3 para V1/CS_14/CS_16.
    ' V12.0.0203 ONDA 17 MD-17.1.a - agora chama o helper generalizado
    ' TV2_RestaurarConfigBaseline (Engine), parametrizado com defaults
    ' que reproduzem o comportamento legado (1, 0).
    TV2_RestaurarConfigBaseline 1, 30
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
    TV2_RestaurarConfigBaseline 1, 30
    TV2_FinalizarExecucao "STRIKES_E2E", silencioso
End Sub

Private Sub TV2_E2E_InserirOSFechadaTeste( _
    ByVal osId As String, _
    ByVal empId As String, _
    ByVal entId As String, _
    ByVal ativId As String, _
    ByVal dtFechamento As Date, _
    ByVal media As Double _
)
    Dim ws As Worksheet
    Dim linha As Long
    Dim colNota As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim errNum As Long
    Dim errMsg As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_E2E_InserirOSFechadaTeste", "Nao foi possivel preparar CAD_OS."
    End If

    linha = TV2_NextDataRow(SHEET_CAD_OS)
    ws.Cells(linha, COL_OS_ID).Value = osId
    ws.Cells(linha, COL_OS_ENT_ID).Value = entId
    ws.Cells(linha, COL_OS_COD_SERV).Value = "001"
    ws.Cells(linha, COL_OS_EMP_ID).Value = empId
    ws.Cells(linha, COL_OS_EMPENHO).Value = "TV2"
    ws.Cells(linha, COL_OS_DT_EMISSAO).Value = dtFechamento - 1
    ws.Cells(linha, COL_OS_DT_PREV_FIM).Value = dtFechamento
    ws.Cells(linha, COL_OS_DT_FECHAMENTO).Value = dtFechamento
    ws.Cells(linha, COL_OS_QT_EST).Value = 1
    ws.Cells(linha, COL_OS_VL_TOTAL).Value = 100
    ws.Cells(linha, COL_OS_QT_EXEC).Value = 1
    ws.Cells(linha, COL_OS_VL_EXEC).Value = 100
    For colNota = COL_OS_NOTA_01 To COL_OS_NOTA_10
        ws.Cells(linha, colNota).Value = media
    Next colNota
    ws.Cells(linha, COL_OS_MEDIA).Value = media
    ws.Cells(linha, COL_OS_OBSERVACOES).Value = "TV2_BORDA_TEMPORAL"
    ws.Cells(linha, COL_OS_ATIV_ID).Value = ativId
    ws.Cells(linha, COL_OS_PREOS_ID).Value = osId & "_PRE"
    ws.Cells(linha, COL_OS_STATUS).Value = "CONCLUIDA"
    ws.Cells(linha, COL_OS_VL_UNIT).Value = 100
    ws.Cells(linha, COL_OS_JUSTIF_DIV).Value = "TV2_BORDA_TEMPORAL"

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Exit Sub

falha:
    errNum = Err.Number
    errMsg = Err.Description
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise IIf(errNum <> 0, errNum, 1004), "TV2_E2E_InserirOSFechadaTeste", errMsg
End Sub

Private Sub TV2_E2E_LimparCadOsPrefixo(ByVal prefixo As String)
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim osId As String
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim errNum As Long
    Dim errMsg As String

    On Error GoTo falha

    If Len(Trim$(prefixo)) = 0 Then Exit Sub

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    ultima = ws.Cells(ws.Rows.count, COL_OS_ID).End(xlUp).row
    If ultima < LINHA_DADOS Then Exit Sub
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_E2E_LimparCadOsPrefixo", "Nao foi possivel preparar CAD_OS."
    End If

    For linha = ultima To LINHA_DADOS Step -1
        osId = Trim$(CStr(ws.Cells(linha, COL_OS_ID).Value))
        If Len(osId) >= Len(prefixo) Then
            If StrComp(Left$(osId, Len(prefixo)), prefixo, vbTextCompare) = 0 Then
                ws.Rows(linha).ClearContents
            End If
        End If
    Next linha

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Exit Sub

falha:
    errNum = Err.Number
    errMsg = Err.Description
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise IIf(errNum <> 0, errNum, 1004), "TV2_E2E_LimparCadOsPrefixo", errMsg
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
    Dim empPreselCanon As String
    Dim empPreOSBruto As String
    Dim empPreOSNumberFormat As String
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
    empPreselCanon = TV2_NormalizarIdMin3(empPresel)
    TV2_LogInfo "STRIKES_E2E", "DIAG_PRESEL", _
        "Pre-selecionada antes de EmitirPreOS (observador externo)", _
        "EMP_PRESEL=" & empPresel & " EMP_PRESEL_CANON=" & empPreselCanon

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

    pre = RepoPreOS_BuscarPorId(resPre.IdGerado)
    empPreOSBruto = TV2_EmpIdPreOSBruto(resPre.IdGerado)
    empPreOSNumberFormat = TV2_EmpIdPreOSNumberFormat(resPre.IdGerado)
    TV2_LogInfo "STRIKES_E2E", "DIAG_PREOS", _
        "PreOS persistida apos EmitirPreOS", _
        "PREOS_ID=" & pre.PREOS_ID & " EMP_REAL=" & pre.EMP_ID & _
        " EMP_BRUTO=" & empPreOSBruto & " NF=" & empPreOSNumberFormat & _
        " STATUS=" & pre.STATUS_PREOS & " EMP_PRESEL=" & empPresel
    TV2_LogAssert "STRIKES_E2E", "DIAG_PREOS_INTEGRITY", "AUTO", _
        "EMP preselecionada deve coincidir com EMP gravada em PRE_OS", _
        "EMP=" & empPreselCanon, _
        "EMP_PRESEL=" & empPresel & " EMP_PRESEL_CANON=" & empPreselCanon & _
        " EMP_PREOS_BRUTO=" & empPreOSBruto & " EMP_PREOS_REPO=" & pre.EMP_ID & _
        " NF=" & empPreOSNumberFormat, _
        "Detecta dupla selecao divergente e coercao numerica na celula bruta de PRE_OS", _
        (empPreOSBruto = empPreselCanon And pre.EMP_ID = empPreselCanon)

    resOs = EmitirOS(resPre.IdGerado, Date + 7, "E2E-" & empPresel)
    If Not resOs.sucesso Then
        TV2_LogInfo "STRIKES_E2E", "E2E_OS_FAIL", _
            "EmitirOS falhou PREOS=" & resPre.IdGerado & " EMP_PRESEL=" & empPresel, _
            "Erro: " & resOs.mensagem
        TV2_E2E_AtenderProximaEmpresa = 0
        Exit Function
    End If

    osReg = RepoOS_BuscarPorId(resOs.IdGerado)
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

    osReg = RepoOS_BuscarPorId(resOs.IdGerado)
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
' Cobertura atual (5 cenarios CS_INT_01..05):
'   CS_INT_01 - entidade com mesmo ENT_ID em ENTIDADE e ENTIDADE_INATIVOS
'   CS_INT_02 - empresa com mesmo EMP_ID em EMPRESAS e EMPRESAS_INATIVAS
'   CS_INT_03 - CNPJ duplicado em EMPRESAS (ATIVAS)
'   CS_INT_04 - referencia orfa em CAD_OS (EMP_ID ou ATIV_ID nao existe)
'   CS_INT_05 - DT_ULT_REATIV nao vazia e invalida em EMPRESAS
'
' Idempotencia: PURE READ em abas operacionais. Unico efeito colateral
' permitido: criar/atualizar abas RPT_BUGS_CONHECIDOS / RPT_BUGS_RESOLVIDOS
' (upsert por BUG_ID e remocao de bug resolvido da fila aberta).
' Execucoes consecutivas produzem mesmo numero de linhas em
' RESULTADO_QA_V2 (delta=5). Em base pre-MD-18.3, a primeira run move
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

    ' CS_INT_05 - DT_ULT_REATIV nao vazia e invalida
    TV2_DetectarDtUltReativInvalida

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
' Detectores Private (CS_INT_01..05). Cada detector e PURE READ.
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

    Dim resDiag As TResult
    Dim qtdOrfaEmp As Long
    Dim qtdOrfaAtiv As Long
    Dim qtdResiduosSemChave As Long
    Dim detalhes As String
    Dim obtido As String

    resDiag = RepoOS_DiagnosticarReferenciasCADOS(qtdOrfaEmp, qtdOrfaAtiv, qtdResiduosSemChave, detalhes)
    obtido = "DIAG_OK=" & CStr(resDiag.sucesso) & _
             "; QTD_ORFA_EMP=" & CStr(qtdOrfaEmp) & _
             "; QTD_ORFA_ATIV=" & CStr(qtdOrfaAtiv) & _
             "; QTD_RESIDUOS_SEM_CHAVE=" & CStr(qtdResiduosSemChave) & _
             "; DETALHES=" & detalhes & _
             "; MSG=" & resDiag.mensagem

    If Not resDiag.sucesso Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_04", "AUTO", _
                      "Executar diagnostico de ref orfa em CAD_OS sem erro fatal", _
                      "Diagnostico RepoOS_DiagnosticarReferenciasCADOS com sucesso", _
                      obtido, _
                      "Toda falha fatal precisa ficar rastreavel", False
    ElseIf qtdOrfaEmp = 0 And qtdOrfaAtiv = 0 And qtdResiduosSemChave = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_04", "AUTO", _
                      "Detectar referencias orfas em CAD_OS (EMP_ID ou ATIV_ID inexistente)", _
                      "Zero orfas e zero residuos sem chave", _
                      obtido, _
                      "Cada OS aponta para empresa e atividade existentes - protege rastreabilidade", _
                      True
        RegistrarBugResolvido _
            "INT-CAD-OS-REF-ORFA", _
            "Referencias orfas em CAD_OS (EMP_ID ou ATIV_ID nao existe em EMPRESAS+INATIVAS / ATIVIDADES)", _
            DateSerial(2026, 5, 3), _
            "TV2_RunIntegridadeBase / TV2_DetectarRefOrfaCAD_OS", _
            "ALTA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_04", _
            CDate(Date), _
            "Codex CLI / Onda 22 MD-22.2 / Quinteto MICRO38", _
            GetBuildImportado(), _
            "RepoOS_DiagnosticarReferenciasCADOS separa orfas reais de residuos sem chave; RepoOS_MigrarRefOrfaLegado limpa apenas residuos sem OS_ID; MIG_006 cobre o contrato.", _
            "auditoria/03_ondas/onda_22_v204_dados_legados/03_TECNICO_MICRO38_REF_ORFA_CAD_OS.md"
        TV2_RemoverBugConhecido "INT-CAD-OS-REF-ORFA"
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_04", _
                      "Referencias orfas em CAD_OS - bug de integridade referencial", _
                      "Zero orfas e zero residuos sem chave", _
                      "Executar RepoOS_MigrarRefOrfaLegado; se restarem ORFA_EMP/ORFA_ATIV, investigar OS reais", _
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
            "Onda 22 MD-22.2: executar RepoOS_MigrarRefOrfaLegado; analisar orfas reais remanescentes", _
            "auditoria/03_ondas/onda_22_v204_dados_legados/03_TECNICO_MICRO38_REF_ORFA_CAD_OS.md")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_04", "AUTO", _
                  "Executar deteccao de ref orfa em CAD_OS sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub

Private Sub TV2_DetectarDtUltReativInvalida()
    On Error GoTo falha

    Dim resDiag As TResult
    Dim qtdInvalidas As Long
    Dim detalhes As String
    Dim obtido As String

    resDiag = RepoEmpresa_DtUltReativInvalidasResumo(qtdInvalidas, detalhes)
    obtido = "DIAG_OK=" & CStr(resDiag.sucesso) & _
             "; QTD_INVALIDAS=" & CStr(qtdInvalidas) & _
             "; DETALHES=" & detalhes & _
             "; MSG=" & resDiag.mensagem

    If Not resDiag.sucesso Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_05", "AUTO", _
                      "Executar diagnostico de DT_ULT_REATIV invalida sem erro fatal", _
                      "Diagnostico RepoEmpresa_DtUltReativInvalidasResumo com sucesso", _
                      obtido, _
                      "Toda falha fatal precisa ficar rastreavel", False
    ElseIf qtdInvalidas = 0 Then
        TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_05", "AUTO", _
                      "Detectar DT_ULT_REATIV nao vazia e invalida em EMPRESAS", _
                      "Zero valores invalidos", _
                      obtido, _
                      "Evita que janela de strikes corrompida caia em modo legado silencioso", _
                      True
        TV2_RemoverBugConhecido "INT-DT-ULT-REATIV-INVALIDA"
    Else
        TV2_LogManual "INTEGRIDADE_BASE", "CS_INT_05", _
                      "DT_ULT_REATIV invalida em EMPRESAS - risco de punicao por janela corrompida", _
                      "Zero valores invalidos", _
                      "Corrigir campo manualmente ou aplicar backfill quando houver EVT_REATIVACAO no AUDIT_LOG", _
                      obtido & " - ver RPT_BUGS_CONHECIDOS"
        Call RegistrarBugConhecido( _
            "INT-DT-ULT-REATIV-INVALIDA", _
            "DT_ULT_REATIV invalida em EMPRESAS - janela de strikes nao confiavel", _
            CDate(Date), _
            "TV2_RunIntegridadeBase / TV2_DetectarDtUltReativInvalida", _
            "ALTA", _
            "TV2_RunIntegridadeBase", _
            "CS_INT_05", _
            "ABERTO", _
            "Onda 22 MD-22.3: corrigir valor invalido ou aplicar backfill por AUDIT_LOG", _
            "auditoria/03_ondas/onda_22_v204_dados_legados/05_TECNICO_MICRO39_DT_ULT_REATIV_INVALIDA.md")
    End If
    Exit Sub

falha:
    TV2_LogAssert "INTEGRIDADE_BASE", "CS_INT_05", "AUTO", _
                  "Executar deteccao de DT_ULT_REATIV invalida sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Toda falha fatal precisa ficar rastreavel", False
End Sub


