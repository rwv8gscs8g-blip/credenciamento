---
titulo: Architecture Brief para Gemini — Refinamento da arquitetura do usehbn-phago
diataxis: explanation
hbn-track: knowledge
audiencia: ia (Gemini Pro/Ultra)
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
proposta-de-uso: Maurício submete este documento como contexto inicial ao Gemini para crítica/refinamento arquitetural
---

# Architecture Brief para Gemini

## Como usar

Este documento é desenhado para ser submetido ao **Gemini Pro/Ultra** (Google) como contexto inicial. Gemini é forte em raciocínio arquitetural longo e crítica de design.

Fluxo sugerido:
1. Abra Gemini Pro / 1.5+
2. Cole este documento inteiro como primeira mensagem
3. Como segunda mensagem, faça pedidos específicos (ver "PEDIDOS PARA O GEMINI" no fim)
4. Itere com Gemini sobre pontos abertos
5. Trazer respostas relevantes para Opus integrar no protocolo HBN

---

# Contexto — Projeto useHBN

## Visão de uma frase

useHBN (Human Brain Net) é um **protocolo aberto para "fagocitose tecnológica segura"**: absorver conhecimento de tecnologias legadas (VBA, COBOL, Pascal, Delphi, Clipper) sem apagar sua identidade original, transformando-as em bibliotecas vivas de conhecimento técnico.

## Os 10 princípios constitucionais (vinculantes)

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

## Tese central

Tecnologia "fagocitada" pelo useHBN continua existindo como: linguagem original + documentação estruturada + padrões de uso + riscos conhecidos + conectores + exemplos + testes + tradução para outras camadas + módulos reutilizáveis por humanos e IAs.

A "fagocitose" é dupla via:
- **IA → entende o passado** — IAs reduzem fricção para compreender código legado, linguagens antigas, sistemas sem documentação
- **Passado → melhora a IA** — lógica antiga (determinística, estável) vira referência para melhorar agentes modernos

## Camadas arquiteturais

- **Camada 0 — Radar**: tecnologias observadas; estados (in-radar, under-analysis, convergence-mapped, candidate, phagocytosed, archived)
- **Camada 1 — Contato**: inventário inicial
- **Camada 2 — Leitura segura**: leitura estática, fingerprint, riscos, sandbox
- **Camada 3 — Compreensão**: extrair intenção, regras de negócio, fluxos
- **Camada 4 — Documentação viva**: niveis humano iniciante, técnico, IA, mantenedor, auditor
- **Camada 5 — Abstração**: separar regra de negócio, implementação, padrão útil, débito técnico
- **Camada 6 — Tradução**: comandos naturais, conectores, agentes, testes, mapas entre linguagens
- **Camada 7 — Validação**: testes automatizados, revisão humana, comparação antes/depois, rollback
- **Camada 8 — Evolução distribuída**: usuários contribuem com ciclos de tokens (modelo BOINC para tarefas cognitivas)

---

# Estado atual (2026-05-02)

## Repos vigentes

### `Credenciamento` (privado, TPGL v1.1)
- Sistema VBA real em produção (50+ módulos, 10 forms, 200+ comandos)
- Versão atual: V12.0.0203-rc1 (publicada hoje)
- Caso empírico de fagocitose VBA → 18 lições documentadas (L1-L18) + 7 padrões M1-M7
- Coordenação inter-IA via `.hbn/` (relay, knowledge, messages, results, readbacks)
- Documentos canônicos: `AGENTS.md`, tese 38, markers V2

### `usehbn-phago` (local AGPLv3, será público)
- Repo novo criado 2026-05-02
- Atualmente: scaffolding (LICENSE AGPLv3, README, PRINCIPLES.md, RADAR.md placeholder, METHODOLOGY.md placeholder, PROTOCOL.md placeholder, pyproject.toml esqueleto)
- Sem código Python ainda — fagocitose começa após estudo profundo das 5 tecnologias

## Radar atual (55 tecnologias inventariadas, 10 já arquivadas)

Distribuição final pós-E1.1:
- archived: 10 (foco-estrategico-temporario)
- convergence-mapped: 1 (MCP)
- in-radar: 27
- phagocytosed: 10 (já em uso real no Credenciamento)
- under-analysis: 7

## 5 tecnologias em estudo profundo (semana 2026-W18)

| Tecnologia | Categoria | Convergência | Recomendação Opus |
|---|---|---|---|
| **Tree-sitter** | conhecimento-estruturado | 9/10 | promover (parsing real de código legado) |
| **Typer** | outros (CLI) | 8/10 | candidate (Wave 11+) |
| **uv** | outros (CLI) | 10/10 | candidate (Wave 11+) |
| **OpenTelemetry** | observabilidade | 8/10 | promover (observabilidade neutra) |
| **Consent capsules** | conhecimento-estruturado | 10/10 | candidate (proposta interna) |

Detalhes em fichas individuais (`usehbn/radar/_per-technology/<slug>.md`).

---

# Arquitetura modular pretendida do usehbn-phago

## Princípio condutor

Cada tecnologia que sobrevive à fagocitose vira **módulo independente** dentro do `usehbn-phago`. Módulos:
- Crescem em ritmo próprio
- Não se acoplam fortemente entre si
- Comunicam apenas via protocolo HBN (markers V2, delta card, ERP, cápsulas)
- Podem ser fagocitados, reorganizados ou despromovidos sem afetar outros

## Estrutura pretendida

```text
~/Projetos/usehbn-phago/
├── pyproject.toml           # uv-managed (PEP 621)
├── uv.lock                  # determinístico
├── LICENSE                  # AGPLv3
├── README.md
├── PRINCIPLES.md
├── docs/
│   └── modules/
│       ├── parsing.md
│       ├── cli.md
│       ├── telemetry.md
│       └── capsules.md
└── src/
    └── hbn_phago/
        ├── __init__.py
        ├── cli/             # Typer
        │   ├── main.py
        │   ├── radar.py
        │   ├── baton.py
        │   └── capsule.py
        ├── parsing/         # Tree-sitter wrapper
        │   ├── languages.py
        │   ├── vba.py
        │   └── queries/
        │       └── vba/
        │           ├── constants.scm
        │           ├── functions.scm
        │           └── error-handling.scm
        ├── telemetry/       # OpenTelemetry SDK wrapper
        │   ├── tracer.py    # decorator @hbn_traced
        │   └── exporters.py
        └── capsules/        # Consent capsules implementation
            ├── schema.py    # Pydantic models
            ├── builder.py
            └── validator.py
```

## Diagrama de fluxo (cenário ilustrativo)

```text
Maurício roda: hbn ciclo executar onda-12

  [Typer recebe comando]
       ↓
  [uv garante ambiente reprodutível]
       ↓
  [OTel abre span "ciclo:onda-12"]
       ↓
       ├─→ [Tree-sitter parseia VBA]
       │       ↓
       │   [Tree-sitter produz AST]
       │       ↓
       │   [Análise gera lição candidata]
       │
       ↓
  [Consent capsules cria cápsula com lição + evidências]
       ↓
  [OTel fecha span; trace gravado em local-ai/traces/]
       ↓
  [Typer mostra resumo + path da cápsula]
```

Cada módulo cumpre função sem saber dos outros. Composição emerge do protocolo HBN.

---

# Restrições arquiteturais

## Particionamento de licenças
- **TPGL v1.1**: tudo dentro do `Credenciamento` (privado)
- **AGPLv3**: tudo dentro do `usehbn-phago` (público futuro)
- **Cápsulas de consentimento**: a única ponte entre os dois (com redaction-map + consent.json + license-target.txt)

## Coordenação inter-IA
- **Frente 1 (Credenciamento)**: Claude Opus dedicado a Onda 11/12+ do Credenciamento (VBA)
- **Frente 2 (usehbn)**: Claude Opus arquiteto + Codex CLI executor — pelo Roadmap esta sessão
- Particionamento de paths estrito (vide `usehbn/methodology/INTER-CHAT-COORDINATION.md`)

## Padrões de protocolo HBN
- **Markers V2** (10 marcadores semânticos): `✅ HBN ACTIVE`, `🟡 HBN NEEDS HUMAN DECISION`, `❌ HBN SECURITY BLOCKED SUGGESTION`, `🟠 HBN SOURCE DRIFT DETECTED`, `🔴 HBN RELEASE BLOCKER`, `🔵 HBN HANDOFF READY`, `⚪ HBN AUDIT-ONLY`, `🟢 HBN CHECKPOINT CLEAN`, `🟤 HBN LICENSE SPLIT REQUIRED`, `🟣 HBN PEER REVIEW REQUESTED`
- **Delta card** (formato canônico de retorno operacional, 7 linhas)
- **ERP** (Execution Result Protocol — JSON estruturado por esteira)
- **Readbacks** (snapshot de estado antes de execuções safe_track)

---

# Pontos abertos para o Gemini ajudar

## Pedido 1 — Crítica geral da arquitetura modular

A arquitetura proposta tem 4 módulos isolados (parsing, cli, telemetry, capsules) que comunicam via "protocolo HBN" (arquivos textuais). Isso é viável arquiteturalmente para um projeto Python sério, ou estou subestimando complexidade de coordenação?

Comparativo desejado: Unix philosophy + microservices + modular monolith — qual o paralelo mais útil?

## Pedido 2 — Ordem de implementação

Sugeri ordem: **uv → Typer → Tree-sitter → OpenTelemetry → Consent capsules** (Consent capsules em paralelo).

Você concorda? Ou há ordem melhor considerando dependências, valor entregue, riscos de rework?

## Pedido 3 — Pontos de integração não óbvios

Há integrações entre essas 5 tecnologias que eu não considerei? Por exemplo:

- Tree-sitter pode gerar `evidence.json` automaticamente para cápsulas (extraindo refs de código)?
- OTel pode capturar trace de `hbn capsule create` para auditoria de promoção?
- Typer pode usar Rich (já dep) para formatar saídas de Tree-sitter (ASTs)?

## Pedido 4 — Riscos arquiteturais

Quais riscos arquiteturais você vê que eu posso ter subestimado?

- Versionamento entre módulos quando crescerem?
- Acoplamento implícito via formatos de arquivo do protocolo?
- Performance quando vários módulos precisam comunicar?
- Manutenibilidade em 5+ anos?

## Pedido 5 — Comparativos com projetos similares

Conhece projetos open-source com arquitetura similar (módulos comunicando via protocolo textual neutro)? Quais as lições deles?

Possíveis referências:
- Org-mode (Emacs) com seus módulos
- Pandoc com filtros
- Prometheus com exporters
- LSP servers com clients
- LLVM com passes

## Pedido 6 — Permeabilidade do radar

Defini Camada 0 (radar) com permeabilidade alta na entrada e filtro de impacto na saída (vide `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`).

A política está bem-balanceada? Em projetos análogos (CNCF Landscape, Awesome lists, Tech Radar do ThoughtWorks), o que aprenderam sobre manter radar útil sem virar zumbi documental?

## Pedido 7 — Cápsulas como módulos independentes que crescem

A frase central de Maurício: "criar cápsulas de conhecimento como módulos independentes que possam crescer no usehbn".

Esse padrão ressoa com algum framework conceitual (data products, knowledge graphs, knowledge bases versionadas)?

## Pedido 8 — Inquietações sobre vendor risk

Stack inclui dependência média/alta em **Astral** (uv + ruff). Astral é startup VC-backed.

Como mitigar vendor risk ao adotar uv como camada base, sem perder os benefícios?

---

# PEDIDOS PARA O GEMINI (após colar este documento, faça os 4 pedidos abaixo)

## Pedido A — Crítica completa
"Critique esta arquitetura inteira. O que está bem pensado? O que tem buraco? O que falta? Seja rigoroso."

## Pedido B — Sugestões concretas
"Para cada um dos 8 pontos abertos acima, me dê resposta concreta com referências (livros, papers, projetos). Privilegie sugestões práticas implementáveis em 4-6 semanas."

## Pedido C — Ordem alternativa
"Proponha uma ordem alternativa de implementação das 5 tecnologias (diferente da que Opus sugeriu). Justifique a alternativa."

## Pedido D — Cenário "1 ano depois"
"Imagine que estamos 1 ano à frente. O usehbn-phago foi adotado por 50 desenvolvedores externos. Que problemas arquiteturais provavelmente surgiram? Como o desenho atual lida ou falha em lidar com eles?"

---

# Material complementar (referências para Gemini consultar)

- Tese completa: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Markers V2: `.hbn/knowledge/0005-protocolo-markers-v2.md`
- Pipeline de fagocitose: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Roadmap de incorporação: `usehbn/study-plans/00-INTEGRATION-ROADMAP.md`
- Study plans individuais: `usehbn/study-plans/0X-<tecnologia>-study-plan.md`

(Maurício: cole estes arquivos como anexos ao Gemini se ele aceitar; senão, descreva resumidamente o que cada um cobre quando perguntado.)

## Versão

- v1.0 — 2026-05-02 — brief inicial.
