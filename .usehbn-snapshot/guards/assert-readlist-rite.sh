#!/usr/bin/env bash
# =============================================================================
# guards/assert-readlist-rite.sh
# G-READLIST-RITE: edicao da read-list canonica exige rito declarado.
#
# Gatilho: core/read-list-canonica.txt ADICIONADO/MODIFICADO no diff.
# Local valida blobs staged (:path). CI valida HEAD:path no range HBN_DIFF_BASE.
# Se a read-list mudar, exige no mesmo diff pelo menos um readback A/M com
# read_list_rite string nao-vazia e human_status="confirmed".
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-readlist-rite"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

READLIST_PATH="core/read-list-canonica.txt"
READLIST_REPO_PATH="$(guard_version_repo_path "$READLIST_PATH" || true)"
if [[ -z "$READLIST_REPO_PATH" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel localizar ${READLIST_PATH}."
    exit 1
fi

diff_am_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=AM "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=AM 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

blob_ref() {
    local version_path="$1" repo_path
    repo_path="$(guard_version_repo_path "$version_path" || true)"
    [[ -n "$repo_path" ]] || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$repo_path"
    else
        printf ':%s\n' "$repo_path"
    fi
}

READLIST_TOUCHED=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if [[ "$f" == "$READLIST_PATH" ]]; then
        READLIST_TOUCHED=1
        break
    fi
done < <(diff_am_files)

if [[ "$READLIST_TOUCHED" -ne 1 ]]; then
    guard_ok "Read-list canonica nao foi adicionada/modificada neste diff — G-READLIST-RITE nao opina."
    exit 0
fi

if ! git cat-file -e "$(blob_ref "$READLIST_PATH")" 2>/dev/null; then
    guard_fail "Read-list canonica aparece como A/M, mas o blob staged/HEAD nao e legivel: ${READLIST_PATH}."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    guard_fail "python3 ausente — nao consigo validar JSON dos readbacks com seguranca."
    exit 2
fi

READBACK_REFS="$(mktemp)"
trap 'rm -f "$READBACK_REFS"' EXIT

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        .hbn/readbacks/*.json)
            ref="$(blob_ref "$f" || true)"
            if [[ -z "$ref" ]] || ! git cat-file -e "$ref" 2>/dev/null; then
                guard_fail "Readback A/M sem blob staged/HEAD legivel: ${f}."
                exit 1
            fi
            printf '%s\t%s\n' "$f" "$ref" >> "$READBACK_REFS"
            ;;
    esac
done < <(diff_am_files)

if [[ ! -s "$READBACK_REFS" ]]; then
    guard_fail "${READLIST_PATH} mudou sem rito declarado: nenhum readback .hbn/readbacks/*.json A/M no mesmo diff com read_list_rite + human_status confirmed."
    exit 1
fi

if ! python3 - "$READBACK_REFS" <<'PY'
import json
import subprocess
import sys

refs_file = sys.argv[1]
errors = []
valid = []
checked = []


def fail(message):
    errors.append(message)


def git_text(ref):
    return subprocess.check_output(
        ["git", "show", ref],
        stderr=subprocess.DEVNULL,
    ).decode("utf-8")


with open(refs_file, encoding="utf-8") as handle:
    for raw in handle:
        raw = raw.rstrip("\n")
        if not raw:
            continue
        path, ref = raw.split("\t", 1)
        checked.append(path)
        try:
            data = json.loads(git_text(ref))
        except Exception as exc:
            fail(f"{path}: JSON ilegivel no blob staged/HEAD ({exc})")
            continue
        if not isinstance(data, dict):
            fail(f"{path}: readback deve ser objeto JSON")
            continue
        rite = data.get("read_list_rite")
        human_status = data.get("human_status")
        if isinstance(rite, str) and rite.strip() and human_status == "confirmed":
            valid.append(path)

if errors:
    for message in errors:
        print(f"G-READLIST-RITE: {message}", file=sys.stderr)
    sys.exit(2)

if not valid:
    detail = ", ".join(checked) if checked else "nenhum"
    print(
        "G-READLIST-RITE: core/read-list-canonica.txt mudou sem rito declarado; "
        f"readbacks checados sem read_list_rite string nao-vazia + human_status confirmed: {detail}",
        file=sys.stderr,
    )
    sys.exit(1)
PY
then
    guard_fail "${READLIST_PATH} mudou sem rito declarado: exige readback staged com read_list_rite string nao-vazia e human_status confirmed."
    exit 1
fi

guard_ok "Read-list canonica mudou com rito declarado em readback staged."
exit 0
