---
titulo: Princípios Constitucionais do useHBN — índice canônico unificado
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-protocolo: useHBN pre-v1 (consolida P1-P10 originais + P11-P13 operacionais formalizados em 2026-05-06; promovidos a constitucional 2026-05-09)
data-original: 2026-05-09
data-migracao: 2026-05-09
autor-original: Claude Opus 4.7 (Frente 2) — extração canônica
autor-migracao: Claude Opus 4.7 (chat arquiteto-mestre useHBN, ~/Projetos/usehbn/) — MD-F
licenca-target: useHBN (proposta de migração para Apache 2.0 + CLA via ADR-005)
status: vigente — referência canônica única dos 13 princípios
fonte-original: ~/Projetos/Credenciamento/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md
referencia-arquitetural: methodology/USEHBN-MODULES-ARCHITECTURE.md (a migrar)
adr-ratificacao: methodology/adr/ADR-009-constituicao-p1-p13.md
---

# Princípios Constitucionais do useHBN

## O que é este documento

Índice canônico único dos princípios que governam o useHBN. Antes desta
formalização (2026-05-09), os 10 princípios constitucionais apareciam
referenciados contextualmente em múltiplos documentos sem fonte canônica
unificada. Este documento é essa fonte.

São **13 princípios constitucionais com peso normativo igual**.
Toda tecnologia, módulo e decisão arquitetural do useHBN é avaliada por
convergência (sim / parcial / não) contra os 13. A matriz de convergência
por tecnologia vive em `radar/CONVERGENCE-MATRIX.md` (a migrar); o
registro consolidado em `radar/REGISTRY.md` (a migrar).

> **Nota de isonomia (2026-05-10, ajuste cross-IA Antigravity):** os 13
> princípios têm peso constitucional **idêntico**. Nenhuma castas
> implícitas: P11, P12, P13 são tão constitucionais quanto P1, P2, P3.
> A informação histórica sobre quando cada princípio foi formalizado vai
> em metadado/rodapé de cada princípio, não em cabeçalho hierárquico.

## Origem

A V1 da tese (`38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`, repo Credenciamento,
2026-05-02) declarou P1-P10 como axiomas iniciais do protocolo. P11-P13
foram articulados durante a janela 2026-05-02 → 2026-05-06 a partir de
incidências reais e promovidos a status constitucional equivalente em
2026-05-09 (decisão Maurício). Histórico de cada princípio em rodapé.

A formalização canônica de cada um vive em arquivo dedicado em
`methodology/` (a migrar). Este documento é o **índice unificado** que
permite leitura conjunta dos 13.

## Os 13 princípios constitucionais

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

**Materializa-se em:** Marcadores (vocabulário documentado), Fagocitose
(cada fase tem doc/01).

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

### P11 — Minimalismo de Cadeia

**Declaração condensada:** Cada nova dependência adicionada ao useHBN
deve passar pelo filtro: a cadeia mínima que ela traz tem ganho
desproporcional ao seu custo de manutenção?

**Origem:** arquivamento de Typer (2026-05-06) — cadeia Click+Rich+
alternatives sem ganho proporcional sobre argparse.

**Marker:** 🟦 HBN MINIMALIST GATE

**Documento canônico:** `methodology/MINIMALISM-PRINCIPLE.md` (a migrar do Credenciamento/usehbn/methodology/)

---

### P12 — Substrato Sólido

**Declaração condensada:** O substrato comum dos módulos do useHBN
deve ser linguagem que oferece estabilidade de décadas, não conforto
imediato. Rust é a escolha (linguagem-base da Árvore Estável).

**Origem:** inversão arquitetural do uv (2026-05-06) — se a vantagem
é Rust, o substrato deveria ser escrito em Rust direto.

**Marker:** 🟪 HBN SUBSTRATO GATE

**Documento canônico:** `methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md` (a migrar do Credenciamento/usehbn/methodology/)

> **Nota — sobrecarga semântica resolvida 2026-05-09**: o sentido de
> "regras só mudam após N ciclos" usado em alguns docs anteriores é
> agora chamado de **"Cadência Constitucional"** e vive como cláusula
> operacional do ADR-001 (Quarta de Sanitização), não como princípio
> numerado novo. P12 canônico é exclusivamente "linguagem-base estável".

> **Nota — P12 e o runtime Python atual (ajuste cross-IA Codex 2026-05-10):**
> P12 orienta a Árvore Estável **futura** do useHBN. **NÃO invalida** o
> runtime Python v0.3.0 atual; runtime Python e P12 coexistem. A
> transição para Rust é processo plurianual via Phagocytosis (estágios
> Routed → Studied → Digested → Mastered → Contributed conforme
> `methodology/PHAGOCYTOSIS.md`). Bumpar v0.3.0 → reescrever em Rust
> não é ação imediata nem prevista para próximas releases. P12 é farol
> de longo prazo, não mandato operacional.

---

### P13 — AI-Language-Abstraction

**Declaração condensada:** O operador humano é fluente em qualquer
linguagem que sua IA fala. Decisões de linguagem são tomadas para
otimizar a IA como cliente prioritário, não a ergonomia humana
direta.

**Origem:** decisão Rust pelo Maurício (2026-05-06) apesar de nunca
ter digitado Rust — IA traduz, humano supervisiona.

**Marker:** 🟧 HBN AI-ABSTRACTION GATE

**Documento canônico:** `methodology/AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md` (a migrar do Credenciamento/usehbn/methodology/)

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

## Cadência de revisão

Os 13 princípios são revisados em cadência **anual** (mais conservadora
que tecnologias). Mudança em redação de qualquer princípio exige:

1. Cross-audit com pelo menos 2 IAs auxiliares (Antigravity + Gemini OU Codex)
2. Decisão Maurício após síntese
3. Cápsula de auditoria registrando o porquê
4. Append-only — princípio antigo permanece com nota `superseded-by`

Adição de novo princípio (P14+) segue mesmo fluxo, com requisito
adicional de pelo menos 2 incidências reais que motivaram a
formulação.

> **Nota — relação com a Quarta de Sanitização (ADR-001)**: a Quarta
> NÃO é instrumento de revisão constitucional. A revisão dos 13
> princípios continua sendo cadência anual com cross-IA + decisão
> humana + cápsula de auditoria. A Quarta opera sobre doutrina
> derivada, ADRs operacionais e métricas de saúde — nunca sobre P1-P13
> diretamente.

## Conexão com outros documentos

- `methodology/USEHBN-MODULES-ARCHITECTURE.md` (a migrar) — arquitetura multi-braço onde os princípios se materializam
- `methodology/THREE-TREES-ARCHITECTURE.md` (a migrar) — modelo de progressão sob os princípios
- `radar/REGISTRY.md` (a migrar) — registro consolidado das fichas com convergência declarada
- `radar/CONVERGENCE-MATRIX.md` (a migrar) — matriz transposta princípio × tecnologia
- ADR-009 (`methodology/adr/ADR-009-constituicao-p1-p13.md`) — ratifica esta migração e estabelece processo de mudança constitucional
- `docs/PRINCIPLES.md` (descontinuado) — lista herdada de v0.2.x com 8 itens; superseded por este documento

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 (Frente 2) — primeira formalização canônica unificada dos 13 princípios. Aprovação Maurício 2026-05-09 da promoção P11-P13 a status constitucional equivalente. Origem: `~/Projetos/Credenciamento/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md`.
- v1.0-migrated — 2026-05-09 — Opus 4.7 (chat arquiteto-mestre useHBN, ~/Projetos/usehbn/) — migração canônica para `~/Projetos/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md` no MD-F do plano de bootstrap. Conteúdo idêntico ao original; apenas paths relativos ajustados para a topologia do mono-repo modular (ADR-003) e nota sobre sobrecarga semântica de P12 resolvida em 2026-05-09 (sentido "Cadência Constitucional" movido para ADR-001).

- v1.1 — 2026-05-10 — Opus 4.7 (chat arquiteto-mestre useHBN) — MD-J do plano de consolidação cross-IA. Ajustes ratificados: (a) eliminada hierarquia visual "fundadores" vs "operacionais" — P1-P13 agora têm peso constitucional idêntico (insight Antigravity); (b) nota explícita em P12 declarando que não invalida runtime Python v0.3.0 (insight Codex); (c) origem histórica preservada em rodapé/metadado de cada princípio. Conteúdo dos 13 princípios mantido íntegro.
