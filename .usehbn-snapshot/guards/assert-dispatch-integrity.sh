#!/usr/bin/env bash
# =============================================================================
# guards/assert-dispatch-integrity.sh
# G-DSP-INT: garante que o dispatch staged aponta para readback ativo, token
# do STATE e autorizacao humana coerentes.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-dispatch-integrity"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

blob_ref() {
    local p
    p="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$p"
    else
        echo ":$p"
    fi
}

blob_mode() {
    local p repo_file
    repo_file="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r HEAD -- "$repo_file" 2>/dev/null | awk '{print $1}' | head -1
    else
        git ls-files --stage -- "$repo_file" 2>/dev/null | awk '{print $1}' | head -1
    fi
}

dispatch_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=ACMR "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/dispatch/.*\.md$' || true
}

DISPATCHES="$(dispatch_files)"
if [[ -z "$DISPATCHES" ]]; then
    guard_ok "Nenhum dispatch staged em .hbn/dispatch/."
    exit 0
fi

STATE_REF="$(blob_ref ".hbn/relay/STATE.md")"
if ! git cat-file -e "$STATE_REF" 2>/dev/null; then
    guard_fail "STATE obrigatório ausente no índice/HEAD: .hbn/relay/STATE.md."
    exit 1
fi

read_state_field() {
    local key="$1"
    git show "$STATE_REF" 2>/dev/null | awk -v key="$key" '
        $0 == "---" {
            if (infm) { exit }
            infm=1
            next
        }
        infm && index($0, key ":") == 1 {
            sub("^[^:]+:[[:space:]]*", "", $0)
            gsub(/^"/, "", $0)
            gsub(/"$/, "", $0)
            print
            exit
        }
    '
}

ACTIVE_READBACK="$(read_state_field "readback_ativo")"
TOKEN_SHA="$(read_state_field "bastao_token_sha256")"

if [[ -z "$ACTIVE_READBACK" ]]; then
    guard_fail "STATE sem readback_ativo; não é possível validar dispatch."
    exit 1
fi
if [[ ! "$TOKEN_SHA" =~ ^[0-9a-f]{64}$ ]]; then
    guard_fail "STATE sem bastao_token_sha256 válido de 64 hex; não é possível validar token_fp."
    exit 1
fi
STATE_TOKEN_FP="${TOKEN_SHA:0:8}"

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    mode="$(blob_mode "$f" || true)"
    if [[ "$mode" != "100644" ]]; then
        guard_fail "Dispatch '${f}' deve ser arquivo regular git mode 100644; modo atual: ${mode:-desconhecido}."
        FAIL=1
        continue
    fi

    ref="$(blob_ref "$f")"
    DISPATCH_FILE="$(mktemp)"
    ERR_FILE="$(mktemp)"
    if ! git show "$ref" > "$DISPATCH_FILE" 2>/dev/null; then
        guard_fail "${f}: não foi possível ler blob staged/HEAD."
        rm -f "$DISPATCH_FILE" "$ERR_FILE"
        FAIL=1
        continue
    fi
    meta="$(python3 - "$f" "$DISPATCH_FILE" 2>"$ERR_FILE" <<'PY' || true
import sys

dispatch_path, dispatch_file = sys.argv[1:3]
text = open(dispatch_file).read()

def unquote(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
        return value[1:-1]
    return value

def parse(lines):
    root = {}
    current = None
    for lineno, raw in enumerate(lines, start=2):
        if not raw.strip():
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        item = raw.strip()
        if indent == 0:
            if ":" not in item:
                raise ValueError(f"linha {lineno}: entrada YAML sem ':'")
            key, value = item.split(":", 1)
            key = key.strip()
            value = value.strip()
            root[key] = unquote(value) if value else None
            current = key
        elif indent == 2 and item.startswith("- "):
            if current is None:
                raise ValueError(f"linha {lineno}: lista sem chave pai")
            if root.get(current) is None:
                root[current] = []
            if isinstance(root[current], list):
                root[current].append(unquote(item[2:]))
        elif indent in (2, 4):
            continue
        else:
            raise ValueError(f"linha {lineno}: YAML fora do subconjunto suportado")
    return root

lines = text.splitlines()
if not lines or lines[0].strip() != "---":
    print("front matter YAML obrigatório na primeira linha", file=sys.stderr)
    sys.exit(1)
end = None
for idx in range(1, len(lines)):
    if lines[idx].strip() == "---":
        end = idx
        break
if end is None:
    print("front matter YAML não foi fechado com ---", file=sys.stderr)
    sys.exit(1)

try:
    data = parse(lines[1:end])
except Exception as exc:
    print(f"front matter inválido em {dispatch_path}: {exc}", file=sys.stderr)
    sys.exit(1)

for key in ("readback_id", "token_fp", "human_authorization"):
    if not data.get(key):
        print(f"campo obrigatório ausente ou vazio: {key}", file=sys.stderr)
        sys.exit(1)

print("\t".join([data["readback_id"], data["token_fp"], data["human_authorization"]]))
PY
)"
    if [[ -z "$meta" ]]; then
        while IFS= read -r err; do
            [[ -z "$err" ]] && continue
            guard_fail "${f}: ${err}"
        done < "$ERR_FILE"
        rm -f "$DISPATCH_FILE" "$ERR_FILE"
        FAIL=1
        continue
    fi
    rm -f "$DISPATCH_FILE" "$ERR_FILE"

    IFS=$'\t' read -r readback_id token_fp human_authorization <<< "$meta"
    expected_readback_path=".hbn/readbacks/${readback_id}.json"
    if ! git cat-file -e "$(blob_ref "$expected_readback_path")" 2>/dev/null; then
        guard_fail "${f}: readback declarado não existe no índice/HEAD: ${expected_readback_path}."
        FAIL=1
    fi
    if [[ "$ACTIVE_READBACK" != "$expected_readback_path" ]]; then
        guard_fail "${f}: readback_id '${readback_id}' não é o readback_ativo do STATE ('${ACTIVE_READBACK}')."
        FAIL=1
    fi
    if [[ "$token_fp" != "$STATE_TOKEN_FP" ]]; then
        guard_fail "${f}: token_fp '${token_fp}' diverge do prefixo do STATE '${STATE_TOKEN_FP}'."
        FAIL=1
    fi
    if [[ -z "$human_authorization" ]]; then
        guard_fail "${f}: human_authorization vazio."
        FAIL=1
    fi
done <<< "$DISPATCHES"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Dispatches staged apontam para readback ativo, token_fp e autorização humana coerentes."
exit 0
