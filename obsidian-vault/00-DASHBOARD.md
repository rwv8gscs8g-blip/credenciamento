---
titulo: Dashboard - Credenciamento
ultima-atualizacao: 2026-05-21
autor-ultima-alteracao: Codex na Onda 29 / fechamento V205
tags: [vivo, dashboard, hbn-active]
versao-sistema: V12.0.0205
linha-alvo: V12.0.0206
build-importado-no-workbook: e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix
hbn-track: fast_track
hbn-status: active
diataxis: status
audiencia: ambos
---

# Dashboard — Credenciamento

> Fonte executiva de status. Discrepâncias entre este arquivo, o relay HBN e o
> status oficial devem ser resolvidas a favor do documento mais recente em
> `obsidian-vault/releases/STATUS-OFICIAL.md`.

## Status atual

| Campo | Valor |
|---|---|
| Versão oficial vigente | **V12.0.0205** (VALIDADO/OFICIAL) |
| Próxima linha | V12.0.0206 |
| Build importado no workbook | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Tag git de publicação | `v12.0.0205` |
| Branch ativa | `codex/v12-0-0205-estabilizacao-docs` |
| Bastão de implementação | Codex — Frente 1 Credenciamento |
| Ambiente | Windows 10+, Excel 2019/2021/365 |
| Planilha homologação | `PlanilhaCredenciamento-Homologacao-V4.xlsm` |

## Onda em curso

**Onda 29 — Fechamento V12.0.0205**

- Status: gate funcional aprovado; auditoria cruzada final e congelamento
  GitHub em preparação.
- Track HBN: safe_track.
- Evidência final: `VR_20260521_182816`.
- Assinatura: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- Documentação principal: release note, regras V205, matriz V205, jornada
  humana, dossiê de release e evidências V205.

## Roadmap

| Linha | Tema | Status |
|---|---|---|
| V12.0.0205 | release oficial de estabilização para produção | VALIDADO |
| V12.0.0206 | estabilização incremental, ajustes manuais, PDF automático e pequenos débitos técnicos | PLANEJADA |
| V12.0.0207 | code review profundo, performance, componentização e preparação SaaS | PLANEJADA |

## Documentos canônicos

### Para IAs

1. [`AGENTS.md`](../AGENTS.md) — entrada canônica.
2. [`.hbn/relay/INDEX.md`](../.hbn/relay/INDEX.md) — bastão e ciclo ativo.
3. [`llms.txt`](../llms.txt) — mapa curado para RAG.
4. [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../.hbn/knowledge/0001-regras-v203-inegociaveis.md) — regras operacionais históricas.
5. [`.hbn/knowledge/0002-regra-ouro-vba-import.md`](../.hbn/knowledge/0002-regra-ouro-vba-import.md) — Regra de Ouro do VBA import.

### Para humanos

1. [`releases/V12.0.0205.md`](releases/V12.0.0205.md) — release oficial vigente.
2. [`../docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`](../docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md) — jornada humana por interface.
3. [`../docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md`](../docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md) — executar o Gate RVS.
4. [`../docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`](../docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md) — regras de negócio.
5. [`../docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md`](../docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md) — cobertura de testes.
6. [`../docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md`](../docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md) — dossiê fonte.

### Evidências

1. [`../auditoria/evidencias/V12.0.0205/INDEX.md`](../auditoria/evidencias/V12.0.0205/INDEX.md) — índice de evidências.
2. [`../auditoria/evidencias/V12.0.0205/MANIFEST.md`](../auditoria/evidencias/V12.0.0205/MANIFEST.md) — manifesto de evidências.
3. [`../auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv`](../auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv) — CSV final do Gate RVS.

## Checkpoint de testes

| Suite | Resultado | Build |
|---|---|---|
| V1 rápida | OK=171, FALHA=0 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| V2 Smoke | OK=34, FALHA=0, MANUAL=4 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| V2 Canônica | OK=24, FALHA=0 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| E2E Strikes | OK=76, FALHA=0 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| IntegridadeBase | OK=4, FALHA=0, MANUAL=1 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Onda23Adv | OK=27, FALHA=0 | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |

## Governança pública

- Licença: TPGL v1.1, com auto-conversão para Apache 2.0 em 4 anos.
- CLA: obrigatório para contribuidores externos.
- Política de segurança: `SECURITY.md`.
- Camada preventiva: Glasswing G1-G5 documentada em
  `.hbn/knowledge/0003-glasswing-style-preventive-security.md`.
- Protocolo de governança AI: HBN
  ([usehbn.org](https://usehbn.org)) — Credenciamento é o primeiro case study
  production-scale do HBN.

## Cadência

Este dashboard deve ser atualizado em todo fechamento de onda, release ou
mudança de linha oficial.
