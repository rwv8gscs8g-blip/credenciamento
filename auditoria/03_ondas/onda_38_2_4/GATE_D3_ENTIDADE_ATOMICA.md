---
titulo: Gate D3 — Entidade Atomica Ativa/Inativa
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Gate D3 — Entidade Atomica Ativa/Inativa

## Resultado

Status: APROVADO.

## Evidencia Automatizada

`TV2_RunIntegridadeEstado` apos Fix3:

- execucao: `TV2_20260530_162347`
- resultado: `OK=5 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado

O cenario `CS_EST_05_EXCLUIR_LINHA_UNICA_TABELA` confirmou que `Util_ExcluirLinhaSegura` possui contrato explicito para a ultima linha de dados de tabela Excel.

## Evidencia Manual

Mauricio reportou que:

- cadastrou a `Entidade 7` com todos os campos preenchidos;
- o modal de edicao mostrou todos os dados;
- inativou uma entidade intermediaria e reativou com sucesso;
- inativou a primeira entidade ativa e reativou com sucesso;
- inativou todas as entidades ate restar uma unica ativa;
- inativou a ultima entidade ativa sem erro;
- confirmou que a ultima entidade apareceu uma unica vez na lista de reativacao;
- reativou todas as entidades;
- confirmou que nenhuma entidade ficou simultaneamente ativa e inativa.

## Decisao

O BLOQUEADOR de integridade ativa/inativa coberto por esta micro-onda esta resolvido no escopo `0120`.
