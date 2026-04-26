Attribute VB_Name = "Teste_V2_Roteiros"
Option Explicit

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
                  "SUCESSO=" & CStr(resPre.Sucesso) & "; PREOS_ID=" & preosId & "; STATUS=" & TV2_StatusPreOS(preosId) & "; EMP_ID=" & TV2_EmpIdPreOS(preosId) & "; VL_EST=" & Format$(TV2_ValorEstPreOS(preosId), "0.00"), _
                  "Valida a persistencia minima da PRE_OS fora da interface", _
                  (resPre.Sucesso And preosId <> "" And _
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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; EMP_RODIZIO=" & TV2_FormatEmpId(rodizio.Empresa.EMP_ID) & "; POS_001=" & CStr(TV2_PosicaoFila("001", TV2_AtivCanonA())) & "; POS_002=" & CStr(TV2_PosicaoFila("002", TV2_AtivCanonA())) & "; POS_003=" & CStr(TV2_PosicaoFila("003", TV2_AtivCanonA())), _
                  "Captura a invariavel do filtro E: pula sem mover e sem punir", _
                  (resPre.Sucesso And rodizio.encontrou And IdsIguais(rodizio.Empresa.EMP_ID, "002") And _
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
                  "SUCESSO_RECUSA=" & CStr(resRec.Sucesso) & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; FILA=" & fila & "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Garante giro correto e punicao minima apos recusa explicita", _
                  (resRec.Sucesso And TV2_StatusPreOS(preosId) = "RECUSADA" And fila = "002,003,001" And TV2_QtdRecusasEmpresa("001") = 1)

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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
                  "; FILA_ANTES=" & filaAntes & _
                  "; EMP_COM_PENDENCIA=" & TV2_FormatEmpId(rodizioPosPendente.Empresa.EMP_ID) & _
                  "; SUCESSO_EXP=" & CStr(resExp.Sucesso) & _
                  "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & _
                  "; FILA_DEPOIS=" & filaDepois & _
                  "; EMP_APOS_EXP=" & TV2_FormatEmpId(rodizioPosExpiracao.Empresa.EMP_ID) & _
                  "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Prova que a expiracao remove o bloqueio por pendencia, pune a empresa e preserva a integridade da fila", _
                  (resPre.Sucesso And filaAntes = "001,002,003" And _
                   rodizioPosPendente.encontrou And IdsIguais(rodizioPosPendente.Empresa.EMP_ID, "002") And _
                   resExp.Sucesso And TV2_StatusPreOS(preosId) = "EXPIRADA" And _
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
                  "SUCESSO_OS=" & CStr(resOs.Sucesso) & "; OS_ID=" & osId & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & fila, _
                  "Confirma a integracao minima entre PRE_OS, OS e fila", _
                  (resOs.Sucesso And osId <> "" And _
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
                  "SUCESSO_AVAL=" & CStr(resAval.Sucesso) & _
                  "; STATUS_OS=" & TV2_StatusOS(osId) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
                  "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()) & _
                  "; STATUS_EMP_001=" & TV2_StatusEmpresa("001") & _
                  "; DT_FIM_001=" & IIf(TV2_DtFimSuspEmpresa("001") > CDate(0), Format$(TV2_DtFimSuspEmpresa("001"), "dd/mm/yyyy"), "(limpa)") & _
                  "; AUDIT_FECH=" & CStr(auditFechDepois - auditFechAntes) & _
                  "; AUDIT_SUSP=" & CStr(auditSuspDepois - auditSuspAntes) & _
                  "; RECUSAS_EMP_001=" & CStr(TV2_QtdRecusasEmpresa("001")), _
                  "Fecha o fluxo core ponta a ponta no nivel de servico", _
                  (resAval.Sucesso And _
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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; MSG=" & resPre.Mensagem & "; PRE_OS=" & CStr(TV2_CountRows(SHEET_PREOS)), _
                  "Fecha a dependencia da interface para ENT_ID invalida", _
                  (Not resPre.Sucesso And TV2_CountRows(SHEET_PREOS) = 0 And _
                   InStr(1, resPre.Mensagem, "Entidade", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    preosId = resPre.IdGerado
    resOs = EmitirOS(preosId, Date - 1, "EMP-MIG-002")
    TV2_LogAssert "SMOKE", "MIG_002", "AUTO", _
                  "Rejeitar data invalida no servico de OS", _
                  "Svc_OS retorna erro sem converter a PRE_OS e sem gravar OS", _
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; SUCESSO_OS=" & CStr(resOs.Sucesso) & "; MSG=" & resOs.Mensagem & "; STATUS_PREOS=" & TV2_StatusPreOS(preosId) & "; OS=" & CStr(TV2_CountRows(SHEET_CAD_OS)), _
                  "Fecha a dependencia da interface para DT_PREV_TERMINO incoerente", _
                  (resPre.Sucesso And Not resOs.Sucesso And _
                   TV2_StatusPreOS(preosId) = "AGUARDANDO_ACEITE" And _
                   TV2_CountRows(SHEET_CAD_OS) = 0 And _
                   InStr(1, resOs.Mensagem, "Data prevista", vbTextCompare) > 0)

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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; SUCESSO_OS=" & CStr(resOs.Sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.Sucesso) & "; MSG=" & resAval.Mensagem & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Fecha a dependencia da interface para a divergencia ficar sem motivo algum", _
                  (resPre.Sucesso And resOs.Sucesso And Not resAval.Sucesso And _
                   TV2_StatusOS(osId) = "EM_EXECUCAO" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) And _
                   InStr(1, resAval.Mensagem, "Justificativa", vbTextCompare) > 0)

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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; SUCESSO_OS=" & CStr(resOs.Sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.Sucesso) & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Preserva compatibilidade com a bateria oficial sem perder rastreabilidade", _
                  (resPre.Sucesso And resOs.Sucesso And resAval.Sucesso And _
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
                  "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & "; SUCESSO_OS=" & CStr(resOs.Sucesso) & "; SUCESSO_AVAL_1=" & CStr(resAval.Sucesso) & "; SUCESSO_AVAL_2=" & CStr(resAval2.Sucesso) & "; MSG2=" & resAval2.Mensagem & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Fecha uma transicao invalida importante sem depender do comportamento visual da interface", _
                  (resPre.Sucesso And resOs.Sucesso And resAval.Sucesso And _
                   Not resAval2.Sucesso And _
                   TV2_StatusOS(osId) = "CONCLUIDA" And _
                   TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3) And _
                   InStr(1, resAval2.Mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0)

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
    obtidoAtm = "SUCESSO_AVANCO=" & CStr(resRec.Sucesso)
    obtidoAtm = obtidoAtm & "; MSG=" & resRec.Mensagem
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
    okAtm = Not resRec.Sucesso
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
        InStr(1, resRec.Mensagem, "ROLLBACK", vbTextCompare) > 0 Or _
        InStr(1, resRec.Mensagem, "Falha ao incrementar recusa", vbTextCompare) > 0)
    TV2_LogAssert "SMOKE", "ATM_001", "AUTO", _
                  "Reverter mutacao parcial quando a segunda escrita falha", _
                  "Avanco punido falha; fila volta ao estado anterior; recusas ficam zeradas; cadastros e credenciamentos nao sofrem mutacao residual; auditoria registra rollback legivel", _
                  obtidoAtm, _
                  "Prova atomicidade ampliada entre CREDENCIADOS e EMPRESAS no fluxo punido", _
                  okAtm

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
                  "SUCESSO=" & CStr(resPre.Sucesso) & _
                  "; MSG=" & resPre.Mensagem & _
                  "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
                  "; PREOS_DEPOIS=" & CStr(qtdPreDepois), _
                  "Protege o item canônico contra associação inválida em CAD_SERV", _
                  (Not resPre.Sucesso And qtdPreAntes = 0 And qtdPreDepois = 0 And _
                   InStr(1, resPre.Mensagem, "Servico nao encontrado", vbTextCompare) > 0)

    TV2_PrepararCenarioTriploCanonico
    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    TV2_LogAssert "CANONICO", "CS_03", "AUTO", _
                  "Emitir a primeira PRE_OS para a empresa A", _
                  "PRE_OS para EMP_ID=001 em AGUARDANDO_ACEITE", _
                  "SUCESSO=" & CStr(resPre.Sucesso) & _
                  "; PREOS_ID=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; STATUS=" & TV2_StatusPreOS(resPre.IdGerado), _
                  "Abre o fluxo nominal A -> B -> C do item canônico", _
                  (resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "001") And _
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
                  "SUCESSO=" & CStr(resPre.Sucesso) & _
                  "; PREOS_B=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Prova o pulo técnico de A por OS aberta", _
                  (resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002"))

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
                  "SUCESSO=" & CStr(resPre.Sucesso) & _
                  "; MSG=" & resPre.Mensagem & _
                  "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
                  "; PREOS_DEPOIS=" & CStr(qtdPreDepois) & _
                  "; STATUS_PREOS_A=" & TV2_StatusPreOS(preosIdA) & _
                  "; STATUS_OS_A=" & TV2_StatusOS(osIdA) & _
                  "; STATUS_PREOS_B=" & TV2_StatusPreOS(preosIdB) & _
                  "; STATUS_PREOS_C=" & TV2_StatusPreOS(preosIdC) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "É o teste crítico de não travamento do cenário canônico", _
                  (Not resPre.Sucesso And qtdPreDepois = qtdPreAntes And _
                   InStr(1, resPre.Mensagem, "SEM_CREDENCIADOS_APTOS", vbTextCompare) > 0 And _
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
                  "SUCESSO_AVAL=" & CStr(resAval.Sucesso) & _
                  "; STATUS_OS_A=" & TV2_StatusOS(osIdA) & _
                  "; SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
                  "; PREOS_NOVA=" & resPre.IdGerado & _
                  "; EMP_ID=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
                  "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()), _
                  "Prova que a fila retoma do ponto correto após resolução parcial do bloqueio", _
                  (resAval.Sucesso And TV2_StatusOS(osIdA) = "CONCLUIDA" And _
                   resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "001"))

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
    obtido22 = "SUCESSO_A=" & CStr(resPre.Sucesso) & _
               "; SUCESSO_B=" & CStr(resPre2.Sucesso) & _
               "; SUCESSO_C=" & CStr(resPre3.Sucesso) & _
               "; PREOS_A=" & preosId22A & _
               "; PREOS_B=" & preosId22B & _
               "; PREOS_C=" & preosId22C & _
               "; A=" & pre22A.ATIV_ID & "|" & pre22A.SERV_ID & "|" & pre22A.STATUS_PREOS & _
               "; B=" & pre22B.ATIV_ID & "|" & pre22B.SERV_ID & "|" & pre22B.STATUS_PREOS & _
               "; C=" & pre22C.ATIV_ID & "|" & pre22C.SERV_ID & "|" & pre22C.STATUS_PREOS & _
               "; COD_A=" & TV2_CodServicoA() & _
               "; AUDIT_PREOS=" & CStr(auditEmissoes) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA())
    ok22 = resPre.Sucesso And resPre2.Sucesso And resPre3.Sucesso
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
    obtido11 = "SUCESSO_SUSP=" & CStr(resSusp.Sucesso) & _
               "; SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; DT_FIM_A=" & Format$(empA.DT_FIM_SUSP, "dd/mm/yyyy") & _
               "; POS_A=" & CStr(posA) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSusp)
    ok11 = resSusp.Sucesso And resPre.Sucesso
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
    obtido13 = "SUCESSO_SUSP=" & CStr(resSusp.Sucesso) & _
               "; SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; DT_FIM_A=" & IIf(TV2_DtFimSuspEmpresa("001") > CDate(0), Format$(TV2_DtFimSuspEmpresa("001"), "dd/mm/yyyy"), "(limpa)") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSusp) & _
               "; AUDIT_REAT=" & CStr(auditReat)
    ok13 = resSusp.Sucesso And resPre.Sucesso
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
    obtido14 = "SUCESSO_AVAL=" & CStr(resAval.Sucesso) & _
               "; STATUS_OS_B=" & TV2_StatusOS(osIdB) & _
               "; SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_B=" & empB.STATUS_GLOBAL & _
               "; DT_FIM_B=" & Format$(empB.DT_FIM_SUSP, "dd/mm/yyyy") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_SUSP=" & CStr(auditSuspDepois - auditSuspAntes)
    ok14 = resAval.Sucesso And TV2_StatusOS(osIdB) = "CONCLUIDA"
    ok14 = ok14 And resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "003")
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
    obtido16 = "SUCESSO_AVAL_B=" & CStr(resAval.Sucesso) & _
               "; SUCESSO_PREOS_C=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS_C=" & TV2_EmpIdPreOS(preosIdC) & _
               "; SUCESSO_OS_C=" & CStr(resOs.Sucesso) & _
               "; SUCESSO_AVAL_C=" & CStr(resAval2.Sucesso) & _
               "; FILA_ANTES_RETORNO=" & filaAntesRetorno & _
               "; SUCESSO_PREOS_RETORNO=" & CStr(resPre2.Sucesso) & _
               "; EMP_RETORNO=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; STATUS_B=" & empB.STATUS_GLOBAL & _
               "; DT_FIM_B=" & IIf(TV2_DtFimSuspEmpresa("002") > CDate(0), Format$(TV2_DtFimSuspEmpresa("002"), "dd/mm/yyyy"), "(limpa)") & _
               "; FILA_APOS_RETORNO=" & filaDepoisRetorno & _
               "; AUDIT_REAT=" & CStr(auditReatDepois - auditReatAntes)
    ok16 = resAval.Sucesso And resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(preosIdC), "003")
    ok16 = ok16 And resOs.Sucesso And resAval2.Sucesso
    ok16 = ok16 And filaAntesRetorno = "001,002,003"
    ok16 = ok16 And resPre2.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre2.IdGerado), "002")
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
        If Not resPre.Sucesso Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Falha ao emitir PRE_OS no ciclo " & CStr(i) & "."
        End If
        preosIdLoop = resPre.IdGerado
        empLoop = TV2_EmpIdPreOS(preosIdLoop)
        If seqObtida <> "" Then seqObtida = seqObtida & ","
        seqObtida = seqObtida & empLoop

        resOs = EmitirOS(preosIdLoop, Date + 7 + i, "EMP-CS-17-" & CStr(i))
        If Not resOs.Sucesso Then
            Err.Raise 1004, "TV2_RunCanonicoFundacao.CS_17", "Falha ao emitir OS no ciclo " & CStr(i) & "."
        End If
        osIdLoop = resOs.IdGerado

        resAval = AvaliarOS(osIdLoop, "QA CANONICO", notas, qtdLoop, "CS_17_LOOP_" & CStr(i), "", Date + 8 + i, Date + 14 + i)
        If Not resAval.Sucesso Then
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
    obtido18 = "SUCESSO_AVAL_1=" & CStr(resAval.Sucesso) & _
               "; SUCESSO_AVAL_2=" & CStr(resAval2.Sucesso) & _
               "; MSG_AVAL_2=" & resAval2.Mensagem & _
               "; SUCESSO_CANCEL=" & CStr(resCanc.Sucesso) & _
               "; MSG_CANCEL=" & resCanc.Mensagem & _
               "; STATUS_OS=" & TV2_StatusOS(osIdA) & _
               "; AUDIT_REJEICAO=" & CStr(auditRejDepois - auditRejAntes)
    ok18 = resAval.Sucesso
    ok18 = ok18 And TV2_StatusOS(osIdA) = "CONCLUIDA"
    ok18 = ok18 And Not resAval2.Sucesso
    ok18 = ok18 And InStr(1, resAval2.Mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0
    ok18 = ok18 And Not resCanc.Sucesso
    ok18 = ok18 And InStr(1, resCanc.Mensagem, "STATUS=CONCLUIDA", vbTextCompare) > 0
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
    obtido20 = "SUCESSO_PREOS=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; STATUS_A=" & empA.STATUS_GLOBAL & _
               "; POS_A=" & CStr(posA) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; AUDIT_INAT=" & CStr(auditInatDepois - auditInatAntes)
    ok20 = resPre.Sucesso And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002")
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
    qtdEmpAtivas23 = TV2_CountOcorrenciasRegistro(SHEET_EMPRESAS, PrimeiraLinhaDadosEmpresas(), COL_EMP_ID, "001", COL_EMP_CNPJ, TV2_CNPJEmpresa("001"))
    qtdEmpInativas23 = TV2_CountOcorrenciasRegistro(SHEET_EMPRESAS_INATIVAS, LINHA_DADOS, COL_EMP_ID, "001", COL_EMP_CNPJ, TV2_CNPJEmpresa("001"))
    obtido23 = "SUCESSO_INAT=" & CStr(resInatEmp.Sucesso) & _
               "; SUCESSO_PREOS_B=" & CStr(resPre.Sucesso) & _
               "; EMP_PREOS_B=" & TV2_EmpIdPreOS(resPre.IdGerado) & _
               "; SUCESSO_REAT=" & CStr(resReatEmp.Sucesso) & _
               "; SUCESSO_PREOS_A=" & CStr(resPre2.Sucesso) & _
               "; EMP_PREOS_A=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; STATUS_A=" & TV2_StatusEmpresa("001") & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; ATIVAS=" & CStr(qtdEmpAtivas23) & _
               "; INATIVAS=" & CStr(qtdEmpInativas23) & _
               "; TOTAL=" & CStr(TV2_CountOcorrenciasEmpresa("001")) & _
               "; AUDIT_INAT=" & CStr(auditInatDepois - auditInatAntes) & _
               "; AUDIT_REAT=" & CStr(auditReatDepois - auditReatAntes)
    ok23 = resInatEmp.Sucesso And resPre.Sucesso And resReatEmp.Sucesso And resPre2.Sucesso
    ok23 = ok23 And IdsIguais(TV2_EmpIdPreOS(resPre.IdGerado), "002")
    ok23 = ok23 And IdsIguais(TV2_EmpIdPreOS(resPre2.IdGerado), "001")
    ok23 = ok23 And TV2_StatusEmpresa("001") = "ATIVA"
    ok23 = ok23 And TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003"
    ok23 = ok23 And TV2_QtdCredenciadosNoItem(TV2_AtivCanonA(), "001") = 3
    ok23 = ok23 And qtdEmpAtivas23 = 1 And qtdEmpInativas23 = 0 And TV2_CountOcorrenciasEmpresa("001") = 1
    ok23 = ok23 And (auditInatDepois - auditInatAntes) = 1
    ok23 = ok23 And (auditReatDepois - auditReatAntes) = 1
    TV2_LogAssert "CANONICO", "CS_23", "AUTO", _
                  "Validar ida e volta de empresa entre ativo e inativo", _
                  "A some da seleção enquanto inativa e volta a ser escolhida após reativação, sem duplicidade cadastral", _
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
    obtido24 = "SUCESSO_INAT=" & CStr(resInatEnt.Sucesso) & _
               "; SUCESSO_PREOS_FALHA=" & CStr(resPre.Sucesso) & _
               "; MSG=" & resPre.Mensagem & _
               "; PREOS_ANTES=" & CStr(qtdPreAntes) & _
               "; PREOS_DEPOIS=" & CStr(qtdPreDepois) & _
               "; SUCESSO_REAT=" & CStr(resReatEnt.Sucesso) & _
               "; SUCESSO_PREOS_OK=" & CStr(resPre2.Sucesso) & _
               "; EMP_PREOS=" & TV2_EmpIdPreOS(resPre2.IdGerado) & _
               "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & _
               "; ATIVAS=" & CStr(qtdEntAtivas24) & _
               "; INATIVAS=" & CStr(qtdEntInativas24) & _
               "; TOTAL=" & CStr(TV2_CountOcorrenciasEntidade("001")) & _
               "; AUDIT_INAT=" & CStr(auditEntInatDepois - auditEntInatAntes) & _
               "; AUDIT_REAT=" & CStr(auditEntReatDepois - auditEntReatAntes)
    ok24 = resInatEnt.Sucesso And Not resPre.Sucesso And qtdPreDepois = qtdPreAntes
    ok24 = ok24 And InStr(1, resPre.Mensagem, "Entidade", vbTextCompare) > 0
    ok24 = ok24 And resReatEnt.Sucesso And resPre2.Sucesso
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
               "; SUCESSO_REC=" & CStr(resRec.Sucesso) & _
               "; SUCESSO_EXP=" & CStr(resExp.Sucesso) & _
               "; SUCESSO_OS=" & CStr(resOs.Sucesso) & _
               "; SUCESSO_AVAL=" & CStr(resAval.Sucesso) & _
               "; SUCESSO_RB=" & CStr(resRollback.Sucesso)
    ok21 = resPre.Sucesso And resRec.Sucesso
    ok21 = ok21 And resPre2.Sucesso And resExp.Sucesso
    ok21 = ok21 And resPre3.Sucesso And resOs.Sucesso And resAval.Sucesso
    ok21 = ok21 And Not resRollback.Sucesso
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

        If resPre.Sucesso Then
            If (i Mod 2) = 1 Then
                resRec = RecusarPreOS(preosId, "RECUSA_STRESS_" & CStr(i))
                detalhe = "ITER=" & CStr(i) & "; ETAPA=RECUSA; PREOS=" & preosId & "; SUCESSO=" & CStr(resRec.Sucesso)
                ok = resRec.Sucesso
            Else
                resOs = EmitirOS(preosId, Date + 3 + i, "EMP-STRESS-" & CStr(i))
                osId = resOs.IdGerado

                If resOs.Sucesso Then
                    TV2_PreencherNotas notas, 7 + (i Mod 2)
                    resAval = AvaliarOS(osId, "QA STRESS V2", notas, qtd, "Stress V2", "", Date + 4 + i, Date + 20 + i)
                    detalhe = "ITER=" & CStr(i) & "; ETAPA=OS+AVAL; PREOS=" & preosId & "; OS=" & osId & "; SUCESSO_OS=" & CStr(resOs.Sucesso) & "; SUCESSO_AVAL=" & CStr(resAval.Sucesso)
                    ok = resAval.Sucesso
                Else
                    detalhe = "ITER=" & CStr(i) & "; ETAPA=OS; PREOS=" & preosId & "; SUCESSO_OS=" & CStr(resOs.Sucesso)
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
    If Not resPre.Sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS04", "Falha ao emitir PRE_OS inicial de A."
    End If

    preosIdA = resPre.IdGerado
    resOs = EmitirOS(preosIdA, Date + 7, "EMP-CS-04")
    If Not resOs.Sucesso Then
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
    If Not resPre.Sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS06", "Falha ao emitir PRE_OS de B."
    End If
    preosIdB = resPre.IdGerado

    resPre = EmitirPreOS("001", TV2_CodServicoA(), 1)
    If Not resPre.Sucesso Then
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
    If Not resPre.Sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS14", "Falha ao emitir PRE_OS de B."
    End If
    preosIdB = resPre.IdGerado

    resOs = EmitirOS(preosIdB, Date + 7, "EMP-CS-14-B")
    If Not resOs.Sucesso Then
        Err.Raise 1004, "TV2_CS_PrepararEstadoAteCS14", "Falha ao emitir OS de B."
    End If
    osIdB = resOs.IdGerado
End Sub
