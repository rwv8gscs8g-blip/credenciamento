---
titulo: Guards canônicos do protocolo — conjunto executável de governança
status: accepted
temperatura: quente
data: 2026-06-10
autoria: claude-fable-5 (arquiteto useHBN, corrente C3)
origem: promovido de Credenciamento/scripts/hbn-guards/ (doutrina viva, batida em campo nos incidentes de 2026-05-02 e 2026-05-24)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
---

# guards/ — o conjunto canônico

Promoção 1:1 dos guards maduros do Credenciamento, com TRÊS diffs e só três:

1. Headers de path (`scripts/hbn-guards/` → `guards/`).
2. `lib/common.sh` ganha `guard_diff_files()`: staged no pre-commit local,
   range `HBN_DIFF_BASE...HEAD` em CI (o Shield exporta a base). Os guards
   `forbid-env-files`, `forbid-legacy-paths` e `assert-scope-lock` usam o helper.
3. `assert-canonical-root` pula em `CI=true` — raiz canônica é invariante da
   máquina do operador, não do runner.

Conjunto (ordem do runner): `assert-canonical-root` → `forbid-tmp-worktree` →
`forbid-env-files` → `forbid-legacy-paths` → `assert-scope-lock` →
`validate-dispatch` → `assert-dispatch-integrity`.
Runner: `bash guards/hbn-guards-runner.sh` (pre-commit local e CI).

Config: `.hbn/canonical-root` (1 linha, raiz física esperada do repo),
`.hbn/active-version` (1 linha: `.` ou `versao_X_Y_Z`) e
`.hbn/forbidden-paths.txt` (opcional; sem ele o guard de legacy libera).
`guards/lib/common.sh::get_canonical_root()` resolve a raiz operacional da
versão ativa; com `.` o comportamento permanece igual ao da raiz atual.

Hooks locais em `.git/hooks/pre-commit` e `.git/hooks/commit-msg` são shims
finos com marcador `HBN_HOOK_SHIM_VERSION=M-A-20260614`. Eles leem
`.hbn/active-version` e delegam ao runner/guards da versão ativa. O runner faz
pre-flight e bloqueia se os hooks estiverem ausentes ou desatualizados.
Bypass de emergência: `HBN_GUARDS_BYPASS=1` + `[bypass-hbn-guards]` na
mensagem + nota em `.hbn/bypasses/` — nunca para raiz canônica.

## Meta-paths

`assert-scope-lock` dispensa `scope.files_allowed` apenas para meta-paths de
coordenacao com tipo e nome controlados: arquivos `.json` ou `.md` cujo
basename siga ADR-025 (`AAAAMMDD-HHMMSS-<agente>-<slug>.{json,md}`),
hearbacks do readback ativo (`.hbn/hearbacks/NNNN-*.{json,md}`), e
nomes-endereco conhecidos como `.hbn/relay/INDEX.md`. Qualquer outro arquivo em
`.hbn/messages/`, `.hbn/bypasses/` ou `.hbn/hearbacks/` cai no scope-lock
normal e precisa estar declarado em `scope.files_allowed`.

Symlinks sao proibidos em qualquer path governado avaliado pelo
`assert-scope-lock`: toda entrada staged com modo git `120000` e bloqueada antes
do scope normal ou da dispensa de meta-path, seja em `.hbn/**`, `guards/`,
`core/`, `src/`, `methodology/`, `REGISTRY.md` ou afins. A mesma regra e
aplicada em CI contra a arvore `HEAD`. Hardlink e tratado pelo Git como arquivo
regular (`100644`), sem semantica de link no objeto versionado, e fica fora do
escopo desta regra.

## Zona livre curada

`assert-zona-livre` (G-ZONA-LIVRE) aplica deny-by-default sobre
`docs/brainstorm/**`. Qualquer arquivo staged nessa area exige que o readback
ativo apontado por `.hbn/relay/STATE.md` (`readback_ativo`) contenha
`"zona_livre_curada": true` e `"zona_livre_nota"` com texto nao-vazio.

O guard le o STATE e o readback do indice local, ou `HEAD` em CI. Se o STATE
nao aponta para um readback valido, se o readback esta ausente/ilegivel, ou se
os marcadores de curadoria faltam, o commit bloqueia: zona livre so entra com
curadoria humana explicita no readback (knowledge 0024).

## Area temporaria /scratch/

`scratch/` e a area efemera local do repo. O Git ignora `/scratch/` e versiona
somente `scratch/README.md` como contrato de uso. A area nao aceita segredos,
PII, credenciais, fixtures permanentes nem artefatos de entrega.

`assert-scratch-lock` (G-SCRATCH-LOCK) falha se qualquer path staged sob
`scratch/` nao for exatamente `scratch/README.md`. Tambem falha fechado se a
versao ativa nao resolve, antes de converter paths do diff.

`assert-scratch-symlink` (G-SCRATCH-SYMLINK) falha se qualquer entrada staged
sob `scratch/` tiver modo Git `120000`, fechando o vetor de symlink escapando da
area efemera. Tambem falha fechado se a versao ativa nao resolve.

`assert-scratch-ignore` (G-SCRATCH-IGNORE) roda quando `.gitignore` esta staged
e exige que o blob staged preserve as linhas `/scratch/` e
`!/scratch/README.md`. Tambem falha fechado se a versao ativa nao resolve.

Conforme knowledge 0021 (Credenciamento): em sandbox o guard é informativo;
conclusivo no Terminal do operador. O CI (Shield, `.github/workflows/hbn-shield.yml`)
é o terceiro ponto de verificação: guards + pytest verdes como portão de merge.

O CLI Python (`src/usehbn/`) permanece implementação de REFERÊNCIA — os guards
não dependem dele (decisão Q3; `assert-scope-lock` e os guards de dispatch
usam python3 local para parse/validacao; qualquer python3 serve).

## Dispatch auto-declarante

`validate-dispatch` (G-DSP-FMT) valida cada arquivo staged em
`.hbn/dispatch/*.md` contra `schemas/dispatch.schema.json`, usando o front
matter YAML como projeção estruturada. Tambem bloqueia o corpo colavel com linha
iniciada por `#`, preservando a cerimonia zsh-safe.

`assert-dispatch-integrity` (G-DSP-INT) confere que o `readback_id` declarado
existe em `.hbn/readbacks/<readback_id>.json`, que ele e o `readback_ativo` do
STATE, que `token_fp` bate com os 8 primeiros hex de `bastao_token_sha256`, e
que `human_authorization` nao esta vazio. Ambos leem o índice local ou `HEAD`
em CI; a working tree solta nao conta.

## Knowledge index vivo

`assert-knowledge-index` (G-KNOW-INDEX) confere que cada arquivo
`.hbn/knowledge/*.md`, exceto `.hbn/knowledge/INDEX.md`, aparece citado pelo
basename como token inteiro no `INDEX.md`; substring nao conta. O guard tambem
falha quando o INDEX cita `NNNN-*.md` inexistente no índice Git local ou em
`HEAD` no CI. A working tree solta nao conta: entrada nova de knowledge e linha
do INDEX precisam entrar no mesmo commit.

## Porta da frente

`assert-frontdoor` (G-FRONTDOOR) confere `core/role-cards.md` como porta da
frente minima para qualquer IA que assuma o bastao. O guard falha fechado se o
arquivo estiver ausente ou ilegivel no indice/HEAD, se passar de 140 linhas ou
8192 bytes (anti-monolito), se a `PARTE A` listar mais de 6 itens, se houver
linha de read-list sem marcador valido seguido de espaco, ou se um path
concreto citado na read-list nao existir no indice/HEAD. A working tree solta
nao conta: o blob validado e o que entra no commit local, ou `HEAD` em CI.

## Exceção rastreável

`assert-exception-traceable` (G-EXC) valida trailers de commit-msg lendo o texto
da mensagem em curso. Em CI, desde a faxina 0027, aplica a mesma regra sobre a
mensagem bruta de cada commit (`git log --format=%B`), em vez do parser nativo
`%(trailers)`. Desde W2/readback 0034, os trailers precisam estar no ultimo
paragrafo nao-vazio da mensagem; linhas `HBN-*` em prosa no corpo nao contam.
