---
titulo: Cadência D Estendida — passagem de bastão entre IAs (meta-protocolo transversal)
diataxis: reference
status: accepted
temperatura: quente
data: 2026-06-10
autoria: claude-fable-5 (corrente C4), promovido do PROMPT_ARQUITETO v1.6 §12 (Opus, onda 0112, hearback Maurício 2026-05-27)
origem: auditoria/00_status/120 (Credenciamento) consolidado em .hbn/protocol-evolutions/20260527-1300
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
---

# Cadência D — papéis, auditoria cruzada e severidades

Meta-protocolo transversal a todos os projetos. Casa canônica: este arquivo.
`AGENTS.md`/`CLAUDE.md` dos projetos apenas apontam para cá — nunca duplicam
(anti-padrão da cópia divergente, incidente 2026-05-24).

## Papéis por ciclo de estabilização (P1, modificada)

1 IMPLEMENTADOR por onda (continuidade preferencial enquanto o contexto não
excede o `handoff_threshold` do perfil do modelo — ADR-015, default 0.5;
handoff obrigatório ao exceder — em chat novo + handoff escrito). 2 AUDITORES
CRUZADOS em contexto novo a cada gate relevante. Humano (Maurício): hearback
final + executor operacional. Invioláveis: implementador NÃO audita o próprio
trabalho; auditores NÃO implementam; implementador propõe evoluções,
auditores arbitram; Maurício decide empates.

## Auditoria SEMPRE em chat novo (P2)

A auditora não retoma chat onde já trabalhou: chat novo = capacidade máxima +
olhar fresco, reconstrução por `Read` dos paths canônicos (read-list do
`core/relay-spec.md`). Honestidade técnica: chat novo reduz mas não elimina
viés de mesma família de pesos — por isso 2-3 auditores + checklist anti-viés.

## Gates intra-onda (P3 — recomendado)

3 a 6 sub-fases auditáveis por marco lógico, cada uma com commit local e
output auditável. <3 = monólito (regressão silenciosa); >6 = micro-gestão.

## Checklist anti-viés de bastão (P4)

Ao recomendar "a quem passar o bastão", a IA DEVE: (1) declarar se há
auto-indicação; (2) listar evidência objetiva; (3) reconhecer o viés natural;
(4) sugerir mitigações. Estrutural: 3 recomendadores independentes; o humano
pesa evidência acima de auto-avaliação (observado 2026-05-27: Codex,
Antigravity e Opus, cada um, preservou a própria relevância).

## Severidade e veto (P7)

| Severidade | Significado | Obrigação do implementador |
|---|---|---|
| BLOQUEADOR | segurança, correção, regressão | NÃO prossegue até resolver (veto) |
| FORTE | qualidade, manutenibilidade | incorpora OU justifica por escrito |
| MARGINAL | nice-to-have | pode ignorar |

Conflito BLOQUEADOR×BLOQUEADOR entre auditores → humano decide; nenhuma IA
sobrescreve o BLOQUEADOR de outra.

## Proposals (P6) e auditoria curta (P9)

Proposals: `NNNN-<ia>-<tema>.md` em `.hbn/proposals/` (série local, ADR-011).
Auditoria curta (1 IA, <1000 palavras) segue EM TESTE, não vigente — critério
de promoção registrado (zero BLOQUEADOR/FORTE perdidos em ≥2 gates); default
é cruzada plena.

## Template de output de auditoria (ex-§12.A)

`# Auditoria cruzada — GATE-<ID> — por <IA> (chat novo)` com seções:
1 Veredito (APROVAR / APROVAR com FORTE incorporados / BLOQUEAR + 1 frase) ·
2 BLOQUEADORES (descrição+evidência+remediação) · 3 FORTES · 4 MARGINAIS ·
5 Convergências · 6 Divergências · 7 Riscos não cobertos · 8 Próxima ação
(indicação de bastão ⇒ checklist anti-viés).

## Prompts de entrada por papel (ex-§12.B)

Os três papéis (implementador que retoma, auditor cruzado, consolidador/
árbitro) entram em chat novo e leem a read-list do `core/relay-spec.md`
(STATE → handoff → readback → contrato do papel em `agents/role-templates.md`
→ invariante sempre-quente). Auditor produz no template acima; consolidador
tabula convergências/BLOQUEADORES e escala empates ao humano.
