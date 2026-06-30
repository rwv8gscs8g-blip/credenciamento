---
titulo: Radar useHBN — Camada 0
diataxis: reference
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Radar useHBN — Camada 0

Este diretório materializa a Camada 0 — Radar do useHBN. Ele registra tecnologias citadas no ecossistema Credenciamento/useHBN antes de qualquer decisão de fagocitose operacional.

O radar existe para separar observação, análise e decisão. Uma tecnologia pode estar apenas em `in-radar`, avançar para `under-analysis`, ter convergência mapeada, virar `candidate`, entrar como `phagocytosed` ou ser arquivada.

## Arquivos

| Arquivo | Função |
|---|---|
| [REGISTRY.md](./REGISTRY.md) | Índice consolidado de todas as tecnologias. |
| [CONVERGENCE-MATRIX.md](./CONVERGENCE-MATRIX.md) | Matriz princípios x tecnologias. |
| [_per-technology/](./_per-technology/) | Fichas individuais por tecnologia. |

## Schema

O schema de estados, ficha individual, registry e matriz segue [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md).

## Fonte inicial

Bootstrap executado na esteira E1 em 2026-05-02, a partir de:

- [`auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`](../../auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md)
- [`.hbn/knowledge/0005-protocolo-markers-v2.md`](../../.hbn/knowledge/0005-protocolo-markers-v2.md)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- [`usehbn/docs/INTEGRATION-VBA-IMPORTER.md`](../docs/INTEGRATION-VBA-IMPORTER.md)
- `local-ai/Time_AI/2026-05-02-V203-fechamento/102*.md` e `103*.md`
- [`AGENTS.md`](../../AGENTS.md)
