---
adr-id: ADR-018
titulo: Papéis como contrato, chapéus como atribuição — e guard anti-groupthink por família de modelo
status: PROPOSED
data-deposito: 2026-06-10
id-global: 20260610-45
autor: claude-fable-5 (arquiteto useHBN, corrente D)
cross-ia-required: Opus + Codex (muda o rito de atribuição — P10; nota: este ADR REDUZ o poder de quem o propõe, ver §Consequências)
hearback-status: pendente (lote corrente D)
prioridade: P1
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + spec + guard-spec + campo no STATE/schema)
aplica-a: protocolo e todos os projetos (atribuição vive no STATE de cada um)
relacionado: [ADR-015 (papeis_aptos + fornecedor nos perfis), core/cadence-d.md (P1/P2/P4), core/roles-assignment-spec.md (20260610-46), guards/assert-role-family.sh (20260610-47), core/relay-spec.md + schemas/state.schema.json (campo atribuicao, proposed)]
evidencia-motivadora: |
  Cadência D já admite: "chat novo reduz mas não elimina viés de mesma
  família de pesos". Decisão de Maurício (corrente D): Opus/Cowork = auditor
  fixo, NÃO outra janela Fable — exatamente porque Fable auditando Fable é
  o mesmo modelo com outro chapéu. Hoje essa regra vive em decisão de chat,
  não em contrato checável; e o STATE 0177 registra papéis em prosa livre,
  sem campo que uma máquina valide.
---

# ADR-018 — Papel é contrato; modelo é quem veste; família não se auto-audita

## O problema, em linguagem humana

O protocolo fala de "implementador" e "auditor" como se fossem pessoas, mas
são CHAPÉUS que modelos vestem por onda. Quando o chapéu não está escrito em
lugar checável, dois riscos: (1) ambiguidade — a janela que retoma não sabe
inequivocamente que chapéu veste; (2) groupthink — um modelo da mesma família
de pesos audita o irmão e chama isso de auditoria cruzada. O caso observado
em 2026-05-27 (cada IA recomendou preservar a própria relevância) mostra que
viés de família é real e estrutural, não má-fé.

## Decisão 1 — Atribuição gravada no STATE (campo `atribuicao`)

O STATE (relay-spec) ganha campo opcional→obrigatório-por-rampa `atribuicao`:
`chapeu_atual` (papel da janela dona do bastão, inequívoco), `implementador`
(apelido de perfil ADR-015), `auditores` (lista de apelidos), `gravada_em`,
`hearback_ref`. Apelidos referenciam `.hbn/models/<apelido>.json` — papel só
pode ser atribuído a quem o tem em `papeis_aptos` (ADR-015). Prosa do campo
`papeis` continua existindo para humanos; `atribuicao` é a versão que máquina
valida. Detalhe normativo: `core/roles-assignment-spec.md`.

## Decisão 2 — Invariante anti-groupthink

Para todo X: **família(auditor de X) ≠ família(implementador de X)**, onde
família = `fornecedor` do perfil (Anthropic × OpenAI × Google × …).
`guards/assert-role-family.sh` (spec) verifica o invariante sobre a
`atribuicao`. Violação = atribuição inválida; exceção só por hearback
explícito registrado (`hearback_ref`), nunca silenciosa. Nota: auditor e
implementador de fornecedores distintos entre si TAMBÉM é o desejável quando
há 2+ auditores (P2 da cadência D), mas o invariante duro é contra o
implementador.

## Decisão 3 — Papéis fixos vigentes (registro da decisão de Maurício, corrente D)

Opus/Cowork = auditor/validador fixo desta fase; janelas Fable NÃO se
auditam entre si (mesma família E mesmos pesos). Humano (Maurício) = gate.

## Decisão 4 — Wrappers de terminal: FUTURO, não construído

Wrappers `fast_track` de leitura/auditoria via CLI ficam ESPECIFICADOS como
direção em `core/roles-assignment-spec.md` §5 e nada mais. Orquestração por
CLI é spec futura por decisão expressa; este ADR não cria código de
orquestração.

## Consequências

Honestidade: este ADR foi escrito por um modelo Anthropic e RESTRINGE
modelos Anthropic (Fable não pode ser auditado por Opus em rigor absoluto de
família — a Decisão 3 registra que Maurício ACEITOU essa exceção
conscientemente para esta fase, dado que Opus×Fable são checkpoints
distintos; o guard, por isso, trata "mesma família" como BLOQUEADOR apenas
entre implementador↔auditor, e como AVISO entre auditores↔arquiteto, citando
o hearback que cobre a exceção vigente). Custo: atribuir onda passa a exigir
1 bloco YAML válido. Ganho: chapéu inequívoco na retomada + groupthink vira
erro de máquina, não lapso de memória.
