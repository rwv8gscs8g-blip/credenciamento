---
titulo: Onda 0113 — Operacionalizar a passagem de bastão (PROMPT_ARQUITETO v1.5)
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Onda 0113 — Operacionalizar a passagem de bastão

> Registro §11 do PROMPT_ARQUITETO. Sucessora da onda 0112 (que definiu a
> Cadência D Estendida). Esta onda produz as ferramentas operacionais para
> devolver o bastão às IAs com o processo estruturado e consistente.

## Gatilho

Mauricio autorizou (chat 2026-05-27): "Confirmo as três perguntas, pode abrir
mais uma onda de bastão antes de devolver para as IAs."

## Hearback das 2 perguntas abertas (2026-05-27)

1. **Fundir** o registro de transferência de bastão no handoff de fim-de-sessão
   (knowledge 0014) — **não** criar artefato 0021 separado.
2. **Concorda** com o critério objetivo de promoção da P9.

## Mudanças aplicadas (fast_track doc-only)

| # | Arquivo | Mudança |
|---|---|---|
| E1 | `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` | v1.4 → **v1.5**: §12.B expandido por papel (§12.B1 implementador, §12.B2 auditor, §12.B3 consolidador) + changelog + bump header |
| E2 | `.hbn/knowledge/0014-protocolo-fim-de-sessao.md` | itens 13-16 (papel, evidência de quem recebe, checklist anti-viés §12.4, prompt de entrada do sucessor) quando gatilho = bastão — **fusão** decidida por Mauricio |
| — | `.hbn/knowledge/INDEX.md` | linha 0014 atualizada (registro de transferência de bastão) |
| — | `auditoria/00_status/122_*.md` | este registro |
| — | `.hbn/relay/INDEX.md` | bloco da onda 0113 |
| — | `.hbn/readbacks/0113-*.json` + `.hbn/results/0113-exec-*.json` | confirmed + ERP |

## Critério objetivo de promoção da P9 (auditoria curta) — APROVADO

Experimento na **Onda 38.2.3**: escolher gates de severidade-máxima-MARGINAL e
rodar **auditoria curta (1 IA, < 1000 palavras) em paralelo a uma cruzada plena**
no mesmo gate. Métrica: nº de achados **BLOQUEADOR/FORTE** que a curta perdeu
em relação à plena.

- **Promover P9** se: **zero** achados BLOQUEADOR/FORTE perdidos pela curta em
  **≥ 2 gates** testados.
- **Rejeitar P9** caso contrário (decisão limpa, sem limbo).

Registrar o resultado no readback da Onda 38.2.3 e no `.hbn/protocol-evolutions/`
da sessão correspondente.

## Invariantes preservados

Nenhum código de domínio tocado. Cadência da onda 0112 (§12 + knowledge 0019)
não alterada — apenas detalhada (§12.B) e instrumentada. Handoff 0014 preservado
e estendido (retrocompatível). Decisão A vs B da 38.2.2 e abertura da 38.2.3 não
tocadas.

## Estado de devolução do bastão às IAs

Com 0112 + 0113 aplicadas, o protocolo tem: papéis e separação (§12.1),
auditoria em chat novo com prompts por papel (§12.2, §12.B1-B3), gates intra-onda
(§12.3), checklist anti-viés (§12.4), severidade + veto (§12.5), numeração de
proposals (§12.6), template de output (§12.A) e registro de transferência de
bastão (knowledge 0014 itens 13-16). **Pronto para devolver o bastão às IAs.**
