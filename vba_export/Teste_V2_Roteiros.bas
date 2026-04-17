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
    Dim rodizio As TRodizioResultado
    Dim resPre As TResult
    Dim resRec As TResult
    Dim resOs As TResult
    Dim resAval As TResult
    Dim notas(1 To 10) As Integer
    Dim preosId As String
    Dim osId As String
    Dim i As Long

    On Error GoTo falha

    TV2_InitExecucao "SMOKE", visual

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

    TV2_LogManual "SMOKE", "MIG_001", _
                  "Entidade inexistente deve falhar no servico de Pre-OS", _
                  "Svc_PreOS retorna erro sem depender de validacao do formulario", _
                  "Lacuna conhecida aprovada para migracao UI -> servico", _
                  "Cobrir quando a guarda de ENT_ID for centralizada em Svc_PreOS"
    TV2_LogManual "SMOKE", "MIG_002", _
                  "Data prevista invalida deve falhar no servico de OS", _
                  "Svc_OS rejeita data incoerente sem depender de validacao do formulario", _
                  "Lacuna conhecida aprovada para migracao UI -> servico", _
                  "Cobrir quando a guarda de data entrar em Svc_OS"
    TV2_LogManual "SMOKE", "MIG_003", _
                  "Divergencia sem justificativa deve falhar no servico de avaliacao", _
                  "Svc_Avaliacao rejeita divergencia sem depender de validacao do formulario", _
                  "Lacuna conhecida aprovada para migracao UI -> servico", _
                  "Cobrir quando a regra de justificativa entrar em Svc_Avaliacao"

    TV2_FinalizarExecucao "SMOKE"
    Exit Sub

falha:
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
