#!/usr/bin/env bash
# =============================================================================
# guards/assert-knowledge-index.sh
# path: guards/assert-knowledge-index.sh
# G-KNOW-INDEX: garante que toda entrada .hbn/knowledge/*.md esteja citada no
# .hbn/knowledge/INDEX.md. O INDEX e ponteiro vivo, nao inventario manual
# opcional: omissao vira bloqueio.
#
# Padrao dos guards C3: localmente le o indice staged; em CI le HEAD no range
# validado por HBN_DIFF_BASE. A working tree solta nao conta.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-knowledge-index"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

INDEX_PATH=".hbn/knowledge/INDEX.md"
KNOWLEDGE_DIR=".hbn/knowledge"
INDEX_REPO_PATH="$(guard_version_repo_path "$INDEX_PATH" || true)"
KNOWLEDGE_REPO_DIR="$(guard_version_repo_path "$KNOWLEDGE_DIR" || true)"

if [[ -z "$INDEX_REPO_PATH" || -z "$KNOWLEDGE_REPO_DIR" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar a knowledge base."
    exit 1
fi

index_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${INDEX_REPO_PATH}" 2>/dev/null
    else
        git show ":${INDEX_REPO_PATH}" 2>/dev/null
    fi
}

knowledge_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r --name-only HEAD -- "$KNOWLEDGE_REPO_DIR" 2>/dev/null || true
    else
        git ls-files --cached -- "$KNOWLEDGE_REPO_DIR" 2>/dev/null || true
    fi | guard_paths_to_version_paths \
        | grep -E '^\.hbn/knowledge/[^/]+\.md$' \
        | sort -u || true
}

regex_escape() {
    sed 's/[][\.^$*+?(){}|]/\\&/g'
}

index_has_token() { # <basename>
    local base="$1" esc
    esc="$(printf '%s' "$base" | regex_escape)"
    grep -qE '(^|[ /|`])'"${esc}"'($|[ /|`])' <<< "$INDEX_CONTENT"
}

index_referenced_knowledge_basenames() {
    printf '%s\n' "$INDEX_CONTENT" \
        | awk -F'|' '/^[[:space:]]*\|/ { print $2 }' \
        | grep -Eo '(^|[ /|`])[0-9]{4}-[A-Za-z0-9._-]+\.md($|[ /|`])' \
        | sed -E 's#^[ /|`]+##; s#[ /|`]+$##' \
        | sort -u || true
}

if ! INDEX_CONTENT="$(index_content)"; then
    guard_fail "INDEX da knowledge ausente ou ilegível no índice/HEAD: ${INDEX_PATH}. G-KNOW-INDEX falha fechado."
    exit 1
fi

FAIL=0
COUNT=0
KNOWLEDGE_FILES="$(knowledge_files)"
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    base="$(basename "$f")"
    [[ "$base" == "INDEX.md" ]] && continue
    COUNT=$((COUNT + 1))
    if ! index_has_token "$base"; then
        guard_fail "Entrada de knowledge sem citação no INDEX: ${f}. Adicione '${base}' em ${INDEX_PATH} no mesmo commit."
        FAIL=1
    fi
done <<< "$KNOWLEDGE_FILES"

while IFS= read -r base; do
    [[ -z "$base" ]] && continue
    if ! grep -qxF "${KNOWLEDGE_DIR}/${base}" <<< "$KNOWLEDGE_FILES"; then
        guard_fail "INDEX cita knowledge inexistente no índice/HEAD: ${KNOWLEDGE_DIR}/${base}. Remova o ponteiro morto ou adicione o arquivo no mesmo commit."
        FAIL=1
    fi
done <<< "$(index_referenced_knowledge_basenames)"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "INDEX da knowledge cita todas as entradas .md (${COUNT})."
exit 0
