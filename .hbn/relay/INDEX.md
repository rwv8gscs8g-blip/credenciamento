---
titulo: Relay HBN — coordenacao inter-IA do Credenciamento
versao-protocolo: HBN 0.3.1
proprietario-bastao: Codex CLI (sessao codex-cli-bloco-b-onda18-2026-05-04) — BASTAO RECEBIDO do Opus 4.7 em 2026-05-04T01:34:31-0300; proprietario unico de implementacao da Frente 1 ate devolucao formal via doc 60.
ciclo-ativo: V12.0.0204 Onda 25 sob Codex CLI. Roadmap V204 Onda 20-25 aprovado e Onda 26 documental adicionada por decisao do operador; MICRO49/MD-24.4 revertido formalmente para MICRO48; MICRO50 rc1, MICRO51 higiene e MICRO52 auditoria cruzada passaram sem P0/P1; MICRO53-fix2 aprovado pelo operador em import M=2/F=0/err=0/skip=0, compile limpo, build f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2, Smoke TV2_20260511_131824 OK=34/FALHA=0/MANUAL=4, testes manuais finais OK e gate final VR_20260511_154433 APROVADO; MICRO54 publicado no GitHub com tag/release v12.0.0204; proxima acao: abertura da auditoria cruzada V12.0.0205.
ancora-estavel-atual: V12-202-Z011-onda17-fechada (INTOCAVEL ate aprovacao operador) — build f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17, Quinteto VR_20260503_234443 APROVADO V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0; Quarteto VR_20260504_000004 APROVADO sintaxe IDENTICA ao MD-17.1.e V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0 MANUAL=5.
proxima-acao: Abrir auditoria cruzada Opus/Antigravity para V12.0.0205.
ultima-atualizacao: 2026-05-11T17:02:00-0300 (MICRO54 publicado no GitHub; release v12.0.0204 criada)
---

> ⚠️ **REGRA INVIOLAVEL (M11 destilada 2026-05-03)**: A IA le `src/vba/`
> (fonte de verdade — AGENTS.md §62-63) e transporta para
> `local-ai/vba_import/` (espelho com prefixos). NUNCA o inverso.
> Cada microdelta valida `shasum src/vba/X == shasum local-ai/vba_import/<prefixo>-X`
> antes de declarar gate. Esta regra ja causou regressao em
> 2026-05-02 (lição M11) e em 2026-05-02 ondas anteriores
> (auditoria 32). Ver `auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`.

## Onda 11 FECHADA — V12.0.0203-rc1 (2026-05-02 06:50 BRT)

> ✅ **PUBLICADA NO GITHUB** — tag `v12.0.0203-rc1` em
> `https://github.com/rwv8gscs8g-blip/credenciamento`. Validacao
> Quarteto pos-import: `VR_20260502_063028 = APROVADO`
> com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0011-onda11-v203-rc1-closure.json](../readbacks/0011-onda11-v203-rc1-closure.json) |
| Hearback | confirmed (Q1-Q7' aprovados em chat 2026-05-02; "Pode comecar a implementacao" + "Confirmo e aprovo de Q5 a Q7. Pode implementar") |
| ERP | [results/0011-exec-onda11.json](../results/0011-exec-onda11.json) |
| Fechamento | [auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md) |
| Drift G7 residual (D1) | [auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md) — 23 arquivos divergentes para Ondas 12-16 caso-a-caso |
| Origem | Cadeia Antigravity → Codex (2026-05-02) revelou drift G7 entre src/vba e local-ai/vba_import nos 6 modulos do dominio strikes |
| Renumeracao | Onda 11 corretiva (esta) substitui Onda 11 original (CNAE), que vira Onda 12+ |
| Deadline hard | Domingo 2026-05-03 23:59 BRT |
| **Deadline atendido** | **sim — fechada em 2026-05-02** |
| **Status microdeltas** | **8/8 ENTREGUES** — ver tabela abaixo |
| **Build label final** | `f7aa84f+v12.0.0203-rc1` |
| **APP_RELEASE_TAG** | `v12.0.0203-rc1` |
| **APP_RELEASE_STATUS** | `RELEASE_CANDIDATE` |
| **APP_RELEASE_TEST_KEY** | `quarteto-2026-05-02` (Quarteto = gate oficial conforme Q7 operador) |
| **Gate oficial** | `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) |
| **Validacao final** | `VR_20260502_054314` = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |
| Ancora estavel atual | **V12-202-Z** (backup operador apos MD-2.3 verde) — build `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental` |
| Validacao intermediaria | VR_20260502_034422 = APROVADO (V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0); TV2_20260502_040156 = E2E STRIKES 64/0 |
| **Pendente operador** | ✅ CONCLUÍDO 2026-05-02 06:50 — Quarteto APROVADO `VR_20260502_063028`, tag `v12.0.0203-rc1` publicada em `https://github.com/rwv8gscs8g-blip/credenciamento` |
| **Onda 11 fisicamente fechada** | 2026-05-02 06:50 BRT |
| Protocolo HBN | V2 vigente — ver [knowledge/0005-protocolo-markers-v2.md](../knowledge/0005-protocolo-markers-v2.md) |
| Cadeia Antigravity → Codex (esta sessao) | local-ai/Time_AI/2026-05-02-V203-fechamento/ (gitignored) |
| Phagocytosis decisao | Proposta A + campos de capsule da D — chat-novo-usehbn implementa em paralelo a partir de 2026-05-02 |
| DT-6 NOVO | Validacao UI Configuracao_Inicial parametrizada — V12.0.0204; spec em auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md |
| Automacao semanal | Wave 11+ (segunda 2026-05-04): Typer + uv + GitHub Actions + signed commits PR-only |
| Fora de escopo | DT-2, DT-4 (Ondas 13+); DT-5 PDFs (V12.0.0204); DT-6 (V12.0.0204); reincorporacao Ondas 2-8 originais (Ondas 12+) |

### Microdeltas Onda 11 — entregues (8/8 + tag pendente)

| ID | Tema | Build label | Validacao | Status |
|---|---|---|---|---|
| **MD-0** | Drift G7 sync — 6 arquivos canonicos copiados de volta para src/vba | (sem bump — sincronizacao) | shasum 6/6 match | ✅ APROVADO |
| **MD-1** | Instrumentacao E2E DT-3 — 5 markers DIAG_* por rodada em TV2_E2E_AtenderProximaEmpresa | `ONDA11.MD1-DT3-diagnostic-incremental` | TV2_RunSmoke 14/0 + E2E rodou capturando evidencia | ✅ APROVADO |
| **MD-2** | Fix A (Select Case tolerante a padding "1"↔"001") + Fix B (CONFIG MAX_STRIKES=3, DIAS=90 no contexto E2E) | `ONDA11.MD2-DT3-fix-test-helper-incremental` | E2E 12 falhas → 1 falha (regressao reduzida) | ✅ APROVADO |
| **MD-2.2** | Asserts da verdade matematica — Etapa E sem loop, valores reais (1, 3, 3) com comentario-vacina | `ONDA11.MD2-2-DT3-asserts-fatos-incremental` | E2E 64/0 (primeira vez); trio falhou por vazamento CONFIG → MD-2.3 | ✅ APROVADO |
| **MD-2.3** | Anti-vazamento de CONFIG — helper TV2_E2E_RestaurarConfigBaseline em sucesso + falha | `ONDA11.MD2-3-DT3-cleanup-config-incremental` | VR_20260502_034422 trio APROVADO (171/0+14/0+20/0) + E2E 64/0 | ✅ APROVADO |
| **MD-3** | DT-1 release gate honesty — `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) | `ONDA11.MD3-DT1-quarteto-release-gate-incremental` | **VR_20260502_054314 = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`** | ✅ APROVADO |
| **MD-3.1** | Visibilidade Quarteto no menu Central V2 (opcao [20]) | `ONDA11.MD3-1-DT1-quarteto-menu-incremental` | manifesto MICRO11 entregue; pendente import operador | ✅ ENTREGUE |
| **MD-4** | CSVs antigos da raiz movidos para `auditoria/04_evidencias/V12.0.0203/` | (sem bump — file-only) | 3 CSVs movidos | ✅ APROVADO |
| **MD-5** | rc1 bump (TAG/STATUS/EVIDENCE_DIR/TEST_KEY) + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP + 70_FECHAMENTO + DRIFT_G7_RESIDUAL | `f7aa84f+v12.0.0203-rc1` | manifesto MICRO12 entregue; pendente import operador | ✅ ENTREGUE |

### Pendente operador para fechamento físico

| Acao | Esforço | Files |
|---|---|---|
| Importar MICRO11 (MD-3.1 menu) + MICRO12 (rc1 bump) no workbook | ~5min | manifestos `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO{11,12}.txt` |
| Compile manual + Quarteto verde | ~12min | `CT_ValidarRelease_QuartetoMinimo` |
| Salvar como `V12-202-AB-onda11-rc1` | ~1min | workbook ancora rc1 |
| `git tag v12.0.0203-rc1` + `git push origin v12.0.0203-rc1` | ~1min | git |
| **MD-5** | V12.0.0203-rc1: bump APP_RELEASE_TAG/STATUS/EVIDENCE_DIR + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP `0011-exec-onda11.json` + `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md` | ~60min | AAX-App_Release.bas + 5+ docs |
| Tag git | `git tag v12.0.0203-rc1` + push (operador) | ~5min | git |

### Licoes destiladas nesta sessao (a registrar em PHAGOCYTOSIS no MD-5)

- **L16** — Anti-vazamento de CONFIG entre suites (toda mudanca de estado em CONFIG por suite deve ser revertida em try/finally simulado)
- **L17** — Instrumentacao cirurgica antes de fixar (DIAG_* logs por etapa revelam causa raiz sem ciclos de hotfix encadeados)
- **L18** — Determinismo > narrativa pedagogica (testes devem refletir fatos do sistema, nao premissas idealizadas)
- **M7** — Auditor de espelho deve hashar src vs canonical antes de RCA (erro do Antigravity virou marker `🟠 SOURCE DRIFT DETECTED`)

## Transicao 2026-05-02 — Sessao original encerra; 2 chats paralelos abrem

| Frente | Bastao | Foco | Prompt de abertura |
|---|---|---|---|
| **1 — Credenciamento** | Claude Opus 4.7 (continuacao) | Fechar V12.0.0203-rc1 (MD-3+MD-4+MD-5+tag) + Ondas 12-19 + FECH conforme roadmap original | `local-ai/Time_AI/2026-05-02-V203-fechamento/200-PROMPT-CHAT-NOVO-CREDENCIAMENTO.md` |
| **2 — usehbn / Fagocitose** | Claude Opus 4.7 = arquiteto senior + validador; Codex = executor em esteiras incrementais; Mauricio = palavra final em decisoes complexas | Bootstrap HBN Phagocytosis Protocol v0.1 (modulo VBA primeiro alvo) + protocolo vivo | `local-ai/Time_AI/2026-05-02-V203-fechamento/201-PROMPT-CHAT-NOVO-USEHBN.md` |

Sincronizacao entre frentes: via arquivos no repo (`.hbn/`, `auditoria/`, `usehbn/`). Sem bloqueio mutuo.

# Relay HBN — Credenciamento

## Bastao atual

| Campo | Valor |
|---|---|
| Proprietario | Claude Opus 4.7 (Cowork) |
| Concedido por | Luis Mauricio Junqueira Zanin |
| Data de concessao | 2026-04-28 |
| Validade | ate fechamento estavel da V12.0.0203 no GitHub |
| Reverte para | Codex (apoio) + Claude Opus em modo auditoria |
| Modo de operacao atual | **CONSULTIVO CONTROLADO** (alterado 2026-04-28 apos violacao G6 — saiu do modo "execucao maxima") |
| Justificativa | retrabalho da Onda 5 nao estabilizada; concentracao em uma IA reduz risco de perda de contexto durante a estabilizacao |

## Onda 10 EM EXECUCAO — Reincorporacao Onda 1 (strikes)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0010-onda10-reincorporacao-onda01.json](../readbacks/0010-onda10-reincorporacao-onda01.json) |
| Hearback | confirmed (5 pontos aprovados em chat 2026-05-01) |
| Microdelta atual | **N/A — Onda 10 FECHADA na canonica em 2026-05-02 com debito DT-3 documentado** |
| ERP | [results/0010-exec-onda10.json](../results/0010-exec-onda10.json) |
| Validacao final | `VR_20260501_233424` (V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0) APROVADO |
| Build label final | `f7aa84f+ONDA10-canonica-fechada-com-debito-strikes` |
| Pasta canonica | `local-ai/vba_import/` (RESTAURADA — Regra de Ouro 0002 reafirmada) |
| Solucao de contorno | `local-ai/vba_import_v3_phase1/` arquivada em `auditoria/04_evidencias/V12.0.0203/_historico_v3_phase1_descontinuado_20260502/` |
| Politica de teste | **TV2_RunSmoke por microdelta + trio mínimo 1x ao final da onda** (oficializado 2026-05-01 18:44) |
| Princípio arquitetural | Testes via interface oficial (TV2_Run*), idempotentes, evoluindo junto com codigo de producao. **Sem smoke ad-hoc no Imediato.** |
| Estrategia de espelho | **A — minimalista** (espelho = baseline + delta da onda; src/vba intocado em Phase A.5; hotfixes residuais para Phase A.6) |
| Microdeltas planejados | 1.0 → 1.1 → 1.2 → 1.4 → 1.3 → 1.5 (ordem com 1.4 antes de 1.3 para preservar config canonica) |
| Build label apos 1.0 | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` |
| Build label final apos 1.5 | `f7aa84f+ONDA10-aprovada` |
| Ancora pos-onda10 | V12-202-T-onda10 |
| Doc tecnico | [auditoria/03_ondas/onda_10_reincorporacao_onda01/](../../auditoria/03_ondas/onda_10_reincorporacao_onda01/) |
| Achado Phase A | Ondas 1-4 estao **PARCIALMENTE** no baseline (so infra/producao parcial; suites/diag/menus ausentes). Onda 5 CONFIRMADA. |
| Estrategia | Reincorporacao progressiva via microdeltas, cada um com gate compile + trio + bump build incremental. |

### Microdeltas concluidos da Onda 10

| ID | Tema | Validacao | Build label | Status |
|---|---|---|---|---|
| 1.0 | Extensao V3 capacidade delta + bump auto | VR_20260501_173310 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` | ✅ APROVADO 2026-05-01 17:44 |
| 1.1 | Repo_Avaliacao.ContarStrikesPorEmpresa | VR_20260501_180949 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental` | ✅ APROVADO 2026-05-01 18:19 |
| 1.2 | Svc_Rodizio.Suspender params opcionais | TV2_20260501_184237 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental` | ✅ APROVADO 2026-05-01 18:44 |
| 1.4 | TV2_SetConfigCanonica grava MAX_STRIKES e DIAS_SUSPENSAO_STRIKE | TV2_20260501_185512 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental` | ✅ APROVADO 2026-05-01 18:55 |
| 1.3 | Svc_Avaliacao bloco 7b strikes ATIVO em producao (regra integrada) | TV2_20260501_194706 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental` | ✅ APROVADO 2026-05-01 19:47 |


## Modo de operacao

**Consultivo controlado** (vigente desde hotfix v2 da Onda 6):

- Leitura ampla permitida (Read, Glob, Grep em todo o repo).
- Escrita pequena: cada arquivo modificado e escrita atomica, com
  hearback explicito para mudancas em arquivos canonicos
  (`.hbn/knowledge/`, `auditoria/01_regras_e_governanca/`,
  `usehbn/agents/`, `CLAUDE.md`).
- **Verificacao G6 obrigatoria** antes de enviar resposta ao Mauricio:
  scan da resposta por padroes VBA (`Private Sub`, `Public Sub`,
  `Public Function`, `Dim ... As`, `Range(...)`, `Sheets(...)`,
  `Cells(...)`, `Application.X`). Se houver match, pausar, mover para
  arquivo, atualizar procedimento, reenviar.
- Comandos shell para o operador continuam permitidos (sao operacionais,
  nao deliverable).
- Modo "execucao maxima" anterior (Onda 6 fase 1-2) provou produzir
  violacao — descontinuado.

## Ciclo encerrado mais recente

**ONDA 9 V3 — Phase 1 APROVADA** (2026-05-01 12:25)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0009-onda09-v3-phase1.json](../readbacks/0009-onda09-v3-phase1.json) |
| Hearback | confirmed (3 OKs explicitos + 7 ciclos iterativos validados) |
| ERP | [results/0009-exec-onda09-v3-phase1.json](../results/0009-exec-onda09-v3-phase1.json) |
| Trio minimo | VR_20260501_121550 — V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0 — APROVADO |
| Compile manual | passou limpo apos remocao do Importador_V2 legado |
| Engine | `src/vba/Importador_V3.bas` (1095 linhas) |
| Pacote isolado | `local-ai/vba_import_v3_phase1/` (LEIA-ME + manifesto + 35M + 13F) |
| Bootstrap | `local-ai/vba_import_v3_phase1/Importador_V3_Bootstrap.bas` |
| Doc tecnico | [auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md](../../auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md) |
| Procedimento | [auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md](../../auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md) |
| Licoes aprendidas | [knowledge/0009-licoes-importador-v3-phase1.md](../knowledge/0009-licoes-importador-v3-phase1.md) (L1-L9 + M1-M5) |
| Ancora | `V12-202-S/` — primeira versao com V3 como importador oficial + compile limpo + trio verde |
| Fixes acumulados | 7 (todos baseados em evidencia empirica do log, nenhum chute) |

## Proximas fases

| Fase | Tema | Status |
|---|---|---|
| 1 | V3 alpha — importar baseline | ✅ APROVADA (2026-05-01) |
| 2 | V3 beta — modo Fresh em .xlsx em branco | OPCIONAL — robustece V3 mas nao bloqueia V203 |
| 3 | V3 gamma — renomeacao L2 | DESCARTADA por decisao operador (L1 escolhido) |
| 4 | Auditoria de debitos tecnicos + re-aplicar Ondas 7/8 se delta | EM PLANEJAMENTO |
| F | FECHAMENTO — atualizar build label + tag v12.0.0203 + push GitHub | DEPOIS DE 4 |

## Onda 5 — HOMOLOGADA

| Campo | Valor |
|---|---|
| Status | HOMOLOGADA em 2026-04-28 |
| Validacao | `VR_20260428_231958` em `auditoria/04_evidencias/V12.0.0203/` |
| Build | `f7aa84f+ONDA05-em-homologacao` |
| Trio minimo | V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0 — **APROVADO** |
| Backup ancora | `V12-202-Q/` no diretorio raiz do projeto |

## Ciclo encerrado mais recente

| Campo | Valor |
|---|---|
| Ciclo | ONDA 6 — consolidacao documental + cleanup |
| Track HBN | safe_track |
| Status | ENCERRADO em 2026-04-28 |
| Readback | [readbacks/0001-onda06.json](../readbacks/0001-onda06.json) |
| Hearback | confirmed |
| ERP | [results/0001-exec-onda06.json](../results/0001-exec-onda06.json) |
| Resumo humano | [reports/0001-onda06-summary.md](../reports/0001-onda06-summary.md) |
| Doc tecnico | [auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md](../../auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md) |
| Commits | `85d7459` (conteudo) + `7e64622` (estrutural) |
| Ciclo origem | [relay/0001-onda06-consolidacao-documental.md](0001-onda06-consolidacao-documental.md) (sera arquivado em proxima abertura de ciclo) |

## Ondas previstas (a partir desta)

| Onda | Tema | Status |
|---|---|---|
| 6 | consolidacao documental + cleanup + integracao Diataxis/llms.txt/AGENTS.md/HBN | EM EXECUCAO |
| 5 (resgate) | homologacao final do form deterministico + Limpa_Base robusta (ja entregue, em homologacao manual) | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | PROXIMA APOS ONDA 6 |
| 8 | heuristica zero em todos os 13 forms | DEPOIS DA 7 |
| 9 | reescrita do Importador_VBA + auditoria de Mod_Types (com aprovacao explicita) | DEPOIS DA 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | DEPOIS DA 9 |

## Proxima acao explicita

**Aprovacao do roadmap V203 final** (ver tabela "Proximas fases" acima).

Recomendacao Claude:
1. **Auditoria de debitos tecnicos** (~30 min Claude) — diff src/vba vs V12-202-S, lista de divergencias se houver
2. **Atualizar carimbo de build** em `App_Release.bas` para `f7aa84f+ONDA09-V3-PHASE1-aprovada` (1 commit)
3. **Phase 2 (opcional)** — robustecer V3 com run em `.xlsx` Fresh
4. **Phase 4 sequencial** — re-rodar trio + V2 Canonica completo + auditar Ondas 7/8 se delta
5. **FECHAMENTO** — tag v12.0.0203 + push GitHub

Aguardando hearback do Mauricio sobre ordem.

## Standard HBN markers

Esta sessao usa os marcadores visiveis do adapter HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `❌ HBN SECURITY BLOCKED SUGGESTION` — gate de seguranca
- `🟡 HBN NEEDS HUMAN DECISION` — aprovacao requerida

---

# Frente 2 — usehbn / Sprint 0 (aberta 2026-05-02)

> Seção append-only adicionada pela Frente 2 conforme protocolo
> `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Não substitui nem
> edita conteúdo da Frente 1 acima.

## Bastão Frente 2

| Campo | Valor |
|---|---|
| Proprietário arquiteto | Claude Opus 4.7 (Cowork — sessão Frente 2 aberta 2026-05-02) |
| Proprietário executor | Codex CLI (delegação por esteiras) |
| Autoridade final | Luís Maurício Junqueira Zanin |
| Modo de operação | ⚪ HBN AUDIT-ONLY para Opus (orquestra, valida; não codifica). Codex em modo executor para esteiras aprovadas. |
| Foco | Bootstrap `hbn-phago` (HBN Phagocytosis Protocol v0.1) — esteira E1 = Radar Bootstrap |
| Repo destino | `~/Projetos/usehbn-phago/` (alternativa b — local separado, AGPLv3 limpo, futura promoção a repo público) |

## Histórico de esteiras Frente 2

### Esteira E1 — Radar Bootstrap (FECHADA — aprovada com débito)

| Campo | Valor |
|---|---|
| ID | E1 — Radar Bootstrap |
| Status | ✅ APROVADA com débito DT-FRENTE2-01 (templates genéricos nas 53 fichas — endereçado em E1.1) |
| Spec | [`300-SPRINT-0-HBN-PHAGO-CODEX.md`](../../local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md) |
| ERP | [`local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json) |
| Resultado | 55 fichas + REGISTRY + MATRIX + repo `~/Projetos/usehbn-phago/` (LICENSE AGPLv3) |
| Validação Opus | V1-V12 verdes (estrutura); A1 amarelo (justificativas template — endereçado em E1.1) |
| Hearback Maurício | "sim para todas as quatro" — 2026-05-02 |

### Esteira E1.1 — Radar Content Deepening (FECHADA — aprovada com débito DT-FRENTE2-02)

| Campo | Valor |
|---|---|
| ID | E1.1 — Radar Content Deepening |
| Status | ✅ APROVADA com débito DT-FRENTE2-02 (justificativas template por categoria — não-bloqueante) |
| Spec | [`302-ESTEIRA-E1-1-RADAR-CONTENT-DEEPENING.md`](../../local-ai/Time_AI/2026-05-02-V203-fechamento/302-ESTEIRA-E1-1-RADAR-CONTENT-DEEPENING.md) |
| ERP | [`2026-05-02_E1-1-radar-deepening.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-1-radar-deepening.json) |
| Resultado | 43 fichas reescritas (templates por categoria) + 10 arquivadas + REGISTRY/MATRIX regenerados + relatório `auditoria/00_status/40` |
| Validação Opus | V1-V3, V7-V15 verdes; V4/V5/V6 amarelos (templates persistentes — não-bloqueante) |
| Hearback Maurício | aprovado 2026-05-02 + decisão estratégica: análise profunda migra para Opus sob demanda |
| Mensagem fechamento | [`.hbn/messages/2026-05-02_06_de-opus_para-codex.md`](../messages/2026-05-02_06_de-opus_para-codex.md) |

### Análise profunda Opus (5 fichas — sob demanda, FECHADA)

| Campo | Valor |
|---|---|
| ID | A5 — Análise Profunda 5 Fichas (Opus) |
| Status | ✅ ENTREGUE |
| Fichas | tree-sitter, typer, uv, opentelemetry, consent-capsules |
| Resultado | 5 reescritas in-place com análise individual real, referências reais, recomendações de promoção |
| Recomendações | tree-sitter → `convergence-mapped` (9/10); opentelemetry → `convergence-mapped` (8/10); consent-capsules → `candidate` (10/10) |
| Confirmações | typer + uv → `candidate` em 2026-05-04 conforme programado (10/10 e 8/10 respectivamente) |

### Permeabilidade do radar formalizada (FECHADA)

| Campo | Valor |
|---|---|
| Doc | [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) — seção "Permeabilidade" |
| Cobertura | 5 vias de entrada, regras de baixo atrito, anti-ruído, reentrada de archived, filtro de impacto |
| Origem | pedido Maurício 2026-05-02 (lógica de permeabilidade para novas tecnologias) |

### Sessão 2026-05-06 — análise das 5 tecnologias + reorientação arquitetural radical

| Campo | Valor |
|---|---|
| ID | A5-EVOLUÇÃO — análise das 5 tecnologias do radar (4 de 5 concluídas) |
| Decisões fechadas | **TODAS AS 5**: Tree-sitter APROVADA; Typer ARQUIVADA; uv ARQUIVADA; Consent Capsules APROVADA (migração imediata); **OpenTelemetry APROVADA (fagocitose progressiva)** |
| **Correção fundamental** | **useHBN é MULTI-BRAÇO; fagocitose é apenas UM dos 6 módulos. Doc canônico: `USEHBN-MODULES-ARCHITECTURE.md`** |
| **Documento de aprovação consolidado** | **`auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md` — 7 blocos de decisão pendentes para Maurício** |
| **Auditoria Cruzada IAs (Módulo 6)** | **declarada em `CROSS-IA-AUDIT-PROTOCOL.md`** |
| **Proposta site** | **`usehbn/site/PROPOSTA-MELHORIA-USEHBN-ORG.md`** |
| Decisão arquitetural maior | **Rust como linguagem-base do useHBN** (Árvore Estável); **Consent Capsules como primeira migração estruturada Python → Rust** |
| Princípios operacionais formalizados | Minimalismo de Cadeia (P11 candidato); Substrato Sólido (P12 candidato); AI-Language-Abstraction (P13 candidato) |
| Modelo arquitetural novo | **3 Árvores — Estável (Rust), Desenvolvimento (transição), Exploração (qualquer linguagem)** |
| Markers V2 novos propostos (7) | 🟦 MINIMALIST, 🟪 SUBSTRATO, 🟧 AI-ABSTRACTION, 🌱 EXPLORATION SEED, 🔧 DEV BRANCH, 🪨 STABLE TRUNK, 🟫 TREE TRANSITION |
| Documentos canônicos novos (8) | `MINIMALISM-PRINCIPLE.md`, `SUBSTRATO-SOLIDO-PRINCIPLE.md`, `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md`, `THREE-TREES-ARCHITECTURE.md`, `LANGUAGE-PLATFORM-COMPARISON.md`, `42_ROADMAP_CONSENT_CAPSULES_RUST.md`, `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` + ficha `rust.md` |
| Status | ⏳ apenas análise OpenTelemetry pendente antes do prompt unificado ao Codex e início efetivo R-A |
| Sucessor | `auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md` (renomear para evitar conflito com 42 atual) ou novo número — a ser criado após decisão #5 |
| V2 useHBN | em planejamento; F1 esboço pronto em `43_PLANO_DOCUMENTACAO_V2_USEHBN.md`; F2 inicia após análise OTel |

## Sistema de revisão semanal (ativado nesta sessão)

| Componente | Path |
|---|---|
| Log append-only | [`usehbn/radar/WEEKLY-UPDATES.md`](../../usehbn/radar/WEEKLY-UPDATES.md) |
| Protocolo | [`usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md`](../../usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md) |
| Frequência | Toda quarta-feira 11:45 BRT |
| Próxima revisão | 2026-05-06 (quarta) |
| Modo | Manual (Opus + Maurício) até Wave 11+; depois `hbn weekly-review` automatizado |

## Decisões registradas no hearback 2026-05-02

| # | Decisão | Status |
|---|---|---|
| 1 | Arquivar 10 tecnologias | Codex executa em E1.1 |
| 2 | Promover MCP → `convergence-mapped` | ✅ Opus executou (ficha atualizada) |
| 3 | Acionar Codex para E1.1 | ✅ Mensagem 04 depositada |
| 4 | Stack CLI (Typer, uv, GH Actions, Signed commits) → `candidate` em 2026-05-04 | Agendado |

## Documentos canônicos da Frente 2 (criados nesta sessão)

| Path | Função |
|---|---|
| [`usehbn/methodology/INTER-CHAT-COORDINATION.md`](../../usehbn/methodology/INTER-CHAT-COORDINATION.md) | Protocolo de coexistência F1 ↔ F2 (particionamento de paths, mensageria, soft-locks) |
| [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) | Camada 0 — Radar formalizada (estados, transições, schema de ficha) |
| [`local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md`](../../local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md) | Spec executável da esteira E1 (Codex) |
| [`local-ai/Time_AI/2026-05-02-V203-fechamento/301-PROTOCOLO-PINGPONG-OPUS-CODEX.md`](../../local-ai/Time_AI/2026-05-02-V203-fechamento/301-PROTOCOLO-PINGPONG-OPUS-CODEX.md) | Protocolo Opus ↔ Codex (handoff, ERP, validação, iteração) |
| [`.hbn/messages/2026-05-02_01_de-frente2_para-frente1.md`](../messages/2026-05-02_01_de-frente2_para-frente1.md) | Mensagem informativa de abertura para a Frente 1 |

## Particionamento de paths vigente

Detalhes em `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Resumo:

- **Frente 2 escreve em**: `usehbn/methodology/`, `usehbn/radar/`, `usehbn/constitution/` (Sprint 1+), `local-ai/Time_AI/2026-05-02-V203-fechamento/3*.md`, `auditoria/00_status/` (numeração 38-42), `.hbn/messages/`, `.hbn/locks/`, `.hbn/knowledge/0010+.md`, repo externo `~/Projetos/usehbn-phago/`
- **Frente 2 NÃO toca**: tudo o que pertence à Frente 1 (`src/vba/`, `local-ai/vba_import/`, `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`, `auditoria/03_ondas/`, `App_Release.bas`, `CHANGELOG.md`, `.hbn/readbacks/0011-*`, `.hbn/results/0011-*`, `auditoria/00_status/` numeração 33-37)
- **Append-only compartilhado**: este `.hbn/relay/INDEX.md` (Frente 2 só adiciona seção própria no fim)

## Markers V2 ativos no abrir da Frente 2

- `✅ HBN ACTIVE` — Frente 2 engajada
- `⚪ HBN AUDIT-ONLY` — Opus orquestra; Codex tem bastão executor
- `🔵 HBN HANDOFF READY` — pacote pronto para release ao Codex (aguardando hearback final)
- `🟤 HBN LICENSE SPLIT REQUIRED` — artefatos cruzam TPGL (Credenciamento) e AGPLv3 (usehbn-phago)
