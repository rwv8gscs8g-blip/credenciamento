---
titulo: Dashboard - Credenciamento
ultima-atualizacao: 2026-05-11
autor-ultima-alteracao: Codex CLI na Onda 25 / MICRO57
tags: [vivo, dashboard, hbn-active]
versao-sistema: V12.0.0204
linha-alvo: V12.0.0205
build-importado-no-workbook: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
hbn-track: fast_track
hbn-status: active
diataxis: status
audiencia: ambos
---

# Dashboard — Credenciamento

> Atualizado a cada onda fechada. Cadencia obrigatoria conforme Onda 6.
> Fonte unica de status. Discrepancias entre este arquivo e
> `auditoria/00_status/22_*` sao resolvidas a favor do mais recente
> (campo `ultima-atualizacao`).

## Status atual

| Campo | Valor |
|---|---|
| Versao oficial vigente | **V12.0.0204** (validada) |
| Linha em estabilizacao | V12.0.0205 (a abrir) |
| Build importado no workbook | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Tag git de publicacao | `v12.0.0204` |
| Branch ativa | `codex/v12-0-0203-governanca-testes` |
| Bastao de implementacao | Codex CLI — Frente 1 Credenciamento |
| Ambiente | Windows 10+, Excel 2019/2021/365 |
| Planilha homologacao | `PlanilhaCredenciamento-Homologacao.xlsm` |

## Onda em curso

**Onda 25 — Publicacao V12.0.0204**

- Status: MICRO57 documental em fechamento; vitrine humana orientada por interface
- Track HBN: safe_track
- Hearback: aprovado pelo operador em 2026-05-11
- Doc tecnica: `auditoria/03_ondas/onda_25_v204_release_candidate/12_TECNICO_MICRO57_GUIA_HUMANO_INTERFACE_V204.md`
- Evidencia final: `VR_20260511_154433`; evidencia adicional pos-App_Release `VR_20260511_175849`
- Proxima linha: V12.0.0205 com auditoria cruzada Opus/Antigravity e lista mestra de evolucoes

## Roadmap apos Onda 6

| Onda | Tema | Status |
|---|---|---|
| V12.0.0204 | release oficial | VALIDADA |
| V12.0.0205 | auditoria cruzada + lista mestra de evolucoes | PROXIMA |
| V12.0.0205 | renomear taxonomia publica de testes | PLANEJADO |

## Documentos canonicos (pos-Onda 6)

### Para IAs
1. [`AGENTS.md`](../AGENTS.md) — entrada canonica
2. [`.hbn/relay/INDEX.md`](../.hbn/relay/INDEX.md) — bastao + ciclo ativo
3. [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../.hbn/knowledge/0001-regras-v203-inegociaveis.md) — 10 regras
4. [`.hbn/knowledge/0002-regra-ouro-vba-import.md`](../.hbn/knowledge/0002-regra-ouro-vba-import.md) — Regra de Ouro
5. [`.hbn/knowledge/0003-glasswing-style-preventive-security.md`](../.hbn/knowledge/0003-glasswing-style-preventive-security.md) — 5 vetores Glasswing

### Para humanos (Diataxis)
1. [`docs/tutorials/GUIA_TESTES_HUMANOS_V204.md`](../docs/tutorials/GUIA_TESTES_HUMANOS_V204.md) — guia principal por interface
2. [`docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md`](../docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md) — liberar macros no Windows
3. [`docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md`](../docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md) — rodar o gate V204 pela Central de Testes
4. [`docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md`](../docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md) — homologacao humana
5. [`docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md`](../docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md) — cobertura de regras

### Para LLMs (RAG)
1. [`llms.txt`](../llms.txt) — mapa curado
2. [`llms-full.txt`](../llms-full.txt) — indice exaustivo

### Vitrine institucional
1. [`releases/STATUS-OFICIAL.md`](releases/STATUS-OFICIAL.md) — status oficial das versoes
2. [`releases/V12.0.0204.md`](releases/V12.0.0204.md) — release validada atual
3. [`metodologia/00-MAPA-DOCUMENTAL.md`](metodologia/00-MAPA-DOCUMENTAL.md) — mapa documental do projeto
4. [`metodologia/01-COMO-A-IA-LE-ESTE-REPO.md`](metodologia/01-COMO-A-IA-LE-ESTE-REPO.md) — guia para o RAG
5. [`metodologia/02-INTEGRACAO-USEHBN.md`](metodologia/02-INTEGRACAO-USEHBN.md) — integracao com o usehbn
6. [`metodologia/03-PROTOCOLO-GLASSWING.md`](metodologia/03-PROTOCOLO-GLASSWING.md) — camada Glasswing aplicada

## Checkpoint de testes

Ultima execucao do gate consolidado: `VR_20260511_175849` (em
`auditoria/evidencias/V12.0.0204/`).

| Suite | Resultado | Build |
|---|---|---|
| V1 rapida | OK=171, FALHA=0 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| V2 Smoke | OK=34, FALHA=0, MANUAL=4 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| V2 Canonica | OK=24, FALHA=0 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| E2E Strikes | OK=76, FALHA=0 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| IntegridadeBase | OK=4, FALHA=0, MANUAL=1 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Onda23Adv | OK=27, FALHA=0 | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |

## Governanca publica

- Licenca: TPGL v1.1 (auto-conversao para Apache 2.0 em 4 anos)
- CLA: obrigatorio para contribuidores externos
- Politica de seguranca: `SECURITY.md`
- Camada preventiva: Glasswing G1-G5 documentada em
  `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
- Protocolo de governanca AI: HBN
  ([usehbn.org](https://usehbn.org)) — Credenciamento e o primeiro
  case study production-scale do HBN.

## Cadencia de update deste dashboard

Update obrigatorio a cada onda fechada. Quem fecha a onda atualiza:

1. Campo `ultima-atualizacao` (frontmatter)
2. Secao "Status atual" (build novo se houver)
3. Secao "Onda em curso" (proxima onda)
4. Tabela "Roadmap apos Onda N"

Ausencia de update bloqueia a abertura da proxima onda.
