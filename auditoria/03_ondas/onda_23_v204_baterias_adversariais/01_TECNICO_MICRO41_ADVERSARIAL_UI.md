---
titulo: Tecnico MICRO41 — Suite adversarial UI
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-07
---

# MICRO41 — Suite adversarial UI

## 1. Objetivo

Abrir a Onda 23 com uma suite read-only dedicada a pontos de UI que
ja causaram risco operacional em auditorias anteriores: reentrada por
duplo clique, acoes destrutivas sem confirmacao, bypass de servico e
guard que nao volta ao estado inicial.

A suite nao escreve em abas de negocio. Ela le arquivos em `src/vba/`
e valida tokens estruturais.

## 2. Entrega

`TV2_RunAdversarial_UI` adiciona 10 cenarios:

| Cenario | Cobertura |
|---|---|
| `UI_ADV_001_REENTRADA_MUTADORES` | flags de reentrada nos forms mutadores |
| `UI_ADV_002_REATIVA_EMPRESA_INTEGRIDADE` | conflito, duplicidade, confirmacao, servicos e reset |
| `UI_ADV_003_REATIVA_ENTIDADE_SERVICO` | reativacao de entidade via servico |
| `UI_ADV_004_ALTERA_EMPRESA_CONFIRMA_IDS` | alteracao/inativacao com `IdsIguais` e guards |
| `UI_ADV_005_ALTERA_ENTIDADE_CONFIRMA_IDS` | mesmo contrato para entidade |
| `UI_ADV_006_AVALIAR_OS_GUARDS` | avaliacao de OS com guard, parse e justificativa |
| `UI_ADV_007_PREOS_OS_DESTRUTIVOS` | rejeitar/expirar/cancelar com fronteira e confirmacao |
| `UI_ADV_008_LIMPAR_BASE_FORM_GUARD` | senha e guard do form `Limpar_Base` |
| `UI_ADV_009_LIMPAR_BASE_CONFIRMACAO` | confirmacao e reset centralizado em `Limpa_Base` |
| `UI_ADV_010_CENTRAL_V2_EXPOE_SUITE` | exposicao da suite na Central V2 |

## 3. Escopo

Este microdelta nao entra no Quinteto ainda. O gate formal continua com:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0
```

A validacao nova e executada antes do Quinteto:

```text
TV2_RunAdversarial_UI False -> ADVERSARIAL_UI=10/0/0
```

## 4. Risco residual

Por ser read-only, a suite captura drift estrutural no codigo-fonte, mas
nao substitui teste manual de clique real nos forms. Esse sera assunto de
ondas futuras de automacao visual, conforme Onda 26 de documentacao/RAG e
planejamento de ferramentas externas.
