Attribute VB_Name = "App_Release"
Option Explicit

' Metadata centralizada da release atual.
' O Menu_Principal apenas consome estas funcoes.

Public Const APP_RELEASE_ATUAL As String = "V12.0.0202"
Public Const APP_RELEASE_STATUS As String = "RELEASE_CANDIDATE"
Public Const APP_RELEASE_CANAL As String = "DESENVOLVIMENTO"
Public Const APP_RELEASE_ALVO As String = "V12.0.0204"
Public Const APP_RELEASE_BUILD_KEY As String = "V12.0.0202|DESENVOLVIMENTO|V12.0.0204"
' V12.0.0203 ONDA 5 - carimbo manual do build (sem rodar publicar_vba_import.sh).
' V12.0.0203 ONDA 10 - bump auto via IV3_BumpBuildLabel / ImportarPacoteV3_Delta.
' V12.0.0203 ONDA 11 - rc1 bump: TAG=v12.0.0203-rc1, STATUS=RELEASE_CANDIDATE,
' EVIDENCE_DIR=auditoria/evidencias/V12.0.0203, TEST_KEY=quarteto-2026-05-02
' (Quarteto = V1+V2_Smoke+V2_Canonica+E2E_Strikes vira gate oficial; Q7 do
' operador 2026-05-02). APP_RELEASE_ATUAL fica V12.0.0202 ate FECH final.
' Identificador semantico: <commit-base>+ONDA<NN>-em-homologacao quando a arvore
' tem mudancas nao commitadas; trocar para <commit-base>+ONDA<NN>-homologado
' apos commitar a onda. AppRelease_BuildImportadoRotulo trata os dois sufixos.
' Padrao iterativo Onda 10+: <commit-base>+ONDA<NN>.MICRO<MM>-<descricao>-incremental
' enquanto microdelta esta em validacao; <commit-base>+ONDA<NN>-aprovada apos onda fechada.
' V12.0.0203 ONDA 17 MD-17.1.a (2026-05-03) - bump para fixture-factory + namespacing
' + RestaurarConfigBaseline generalizado + TV2_NextDataRow promovido a Public.
' V12.0.0203 ONDA 17 MD-17.1.b (2026-05-03) - 5 cenarios novos: CS_BORDA_MAX2,
' CS_BORDA_MAX5, CS_NOTA_ZERO em V2_Canonica + CS_E2E_REATIV2STRIKES,
' CS_E2E_5EMPS em E2E_Strikes; helpers TV2_FF_AtenderProximaEmpresa +
' TV2_FF_RodadaCompleta em Roteiros. Q-MD17.1.b decisoes: encaixe (a),
' reativacao zera contador (a) > revisada para AMARELO via aud_44, 5EMPS = 3 voltas (b).
' V12.0.0203 ONDA 17 MD-17.1.b-fix1 (2026-05-03) - fix do Quarteto reprovado em
' VR_20260503_020405: TV2_FixtureFactory gerava ATIV_ID alfanumerico que era
' coercido para "000" por TV2_Pad3 dentro de TV2_CredenciarAtividade. Fix:
' ATIV_ID via hash determinístico do escopo (faixa 900-979). Engine ganha 3
' helpers Private: TV2_FF_HashEscopoParaAtivId, TV2_FF_LimparAtividadesEscopo,
' TV2_FF_LimparLinhaPorIdExato.
' V12.0.0203 ONDA 17 MD-17.1.b-fix2 (2026-05-03) - fix2 do erro de coordenacao do
' fix1: ao escolher Opcao A do procedimento (restaurar workbook para MD-17.1.a),
' o Roteiros voltou ao estado anterior aos 5 cenarios novos. fix1 nao re-importou
' o Roteiros (so Engine + App_Release). Quarteto VR_20260503_025114 verde mas
' incompleto (V2_Canonica=20/0 em vez de 23/0; E2E_Strikes=64/0 em vez de 66/0).
' fix2 re-aplica ABG-Teste_V2_Roteiros.bas (com os 5 cenarios) + bumpa label.
' V12.0.0203 ONDA 17 MD-17.1.c-pre TENTATIVA REVERTIDA (2026-05-03) - regeneracao
' dos 4 .code-only.txt a partir dos .frm causou Err=50132 no V3 cm.AddFromString
' (Reativa_Entidade primeiro a falhar). Causa raiz nao isolada com confianca em
' tempo razoavel. Decisao: reverter, manter drift M9 documentado, e usar
' comparacao tolerante em V4 da TV2_RunUiSmokeReadOnly futura. Licao M15 candidata.
' Estado restaurado para MD-17.1.b-fix2; chat encerrando para handoff novo Opus 4.7.
' TAG e TEST_KEY mantidos (rc2 + quinteto-* serao bumpados em MD-17.5).
' V12.0.0203 ONDA 17 MD-17.1.c real (2026-05-03 - chat 2 Opus 4.7) - adiciona
' Public Sub TV2_RunUiSmokeReadOnly + 7 helpers Private (TV2_UI_VbeCanary,
' TV2_UI_RepoRoot, TV2_UI_VerificarV1..V4, TV2_UI_LerArquivoTexto,
' TV2_UI_LerSecaoCodigoFrm, TV2_UI_NormalizarGammaTexto) em Roteiros. Wire-up
' dentro de TV2_RunSmoke antes de TV2_FinalizarExecucao "SMOKE". 4 forms x 5
' verificacoes (V1=existencia controles canonicos, V2=set equality STRICT=False,
' V3=helpers UI esperados Q-MD17.1.c.2=A, V4=.frm<->.code-only gamma tolerante,
' V5_CANARY=VBE acessivel). Cap M11=0 imports em forms preservado. Listas
' canonicas hardcoded derivadas de grep nos .frm em src/vba/.
' V12.0.0203 ONDA 17 MD-17.1.c-fix1 (2026-05-03) - fix do Quarteto reprovado
' em VR_20260503_141832 (V2_Smoke=19/4): 2 bugs do MD original. (a) canControles
' incluiu nomes de variaveis VBA WithEvents (mTxtBusca/mTxtBuscaTopo/
' mTxtFiltroCredLista) que NAO sao controles - sao ponteiros bound dinamicamente
' via UI_PegarTextBoxBuscaTopoDireita ou Me.Controls(). Removidos. Em Credencia_Empresa
' troca TxtFiltro_CredenciamentoServico (tentativa primaria) por CR_TxtFiltroListaDin
' (fallback efetivo no .frx, confirmado via CSV de falhas). (b) TV2_UI_RepoRoot
' assumia workbook em V12-202-Z003/*.xlsm e usava ThisWorkbook.Path & "\.."
' - workbook esta na raiz do repo (confirmado: CSV salvo em raiz). Fix: probe
' 2 candidatos e retorna o que tem src\vba. Sem mudancas em Engine, V2-V5,
' helpers TV2_UI_*, ou tabelas canonicas de helpers (V3). Cap M11=0 mantido.
' V12.0.0203 ONDA 17 MD-17.1.c-fix2 (2026-05-03) - fix do Quarteto reprovado
' em VR_20260503_152729 (V2_Smoke=23/5). 2 bugs nao isolados em fix1:
' (a) Em Credencia_Empresa, TxtFiltro tambem nao eh estatico no .frx -
' CR_EnsureFiltroListaDinamico cria via Me.Controls.Add em runtime. Smoke
' read-only nunca ve. canControles(4) reduzido para "CR_Credenciar,CR_Lista".
' (b) V4 gamma reprovou nos 4 forms com diff ~170 chars. TV2_UI_LerSecaoCodigoFrm
' cortava o .frm em "Attribute VB_Name" (incluindo 5 attrs de form: VB_Name,
' VB_GlobalNameSpace, VB_Creatable, VB_PredeclaredId, VB_Exposed) que NAO
' existem no .code-only.txt (que comeca direto no codigo). Fix: cortar APOS
' "Attribute VB_Exposed". Sem mudancas em Engine, helpers TV2_UI_VbeCanary/
' VerificarV1/V2/V3, NormalizarGammaTexto, ou helpers de helpers. Cap M11=0
' mantido. M16 candidata oficializada na MD-17.5: "controles dinamicos via
' Me.Controls.Add nao sao detectaveis por smoke read-only".
' V12.0.0203 ONDA 17 MD-17.1.c-fix3 (2026-05-03) - fix do Quarteto reprovado
' em VR_20260503_155854 (V2_Smoke=23/4). Diff residual de 2-3 chars nos 4
' V4 gamma. Causa raiz isolada via reproducao bash do algoritmo VBA exato:
' .frm tem 2-3 trailing newlines a mais que .code-only.txt (verificado via
' TAIL_HEX). Fix: TV2_UI_NormalizarGammaTexto ganha regra (d) skip linhas
' vazias apos RTrim. Linhas em branco nao mudam significado de codigo VBA.
' Validacao bash pre-import: GAMMA MATCH em todos 4 forms (Reativa_Entidade
' 11862 chars, Reativa_Empresa 12299, Cadastro_Servico 8525, Credencia_Empresa
' 12774). MD-17.1.c real fechada com Quarteto APROVADO. Licoes oficializadas
' em PHAGOCYTOSIS: L22 (estrutura .frm vs .code-only.txt), L23 (controles
' dinamicos via Me.Controls.Add), L24 (gamma skip linhas vazias), M15 (V3
' cm.AddFromString Err=50132 workaround), M16 (reproducao bash/python do
' algoritmo VBA antes do import), M17 (disciplina canonico UI 3 camadas).
' V12.0.0203 ONDA 17 MD-17.1.d.I (2026-05-03) - perf gamma conservador.
' Adiciona 3 globals Private (gTV2OldCalc, gTV2OldScreen, gTV2OldEvents) +
' 2 helpers Private (TV2_PerfModeOn, TV2_PerfModeRestore) em Engine. Wire-up:
' TV2_InitExecucao chama TV2_PerfModeOn apos timer; TV2_FinalizarExecucao
' chama TV2_PerfModeRestore antes da MsgBox + handler erro_fatal_handler
' garante restore mesmo em erro fatal (Excel nao trava em Calculation manual).
' TV2_PausarVisual vira no-op (Application.Wait removido). Idempotencia
' GARANTIDA por design: zero formulas em Repo_*/Svc_* lidas pelos testes
' (Calculation manual safe), zero Worksheet_Change handlers fora de Auto_Open
' (EnableEvents=False safe), ScreenUpdating=False ja padrao em outros modulos.
' VR_20260503_171717 Run 2 confirmou idempotencia empirica + speed-up 11.5%
' (13m00 vs baseline 14m41s). Alvo HF8 <10min nao atingido - debito MD-17.1.d.I.b
' aberto para gamma profundo (batch I/O, refatoracao setup duplicado).
' V12.0.0203 ONDA 17 MD-17.1.d.II (2026-05-03) - visibility alfa (status bar
' rica). Adiciona Util_Config.GetStatusBarVerbosity (default 2; range 0-3) +
' 2 globals Private em Engine (gTV2VerbosityCached, gTV2TotalCenarios) +
' Public Sub TV2_StatusBar(suite, cenAtual, totN, nomeCenario, etapa) com
' 4 niveis. Wire-up: TV2_InitExecucao caches verbosity + accepts Optional
' totalCenarios; TV2_LogLinha chama TV2_StatusBar SEMPRE (nao apenas em
' modo visual - resolve sensacao Quarteto travado); TV2_FinalizarExecucao
' chama TV2_StatusBar de "concluido" antes do MsgBox. Idempotencia trivial.
' VR_20260503_175218 confirmou Quarteto APROVADO + visibility OK em SMOKE/
' CANONICO/E2E_STRIKES. Feedback operador: V1_RAPIDA estatica (BO sem update
' fora de modo visual) + msg final mostrava CSV path mesmo sem confirmar
' geracao. 2 fixes em MD-17.1.d.III.
' V12.0.0203 ONDA 17 MD-17.1.d.III (2026-05-03) - hotfix visibility V1_RAPIDA
' + msg CSV resumo. (a) Teste_Bateria_Oficial.bas linha 1502: StatusBar update
' SEMPRE (nao apenas modo visual); coloracao + scroll continuam restritos.
' Resolve V1_RAPIDA estatica durante CT_ValidarRelease_*. (b) Teste_Validacao_
' Release.bas linhas 49+147: msg final verifica Dir(csvResumo) <> "" antes
' de mostrar; status explicito "(gerado)" / "NAO GERADO" / "nao exportado".
' Resolve sensacao de "passa imagem errada" quando operador procurava CSV
' em path errado. CSV de fato existe em auditoria/evidencias/V12.0.0203/
' (verificado pre-fix; era sempre gerado).
' V12.0.0203 ONDA 17 MD-17.1.e (2026-05-03) - limpeza C3 + renumeracao
' semantica do menu Central V2. CT2_AbrirCentral renumerada para fluxo
' Gates -> V1 -> V2 -> Visualizacao -> Utilitarios (16 opcoes contiguas).
' Removidas da MENSAGEM as opcoes [2] Smoke assistido, [4] Stress assistido
' e [6] Roteiro assistido V2 - funcao pedagogica resolvida pela status bar
' (L26/L27 oficial em MD-17.1.d). Subs CT2_ExecutarSmokeAssistido /
' CT2_ExecutarStressAssistido / TV2_AbrirRoteiroAssistido permanecem Public,
' callable via janela Imediato. Adicionadas duas Subs novas:
' CT2_ExecutarBateriaV1 (atalho [3] para RunBateriaOficial) e
' CT2_ExecutarLimparTestes (atalho [16] para CT_LimparTestesAntigos, novo
' wrapper Public em Central_Testes.bas chamando CT_LimparArtefatosTesteV1).
' Idempotencia trivial (menu = roteamento + apresentacao). Quinteto Minimo
' [1] reservado para MD-17.3 (decisao operador 2026-05-03 para evitar falso
' positivo: opcao 2 do hearback Q-MD17.1.e).
' V12.0.0203 ONDA 17 BLOCO A (Caminho C - 2026-05-03 chat 4 Opus 4.7) -
' fechamento da Onda 17 em pacote unificado MICRO24 cobrindo MD-17.2 +
' MD-17.3 + MD-17.4. MD-17.2 entrega TV2_RunIntegridadeBase (suite PURE READ
' com 4 cenarios CS_INT_01..04: entidade dup ATIVA+INATIVA, empresa dup
' ATIVA+INATIVA, CNPJ dup em EMPRESAS, ref orfa em CAD_OS) + RPT_BUGS_
' CONHECIDOS (10 colunas A-J) + helpers Public RegistrarBugConhecido
' (upsert por BUG_ID) + TV2_AbrirRPTBugsConhecidos. Entrada inicial em
' RPT_BUGS_CONHECIDOS: DT-17-REATIV-STRIKES (descoberto MD-17.1.b,
' resolucao Onda 18 MD-18.1). MD-17.3 entrega CT_ValidarRelease_
' QuintetoMinimo (V1+V2_Smoke+V2_Canonica+E2E_Strikes+IntegridadeBase) +
' helpers Quinteto (StatusGeral, Sintaxe, ExportarResumoCSV,
' EscreverResumoIA, FormatarSheet) espelhando padrao Quarteto +
' renumeracao Central V2 para 17 opcoes ([1]Quinteto OFICIAL, [2]Quarteto,
' [3]Trio, [4]V1, [5-9]V2 suites, [10-15]Visualizacao, [16]Roteiro,
' [17]Limpar). MD-17.4 valida Quinteto + Quarteto verde simultaneo.
' Idempotencia: TV2_RunIntegridadeBase e PURE READ + UPSERT em
' RPT_BUGS_CONHECIDOS. Bloco A nao toca forms (C11 Cap M10=0 mantido).
' DT-MD17.1.e-STATUSBAR-HINT (toca form) adiado para Bloco B / Onda 18
' onde C11 ja esta liberado. APP_RELEASE_TEST_KEY bumpado para
' "quinteto-2026-05-04". Build label: ONDA17.MD2-bloco-a-fechamento-onda17.
' V12.0.0203 ONDA 18 MD-18.1a (2026-05-04) - schema DT_ULT_REATIV.
' Adiciona EMPRESAS/EMPRESAS_INATIVAS coluna U COL_EMP_DT_ULT_REATIV,
' campo TEmpresa.DT_ULT_REATIV, cabecalho LimpaBase, leitura Repo_Empresa,
' cadastros canonicos/testes e copia de inativos ate a nova coluna U.
' Forms ficam fora deste delta por M15; cadastro direto deixa U vazia por
' omissao. Logica de janela de strikes fica para MD-18.1b.
' Fix2: Preencher.Limpa_Base chama LimpaBaseTotalReset sem qualificador de
' modulo para evitar erro de compile pos Remove+Import de Mod_Limpeza_Base.
' V12.0.0203 ONDA 18 MD-18.1b (2026-05-04) - janela de strikes apos
' reativacao. Svc_Rodizio.Reativar grava DT_ULT_REATIV; Repo_Avaliacao
' adiciona ContarStrikesParaPunicao com corte por COL_OS_DT_FECHAMENTO;
' Svc_Avaliacao usa o contador de punicao. CS_E2E_REATIV2STRIKES vira
' verde e novos cenarios cobrem DT_ULT_REATIV, historico total, janela,
' re-suspensao pos-3 strikes e modo legado com DT_ULT_REATIV vazia.
' V12.0.0203 ONDA 18 MD-18.3 (2026-05-04) - cria RPT_BUGS_RESOLVIDOS
' e move DT-17-REATIV-STRIKES da fila aberta para resolvidos apos Quinteto
' VR_20260504_060256 aprovar MICRO26. INT-CAD-OS-REF-ORFA permanece aberto.
' V12.0.0203 ONDA 18 MD-18.2 (2026-05-04) - adiciona dica no primeiro
' aviso do Modo Treinamento para acompanhar progresso na barra de status.
' V12.0.0203 ONDA 17+18 MD-17.5 (2026-05-04) - fechamento conjunto
' em rc3 apos Bloco A + Bloco B verdes. Final fica pos-auditoria cruzada.
' V12.0.0203 MICRO30 (2026-05-04) - correcao R1 final pre-teste manual:
' Reativa_Empresa.frm passa a chamar ReativarLinhaEmpresa apos mover a linha
' de EMPRESAS_INATIVAS para EMPRESAS, gravando DT_ULT_REATIV e auditoria.
' MICRO30-fix1: ClassificaEmpresa passa a ordenar tambem a coluna U para
' preservar DT_ULT_REATIV apos a reativacao e classificacao da aba.
' V12.0.0204 ONDA 20 MD-20.1-20.5 (2026-05-05) - P0 UI:
' Reativa_Entidade passa por Svc_Entidade + AUDIT_LOG; reativacao de
' empresa preserva/restaura credenciamentos por atividade; handlers
' mutadores ganham guard de reentrada.
' V12.0.0204 ONDA 21 MD-21.1 (2026-05-05) - GravarStatusEmpresa passa
' a retornar TResult e suspensao/reativacao validam persistencia antes de
' declarar sucesso. AvancarFila deixa de mascarar falha de Suspender apos
' recusa punivel.
' V12.0.0204 ONDA 21 MD-21.2-21.3 (2026-05-05) - AvaliarOS nao declara
' sucesso quando Suspender ou AvancarFila falha apos a avaliacao ja salva;
' retorna falha explicita com IdGerado da OS para triagem operacional.
' V12.0.0204 ONDA 21 MD-21.4 (2026-05-05) - ContarStrikes* ganha caminho
' com TResult + qtd ByRef; AvaliarOS usa ContarStrikesParaPunicaoResultado
' para impedir decisao punitiva baseada em zero silencioso.
' V12.0.0204 ONDA 21 MD-21.5 (2026-05-05) - EmitirOS prepara PRE_OS
' antes de criar OS e remove a OS recem-criada em falha posterior.
' V12.0.0204 ONDA 21 MD-21.5 fix1 (2026-05-05) - wrappers RepoOS_*
' evitam falha de resolucao do VBE em chamada qualificada do modulo de OS.
' V12.0.0204 ONDA 21 MD-21.5 fix2 (2026-05-05) - elimina
' qualificacoes do buscador de OS remanescentes em servico, testes e UI.
' V12.0.0204 ONDA 21 MD-21.5 fix3 (2026-05-05) - pacote cumulativo
' reimporta Svc_OS junto dos wrappers para workbook reaberto sem salvar fix1.
Public Const APP_BUILD_IMPORTADO As String = "f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix3"
Public Const APP_BUILD_BRANCH As String = "codex/v12-0-0203-governanca-testes"
Public Const APP_BUILD_GERADO_EM As String = "2026-05-05 00:00"
Public Const APP_RELEASE_TAG As String = "v12.0.0204-dev"
Public Const APP_RELEASE_EVIDENCE_DIR As String = "auditoria/evidencias/V12.0.0204"
Public Const APP_RELEASE_TEST_KEY As String = "quinteto-v204-onda21-md21-5-fix3-2026-05-05"
Public Const APP_GITHUB_REPO_URL As String = "https://github.com/rwv8gscs8g-blip/credenciamento"
Public Const APP_GITHUB_RELEASE_NOTES_URL As String = APP_GITHUB_REPO_URL & "/tree/main/obsidian-vault/releases"

Public Function AppRelease_Atual() As String
    AppRelease_Atual = APP_RELEASE_ATUAL
End Function

Public Function AppRelease_Status() As String
    AppRelease_Status = APP_RELEASE_STATUS
End Function

Public Function AppRelease_Canal() As String
    AppRelease_Canal = APP_RELEASE_CANAL
End Function

Public Function AppRelease_Alvo() As String
    AppRelease_Alvo = APP_RELEASE_ALVO
End Function

Public Function AppRelease_BuildKey() As String
    AppRelease_BuildKey = APP_RELEASE_BUILD_KEY
End Function

Public Function AppRelease_BuildImportado() As String
    AppRelease_BuildImportado = APP_BUILD_IMPORTADO
End Function

Public Function AppRelease_BuildImportadoRotulo() As String
    Dim build As String
    Dim buildNorm As String

    build = APP_BUILD_IMPORTADO
    buildNorm = LCase$(build)

    If build = "" Or build = "PACOTE_NAO_CARIMBADO" Then
        AppRelease_BuildImportadoRotulo = build
    ElseIf Right$(buildNorm, Len("-em-homologacao")) = "-em-homologacao" Then
        AppRelease_BuildImportadoRotulo = Left$(build, Len(build) - Len("-em-homologacao")) & " (em homologação)"
    ElseIf Right$(buildNorm, Len("-homologado")) = "-homologado" Then
        AppRelease_BuildImportadoRotulo = Left$(build, Len(build) - Len("-homologado")) & " (homologado)"
    ElseIf Right$(buildNorm, Len("-di" & "rty")) = "-di" & "rty" Then
        AppRelease_BuildImportadoRotulo = Left$(build, Len(build) - Len("-di" & "rty")) & " (em homologação)"
    Else
        AppRelease_BuildImportadoRotulo = build & " (homologado)"
    End If
End Function

Public Function AppRelease_BuildBranch() As String
    AppRelease_BuildBranch = APP_BUILD_BRANCH
End Function

Public Function AppRelease_BuildGeradoEm() As String
    AppRelease_BuildGeradoEm = APP_BUILD_GERADO_EM
End Function

Public Function AppRelease_Tag() As String
    AppRelease_Tag = APP_RELEASE_TAG
End Function

Public Function AppRelease_EvidenceDir() As String
    AppRelease_EvidenceDir = APP_RELEASE_EVIDENCE_DIR
End Function

Public Function AppRelease_TestKey() As String
    AppRelease_TestKey = APP_RELEASE_TEST_KEY
End Function

Public Function AppRelease_Iteracao() As String
    Dim partes() As String

    partes = Split(Replace$(APP_RELEASE_ATUAL, "V", ""), ".")
    If UBound(partes) >= 2 Then
        AppRelease_Iteracao = partes(2)
    Else
        AppRelease_Iteracao = APP_RELEASE_ATUAL
    End If
End Function

Public Function AppRelease_GitHubRepoUrl() As String
    AppRelease_GitHubRepoUrl = APP_GITHUB_REPO_URL
End Function

Public Function AppRelease_GitHubReleaseNotesUrl() As String
    AppRelease_GitHubReleaseNotesUrl = APP_GITHUB_RELEASE_NOTES_URL
End Function

Public Function GetReleaseAtual() As String
    GetReleaseAtual = AppRelease_Atual()
End Function

Public Function GetReleaseStatus() As String
    GetReleaseStatus = AppRelease_Status()
End Function

Public Function GetReleaseCanal() As String
    GetReleaseCanal = AppRelease_Canal()
End Function

Public Function GetReleaseAlvo() As String
    GetReleaseAlvo = AppRelease_Alvo()
End Function

Public Function GetReleaseBuildKey() As String
    GetReleaseBuildKey = AppRelease_BuildKey()
End Function

Public Function GetBuildImportado() As String
    GetBuildImportado = AppRelease_BuildImportado()
End Function

Public Function GetBuildImportadoRotulo() As String
    GetBuildImportadoRotulo = AppRelease_BuildImportadoRotulo()
End Function

Public Function GetBuildBranch() As String
    GetBuildBranch = AppRelease_BuildBranch()
End Function

Public Function GetBuildGeradoEm() As String
    GetBuildGeradoEm = AppRelease_BuildGeradoEm()
End Function

Public Function GetIteracaoAtual() As String
    GetIteracaoAtual = AppRelease_Iteracao()
End Function

Public Function GetGitHubRepoUrl() As String
    GetGitHubRepoUrl = AppRelease_GitHubRepoUrl()
End Function

Public Function GetGitHubReleaseNotesUrl() As String
    GetGitHubReleaseNotesUrl = AppRelease_GitHubReleaseNotesUrl()
End Function

Public Function GetReleaseTag() As String
    GetReleaseTag = AppRelease_Tag()
End Function

Public Function GetReleaseEvidenceDir() As String
    GetReleaseEvidenceDir = AppRelease_EvidenceDir()
End Function

Public Function GetReleaseTestKey() As String
    GetReleaseTestKey = AppRelease_TestKey()
End Function


