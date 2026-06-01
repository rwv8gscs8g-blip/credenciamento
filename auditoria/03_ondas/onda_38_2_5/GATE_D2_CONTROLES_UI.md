---
titulo: Gate D2 — Controles Canonicos da UI
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Gate D2 — Controles Canonicos da UI

## Criterio

`Configuracao_Inicial.frx` precisa conter os TextBoxes canonicos de regras de negocio:

- `TxtNotaCorte`
- `TxtMaxStrikes`
- `TxtDiasSuspensao`
- `PR_Val_OS`
- `TP_Valor`
- `TxtMesesSuspensao`

## Evidencia Local

O export humano em `local-ai/incoming/vba-forms/Configuracao_Inicial.frx` tem timestamp `2026-05-31 15:29` e o inventario por `strings` encontrou os seis nomes.

O binario foi promovido para:

- `src/vba/Configuracao_Inicial.frx`
- `local-ai/vba_import/002-formularios/Configuracao_Inicial.frx`

Hash SHA-256 do binario promovido:

```text
a7f1760d1b21f98b74954d70065ea8310a8f0783ab38eb1194062e486d67f025
```

## Status

Pre-import local: PASS.

Confirmacao visual no workbook pos-import: pendente do operador.
