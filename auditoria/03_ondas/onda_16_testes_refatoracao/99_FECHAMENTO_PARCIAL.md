---
titulo: 99 - Fechamento PARCIAL Onda 16 — entregas + cancelamentos + lições
diataxis: status
hbn-track: safe_track
hbn-status: superseded
audiencia: ambos
versao-sistema: V12.0.0203-rc1 (rc1 publicada; rc2 não vai sair na Onda 16)
data: 2026-05-03
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
licenca-target: TPGL-v1.1 (Credenciamento)
---

# Fechamento PARCIAL Onda 16 — Refatoração testes

## TL;DR

Onda 16 fecha PARCIALMENTE em 2026-05-03 com 3 microdeltas entregues
(MD-16.1, 16.2, 16.3-fix1) que **estão importados no workbook
estável `V12-202-Z003`**, e 3 microdeltas cancelados (MD-16.4,
16.5-documental, 16.6 com tentativas falhas). Quarteto Mínimo
verde sobre o estado restaurado. **Não haverá tag rc2** desta onda
— evolução para rc2 vai depender da Onda 17 (cobertura UI).

## Microdeltas — status final

| MD | Tema | Status | Workbook |
|---|---|---|---|
| **16.1** | Texto Central V12 + V2 com Quarteto destacado | ✅ APROVADO | importado |
| **16.2** | Coluna `DURACAO_MS` em HISTORICO_QA_V2 + threshold em CONFIG | ✅ APROVADO | importado |
| **16.3 fix1** | Aba `EVOLUCAO_TESTES` + sparkline + opção `[21]` + InputBox refatorado para variável `prompt` | ✅ APROVADO | importado |
| 16.4 | `Util_PDF.bas` + CNPJ no nome + suite determinismo + opção `[22]` | ❌ Descartado | NÃO importado (em quarentena) |
| 16.4 fix1 | Hash overflow `Long`→`Double` | ❌ Descartado | NÃO importado |
| 16.5 | Inventário de filtros (documental) | ⚠️ Insumo Onda 17 | n/a |
| 16.6.1 | Refatoração Reativa_Entidade.frm sem heurística | ❌ Cancelado | revertido |
| 16.6.2 | Refatoração Reativa_Empresa.frm sem heurística | ❌ Cancelado | revertido |
| 16.6 fix1 (MICRO19) | Rollback Reativa_Entidade + Reativa_Empresa | ❌ Incompleto | parcialmente importado |
| 16.6 fix4 (MICRO20) | Sincronizar `.code-only.txt` Reativa_Empresa | ❌ Causou regressão | gerou crash |

## Estado final do workbook estável

| Campo | Valor |
|---|---|
| Workbook ancora | `V12-202-Z003/02_05_2026 20_43_09PlanilhaCredenciamento-Homologacao-V3.xlsm` |
| Build label | `f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida) |
| `APP_RELEASE_STATUS` | `RELEASE_CANDIDATE` |
| Validação | `VR_20260502_222849` — Quarteto APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |

## Causa raiz do cancelamento de MD-16.6

Sequência de imports iterativos (4× no mesmo form em ~3h) corrompeu
estado interno do workbook. Sintomas:

- Lista de Reativa_Entidade abria vazia mesmo após inativar entidades
- Lista de Reativa_Empresa abria com erro "Objeto chamado foi
  desconectado de seus clientes"
- Excel fechava ao compilar
- Excel fechava ao clicar em "Inativar Entidade"

Recuperação só foi possível restaurando backup do operador
(`V12-202-Z003`).

## Bug pré-existente descoberto (input para Onda 17)

Durante a recuperação, ao tentar reativar Entidade 2, ela apareceu
**simultaneamente em ENTIDADE (ativa) e em ENTIDADE_INATIVOS**. O
helper `UI_EntidadeInativasTemConflito` (em `Reativa_Entidade.frm`)
detecta corretamente e bloqueia a reativação com mensagem "linhas
conflitantes". Mas o **bug raiz** é como a entidade chegou em ambas
as abas. É um caso de **integridade transacional violada** que vira
fixture de teste em Onda 17.

## Lições destiladas (registradas em PHAGOCYTOSIS L19+L20+M8+M9+M10+M11)

- **L19** — InputBox/MsgBox grandes precisam de variável `prompt`
  acumulada (limite ~25 line continuations).
- **L20** — Hash determinístico em VBA: `Double` + módulo manual,
  nunca `Long` (overflow silenciado mascara diagnóstico).
- **M8** — Suite de gate de release deve cobrir TODA superfície que
  pode regredir, incluindo UI (Quarteto não cobriu filtros).
- **M9** — Forms VBA têm DOIS espelhos (`.frm` e `.code-only.txt`)
  e dessincronia faz V3 importar versão errada.
- **M10** — Cap 1 import por form por dia com gate verde entre cada.
- **M11** — Primazia documentada (`src/vba/` fonte de verdade,
  `local-ai/vba_import/` espelho) deve ser honrada mesmo sob
  iteração rápida.

## Continuidade — Onda 17 abre

A Onda 17 vai **PRIMEIRO construir cobertura UI** (`TV2_RunUiFiltros`
+ Quinteto release gate + suite de integridade base) **ANTES de
qualquer mexida em forms**. Sem cobertura, qualquer mudança volta a
regredir silenciosamente. Plano detalhado em
[`../../00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md`](../../00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md).

## Quarentena

Artefatos descartados foram movidos (não deletados) para:

```
auditoria/04_evidencias/V12.0.0203/_quarentena_pos_md16_3_2026_05_03/
├── canonico/        (Util_PDF.bas, Util_Empresa.bas + prefixados)
├── manifestos/      (MICRO16, 16-fix1, 17, 18, 19, 20)
└── procedimentos/   (MD16_3_fix1, MD16_4 procedimentos de import)
```

Operador pode resgatar quando Onda 17 estiver verde.

## Versão

- v1.0 — 2026-05-03 — fechamento parcial inicial.
