# Changelog

Este projeto adota o espírito do Keep a Changelog. As mudanças aqui registradas
tratam apenas da linha pública oficial.

## [v12.0.0204-dev] — em desenvolvimento

### Adicionado

- **Onda 20 / MICRO31** — P0 UI: reativacao de entidade via servico,
  preservacao/restauracao de credenciamentos na reativacao de empresa e
  guards de reentrada em forms mutadores.
- **Onda 22 / MICRO37** — backfill auditavel de `DT_ULT_REATIV` a
  partir do `AUDIT_LOG`, com deteccao read-only e aplicacao explicita.
- **Onda 22 / MICRO38** — diagnostico e migracao controlada de residuos
  sem chave em `CAD_OS`, com comando operacional
  `RepoOS_MigrarRefOrfaLegado`.

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
- Regra permanente documentada em HBN: funcionalidade nova exige teste
  correspondente no mesmo microdelta.
- Regra permanente documentada em HBN: higiene documental recorrente
  antes de passar de microdelta, onda, release ou bastao.
- Roadmap V204 expandido com Onda 26 pos-release para documentacao,
  RAG/Obsidian e rotina recorrente de faxina documental.

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
