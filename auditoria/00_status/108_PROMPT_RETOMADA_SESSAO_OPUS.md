# Prompt de retomada — sessão Opus 4.7 sucessora (pós-handoff 0108)

> Copie e cole o bloco abaixo no primeiro turno da próxima sessão Opus.

---

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo a continuidade do bastão V12.0.0206 do
Sistema de Credenciamento. A sessão anterior (2026-05-26 ~10:00 → 11:18,
~1h20) fechou a Onda 38.2.1-AR1-FIX2-PERF com gate humano APROVADO e
produziu este handoff. Bastão **permanece com você**.

**Raiz canônica:** `/Users/macbookpro/Projetos/Credenciamento`
**Branch:** `codex/v12-0-0206-planejamento`
**Data de retomada:** próxima janela útil
**Anchor funcional V206:** commit `ee75b30` + workbook em build
`ad5b487+ONDA38.2.1-AR1-FIX2-PERF` + RVS Trio APROVADO `VR_20260526_102200`

## Leitura obrigatória inicial (na ordem)

1. `.hbn/relay/INDEX.md` — estado vivo
2. `.hbn/messages/20260526-1118-handoff-fim-sessao-opus.md` — handoff
   completo (12 itens + auditoria cruzada item 13)
3. `.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json` — ERP da
   última onda, contém findings F-NEW3/F-NEW4/F-NEW4-DT
4. `.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md` — handoff
   anterior (item 13 análise técnica F4/F5)
5. `.hbn/knowledge/0014-protocolo-fim-de-sessao.md`
6. `.hbn/knowledge/0015-readback-opening-bootstrap.md`
7. `.hbn/knowledge/0016-bump-build-label-anti-conflito.md`
8. `auditoria/03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md`
9. `AGENTS.md` + `CLAUDE.md`

Verifique o estado:

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -8 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

Esperado:
- HEAD em commit de handoff (push já feito até `067f2dc`)
- Working tree limpo
- 5/5 guards verdes

## Estado consolidado ao iniciar

**Fechadas até aqui:** 38.2.1 + 38.2.1-AR1 + 38.2.1-AR1-FIX2-PERF.

**Findings ativos:**
- F1, F2, F5 → ✅ RESOLVIDOS
- F-NEW3 (cosmético — ID 5 sem padding) → Onda 38.2.2
- F-NEW4 (performance parcial ~2×) → Onda 38.2.2 + V207
- F-NEW4-DT (testes E2E de cadastros) → V207

## Sua primeira ação (não é implementação)

**Entregue os 2 prompts da auditoria cruzada ao Mauricio** (textos prontos
no item 13.B e 13.C do handoff `.hbn/messages/20260526-1118-handoff-
fim-sessao-opus.md`):

1. **Prompt para Codex** — auditoria de código V206 + 3 propostas V207
   (foco em código, performance, idempotência, testes).
2. **Prompt para Antigravity/Gemini** — auditoria sistêmica V206 + 3
   propostas V207 (foco em visão SaaS, documentação, auditoria, migração).

Mauricio abre as 2 sessões em paralelo. As IAs auxiliares produzem 4
arquivos `.md` em `.hbn/proposals/0001-0004-*`. Você consolida quando
voltarem.

## Em paralelo (opcional, NÃO bloqueia auditoria)

Pode iniciar **deep-dive PHAGOCYTOSIS-VBA-PATTERNS** lendo capítulos
M9, L22, L23, L24, M15, M16, M17 em
`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`. Esse pré-trabalho é
obrigatório antes da Onda 38.2.2 (filtros nativos + envelopamento
.frm + fix F-NEW3).

A Onda 38.2.2 pode rodar em paralelo à auditoria cruzada (escopo V206,
não V207). Filtros + .frm performance + F-NEW3 são todos V206 puro.

## Restrições inalteradas

- ✅ HBN ACTIVE
- Bastão com Claude Opus 4.7 até freeze V12.0.0206
- Codex retorna como auditor adversarial pós-implementação
- Sequência: readback (PENDING) → hearback (confirmed) → execução → commit
- Não tocar **em ondas V206**: `Mod_Types.bas`, `Importador_V3.bas`,
  `Svc_*` blindados (`Svc_Rodizio`, `Svc_Avaliacao`, `Svc_OS`, `Svc_PreOS`,
  `Svc_Entidade`, `Svc_Transacao`), `local-ai/incoming/**`
- **Para V207 (refatoração)**: os tabus acima estão LIBERADOS apenas
  para análise/proposta nas 6 propostas (Codex + Antigravity) — NÃO
  para implementação direta.
- Importação operacional somente via `ImportarPacoteV3_Delta` (jamais
  completo)
- Knowledge 0016 vigente: deixar `App_Release.bas` no estado da onda
  anterior; deixar o Importador V3 fazer o BUMP

## Quando atingir ~40-50% de contexto

Aplicar `knowledge/0014-protocolo-fim-de-sessao` — produzir novo handoff
em `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md` e novo
prompt em `auditoria/00_status/109_PROMPT_RETOMADA_SESSAO_OPUS.md`.

Lição registrada por Mauricio: handoff a 50% melhora qualidade de
análise. Não esperar fadiga.

---PROMPT---

## Referências

- Handoff origem: [`.hbn/messages/20260526-1118-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260526-1118-handoff-fim-sessao-opus.md)
- ERP último fechado: [`.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json`](../../.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json)
- Doc técnico: [`auditoria/03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md`](../03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md)
- Relay: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
