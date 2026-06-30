---
path: core/dispatch-spec.md
id-global: 20260616-003203-codex-dispatch-spec
titulo: Dispatch auto-declarante
status: accepted
temperatura: quente
created_at: 2026-06-16T00:32:03-03:00
---

# Dispatch Auto-Declarante

Esta spec define o artefato `.hbn/dispatch/NNNN-*.md`: o despacho que entrega
uma onda ao implementador ou auditor sem depender de memoria solta do chat. O
front matter declara o contrato mecanico; o corpo contem texto colavel para a
execucao humana/IA.

## Campos Normativos

Todo dispatch deve declarar, no front matter YAML:

- `dispatch_id`: id estavel do despacho, igual ao basename sem `.md`.
- `readback_id`: readback autorizado que governa o escopo da onda.
- `token_fp`: prefixo de 8 hex de `bastao_token_sha256` no STATE.
- `human_authorization`: autorizacao humana nao vazia.
- `scope.files_allowed`: lista nao vazia de paths permitidos.
- `scope.files_forbidden`: lista de paths proibidos, vazia quando nao houver.
- `action_plan`: lista nao vazia de passos executaveis.

Campos opcionais conhecidos incluem `path`, `schema_version`, `agent_id`,
`role`, `status`, `created_at`, `summary`, `invariants` e
`validation_commands`. O schema executavel e `schemas/dispatch.schema.json`.

## Semantica Auto-Declarante

O dispatch e auto-declarante porque carrega o readback, o fingerprint do
bastao, o escopo positivo/negativo e o plano. Um leitor deve conseguir
confrontar o arquivo com o STATE e os readbacks versionados sem buscar contexto
externo para saber se o despacho ainda e o ativo e autorizado.

`readback_id` nao e apenas decorativo: G-DSP-INT exige que ele exista em
`.hbn/readbacks/<readback_id>.json` e que seja o `readback_ativo` do STATE
staged/HEAD conforme o modo de execucao do guard. `token_fp` deve bater com os
8 primeiros caracteres de `bastao_token_sha256`. `human_authorization` deve ser
texto nao vazio.

## Invariante Zsh-Safe

O corpo colavel de um dispatch nao pode conter linha iniciada por `#`. A regra
e deliberadamente mecanica: ao colar o bloco em zsh, uma linha de comentario
pode esconder comando, marcador ou instrucao que nao foi executada. Texto
explicativo deve ficar no front matter, em listas sem `#`, ou em prosa que nao
comece por esse caractere.

G-DSP-FMT valida a forma e esta regra zsh-safe. G-DSP-INT valida a coerencia
com o readback ativo e o STATE. Ambos sao bloqueantes quando entram no runner.
