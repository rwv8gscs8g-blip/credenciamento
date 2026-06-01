---
titulo: Gate D2 — Ordenacao e Listagem de Entidades
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Gate D2 — Ordenacao e Listagem de Entidades

## Resultado

Status: APROVADO COM RESSALVA VISUAL.

## Evidencia Reportada

Mauricio reportou que, apos Fix3:

- a lista de entidades foi carregada;
- novas entidades criadas apareceram na lista ativa;
- a lista de inativas apareceu na ordem esperada;
- a reativacao trouxe entidades de volta para a lista ativa;
- nenhuma entidade ficou simultaneamente ativa e inativa.

## Ressalva

Depois de reativar todas as entidades, a entidade 3 nao ficou imediatamente visivel na area exibida da lista principal. Pelas imagens existe barra de rolagem na lista, entao o achado fica classificado como problema de visualizacao/scroll/foco, nao como falha comprovada de persistencia.

Esse residuo deve ser tratado em onda futura de leitura/exibicao, provavelmente em `Menu_Principal.frm`, fora do readback `0120`.

## Decisao

O Gate D2 nao bloqueia a conclusao da micro-onda de integridade de estado, desde que o RVS pos-Fix3 passe e a auditoria cruzada concorde que o residuo e visual.
