---
titulo: Onda 37.1 — Diagnostico de drift funcional e decisoes
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Onda 37.1 — Diagnostico de drift funcional e decisoes

## Objetivo

Explicar a origem dos 28 arquivos marcados como `diferenca_funcional` na
Onda 37, preservar as licoes das tentativas MD33 reprovadas e preparar ADRs
para os dois arquivos ausentes no export V5.

## Resultado do diagnostico

| Subclasse | Qtde | Acao proposta |
|---|---:|---|
| `drift_md33_descartar` | 3 | Propor Onda 37.2 safe_track para reverter `src/vba/` ao estado equivalente a V5 nesses arquivos. |
| `drift_legitimo_anterior_v5` | 25 | Nao reverter em bloco; abrir analise por onda/arquivo se forem importaveis. |
| `drift_misto` | 0 | Sem acao. |
| `drift_inesperado_investigar` | 0 | Sem decisao humana individual necessaria. |

## Cadeia MD33 descartavel

| Commit | Papel |
|---|---|
| `0b7c4e8` | Consolidou raiz canonica e tocou `Menu_Principal.frm`; entrou na cadeia que nao resultou em workbook compilavel. |
| `7ba5d97` | Tentativa de estabilizar gate de relatorios; tocou `Menu_Principal.frm` e `Preencher.bas`. |
| `031e077` | Tentativa de evitar novo import do menu; tocou `Menu_Principal.frm`, `Rel_Emp_Serv.frm`, `Rel_OSEmpresa.frm`. |
| `0d3893f` | Pausa/rebase da cadeia; tocou `Importador_V3.bas`, `Preencher.bas`, `Rel_Emp_Serv.frm`, `Rel_OSEmpresa.frm`. |

## Artefatos gerados

- `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao_drift_funcional.md`
- `auditoria/01_regras_e_governanca/L26_LICOES_MD33_TENTATIVAS_FRUSTRADAS.md`
- `auditoria/01_regras_e_governanca/ADR-20260524-remocao-importador-v2.md`
- `auditoria/01_regras_e_governanca/ADR-20260524-pendencia-emergencia-cnae.md`
- `.hbn/knowledge/0014-protocolo-reprovacao-onda.md`
- `auditoria/03_ondas/onda_37_1_decisoes_drift/PROPOSTA_ONDA_37_2_SAFE_TRACK.md`

## Invariantes preservados

- Nenhum arquivo em `src/vba/` foi alterado.
- Nenhum arquivo em `local-ai/vba_import/` foi alterado.
- Nenhum arquivo em `local-ai/incoming/` foi alterado.
- Nenhum pacote importavel foi criado.

## Decisao operacional

A V5 continua sendo a unica versao conhecida que compila. A proxima onda que
tocar VBA deve partir de readback safe_track especifico e tratar `src/vba/`
como possivel drift, nao como verdade importavel automatica.
