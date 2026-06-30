#!/usr/bin/env bash
# =============================================================================
# guards/forbid-legacy-paths.sh
# Guarda G-LEG: recusa commit que TOQUE caminhos declaradamente legados,
# preservando-os apenas como histórico. Lista carregada de
# .hbn/forbidden-paths.txt — uma linha = um glob ou caminho exato.
# Comentários começam com #.
# =============================================================================
set -euo pipefail

GUARD_NAME="forbid-legacy-paths"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

ACTIVE_ROOT="$(get_canonical_root || true)"
if [[ -z "$ACTIVE_ROOT" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar forbidden-paths da versão ativa."
    exit 1
fi
FORBIDDEN_FILE="${ACTIVE_ROOT}/.hbn/forbidden-paths.txt"

if [[ ! -f "$FORBIDDEN_FILE" ]]; then
    guard_log "Sem .hbn/forbidden-paths.txt — guard sem alvos, liberando."
    exit 0
fi

STAGED="$(guard_diff_files)"
if [[ -z "$STAGED" ]]; then
    guard_ok "Sem arquivos staged."
    exit 0
fi

# Carrega padrões (uma linha por padrão, ignora vazias e comentários)
PATTERNS=()
while IFS= read -r line; do
    line="${line%%#*}"   # tira comentário inline
    line="${line## }"    # trim leading spaces
    line="${line%% }"    # trim trailing spaces
    [[ -z "$line" ]] && continue
    PATTERNS+=("$line")
done < "$FORBIDDEN_FILE"

if [[ ${#PATTERNS[@]} -eq 0 ]]; then
    guard_ok "Lista de caminhos proibidos vazia."
    exit 0
fi

FAIL=0
VIOLATIONS=()

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    for pat in "${PATTERNS[@]}"; do
        # bash glob match (case sensitive)
        # shellcheck disable=SC2053
        if [[ "$f" == $pat ]]; then
            VIOLATIONS+=("$f (casa proibição: $pat)")
            FAIL=1
            break
        fi
    done
done <<< "$STAGED"

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Nenhum arquivo em caminhos legacy."
    exit 0
fi

echo "  Arquivos bloqueados (em paths legacy):" >&2
for v in "${VIOLATIONS[@]}"; do
    echo "    - $v" >&2
done
echo "" >&2
echo "  Como corrigir:" >&2
echo "    1. Mover para path canônico (ver AGENTS.md §estrutura)" >&2
echo "    2. Se precisa PRESERVAR como histórico: git rm --cached e deixar fisicamente intocado" >&2
echo "    3. Lista de proibições: .hbn/forbidden-paths.txt" >&2
exit 1
