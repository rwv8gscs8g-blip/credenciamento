---
titulo: Onda 36.1 — Formalização do protocolo de fim-de-sessão como knowledge 0014
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
autor: claude-opus-4-7
papel: arquiteto-principal (primeira iteração manual do PROMPT_ARQUITETO_USEHBN_AUTONOMO)
---

# Onda 36.1 — Knowledge 0014 (protocolo fim-de-sessão)

## Origem

Sessão Opus de 2026-05-24 que rodou as Ondas 36, 37, 37.1, 37.2, 37.3, 37.4
consumiu ~13 horas de chat sem produzir handoff formal entre transferências
de bastão (Codex → Opus em 37.3, Opus → Codex em 37.4+). Recuperação de
contexto na crise de compile dependeu de memória humana e re-leitura ad-hoc
de ~15 documentos.

Esse gap virou o item A2 do backlog do `PROMPT_ARQUITETO_USEHBN_AUTONOMO`
(criado na sessão de 2026-05-24). Mauricio ativou manualmente o prompt em
2026-05-25 00:45 BRT para primeira iteração real, e Opus selecionou A2 por:

- ser pré-requisito de A3 (CI semanal) e A4 (revisão de bypasses);
- ter baixo risco (zero código VBA tocado);
- endereçar gap concreto vivido na sessão imediatamente anterior;
- ter escopo disjunto da Onda 38 (em paralelo sob bastão Codex).

## O que foi feito

1. `.hbn/knowledge/0014-protocolo-fim-de-sessao.md` — regra permanente em
   96 linhas (limite 100), estrutura fixa (Regra / Gatilhos / Conteúdo
   mínimo / Aplicação inicial / Como evoluir).
2. `AGENTS.md` — 1 linha nova inserida após item 0013 na lista de leitura
   obrigatória; renumeração simples de 16 → 17 itens.
3. Este documento técnico (≤50 linhas planejadas).
4. **Auto-aplicação imediata** (gate 4 do readback 0095): handoff real desta
   sessão Opus em `.hbn/messages/20260525-XXXX-handoff-fim-sessao-opus.md`
   antes de fechar ERP 0095.

## Gates passados

| Gate | Status | Evidência |
|---|---|---|
| G1: knowledge ≤ 100 linhas, estrutura fixa | pass | 96 linhas |
| G2: AGENTS.md atualizado | pass | nova linha entre 0013 e 105 |
| G3: zero diff em paths proibidos | pass | git diff confirma |
| G4: handoff real produzido (auto-aplicação) | pass | `.hbn/messages/20260525-*` |
| G5: CHANGELOG atualizado | pass | entrada Onda 36.1 |

## Bastão após esta onda

Continua com Opus (em modo `audit-only` / pausa) e com Codex (executor da
Onda 38 em paralelo). Próxima ativação manual do prompt arquiteto: quando
Mauricio decidir. Backlog A3 (CI semanal) ou A4 (revisão bypasses) são os
próximos candidatos naturais.

## Referências

- `.hbn/knowledge/0014-protocolo-fim-de-sessao.md`
- `.hbn/readbacks/0095-onda36-1-knowledge-0014-fim-sessao.json`
- `.hbn/results/0095-exec-onda36-1-knowledge-0014-fim-sessao.json`
- `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` §4 Backlog
- `auditoria/00_status/105_*` (auditoria-mãe Onda 36)
