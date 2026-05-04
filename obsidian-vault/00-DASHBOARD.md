---
titulo: Dashboard - Credenciamento
ultima-atualizacao: 2026-04-28
autor-ultima-alteracao: Claude Opus 4.7 (Cowork) na Onda 6
tags: [vivo, dashboard, hbn-active]
versao-sistema: V12.0.0202
linha-alvo: V12.0.0203
build-importado-no-workbook: f7aa84f+ONDA05-em-homologacao
hbn-track: fast_track
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
| Versao oficial vigente | **V12.0.0202** (validada) |
| Linha em estabilizacao | V12.0.0203 |
| Build importado no workbook | `f7aa84f+ONDA05-em-homologacao` |
| Tag git de salvaguarda | `pre-onda-06-2026-04-28` |
| Branch ativa | `codex/v12-0-0203-governanca-testes` |
| Bastao de implementacao | Claude Opus 4.7 (Cowork) — ate V12.0.0203 estavel no GitHub |
| Ambiente | Windows 10+, Excel 2019/2021/365 |
| Planilha homologacao | `PlanilhaCredenciamento-Homologacao.xlsm` |

## Onda em curso

**Onda 6 — Consolidacao documental + cleanup + integracao HBN/Diataxis/llms.txt/AGENTS.md/Glasswing**

- Status: EM EXECUCAO (em fechamento)
- Track HBN: safe_track
- Hearback: confirmed
- Doc tecnica: `auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md`
- Readback: `.hbn/readbacks/0001-onda06.json`
- Sem alteracao de codigo VBA (doc-only)

## Roadmap apos Onda 6

| Onda | Tema | Status |
|---|---|---|
| 5 (residual) | homologacao do form deterministico + Limpa_Base robusta | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | proxima apos 6 |
| 8 | heuristica zero em todos os 13 forms | depois da 7 |
| 9 | reescrita Importador_VBA + auditoria Mod_Types | depois da 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | depois da 9 |

## Documentos canonicos (pos-Onda 6)

### Para IAs
1. [`AGENTS.md`](../AGENTS.md) — entrada canonica
2. [`.hbn/relay/INDEX.md`](../.hbn/relay/INDEX.md) — bastao + ciclo ativo
3. [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../.hbn/knowledge/0001-regras-v203-inegociaveis.md) — 10 regras
4. [`.hbn/knowledge/0002-regra-ouro-vba-import.md`](../.hbn/knowledge/0002-regra-ouro-vba-import.md) — Regra de Ouro
5. [`.hbn/knowledge/0003-glasswing-style-preventive-security.md`](../.hbn/knowledge/0003-glasswing-style-preventive-security.md) — 5 vetores Glasswing

### Para humanos (Diataxis)
1. `docs/tutorials/` — aprender (passo-a-passo)
2. `docs/how-to/` — cookbook (importar pacote, rodar testes, gerar evidencia)
3. `docs/reference/` — consulta (regras, API VBA, governanca)
4. `docs/explanation/` — entender (arquitetura, decisoes, racional)

### Para LLMs (RAG)
1. [`llms.txt`](../llms.txt) — mapa curado
2. [`llms-full.txt`](../llms-full.txt) — indice exaustivo

### Vitrine institucional
1. [`releases/STATUS-OFICIAL.md`](releases/STATUS-OFICIAL.md) — status oficial das versoes
2. [`releases/V12.0.0202.md`](releases/V12.0.0202.md) — release validada atual
3. [`metodologia/00-MAPA-DOCUMENTAL.md`](metodologia/00-MAPA-DOCUMENTAL.md) — mapa documental do projeto
4. [`metodologia/01-COMO-A-IA-LE-ESTE-REPO.md`](metodologia/01-COMO-A-IA-LE-ESTE-REPO.md) — guia para o RAG
5. [`metodologia/02-INTEGRACAO-USEHBN.md`](metodologia/02-INTEGRACAO-USEHBN.md) — integracao com o usehbn
6. [`metodologia/03-PROTOCOLO-GLASSWING.md`](metodologia/03-PROTOCOLO-GLASSWING.md) — camada Glasswing aplicada

## Checkpoint de testes

Ultima execucao do trio minimo: `VR_20260426_111549` (em
`auditoria/04_evidencias/V12.0.0203/`).

| Suite | Resultado | Build |
|---|---|---|
| V1 rapida | OK=171, FALHA=0 | 88107f1 (anterior a Ondas 1-5) |
| V2 Smoke | OK=14, FALHA=0 | 88107f1 |
| V2 Canonica | OK=20, FALHA=0 | 88107f1 |

> **Nota:** o trio minimo precisa ser re-executado contra
> `f7aa84f+ONDA05-em-homologacao` para ratificar Ondas 1-5. Esse e o
> primeiro gate da Onda 7.

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
