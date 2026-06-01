---
titulo: Gate D3 — V2 Persistencia Painel
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Gate D3 — V2 Persistencia Painel

## Criterio

Executar no workbook apos import e compile:

```vb
TV2_RunPersistenciaPainel
```

Resultado esperado:

```text
OK=2 | FALHA=0 | MANUAL=0
```

## O Que a Suite Valida

- `Configuracao_Inicial` expoe `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`, `PR_Val_OS`, `TP_Valor` e `TxtMesesSuspensao` em runtime.
- A persistencia do painel grava `COL_CFG_NOTA_MINIMA`, `COL_CFG_MAX_STRIKES`, `COL_CFG_DIAS_SUSPENSAO_STRIKE`, `COL_CFG_PRAZO_PREOS`, `COL_CFG_MAX_RECUSAS` e `COL_CFG_MESES_SUSPENSAO`.
- Os valores originais de `CONFIG` sao restaurados ao final da suite.

## Resultado Humano

Executado por Mauricio no workbook em 2026-05-31 16:49.

```text
TV2_RunPersistenciaPainel
OK=2 | FALHA=0 | MANUAL=0
CSV de falhas: Nao exportado
```

## Status

PASS.
