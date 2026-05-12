---
titulo: Princípios Constitucionais do useHBN — índice canônico unificado
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-protocolo: useHBN 1.0 (consolida P1-P10 originais + P11-P13 operacionais formalizados em 2026-05-06)
data: 2026-05-09
autor: Claude Opus 4.7 (Frente 2) — extração canônica a partir de USEHBN-MODULES-ARCHITECTURE.md, RADAR-PHAGOCYTOSIS-PIPELINE.md e fichas dos 3 princípios operacionais
licenca-target: usehbn (AGPLv3)
status: vigente — referência canônica única dos 13 princípios
referencia-arquitetural: usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md
---

# Princípios Constitucionais do useHBN

## O que é este documento

Índice canônico único dos princípios que governam o useHBN. Antes desta
formalização, os 10 princípios constitucionais apareciam referenciados
contextualmente em múltiplos documentos (RADAR-PHAGOCYTOSIS-PIPELINE,
USEHBN-MODULES-ARCHITECTURE, fichas individuais dos princípios
operacionais), sem fonte canônica unificada. Este documento é essa
fonte.

São **13 princípios**:

- **P1-P10** — princípios constitucionais fundadores (V1 da tese, 2026-05-02)
- **P11-P13** — princípios operacionais formalizados na janela 2026-05-02 → 2026-05-06; promovidos a status constitucional equivalente em 2026-05-09 (decisão Maurício)

Toda tecnologia, módulo e decisão arquitetural do useHBN é avaliada
por convergência (sim / parcial / não) com os 13 princípios. A matriz
de convergência por tecnologia vive em
[`usehbn/radar/CONVERGENCE-MATRIX.md`](../radar/CONVERGENCE-MATRIX.md);
o registro consolidado em [`usehbn/radar/REGISTRY.md`](../radar/REGISTRY.md).

## Origem

A V1 da tese (`38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`) declarou os 10
princípios fundadores em 2026-05-02 como axiomas do protocolo.
Permaneceram inalterados em redação desde então. Os 3 princípios
operacionais nasceram em incidências reais durante a janela 2026-05-02
→ 2026-05-06:

- **P11 (Minimalismo de Cadeia)** — articulado durante o arquivamento de Typer (cadeia inflada de dependências sem ganho proporcional)
- **P12 (Substrato Sólido)** — articulado durante a inversão arquitetural do uv (se a vantagem é Rust, escrevamos em Rust direto)
- **P13 (AI-Language-Abstraction)** — articulado quando Maurício declarou Rust como linguagem-base apesar de nunca ter digitado Rust (operador é fluente em qualquer linguagem que sua IA fala)

A formalização canônica de cada um vive em arquivo dedicado em
`usehbn/methodology/`. Este documento é o **índice unificado** que
permite leitura conjunta dos 13.

## Os 10 princípios constitucionais

### P1 — Preservar antes de transformar

**Declaração canônica:** Todo artefato existente é preservado em estado
original antes de qualquer transformação. Cópias sanitizadas operam
sobre o original; o original fica intocado.

**Axiomas derivados:**
- Backups versionados antes de mudança estrutural
- Cópia de espelho local antes de migração
- Original sobrevive a falha da transformação

**Como verificar:** existe snapshot/backup do estado pré-transformação
recuperável sem perda?

**Materializa-se em:** Cápsulas (cópia sanitizada), Fagocitose (cada
fase preserva o estado anterior).

---

### P2 — Documentar antes de executar

**Declaração canônica:** Antes de executar mudança não-trivial, a
intenção, o escopo e o critério de sucesso ficam documentados em
arquivo do repositório. Execução sem documentação prévia é violação.

**Axiomas derivados:**
- ADR (Architecture Decision Record) precede mudança estrutural
- Plano de microdelta precede execução em ondas
- Readback vazio é execução não documentada

**Como verificar:** existe documento (ADR, plano, readback) anterior
ao commit que executa a mudança?

**Materializa-se em:** Coordenação inter-IA (mensageria + readbacks),
Auditoria Cruzada (audit-trail YAML por pedido).

---

### P3 — Testar antes de refatorar

**Declaração canônica:** Refatoração só ocorre sobre código com
cobertura de teste ativa. Refatorar sem testes verdes equivale a
reescrita às escuras.

**Axiomas derivados:**
- "Trio mínimo verde" antes e depois da refatoração
- Suíte de teste é primeira coisa a estabilizar
- Testes ausentes implicam refatoração proibida até suíte existir

**Como verificar:** baseline de testes verdes documentado antes do
diff de refatoração?

**Materializa-se em:** Fagocitose (gates F2→F3 exigem testes verdes),
Cápsulas (validação de schema é teste).

---

### P4 — Explicar antes de automatizar

**Declaração canônica:** Toda automação tem explicação textual em
documento canônico antes de ser implementada. Comportamento automático
sem explicação humana legível é caixa-preta proibida.

**Axiomas derivados:**
- Pipelines CI/CD têm README explicativo
- Hooks de protocolo têm documento de origem
- Comando `hbn` tem `--help` que cita o documento canônico

**Como verificar:** se um humano ler apenas a documentação, ela
explica o que o automatismo faz e por quê?

**Materializa-se em:** Marcadores (vocabulário documentado em
`0005-protocolo-markers-v2.md`), Fagocitose (cada fase tem doc/01).

---

### P5 — Humano no controle por padrão

**Declaração canônica:** Decisões irreversíveis ou de impacto sistêmico
exigem confirmação humana explícita. IAs podem propor, executar
operações reversíveis e validar; aprovação final em pontos de risco
é sempre humana.

**Axiomas derivados:**
- Operador é tiebreaker em conflito entre IAs
- Promoção para repositório público exige consentimento explícito
- Cápsula assinada exige `consent.json` com humano nomeado

**Como verificar:** existe trilha de aprovação humana para cada
decisão de impacto irreversível?

**Materializa-se em:** Cápsulas de Consentimento (humano assina),
Coordenação inter-IA (operador é tiebreaker), Auditoria Cruzada
(decisão Maurício após síntese).

---

### P6 — Toda evolução deve ser reversível

**Declaração canônica:** Cada mudança tem caminho de rollback testado
e documentado. Evoluções sem reversão definida ferem o princípio,
mesmo que pareçam inofensivas.

**Axiomas derivados:**
- Rollback é testado, não presumido
- Despromoção de tecnologia (F4 → F0) é caminho válido
- Migrations têm `down` antes de `up` ser aplicada em produção

**Como verificar:** existe procedimento documentado e exercitado de
reverter a mudança?

**Materializa-se em:** Fagocitose (despromoção via ADR), Radar
(estado `archived` permite reentrada), Cápsulas (revogação por hash).

---

### P7 — Nenhuma tecnologia fagocitada perde sua identidade

**Declaração canônica:** Quando o useHBN incorpora uma tecnologia, o
contexto, a fonte e o racional originais são preservados. A
incorporação não apaga a história do que foi absorvido.

**Axiomas derivados:**
- `lesson.md` da cápsula referencia origem
- `evidence.json` carrega refs do material original
- Histórico de transições é append-only

**Como verificar:** alguém olhando a tecnologia incorporada consegue
chegar à fonte original?

**Materializa-se em:** Cápsulas (`evidence.json` + redução não destrói
referências), Radar (histórico de transições preservado).

---

### P8 — O protocolo importa mais que a ferramenta

**Declaração canônica:** Convenções textuais e schemas formais são a
camada permanente; ferramentas que os implementam são intercambiáveis.
Quando ferramenta e protocolo divergem, protocolo vence.

**Axiomas derivados:**
- CLI `hbn` é uma implementação possível, não a única
- Cápsulas são spec textual; podem ser implementadas em qualquer linguagem
- Marcadores são labels textuais; emojis são afetação humana

**Como verificar:** o protocolo sobrevive a substituição da ferramenta
de implementação atual?

**Materializa-se em:** Marcadores (vocabulário independe de tooling),
Cápsulas (JSON + Markdown ferramenta-agnóstico), Coordenação inter-IA
(arquivos no filesystem, não daemon).

---

### P9 — Frameworks são descartáveis; princípios são permanentes

**Declaração canônica:** Adoção de framework ou biblioteca é decisão
revisável conforme contexto evolui. Os princípios constitucionais são
o que não muda. Lock-in em framework é falha de design.

**Axiomas derivados:**
- Toda dependência externa tem critério de saída documentado
- Substituição de framework é evento esperado, não trauma
- Framework arquivado vira ficha em `archived` no radar

**Como verificar:** se a dependência X for descontinuada amanhã, o
useHBN sobrevive sem reescrita massiva?

**Materializa-se em:** Radar (estado `archived` é caminho normal),
P11 (Minimalismo de Cadeia herda este princípio diretamente).

---

### P10 — Segurança e não-regressão > velocidade

**Declaração canônica:** Quando há tensão entre velocidade de entrega
e gates de segurança/não-regressão, segurança vence. Onda fechada com
gate de segurança violado não é onda fechada.

**Axiomas derivados:**
- 8 vetores Glasswing (G1-G8) bloqueiam fechamento se violados
- Trio mínimo verde antes de tag de release
- Truth Barrier impede claims sem evidência

**Como verificar:** existe gate automatizado que bloqueia entrega se
segurança/não-regressão for comprometida?

**Materializa-se em:** Segurança (G1-G8 inteiro), Auditoria Cruzada
(gate de aprovação multi-IA), Fagocitose (F4→F5 exige ≥30 dias sem
regressão).

---

## Os 3 princípios operacionais (P11-P13)

Formalizados em arquivos dedicados em `usehbn/methodology/`. Cada um
foi destilado de uma decisão real durante a janela 2026-05-02 →
2026-05-06. Promovidos a status constitucional equivalente em
2026-05-09 (decisão Maurício); permanecem com numeração P11-P13 para
preservar separação histórica.

### P11 — Minimalismo de Cadeia

**Declaração condensada:** Cada nova dependência adicionada ao useHBN
deve passar pelo filtro: a cadeia mínima que ela traz tem ganho
desproporcional ao seu custo de manutenção?

**Origem:** arquivamento de Typer (2026-05-06) — cadeia Click+Rich+
alternatives sem ganho proporcional sobre argparse.

**Marker:** 🟦 HBN MINIMALIST GATE

**Documento canônico:** [MINIMALISM-PRINCIPLE.md](MINIMALISM-PRINCIPLE.md)

---

### P12 — Substrato Sólido

**Declaração condensada:** O substrato comum dos módulos do useHBN
deve ser linguagem que oferece estabilidade de décadas, não conforto
imediato. Rust é a escolha (linguagem-base da Árvore Estável).

**Origem:** inversão arquitetural do uv (2026-05-06) — se a vantagem
é Rust, o substrato deveria ser escrito em Rust direto.

**Marker:** 🟪 HBN SUBSTRATO GATE

**Documento canônico:** [SUBSTRATO-SOLIDO-PRINCIPLE.md](SUBSTRATO-SOLIDO-PRINCIPLE.md)

---

### P13 — AI-Language-Abstraction

**Declaração condensada:** O operador humano é fluente em qualquer
linguagem que sua IA fala. Decisões de linguagem são tomadas para
otimizar a IA como cliente prioritário, não a ergonomia humana
direta.

**Origem:** decisão Rust pelo Maurício (2026-05-06) apesar de nunca
ter digitado Rust — IA traduz, humano supervisiona.

**Marker:** 🟧 HBN AI-ABSTRACTION GATE

**Documento canônico:** [AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md](AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md)

---

## Tabela cruzada: princípios → módulos materializadores

| Princípio | Módulos onde se materializa primariamente |
|---|---|
| P1 — Preservar antes de transformar | Cápsulas, Fagocitose |
| P2 — Documentar antes de executar | Coordenação inter-IA, Auditoria Cruzada |
| P3 — Testar antes de refatorar | Fagocitose, Cápsulas |
| P4 — Explicar antes de automatizar | Marcadores, Fagocitose |
| P5 — Humano no controle por padrão | Cápsulas, Coordenação inter-IA, Auditoria Cruzada |
| P6 — Toda evolução deve ser reversível | Fagocitose, Radar, Cápsulas |
| P7 — Nenhuma tecnologia fagocitada perde sua identidade | Cápsulas, Radar |
| P8 — O protocolo importa mais que a ferramenta | Marcadores, Cápsulas, Coordenação inter-IA |
| P9 — Frameworks são descartáveis; princípios são permanentes | Radar (transversal a todos os módulos) |
| P10 — Segurança e não-regressão > velocidade | Segurança, Auditoria Cruzada, Fagocitose |
| P11 — Minimalismo de Cadeia | Fagocitose (gate de cadeia em F1→F2), Cápsulas (cadeia mínima Rust) |
| P12 — Substrato Sólido | Cápsulas (R-D promoção a Estável), Fagocitose (Árvore Estável) |
| P13 — AI-Language-Abstraction | Cápsulas (Python→Rust), Fagocitose (estudos profundos NotebookLM) |

## Convergência tecnológica

Cada ficha em `usehbn/radar/_per-technology/<slug>.md` declara
convergência (sim / parcial / não) por princípio. A matriz transposta
em [`usehbn/radar/CONVERGENCE-MATRIX.md`](../radar/CONVERGENCE-MATRIX.md)
permite leitura cruzada princípio × tecnologia.

Snapshot vivo de tecnologias com convergência declarada (2026-05-09):

| Tecnologia | Convergência | Estado | Notas |
|---|---|---|---|
| Rust | 13/13 sim | phagocytosed | linguagem-base do substrato |
| Consent Capsules | 10/10 sim (P1-P10) + alinhamento explícito P11-P13 | candidate | primeiro projeto demonstrador |
| Tree-sitter | 9/10 sim (1 parcial) | candidate (promovido 2026-05-09) | aprovação favorável Maurício |
| OpenTelemetry | 7/10 sim | candidate | roadmap O-A→O-E pendente |
| Typer | 5/10 sim | archived | cadeia inflada (P11) |
| uv | 6/10 sim | archived | inversão arquitetural P12 |

## Cadência de revisão

Os 13 princípios são revisados em cadência **anual** (mais conservador
que tecnologias). Mudança em redação de qualquer princípio exige:

1. Cross-audit com pelo menos 2 IAs auxiliares (Antigravity + Gemini)
2. Decisão Maurício após síntese
3. Cápsula de auditoria registrando o porquê
4. Append-only — princípio antigo permanece com nota `superseded-by`

Adição de novo princípio (P14+) segue mesmo fluxo, com requisito
adicional de pelo menos 2 incidências reais que motivaram a
formulação.

## Conexão com outros documentos

- [USEHBN-MODULES-ARCHITECTURE.md](USEHBN-MODULES-ARCHITECTURE.md) — arquitetura multi-braço onde os princípios se materializam
- [THREE-TREES-ARCHITECTURE.md](THREE-TREES-ARCHITECTURE.md) — modelo de progressão sob os princípios
- [usehbn/radar/REGISTRY.md](../radar/REGISTRY.md) — registro consolidado das fichas com convergência declarada
- [usehbn/radar/CONVERGENCE-MATRIX.md](../radar/CONVERGENCE-MATRIX.md) — matriz transposta princípio × tecnologia
- [38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md](../../auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md) — V1 da tese onde P1-P10 nasceram

## Versão

- v1.0 — 2026-05-09 — primeira formalização canônica unificada dos 13 princípios. Extração a partir de RADAR-PHAGOCYTOSIS-PIPELINE.md (linhas 119-129) e USEHBN-MODULES-ARCHITECTURE.md (linhas 53-63) para P1-P10; síntese das fichas individuais para P11-P13. Aprovação Maurício 2026-05-09 da promoção P11-P13 a status constitucional equivalente.
