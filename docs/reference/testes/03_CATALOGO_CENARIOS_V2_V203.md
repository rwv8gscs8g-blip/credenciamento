---
titulo: Catalogo de Cenarios V2 V203
diataxis: reference
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Catalogo de Cenarios V2 V203

Este catalogo resume a funcao dos cenarios V2 usados na estabilizacao
da `V12.0.0203`. Ele nao substitui `src/vba/Teste_V2_Roteiros.bas`; e a
leitura humana do mapa.

## Familias

| Familia | Finalidade | Observacao |
|---|---|---|
| `CS_*` canonicos | regras de negocio centrais | executados na V2 Canonica |
| `CS_E2E_*` | fluxo ponta a ponta | usado na suite E2E Strikes |
| `CS_INT_*` | integridade passiva de base | usado em IntegridadeBase |
| `TV2_*` helpers | montagem canonica de dados | nao sao cenarios de aceite isolados |

## Cenarios de negocio relevantes

| Cenario | Objetivo humano | Area coberta |
|---|---|---|
| `CS_E2E_REATIV2STRIKES` | provar que reativacao zera janela punitiva sem apagar historico | rodizio, avaliacao, strikes |
| `CS_23` | validar ida e volta ativo/inativo com preservacao de fila | forms, reativacao, ordenacao |
| `CS_INT_04` | detectar referencia orfa em `CAD_OS` | integridade de dados |
| cenarios de cadastro | provar cadastro canonico de empresa, entidade, servico e credenciamento | repos e services |
| cenarios de avaliacao | provar registro de avaliacao e efeitos de status | avaliacao e auditoria |
| cenarios de rodizio | provar selecao, fila, recusa e suspensao | rodizio |

## Regra de leitura de falha

| Falha | Leitura |
|---|---|
| esperado e obtido diferentes | comportamento divergente do contrato |
| `DT_ULT_REATIV` vazio quando deveria estar preenchido | risco direto na janela de strikes |
| quantidade `TOTAL` inesperada | possivel duplicidade, ordenacao ou dado residual |
| referencia orfa | integridade de base, normalmente candidata a V204 se nao bloquear regra principal |

## Cenario que gerou a correcao final rc4

`CS_23` detectou que `DT_ULT_REATIV` ficava vazio apos classificacao da
aba `EMPRESAS`. A causa foi ordenacao parcial ate a coluna `T`, deixando
a coluna `U` fora do bloco ordenado. A correcao final fez a classificacao
abranger a coluna `COL_EMP_DT_ULT_REATIV`.

## Como evoluir o catalogo na V204

1. Nomear cada cenario com regra de negocio explicita.
2. Registrar pre-condicao, acao, assert principal e efeito colateral.
3. Marcar se o cenario e deterministico, assistido ou destrutivo.
4. Manter matriz regra x cenario x evidencia.
5. Separar falha de sistema, falha de dado e falha de teste.
