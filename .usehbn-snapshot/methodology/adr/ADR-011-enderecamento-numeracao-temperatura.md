---
adr-id: ADR-011
titulo: Endereçamento, numeração sequencial e temperatura de artefatos — padrão único multi-projeto
status: ACCEPTED
data-deposito: 2026-06-10
autor: claude-fable-5 (arquiteto useHBN, corrente C2)
cross-ia-required: Opus + Codex (padrão estrutural, P10)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P0 (mata classe inteira de perda de rastreabilidade)
aplica-a: TODOS os projetos sob o protocolo (usehbn, Credenciamento, timelessphoto, futuros)
relacionado: [ADR-012 (naming versões/ondas), core/relay-spec.md (read-list), ADR-008 v2 (inbox usa este id)]
evidencia-motivadora: |
  Artefatos sem número crescente no próprio repo canônico em 2026-06-10:
  docs/ANALISE-PROFUNDA-EVOLUCAO-PROTOCOLO-2026-06-10.md,
  HBN-ARCHITECTURAL-REVIEW-2026-04.md, AUDITORIA_SUPERPOWERS.md,
  PROMPT_C1_BASTAO_FABLE5.md vs PROMPT_C2_CHAIN_FABLE5.md (ordem só via mtime),
  reports/BASELINE-RETOMADA-2026-06-10.md. Impossível responder "o que veio
  antes?" sem git forensics. Colisão real: proposals 0014×0014 (multi-frente).
---

# ADR-011 — Endereçamento, numeração e temperatura

## O problema, em linguagem humana

Hoje um documento nasce com o nome que o autor inventou na hora
(`ANALISE-PROFUNDA-*.md`, `AUDITORIA_SUPERPOWERS.md`). Seis meses depois,
ninguém — humano ou IA — sabe qual análise veio antes de qual, qual ainda
vale e qual já foi substituída. O custo é pago a cada retomada: relê-se
documento morto como se fosse vivo. Este ADR dá a cada artefato (1) um número
que diz QUANDO ele entrou na fila, (2) uma temperatura que diz SE ele ainda
governa, e (3) um livro-razão que responde as duas perguntas sem abrir o
arquivo.

## Decisão 1 — ID global: `AAAAMMDD-NN` (data + sequência do dia)

Todo artefato do protocolo recebe, ao nascer, o id `AAAAMMDD-NN`
(data do depósito + sequência de 2 dígitos dentro do dia, atribuída pela
ordem de entrada no REGISTRY — Decisão 4). Ex.: `20260610-03`.

**Por que este e não o NNNN global puro:**

- **Monotônico por construção**: ordena lexicograficamente = ordena no tempo.
  Não exige consultar um contador central para saber o próximo número — só o
  bloco do dia corrente no REGISTRY (NN raramente passa de meia dúzia).
- **Anti-colisão estrutural**: a colisão 0014×0014 aconteceu porque duas
  frentes disputavam o mesmo contador global sem coordenação. Com
  `AAAAMMDD-NN`, duas frentes em dias diferentes NUNCA colidem; no mesmo dia,
  o ponto de coordenação é uma linha de append no REGISTRY do plano — barato
  e auditável.
- **Auto-datado**: o id já responde "quando" sem abrir o arquivo nem o git.

**Séries locais existentes continuam** (ADR-NNN, knowledge NNNN, proposals
NNNN, readbacks NNNN): elas já são monotônicas dentro da própria série e
renomeá-las violaria a regra "nunca renomear história". A série local segue
sendo a chave DENTRO da pasta; o REGISTRY registra o id global de cada
depósito novo, costurando as séries numa linha do tempo única.

Artefato FORA de série numerada (relatórios, análises, prompts, auditorias —
exatamente os órfãos de hoje) passa a nascer como
`AAAAMMDD-NN-<tipo>-<slug>.md`. Vocabulário de `<tipo>`: o do ADR-012 §3
(rb, exec, tecnico, handoff, proposal, adr, audit, analise, report, prompt,
knowledge, baseline).

## Decisão 2 — Tabela única tipo → pasta → numeração → temperatura default

Idêntica em todos os projetos. No protocolo (usehbn) e nas apps consumidoras
(`.hbn/` do projeto):

| Tipo | Pasta | Numeração | Temperatura default |
|---|---|---|---|
| adr | `methodology/adr/` | `ADR-NNN` (série local) | quente (PROPOSED/ACCEPTED); ultrapassado ao ser superseded |
| knowledge | `.hbn/knowledge/` | `NNNN` (série local) | quente até `revisar-em`; sob demanda na leitura (relay-spec) |
| readback | `.hbn/readbacks/` | `NNNN` (série local) | quente enquanto onda aberta; frio ao fechar |
| hearback | `.hbn/hearbacks/` | `NNNN` (espelha o readback) | frio ao nascer (registro) |
| proposal (auditoria/consolidação) | `.hbn/proposals/` | `NNNN` (série local) | quente até consolidada; frio depois |
| exec/result | `.hbn/results/` | `NNNN` (série local) | frio ao nascer |
| handoff | `.hbn/messages/` | `AAAAMMDD-NN` | quente até retomada concluída; frio depois |
| relatório/auditoria/análise | `reports/` (protocolo) ou `auditoria/` | `AAAAMMDD-NN` | frio ao entregar (evidência histórica) |
| prompt de ciclo | raiz ou `docs/` | `AAAAMMDD-NN` | quente durante o ciclo; frio ao encerrar |
| inbox (feedback de projeto) | `inbox/<projeto>/` | `AAAAMMDD-NN` (namespaced por projeto) | quente até consolidado pelo arquiteto |
| spec core | `core/` | sem número (nome estável) | quente; ultrapassado via `superseded_by` |

Specs core e arquivos de nome estável (AGENTS.md, README) não recebem id no
nome — são endereços, não eventos; entram no REGISTRY quando mudam de
temperatura.

## Decisão 3 — Temperatura no front-matter

Campo obrigatório em todo artefato novo:

```yaml
temperatura: quente | frio | ultrapassado
superseded_by: <id>        # obrigatório se ultrapassado
```

- **quente** — vivo, governa agora. Só artefato quente PODE estar em
  read-list (condição necessária, não suficiente: a read-list canônica é a
  seleção MÍNIMA entre os quentes, per core/relay-spec.md e a regra do
  invariante sempre-quente).
- **frio** — histórico preservado. Fora de qualquer read-list. NUNCA deletado.
- **ultrapassado** — substituído por outro artefato (`superseded_by`
  obrigatório). Morto para decisão, preservado para auditoria. NUNCA deletado.

Transição é mudança de front-matter + linha no REGISTRY — nunca rename,
nunca delete.

## Decisão 4 — REGISTRY append-only por plano

Um `REGISTRY.md` por plano (raiz do usehbn; `.hbn/REGISTRY.md` nas apps).
Append-only, uma linha por evento (nascimento ou mudança de temperatura):

```markdown
| id | artefato (path) | tipo | temperatura | superseded_by |
|---|---|---|---|---|
| 20260610-01 | reports/BASELINE-RETOMADA-2026-06-10.md | baseline | frio | — |
| 20260610-02 | methodology/adr/ADR-011-enderecamento-numeracao-temperatura.md | adr | quente | — |
```

É o livro-razão: dado qualquer par de artefatos, a ordem das linhas (e o id)
diz o que veio antes; a coluna temperatura/superseded_by diz se algum foi
ultrapassado — sem abrir arquivo nenhum. Quem deposita artefato appenda a
linha no mesmo commit (verificável por guard futuro, mesmo padrão do
guard-state-fresh).

## Decisão 5 — Migração: só daqui pra frente

- Nenhum arquivo histórico é renomeado. NUNCA.
- Todo artefato NOVO a partir da aceitação nasce conforme este ADR.
- O REGISTRY abre com uma seção "Legado (mapeamento, sem rename)" listando os
  órfãos conhecidos com data efetiva reconstruída do git
  (ex.: `HBN-ARCHITECTURAL-REVIEW-2026-04.md → efetivo ~2026-04-03, frio`),
  apenas para que o livro-razão responda também pelo passado.
- Artefato legado que ainda governa (quente) ganha o front-matter de
  temperatura na primeira edição natural — sem onda dedicada de retrofit.

## Consequências

Positivas: o problema "doc sem número" fica impossível going-forward; ordem
temporal e vigência respondíveis em O(1) pelo REGISTRY; colisões de id entre
frentes/projetos eliminadas por construção; base para o inbox multi-projeto
(ADR-008 v2). Negativas: disciplina nova de 1 linha de append por depósito
(mitigada por guard futuro); dois esquemas convivem (séries locais legadas +
id global) — custo aceito para não reescrever história.

## DONE-check

Dado dois artefatos quaisquer: ids `AAAAMMDD-NN` (ou linhas do REGISTRY, para
séries locais) ordenam inequivocamente quem veio antes; `temperatura` +
`superseded_by` dizem se algum foi ultrapassado.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente C2 — depósito inicial (PROPOSED).
