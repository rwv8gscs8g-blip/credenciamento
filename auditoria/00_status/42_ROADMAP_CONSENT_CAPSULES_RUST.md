---
titulo: 42 - Roadmap de Consent Capsules — primeira migração estruturada Python → Rust
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06
autor: Claude Opus 4.7 (Frente 2)
licenca-target: TPGL v1.1 (este planejamento; artefatos gerados em AGPLv3)
arvore-hbn-atual: development-branch
arvore-hbn-alvo: stable-trunk
sucessor-direto: 43_PLANO_DOCUMENTACAO_V2_USEHBN.md (V2 incorporará este roadmap como parte do núcleo)
---

# 42 — Roadmap Consent Capsules (Python → Rust)

## Por que Consent Capsules é o primeiro projeto

Maurício declarou em 2026-05-06: "absolutamente fundamental ... deve ser o primeiro projeto com fluxo estruturado para conversar para uma modelo em Rust, que evolua da linguagem atual para um repositório que trate as características da segurança".

Razões pelas quais a escolha faz sentido arquitetural:

| Razão | Justificativa |
|---|---|
| **Convergência 10/10 com princípios** | Único na lista (junto com uv que foi arquivada por outro motivo); encaixe quase perfeito com filosofia useHBN |
| **Cadeia de deps mínima** | Implementação Rust precisa apenas: serde (JSON), sha2 (hashes), ed25519-dalek (JWS) — todas crates first-class do ecossistema Rust |
| **Caso de teste do modelo das 3 árvores** | Demonstra fluxo Exploração → Desenvolvimento → Estável de forma controlada antes de aplicar a Tree-sitter (decisão #1, mais complexa) |
| **Tecnologia de assinatura/compatibilidade** | Habilita as outras migrações a virem assinadas e auditáveis — auto-referencial |
| **Sem dependência de outra tecnologia em estudo** | Diferente de Tree-sitter (que precisa gramática VBA validada) ou OpenTelemetry (que precisa POC com gen-ai conventions) |
| **Pequeno o suficiente para ser feito em semanas** | Spec dos 6 arquivos é finita; schema Pydantic→Rust é tradução direta; não há domínio externo enorme a aprender |

## Visão geral — 5 fases (R-A a R-E)

Cada fase pertence a uma **árvore** específica do modelo:

```text
Fase R-A (Python POC)              ┐ Árvore de Desenvolvimento
Fase R-B (Tradução Rust 1:1)       ┤ (transição)
Fase R-C (Rust idiomatic)          ┘
Fase R-D (Promoção à Estável)        — passa para Árvore Estável
Fase R-E (Documentação V2)           — entra na V2 do useHBN
```

## Fase R-A — Spec final e POC em Python

**Objetivo**: validar o schema dos 6 arquivos da cápsula com caso real, em Python (mais rápido para prototipar). NÃO é Rust ainda — é a especificação que vai virar Rust.

**Deliverables**:
- `usehbn-phago/modules/capsules/python_poc/schema.py` — Pydantic models para os 6 arquivos
  - `Lesson` (lesson.md frontmatter + body)
  - `Evidence` (evidence.json schema)
  - `RedactionMap` (redaction-map.json schema)
  - `Consent` (consent.json schema)
  - `LicenseTarget` (license-target.txt schema)
  - `Hashes` (hashes.json schema)
- `usehbn-phago/modules/capsules/python_poc/builder.py` — montagem de cápsula
- `usehbn-phago/modules/capsules/python_poc/validator.py` — validação cruzada (hashes, redactions aplicadas)
- **Cápsula real funcionando**: `capsule-001-L18-determinismo` — primeira cápsula real promovendo lição L18 do Credenciamento
- Tests pytest cobrindo schema válido + inválido + edge cases

**Linguagem**: Python (familiar; rápido para iteração)
**Marker**: 🌱 HBN EXPLORATION SEED → 🔧 HBN DEV BRANCH (transição em curso)
**Duração estimada**: 1 semana
**Gate de saída**:
- Cápsula L18 valida schema completo
- Hashes batem com conteúdo
- Redação aplicada (verificável)
- consent.json formal de Maurício

**Decisões críticas que precisam ser tomadas nesta fase**:
- Schema definitivo de cada um dos 6 arquivos (Pydantic models são contrato)
- Algoritmo de assinatura: Ed25519 (recomendação Opus — mais leve e seguro que RSA)
- Formato de hashes: SHA-256 (padrão indústria)
- Granularidade: 1 lição = 1 cápsula? Ou agrupamentos? — recomendo 1:1 inicialmente
- Estrutura do diretório: `capsules/<id-incremental>-<slug-curto>/` ou `capsules/<sha-prefix>/`?

## Fase R-B — Tradução Rust 1:1

**Objetivo**: traduzir o POC Python para Rust de forma fiel, **sem otimizações idiomáticas ainda**. Foco: validar que o schema funciona em Rust e que comportamento é idêntico ao Python.

**Deliverables**:
- `usehbn-phago/modules/capsules/rust_v1/Cargo.toml` — projeto Rust com cargo
- `usehbn-phago/modules/capsules/rust_v1/src/schema.rs` — structs com derive(Serialize, Deserialize) via serde
- `usehbn-phago/modules/capsules/rust_v1/src/builder.rs` — funções de montagem
- `usehbn-phago/modules/capsules/rust_v1/src/validator.rs` — validação cruzada
- `usehbn-phago/modules/capsules/rust_v1/src/main.rs` — binary mínimo CLI
- Tests `cargo test` espelhando os pytests do Python POC
- **Cápsula L18 reprocessada em Rust**: bytes de saída devem ser idênticos aos do Python POC

**Crates Rust escolhidas** (cadeia mínima):
- `serde` + `serde_json` — serialização JSON (de facto standard Rust; cadeia limpa)
- `sha2` — hashes SHA-256 (rust-crypto official)
- `ed25519-dalek` — assinatura Ed25519 (referência indústria; auditada)
- `chrono` — timestamps com timezone (precisa para `authorized_at`)

Total cadeia transitiva esperada: ~10 crates (todas mainstream, todas auditadas, todas zero-deps elas mesmas no nível conceitual). Compatível com Princípio do Minimalismo de Cadeia.

**Linguagem**: Rust (1:1 com Python)
**Marker**: 🔧 HBN DEV BRANCH + 🟫 HBN TREE TRANSITION
**Duração estimada**: 1-2 semanas
**Gate de saída**:
- Suite de testes Rust 100% verde
- **Output bit-a-bit idêntico** entre Python POC e Rust v1 para mesmas entradas
- Documentação inicial do crate (`cargo doc`)

## Fase R-C — Refinamentos Rust idiomatic

**Objetivo**: reescrever em padrões idiomáticos Rust — não tradução literal, mas Rust como Rust deve ser (ownership, lifetimes, traits, type-state pattern).

**Deliverables**:
- `usehbn-phago/modules/capsules/rust_v2/` — nova versão idiomatic
- Type-state pattern para fases da cápsula:
  - `Capsule<Draft>` (incompleta)
  - `Capsule<Validated>` (passou validator)
  - `Capsule<Signed>` (consent.jws presente)
  - `Capsule<Promoted>` (publicada no repo)
- Implementação de traits relevantes (`Display`, `Debug`, `From`, `TryFrom`)
- API ergonomic: `Capsule::new().lesson(...).evidence(...).sign(key).validate()?`
- Documentação de doctests
- Benchmarks via `criterion` para validar Princípio do Substrato Sólido (microssegundos)

**Linguagem**: Rust idiomatic
**Marker**: 🔧 HBN DEV BRANCH (refinamento)
**Duração estimada**: 2-3 semanas
**Gate de saída**:
- Output bit-a-bit ainda idêntico (regressão zero)
- Type-state pattern previne em compile-time mais erros que o validator runtime
- Benchmarks: criar+validar+assinar cápsula em < 5ms

## Fase R-D — Promoção à Árvore Estável

**Objetivo**: passar pelos gates rigorosos da Árvore Estável e tornar Consent Capsules a primeira tecnologia oficialmente em produção do `usehbn-phago`.

**Deliverables**:
- Coverage ≥ 95% (instrumentado com `cargo tarpaulin`)
- Property-based tests via `proptest` para schema validation
- Fuzzing via `cargo-fuzz` para inputs maliciosos
- ADR-001 documentando decisões de design
- Documentação canônica:
  - `usehbn-phago/docs/modules/capsules.md` — referência completa
  - `usehbn-phago/docs/tutorials/02-creating-your-first-capsule.md` — tutorial Diataxis
  - `usehbn-phago/docs/explanation/why-consent-capsules.md` — racional
- **Cápsula meta-fundadora**: `capsule-000-capsules-bootstrap` — cápsula que documenta como cápsulas funcionam (auto-referencial; primeira cápsula promovida ao repo público)
- Cápsula L18 (Determinismo) re-promovida usando Rust v2 — agora com signed `consent.json`
- Adendum à tese 38 com Consent Capsules como caso de fagocitose completa
- CHANGELOG do `usehbn-phago` com release v0.1.0

**Linguagem**: Rust v2 idiomatic
**Marker**: 🔧 → 🪨 HBN STABLE TRUNK (promoção)
**Duração estimada**: 2-3 semanas (testes + docs canônicos)
**Gate de saída**:
- Suite completa verde
- Aprovação Maurício explícita
- Cápsula meta-fundadora promovida e validada por terceiros (ainda que apenas Codex como "terceiro")
- ADR aprovado

## Fase R-E — Adoção em V2 useHBN

**Objetivo**: Consent Capsules vira um dos núcleos da documentação V2 do useHBN (a ser preparada após análise OpenTelemetry).

**Deliverables**:
- Capítulo dedicado na V2: "Consent Capsules — infraestrutura de assinatura, compatibilidade e redução de erros"
- Tutorial de adoção em outros projetos
- Cookbook de cápsulas comuns (lição, padrão, decisão arquitetural, ADR)
- Roadmap V2 da própria Consent Capsules (versionamento de cápsulas, revogação, multilíngua)

**Linguagem**: documentação (Markdown estruturado)
**Marker**: 🪨 HBN STABLE TRUNK (consolidado)
**Duração estimada**: 1 semana (parte do esforço maior da V2)
**Gate de saída**:
- V2 publicada com Consent Capsules como capítulo
- Adoção interna (Frente 1 do Credenciamento começa a gerar cápsulas reais para lições)

## Cronograma agregado

| Fase | Duração | Cumulativo |
|---|---|---|
| R-A (POC Python) | 1 semana | semana 1 |
| R-B (Rust 1:1) | 1-2 semanas | semana 2-3 |
| R-C (Rust idiomatic) | 2-3 semanas | semana 4-6 |
| R-D (Promoção Estável) | 2-3 semanas | semana 6-9 |
| R-E (V2 useHBN) | 1 semana | semana 9-10 |

**Total estimado**: ~10 semanas de trabalho efetivo. Calendário pode ser maior se Onda 12+ do Credenciamento exigir atenção da Frente 1 em paralelo.

**Início**: após geração do `42_PROMPT_UNIFICADO_CODEX.md` (depende de análise OpenTelemetry — última das 5).

## Dependências entre fases e tecnologias

| Dependência | Fase | Impacto |
|---|---|---|
| Análise OpenTelemetry concluída | antes de R-A | Decisão se OTel entra como dep ou não (provável: não, por Minimalismo de Cadeia) |
| Decisão Rust (✅ tomada) | R-B em diante | Linguagem-base estabelecida; sem refazer |
| Tree-sitter (decisão #1) | independente | Não bloqueia; mas Tree-sitter pode usar Consent Capsules para empacotar AST artifacts depois (sinergias futuras) |
| `usehbn-phago` repo bootstrap | antes de R-A | Repo já existe localmente; falta `cargo init` quando R-B começar |

## Roles na execução

| Papel | Quem | Responsabilidades |
|---|---|---|
| Decisor | Maurício | Aprovações de gate; consent.json signing |
| Arquiteto | Opus | Spec, schemas, ADRs, validação |
| Implementador R-A (Python) | Opus + Maurício | POC manual em Python — pequeno o suficiente para fazer junto |
| Implementador R-B (Rust 1:1) | Codex CLI | Tradução estruturada de Python para Rust com guia Opus |
| Implementador R-C (Rust idiomatic) | Codex + Opus iterando | Refinamento; type-state design por Opus |
| Implementador R-D (gates Estável) | Codex + Opus | Suíte de testes; docs canônicos |
| Validador final | Maurício | Aprovação para passar à Estável |

## Riscos e mitigações

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Schema dos 6 arquivos precisar mudar após R-A | Média | R-A é deliberadamente curto; iterar em horas, não semanas |
| Diferença bit-a-bit Python vs Rust por encoding (UTF-8 vs UTF-16, line endings) | Alta | Definir encoding canônico em R-A: UTF-8, LF; testar em R-B explicitamente |
| Crate ed25519-dalek ter breaking changes | Baixa | Pinar versão; auditar antes de adotar |
| Testes property-based revelarem bugs em R-D que não apareceram antes | Média | Bom — é exatamente o objetivo; budget tempo extra na R-D |
| Maurício mudar de ideia sobre granularidade (1:1 lição vs agrupamento) | Baixa-média | R-A serve para validar; mudanças após R-B custam mais |
| Onda 12+ do Credenciamento consumir tempo Frente 1 | Alta | Frente 2 (este roadmap) é independente; segue paralelo |

## Markers HBN V2 ativos no roadmap

- 🌱 HBN EXPLORATION SEED — para experimentos pré-R-A
- 🔧 HBN DEV BRANCH — fases R-A, R-B, R-C
- 🪨 HBN STABLE TRUNK — fase R-D em diante
- 🟫 HBN TREE TRANSITION — entre R-A e R-B (Python → Rust)
- 🟪 HBN SUBSTRATO GATE — invocado na decisão de migrar para Rust
- 🟧 HBN AI-ABSTRACTION GATE — invocado quando Codex/Opus traduzir Python → Rust sem operador digitar

## Consent Capsules como demonstração viva dos 3 princípios operacionais

Esta migração será caso-fundador da aplicação dos 3 princípios formalizados em 2026-05-06:

| Princípio | Como aplica em Consent Capsules |
|---|---|
| Minimalismo de Cadeia | Cadeia mínima Rust (serde + sha2 + ed25519-dalek + chrono) ~10 transitivas todas auditadas |
| Substrato Sólido | Migração Python → Rust compilado; benchmarks validam microssegundos |
| AI-Language-Abstraction | Operador (Maurício) não digita uma linha de Rust; IA traduz; operador aprova |

Sucesso desta migração **valida os princípios empiricamente**. Falha **força revisão** dos princípios.

## Próximos passos imediatos (após análise OpenTelemetry)

1. Maurício conclui análise OpenTelemetry (4ª das 5)
2. Opus gera `auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md` consolidando as 5 decisões + adendum desta tabela de roadmap
3. Codex executa esteira de bootstrap do `usehbn-phago` (pyproject mínimo se houver POC Python; Cargo.toml para Rust)
4. Frente 2 inicia R-A em Python

## Versão

- v1.0 — 2026-05-06 — roadmap inicial após aprovação Maurício de Consent Capsules como primeiro projeto da migração estruturada Python → Rust.
