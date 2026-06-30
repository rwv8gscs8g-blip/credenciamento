---
titulo: Proposta de Melhoria do Site usehbn.org — versão rica e motivacional
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: humano (Maurício para decisão; público após implementação)
versao-sistema: V12.0.0203
data: 2026-05-06
autor: Claude Opus 4.7 (Frente 2) após pedido de Maurício 2026-05-06
licenca-target: usehbn (AGPLv3)
status: PROPOSTA — aguardando aprovação Maurício para implementação
---

# Proposta de Melhoria do Site usehbn.org

## Contexto

Maurício pediu em 2026-05-06: "Faça uma proposta de melhoria do site de forma mais rica e motivacional do usehbn.org para ficar mais fácil o entendimento e o caminho que estamos seguindo."

Esta proposta cobre **estrutura de páginas, copy textual e roadmap de publicação**. Não tenho acesso direto ao código atual do site — proposta é desenhada para ser independente de qual stack o site use (Hugo, Astro, MkDocs, Jekyll, raw HTML).

## Premissas (corrigidas pós-2026-05-06)

- useHBN é **um conjunto de intenções declaradas para coordenação humano-IA** com múltiplos braços/módulos (não apenas fagocitose)
- Princípios constitucionais (10) + operacionais (3 candidatos) governam todo o protocolo
- Modelo das 3 Árvores (Estável/Desenvolvimento/Exploração) aplica-se a cada módulo
- Linguagem-base: Rust (Árvore Estável) — declarado em 2026-05-06
- Casos reais: Credenciamento V12.0.0203 (VBA), Tree-sitter (parsing), Consent Capsules (assinatura), OpenTelemetry (observabilidade)

## Estrutura de páginas proposta

```text
usehbn.org/
├── /                              → Landing page (hero + visão de 30s)
├── /vision                        → Visão e tese central
├── /principles                    → 10 princípios + 3 operacionais
├── /modules/                      → Os módulos do useHBN
│   ├── /modules/phagocytosis     → Módulo 1 — Fagocitose
│   ├── /modules/capsules         → Módulo 2 — Consent Capsules
│   ├── /modules/coordination     → Módulo 3 — Coordenação inter-IA
│   ├── /modules/security         → Módulo 4 — Segurança
│   ├── /modules/markers          → Módulo 5 — Markers V2
│   └── /modules/cross-audit      → Módulo 6 — Auditoria Cruzada
├── /three-trees                   → Modelo das 3 Árvores
├── /roadmap                       → Roadmap público (próximos 6 meses)
├── /case-studies/                 → Casos reais
│   ├── /case-studies/credenciamento  → Caso fundador
│   ├── /case-studies/tree-sitter     → Tecnologia incorporada
│   └── /case-studies/consent-capsules → Primeira migração estruturada
├── /contribute                    → Como contribuir
├── /community                     → Comunidade + canais
├── /docs                          → Link para documentação técnica (V2 do useHBN)
└── /blog                          → Posts e atualizações
```

## Páginas detalhadas

### Página 1 — Landing (/) — visão de 30 segundos

#### Hero section

**Título principal** (h1):

> **useHBN — Human Brain Net**
> Protocolo aberto de coordenação humano-IA

**Subtítulo** (h2 ou parágrafo grande):

> Princípios constitucionais para preservar tecnologias legadas, coordenar IAs com segurança e construir software que sobreviva décadas — escrito com a IA, lido por humanos, transcritível para qualquer linguagem.

**Chamada de ação principal** (botões):

- 🪨 Como adotar — link para `/contribute`
- 📖 Princípios — link para `/principles`
- 🧪 Casos reais — link para `/case-studies`

#### Pitch em três pontos (3 colunas)

```text
┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐
│ 🌳 Protocolo aberto  │ │ 🪨 Substrato sólido  │ │ 🤝 Coordenação real  │
│                     │ │                     │ │                     │
│ AGPLv3, princípios  │ │ Compilado em Rust   │ │ Markers V2 +        │
│ permanentes,        │ │ para décadas de     │ │ delta cards +       │
│ frameworks          │ │ estabilidade.       │ │ cápsulas para IAs   │
│ descartáveis.       │ │ Microssegundos      │ │ trabalharem juntas  │
│                     │ │ contam.             │ │ com humanos.        │
└─────────────────────┘ └─────────────────────┘ └─────────────────────┘
```

#### Banner motivacional (centro da página)

> **"As coisas devem simplesmente funcionar, porque estão certas e foram colocadas na ordem certa. Podendo ser transcritas para qualquer linguagem que exista ou venha ser inventada."**
>
> — Luís Maurício Junqueira Zanin, articulação fundadora

#### Métricas/status público (rodapé do hero)

- **6 módulos** declarados ou em desenvolvimento
- **13 princípios** (10 constitucionais + 3 operacionais)
- **17 markers V2** (vocabulário compartilhado)
- **AGPLv3** — totalmente aberto

### Página 2 — Visão (/vision)

**Título**: useHBN — uma visão de coordenação humano-IA

**Estrutura**:

1. **O problema** (2 parágrafos)
   - IAs estão escrevendo software em volume crescente
   - Cadeias de dependências legacy se acumulam ("metástase de dependências")
   - Tecnologias antigas (VBA, COBOL, Pascal) carregam regras de negócio críticas mas viram "caixas pretas"
   - Sem protocolo, cada projeto recria os mesmos erros

2. **A proposta** (3 parágrafos)
   - useHBN é um **conjunto de intenções declaradas** para coordenação humano-IA
   - Múltiplos braços materializam essas intenções progressivamente
   - Filosofia: preservar identidade, código limpo, lógica formal portável

3. **A tese central — fagocitose tecnológica segura** (3 parágrafos)
   - Tecnologias fagocitadas viram **bibliotecas vivas de conhecimento**
   - Não substitui — absorve preservando identidade
   - Dupla via: IA entende o passado; passado melhora a IA

4. **Os 10 princípios** (lista clicável que leva a `/principles`)

5. **Os 6 módulos do useHBN** (cards clicáveis)

### Página 3 — Princípios (/principles)

**Layout**: 13 cards (10 constitucionais + 3 operacionais), cada um com título + 1 frase + link para detalhamento.

**Card padrão**:

```text
┌──────────────────────────────────────────────┐
│ P1 — Preservar antes de transformar           │
│                                              │
│ Toda mudança em tecnologia legada começa por │
│ preservar o que existe. Transformação só     │
│ depois de entender, documentar e testar.     │
│                                              │
│ → Detalhes • → Casos onde aplica             │
└──────────────────────────────────────────────┘
```

**Princípios operacionais** (após os 10 constitucionais):

```text
🟦 P11 candidato — Minimalismo de Cadeia
🟪 P12 candidato — Substrato Sólido
🟧 P13 candidato — IA-Language-Abstraction
```

Cada um com explicação curta + link para documento canônico.

### Página 4 — Módulos (/modules)

**Layout**: tabela de módulos com status visual (badge).

```text
┌──────────────────────┬──────────────────────────────────────────────┬─────────────────────┐
│ Módulo               │ Função                                       │ Status              │
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 🌳 Fagocitose         │ Absorver tecnologias legadas preservando     │ 🔧 em desenvolvimento │
│                      │ identidade                                   │                     │
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 🔐 Consent Capsules   │ Assinatura, compatibilidade, redução de erros│ 🔧 migração ativa   │
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 🤝 Coordenação inter-IA│ Markers, delta cards, passagem de bastão     │ 📋 declarado / parcial│
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 🛡️ Segurança          │ Glasswing-style; gates preventivos            │ 📋 declarado         │
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 💬 Markers V2         │ Vocabulário semântico compartilhado humano-IA│ 🔄 em uso operacional│
├──────────────────────┼──────────────────────────────────────────────┼─────────────────────┤
│ 🔄 Auditoria Cruzada  │ Validação cruzada antes de fechar esteiras   │ 📋 protocolo declarado│
└──────────────────────┴──────────────────────────────────────────────┴─────────────────────┘
```

Cada módulo é página clicável com detalhes técnicos.

### Página 5 — Modelo das 3 Árvores (/three-trees)

**Diagrama central** (versão SVG do diagrama do `THREE-TREES-ARCHITECTURE.md`).

**Texto explicativo**: 3 parágrafos por árvore + critérios de transição.

**Tabela final**: estado atual de cada módulo nas 3 árvores.

### Página 6 — Roadmap (/roadmap)

**Timeline visual** (próximos 6 meses):

```text
Maio 2026     │ R-A Consent Capsules (Python POC)
              │ Estudo OpenTelemetry concluído
              │ V2 documentação useHBN — F2 redação
              │
Junho 2026    │ R-B Consent Capsules (Rust 1:1)
              │ Tree-sitter Fase B — POC parsing VBA
              │ V2 — F3 revisão Maurício
              │
Julho 2026    │ R-C Consent Capsules (Rust idiomatic)
              │ Tree-sitter Fase C — Integração protocolar
              │ OpenTelemetry Fase O-A
              │
Agosto 2026   │ R-D Consent Capsules → Árvore Estável
              │ Tree-sitter Fase D — Documentação
              │ OpenTelemetry Fase O-B (Rust own implementation)
              │
Setembro 2026 │ Tree-sitter Fase E — Adoção operacional
              │ R-E Consent Capsules — V2 useHBN publicada
              │ Auditoria cruzada IA em fluxo regular
              │
Outubro 2026  │ V2 useHBN publicada no GitHub
              │ Primeiros adopters externos convidados
              │ Cápsulas reais promovidas com consent
```

### Página 7 — Casos reais (/case-studies)

**Card layout** com 3 casos:

```text
┌────────────────────────────────────────────┐
│ Caso 1 — Credenciamento V12.0.0203          │
│ Sistema VBA real em produção (50+ módulos) │
│ Onda 11 fechada com release v12.0.0203-rc1 │
│ Caso fundador da fagocitose VBA            │
│ → leia mais                                │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│ Caso 2 — Tree-sitter como linguagem comum   │
│ Parser real de código legado               │
│ ASTs como notação canônica humano-IA       │
│ Substituirá regex frágil no hbn-phago      │
│ → leia mais                                │
└────────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│ Caso 3 — Consent Capsules em migração Rust  │
│ Primeiro projeto demonstrador 3 árvores    │
│ R-A→R-E em ~10 semanas                     │
│ Tecnologia de assinatura + compatibilidade │
│ → leia mais                                │
└────────────────────────────────────────────┘
```

### Página 8 — Como contribuir (/contribute)

**Estrutura**:

1. **Para desenvolvedores Rust** — `usehbn-phago`, `usehbn-capsules`, `usehbn-otel-rust`
2. **Para arquitetos** — críticas e propostas a princípios
3. **Para case studies** — submeter sistemas legados como casos
4. **Para curadores de gramáticas Tree-sitter** — adicionar suporte a linguagens novas
5. **Para revisores** — auditoria cruzada de PRs

**CLA inline** referenciando AGPLv3.

### Página 9 — Comunidade (/community)

- GitHub Discussions (links)
- Discord ou Matrix (a decidir)
- Twitter/Mastodon
- Newsletter (opcional)
- Code of Conduct (link)

### Página 10 — Blog (/blog)

Posts iniciais sugeridos:

1. **"useHBN — por que outro protocolo?"** — manifesto fundador
2. **"Por que escolhemos Rust como linguagem-base"** — derivação dos 3 princípios operacionais
3. **"O modelo das 3 Árvores"** — explicação detalhada com diagramas
4. **"Auditoria cruzada entre IAs — como funciona"** — protocolo Módulo 6
5. **"Da regex frágil ao parser real — Tree-sitter no useHBN"** — caso técnico
6. **"Cápsulas de consentimento — assinando código com propósito"** — Module 2 explicado
7. **"O paradigma da IA-como-abstração-de-linguagem"** — argumento filosófico
8. **"Linus, Python e Rust — a tradição radical da simplicidade"** — racional histórico

## Princípios visuais

### Tom

- **Técnico mas acessível** — devs puristas como audiência primária
- **Sóbrio mas motivacional** — substância > marketing
- **Citações de Maurício preservadas** literalmente em pontos-chave
- **Visualizações** preferidas sobre prosa onde caber

### Tipografia

- **Títulos**: sans-serif moderna (Inter, Geist, IBM Plex Sans)
- **Corpo**: legível em alto-DPI (Inter, Source Sans Pro)
- **Código**: monospace de qualidade (Fira Code, JetBrains Mono, Geist Mono)

### Cores

- **Substrato Sólido**: tons de cinza escuro/grafite (sobriedade)
- **Acentos**: laranja Rust (homenagem à linguagem) ou turquesa (neutro)
- **Markers V2**: cores oficiais dos markers (✅ verde, 🟦 azul, 🟪 roxo, 🟧 laranja, etc.)

### Imagens/diagramas

- **Diagramas SVG inline** para 3 árvores, módulos, fluxo de auditoria
- **Sem imagens stock** (clichê tech)
- **Screenshots** apenas onde demonstram funcionalidade real

## Stack técnico recomendado para o site

Considerando o **Princípio do Minimalismo de Cadeia** (que aplica também ao site):

| Aspecto | Recomendação | Razão |
|---|---|---|
| Static site generator | **Hugo** ou **Astro** | Compilação rápida; Hugo em Go (substrato sólido); Astro em Node mas gera HTML estático |
| Framework JS | **nenhum** se possível; Astro com mínimo JS | Princípio do Minimalismo |
| Hospedagem | **GitHub Pages** ou **Cloudflare Pages** | Gratuito; deploy via push |
| Domínio | **usehbn.org** (já registrado) | Manter |
| CMS | **Markdown puro no repo** | Princípio do Substrato Sólido — texto cristalino portável |
| Analytics | **Plausible** ou **nada** | Privacy-first; não-Google |
| Comments | **GitHub Discussions** ou nada | Sem JS extra; sem trackers |

Recomendação primária: **Astro + Markdown + Tailwind básico + Cloudflare Pages**. Custo zero. Build rápido.

## Roadmap de implementação do site

| Fase | Quando | Output |
|---|---|---|
| F-S1 — Aprovação desta proposta | hoje | aprovação Maurício |
| F-S2 — Design layout (wireframes) | esta semana | mockups Figma ou similar (ou Markdown puro com layout textual) |
| F-S3 — Stack técnico setup | semana seguinte | Astro/Hugo bootstrap |
| F-S4 — Implementação páginas 1-5 | 2 semanas | landing, vision, principles, modules, three-trees |
| F-S5 — Implementação páginas 6-10 | 1 semana | roadmap, case-studies, contribute, community, blog |
| F-S6 — Conteúdo do blog (posts iniciais) | 2 semanas em paralelo | 8 posts |
| F-S7 — Revisão Maurício | 1 semana | feedback integrado |
| F-S8 — Lançamento público | última semana | usehbn.org no ar com versão V2 |

**Total estimado**: 6-8 semanas. Pode ser acelerado com IA (Codex implementando layout; Opus escrevendo posts).

## Auditoria cruzada deste site

Antes do lançamento, este site passa pelo Protocolo de Auditoria Cruzada (Módulo 6):

- Auditor primário: Opus (escreveu)
- Auditor cruzado 1: Gemini (crítica de design e completude)
- Auditor cruzado 2: Maurício (decisor final + voz autêntica)
- Eventualmente: Antigravity ou outra IA para perspectiva externa

## Versão

- v1.0 — 2026-05-06 — primeira proposta após pedido explícito de Maurício de "site mais rico e motivacional".
