#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/lib/common.sh
# Funções comuns aos hbn-guards. NÃO executar isolado — sourceado por scripts.
# =============================================================================

# ANSI colors (degradam graciosamente em terminal sem suporte)
if [[ -t 1 ]]; then
    C_RED=$'\033[0;31m'
    C_GREEN=$'\033[0;32m'
    C_YELLOW=$'\033[0;33m'
    C_BLUE=$'\033[0;34m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_END=$'\033[0m'
else
    C_RED="" ; C_GREEN="" ; C_YELLOW="" ; C_BLUE="" ; C_BOLD="" ; C_DIM="" ; C_END=""
fi

# Identificação do guard que chama (usar no início do script: GUARD_NAME="assert-canonical-root")
GUARD_NAME="${GUARD_NAME:-hbn-guard}"

guard_log() {
    echo "${C_DIM}[hbn-guards/${GUARD_NAME}]${C_END} $*" >&2
}

guard_ok() {
    echo "${C_GREEN}${C_BOLD}[hbn-guards/${GUARD_NAME}] ✓${C_END} $*" >&2
}

guard_warn() {
    echo "${C_YELLOW}${C_BOLD}[hbn-guards/${GUARD_NAME}] ⚠${C_END} $*" >&2
}

guard_fail() {
    echo "" >&2
    echo "${C_RED}${C_BOLD}[hbn-guards/${GUARD_NAME}] ✗ COMMIT BLOQUEADO${C_END}" >&2
    echo "${C_RED}  motivo:${C_END} $*" >&2
    echo "" >&2
}

# Retorna o caminho canônico esperado a partir de .hbn/canonical-root
guard_canonical_root() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
    if [[ -z "$repo_root" ]]; then
        echo ""
        return 1
    fi
    local f="${repo_root}/.hbn/canonical-root"
    if [[ ! -f "$f" ]]; then
        echo ""
        return 1
    fi
    # Lê primeira linha não vazia/não comentário
    grep -v '^\s*#' "$f" | grep -v '^\s*$' | head -1
}

# Bypass de emergência — alinhado com a convenção GLASSWING_BYPASS já existente.
# Parâmetro opcional: nome do guard (usado apenas em logs).
guard_check_bypass() {
    local name="${1:-${GUARD_NAME:-hbn-guard}}"
    if [[ "${HBN_GUARDS_BYPASS:-0}" == "1" ]]; then
        guard_warn "BYPASS ATIVO (HBN_GUARDS_BYPASS=1) em $name. Justifique no commit msg com [bypass-hbn-guards] e abra nota em .hbn/bypasses/."
        return 0
    fi
    if [[ "${GLASSWING_BYPASS:-0}" == "1" ]]; then
        guard_warn "BYPASS Glasswing detectado (GLASSWING_BYPASS=1) em $name. hbn-guards também respeita."
        return 0
    fi
    return 1
}
