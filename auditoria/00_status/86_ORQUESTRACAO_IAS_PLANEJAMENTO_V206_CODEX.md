---
titulo: Orquestração Inter-IA do Planejamento V12.0.0206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Orquestração Inter-IA — Planejamento V12.0.0206

## Decisão

É adequado realizar validação cruzada antes de implementar a V12.0.0206.

Motivo: a V12.0.0205 acabou de ser congelada como linha estável. A V12.0.0206
deve ser incremental e precisa proteger a confiança recém-estabelecida. A
validação cruzada reduz risco de escopo escondido, principalmente em PDF
automático, Importador V3, evidências e limpeza documental.

## Sequência

| Ordem | IA | Entrada | Saída esperada |
|---|---|---|---|
| V206-P1 | Claude Opus | `84_PROMPT_PLANEJAMENTO_V206_CLAUDE_OPUS.md` | `88_AUDITORIA_PLANEJAMENTO_V206_CLAUDE_OPUS.md` |
| V206-P2 | Gemini/Antigravity | `85_PROMPT_PLANEJAMENTO_V206_GEMINI_ANTIGRAVITY.md` | `89_AUDITORIA_ADVERSARIAL_PLANEJAMENTO_V206_GEMINI.md` |
| V206-P3 | Codex | pareceres 88/89 + roadmap preliminar | `90_CONSOLIDACAO_ROADMAP_V206_CODEX.md` |

## Critérios Para Codex Consolidar

- Se Opus e Gemini concordarem em uma onda P0/P1, ela entra no roadmap V206.
- Se uma IA apontar risco P0/P1, Codex deve corrigir o plano antes de codificar.
- Se o item exigir refatoração ampla, performance estrutural ou componentização,
  mover para V12.0.0207.
- Se o item alterar regra RN-01 a RN-17, bloquear até decisão humana explícita.
- Se o item for documentação, evidência, importador, PDF ou UX de validação,
  pode ser candidato a V12.0.0206.

## Prompt de Consolidação Para Codex

Após receber os relatórios 88 e 89, Codex deve:

1. comparar achados P0/P1/P2/P3;
2. produzir backlog V206 em ondas e microdeltas;
3. definir gates por onda;
4. atualizar o roadmap final V206;
5. pedir hearback humano antes do primeiro microdelta de código.

Documento de saída:

```text
auditoria/00_status/90_CONSOLIDACAO_ROADMAP_V206_CODEX.md
```

