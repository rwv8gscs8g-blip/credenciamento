---
titulo: 03 - Roadmap Onda 22 V204 Dados Legados
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Onda 22 V204 - Dados legados, backfill e integridade

## 1. Objetivo

Fechar os riscos de base migrada: `DT_ULT_REATIV` vazia/invalida,
referencias orfas em `CAD_OS` e bordas temporais.

## 2. Microdeltas

| MD | Mudanca | Teste/Gate |
|---|---|---|
| MD-22.1 | Backfill auditavel de `DT_ULT_REATIV` usando `AUDIT_LOG` | `CS_BACKFILL_REATIV_FROM_AUDIT` |
| MD-22.2 | `Auto_Open` apenas detecta e recomenda backfill, sem mutacao automatica destrutiva | Smoke |
| MD-22.3 | Tratar `DT_ULT_REATIV` invalida com diagnostico | `CS_REATIV_DATA_INVALIDA` |
| MD-22.4 | Fechar `INT-CAD-OS-REF-ORFA` com relatorio e saneamento controlado | IntegridadeBase sem manual |
| MD-22.5 | Bordas: data igual, anterior, posterior e futura | `TV2_RunBoundary_Dates` parcial |

## 3. Criterio de aceite

1. Base migrada nao volta a modo legado sem diagnostico.
2. Orfaos em `CAD_OS` nao ficam como bug conhecido aberto.
3. IntegridadeBase passa sem manual em base canonica.
4. Quinteto verde.
