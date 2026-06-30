#!/usr/bin/env bash
# =============================================================================
# guards/assert-audit-diversity.sh
# G-DIVERSITY (R3b/readback 0053): enforca diversidade de familia na selagem.
# Para cada .hbn/results/*cross-ia*.md ADICIONADO, identifica o readback
# auditado por APROVA_<NNNN>: SIM|NAO. Para cada <NNNN> tocado, exige que o
# conjunto tracked (indice local / HEAD em CI) tenha >=2 familias distintas
# com APROVA SIM, excluindo a familia do implementador do readback auditado.
#
# Fail-closed: mapa, readback, SOU, familia ou veredito ilegivel bloqueia.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-audit-diversity"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MAP_PATH="guards/data/auditor-families.txt"
MAP_REPO_PATH="$(guard_version_repo_path "$MAP_PATH" || true)"
if [[ -z "$MAP_REPO_PATH" ]]; then
    guard_fail "G-DIVERSITY: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

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

map_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${MAP_REPO_PATH}" 2>/dev/null
    else
        git show ":${MAP_REPO_PATH}" 2>/dev/null
    fi
}

if ! MAP_CONTENT="$(map_content)"; then
    guard_fail "G-DIVERSITY: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

MAP_FAIL=0
MAP_ENTRIES=""
while IFS= read -r line; do
    line="${line%%#*}"
    line="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -z "$line" ]] && continue
    if [[ ! "$line" =~ ^([A-Za-z0-9._-]+)[[:space:]]+([A-Za-z0-9._-]+)$ ]]; then
        guard_fail "G-DIVERSITY: linha invalida no mapa ${MAP_PATH}: ${line}"
        MAP_FAIL=1
        continue
    fi
    MAP_ENTRIES="${MAP_ENTRIES}${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"$'\n'
done <<< "$MAP_CONTENT"

if [[ "$MAP_FAIL" -ne 0 || -z "$MAP_ENTRIES" ]]; then
    guard_fail "G-DIVERSITY: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

DUPLICATE_ALIAS="$(printf '%s' "$MAP_ENTRIES" | awk 'NF { seen[$1]++ } END { for (k in seen) if (seen[k] > 1) print k }' | sort | head -1)"
if [[ -n "$DUPLICATE_ALIAS" ]]; then
    guard_fail "G-DIVERSITY: apelido duplicado no mapa ${MAP_PATH}: ${DUPLICATE_ALIAS}"
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
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/results/[^/]*cross-ia[^/]*\.md$' || true
}

all_cross_ia_results() {
    local results_repo_dir
    results_repo_dir="$(guard_version_repo_path ".hbn/results" || true)"
    [[ -n "$results_repo_dir" ]] || return 0
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r --name-only HEAD -- "$results_repo_dir" 2>/dev/null || true
    else
        git ls-files -- "$results_repo_dir" 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/results/[^/]*cross-ia[^/]*\.md$' || true
}

readback_for() {
    local rb_num="$1" readbacks_repo_dir
    readbacks_repo_dir="$(guard_version_repo_path ".hbn/readbacks" || true)"
    [[ -n "$readbacks_repo_dir" ]] || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r --name-only HEAD -- "$readbacks_repo_dir" 2>/dev/null || true
    else
        git ls-files -- "$readbacks_repo_dir" 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E "^\.hbn/readbacks/${rb_num}-[^/]+\.json$" || true
}

readback_implementador() {
    local rb_path="$1" ref
    ref="$(blob_ref "$rb_path" || true)"
    if [[ -z "$ref" ]] || ! git cat-file -e "$ref" 2>/dev/null; then
        return 1
    fi
    if ! command -v python3 >/dev/null 2>&1; then
        return 1
    fi
    git show "$ref" 2>/dev/null | python3 -c 'import json, sys; data=json.load(sys.stdin); print(data.get("implementador_id") or "")' 2>/dev/null
}

parse_added_result() {
    local result="$1" ref content verdict_lines sou_line expected_family
    ref="$(blob_ref "$result" || true)"
    if [[ -z "$ref" ]] || ! git cat-file -e "$ref" 2>/dev/null; then
        guard_fail "G-DIVERSITY: blob staged/HEAD ilegivel em ${result}"
        return 1
    fi
    content="$(git show "$ref" 2>/dev/null || true)"
    verdict_lines="$(grep -E '^APROVA_[0-9]{4}:[[:space:]]*(SIM|NAO)[[:space:]]*$' <<< "$content" || true)"
    if [[ -z "$verdict_lines" ]]; then
        guard_fail "G-DIVERSITY: veredito APROVA_<NNNN>: SIM|NAO ausente em result adicionado ${result}"
        return 1
    fi
    if [[ "$(printf '%s\n' "$verdict_lines" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')" != "1" ]]; then
        guard_fail "G-DIVERSITY: result adicionado ${result} deve ter exatamente um veredito APROVA_<NNNN>: SIM|NAO"
        return 1
    fi
    if [[ ! "$verdict_lines" =~ ^APROVA_([0-9]{4}):[[:space:]]*(SIM|NAO)[[:space:]]*$ ]]; then
        guard_fail "G-DIVERSITY: veredito invalido em ${result}"
        return 1
    fi
    RESULT_TARGET="${BASH_REMATCH[1]}"
    RESULT_VERDICT="${BASH_REMATCH[2]}"

    sou_line="$(printf '%s\n' "$content" | sed -n '1,12p' | grep -E '^SOU:' | head -1 || true)"
    if [[ ! "$sou_line" =~ ^SOU:[[:space:]]*([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*familia[[:space:]]+([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*papel[[:space:]]+auditor[[:space:]]*$ ]]; then
        guard_fail "G-DIVERSITY: SOU canonico ausente em result adicionado ${result}"
        return 1
    fi
    RESULT_ALIAS="${BASH_REMATCH[1]}"
    RESULT_FAMILY="${BASH_REMATCH[2]}"
    expected_family="$(expected_family_for "$RESULT_ALIAS")"
    if [[ -z "$expected_family" ]]; then
        guard_fail "G-DIVERSITY: auditor fora do mapa canonico em ${result} (${RESULT_ALIAS}/${RESULT_FAMILY})"
        return 1
    fi
    if [[ "$RESULT_FAMILY" != "$expected_family" ]]; then
        guard_fail "G-DIVERSITY: familia incoerente em ${result} (${RESULT_ALIAS} declara ${RESULT_FAMILY}; esperado ${expected_family})"
        return 1
    fi
    return 0
}

family_for_result_if_sim() {
    local result="$1" rb_num="$2" ref content verdict_lines verdict sou_line expected_family
    ref="$(blob_ref "$result" || true)"
    if [[ -z "$ref" ]] || ! git cat-file -e "$ref" 2>/dev/null; then
        guard_fail "G-DIVERSITY: blob tracked ilegivel em ${result}"
        return 2
    fi
    content="$(git show "$ref" 2>/dev/null || true)"
    verdict_lines="$(grep -E "^APROVA_${rb_num}:[[:space:]]*(SIM|NAO)[[:space:]]*$" <<< "$content" || true)"
    if [[ -z "$verdict_lines" ]]; then
        return 1
    fi
    if [[ "$(printf '%s\n' "$verdict_lines" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')" != "1" ]]; then
        guard_fail "G-DIVERSITY: ${result} tem veredito APROVA_${rb_num} duplicado"
        return 2
    fi
    if [[ ! "$verdict_lines" =~ ^APROVA_${rb_num}:[[:space:]]*(SIM|NAO)[[:space:]]*$ ]]; then
        guard_fail "G-DIVERSITY: veredito APROVA_${rb_num} invalido em ${result}"
        return 2
    fi
    verdict="${BASH_REMATCH[1]}"
    if [[ "$verdict" != "SIM" ]]; then
        return 1
    fi

    sou_line="$(printf '%s\n' "$content" | sed -n '1,12p' | grep -E '^SOU:' | head -1 || true)"
    if [[ ! "$sou_line" =~ ^SOU:[[:space:]]*([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*familia[[:space:]]+([A-Za-z0-9._-]+)[[:space:]]*·[[:space:]]*papel[[:space:]]+auditor[[:space:]]*$ ]]; then
        guard_fail "G-DIVERSITY: SOU canonico ausente em ${result} com APROVA_${rb_num}: SIM"
        return 2
    fi
    RESULT_ALIAS="${BASH_REMATCH[1]}"
    RESULT_FAMILY="${BASH_REMATCH[2]}"
    expected_family="$(expected_family_for "$RESULT_ALIAS")"
    if [[ -z "$expected_family" ]]; then
        guard_fail "G-DIVERSITY: auditor fora do mapa canonico em ${result} (${RESULT_ALIAS}/${RESULT_FAMILY})"
        return 2
    fi
    if [[ "$RESULT_FAMILY" != "$expected_family" ]]; then
        guard_fail "G-DIVERSITY: familia incoerente em ${result} (${RESULT_ALIAS} declara ${RESULT_FAMILY}; esperado ${expected_family})"
        return 2
    fi
    printf '%s\n' "$RESULT_FAMILY"
    return 0
}

ADDED_RESULTS="$(added_results)"
if [[ -z "$ADDED_RESULTS" ]]; then
    guard_ok "Nenhum .hbn/results/*cross-ia*.md adicionado no diff."
    exit 0
fi

FAIL=0
TARGETS=""
while IFS= read -r result; do
    [[ -z "$result" ]] && continue
    if parse_added_result "$result"; then
        TARGETS="${TARGETS}${RESULT_TARGET}"$'\n'
    else
        FAIL=1
    fi
done <<< "$ADDED_RESULTS"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

TARGETS="$(printf '%s' "$TARGETS" | sed '/^[[:space:]]*$/d' | sort -u)"
ALL_RESULTS="$(all_cross_ia_results)"

while IFS= read -r rb_num; do
    [[ -z "$rb_num" ]] && continue

    rb_candidates="$(readback_for "$rb_num")"
    rb_count="$(printf '%s\n' "$rb_candidates" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')"
    if [[ "$rb_count" != "1" ]]; then
        guard_fail "G-DIVERSITY: readback auditado ${rb_num} indeterminavel em .hbn/readbacks/${rb_num}-*.json (encontrados: ${rb_count})"
        FAIL=1
        continue
    fi
    rb_path="$(printf '%s\n' "$rb_candidates" | sed -n '1p')"
    impl_alias="$(readback_implementador "$rb_path" || true)"
    if [[ -z "$impl_alias" ]]; then
        guard_fail "G-DIVERSITY: implementador_id ausente/ilegivel em ${rb_path}"
        FAIL=1
        continue
    fi
    impl_family="$(expected_family_for "$impl_alias")"
    if [[ -z "$impl_family" ]]; then
        guard_fail "G-DIVERSITY: implementador_id '${impl_alias}' de ${rb_path} fora do mapa canonico ${MAP_PATH}"
        FAIL=1
        continue
    fi

    sim_families=""
    relevant_results=0
    while IFS= read -r result; do
        [[ -z "$result" ]] && continue
        family_rc=0
        family="$(family_for_result_if_sim "$result" "$rb_num")" || family_rc=$?
        if [[ "$family_rc" -eq 2 ]]; then
            FAIL=1
            continue
        fi
        if [[ "$family_rc" -eq 0 && -n "$family" ]]; then
            relevant_results=$((relevant_results + 1))
            sim_families="${sim_families}${family}"$'\n'
        fi
    done <<< "$ALL_RESULTS"

    distinct_non_impl="$(printf '%s' "$sim_families" | sed '/^[[:space:]]*$/d' | awk -v impl="$impl_family" '$0 != impl { seen[$0]=1 } END { for (f in seen) print f }' | sort)"
    distinct_count="$(printf '%s\n' "$distinct_non_impl" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')"
    if [[ "$distinct_count" -lt 2 ]]; then
        found="$(printf '%s' "$distinct_non_impl" | paste -sd ',' - 2>/dev/null || true)"
        [[ -n "$found" ]] || found="nenhuma"
        guard_fail "G-DIVERSITY: readback ${rb_num} tem ${distinct_count} familia(s) distinta(s) != implementador com APROVA SIM; exige >=2. Implementador=${impl_alias}/${impl_family}; familias_validas=${found}; results_SIM=${relevant_results}."
        FAIL=1
        continue
    fi
done <<< "$TARGETS"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Diversidade de auditoria satisfeita: cada readback tocado tem >=2 familias distintas != implementador com APROVA SIM."
exit 0
