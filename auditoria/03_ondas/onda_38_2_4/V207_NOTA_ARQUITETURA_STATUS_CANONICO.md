---
titulo: Nota V207 — Cadastro Canonico com Status
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Nota V207 — Cadastro Canonico com Status

## Contexto

Durante a revalidacao manual da Onda 38.2.4, Mauricio questionou se a arquitetura atual de ativacao/inativacao por copia de linha entre abas (`ENTIDADE` <-> `ENTIDADE_INATIVOS`, `EMPRESAS` <-> `EMPRESAS_INATIVAS`) deveria ser revista antes da migracao gradual para SaaS.

## Proposta para Revisao V207

Avaliar uma arquitetura em que empresas e entidades sejam registros canonicos permanentes, com um campo de status operacional em vez de mover/copiar/apagar a linha completa.

Modelo conceitual:

- `ENTIDADES`: registro canonico unico por `ENT_ID`, com dados cadastrais permanentes;
- `EMPRESAS`: registro canonico unico por `EMP_ID`, com dados cadastrais permanentes;
- `STATUS`: campo ou tabela associada com valores como `ATIVO`, `INATIVO`, `SUSPENSO`, `BLOQUEADO`;
- `HISTORICO_STATUS`: trilha append-only com data/hora, operador, motivo e status anterior/novo;
- telas Excel continuam exibindo listas ativas/inativas, mas passam a usar filtros sobre status, nao abas duplicadas.

## Beneficios Esperados

- elimina duplicidade fisica de entidades/empresas;
- reduz risco de registro ativo e inativo simultaneamente;
- simplifica reativacao/inativacao para update transacional de status;
- melhora idempotencia e integridade referencial;
- aproxima o workbook de um modelo relacional/API;
- facilita sincronizacao futura com SaaS;
- preserva a metodologia da interface Excel enquanto reorganiza a logica por tras.

## Riscos e Guard-Rails

- nao implementar em V206: mudanca estrutural de schema e regras de migracao;
- exigir auditoria cruzada antes de qualquer mudanca;
- manter compatibilidade de interface para o operador;
- criar camada de adaptadores para que forms existentes consumam listas filtradas;
- definir migracao reversivel das abas atuais para modelo canonico;
- preservar historico operacional e evidencias de auditoria.

## Recomendacao Codex

Levar esta proposta para a pauta de arquitetura V207 com auditoria cruzada. Para V206, manter escopo conservador: estabilizar os fluxos existentes e corrigir bloqueadores L43 sem alterar o modelo de dados fisico.
