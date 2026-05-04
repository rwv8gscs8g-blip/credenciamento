---
titulo: Mapa de Testes V203 Quinteto
diataxis: reference
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Mapa de Testes V203 Quinteto

Este documento define o contrato humano do Quinteto de validacao da
`V12.0.0203`.

## Composicao

| Etapa | Macro/suite | Papel | Resultado rc4 |
|---|---|---|---|
| 1 | V1 rapida | regressao funcional historica | `171/0` |
| 2 | V2 Smoke | sanity check rapido dos fluxos V2 | `27/0` |
| 3 | V2 Canonica | cenarios canonicos de negocio | `23/0` |
| 4 | E2E Strikes | rodizio, avaliacao, suspensao e reativacao | `71/0` |
| 5 | IntegridadeBase | auditoria passiva de base e referencias | `3/0` |

## Leitura operacional

| Suite | O que prova | O que nao prova sozinha |
|---|---|---|
| V1 rapida | a bateria historica nao regrediu | combinatoria profunda V2 |
| V2 Smoke | fluxo minimo executa | regras de borda |
| V2 Canonica | principais contratos de negocio | todos os caminhos de UI |
| E2E Strikes | ciclo de strikes e reativacao | todas as telas de manutencao |
| IntegridadeBase | referencias orfas e sinais de corrupcao | causa raiz automatica |

## Gate rc4

| Campo | Valor |
|---|---|
| `VALIDACAO_ID` | `VR_20260504_171048` |
| Build | `f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u` |
| Resultado | `APROVADO` |
| Uso autorizado | teste manual formal |
| Uso nao autorizado | producao |

## Sinais de bloqueio

1. Qualquer falha em compilacao.
2. Qualquer falha em `V2_CANONICO` sem explicacao aceita.
3. Qualquer divergencia entre build exibido e build esperado.
4. Qualquer drift `src/vba` versus importador detectado por Glasswing.
5. Falha nova em reativacao, strikes ou ordenacao da aba `EMPRESAS`.

## Sinais que podem virar V204

1. Debito ja conhecido e documentado.
2. Falha de dado legado que nao altera regra principal.
3. Mensagem de erro vaga sem regressao funcional comprovada.
4. Lacuna de cobertura que nao contradiz o comportamento testado.

## Evidencia minima

Cada execucao formal deve preservar:

1. CSV de validacao;
2. print do resumo;
3. build;
4. `VALIDACAO_ID`;
5. anotacao humana sobre contexto e decisao.
