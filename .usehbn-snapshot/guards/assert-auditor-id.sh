#!/usr/bin/env bash
# =============================================================================
# guards/assert-auditor-id.sh
# G-AUDITOR-ID: torna a auto-identificacao do auditor um gate fail-closed.
# Para cada .hbn/results/*.md ADICIONADO, exige:
#   - nome AAAAMMDD-HHMMSS-<apelido>-cross-ia-<onda>.md;
#   - linha SOU canonica nas primeiras 12 linhas;
#   - apelido do SOU igual ao apelido do arquivo;
#   - familia canonica e coerente com guards/data/auditor-families.txt.
#
# Padrao local/CI: local le o indice staged; CI le HEAD no range HBN_DIFF_BASE.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-auditor-id"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MAP_PATH="guards/data/auditor-families.txt"
MAP_REPO_PATH="$(guard_version_repo_path "$MAP_PATH" || true)"
if [[ -z "$MAP_REPO_PATH" ]]; then
    guard_fail "G-AUDITOR-ID: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

map_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${MAP_REPO_PATH}" 2>/dev/null
    else
        git show ":${MAP_REPO_PATH}" 2>/dev/null
    fi
}

if ! MAP_CONTENT="$(map_content)"; then
    guard_fail "G-AUDITOR-ID: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

MAP_FAIL=0
MAP_ENTRIES=""
while IFS= read -r line; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -z "$line" ]] && continue
    if [[ ! "$line" =~ ^([A-Za-z0-9._-]+)[[:space:]]+([A-Za-z0-9._-]+)$ ]]; then
        guard_fail "G-AUDITOR-ID: linha invalida no mapa ${MAP_PATH}: ${line}"
        MAP_FAIL=1
        continue
    fi
    map_alias="${BASH_REMATCH[1]}"
    family="${BASH_REMATCH[2]}"
    MAP_ENTRIES="${MAP_ENTRIES}${map_alias} ${family}"$'\n'
done <<< "$MAP_CONTENT"

if [[ "$MAP_FAIL" -ne 0 || -z "$MAP_ENTRIES" ]]; then
    guard_fail "G-AUDITOR-ID: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

DUPLICATE_ALIAS="$(printf '%s' "$MAP_ENTRIES" | awk 'NF { seen[$1]++ } END { for (k in seen) if (seen[k] > 1) print k }' | sort | head -1)"
if [[ -n "$DUPLICATE_ALIAS" ]]; then
    guard_fail "G-AUDITOR-ID: apelido duplicado no mapa ${MAP_PATH}: ${DUPLICATE_ALIAS}"
    exit 1
fi

expected_family_for() {
    local key="$1"
    awk -v k="$key" '$1 == k { print $2; exit }' <<< "$MAP_ENTRIES"
}

added_results() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=A "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=A 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/results/[^/]+\.md$' || true
}

blob_ref() {
    local repo_path
    repo_path="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$repo_path"
    else
        printf ':%s\n' "$repo_path"
    fi
}

RESULTS="$(added_results)"
if [[ -z "$RESULTS" ]]; then
    guard_ok "Nenhum .hbn/results/*.md adicionado no diff."
    exit 0
fi

FAIL=0
while IFS= read -r result; do
    [[ -z "$result" ]] && continue

    file_alias=""
    if [[ "$result" =~ ^\.hbn/results/[0-9]{8}-[0-9]{6}-([A-Za-z0-9._-]+)-cross-ia-[A-Za-z0-9._-]+\.md$ ]]; then
        file_alias="${BASH_REMATCH[1]}"
    else
        guard_fail "G-AUDITOR-ID: nome nao canonico em ${result}"
        FAIL=1
        continue
    fi

    ref="$(blob_ref "$result" || true)"
    if [[ -z "$ref" ]] || ! git cat-file -e "$ref" 2>/dev/null; then
        guard_fail "G-AUDITOR-ID: blob staged/HEAD ilegivel em ${result}"
        FAIL=1
        continue
    fi

    sou_line="$(git show "$ref" 2>/dev/null | sed -n '1,12p' | grep -E '^SOU:' | head -1 || true)"
    if [[ -z "$sou_line" ]]; then
        guard_fail "G-AUDITOR-ID: SOU canonico ausente em ${result}"
        FAIL=1
        continue
    fi

    if [[ ! "$sou_line" =~ ^SOU:[[:space:]]*([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*familia[[:space:]]+([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*papel[[:space:]]+auditor[[:space:]]*$ ]]; then
        guard_fail "G-AUDITOR-ID: SOU canonico ausente em ${result}"
        FAIL=1
        continue
    fi
    sou_alias="${BASH_REMATCH[1]}"
    sou_family="${BASH_REMATCH[2]}"

    if [[ "$sou_alias" != "$file_alias" ]]; then
        guard_fail "G-AUDITOR-ID: apelido do arquivo (${file_alias}) diverge do SOU (${sou_alias}) em ${result}"
        FAIL=1
        continue
    fi

    expected_family="$(expected_family_for "$file_alias")"
    if [[ -z "$expected_family" ]]; then
        guard_fail "G-AUDITOR-ID: familia/apelido fora do mapa canonico em ${result} (${file_alias}/${sou_family})"
        FAIL=1
        continue
    fi
    if [[ "$sou_family" != "$expected_family" ]]; then
        guard_fail "G-AUDITOR-ID: familia incoerente em ${result} (${file_alias} declara ${sou_family}; esperado ${expected_family})"
        FAIL=1
        continue
    fi
done <<< "$RESULTS"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Todos os results adicionados trazem SOU canonico, apelido e familia coerentes."
exit 0
