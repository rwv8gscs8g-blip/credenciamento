#!/usr/bin/env bash
# =============================================================================
# guards/assert-frontdoor.sh
# G-FRONTDOOR: garante que core/role-cards.md continue sendo a porta da frente
# minima: arquivo presente/legivel, teto anti-monolito e read-list limitada.
# Le o blob staged localmente e HEAD em CI; working tree solta nao conta.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-frontdoor"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

ROLE_CARDS_PATH="core/role-cards.md"
MAX_LINES=140
MAX_BYTES=8192

blob_ref() {
    local p
    p="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$p"
    else
        echo ":$p"
    fi
}

ROLE_REF="$(blob_ref "$ROLE_CARDS_PATH" || true)"
if [[ -z "$ROLE_REF" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel localizar ${ROLE_CARDS_PATH}."
    exit 1
fi

if ! git cat-file -e "$ROLE_REF" 2>/dev/null; then
    guard_fail "Porta da frente ausente no indice/HEAD: ${ROLE_CARDS_PATH}."
    exit 1
fi

BYTE_COUNT="$(git cat-file -s "$ROLE_REF" 2>/dev/null || echo 0)"
if [[ "${BYTE_COUNT:-0}" -gt "$MAX_BYTES" ]]; then
    guard_fail "${ROLE_CARDS_PATH} excede o teto anti-monolito: ${BYTE_COUNT} bytes (maximo ${MAX_BYTES})."
    exit 1
fi

CONTENT="$(git show "$ROLE_REF" 2>/dev/null || true)"
if [[ -z "$CONTENT" ]]; then
    guard_fail "Porta da frente ilegivel no indice/HEAD: ${ROLE_CARDS_PATH}."
    exit 1
fi

LINE_COUNT="$(printf '%s\n' "$CONTENT" | wc -l | tr -d '[:space:]')"
if [[ "${LINE_COUNT:-0}" -gt "$MAX_LINES" ]]; then
    guard_fail "${ROLE_CARDS_PATH} excede o teto anti-monolito: ${LINE_COUNT} linhas (maximo ${MAX_LINES})."
    exit 1
fi

if ! READLIST_BLOCK="$(printf '%s\n' "$CONTENT" | awk '
    /^##[[:space:]]+PARTE A[[:space:]-]/ { in_part = 1; seen = 1; next }
    /^##[[:space:]]+PARTE B[[:space:]-]/ { in_part = 0 }
    in_part { print }
    END {
        if (!seen) {
            exit 2
        }
    }
')"; then
    guard_fail "Secao 'PARTE A - READ-LIST DA PORTA DA FRENTE' ausente em ${ROLE_CARDS_PATH}."
    exit 1
fi

path_exists_in_commit() { # <path relativo a versao ativa>
    local p="$1" repo_path ref
    repo_path="$(guard_version_repo_path "$p")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        ref="HEAD:${repo_path}"
    else
        ref=":${repo_path}"
    fi
    git cat-file -e "$ref" 2>/dev/null
}

FAIL=0
READLIST_ITEMS=0
while IFS= read -r line; do
    trimmed="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -z "$trimmed" ]] && continue
    if ! grep -Eq '^([0-9]+\.|-|\*) ' <<< "$trimmed"; then
        if grep -Eq '^([0-9]+\.|-|\*)' <<< "$trimmed"; then
            guard_fail "Read-list da porta da frente contem marcador sem espaco: '${trimmed}'. Use '1. ', '- ' ou '* ' no inicio da linha."
            FAIL=1
        elif grep -Eq '^(\+|[0-9]+\)) ' <<< "$trimmed"; then
            guard_fail "Read-list da porta da frente contem marcador nao mapeado: '${trimmed}'. Use '1. ', '- ' ou '* ' no inicio da linha."
            FAIL=1
        elif grep -Eq '(^| )([0-9]+\.|-|\*) ' <<< "$trimmed"; then
            guard_fail "Read-list da porta da frente contem marcador inline: '${trimmed}'. Cada item deve ocupar sua propria linha."
            FAIL=1
        elif grep -Eq '(\.hbn/[A-Za-z0-9_./-]+|core/[A-Za-z0-9_./-]+|guards/[A-Za-z0-9_./-]+|schemas/[A-Za-z0-9_./-]+)' <<< "$trimmed"; then
            guard_fail "Read-list da porta da frente contem path concreto fora de item mapeado: '${trimmed}'. Paths da read-list devem ficar em linhas '1. ', '- ' ou '* '."
            FAIL=1
        fi
        continue
    fi
    READLIST_ITEMS=$((READLIST_ITEMS + 1))
    if grep -Eq '(^| )([0-9]+\.|-|\*) ' <<< "${trimmed#* }"; then
        guard_fail "Read-list da porta da frente contem marcador inline na mesma linha: '${trimmed}'. Cada item deve ocupar sua propria linha."
        FAIL=1
    fi
    while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        p="${p%.}"
        p="${p%,}"
        if ! path_exists_in_commit "$p"; then
            guard_fail "Read-list da porta da frente cita path inexistente no indice/HEAD: ${p}."
            FAIL=1
        fi
    done <<< "$(grep -Eo '(\.hbn/[A-Za-z0-9_./-]+|core/[A-Za-z0-9_./-]+|guards/[A-Za-z0-9_./-]+|schemas/[A-Za-z0-9_./-]+)' <<< "$trimmed" | sort -u || true)"
done <<< "$READLIST_BLOCK"

if [[ "$READLIST_ITEMS" -eq 0 ]]; then
    guard_fail "Read-list da porta da frente nao tem itens mapeados em ${ROLE_CARDS_PATH}."
    FAIL=1
fi

if [[ "$READLIST_ITEMS" -gt 6 ]]; then
    guard_fail "Read-list da porta da frente tem ${READLIST_ITEMS} itens (maximo 6)."
    FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Porta da frente OK: ${LINE_COUNT} linhas, ${BYTE_COUNT} bytes; read-list com ${READLIST_ITEMS} item(ns)."
exit 0
