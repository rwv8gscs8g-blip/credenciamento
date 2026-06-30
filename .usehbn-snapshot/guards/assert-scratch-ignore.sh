#!/usr/bin/env bash
# =============================================================================
# guards/assert-scratch-ignore.sh
# G-SCRATCH-IGNORE: se .gitignore estiver staged, exige que a protecao da area
# efemera continue presente no blob staged: /scratch/ e !/scratch/README.md.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-scratch-ignore"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if ! get_canonical_root >/dev/null; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel mapear .gitignore com seguranca."
    exit 1
fi

GITIGNORE_PATH=".gitignore"
GITIGNORE_REPO_PATH="$(guard_version_repo_path "$GITIGNORE_PATH" || true)"
if [[ -z "$GITIGNORE_REPO_PATH" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel localizar .gitignore."
    exit 1
fi

gitignore_changed() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=ACMRD "${HBN_DIFF_BASE}...HEAD" -- "$GITIGNORE_REPO_PATH" 2>/dev/null \
            | grep -qxF "$GITIGNORE_REPO_PATH"
    else
        git diff --cached --name-only --diff-filter=ACMRD -- "$GITIGNORE_REPO_PATH" 2>/dev/null \
            | grep -qxF "$GITIGNORE_REPO_PATH"
    fi
}

if ! gitignore_changed; then
    guard_ok ".gitignore nao esta staged; protecao de scratch sem alteracao neste commit."
    exit 0
fi

gitignore_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${GITIGNORE_REPO_PATH}" 2>/dev/null
    else
        git show ":${GITIGNORE_REPO_PATH}" 2>/dev/null
    fi
}

if ! CONTENT="$(gitignore_content)"; then
    guard_fail ".gitignore staged ausente ou ilegivel. G-SCRATCH-IGNORE falha fechado."
    exit 1
fi

FAIL=0
if ! grep -qxF "/scratch/" <<< "$CONTENT"; then
    guard_fail ".gitignore staged perdeu a linha obrigatoria: /scratch/"
    FAIL=1
fi
if ! grep -qxF "!/scratch/README.md" <<< "$CONTENT"; then
    guard_fail ".gitignore staged perdeu a excecao obrigatoria: !/scratch/README.md"
    FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok ".gitignore preserva /scratch/ e !/scratch/README.md."
exit 0
