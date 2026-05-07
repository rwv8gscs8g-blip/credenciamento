---
titulo: Tecnico MICRO39-fix1 — Smoke MIG_007
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# MICRO39-fix1 — Smoke MIG_007

## 1. Falha observada

O operador importou e compilou o MICRO39. O Quinteto reprovou em
`VR_20260506_222237` com `V2_SMOKE=17/1`. O CSV
`TesteV2_SMOKE_Falhas_TV2_20260506_222947.csv` registrou `FATAL` com
`Erro 0`.

O ponto de corte do Smoke indica falha no novo bloco `MIG_007`, antes de
o cenario conseguir registrar seu assert.

## 2. Causa

O `MIG_007` provocava a regra de negocio escrevendo
`DATA_INVALIDA_MIG_007` diretamente em `EMPRESAS.DT_ULT_REATIV`. Em
workbook real, essa escrita pode falhar por protecao, validacao ou estado
da planilha antes do assert. Alem disso, o handler fatal fazia limpeza com
`On Error Resume Next` antes de preservar `Err.Number` e
`Err.Description`, por isso a falha apareceu como `Erro 0`.

## 3. Correcao

`ContarStrikesParaPunicaoResultado` ganhou parametro opcional para
validar um valor de `DT_ULT_REATIV` injetado pelo teste sem tocar a aba.
A validacao foi extraida para
`RepoAvaliacao_ValidarDtUltReativParaPunicao`, usada pelo caminho real e
pelo teste.

O `MIG_007` agora testa o mesmo contrato do contador com override
deterministico, sem mutacao direta de `EMPRESAS`.

## 4. Gate

Esperado apos importacao do `MICRO39-fix1`:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=4/0
```

