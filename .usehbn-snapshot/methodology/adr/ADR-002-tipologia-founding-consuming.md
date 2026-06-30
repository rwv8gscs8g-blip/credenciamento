---
adr-id: ADR-002
titulo: Tipologia formal — Founding/Consuming Application vs Module
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Codex + Antigravity
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco)
prioridade: P0
ordem-cross-ia: 1 de 5 (serial 002 → 003 → 004 → 009 → 001)
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.2
  - doc 66 v2.0 (Credenciamento) §3.1, §11.1
licenca-target: Apache 2.0 + CLA (decisão operador 2026-05-09; ratificação em ADR-005)
---

# ADR-002 — Tipologia formal: Founding/Consuming Application vs Module

## Status

**PROPOSED** — aguardando cross-IA (Codex) e Hearback humano. Bloqueia
ADR-003 (topologia) e ADR-008 (migração snapshot) que dependem desta
tipologia para definir contornos.

## Contexto

O ecossistema useHBN misturou até 2026-05-09 o status do Credenciamento
("módulo do protocolo" vs "aplicação consumidora"). Três auditorias
cruzadas (Antigravity + Codex + Opus) executadas em 2026-05-09
convergiram unanimemente: **Credenciamento é Aplicação Fundadora +
Aplicação Consumidora, NUNCA módulo do protocolo**.

Sem formalização desta tipologia em ADR:

- Risco de regressão: futura IA operando em CWD do Credenciamento pode
  voltar a editar o protocolo "porque está dentro do mesmo repo".
- Identidade pública diluída: comunicação externa não diferencia
  "padrão descoberto pela aplicação fundadora" de "implementação do
  protocolo".
- Topologia (ADR-003) sem termos canônicos para apontar.

Precedente histórico citado pela Antigravity: React nasceu no Facebook
Ads Manager. O Ads Manager foi a aplicação fundadora. Hoje o Ads Manager
é apenas aplicação consumidora — não hospeda doc canônica do React.
Mesma trajetória aqui.

## Decisão

Formalizar tipologia canônica:

| Termo | Definição | Aplicação atual | Status proibido futuramente |
|---|---|---|---|
| **Founding Application** | Aplicação onde os padrões do protocolo foram descobertos empiricamente. Status histórico, não técnico. Único por protocolo. | Credenciamento | n/a |
| **Consuming Application** | Aplicação que consome o protocolo como dependência via `.usehbn-snapshot/` read-only. Status técnico atual e futuro. Múltiplas possíveis. | Credenciamento (e futuras candidatas — decisão O4 do doc 66 v2.0) | n/a |
| **Reference Implementation** | Código-base oficial que materializa o protocolo. Inexistente hoje. | Será construída em `~/Projetos/usehbn/examples/` ou subpasta dedicada | n/a |
| **Protocol Specification** | Especificação normativa RFC-style. | `~/Projetos/usehbn/modules/` (a criar pelo ADR-003) | n/a |
| **NÃO-módulo** | Status proibido para qualquer aplicação consumidora. | — | Credenciamento NUNCA recebe este rótulo |

Tipologia ratificada para uso em:

- README (público) do useHBN.
- `docs/CASE-STUDY-CREDENCIAMENTO.md` (atualizar terminologia).
- `methodology/PRINCIPIOS-CONSTITUCIONAIS.md` (citação em texto sobre P7
  e P8).
- `methodology/MATURITY-MATRIX.md` (linha "Credenciamento" muda de
  "Visão / referência externa" para "Founding/Consuming Application —
  referência externa").
- AGENTS.md raiz das aplicações consumidoras (declara
  `useHBN-version: ^X.Y.Z` — formato em ADR-004).

## Consequências

**Positivas:**
- Identidade pública clara: "useHBN é o protocolo; Credenciamento é a
  aplicação onde os padrões foram descobertos e validados".
- Topologia (ADR-003) ganha termos canônicos para apontar.
- Próximas aplicações consumidoras (decisão O4 pendente para Quarta 0)
  têm rótulo claro a aplicar.

**Negativas (assumíveis):**
- `docs/CASE-STUDY-CREDENCIAMENTO.md` precisa retrabalho de redação —
  trabalho mecânico, baixo risco.
- `~/Projetos/usehbn/AGENTS.md` raiz não existe ainda — bloqueia
  indiretamente MD-C (criação do AGENTS.md raiz).
- `~/Projetos/Credenciamento/AGENTS.md` **existe**, mas **sem seção
  de dependência `useHBN-version`** (correção 2026-05-10 cross-IA Codex
  — depósito original v1.0 afirmava incorretamente que ambos repos
  não tinham AGENTS.md). MD subsequente adiciona a seção via Codex
  CLI no Credenciamento (pós-v204 final, junto com ADR-008).
- `useHBN-version` em AGENTS.md é **contrato documental inicial**
  (não enforcement automático em v0.3.0). Validação automática via
  `hbn doctor` entra após MD-H (resolução de versão) + MD-I (snapshot
  tooling). Antes disso, o campo é declarativo — IA leitora respeita;
  ferramentas não validam.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Operadores externos confundirem "Founding Application" com "produto principal" | Glossário no README + nota explícita "Founding é status histórico, não técnico" |
| R2 | 2ª aplicação consumidora chegando antes de cross-IA acontecer | Postergar promoção pública até ADR-002 ratificado |
| R3 | Termo "Founding" parecer pretensioso em comunicação externa | Manter texto curto e factual; precedente React/Ads Manager dá ancoragem |

## Próximo passo

1. ✅ Cross-IA review por Codex concluído (`0001-cross-ia-codex-ADR-002.json`) + Antigravity (`0011-cross-ia-antigravity-ADR-002.md`).
2. ✅ Ajustes MD-J aplicados (2026-05-10).
3. Hearback humano (Mauricio) → status PROPOSED → ACCEPTED.
4. MD subsequente: atualizar README (frase didática Antigravity: "O Credenciamento foi a fundição onde o HBN foi forjado; hoje, é apenas seu primeiro consumidor") + CASE-STUDY-CREDENCIAMENTO + MATURITY-MATRIX (linha "Credenciamento" → "Founding/Consuming Application — referência externa").

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) corrigida afirmação errada — `Credenciamento/AGENTS.md` existe mas sem seção `useHBN-version` (Codex); (b) `useHBN-version` declarado como contrato documental inicial, não enforcement; (c) frase didática Antigravity adicionada ao plano de README pós-ratificação.
