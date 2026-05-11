---
titulo: Tecnico MICRO42 - Suite transacao interrupt
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-07
---

# MICRO42 - Suite transacao interrupt

## 1. Objetivo

Ampliar a cobertura adversarial da Onda 23 com uma suite autonoma para
contratos de `Svc_Transacao`: limpeza de estado, rollback idempotente,
restauracao de write e rejeicao de transacao aninhada.

Este microdelta nao altera a regra de negocio de producao. A entrega e
test-first: exercita os contratos ja existentes para impedir regressao
em futuras refatoracoes transacionais.

## 2. Entrega

`TV2_RunTransaction_Interrupt` adiciona 6 cenarios:

| Cenario | Cobertura |
|---|---|
| `TX_INT_001_COMMIT_LIMPA_ESTADO` | commit encerra transacao, limpa id e audita `STATUS=COMMIT` |
| `TX_INT_002_ROLLBACK_SEM_WRITE_LIMPA_ESTADO` | rollback sem writes retorna OK e limpa estado |
| `TX_INT_003_ROLLBACK_RESTAURA_VALOR` | rollback restaura sentinela em `RESULTADO_QA_V2` |
| `TX_INT_004_ANINHADA_PRESERVA_EXTERNA` | tentativa aninhada falha e preserva a transacao externa |
| `TX_INT_005_COMMIT_APOS_ROLLBACK_NAO_REABRE` | commit defensivo apos rollback nao reabre estado |
| `TX_INT_006_ROLLBACK_DUPLO_IDEMPOTENTE` | rollback duplo fica idempotente e deixa estado limpo |

## 3. Escopo

A suite escreve apenas nas abas tecnicas de teste/auditoria:

- `RESULTADO_QA_V2`: celula sentinela temporaria em coluna fora do layout visivel.
- `AUDIT_LOG`: eventos naturais de `Svc_Transacao`.
- `TESTE_TRILHA`/`AUDIT_TESTES`: evidencias V2.

Nenhuma aba operacional de cadastro/rodizio/OS e alterada pela suite.

## 4. Gate

Validacao nova:

```text
TV2_RunTransaction_Interrupt False -> TRANSACAO_INTERRUPT=6/0/0
```

Quinteto esperado sem mudanca:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0
```

## 5. Risco residual

A suite valida a transacao minima atual, mas nao transforma o sistema em
transacao multi-nivel. `Svc_Transacao` continua rejeitando aninhamento
explicitamente. Se no futuro houver necessidade de stack transacional,
isso deve virar microdelta proprio com testes de rollback em cascata.
