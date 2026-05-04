---
titulo: 47 — Transição chat novo Opus 4.7 (2026-05-03 madrugada)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada; rc2 depende de Onda 17 fechar)
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessão encerrando
licenca-target: TPGL-v1.1
---

# 47. Transição chat novo Opus 4.7 — Onda 17 in-progress

> **Atualização 2026-05-03 18:35 BRT (chat 2 Opus 4.7 encerrando)**:
> Sessão chat 2 entregou MD-17.1.c real + MD-17.1.d.I/II/III com Quarteto
> APROVADO em `V12-202-Z003-onda17-md1d3`. Idempotência empírica
> confirmada + visibility funcionando + UX corrigida. 6 lições novas
> oficializadas em PHAGOCYTOSIS (L22-L27 + M15-M19). Continuação em
> sessão chat 3 (recomendado: Antigravity com Claude Code via VS Code).
> Handoff completo em
> [`49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md`](49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md).

## TL;DR

Sessão Claude Opus 4.7 Cowork iniciada em 2026-05-03 0:30 BRT está
encerrando às ~04:30 BRT após ~4h de execução com sinais de fadiga de
contexto. Quarteto VR_20260503_031425 APROVADO em
`V12-202-Z003-onda17-md1b-fix2` (sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0`,
tempo baseline 14m41s). MD-17.0/17.1.a/17.1.b fechadas; MD-17.1.c
tentada (parcial) e revertida. Próxima sessão Opus 4.7 abre com este
documento + prompt para retomar MD-17.1.c em diante.

## Estado canônico atual (validado)

| Campo | Valor |
|---|---|
| Workbook ancora estável | `V12-202-Z003-onda17-md1b-fix2` |
| Build label | `f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida) |
| Validação canônica | `VR_20260503_031425` Quarteto APROVADO |
| Sintaxe Quarteto | `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=1 separado em E2E) |
| Tempo baseline Quarteto | **14m 41s 91cs** — referência para MD-17.1.d.I |
| `src/vba/` ↔ `local-ai/vba_import/` | Sincronizados (M11) — 19+ .bas + 13 .frm + 13 .frx + 4 .code-only.txt revertidos para fix2 |
| Bastão Frente 1 | LIVRE — aguarda nova sessão Opus 4.7 |

## Microdeltas Onda 17 — status final desta sessão

| MD | Status | VR / Build label |
|---|---|---|
| **17.0** | ✅ Fechada | Readback 0013 gravado |
| **17.1.a** | ✅ Fechada | `VR_20260503_010329` / `ONDA17.MD1A-fixture-factory-namespacing` |
| **17.1.b** | ✅ Fechada | `VR_20260503_031425` / `ONDA17.MD1B-fix2-cenarios-aplicados` (após fix1+fix2) |
| **17.1.c-pre** | ❌ Revertida | Tentativa de regenerar 4 `.code-only.txt`. V3 `cm.AddFromString` falhou Err=50132 em Reativa_Entidade. Causa raiz não isolada. Reversão executada. |
| **17.1.c real** | ⏸ Pendente | Decisões já tomadas: Q-MD17.1.c.1=B, Q-MD17.1.c.2=A, Q-MD17.1.c.3=B → revisada para γ tolerante após M15 |
| 17.1.d.I | ⏸ Pendente | Performance γ — alvo Quarteto <10min |
| 17.1.d.II | ⏸ Pendente | Visibility α — status bar rica |
| 17.1.e | ⏸ Pendente | Limpeza C3 (smoke/stress assistido + V1 dialog) |
| 17.2 | ⏸ Pendente | TV2_RunIntegridadeBase + RPT_BUGS_CONHECIDOS |
| 17.3 | ⏸ Pendente | CT_ValidarRelease_QuintetoMinimo + bump TEST_KEY |
| 17.4 | ⏸ Pendente | Validação Quinteto + Quarteto |
| 17.5 | ⏸ Pendente | rc2 bump + CHANGELOG + L21+M12+M13+M14+M15 + ERP + fechamento |

## Lições destiladas nesta sessão (a oficializar em PHAGOCYTOSIS na MD-17.5)

| ID | Tema | Onde está documentada |
|---|---|---|
| **L21** | Helpers VBA antigos com coerção via `Val()` invalidam convenções alfanuméricas posteriores (causa raiz fix1 do MD-17.1.b) | `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (oficial) |
| **M12** | Smoke testes em janela Imediato sem assert mascaram bug latente | `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (oficial) |
| **M13** | Janela Imediato é runtime global; helpers Private de módulo são invisíveis | `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (oficial) |
| **M14** | Plano de fix em onda multi-microdelta deve cobrir TODAS as opções de rollback | `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (oficial) + `auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md` |
| **M15** | V3 `cm.AddFromString` pode falhar com Err=50132 mesmo após `IV3_LimparAtributosCodeOnly`; causa exata não isolada nesta sessão | Candidata; será destilada na MD-17.5 |

## Débitos abertos

| ID | Descrição | Resolução prevista |
|---|---|---|
| **DT-17-REATIV-STRIKES** | ContarStrikesPorEmpresa sem janela temporal pós-reativação. CS_E2E_REATIV2STRIKES AMARELO em V2_E2E_STRIKES | Onda 18 (Opção B: `ContarStrikesParaPunicao` + `COL_EMP_DT_ULT_REATIV`). Spec completa em `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md` |
| **Drift M9 cosmético** | 4 `.code-only.txt` divergem do `.frm` (3 comentários extras + capitalização Cont/cont em 2; trailing whitespace em 2) | MD-17.1.c real usará comparação tolerante (γ) em V4. Onda 18+ pode regenerar com mais cuidado |

## Decisões Q-MD17.1.c já tomadas (validar com operador no novo chat)

| # | Pergunta | Decisão |
|---|---|---|
| Q-MD17.1.c.1 | V5 (controles do designer via VBE Extensibility) | **B — sempre obrigatório**; cenário falha se Trust Center desabilitado |
| Q-MD17.1.c.2 | Lista de helpers UI canônicos esperados | **A — manter exato** (qualquer remoção dispara alerta) |
| Q-MD17.1.c.3 | Comparação `.frm` ↔ `.code-only.txt` | **B revisada para γ tolerante** após M15: ignorar comentários `'`, trailing whitespace, e diferenças case-insensitive |

## Por que esta transição é necessária (transparência)

Sinais empíricos de fadiga de contexto após ~4h de sessão:

1. **Densidade alta de erros recentes** (4 lições destiladas em poucas horas)
2. **Custo cumulativo do operador**: ~3h de madrugada por causa de rounds extras (fix1+fix2 da MD-17.1.b + MICRO18-pre revertido)
3. **MDs futuras complexas** (γ refatoração + visibility + Onda 18 crítica)
4. **Sinalização explícita do operador**: "vamos acelerar agora"
5. **Decisão acordada**: encerrar com checkpoint estável + handoff para novo chat Opus 4.7

## Próximos passos no novo chat

1. Nova sessão Opus 4.7 lê este documento + Tier 1 + Tier 2 (definidos no prompt)
2. Confirma checkpoint atual (`V12-202-Z003-onda17-md1b-fix2`)
3. Hearback Q1 com operador (5 perguntas)
4. Retoma MD-17.1.c real com γ tolerante

## Documentos relacionados

- [`.hbn/readbacks/0013-onda17-test-first.json`](../../.hbn/readbacks/0013-onda17-test-first.json)
- [`auditoria/00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md`](43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](44_DEBITO_DT_17_REATIV_STRIKES.md)
- [`auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md`](45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- 5 procedimentos em [`auditoria/03_ondas/onda_17_test_first/`](../03_ondas/onda_17_test_first/) (01 a 05)

## Versão

- v1.0 — 2026-05-03 — encerramento de sessão + handoff para novo chat.
