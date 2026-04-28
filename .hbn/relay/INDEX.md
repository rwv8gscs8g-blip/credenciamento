---
titulo: Relay HBN — coordenacao inter-IA do Credenciamento
versao-protocolo: HBN 0.2.0
proprietario-bastao: Claude Opus 4.7 (sessao Cowork de 2026-04-28)
ciclo-ativo: SEM CICLO ATIVO (Onda 6 encerrada em 2026-04-28)
proxima-acao: aguardando mandato do Mauricio entre 4 opcoes (ver .hbn/results/0001-exec-onda06.json)
ultima-atualizacao: 2026-04-28
---

# Relay HBN — Credenciamento

## Bastao atual

| Campo | Valor |
|---|---|
| Proprietario | Claude Opus 4.7 (Cowork) |
| Concedido por | Luis Mauricio Junqueira Zanin |
| Data de concessao | 2026-04-28 |
| Validade | ate fechamento estavel da V12.0.0203 no GitHub |
| Reverte para | Codex (apoio) + Claude Opus em modo auditoria |
| Justificativa | retrabalho da Onda 5 nao estabilizada; concentracao em uma IA reduz risco de perda de contexto durante a estabilizacao |

## Ciclo ativo

**SEM CICLO ATIVO.** Onda 6 encerrada em 2026-04-28.

## Ciclo encerrado mais recente

| Campo | Valor |
|---|---|
| Ciclo | ONDA 6 — consolidacao documental + cleanup |
| Track HBN | safe_track |
| Status | ENCERRADO em 2026-04-28 |
| Readback | [readbacks/0001-onda06.json](../readbacks/0001-onda06.json) |
| Hearback | confirmed |
| ERP | [results/0001-exec-onda06.json](../results/0001-exec-onda06.json) |
| Resumo humano | [reports/0001-onda06-summary.md](../reports/0001-onda06-summary.md) |
| Doc tecnico | [auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md](../../auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md) |
| Commits | `85d7459` (conteudo) + `7e64622` (estrutural) |
| Ciclo origem | [relay/0001-onda06-consolidacao-documental.md](0001-onda06-consolidacao-documental.md) (sera arquivado em proxima abertura de ciclo) |

## Ondas previstas (a partir desta)

| Onda | Tema | Status |
|---|---|---|
| 6 | consolidacao documental + cleanup + integracao Diataxis/llms.txt/AGENTS.md/HBN | EM EXECUCAO |
| 5 (resgate) | homologacao final do form deterministico + Limpa_Base robusta (ja entregue, em homologacao manual) | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | PROXIMA APOS ONDA 6 |
| 8 | heuristica zero em todos os 13 forms | DEPOIS DA 7 |
| 9 | reescrita do Importador_VBA + auditoria de Mod_Types (com aprovacao explicita) | DEPOIS DA 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | DEPOIS DA 9 |

## Proxima acao explicita

Aguardando mandato do Mauricio entre 4 opcoes:

| # | Opcao | Custo | Recomendacao |
|---|---|---|---|
| A | Homologar Onda 5 manualmente no workbook (rodar trio minimo, validar Util_Filtro_Lista divergencia) | ~30 min do Mauricio | depois de C |
| B | Abrir Onda 7 (familia `IDM_*` + `RDZ_*` + script `glasswing-checks.sh`) | 1 sessao Claude Opus | depois de A |
| C | Commitar finalizacao HBN (mover relay -> archive + ERP + summary commitados) | 1 commit pequeno | **AGORA** — fecha o ciclo |
| D | Push das 3 ondas para origin/codex/v12-0-0203-governanca-testes | 30 segundos | depois de B verde |

**Recomendacao minha:** C → A → B → D, nessa ordem.

## Standard HBN markers

Esta sessao usa os marcadores visiveis do adapter HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `❌ HBN SECURITY BLOCKED SUGGESTION` — gate de seguranca
- `🟡 HBN NEEDS HUMAN DECISION` — aprovacao requerida
