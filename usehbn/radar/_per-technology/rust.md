---
titulo: Rust
slug: rust
categoria: stack-fundacional
estado: phagocytosed
data-entrada: 2026-05-06
ultima-revisao: 2026-05-06 (declarada como linguagem-base da Árvore Estável)
proxima-revisao: 2026-11-06 (revisão semestral; revisitar se Zig 1.0 amadurecer ou alternativa surgir)
fonte-radar: "auditoria/00_status/41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md (decisão Maurício 2026-05-06)"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT OR Apache-2.0 (dual-license)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
papel-no-protocolo: linguagem-base oficial da Árvore Estável (modelo das 3 árvores)
arvore-hbn: stable-trunk
tipo: stack-fundacional (não tecnologia auxiliar; é o substrato)
---

# Rust

## Por que está no radar como `phagocytosed`

Rust não é uma tecnologia que entrou no radar pelo processo normal de observação → análise. Foi **declarada como linguagem-base oficial** do useHBN/`usehbn-phago` por decisão arquitetural de Maurício em 2026-05-06, em sequência à formalização dos princípios do Minimalismo de Cadeia, Substrato Sólido e AI-Language-Abstraction.

Esta ficha existe para **registrar formalmente a decisão**, contextualizar a escolha entre alternativas (Go, Zig, Swift, OCaml — ver `LANGUAGE-PLATFORM-COMPARISON.md`) e servir de referência para todas as transições futuras.

## Resumo da tecnologia

Rust é linguagem de sistemas com **memory safety sem GC**, performance C/C++, **type system algébrico** Haskell-style. Mantida pela **Rust Foundation** desde 2021 (foundation neutra com membros corporativos: AWS, Google, Microsoft, Mozilla, Huawei, Meta).

Características técnicas relevantes para useHBN:
- Compilação nativa para macOS, Linux, Windows + WASM (cross-compilation via `cargo build --target ...`)
- Borrow checker — previne data races em compile time
- "Zero-cost abstractions" — generics, traits, iterators sem overhead em runtime
- `cargo` — ferramenta unificada (build, test, doc, format, lint, publish)
- `tree-sitter` crate — bindings Rust **nativos first-class** (não FFI) — match perfeito com decisão #1 (Tree-sitter)
- `no_std` — pode rodar sem standard library (embedded; bare metal)
- Comunidade obsessiva com correctness (clippy, miri, fuzzing como cultura cotidiana)

Adoção em produção: AWS Firecracker, Cloudflare Workers, Discord, Dropbox, Microsoft (Windows kernel partial), Linux kernel (desde 2022). Maturidade: 10+ anos em produção, 14+ anos desde primeira release pública.

Licença: dual MIT/Apache-2.0 (compatível com AGPLv3 — sublicenciável).

## Convergência com os 10 princípios useHBN + 3 operacionais

### Princípios constitucionais (10)

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| P1 | Preservar antes de transformar | sim | Borrow checker preserva invariantes; type system documenta intent |
| P2 | Documentar antes de executar | sim | `cargo doc` gera doc do código; type signatures são doc viva |
| P3 | Testar antes de refatorar | sim | `cargo test` integrado; property-based via `proptest`; fuzzing via `cargo-fuzz` |
| P4 | Explicar antes de automatizar | sim | Type signatures + comentários // /// = explicação intrínseca |
| P5 | Humano no controle | sim | Compilador é estrito; humano decide cada `unsafe` (raros) |
| P6 | Reversibilidade | sim | Commits pequenos via cargo workspace; tudo rastreável |
| P7 | Identidade preservada | sim | Bindings Rust não modificam C/Tree-sitter — chama API nativa |
| P8 | Protocolo > ferramenta | sim | Rust é ferramenta; protocolo HBN é a lógica formal |
| P9 | Frameworks descartáveis | sim | Lock-in baixo (lógica formal portável); Rust pode ser substituída no futuro |
| P10 | Segurança e não-regressão > velocidade | sim | Memory safety por design; `unsafe` opt-in explícito |

### Princípios operacionais (3 formalizados em 2026-05-06)

| Princípio | Convergência | Justificativa |
|---|---|---|
| Minimalismo de Cadeia | sim | Cultura comunitária zero-deps; `no_std` opcional; cadeias mínimas como norma |
| Substrato Sólido | sim | Linguagem compilada nativa; type system algébrico; lógica formal portável |
| AI-Language-Abstraction | sim | IAs (Claude inclusive) escrevem Rust idiomatic; operador fluente via IA |

**Convergência total: 13/13 sim, 0/13 parcial, 0/13 não.** Match arquitetural máximo.

## Por que Rust foi escolhida (vs Go, Zig, Swift, OCaml)

Resumo da análise comparativa em `LANGUAGE-PLATFORM-COMPARISON.md`:

- **vs Go**: Rust tem type system mais expressivo + memory safety sem GC; Go tem compilação mais rápida e curva mais suave. Decisão favoreceu rigor de Rust sobre velocidade de iteração de Go.
- **vs Zig**: Match filosófico mais radical mas pre-1.0 em 2026; risco temporal real. Reavaliar quando Zig 1.0 sair (provável 2027).
- **vs Swift**: ecossistema fora do Apple ainda pequeno; useHBN pretende cross-platform amplo.
- **vs OCaml**: nicho excelente para parsers; comunidade muito menor; tooling não-padrão.

**Argumento decisivo**: Tree-sitter (decisão #1 do radar) tem bindings Rust **nativos first-class**. Adotar Rust elimina FFI no caminho crítico de parsing.

## Divergências e riscos

- **Curva de aprendizado humana** — borrow checker exige modelo mental novo. **Mitigação via Princípio AI-Language-Abstraction**: Maurício é fluente em Rust via IA fluente em Rust; curva de aprendizado humana direta não é bloqueio.
- **Compilação lenta** em projetos grandes — `cargo check` mitiga durante iteração; full build pode ser lento.
- **Crates de qualidade variável** — comunidade ampla mas heterogênea; auditar antes de adotar (filtra pelo Princípio do Minimalismo).
- **Async story complicada** — múltiplas runtimes (tokio, async-std); escolher uma e padronizar.
- **Compatibilidade AGPLv3** — Rust é MIT/Apache-2.0; sublicenciável em AGPLv3 sem problema.

## Papel no protocolo useHBN

### Linguagem da Árvore Estável (rocha — décadas sem travar)

Todo código que precisar persistir como protocolo do useHBN será escrito em Rust. A Árvore Estável é o **`usehbn-phago` em Rust** — começa com módulo `parsing/` (Tree-sitter integration), depois `capsules/`, `cli/`, `radar/`, etc.

### Linguagem da Árvore de Desenvolvimento (alvo)

Implementações Python na Árvore de Desenvolvimento migram para Rust quando a lógica amadurece. Cápsulas de conhecimento documentam a migração.

### Não é a linguagem da Árvore de Exploração

Exploração permanece poliglota — Python para conexão com VBA do Credenciamento, JS para Web, qualquer ferramenta que conecte rápido. Rust entra quando a lógica está madura.

## O que muda na arquitetura imediatamente

Decisão Rust afeta retroativamente:

1. **Tree-sitter integration** — bindings Rust nativos em vez de Python (mais limpo)
2. **CLI hbn** — Rust com `clap` (zero-deps cultura) em vez de Python+Typer (arquivada)
3. **Consent capsules** — implementação Rust com `serde` para JSON; cripto via `ed25519-dalek` ou `rcrypto`
4. **OpenTelemetry** (a estudar) — `opentelemetry-rust` crate; ou implementação OTLP-JSON própria mínima
5. **Build do `usehbn-phago`** — `cargo` em vez de `uv` (uv arquivada)

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| **2026-05-06** | **n/a** | **phagocytosed (declarada)** | **Decisão arquitetural de Maurício após formalização dos princípios Minimalismo de Cadeia + Substrato Sólido + AI-Language-Abstraction. Rust escolhida sobre Go (compilação rápida mas type system simples), Zig (match filosófico mas pre-1.0), Swift (ecossistema fora-Apple pequeno), OCaml (nicho).** | **Maurício (palavra final)** |

## Referências

- [Documentação oficial Rust](https://www.rust-lang.org/learn) — guia completo
- [The Rust Book](https://doc.rust-lang.org/book/) — referência canônica
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Repositório GitHub (rust-lang/rust)](https://github.com/rust-lang/rust) — MIT/Apache-2.0
- [Rust Foundation](https://foundation.rust-lang.org/) — governance
- [tree-sitter crate (Rust binding)](https://crates.io/crates/tree-sitter) — relevante para useHBN
- [crates.io](https://crates.io/) — registry oficial
- [The Rustonomicon](https://doc.rust-lang.org/nomicon/) — para casos avançados (unsafe)
- [Comparativo de linguagens — useHBN](../../methodology/LANGUAGE-PLATFORM-COMPARISON.md) — análise interna
- [Princípio do Substrato Sólido](../../methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md)
- [Princípio AI-Language-Abstraction](../../methodology/AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md)
- [Modelo das 3 Árvores](../../methodology/THREE-TREES-ARCHITECTURE.md)

## Markers V2 ativos

- `🪨 HBN STABLE TRUNK` — Rust é a linguagem da Árvore Estável
- `🟧 HBN AI-ABSTRACTION GATE` — decisão tomada sob este princípio (Maurício adota Rust mesmo sem ter digitado uma linha)
- `🟪 HBN SUBSTRATO GATE` — decisão sob Substrato Sólido (linguagem compilada)
- `🟦 HBN MINIMALIST GATE` — Rust passa no filtro do Minimalismo (cultura zero-deps)

## Versão

- v1.0 — 2026-05-06 — declaração formal de Rust como linguagem-base do useHBN.
