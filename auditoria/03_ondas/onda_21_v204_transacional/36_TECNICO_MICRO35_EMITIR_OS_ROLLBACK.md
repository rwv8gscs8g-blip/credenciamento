---
titulo: 36 - Tecnico MICRO35 Onda 21 V204 EmitirOS Rollback
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO35 - EmitirOS Com Ordem Segura E Rollback

## 1. Objetivo

Fechar o debito `DT-V204-EMITIR-OS-ROLLBACK`: `EmitirOS` nao pode criar
uma OS em `CAD_OS` quando a conversao da `PRE_OS` ainda nao esta garantida.

## 2. Mudancas

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_OS.bas` | Adiciona `ExcluirPorId(OS_ID)` para rollback da OS recem-criada. |
| `src/vba/Svc_OS.bas` | Prepara `PRE_OS` antes de inserir OS. |
| `src/vba/Svc_OS.bas` | Guarda valores antigos de `STATUS`, `OS_ID` e `DT_EM_OS` da `PRE_OS`. |
| `src/vba/Svc_OS.bas` | Se falhar apos criar OS, restaura a `PRE_OS` e remove a OS recem-criada. |
| `src/vba/Svc_OS.bas` | Falha de `AvancarFila` continua como aviso compativel, mas passa a registrar `EVT_TRANSACAO`. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.5-emitir-os-rollback`. |

## 3. Politica adotada

Esta MICRO35 nao altera a semantica historica de `AvancarFila` em `EmitirOS`.
Quando a OS e a PRE_OS ja estao consistentes, falha de fila permanece como
aviso operacional para preservar compatibilidade com V1/V2. A novidade e que
o aviso tambem fica registrado em `AUDIT_LOG` como `EVT_TRANSACAO`.

## 4. Risco fechado

| Debito | Estado apos MICRO35 |
|---|---|
| `DT-V204-EMITIR-OS-ROLLBACK` | Fechado para falha posterior a criacao de OS. |
| OS criada sem PRE_OS convertida | Mitigado: rollback remove OS recem-criada e restaura PRE_OS. |
| Falha de preparo de PRE_OS depois de OS criada | Mitigado: PRE_OS e preparada antes da insercao da OS. |
| Falha de fila sem auditabilidade | Mitigado: gera `EVT_TRANSACAO` com `AVANCAR_FILA_FALHOU`. |

## 5. Escopo adiado

1. `Svc_Transacao` detectar aninhamento fica para MD-21.6.
2. Bateria automatizada de fault injection fica para Onda 23.
3. Mudanca da politica de `AvancarFila` para `sucesso=False` fica para decisao de compatibilidade posterior.

## 6. Validacao esperada

Gate esperado:

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## 7. Evidencias de entrada

1. MICRO34 verde: `VR_20260505_185750`.
2. Auditoria Codex 56 apontou `Svc_OS.EmitirOS` como P1 por criar OS antes de garantir PRE_OS.
3. Auditoria Antigravity 65 confirmou risco P1 de ordem de dependencia.
