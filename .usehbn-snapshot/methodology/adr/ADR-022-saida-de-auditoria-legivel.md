---
adr-id: ADR-022
titulo: Saída de auditoria legível por humano — markdown é o veredito, JSON é anexo de máquina
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-81
path: methodology/adr/ADR-022-saida-de-auditoria-legivel.md
autor: claude-fable-5 (arquiteto useHBN, corrente E — fechamento, Bloco 4)
cross-ia-required: Codex + Antigravity (formaliza prática que eles mesmos exercem — P10)
hearback-status: confirmado por Maurício (readback 0003, 2026-06-10)
prioridade: P1 (o gate humano só funciona se o humano consegue LER o que decide)
temperatura: quente
tier-desta-mudanca: T1 (formaliza convenção já exercida; nenhum código alterado)
aplica-a: toda auditoria, parecer, resultado e relatório de ciclo do protocolo e das apps
relacionado: [.hbn/results/0025-cross-ia-codex-corrente-e.md (precedente exercido), .hbn/results/0026-cross-ia-antigravity-corrente-e.md, ADR-011 (tipos result/relatório), core/cadence-d.md (severidades), ADR-014 (cerimônia proporcional)]
evidencia-motivadora: |
  Pedido humano #4 da corrente E: resultados de auditoria entregues só como
  JSON obrigam o gate humano a parsear de olho o que deveria estar lendo em
  prosa. O precedente bom já existe e foi exercido NESTA corrente: o Codex
  entregou a re-auditoria 0025 como par .json (máquina) + .md (humano, com
  veredito, findings por severidade, recomendação por hearback e resumo
  ≤10 linhas). Este ADR transforma o precedente em regra.
---

# ADR-022 — Saída de auditoria legível por humano

## O problema, em linguagem humana

O protocolo decide por hearback humano. Hearback pressupõe que o humano LEU
e ENTENDEU o que está autorizando. Um parecer entregue só como JSON inverte
o ônus: o decisor vira parser. O custo aparece exatamente no ponto mais
crítico do sistema — o gate — e a tentação de "confiar no resumo da IA sem
ler" é a própria validação de teatro (ADR-020) na camada humana.

## Decisão 1 — Toda auditoria/resultado produz renderização markdown legível

Todo parecer, auditoria, re-auditoria ou resultado de ciclo entrega um `.md`
legível por humano contendo, nesta ordem de prioridade:

1. **Veredito** — em uma linha (aprovado/reprovado/aprovado-com-reserva;
   VETO_ADOCAO quando aplicável).
2. **Findings por severidade** — BLOQUEADOR / FORTE / MARGINAL (vocabulário
   da cadência D), cada um com EVIDÊNCIA verificável (arquivo:linha,
   comando+saída) — finding sem evidência não é finding (Truth Barrier).
3. **Recomendação por hearback** — itens enumerados na granularidade em que
   o humano decide (aprovar/recusar POR item, não em bloco).
4. **Resumo para humano** — ≤10 linhas, autossuficiente.

## Decisão 2 — JSON é anexo de máquina, nunca a entrega principal

Saída estruturada (`.json`) é bem-vinda como ANEXO para consumo mecânico
(guards, agregadores), no mesmo número de série do `.md` (precedente: par
`0025-*.json` + `0025-*.md`). Na divergência entre os dois, o `.md` assinado
pelo auditor é o parecer; o `.json` é derivado.

## Decisão 3 — Todo ciclo termina listando os caminhos criados

Handoff/fechamento de ciclo termina com a lista dos caminhos
criados/alterados, 1 linha por caminho, com 1 frase do que é. (Precedente:
handoffs da corrente E.) É a versão humana do REGISTRY do dia: o leitor da
retomada sabe o que nasceu sem rodar git.

## Enforcement

Regra de convenção verificada na re-auditoria cruzada (auditor que recebe
JSON sem `.md` legível registra finding FORTE). Guard mecânico NÃO é criado
nesta onda — legibilidade não se afere por grep; se a prática derivar,
proposta futura pode exigir mecanicamente o par `.json`+`.md` em
`.hbn/results/`.

## Consequências

Positivas: o gate humano lê prosa, não parseia; pareceres ganham forma
comparável entre famílias de IA; o resumo ≤10 linhas vira a unidade de
decisão. Negativas: custo de escrita dobrado para o auditor (par md+json) —
aceito: o tempo do gate humano é o recurso mais escasso do protocolo.

## DONE-check

Dado qualquer resultado novo em `.hbn/results/`: existe `.md` com as 4
seções da Decisão 1; se houver `.json`, é anexo do mesmo número. Todo
handoff de ciclo termina com a lista de caminhos (Decisão 3).

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente E (fechamento) — depósito inicial.
- v1.1 — 2026-06-10 — codex, consolidação — ACCEPTED por hearback humano no readback 0003.
