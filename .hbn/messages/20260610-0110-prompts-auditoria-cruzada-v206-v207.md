---
titulo: Prompts de auditoria cruzada V206/V207 - Opus, Antigravity e Codex
diataxis: how-to
hbn-track: fast_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-06-10
---

# Prompts de Auditoria Cruzada V206/V207

## Prompt 1 — Claude Opus 4.8

Use este prompt em chat novo do Claude Opus 4.8.

```text
Voce e Claude Opus 4.8, auditor/arquiteto sob AGENTS.md, HBN e Cadencia D Estendida no projeto Sistema de Credenciamento.

Raiz canonica obrigatoria:
/Users/macbookpro/Projetos/Credenciamento

Branch esperada:
codex/v12-0-0206-planejamento

Antes de ler ou editar, valide:
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list

Leia obrigatoriamente:
AGENTS.md
.hbn/relay/INDEX.md
.hbn/knowledge/0014-protocolo-fim-de-sessao.md
.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md
.hbn/knowledge/0022-firewall-workflow-fast-track.md
.hbn/messages/20260610-0110-handoff-fim-sessao-codex-bastao-codex-para-opus.md
.hbn/messages/20260610-0110-prompts-auditoria-cruzada-v206-v207.md
.hbn/results/0176-exec-onda-38-2-43-aviso-duas-linhas-relatorios-zoom.json
.hbn/results/0177-exec-onda-38-2-44-handoff-opus-pendencias-v206-v207.json

Contexto humano recente:
- 0176 importou: M=6 | F=3 | err=0 | skip=0.
- 0176 compilou limpo.
- TV2_20260610_005405: OK=16 | FALHA=0 | MANUAL=0.
- PDFs 039-048 foram gerados apos a 0176.
- O aviso em Pre-OS/OS melhorou com B29/B30.
- A tentativa de usar melhor a area branca direita dos relatorios nao funcionou.
- O operador pediu pausa de implementacao, bastao formal para Opus, melhoria useHBN e retomada Codex apenas depois dos pareceres.

Escopo da sua auditoria:
1. Auditar o estado das pendencias V206 antes do freeze.
2. Auditar a falha visual persistente dos relatorios 043-048 e indicar se ela e BLOQUEADOR, FORTE ou MARGINAL para o freeze.
3. Revisar pendencias de handoffs anteriores, relay, ERPs e docs HBN que podem bloquear estabilizacao.
4. Revisar o plano V207: quais itens sao refatoramento e nao devem entrar na V206.
5. Propor melhoria do protocolo useHBN para passagem de bastao, documentacao, prompts multi-IA e consolidacao de auditorias.
6. Nao implementar correcao VBA.
7. Nao rodar VCR.
8. Nao fazer reset/revert/stash.

Severidades:
- BLOQUEADOR: impede freeze ou nova implementacao ate resolver.
- FORTE: deve ser incorporado ou justificado por escrito.
- MARGINAL: pode virar backlog.

Saidas obrigatorias:
1. Parecer principal:
.hbn/proposals/0034-claude-opus48-auditoria-pendencias-freeze-v206-v207.md

2. Proposta useHBN:
.hbn/protocol-evolutions/20260610-claude-opus48-proposta-usehbn-bastao-documentacao-cross-audit.md

Formato do parecer:
- Findings primeiro, por severidade, com arquivo/linha quando aplicavel.
- VETO_AVANCO: SIM/NAO.
- Pendencias V206 para freeze.
- Itens explicitamente adiados para V207.
- Plano recomendado de ondas finais ate congelamento.
- Checklist anti-vies de bastao.

Formato da proposta useHBN:
- Problema observado.
- Regra proposta.
- Artefatos obrigatorios por papel: implementador, auditor Opus, auditor Antigravity, consolidador Codex.
- Nomes/path padrao.
- Como validar mecanicamente ou por checklist.
- Risco de burocracia e mitigacao.

Ao terminar, nao implemente nada. Apenas entregue os caminhos dos arquivos e um resumo executivo.
```

## Prompt 2 — Antigravity rodando Gemini 3.5

Use este prompt no Antigravity/Gemini 3.5 em contexto novo.

```text
Voce e Antigravity rodando Gemini 3.5, auditor adversarial sob AGENTS.md, HBN e Cadencia D Estendida no projeto Sistema de Credenciamento.

Raiz canonica obrigatoria:
/Users/macbookpro/Projetos/Credenciamento

Branch esperada:
codex/v12-0-0206-planejamento

Antes de ler ou editar, valide:
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list

Leia obrigatoriamente:
AGENTS.md
.hbn/relay/INDEX.md
.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md
.hbn/messages/20260610-0110-handoff-fim-sessao-codex-bastao-codex-para-opus.md
.hbn/results/0176-exec-onda-38-2-43-aviso-duas-linhas-relatorios-zoom.json

Evidencias humanas:
- Importador 0176: M=6 | F=3 | err=0 | skip=0.
- Compile limpo.
- TV2_20260610_005405: OK=16 | FALHA=0 | MANUAL=0.
- PDFs: /Users/macbookpro/Downloads/039.pdf a /Users/macbookpro/Downloads/048.pdf.
- Falha relatada: area branca direita dos relatorios nao foi usada como esperado.

Escopo adversarial:
1. Validar visualmente/textualmente PDFs 039-048.
2. Dizer se B29/B30 resolveu Pre-OS/OS.
3. Investigar por que relatorios continuam pequenos/com area branca.
4. Apontar riscos de uma proxima correcao visual: colunas, PrintArea, Zoom, PageSetup, AutoFit, resumo operacional.
5. Verificar se algum teste TV2 atual da falsa seguranca para esse problema visual.
6. Revisar se ha regressao operacional ou de documentacao.
7. Nao implementar correcao.
8. Nao rodar VCR.

Saida obrigatoria:
.hbn/proposals/0035-antigravity-gemini35-auditoria-adversarial-pendencias-freeze-v206-v207.md

Formato:
- Findings primeiro por BLOQUEADOR/FORTE/MARGINAL.
- VETO_AVANCO: SIM/NAO.
- Evidencias dos PDFs por numero.
- Hipoteses tecnicas priorizadas.
- Proposta de proxima onda, se houver, com gates humanos.
- Checklist anti-vies.

Ao terminar, nao implemente nada. Apenas entregue o caminho do arquivo e resumo executivo.
```

## Prompt 3 — Codex no proximo chat

Use este prompt em novo chat do Codex depois que Mauricio colar as respostas do
Opus e do Antigravity.

```text
Voce e Codex, implementador principal V206 sob AGENTS.md, HBN e Cadencia D Estendida no projeto Sistema de Credenciamento.

Raiz canonica obrigatoria:
/Users/macbookpro/Projetos/Credenciamento

Branch esperada:
codex/v12-0-0206-planejamento

Antes de ler ou editar, valide:
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list

Leia obrigatoriamente:
AGENTS.md
.hbn/relay/INDEX.md
.hbn/messages/20260610-0110-handoff-fim-sessao-codex-bastao-codex-para-opus.md
.hbn/messages/20260610-0110-prompts-auditoria-cruzada-v206-v207.md
.hbn/proposals/0034-claude-opus48-auditoria-pendencias-freeze-v206-v207.md
.hbn/proposals/0035-antigravity-gemini35-auditoria-adversarial-pendencias-freeze-v206-v207.md
.hbn/protocol-evolutions/20260610-claude-opus48-proposta-usehbn-bastao-documentacao-cross-audit.md

Tarefa:
1. Consolidar os pareceres Opus e Antigravity.
2. Produzir:
.hbn/proposals/0036-codex-consolidacao-auditorias-pendencias-freeze-v206-v207.md
3. Apresentar ao Mauricio uma proposta de proximas ondas:
   - correcoes visuais restantes dos relatorios;
   - validacao tela a tela pendente;
   - checkpoint VCR antes do freeze;
   - backlog V207/refatoramento.
4. Nao implementar antes de readback/hearback proprio da proxima onda.

Formato:
- Findings consolidados primeiro.
- Tabela Opus x Antigravity x Codex.
- VETO_AVANCO consolidado.
- Proxima onda recomendada com escopo e gates.
- Itens V207 explicitamente fora da V206.
```

## Saidas Esperadas

| IA | Papel | Arquivo de saida |
|---|---|---|
| Claude Opus 4.8 | Auditor/arquiteto V206/V207 | `.hbn/proposals/0034-claude-opus48-auditoria-pendencias-freeze-v206-v207.md` |
| Claude Opus 4.8 | Proponente useHBN | `.hbn/protocol-evolutions/20260610-claude-opus48-proposta-usehbn-bastao-documentacao-cross-audit.md` |
| Antigravity/Gemini 3.5 | Auditor adversarial visual/operacional | `.hbn/proposals/0035-antigravity-gemini35-auditoria-adversarial-pendencias-freeze-v206-v207.md` |
| Codex | Consolidador/implementador apos pareceres | `.hbn/proposals/0036-codex-consolidacao-auditorias-pendencias-freeze-v206-v207.md` |
