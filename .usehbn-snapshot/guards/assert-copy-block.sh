#!/usr/bin/env bash
# =============================================================================
# guards/assert-copy-block.sh
# G-COPY: torna mecanico o contrato de bloco copiavel em artefatos novos.
#
# Escopo: arquivos ADICIONADOS em .hbn/messages/*.md e docs/prompts/*.md cujo
# front-matter tenha tipo: despacho|prompt. Valida o blob staged localmente
# (git show :path) e HEAD:path em CI com HBN_DIFF_BASE.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-copy-block"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

guard_added_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=A "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=A 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

blob_ref() {
    local p
    p="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$p"
    else
        printf ':%s\n' "$p"
    fi
}

map_ref() {
    local p
    p="$(guard_version_repo_path "guards/data/auditor-families.txt")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$p"
    else
        printf ':%s\n' "$p"
    fi
}

MAP_CONTENT="$(git show "$(map_ref)" 2>/dev/null || true)"
if [[ -z "$MAP_CONTENT" ]]; then
    guard_fail "Mapa de apelidos ausente/ilegivel em guards/data/auditor-families.txt."
    exit 1
fi

declare -a VALID_DESTS=()
while IFS= read -r raw; do
    line="${raw%%#*}"
    line="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^([A-Za-z0-9._-]+)[[:space:]]+[A-Za-z0-9._-]+$ ]]; then
        VALID_DESTS+=("${BASH_REMATCH[1]}")
    else
        guard_fail "Linha invalida no mapa guards/data/auditor-families.txt: ${line}"
        exit 1
    fi
done <<< "$MAP_CONTENT"
VALID_DESTS+=("codex" "human")

dest_is_valid() {
    local want="$1" item
    for item in "${VALID_DESTS[@]}"; do
        [[ "$item" == "$want" ]] && return 0
    done
    return 1
}

frontmatter_info() { # <file> -> "tipo<TAB>fm_end_line"; vazio se sem frontmatter
    local file="$1" line line_no=0 tipo="" fm_end=0 value
    while IFS= read -r line || [[ -n "$line" ]]; do
        line_no=$((line_no + 1))
        if [[ "$line_no" -eq 1 ]]; then
            [[ "$line" == "---" ]] || break
            continue
        fi
        if [[ "$line" == "---" ]]; then
            fm_end="$line_no"
            break
        fi
        if [[ "$line" =~ ^tipo:[[:space:]]*(.*)$ ]]; then
            value="${BASH_REMATCH[1]}"
            value="$(printf '%s' "$value" | sed -E 's/[[:space:]]+#.*$//; s/^[[:space:]]+//; s/[[:space:]]+$//; s/^["'"'"']//; s/["'"'"']$//')"
            tipo="$value"
        fi
    done < "$file"
    if [[ "$fm_end" -gt 0 ]]; then
        printf '%s\t%s\n' "$tipo" "$fm_end"
    fi
}

validate_copy_block() { # <path> <tmpfile> <fm_end_line>
    local path="$1" file="$2" fm_end="$3"
    local line line_no=0 begin_count=0 end_count=0 open=0 payload_nonempty=0
    local fail=0 dest=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_no=$((line_no + 1))
        [[ "$line_no" -le "$fm_end" ]] && continue

        if [[ "$line" =~ ^[[:space:]]*⟦HBN-COPY ]]; then
            if [[ "$line" =~ ^⟦HBN-COPY\ dest=([A-Za-z0-9._-]+)⟧\ BEGIN$ ]]; then
                begin_count=$((begin_count + 1))
                dest="${BASH_REMATCH[1]}"
                if [[ "$open" -eq 1 ]]; then
                    guard_fail "${path}: BEGIN de HBN-COPY antes de fechar o bloco anterior."
                    fail=1
                fi
                if ! dest_is_valid "$dest"; then
                    guard_fail "${path}: dest '${dest}' nao esta em guards/data/auditor-families.txt nem em {codex,human}."
                    fail=1
                fi
                open=1
                continue
            fi
            if [[ "$line" == "⟦HBN-COPY END⟧" ]]; then
                end_count=$((end_count + 1))
                if [[ "$open" -ne 1 ]]; then
                    guard_fail "${path}: END de HBN-COPY antes de BEGIN."
                    fail=1
                fi
                open=0
                continue
            fi
            guard_fail "${path}: linha sentinela HBN-COPY malformada na linha ${line_no}: ${line}"
            fail=1
            continue
        fi

        if [[ "$open" -eq 1 && "$line" =~ [^[:space:]] ]]; then
            payload_nonempty=1
        fi
    done < "$file"

    if [[ "$begin_count" -ne 1 || "$end_count" -ne 1 ]]; then
        guard_fail "${path}: esperado exatamente 1 bloco HBN-COPY; encontrados BEGIN=${begin_count}, END=${end_count}."
        fail=1
    fi
    if [[ "$open" -ne 0 ]]; then
        guard_fail "${path}: bloco HBN-COPY aberto sem END."
        fail=1
    fi
    if [[ "$payload_nonempty" -ne 1 ]]; then
        guard_fail "${path}: payload HBN-COPY vazio."
        fail=1
    fi

    [[ "$fail" -eq 0 ]]
}

ADDED="$(guard_added_files)"
if [[ -z "$ADDED" ]]; then
    guard_ok "Nenhum arquivo adicionado no diff."
    exit 0
fi

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        .hbn/messages/*.md|docs/prompts/*.md) ;;
        *) continue ;;
    esac

    ref="$(blob_ref "$f")"
    git cat-file -e "$ref" 2>/dev/null || continue

    tmp="$(mktemp)"
    if ! git show "$ref" > "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        guard_fail "${f}: blob staged/HEAD ilegivel."
        FAIL=1
        continue
    fi

    info="$(frontmatter_info "$tmp" || true)"
    if [[ -z "$info" ]]; then
        rm -f "$tmp"
        continue
    fi
    IFS=$'\t' read -r tipo fm_end <<< "$info"
    case "$tipo" in
        despacho|prompt) ;;
        *)
            rm -f "$tmp"
            continue
            ;;
    esac

    if ! validate_copy_block "$f" "$tmp" "$fm_end"; then
        FAIL=1
    fi
    rm -f "$tmp"
done <<< "$ADDED"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Todo despacho/prompt novo em .hbn/messages/ ou docs/prompts/ contem exatamente um bloco HBN-COPY valido."
exit 0
