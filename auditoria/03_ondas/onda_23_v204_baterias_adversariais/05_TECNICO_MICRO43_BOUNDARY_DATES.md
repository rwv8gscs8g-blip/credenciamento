---
titulo: Tecnico MICRO43 - Suite Boundary Dates
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-07
---

# MICRO43 - Suite Boundary Dates

## 1. Objetivo

Ampliar a cobertura adversarial da Onda 23 com uma suite autonoma para
bordas de data em APIs publicas ja existentes, sem alterar regra de
producao nem gravar abas operacionais.

## 2. Entrega

`TV2_RunBoundary_Dates` adiciona 9 cenarios:

| Cenario | Cobertura |
|---|---|
| `DATE_BND_001_OS_DATA_VAZIA_DEFAULT` | data/empenho vazios geram defaults seguros |
| `DATE_BND_002_OS_HOJE_PERMITIDO` | data prevista igual a hoje e aceita |
| `DATE_BND_003_OS_ONTEM_REJEITADO` | data prevista anterior a hoje e bloqueada |
| `DATE_BND_004_OS_31_FEV_REJEITADO` | data inexistente nao sofre rollover silencioso |
| `DATE_BND_005_OS_BISSEXTO_VALIDO` | 29/02 em ano bissexto e aceito |
| `DATE_BND_006_OS_BISSEXTO_INVALIDO` | 29/02 em ano nao bissexto e rejeitado |
| `DATE_BND_007_OS_ANO_CURTO_2030` | ano curto segue contrato atual de normalizacao para 20xx |
| `DATE_BND_008_AVAL_DATA_EQUIVALENTE_SEM_MUDANCA` | data equivalente nao gera mudanca falsa na avaliacao |
| `DATE_BND_009_AVAL_DATA_DIFERENTE_COM_MUDANCA` | data diferente gera resumo de mudanca rastreavel |

## 3. Escopo

A suite chama apenas:

- `MontarParametrosEmissaoOS`
- `DescreverMudancasAvaliacao`
- infraestrutura V2 de resultado/auditoria de testes

Nao cria empresa, entidade, Pre-OS, OS, avaliacao ou transacao de
producao.

## 4. Gate

Validacao nova:

```text
TV2_RunBoundary_Dates False -> BOUNDARY_DATES=9/0/0
```

Quinteto esperado sem mudanca:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0
```

## 5. Risco residual

Este microdelta documenta o contrato atual de anos curtos (`30` vira
`2030`). Se o produto decidir exigir quatro digitos obrigatorios em
V204 final, esse comportamento deve virar uma mudanca explicita de regra
com novo teste de rejeicao.
