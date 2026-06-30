#!/usr/bin/env bash
# =============================================================================
# guards/assert-zona-livre.sh
# G-ZONA-LIVRE: deny-by-default para docs/brainstorm/**.
#
# Qualquer path staged sob docs/brainstorm/** exige que o readback ativo,
# resolvido de .hbn/relay/STATE.md (campo readback_ativo), declare curadoria
# humana explicita:
#   "zona_livre_curada": true
#   "zona_livre_nota": "<texto nao-vazio>"
#
# Fail-closed: se STATE, readback ativo ou JSON estiver ausente/ilegivel,
# bloqueia. A working tree solta nao conta: localmente le o indice staged;
# em CI le HEAD no range validado por HBN_DIFF_BASE.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-zona-livre"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ACTIVE_ROOT="$(get_canonical_root || true)"
if [[ -z "$ACTIVE_ROOT" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel mapear docs/brainstorm/** com seguranca."
    exit 1
fi

STAGED="$(guard_diff_files || true)"
BRAINSTORM_PATHS="$(printf '%s\n' "$STAGED" | grep -E '^docs/brainstorm/.+' || true)"

if [[ -z "$BRAINSTORM_PATHS" ]]; then
    guard_ok "Nenhum path staged sob docs/brainstorm/**."
    exit 0
fi

STATE_PATH=".hbn/relay/STATE.md"
STATE_REPO_PATH="$(guard_version_repo_path "$STATE_PATH" || true)"
if [[ -z "$STATE_REPO_PATH" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel localizar STATE."
    exit 1
fi

blob_ref() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$1"
    else
        printf ':%s\n' "$1"
    fi
}

STATE_FILE="$(mktemp)"
RB_FILE="$(mktemp)"
trap 'rm -f "$STATE_FILE" "$RB_FILE"' EXIT

if ! git show "$(blob_ref "$STATE_REPO_PATH")" > "$STATE_FILE" 2>/dev/null; then
    guard_fail "STATE ausente ou ilegivel no indice/HEAD: ${STATE_PATH}. G-ZONA-LIVRE falha fechado."
    exit 1
fi

ACTIVE_RB_PATH="$(grep -E '^[[:space:]]*readback_ativo:' "$STATE_FILE" | head -1 \
    | sed -E "s/^[^:]+:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^[\"'[:space:]]+//; s/[\"'[:space:]]+$//" \
    || true)"

if [[ -z "$ACTIVE_RB_PATH" ]]; then
    guard_fail "STATE sem campo readback_ativo. zona livre so entra com curadoria humana explicita no readback — knowledge 0024."
    exit 1
fi

case "$ACTIVE_RB_PATH" in
    .hbn/readbacks/*.json) ;;
    *)
        guard_fail "readback_ativo invalido no STATE: '${ACTIVE_RB_PATH}'. Esperado .hbn/readbacks/<id>.json."
        exit 1
        ;;
esac

case "$ACTIVE_RB_PATH" in
    /*|*..*|*//*|*\\*|*" "*|*"	"*)
        guard_fail "readback_ativo inseguro no STATE: '${ACTIVE_RB_PATH}'."
        exit 1
        ;;
esac

ACTIVE_RB_REPO_PATH="$(guard_version_repo_path "$ACTIVE_RB_PATH" || true)"
if [[ -z "$ACTIVE_RB_REPO_PATH" ]]; then
    guard_fail "Nao foi possivel resolver o readback ativo '${ACTIVE_RB_PATH}' na versao ativa."
    exit 1
fi

if ! git show "$(blob_ref "$ACTIVE_RB_REPO_PATH")" > "$RB_FILE" 2>/dev/null; then
    guard_fail "Readback ativo ausente ou ilegivel no indice/HEAD: ${ACTIVE_RB_PATH}. zona livre so entra com curadoria humana explicita no readback — knowledge 0024."
    echo "  Paths staged sob docs/brainstorm/**:" >&2
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        echo "    - $f" >&2
    done <<< "$BRAINSTORM_PATHS"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    guard_fail "python3 ausente — nao consigo validar JSON do readback ativo com seguranca."
    exit 2
fi

set +e
CHECK_MSG="$(python3 - "$RB_FILE" <<'PY'
import json
import sys

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        rb = json.load(f)
except Exception as exc:
    print(f"readback JSON ilegivel: {exc}")
    sys.exit(2)

if rb.get("zona_livre_curada") is not True:
    print('falta "zona_livre_curada": true')
    sys.exit(1)

nota = rb.get("zona_livre_nota")
if not isinstance(nota, str) or not nota.strip():
    print('falta "zona_livre_nota" nao-vazio')
    sys.exit(1)

sys.exit(0)
PY
)"
CHECK_RC=$?
set -e

if [[ "$CHECK_RC" -ne 0 ]]; then
    if [[ "$CHECK_RC" -eq 2 ]]; then
        guard_fail "Readback ativo ilegivel: ${ACTIVE_RB_PATH}. zona livre so entra com curadoria humana explicita no readback — knowledge 0024."
    else
        guard_fail "zona livre so entra com curadoria humana explicita no readback — knowledge 0024. ${CHECK_MSG}"
    fi
    echo "  Readback ativo: ${ACTIVE_RB_PATH}" >&2
    echo "  Paths staged sob docs/brainstorm/**:" >&2
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        echo "    - $f" >&2
    done <<< "$BRAINSTORM_PATHS"
    exit 1
fi

guard_ok "Zona livre curada no readback ativo (${ACTIVE_RB_PATH}); docs/brainstorm/** liberado."
exit 0
