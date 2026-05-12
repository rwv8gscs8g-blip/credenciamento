---
titulo: Plano de Estudo Foco — 5 Tecnologias / Semana 2026-W18
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: humano + ia
data: 2026-05-02
revisar-em: 2026-05-06 (próximo update semanal — quarta-feira)
licenca-target: usehbn (AGPLv3)
janela: 2026-05-02 sábado → 2026-05-06 quarta = 4 dias úteis de imersão
---

# Plano de Estudo Foco — 5 Tecnologias

## Por que esta semana

Maurício decidiu (2026-05-02) usar a janela até o próximo update semanal (quarta 2026-05-06) para imersão profunda em 5 tecnologias selecionadas pelo radar useHBN. Objetivo: chegar na quarta com decisões fundamentadas sobre quais começam a ser fagocitadas e quais ficam em standby.

## As 5 tecnologias

| # | Tecnologia | Categoria | Estado atual | Pergunta a responder |
|---|---|---|---|---|
| 1 | **Tree-sitter** | conhecimento-estruturado | in-radar (9/10 sim) | Como GLR parsing destrava `hbn-phago` para VBA/COBOL/Pascal? |
| 2 | **Typer** | outros (stack CLI) | under-analysis (8/10 sim) | A árvore de dependências (Click, Rich, etc.) é gerenciável? |
| 3 | **uv** | outros (stack CLI) | under-analysis (10/10 sim) | Como migrar projetos Python existentes; comparativo com Poetry/pdm? |
| 4 | **OpenTelemetry** | observabilidade | in-radar (8/10 sim) | Como instrumentar ciclos HBN sem capturar dados sensíveis? |
| 5 | **Consent capsules** | conhecimento-estruturado | under-analysis (10/10 sim) | Como materializar a proposta D em schema JSON + workflow Git? |

## Estrutura desta pasta

```text
study-plans/
├── README.md                            (este arquivo — overview)
├── 00-INTEGRATION-ROADMAP.md            (plano de incorporação progressiva no usehbn-phago)
├── 01-tree-sitter-study-plan.md         (estudo profundo Tree-sitter + LR/GLR/Earley)
├── 02-typer-study-plan.md               (estudo profundo Typer + cadeia de dependências)
├── 03-uv-study-plan.md                  (estudo profundo uv + comparativos)
├── 04-opentelemetry-study-plan.md       (estudo profundo OTel + 3 pilares + gen-ai)
├── 05-consent-capsules-study-plan.md    (estudo profundo cápsulas + W3C VC + JWS)
├── notebooklm/
│   ├── SUPERPROMPT-TEMPLATE.md          (template universal — como construir superprompts NLM)
│   ├── 01-tree-sitter-superprompt.md    (superprompt ready-to-use)
│   ├── 02-typer-superprompt.md          (idem)
│   ├── 03-uv-superprompt.md             (idem)
│   ├── 04-opentelemetry-superprompt.md  (idem)
│   └── 05-consent-capsules-superprompt.md (idem)
└── gemini/
    └── ARCHITECTURE-BRIEF.md            (brief para Gemini refinar arquitetura usehbn-phago)
```

(Arquivos da pasta `notebooklm/` e `gemini/` são entregues na sequência desta sessão.)

## Como usar — fluxo recomendado de 4 dias

### Sábado 2026-05-02 (hoje, fim de tarde / noite)
- Ler este README + `00-INTEGRATION-ROADMAP.md` (entender o panorama de incorporação)
- Escolher uma das 5 tecnologias para começar (recomendo **Tree-sitter** ou **uv** — duas extremidades de complexidade)

### Domingo 2026-05-03
- Estudo profundo da tecnologia escolhida usando `0X-<tecnologia>-study-plan.md` como guia
- Copiar o superprompt correspondente em `notebooklm/0X-<tecnologia>-superprompt.md` e colar no Notebook LM
- Notebook LM gera podcast (~25-40 min) — escutar durante caminhada/exercício
- Anotar dúvidas e insights

### Segunda 2026-05-04 + Terça 2026-05-05
- Repetir ciclo (study plan → Notebook LM → podcast → anotações) com as 4 tecnologias restantes
- 1 tecnologia por dia + 1 reserva para revisão
- **Em paralelo**: stack CLI (Typer + uv + GH Actions + Signed commits) viram `candidate` automaticamente em 2026-05-04 — Opus já tem decisão para isso

### Terça 2026-05-05 (à noite) ou Quarta 2026-05-06 (manhã)
- Submeter `gemini/ARCHITECTURE-BRIEF.md` ao Gemini para refinamento de arquitetura
- Gemini sugere ajustes; Opus revisa e incorpora os bons

### Quarta 2026-05-06 (revisão semanal — 11:45 BRT)
- Decisões de promoção: quais das 5 viram `convergence-mapped` ou `candidate`?
- Quais POCs começam? (Opus monta esteiras E2/E3/etc.)
- Addendum em `WEEKLY-UPDATES.md` registra decisões

## Princípio condutor — cápsulas de conhecimento como módulos independentes

Maurício pediu: "criar cápsulas de conhecimento como módulos independentes que possam crescer no usehbn".

Cada uma das 5 tecnologias, ao ser fagocitada, vira **um módulo independente do `usehbn-phago`**:

```text
usehbn-phago/
├── modules/
│   ├── parsing/      (Tree-sitter — depois de fagocitada)
│   ├── cli/          (Typer + uv — stack)
│   ├── telemetry/    (OpenTelemetry)
│   └── capsules/     (Consent capsules — implementação interna)
└── docs/
    └── modules/
        ├── parsing.md
        ├── cli.md
        ├── telemetry.md
        └── capsules.md
```

Cada módulo:
- Tem documentação própria
- Pode ser usado isoladamente
- Pode ser substituído sem afetar os outros (P9 reforçado)
- Tem testes próprios
- Cresce de forma incremental — **não precisa estar completo para ser útil**

Detalhes do plano de incorporação em `00-INTEGRATION-ROADMAP.md`.

## Markers V2 ativos nesta sessão

- ✅ HBN ACTIVE — Frente 2 produzindo material de estudo
- ⚪ HBN AUDIT-ONLY — não há código sendo executado (planejamento)
- 🔵 HBN HANDOFF READY — material entregue para Maurício estudar

## Versão

- v1.0 — 2026-05-02 — pacote inicial criado a partir do hearback "essas tecnologias merecem pelo menos a próxima semana de estudo"
