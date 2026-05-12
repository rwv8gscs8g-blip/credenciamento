---
titulo: Indice dos modulos do useHBN
tipo: indice
audiencia: humano + ia
licenca: AGPLv3
---

# Modulos do useHBN

O useHBN e um sistema multi-braco. Cada modulo cobre um eixo
especifico do protocolo. Os modulos crescem em ritmo proprio, nao se
acoplam fortemente, comunicam apenas via convencoes textuais
(marcadores, delta card, capsulas).

## Os sete modulos

| # | Modulo | Papel |
|---|---|---|
| 1 | [Radar](RADAR.md) | observacao e categorizacao de tecnologias |
| 2 | [Fagocitose](FAGOCITOSE.md) | incorporacao progressiva e auditavel de tecnologias ao uso real |
| 3 | [Capsulas de Consentimento](CAPSULAS-DE-CONSENTIMENTO.md) | unidade atomica de transferencia de conhecimento com consentimento assinado |
| 4 | [Coordenacao inter-IA](COORDENACAO-INTER-IA.md) | coexistencia segura de multiplas IAs operando o mesmo repositorio |
| 5 | [Seguranca](SEGURANCA.md) | guardrails preventivos contra IAs encontrando vulnerabilidades antes que humanos remediam |
| 6 | [Marcadores](MARCADORES.md) | lingua franca semantica entre IAs e operador |
| 7 | [Auditoria Cruzada](AUDITORIA-CRUZADA.md) | validacao multi-IA antes do fechamento de decisoes criticas |

## Mapa de dependencias entre modulos

```text
                        ┌──────────────┐
                        │    Radar     │
                        └──────┬───────┘
                               │ candidates
                               ▼
                        ┌──────────────┐
                        │  Fagocitose  │
                        └──────┬───────┘
                               │ promocoes
                               ▼
                ┌────────────────────────────┐
                │ Capsulas de Consentimento  │
                └──────┬───────────────┬─────┘
                       │               │
                handoffs│               │assinatura
                       │               │
                ┌──────▼─────┐  ┌──────▼─────┐
                │Coordenacao │  │ Seguranca  │
                │  inter-IA  │  │            │
                └──────┬─────┘  └──────┬─────┘
                       │               │
                       └──────┬────────┘
                              │
                              ▼
                       ┌────────────┐
                       │ Auditoria  │
                       │  Cruzada   │
                       └──────┬─────┘
                              │ usa
                              ▼
                       ┌────────────┐
                       │ Marcadores │
                       └────────────┘
                       (transversal a todos)
```

Marcadores e Capsulas sao infraestrutura transversal — todos os outros
modulos os utilizam.

## Tom dos documentos

Os modulos seguem padrao DECLARATIVO derivado de [RADAR.md](RADAR.md)
como template canonico. Cada documento tem 8 blocos:

1. Frontmatter YAML (titulo, tipo, papel, audiencia, licenca)
2. `## O que e` — definicao declarativa
3. `## <Componentes / Estados / Vetores>` — nomenclatura adaptada
4. `## Movimento / Fluxo` — diagrama ASCII de transicoes
5. `## Filtros / Gates` — tabela de regras
6. `## Marcadores` — markers que tocam o modulo
7. `## Conexao com outros modulos` — tabela de dependencias
8. `## Como adotar em outro projeto` — passos replicaveis

Tom: princípio é spec, nao narrativa de processo. Citacoes operacionais
do operador como blocos `>` integrais, sempre que cobertas pelos
insumos.

## Arquitetura de fundo

Documento de referencia conceitual:
[USEHBN-MODULES-ARCHITECTURE.md](../methodology/USEHBN-MODULES-ARCHITECTURE.md)
— formaliza os 6+1 modulos como conceitos-ancora e mapeia o protocolo
multi-braco que substitui a leitura anterior centrada em fagocitose.

Modelo arquitetural global:
[THREE-TREES-ARCHITECTURE.md](../methodology/THREE-TREES-ARCHITECTURE.md)
— modelo das 3 Arvores (Estavel / Desenvolvimento / Exploracao) sob
o qual os modulos se desenvolvem.

Principios constitucionais (10) e operacionais (3):
- [MINIMALISM-PRINCIPLE.md](../methodology/MINIMALISM-PRINCIPLE.md)
- [SUBSTRATO-SOLIDO-PRINCIPLE.md](../methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md)
- [AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md](../methodology/AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md)

## Estado dos modulos

| Modulo | Estado | Notas |
|---|---|---|
| Radar | operacional | 55 fichas em `usehbn/radar/_per-technology/` |
| Fagocitose | em desenvolvimento | F1 ativa em multiplas tecnologias (Tree-sitter, Consent Capsules) |
| Capsulas de Consentimento | em migracao | aprovada 2026-05-06; R-A em curso |
| Coordenacao inter-IA | parcialmente operacional | `.hbn/relay/`, markers V2, INTER-CHAT-COORDINATION em uso |
| Seguranca | operacional | G1-G8 documentados em `.hbn/knowledge/0003`; gates rodam em pre-commit |
| Marcadores | operacional | 21 markers canonicos (V2 base + addendum 2026-05-09) |
| Auditoria Cruzada | declarado | primeira aplicacao prevista no fechamento R-A |
