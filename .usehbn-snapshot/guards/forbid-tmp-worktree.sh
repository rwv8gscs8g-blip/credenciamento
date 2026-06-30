#!/usr/bin/env bash
# =============================================================================
# guards/forbid-tmp-worktree.sh
# Guarda G-TMP: verifica `git worktree list` e recusa se houver QUALQUER worktree
# em /tmp, /private/tmp, /var/tmp ou subdiretórios de Downloads/Trash.
# Mesmo que o pre-commit esteja sendo executado da raiz correta, um worktree
# ativo em tmp é vetor para drift entre IAs.
# =============================================================================
set -euo pipefail

GUARD_NAME="forbid-tmp-worktree"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

# git worktree list pode falhar se o repo for shallow ou estranho — toleramos.
WORKTREES="$(git worktree list --porcelain 2>/dev/null || true)"
if [[ -z "$WORKTREES" ]]; then
    guard_ok "Nenhum worktree registrado (ok)."
    exit 0
fi

# Extrai apenas linhas "worktree <path>"
PATHS="$(echo "$WORKTREES" | awk '/^worktree /{print $2}')"

FAIL=0
while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    case "$p" in
        /tmp/*|/private/tmp/*|/var/tmp/*|*/Downloads/*|*/.Trash/*)
            guard_fail "Worktree proibido detectado: $p"
            FAIL=1
            ;;
    esac
done <<< "$PATHS"

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Nenhum worktree em /tmp ou áreas voláteis."
    exit 0
fi

echo "  Como corrigir:" >&2
echo "    1. Listar worktrees:        git worktree list" >&2
echo "    2. Remover worktree tmp:    git worktree remove --force <path>" >&2
echo "    3. Garantir que a branch ativa esteja na raiz canônica" >&2
exit 1
