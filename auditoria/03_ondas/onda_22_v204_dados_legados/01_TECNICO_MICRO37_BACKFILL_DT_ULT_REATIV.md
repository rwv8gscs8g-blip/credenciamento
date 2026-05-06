---
titulo: Onda 22 MICRO37 — Backfill auditavel de DT_ULT_REATIV
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Onda 22 MICRO37 — Backfill auditavel de DT_ULT_REATIV

## Objetivo

Fechar a primeira parte da Onda 22 para bases legadas: empresas reativadas antes da criacao da coluna `DT_ULT_REATIV` podem ter o corte reconstruido a partir do `AUDIT_LOG`, sem mutacao automatica ao abrir o workbook.

## Mudanca tecnica

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_Empresa.bas` | adiciona deteccao read-only de pendencias e aplicacao explicita de backfill por `AUDIT_LOG` |
| `src/vba/Auto_Open.bas` | exibe hint passivo em `Application.StatusBar` quando ha pendencia; nao aplica backfill |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `MIG_005` ao Smoke para validar deteccao, aplicacao e auditoria |
| `src/vba/Teste_V2_Engine.bas` | registra `MIG_005` no catalogo e roteiro assistido |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA22.MD22.1-backfill-dt-ult-reativ` |

## Contrato de comportamento

1. Deteccao: varre `EMPRESAS` em busca de `DT_ULT_REATIV` vazia/invalida com evento `EVT_REATIVACAO` de `ENT_EMP` no `AUDIT_LOG`.
2. Aplicacao: so ocorre por chamada explicita da rotina de backfill.
3. Auditoria: cada preenchimento registra `EVT_TRANSACAO` com `BACKFILL_DT_ULT_REATIV`.
4. Abertura do workbook: apenas sinaliza a pendencia em `StatusBar`; nao altera dados.
5. Bases sem evento de reativacao preservado nao sao inventadas; continuam para diagnostico posterior.

## Cobertura de teste

`TV2_RunSmoke` passa a incluir `MIG_005`:

| Cenario | Validacao |
|---|---|
| `MIG_005` | cria empresa canonica com `DT_ULT_REATIV` vazia, registra evento legado de reativacao, detecta 1 pendencia, aplica backfill, confirma 0 pendencias depois e exige auditoria `BACKFILL_DT_ULT_REATIV` |

Sintaxe esperada do Quinteto apos importacao:

`V1=171/0+V2_Smoke=30/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## Limites conscientes

- MICRO37 nao cria interface humana para aplicar backfill em producao; o foco e disponibilizar rotina auditavel e teste automatico.
- MICRO37 nao resolve ainda referencias orfas em `CAD_OS`; isso permanece para MD-22.4.
- MICRO37 nao muda a regra de strikes; apenas reduz retorno silencioso ao modo legado em bases migradas.

## Higiene documental

Gate aplicado conforme `.hbn/knowledge/0011-higiene-documental-recorrente.md`:

- readback/ERP criados;
- manifesto V3 criado;
- `src/vba` e `local-ai/vba_import` com `shasum` pareado;
- procedimento de importacao com comando copiavel;
- CHANGELOG/relay atualizados.

