#!/usr/bin/env bash
# =============================================================================
# guards/assert-scratch-symlink.sh
# G-SCRATCH-SYMLINK: bloqueia qualquer entrada staged sob scratch/ com modo Git
# 120000 (symlink). Fecha o vetor de link escapando da area efemera.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-scratch-symlink"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if ! get_canonical_root >/dev/null; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel mapear scratch/ com seguranca."
    exit 1
fi

scratch_diff_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=ACMRD "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=ACMRD 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

is_staged_symlink() {
    local file="$1" repo_file
    repo_file="$(guard_version_repo_path "$file" || echo "")"
    [[ -z "$repo_file" ]] && return 1

    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r HEAD -- "$repo_file" 2>/dev/null | grep -q '^120000[[:space:]]'
    else
        git ls-files --stage -- "$repo_file" 2>/dev/null | grep -q '^120000[[:space:]]'
    fi
}

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        scratch/*)
            if is_staged_symlink "$f"; then
                guard_fail "Symlink staged proibido sob scratch/: ${f}."
                FAIL=1
            fi
            ;;
    esac
done <<< "$(scratch_diff_files)"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Nenhum symlink staged sob scratch/."
exit 0
