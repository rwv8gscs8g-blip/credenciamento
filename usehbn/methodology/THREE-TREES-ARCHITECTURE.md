---
titulo: Modelo das Três Árvores — arquitetura de progressão tecnológica do useHBN
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06
autor: articulado por Luís Maurício Junqueira Zanin (hearback uv 2026-05-06 tarde); formalizado por Claude Opus 4.7 (Frente 2)
licenca-target: usehbn (AGPLv3)
status-protocolo: modelo arquitetural vigente; complementa os 10 princípios constitucionais + 3 princípios operacionais formalizados em 2026-05-06
complementa: MINIMALISM-PRINCIPLE.md, SUBSTRATO-SOLIDO-PRINCIPLE.md, AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md
revisar-em: cada decisão de transição entre árvores
---

# Modelo das Três Árvores

## Origem — articulação operacional de Maurício

Em 2026-05-06 (tarde), em sequência aos arquivamentos de Typer e uv e à formalização dos princípios do Minimalismo de Cadeia + Substrato Sólido, Maurício articulou um modelo arquitetural inédito (citação operacional):

> "Vamos criar árvores de abstração. A árvore estável é em Rust, compilada, ou compilada em outra linguagem e pode ficar ligada em máquinas por décadas sem travar. A árvore de desenvolvimento vai ter processos de migração de linguagens mais abertas para a escolha da linguagem compilada padrão (por hora Rust). A árvore de exploração e estudo pode ser qualquer linguagem, mesmo as não compiladas, como Python e outras, para associação e conexão com as bordas das diferentes tecnologias. Quando a lógica estiver madura, migra a funcionalidade e migra a tecnologia. Como os frameworks podem ser substituídos (inclusive as linguagens) essa é uma forma de amadurecimento e experimentação. Deixando aberta para o novo, e para os avanços, mas uma rocha sólida para a estabilidade."

Este documento formaliza o modelo como **camada arquitetural canônica** do useHBN — radicaliza o princípio P9 (frameworks descartáveis) ao incluir a linguagem-base como elemento descartável dentro de processo controlado.

## Visão geral — as três árvores

```text
┌──────────────────────────────────────────────────────────────────┐
│ ÁRVORE DE EXPLORAÇÃO E ESTUDO                                    │
│ ⚡ Qualquer linguagem · POCs · prototipagem · bordas             │
│ → Validar hipóteses, conectar com tecnologias externas           │
│ Linguagens hoje: Python, JS, Bash, qualquer outra                │
└─────────────────────────────┬────────────────────────────────────┘
                              │
                              │ hipótese provada → lógica de negócio extraída
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│ ÁRVORE DE DESENVOLVIMENTO                                        │
│ 🔧 Migração progressiva · testes razoáveis · docs em curso       │
│ → Mover funcionalidades amadurecidas em direção à estabilidade   │
│ Linguagens hoje: Python (em transição), Rust (alvo)              │
└─────────────────────────────┬────────────────────────────────────┘
                              │
                              │ implementação testada + cápsula de conhecimento
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│ ÁRVORE ESTÁVEL                                                   │
│ 🪨 Compilada · décadas sem travar · gates rigorosos              │
│ → Protocolo que persiste; uso operacional real                   │
│ Linguagem hoje: Rust (decisão 2026-05-06; pode evoluir)          │
└──────────────────────────────────────────────────────────────────┘
```

Cada árvore opera com **filtros, ritmos e responsabilidades distintas**.

## Árvore de Exploração e Estudo

### Propósito
Espaço de **conexão com bordas**: integração com tecnologias externas, validação de hipóteses, prototipagem rápida, extração de regras de negócio de sistemas legados (VBA do Credenciamento, COBOL futuro, etc.).

### Características
- **Qualquer linguagem** — Python, JavaScript, Ruby, Bash, R, qualquer ferramenta que conecte rápido
- **Sem compromisso de longevidade** — código pode ser descartado livremente
- **Foco em hipóteses** — "isso funciona? a regra de negócio é assim mesmo?"
- **Documentação leve** — README + comentários inline; docs formais não obrigatórias
- **Testes opcionais** — verificação manual aceitável

### Critérios de entrada
- Pergunta concreta a responder: "como X funciona?", "Y é viável?", "Z se conecta com W?"
- Justificativa: por que vale a pena investigar isso?

### Critérios de saída (passar para Desenvolvimento)
- Hipótese provada com evidência concreta
- **Regra de negócio extraída e documentada** em formato de "lição" estruturada (lesson.md)
- Cápsula de conhecimento embrionária (mesmo que sem consent.json final)

### Marker associado
`🌱 HBN EXPLORATION SEED` — código nasceu na árvore de exploração; pode ser descartado.

## Árvore de Desenvolvimento

### Propósito
Espaço de **migração progressiva** entre exploração e estabilidade. Aqui a lógica amadurece, é testada, documentada, e preparada para virar Rust se for o caso.

### Características
- **Linguagens em transição** — começando provavelmente em Python (familiar, rápido) e migrando para Rust conforme amadurece
- **Compromisso médio prazo** — código aqui dura 3-12 meses tipicamente
- **Foco em estabilizar lógica** — refinamento de regras, testes, edge cases
- **Documentação progressiva** — docs/01-04 conforme template `INCORPORATION-PROGRESSIVE-PLAN.md`
- **Testes obrigatórios** — pytest (Python) ou cargo test (Rust); coverage razoável

### Critérios de entrada
- Vem da Exploração com regra de negócio documentada
- Cápsula de conhecimento embrionária criada
- Decisão consciente: "isso vai virar parte do useHBN"

### Critérios de saída (passar para Estável)
- Implementação testada com cobertura ≥ 80%
- Documentação completa
- **Reescrita em Rust validada** (se ainda estava em outra linguagem)
- Cápsula de consentimento finalizada (consent.json + redaction-map + license-target)
- Aprovação Maurício para promoção

### Marker associado
`🔧 HBN DEV BRANCH` — código em progressão; sujeito a refatoração.

## Árvore Estável

### Propósito
**Protocolo que persiste**. Código que pode ficar em produção por décadas sem manutenção emergencial. Base sobre a qual outros constroem.

### Características
- **Linguagem compilada** — Rust por decisão 2026-05-06 (revisitar se Zig 1.0 madurar bem, ou outra alternativa surgir)
- **Compromisso de décadas** — código aqui é "a rocha"
- **Foco em correctness e performance** — zero overhead, memory safety, behavior predictable
- **Documentação canônica** — referência mundial; tutorials Diataxis; vocabulary reference
- **Testes rigorosos** — coverage > 95%; property-based tests; integration tests; benchmarks
- **Mudanças via processo formal** — RFCs; ADRs; mínimo 2 revisores

### Critérios de entrada (vindo de Desenvolvimento)
- Suite completa de testes verde + benchmark estabilizado
- Cápsula de consentimento + license-target = AGPLv3
- ADR documentando decisão arquitetural
- Aprovação Maurício explícita

### Critérios de saída (despromoção — raro)
- Tecnologia tornou-se inerentemente insegura (CVE não corrigível)
- Substituição por candidata superior demonstrada empiricamente
- Decisão estratégica de Maurício após 6+ meses de uso

### Marker associado
`🪨 HBN STABLE TRUNK` — código rocha; mudanças via processo formal.

## Movimento entre árvores

### Trajetória padrão (forward)
```
Exploração → Desenvolvimento → Estável
```
Hipótese vira regra de negócio vira implementação canônica.

### Trajetória reversa (raro mas permitido)
```
Estável → Desenvolvimento → Exploração ou Archived
```
Quando uma decisão estável precisa ser repensada (mudança de paradigma, breaking insight, etc.).

### Trajetória de "salto"
```
Exploração → Estável (raro, requer justificativa)
```
Apenas quando: tecnologia já madura externamente + caso de uso muito claro + Maurício decide acelerar.

### Movimento entre Exploração e Estável simultâneo
Permitido — uma tecnologia pode ter implementação na Exploração (POC em Python) E na Estável (código Rust em produção) **ao mesmo tempo**. A da Estável é a "fonte da verdade"; a da Exploração serve para experimentar próximas evoluções sem desestabilizar a Estável.

## Estado atual do useHBN nas três árvores (2026-05-06)

### Árvore Estável (Rust — apenas declarada; código futuro)
- *vazia ainda* — implementação Rust começa após decisão arquitetural maior aprovada e prompt unificado para Codex
- Linguagem oficial: **Rust** (decisão Maurício 2026-05-06)
- Primeiro candidato a entrar: módulo `parsing/` baseado em Tree-sitter (decisão #1 já tomada)

### Árvore de Desenvolvimento (transitória)
- `usehbn-phago` em Python (pretendido) → ponte temporária; vai migrar para Rust
- Cápsulas de consentimento (proposta interna) — em design; implementação Python primeiro, Rust depois
- CLI `hbn` — desenho começou em Python (Typer/Click) mas Typer arquivada; reavaliar em Rust direto

### Árvore de Exploração e Estudo (ativa)
- **Sistema Credenciamento (VBA)** — fonte primária de regras de negócio; alvo de fagocitose
- **POCs Tree-sitter** — primeiros experimentos de parsing (planejados)
- **POCs cápsulas** — manual de cápsula com lição L18 (planejado)
- Notebooks LM com 5 tecnologias estudadas — output da exploração conceitual

## Como tecnologias do radar se mapeiam às árvores

| Tecnologia | Árvore atual | Árvore alvo |
|---|---|---|
| Tree-sitter | Exploração (estudada) | Estável (após Fase E do plano 6 fases) |
| Typer | (arquivada — não entrou em nenhuma árvore) | n/a |
| uv | (arquivada — não entrou em nenhuma árvore) | n/a |
| OpenTelemetry | a estudar | a decidir após estudo |
| Consent capsules | em design (Exploração) | Desenvolvimento → Estável |
| **Rust** | **declarada como linguagem da Estável** | **Estável (decisão tomada)** |

## Filtros aplicados em cada árvore

### Filtros para Árvore de Exploração (baixos)
- Curiosidade legítima
- Tempo razoável (não meses parado)

### Filtros para Árvore de Desenvolvimento (médios)
- Os 10 princípios constitucionais
- Princípio do Minimalismo de Cadeia
- Princípio do Substrato Sólido (com tolerância — ainda não chegou no Rust)
- Princípio AI-Language-Abstraction (irrelevante aqui — qualquer linguagem aceita)
- Testes obrigatórios

### Filtros para Árvore Estável (altos)
- TODOS os 10 princípios constitucionais
- TODOS os 3 princípios operacionais formalizados (Minimalismo, Substrato, AI-Abstraction)
- Linguagem compilada (Rust hoje)
- Cobertura de testes > 95%
- Documentação canônica completa
- Cápsula de consentimento
- ADRs documentados
- Aprovação humana explícita

## Marker HBN V2 derivado (proposta)

Adendum proposto ao `0005-protocolo-markers-v2.md`:

| Marker | Quando usar |
|---|---|
| `🌱 HBN EXPLORATION SEED` | Código vive na Árvore de Exploração; pode ser descartado |
| `🔧 HBN DEV BRANCH` | Código vive na Árvore de Desenvolvimento; sujeito a refactor |
| `🪨 HBN STABLE TRUNK` | Código vive na Árvore Estável; mudanças via processo formal |
| `🟫 HBN TREE TRANSITION` | Código transitando entre árvores (ex.: Dev → Estável) |

Esses 4 markers complementam o sistema V2 existente — orientam contexto operacional pela árvore.

## Aplicação prática — primeiros passos

### Passo 1 — declarar Rust como linguagem da Árvore Estável
Já feito — esta decisão é registrada em:
- `usehbn/radar/_per-technology/rust.md` (ficha do radar com estado especial)
- `auditoria/00_status/41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md`

### Passo 2 — categorizar trabalho atual em árvores
- `Credenciamento/src/vba/` → Árvore de Exploração (sistema legado, fonte de regras)
- `usehbn-phago/` (Python pretendido) → Árvore de Desenvolvimento (transitório)
- `usehbn-phago/` futuro Rust → Árvore Estável (alvo)

### Passo 3 — estabelecer processo de migração Dev → Estável
Formalizado em prompt unificado ao Codex (a ser criado em `auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md`).

### Passo 4 — adicionar markers em todos os documentos novos
Cada arquivo daqui em diante declara em qual árvore vive (campo `arvore-hbn` no frontmatter).

### Passo 5 — criar dashboard das 3 árvores
Eventual `usehbn-phago/docs/three-trees-dashboard.md` mostrando o que está em cada árvore agora.

## Conexão com princípios constitucionais e operacionais

### Conexão com os 10 princípios constitucionais
| Princípio | Relação com 3-trees |
|---|---|
| **P1 — Preservar antes de transformar** | Exploração preserva; Estável transforma com cuidado |
| **P3 — Testar antes de refatorar** | Cada árvore tem nível de teste apropriado |
| **P6 — Reversibilidade** | Tecnologias podem voltar de Estável para Dev se contexto mudar |
| **P8 — Protocolo > ferramenta** | As árvores são o protocolo; linguagens são ferramentas |
| **P9 — Frameworks descartáveis** | Radicalizado: até linguagens são descartáveis (Rust hoje, possivelmente outra amanhã) |
| **P10 — Segurança e não-regressão** | Filtros progressivos garantem qualidade aumentada por árvore |

### Conexão com os 3 princípios operacionais
| Princípio operacional | Como 3-trees aplica |
|---|---|
| **Minimalismo de Cadeia** | Filtros mais rigorosos na Estável bloqueiam deps desnecessárias |
| **Substrato Sólido** | Estável exige linguagem compilada; Dev pode estar em transição; Exploração permite qualquer |
| **AI-Language-Abstraction** | Liberta humanos de prender-se a linguagens; árvores formalizam o ecossistema dessa liberdade |

## Sinais para revisão deste modelo

Este modelo deve ser revisado se:
- Surgir necessidade de 4ª árvore (improvável; complica o modelo)
- Movimentos entre árvores se mostrarem mais raros do que esperado (modelo overengineered)
- IAs pararem de ser camada de abstração de linguagem (improvável; mais provável o oposto)
- Uma única árvore comportar todos os casos (improvável dado a tese 38)

## Status protocolar

- **Modelo arquitetural vigente** desde 2026-05-06
- **Candidato a P12 ou P13 constitucional** após 3+ aplicações documentadas (em conjunto com IA-Language-Abstraction)
- **Promovido a documento canônico** do `usehbn-phago` quando a Árvore Estável tiver primeiro código

## Versão

- v1.0 — 2026-05-06 — formalização inicial após articulação radical de Maurício sobre 3 árvores + decisão Rust.
