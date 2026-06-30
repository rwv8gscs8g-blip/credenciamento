---
titulo: "hbn-exuvia — scaffold inativo da maquina de muda"
status: proposed
temperatura: quente
path: core/hbn-exuvia-scaffold.md
id-global: 20260614-183746-codex-hbn-exuvia-scaffold
created_at: "2026-06-14T18:37:46-03:00"
---

# hbn-exuvia — scaffold inativo

Este documento registra a mecanica preparada na onda M-A. Ele nao autoriza a
exuvia real. A ativacao continua bloqueada pelo Fitness Gate: baseline
funcional, Ponte do Credenciamento verde e confronto incumbente x desafiante.

## Ponteiro ativo

`.hbn/active-version` e a fonte unica da versao ativa.

- valor `.` significa: o incumbente 0.3.x continua na raiz atual;
- valor futuro `versao_X_Y_Z` aponta para uma pasta de versao inteira;
- arquivo ausente, vazio, com mais de uma linha ativa, com path inseguro ou com
  marcador de conflito de merge e estado invalido;
- conflito de merge no ponteiro nunca e resolvido automaticamente: falha
  fechado ate uma resolucao humana escolher exatamente uma versao ativa.

Nesta onda o ponteiro fica em `.`. Portanto, o comportamento observavel deve
ser igual ao da raiz atual.

## Hooks

Os hooks locais em `.git/hooks/pre-commit` e `.git/hooks/commit-msg` sao shims
finos e autonomos. Eles leem `.hbn/active-version`, validam o ponteiro e so
entao delegam para os guards da versao ativa.

Como `.git/hooks/` nao e versionado pelo Git, os templates auditaveis ficam em
`guards/hook-shims/pre-commit` e `guards/hook-shims/commit-msg`. A instalacao
local deve manter o marcador de versao desses templates.

Fail-closed obrigatorio:

- ponteiro ausente ou ilegivel bloqueia;
- ponteiro com conflito bloqueia;
- pasta da versao ativa inexistente bloqueia;
- runner ou guards obrigatorios ausentes na versao ativa bloqueiam;
- hooks ausentes ou sem o marcador `HBN_HOOK_SHIM_VERSION=M-A-20260614`
  bloqueiam o runner em pre-flight.

## Guards version-aware

`guards/lib/common.sh::get_canonical_root()` resolve a raiz da versao ativa.
`guard_diff_files()` entrega paths relativos a essa raiz. Assim, um path Git
`versao_1_0_0/.hbn/messages/x.md` passa a ser validado como
`.hbn/messages/x.md` dentro da versao.

`G-REG` le o `REGISTRY.md` da versao ativa e compara paths sem o prefixo da
pasta de versao. `G-STRAY` continua bloqueando `.hbn` solto, mas aceita `.hbn`
dentro de uma `versao_*` pertencente a um repo com `.hbn/active-version`.

## Continuidade token x STATE

O token de posse permanece em `.git/hbn-baton-token`, compartilhado entre
versoes e nunca versionado. O `STATE.md` que governa e o da versao ativa.
Rollback precisa reconciliar esses dois planos:

1. preservar o arquivo local `.git/hbn-baton-token`;
2. calcular o sha256 do token preservado;
3. ajustar o `bastao_token_sha256` do `STATE.md` ativo para esse hash, ou
   exigir rotacao humana se o token local estiver ausente;
4. preservar o fingerprint publico `34a7f2f9` enquanto esse for o token de
   posse em vigor.

## Tag anti-GC e rollback

A tag planejada para o corte real e `hbn-exuvia/protocol-0.3.x`. Ela deve
apontar para o commit que congela a casca 0.3.x. M-A nao cria essa tag, pois
nao ha corte real nesta onda.

O script `scripts/hbn-exuvia-rollback.sh` existe para dry-run e para a futura
M-C. Por padrao ele so relata o plano. A aplicacao real exige `--apply` e deve
ser feita pelo operador depois do Fitness Gate.

## Bloat e glacier

O congelamento futuro usa `git mv`, nunca `cp`, para nao duplicar a historia.
`build/`, `dist/`, caches, logs e artefatos temporarios ficam ignorados. A
politica de glacier deve ser calendarizada:

- apos cada exuvia real, auditar tamanho e leitura da versao ativa;
- manter a casca recem-abandonada no repo enquanto ela for ancora operacional;
- quando houver duas cascas frias acumuladas, propor descida da mais antiga ao
  glacier com indice frio e ponteiro de consulta;
- nenhuma descida ao glacier acontece sem hearback humano e cross-audit.
