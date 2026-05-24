---
titulo: Índice de Evidências V12.0.0206
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Índice de Evidências V12.0.0206

Esta pasta é a área canônica de evidências da V12.0.0206.

A V12.0.0206 ainda não possui gate próprio executado. A assinatura de não
regressão herdada da V12.0.0205 permanece:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Estrutura

```text
auditoria/evidencias/V12.0.0206/
  INDEX.md
  MANIFEST.md
  MANIFESTO.csv
  csv/
  pdf/
  prints/
  intermediarios/
```

## Estado Atual

| Artefato | Papel | Status | Observação |
|---|---|---|---|
| `MANIFEST.md` | manifesto humano | ATIVO | Sem evidência V206 própria ainda |
| `MANIFESTO.csv` | espelho tabular | ATIVO | Cabeçalho preparado para automação |

## Convenções

- CSV final: `csv/ValidacaoReleaseRVS_V12_0_0206_<VALIDATION_ID>.csv`
- PDF automático: `pdf/ValidacaoReleaseRVS_V12_0_0206_<VALIDATION_ID>.pdf`
- Prints: `prints/Assinatura_RVS_Aprovada_<timestamp>.png`

## Regras V206

- O teste de PDF será isolado e complementar.
- O PDF não entra nas seis baterias do RVS.
- O RVS não recebe contadores novos na V12.0.0206.
- Hashes de novos artefatos devem ser registrados em `MANIFEST.md` e
  `MANIFESTO.csv` no mesmo delta.
