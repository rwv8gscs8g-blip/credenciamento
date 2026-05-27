---
titulo: Evolução do protocolo HBN — Onda 0112 — Cadência D Estendida / passagem de bastão (PROMPT_ARQUITETO v1.4)
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Onda 0112 — Cadência D Estendida (passagem de bastão entre IAs)

> Registro exigido pela §11 do `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`: toda
> mudança no prompt mestre (que vive fora do repo, em `/Users/macbookpro/Projetos/`)
> é registrada aqui, no Credenciamento como casa-mãe do protocolo.

## Gatilho

Mauricio pediu (chat 2026-05-27) uma nova onda do PROMPT_ARQUITETO com ações
ligadas à **melhoria da passagem de bastão entre as IAs**, consumindo como input
o doc `120_SUGESTOES_EVOLUCAO_PROTOCOLO_HBN.md` (10 propostas P1-P10 da Opus,
pós-auditoria cruzada Codex 0012 + Gemini/Antigravity 0011).

## Decisões (hearback Mauricio 2026-05-27)

Via AskUserQuestion + confirmação explícita das 3 perguntas abertas:

1. **P1 modificada** — implementador **por onda** (continuidade preferencial < 50%
   contexto + handoff entre ondas), **não** implementador único por ciclo inteiro.
2. **P7 renomeada** — severidade de auditoria **BLOQUEADOR / FORTE / MARGINAL**
   (evita colisão com os vários "P0" já existentes).
3. **Roteamento meta-protocolo** — Cadência vive no **PROMPT_ARQUITETO §12 +
   knowledge 0019**; `AGENTS.md`/`CLAUDE.md` apenas apontam.

Veredito completo por proposta em
`.hbn/protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md`.

## Mudanças aplicadas (onda fast_track doc-only)

| # | Arquivo | Mudança |
|---|---|---|
| 1 | `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` | v1.3 → **v1.4**: §12 (Cadência D Estendida) + §12.A (template auditoria) + §12.B (prompt de entrada chat novo) + changelog + bump do header |
| 2 | `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md` | NOVO — Tier 1 canônico (P1 mod, P2, P3, P4, P6, P7 + equivalência de severidade) |
| 3 | `.hbn/knowledge/0020-explore-diff-cosmetico-suspeito.md` | NOVO — L44 (P5) |
| 4 | `.hbn/knowledge/INDEX.md` | linhas 0019 e 0020 + bump de data |
| 5 | `AGENTS.md` | ponteiro 9b → knowledge 0019 |
| 6 | `CLAUDE.md` | ponteiro item 6 → knowledge 0020 |
| 7 | `auditoria/00_status/120_*.md` | status → CONSOLIDADO |
| 8 | `.hbn/relay/INDEX.md` | bloco da onda 0112 |
| 9 | `.hbn/readbacks/0112-*.json` + `.hbn/results/0112-exec-*.json` | readback confirmed + ERP |

## Invariantes preservados

Nenhum código de domínio tocado. Anchor V206 funcional (`ee75b30`) intacto.
Knowledges 0001-0018 inalteradas. Decisão A vs B da Onda 38.2.2 e abertura da
38.2.3 não tocadas por esta onda (linha separada).

## Sucessor

Onda **0113** (aberta na mesma sessão, pendente de hearback) operacionaliza a
passagem de bastão: detalhamento do prompt de entrada §12.B por papel, template
de **registro de transferência de bastão**, e plano de teste empírico da P9 na
Onda 38.2.3.
