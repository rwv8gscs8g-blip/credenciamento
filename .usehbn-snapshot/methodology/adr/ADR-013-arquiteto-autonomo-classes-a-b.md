---
adr-id: ADR-013
titulo: Arquiteto autônomo 2.0 — duas classes de mudança, rampa de confiança e regra do commit único
status: ACCEPTED
data-deposito: 2026-06-10
autor: claude-fable-5 (arquiteto useHBN, corrente C4)
cross-ia-required: Opus + Codex (muda o rito operacional do arquiteto)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P0
temperatura: quente
aplica-a: ciclo do arquiteto autônomo (canônico usehbn; projetos via inbox)
relacionado: [ADR-010 (motor autoevolve — proposto promover a ACCEPTED), ADR-011 (REGISTRY), agents/architect-autonomous.md, .hbn/queue/, decisões Q1/Q2/Q3 de Maurício 2026-06-10]
evidencia-motivadora: |
  PROMPT_ARQUITETO_USEHBN_AUTONOMO.md v1.6: 829 linhas misturando 4 coisas
  (identidade, backlog §4, knowledges L27/L28, Cadência D §12), vive FORA de
  git (/Users/macbookpro/Projetos/, sem versionamento), e opera na casa onde
  não pode commitar (Credenciamento, firewall 0022). Em contraste, o motor
  autoevolve (ADR-010) entregou 16 microdeltas commitados em um ciclo e parou
  limpo — é o único executor que já provou a mecânica completa.
---

# ADR-013 — Arquiteto autônomo 2.0: classes A/B, rampa, commit único

## O problema, em linguagem humana

O arquiteto v1.6 é um prompt-monólito: para mudar o backlog edita-se o mesmo
arquivo que define a identidade; para aprender uma lição nova infla-se o
prompt em mais 40 linhas. E o rito é único: TODA mudança, até renumerar um
índice, paga o ciclo completo readback→hearback individual→exec. Resultado
medido: itens de faxina pendentes há semanas (A4, F4) porque custam o mesmo
rito de um ADR. Este ADR separa o que é barato do que é caro — e dá ao
barato um trilho commitado com freio humano, reusando o motor que já
funcionou (autoevolve).

## Decisão 1 — Decomposição do monólito (peças versionadas no canônico)

| Peça do v1.6 | Novo endereço (git, canônico) |
|---|---|
| Identidade + regras + pré-flight + sinais | `agents/architect-autonomous.md` (curto, estável) |
| Backlog §4 | `.hbn/queue/NNN-<tema>.json` — estado em arquivo, 1 item = 1 arquivo |
| L27 (comandos atômicos copiáveis) | `.hbn/knowledge/0001-comandos-atomicos-copiaveis.md` |
| L28 (entrega operacional minimalista) | `.hbn/knowledge/0002-entrega-operacional-minimalista.md` |
| Cadência D §12 (papéis, severidades, anti-viés) | `core/cadence-d.md` |

O prompt v1.6 fora de git vira LEGADO (frio) após a adoção; nenhuma regra
dele se perde — cada uma tem endereço novo na tabela acima.

## Decisão 2 — Duas classes de mudança

**Classe A — manutenção mecânica** (faxina, índice, arquivamento,
renumeração, consolidação de inbox, atualização de REGISTRY):

- Executor: o motor autoevolve (ADR-010) — append em JSONL
  (`.hbn/autoevolve/cycle-AAAA-MM-DD.jsonl`), orçamento de diff por item
  (default ≤50 linhas; acima disso o item é promovido a classe B).
- Commitada NO ciclo, sem hearback prévio; hearback em LOTE no fim
  (Maurício revisa o conjunto, com diff agregado).
- **Rampa (decisão Q2)**: na 1ª semana o modo é DRY-RUN — o ciclo declara o
  que faria (item, diff previsto, orçamento) e NÃO escreve. Promoção a
  execução real só por hearback explícito após a semana.
- **HUMAN_GATE por arquivo**: linha `human_gate: true` no front-matter de
  qualquer arquivo o exclui da classe A para sempre (trava unilateral de
  Maurício, sem ADR).

**Classe B — mudança normativa** (ADR, schema, guard, princípio, spec core,
qualquer coisa que mude contrato):

- Rito atual integral: readback → hearback INDIVIDUAL confirmado → execução.
- Nunca executa sem hearback. Sem exceções, sem rampa.

Fronteira na dúvida: é B. Critério prático: se reverter exige pensar, é B;
se reverter é `git revert` indolor, pode ser A.

## Decisão 3 — Regra de ouro do ciclo

Todo ciclo do arquiteto termina com EXATAMENTE UM de dois desfechos:

1. **1 commit atômico** (classe A executada, ou classe B pós-hearback); OU
2. **1 no-op declarado** — linha no JSONL + sinal no chat: "nada elegível na
   fila" (ou "dry-run: faria X").

Dois commits no mesmo ciclo = violação (excesso de produção é vício, regra
herdada do v1.6 §3). Zero declaração = violação (silêncio não é no-op).

## Decisão 4 — Onde o arquiteto opera (decisão Q1)

Pré-flight começa com `cd /Users/macbookpro/Projetos/usehbn` e
`bash guards/hbn-guards-runner.sh`. O arquiteto commita SÓ no canônico.
Projetos (Credenciamento etc.) recebem o trabalho como PROPOSTA: artefato
canônico + mensagem; a adoção é onda própria do projeto com hearback. O
firewall 0022 permanece intacto: nada de domínio/VBA, nunca, em nenhuma
classe.

## Decisão 5 — ADR-010 promovido a ACCEPTED (proposta embutida)

O motor autoevolve é o executor da classe A. Ele já provou: 16 microdeltas,
JSONL íntegro, parada limpa (evidência: `.hbn/autoevolve/cycle-2026-05-13.jsonl`,
commits 8c32ec3…9a60c10). Manter o motor PROPOSED enquanto este ADR o
referencia como executor seria construir sobre areia declarada. Pede-se no
mesmo hearback: ADR-010 → ACCEPTED.

## Consequências

Positivas: faxina deixa de custar rito de ADR (vazão para A4/F4 e
equivalentes); prompt do arquiteto vira artefato git com diff e changelog;
backlog auditável por arquivo; o humano mantém TRÊS freios na classe A
(rampa, lote, HUMAN_GATE) e o freio absoluto na B. Negativas: classificação
A/B exige julgamento (mitigado: na dúvida é B); o lote da classe A
concentra a revisão humana no fim do ciclo (mitigado: orçamento de diff).

## DONE-check

Prompt do arquiteto versionado no repo; backlog como estado externo em
`.hbn/queue/`; este ADR define A/B com a rampa do Q2; um dry-run demonstra
o desfecho "1 commit ou no-op declarado".

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente C4 — depósito inicial (PROPOSED).
