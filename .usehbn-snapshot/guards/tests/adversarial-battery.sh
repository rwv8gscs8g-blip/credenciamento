#!/usr/bin/env bash
# =============================================================================
# guards/tests/adversarial-battery.sh
# path: guards/tests/adversarial-battery.sh · id-global: 20260611-162102-fable5-bateria-adversarial
# BATERIA ADVERSARIAL (onda 0006 I-12 — critério de aceite mecânico da onda,
# ADR-020): tenta CADA burla documentada nos cross-audits 0036/0037 e na
# consolidação 20260611-131310 e EXIGE que o guard correspondente BLOQUEIE.
# Qualquer burla passando = bateria vermelha = onda reprovada.
#
# É também a semente da auditoria Glasswing periódica (desenho §6.4): a cada
# N ondas, uma janela adversarial de família ≠ implementador tenta burlar os
# guards; toda burla nova achada vira linha permanente AQUI.
#
# Uso: bash guards/tests/adversarial-battery.sh   (exit 0 = todas bloqueadas)
# Saída: tabela BURLA × GUARD × RESULTADO.
# =============================================================================
set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARDS_DIR="$(dirname "$TESTS_DIR")"
REPO_ROOT="$(cd "$GUARDS_DIR/.." && pwd)"
unset HBN_GUARDS_BYPASS GLASSWING_BYPASS HBN_DIFF_BASE CI GITHUB_ACTIONS 2>/dev/null || true

SUITE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/hbn-adv.XXXXXX")"
export TMPDIR="$SUITE_TMP"
trap 'rm -rf "$SUITE_TMP" "$TESTS_DIR"/adv-cr.* 2>/dev/null || true; true' EXIT INT TERM

FALHAS=0
ROWS=()
try_burla() { # <descricao> <guard> <rc-obtido>  (esperado: rc != 0 = BLOQUEADA)
    local desc="$1" guard="$2" rc="$3" res
    if [[ "$rc" -ne 0 ]]; then
        res="BLOQUEADA ✓"
    else
        res="PASSOU ✗ (FALHA DA ONDA)"
        FALHAS=$((FALHAS + 1))
    fi
    ROWS+=("$(printf '%-52s | %-8s | %s' "$desc" "$guard" "$res")")
}

mk_repo() { # repo git mínimo
    local d; d="$(mktemp -d)"
    ( cd "$d" && git init -q && git config user.email a@b && git config user.name a && mkdir -p .hbn && echo "." > .hbn/active-version ) >/dev/null 2>&1
    echo "$d"
}

# B1 — nome SERIAL novo em série de evento (o caso 0036/0037)
d="$(mk_repo)"
( cd "$d" && mkdir -p .hbn/results && echo x > .hbn/results/0099-parecer-burlado.md && git add -A ) >/dev/null 2>&1
try_burla "B1 nome serial novo em .hbn/results/" "G-NUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-parallel-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B2 — created_at em UTC na linha nova do REGISTRY
d="$(mk_repo)"
( cd "$d" && echo x > nota.md && printf '| id | a | t | T | s | created_at |\n|---|---|---|---|---|---|\n' > REGISTRY.md && git add -A && git commit -qm i \
  && printf '| 20260611-101010-agente-x | nota.md | doc | frio | — | 2026-06-11T10:10:10Z |\n' >> REGISTRY.md && git add REGISTRY.md ) >/dev/null 2>&1
try_burla "B2 created_at UTC (Z) no REGISTRY"            "G-NUM"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-parallel-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B3 — CI=true em commit local (o bypass do readback 0005)
d="$(mktemp -d -p "$TESTS_DIR" adv-cr.XXXXXX)"
( cd "$d" && git init -q && mkdir .hbn && echo "." > .hbn/active-version && pwd -P > .hbn/canonical-root ) >/dev/null 2>&1
try_burla "B3 CI=true local (sem CI real)"               "G-CR"    "$( ( cd "$d" && CI=true bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B4 — HBN_GUARDS_BYPASS=1 sem nota staged (Glasswing como burla)
d="$(mk_repo)"
( cd "$d" && git commit -q --allow-empty -m i && echo "SECRET=x" > .env && git add .env ) >/dev/null 2>&1
try_burla "B4 bypass env sem nota em .hbn/bypasses/"     "comuns"  "$( ( cd "$d" && HBN_GUARDS_BYPASS=1 bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B5 — .hbn órfão FUNDO (5 níveis; o falso negativo do maxdepth 4)
r="$(mktemp -d)"
mkdir -p "$r/a/b/c/d/.hbn"
try_burla "B5 .hbn órfão a 5 níveis de profundidade"     "G-STRAY" "$( ( HBN_SCAN_ROOT="$r" bash "$GUARDS_DIR/assert-no-stray-hbn.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$r"

# B6 — SYMLINK chamado .hbn (invisível ao find -type d)
r="$(mktemp -d)"
mkdir -p "$r/alvo" "$r/proj" && ln -s "$r/alvo" "$r/proj/.hbn"
try_burla "B6 symlink .hbn órfão"                        "G-STRAY" "$( ( HBN_SCAN_ROOT="$r" bash "$GUARDS_DIR/assert-no-stray-hbn.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$r"

# B7 — esconder .hbn sob pasta 'backups2' (fora da allowlist)
r="$(mktemp -d)"
mkdir -p "$r/backups2/oculto/.hbn"
try_burla "B7 .hbn escondido sob backups2/"              "G-STRAY" "$( ( HBN_SCAN_ROOT="$r" bash "$GUARDS_DIR/assert-no-stray-hbn.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$r"

# B8 — SCAN_ROOT inválido (fail-open virava bypass ambiental)
try_burla "B8 HBN_SCAN_ROOT apontando para o nada"       "G-STRAY" "$( ( HBN_SCAN_ROOT=/nao/existe bash "$GUARDS_DIR/assert-no-stray-hbn.sh" >/dev/null 2>&1 ); echo $? )"

# B9 — scope.files_allowed VAZIO em safe_track (caso readback 0004)
d="$(mk_repo)"
( cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/readbacks docs \
  && printf '{"readback_id":"0001-t","track":"safe_track","human_status":"confirmed","scope":{"files_allowed":[],"files_forbidden":[]}}\n' > .hbn/readbacks/0001-t.json \
  && git add .hbn/readbacks/0001-t.json && git commit -qm readback \
  && echo x > docs/x.md && git add docs/x.md ) >/dev/null 2>&1
try_burla "B9 scope vazio em safe_track"                 "G-SCO"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B10 — implementador escalado como auditor de si mesmo
d="$(mk_repo)"
( cd "$d" && mkdir -p .hbn/relay \
  && printf -- '---\natribuicao:\n  implementador: ego-1\n  auditores: [ego-1, outro-2]\n---\n' > .hbn/relay/STATE.md \
  && git add -A && git commit -qm i ) >/dev/null 2>&1
try_burla "B10 implementador == auditor (groupthink)"    "G-FAM"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-role-family.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B11 — hearback forjado por IA SEM assinatura, com chave de operador registrada
kd="$(mktemp -d)"
ssh-keygen -q -t ed25519 -N "" -f "$kd/op" >/dev/null 2>&1
mkdir -p "$kd/ops" && cp "$kd/op.pub" "$kd/ops/op.pub"
d="$(mk_repo)"
( cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/hearbacks \
  && printf '{"status":"confirmed","signed_by":"Humano Forjado"}\n' > .hbn/hearbacks/9999-forjado.json \
  && git add .hbn/hearbacks/9999-forjado.json ) >/dev/null 2>&1
try_burla "B11 hearback sem assinatura (chave registrada)" "G-HRB"  "$( ( cd "$d" && HBN_OPERATORS_DIR="$kd/ops" bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d" "$kd"

# B12 — hearback staged JUNTO com a obra que ele autoriza
d="$(mk_repo)"
( cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/hearbacks docs \
  && printf '{"status":"confirmed"}\n' > .hbn/hearbacks/9998-junto.json \
  && echo obra > docs/obra.md && git add -A ) >/dev/null 2>&1
try_burla "B12 hearback no mesmo commit da obra"         "G-HRB"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B13 — exceção F-01 (impl==agente do readback) SEM os sinais exigidos
d="$(mk_repo)"
( cd "$d" && mkdir -p .hbn/relay .hbn/readbacks \
  && printf '{"readback_id":"0007-t","agent_id":"ego-1","track":"safe_track","human_status":"confirmed"}\n' > .hbn/readbacks/0007-t.json \
  && printf -- '---\nsinais_abertos:\n  - "tudo normal"\natribuicao:\n  implementador: ego-1\n  auditores: [outro-2]\n---\n' > .hbn/relay/STATE.md \
  && git add -A -f && git commit -qm i ) >/dev/null 2>&1
try_burla "B13 exceção impl==agente sem os 4 sinais"     "G-EXC"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-exception-traceable.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B14 — posse forjada: arquivo .git/hbn-baton-token com token ERRADO e
# fingerprint correto copiado do log (G-TOK v2 — replay do fingerprint
# público NÃO abre o hook sem o arquivo de token legítimo)
d="$(mk_repo)"
( cd "$d" && mkdir -p .hbn/relay \
  && HASH_LEGIT="$(printf '%s' token-legitimo | sha256sum | awk '{print $1}')" \
  && printf -- '---\nbastao_token_sha256: %s\n---\n' "$HASH_LEGIT" > .hbn/relay/STATE.md \
  && git add -A && git commit -qm i \
  && printf '%s\n' token-roubado > .git/hbn-baton-token \
  && printf 'feat: x\n\nHBN-Token-FP: %s\n' "$(printf '%s' "$HASH_LEGIT" | cut -c1-8)" > msg.txt ) >/dev/null 2>&1
try_burla "B14 arquivo de token local ERRADO + FP do log" "G-TOK"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-baton-token.sh" "$d/msg.txt" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B15 — conflito de merge no ponteiro de versão ativa deve falhar fechado
d="$(mktemp -d -p "$TESTS_DIR" adv-cr-active.XXXXXX)"
(
  cd "$d" && git init -q && mkdir -p .hbn versao_1_0_0 \
  && pwd -P > .hbn/canonical-root \
  && printf '<<<<<<< ours\n.\n=======\nversao_1_0_0\n>>>>>>> theirs\n' > .hbn/active-version
) >/dev/null 2>&1
try_burla "B15 active-version com conflito de merge"    "G-CR"    "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B16 — auto-emenda de escopo: readback estende files_allowed e usa o delta no
# mesmo commit (regressao do drible ca69ef9).
d="$(mk_repo)"
(
  cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/readbacks \
  && cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope": {
    "files_allowed": [".hbn/readbacks/0001-t.json", "docs/vigente/**"],
    "files_forbidden": []
  }
}
EOF
  git add .hbn/readbacks/0001-t.json && git commit -qm readback \
  && cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope_extension": {
    "human": "Tester Humano",
    "evidence": "autoriza somente extensao isolada",
    "created_at": "2026-06-15T10:43:09-03:00",
    "allowed_delta": ["docs/novo/**"]
  },
  "scope": {
    "files_allowed": [".hbn/readbacks/0001-t.json", "docs/vigente/**", "docs/novo/**"],
    "files_forbidden": []
  }
}
EOF
  mkdir -p docs/novo && echo x > docs/novo/parecer.md \
  && git add .hbn/readbacks/0001-t.json docs/novo/parecer.md
) >/dev/null 2>&1
try_burla "B16 auto-emenda files_allowed + uso"          "G-SCO"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B17 — smuggling por meta-path: payload de tipo/nome arbitrario em caminhos de
# coordenacao nao pode ser auto-permitido pelo scope-lock.
d="$(mk_repo)"
(
  cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/readbacks .hbn/bypasses .hbn/messages \
  && cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope": {
    "files_allowed": ["docs/**"],
    "files_forbidden": []
  }
}
EOF
  git add .hbn/readbacks/0001-t.json && git commit -qm readback \
  && printf 'echo payload\n' > .hbn/bypasses/payload.sh \
  && printf 'print(1)\n' > .hbn/messages/exploit.py \
  && git add .hbn/bypasses/payload.sh .hbn/messages/exploit.py
) >/dev/null 2>&1
try_burla "B17 smuggling meta-path tipo/nome arbitrario" "G-SCO"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B18 — symlink com basename ADR-025 em meta-path governado nao pode ser
# auto-permitido pelo scope-lock.
d="$(mk_repo)"
(
  cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/readbacks .hbn/messages \
  && cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope": {
    "files_allowed": ["docs/**"],
    "files_forbidden": []
  }
}
EOF
  git add .hbn/readbacks/0001-t.json && git commit -qm readback \
  && printf 'echo payload\n' > payload.sh \
  && ln -s ../../payload.sh .hbn/messages/20260615-120000-codex-handoff-x.md \
  && git add .hbn/messages/20260615-120000-codex-handoff-x.md
) >/dev/null 2>&1
try_burla "B18 symlink ADR-025 em meta-path governado"  "G-SCO"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B19 — symlink em path governado nao-.hbn com nome que casa files_allowed
# permissivo tambem deve ser bloqueado.
d="$(mk_repo)"
(
  cd "$d" && git commit -q --allow-empty -m i && mkdir -p .hbn/readbacks guards \
  && cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope": {
    "files_allowed": ["guards/**"],
    "files_forbidden": []
  }
}
EOF
  git add .hbn/readbacks/0001-t.json && git commit -qm readback \
  && printf 'echo payload\n' > payload.sh \
  && ln -s ../payload.sh guards/falso-guard.sh \
  && git add guards/falso-guard.sh
) >/dev/null 2>&1
try_burla "B19 symlink em guards/ permitido por escopo" "G-SCO"   "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B20 — dispatch com token_fp diferente do prefixo do STATE.
mk_dispatch_repo() {
    local d; d="$(mktemp -d)"
    (
      cd "$d"
      git init -q
      git config user.email a@b
      git config user.name a
      mkdir -p .hbn/relay .hbn/readbacks .hbn/dispatch schemas
      echo "." > .hbn/active-version
      cp "$REPO_ROOT/schemas/dispatch.schema.json" schemas/dispatch.schema.json
      cat > .hbn/relay/STATE.md <<'EOF'
---
bastao_token_sha256: 34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf
readback_ativo: ".hbn/readbacks/0025-s2-dispatch-auto-declarante.json"
---
EOF
      cat > .hbn/readbacks/0025-s2-dispatch-auto-declarante.json <<'EOF'
{"readback_id":"0025-s2-dispatch-auto-declarante","track":"safe_track","human_status":"confirmed","scope":{"files_allowed":[".hbn/dispatch/0025-s2-dispatch-auto-declarante.md"],"files_forbidden":[]}}
EOF
      git add -A
      git commit -qm init
    ) >/dev/null 2>&1
    echo "$d"
}
write_dispatch_adv() {
    local d="$1" rb="${2:-0025-s2-dispatch-auto-declarante}" fp="${3:-34a7f2f9}" body="${4:-Executar despacho sem comentario.}"
    (
      cd "$d" && cat > .hbn/dispatch/0025-s2-dispatch-auto-declarante.md <<EOF
---
dispatch_id: 0025-s2-dispatch-auto-declarante
path: .hbn/dispatch/0025-s2-dispatch-auto-declarante.md
readback_id: ${rb}
token_fp: ${fp}
human_authorization: Mauricio (Luis Mauricio Junqueira Zanin)
scope:
  files_allowed:
    - .hbn/dispatch/0025-s2-dispatch-auto-declarante.md
  files_forbidden:
    - main
action_plan:
  - Executar S2
---
${body}
EOF
      git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md
    ) >/dev/null 2>&1
}
d="$(mk_dispatch_repo)"
write_dispatch_adv "$d" "0025-s2-dispatch-auto-declarante" "deadbeef"
try_burla "B20 dispatch token_fp divergente do STATE"  "G-DSP-INT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-dispatch-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B21 — dispatch declarando readback inexistente/nao-ativo.
d="$(mk_dispatch_repo)"
write_dispatch_adv "$d" "0099-inexistente" "34a7f2f9"
try_burla "B21 dispatch readback inexistente/nao-ativo" "G-DSP-INT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-dispatch-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B22 — corpo colavel quebra zsh-safe com linha iniciada por '#'.
d="$(mk_dispatch_repo)"
write_dispatch_adv "$d" "0025-s2-dispatch-auto-declarante" "34a7f2f9" "# comentario que nao pode ser colado"
try_burla "B22 dispatch com linha # no corpo colavel" "G-DSP-FMT" "$( ( cd "$d" && bash "$GUARDS_DIR/validate-dispatch.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B23 — G-EXC em modo CI nao pode aceitar commit que termina com HBN-Token-FP
# mas omite HBN-Human-Authorization.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/relay .hbn/readbacks docs
  cat > .hbn/readbacks/0007-t.json <<'EOF'
{"readback_id":"0007-t","agent_id":"ego-1","authorization":{"human":"Tester Humano","evidence":"ordem em chat 2026-06-16"},"track":"safe_track","human_status":"confirmed","scope":{"files_allowed":["**"],"files_forbidden":[]}}
EOF
  cat > .hbn/relay/STATE.md <<'EOF'
---
sinais_abertos:
  - "🔴 EXCEÇÃO F-01 ATIVA — PROPOSED_UNTIL_CROSS_AUDIT"
atribuicao:
  implementador: ego-1
  auditores: [outro-2]
---
EOF
  git add -A -f
  git commit -qm init
) >/dev/null 2>&1
base="$(git -C "$d" rev-parse HEAD)"
(
  cd "$d"
  echo payload > docs/b23.md
  git add docs/b23.md
  git commit -qm $'feat: b23\n\nHBN-Readback: 0007\nHBN-Token-FP: 34a7f2f9'
) >/dev/null 2>&1
try_burla "B23 CI trailer token sem autorizacao humana" "G-EXC" "$( ( cd "$d" && HBN_DIFF_BASE="$base" bash "$GUARDS_DIR/assert-exception-traceable.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B24 — knowledge nova sem linha no INDEX nao pode entrar.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/knowledge
  cat > .hbn/knowledge/INDEX.md <<'EOF'
# Knowledge Index

| Entrada | Uso |
|---|---|
| `0001-base.md` | Base testada. |
EOF
  echo "# Base" > .hbn/knowledge/0001-base.md
  git add -A
  git commit -qm init
  echo "# Burla" > .hbn/knowledge/9999-burla-sem-index.md
  git add .hbn/knowledge/9999-burla-sem-index.md
) >/dev/null 2>&1
try_burla "B24 knowledge nova ausente do INDEX" "G-KNOW" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-knowledge-index.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B25 — role-cards inflado e read-list estourada nao pode entrar.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p core
  cat > core/role-cards.md <<'EOF'
# Porta Da Frente De Papeis

## PARTE A - READ-LIST DA PORTA DA FRENTE

1. `.hbn/relay/STATE.md`
2. O readback ativo apontado no STATE.
3. `core/role-cards.md`
4. `.hbn/knowledge/0001-comandos-atomicos-copiaveis.md`
5. `.hbn/knowledge/0002-entrega-operacional-minimalista.md`
6. `.hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md`
7. `docs/tentativa-de-monolito.md`

## PARTE B - TRES CARTOES
EOF
  for i in {1..135}; do echo "linha inflada $i"; done >> core/role-cards.md
  git add core/role-cards.md
) >/dev/null 2>&1
try_burla "B25 role-cards inflado/read-list >6" "G-FRONT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-frontdoor.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B26 — arquivo staged em scratch/ nao pode entrar no historico.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p scratch
  echo segredo > scratch/segredo.txt
  git add scratch/segredo.txt
) >/dev/null 2>&1
try_burla "B26 arquivo staged em scratch/" "G-SCRATCH-LOCK" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scratch-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B27 — symlink staged em scratch/ nao pode escapar da area efemera.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p scratch
  ln -s ../core scratch/link
  git add scratch/link
) >/dev/null 2>&1
try_burla "B27 symlink staged em scratch/" "G-SCRATCH-SYMLINK" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scratch-symlink.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B28 — .gitignore staged sem /scratch/ remove a protecao da area efemera.
d="$(mk_repo)"
(
  cd "$d"
  printf '!/scratch/README.md\n' > .gitignore
  git add .gitignore
) >/dev/null 2>&1
try_burla "B28 .gitignore staged sem /scratch/" "G-SCRATCH-IGNORE" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scratch-ignore.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B29 — INDEX nao pode satisfazer 0002 via substring em 10002 nem manter
# ponteiro morto para NNNN-*.md inexistente.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/knowledge
  cat > .hbn/knowledge/INDEX.md <<'EOF'
# Knowledge Index

| Entrada | Uso |
|---|---|
| `0001-base.md` | Base testada. |
| `10002-nova.md` | Substring que antes satisfazia 0002-nova.md. |
| `9999-ponteiro-morto.md` | Ponteiro morto. |
EOF
  echo "# Base" > .hbn/knowledge/0001-base.md
  git add -A
  git commit -qm init
  echo "# Nova" > .hbn/knowledge/0002-nova.md
  git add .hbn/knowledge/0002-nova.md
) >/dev/null 2>&1
try_burla "B29 knowledge substring + ponteiro morto" "G-KNOW" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-knowledge-index.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B30 — linha unica densa abaixo do teto de linhas antigo nao pode passar.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p core
  {
    echo "# Porta Da Frente De Papeis"
    printf 'x%.0s' {1..9000}
    echo
    echo "## PARTE A - READ-LIST DA PORTA DA FRENTE"
    echo "1. \`.hbn/relay/STATE.md\`"
    echo "## PARTE B - TRES CARTOES"
  } > core/role-cards.md
  mkdir -p .hbn/relay
  echo "---" > .hbn/relay/STATE.md
  git add core/role-cards.md .hbn/relay/STATE.md
) >/dev/null 2>&1
try_burla "B30 frontdoor linha unica densa" "G-FRONT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-frontdoor.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B30 — path concreto inexistente na read-list tambem deve bloquear.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p core .hbn/relay .hbn/knowledge
  cat > core/role-cards.md <<'EOF'
# Porta Da Frente De Papeis

## PARTE A - READ-LIST DA PORTA DA FRENTE

1. `.hbn/relay/STATE.md`
2. O readback ativo apontado no STATE.
3. `core/role-cards.md`
4. `core/inexistente-na-read-list.md`

## PARTE B - TRES CARTOES
EOF
  echo "---" > .hbn/relay/STATE.md
  git add core/role-cards.md .hbn/relay/STATE.md
) >/dev/null 2>&1
try_burla "B30 frontdoor path inexistente" "G-FRONT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-frontdoor.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B31 — prosa no corpo com linhas HBN-* nao substitui trailers reais no ultimo
# paragrafo.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/relay .hbn/readbacks
  cat > .hbn/readbacks/0007-t.json <<'EOF'
{"readback_id":"0007-t","agent_id":"ego-1","authorization":{"human":"Tester Humano","evidence":"ordem em chat 2026-06-16"},"track":"safe_track","human_status":"confirmed","scope":{"files_allowed":["**"],"files_forbidden":[]}}
EOF
  cat > .hbn/relay/STATE.md <<'EOF'
---
sinais_abertos:
  - "🔴 EXCEÇÃO F-01 ATIVA — PROPOSED_UNTIL_CROSS_AUDIT"
atribuicao:
  implementador: ego-1
  auditores: [outro-2]
---
EOF
  git add -A -f
  git commit -qm init
  cat > msg-b31.txt <<'EOF'
feat: b31

Corpo menciona trailers antigos:
HBN-Readback: 0007
HBN-Human-Authorization: ordem-tester

Resumo final sem trailers reais.
EOF
) >/dev/null 2>&1
try_burla "B31 prosa HBN-* no corpo sem trailers finais" "G-EXC" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-exception-traceable.sh" "$d/msg-b31.txt" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B32 — sem active-version, path staged em scratch/ nao pode sumir por falha de
# mapeamento; G-SCRATCH-LOCK falha fechado.
d="$(mk_repo)"
(
  cd "$d"
  rm -f .hbn/active-version
  mkdir -p scratch
  echo segredo > scratch/segredo.txt
  git add scratch/segredo.txt
) >/dev/null 2>&1
try_burla "B32 active-version ausente + scratch staged" "G-SCRATCH-LOCK" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-scratch-lock.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B33 — docs/brainstorm/* staged sem curadoria explicita no readback ativo nao
# pode entrar como zona livre selada por inercia.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/relay .hbn/readbacks docs/brainstorm
  cat > .hbn/relay/STATE.md <<'EOF'
---
readback_ativo: ".hbn/readbacks/0001-zona.json"
---
EOF
  printf '{"readback_id":"0001-zona"}\n' > .hbn/readbacks/0001-zona.json
  git add .hbn/relay/STATE.md .hbn/readbacks/0001-zona.json
  git commit -qm init
  echo ideia > docs/brainstorm/b33-sem-curadoria.md
  git add docs/brainstorm/b33-sem-curadoria.md
) >/dev/null 2>&1
try_burla "B33 docs/brainstorm sem curadoria" "G-ZONA" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-zona-livre.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B34-B37 — G-AUDITOR-ID: autoidentificacao do auditor deve falhar fechado.
mk_auditor_id_repo() {
  local d; d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p guards/data .hbn/results
    cp "$REPO_ROOT/guards/data/auditor-families.txt" guards/data/auditor-families.txt
    git add guards/data/auditor-families.txt
    git commit -qm auditor-map
  ) >/dev/null 2>&1
  echo "$d"
}
write_auditor_id_result() { # <repo> <apelido-arquivo> <onda> <sou-line|NONE>
  local d="$1" file_alias="$2" wave="$3" sou_line="$4" f
  f=".hbn/results/20260617-160100-${file_alias}-cross-ia-${wave}.md"
  (
    cd "$d"
    mkdir -p .hbn/results
    {
      echo "---"
      echo "path: ${f}"
      echo "---"
      echo "APROVA_0047: SIM"
      if [[ "$sou_line" != "NONE" ]]; then
        echo "$sou_line"
      fi
      echo ""
      echo "Parecer adversarial."
    } > "$f"
    git add "$f"
  ) >/dev/null 2>&1
}

d="$(mk_auditor_id_repo)"
write_auditor_id_result "$d" "grok" "b34-sem-sou" "NONE"
try_burla "B34 result sem SOU canonico" "G-AUD-ID" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-auditor-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_auditor_id_repo)"
write_auditor_id_result "$d" "grok" "b35-familia-fora-mapa" "SOU: grok · familia Klingon · papel auditor"
try_burla "B35 familia fora do mapa canonico" "G-AUD-ID" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-auditor-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_auditor_id_repo)"
write_auditor_id_result "$d" "grok" "b36-apelido-divergente" "SOU: antigravity · familia Google · papel auditor"
try_burla "B36 apelido arquivo != SOU" "G-AUD-ID" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-auditor-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_auditor_id_repo)"
write_auditor_id_result "$d" "cursor" "b37-familia-incoerente" "SOU: cursor · familia Google · papel auditor"
try_burla "B37 apelido/familia incoerentes" "G-AUD-ID" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-auditor-id.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B38 — mislabel de arvore: artefato nasce estavel sem evento append-only de
# promocao rastreavel.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/relay docs
  cat > .hbn/relay/STATE.md <<'EOF'
---
proxima_acao: "testar B38"
---
EOF
  cat > REGISTRY.md <<'EOF'
| id | artefato (path) | tipo | temperatura | arvore | superseded_by | created_at |
|---|---|---|---|---|---|---|
EOF
  git add .hbn/relay/STATE.md REGISTRY.md
  git commit -qm init
  echo "| 20260101-01 | docs/b38-mislabel.md | doc | quente | estavel | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
  git add REGISTRY.md
) >/dev/null 2>&1
try_burla "B38 arvore estavel sem promocao" "G-ARVORE" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-arvore-label.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B39 — G-TRAILERS independe de implementador no STATE. Mesmo com
# implementador=null, commit governado com trailers nao-contiguos deve bloquear.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p .hbn/relay guards
  cat > .hbn/relay/STATE.md <<'EOF'
---
atribuicao:
  implementador: null
---
EOF
  git add -A -f
  git commit -qm init
  echo payload > guards/b39.sh
  git add guards/b39.sh
  cat > msg-b39.txt <<'EOF'
feat: b39

HBN-Readback: 0051
HBN-Human-Authorization: Mauricio

HBN-Token-FP: 34a7f2f9
EOF
) >/dev/null 2>&1
try_burla "B39 impl=null + trailers nao-contiguos" "G-TRAIL" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-trailers-contiguous.sh" "$d/msg-b39.txt" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B40 — selagem com diversidade insuficiente: apenas uma familia distinta
# diferente da familia do implementador com APROVA SIM nao pode selar.
d="$(mk_repo)"
(
  cd "$d"
  mkdir -p guards/data .hbn/readbacks .hbn/results
  cp "$REPO_ROOT/guards/data/auditor-families.txt" guards/data/auditor-families.txt
  cat > .hbn/readbacks/0099-diversity-fixture.json <<'EOF'
{"readback_id":"0099-diversity-fixture","implementador_id":"codex","track":"safe_track","human_status":"confirmed","scope":{"files_allowed":[".hbn/results/*.md"],"files_forbidden":[]}}
EOF
  git add guards/data/auditor-families.txt .hbn/readbacks/0099-diversity-fixture.json
  git commit -qm init
  cat > .hbn/results/20260617-170100-grok-cross-ia-diversity-0099.md <<'EOF'
---
path: .hbn/results/20260617-170100-grok-cross-ia-diversity-0099.md
---
SOU: grok · familia xAI · papel auditor
APROVA_0099: SIM

Parecer adversarial: so uma familia nao-implementador.
EOF
  git add .hbn/results/20260617-170100-grok-cross-ia-diversity-0099.md
) >/dev/null 2>&1
try_burla "B40 selagem com diversidade insuficiente" "G-DIV" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-audit-diversity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B41-B47 — G-ORQ-ENTRADA: bastao de orquestrador sem atestacao v2
# extrativa valida nao pode seguir.
write_valid_orq_attestation_adv() {
  local d="$1"
  (
    cd "$d"
    python3 - <<'PY'
import hashlib, json, re, subprocess

TOKEN_FP = "34a7f2f9"
ALGORITHM = "orq-entrada.v2/extractive-lines"
STATE = ".hbn/relay/STATE.md"
READ_LIST = "core/read-list-canonica.txt"

def git_bytes(*args):
    return subprocess.check_output(["git", *args], stderr=subprocess.DEVNULL)

def blob(path):
    oid = git_bytes("rev-parse", f":{path}").decode().strip()
    return oid, git_bytes("cat-file", "-p", oid)

def sha256_b(value):
    return hashlib.sha256(value).hexdigest()

def sha256_s(value):
    return sha256_b(value.encode())

def canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))

def state_value(text, key):
    for line in text.splitlines():
        if not re.match(rf"^\s*{re.escape(key)}:", line):
            continue
        value = re.sub(r"\s+#.*$", "", line.split(":", 1)[1]).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        return value
    return ""

_, state_content = blob(STATE)
state_text = state_content.decode()
handoff = state_value(state_text, "handoff_mais_recente")
readback = state_value(state_text, "readback_ativo")

_, read_list_content = blob(READ_LIST)
paths = []
for raw in read_list_content.decode().splitlines():
    line = raw.split("#", 1)[0].strip()
    if not line:
        continue
    if line == "DYNAMIC handoff_mais_recente":
        paths.append(handoff)
    elif line == "DYNAMIC readback_ativo":
        paths.append(readback)
    else:
        paths.append(line.split(None, 1)[1])

manifest = []
content_by_path = {}
for path in paths:
    oid, content = blob(path)
    text = content.decode()
    nonempty = [(i, line) for i, line in enumerate(text.splitlines(), 1) if line.strip()]
    content_by_path[path] = (content, nonempty)
    manifest.append({
        "path": path,
        "blob_oid": oid,
        "sha256": sha256_b(content),
        "bytes": len(content),
        "nonempty_lines": len(nonempty),
    })

manifest_sha = sha256_s(canonical(manifest))
readback_data = json.loads(content_by_path[readback][0].decode())
execution_id = readback_data["execution_id"]
seed = sha256_s(f"orq-entrada.v2\n{execution_id}\n{TOKEN_FP}\n{manifest_sha}")

line_responses = []
for path in [STATE, readback, "core/orchestrator-profile-spec.md"]:
    record = next(item for item in manifest if item["path"] == path)
    idx = int(sha256_s(f"{seed}\n{path}\n{record['blob_oid']}")[:8], 16) % record["nonempty_lines"]
    line_no, line_text = content_by_path[path][1][idx]
    line_responses.append({
        "path": path,
        "line_no": line_no,
        "line_text": line_text,
        "line_sha256": sha256_s(line_text),
    })

data = {
    "papel": "orquestrador",
    "identidade": "opus-4-8",
    "proprietario_bastao": "claude-opus-4-8",
    "bastao_token_fp": TOKEN_FP,
    "algorithm": ALGORITHM,
    "execution_id": execution_id,
    "read_list_ref": READ_LIST,
    "atestado_por": "opus-4-8",
    "atestado_em": "2026-06-18T01:58:00-03:00",
    "manifest_sha256": manifest_sha,
    "challenge": {
        "seed_sha256": seed,
        "line_responses": line_responses,
        "field_responses": [
            {"path": STATE, "field": "readback_ativo", "value": readback},
            {"path": STATE, "field": "proxima_acao", "value": state_value(state_text, "proxima_acao")},
        ],
    },
}
with open(".hbn/attestations/34a7f2f9-orq-entrada.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
  )
}

mk_orq_entrada_repo_adv() {
  local d; d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .hbn/relay .hbn/readbacks .hbn/messages .hbn/attestations \
      .hbn/knowledge agents core guards/data
    cat > .hbn/relay/STATE.md <<'EOF'
---
bastao_token_sha256: 34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf
proprietario_bastao: claude-opus-4-8
papel_bastao: "orquestrador"
readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"
handoff_mais_recente: ".hbn/messages/20260618-003300-codex-handoff-g-orq-entrada.md"
proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."
atribuicao:
  chapeu_atual: orquestrador
  implementador: codex
---
EOF
    echo '{"readback_id":"0056-g-orq-entrada","execution_id":"g-orq-entrada-adv-2026-06-18","agent_id":"codex","track":"safe_track","human_status":"confirmed","authorization":{"human":"Mauricio","evidence":"teste"}}' > .hbn/readbacks/0056-g-orq-entrada.json
    echo "# Handoff G-ORQ-ENTRADA" > .hbn/messages/20260618-003300-codex-handoff-g-orq-entrada.md
    echo "# role templates" > agents/role-templates.md
    echo "# firewall 0022" > .hbn/knowledge/0022-firewall-workflow-fast-track.md
    echo "# role cards" > core/role-cards.md
    echo "# comandos" > .hbn/knowledge/0001-comandos-atomicos-copiaveis.md
    echo "# entrega" > .hbn/knowledge/0002-entrega-operacional-minimalista.md
    echo "# temporaria" > .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
    echo "# gate enforcado falha fechado" > .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md
    echo "# auditor read-only" > .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md
    echo "# fornecedor(implementador) != fornecedor(orquestrador)" > core/orchestrator-profile-spec.md
    echo "# STATE <= 80 linhas" > core/relay-spec.md
    cat > core/read-list-canonica.txt <<EOF
$(git hash-object .hbn/relay/STATE.md) .hbn/relay/STATE.md
DYNAMIC handoff_mais_recente
DYNAMIC readback_ativo
$(git hash-object agents/role-templates.md) agents/role-templates.md
$(git hash-object .hbn/knowledge/0022-firewall-workflow-fast-track.md) .hbn/knowledge/0022-firewall-workflow-fast-track.md
$(git hash-object core/role-cards.md) core/role-cards.md
$(git hash-object .hbn/knowledge/0001-comandos-atomicos-copiaveis.md) .hbn/knowledge/0001-comandos-atomicos-copiaveis.md
$(git hash-object .hbn/knowledge/0002-entrega-operacional-minimalista.md) .hbn/knowledge/0002-entrega-operacional-minimalista.md
$(git hash-object .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md) .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
$(git hash-object .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md) .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md
$(git hash-object .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md) .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md
$(git hash-object core/orchestrator-profile-spec.md) core/orchestrator-profile-spec.md
$(git hash-object core/relay-spec.md) core/relay-spec.md
EOF
    git add -A
  ) >/dev/null 2>&1
  write_valid_orq_attestation_adv "$d"
  ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm orq-entrada ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_orq_entrada_repo_adv)"
( cd "$d" && git rm -q .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B41 orquestrador sem atestacao" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
( cd "$d" && printf '\ndrift staged\n' >> core/relay-spec.md && git add core/relay-spec.md ) >/dev/null 2>&1
try_burla "B42 arquivo da read-list alterado" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["line_responses"][0]["line_sha256"] = "0" * 64
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B43 line_sha256 errado" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["field_responses"] = [
    item for item in data["challenge"]["field_responses"]
    if item.get("field") != "readback_ativo"
]
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B44 field_response ausente" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["line_responses"][0]["line_text"] = "linha extrativa forjada"
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B45 linha extrativa forjada" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import hashlib, json, sys
path = sys.argv[1]
data = json.load(open(path))
old_manifest = "1" * 64
data["manifest_sha256"] = old_manifest
data["challenge"]["seed_sha256"] = hashlib.sha256(
    f"orq-entrada.v2\n{data['execution_id']}\n34a7f2f9\n{old_manifest}".encode()
).hexdigest()
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B46 reuso seed de manifest antigo" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["line_responses"] = []
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B47 tentativa sem ler linhas" "G-ORQ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B48-B54 — G-ORQ-REF: atos de autoridade do orquestrador devem carregar
# orq_entrada_ref valido e so aceitam regeneracao real same-fp da atestacao.
set_orq_ref_on_active_readback_adv() { # <repo> <ref>
  local d="$1" ref="$2"
  python3 - "$d/.hbn/readbacks/0056-g-orq-entrada.json" "$ref" <<'PY'
import json, sys
path, ref = sys.argv[1:3]
data = json.load(open(path, encoding="utf-8"))
data["orq_entrada_ref"] = ref
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
  ( cd "$d" && git add .hbn/readbacks/0056-g-orq-entrada.json ) >/dev/null 2>&1
  write_valid_orq_attestation_adv "$d"
  ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm orq-ref-base ) >/dev/null 2>&1
}

stage_orq_dispatch_adv() {
  local d="$1"
  (
    cd "$d"
    mkdir -p .hbn/dispatch
    cat > .hbn/dispatch/0056-g-orq-entrada.md <<'EOF'
---
dispatch_id: 0056-g-orq-entrada
path: .hbn/dispatch/0056-g-orq-entrada.md
readback_id: 0056-g-orq-entrada
token_fp: 34a7f2f9
human_authorization: Mauricio
---
Executar despacho de autoridade.
EOF
    git add .hbn/dispatch/0056-g-orq-entrada.md
  ) >/dev/null 2>&1
}

stage_orq_message_dispatch_adv() {
  local d="$1"
  (
    cd "$d"
    mkdir -p .hbn/messages
    cat > .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md <<'EOF'
---
tipo: despacho
path: .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md
readback_alvo: 0056-g-orq-entrada
token_fp: 34a7f2f9
human_authorization: Mauricio
---
Despacho de autoridade em .hbn/messages.
EOF
    git add .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md
  ) >/dev/null 2>&1
}

mk_orq_ref_base_adv() { # [ref]
  local ref="${1:-.hbn/attestations/34a7f2f9-orq-entrada.json}" d
  d="$(mk_orq_entrada_repo_adv)"
  set_orq_ref_on_active_readback_adv "$d" "$ref"
  echo "$d"
}

stage_orq_selagem_same_fp_adv() {
  local d="$1"
  (
    cd "$d"
    cat > .hbn/readbacks/0062-selagem-w-orq-3b.json <<'EOF'
{"readback_id":"0062-selagem-w-orq-3b","execution_id":"w-orq-3b-selagem-adv","track":"safe_track","human_status":"confirmed","status":"selado","authority_act":"selagem","orq_entrada_ref":".hbn/attestations/34a7f2f9-orq-entrada.json"}
EOF
    python3 - <<'PY'
from pathlib import Path
path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace('readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"', 'readback_ativo: ".hbn/readbacks/0062-selagem-w-orq-3b.json"')
text = text.replace('proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."', 'proxima_acao: "Cross-audit W-ORQ-3b apos dogfood P1."')
path.write_text(text, encoding="utf-8")
PY
    git add .hbn/relay/STATE.md .hbn/readbacks/0062-selagem-w-orq-3b.json
  ) >/dev/null 2>&1
  write_valid_orq_attestation_adv "$d"
  ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
}

d="$(mk_orq_entrada_repo_adv)"
stage_orq_dispatch_adv "$d"
try_burla "B48 despacho com orq_entrada_ref omitido" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv)"
( cd "$d" && git rm -q .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm remove-orq-attestation ) >/dev/null 2>&1
stage_orq_dispatch_adv "$d"
try_burla "B49 orq_entrada_ref dangling/ausente" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv ".hbn/attestations/deadbeef-orq-entrada.json")"
stage_orq_dispatch_adv "$d"
try_burla "B50 orq_entrada_ref com fp trocado" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv)"
stage_orq_dispatch_adv "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["nota_repin"] = "alteracao no mesmo commit de autoridade"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B51 auto-repin sem regeneracao real" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv)"
stage_orq_selagem_same_fp_adv "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["bastao_token_fp"] = "deadbeef"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B52 atestacao esperada com fp JSON trocado" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv)"
(
  cd "$d"
  cat > .hbn/readbacks/0062-selagem-w-orq-3b.json <<'EOF'
{"readback_id":"0062-selagem-w-orq-3b","execution_id":"w-orq-3b-selagem-adv","track":"safe_track","human_status":"confirmed","status":"selado","authority_act":"selagem","orq_entrada_ref":".hbn/attestations/34a7f2f9-orq-entrada.json"}
EOF
  python3 - <<'PY'
from pathlib import Path
path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace("34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf", "34a7f2f900000000000000000000000000000000000000000000000000000000")
text = text.replace('readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"', 'readback_ativo: ".hbn/readbacks/0062-selagem-w-orq-3b.json"')
text = text.replace('proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."', 'proxima_acao: "Cross-audit W-ORQ-3b apos dogfood P1."')
path.write_text(text, encoding="utf-8")
PY
  git add .hbn/relay/STATE.md .hbn/readbacks/0062-selagem-w-orq-3b.json
) >/dev/null 2>&1
write_valid_orq_attestation_adv "$d"
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B53 full-SHA do bastao trocado com mesmo fp" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv)"
stage_orq_selagem_same_fp_adv "$d"
( cd "$d" && cp .hbn/attestations/34a7f2f9-orq-entrada.json .hbn/attestations/deadbeef-orq-entrada.json && git add .hbn/attestations/deadbeef-orq-entrada.json ) >/dev/null 2>&1
try_burla "B54 atestacao extra staged junto ao ato" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B55-B62 — G-COPY: bloco copiavel em despacho/prompt novo deve ser mecanico.
mk_copy_repo_adv() {
  local d; d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .hbn/messages docs/prompts guards/data
    cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
opus Anthropic
grok xAI
antigravity Google
EOF
    git add -A
    git commit -qm copy-base
  ) >/dev/null 2>&1
  echo "$d"
}

write_copy_doc_adv() { # <path> <tipo> <body>
  local path="$1" tipo="$2" body="$3"
  {
    printf -- '---\n'
    printf 'tipo: %s\n' "$tipo"
    printf 'path: %s\n' "$path"
    printf -- '---\n'
    printf '%s\n' "$body"
  } > "$path"
}

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" "sem bloco copiavel"
  git add -A
) >/dev/null 2>&1
try_burla "B55 despacho novo sem bloco HBN-COPY" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\num\n⟦HBN-COPY END⟧\n⟦HBN-COPY dest=human⟧ BEGIN\ndois\n⟦HBN-COPY END⟧'
  git add -A
) >/dev/null 2>&1
try_burla "B56 dois blocos HBN-COPY no mesmo artefato" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\npayload'
  git add -A
) >/dev/null 2>&1
try_burla "B57 BEGIN HBN-COPY sem END" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY END⟧\n⟦HBN-COPY dest=codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
  git add -A
) >/dev/null 2>&1
try_burla "B58 END HBN-COPY antes de BEGIN" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=desconhecido⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
  git add -A
) >/dev/null 2>&1
try_burla "B59 dest fora do mapa canonico" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest =codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
  git add -A
) >/dev/null 2>&1
try_burla "B60 dest HBN-COPY malformado" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\n⟦HBN-COPY END⟧'
  git add -A
) >/dev/null 2>&1
try_burla "B61 payload HBN-COPY vazio" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_copy_repo_adv)"
(
  cd "$d"
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" "sem bloco no staged"
  git add -A
  write_copy_doc_adv ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\npayload so na working tree\n⟦HBN-COPY END⟧'
) >/dev/null 2>&1
try_burla "B62 working tree boa com staged ruim" "G-COPY" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B63-B67 — G-NEXT: proximo_ponto em STATE deve ser unico, canonico e
# dereferenciar bloco versionado existente no blob staged/HEAD.
mk_next_repo_adv() {
  local variant="$1" d
  d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .hbn/relay .hbn/messages guards/data
    cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
opus Anthropic
grok xAI
antigravity Google
EOF
    echo "# Despacho G-NEXT" > .hbn/messages/next.md
    case "$variant" in
      sem-mapa)
        cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proxima_acao: "texto legado sem campo de maquina"
---
EOF
        ;;
      ato-invalido)
        cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: teleporte
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
        ;;
      destino-invalido)
        cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: bard
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
        ;;
      bloco-inexistente)
        cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/ausente.md
  status: pendente
---
EOF
        ;;
      duplicado)
        cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
proximo_ponto:
  passo: "hearback duplicado"
  ato: hearback
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
        ;;
    esac
    git add .hbn/active-version guards/data/auditor-families.txt .hbn/relay/STATE.md
    if [[ "$variant" != "bloco-inexistente" ]]; then
      git add .hbn/messages/next.md
    fi
  ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_next_repo_adv sem-mapa)"
try_burla "B63 STATE sem proximo_ponto" "G-NEXT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_next_repo_adv ato-invalido)"
try_burla "B64 proximo_ponto.ato fora do enum" "G-NEXT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_next_repo_adv destino-invalido)"
try_burla "B65 destino nao-canonico" "G-NEXT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_next_repo_adv bloco-inexistente)"
try_burla "B66 bloco_ref inexistente" "G-NEXT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_next_repo_adv duplicado)"
try_burla "B67 proximo_ponto duplicado" "G-NEXT" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B71-B75 — G-QUORUM: selagem vigente exige seals_proposal e quorum
# canonico com >=2 familias distintas != OpenAI.
mk_quorum_repo_adv() {
  local variant="$1" d
  d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .hbn/readbacks .hbn/results guards/data
    cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
grok xAI
grok2 xAI
antigravity Google
EOF
    if [[ "$variant" == "sem-seals" ]]; then
      printf '{"readback_id":"0100-selagem-teste","status":"vigente"}\n' > .hbn/readbacks/0100-selagem-teste.json
    else
      printf '{"readback_id":"0100-selagem-teste","status":"vigente","seals_proposal":"0099"}\n' > .hbn/readbacks/0100-selagem-teste.json
    fi
    write_quorum_adv_result() {
      local path="$1" autor="$2" familia="$3" verdict="$4"
      {
        printf -- '---\n'
        printf 'autor: %s\n' "$autor"
        printf 'familia: %s\n' "$familia"
        printf -- '---\n'
        printf '# Parecer\n'
        if [[ -n "$verdict" ]]; then
          printf '%s\n' "$verdict"
        else
          printf 'Sem aprovacao canonica.\n'
        fi
      } > "$path"
    }
    case "$variant" in
      sem-seals)
        write_quorum_adv_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
        write_quorum_adv_result .hbn/results/20260101-010102-antigravity-cross-ia-quorum-0099.md antigravity Google "APROVA_0099: SIM"
        ;;
      um-parecer)
        write_quorum_adv_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
        ;;
      mesma-familia)
        write_quorum_adv_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
        write_quorum_adv_result .hbn/results/20260101-010102-grok2-cross-ia-quorum-0099.md grok2 xAI "APROVA_0099: SIM"
        ;;
      openai-nao-conta)
        write_quorum_adv_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
        write_quorum_adv_result .hbn/results/20260101-010102-codex-cross-ia-quorum-0099.md codex OpenAI "APROVA_0099: SIM"
        ;;
      sem-aprova)
        write_quorum_adv_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
        write_quorum_adv_result .hbn/results/20260101-010102-antigravity-cross-ia-quorum-0099.md antigravity Google ""
        ;;
    esac
    git add .hbn/active-version guards/data/auditor-families.txt .hbn/readbacks/0100-selagem-teste.json .hbn/results
  ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_quorum_repo_adv sem-seals)"
try_burla "B71 selagem sem seals_proposal" "G-QUORUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_quorum_repo_adv um-parecer)"
try_burla "B72 selagem com so 1 parecer nao-OpenAI" "G-QUORUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_quorum_repo_adv mesma-familia)"
try_burla "B73 quorum falso por mesma familia" "G-QUORUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_quorum_repo_adv openai-nao-conta)"
try_burla "B74 parecer OpenAI contado como quorum" "G-QUORUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_quorum_repo_adv sem-aprova)"
try_burla "B75 parecer sem APROVA_NNNN SIM" "G-QUORUM" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B76-B78 — G-READLIST-RITE: qualquer A/M em core/read-list-canonica.txt
# exige readback staged com read_list_rite string nao-vazia + human_status
# confirmed no mesmo diff.
mk_readlist_rite_repo_adv() {
  local variant="$1" d
  d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p core .hbn/readbacks
    printf 'base .hbn/relay/STATE.md\n' > core/read-list-canonica.txt
    git add .hbn/active-version core/read-list-canonica.txt
    git commit -qm init
    printf 'base .hbn/relay/STATE.md\nnovo core/role-cards.md\n' > core/read-list-canonica.txt
    case "$variant" in
      sem-readback)
        git add core/read-list-canonica.txt
        ;;
      sem-rite)
        printf '{"readback_id":"0100-sem-rite","human_status":"confirmed"}\n' > .hbn/readbacks/0100-sem-rite.json
        git add core/read-list-canonica.txt .hbn/readbacks/0100-sem-rite.json
        ;;
      human-pendente)
        printf '{"readback_id":"0100-human-pendente","human_status":"pending","read_list_rite":"0100-human-pendente"}\n' > .hbn/readbacks/0100-human-pendente.json
        git add core/read-list-canonica.txt .hbn/readbacks/0100-human-pendente.json
        ;;
    esac
  ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_readlist_rite_repo_adv sem-readback)"
try_burla "B76 read-list A/M sem readback staged" "G-READ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-readlist-rite.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_readlist_rite_repo_adv sem-rite)"
try_burla "B77 readback sem read_list_rite" "G-READ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-readlist-rite.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_readlist_rite_repo_adv human-pendente)"
try_burla "B78 human_status != confirmed" "G-READ" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-readlist-rite.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B79-B80 — G-ORQ-REF W-ORQ-4b: despachos de autoridade em .hbn/messages
# com tipo: despacho tambem devem ser gateados por orq_entrada_ref.
d="$(mk_orq_entrada_repo_adv)"
stage_orq_message_dispatch_adv "$d"
try_burla "B79 messages tipo despacho sem orq_entrada_ref" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_ref_base_adv ".hbn/attestations/deadbeef-orq-entrada.json")"
stage_orq_message_dispatch_adv "$d"
try_burla "B80 messages tipo despacho ref divergente" "G-ORQREF" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B81-B82 — G-FRZ W-ORQ-4c: freeze nao pode ignorar meta-superficie do
# orquestrador no disco.
d="$(mk_orq_entrada_repo_adv)"
(
  cd "$d"
  cat > .hbn/readbacks/0081-freeze-pendente.json <<'EOF'
{"readback_id":"0081-freeze-pendente","execution_id":"freeze-pendente-adv","track":"safe_track","human_status":"confirmed","status":"implemented_pending_cross_audit","activation_status":"PROPOSED_UNTIL_CROSS_AUDIT"}
EOF
  git add .hbn/readbacks/0081-freeze-pendente.json
  git commit -qm freeze-pending-readback
) >/dev/null 2>&1
try_burla "B81 freeze com readback PROPOSED pendente" "G-FRZ" "$( ( cd "$d" && bash "$GUARDS_DIR/freeze-gate.sh" "$TESTS_DIR/fixtures/freeze/good-all-ok.json" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_orq_entrada_repo_adv)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["manifest_sha256"] = "0" * 64
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
try_burla "B82 freeze com atestacao orq invalida" "G-FRZ" "$( ( cd "$d" && bash "$GUARDS_DIR/freeze-gate.sh" "$TESTS_DIR/fixtures/freeze/good-all-ok.json" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B83-B87 — G-CI-BATTERY: o workflow do Shield deve chamar apenas o
# entrypoint canonico por igualdade exata, e o entrypoint deve executar de
# verdade runner, suite e bateria adversarial.
mk_ci_battery_repo_adv() {
  local variant="$1" d
  d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .github/workflows guards/tests
    cat > guards/ci-entry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash guards/hbn-guards-runner.sh
bash guards/tests/run-guard-tests.sh
bash guards/tests/adversarial-battery.sh
EOF
    case "$variant" in
      sem-entrypoint)
        cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash guards/hbn-guards-runner.sh
      - run: bash guards/tests/run-guard-tests.sh
      - run: bash guards/tests/adversarial-battery.sh
EOF
        ;;
      entry-sem-bateria)
        cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash guards/ci-entry.sh
EOF
        cat > guards/ci-entry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash guards/hbn-guards-runner.sh
bash guards/tests/run-guard-tests.sh
EOF
        ;;
      comentario-entrypoint)
        cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "skip" # bash guards/ci-entry.sh
EOF
        ;;
      echo-entrypoint)
        cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "bash guards/ci-entry.sh"
EOF
        ;;
      heredoc-entrypoint)
        cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          cat <<EOF2
          bash guards/ci-entry.sh
          EOF2
EOF
        ;;
    esac
    git add .hbn/active-version .github/workflows/hbn-shield.yml guards/ci-entry.sh
  ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_ci_battery_repo_adv sem-entrypoint)"
try_burla "B83 CI sem step exato de ci-entry.sh" "G-CI" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_ci_battery_repo_adv entry-sem-bateria)"
try_burla "B84 ci-entry.sh sem adversarial-battery.sh" "G-CI" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_ci_battery_repo_adv comentario-entrypoint)"
try_burla "B85 CI comentario inline ci-entry.sh" "G-CI" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_ci_battery_repo_adv echo-entrypoint)"
try_burla "B86 CI echo ci-entry.sh" "G-CI" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_ci_battery_repo_adv heredoc-entrypoint)"
try_burla "B87 CI heredoc-data ci-entry.sh" "G-CI" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# B88-B90 — G-ARVORE-LABEL: despromocao precisa ser evento rastreavel.
mk_arvore_despromocao_repo_adv() {
  local base_arvore="$1" added_tipo="$2" added_arvore="$3" added_ref="$4" d
  d="$(mk_repo)"
  (
    cd "$d"
    mkdir -p .hbn/relay docs
    cat > .hbn/relay/STATE.md <<'EOF'
---
proxima_acao: "testar despromocao adversarial"
---
EOF
    cat > REGISTRY.md <<EOF
| id | artefato (path) | tipo | temperatura | arvore | superseded_by | created_at |
|---|---|---|---|---|---|---|
| 20260101-01 | docs/b88-b90.md | arvore-promocao | quente | ${base_arvore} | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |
EOF
    git add .hbn/active-version .hbn/relay/STATE.md REGISTRY.md
    git commit -qm init
    printf '| 20260101-02 | docs/b88-b90.md | %s | frio | %s | %s | 2026-01-01T10:00:00-03:00 |\n' \
      "$added_tipo" "$added_arvore" "$added_ref" >> REGISTRY.md
    git add REGISTRY.md
  ) >/dev/null 2>&1
  echo "$d"
}

d="$(mk_arvore_despromocao_repo_adv estavel doc fronteira "—")"
try_burla "B88 despromocao estavel->fronteira sem evento" "G-ARVORE" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-arvore-label.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_arvore_despromocao_repo_adv intermediaria doc fronteira "—")"
try_burla "B89 despromocao intermediaria->fronteira sem evento" "G-ARVORE" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-arvore-label.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(mk_arvore_despromocao_repo_adv estavel arvore-despromocao fronteira "—")"
try_burla "B90 despromocao sem readback versionado" "G-ARVORE" "$( ( cd "$d" && bash "$GUARDS_DIR/assert-arvore-label.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# --- Saída legível (ADR-022): BURLA × GUARD × RESULTADO ----------------------
echo ""
printf '%-52s | %-8s | %s\n' "BURLA" "GUARD" "RESULTADO"
printf '%.0s-' {1..80}; echo ""
for row in "${ROWS[@]}"; do echo "$row"; done
echo ""
if [[ "$FALHAS" -ne 0 ]]; then
    echo "BATERIA VERMELHA — ${FALHAS} burla(s) PASSARAM. Onda reprovada (ADR-020)."
    exit 1
fi
echo "BATERIA VERDE — toda burla documentada foi BLOQUEADA pelo guard correspondente."
exit 0
