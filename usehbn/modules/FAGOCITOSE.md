---
titulo: Fagocitose
tipo: modulo-do-usehbn
papel: incorporacao progressiva e auditavel de tecnologias ao uso real
audiencia: humano + ia
licenca: AGPLv3
---

# Fagocitose

## O que e

Fagocitose e o modulo do useHBN que **incorpora tecnologias aprovadas
ao uso real** atraves de fases auditaveis com gates concretos. Recebe
tecnologias do Radar quando elas atingem o estado `candidate` e as
conduz, passo a passo, ate o uso operacional e, eventualmente, a
promocao publica.

Cada tecnologia que sobrevive a fase de estudo vira **modulo
independente** dentro do ecossistema useHBN. Modulos crescem em ritmo
proprio, nao se acoplam fortemente entre si, comunicam apenas via
protocolo HBN, e podem ser fagocitados, reorganizados ou despromovidos
sem afetar outros modulos.

O nome "fagocitose" e literal: a tecnologia entra como corpo externo,
e absorvida em fases controladas, e passa a fazer parte do organismo
sem perder sua identidade. Cada fase e auditavel; cada transicao tem
gate; cada incorporacao gera capsula de conhecimento.

O nucleo do useHBN nao e codigo — e **protocolo textual** (markers V2,
delta card, schemas de capsula). Modulos podem ser implementados em
qualquer linguagem; so precisam respeitar o protocolo nas fronteiras.

## As seis fases (F0 → F5)

| Fase | Estado da ficha radar | Output esperado |
|---|---|---|
| **F0 — Observacao** | `in-radar` | ficha curta + 1-3 linhas de motivacao |
| **F1 — Estudo profundo** | `under-analysis` | docs/01-02 + bibliografia + plano de POC |
| **F2 — POC isolado** | `under-analysis` (validado) | poc/ + tests/ basicos + ADR-001 |
| **F3 — Integracao protocolar** | `convergence-mapped` | modulo conectado ao protocolo HBN; capsula gerada |
| **F4 — Fagocitose operacional** | `candidate` → `phagocytosed` | uso real em ciclos HBN; documentacao operacional |
| **F5 — Promocao publica** | `phagocytosed` (publico) | capsula promovida via Capsulas de Consentimento |

F0 e responsabilidade do Radar (ver [RADAR.md](RADAR.md)). F1 a F5 sao
fagocitose propriamente dita.

## Movimento entre fases

```text
F0  →  F1  →  F2  →  F3  →  F4  →  F5
 ↑     ↑     ↑     ↑     ↑      
 └─────┴─────┴─────┴─────┴── (despromocao com ADR + rollback)
```

Forward e gradual. Cada transicao requer evidencia adicional. Reverse
e permitido em qualquer ponto: tecnologias podem regredir se contexto
mudar, mantenedor abandonar o projeto, concorrente melhor surgir, ou
risco operacional ser descoberto.

Despromocao radical (F4 → F0 ou `archived`) exige aprovacao explicita
do operador.

## Gates entre fases

| Transicao | Pergunta-chave | Evidencia obrigatoria |
|---|---|---|
| F0 → F1 | A tecnologia merece gasto de energia analitica? | decisao consciente do operador |
| F1 → F2 | Estudei o suficiente para tentar implementar? | docs/01 + docs/02 + bibliografia (≥5 fontes) + plano POC |
| F2 → F3 | O POC roda end-to-end com testes verdes? | poc/ + tests/ ≥5 testes verdes + ADR-001 + comparativo vs alternativa simples + rollback testado |
| F3 → F4 | A integracao com o protocolo HBN esta validada? | markers V2 corretos + capsula gerada (lesson + evidence + redaction + consent + license + hashes) + comando `hbn <modulo>` |
| F4 → F5 | Houve uso operacional estavel? | ≥30 dias sem regressao + ≥1 capsula promovida + autorizacao do operador |

## Estrutura template do modulo fagocitado

Cada tecnologia em F2 ou alem vive em
`~/Projetos/usehbn-phago/modules/<slug>/` com:

```text
modules/<slug>/
├── README.md                  # visao geral, status, link para ficha do radar
├── ficha-snapshot.md          # copia da ficha do radar no momento da incorporacao
├── docs/
│   ├── 01-fundamentos.md
│   ├── 02-relacao-principios-hbn.md
│   ├── 03-design-poc.md
│   ├── 04-roadmap.md
│   └── ADR/                   # Architecture Decision Records
├── poc/                       # provas de conceito isoladas
├── tests/                     # testes pytest
├── capsules/                  # capsulas geradas (ver Capsulas de Consentimento)
├── pyproject.toml             # se for modulo Python instalavel
└── CHANGELOG.md
```

A estrutura nao e dogma; e ponto de partida. Modulos podem adaptar
conforme natureza da tecnologia (Rust crate, biblioteca header-only,
etc.).

## Composicao entre modulos fagocitados

Modulos NAO se importam diretamente em codigo. Comunicam via arquivos
do protocolo HBN. Cenario ilustrativo apos F4 das primeiras
tecnologias:

```text
Operador roda: hbn ciclo executar onda-12

  → CLI recebe comando
  → ambiente reprodutivel garantido
  → trace aberto: span "ciclo:onda-12"
    → parsing le codigo da onda
    → producao de AST
    → analise gera licao candidata
    → capsula criada com licao + evidencias
  → trace fechado; gravado em local-ai/traces/
  → CLI mostra resumo + path da capsula
```

Cada modulo cumpre uma funcao sem saber dos outros. Composicao emerge
do protocolo, nao de acoplamento direto.

## Motivacao — por que fagocitose precisa ser progressiva

A Camada 0 (Radar) atua como **filtro epistemico**: garante que toda
tecnologia fagocitada foi escolhida por convergencia com os principios,
nao por hype, urgencia ou pressao externa.

Sem fases progressivas, dois riscos atingem o useHBN:

1. **Fagocitose prematura** — tecnologia entra no pipeline operacional
   antes de ter sido avaliada criticamente; o custo de remocao depois
   e alto. Fere o principio constitucional 6 (reversibilidade) e o
   principio 9 (frameworks descartaveis vs principios permanentes).
2. **Captura por modismo** — sem filtro explicito, o protocolo
   persegue novidades.

Fagocitose progressiva mitiga ambos: cada fase exige evidencia
acumulada, e a regressao e barata em F1-F2 (pouco investido) e cara
mas possivel em F4-F5.

## Politica de rollback / despromocao

Modulo em F2-F4 pode regredir para fase anterior se:

- Mudanca de contexto invalida premissa (ex.: mantenedor abandona)
- Concorrente surge com encaixe melhor
- Risco operacional descoberto (CVE, design flaw)
- Convergencia com principios se mostra mais fraca do que parecia

Despromocao exige:

- Justificativa explicita em ADR (`decisions/ADR-NNN-despromocao.md`)
- Atualizacao da ficha do radar com nova transicao de estado
- Reversibilidade de qualquer integracao feita (rollback testado)

Despromocao radical (F4 → F0 ou `archived`) requer aprovacao explicita
do operador.

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🌱 HBN EXPLORATION SEED | tecnologia em F0-F1 (modulo na Arvore de Exploracao) |
| 🔧 HBN DEV BRANCH | modulo em F2-F4 (Arvore de Desenvolvimento) |
| 🪨 HBN STABLE TRUNK | modulo em F5 (Arvore Estavel; uso publico) |
| 🟫 HBN TREE TRANSITION | momento de promocao entre arvores (F2→F3, F4→F5) |
| 🌳 HBN MODULE BOUNDARY | decisao que toca este modulo e outro simultaneamente |
| 🟦 HBN MINIMALIST GATE | analise de cadeia de dependencias do candidato |
| 🟪 HBN SUBSTRATO GATE | criterio de promocao a Arvore Estavel |
| 🟧 HBN AI-ABSTRACTION GATE | escolha de linguagem/ferramenta com IA como cliente |

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Radar | Recebe tecnologias em estado `candidate` para iniciar F1; devolve para `archived` em caso de despromocao |
| Capsulas de Consentimento | Cada transicao F3→F4 e F4→F5 emite capsula assinada; capsulas sao a unidade de promocao publica em F5 |
| Coordenacao inter-IA | Cada fase pode ser executada por IAs diferentes; bastao e registrado em `.hbn/relay/`; readbacks documentam outputs |
| Seguranca | Gates G1-G8 (Glasswing-style) sao verificados antes de F4 e F5; codigo de produto na resposta da IA bloqueia entrega |
| Auditoria Cruzada | Promocoes F3→F4 e F4→F5 passam por auditoria multi-IA antes do fechamento |
| Marcadores | Cada fase tem marker associado; transicoes geram eventos com markers especificos |

## Como adotar a Fagocitose em outro projeto

Para replicar este modulo em projeto externo:

1. Criar pasta `modules/` no repositorio do projeto
2. Adotar o template de modulo (`docs/`, `poc/`, `tests/`, `capsules/`)
3. Definir gates por fase em documento equivalente a este (cada
   projeto pode ajustar os criterios — F2→F3 pode ser mais ou menos
   exigente conforme dominio)
4. Vincular o modulo a uma ficha no Radar (modulo `RADAR`)
5. Usar marcadores padronizados (🌱 🔧 🪨 🟫 🌳)
6. Emitir capsulas em cada transicao significativa (modulo `CAPSULAS-DE-CONSENTIMENTO`)
7. Manter cadencia de revisao trimestral por fase para detectar
   modulos parados (mesmo principio do Radar — energia se concentra
   onde gera valor)

A fagocitose progressiva nao depende de stack especifica; depende de
disciplina de fases + gates + capsulas. Pode ser adotada em qualquer
linguagem ou ecossistema.

## Estado dos modulos em fagocitose (snapshot vivo)

Mantido na ficha do Radar de cada tecnologia em
`usehbn/radar/_per-technology/<slug>.md` campo `estado` + nova
transicao append-only no historico. Cross-link com `usehbn-phago/`
quando o modulo existe operacionalmente.
