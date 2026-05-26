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

## ⚠️ Atenção — janela de melhoria do protocolo entre sessões

Entre o handoff (2026-05-26 11:18) e esta retomada, **outra sessão Opus
executou manualmente** `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`
e evoluiu o prompt para **v1.3** (incorpora auto-evolução do protocolo a
cada handoff — §7.3 + Passo 5 do §7 + passo F do §2 pré-flight). Antes
de seguir o roteiro do handoff cegamente:

1. **OBRIGATÓRIO**: leia o PROMPT_ARQUITETO v1.3 (em particular §7.3) e
   internalize que esta sessão, ao produzir SEU handoff de fim-de-sessão,
   produzirá também `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda<N>-proposals.md`
   no Credenciamento, com 1-3 micro-evoluções atômicas observadas durante
   o trabalho. Sem esse arquivo, o 🔵 HBN HANDOFF READY é incompleto.
2. Compare o estado atual de `.hbn/knowledge/` com a versão do handoff
   (`git log --oneline -- .hbn/knowledge/` desde commit `9e2fe83`).
3. Releia AGENTS.md e knowledges 0013–0016 (e qualquer 0017+ novo).
4. Se houver mudanças estruturais no protocolo (novo formato de readback,
   novo guard, nova convenção de scope, etc.), **ajuste o plano do item 13**
   do handoff antes de entregar os prompts a Mauricio. Os prompts 13.B e
   13.C podem precisar ser regenerados com a nova convenção.
5. Se nada mais mudou além do PROMPT_ARQUITETO v1.3, prossiga normalmente.

Não há urgência em "agarrar-se" ao handoff anterior — o objetivo é
manter coerência arquitetural com o estado atual do protocolo.

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
- HEAD no commit da onda **0110** (evolução manual do protocolo v1.3 +
  knowledge 0017), sucessor do `d03de55`. Push já realizado pelo Mauricio
  antes desta sessão começar.
- Working tree limpo
- 5/5 guards verdes

## Estado consolidado ao iniciar

**Fechadas até aqui:** 38.2.1 + 38.2.1-AR1 + 38.2.1-AR1-FIX2-PERF.

**Findings ativos:**
- F1, F2, F5 → ✅ RESOLVIDOS
- F-NEW3 (cosmético — ID 5 sem padding) → Onda 38.2.2
- F-NEW4 (performance parcial ~2×) → Onda 38.2.2 + V207
- F-NEW4-DT (testes E2E de cadastros) → V207

## Passo 0 — Fechar o ERP da onda 0110 (~1 min, antes de qualquer outra coisa)

A onda 0110 (evolução do protocolo v1.3 + knowledge 0017) foi commitada
pelo Mauricio antes desta sessão começar, mas ficou sem ERP. Crie o
arquivo `.hbn/results/0110-exec-evolucao-protocolo-v13.json` registrando:
commit hash do push, output dos 5 guards passando, output do `git log -1`.
Modelo: usar o `0107-exec-handoff-fim-sessao-opus.json` como referência
de schema para ERP de fast_track doc-only. Depois confirmar `human_status`
em chat com Mauricio (1 frase). Custo: ~1% de contexto.

## Sua primeira ação (depois do Passo 0)

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

Aplicar `knowledge/0014-protocolo-fim-de-sessao` + §7 Passo 5 do
PROMPT_ARQUITETO v1.3 — produzir TRÊS artefatos antes de assinar 🔵:

1. **Handoff operacional**: `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md`
   (12 itens conforme schema knowledge 0014).
2. **Prompt de retomada**: `auditoria/00_status/109_PROMPT_RETOMADA_SESSAO_OPUS.md`
   (mesma estrutura deste 108, atualizado com estado novo).
3. **Proposta de evolução do protocolo** (NOVO em v1.3 — §7.3):
   `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda<N>-proposals.md` com 1-3
   micro-evoluções atômicas observadas nesta sessão. Se nenhuma evolução
   for proposta, criar o arquivo mesmo assim com `## 1. Lições novas:
   nenhuma` e `## 2. Propostas: nenhuma` — ausência registrada é válida;
   esquecer o arquivo é falha de protocolo.

**Orçamento de contexto sugerido** (lição desta sessão arquiteta):

- ~50% do contexto: trabalho substantivo (entrega prompts 13.B/13.C,
  deep-dive PHAGOCYTOSIS, consolidação parcial se as 4 propostas
  chegarem dentro da sessão).
- ~30% do contexto: redação dos 3 artefatos de handoff acima.
- ~20% do contexto: buffer para qualquer ajuste último-minuto pedido por
  Mauricio em chat.

Lição registrada por Mauricio: handoff a 50% melhora qualidade de
análise. **Não esperar fadiga.** A sessão anterior fechou a 90% e
produziu este handoff sob pressão — repetir o mesmo padrão é regressão.

---PROMPT---

## Referências

- Handoff origem: [`.hbn/messages/20260526-1118-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260526-1118-handoff-fim-sessao-opus.md)
- ERP último fechado: [`.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json`](../../.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json)
- Doc técnico: [`auditoria/03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md`](../03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md)
- Relay: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
