---
titulo: Plano de Incorporação Progressiva — cápsulas de conhecimento como módulos independentes
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 2 — usehbn)
licenca-target: usehbn (AGPLv3)
revisar-em: 2026-05-09 (após primeira semana de estudo profundo)
---

# Plano de Incorporação Progressiva — cápsulas de conhecimento como módulos independentes

## 1. Princípio fundacional

Cada tecnologia que sobrevive à fase de estudo vira **módulo independente** dentro do ecossistema useHBN. Módulos:

- **Crescem em ritmo próprio** — não esperam por outros módulos para evoluir
- **Não se acoplam fortemente entre si** — comunicam apenas via protocolo HBN (markers V2, delta card, ERP, cápsulas)
- **Podem ser fagocitados, reorganizados ou despromovidos** sem afetar outros módulos
- **Geram cápsulas de conhecimento** — cada módulo é "embalável" para promoção pública

Inspiração arquitetural: **Unix philosophy** (cada ferramenta faz uma coisa bem) + **modular monorepo** (Nx, Turborepo) + **microkernel pattern** (núcleo fino + módulos plugáveis).

A diferença essencial: o "núcleo" do useHBN não é código — é **protocolo textual** (markers V2, delta card, schemas de cápsula). Módulos podem ser implementados em qualquer linguagem; só precisam respeitar o protocolo nas fronteiras.

## 2. Estrutura template de módulo

Cada módulo vive em `~/Projetos/usehbn-phago/modules/<slug>/`:

```text
modules/<slug>/
├── README.md                  # visão geral, status, link para ficha do radar
├── ficha-snapshot.md          # cópia da ficha do radar no momento da incorporação
├── docs/
│   ├── 01-fundamentos.md      # conceitos centrais da tecnologia
│   ├── 02-relacao-principios-hbn.md  # como atende cada um dos 10 princípios
│   ├── 03-design-poc.md       # decisões de design do POC
│   ├── 04-roadmap.md          # fases planejadas (F1-F5)
│   └── ADR/                   # Architecture Decision Records
│       ├── ADR-001-...
│       └── ADR-002-...
├── poc/                       # provas de conceito isoladas
│   ├── poc-01-basico.py
│   ├── poc-02-integrado.py
│   └── README.md              # como rodar
├── tests/                     # testes pytest
│   ├── test_poc_basico.py
│   └── conftest.py
├── capsules/                  # cápsulas de conhecimento geradas
│   └── capsule-001/           # ver Consent capsules spec
├── pyproject.toml             # se for módulo Python instalável
└── CHANGELOG.md               # histórico de mudanças do módulo
```

## 3. Fases de incorporação (F0 → F5)

| Fase | Estado da ficha radar | Output esperado | Duração típica | Gate de saída |
|---|---|---|---|---|
| **F0 — Observação** | `in-radar` (modo-estudo: superficial) | ficha curta + 1-3 linhas de motivação | dias | decisão consciente de gastar energia |
| **F1 — Estudo profundo** | `under-analysis` (modo-estudo: profundo) | docs/01-02 + bibliografia + podcast NotebookLM ouvido + plano de POC | 1-2 semanas | Maurício declara "estudei o suficiente" |
| **F2 — POC isolado** | `under-analysis` (modo-estudo: validado) | poc/ + tests/ básicos + ADR-001 (decisão de design) | 1 semana | POC roda end-to-end; testes verdes |
| **F3 — Integração protocolar** | `convergence-mapped` | módulo conectado ao protocolo HBN; cápsula de conhecimento gerada; integração com `hbn` CLI testada | 1-2 semanas | markers V2 corretos; rollback validado |
| **F4 — Fagocitose operacional** | `candidate` → `phagocytosed` | uso real em ciclos HBN; documentação operacional pública | 4+ semanas | 30+ dias sem regressão |
| **F5 — Promoção pública** | `phagocytosed` (público) | cápsula promovida para repo público via consent capsules | quando estável | consent + redaction completos |

## 4. Gates de teste por fase

### F0 → F1
- 1 frase justificando relevância para um dos 10 princípios
- Slug único kebab-case
- Frontmatter mínimo na ficha do radar

### F1 → F2
- `docs/01-fundamentos.md` cobrindo conceitos centrais (escrito por Maurício ou Opus)
- `docs/02-relacao-principios-hbn.md` com análise individual dos 10 princípios
- Bibliografia consolidada (mínimo 5 fontes oficiais)
- Plano de POC documentado em `docs/03-design-poc.md`
- Maurício confirma: "estudei o suficiente, ok prosseguir"

### F2 → F3
- POC roda end-to-end em macOS Sequoia do operador
- Testes pytest básicos passam (mínimo 5 testes)
- ADR-001 documentando decisão de design
- Comparativo escrito vs alternativa simples (regex, código manual, etc.)
- Rollback testado: desinstalar módulo não quebra resto do useHBN

### F3 → F4
- Integração com markers V2 demonstrada
- Cápsula de conhecimento gerada (lesson + evidence + redaction + consent + license-target + hashes)
- Comando `hbn <modulo> ...` na CLI hbn (Wave 11+)
- Documentação operacional em `usehbn-phago/docs/<slug>/`

### F4 → F5
- Mínimo 30 dias de uso operacional sem regressão
- Pelo menos 1 cápsula promovida com sucesso (consent capsules em uso real)
- Maurício autoriza promoção pública

## 5. Cronograma para as 5 tecnologias atuais

**Período de foco: 2026-05-02 a 2026-05-09 (semana 1).**

Esta semana = **F1 (estudo profundo)** para todas as 5. Output esperado por tecnologia até quarta 2026-05-06 (revisão semanal):

| Tecnologia | Foco do estudo | Decisão esperada em 2026-05-09 |
|---|---|---|
| **Tree-sitter** | LR/GLR parsers; gramáticas BNF/EBNF; gramática VBA real (eirikpre); extração de regras de negócio | F2 (POC parsing `Const_Colunas.bas`) ou aguardar |
| **Typer** | cadeia de dependências completa (Click + Rich + alternatives); comparação com argparse, click puro, cyclopts; typer-slim | F2 (POC `hbn baton status`) ou trocar por Click puro |
| **uv** | reprodutibilidade; PubGrub algorithm; comparação Poetry/pdm/hatch; PEP 621/723 | F2 (`uv init usehbn-phago` + benchmark) confirmar |
| **OpenTelemetry** | distributed tracing fundamentals; semantic conventions gen-ai; W3C Trace Context; backend OTLP-JSON local | F2 (POC instrumentar 1 ciclo HBN) ou aguardar |
| **Consent capsules** | data sovereignty patterns; W3C VC; spec dos 6 arquivos da cápsula; redaction strategies | F2 (POC manual de 1 cápsula com L18) |

**Não promover nenhuma a F2 antes do final da semana sem hearback explícito de Maurício.**

## 6. Como módulos se conectam — interfaces declaradas no protocolo

Módulos NÃO se importam diretamente em código. Comunicam via **arquivos do protocolo HBN**:

| O que cada módulo produz | O que cada módulo consome |
|---|---|
| **Tree-sitter** produz: AST em JSON; relatório de extração de regras | consome: arquivos `.bas`/`.cob`/etc. do filesystem |
| **OTel** produz: trace OTLP-JSON em `local-ai/traces/` | consome: spans emitidos por outros módulos |
| **Consent capsules** produz: capsula completa em `capsules/<id>/` | consome: lições + evidências de qualquer módulo |
| **Typer (CLI hbn)** produz: comandos invocáveis `hbn <subcomando>` | consome: API/funções dos outros módulos |
| **uv** produz: ambiente Python reprodutível | consome: `pyproject.toml` + `uv.lock` |

CLI `hbn` (Typer) orquestra os 4 outros. Cada outro módulo pode ser usado standalone também (CLI = invocação conveniente, não obrigatória).

## 7. Política de rollback / despromoção

Módulo em F2-F4 pode regredir para fase anterior se:
- Mudança de contexto invalida premissa (ex.: mantenedor abandona projeto)
- Concorrente surge com encaixe melhor
- Risco operacional descoberto (CVE, design flaw)

Despromoção exige:
- Justificativa explícita em ADR (`decisions/ADR-NNN-despromocao.md`)
- Atualização da ficha do radar com nova transição de estado
- Reversibilidade de qualquer integração feita (rollback testado)

Despromoção radical (F4 → F0 ou archived) requer aprovação Maurício.

## 8. Como cápsulas de conhecimento crescem dentro de cada módulo

Cada módulo gera **múltiplas cápsulas** ao longo da evolução:

- **Cápsula de fundamentos** — conceitos básicos, alvo público leigo
- **Cápsula de princípios** — relação com os 10 princípios HBN
- **Cápsula de design** — decisões de POC
- **Cápsula de operação** — uso real, lições aprendidas
- **Cápsula de despromoção** (se ocorrer) — por que parou de usar

Cápsulas são unidade de transferência. Módulo público é coleção de cápsulas. Maurício consente cada cápsula individualmente antes de promoção.

## 9. Conexão entre módulos — composição via protocolo

Cenário ilustrativo (após F4 das 5 tecnologias):

```
Maurício roda: hbn ciclo executar onda-12

  → Typer (CLI) recebe comando
  → uv (env) garante ambiente reprodutível
  → OTel (trace) abre span "ciclo:onda-12"
    → Tree-sitter (parsing) lê código VBA da onda
    → Tree-sitter produz AST
    → Análise gera lição candidata
    → Consent capsules (capsule) cria cápsula com lição + evidências
  → OTel fecha span; trace gravado em local-ai/traces/
  → Typer mostra resumo + path da cápsula
```

Cada módulo cumpre uma função sem saber dos outros. Composição emerge do protocolo.

## 10. Status atual (2026-05-02)

| Módulo | Fase atual | Próximo passo |
|---|---|---|
| Tree-sitter | F0 → F1 (entrando) | docs/01 + bibliografia + plano de POC |
| Typer | F0 → F1 (entrando) | mesmo |
| uv | F0 → F1 (entrando) | mesmo |
| OpenTelemetry | F0 → F1 (entrando) | mesmo |
| Consent capsules | F0 → F1 (entrando) | mesmo + spec dos 6 arquivos |

**Próxima decisão consciente:** 2026-05-09 — quais avançam para F2?

## Versão

- v1.0 — 2026-05-02 — plano inicial após decisão Maurício de focar em estudo profundo das 5 tecnologias por uma semana antes de promover.
