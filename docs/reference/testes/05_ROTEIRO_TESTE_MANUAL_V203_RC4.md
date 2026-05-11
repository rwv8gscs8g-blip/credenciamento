---
titulo: Roteiro de Teste Manual V203 rc4
diataxis: reference
hbn-track: fast_track
hbn-status: archived
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Roteiro de Teste Manual V203 rc4

> Documento historico da rc4. O roteiro vigente para teste humano externo da
> V12.0.0204 e [07_ROTEIRO_TESTE_MANUAL_V204.md](07_ROTEIRO_TESTE_MANUAL_V204.md).

Este roteiro orienta o ciclo manual depois do Quinteto verde. Ele existe
para descobrir problemas de uso real antes da abertura da V204.

## Cabecalho do ciclo

| Campo | Preencher |
|---|---|
| operador |  |
| data/hora |  |
| workbook |  |
| build |  |
| `VALIDACAO_ID` previo |  |
| resultado do Quinteto |  |

## Checklist inicial

1. Abrir workbook correto.
2. Confirmar build com `?GetBuildImportado`.
3. Confirmar compilacao limpa.
4. Confirmar que a aba `VALIDACAO_RELEASE` mostra gate verde recente.
5. Confirmar que a release em teste e rc4, nao producao.

## Fluxos manuais obrigatorios

| Fluxo | Acao | Resultado esperado |
|---|---|---|
| cadastro de empresa | cadastrar empresa nova de teste | aparece em listas sem duplicidade |
| cadastro de entidade | cadastrar entidade nova de teste | aparece em listas sem erro |
| credenciamento | vincular empresa a atividade/servico | credenciamento fica pesquisavel |
| rodizio | selecionar empresa elegivel | fila avanca de forma coerente |
| avaliacao | aplicar avaliacao negativa | strike registrado |
| suspensao | acumular condicao de suspensao | status muda e fica visivel |
| reativacao | reativar empresa suspensa | `DT_ULT_REATIV` preservado apos ordenacao |
| classificacao | classificar lista de empresas | coluna U acompanha a linha correta |
| limpeza base | testar somente se ambiente permitir | confirmacao clara antes de limpar |

## Registro de anomalia

Para cada anomalia, coletar:

1. tela/aba;
2. acao executada;
3. dado usado;
4. resultado esperado;
5. resultado obtido;
6. print;
7. se houve erro VBA;
8. se o problema se repete apos fechar/reabrir.

## Criterios de bloqueio

| Severidade | Criterio |
|---|---|
| P0 | perda de dados, corrupcao de coluna, falha de compilacao |
| P1 | regra de negocio errada, reativacao/strikes incoerente, duplicidade ativa |
| P2 | mensagem vaga, fluxo confuso, lacuna de auditoria |
| P3 | ajuste visual, texto, ergonomia |

## Encerramento

O teste manual termina com:

1. decisao humana;
2. lista de bugs encontrados;
3. lista de duvidas de regra de negocio;
4. recomendacao: corrigir na V203 ou abrir na V204.
