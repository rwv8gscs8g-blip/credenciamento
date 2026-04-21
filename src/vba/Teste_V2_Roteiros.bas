Attribute VB_Name = "Teste_V2_Roteiros"
Option Explicit

' ============================================================
' Teste_V2_Roteiros
' Suites executaveis da bateria V2:
' - smoke rapido / assistido
' - stress deterministico
' ============================================================

Public Sub TV2_RunSmoke(Optional ByVal visual As Boolean = False)
    Dim fila As String
    Dim filaAntes As String
    Dim filaDepois As String
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
    For i = 1 To 10
        notas(i) = 8
    Next i
    resAval = AvaliarOS(osId, "QA V2", notas, 2, "Cenario smoke V2", "", Date + 6, Date + 15)
    TV2_LogAssert "SMOKE", "SMK_007", "AUTO", _
                  "Avaliar OS e concluir o ciclo", _
                  "OS concluida e fila com ordem integra", _
                  "SUCESSO_AVAL=" & CStr(resAval.Sucesso) & "; STATUS_OS=" & TV2_StatusOS(osId) & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()), _
                  "Fecha o fluxo core ponta a ponta no nivel de servico", _
                  (resAval.Sucesso And TV2_StatusOS(osId) = "CONCLUIDA" And TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3))

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
    TV2_ProtegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    resRec = AvancarFila("001", TV2_AtivCanonA(), True, "ATM_001_FALHA_CONTROLADA")
    TV2_DesprotegerAbaTeste SHEET_EMPRESAS, senhaFalhaAba
    TV2_LogAssert "SMOKE", "ATM_001", "AUTO", _
                  "Reverter mutacao parcial quando a segunda escrita falha", _
                  "Avanco punido falha; fila volta ao estado anterior; recusas ficam zeradas; auditoria registra rollback", _
                  "SUCESSO_AVANCO=" & CStr(resRec.Sucesso) & "; MSG=" & resRec.Mensagem & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & "; POS_001=" & CStr(TV2_PosicaoFila("001", TV2_AtivCanonA())) & "; REC_EMP=" & CStr(TV2_QtdRecusasEmpresa("001")) & "; REC_CRED=" & CStr(TV2_QtdRecusasCredenciamento("001", TV2_AtivCanonA())) & "; AUDIT=" & CStr(TV2_CountRows(SHEET_AUDIT)), _
                  "Prova atomicidade minima entre CREDENCIADOS e EMPRESAS no fluxo punido", _
                  (Not resRec.Sucesso And _
                   TV2_FilaCsv(TV2_AtivCanonA()) = "001,002,003" And _
                   TV2_PosicaoFila("001", TV2_AtivCanonA()) = 1 And _
                   TV2_QtdRecusasEmpresa("001") = 0 And _
                   TV2_QtdRecusasCredenciamento("001", TV2_AtivCanonA()) = 0 And _
                   TV2_CountRows(SHEET_AUDIT) >= 1 And _
                   TV2_AuditContemTrecho("ROLLBACK"))

    TV2_FinalizarExecucao "SMOKE"
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
    TV2_FinalizarExecucao "SMOKE"
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

        ok = ok And TV2_FilaTemOrdemIntegra(TV2_AtivCanonA(), 3)

        TV2_LogAssert "STRESS", "STR_001", "AUTO", _
                      "Manter invariantes de fila em repeticao controlada", _
                      "Fila com IDs unicos, ordem integra e posicoes estritamente crescentes", _
                      detalhe & "; FILA=" & TV2_FilaCsv(TV2_AtivCanonA()) & "; POSICOES=" & TV2_FilaComPosicoesCsv(TV2_AtivCanonA()), _
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
