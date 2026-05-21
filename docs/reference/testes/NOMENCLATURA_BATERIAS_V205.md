---
titulo: Crosswalk de Nomenclatura de Testes V205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Crosswalk de Nomenclatura de Testes — V12.0.0205

Este documento estabelece a equivalência entre a nomenclatura histórica das
baterias de teste e a nomenclatura profissional adotada a partir da
V12.0.0205.

## Regra de Ouro

Na V12.0.0205 os símbolos VBA permanecem inalterados. A mudança ocorre nos
rótulos de interface, documentação, evidências novas e materiais de auditoria.

## Tabela de Equivalência

| Nome histórico | Nome oficial V205 | Sigla | Símbolo VBA preservado | Papel |
|---|---|---|---|---|
| Sexteto Mínimo | Gate de Validação de Release | RVS | `CT_ValidarRelease_SextetoMinimo` | Gate oficial com V1, V2 Smoke, V2 Canônica, E2E Strikes, IntegridadeBase e Onda23Adv |
| Quinteto | Suíte de Regressão Consolidada | SRC | `CT_ValidarRelease_QuintetoMinimo` | Regressão consolidada sem o bloco adversarial Onda 23 |
| Quarteto Direto | Bateria Rápida Legada | BRL | `CT_ValidarRelease_QuartetoMinimo` | Gate histórico rebaixado; não é o caminho principal da V205 |

## Evidências

- Evidências V204 preservam nomes históricos, incluindo
  `ValidacaoReleaseSexteto_*`.
- Evidências V205 novas devem usar o prefixo `ValidacaoReleaseRVS_V12_0_0205_`
  para o gate oficial.
- Evidências geradas por baterias legadas expostas para compatibilidade usam
  `ValidacaoReleaseSRC_V12_0_0205_`, `ValidacaoReleaseBRL_V12_0_0205_` ou
  `ValidacaoReleaseTrio_V12_0_0205_`.
- Nenhum CSV validado de V204 deve ser renomeado.

## Regra Para IAs

Quando encontrar `Sexteto` em símbolo VBA ou evidência histórica, tratar como
equivalente técnico de `RVS`, sem propor renomeação física em V205.
