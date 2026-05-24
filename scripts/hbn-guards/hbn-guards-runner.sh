#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/hbn-guards-runner.sh
# Orquestra todos os guards na ordem correta. Chamado pelo .git/hooks/pre-commit.
# Cada guard é independente e falha cedo (fail-fast). Logs claros.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -t 1 ]]; then
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_END=$'\033[0m'
else
    C_BOLD="" ; C_DIM="" ; C_END=""
fi

echo "${C_BOLD}[hbn-guards] Iniciando bateria de guards de governança…${C_END}" >&2

# Ordem importa: raiz canônica primeiro (se errada, nada do resto faz sentido).
GUARDS=(
    "assert-canonical-root.sh"
    "forbid-tmp-worktree.sh"
    "forbid-env-files.sh"
    "forbid-legacy-paths.sh"
    "assert-scope-lock.sh"
)

OVERALL=0
for g in "${GUARDS[@]}"; do
    echo "${C_DIM}---${C_END}" >&2
    if bash "${SCRIPT_DIR}/${g}"; then
        :
    else
        rc=$?
        OVERALL=$rc
        # Para nos primeiros erros para feedback rápido
        break
    fi
done

echo "${C_DIM}---${C_END}" >&2
if [[ $OVERALL -eq 0 ]]; then
    echo "${C_BOLD}[hbn-guards] Todos os guards passaram.${C_END}" >&2
else
    echo "${C_BOLD}[hbn-guards] Guards FALHARAM (código $OVERALL).${C_END}" >&2
fi
exit $OVERALL
