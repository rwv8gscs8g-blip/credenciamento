---
adr-id: ADR-010
titulo: Autoevolve — ciclo de microdeltas locais com scaffold para computação distribuída
status: ACCEPTED
data-deposito: 2026-05-13
data-ratificacao: 2026-06-10
autor: Claude Opus 4.7 (chat autoevolve cycle 2026-05-13)
cross-ia-required: Opus + (Codex OU Antigravity)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P1
ordem-cross-ia: livre — não bloqueia ADRs P0
relacionado:
  - ADR-001 (Quarta de Sanitização — janela 12h BRT)
  - ADR-007 (Métricas de saúde)
  - src/usehbn/autoevolve/ (implementação de referência local)
  - docs/feynman/USEHBN-EXPLICADO.md (vitrine humana do ciclo)
---

# ADR-010 — Autoevolve: ciclo de microdeltas locais, scaffold distribuído

## Status

**ACCEPTED** — depositado 2026-05-13 durante o próprio ciclo descrito e
ratificado por hearback humano em 2026-06-10.

## Contexto

A Quarta de Sanitização (ADR-001) tem janela ativa de tokens IA de
~6h por semana (terça-noite + quarta 06–12h BRT). Esse tempo precisa
produzir **entrega objetiva, verificável e padronizada** em vários
braços do sistema, sem desorganizar o resto.

Sem disciplina, a janela vira:

1. Esforço espalhado sem mensuração por braço;
2. Microdeltas grandes demais — risco de regressão;
3. Trilha de auditoria misturada com decisões doutrinárias dos ADRs.

## Decisão

Adotar o **ciclo Autoevolve** como mecanismo operacional padrão da
janela de tokens IA da Quarta de Sanitização. Características:

### 1. Unidade de trabalho — microdelta

Cada iteração da janela é uma **MicrodeltaTask** com contrato
JSON-serializável (`src/usehbn/autoevolve/contract.py`, v1.0.0):

- `arm`: nome do braço do sistema (ex.: `translation`, `runtime`);
- `slug`: identificador curto da mudança;
- `files_allowed`: prefixos de path permitidos;
- `tests_required`: lista de seletores pytest obrigatórios;
- `max_diff_lines`: orçamento de diff (default 80).

### 2. Cadeia obrigatória por microdelta

```
pop → apply → pytest → gate de aprovação → commit → audit
```

Critério de aprovação automática:

1. `pytest -q` verde antes e depois;
2. Diff dentro do orçamento `max_diff_lines`;
3. Nenhum arquivo fora de `files_allowed`;
4. Sem `--no-verify`, `--force`, `reset --hard`;
5. Sem push para remoto durante o ciclo;
6. Sem mudança em `Credenciamento/` (freeze V204 ativo).

Se qualquer critério falhar, o microdelta é gravado no audit como
`failed`/`oversized`/`skipped` e o orquestrador segue para o próximo.

### 3. Trilha de auditoria — `.hbn/autoevolve/cycle-<id>.jsonl`

Uma linha JSONL por microdelta, selada com os signals canônicos
(`INTENT_DECLARED`, `READBACK_OK`, `EXECUTION_START`, `EXECUTION_END`,
`AUDIT_SEALED`, `AUTOEVOLVE_TICK`). `AUTOEVOLVE_TICK` formaliza-se
como o 17º signal HBN — operacional, não user-facing.

### 4. Interface humana — `hbn autoevolve`

CLI com `status`, `audit`, `approve`, `rollback`. `approve --lock`
cria o marker `.hbn/autoevolve/HUMAN_GATE` que bloqueia
microdeltas auto. `rollback --commit <hash>` imprime o `git revert`
correspondente.

### 5. Scaffold distribuído

A implementação atual é local (LocalWorker + FileQueue). Os
contratos `MicrodeltaTask` e `MicrodeltaResult` são JSON-serializáveis
de propósito: a próxima geração substitui `FileQueue` por
Redis/SQS/HTTP e `LocalWorker` por `RemoteWorker`, **sem alterar o
orquestrador, o audit, ou o CLI**.

### 6. Mapa de braços

A janela cobre obrigatoriamente os 14 braços catalogados:

1. Protocol Core
2. Runtime
3. CLI
4. Bridge
5. Execution
6. Connectors
7. Translation
8. State
9. Trigger
10. Signals
11. Methodology
12. Schemas
13. Site/Docs
14. Audit/Tooling

Pelo menos 12 dos 14 devem registrar microdelta verde para a
janela ser considerada bem-sucedida. Abaixo disso, abrir post-mortem.

## Consequências

### Positivas

1. Cada Quarta vira um ciclo mensurável com 12–17 commits pequenos
   e testáveis em vez de 1–2 commits grandes;
2. Trilha de auditoria `.jsonl` permite reproduzir o ciclo;
3. O scaffold distribuído elimina a necessidade de re-arquitetar
   quando a operação evoluir para múltiplos workers;
4. A vitrine pública (página HTML estática derivada do `.jsonl`) é
   evidência verificável do que mudou.

### Negativas / Riscos

1. **Overhead em pull requests pequenos** — para uma mudança trivial
   fora de Quarta, o ciclo Autoevolve é caro demais. **Mitigação**:
   o ciclo é opt-in, ativado por `hbn autoevolve plan`;
2. **Granularidade demais pode esconder design coeso** — uma série
   de microdeltas pode produzir incoerência local. **Mitigação**:
   o consolidador (`hbn autoevolve audit`) renderiza relatório
   markdown agregado, e o humano lê isso antes de promover versão;
3. **Aprovação automática quando o humano está dormindo** —
   pytest verde não cobre design ruim. **Mitigação**: gate
   `HUMAN_GATE` ativável por arquivo + revisão obrigatória antes
   de qualquer bump de PROTOCOL_VERSION.

## Próximo passo

1. Cross-IA review por Codex e/ou Antigravity sobre este ADR;
2. Hearback humano (Mauricio) com bloco consolidado;
3. Após ACCEPTED, registrar atributo `cycle.adr` em
   `.hbn/autoevolve/cycle-*.jsonl` apontando para `ADR-010`.

## Versão

v1.0 — depósito inicial 2026-05-13 dentro do próprio ciclo,
escrito por Claude Opus 4.7 chat autoevolve.
