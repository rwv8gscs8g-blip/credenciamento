#!/usr/bin/env bash
# =============================================================================
# guards/assert-no-stray-hbn.sh
# path: guards/assert-no-stray-hbn.sh · id-global: 20260611-101851-fable-5-guard-no-stray-hbn
# Guarda G-STRAY: detecta `.hbn/` ÓRFÃO — diretório .hbn cujo pai NÃO é raiz
# de repositório git. Defesa direta contra o incidente opus-4-8 de 2026-06-11
# (orquestrador escreveu .hbn/results/ solto em ~/Projetos, fora de qualquer
# repo — invisível para todos os guards commit-time, porque escrita solta
# não passa por commit).
#
# REGRA: todo `.hbn/` deve morar ao lado de um `.git/` (raiz de worktree).
#   Legítimos hoje: usehbn/.hbn, Credenciamento/.hbn, MAURICIOZANIN-HUB/.hbn.
#   Órfão = bloqueio (no pre-commit) ou achado (no sweep).
#
# DUPLO USO (a escrita solta NÃO comita — o sweep é a única detecção):
#   1. No runner (pre-commit): roda a cada commit do canônico — varre o
#      diretório PAI da raiz canônica e bloqueia se houver órfão.
#   2. Sweep manual/agendado: `bash guards/assert-no-stray-hbn.sh --sweep`
#      (mesma checagem, saída verbosa; rode após qualquer sessão de IA).
#
# Parâmetros (env):
#   HBN_SCAN_ROOT       — raiz da varredura. Default: pai da raiz canônica
#                         (.hbn/canonical-root); senão, pai do git toplevel.
#   HBN_STRAY_ALLOWLIST — arquivo de globs permitidos (default:
#                         <toplevel>/.hbn/stray-allowlist, VERSIONADO).
#
# v2 (onda 0006 I-07 — F-04 dos cross-audits 0036 P4 / 0037 P4):
#   - fail-CLOSED: SCAN_ROOT indeterminado/inexistente = exit 1 no modo
#     guard (era exit 0 com aviso = bypass ambiental); --sweep mantém aviso.
#   - profundidade 6 (era 4 — órfão fundo passava).
#   - symlink chamado .hbn também é detectado (-type l).
#   - poda hardcoded de `backups` REMOVIDA → .hbn/stray-allowlist
#     (globs versionados, mudança com hearback; default */backups/*).
#
# status: accepted (readback 0005); v2 = onda 0006 (readback 0006).
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-STRAY), com
#   HBN_SCAN_ROOT apontando para árvore sintética (ADR-020).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-no-stray-hbn"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MODE="guard"
if [[ "${1:-}" == "--sweep" ]]; then
    MODE="sweep"
fi

# Raiz da varredura: HBN_SCAN_ROOT > pai da raiz canônica do repo (se existir
# localmente) > pai do git toplevel.
SCAN_ROOT="${HBN_SCAN_ROOT:-}"
if [[ -z "$SCAN_ROOT" ]]; then
    CANONICAL="$(guard_repo_canonical_root || true)"
    if [[ -n "$CANONICAL" && -d "$(dirname "$CANONICAL")" ]]; then
        SCAN_ROOT="$(dirname "$CANONICAL")"
    else
        TOPLEVEL="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
        [[ -n "$TOPLEVEL" ]] && SCAN_ROOT="$(dirname "$TOPLEVEL")"
    fi
fi

if [[ -z "$SCAN_ROOT" || ! -d "$SCAN_ROOT" ]]; then
    if [[ "$MODE" == "sweep" ]]; then
        guard_warn "Raiz de varredura indeterminada (HBN_SCAN_ROOT/canonical-root/toplevel). Varredura pulada — rode o sweep no Terminal do operador."
        exit 0
    fi
    guard_fail "Raiz de varredura indeterminada ou inexistente (HBN_SCAN_ROOT='${HBN_SCAN_ROOT:-}'). Fail-CLOSED no modo guard (F-04: SCAN_ROOT inválido era bypass ambiental). Corrija o ambiente ou rode --sweep no Terminal do operador."
    exit 1
fi

# Allowlist de globs (substitui a poda hardcoded de backups/ — F-04):
ALLOWLIST_FILE="${HBN_STRAY_ALLOWLIST:-}"
if [[ -z "$ALLOWLIST_FILE" ]]; then
    _TOP="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
    [[ -n "$_TOP" && -f "${_TOP}/.hbn/stray-allowlist" ]] && ALLOWLIST_FILE="${_TOP}/.hbn/stray-allowlist"
fi
is_allowlisted() {
    local d="$1" pat
    [[ -n "$ALLOWLIST_FILE" && -f "$ALLOWLIST_FILE" ]] || return 1
    while IFS= read -r pat; do
        [[ -z "$pat" || "$pat" =~ ^[[:space:]]*# ]] && continue
        pat="$(echo "$pat" | xargs)"
        # shellcheck disable=SC2053
        [[ "$d" == $pat ]] && return 0
    done < "$ALLOWLIST_FILE"
    return 1
}

real_dir() {
    if [[ -d "$1" ]]; then
        ( cd "$1" && pwd -P )
    else
        printf '%s\n' "$1"
    fi
}

ACTIVE_ROOT_REAL=""
ACTIVE_ROOT="$(get_canonical_root 2>/dev/null || true)"
[[ -n "$ACTIVE_ROOT" ]] && ACTIVE_ROOT_REAL="$(real_dir "$ACTIVE_ROOT")"

is_version_dir_name() {
    [[ "$1" =~ ^versao_[0-9]+_[0-9]+_[A-Za-z0-9]+$ ]]
}

is_valid_hbn_home() {
    local d="$1" parent grand parent_real
    parent="$(dirname "$d")"
    if [[ -e "${parent}/.git" ]]; then
        return 0
    fi
    parent_real="$(real_dir "$parent")"
    if [[ -n "$ACTIVE_ROOT_REAL" && "$parent_real" == "$ACTIVE_ROOT_REAL" ]]; then
        return 0
    fi
    grand="$(dirname "$parent")"
    if is_version_dir_name "$(basename "$parent")" && [[ -e "${grand}/.git" && -f "${grand}/.hbn/active-version" ]]; then
        return 0
    fi
    return 1
}

STRAYS=()
while IFS= read -r d; do
    [[ -z "$d" ]] && continue
    is_allowlisted "$d" && continue
    if ! is_valid_hbn_home "$d"; then
        STRAYS+=("$d")
    fi
done < <(find "$SCAN_ROOT" -maxdepth 6 \
            \( -name .git -o -name node_modules -o -name .venv \) -prune \
            -o \( -type d -o -type l \) -name ".hbn" -print 2>/dev/null)

if [[ ${#STRAYS[@]} -eq 0 ]]; then
    guard_ok "Nenhum .hbn órfão sob ${SCAN_ROOT} (todo .hbn mora em raiz de repo git)."
    exit 0
fi

guard_fail ".hbn ÓRFÃO detectado (escrita solta fora de repo git — o anti-padrão do incidente opus-4-8):"
for s in "${STRAYS[@]}"; do
    echo "    - $s  (pai sem .git: $(dirname "$s"))" >&2
done
echo "" >&2
echo "  Como corrigir:" >&2
echo "    1. Conteúdo útil? Mover para o .hbn do repo correto (ex.: ${SCAN_ROOT}/usehbn/.hbn/) + linha no REGISTRY" >&2
echo "    2. Vazio/lixo? Remover o diretório órfão" >&2
echo "    3. Registrar P0 em .hbn/readbacks/ se entregáveis nasceram no lugar errado" >&2
echo "    4. NUNCA usar HBN_GUARDS_BYPASS=1 para contornar esta regra" >&2
[[ "$MODE" == "sweep" ]] && echo "  (modo sweep: achado reportado; corrija e rode de novo)" >&2
exit 1
