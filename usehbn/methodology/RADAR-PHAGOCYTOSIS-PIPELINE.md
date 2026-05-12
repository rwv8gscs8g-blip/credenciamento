---
titulo: Pipeline Radar → Fagocitose — formalização da Camada 0 no useHBN
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-protocolo: usehbn 0.4.0 (proposta)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 2) com base em proposta de Luís Maurício Junqueira Zanin (2026-05-02)
licenca-target: usehbn (AGPLv3)
supersedes: nenhum (extensão da tese 38, sem invalidar nada)
---

# Pipeline Radar → Fagocitose

## Resumo executivo

Este documento formaliza a **Camada 0 — Radar** como passo anterior
às 8 camadas operacionais da tese de fagocitose tecnológica do useHBN
(`auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`).

Camada 0 responde: **antes de fagocitar uma tecnologia, como sabemos
que ela merece ser fagocitada?**

A resposta: ela passa por um pipeline de observação, análise de
convergência com os 10 princípios constitucionais, e decisão
explícita. Tecnologias podem entrar e sair do radar sem custo. Só
depois de aprovadas como `candidate` é que iniciam o fluxo Camadas
1-8 (Contato → Evolução distribuída).

## Motivação

Sem Camada 0, há dois riscos que ferem a constituição useHBN:

1. **Fagocitose prematura** (fere princípio 6 — reversibilidade — e
   princípio 9 — frameworks descartáveis vs princípios permanentes).
   Uma tecnologia entra no pipeline operacional antes de ter sido
   avaliada criticamente; o custo de remoção depois é alto.
2. **Captura por modismo** (já listada como risco na tese 38 §6).
   Sem filtro explícito, o protocolo persegue novidades.

Camada 0 é o **filtro epistêmico**: garante que toda tecnologia
fagocitada foi escolhida por convergência com os princípios, não por
hype, urgência ou pressão externa.

## Estados da Camada 0

```
                      ┌──────────────┐
                      │  in-radar    │◄──────┐
                      └──────┬───────┘       │
                             │               │ (volta)
                             ▼               │
                    ┌────────────────┐       │
                    │ under-analysis │───────┤
                    └────────┬───────┘       │
                             │               │
                             ▼               │
                  ┌──────────────────────┐   │
                  │ convergence-mapped   │───┤
                  └──────────┬───────────┘   │
                             │               │
                  ┌──────────┴───────────┐   │
                  ▼                      ▼   │
            ┌──────────┐          ┌──────────┴─┐
            │candidate │          │  archived  │
            └─────┬────┘          └────────────┘
                  │
                  ▼ (entra Camada 1 — Contato)
        ┌──────────────────┐
        │  phagocytosed    │ (gerido pelas Camadas 1-8)
        └──────────────────┘
```

| Estado | Definição | Critério de transição (forward) | Critério de transição (back) |
|---|---|---|---|
| `in-radar` | Tecnologia observada e registrada; sem análise formal ainda | Decisão de iniciar análise | Decisão de arquivar (não merece análise) |
| `under-analysis` | Análise comparativa contra os 10 princípios em curso | Análise dos 10 princípios completa | Análise inviável (sem dados) → `in-radar` ou `archived` |
| `convergence-mapped` | Matriz convergência/divergência completa, decisão pendente | Decisão humana de promover a candidato | Convergência fraca → `archived` |
| `candidate` | Aprovada para fagocitose; aguardando ciclo operacional | Início do ciclo Camada 1 (Contato) | Mudança de prioridade → volta para `convergence-mapped` |
| `phagocytosed` | Entrou no pipeline Camadas 1-8; gerido pelo fluxo operacional da tese 38 | (não há forward — é estado terminal do radar) | Deprecação formal → `archived` (com motivo) |
| `archived` | Saiu do radar com justificativa registrada | (estado de descanso) | Reentrada por mudança de contexto → `in-radar` |

## Schema de ficha por tecnologia

Cada tecnologia no radar tem um arquivo dedicado em
`usehbn/radar/_per-technology/<slug>.md` com este frontmatter:

```yaml
---
titulo: <Nome canônico>
slug: <slug-kebab-case>
categoria: agentes | observabilidade | legado | conhecimento-estruturado | computacao-distribuida | outros
estado: in-radar | under-analysis | convergence-mapped | candidate | phagocytosed | archived
data-entrada: AAAA-MM-DD
ultima-revisao: AAAA-MM-DD
proxima-revisao: AAAA-MM-DD (sugerida)
fonte-radar: <quem/o-que colocou no radar>
licenca-target: usehbn (AGPLv3) — se promovida para repo público
hbn-track: knowledge
audiencia: ambos
---
```

E o corpo segue este template:

```markdown
# <Nome canônico>

## Por que está no radar
<1-3 parágrafos: o que motivou a observação inicial>

## Resumo da tecnologia
<O que é, em 5-10 linhas neutras>

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa (1-2 linhas) |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim/parcial/não | ... |
| 2 | Documentar antes de executar | ... | ... |
| 3 | Testar antes de refatorar | ... | ... |
| 4 | Explicar antes de automatizar | ... | ... |
| 5 | Humano no controle por padrão | ... | ... |
| 6 | Toda evolução deve ser reversível | ... | ... |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | ... | ... |
| 8 | O protocolo importa mais que a ferramenta | ... | ... |
| 9 | Frameworks são descartáveis; princípios são permanentes | ... | ... |
| 10 | Segurança e não-regressão > velocidade | ... | ... |

## Divergências e riscos
<Onde a tecnologia conflita com algum princípio, ou apresenta riscos
operacionais para o useHBN>

## O que precisa para avançar de estado
<Critérios objetivos: dados, validação empírica, decisão humana>

## Histórico de transições
| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| AAAA-MM-DD | n/a | in-radar | <motivo entrada> | <quem> |

## Referências
<Links, artigos, casos de uso, repositórios>
```

## Schema do REGISTRY consolidado

`usehbn/radar/REGISTRY.md` mantém tabela única com todas as fichas:

```markdown
| Slug | Nome | Categoria | Estado | Convergência média | Última revisão | Ficha |
|---|---|---|---|---|---|---|
| langgraph | LangGraph | agentes | under-analysis | 7/10 sim | 2026-05-02 | [ficha](./_per-technology/langgraph.md) |
| ...
```

**Convergência média** = contagem de "sim" dos 10 princípios da ficha.
Cálculo simples, mas dá leitura rápida.

## Schema da CONVERGENCE-MATRIX

`usehbn/radar/CONVERGENCE-MATRIX.md` é matriz transposta — princípios
nas linhas, tecnologias nas colunas — para visualização cruzada:

```markdown
| Princípio | LangGraph | CrewAI | AutoGen | ... |
|---|---|---|---|---|
| 1 - Preservar antes de transformar | sim | parcial | não | ... |
| 2 - Documentar antes de executar | sim | sim | parcial | ... |
| ...
```

Útil para identificar **princípios sub-atendidos pelo radar atual**
(linha cheia de "não" = nenhuma tecnologia atende aquele princípio bem).

## Critérios de transição entre estados

### `in-radar` → `under-analysis`
- Há dados públicos suficientes (docs, repo, casos de uso)
- Há tempo/recurso para conduzir a análise
- Decisão da Frente 2 (arquiteto)

### `under-analysis` → `convergence-mapped`
- Matriz dos 10 princípios completa (sem "n/a" injustificado)
- Divergências e riscos documentados
- Pelo menos 1 referência empírica externa (não só docs do projeto)

### `convergence-mapped` → `candidate`
- Convergência ≥ 7/10 princípios (heurística inicial; revisar após 10+ análises)
- Sem divergência crítica (princípios 5, 6, 10 — humano, reversibilidade, segurança)
- Decisão explícita do operador (Maurício)

### `candidate` → `phagocytosed`
- Início formal do ciclo Camada 1 (Contato) com inventário inicial
- Marker `🔵 HBN HANDOFF READY` da Frente 2 para a frente operacional

### Qualquer estado → `archived`
- Convergência fraca, divergência crítica, ou decisão estratégica
- Justificativa obrigatória no histórico de transições
- Pode reentrar em `in-radar` se contexto mudar

## Cadência de revisão

| Estado | Revisão sugerida |
|---|---|
| `in-radar` | trimestral |
| `under-analysis` | mensal (análise é trabalho ativo) |
| `convergence-mapped` | trimestral (decisão pendente) |
| `candidate` | mensal (prioridade alta para iniciar ciclo) |
| `phagocytosed` | gerido pelas Camadas 1-8 (fora do radar) |
| `archived` | anual (verificar se contexto mudou) |

A automação semanal (Wave 11+ — `hbn weekly-review`) gera lista de
fichas com revisão atrasada.

## Permeabilidade — como novas tecnologias entram no radar

O radar não é estático. Precisa absorver tecnologias novas continuamente sem virar "festival de novidades" — equilíbrio entre **permeabilidade** (entra fácil) e **parsimônia** (gasta energia onde importa).

### Vias de entrada

| Via | Origem | Quem propõe | Filtro inicial |
|---|---|---|---|
| **Observação direta** | Maurício, Opus, Codex topam tecnologia em uso real, paper, comparativo | qualquer um | adicionar como `in-radar` se 1 sentença justifica relevância para um dos 10 princípios |
| **Spin-off de análise** | Análise de tecnologia X cita tecnologia Y como dependência ou alternativa | quem fez análise | Y vira ficha `in-radar` apontando para a ficha de X |
| **Sugestão externa** | Após `usehbn-phago` ser público, contribuidores externos propõem via issue | qualquer um | mantenedor (Maurício/Opus) decide aceitar como `in-radar` ou rejeitar com motivo |
| **Reentrada** | Tecnologia previamente `archived` recupera relevância | qualquer um | volta a `in-radar` com nota explicando mudança de contexto |
| **Substituição** | Tecnologia atual em estado X é desafiada por alternativa | quem encontra | nova entra como `in-radar` referenciando a anterior; revisão semanal compara |

### Regras de baixo atrito (entrada)

Para entrar no radar como `in-radar`, basta:

1. Slug único kebab-case
2. Frontmatter mínimo (categoria, estado, data-entrada, fonte-radar)
3. Frase de 1-3 linhas em "Por que está no radar"

**Análise individual completa só é exigida na transição `in-radar` → `under-analysis`** (decisão consciente de gastar energia analítica). Essa análise é responsabilidade do Opus sob demanda (não Codex — vide DT-FRENTE2-02).

### Anti-ruído

- Nenhuma tecnologia entra duas vezes (deduplicação manual ou via slug check)
- Tecnologia que ficou `in-radar` mais de 180 dias sem evidência adicional vira candidata a arquivamento na revisão semanal
- Observação genérica ("AI Framework do mês") **sem motivo concreto** não vira ficha — fica em rascunho mental até alguém articular o porquê

### Reentrada de archived

Tecnologia arquivada pode reentrar em `in-radar` se:
- Mudança de contexto justifica (ex.: AutoGen v0.5 estabilizar)
- Demanda de projeto específico cria caso concreto
- Maurício decidir reabrir

Reentrada exige:
- Justificativa explícita em "Histórico de transições"
- Atualização de "Por que está no radar" refletindo novo contexto
- Não apaga histórico antigo (append-only)

### Filtro de impacto (saída — aplicado pela revisão semanal)

| Estado | Pergunta | Ação se "não" |
|---|---|---|
| `in-radar` | Há impacto plausível em ≤6 meses? | sugerir arquivamento |
| `under-analysis` | Análise progrediu nos últimos 90 dias? | sugerir regressão para `in-radar` ou arquivamento |
| `convergence-mapped` | Há ação concreta planejada para virar candidato? | sugerir despriorização |
| `candidate` | Existe plano operacional para fagocitose? | sugerir adiamento ou regressão |

Sem filtro de impacto, o radar incha. Com filtro, energia se concentra onde gera valor.

## Integração com Camadas 1-8 da tese 38

Camada 0 é **antes** de Camada 1. Não substitui nada. Quando uma
tecnologia transita para `phagocytosed`, ela entra na Camada 1
(Contato) com:

- Ficha completa do radar como input inicial
- Matriz de convergência como racional documentado
- Histórico de transições como evidência de processo

A Camada 1 produz inventário inicial; Camadas 2-8 seguem o fluxo
canônico da tese 38.

## Marcadores HBN V2 aplicáveis

- `⚪ HBN AUDIT-ONLY` — quando uma tecnologia está em `under-analysis`
- `🟡 HBN NEEDS HUMAN DECISION` — em transições `convergence-mapped` → `candidate`
- `🟤 HBN LICENSE SPLIT REQUIRED` — fichas declaram `licenca-target`
- `🔵 HBN HANDOFF READY` — quando ficha vira `candidate` e está pronta para Camada 1

## Hook para o futuro — comando `hbn radar`

A CLI `hbn` (Wave 11+) terá:

| Comando | Função |
|---|---|
| `hbn radar list --state <estado>` | Lista tecnologias por estado |
| `hbn radar add <slug>` | Cria ficha nova com template |
| `hbn radar transition <slug> --to <estado>` | Move tecnologia entre estados, exigindo justificativa |
| `hbn radar overdue` | Lista fichas com revisão atrasada |
| `hbn radar matrix --regenerate` | Regenera CONVERGENCE-MATRIX a partir das fichas |

Até lá, tudo manual — mas com schema forte, dá para automatizar depois
sem reescrita.

## Versão

- v1.0 — 2026-05-02 — formalização inicial da Camada 0 a partir de
  proposta do operador na sessão de bootstrap da Frente 2.
