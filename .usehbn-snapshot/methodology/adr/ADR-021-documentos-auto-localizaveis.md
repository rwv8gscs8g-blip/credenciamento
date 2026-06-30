---
adr-id: ADR-021
titulo: Documentos auto-localizáveis — todo artefato declara `path:` com o caminho canônico onde mora
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-79
path: methodology/adr/ADR-021-documentos-auto-localizaveis.md
autor: claude-fable-5 (arquiteto useHBN, corrente E — fechamento, Bloco 3)
cross-ia-required: Codex + Antigravity (estende ADR-011, padrão estrutural — P10)
hearback-status: confirmado por Maurício (readback 0003, 2026-06-10)
prioridade: P1 (fecha o gap "artefato colado em chat não sabe onde mora")
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + guard novo + templates)
aplica-a: todo artefato novo do protocolo e das apps consumidoras
relacionado: [ADR-011 (endereçamento/numeração — este ADR o estende), ADR-020 (teste negativo obrigatório), guards/assert-self-path.sh, methodology/templates/ADR-TEMPLATE.md, methodology/templates/MD-TEMPLATE.md]
evidencia-motivadora: |
  Artefatos do protocolo circulam COLADOS em chats, prompts e handoffs entre
  janelas de IA. Um documento colado sem origem obriga o destinatário a
  adivinhar onde ele mora — e um rename silencioso (ou um path de handoff
  digitado de memória) cria referência fantasma sem que guard nenhum perceba.
  O pedido humano #2 da corrente E nomeia o requisito: o documento deve ser
  auto-localizável. ADR-020 e o hearback 0002 já nasceram com `path:`
  (dogfood); falta a regra e o dente.
---

# ADR-021 — Documentos auto-localizáveis

## O problema, em linguagem humana

O ADR-011 deu a cada artefato um número (quando nasceu) e uma temperatura
(se ainda governa). Falta a terceira pergunta que toda retomada faz: ONDE
ele mora. Hoje a resposta vive fora do documento — no REGISTRY, no handoff,
na memória de quem colou. Quando o documento viaja (chat, prompt, e-mail),
a resposta viaja separada e se perde. Pior: um `path:` errado é mais nocivo
que nenhum, porque manda o leitor com confiança ao lugar errado.

## Decisão 1 — Campo `path:` obrigatório em artefato novo

Todo artefato novo do protocolo declara seu caminho canônico, relativo à
raiz do repositório:

- `.md`: campo `path:` no front-matter YAML.
- `.json` governado (hearbacks, e demais quando aplicável): chave
  top-level `"path"`.

O valor é o caminho REAL do arquivo. Declarar é responsabilidade de quem
deposita; manter é responsabilidade de quem move (mover arquivo = atualizar
`path:` no mesmo commit — e mover artefato numerado segue proibido pelo
ADR-011, "nunca renomear história").

## Decisão 2 — Guard leve `assert-self-path` (G-SLF), com teste negativo

`guards/assert-self-path.sh` recusa, no diff (staged local; range em CI;
`--diff-filter=AR` para pegar rename):

1. **Auto-localização mentirosa**: arquivo novo/renomeado que declara
   `path:` DIFERENTE do caminho real → BLOQUEIA. (Teste negativo
   obrigatório por ADR-020 — é o caso-ruim canônico deste guard.)
2. **Artefato governado mudo**: artefato numerado novo (subconjunto `.md`
   da tabela do ADR-011 Decisão 2 + `.hbn/hearbacks/*.json`) sem `path:`
   declarado → BLOQUEIA.

O guard NÃO entra no runner nesta onda (ADR-020 Decisão 2: ativação é onda
própria, com suíte verde + hearback).

## Decisão 3 — Templates dos tipos do ADR-011 atualizados

`methodology/templates/ADR-TEMPLATE.md` e `methodology/templates/MD-TEMPLATE.md`
ganham `id-global:`, `path:` e `temperatura:` no front-matter — os três
campos que o ADR-011 + este ADR exigem e que os templates ainda não pediam
(drift template×regra detectado nesta onda).

## Decisão 4 — Migração: só daqui pra frente

Espelha ADR-011 Decisão 5: nenhum retrofit em massa. Artefato legado ganha
`path:` na primeira edição natural. O guard só olha arquivos novos/renomeados.

## Consequências

Positivas: documento colado em qualquer contexto carrega o próprio endereço;
rename sem atualização de front-matter vira erro mecânico; custo de
verificação cai para "compare duas strings". Negativas: redundância
path-no-arquivo × path-no-filesystem (é o preço da auto-localização —
mesma lógica do REGISTRY); mais um campo para preencher (mitigado pelos
templates).

## DONE-check

`bash guards/tests/run-guard-tests.sh` verde incluindo: caso-ruim
"`path:` declarado ≠ real" BLOQUEADO; caso-ruim "artefato numerado sem
`path:`" BLOQUEADO; caso-bom passa. Templates pedem os três campos.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente E (fechamento) — depósito inicial.
- v1.1 — 2026-06-10 — codex, consolidação — ACCEPTED por hearback humano no readback 0003, sem ativar guards no runner.
