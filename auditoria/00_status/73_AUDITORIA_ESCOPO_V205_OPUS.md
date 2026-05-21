---
titulo: Auditoria de Escopo V205 Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
autor: Claude Opus 4.7
origem: Superprompt 1
---

# Auditoria de Escopo V12.0.0205 — Opus

Este documento registra a síntese canônica do Superprompt 1. A análise completa
foi conduzida fora deste commit, sem alteração de código, usando como fonte de
verdade a branch `codex/v12-0-0203-governanca-testes` no commit `e43352f`.

## Veredito

A V12.0.0205 deve ser aberta como release de estabilização para produção:

- durante o ciclo, ela é `RELEASE_CANDIDATE`;
- no gate final, pode ser promovida para `VALIDADO` / `OFICIAL`;
- não deve adicionar regra de negócio;
- deve resolver clareza, evidências, documentação e UX de validação.

## Fonte de verdade

| Campo | Valor |
|---|---|
| Release oficial anterior | `V12.0.0204` |
| Build validado | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Gate pós-App_Release | `VR_20260511_175849` |
| Sintaxe de regressão | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Próxima versão alvo | `V12.0.0205` |

O `main` local antigo não é fonte de verdade para a V205.

## Achados principais

1. A topologia de branches precisava ser tratada antes da execução física da
   V205.
2. A V205 não é puramente documental: labels, menus, prefixos CSV e metadados
   de release exigem VBA textual/UX/evidência.
3. A automação completa de PDF deve ser especificada na V205 e implementada
   apenas na V206.
4. A guarda de regressão funcional da V205 deve preservar a sintaxe numérica da
   V204.

## Recomendação para SP2

O auditor cruzado deveria estressar a topologia de branch, a premissa de gate
idêntico, a classificação V205/V206/SaaS e a ordem documental.
