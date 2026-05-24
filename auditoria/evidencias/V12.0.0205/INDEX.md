---
titulo: Índice de Evidências V12.0.0205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Índice de Evidências V12.0.0205

Esta pasta é a fonte canônica das evidências da V12.0.0205.

## Estrutura

```text
auditoria/evidencias/V12.0.0205/
  INDEX.md
  MANIFEST.md
  MANIFESTO.csv
  csv/
  pdf/
  prints/
  intermediarios/
```

## Convenções

- CSV final: `csv/ValidacaoReleaseRVS_V12_0_0205_<VALIDATION_ID>.csv`
- PDF manual: `pdf/V2_VALIDACAO_HUMANA_RVS_V12_0_0205_<VALIDATION_ID>.pdf`
- Prints: `prints/Assinatura_RVS_Aprovada_<timestamp>.png`

## Evidências Registradas

| Artefato | Papel | Status | Observação |
|---|---|---|---|
| [`csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv`](csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv) | gate final RVS pós-MICRO61 | APROVADO | Evidência final de freeze V205 |
| [`csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv`](csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv) | gate funcional RVS | APROVADO | Homologação interna V205, preservada como evidência complementar |

## Resultado do Gate RVS

| Campo | Valor |
|---|---|
| Validation ID | `VR_20260523_215637` |
| Build | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Resultado geral | `APROVADO` |
| Sintaxe | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |

## Evidências Complementares

- PDF manual da aba `VALIDACAO_RELEASE` pode ser anexado em `pdf/` antes da
  tag ou na V12.0.0206.
- Print de homologação pode ser arquivado em `prints/` como evidência humana
  complementar.
- Hashes dos artefatos manuais devem ser adicionados ao manifesto se forem
  anexados.
