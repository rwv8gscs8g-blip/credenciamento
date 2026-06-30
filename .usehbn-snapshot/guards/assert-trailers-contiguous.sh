#!/usr/bin/env bash
# =============================================================================
# guards/assert-trailers-contiguous.sh
# path: guards/assert-trailers-contiguous.sh · id-global: 20260617-210200-codex-guard-trailers-contiguous
# Guarda G-TRAILERS (R3a/readback 0051).
#   Para TODO commit que toca path governado, exige os tres trailers HBN
#   contiguos no ultimo paragrafo da mensagem:
#     HBN-Readback
#     HBN-Human-Authorization
#     HBN-Token-FP
#
# Diferente do G-EXC, esta regra independe do campo implementador no STATE.
# O objetivo e fechar o buraco em que implementador=null desativava o G-EXC e
# deixava trailers nao-contiguos passarem.
#
# Modos:
#   assert-trailers-contiguous.sh <commit-msg-file>   ← hook commit-msg local
#   HBN_DIFF_BASE=<sha> assert-trailers-contiguous.sh ← CI/range pushed
#
# Fail-closed: se ha path governado e a mensagem nao e legivel, bloqueia.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-trailers-contiguous"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MSG_FILE="${1:-}"

last_paragraph() {
    awk '
        /^[[:space:]]*$/ {
            if (current != "") {
                last = current
                current = ""
            }
            next
        }
        {
            current = current (current == "" ? "" : "\n") $0
        }
        END {
            if (current != "") {
                last = current
            }
            print last
        }
    '
}

is_governed_path() {
    local p="$1"
    case "$p" in
        core/*|guards/*|schemas/*|methodology/*|src/*|REGISTRY.md|AGENTS.md) return 0 ;;
        .hbn/readbacks/*|.hbn/results/*|.hbn/messages/*|.hbn/relay/*|.hbn/knowledge/*) return 0 ;;
    esac
    return 1
}

governed_paths_from() {
    local p
    while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        if is_governed_path "$p"; then
            printf '%s\n' "$p"
        fi
    done
}

staged_paths() {
    guard_diff_files
}

commit_paths() {
    local commit="$1"
    git diff-tree --root --no-commit-id --name-only -r "$commit" 2>/dev/null \
        | guard_paths_to_version_paths
}

require_trailers_in() { # <texto> <origem>
    local txt="$1" origem="$2" trailer_block miss=0
    trailer_block="$(printf '%s\n' "$txt" | last_paragraph)"

    if [[ -z "$trailer_block" ]]; then
        guard_fail "Mensagem sem ultimo paragrafo legivel em ${origem}; commits governados exigem trailers HBN contiguos."
        return 1
    fi

    grep -qE '^HBN-Readback:[[:space:]]*[^[:space:]]' <<< "$trailer_block" || {
        guard_fail "Trailer AUSENTE em ${origem}: 'HBN-Readback: <id>' no ultimo paragrafo."
        miss=1
    }
    grep -qE '^HBN-Human-Authorization:[[:space:]]*[^[:space:]]' <<< "$trailer_block" || {
        guard_fail "Trailer AUSENTE em ${origem}: 'HBN-Human-Authorization: <ref>' no ultimo paragrafo."
        miss=1
    }
    grep -qE '^HBN-Token-FP:[[:space:]]*[^[:space:]]' <<< "$trailer_block" || {
        guard_fail "Trailer AUSENTE em ${origem}: 'HBN-Token-FP: <fp>' no ultimo paragrafo."
        miss=1
    }
    [[ "$miss" -ne 0 ]] && return 1

    if ! printf '%s\n' "$trailer_block" | awk '
        {
            lines[NR] = $0
        }
        END {
            for (i = 1; i <= NR - 2; i++) {
                if (lines[i] ~ /^HBN-Readback:[[:space:]]*[^[:space:]]/ &&
                    lines[i + 1] ~ /^HBN-Human-Authorization:[[:space:]]*[^[:space:]]/ &&
                    lines[i + 2] ~ /^HBN-Token-FP:[[:space:]]*[^[:space:]]/) {
                    exit 0
                }
            }
            exit 1
        }
    '; then
        guard_fail "Trailers HBN NAO contiguos em ${origem}. O ultimo paragrafo deve conter HBN-Readback, HBN-Human-Authorization e HBN-Token-FP em linhas consecutivas."
        return 1
    fi

    return 0
}

if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    FAIL=0
    while IFS= read -r c; do
        [[ -z "$c" ]] && continue
        GOVERNED="$(commit_paths "$c" | governed_paths_from)"
        if [[ -z "$GOVERNED" ]]; then
            guard_log "Commit ${c:0:7} sem path governado; G-TRAILERS isento."
            continue
        fi
        if ! txt="$(git log -1 --format='%B' "$c" 2>/dev/null)"; then
            guard_fail "Nao foi possivel ler mensagem do commit ${c:0:7} do range pushed."
            FAIL=1
            continue
        fi
        if ! require_trailers_in "$txt" "commit ${c:0:7} do range pushed"; then
            echo "  Paths governados nesse commit:" >&2
            printf '    - %s\n' $GOVERNED >&2
            FAIL=1
        fi
    done <<< "$(git rev-list --reverse "${HBN_DIFF_BASE}..HEAD" 2>/dev/null || true)"

    [[ "$FAIL" -ne 0 ]] && exit 1
    guard_ok "Trailers HBN contiguos em todos os commits governados do range."
    exit 0
fi

GOVERNED="$(staged_paths | governed_paths_from)"
if [[ -z "$GOVERNED" ]]; then
    guard_ok "Nenhum path governado no commit em curso; G-TRAILERS isento."
    exit 0
fi

if [[ -z "$MSG_FILE" || ! -f "$MSG_FILE" ]]; then
    guard_fail "Mensagem de commit ilegivel para diff governado. Use este guard no commit-msg com o arquivo da mensagem."
    echo "  Paths governados staged:" >&2
    printf '    - %s\n' $GOVERNED >&2
    exit 1
fi

if ! require_trailers_in "$(cat "$MSG_FILE")" "mensagem do commit em curso"; then
    echo "  Paths governados staged:" >&2
    printf '    - %s\n' $GOVERNED >&2
    exit 1
fi

guard_ok "Trailers HBN presentes e contiguos no ultimo paragrafo da mensagem do commit governado."
exit 0
