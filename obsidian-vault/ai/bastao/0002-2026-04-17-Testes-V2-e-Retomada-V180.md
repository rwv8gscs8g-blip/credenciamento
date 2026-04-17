---
titulo: Retomada do desenvolvimento na V12.0.0180 e fundacao da bateria V2
data: 2026-04-17
autor: GPT-5 (Codex)
versao: V12.0.0185
status: ativo
tags: [bastao, testes, estabilizacao]
---

# 0002 - Testes V2 e Retomada da V180

## Contexto

O usuario aprovou a retomada do desenvolvimento a partir da `V12.0.0180`, tratada como base estavel, e aprovou integralmente a estrategia de evolucao dos testes V2.

Havia tentativa local posterior a `0180` focada no importador VBA, sem commit proprio. Essa tentativa foi preservada em backup antes de limpar o working tree.

## Decisoes Tomadas

1. Preservar a tentativa pos-180 em `backups/rollback-post-v180-2026-04-17/`
2. Abrir branch de retomada sobre o commit `9275640` (`Release V12.0.0180`)
3. Manter a bateria legada intacta e criar a V2 em modulos novos
4. Publicar a retomada como `V12.0.0182`
5. Marcar a `V12.0.0180` como `VALIDADO` em governanca

## O que foi feito nesta sessao

- rollback operacional do working tree para a base `V12.0.0180`
- backup do diff local pos-180 em patch binario
- criacao de `Central_Testes_V2.bas`
- criacao de `Teste_V2_Engine.bas`
- criacao de `Teste_V2_Roteiros.bas`
- geracao de catalogo semantico em planilha `CATALOGO_CENARIOS_V2`
- definicao de resultados estruturados em `RESULTADO_QA_V2`
- stress deterministico com invariantes basicas de fila
- simplificacao da `Central_Testes` para a transicao: apenas legado + V2
- V2 passa a recolher o `Menu_Principal`, abrir `RESULTADO_QA_V2` filtrado na execucao atual e exportar CSVs automaticamente com contexto semantico
- V2 passa a recolher o `Menu_Principal` tambem em toda navegacao assistida (`abrir resultado`, `abrir catalogo` e entradas `CT2_*`)

## Pendencias

- importar a `V12.0.0182` no Excel e validar macros `CT2_*`
- expandir a V2 para cenarios combinatorios gerados
- migrar guardas de UI para `Svc_PreOS`, `Svc_OS` e `Svc_Avaliacao`
- plugar a V2 na central legada somente depois da rodada inicial de validacao

## Observacoes Operacionais

- branch de trabalho: `codex/v180-stable-reset`
- commit/base de retomada: `9275640`
- backup da tentativa local anterior: `backups/rollback-post-v180-2026-04-17/`
