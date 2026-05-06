---
titulo: 44 - Tecnico MICRO36 Transacao Aninhada
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# MICRO36 - Transacao aninhada

## 1. Contexto

A auditoria marcou a lacuna R-48: `Svc_Transacao` mantinha estado global
unico e `Transacao_Iniciar` podia sobrescrever uma transacao ativa.

## 2. Mudanca

`Transacao_Iniciar` agora calcula o novo id sem alterar o estado global. Se
ja existe transacao ativa:

1. registra `EVT_TRANSACAO` com `MOTIVO=TRANSACAO_ANINHADA`;
2. preserva `gTransacaoId` e writes da transacao externa;
3. levanta erro explicito com origem `Svc_Transacao.Transacao_Iniciar`.

## 3. Cobertura

`TV2_RunSmoke` ganhou `ATM_002`, que valida:

| Verificacao | Esperado |
|---|---|
| segunda abertura | erro explicito |
| transacao externa | continua ativa apos erro |
| id externo | preservado |
| auditoria | contem `TRANSACAO_ANINHADA` |
| limpeza | rollback final encerra a transacao |

## 4. Gate esperado

`V1=171/0+V2_Smoke=29/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`
