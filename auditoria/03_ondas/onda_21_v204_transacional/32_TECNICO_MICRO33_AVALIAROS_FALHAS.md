---
titulo: 32 - Tecnico MICRO33 Onda 21 V204 AvaliarOS Falhas
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO33 - AvaliarOS Propaga Falhas

## 1. Objetivo

Fechar os debitos MD-21.2 e MD-21.3 do roadmap transacional:
`AvaliarOS` nao deve retornar sucesso operacional quando uma subrotina
critica falha depois da avaliacao ter sido persistida.

## 2. Mudancas

| Arquivo | Mudanca |
|---|---|
| `src/vba/Svc_Avaliacao.bas` | Se `Suspender` falhar apos strike punitivo, `AvaliarOS` retorna `sucesso=False`, preserva `IdGerado=OS_ID` e registra evento de falha parcial. |
| `src/vba/Svc_Avaliacao.bas` | Se `AvancarFila` falhar apos avaliacao, `AvaliarOS` retorna `sucesso=False`, preserva `IdGerado=OS_ID` e registra evento de falha parcial. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.2-3-avaliar-os-falhas`. |

## 3. Politica adotada

A MICRO33 nao tenta rollback da avaliacao ja persistida. Essa decisao reduz
risco de corromper `CAD_OS`/`AVALIACOES` no meio da Onda 21. A falha fica
explicita no `TResult`, com `OS_JA_AVALIADA=SIM` em `AUDIT_LOG`, para o
operador tratar o estado parcial em fluxo assistido.

## 4. Risco fechado

| Debito | Estado apos MICRO33 |
|---|---|
| `DT-V204-AVALIAROS-PROPAGA-FALHAS` | Fechado para `Suspender` e `AvancarFila`. |
| Sucesso falso apos falha de suspensao | Mitigado: retorno vira falha explicita. |
| Sucesso falso apos falha de fila | Mitigado: retorno vira falha explicita. |

## 5. Escopo adiado

1. Resultado estruturado de `ContarStrikes*` fica para MD-21.4.
2. Rollback/ordem segura de `EmitirOS` fica para MD-21.5.
3. Guard de aninhamento de `Svc_Transacao` fica para MD-21.6.
4. Bateria adversarial com fault injection fica para Onda 23.

## 6. Validacao esperada

Gate esperado:

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## 7. Observacao de importacao

O operador informou MICRO32 verde, mas o print recebido ainda exibia build visual
da MICRO31. Por isso o manifesto MICRO33 inclui tambem os modulos de dependencia
da MICRO32 (`Repo_Empresa` e `Svc_Rodizio`) para reduzir risco de base visualmente
defasada no workbook.
