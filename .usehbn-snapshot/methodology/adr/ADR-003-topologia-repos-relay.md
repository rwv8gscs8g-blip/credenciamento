---
adr-id: ADR-003
titulo: Topologia de repositórios e relay multi-camada
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Antigravity + Codex
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco)
prioridade: P0
ordem-cross-ia: 2 de 5 (depende de ADR-002 ratificado)
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.3
  - doc 66 v2.0 (Credenciamento) §3.2, §11.1
  - ADR-002 (tipologia)
  - ADR-008 (migração Credenciamento/usehbn/)
---

# ADR-003 — Topologia de repositórios e relay multi-camada

## Status

**PROPOSED** — depende de ADR-002 (tipologia formal). Bloqueia ADR-008
(migração snapshot) e a criação efetiva de `modules/`.

## Contexto

Hoje o protocolo useHBN vive em `~/Projetos/usehbn/` como mono-repo sem
partição funcional clara. Documentos normativos, arquiteturais e
históricos coabitam `core/`, `docs/`, `agents/` e `auditoria/` (este
último recém-criado). Auditorias cruzadas Antigravity Q3 e Codex Q3
convergiram em 2026-05-09: **mono-repo modular com partição funcional
F1/F2/F3** é o caminho correto, em paralelo a poly-repos como espelhos
read-only quando aplicável.

Auditoria Antigravity diagnosticou: 27+ docs hipertrofiadas em `docs/`
sem cerne funcional declarado. Auditoria Codex propôs partição
estrutural. Esta ADR materializa.

## Decisão

Adotar topologia mono-repo modular com 4 partições funcionais e
relay multi-camada:

```
~/Projetos/usehbn/                  FONTE DE VERDADE do protocolo
├── modules/                        ESPECIFICAÇÃO NORMATIVA (RFC-style)
│   ├── PROTOCOL-CONTRACT.md        (cerne C4 — funde ARCHITECTURE,
│   │                                 how-it-works, UNIVERSAL-TRANSLATOR,
│   │                                 RUNTIME-ADAPTERS, CONNECTORS)
│   ├── INTEGRATIONS.md             (cerne C5 — funde 6 INTEGRATION-*)
│   └── GOVERNANCE.md               (cerne C6 — funde LICENSING,
│                                     PUBLISHING, OPEN-SOURCE-STRATEGY,
│                                     EXECUTION-DECISION)
├── methodology/                    ARQUITETURA + PRINCÍPIOS + ADRs
│   ├── PRINCIPIOS-CONSTITUCIONAIS.md  (P1-P13 — fonte canônica única)
│   ├── PHAGOCYTOSIS.md             (cerne C2 — funde PHAGO + EVOLUTION-POLICY)
│   ├── MATURITY-MATRIX.md          (cerne C3 — intacto)
│   ├── TUTORIALS.md                (cerne C7 — funde QUICKSTART, SAFE-TESTING,
│   │                                 ANALYTICS, DOMAINS)
│   ├── PRINCIPLES.md (legado)      (cerne C1 — funde VISION, FOUNDING-NOTES,
│   │                                 HBN-LANGUAGE-v0.1, TRUTH-BARRIER, GUARDIAN,
│   │                                 INTENT-RISK-MATRIX — superseded)
│   ├── ROADMAP.md                  (unifica ROADMAP raiz + docs/roadmap)
│   ├── adr/                        (Architecture Decision Records — este dir)
│   ├── rfc/                        (Request For Comments — futuro)
│   ├── wave-plans/                 (planos de onda; v0.3.0 vai aqui)
│   ├── study-plans/                (planos de estudo de tecnologias — decisão MD-K)
│   │   ├── notebooklm/             (superprompts NotebookLM)
│   │   └── gemini/                 (briefs Gemini)
│   └── templates/                  (templates reutilizáveis: cross-audit, ADR, MD)
├── auditoria/                      HISTÓRICO DO PROTOCOLO (F2)
│   ├── 00_status/                  (docs meta — bootstrap, addendum)
│   ├── case-studies/               (Credenciamento — cerne C8)
│   ├── decisions/                  (registros de decisão fora dos ADRs)
│   ├── capsulas/                   (cápsulas de auditoria — paths ascii, ADR-009 §7)
│   └── quartas/                    (registros das Quartas — após ADR-001)
├── radar/                          PARTIÇÃO STANDALONE (decisão MD-K 2026-05-10)
│   ├── REGISTRY.md                 (registro de tecnologias)
│   ├── CONVERGENCE-MATRIX.md       (matriz princípio × tecnologia)
│   ├── WEEKLY-UPDATES.md           (histórico — ciclo de revisão semanal próprio)
│   └── _per-technology/            (60+ fichas atômicas)
├── examples/                       REFERENCE IMPLEMENTATION (futura)
├── core/                           LEGADO — fonte das 5 specs originais
│                                   (a fundir em modules/PROTOCOL-CONTRACT.md
│                                   na Onda "Documental Sanitization")
├── docs/                           LEGADO — em particionamento progressivo
│                                   para modules/ + methodology/ + auditoria/
├── schemas/                        contratos JSON (intactos)
├── agents/                         contratos de IA (intactos por ora)
├── src/                            implementação Python (intacta)
├── tests/                          testes (intactos)
├── .hbn/                           coordenação inter-IA do PROTOCOLO
│   ├── relay/                      iterações ativas
│   ├── relay-archive/              iterações resolvidas
│   ├── knowledge/                  conhecimento reutilizável
│   ├── readbacks/                  readbacks ativos
│   ├── results/                    ERPs gravados
│   ├── reports/                    output humano
│   ├── connectors/                 catálogo + aprovações
│   └── meta/                       META-RELAY (decisões cruzadas) — fase 1
└── AGENTS.md (raiz)                CONTRATO único de IA (a criar — MD-C)

~/Projetos/Credenciamento/          APLICAÇÃO CONSUMIDORA
├── src/vba/                        código da app (intacto durante v204)
├── auditoria/                      histórico da APP (F1)
├── .hbn/                           coordenação inter-IA da APP
├── usehbn/                         LEGADO — substituir após v204 final (ADR-008)
├── .usehbn-snapshot/               read-only mirror — populado após ADR-008
└── AGENTS.md (raiz)                declara `useHBN-version: ^X.Y.Z`
```

### Relay multi-camada

| Camada | Localização | Função |
|---|---|---|
| Relay do protocolo | `~/Projetos/usehbn/.hbn/relay/` | Coordenação inter-IA dentro do useHBN |
| Relay da app | `~/Projetos/Credenciamento/.hbn/relay/` | Coordenação inter-IA dentro do Credenciamento |
| Meta-relay | `~/Projetos/usehbn/.hbn/meta/` | Decisões cruzadas entre repos. Fase 1: subdir do useHBN. Fase 2 (eventual): repo standalone `~/Projetos/.hbn-meta/` se volume justificar (decisão futura). |
| Bridge cross-repo | `additionalDirectories` em `.claude/settings.local.json` | Permissão de leitura de um repo no CWD do outro |

Decisão O2 do doc 66 v2.0 ratificada: meta-relay vive como `.hbn/meta/`
do useHBN (subdir, NÃO repo standalone) na fase 1.

## Plano de compatibilidade `core/` → `modules/` (ajuste MD-J cross-IA Codex)

A renomeação não é atômica. `core/` permanece como **diretório legado**
com banner `SUPERSEDED: see modules/<arquivo>` no topo de cada `.md`
por **pelo menos 1 release** após `modules/` ser populado. Sem imports
Python para `core/` em `src/usehbn/` (não é runtime — confirmado
cross-IA Codex), apenas superfície pública e documental.

Arquivos que referenciam `core/` e precisam ser atualizados em MD
subsequente:

| Arquivo:linha | Referência | Ação |
|---|---|---|
| `README.md:406` | `core/` em "Project Structure" | atualizar para `modules/` + nota de transição |
| `README.md:421` | `core/: protocol specifications` | atualizar |
| `site/index.html:40` | URL GitHub para `core/protocol.md` | manter redirect ou atualizar URL |
| `agents/wave-protocol.md:155` | `core/` no grep doutrinário | adicionar `modules/` à lista (não remover `core/` enquanto legado vivo) |

Critério de remoção definitiva de `core/`: 1 release completa após
`modules/` populado + zero links públicos quebrados verificados via
`hbn doctor`.

## Consequências

**Positivas:**
- Cada IA operando em CWD sabe imediatamente o escopo de escrita
  permitido pela partição (modules/ vs methodology/ vs auditoria/).
- Hipertrofia documental futura tem cerne para crescer ou cortar.
- Topologia compatível com ADR-008 (migração `Credenciamento/usehbn/`
  → `.usehbn-snapshot/`).

**Negativas (assumíveis):**
- Migração das ~35 docs em fases. Onda dedicada "Documental
  Sanitization" (a propor após v204) faz a fusão linha-a-linha.
- `core/` torna-se `modules/` em renomeação eventual; ajustes em
  imports docs e referências cruzadas necessários.
- Perda informacional possível na fusão se redução for agressiva. Risco
  mitigado por revisão cross-IA da Onda dedicada.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Conflito de partição: doc híbrido entre `modules/` (normativo) e `methodology/` (arquitetural) | Regra: se descreve "o que é o protocolo" → modules/; se descreve "como decidimos / como evoluímos" → methodology/ |
| R2 | `.hbn/meta/` crescer descontroladamente sem repo separado | Métrica em ADR-007 monitora; promoção a repo standalone vira sub-ADR |
| R3 | IAs operando em CWD errado (Credenciamento vs useHBN) durante migração | `additionalDirectories` + permissions deny no settings.local.json (já ativo) |
| R4 | docs/ legado virar terra-de-ninguém durante transição | MD subsequente ao ADR-007 estabelece deadline de fusão (ex.: até v0.3.1) |

## Próximo passo

1. ADR-002 ratificado primeiro (define termos).
2. Cross-IA review por Antigravity.
3. Hearback humano.
4. Status PROPOSED → ACCEPTED.
5. Criação efetiva de `modules/` (vazio inicialmente; populado pela Onda
   "Documental Sanitization" futura).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajuste: adicionada seção "Plano de compatibilidade core/ → modules/" (insight Codex) — `core/` vira legado com banner SUPERSEDED por ≥1 release; lista dos 4 arquivos a atualizar; `modules/` não é populado na ratificação (fusão das ~35 docs é Onda separada).
- v1.2 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — decisões de topologia ratificadas pelo operador via MD-K §E: (a) `radar/` é **partição standalone** (não subpasta de `methodology/`) — volume 64+ arquivos + ciclo de revisão próprio (semanal vs anual); (b) `study-plans/` vive em `methodology/study-plans/`; (c) `methodology/templates/` é a pasta de templates reutilizáveis. Tree atualizado.
