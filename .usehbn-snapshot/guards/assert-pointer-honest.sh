#!/usr/bin/env bash
# =============================================================================
# guards/assert-pointer-honest.sh
# path: guards/assert-pointer-honest.sh · id-global: 20260610-205330-fable-5-guard-pointer-honest
# Guarda G-PTR: dá dente ao ADR-024 Decisão 3 (Ponteiro HBN não mente).
# Spec normativa: core/pointer-spec.md §3.
#   (1) BLOQUEADOR: path do texto do ponteiro não existe na revisão STAGED
#       (git cat-file -e :<path>; HEAD:<path> em CI) — herda E-FECH-01/02.
#   (2) BLOQUEADOR: destino existe mas declara `path:` ≠ path do ponteiro
#       (auto-localização e ponteiro divergem — um dos dois mente; ADR-021).
#   (3) BLOQUEADOR: linha ⟦HBN⟧ sem `ação:` (ponteiro sem gesto transfere o
#       custo ao receptor — anti-padrão "leia estes 7 documentos").
#   (4) AVISO: href absoluto cuja cauda não termina no path relativo do texto.
#
# status: accepted (adoção orquestração-start, readback 0004) — FORA do runner.
# Escopo (pointer-spec §3, gatilho): arquivos .md staged em .hbn/messages/ e
#   docs/prompts/ (handoffs, relatos, prompts). Specs/ADRs ficam FORA do
#   gatilho de propósito: carregam exemplos e templates de ponteiro em code
#   fence que não são ponteiros reais.
# Formas aceitas (pointer-spec §1 e §2.4):
#   ⟦HBN⟧ [<path>](<href>) · sinal: … · ação: …      (canônica)
#   ⟦HBN⟧ <path> · sinal: … · ação: …                (degradada, sem href)
# `path:` do destino: front-matter YAML em .md; chave top-level em .json
#   (mesma extração do G-SLF). Outras extensões: só regras 1, 3 e 4.
# FIX cross-audit 0031 F-02: linhas dentro de code-fence markdown (``` ou
#   ~~~) são IGNORADAS na varredura de ⟦HBN⟧ — exemplos/templates de
#   ponteiro em documentação não são ponteiros reais (evita falso-positivo).
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-PTR).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-pointer-honest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

blob_ref() {
    local p
    p="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$p"
    else
        echo ":$p"
    fi
}

# Mesma extração do G-SLF (ADR-021): path: do primeiro front-matter YAML.
fm_declared_path() {
    awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' \
        | grep -E '^path:' | head -1 \
        | sed -E 's/^path:[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//; s/[[:space:]]+$//' \
        || true
}

json_declared_path() {
    python3 -c '
import json, sys
try:
    v = json.load(sys.stdin).get("path", "")
    print(v if isinstance(v, str) else "")
except Exception:
    print("")
' || true
}

MARKER='⟦HBN⟧'
FAIL=0

CHANGED="$(guard_diff_files)"
if [[ -z "$CHANGED" ]]; then
    guard_ok "Nenhum arquivo no diff."
    exit 0
fi

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        .hbn/messages/*.md|docs/prompts/*.md) ;;
        *) continue ;;
    esac
    ref="$(blob_ref "$f")"
    git cat-file -e "$ref" 2>/dev/null || continue
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        # Regra 3: ação obrigatória na própria linha.
        if [[ "$line" != *"ação:"* ]]; then
            guard_fail "Ponteiro sem ação em '${f}': '${line}' — todo ⟦HBN⟧ termina com o gesto do leitor (pointer-spec §3.3)."
            FAIL=1
        fi
        # Extrai o path: forma canônica [path](href) ou degradada (token nu).
        ptr_path="" ; href=""
        after="${line#*"$MARKER"}"
        after="${after# }"
        if [[ "$after" == \[* ]]; then
            ptr_path="${after#\[}" ; ptr_path="${ptr_path%%\]*}"
            rest="${after#*\]}"
            if [[ "$rest" == \(* ]]; then
                href="${rest#\(}" ; href="${href%%\)*}"
            fi
        else
            ptr_path="${after%% *}"
        fi
        if [[ -z "$ptr_path" ]]; then
            guard_fail "Linha ⟦HBN⟧ sem path extraível em '${f}': '${line}' (pointer-spec §1)."
            FAIL=1
            continue
        fi
        # Regra 1: o path precisa existir na revisão staged (não na working tree).
        dref="$(blob_ref "$ptr_path")"
        if ! git cat-file -e "$dref" 2>/dev/null; then
            guard_fail "Ponteiro mentiroso em '${f}': destino '${ptr_path}' NÃO existe na revisão staged (pointer-spec §3.1; E-FECH-01/02: working tree não conta — git add o destino ou corrija o path)."
            FAIL=1
            continue
        fi
        # Regra 2: path do ponteiro == path: declarado pelo destino (quando declara).
        declared=""
        case "$ptr_path" in
            *.md)   declared="$(git show "$dref" 2>/dev/null | fm_declared_path)" ;;
            *.json) declared="$(git show "$dref" 2>/dev/null | json_declared_path)" ;;
        esac
        if [[ -n "$declared" && "$declared" != "$ptr_path" ]]; then
            guard_fail "Ponteiro × auto-localização divergem em '${f}': ponteiro diz '${ptr_path}', destino declara path: '${declared}' — um dos dois mente (pointer-spec §3.2; ADR-021)."
            FAIL=1
        fi
        # Regra 4 (AVISO): cauda do href ≠ path relativo do texto.
        if [[ -n "$href" && "$href" == file://* ]]; then
            href_sem_frag="${href%%#*}"
            if [[ "$href_sem_frag" != *"$ptr_path" ]]; then
                guard_warn "href '${href}' não termina no path relativo '${ptr_path}' em '${f}' (pointer-spec §3.4 — href apontando para arquivo diferente do declarado)."
            fi
        fi
    done <<< "$(git show "$ref" 2>/dev/null | awk -v m="$MARKER" '
        /^[[:space:]]*(```|~~~)/ { infence = !infence; next }
        !infence && index($0, m) { print }
    ' || true)"
done <<< "$CHANGED"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Todo ponteiro ⟦HBN⟧ staged aponta para destino existente, coerente com o path: declarado, e carrega ação."
exit 0
