---
titulo: Marcadores
tipo: modulo-do-usehbn
papel: lingua franca semantica entre IAs e operador
audiencia: humano + ia
licenca: AGPLv3
---

# Marcadores

## O que e

Marcadores e o modulo do useHBN que **define o vocabulario semantico
compartilhado entre IAs e operador**. Cada marcador e um simbolo +
label canonico que carrega significado operacional preciso (estado de
bastao, gate de seguranca, transicao de arvore, fadiga de contexto).

Marcadores sao a lingua franca: sao curtos o suficiente para abrir
qualquer mensagem, longos o suficiente para nao serem ambiguos. Toda
IA participante do useHBN os usa em delta cards, readbacks,
mensageria e revisoes semanais.

O conjunto canonico cresce **append-only** via revisao semanal. Nunca
e reescrito; markers obsoletos recebem `supersedes:` em addendum,
nunca exclusao silenciosa.

## Os dois conjuntos

| Conjunto | Quantos | Origem | Documento canonico |
|---|---|---|---|
| **V2 base** | 10 (3 V1 + 7 V2) | cadeia Antigravity → Codex → Opus 2026-05-02 | [.hbn/knowledge/0005-protocolo-markers-v2.md](../../.hbn/knowledge/0005-protocolo-markers-v2.md) (corpo) |
| **V2 estendido (addendum 2026-05-09)** | 11 (3 principios + 5 arvores + 3 auditoria) | sessao Cowork 2026-05-02 → 2026-05-06 | mesmo arquivo, secao `## 2026-05-09 weekly addendum` |

Total: **21 marcadores canonicos**.

## Tabela canonica completa (V2 base + addendum)

| Marcador | Conjunto | Modulo de origem | Quando aplica |
|---|---|---|---|
| `✅ HBN ACTIVE` | V1/V2 base | Marcadores | protocolo engajado; abre cada ciclo |
| `🟡 HBN NEEDS HUMAN DECISION` | V1/V2 base | Marcadores | aprovacao humana requerida antes de prosseguir |
| `❌ HBN SECURITY BLOCKED SUGGESTION` | V1/V2 base | Seguranca | gate de seguranca recusou proposta |
| `🟠 HBN SOURCE DRIFT DETECTED` | V2 base | Coordenacao + Seguranca | duas fontes canonicas divergem; bloqueia fechamento |
| `🔴 HBN RELEASE BLOCKER` | V2 base | Seguranca | falha impede tag/release |
| `🔵 HBN HANDOFF READY` | V2 base | Coordenacao inter-IA | IA atual fechou escopo limpamente |
| `⚪ HBN AUDIT-ONLY` | V2 base | Coordenacao inter-IA | IA nao tem bastao executor; so escreve diagnostico |
| `🟢 HBN CHECKPOINT CLEAN` | V2 base | Coordenacao inter-IA | onda fechou com artefatos, gate e ERP consistentes |
| `🟤 HBN LICENSE SPLIT REQUIRED` | V2 base | Capsulas | ciclo cruza repos/licencas distintas |
| `🟣 HBN PEER REVIEW REQUESTED` | V2 base | Auditoria Cruzada | revisao humana de UI ou tecnica IA-IA solicitada |
| `🟦 HBN MINIMALIST GATE` | addendum | Methodology (principios operacionais) | decisao de adicao passou pelo Principio Minimalismo de Cadeia |
| `🟪 HBN SUBSTRATO GATE` | addendum | Methodology (principios operacionais) | artefato pertence a Arvore Estavel ou cumpre criterios de promocao |
| `🟧 HBN AI-ABSTRACTION GATE` | addendum | Methodology (principios operacionais) | decisao tomada considerando IA como cliente prioritario |
| `🌱 HBN EXPLORATION SEED` | addendum | Fagocitose | tecnologia/ideia em Arvore de Exploracao |
| `🔧 HBN DEV BRANCH` | addendum | Fagocitose | artefato em Arvore de Desenvolvimento |
| `🪨 HBN STABLE TRUNK` | addendum | Fagocitose | artefato em Arvore Estavel |
| `🟫 HBN TREE TRANSITION` | addendum | Fagocitose | artefato cruzando fronteira entre arvores |
| `🌳 HBN MODULE BOUNDARY` | addendum | Marcadores | fronteira entre modulos do useHBN |
| `🔍 HBN CROSS-AUDIT IN PROGRESS` | addendum | Auditoria Cruzada | decisao em auditoria cruzada; resultado pendente |
| `🤝 HBN CROSS-AUDIT APPROVED` | addendum | Auditoria Cruzada | auditoria cruzada chegou a consenso |
| `⚖️ HBN CROSS-AUDIT ITERATION` | addendum | Auditoria Cruzada | auditoria detectou divergencia; mais uma rodada |

### Familia visual da auditoria cruzada

A familia 🔍/🤝/⚖️ usa simbolos univocamente relacionados a auditoria:
lupa investiga, aperto de mao consente, balanca pesa divergencia. A
escolha foi feita para evitar reuso visual de `✅` e `🟡` (V1) que
geraria confusao em leitura rapida — o cerebro decodifica icone antes
do label.

Versoes anteriores destes 3 marcadores (`🔄` / `✅` / `🟡`) ficam
documentadas em [.hbn/knowledge/0005-protocolo-markers-v2.md](../../.hbn/knowledge/0005-protocolo-markers-v2.md)
sob a secao `## 2026-05-09 weekly addendum (correcao Grupo C)`. A
canonica vigente e a deste documento.

## Movimento — ciclo de vida de um marcador

```text
proposto → operacional → revisao semanal → ┬→ supersedes (substituido)
                                            └→ aposentado (raro; documentado)
```

Markers sao **append-only**. Nenhum e excluido silenciosamente.
Substituicao requer addendum com `supersedes: <marker antigo>` e
justificativa.

## Filtros / Gates

| Regra | Pergunta | Acao se violada |
|---|---|---|
| Append-only | Estou editando secao existente do protocolo de markers? | nao; criar addendum no fim |
| Supersedes formal | Substituicao tem campo `supersedes` apontando para marker antigo? | sim → ok; nao → rejeitar |
| Label completo | Estou usando emoji solto sem label? | nao; sempre `<emoji> HBN <LABEL>` |
| Promocao | Marker novo tem ≥ 2 reproducoes em projetos distintos? | sim → promovel a candidato; nao → fica em rascunho |
| Reusabilidade | Marker novo se sobrepoe semanticamente a existente? | sim → ajustar antes de promover |

## Cadencia de revisao semanal

Marcadores recebem revisao append-only toda quarta-feira 11:45 BRT.
Itens da revisao:

1. Novos candidatos a marker (propostos por qualquer IA participante)
2. Decisoes promovidas (de candidato a operacional)
3. Itens rejeitados (com motivo)
4. Links de PRs/issues relevantes

Rascunho semanal e draft ate aprovacao do operador. Promocao para o
repositorio publico exige consentimento explicito por capsula.

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Fagocitose | Markers de arvore (🌱 🔧 🪨 🟫) sinalizam fase do modulo fagocitado |
| Capsulas de Consentimento | Markers 🟫 🟡 ✅ 🟤 acompanham ciclo de vida da capsula |
| Coordenacao inter-IA | Markers 🔵 🟢 🟠 ⚪ acompanham fluxo do bastao |
| Seguranca | Markers 🟠 ❌ 🔴 sinalizam violacoes de gates G1-G8 |
| Auditoria Cruzada | Markers 🔍 🤝 ⚖️ 🟣 sinalizam etapas e veredito |
| Radar | Markers de arvore acompanham estado da ficha (`in-radar` → `phagocytosed`) |

Marcadores e o modulo mais transversal — toca todos os outros 5 (mais
o Radar).

## Como adotar Marcadores em outro projeto

Para replicar este modulo em projeto externo:

1. Adotar o conjunto V2 base (10 markers) como vocabulario inicial
2. Adicionar markers de dominio conforme necessidade, sempre seguindo
   convencao `<emoji> HBN <LABEL>` (ou prefixo proprio do projeto)
3. Manter documento canonico (`0005-protocolo-markers-v2.md` ou
   equivalente) com cabecalho + corpo + addendums datados
4. Aplicar regra append-only — nunca reescrever secoes; sempre
   adicionar addendum
5. Adotar `supersedes:` formal quando marker velho e substituido
6. Estabelecer cadencia de revisao (semanal sugerido)
7. Treinar IAs participantes para usar label completo em delta cards
   e readbacks, nao emoji solto
8. Cross-link com modulo `AUDITORIA-CRUZADA` para markers da familia
   cruzada (🔄 ✅ 🟡)
9. Documentar cada novo marker proposto com: quando aplica, modulo de
   origem, exemplo de uso

## Delta card e marcadores

Marcadores entram no campo apropriado do delta card de 7 linhas
(definido em [Coordenacao inter-IA](COORDENACAO-INTER-IA.md)):

```text
HBN mode: <audit-only | executor>     ← usa ⚪ HBN AUDIT-ONLY?
Baton: <owner>                        ← 🔵 HBN HANDOFF READY?
Scope: <onda/microdelta>
Touched paths: <paths or none>
Gate run: <none/manual/command>       ← 🟠 HBN SOURCE DRIFT DETECTED?
Evidence: <csv/log/doc>
Decision needed: <yes/no>             ← 🟡 HBN NEEDS HUMAN DECISION?
```

Marcadores nao substituem o delta card; o complementam. O card e
estrutural; os markers sao semanticos.

## Estado vivo

Documento canonico: [.hbn/knowledge/0005-protocolo-markers-v2.md](../../.hbn/knowledge/0005-protocolo-markers-v2.md).
Atualizado append-only via revisoes semanais. Total atual: 21
marcadores.
