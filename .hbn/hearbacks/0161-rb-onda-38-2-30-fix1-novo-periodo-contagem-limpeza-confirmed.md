---
titulo: Hearback 0161 — fix1 Novo Periodo limpeza e contagem
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Hearback 0161 — confirmado

Mauricio aprovou o readback
`0161-rb-onda-38-2-30-fix1-novo-periodo-contagem-limpeza`.

Autorizado implementar o fix1 para corrigir o falso negativo de
`CFGCSV_06_NOVO_PERIODO_COPIA_LIMPEZA`, ajustando limpeza e contagem
pos-Novo Periodo sem VCR, sem designer/.frx e sem tocar arquivos proibidos.

O gate esperado apos import/compile e repetir:

```vb
TV2_RunConfigCenariosNovoPeriodo
```

Resultado esperado:

```text
OK=7 | FALHA=0 | MANUAL=0
```
