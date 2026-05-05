---
titulo: 02 - Roadmap Onda 21 V204 Transacional
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Onda 21 V204 - Integridade transacional e erro explicito

## 1. Objetivo

Remover sucesso falso em repositorios/servicos e impedir que falha
interna seja interpretada como operacao concluida.

## 2. Microdeltas

| MD | Mudanca | Risco fechado | Gate |
|---|---|---|---|
| MD-21.1 | `GravarStatusEmpresa` passa a retornar resultado estruturado | `DT-V204-GRAVARSTATUS-RESULT` | V1 + V2 Canonica |
| MD-21.2 | `Suspender` valida persistencia e propaga falha | sucesso falso em suspensao | E2E Strikes |
| MD-21.3 | `AvaliarOS` decide explicitamente falha de `Suspender`/`AvancarFila` | `DT-V204-AVALIAROS-PROPAGA-FALHAS` | E2E Strikes |
| MD-21.4 | `ContarStrikes*` retorna resultado, nao `0` em erro | `DT-V204-CONTARSTRIKES-RESULT` | boundary + E2E |
| MD-21.5 | `EmitirOS` ganha ordem/rollback seguro | `DT-V204-EMITIR-OS-ROLLBACK` | transaction interrupt |
| MD-21.6 | `Svc_Transacao` detecta aninhamento | transacao parcial | V2 Canonica |

## 3. Criterio de aceite

1. Nenhuma chamada critica ignora `sucesso=False`.
2. Erro em contador de strikes bloqueia decisao punitiva.
3. Erro em emissao de OS nao deixa PRE_OS/CAD_OS divergente.
4. Quinteto verde.
