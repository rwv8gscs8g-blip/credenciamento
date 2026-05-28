---
titulo: Bypass HBN — GATE-A4 RVS evidencias AAX drift
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-28
---

# Bypass HBN — GATE-A4 RVS evidencias AAX drift

## Motivo

O commit deste readback registra apenas evidencias e documentacao do GATE-A4 Fase 1/Fase 2. O working tree continua com `local-ai/vba_import/001-modulo/AAX-App_Release.bas` modificado por BUMP operacional do Importador V3, mas esse arquivo nao deve ser staged neste commit.

## Escopo do bypass

Permitir commit documental/evidencial com `[bypass-hbn-guards]` sem incluir `AAX-App_Release.bas`.

## Evidencia

Os CSVs RVS reais sao:

- `VR_20260528_063131` — `35217c0+ONDA38.2.3-A4-F1-MODULOS` — APROVADO
- `VR_20260528_090314` — `35217c0+ONDA38.2.3-A4-F2-FORMS` — APROVADO
