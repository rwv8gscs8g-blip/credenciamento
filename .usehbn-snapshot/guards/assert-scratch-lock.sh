#!/usr/bin/env bash
# =============================================================================
# guards/assert-scratch-lock.sh
# G-SCRATCH-LOCK: bloqueia qualquer path staged sob scratch/ que nao seja
# exatamente scratch/README.md. A area de rascunho e efemera e deny-by-default:
# nada ali deve vazar para o historico/origin.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-scratch-lock"
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

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        scratch/README.md) ;;
        scratch/*)
            guard_fail "Path staged proibido sob scratch/: ${f}. Apenas scratch/README.md pode entrar no historico."
            FAIL=1
            ;;
    esac
done <<< "$(scratch_diff_files)"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Nenhum path proibido staged sob scratch/."
exit 0
