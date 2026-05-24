---
titulo: Onda 37 — Reconciliacao V5 vs src/vba
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Onda 37 — Reconciliacao V5 vs src/vba

## Objetivo

Produzir evidencia versionada da comparacao entre a anchor operacional V5 e `src/vba/`, antes de qualquer retomada funcional da V206.

## Entradas

- `src/vba/`: 66 arquivos `.bas/.frm/.frx`.
- `local-ai/incoming/V206_ANCHOR_V5_20260524/`: 64 arquivos `.bas/.frm/.frx`.

## Saidas

- `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv`.
- `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md`.

## Resultado

| Classe | Qtde |
|---|---:|
| igual | 8 |
| drift_export_benigno | 28 |
| diferenca_funcional | 28 |
| ausente_no_workbook | 0 |
| obsoleto_no_repo | 1 |
| precisa_decisao_humana | 1 |

## Decisoes bloqueadas

A Onda 37 nao decide remocao, reincorporacao ou overwrite de nenhum arquivo. O unico item marcado como `precisa_decisao_humana` e `Emergencia_CNAE.bas`.

## Invariantes conferidos

- `src/vba/` nao foi editado.
- `local-ai/vba_import/` nao foi editado.
- `local-ai/incoming/` nao foi editado.
- Workbook V5 nao foi tocado.
