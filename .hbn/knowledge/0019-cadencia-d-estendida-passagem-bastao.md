---
titulo: Cadência D Estendida — passagem de bastão entre IAs
data: 2026-05-27
autoria: claude-opus-4-7 (arquiteto, onda 0112)
aplica-a: toda IA que implementa, audita ou participa de transferência de bastão neste projeto
revisar-em: 2026-07-01 (após ≥ 2 ondas de uso real)
hbn-track: fast_track
hbn-status: knowledge
audiencia: ambos
versao-sistema: V12.0.0206
---

# Cadência D Estendida — passagem de bastão entre IAs

> Knowledge canônico (Tier 1) que materializa a §12 do
> `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`. O PROMPT_ARQUITETO é a doutrina
> transversal; este arquivo é a regra permanente **deste projeto**. `AGENTS.md`
> aponta para cá; não duplica a regra.
>
> Origem: doc `auditoria/00_status/120_SUGESTOES_EVOLUCAO_PROTOCOLO_HBN.md`
> consolidado na onda 0112 (decisão em
> `.hbn/protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md`).

## Regra

Em estabilização pré-release público de alto risco de regressão, a operação
multi-IA segue a Cadência D Estendida.

### 1. Papéis (P1)

- **1 implementador por onda**, com continuidade preferencial enquanto < 50% de
  contexto (knowledge 0017). Handoff de implementador obrigatório entre ondas se
  o orçamento estourar — em chat novo + handoff escrito.
- **2 auditores cruzados em contexto novo** a cada gate relevante.
- **Mauricio**: hearback final + executor operacional.
- Implementador não audita o próprio trabalho; auditores não implementam;
  implementador propõe evoluções, auditores arbitram; Mauricio decide empates.

> Nota de decisão: rejeitamos "1 implementador único para o ciclo inteiro (3+
> ondas)" — recria fadiga e cria bus factor. Continuidade é preferência, não amarra.

### 2. Auditoria sempre em chat novo (P2)

Auditoria cruzada começa em chat novo; a auditora reconstrói estado por `Read`
(nunca por memória) usando o prompt de entrada §12.B do PROMPT_ARQUITETO. Output
único persistente em `.hbn/proposals/`, no template §12.A. Chat novo reduz — não
elimina — viés de modelo; combina com o checklist anti-viés e 2-3 auditores.

### 3. Gates intra-onda (P3, recomendado)

3-6 sub-fases auditáveis por marco lógico. < 3 = monolítico; > 6 = micro-gestão.
Cada gate é um mini-handoff auditável.

### 4. Checklist anti-viés de bastão (P4)

Toda IA perguntada "a quem passar o bastão" declara auto-indicação, lista
evidência objetiva, reconhece o viés natural e sugere mitigação. Preferir 3
recomendadores independentes; Mauricio pesa evidência acima de auto-avaliação.

### 5. Severidade de auditoria e veto (P7)

| Severidade | Significado | Obrigação do implementador |
|---|---|---|
| **BLOQUEADOR** | segurança / correção / regressão | não prossegue até resolver (veto) |
| **FORTE** | qualidade / manutenibilidade | incorpora ou justifica por escrito |
| **MARGINAL** | nice-to-have | pode ignorar |

Equivalência com vocabulário informal anterior: **P0→BLOQUEADOR, P1→FORTE,
P2→MARGINAL**. Conflito BLOQUEADOR×BLOQUEADOR → Mauricio decide. Nenhuma IA
sobrescreve BLOQUEADOR alheio por autoridade arquitetural.

### 6. Numeração de proposals (P6)

`.hbn/proposals/NNNN-<ia>-<tema>.md` (4 dígitos, cronológico). Próximo livre:

```
ls .hbn/proposals/ | grep -oE '^[0-9]{4}' | sort -n | tail -1
```

### 7. Auditoria curta (P9 — EM TESTE, não vigente)

Auditoria curta (1 IA, < 1000 palavras) só se o máximo de severidade alcançável
for MARGINAL. Default = cruzada plena. A testar na Onda 38.2.3 antes de promover.

## Como verificar

- A §12 existe no `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` (versão ≥ 1.4).
- O `AGENTS.md` tem ponteiro para este arquivo (0019).
- Toda auditoria cruzada nova em `.hbn/proposals/` usa o template §12.A com
  severidades BLOQUEADOR/FORTE/MARGINAL (não "P0/P1/P2").
- Toda recomendação de bastão em ERP/handoff aplica o checklist anti-viés §12.4.
