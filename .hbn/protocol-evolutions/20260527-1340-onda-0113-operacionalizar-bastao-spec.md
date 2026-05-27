---
titulo: Onda 0113 — Operacionalizar a passagem de bastão (ferramentas prontas para devolver o bastão às IAs)
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
autoria: claude-opus-4-7 (modo ARQUITETO — sessão Cowork 2026-05-27 ~13:40 BRT)
gatilho: Mauricio autorizou abrir mais uma onda de bastão antes de devolver o bastão às IAs, para que o processo esteja estruturado e consistente
predecessor: onda 0112 (PROMPT_ARQUITETO v1.4 §12 Cadência D Estendida)
readback-associado: .hbn/readbacks/0113-operacionalizar-passagem-bastao.json
status: CONSOLIDADO — hearback Mauricio 2026-05-27. Pergunta 1: FUNDIR no handoff 0014 (não criar 0021). Pergunta 2: critério P9 APROVADO. Aplicado em PROMPT_ARQUITETO v1.5 + knowledge 0014 (itens 13-16) + auditoria 122.
---

# Onda 0113 — Operacionalizar a passagem de bastão

> A onda 0112 definiu a **cadência** (papéis, chat novo, severidade, veto,
> anti-viés). Esta onda 0113 produz as **ferramentas operacionais** que tornam a
> cadência usável sem improviso quando o bastão voltar às IAs (Codex
> implementador + Opus/Antigravity auditores cruzados). Sem isto, cada IA
> reinventa o formato a cada transferência — exatamente a fricção que o protocolo
> combate.
>
> Como a onda 0112, esta **não edita o protocolo neste turno** — propõe o texto e
> aguarda hearback.

## Problema concreto que esta onda resolve

Hoje, ao passar o bastão de uma IA para outra, existem dois artefatos parciais:
o **handoff de fim-de-sessão** (knowledge 0014, foco em "minha sessão acabou") e
o **prompt de entrada de auditoria** (§12.B, genérico). Falta:

1. Um **prompt de entrada por papel** — implementador que retoma ≠ auditor
   cruzado ≠ consolidador. Hoje é um só, genérico.
2. Um **registro de transferência de bastão** específico para quando o **papel
   muda de IA-para-IA** — com o checklist anti-viés (§12.4) preenchido, não só
   prosa. O handoff 0014 cobre "fim de sessão", não "troca de papel/IA".
3. Um **plano de teste empírico da P9** (auditoria curta), para que a decisão de
   promover ou rejeitar P9 seja baseada em dados da Onda 38.2.3, não em opinião.

## Entregáveis propostos (a aplicar SÓ após hearback)

### E1 — §12.B expandido por papel (no PROMPT_ARQUITETO)

Substituir o §12.B genérico por três variantes de prompt de entrada de chat
novo, cada uma apontando para os paths canônicos a ler por `Read`:

- **§12.B1 — Implementador que retoma uma onda**: lê relay/INDEX → último ERP →
  readback da onda ativa → knowledge de domínio (PHAGOCYTOSIS por tabela
  CLAUDE.md) → confirma orçamento de contexto (0017) antes de tocar arquivo.
- **§12.B2 — Auditor cruzado** (já existe em forma genérica; vira a variante de
  auditoria): lê relay/INDEX → ERP/readback → diff alvo → knowledge 0019;
  produz no template §12.A com BLOQUEADOR/FORTE/MARGINAL; não implementa.
- **§12.B3 — Consolidador/árbitro** (papel da Opus ao reunir 2 auditorias): lê
  os N outputs de `.hbn/proposals/` → tabula convergências/divergências →
  aplica checklist anti-viés §12.4 a qualquer recomendação de bastão → produz
  consolidação em `auditoria/00_status/NNN_*`.

### E2 — knowledge 0021: Registro de transferência de bastão

Novo `.hbn/knowledge/0021-registro-transferencia-bastao.md` define o template
abaixo, preenchido **toda vez que o papel/IA muda** (distinto do handoff 0014 de
fim-de-sessão). Caminho do artefato:
`.hbn/messages/AAAAMMDD-HHmm-bastao-<de>-para-<para>.md`.

```markdown
# Registro de transferência de bastão — <de> → <para>

**Data/hora**: AAAA-MM-DD HH:MM BRT
**Papel transferido**: implementador | auditor cruzado | consolidador
**Onda**: <ID e tema>
**Orçamento de contexto na origem**: <~N% — knowledge 0017>

## 1. Estado objetivo (não opinião)
- Último ERP: <path>
- Readback ativo: <path> (human_status: …)
- Sinais HBN abertos: <🟡/🟠/🔵/❌ …>

## 2. Próxima ação única para quem recebe
<1 frase acionável>

## 3. Checklist anti-viés de bastão (§12.4) — OBRIGATÓRIO
- [ ] Esta recomendação inclui auto-indicação? (sim/não — qual)
- [ ] Evidência objetiva que sustenta a escolha de quem recebe: <…>
- [ ] Viés natural reconhecido: <…>
- [ ] Mitigação sugerida: <…>

## 4. Paths a ler por Read ao assumir (chat novo)
<lista>

🔵 HBN BASTÃO TRANSFERIDO — <de> → <para>
```

### E3 — Plano de teste empírico da P9 (auditoria curta)

Registrar no readback da Onda 38.2.3 (quando abrir) um experimento controlado:
escolher **1 gate de severidade-máxima-MARGINAL** e rodar auditoria curta (1 IA,
< 1000 palavras) em paralelo a uma cruzada plena no mesmo gate; comparar se a
curta perdeu algum achado que a plena pegou. **Métrica objetiva**: nº de achados
BLOQUEADOR/FORTE perdidos pela curta. Critério de promoção da P9: **zero
achados BLOQUEADOR/FORTE perdidos** em ≥ 2 gates testados. Caso contrário,
rejeitar P9.

## Veredito de escopo

- E1, E2 = Tier 1 operacional (entram em PROMPT_ARQUITETO §12.B + knowledge 0021).
- E3 = instrução para a Onda 38.2.3 (não é regra vigente; é desenho de experimento).

## O que esta onda NÃO faz

- Não edita o protocolo neste turno (só após hearback).
- Não toca código de domínio.
- Não abre a Onda 38.2.3 nem decide A vs B (linha separada).
- Não promove a P9 — apenas instrumenta o teste dela.

## Pergunta aberta para Mauricio (hearback)

1. O **registro de transferência de bastão** (E2) deve ser **artefato separado**
   do handoff de fim-de-sessão (0014), como proposto, ou prefere **fundir** os
   dois num só template para reduzir nº de arquivos?
2. Concorda com o critério objetivo de promoção da P9 (zero BLOQUEADOR/FORTE
   perdidos em ≥ 2 gates)?

## Sinal HBN

🔵 HBN HANDOFF READY — onda 0113 aberta; aguardando hearback de Mauricio em
`.hbn/readbacks/0113-operacionalizar-passagem-bastao.json`.
