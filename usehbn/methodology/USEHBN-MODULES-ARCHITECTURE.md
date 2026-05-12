---
titulo: Arquitetura de Módulos do useHBN — useHBN é multi-braço; fagocitose é apenas UM dos braços
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06
autor: Claude Opus 4.7 (Frente 2) após correção explícita de Luís Maurício Junqueira Zanin
licenca-target: usehbn (AGPLv3)
status: corrige interpretação errada presente em documentos anteriores criados por Opus desde 2026-05-02
publicacao-prevista: GitHub usehbn-phago — esta semana após aprovação Maurício
---

# Arquitetura de Módulos do useHBN

## Reconhecimento de erro de interpretação prévia

Em 2026-05-06 Maurício corrigiu, em comunicação direta, uma interpretação que eu (Opus) estava propagando em vários documentos:

> "Atenção Claude. A useHBN é um conjunto de intenções declaradas que ainda não estão desenvolvidas, então começamos o estudo para desenvolver um primeiro braço do useHBN que seria o módulo de fagocitose. Ou seja, esse é um braço e aconteceu e por isso estamos indo nesta linha de estudo. O protocolo é mais do que isso e pressupõe a chamada, a segurança, a forma como as IAs estão interagindo e a passagem do bastão. Apenas gastamos energia na construção do módulo de fagocitose, para ele vamos contar muito em particular com o Tree-sitter. Mas existe muita coisa a ser construída nos braços da tecnologia que por hora estão apenas declaradas como intenção, mas que irão crescer (não podemos dizer que o useHBN é apenas um sistema de fagocitose de software como você citou na documentação)."

Documentos que carregavam o erro (a corrigir):

- `38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md` (V1) — focava em fagocitose como conceito central
- `LANGUAGE-PLATFORM-COMPARISON.md` — falava em "linguagem-base do useHBN/hbn-phago" como se fossem sinônimos
- `THREE-TREES-ARCHITECTURE.md` — implicitamente tratava as árvores como árvores de "fagocitose"
- `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` — estrutura V2 estava centrada em fagocitose

Este documento estabelece a **interpretação correta** e serve de referência canônica daqui em diante. Os documentos acima recebem adendum apontando para este.

## Visão correta — useHBN como protocolo multi-braço

### Tese central revisada

> **useHBN (Human Brain Net) é um conjunto de intenções declaradas para coordenação humano-IA.** Múltiplos braços/módulos materializam essas intenções progressivamente. **Fagocitose é apenas um dos braços** — o primeiro a ganhar atenção construtiva concentrada por necessidade prática (caso Credenciamento V12.0.0203).

### Os braços/módulos do useHBN (declarados como intenção; em vários estágios de maturidade)

| # | Módulo | Status atual | Função |
|---|---|---|---|
| 1 | **Fagocitose tecnológica segura** | em desenvolvimento (primeiro braço ativo) | Absorver tecnologias legadas preservando identidade |
| 2 | **Consent Capsules — assinatura de código** | em migração imediata (aprovada 2026-05-06) | Assinatura, compatibilidade, redução de erros — usada por todos os outros módulos por padrão |
| 3 | **Coordenação inter-IA / Chamada e passagem de bastão** | declarado como intenção; parcialmente operacional | Como IAs (Opus, Codex, Antigravity, Gemini, etc.) coordenam, passam tarefas, validam outputs |
| 4 | **Segurança (Glasswing-style)** | declarado como intenção; existem fundamentos no Credenciamento | Camadas de proteção preventiva, detecção de drift, gates de segurança |
| 5 | **Markers V2 / Protocolo de comunicação semântica** | em uso operacional informal; a formalizar | Vocabulário compartilhado entre humanos e IAs (✅, 🟡, 🟦, 🟪, 🟧, 🪨, etc.) |
| 6 | **Auditoria cruzada entre IAs** | declarado como intenção; documento dedicado em `CROSS-IA-AUDIT-PROTOCOL.md` | Validação cruzada antes de fechar esteiras de desenvolvimento |
| 7 | **Outros módulos futuros** | conforme intenções amadurecerem | Espaço aberto para evolução |

### Princípios constitucionais permanecem os mesmos

Os 10 princípios constitucionais publicados em usehbn.org governam **todos os braços**, não apenas fagocitose:

1. Preservar antes de transformar
2. Documentar antes de executar
3. Testar antes de refatorar
4. Explicar antes de automatizar
5. Humano no controle por padrão
6. Toda evolução deve ser reversível
7. Nenhuma tecnologia fagocitada perde sua identidade
8. O protocolo importa mais que a ferramenta
9. Frameworks são descartáveis; princípios são permanentes
10. Segurança e não-regressão > velocidade

A trinca de princípios operacionais formalizada em 2026-05-06 (Minimalismo de Cadeia, Substrato Sólido, AI-Language-Abstraction) também aplica-se a **todos os braços**.

### O que muda nas decisões tomadas

A **decisão Rust como linguagem-base** continua válida — mas agora se entende que é a linguagem-base **do conjunto de módulos** do useHBN, não exclusivamente do "módulo de fagocitose".

O **modelo das 3 Árvores** (Estável/Desenvolvimento/Exploração) aplica-se a **todos os módulos** independentemente. Cada módulo tem suas três árvores.

## Arquitetura proposta

### Repositórios

| Repo | Conteúdo |
|---|---|
| `usehbn` (público AGPLv3 — usehbn.org) | Princípios constitucionais + protocolo de markers + documentação V2 do useHBN como conjunto de módulos |
| `usehbn-phago` (público AGPLv3) | Implementação Rust do **módulo de fagocitose** especificamente |
| `usehbn-capsules` (público AGPLv3 — futuro) | Implementação Rust do **módulo Consent Capsules** especificamente |
| `usehbn-otel-rust` (público AGPLv3 — futuro) | Implementação Rust do módulo de observabilidade (OpenTelemetry alternativa rápida) |
| `usehbn-coord` (público AGPLv3 — futuro distante) | Coordenação inter-IA quando amadurecer |

Cada módulo é um **repo independente**. Conectam-se via Consent Capsules (assinatura de código) e via protocolo HBN (markers V2 + delta card + ERP).

### Por que repos separados (não monorepo)

Coerente com:

- **P9 — frameworks descartáveis**: cada módulo pode ser substituído sem afetar os outros
- **Princípio do Substrato Sólido — lógica formal portável**: cada módulo é unidade de portabilidade
- **Princípio do Minimalismo de Cadeia**: cada módulo declara dependências mínimas
- **AI-Language-Abstraction**: IAs orquestram entre módulos; humanos exercem julgamento

### Como módulos se conectam

```text
                ┌─────────────────────────────────────────────┐
                │  usehbn (princípios + protocolo + V2 docs)   │
                │  Markers V2 · Delta card · ERP · Cápsulas    │
                └─────────────────────────────────────────────┘
                       │ governance + protocolo
        ┌──────────────┼──────────────┬──────────────┬─────────────┐
        ▼              ▼              ▼              ▼             ▼
┌───────────────┐ ┌──────────┐ ┌──────────────┐ ┌──────────┐ ┌──────────┐
│ usehbn-phago  │ │ usehbn-  │ │ usehbn-otel- │ │ usehbn-  │ │ outros   │
│ (fagocitose)  │ │ capsules │ │ rust (obs)   │ │ coord    │ │ módulos  │
│ Tree-sitter   │ │ Ed25519  │ │ OTLP+spans   │ │ inter-IA │ │ futuros  │
└───────┬───────┘ └────┬─────┘ └──────┬───────┘ └────┬─────┘ └─────┬────┘
        │              │              │              │             │
        └──────────────┴──────────────┴──────────────┴─────────────┘
                              │
                              ▼ assinaturas via cápsulas
                       (todos usam capsules)
```

Consent Capsules é **infraestrutura transversal** — todos os outros módulos a usam para assinar releases, validar integridade, declarar consentimento.

## Posicionamento dos módulos hoje (2026-05-06)

### Módulo 1 — Fagocitose (em desenvolvimento)

- Repo previsto: `usehbn-phago` (já criado em `~/Projetos/usehbn-phago/`)
- Linguagem: Python (Exploração) → Rust (Estável)
- Tecnologias incorporadas/em incorporação:
  - **Tree-sitter** — parsing real (decisão #1 do radar; aprovada 2026-05-06)
  - **OpenTelemetry** — observabilidade do processo de fagocitose (`candidate` aprovada 2026-05-06; vai virar `usehbn-otel-rust` em paralelo)
- Caso real: Credenciamento V12.0.0203 (sistema VBA)
- Status: planejamento; primeiro código Rust virá após R-A do Consent Capsules

### Módulo 2 — Consent Capsules (migração imediata)

- Repo previsto: `usehbn-capsules` (a criar)
- Linguagem: Python R-A (POC) → Rust R-B em diante
- Função: assinatura, compatibilidade, redução de erros — **usada por todos os outros módulos por padrão**
- Roadmap: 5 fases R-A a R-E em ~10 semanas
- Status: aprovada 2026-05-06; **migração inicia imediatamente**
- **Primeira manifestação concreta da Árvore Estável do useHBN**

### Módulo 3 — Coordenação inter-IA / Passagem de bastão

- Status: declarado como intenção; **parcialmente operacional** (já usamos `.hbn/relay/INDEX.md`, `.hbn/messages/`, markers V2 ✅/🟡/🟠/🔵/etc.)
- Repo previsto: `usehbn-coord` (futuro; talvez 2026-Q3+)
- Tecnologias adjacentes: MCP (Model Context Protocol — `convergence-mapped` no radar), markers V2
- Função: como IAs coordenam, passam tarefas, validam outputs, registram bastão

### Módulo 4 — Segurança (Glasswing-style)

- Status: declarado como intenção; **fundamentos existem no Credenciamento** (`.hbn/knowledge/0003-glasswing-style-preventive-security.md`)
- Repo previsto: `usehbn-glasswing` (futuro)
- Função: camadas de proteção preventiva, detecção de drift (G6/G7/G8), gates de segurança

### Módulo 5 — Markers V2 / Protocolo de comunicação semântica

- Status: **em uso operacional** mas não formalizado como módulo separado
- Documento canônico: `.hbn/knowledge/0005-protocolo-markers-v2.md`
- Função: vocabulário compartilhado humano-IA — 10 markers originais V2 + 7 novos propostos em 2026-05-06
- Provável evolução: spec versionada como `usehbn-markers` (futuro)

### Módulo 6 — Auditoria Cruzada entre IAs (declarada nesta sessão)

- Status: declarado como intenção em 2026-05-06; documento canônico em `CROSS-IA-AUDIT-PROTOCOL.md`
- Função: antes de fechar cada esteira, IAs revisam mutuamente os outputs (Opus desenha; Codex implementa; outra IA audita; Maurício decide)

## Como esta arquitetura altera a documentação V2 do useHBN

O plano original da V2 (`43_PLANO_DOCUMENTACAO_V2_USEHBN.md`) está centrado em fagocitose. **Precisa ser revisado** para refletir esta arquitetura multi-braço.

Alterações necessárias na V2:

- **Parte I (Fundação)** — manter; princípios são transversais
- **Parte IV (Tecnologias fundadoras)** — reorganizar como **Parte IV — Os Módulos do useHBN** com capítulos por módulo (não por tecnologia)
  - Capítulo 14: Módulo 1 — Fagocitose (incorpora Tree-sitter, OTel)
  - Capítulo 15: Módulo 2 — Consent Capsules (assinatura)
  - Capítulo 16: Módulo 3 — Coordenação inter-IA (declarado, em formação)
  - Capítulo 17: Módulo 4 — Segurança (declarado)
  - Capítulo 18: Módulo 5 — Markers V2 (em uso)
  - Capítulo 19: Módulo 6 — Auditoria Cruzada (em formação)
  - Capítulo 20: Outros módulos previstos
- **Parte V (Operação cotidiana)** — manter
- **Parte VI (Aplicação)** — manter mas reorganizar exemplos por módulo
- **Apêndices** — adicionar mapeamento "intenção declarada → módulo materializado"

## Princípios editoriais para correção da documentação anterior

Daqui em diante:

1. **Nunca dizer "useHBN é fagocitose"** — fagocitose é UM braço
2. **Sempre dizer "módulo de fagocitose do useHBN"** quando referindo-se ao braço específico
3. **Linkar para este documento** sempre que mencionar "braços/módulos"
4. **Adendum em documentos antigos** apontando para este

## Conexão com decisões já tomadas (sem invalidá-las)

- ✅ **Decisão Rust como linguagem-base** — continua válida; agora se entende que é a linguagem do **substrato comum** dos módulos
- ✅ **Modelo das 3 Árvores** — continua válido; **cada módulo** tem suas 3 árvores
- ✅ **3 princípios operacionais (Minimalismo / Substrato / AI-Abstraction)** — continuam válidos; aplicam-se a **todos os módulos**
- ✅ **Tree-sitter aprovada** — entra como tecnologia do **módulo de fagocitose**
- ✅ **Consent Capsules aprovada** — é **módulo paralelo** (não dentro do módulo de fagocitose)
- ✅ **OpenTelemetry aprovada** — entra como tecnologia do **módulo de fagocitose** (instrumentação) com produto derivado **`usehbn-otel-rust`** (módulo separado eventualmente)

## Documentos a serem atualizados (próxima esteira)

- [ ] `38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md` — adicionar adendum no topo apontando para este
- [ ] `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` — refatorar Parte IV
- [ ] `THREE-TREES-ARCHITECTURE.md` — esclarecer que árvores são por módulo
- [ ] `LANGUAGE-PLATFORM-COMPARISON.md` — substituir "useHBN/hbn-phago" por "módulos do useHBN"
- [ ] Site usehbn.org — refletir arquitetura multi-braço (proposta em `PROPOSTA-MELHORIA-USEHBN-ORG.md`)

Esses adendums não são urgentes — podem ser feitos sequencialmente conforme avançamos. Importante é que **este documento exista** como referência correta a partir de agora.

## Marker HBN V2 derivado (proposta)

| Marker | Quando usar |
|---|---|
| `🌳 HBN MODULE BOUNDARY` | Indica fronteira entre módulos do useHBN; importante para clareza |

## Versão

- v1.0 — 2026-05-06 — primeira versão após correção explícita de Maurício sobre o escopo do useHBN.

## 2026-05-09 addendum — fichas individuais dos 6 módulos publicadas

Os 6 módulos declarados nesta arquitetura (mais o Radar, infraestrutura
de observação) agora têm arquivos individuais no padrão declarativo
RADAR.md, em [usehbn/modules/](../modules/):

| # | Módulo | Arquivo |
|---|---|---|
| — | Radar (infraestrutura) | [usehbn/modules/RADAR.md](../modules/RADAR.md) |
| 1 | Fagocitose | [usehbn/modules/FAGOCITOSE.md](../modules/FAGOCITOSE.md) |
| 2 | Cápsulas de Consentimento | [usehbn/modules/CAPSULAS-DE-CONSENTIMENTO.md](../modules/CAPSULAS-DE-CONSENTIMENTO.md) |
| 3 | Coordenação inter-IA | [usehbn/modules/COORDENACAO-INTER-IA.md](../modules/COORDENACAO-INTER-IA.md) |
| 4 | Segurança | [usehbn/modules/SEGURANCA.md](../modules/SEGURANCA.md) |
| 5 | Marcadores | [usehbn/modules/MARCADORES.md](../modules/MARCADORES.md) |
| 6 | Auditoria Cruzada | [usehbn/modules/AUDITORIA-CRUZADA.md](../modules/AUDITORIA-CRUZADA.md) |

Índice consolidado em [usehbn/modules/INDEX.md](../modules/INDEX.md).

Cada arquivo segue estrutura canônica de 8 blocos: frontmatter,
"O que é", componentes/estados/vetores, movimento/fluxo,
filtros/gates, marcadores, conexão com outros módulos, como adotar
em outro projeto.

Este documento (`USEHBN-MODULES-ARCHITECTURE.md`) permanece como
referência conceitual correta da arquitetura multi-braço. As fichas
em `usehbn/modules/` são a declaração canônica de cada módulo
individual, derivadas dele.

Outras consequências do addendum:

- Adendum também aplicado a `.hbn/knowledge/0005-protocolo-markers-v2.md`
  com os 11 marcadores novos formalizados nesta sessão (3 dos
  princípios operacionais + 5 das 3 árvores + 3 da auditoria
  cruzada). Total agora: 21 marcadores canônicos.
- A lacuna estrutural identificada na validação inicial da sessão
  Antigravity de continuidade (5 dos 6 módulos sem arquivo
  individual em `usehbn/modules/`) está resolvida.

Próximos itens da fila (não resolvidos neste addendum):

- Refator do `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` para refletir os 6
  módulos paralelos
- Atualização da promoção formal do Tree-sitter no
  `usehbn/radar/REGISTRY.md` (`in-radar` → `candidate`)
- Documento índice canônico dos 10 princípios constitucionais (P1–P10)
- READMEs em `usehbn/methodology/`
- Geração do `46_PROMPT_UNIFICADO_CODEX.md`
