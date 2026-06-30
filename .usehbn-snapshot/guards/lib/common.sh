#!/usr/bin/env bash
# =============================================================================
# guards/lib/common.sh
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
HBN_HOOK_SHIM_VERSION="M-A-20260614"

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

# Retorna a raiz do repositório Git.
guard_repo_root() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
    if [[ -z "$repo_root" ]]; then
        echo ""
        return 1
    fi
    echo "$repo_root"
}

# Retorna o caminho canônico esperado do repositório a partir de
# .hbn/canonical-root. Esse é o trilho físico do repo; a raiz operacional da
# versão ativa é resolvida por get_canonical_root().
guard_repo_canonical_root() {
    local repo_root
    repo_root="$(guard_repo_root)" || return 1
    local f="${repo_root}/.hbn/canonical-root"
    if [[ ! -f "$f" ]]; then
        echo ""
        return 1
    fi
    # Lê primeira linha não vazia/não comentário
    grep -v '^[[:space:]]*#' "$f" | grep -v '^[[:space:]]*$' | head -1
}

# Lê e valida .hbn/active-version. Política: exatamente uma versão ativa vence.
# Arquivo ausente, vazio, com conflito de merge ou apontando para path inseguro
# é estado inválido e deve falhar fechado.
guard_active_version_rel() {
    HBN_ACTIVE_VERSION_ERROR=""
    local repo_root pointer raw count value
    repo_root="$(guard_repo_root)" || {
        HBN_ACTIVE_VERSION_ERROR="não foi possível resolver a raiz do repositório Git"
        return 1
    }
    pointer="${repo_root}/.hbn/active-version"
    if [[ ! -r "$pointer" ]]; then
        HBN_ACTIVE_VERSION_ERROR="ponteiro ${pointer} ausente ou ilegível"
        return 1
    fi
    if grep -qE '^(<<<<<<<|=======|>>>>>>>)' "$pointer" 2>/dev/null; then
        HBN_ACTIVE_VERSION_ERROR="ponteiro ${pointer} contém marcador de conflito de merge; resolva manualmente para uma única versão ativa"
        return 1
    fi
    raw="$(grep -v '^[[:space:]]*#' "$pointer" | grep -v '^[[:space:]]*$' || true)"
    count="$(printf '%s\n' "$raw" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]')"
    if [[ "$count" != "1" ]]; then
        HBN_ACTIVE_VERSION_ERROR="ponteiro ${pointer} deve conter exatamente uma linha ativa; encontrou ${count}"
        return 1
    fi
    value="$(printf '%s\n' "$raw" | sed -n '1p' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    if [[ "$value" != "." && ! "$value" =~ ^versao_[0-9]+_[0-9]+_[A-Za-z0-9]+$ ]]; then
        HBN_ACTIVE_VERSION_ERROR="ponteiro ${pointer} aponta para valor inválido '${value}' (permitido: '.' ou versao_X_Y_Z)"
        return 1
    fi
    case "$value" in
        /*|*..*|*//*|*\\*|*" "*|*"	"*)
            HBN_ACTIVE_VERSION_ERROR="ponteiro ${pointer} contém path inseguro '${value}'"
            return 1
            ;;
    esac
    printf '%s\n' "$value"
}

# API pedida pela onda M-A: raiz canônica = raiz da versão ativa.
get_canonical_root() {
    local repo_root rel root
    repo_root="$(guard_repo_root)" || return 1
    rel="$(guard_active_version_rel)" || return 1
    if [[ "$rel" == "." ]]; then
        root="$repo_root"
    else
        root="${repo_root}/${rel}"
    fi
    if [[ ! -d "$root" ]]; then
        HBN_ACTIVE_VERSION_ERROR="ponteiro .hbn/active-version aponta para versão inexistente: ${rel}"
        return 1
    fi
    ( cd "$root" && pwd -P )
}

# Compatibilidade com os guards existentes: agora retorna a raiz da versão ativa.
guard_canonical_root() {
    get_canonical_root
}

guard_active_version_prefix() {
    local rel
    rel="$(guard_active_version_rel)" || return 1
    if [[ "$rel" == "." ]]; then
        echo ""
    else
        printf '%s/' "$rel"
    fi
}

# Converte path relativo à versão ativa para path relativo ao repo Git.
guard_version_repo_path() {
    local p="$1" rel
    case "$p" in
        /*) printf '%s\n' "$p"; return 0 ;;
    esac
    rel="$(guard_active_version_rel)" || return 1
    if [[ "$rel" == "." ]]; then
        printf '%s\n' "$p"
    else
        printf '%s/%s\n' "$rel" "$p"
    fi
}

# Converte path relativo ao repo Git para path relativo à versão ativa.
guard_repo_path_to_version_path() {
    local p="$1" prefix
    prefix="$(guard_active_version_prefix)" || return 1
    if [[ -n "$prefix" && "$p" == "$prefix"* ]]; then
        printf '%s\n' "${p#"$prefix"}"
    else
        printf '%s\n' "$p"
    fi
}

guard_paths_to_version_paths() {
    local p
    while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        guard_repo_path_to_version_path "$p"
    done
}

guard_hook_path() {
    local hook="$1" repo_root p
    repo_root="$(guard_repo_root)" || return 1
    p="$(git rev-parse --git-path "hooks/${hook}" 2>/dev/null || echo "")"
    [[ -z "$p" ]] && return 1
    case "$p" in
        /*) printf '%s\n' "$p" ;;
        *) printf '%s/%s\n' "$repo_root" "$p" ;;
    esac
}

guard_check_hooks_current() {
    local hook path fail=0
    for hook in pre-commit commit-msg; do
        path="$(guard_hook_path "$hook" || true)"
        if [[ -z "$path" || ! -f "$path" ]]; then
            guard_fail "Hook ${hook} ausente em .git/hooks. Clone sem onboarding não tem enforcement; instale o shim HBN antes de operar."
            fail=1
            continue
        fi
        if [[ ! -x "$path" ]]; then
            guard_fail "Hook ${hook} existe mas não é executável: ${path}"
            fail=1
        fi
        if ! grep -q "HBN_HOOK_SHIM_VERSION=${HBN_HOOK_SHIM_VERSION}" "$path" 2>/dev/null; then
            guard_fail "Hook ${hook} desatualizado: falta marcador HBN_HOOK_SHIM_VERSION=${HBN_HOOK_SHIM_VERSION}. Reinstale o shim version-aware."
            fail=1
        fi
    done
    [[ "$fail" -eq 0 ]]
}

# Bypass de emergência — alinhado com a convenção GLASSWING_BYPASS já existente.
# Parâmetro opcional: nome do guard (usado apenas em logs).
#
# F-10 (onda 0006 I-06, cross-audit 0036 P1 / 0037 P1): a env de bypass só
# surte efeito se houver NOTA ADICIONADA em .hbn/bypasses/ no MESMO diff
# staged (formato <AAAAMMDD-HHMMSS>-<agente>-<motivo>.md). Env sem nota =
# bypass IGNORADO: os guards rodam normalmente, com aviso. Era a ironia
# apontada pelos auditores: o mecanismo da auditoria anti-burla (Glasswing)
# era ele mesmo uma burla silenciosa. CI: nota de bypass sem hearback
# correspondente = achado (auditoria de trailers, runbook).
guard_check_bypass() {
    local name="${1:-${GUARD_NAME:-hbn-guard}}"
    local envname=""
    if [[ "${HBN_GUARDS_BYPASS:-0}" == "1" ]]; then
        envname="HBN_GUARDS_BYPASS"
    elif [[ "${GLASSWING_BYPASS:-0}" == "1" ]]; then
        envname="GLASSWING_BYPASS"
    fi
    [[ -z "$envname" ]] && return 1
    local notes
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        notes="$(git diff --name-only --diff-filter=A "${HBN_DIFF_BASE}...HEAD" 2>/dev/null \
            | grep -E '^\.hbn/bypasses/[0-9]{8}-[0-9]{6}-[A-Za-z0-9._-]+\.md$' || true)"
    else
        notes="$(git diff --cached --name-only --diff-filter=A 2>/dev/null \
            | grep -E '^\.hbn/bypasses/[0-9]{8}-[0-9]{6}-[A-Za-z0-9._-]+\.md$' || true)"
    fi
    if [[ -n "$notes" ]]; then
        guard_warn "BYPASS ATIVO (${envname}=1) em $name COM nota staged: $(echo "$notes" | xargs). Hearback humano obrigatório na adoção; CI cruza nota×hearback."
        return 0
    fi
    guard_warn "${envname}=1 IGNORADO em $name: nenhuma nota ADICIONADA em .hbn/bypasses/<carimbo>-<agente>-<motivo>.md neste diff (F-10, onda 0006). Guards rodam normalmente."
    return 1
}

# Arquivos sob analise: staged (pre-commit local) OU range de CI.
# Em CI, exporte HBN_DIFF_BASE=<sha base> (o Shield faz isso) para validar
# o range pushed em vez do index (vazio em CI).
guard_diff_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=ACMR "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true
    fi | guard_paths_to_version_paths
}
