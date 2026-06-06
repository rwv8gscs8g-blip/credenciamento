# Changelog

Este projeto adota o espírito do Keep a Changelog. As mudanças aqui registradas
tratam apenas da linha pública oficial.

## [v12.0.0206] — em validação pós-GATE-A4, sem freeze declarado

### Adicionado

- **Onda 38.2.24 — impressão residual Quant./borda code-only** — corrige as
  duas ressalvas conhecidas do GATE 2: `AplicarFormatoQuantidade` passa a usar
  formato inteiro `"0"`, evitando `Quant.` impresso como `1,`; e
  `IMP_AVALIA!A25:A45` passa a receber borda externa esquerda preta contínua
  com peso `xlMedium`, preservando as bordas internas finas. A suite isolada
  `TV2_RunImpressaoResidual` sobe de 6 para 7 asserts com o novo
  `IR_07_QUANTIDADE_INTEIRA` e `IR_05` exigindo peso médio na borda externa.
  Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY.txt`.
  Gate humano pendente: importar, compilar e executar
  `TV2_RunImpressaoResidual`, esperado `OK=7 | FALHA=0 | MANUAL=0`. Sem tocar
  UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`,
  `Importador_V3.bas`, `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`. Sem
  freeze V206 declarado.

- **Onda 38.2.23-fix1 — impressão residual teste-only** — corrige falso
  negativo de `IR_03_AVALIACAO_DEMANDANTE_L9P15` em
  `Teste_V2_Impressao_Residual.bas`. O gate humano da 0143 importou e compilou
  com sucesso, mas `TV2_RunImpressaoResidual` retornou `OK=5 | FALHA=1` porque
  o teste exigia `L8=esperado`; o CSV mostrou `L9_VISUAL=esperado` e
  `MERGE_L9=Verdadeiro`, portanto o bloqueador visual estava corrigido. O
  fix1 passa a usar `IMP_AVALIA!L9:P15` como criterio de aceite e mantem `L8`
  apenas como detalhe diagnostico. Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY.txt`.
  Gate humano pendente: importar, compilar e executar
  `TV2_RunImpressaoResidual`, esperado `OK=6 | FALHA=0 | MANUAL=0`. Sem tocar
  `Preencher.bas`, UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`,
  `Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas` ou
  `Teste_V2_Roteiros.bas`. Sem freeze V206 declarado.

- **Onda 38.2.23 — impressão residual code-only/template** — corrige por
  `Preencher.bas` quatro resíduos isolados na auditoria 0142: demandante de
  `IMP_AVALIA` agora é gravado também no range visual real `L9:P15`; total
  visual de `EMITE_OS` agora preenche `N63:P63`; bordas críticas de
  `EMITE_PREOS!C9/C11` e `IMP_AVALIA!A25:A45` são reaplicadas por VBA.
  Adiciona o módulo isolado `Teste_V2_Impressao_Residual.bas` com
  `TV2_RunImpressaoResidual`, cobrindo células mescladas, total visual,
  idempotência e bordas reais do workbook. Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE.txt`.
  Gate humano executado por Mauricio: importacao e compile limpos; teste
  dirigido retornou `OK=5 | FALHA=1` por falso negativo de `IR_03`, corrigido
  na 38.2.23-fix1. Sem tocar
  UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`,
  `Importador_V3.bas`, `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`. Sem
  freeze V206 declarado.

- **Onda 38.2.21 — formulários residuais code-only** — adiciona defesa em
  `Svc_Avaliacao.AvaliarOS`: quando o avaliador vem vazio, o serviço resolve o
  demandante por `OS_ID -> CAD_OS.ENT_ID -> ENTIDADE.NOME`; se não conseguir,
  rejeita a avaliação antes de gravar dados incompletos. Adiciona o módulo
  isolado `Teste_V2_Formularios_Residuais.bas` com
  `TV2_RunFormulariosResiduaisCodeOnly`, cobrindo duas OS com demandantes
  distintos, lista de avaliação multi-OS, payload com `Desc_entidade` obsoleto,
  chamada direta a `AvaliarOS` com avaliador vazio, negativo de `ENT_ID`
  inexistente e restauração da base. Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY.txt`.
  Gate humano validado por Mauricio: importacao executada, compile limpo e
  `TV2_20260602_234618` com `OK=6 | FALHA=0 | MANUAL=0`, sem CSV de falhas.
  Sem tocar UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`,
  `Mod_Types.bas`, `Importador_V3.bas`, `Preencher.bas`,
  `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`. Sem freeze V206 declarado.

- **Onda 38.2.20 — UX IniciarSistema code-only** — adiciona o modulo padrao
  `UX_IniciarSistema.bas` para instalar/atualizar um shape visual de planilha
  com `OnAction="IniciarSistema"`, sem depender de `Auto_Open`, `ThisWorkbook`
  ou UserForms. O instalador evita abas criticas de dados e usa uma aba
  operacional visivel; a macro humana para deixar o botao persistido e
  `UX_InstalarAtalhoIniciarSistema`. Adiciona o modulo isolado
  `Teste_V2_UX_IniciarSistema.bas` com `TV2_RunUXIniciarSistemaCodeOnly`,
  cobrindo criacao, `OnAction`, idempotencia, preservacao de celulas sentinela
  e limpeza/restauracao. Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY.txt`.
  Gate humano validado por Mauricio: importacao executada, compile limpo e
  `TV2_20260602_205320` com `OK=5 | FALHA=0 | MANUAL=0`, sem CSV de falhas.
  Para deixar o botao persistido, executar `UX_InstalarAtalhoIniciarSistema`
  apos o teste verde. Sem tocar `Auto_Open.bas`, `ThisWorkbook`, UserForms,
  `.frx`, `Svc_Avaliacao.bas`, `Preencher.bas`, `Mod_Types.bas`,
  `Importador_V3.bas`, `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`. Sem
  freeze V206 declarado.

- **Onda 38.2.18 — recuperação BO_330 diagnóstico** — pacote V3 mínimo para
  o workbook de referência que compila (`fd45a5d+ONDA38.2.6-IMPRESSAO-INTEGRIDADE`),
  sem importar `Teste_V2_Engine.bas`/`Teste_V2_Roteiros.bas` completos e sem
  tocar produção ou UserForms. Adiciona o módulo isolado
  `Teste_V2_BO330_Diagnostico.bas` e a macro `TV2_RunBO330Diagnostico` para
  registrar atividade C, fila, `OS_EMP_ID`, média, strikes, status e
  `DT_FIM_SUSP` da empresa real da OS e da `EMP03` observada pela bateria V1.
  Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO.txt`.
  Gate humano pendente: importar, compilar e executar
  `TV2_RunBO330Diagnostico`; falhas do diagnóstico são evidência para a
  próxima correção, não regressão deste pacote. Sem freeze V206 declarado.

- **Onda 38.2.2 — V206 puro freeze (esta onda, última antes do freeze V206)** —
  5 alvos atômicos pré-aprovados na 2ª rodada auditoria cruzada V207
  (`auditoria/00_status/112_*.md`):
  - **AT-1** (item 68 Codex, sev. ALTO): nova `Util_Planilha.Util_MaxIdOperacional(nomeAba)`
    pair-aware EMPRESAS+EMPRESAS_INATIVAS / ENTIDADE+ENTIDADE_INATIVOS;
    `ProximoId` redirecionado. Resolve risco de cadastro novo receber ID já
    usado por entrada INATIVA.
  - **AT-2** (item 69 Codex, sev. MÉDIO): `On Error GoTo` movido para ANTES
    de `Util_IniciarBlocoRapido()` em `SanearContadoresAR1` + 4 funções
    `Repo_Empresa` (Inserir/Atualizar/GravarStatusEmpresa/Backfill). Garante
    restauração de `TEstadoExcel` mesmo em erro precoce.
  - **AT-3** (F-NEW3 sistemático): `NumberFormat = "@"` na coluna A antes da
    gravação do ID em 5 cadastros — `Menu_Principal.C_Cadastrar_Click`
    (entidade), `Menu_Principal.M_Cadastrar_Empresa_Click` (empresa-alt),
    `Credencia_Empresa.CR_Credenciar_Click` (loop credenciamento, dentro do
    For), `Cadastro_Servico.S_Cadastrar_SV_Click` (atividade + serviço).
    Resolve cosmético `5` vs `005`.
  - **AT-4** (filtros nativos): 7 handlers estáticos `TextBox16..22_Change` no
    `Menu_Principal.frm` substituem a descoberta heurística via
    `UI_TextBoxSeExisteRecursivo + UI_PegarTextBoxBuscaDaLista`. Despacho
    centralizado via nova `Public Sub Preencher_FiltrarPorBoxEstatico(nomeContexto, termo)`
    em `Preencher.bas`. Cada handler estático evita double-call via guard
    `If mTxtFiltro... Is TextBoxN`. Handlers dinâmicos `mTxtFiltro*_Change`
    mantidos como **fallback** (débito V207: rename canônico no designer +
    `Optional filtro` em `PreencherPreencheOS`/`PreencherAvaliarOS`).
    Reverte definitivamente a regressão da Onda 38.2.1
    (`e9bcf42 revert filtros menu principal`).
  - **AT-5** (envelopamento `Util_Excel_Performance` em 3 `.frm`):
    `Util_IniciarBlocoRapido`/`Util_FinalizarBlocoRapido` aplicado aos 4 subs
    de cadastro UI restantes (Menu_Principal entidade + empresa-alt;
    Credencia_Empresa CR_Credenciar_Click envolvendo loop For; Cadastro_Servico
    S_Cadastrar_SV_Click envolvendo atividade + serviço). Padrão emergente:
    flag `blocoRapidoIniciado As Boolean` defensiva no handler de erro
    (evita restaurar `TEstadoExcel` zerada se erro ocorreu antes de Iniciar).
    Speedup esperado: 3-8× em PC antigo para cadastros UI.
  - Manifesto V3: `000-MANIFESTO-V3-DELTA-ONDA38-2-2-V206-FREEZE.txt` (8 módulos M).
  - Build label esperado pós-import: `<HEAD>+ONDA38.2.2-V206-FREEZE`.
  - Anchor de rollback: commit `179bac5`. Anchor V206 funcional: `ee75b30`.
  - 10 gates humanos pós-commit (IMPORT → COMPILE → AT-1..AT-5 → RVS →
    VAL-TELA-A-TELA conforme cronograma `38_2_TECNICO.md:79` → FREEZE).
  - Documentado em [`auditoria/03_ondas/onda_38_2_2_v206_freeze/38_2_2_TECNICO.md`](auditoria/03_ondas/onda_38_2_2_v206_freeze/38_2_2_TECNICO.md).

- **Onda 37** — reconciliação V5 vs `src/vba/` com manifesto SHA-256 e matriz
  de classificação em
  `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/`, sem tocar código
  VBA nem pacote `local-ai/vba_import/`.
- **Onda 37.1** — subclassificação dos 28 `diferenca_funcional`, lição L26
  das tentativas MD33 frustradas, knowledge HBN 0014 e ADRs para
  `Importador_V2.bas` e `Emergencia_CNAE.bas`, sem tocar VBA.

### Corrigido

- **Onda 38.2.19-fix1 — formulario avaliacao IdsIguais no teste isolado** —
  corrige somente `Teste_V2_Form_Avaliacao_Modulos.bas` para usar
  `IdsIguais` ao localizar `OS_ID` na `AV_Lista` e em `CAD_OS`. A falha
  `TV2_20260602_125043` da 0138 mostrou que `FAM_02` e `FAM_04` passaram,
  mas `FAM_03`/`FAM_05` falharam por comparacao textual estrita no helper do
  teste. Inclui manifesto V3 test-only
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS.txt`.
  Gate humano pendente: Importador V3 esperado `M=2 | F=0 | err=0 | skip=0`,
  compile limpo e `TV2_RunFormAvaliacaoModulos` esperado
  `OK=5 | FALHA=0 | MANUAL=0`. Validada por Mauricio com importacao,
  compile limpo e `TV2_20260602_181749` retornando
  `OK=5 | FALHA=0 | MANUAL=0`, sem CSV de falhas. Mauricio executou tambem o
  Gate RVS completo `VR_20260602_182253`, resultado `APROVADO`, com
  `V1_RAPIDA OK=171/FALHA=0`, `V2_SMOKE OK=34/FALHA=0/MANUAL=4`,
  `V2_CANONICO OK=24/FALHA=0`, `E2E_STRIKES OK=76/FALHA=0`,
  `INTEGRIDADE_BASE OK=4/FALHA=0/MANUAL=1` e
  `ONDA23_ADV OK=27/FALHA=0`. Sem tocar `Svc_Avaliacao.bas`,
  `Preencher.bas`, UserForms, `.frx`, `Auto_Open.bas`, `Mod_Types.bas`,
  `Importador_V3.bas`, `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`. Sem
  freeze V206 declarado.

- **Onda 38.2.19 — formulario avaliacao por modulos primeiro** — retoma a
  melhoria dos formularios apos o crash de compile da 38.2.17, mas em pacote
  conservador sem `Menu_Principal.frm`, sem UserForms, sem `.frx` e sem
  `Teste_V2_Engine.bas`/`Teste_V2_Roteiros.bas` completos. `Svc_Avaliacao.bas`
  resolve o demandante por `OS_ID -> CAD_OS.ENT_ID -> ENTIDADE.NOME`;
  `PreencherAvaliarOS` popula `AV_Lista` coluna 1 no formulario existente; e
  `MontarPayloadAvaliacao` faz fallback para esse demandante quando o avaliador
  vem vazio, preservando avaliador explicito. Adiciona o modulo isolado
  `Teste_V2_Form_Avaliacao_Modulos.bas` com a macro
  `TV2_RunFormAvaliacaoModulos` e 5 asserts dirigidos. Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO.txt`.
  Gate humano: Importador V3 `M=4 | F=0 | err=0 | skip=0` e compile limpo,
  mas `TV2_20260602_125043` retornou `OK=3 | FALHA=2 | MANUAL=0`. O CSV
  indicou falha no teste isolado por comparacao estrita de `OS_ID`; o resolver
  de demandante e o fallback do payload passaram. Fix1 0139 recomendado como
  test-only com `IdsIguais`, sem tocar producao nem UserForms. Sem freeze V206
  declarado.

- **Onda 38.2.18-fix1 — BO_330 status canônico no diagnóstico** — corrige
  apenas a expectativa do módulo `Teste_V2_BO330_Diagnostico.bas` para o
  literal canônico `SUSPENSA_GLOBAL`. O CSV `TV2_20260602_105519` mostrou que
  a produção suspendeu a `EMP03` e gravou `DT_FIM_SUSP=2026-07-02`; a falha
  estava no diagnóstico 0136, que esperava `SUSPENSA`. Inclui manifesto V3
  mínimo
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_FIX1_BO330_STATUS_CANONICO.txt`.
  Validada por Mauricio com Importador V3 `M=2 | F=0 | err=0 | skip=0`,
  compile limpo, `TV2_20260602_111854` com
  `OK=24 | FALHA=0 | MANUAL=0` e Trio mínimo `VR_20260602_112011` APROVADO
  (`V1_RAPIDA OK=171/FALHA=0`, `V2_SMOKE OK=34/FALHA=0/MANUAL=4`,
  `V2_CANONICO OK=24/FALHA=0`). Sem tocar produção, UserForms,
  `Auto_Open.bas`, `Mod_Types.bas` ou `Importador_V3.bas`. Sem freeze V206
  declarado.

- **Onda 38.2.17 — formulários de avaliação/demandante** — primeira fatia de
  melhoria dos formulários V206. Adiciona
  `ResolverDemandanteAvaliacaoPorOS` em `Svc_Avaliacao.bas` para resolver o
  demandante por `OS_ID -> CAD_OS.ENT_ID -> ENTIDADE.NOME`. `PreencherAvaliarOS`
  passa a preencher `AV_Lista` por esse helper; `Menu_Principal.EncerraOS_Click`
  deixa de depender de `AVListaCol(1)`/`Desc_entidade` obsoletos, bloqueia
  avaliação quando o demandante não resolve, inclui o demandante na confirmação,
  alimenta payload e impressão com o nome resolvido e preserva o registro
  auditável via `AvaliarOS`. Adiciona a suíte dirigida
  `TV2_RunFormulariosAvaliacaoDemandante` com 7 asserts cobrindo OS em execução,
  resolução por OS, lista, payload, impressão, auditoria
  `AVALIADOR=Local 1` e falha auditável para `ENT_ID` inexistente. Inclui
  manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_17_FORMULARIOS_AVALIACAO_DEMANDANTE.txt`.
  Gate humano falhou: o delta importou, mas o compile travou e fechou o Excel
  antes da execução V2. O workbook foi recuperado para uma âncora compilável e
  a frente de formulários ficou suspensa até a recuperação/diagnóstico BO_330.
  Sem freeze V206 declarado.

- **Onda 38.2.16 — BL-4 proteção persistente após save/reopen** — com
  decisão explícita de Mauricio, aplica exceção estreita em `Auto_Open.bas`
  para registrar e verificar a reaplicação da proteção crítica na abertura do
  workbook. `Util_Planilha.bas` passa a validar não só `ProtectContents`,
  objetos protegidos e células bloqueadas, mas também escrita VBA de mesmo
  valor em célula bloqueada protegida, evidenciando que `UserInterfaceOnly` foi
  reaplicado após reabrir o arquivo. Adiciona a suíte dirigida
  `TV2_RunBL4ProtecaoPersistente` com 5 asserts e manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_BL4_PROTECAO_PERSISTENTE.txt`.
  Gate humano inicial: Importador V3 `M=5 | F=0 | err=0 | skip=0` e compile
  limpo, mas `TV2_20260601_105519` retornou `OK=4 | FALHA=1 | MANUAL=0` em
  `BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO` (`EXECUTADA_EM=nao registrada`).
  Rerun `TV2_20260601_110148` repetiu a mesma falha unica com
  `OK=4 | FALHA=1 | MANUAL=0`. Micro-onda 38.2.16-fix1/readback 0133
  implementa marcador persistente/auditavel de `Auto_Open` via nomes ocultos do
  workbook, ajusta `BL4_01` para ler esse marcador em vez de depender apenas de
  variavel VBA em memoria e publica o manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER.txt`.
  Gate humano fix1: Importador V3 `M=4 | F=0 | err=0 | skip=0` e compile
  limpo, mas `TV2_20260601_115504` retornou `OK=4 | FALHA=1 | MANUAL=0` em
  `BL4_01`, com `MARCADOR_TS=nao registrado`. Proxima etapa: diagnosticar
  `Application.EnableEvents` e disparo real de `Workbook_Open` antes de nova
  implementacao. Diagnostico confirmou `Application.EnableEvents=True` e
  `IniciarSistema` criando marcador persistente com `OK=True`; reexecucao
  `TV2_20260601_120900` retornou `OK=5 | FALHA=0 | MANUAL=0`. Sem freeze V206
  declarado.

- **Onda 38.2.15 — FT-4 credenciamento em lote** — refatora o fluxo real de
  `Credencia_Empresa.frm` para alocar `CRED_ID`/AR1 em lote, calculando a base
  por `max(AR1, Util_MaxIdOperacional(CREDENCIADOS))`, incrementando IDs em
  memoria e atualizando AR1 uma unica vez ao final. Mantem a regra existente:
  uma atividade selecionada credencia a empresa em todos os servicos da
  atividade e duplicidades continuam ignoradas. Adiciona a suite dirigida
  `TV2_RunFT4CredenciamentoLote`, cobrindo base populada, sequencia continua
  de `CRED_ID`, AR1 final, idempotencia de reexecucao e tempo <= 10 segundos.
  Inclui manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_15_FT4_CREDENCIAMENTO_LOTE.txt`.
  Validada por Mauricio com Importador V3 `M=3 | F=1 | err=0 | skip=0`,
  compile limpo e `TV2_20260601_102735` com
  `OK=6 | FALHA=0 | MANUAL=0`. Sem freeze V206 declarado.

- **Onda 38.2.14 — behavioralizacao C1, primeira fatia** — adiciona a suite
  dirigida `TV2_RunBehavioralizacaoC1`, com verificacoes comportamentais para
  reduzir dependencia dos asserts estaticos `TV2_EST_*`: round-trip real de
  `CONFIG!A:N`, ordenacao de entidade com base populada, alocacao sequencial
  de `CRED_ID`/AR1 com contador atrasado, unicidade/canonicalidade dos
  `CRED_ID` e integridade de fila canonica. Inclui manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_14_BEHAVIORALIZACAO_C1.txt`.
  Validada por Mauricio com Importador V3 `M=3 | F=0 | err=0 | skip=0`,
  compile limpo e `TV2_20260601_093826` com
  `OK=5 | FALHA=0 | MANUAL=0`. FT-4/credenciamento em lote permanece fora
  desta onda. Sem freeze V206 declarado.

- **Onda 38.2.12 — Performance/UX basica (FT-3 parcial, FT-2 parcial e MG-1)** —
  remove do `ProgressBar` o `ThisWorkbook.Save` embutido e o busy-wait
  `timedelay`, mantendo apenas feedback visual leve; extrai a limpeza dos
  campos de cadastro de entidade para `LimparCamposCadastroEntidade`; e passa
  `AbrirURLExterna` a tentar `Shell open` primeiro no Mac antes dos fallbacks
  `FollowHyperlink`. Inclui a suite dirigida `TV2_RunPerformanceUXBasica`
  (validada por Mauricio com `OK=5 | FALHA=0 | MANUAL=0`) e manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_12_PERFORMANCE_UX_BASICA.txt`.
  FT-4/credenciamento em lote permanece fora desta onda por risco de sequencia
  de IDs. Sem freeze V206 declarado.

- **Onda 38.2.10 — higiene estrutural do repositório e commit de consolidação** —
  adiciona `.gitattributes`, `.editorconfig` e scripts read-only de higiene
  para impedir falsos positivos de `git diff --check` em exportáveis VBA
  (`.bas`, `.frm`, `.cls` e `code-only.txt`) sem normalização física em massa.
  `.frx` passa a ser tratado como binário. Artefatos grandes soltos na raiz
  foram movidos para `local-ai/incoming/artefatos-avulsos/20260531/`, e o CSV
  de falha V2 solto foi movido para `auditoria/evidencias/V12.0.0205/csv/`.
  Inclui documentação em `docs/reference/governanca/HIGIENE_REPOSITORIO_V206.md`.
  Sem freeze V206 declarado.

- **Onda 38.2.9 — snapshot de CONFIG nas suites V2 (FT-11 expandido)** —
  `TV2_InitExecucao` passa a capturar `CONFIG!A:N` antes de cada suite V2 e
  `TV2_FinalizarExecucao` restaura a mesma faixa no encerramento normal e no
  handler fatal. Isso permite que os testes usem baseline canonica sem deixar
  valores de teste em gestor, municipio, logo, prazo de Pre-OS, recusas,
  meses/dias de suspensao, nota minima, strikes ou threshold de teste lento.
  Inclui a suite dirigida nao destrutiva `TV2_RunConfigSnapshotV2` (`OK=4`
  esperado) e manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_9_CONFIG_SNAPSHOT_V2.txt`.
  Sem freeze V206 declarado.

- **Onda 38.2.8 — baseline V2 preserva CONFIG operacional (FT-11)** —
  `TV2_SetConfigCanonica` deixa de sobrescrever diretamente `COL_CFG_GESTOR`
  e `COL_CFG_MUNICIPIO` com `Gestor Testes V2` / `Municipio de Testes V2`.
  Quando esses campos ja possuem valor salvo pelo operador, o baseline V2
  preserva o texto operacional; os valores de teste passam a ser fallback
  apenas para CONFIG vazia. Inclui a suite dirigida nao destrutiva
  `TV2_RunConfigBaselineSeguro` (`OK=3` esperado) e manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_8_CONFIG_BASELINE_V2.txt`.
  Sem freeze V206 declarado.

- **Onda 38.2.7 — leitura e exibicao (FT-1, FT-5, FT-6 e FT-8 do
  parecer 0024)** — amplia a selecao simples de entidade no `Menu_Principal`
  para preencher todos os campos visiveis com a mesma paridade do duplo clique,
  exibe o ID antes do CNPJ nas listas de entidades/empresas, preserva no
  rodizio os dados de entidade usados pela emissao de OS, e passa o filtro
  `TextBox19` para a lista de Pre-OS pendentes em `PreencherPreencheOS`.
  Inclui a suite dirigida `TV2_RunLeituraExibicao` (`OK=5` esperado) e manifesto
  V3 `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_7_LEITURA_EXIBICAO.txt`.
  A auditoria dos PDFs anexos identificou bordas/formato irregulares nos
  templates de impressao, e a auditoria de municipio identificou risco de
  reset por baseline V2 (`Municipio de Testes V2`); ambos ficam registrados
  para onda propria, sem freeze V206 declarado.

- **Onda 38.2.6 — integridade de impressão (BL-5, BL-6, BL-7 e FT-7 do
  parecer 0024)** — adiciona normalização de ID de Pré-OS para o texto
  exibido como `PROVISORIA - <id>`, carrega `END_ENTIDADE` da aba
  `ENTIDADE` antes de `PreencherOS`, passa o empenho de OS por
  `N_Empenho.Value`, e limita notas impressas da avaliação em `0..10`
  antes de gravar `IMP_AVALIA!N27:N36`. Inclui a suite dirigida
  `TV2_RunImpressaoIntegridade` (`OK=6` esperado) e manifesto V3
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_6_IMPRESSAO_INTEGRIDADE.txt`.
  Sem freeze V206 declarado.

- **Onda 38.2.5 — pacote UI de regras de negócio (BL-1 do parecer 0024)** —
  restaura no pacote importável de `Configuracao_Inicial` os controles
  `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`, `PR_Val_OS`,
  `TP_Valor` e `TxtMesesSuspensao`, promove o `.frx` exportado pelo operador, remove
  mascaramento da ausência de controles no code-behind, persiste
  `COL_CFG_PRAZO_PREOS`, `COL_CFG_MAX_RECUSAS` e
  `COL_CFG_MESES_SUSPENSAO` pela UI sem alterar `Svc_Rodizio`, e adiciona
  a suite dirigida `TV2_RunPersistenciaPainel`. Gate humano aprovado:
  Importador V3 `M=2 | F=1 | err=0 | skip=0`, compile limpo e
  `TV2_RunPersistenciaPainel` `OK=2 | FALHA=0 | MANUAL=0`.
  Manifesto V3:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_5_UI_REGRAS_NEGOCIO.txt`.
  Sem freeze V206 declarado.

- **Onda 38.2.1-AR1-FIX2-PERF gate humano APROVADO com findings** —
  Import V3 `M=5 | F=0 | err=0 | skip=0`; compile limpo;
  `SanearContadoresAR1` `ok=7 falhas=0` com guarda monotônica validada
  na real (`CREDENCIADOS!AR1 8 -> 8 (sources: CREDENCIADOS=4)` — sem a
  guarda, AR1 cairia para 4 e reusaria IDs deletados; **F5 do ERP 0106
  RESOLVIDO definitivamente**); cadastros sequenciais (empresa 6 → ID
  004, empresa 7 → ID 005); performance ~2× mais rápida (esperado
  10–30×, parcial); RVS Trio APROVADO `VR_20260526_102200`
  (`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`). Findings novos:
  **F-NEW3** (cosmético — ID `5` em ENTIDADE em vez de `005`, causa em
  `Menu_Principal.frm:1622` ListObject sem `NumberFormat="@"`),
  **F-NEW4** (continuação F4 — performance parcial, gargalo residual em
  `.frm` e reload de ListBox), **F-NEW4-DT** (débito técnico V207 —
  testes E2E de cadastros não existem). Próxima onda 38.2.2 cobre
  filtros nativos + envelopamento `.frm` + fix F-NEW3, com deep-dive
  PHAGOCYTOSIS como pré-trabalho obrigatório.
- **Onda 38.2.1-AR1-FIX2-PERF (em execução)** — combina **Parte A**
  (ID monotônico) e **Parte B.lite** (Excel performance wrapper para
  `Repo_Empresa`). Parte A: `Util_Sanear_Contadores.SanearAR1EmAbaPareada`
  ganha guarda `If maxId < valorAnterior Then maxId = valorAnterior`
  (resolve regressão F5 — CRED_IDs 005/006 viram gaps permanentes);
  `Util_Planilha.ProximoId` ganha defesa em profundidade chamando nova
  `Public Util_MaxIdNaColunaA` (cobre AR1 dessincronizado por edição
  manual). Parte B.lite: novo módulo `Util_Excel_Performance.bas` com
  `Util_IniciarBlocoRapido()`/`Util_FinalizarBlocoRapido()` (usa
  `Variant array` por Glasswing G8) aplicado a 4 funções de
  `Repo_Empresa` + `SanearContadoresAR1`. Cadastro/edição de empresa
  esperado 10–30× mais rápido em PCs antigos. Cadastros em `.frm`
  (entidade, credenciamento, atividade) ficam para Onda 38.2.2 com
  deep-dive PHAGOCYTOSIS antes. Readback 0108, manifesto delta
  `ONDA38-2-1-AR1-FIX2-PERF`, build label
  `ad5b487+ONDA38.2.1-AR1-FIX2-PERF`.
- **Onda 38.2.1-AR1 gate humano APROVADO** — `SanearContadoresAR1`
  executou com `ok=7 falhas=0`; cadastro de empresa nova retornou ID
  004 (vs 001 anterior, F1 resolvido); cadastro de entidade nova
  aparece no fim da lista (F2 resolvido); Sexteto completo APROVADO
  em `VR_20260526_035523` (V1=171/0 + V2_Smoke=34/0 + V2_Canonica=24/0
  + E2E_Strikes=76/0 + IntegridadeBase=4/0 + Onda23Adv=27/0). Finding
  minor F5 registrado para decisão: `CREDENCIADOS!AR1` decresceu de
  6 para 4 (IDs 005 e 006 deletados historicamente; algoritmo
  `max(ID)` ressincronizou; próximo cadastro reusará ID 005). Aguarda
  decisão sobre mitigar agora (microdelta), deferir V207, ou
  descartar.
- **Onda 38.2.1-AR1 hotfix BUMP** — reverte `src/vba/App_Release.bas` ao
  estado do commit `e9bcf42` (Onda 38.2.1) após primeiro
  `ImportarPacoteV3_Delta` abortar com `[V3 FALHA] BUMP_NO_CHANGE`. Causa:
  pré-setar `APP_BUILD_IMPORTADO` no `.bas` igual ao target combinado com
  `APP_BUILD_GERADO_EM` coincidindo com o minuto do import faz a
  substituição textual do `IV3_AtualizarConstantesAppRelease` ser no-op
  duplo, e o Importador V3 trata como falha. Knowledge HBN 0016
  documenta a regra: deixar o `App_Release.bas` no estado da onda
  anterior para que o Importador V3 faça o BUMP corretamente durante a
  fase `5b_BUMP_BUILD_LABEL`.
- **Onda 38.2.1-AR1** — saneamento idempotente dos contadores `AR1`
  das 7 abas que usam `Util_Planilha.ProximoId` (EMPRESAS, ENTIDADE,
  ATIVIDADES, CAD_SERV, PRE_OS, CAD_OS, CREDENCIADOS), corrigindo a
  regressão de cadastro de empresa retornando ID 001 observada no gate
  humano da Onda 38.2.1. Causa raiz: workbook restaurado de backup
  pré-38.2 veio com `<aba>!AR1` dessincronizado do `max(ID)` real.
  Cria módulo `Util_Sanear_Contadores.bas` com `Public Sub
  SanearContadoresAR1()` chamada manualmente uma vez no Imediato após
  o import. Para EMPRESAS e ENTIDADE, considera também as abas
  pareadas `EMPRESAS_INATIVAS` e `ENTIDADE_INATIVOS` no cálculo de
  `max(ID)`, blindando contra o caso em que a empresa/entidade de
  maior ID foi inabilitada. Não altera `Util_Planilha.ProximoId` nem
  qualquer dado de cadastro. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-AR1-SANEAR-CONTADORES.txt`.
  Carimbo: `e9bcf42+ONDA38.2.1-AR1-sanear-contadores`.
- **Onda 38.2.1** — revert forward-only dos filtros do `Menu_Principal.frm`
  após reprovação da Onda 38.2 no gate humano (erro VBA 424 ao digitar nos
  campos, filtros inconsistentes, suspeita de corrupção de estado com
  cadastro de empresa retornando ID 001). Restaura `Menu_Principal.frm` e
  `Preencher.bas` byte-a-byte do anchor `a6ad842` (Onda 38.1.5 estável);
  `App_Release.bas` carimbado com novo build label. ERP 0104 fechado como
  `human_gate_failed`. Bastão transferido provisoriamente Codex → Claude
  Opus 4.7 para esta fase de estabilização da V12.0.0206. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-REVERT-FILTROS-MENU.txt`.
  Carimbo: `7bca168+ONDA38.2.1-revert-filtros-menu`.
- **Onda 38.2** — REPROVADA NO GATE HUMANO em 2026-05-25. Tentou corrigir
  filtros do `Menu_Principal.frm` com ponteiros `WithEvents` dinâmicos para
  `TextBox16` a `TextBox22`. Falhou por double-handler competindo com os
  `TextBoxNN_Change` nativos do `.frm`, gerando erro VBA 424 e mutação dupla
  de variáveis globais (`cont`, `NItem`, `nLinhas`, `i`). Diagnóstico
  convergente: Antigravity/Gemini + Opus + Codex aprovaram reverter. Manifesto
  delta da tentativa (revertido pela Onda 38.2.1):
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-FILTROS-MENU.txt`.
  Carimbo: `a6ad842+ONDA38.2-filtros-menu`.
- **Onda 38.1.5** — reaplica exclusivamente `Rel_Emp_Serv.frm` corrigido em
  workbook restaurado de base anterior à 38.1, recuperando o preparo/restauro
  de proteção da aba `RELATORIO` para o relatório de Empresas Credenciadas por
  Serviço sem tocar `Rel_OSEmpresa.frm`. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-5-REL-EMP-SERV-PROTECAO.txt`.
  Carimbo: `696a8c2+ONDA38.1.5-rel-emp-serv-protecao`.
- **Onda 38.1.4** — restaura `Rel_OSEmpresa.frm` ao conteúdo compilável da
  Onda 38.1.2 após a tentativa 38.1.3 derrubar o compile VBE. Também registra
  a lição HBN L11: manifesto delta aponta para arquivo vivo em
  `local-ai/vba_import/`, não para snapshot histórico. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-4-RESTAURA-REL-OS-EMPRESA.txt`.
  Carimbo: `8d5e2e6+ONDA38.1.4-restaura-rel-os-empresa`.
- **Onda 38.1.3** — padroniza a apresentação da coluna `NOTA TOTAL` em
  `Rel_OSEmpresa` para duas casas decimais, preservando o cálculo e o
  cabeçalho aprovados. **Reprovada no gate humano: importou, mas o Excel
  fechou durante o compile VBE; substituída pela Onda 38.1.4.** Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-3-NOTA-TOTAL-DECIMAL.txt`.
  Carimbo: `35775b3+ONDA38.1.3-nota-total-decimal`.
- **Onda 38.1.2** — corrige o botão real de `Rel_OSEmpresa`: o
  `CommandButton` do form chama-se `B_RelMEIOS`, enquanto o código anterior
  tinha apenas `B_RelEmpresaOS_Click`. O novo handler `B_RelMEIOS_Click`
  chama a mesma rotina central de impressão, mantendo o handler antigo como
  compatibilidade, sem tocar `.frx`. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-2-REL-OS-EMPRESA-BOTAO.txt`.
  Carimbo: `10ef253+ONDA38.1.2-rel-os-empresa-botao`.
- **Onda 38.1.1** — hotfix mínimo dos relatórios afetados pela Onda 38.1:
  remove `PrintPreview` dos caminhos que travavam a interface, transforma
  **Não** em cancelamento limpo, preenche `Dt_inicial` em OS por Empresa com o
  primeiro dia do mês de sete meses atrás, normaliza datas `dd/mm/aaaa`,
  `ddmmaaaa` e `ddmmaa`, e troca a busca contígua em `CAD_OS` por varredura
  completa por empresa/período. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-1-RELATORIOS-HOTFIX.txt`.
  Carimbo: `6103cab+ONDA38.1.1-relatorios-hotfix`.
- **Onda 38.1** — destrava os relatórios `Rel_OSEmpresa` e
  `Rel_Emp_Serv` após gate humano da Onda 38: os forms agora preparam e
  restauram a proteção da aba `RELATORIO`, limpam resíduos/área impressa,
  aplicam formatação mínima padrão e o botão **Imprimir Relatório** de OS por
  Empresa passa a gerar o relatório com a empresa selecionada e a data atual
  digitada no form. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-RELATORIOS-PROTECAO.txt`.
  Carimbo: `cf778b2+ONDA38.1-relatorios-protecao`.
- **Onda 38** — MD33 restart correto para `Rel_OSEmpresa` e
  `Rel_Emp_Serv`: os handlers em `Menu_Principal.frm` agora criam a
  instância via `VBA.UserForms.Add` antes do preenchimento, `Preencher.bas`
  deixa de criar fallback invisível para `Rel_OSEmpresa`, e o preaquecimento
  do relatório no `UserForm_Initialize` do menu foi removido. Manifesto delta:
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-MD33-RESTART.txt`.
  Carimbo: `e43352f+ONDA38.MD33-restart-relatorios`.
- **Onda 37.2** — reversão controlada dos três `drift_md33_descartar`
  (`Importador_V3.bas`, `Menu_Principal.frm`, `Preencher.bas`) para estado
  equivalente à V5, com espelhos correspondentes em `local-ai/vba_import/`.
- **Onda 37.3** (Opus, bastão recebido de Codex) — reset completo de
  `src/vba/` ao estado equivalente exato do export V5 (64 arquivos),
  após ImportarPacoteV3 + compile VBE falharem com os 28 `drift_legitimo_anterior_v5`
  remanescentes na 37.2. Backup defensivo preservado em
  `auditoria/03_ondas/onda_37_3_reset_src_vba_v5/backup_pre_reset/`.
  Remoção física de `Importador_V2.bas` e `Emergencia_CNAE.bas` aplicada
  conforme ADRs da Onda 37.1. **Gate humano (compile VBE + smoke)
  fechado em 2026-05-25 com `CT_ValidarRelease_TrioMinimo` APROVADO
  `VR_20260524_235715` (V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0).**
- **Onda 37.4** (Opus) — microdelta NOOP `ONDA37-4-TESTE-NOOP` que
  validou o fluxo `ImportarPacoteV3_Delta(nomeDelta, buildLabel)` no
  workbook V5 reconstituído. Resultado: `M=1 | F=0 | err=0 | skip=0`,
  compile limpo, trio APROVADO. Manifesto em
  `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA37-4-TESTE-NOOP.txt`.
  Carimbo: `APP_BUILD_IMPORTADO = e43352f+ONDA37.4-teste-delta-noop`.

### Conhecimento

- **Knowledge `0014-protocolo-fim-de-sessao.md`** (Onda 36.1) — Regra
  permanente: toda IA que opere em sessão longa produz handoff de
  fim-de-sessão em `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-<agente>.md`
  ao detectar gatilho (operador pede stop, >30 turnos, contexto >50%,
  transferência de bastão, ou ERP fechado). Auto-aplicação imediata: primeiro
  handoff real foi o desta própria sessão Opus que criou a regra
  (`.hbn/messages/20260525-0100-handoff-fim-sessao-opus.md`). Primeira
  iteração manual do `PROMPT_ARQUITETO_USEHBN_AUTONOMO`.
- **Knowledge `0018-uso-delta-vs-completo.md`** (L33) — Regra permanente:
  `ImportarPacoteV3_Delta` é o caminho default; `ImportarPacoteV3()`
  completo gera fantasma de cache no VBE e fica restrito a Fresh workbook
  ou emergência. **Débito técnico V207**: investigar e marcar uso restrito
  formalmente.
- **Superprompt `107_SUPERPROMPT_CODEX_RETOMADA_ONDA_38_PDF.md`** — handoff
  do bastão Opus → Codex para retomada da V206 a partir da Onda 38
  (correção `Rel_OSEmpresa` / `Rel_Emp_Serv`) via microdeltas, sem
  `ImportarPacoteV3()` completo.

### Governança

- `Emergencia_CNAE.bas` ficou classificado como `precisa_decisao_humana` antes
  de qualquer remoção, reincorporação ou importação futura.
- `Importador_V2.bas` ficou classificado como `obsoleto_no_repo`, sem remoção
  nesta onda.
- A cadeia MD33 descartável ficou identificada como origem de drift em
  `Importador_V3.bas`, `Menu_Principal.frm` e `Preencher.bas`; a execução de
  reversão foi executada em readback safe_track próprio e entregue para gate
  humano de importação/compile no VBE.

### Validação

- **Onda 37.2** permanece `delivered_for_human_gate`: o ERP só fecha depois de
  Mauricio importar exclusivamente de `local-ai/vba_import/` e confirmar
  `Debug > Compile VBAProject` no VBE.

## [v12.0.0205] — 2026-05-21

> Release oficial V205. Build validado:
> `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`. Gate RVS aprovado em
> `VR_20260523_215637` com assinatura funcional idêntica à V204:
> `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.

### Adicionado

- **Onda 26 / MD26.1** — saneamento do script
  `.github/scripts/verify_release_consistency.sh` para aceitar a estrutura real
  de evidências V204/V205, `INDEX.md`/`MANIFEST.md` e os novos prefixos RVS.
- **Onda 26 / MD26.1** — arquivamento da auditoria de escopo V205 e auditorias
  cruzadas SP1/SP2/SP3 em `auditoria/00_status/`.
- **Onda 26 / MD26.1** — roadmap de produção
  `auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md`.
- **Onda 26 / MD26.1** — documentação pública V205:
  crosswalk RVS/SRC/BRL, especificação de PDF para V206, regras de negócio
  consolidadas RN-01 a RN-17, matriz de cobertura, jornada humana, dossiê de
  release e how-to do Gate RVS.
- **Onda 27 / MD27.1** — Central de Testes com nomenclatura profissional:
  **Gate de Validação de Release (RVS)**, **Suíte de Regressão Consolidada
  (SRC)** e **Bateria Rápida Legada (BRL)**.
- **Onda 28 / MD28.2** — evidência final V205 em
  `auditoria/evidencias/V12.0.0205/`, com CSV aprovado e manifesto de hash.
- **Onda 29 / MD29.1** — promoção da vitrine pública para V12.0.0205 como linha
  VALIDADO/OFICIAL e preparação da auditoria final positiva entre IAs.
- **Onda 29 / MD29.3** — freeze final pós-MICRO61, com compile VBE confirmado
  pelo operador e novo Gate RVS em `VR_20260523_215637`.

### Corrigido

- Prefixos de CSV de release passam a usar `ValidacaoReleaseRVS_V12_0_0205_`
  na V205, eliminando ambiguidade visual com a série V12.0.0203/V12.0.0204.
- `App_Release.bas` passa a apontar a linha oficial para V12.0.0205 e a próxima
  linha planejada para V12.0.0206.
- `README.md`, `AGENTS.md`, `llms.txt`, índices `docs/` e status oficial passam
  a direcionar leitores humanos e IAs para os artefatos V205.

### Validação

- Import V3 final MICRO61 aprovado pelo operador:
  `M=1 | F=0 | err=0 | skip=0`.
- Compilação VBE final pós-MICRO61 aprovada pelo operador em 23/05/2026.
- `TV2_RunAdversarial_UI` aprovado em `TV2_20260521_182645`:
  `OK=12 | FALHA=0 | MANUAL=0`.
- Gate RVS final aprovado em `VR_20260523_215637`:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- CSV final:
  `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv`.
- SHA-256 do CSV final:
  `7146912436ab0ef3080e90d7183c614699226a65047330a2730718f2cfffbc60`.

### Próximas Linhas

- **V12.0.0206** — estabilização incremental pós-produção: ajustes de testes
  manuais, PDF automático, pequenos débitos técnicos e melhorias prorrogadas.
- **V12.0.0207** — code review profundo, performance, componentização e
  preparação arquitetural para evolução SaaS, salvo decisão posterior de
  roadmap.

## [v12.0.0204] — 2026-05-11

> Release oficial V204. Build final validado:
> `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`. Gate final aprovado em
> `VR_20260511_154433`, com Smoke `TV2_20260511_131824` retornando
> `OK=34 | FALHA=0 | MANUAL=4` e testes manuais finais aprovados pelo operador.

### Adicionado

- **Onda 20 / MICRO31** — P0 UI: reativacao de entidade via servico,
  preservacao/restauracao de credenciamentos na reativacao de empresa e
  guards de reentrada em forms mutadores.
- **Onda 22 / MICRO37** — backfill auditavel de `DT_ULT_REATIV` a
  partir do `AUDIT_LOG`, com deteccao read-only e aplicacao explicita.
- **Onda 22 / MICRO38** — diagnostico e migracao controlada de residuos
  sem chave em `CAD_OS`, com comando operacional
  `RepoOS_MigrarRefOrfaLegado`.
- **Onda 22 / MICRO39** — diagnostico read-only de `DT_ULT_REATIV`
  nao vazia e invalida em `EMPRESAS`, com cobertura `CS_INT_05`.
- **Onda 22 / MICRO40** — quatro cenarios E2E para bordas temporais da
  janela punitiva de strikes apos reativacao: anterior, igual,
  posterior e corte futuro.
- **Onda 23 / MICRO41** — suite `TV2_RunAdversarial_UI` read-only com
  10 asserts `UI_ADV_*` para guards, confirmacoes, acoes destrutivas e
  exposicao na Central V2.
- **Onda 23 / MICRO42** — suite `TV2_RunTransaction_Interrupt` com
  6 asserts `TX_INT_*` para commit, rollback, aninhamento e cleanup
  idempotente de `Svc_Transacao`.
- **Onda 23 / MICRO43** — suite `TV2_RunBoundary_Dates` com
  9 asserts `DATE_BND_*` para parser de data de OS e normalizacao de
  data na avaliacao.
- **Onda 23 / MICRO44** — matriz documental V204
  `regra -> cenario -> assert -> evidencia`, preparando o Sexteto como
  gate de release com bloco adversarial da Onda 23.
- **Onda 23 / MICRO45** — gate `CT_ValidarRelease_SextetoMinimo`,
  agregando Quinteto + bloco adversarial Onda 23
  (`ADVERSARIAL_UI`, `TRANSACAO_INTERRUPT`, `BOUNDARY_DATES`) como gate
  oficial V204-dev; a Central V2 passa a expor o Sexteto como opcao [1].
- **Onda 24 / MICRO46** — hardening de `Limpar_Base`: campo de senha
  mascarado, validacao centralizada sem token sensivel literal no form,
  auditoria de tentativa negada/autorizada e novo assert
  `UI_ADV_012_LIMPAR_BASE_SEM_SENHA_CLARA`; tambem remove literal
  sensivel remanescente no preparo da planilha de validacao release.
- **Onda 24 / MICRO47** — `Configuracao_Inicial` passa a rejeitar
  valores invalidos da regra de strikes antes de gravar `CONFIG`, com
  mensagem clara, auditoria `CONFIG_INVALIDA` e novo assert `MIG_008`
  no `TV2_RunSmoke`.
- **Onda 24 / MICRO48** — `Svc_Avaliacao.AvaliarOS` passa a registrar
  no `AUDIT_LOG` a dupla contagem de nota baixa: `STRIKES_TOTAL` bruto
  e `STRIKES_PUNICAO` na janela pos-reativacao, com novo assert
  `CS_REATIV_AUDIT_DUAL_COUNTER` em E2E Strikes.
- **Onda 25 / MICRO50** — bump para `v12.0.0204-rc1`, preservando a base
  segura MICRO48 e corrigindo o alvo de evidencia do gate para
  `auditoria/evidencias/V12.0.0204`.
- **Onda 25 / MICRO51** — higiene documental final do rc1: status,
  roadmap, relay/results, checklist de publicacao e debitos aceitos sem
  novo pacote V3.
- **Onda 25 / MICRO52** — pacote de auditoria cruzada final Opus +
  Antigravity, com criterio de saida sem P0/P1 antes de tag/release.
- **Onda 25 / MICRO53** — Smoke ganha `MIG_009`, cobrindo o contrato
  de Limpar Base: `ATIVIDADES` preservada e `CAD_SERV` zerado.
- **Onda 25 / MICRO54** — fechamento de publicacao V204: release note
  publica, status oficial, matriz de testes, relay/results e vitrine
  documental alinhados ao gate final `VR_20260511_154433`.
- **Onda 25 / MICRO55** — `App_Release` final alinhado a V12.0.0204
  VALIDADO/OFICIAL, com proxima release alvo V12.0.0205 e evidencia adicional
  `VR_20260511_175849`.
- **Onda 25 / MICRO56** — vitrine humana V204: guia de liberacao de macros no
  Windows, how-to do Sexteto, roteiro manual V204, matriz de cobertura de
  regras V204 e arquivamento semantico dos documentos V203/rc4.
- **Onda 25 / MICRO57** — guia humano V204 reorientado para validacao pela
  interface do Excel: botao Sobre, botao Central de Testes, Central V2 opcao
  `[1] Sexteto Minimo`, roteiro manual e checklist sem VBE/Janela Imediata.
- **Onda 25 / MICRO58** — vitrine pública V204 racionalizada para testador
  humano externo: regras de negócio V204 canônicas, guia humano em Markdown e
  Word, índice de evidências, acentuação PT-BR, separação `docs/` vs `doc/`,
  atualização do `AGENTS.md`, promoção do Importador V3 e arquivamento
  explícito do material histórico V2/V203.
- **Onda 25 / MICRO59** — incorporação do protocolo Word aprovado de
  homologação humana V12.0.0204, com 82 páginas renderizadas para QA visual,
  e preparação do handoff V205 para Codex 5.5.

### Corrigido

- **Onda 21 / MICRO32** — `Repo_Empresa.GravarStatusEmpresa` passa a
  retornar `TResult` e validar persistencia. `Svc_Rodizio.Suspender` e
  `ReativarLinhaEmpresa` deixam de declarar sucesso quando a gravacao em
  `EMPRESAS` falha ou nao confirma o estado esperado.
- `Svc_Rodizio.AvancarFila` deixa de mascarar falha de `Suspender` apos
  recusa punivel.
- **Onda 21 / MICRO33** — `Svc_Avaliacao.AvaliarOS` passa a retornar
  falha explicita quando `Suspender` ou `AvancarFila` falha apos a
  avaliacao ja persistida, registrando `AUDIT_LOG` com `OS_JA_AVALIADA=SIM`.
- **Onda 21 / MICRO34** — `Repo_Avaliacao` ganha contadores de strikes
  com `TResult` e `qtdOut`; `AvaliarOS` usa o caminho verificavel antes
  de decidir suspensao, evitando zero silencioso em erro.
- **Onda 21 / MICRO35** — `Svc_OS.EmitirOS` passa a preparar `PRE_OS`
  antes de criar OS e remove a OS recem-criada caso uma falha posterior
  impeça concluir a conversao; falha de fila ganha auditoria transacional.
- **Onda 21 / MICRO35-fix1** — corrige compilacao no VBE substituindo
  chamadas qualificadas `Repo_OS.*` por wrappers publicos `RepoOS_*`.
- **Onda 21 / MICRO35-fix2** — remove chamadas remanescentes
  `Repo_OS.BuscarPorId` em servico, UI e testes V2.
- **Onda 21 / MICRO35-fix3** — torna o pacote de compilacao cumulativo,
  reimportando `Svc_OS` junto dos wrappers para cobrir workbook reaberto
  sem salvar o `MICRO35-fix1`.
- **Onda 21 / MICRO36** — `Svc_Transacao.Transacao_Iniciar` rejeita
  transacao aninhada sem sobrescrever a transacao externa; Smoke ganha
  `ATM_002` para cobrir a lacuna R-48.
- `Auto_Open` passa a sinalizar pendencias de backfill de
  `DT_ULT_REATIV` em `StatusBar`, sem aplicar mutacao automatica.
- **Onda 22 / MICRO38** — `INT-CAD-OS-REF-ORFA` deixa de misturar
  residuos legados sem `OS_ID` com orfas reais: residuos podem ser
  limpos de forma auditavel, enquanto OS reais com `EMP_ID`/`ATIV_ID`
  invalidos continuam reportadas.
- `TV2_ClearSheet` passa a limpar sobras nas primeiras 50 colunas,
  evitando que dados residuais em colunas finais reaparecam como drift
  estrutural em `CAD_OS`.
- **Onda 22 / MICRO39** — `ContarStrikesParaPunicaoResultado` passa a
  bloquear punicao quando `DT_ULT_REATIV` esta corrompida, evitando
  retorno silencioso ao modo legado.
- **Onda 22 / MICRO39-fix1** — `MIG_007` deixa de escrever data invalida
  diretamente em `EMPRESAS` e passa a validar o contador com override
  deterministico; o handler fatal do Smoke preserva o erro original.
- **Onda 25 / MICRO53** — `LimpaBaseTotalReset` passa a limpar
  `CAD_SERV` com cabecalho canonico e remove `CAD_SERV` da lista
  "PRESERVADO"; o refresh do Cadastro de Servico descarta instancia
  oculta/stale e protege leitura do filtro apos modal.
- **Onda 25 / MICRO53-fix2** — baseline V2 recria servicos canonicos
  apos Limpar Base zerar `CAD_SERV`, restaurando Smoke `34/0/4`.

### Validação

- MICRO31 aprovado pelo operador em `VR_20260505_155650`:
  `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO32 entregue para importacao como
  `f7aa84f+ONDA21.MD21.1-status-empresa-result`.
- MICRO32 aprovado pelo operador em `VR_20260505_174431`:
  `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO33 entregue para importacao como
  `f7aa84f+ONDA21.MD21.2-3-avaliar-os-falhas`.
- MICRO33 aprovado pelo operador em `VR_20260505_180817`:
  `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO34 entregue para importacao como
  `f7aa84f+ONDA21.MD21.4-contar-strikes-result`.
- MICRO34 aprovado pelo operador em `VR_20260505_185750`:
  `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO35 entregue para importacao como
  `f7aa84f+ONDA21.MD21.5-emitir-os-rollback`.
- MICRO35-fix1 entregue para importacao como
  `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix1`.
- MICRO35-fix2 entregue para importacao como
  `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix2`.
- MICRO35-fix3 entregue para importacao como
  `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix3`.
- MICRO35-fix3 aprovado pelo operador em `VR_20260505_213722`:
  `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO36 entregue para importacao como
  `f7aa84f+ONDA21.MD21.6-transacao-aninhamento`.
- MICRO36 aprovado pelo operador em `VR_20260506_092007`:
  `V1=171/0+V2_Smoke=29/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO37 entregue para importacao como
  `f7aa84f+ONDA22.MD22.1-backfill-dt-ult-reativ`.
  Aprovado pelo operador em `VR_20260506_120157`:
  `V1=171/0+V2_Smoke=30/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO38 entregue para importacao como
  `f7aa84f+ONDA22.MD22.2-ref-orfa-cad-os`. Aprovado pelo operador em
  `VR_20260506_163217`; migracao controlada limpou 82 residuos sem
  chave em `CAD_OS` e deixou `ORFA_EMP=0`, `ORFA_ATIV=0`,
  `RESIDUOS=0`.
  Gate: `V1=171/0+V2_Smoke=31/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
- MICRO39 entregue para importacao como
  `f7aa84f+ONDA22.MD22.3-dt-ult-reativ-invalida`.
  Reprovado pelo operador em `VR_20260506_222237` por fatal no
  `V2_SMOKE` antes do assert `MIG_007`.
- MICRO39-fix1 entregue para importacao como
  `f7aa84f+ONDA22.MD22.3-dt-ult-reativ-invalida-fix1`.
  Aprovado pelo operador em `VR_20260506_232006`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=4/0`.
- MICRO40 entregue para importacao como
  `f7aa84f+ONDA22.MD22.4-bordas-temporais-strikes`.
  Aprovado pelo operador em `VR_20260507_010423`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0`.
- MICRO41 entregue para importacao como
  `f7aa84f+ONDA23.MD23.1-adversarial-ui`.
  Aprovado pelo operador com suite nova `TV2_20260507_022218`
  (`ADVERSARIAL_UI=10/0/0`) e Quinteto `VR_20260507_022355`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0`.
- MICRO42 entregue para importacao como
  `f7aa84f+ONDA23.MD23.2-transacao-interrupt`.
  Aprovado pelo operador com suite nova `TV2_20260507_042944`
  (`TRANSACAO_INTERRUPT=6/0/0`) e Quinteto `VR_20260507_043052`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0`.
- MICRO43 entregue para importacao como
  `f7aa84f+ONDA23.MD23.3-boundary-dates`.
  Aprovado pelo operador com suite nova `TV2_20260509_020108`
  (`BOUNDARY_DATES=9/0/0`) e Quinteto `VR_20260507_083959`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0`.
- MICRO44 entregue como delta documental, sem importacao V3:
  `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md`.
- MICRO45 entregue para importacao como
  `f7aa84f+ONDA23.MD23.5-sexteto-gate`. Aprovado pelo operador com
  `ADVERSARIAL_UI=11/0/0` em `TV2_20260509_025210` e Sexteto
  `VR_20260509_025323`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=26/0`.
- MICRO46 entregue para importacao como
  `f7aa84f+ONDA24.MD24.1-limpar-base-seguro`. Aprovado pelo operador
  com `ADVERSARIAL_UI=12/0/0` em `TV2_20260509_141117` e Sexteto
  `VR_20260509_141235`:
  `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO47 entregue para importacao como
  `f7aa84f+ONDA24.MD24.2-config-invalida-audit`. Gate esperado:
  `TV2_RunSmoke False = 33/0/4` e Sexteto
  `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO47 aprovado pelo operador em `TV2_20260509_150814` e Sexteto
  `VR_20260509_163840`:
  `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO48 entregue para importacao como
  `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`. Gate esperado:
  `TV2_RunRodizioStrikesEndToEnd False = 76/0/0` e Sexteto
  `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO49, MICRO49-fix1 e MICRO49-fix2 reprovados por compile crash ou
  build stale apos recovery. Rollback formal para MICRO48 aprovado em
  `VR_20260509_231321`; MD-24.4 fica deferido para V205.
- MICRO50 entregue para importacao como `f7aa84f+v12.0.0204-rc1`.
  Aprovado pelo operador em `VR_20260510_000428`: Sexteto
  `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
  com CSV em `auditoria/evidencias/V12.0.0204`.
- MICRO51 executado como delta documental sem alteracao de VBA; proximo
  gate recomendado e auditoria cruzada final MICRO52, sem P0/P1.
- MICRO52 entregue como pacote documental read-only para auditoria
  externa. Antigravity retornou `APROVAR_PARA_MICRO54`; Opus retornou
  `APROVAR_COM_RESSALVAS_P2`; nenhum P0/P1 identificado. MICRO54 sera
  ampliado para fechar P2 documentais antes de tag/release.
- MICRO53 entregue para importacao como
  `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix`. Gate esperado:
  `TV2_RunSmoke False = 34/0/4`, teste manual confirmando `CAD_SERV`
  zerado e Cadastro de Servico abrindo sem erro, e Sexteto
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO53-fix1 entregue para importacao como
  `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix1`, corrigindo erro de
  sintaxe em `Preencher.CorrigirMojibakeBasico` com uso de `ChrW$()`
  no lugar de literais mojibake ambiguas.
- MICRO53-fix2 entregue para importacao como
  `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`, corrigindo FATAL do
  Smoke `SERV_A/B/C=0` ao recriar `CAD_SERV` canonico na baseline V2
  apos o novo contrato de limpeza de servicos. Aprovado pelo operador
  em importacao `M=2/F=0/err=0/skip=0`, compile limpo, build esperado e
  Smoke `TV2_20260511_131824` com `OK=34/FALHA=0/MANUAL=4`.
- Validacao manual final aprovada pelo operador em 2026-05-11.
- Gate final `VR_20260511_154433` aprovado:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- MICRO54 fecha publicacao sem nova funcionalidade: status oficial,
  release note publica, matriz de testes, HBN e vitrine documental
  passam a apontar para `v12.0.0204`.
- MICRO55 entregue como micro release de metadado: `App_Release` passa
  a exibir V12.0.0204 / VALIDADO / OFICIAL, preserva o build validado
  `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` e aponta a proxima
  release alvo para V12.0.0205.
- MICRO55 aprovado pelo operador em 2026-05-11 com Importador V3
  `M=1/F=0/err=0/skip=0`, compile limpo, tela `Sobre` alinhada e
  Sexteto extra `VR_20260511_175849` APROVADO.
- MICRO56 executado como delta documental sem alteracao de VBA, fechando
  bloqueio P1 dos guias humanos: testador externo agora encontra liberacao
  de macros, gate Sexteto V204, roteiro manual V204 e matriz de cobertura
  V204 como trilha publica canonica.
- MICRO57 executado como delta documental sem alteracao de VBA, corrigindo a
  trilha publica para o perfil real do testador externo: abrir Excel, liberar
  macros, clicar em **Central de Testes** e rodar a bateria pela interface.
- Regra permanente documentada em HBN: funcionalidade nova exige teste
  correspondente no mesmo microdelta.
- Regra permanente documentada em HBN: higiene documental recorrente
  antes de passar de microdelta, onda, release ou bastao.
- Roadmap V204 expandido com Onda 26 pos-release para documentacao,
  RAG/Obsidian e rotina recorrente de faxina documental.

### Debitos Tecnicos Deferidos

- **V205 / MD-24.4 deferido** — documentar side-effects de
  `Svc_Rodizio.SelecionarEmpresa` em microdelta novo, partindo de base
  limpa, sem reaproveitar MICRO49.
- **Onda 26 / V205** — tratar falhas residuais do
  `glasswing-checks.sh --strict` que nao sao G7/G8: G1 historico do
  `Importador_V3_Bootstrap.bas` e warnings antigos G2/G5.
- **Onda 26 / V205** — alinhar o filename do CSV de Sexteto V204: o
  arquivo do rc1 foi gravado na pasta correta `auditoria/evidencias/V12.0.0204`,
  mas ainda saiu com prefixo historico `ValidacaoReleaseSexteto_V12_0_0203`.
- **V205 / taxonomia de testes** — renomear "Sexteto" para nomenclatura
  profissional de engenharia de software, com proposta a ser definida na
  auditoria cruzada Opus/Antigravity da V12.0.0205.

## [v12.0.0203-rc4] — 2026-05-04

> **Release Candidate para testes manuais formais.** Esta versão corrige
> a ressalva R1 das auditorias cruzadas 58/59 antes de liberar a V203 para
> homologação manual. Continua não sendo produção.

### Publicacao e treinamento

- Preparado pacote documental de vitrine publica da V203 rc4 para GitHub.
- Criado guia humano de treinamento de testes manuais da V203.
- Criado procedimento do Quinteto de validacao release.
- Criados mapa do Quinteto, catalogo de cenarios V2, matriz de cobertura
  de regras de negocio e roteiro manual da rc4.
- Criados prompts de auditoria cruzada para Opus e Antigravity cobrindo
  regras de negocio, seguranca, cobertura combinatoria e proposta V204.
- Criado plano inicial `V12.0.0204` para estabilizacao final dos debitos
  tecnicos conhecidos antes de producao.

### Corrigido

- **DT-FRENTE1-FORMS-BYPASS-REATIV / R1** — `Reativa_Empresa.frm` deixa
  de reativar empresa apenas por cópia direta. Após mover a linha de
  `EMPRESAS_INATIVAS` para `EMPRESAS`, o form chama
  `ReativarLinhaEmpresa`, que grava `STATUS=ATIVA`, zera recusas, limpa
  `DT_FIM_SUSP`, preenche `DT_ULT_REATIV` e registra `EVT_REATIVACAO`.
- `Svc_Rodizio.Reativar` passa a reutilizar a mesma rotina central
  `ReativarLinhaEmpresa`, reduzindo divergência entre reativação
  automática e reativação via UI.
- `CS_23` agora valida que a ida/volta empresa ativa ↔ inativa retorna
  com `DT_ULT_REATIV` preenchida.
- **MICRO30-fix1** — `ClassificaEmpresa` agora ordena `EMPRESAS` até a
  coluna `U` (`COL_EMP_DT_ULT_REATIV`). Isso preserva a data de reativação
  após a classificação da aba.

### Alterado

- **`APP_RELEASE_TAG`**: `v12.0.0203-rc3` → `v12.0.0203-rc4`.
- **`APP_BUILD_IMPORTADO`**:
  `f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u`.
- **`APP_RELEASE_TEST_KEY`**:
  `quinteto-v203-rc4-2026-05-04`.

### Débitos Ainda Não Resolvidos Nesta Candidata

- **INT-CAD-OS-REF-ORFA** — permanece aberto em `RPT_BUGS_CONHECIDOS`
  quando a base contém referências órfãs em `CAD_OS`.
- **DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT** — deferido para V12.0.0204.
- **DT-FRENTE1-REATIV-NOOP-ATIVA** — deferido para V12.0.0204.
- **DT-FRENTE1-BACKFILL-AUDIT** — deferido para V12.0.0204.
- **DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO** — deferido para V12.0.0204.

### Validação

- `MICRO30` importou e compilou, mas o Quinteto `VR_20260504_163656`
  reprovou em `CS_23`: `DT_ULT_REATIV_A=(vazia)`.
- `MICRO30-fix1` entregue para importação, corrigindo a ordenação
  `EMPRESAS` de `A:T` para `A:U`.
- `MICRO30-fix1` importou, compilou e passou no Quinteto
  `VR_20260504_171048`.
- Gate aprovado:
  `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.

## [v12.0.0203-rc3] — 2026-05-04

> **Release Candidate** após fechamento conjunto Onda 17 + Onda 18.
> Status: `RELEASE_CANDIDATE`. Gate oficial: **Quinteto Mínimo**
> (`CT_ValidarRelease_QuintetoMinimo` = V1 + V2 Smoke + V2 Canônica +
> E2E Strikes + IntegridadeBase). `APP_RELEASE_TEST_KEY =
> "quinteto-onda18-2026-05-04"`. Promoção para `v12.0.0203` final fica
> condicionada à auditoria cruzada Opus + Antigravity.

### Adicionado

- **Onda 17 (Bloco A)** — gate Quinteto oficial:
  - `TV2_RunIntegridadeBase` como suite de auditoria passiva.
  - `RPT_BUGS_CONHECIDOS` com upsert por `BUG_ID`.
  - `CT_ValidarRelease_QuintetoMinimo` e renumeração da Central V2.
  - Status bar sempre atualizada nas suites de teste.
- **Onda 18 (Bloco B)** — resolução crítica DT-17:
  - `EMPRESAS.DT_ULT_REATIV` na coluna U.
  - `TEmpresa.DT_ULT_REATIV`.
  - `Svc_Rodizio.Reativar` grava `DT_ULT_REATIV`.
  - `Repo_Avaliacao.ContarStrikesParaPunicao` filtra punição por
    `COL_OS_DT_FECHAMENTO > DT_ULT_REATIV`, preservando contador
    histórico total.
  - `RPT_BUGS_RESOLVIDOS` e migração do `DT-17-REATIV-STRIKES` para
    `RESOLVIDO`.
  - Dica visual no primeiro aviso do Modo Treinamento para acompanhar
    progresso na barra de status.

### Alterado

- **`APP_RELEASE_TAG`**: `v12.0.0203-rc1` → `v12.0.0203-rc3`.
- **`APP_BUILD_IMPORTADO`**: `f7aa84f+v12.0.0203-rc3`.
- **`APP_RELEASE_TEST_KEY`**:
  `quinteto-2026-05-04` → `quinteto-onda18-2026-05-04`.
- **E2E_Strikes**: 65 asserts verdes → 71 asserts verdes, com seis
  asserções novas cobrindo reativação, janela de punição e modo legado.

### Resolvido

- **DT-17-REATIV-STRIKES** — reativação de empresa não zera histórico,
  mas zera a janela de punição. `CS_E2E_REATIV2STRIKES` deixou de ser
  manual/amarelo e passou a assert verde.
- **DT-MD17.1.e-STATUSBAR-HINT** — aviso do Modo Treinamento agora
  orienta o operador a acompanhar a barra de status.

### Débitos deferidos

- **INT-CAD-OS-REF-ORFA** — permanece aberto em `RPT_BUGS_CONHECIDOS`
  quando a base contém referências órfãs em `CAD_OS`.
- **DT-FRENTE1-FORMS-BYPASS-REATIV** — deferido para onda futura.
- **DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT** — deferido.
- **DT-FRENTE1-REATIV-NOOP-ATIVA** — deferido.
- **DT-FRENTE1-BACKFILL-AUDIT** — deferido.
- **DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO** — deferido.

### Validação final

- **Bloco A**:
  - Quinteto `VR_20260503_234443` = **APROVADO**:
    `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0`.
  - Quarteto `VR_20260504_000004` = **APROVADO** com sintaxe idêntica
    ao baseline MD-17.1.e.
- **Bloco B**:
  - `MICRO25-fix2` Quinteto `VR_20260504_054106` = **APROVADO**.
  - `MICRO26` Quinteto `VR_20260504_060256` = **APROVADO**:
    `E2E_Strikes=71/0`.
  - `MICRO27` Quinteto `VR_20260504_064117` = **APROVADO**.
  - `MICRO28` Quinteto `VR_20260504_070441` = **APROVADO**:
    `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.
  - `MICRO29` Quinteto `VR_20260504_075624` = **APROVADO**:
    `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.

## [v12.0.0203-rc1] — 2026-05-02

> **Release Candidate** da linha V12.0.0203. Status:
> `RELEASE_CANDIDATE`. Gate oficial de release: **Quarteto Mínimo**
> (`CT_ValidarRelease_QuartetoMinimo` = V1 + V2 Smoke + V2 Canonica +
> V2 E2E Strikes). `APP_RELEASE_TEST_KEY = "quarteto-2026-05-02"`.
> Promoção para `v12.0.0203` final ocorrerá após Ondas 12-15
> reincorporadas + push GitHub público.

### Adicionado

- **Onda 11 (V12.0.0203-rc1 closure, 2026-05-02)** — fechamento
  corretivo + release candidate.
  - **MD-0** — drift G7 sync: 6 arquivos canônicos copiados de volta
    para `src/vba` (Svc_Avaliacao, Repo_Avaliacao, Teste_V2_Roteiros,
    Util_Config, Svc_PreOS, Svc_Rodizio).
  - **MD-1** — instrumentação E2E DT-3: 5 marcadores `DIAG_*` por
    rodada em `TV2_E2E_AtenderProximaEmpresa`.
  - **MD-2** — fix DT-3 part A: Select Case tolerante a padding
    `"1"↔"001"` + CONFIG `MAX_STRIKES=3`, `DIAS_SUSPENSAO_STRIKE=90`
    no contexto E2E.
  - **MD-2.2** — asserts da verdade matemática: Etapa E sem loop,
    valores reais (1, 3, 3) com comentário-vacina.
  - **MD-2.3** — anti-vazamento de CONFIG: helper
    `TV2_E2E_RestaurarConfigBaseline` em sucesso + falha (try/finally
    simulado).
  - **MD-3** — DT-1 release gate honesty:
    `CT_ValidarRelease_QuartetoMinimo` (V1 + V2_Smoke + V2_Canonica +
    E2E_Strikes). Sintaxe canônica do bloco IA:
    `V1=A/F+V2_Smoke=A/F+V2_Canonica=A/F+E2E_Strikes=A/F`.
  - **MD-3.1** — visibilidade do Quarteto no menu da Central V2
    (opção `[20]`, preserva `[15]-[19]` reservadas para Ondas 12-16).
  - **MD-4** — CSVs de evidência da raiz movidos para
    `auditoria/04_evidencias/V12.0.0203/`.
  - **MD-5** — bump rc1 + CHANGELOG + ERP + fechamento Onda 11 +
    relatório de drift G7 residual.
- **Lições destiladas** em `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
  (append-only, preservando L1-L15 + M1-M6):
  - **L16** — Anti-vazamento de CONFIG entre suites.
  - **L17** — Instrumentação cirúrgica antes de fixar.
  - **L18** — Determinismo > narrativa pedagógica.
  - **M7** — Auditor de espelho deve hashar src vs canonical antes de RCA.
- **Marcadores HBN V2** (`.hbn/knowledge/0005-protocolo-markers-v2.md`):
  10 marcadores (3 V1 + 7 V2 novos: 🟠 source drift, 🔴 release blocker,
  🔵 handoff ready, ⚪ audit-only, 🟢 checkpoint clean, 🟤 license split,
  🟣 peer review).
- **Delta card 7 linhas** como retorno operacional canônico de IA em
  `safe_track`.
- **Specs deslocadas para V12.0.0204**:
  - DT-5 (PDFs por ciclo de rodízio) — spec em
    `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`.
  - DT-6 (Validação UI Configuracao_Inicial parametrizada) — spec em
    `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`.

### Alterado

- **`APP_RELEASE_STATUS`**: `VALIDADO` → `RELEASE_CANDIDATE`.
- **`APP_RELEASE_TAG`**: `v12.0.0202` → `v12.0.0203-rc1`.
- **`APP_RELEASE_EVIDENCE_DIR`**: `auditoria/evidencias/V12.0.0202`
  → `auditoria/evidencias/V12.0.0203`.
- **`APP_RELEASE_TEST_KEY`**: `bo-2026-04-20+v2-2026-04-20` →
  `quarteto-2026-05-02` (Quarteto vira gate canônico).
- **`APP_BUILD_IMPORTADO`**: `f7aa84f+v12.0.0203-rc1`.
- **Central V2**: opção `[12]` renomeada para "Validacao release Trio";
  opção `[20]` adicionada para "Validacao release Quarteto".

### Resolvido (débitos técnicos)

- **DT-1** (release gate honesty) — Quarteto entrega cobertura
  E2E Strikes no gate oficial.
- **DT-3** (12 falhas em `TV2_RunRodizioStrikesEndToEnd`) — fluxo
  natural com 3 EMPs valida regra de strikes end-to-end (64 asserts
  verdes).

### Drift G7 residual reconhecido (não bloqueante)

- 30+ módulos divergem entre `src/vba` e `local-ai/vba_import` por
  hotfixes V2 históricos (D1 do roadmap 27). Documentado em
  `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`.
  Resolução: caso-a-caso pelas Ondas 12-16.

### Validação final

- **Gate Quarteto Mínimo** `VR_20260502_054314` = **APROVADO**:
  `V1=171/0 + V2_Smoke=14/0 + V2_Canonica=20/0 + E2E_Strikes=64/0`.
- Compile manual limpo no workbook ancora `V12-202-Z`.

## [Unreleased]

### Adicionado (Onda 6 — consolidacao documental + integracao metodologica)

- **`AGENTS.md`** — entrada canonica para qualquer IA (padrao
  [agents.md](https://agents.md/)), substituindo a fragmentacao entre
  `CLAUDE.md`, `.cursorrules`, `.codex/`, etc. `CLAUDE.md` agora aponta
  para `AGENTS.md`.
- **`llms.txt`** — mapa curado para LLMs (padrao
  [llmstxt.org](https://llmstxt.org/)).
- **`llms-full.txt`** — indice exaustivo dos `.md` versionados.
- **`.hbn/`** — coordenacao inter-IA HBN-native:
  `relay/INDEX.md`, `relay/0001-onda06-consolidacao-documental.md`,
  `knowledge/{INDEX,0001-regras-v203-inegociaveis,0002-regra-ouro-vba-import,0003-glasswing-style-preventive-security}.md`,
  `readbacks/0001-onda06.json`, `reports/INDEX.md`, `results/INDEX.md`.
- **`auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md`** —
  constituicao operacional da V12.0.0203 (10 regras inegociaveis,
  ratificadas por Mauricio em 2026-04-28).
- **`obsidian-vault/metodologia/`** — 4 documentos novos: `00-MAPA-DOCUMENTAL.md`,
  `01-COMO-A-IA-LE-ESTE-REPO.md`, `02-INTEGRACAO-USEHBN.md`,
  `03-PROTOCOLO-GLASSWING.md`. Vault revivido (Opcao A) com cadencia
  obrigatoria de update por onda fechada.
- **`local-ai/scripts/onda06-cleanup.sh`** — script unico para o operador
  rodar localmente (sandbox Cowork bloqueia `rm`/`mv`/`git rm`/`git mv`
  no fuse mount).

### Alterado (Onda 6)

- **`auditoria/` reorganizado por tipo** preservando numeracao
  historica: `00_status/`, `01_regras_e_governanca/`, `02_planos/`,
  `03_ondas/onda_NN_<tema>/`, `04_evidencias/`. `auditoria/40` e o
  novo `auditoria/41` ficam na raiz como sumarios cronologicos.
- **`docs/` reorganizado em quadrantes Diataxis**: `tutorials/`,
  `how-to/`, `reference/`, `explanation/`. Conteudo migrado preservando
  historia git.
- **`CLAUDE.md` refinado**: substitui "proibicao absoluta de
  `Mod_Types.bas`" por "intervencao planejada na Onda 9 com plano
  dedicado e aprovacao previa". Aponta para `AGENTS.md` como fonte
  canonica.
- **`local-ai/vba_import/README.md`** atualizado com referencia
  consolidada a Regra de Ouro e nota sobre macros descartaveis fora do
  pacote oficial.
- **`obsidian-vault/00-DASHBOARD.md`** atualizado para refletir Ondas
  1-5 + Onda 6, com cadencia de update obrigatoria por onda fechada.

### Removido (Onda 6)

- **`auditoria/39_REGRA_PACOTE_VBA_IMPORT.md`** — duplicacao consolidada
  em `auditoria/40` secao 4.1, em `local-ai/vba_import/000-REGRA-OURO.md`,
  e no novo `.hbn/knowledge/0002-regra-ouro-vba-import.md`. Conteudo
  preservado nas tres referencias.
- **5 macros descartaveis da raiz de `local-ai/vba_import/`**:
  `Diag_Imediato.bas`, `Diag_Simples.bas`, `Limpa_Base_Total.bas`,
  `Reset_CNAE_Total.bas`, `Set_Config_Strikes_Padrao.bas`. Movidas
  para `Projetos/backups/credenciamento/macros_descartaveis_v0203/` com
  mapa de retorno. Diag_Imediato sera reintroduzido na Onda 7 como
  cenario `RDZ_DIAG_001` automatizado.
- **~80 MB de backups historicos**: `backup_bateria_oficial/`,
  `V12-202-{L,M,N,O,P}/`, `BKP_forms/`, `backups/` movidos para
  `Projetos/backups/credenciamento/` (fora do repo publico).
  Repositorio publico cai de ~80 MB para alvo de < 10 MB.

### Integracao metodologica (Onda 6 — case study para o usehbn)

O Credenciamento adotou formalmente 4 protocolos externos compostos
com o HBN como base de coordenacao inter-IA:

| Protocolo | Documento | Papel |
|---|---|---|
| [HBN](https://usehbn.org) | `.hbn/`, `AGENTS.md`, readback/hearback | core de coordenacao |
| [Diataxis](https://diataxis.fr/) | `docs/{tutorials,how-to,reference,explanation}/` | docs para humanos |
| [llms.txt](https://llmstxt.org/) | `llms.txt`, `llms-full.txt` | docs para LLMs |
| [agents.md](https://agents.md/) | `AGENTS.md` | contrato unificado de agentes |
| Glasswing-style preventive | `.hbn/knowledge/0003-*.md` + 5 vetores G1-G5 | seguranca preventiva |

O `usehbn` recebeu 6 documentos novos formalizando essas integracoes:
`docs/EVOLUTION-POLICY.md`, `docs/INTEGRATION-{DIATAXIS,LLMS-TXT,AGENTS-MD,GLASSWING}.md`,
`docs/CASE-STUDY-CREDENCIAMENTO.md`. Detalhes em
`auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md`.

### Importante (Onda 6)

- **Sem alteracao de codigo VBA.** Build do workbook permanece
  `f7aa84f+ONDA05-em-homologacao` — Onda 5 segue em homologacao manual
  do Mauricio.
- **Sem push para origin.** Apenas commit local. Push e decisao do
  Mauricio apos auditoria final.
- **Reversivel** via `git reset --hard pre-onda-06-2026-04-28`.

### Alterado

- **ONDA 5 — Determinismo no formulario de configuracao**: substituida
  a heuristica `CI_BuscarTextBoxPorLabel` (Label adjacente) pela leitura
  e gravacao DIRETA dos textboxes `TxtNotaCorte`, `TxtMaxStrikes`,
  `TxtDiasSuspensao` em `Configuracao_Inicial.frm`. Em conformidade com
  a regra V203 ("eliminar toda heuristica"). As 3 funcoes
  `CI_TextoTextBoxPorLabel`, `CI_DefinirTextoTextBoxPorLabel` e
  `CI_BuscarTextBoxPorLabel` foram REMOVIDAS do form. `On Error Resume
  Next` curto preserva compatibilidade com workbooks antigos
- **ONDA 5 — Limpa Base operacional robusta**: `Preencher.Limpa_Base`
  agora delega para o novo modulo `Mod_Limpeza_Base.LimpaBaseTotalReset`,
  que (a) detecta cabecalho corrompido e reescreve o cabecalho canonico,
  (b) usa `MAX(End(xlUp))` em colunas A..AT para evitar UsedRange
  "vazado", (c) limpa tambem `EMPRESAS_INATIVAS`, `ENTIDADE_INATIVOS`,
  `AUDIT_LOG` e `RELATORIO`. Preserva: `ATIVIDADES`, `CAD_SERV`,
  `CONFIG`. O caminho da interface (Configuracoes Iniciais > Limpar
  Base, com senha) agora garante limpeza idempotente — substitui o uso
  da macro descartavel `local-ai/vba_import/Limpa_Base_Total.bas`
- build atualizado para `f7aa84f+ONDA05-em-homologacao`

### Adicionado

- novo modulo `src/vba/Mod_Limpeza_Base.bas` com a funcao publica
  `LimpaBaseTotalReset(Optional ByRef relatorioOut As String) As Boolean`
  e helpers internos para detectar cabecalho corrompido e reescrever
  cabecalho canonico por aba; cria `RPT_LIMPEZA_TOTAL` com o resumo da
  operacao
- wire-up dos 3 campos novos em `Configuracao_Inicial.frm` (ONDA 4 da
  esteira Opus): tela ja exibida com Labels "Se a empresa receber XX
  avaliacoes menores que YY sera inabilitada por ZZ dias" agora le e
  grava em `CONFIG` as colunas `COL_CFG_NOTA_MINIMA` (K),
  `COL_CFG_MAX_STRIKES` (L) e `COL_CFG_DIAS_SUSPENSAO_STRIKE` (M);
  validacao defensiva: campos vazios ou fora da faixa permitida nao
  zeram a configuracao em vigor
- helper publico `Diag_RodizioStatus(ATIV_ID)` em `Svc_Rodizio.bas`
  que produz aba `RPT_DIAG_RODIZIO` com fotografia auditavel da fila:
  posicao, EMP_ID, STATUS_CRED, STATUS_GLOBAL, DT_FIM_SUSP, OS aberta,
  Pre-OS pendente e decisao prevista (`APTA`, `FILTRO_A..E`,
  `SEM_EMPRESA`); util para diagnosticar "sem empresas disponiveis"
  em testes manuais
- nova opcao `[16] Diag rodizio` na Central V2 (entrada interativa
  via `Diag_RodizioStatusInteractive`)
- nova suite `TV2_RunCfg` com 2 cenarios `CFG_001..002` validando ida
  e volta dos parametros de strikes via getters publicos em
  `Util_Config`
- nova opcao `[17] Configuracao de strikes: ida e volta` na Central V2
- dedup automatico de duplicatas em `ATIVIDADES` apos cada reset CNAE
  (ONDA 3 da esteira Opus): pares `(CNAE, DESCRICAO)` repetidos sao
  removidos preservando a primeira ocorrencia, e a contagem entra em
  `AUDIT_LOG` no campo `DUPLICATAS_REMOVIDAS`. Decisao do operador:
  duplicatas eram erro de import remanescente e nao devem persistir
- housekeeping de snapshots `CAD_SERV_SNAPSHOT_*`: o reset CNAE agora
  pergunta antes de podar snapshots antigos, mantendo os 5 mais
  recentes por default; auditoria registra `SNAPSHOTS_PODADOS=N`
- novas funcoes publicas em `Preencher.bas`:
  `CnaeRemoverDuplicatasAtividades()`,
  `CnaePodarSnapshots(manterUltimos)`,
  `CnaeConfirmarPodaSnapshots(manterUltimos)`
- `LimparAbaOperacional` exposta como `Public` em `Preencher.bas`
  (sem alteracao de comportamento) para permitir cobertura de
  regressao em `CNAE_006`
- 3 cenarios novos `CNAE_004..006` na suite `TV2_RunCnae` cobrindo
  dedup automatico, poda de snapshots com preservacao dos N recentes
  e regressao de `Limpa_Base` (ATIVIDADES e CAD_SERV intactos)
- snapshot automatico de `CAD_SERV` antes de cada reset CNAE (ONDA 2
  da esteira Opus): a aba `CAD_SERV_SNAPSHOT_<timestamp>` preserva o
  estado anterior das vinculacoes servico-atividade para reaproveitamento
  manual quando necessario; snapshots ficam protegidos com a senha
  padrao para evitar edicao acidental
- validacao automatica de duplicidade em `ATIVIDADES` apos cada reset
  CNAE: o reset agora reporta a quantidade de pares
  `(CNAE, DESCRICAO)` duplicados e registra esse numero em
  `AUDIT_LOG` via `EVT_TRANSACAO`, permitindo deteccao precoce de
  CSV mal formatado
- novas funcoes publicas em `Preencher.bas`:
  `CnaeSnapshotCadServ(qtdLinhasOut)`,
  `CnaeContarDuplicatasAtividades()`,
  `CnaeListarSnapshots()`
- nova constante `SHEET_PREFIX_CAD_SERV_SNAP` em `Const_Colunas.bas`
  para padronizar o prefixo das abas-snapshot
- nova suite `TV2_RunCnae` com 3 cenarios `CNAE_001..003` cobrindo
  criacao do snapshot, deteccao de duplicata via injecao controlada
  e coexistencia ordenada de multiplos snapshots
- nova entrada `[15] CNAE: snapshot e dedup` na Central V2
  (`Central_Testes_V2.CT2_ExecutarCnae`)
- regra de suspensao por strikes na avaliacao (ONDA 1 da esteira Opus):
  cada avaliacao com `MEDIA < NOTA_MINIMA` conta 1 strike; empresa e
  suspensa quando strikes acumulados atingem `MAX_STRIKES`; punicao
  passa a usar `DIAS_SUSPENSAO_STRIKE` em dias como prazo absoluto;
  defaults `NOTA_MINIMA=5.0`, `MAX_STRIKES=3`, `DIAS_SUSPENSAO_STRIKE=90`;
  retro-compatibilidade garantida: `MAX_STRIKES=1` reproduz a regra
  antiga (suspende na primeira nota baixa)
- novas colunas `COL_CFG_MAX_STRIKES` (L) e `COL_CFG_DIAS_SUSPENSAO_STRIKE`
  (M) na aba `CONFIG`; getters publicos `Util_Config.GetMaxStrikes`,
  `Util_Config.GetDiasSuspensaoStrike`
- helper `Repo_Avaliacao.ContarStrikesPorEmpresa(EMP_ID, notaCorte)`
  que conta on-the-fly avaliacoes ruins concluidas
- novo parametro opcional `diasSuspensao` em `Svc_Rodizio.Suspender`
  (default 0 mantem fallback em meses); auditoria de suspensao agora
  registra `BASE=DIAS|MESES`, `DIAS=N|MESES=N` e `MOTIVO=` quando
  informado
- nova suite `TV2_RunStrikes` com 7 cenarios `CS_AVAL_001..007` cobrindo
  acumulacao, nao-zeramento por avaliacao boa, suspensao em dias,
  retro-compatibilidade com MAX=1 e reativacao automatica
- nova entrada `[14] Strikes na avaliacao` na Central V2
  (`Central_Testes_V2.CT2_ExecutarStrikes`)
- contrato explícito de release com tag, diretório de evidência e chave pública de teste em `src/vba/App_Release.bas`
- camada de versionamento seguro com `release oficial`, `canal ativo`, `próxima release alvo` e `assinatura do build`
- rastreabilidade visual do pacote importado com `build importado`, `origem do build` e `pacote gerado em`
- novo cenário V2 `EXP_001` para validar expiração de Pre-OS com punição e retomada correta da fila
- proposta canônica `CS_*` para a Sprint 2 incorporada ao índice público e ao plano executável
- primeiro lote canônico `CS_00..CS_08` automatizado na V2
- cenário canônico `CS_22` automatizado para validar associação estável entre atividade e serviço em emissões repetidas
- cenários canônicos `CS_11` e `CS_13` automatizados para validar suspensão manual e reativação automática por prazo vencido
- cenários canônicos `CS_14`, `CS_16` e `CS_20` automatizados para validar suspensão por nota, retorno ordenado após prazo vencido e filtro cadastral de empresa inativa
- cenário canônico `CS_17` automatizado para validar giro longo `A,B,C,A,B,C,A` sem travamento e com integridade da fila
- cenário canônico `CS_18` automatizado para validar transições inválidas de OS concluída com rejeição auditável
- cenário canônico `CS_21` automatizado para validar completude mínima das famílias críticas do `AUDIT_LOG`
- cenários canônicos `CS_23` e `CS_24` automatizados para validar ida e volta de empresa e entidade entre cadastros ativos/inativos sem duplicidade semântica
- cenário `SMK_007` reforçado para validar auditoria mínima de fechamento e ausência de suspensão indevida em avaliação satisfatória
- cenário `ATM_001` reforçado para validar rollback multi-aba sem mutação residual em `EMPRESAS` e `CREDENCIADOS`, com mensagem legível de rollback
- cenário `STR_001` reforçado para validar IDs canônicos `001,002,003`, ausência de duplicidade semântica no item e quantidade final estável de credenciamentos
- extração inicial da montagem do payload de avaliação para `Svc_Avaliacao.bas`, reduzindo acoplamento no `Menu_Principal.frm`
- primeira extração da orquestração de emissão para `Svc_PreOS.bas` e `Svc_OS.bas`, reduzindo parsing e defaults locais no `Menu_Principal.frm`
- defaults da avaliação carregados diretamente da `CAD_OS`, com justificativa obrigatória quando houver edição de empenho, data, quantidade ou valor pré-preenchidos
- consistência da média da avaliação entre confirmação, persistência e impressão, usando um único cálculo canônico com duas casas decimais
- relatório imprimível da última execução V2 em `RPT_TESTES_V2`, com impressão opcional
- área documental `docs/testes/` para padronizar a narrativa humana das baterias de teste
- trilha cumulativa da suíte V2 em `TESTE_TRILHA` e `AUDIT_TESTES`
- limpeza opcional dos artefatos anteriores da V1 antes da nova execução
- fluxo da V1 unificado para um único ponto de impressão e sem exportação lateral no relatório
- limpeza opcional ampliada para remover artefatos V1/V2 e snapshots `SNAPV2_*`
- workflow de governança ampliado para verificar coerência entre versão, status oficial, tag, changelog e pacote de evidências
- documentação pública da esteira de release e evidência em `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`
- plano executável da Sprint 2 para fortalecimento incremental dos testes e redução de dependência da interface
- primeira fatia de `C3` incorporada: relatórios simples do `Menu_Principal` agora reutilizam helper comum de configuração de página
- padronização inicial dos relatórios com título acentuado, nome do relatório no rodapé e referência auditável automática para impressão
- validador consolidado de release encadeando V1 rápida, V2 Smoke e V2 Canônica em uma evidência copiável para IA
- manifesto candidato de evidências da `V12.0.0203` em `auditoria/evidencias/V12.0.0203/`

### Alterado

- endurecimento do `verify-docs.yml` para a linha pública pós-lançamento da `V12.0.0202`
- tela `Sobre` do sistema para diferenciar visualmente a release oficial `V12.0.0202` da próxima release alvo `V12.0.0203`
- tela `Sobre` reduzida para evitar truncamento do `MsgBox` do VBA e exibir o commit exato do pacote importado
- bateria oficial V1 passa a exportar CSV automático apenas quando houver falhas
- modo de execução da V1 renomeado na interface para distinguir `RÁPIDA` de `ASSISTIDA`, mantendo a mesma bateria com diferença apenas de pausa visual
- V1 automatizada deixa de sincronizar `CHECKLIST_136` ao vivo e passa a usar apenas `RESULTADO_QA` como saída automática
- `CHECKLIST_136` passa a ser tratada como planilha manual opcional, desacoplada da bateria automatizada
- modo `ASSISTIDA` da V1 com delay reduzido e rolagem reposicionada para manter a linha atual mais abaixo na tela
- mensagens finais e relatório da V1 deixam de destacar `MANUAL` quando a execução é 100% automática
- `Audit_Log` ganha a família `Validacao Rejeitada`
- `Audit_Log` passa a diferenciar inativação e reativação de empresa vs entidade na descrição legível do evento
- `Svc_Avaliacao` passa a registrar `Avaliacao Registrada` de forma explícita e sempre auditável
- backlog explícito para revisão futura da UX dos testes assistidos antes do fechamento da versão
- pacote local de importação passa a destacar `AAX-App_Release.bas` como obrigatório em toda microevolução parcial com rastreabilidade visual

### Validado

- build `20e400b-em-homologacao` importado em workbook de homologação, com `Sobre` exibindo commit, branch e data de geração do pacote
- compilação limpa confirmada por operador humano no build `20e400b-em-homologacao`
- Bateria Oficial V1 rápida validada em 2026-04-26 com `OK=171` e `FALHA=0`
- V2 Smoke validado em 2026-04-26 com `OK=14`, `FALHA=0` e sem CSV de falhas
- V2 Canônica validada em 2026-04-26 com `OK=20`, `FALHA=0` e sem CSV de falhas
- validador consolidado `VR_20260426_111549` aprovado com V1 rápida, V2 Smoke e V2 Canônica verdes

### Adiado

- promoção de `APP_RELEASE_ATUAL` para `V12.0.0203` até o fechamento formal da release
- desacoplamento total tela a tela da interface operacional
- reescrita do importador automático e revisão estrutural de `Mod_Types.bas`
- redesign visual completo dos testes assistidos e padronização visual profunda dos relatórios

## [V12.0.0202] - 2026-04-19

### Corrigido

- estabilização da chamada `AvaliarOS(...)` em workbooks restritivos
- consolidação da compilação após a linha de hotfixes da série `0194-0202`
- neutralização final do helper público de proteção de abas na árvore publicada

### Validado

- compilação limpa por operador humano
- bateria oficial recente sem falhas bloqueantes
- evidência pública da bateria oficial publicada em `auditoria/evidencias/V12.0.0202/`
- evidência fresca da V2 validada por operador humano e publicada no mesmo diretório
- auditoria positiva de pontos fortes consolidada em `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md`

### Observações

- linha oficial registrada em [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md)
- linha pública oficial promovida no `main`
- fechamento residual concentrado em homologação jurídica humana e automação adicional de governança
