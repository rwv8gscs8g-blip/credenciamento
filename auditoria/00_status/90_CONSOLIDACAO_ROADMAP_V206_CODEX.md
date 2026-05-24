---
titulo: Consolidação do Roadmap V12.0.0206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
escopo: V206-P3 — consolidação dos pareceres Opus e Gemini
---

# Consolidação do Roadmap V12.0.0206 — Codex

## Entradas

- `88_AUDITORIA_PLANEJAMENTO_V206_CLAUDE_OPUS.md`
- `89_AUDITORIA_ADVERSARIAL_PLANEJAMENTO_V206_GEMINI.md`
- `31_ROADMAP_V206_PRELIMINAR.md`
- `83_READBACK_ABERTURA_V206_CODEX.md`

## Veredito Consolidado

**APROVADO PARA HEARBACK HUMANO.** Não iniciar código neste chat. O próximo
Codex deve assumir em chat novo usando o prompt 91.

O consenso é claro:

- V12.0.0206 deve ser incremental.
- V12.0.0207 deve absorver refatoração, performance e componentização.
- PDF automático é desejável, mas precisa ser isolado do RVS.
- Débitos técnicos exigem lista nominal.
- `docs/` e `doc/` não podem ser confundidos.

## Divergência Entre IAs

| Tema | Opus | Gemini | Decisão Codex |
|---|---|---|---|
| Ordem do PDF | Depois da higiene documental | Pode vir cedo, com blindagem | Higiene e Importador antes do PDF |
| PDF no RVS | Isolado | Isolado, P0 se contaminar | Isolado obrigatório |
| Débitos técnicos | Lista nominal | Bloqueio de refatoração disfarçada | Lista nominal e módulos críticos bloqueados |
| `doc/` | V207 | Banido da V206 | Banido da V206 |

## Itens Aceitos Para V12.0.0206

- Higiene documental e evidências.
- Mensagens do Importador V3.
- Especificação de teste PDF isolado.
- PDF automático robusto.
- Jornada humana V206.
- Débitos pequenos nominais, se aprovados.
- RC/freeze V206 com auditoria cruzada final.

## Itens Movidos Para V12.0.0207

- Code review profundo.
- Performance estrutural.
- Componentização.
- Renomeação de símbolos VBA.
- Reorganização de `doc/`.
- Preparação SaaS.

## Roadmap Consolidado

O roadmap final está em:

```text
auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md
```

## Gates

| Tipo de onda | Gate mínimo |
|---|---|
| Documentação | `verify_release_consistency.sh`, `git diff --check`, link scan |
| Mensagens VBA | compile VBE + Smoke |
| PDF | compile VBE + Smoke + teste PDF isolado + RVS completo |
| Débito técnico | teste específico + RVS completo se tocar código |
| Freeze | RVS completo + AF1/AF2/AF3 + tag |

## Pedido de Hearback Humano

Antes de iniciar Onda 31, o operador deve aprovar:

1. roadmap consolidado em `32_ROADMAP_V206_CONSOLIDADO.md`;
2. abertura de chat novo para implementação;
3. execução da Onda 31 como primeira onda de implementação;
4. regra de PDF isolado fora dos contadores RVS.

