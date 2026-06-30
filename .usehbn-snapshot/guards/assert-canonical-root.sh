#!/usr/bin/env bash
# =============================================================================
# guards/assert-canonical-root.sh
# Guarda G-CR: recusa qualquer operação fora da raiz canônica declarada em
# .hbn/canonical-root. Defesa direta contra os incidentes de 2026-05-02 e
# 2026-05-24 (IA escrevendo em /private/tmp ou em pasta paralela).
#
# Onda 0006 (F-05, cross-audit 0036 P6 / 0037 P6):
#   - skip de CI só com GITHUB_ACTIONS=true E HBN_DIFF_BASE não-vazio;
#     CI=true solto em pre-commit local = FAIL (era o bypass do readback 0005).
#   - .hbn/alt-roots: raízes alternativas autorizadas (sandbox Cowork etc.),
#     versionado, mudança só com hearback. MODELO DE CONFIANÇA (declarado):
#     alt-roots é lido da working tree local, o MESMO modelo do próprio
#     .hbn/canonical-root — quem pode forjar um, pode forjar o outro; a
#     trava real é o arquivo ser VERSIONADO (drift visível em diff) e a
#     auditoria de trailers/CI. Não é trava criptográfica.
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-CR), incluindo
#   CI=true local → BLOCK; alt-root autorizada → PASS; divergente → BLOCK.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-canonical-root"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

# Em CI a raiz canonica e invariante da maquina do operador, nao do runner.
# F-05 (cross-audit 0036 P6 / 0037 P6, onda 0006): o skip exige contexto REAL
# de CI — marcador do provedor (GITHUB_ACTIONS=true) E range de diff
# (HBN_DIFF_BASE não-vazio, exportado pelo Shield). `CI=true` solto em
# pre-commit local era bypass trivial (usado de fato nos commits do readback
# 0005) e agora é FAIL explícito.
if [[ "${GITHUB_ACTIONS:-}" == "true" && -n "${HBN_DIFF_BASE:-}" ]]; then
    guard_ok "CI real (GITHUB_ACTIONS=true + HBN_DIFF_BASE) — raiz canônica é invariante da máquina do operador; checagem delegada ao pre-commit local."
    exit 0
fi
if [[ "${CI:-}" == "true" ]]; then
    guard_fail "CI=true fora de contexto real de CI (exige GITHUB_ACTIONS=true E HBN_DIFF_BASE) é bypass — F-05 do cross-audit 0036/0037. Se você é um sandbox legítimo, registre a raiz em .hbn/alt-roots (arquivo versionado; mudança só com hearback humano). NUNCA exporte CI=true para commitar localmente."
    exit 1
fi

REPO_CANONICAL="$(guard_repo_canonical_root)"
if [[ -z "$REPO_CANONICAL" ]]; then
    guard_fail "Arquivo .hbn/canonical-root ausente ou ilegível na raiz do repo. Não é possível validar a raiz canônica."
    exit 1
fi
ACTIVE_ROOT="$(get_canonical_root || true)"
if [[ -z "$ACTIVE_ROOT" ]]; then
    guard_fail "Ponteiro .hbn/active-version inválido: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Conflito/ausência/corrupção do ponteiro é fail-closed até resolução manual explícita."
    exit 1
fi

# pwd resolvido (segue symlinks; SMB mounts são resolvidos via realpath/-P)
PWD_REAL="$(pwd -P 2>/dev/null || pwd)"
TOPLEVEL_REAL="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
# Resolve symlinks no toplevel também (macOS pode reportar /private/tmp como /tmp)
if [[ -d "$TOPLEVEL_REAL" ]]; then
    TOPLEVEL_REAL="$(cd "$TOPLEVEL_REAL" && pwd -P)"
fi

# Normaliza canonical para resolver symlinks também
if [[ -d "$REPO_CANONICAL" ]]; then
    REPO_CANONICAL_REAL="$(cd "$REPO_CANONICAL" && pwd -P)"
else
    REPO_CANONICAL_REAL="$REPO_CANONICAL"
fi
ACTIVE_ROOT_REAL="$(cd "$ACTIVE_ROOT" && pwd -P)"

# Raízes ALTERNATIVAS autorizadas (.hbn/alt-roots — onda 0006, F-05):
# uma raiz absoluta ou glob bash por linha; arquivo VERSIONADO; mudança só
# com hearback humano. Toplevel ∈ {canonical} ∪ alt-roots = OK. Arquivo
# ausente ou vazio ⇒ só a canônica vale (fail-closed).
matches_alt_root() {
    local top="$1" alt_file="${TOPLEVEL_REAL}/.hbn/alt-roots" pat
    [[ -f "$alt_file" ]] || return 1
    while IFS= read -r pat; do
        [[ -z "$pat" || "$pat" =~ ^[[:space:]]*# ]] && continue
        pat="$(echo "$pat" | xargs)"
        # shellcheck disable=SC2053
        if [[ "$top" == $pat ]]; then
            return 0
        fi
    done < "$alt_file"
    return 1
}

FAIL=0
ALT=0
if [[ "$TOPLEVEL_REAL" != "$REPO_CANONICAL_REAL" ]]; then
    if matches_alt_root "$TOPLEVEL_REAL"; then
        ALT=1
        guard_warn "Raiz ALTERNATIVA autorizada por .hbn/alt-roots: $TOPLEVEL_REAL (≠ canônica $REPO_CANONICAL_REAL). Rastreável — ver hearback que autorizou a entrada."
    else
        guard_fail "git toplevel ($TOPLEVEL_REAL) ≠ raiz canônica do repo ($REPO_CANONICAL_REAL) e não consta em .hbn/alt-roots."
        FAIL=1
    fi
fi

case "${ACTIVE_ROOT_REAL}/" in
    "${TOPLEVEL_REAL}/"*) ;;
    *)
        guard_fail "Raiz da versão ativa (${ACTIVE_ROOT_REAL}) está fora do repo Git (${TOPLEVEL_REAL}). Ponteiro .hbn/active-version inválido."
        FAIL=1
        ;;
esac

# Recusa worktrees em /tmp ou /private/tmp explicitamente, mesmo que canonical-root
# estivesse mal configurado.
case "$TOPLEVEL_REAL" in
    /tmp/*|/private/tmp/*|*/tmp/*)
        guard_fail "Worktree em área temporária ($TOPLEVEL_REAL). Pastas /tmp não podem hospedar trabalho HBN — ver auditoria/00_status/98_DIAGNOSTICO_RAIZ_CANONICA_V206_CODEX.md."
        FAIL=1
        ;;
esac

if [[ $FAIL -eq 0 ]]; then
    if [[ $ALT -eq 1 ]]; then
        guard_ok "Raiz alternativa autorizada (.hbn/alt-roots): $TOPLEVEL_REAL; versão ativa: $ACTIVE_ROOT_REAL"
    else
        guard_ok "Raiz canônica OK: $TOPLEVEL_REAL; versão ativa: $ACTIVE_ROOT_REAL"
    fi
    exit 0
fi

echo "  Como corrigir:" >&2
echo "    1. Mover o trabalho de volta para: ${REPO_CANONICAL_REAL}" >&2
echo "    2. Em caso de worktree perdido: bash guards/forbid-tmp-worktree.sh para detalhes" >&2
echo "    3. Registrar P0 em .hbn/readbacks/ se entregáveis foram criados na raiz errada" >&2
echo "    4. NUNCA usar HBN_GUARDS_BYPASS=1 para contornar esta regra" >&2
exit 1
