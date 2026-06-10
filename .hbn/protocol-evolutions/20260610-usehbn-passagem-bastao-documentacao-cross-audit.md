---
titulo: Proposta inicial useHBN - passagem de bastao, documentacao e auditoria cruzada
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-10
---

# Proposta Inicial useHBN

## Problema Observado

O ciclo V206 mostrou uma forma de trabalho eficaz, mas ainda cara em contexto:

- o relay concentra muito estado historico e fica dificil distinguir "proxima
  acao" de "memoria antiga";
- prompts de auditoria cruzada sao preparados de forma ad hoc;
- outputs de Opus, Antigravity e Codex nem sempre nascem com paths reservados;
- o Codex implementador tende a querer corrigir antes de consolidar pareceres;
- evidencias humanas de import/compile/TV2/PDF ficam no chat e precisam ser
  reincorporadas manualmente em HBN.

## Regra Proposta

Criar uma cadencia formal de **pacote de auditoria cruzada** sempre que houver:

- falha visual recorrente;
- pre-freeze de release;
- transferencia de bastao entre modelos;
- planejamento de refatoramento de versao futura.

## Artefatos por Papel

### Implementador

Produz:

- readback da onda corrente;
- ERP da onda corrente;
- handoff em `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-<agente>-bastao-<de>-para-<para>.md`;
- prompt pack em `.hbn/messages/AAAAMMDD-HHmm-prompts-auditoria-cruzada-<tema>.md`;
- relay atualizado com estado curto e proxima acao.

### Auditor Opus

Produz:

- `.hbn/proposals/NNNN-claude-opus48-auditoria-<tema>.md`;
- quando houver melhoria de protocolo, `.hbn/protocol-evolutions/AAAAMMDD-claude-opus48-proposta-<tema>.md`.

### Auditor Antigravity/Gemini

Produz:

- `.hbn/proposals/NNNN-antigravity-gemini35-auditoria-adversarial-<tema>.md`.

### Consolidador Codex

Produz:

- `.hbn/proposals/NNNN-codex-consolidacao-auditorias-<tema>.md`;
- readback da proxima onda de implementacao, se e somente se Mauricio aprovar.

## Checklist Obrigatorio do Prompt Pack

Todo prompt pack deve conter:

- raiz canonica;
- branch esperada;
- comandos de preflight;
- leituras obrigatorias;
- evidencias humanas recentes;
- escopo e nao-escopo;
- severidade BLOQUEADOR/FORTE/MARGINAL;
- arquivo de saida exato;
- proibicao explicita de implementacao quando a tarefa for auditoria.

## Validacao

Validacao manual minima:

- `rg -n "Saida obrigatoria|\\.hbn/proposals|VETO_AVANCO|BLOQUEADOR|FORTE|MARGINAL" .hbn/messages/<prompt-pack>.md`
- `git status --short --branch`
- `bash scripts/hbn-guards/hbn-guards-runner.sh`

Validacao futura desejavel:

- schema `handoff.schema.json`;
- schema leve para prompt pack;
- guard que recuse relay sem `proxima-acao` atualizada quando houver handoff
  novo.

## Risco de Burocracia

Risco: transformar cada microcorrecao em excesso de documento.

Mitigacao: aplicar este pacote apenas em gates relevantes, transferencia de
bastao, freeze ou falha recorrente. Microfix simples continua com readback/ERP
normal.

## Recomendacao ao Opus

Opus deve auditar esta proposta, remover excessos, transformar o que for regra
permanente em knowledge nova ou atualizacao de knowledge existente, e manter o
que for apenas experimental como protocol-evolution.
