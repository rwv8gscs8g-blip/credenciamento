---
adr-id: ADR-017
titulo: Freeze-gate executável — "congelável" é veredicto de máquina, não opinião de doc
status: PROPOSED
data-deposito: 2026-06-10
id-global: 20260610-40
autor: claude-fable-5 (arquiteto useHBN, corrente D)
cross-ia-required: Opus + Codex (rito de release — P10)
hearback-status: pendente (lote corrente D)
prioridade: P1
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + spec + schema + guard-spec)
aplica-a: protocolo (padrão); aplicação à V206 = inbox/credenciamento/20260610-44
relacionado: [core/freeze-gate-spec.md (20260610-41), schemas/freeze-checklist.schema.json (20260610-42), guards/freeze-gate.sh (20260610-43), ADR-016 (dual-run alimenta critérios), cadence-d (severidade BLOQUEADOR)]
evidencia-motivadora: |
  STATE da onda 0177 (Credenciamento): "🟡 freeze V12.0.0206 bloqueado até
  validação tela a tela" convive com pressão de avançar para V207. Hoje
  "206 congelável" é uma frase em handoff — cada IA que retoma reinterpreta
  o que falta. Pareceres 0034/0035/0036 abertos, gate visual 0176 aberto:
  estado de freeze disperso em 3+ artefatos, sem resposta única.
---

# ADR-017 — Freeze é gate, não doc

## O problema, em linguagem humana

"Está congelável?" hoje se responde relendo handoffs e contando pendências de
cabeça — cada plantonista refaz a conta e chega a um número diferente. A
pergunta é binária e os critérios são enumeráveis; logo, a resposta deve sair
de uma máquina que lê um checklist estruturado e devolve "sim" ou "não, falta
X, Y, Z". O humano continua dono dos critérios e das evidências; a máquina só
elimina a releitura e o autoengano.

## Decisão 1 — Checklist estruturado por versão-alvo

Cada candidata a freeze tem UM arquivo `freeze-checklist` (schema
`schemas/freeze-checklist.schema.json`) com critérios nomeados, cada um
`ok | pendente | na`, com `evidencia` obrigatória para `ok` (path/hash/id de
teste — Truth Barrier: afirmação sem evidência não conta).

## Decisão 2 — Gate executável

`guards/freeze-gate.sh` (spec; mesma família dos guards C3) lê o checklist e
responde `congelável: sim` (exit 0) ou `congelável: não` + lista do que falta
(exit 1). Regras: todo critério `obrigatorio: true` precisa estar `ok`;
`na` exige `justificativa`; `bloqueadores_abertos > 0` = não, sempre
(severidade BLOQUEADOR da cadência D é veto).

## Decisão 3 — Critérios canônicos mínimos (perfil "app de domínio")

validação tela a tela concluída; toda correção da janela coberta por teste
verde; idempotência provada (re-execução sem efeito novo, com evidência);
PDFs de evidência do rodízio gerados; zero BLOQUEADOR aberto; pareceres de
auditoria cruzada da janela fechados. Projetos estendem, nunca encolhem, a
lista obrigatória sem hearback.

## Decisão 4 — Aplicação a projeto é proposta, não imposição

A instância V12.0.0206 do Credenciamento entra por
`inbox/credenciamento/20260610-44-freeze-gate-v206.md`. O canônico define o
padrão; quem preenche checklist e roda o gate no projeto é o time do projeto
(humano roda — coerente com 0022/0021).

## Consequências

Custo: manter o checklist atualizado a cada onda (1 flip de campo por
critério — T1). Ganho: "congelável?" vira comando de 1 linha com resposta
auditável; remove a classe de erro "freeze por cansaço". Risco: checklist
teatral (ok sem evidência real) — mitigado pela evidência obrigatória e pelo
auditor cruzado conferir amostras.
