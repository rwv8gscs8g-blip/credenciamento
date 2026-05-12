---
titulo: Radar
tipo: modulo-do-usehbn
papel: observação e categorização de tecnologias
audiencia: humano + ia
licenca: AGPLv3
---

# Radar

## O que é

Radar é o módulo de **observação de tecnologias** do useHBN. Toda tecnologia que entra no campo de visão do projeto recebe ficha. Toda ficha tem estado. Estado reflete a relação atual entre o useHBN e a tecnologia.

O Radar não é arquivo — é processo. Mantém o projeto consciente do que está observando, do que decidiu deixar entrar, do que descartou, e do que está em uso real.

## Os seis estados

### in-radar

Tecnologia observada e registrada com motivo. Ainda sem análise formal.

### under-analysis

Análise individual em curso. Convergência com os 13 princípios sendo medida (10 constitucionais + 3 operacionais).

### convergence-mapped

Análise concluída. Convergência registrada. Decisão de promoção pendente.

### candidate

Aprovada para incorporação ao protocolo. Aguardando ciclo de implementação.

### phagocytosed

Incorporada. Em uso real dentro de algum módulo do useHBN.

### archived

Saiu do foco. Reentrada permitida quando contexto mudar.

## Movimento entre estados

```text
in-radar  →  under-analysis  →  convergence-mapped  →  candidate  →  phagocytosed
   ↑                                                                       ↓
archived  ←─────────────────────────────────────────────────  (deprecação formal)
```

Forward é gradual. Cada transição requer evidência adicional. Reverse é permitido em qualquer ponto: tecnologias podem regredir se contexto mudar.

## Cinco vias de entrada

| Via | Quem inicia | Filtro inicial |
|---|---|---|
| Observação direta | operador (humano ou IA) topa com tecnologia | uma frase justificando relevância para um dos 13 princípios |
| Spin-off de análise | análise de X cita Y como dependência ou alternativa | Y vira ficha apontando para a ficha de X |
| Sugestão externa | issue no repositório público | mantenedor decide aceitar ou rejeitar com motivo |
| Reentrada | tecnologia archived recupera relevância | volta a `in-radar` com nota explicando mudança de contexto |
| Substituição | alternativa surge para tecnologia adotada | nova entra como `in-radar` referenciando a anterior |

## Filtros progressivos por transição

| Transição | Pergunta-chave |
|---|---|
| nada → in-radar | Há motivo concreto registrável em três linhas? |
| in-radar → under-analysis | Vale gastar energia analítica formal? |
| under-analysis → convergence-mapped | A análise dos 13 princípios está completa? |
| convergence-mapped → candidate | Convergência ≥ 7/13 e sem divergência crítica? |
| candidate → phagocytosed | Há plano operacional de incorporação? |

## Filtro de impacto na revisão semanal

| Estado | Pergunta | Ação se "não" |
|---|---|---|
| in-radar | Há impacto plausível em ≤6 meses? | sugerir arquivamento |
| under-analysis | Análise progrediu nos últimos 90 dias? | sugerir regressão ou arquivamento |
| convergence-mapped | Há ação concreta planejada? | sugerir despriorização |
| candidate | Existe plano operacional? | sugerir adiamento |

## Permeabilidade

Entrada é leve. Slug único, frontmatter mínimo, frase de motivação. Análise individual completa só é exigida na transição para `under-analysis`.

Saída é por filtro de impacto. Tecnologias paradas migram para `archived`. Reentrada permanece sempre permitida.

A permeabilidade alta na entrada combinada com filtro rigoroso na saída mantém o radar **vivo sem virar zumbi documental**.

## Estrutura de uma ficha

Cada tecnologia tem arquivo em `radar/_per-technology/<slug>.md`.

Frontmatter:

```yaml
---
titulo: Nome canônico
slug: slug-kebab-case
categoria: agentes | observabilidade | legado | conhecimento-estruturado | computacao-distribuida | outros | stack-fundacional
estado: in-radar | under-analysis | convergence-mapped | candidate | phagocytosed | archived
data-entrada: AAAA-MM-DD
licenca-tecnologia: licença da tecnologia (MIT, GPL, Apache-2.0, etc.)
licenca-target: usehbn (AGPLv3)
modulo-do-usehbn: módulo onde aplica (se aplicável)
arvore-hbn: stable-trunk | dev-branch | exploration-seed
---
```

Conteúdo:

1. Por que está no radar
2. Resumo da tecnologia
3. Convergência com os 13 princípios (sim / parcial / não, com justificativa)
4. Divergências e riscos
5. O que precisa para avançar de estado
6. Histórico de transições (append-only)
7. Referências

## Cadência de revisão

| Estado | Revisão |
|---|---|
| in-radar | trimestral |
| under-analysis | mensal (análise é trabalho ativo) |
| convergence-mapped | trimestral (decisão pendente) |
| candidate | mensal (prioridade alta) |
| phagocytosed | gerido pelos módulos onde foi incorporada |
| archived | anual |

A revisão semanal é toda quarta-feira 11:45 BRT. Identifica fichas com revisão atrasada e propõe transições.

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🌱 EXPLORATION SEED | tecnologia em exploração inicial |
| 🟫 TREE TRANSITION | em transição de estado |
| 🪨 STABLE TRUNK | fagocitada e em produção |

## Conexão com outros módulos

| Módulo | Relação |
|---|---|
| Fagocitose | Recebe tecnologias em estado `candidate`; gerencia o processo de incorporação |
| Cápsulas de Consentimento | Cada promoção a `phagocytosed` gera cápsula registrando consentimento |
| Auditoria Cruzada | Promoções entre estados passam por validação cruzada antes do fechamento |
| Markers | Estados do radar correspondem a marcadores específicos |

## Como adotar o Radar em outro projeto

O Radar é replicável. Para adotar em projeto externo:

1. Crie pasta `radar/` no repositório
2. Crie subpasta `radar/_per-technology/` para fichas individuais
3. Mantenha `REGISTRY.md` consolidado com todas as fichas
4. Defina ciclo de revisão (semanal sugerido)
5. Use os 6 estados padronizados (não invente estados novos)
6. Use os marcadores padronizados (interoperabilidade entre projetos useHBN)

## Estado do Radar do useHBN (snapshot vivo)

Mantido em `usehbn/radar/REGISTRY.md`. Atualizado a cada transição.
