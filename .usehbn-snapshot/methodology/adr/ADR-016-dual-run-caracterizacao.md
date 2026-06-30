---
adr-id: ADR-016
titulo: Dual-run / teste de caracterização — padrão para reescrever legado com segurança
status: PROPOSED
data-deposito: 2026-06-10
id-global: 20260610-37
autor: claude-fable-5 (arquiteto useHBN, corrente D)
cross-ia-required: Opus + Codex (padrão estrutural — P10)
hearback-status: pendente (lote corrente D)
prioridade: P1
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + spec + schema)
aplica-a: protocolo (padrão); aplicação a projeto consumidor = proposta via inbox/<projeto>/
relacionado: [ADR-014 (T3: humano aplica), core/dual-run-spec.md (20260610-38), schemas/dual-run-result.schema.json (20260610-39), knowledge 0021 (sandbox informativo)]
evidencia-motivadora: |
  Transição V206→V207 do Credenciamento: reescrever motor legado (VBA) cujo
  comportamento real inclui regras NÃO documentadas, descobertas só em
  produção. Hoje não existe trilho: ou se reescreve "no escuro" (regressão
  silenciosa) ou não se reescreve (dívida eterna). O protocolo já tem o
  análogo em escala menor: guards C3 foram promovidos 1:1 com diff declarado
  — dual-run generaliza isso para motores inteiros.
---

# ADR-016 — Dual-run: o velho vira gabarito do novo

## O problema, em linguagem humana

Reescrever um sistema legado é trocar o motor com o avião voando. O perigo
não está no que o legado DIZ que faz (isso os docs cobrem), está no que ele
FAZ sem dizer — regras embutidas que viraram contrato com os usuários sem
ninguém decidir. A solução clássica (Feathers, characterization testing) é
inverter o ônus: o comportamento ATUAL, certo ou errado, vira o gabarito
("golden"); o motor novo só ganha o lugar do velho quando produz saída
idêntica — ou quando cada diferença foi olhada por um humano e aprovada por
escrito. Bug conhecido reproduzido é decisão; bug novo introduzido é acidente.

## Decisão 1 — O velho é o gabarito (golden)

Para cada caso do corpus de caracterização, a saída do motor ATUAL é
registrada com hash e congelada (`core/dual-run-spec.md` §2). O corpus DEVE
incluir os casos que exercitam regras não documentadas conhecidas e os casos
de borda colhidos de produção — não só o caminho feliz.

## Decisão 2 — Gate mecânico de substituição

Motor novo substitui o velho somente quando, para TODO caso do corpus:
`diff == 0` (byte-idêntico ou idêntico sob normalização declarada), OU
`diff != 0` com `justificativa` escrita + `hearback_ref` confirmado. Um único
caso `diferente` sem justificativa aprovada = gate FALHA. O resultado de cada
caso é um registro `schemas/dual-run-result.schema.json` — o gate é uma
função sobre esses registros, executável por script ou à mão.

## Decisão 3 — Divisão de trabalho (tier T3, ADR-014)

A IA DESENHA o harness (corpus, normalizações, script de comparação, formato
dos registros); o HUMANO RODA no ambiente real e commita os resultados. IA
nunca executa o motor de produção nem commita no projeto consumidor —
coerente com o firewall 0022 e knowledge 0021. Aplicação deste padrão a um
projeto específico entra por `inbox/<projeto>/`, nunca por edição direta.

## Consequências

Custo: montar corpus dá trabalho e o golden pode congelar bugs — por design;
o bug congelado fica VISÍVEL (caso nomeado) e sua correção vira diff
justificado com hearback, não acidente. Risco residual: corpus incompleto;
mitigação na spec §5 (cobertura mínima + regra "produção encontrou caso novo
→ caso entra no corpus antes do fix").
