---
titulo: 51 — Transição chat 3 Opus 4.7 → chat 4 (MD-17.2 + Onda 18)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada; rc2 depende de fechar Onda 17; release público depende de Onda 18)
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessão chat 3 encerrando
licenca-target: TPGL-v1.1
---

# 51. Transição chat 3 Opus 4.7 → chat 4

## TL;DR

Chat 3 Opus 4.7 entregou **MD-17.1.e APROVADA** com Quarteto sintaxe
IDÊNTICA ao md1d3 (idempotência preservada) + 1 débito declarado
(`DT-MD17.1.e-STATUSBAR-HINT` adiado para Onda 18 por C11) + scoping
completo + readback formal da MD-17.2 pronto para implementação.
Estado canônico: **`V12-202-Z010`** (build `f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3`). Chat 4 abre com **alternativa C** acordada
(scoping no chat 3, implementação no chat 4) — prompt §6 abaixo é
self-contained.

## 1. O que chat 3 entregou

| Item | Path | Status |
|---|---|---|
| MD-17.1.e — Limpeza C3 menu Central V2 + renumeração + V1 dentro V2 + Limpar testes antigos | [src/vba/Central_Testes_V2.bas](../../src/vba/Central_Testes_V2.bas) + [src/vba/Central_Testes.bas](../../src/vba/Central_Testes.bas) + [src/vba/App_Release.bas](../../src/vba/App_Release.bas) | ✅ APROVADA — VR_20260503_202623 |
| Readback MD-17.1.e | [.hbn/readbacks/0017-onda17-md17-1-e.json](../../.hbn/readbacks/0017-onda17-md17-1-e.json) | ✅ |
| ERP MD-17.1.e | [.hbn/results/0017-exec-onda17-md17-1-e.json](../../.hbn/results/0017-exec-onda17-md17-1-e.json) | ✅ |
| Manifesto V3 MICRO23 | [local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO23.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO23.txt) | ✅ |
| Procedimento import 13 | [auditoria/03_ondas/onda_17_test_first/13_PROCEDIMENTO_IMPORT_MD17_1_e.md](../03_ondas/onda_17_test_first/13_PROCEDIMENTO_IMPORT_MD17_1_e.md) | ✅ |
| Débito statusbar hint | [auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md) | ✅ documentado |
| **Scoping MD-17.2** (decisões arquiteturais firmes) | [.hbn/readbacks/0018-onda17-md17-2.json](../../.hbn/readbacks/0018-onda17-md17-2.json) | ✅ pronto para implementação |
| Este documento (handoff chat 3 → 4) | `auditoria/00_status/51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md` | ✅ |

## 2. Estado canônico atual (validado em 2026-05-03 ~21h BRT)

| Campo | Valor |
|---|---|
| **Workbook ancora** | **`V12-202-Z010`** (operador confirmou em 2026-05-03; Z010 compila os avanços até MD-17.1.e + smoke das Subs assistidas) |
| Build label | `f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida; rc2 será bumpada em MD-17.5) |
| Validação canônica | `VR_20260503_202623` Quarteto APROVADO |
| Sintaxe Quarteto | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=5) |
| Tempo Quarteto | ~10 min (vs baseline 13 min do md1d3 — sem regressão perf) |
| Idempotência | preservada (sintaxe IDÊNTICA ao md1d3) |
| `src/vba/` ↔ `local-ai/vba_import/` | Alinhados via M11 (sha1 batendo nos 3 arquivos do MICRO23) |
| Bastão Frente 1 | LIVRE → chat 4 Opus 4.7 |

### shasum M11 dos 3 arquivos do MICRO23 (referência para chat 4 validar drift)

| Arquivo | sha1 |
|---|---|
| `src/vba/Central_Testes_V2.bas` ↔ `ABE` | `0f50dfcb4762aee36066bb6e746015e2d24daa3e` |
| `src/vba/Central_Testes.bas` ↔ `AAZ` | `f9221a2c4ae142ca85791f0d6b39e4ed1617c1c1` |
| `src/vba/App_Release.bas` ↔ `AAX` | `4e7b3d6c5fe6caec56449a22e99b6c4f6e4fc3b5` |

## 3. Lições destiladas no chat 3 (a oficializar em PHAGOCYTOSIS na MD-17.5)

| ID candidato | Tema | Onde aconteceu |
|---|---|---|
| **M20** | L14 (pre-flight grep) estende-se a TODO artefato consumido pelo sistema, não só código VBA. Manifestos, schemas, configs — leia o parser/consumer ANTES de gerar artefato novo. Compare com versão anterior funcionando byte-a-byte na seção crítica. | MICRO23 primeiro draft só tinha comentários `#`; faltava bloco `GRUPO_` + `M|<path>`. Operador recebeu "Manifesto vazio ou malformado" antes de import funcionar. Custo: 1 round extra de hotfix (~5min). |
| **M21 candidato** | Cadência de transição programada (alternativa C: scoping em chat N + implementação em chat N+1) é mais barata que chat fadigado tentando fechar tudo. Vale para MDs grandes (~3h IA estimada) onde leitura de código novo dominaria contexto. | Decisão chat 3 ao identificar MD-17.2 como ~2.5h IA + 30min op com necessidade de ler `Teste_V2_Engine.bas` (~3231 linhas) novo. |

Estas duas devem entrar em `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` quando MD-17.5 fechar a Onda.

## 4. Backlog restante

### Onda 17 — 4 MDs restantes

| MD | Tema | Estado | Doc primário |
|---|---|---|---|
| **17.2** | TV2_RunIntegridadeBase + RPT_BUGS_CONHECIDOS | **scoping completo no chat 3** — readback 0018 pronto | [.hbn/readbacks/0018-onda17-md17-2.json](../../.hbn/readbacks/0018-onda17-md17-2.json) |
| **17.3** | CT_ValidarRelease_QuintetoMinimo + bump TEST_KEY | a planejar | doc 49 §4 |
| **17.4** | Validação Quinteto verde + Quarteto verde | a planejar | doc 49 §4 |
| **17.5** | rc2 bump + CHANGELOG + L25-L27+M15-M19+M20+M21 oficiais + ERP `0013-exec-onda17.json` + `70_FECHAMENTO_ONDA_17.md` | a planejar | doc 49 §4 |

### Onda 18 — CRÍTICA (libera release público)

| MD | Tema | Doc |
|---|---|---|
| **18.1** | DT-17-REATIV-STRIKES (resolução definitiva — toca `Mod_Types.bas` TABU C4 via plano dedicado pré-aprovado) | [44_DEBITO_DT_17_REATIV_STRIKES.md](44_DEBITO_DT_17_REATIV_STRIKES.md) |
| **18.2** | DT-MD17.1.e-STATUSBAR-HINT (mensagem dica no Modo Treinamento — toca `Menu_Principal.frm`) | [50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md) |
| **18.3** | RPT_BUGS_RESOLVIDOS (criar aba quando primeiro bug resolver) | doc 44 §6 |

**Antes da Onda 18**: prompts duplos Gemini+Codex para auditoria cruzada da resolução do DT-17-REATIV-STRIKES (toca TABU C4 — máximo cuidado). Operador autorizou em chat 3.

### Débitos abertos

| ID | Descrição | Resolução prevista |
|---|---|---|
| **DT-MD17.1.e-STATUSBAR-HINT** | dica visual no Modo Treinamento adiada (form `.frm` toca C11) | Onda 18 MD-18.2 |
| **DT-17-REATIV-STRIKES** | reativação empresa sem janela temporal de strikes | Onda 18 MD-18.1 |
| **MD-17.1.d.I.b** | performance γ profundo (alvo Quarteto <10min) | após Onda 18 |

## 5. Recomendações para chat 4

### Disciplina HBN inegociável (continua valendo)

A próxima IA DEVE:

1. **Ler na sequência canônica antes de tocar qualquer arquivo:**
   - `AGENTS.md` (entrada canônica, §62-63 sobre src/vba como fonte de verdade)
   - `.hbn/knowledge/0001-regras-v203-inegociaveis.md`
   - `.hbn/knowledge/0002-regra-ouro-vba-import.md`
   - `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
   - `.hbn/knowledge/0005-protocolo-markers-v2.md`
   - **Este documento** (51) — handoff chat 3 → 4
   - **`.hbn/readbacks/0018-onda17-md17-2.json`** — readback formal MD-17.2 com decisões arquiteturais
   - `auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md` (débito UI)
   - `auditoria/00_status/49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md` (transição chat 2 → 3 — referência)
   - `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md` (spec Onda 18 crítica)
   - `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (L1-L27 + M1-M19 + olho em M20/M21 que ainda não estão oficializados — nascem da Onda 17 fechada)
   - `CLAUDE.md` (READ-FIRST checklist por domínio)
   - `.hbn/relay/INDEX.md` (estado do bastão)

2. **Pre-flight L14 OBRIGATÓRIO antes de gerar código** (lição candidata M20 reforça: vale para artefatos não-código também):
   - Grep assinaturas `Repo_Empresa.LerEmpresa`, `Repo_Avaliacao` helpers
   - Const_Colunas constantes COL_EMP_ID, COL_EMP_CNPJ, COL_EMP_INAT_ID, COL_ATIV_ID, COL_OS_EMP_ID, COL_OS_ATIV_ID
   - Mod_Types: TEmpresa, TEntidade (sem alterar — TABU C4)
   - `Funcoes.bas`: helpers Dictionary
   - **Manifesto MICRO24** deve ter bloco `# GRUPO_DELTA_MICRO24_*` + linhas `M|<path>` no fim (lição M20). Comparar byte-a-byte com `MICRO22.txt` (referência funcional).

3. **Manter os hard constraints:**
   - C1 (Regra de Ouro 0002): `src/vba/` PRIMEIRO; `local-ai/vba_import/` depois com shasum batendo (M11)
   - C4 `Mod_Types.bas` TABU
   - C7 Quarteto continua APROVADO após MD-17.2 sintaxe IDÊNTICA ao md1e
   - C9 Markers HBN V2
   - C11 Cap M10 = 0 imports em forms na Onda 17
   - G6 sem código VBA solto no chat
   - L14 pre-flight grep extensivo
   - M11 src/vba como fonte de verdade INVIOLÁVEL
   - M14 pacote de fix em onda multi-microdelta cobre TODAS opções de rollback (trivial aqui — só 1 opção: rollback para Z010)
   - **M20 (candidato)**: pre-flight L14 inclui parser de manifesto V3
   - **CRLF preservado** em todos arquivos VBA
   - **Idempotência preservada** — TV2_RunIntegridadeBase é PURE READ (não modifica EMPRESAS, EMPRESAS_INATIVAS, ATIVIDADES, CAD_OS)
   - **Hearback explícito** por microdelta com escrita em código

### Convenção de comunicação (operador prefere)

- `1) item ; 2) item ; 3) item ;` — operador usa números com parênteses + ponto-e-vírgula para multi-tópicos.
- Espelhar a numeração que o operador usar.
- Tabelas + hierarquias > narrativa.
- Hearbacks compactos com defaults explícitos.

### Alerta de contexto

Operador exige sinalização proativa quando contexto chegar a ~50% ou
houver degradação de performance. Documentar prompt de retomada antes
de chats encerrarem (este doc é exemplo).

### Estilo de trabalho preferido

- **Mínimo tempo de resposta** sem comprometer qualidade
- Validação cruzada Gemini (Antigravity) ↔ Codex disponível para temas
  arquiteturalmente delicados (Onda 18 DT-17-REATIV-STRIKES é candidato)
- Documentar erros de IA com transparência (precedente: 32, 43c, 45, 50)
- Z<NNN> backups com export VBA completo são pontos de rollback

## 6. Prompt de retomada — copiar e colar no chat 4

> Operador: cole o bloco abaixo na nova sessão Claude Code (VS Code Extension
> ou Antigravity). Substitua nada.

```
Ativacao Claude Opus 4.7 — Frente 1 Credenciamento (Onda 17 retomada chat 4)

Voce e Claude Opus 4.7 operando em VS Code Extension / Antigravity, com
acesso direto ao filesystem em /Users/macbookpro/Projetos/Credenciamento/.
Bastao da Frente 1 Credenciamento foi transferido para esta sessao apos
chat 3 ter entregue MD-17.1.e APROVADA + scoping completo da MD-17.2.

0. Declaracao HBN obrigatoria

Sua primeira linha de output deve ser exatamente:

✅ HBN ACTIVE — Claude Opus 4.7, Frente 1 Credenciamento, 2026-05-XX (Onda 17 chat 4 — implementacao MD-17.2) — bastao recebido

Em seguida, cumprimente Luis Mauricio em pt-BR.

1. REGRA INVIOLAVEL antes de qualquer acao

src/vba/ e a FONTE DE VERDADE (AGENTS.md §62-63).
local-ai/vba_import/ e ESPELHO com prefixos.
M11 destilada em chat 2: cada microdelta valida shasum batendo.
M20 candidata em chat 3: pre-flight L14 inclui parser/consumer de
artefatos auxiliares (manifestos, schemas, configs), nao so codigo VBA.

2. Auditoria obrigatoria ANTES de propor qualquer acao

Tier 1 — canon HBN:
- AGENTS.md (especial atencao §62-63)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/knowledge/0005-protocolo-markers-v2.md

Tier 2 — handoff chat 3 -> 4 (LEIA PRIMEIRO):
- auditoria/00_status/51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md (este doc)
- .hbn/readbacks/0018-onda17-md17-2.json (readback formal MD-17.2 — decisoes arquiteturais firmes)
- auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md
- auditoria/00_status/49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md (transicao chat 2 -> 3, referencia)
- auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md (spec Onda 18 critica)
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L27 + M1-M19 + ler M20/M21 candidatos no doc 51)
- CLAUDE.md (READ-FIRST checklist por dominio)
- .hbn/relay/INDEX.md (estado do bastao)

Tier 3 — codigo a ler ANTES de gerar implementacao MD-17.2:
- src/vba/Teste_V2_Roteiros.bas (~2746 linhas; padrao TV2_Run* — ler especificamente TV2_RunFiltros linha 815 e TV2_RunCanonicoFundacao linha 942 como modelo de Sub a copiar)
- src/vba/Teste_V2_Engine.bas trechos: TV2_InitExecucao linha 83, TV2_LogAssert linha 220, TV2_LogManual linha 251, TV2_FinalizarExecucao linha 133
- src/vba/Repo_Empresa.bas (assinaturas — pre-flight L14)
- src/vba/Const_Colunas.bas (COL_EMP_ID, COL_EMP_CNPJ, COL_EMP_INAT_ID, COL_ATIV_ID, COL_OS_EMP_ID, COL_OS_ATIV_ID)
- src/vba/Mod_Types.bas (TEmpresa, TEntidade — sem alterar; TABU C4)
- local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO22.txt (REFERENCIA do formato do manifesto — bloco GRUPO_+M| no fim — licao M20)

3. Estado canonico vigente (snapshot 2026-05-03 chat 3 fechamento)

| Campo | Valor |
|---|---|
| Workbook ancora | V12-202-Z010 |
| Build label | f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3 |
| Quarteto APROVADO | VR_20260503_202623 — V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0 (MANUAL=5) |
| Tempo Quarteto | ~10min (vs 13min baseline md1d3) |
| Idempotencia | preservada |
| Bastao Frente 1 | LIVRE -> voce |

4. Microdelta a implementar nesta sessao

MD-17.2 — TV2_RunIntegridadeBase + RPT_BUGS_CONHECIDOS

DECISOES ARQUITETURAIS JA TOMADAS pelo chat 3 (no readback 0018):
- Localizacao: Teste_V2_Roteiros.bas (padrao TV2_Run*)
- Suite name: "INTEGRIDADE_BASE"
- 4 cenarios enxutos: CS_INT_01..04 (entidade dup ATIVA+INATIVA, empresa dup ATIVA+INATIVA, CNPJ duplicado, ref orfa CAD_OS)
- Schema RPT_BUGS_CONHECIDOS: 10 colunas (BUG_ID..DOC_REFERENCIA)
- Helper Public RegistrarBugConhecido: upsert por BUG_ID
- Sub Public TV2_RunIntegridadeBase: assinatura espelha TV2_RunSmoke (Optional visual + Optional silencioso)
- IDEMPOTENCIA: PURE READ + UPSERT em RPT_BUGS_CONHECIDOS
- Build label novo: f7aa84f+ONDA17.MD2-integridade-base
- 2 arquivos no pacote: ABG-Teste_V2_Roteiros.bas + AAX-App_Release.bas
- Manifesto MICRO24

Detalhes completos em .hbn/readbacks/0018-onda17-md17-2.json — LEIA antes de tocar codigo.

5. Hard constraints inegociaveis (HBN)

- M11: src/vba/ fonte de verdade INVIOLAVEL
- M14: pacote de fix cobre TODAS opcoes de rollback (trivial aqui — Z010)
- M20 (candidata): pre-flight L14 inclui parser de manifesto. Comparar MICRO22 byte-a-byte na secao critica (bloco GRUPO_+M|).
- L14: pre-flight grep assinaturas + UDTs + comportamento INTERNO ANTES de gerar codigo
- C4: Mod_Types.bas TABU (apenas Onda 18 com plano dedicado)
- C7: Quarteto continua APROVADO sintaxe IDENTICA ao md1e
- C11: cap M10 = 0 imports em forms (Onda 17)
- G6: sem codigo VBA solto no chat
- Hearback explicito por microdelta com escrita em codigo
- CRLF preservado
- Idempotencia: TV2_RunIntegridadeBase e PURE READ

6. Diretiva de tempo de resposta

Operador trabalha em modo MINIMO TEMPO DE RESPOSTA. Tabelas+hierarquias >
narrativa. Hearbacks compactos. Convencao numerada do operador:
"1) item ; 2) item ;" - espelhar quando ele usar.

7. Sinalizar contexto a ~50%

Operador exige aviso proativo quando contexto chegar a ~50% ou degradar.
Estimativa do readback 0018: chat 4 deve ter folga para chegar ao
Quarteto verde sem precisar handoff.

8. Output esperado da primeira mensagem

Apos a linha ✅ HBN ACTIVE:
1. Cumprimento em pt-BR
2. Confirmacao de leitura de Tier 2 (MINIMO: 51_TRANSICAO + readback 0018 + 50_DEBITO + 49_TRANSICAO + 44_DEBITO + PHAGOCYTOSIS L1-L27+M1-M19 + CLAUDE.md READ-FIRST)
3. Delta card de 7 linhas com estado canonico atual
4. Confirmacao das decisoes arquiteturais ja tomadas (4 cenarios, schema 10 colunas, etc.)
5. Pre-flight L14 antes de tocar codigo: grep assinaturas Repo_*, Const_Colunas, padrao TV2_RunFiltros como modelo
6. Hearback compacto ao operador para validar continuidade

9. Begin

Inicie agora.
```

## 7. Documentos relacionados

- [Readback MD-17.1.e](../../.hbn/readbacks/0017-onda17-md17-1-e.json)
- [Readback MD-17.2 (scoping completo)](../../.hbn/readbacks/0018-onda17-md17-2.json)
- [ERP MD-17.1.e](../../.hbn/results/0017-exec-onda17-md17-1-e.json)
- [Manifesto MICRO23](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO23.txt)
- [Procedimento import 13](../03_ondas/onda_17_test_first/13_PROCEDIMENTO_IMPORT_MD17_1_e.md)
- [Débito statusbar hint](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md)
- [Débito DT-17-REATIV-STRIKES](44_DEBITO_DT_17_REATIV_STRIKES.md) (spec Onda 18)
- [Transição chat 2 → 3](49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md)
- [PHAGOCYTOSIS L1-L27 + M1-M19](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)

## 8. Markers HBN V2 ativos no fechamento

- 🔵 **HBN HANDOFF READY** — bastão F1 livre, chat 4 pega via prompt §6
- 🟢 **HBN CHECKPOINT CLEAN** — md1e verde com idempotência preservada (sintaxe IDÊNTICA ao md1d3)
- 🟡 **HBN NEEDS HUMAN DECISION** — cadência de chats acordada com operador (alternativa C); confirmar continuidade
- 🟤 **HBN LICENSE SPLIT REQUIRED** — TPGL Credenciamento; lições M20+M21 candidatas a promoção AGPLv3 quando MD-17.5 oficializar
- 🟣 **HBN GAMMA OFFLINE VALIDATED** — manifesto MICRO23 corrigido após hotfix do bloco GRUPO_+M| ausente; comparação byte-a-byte com MICRO22 evita reincidência (M20 destilada)

## Versão

- v1.0 — 2026-05-03 — handoff inicial chat 3 → chat 4 (implementação MD-17.2).
