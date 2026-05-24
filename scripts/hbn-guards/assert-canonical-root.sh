#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/assert-canonical-root.sh
# Guarda G-CR: recusa qualquer operação fora da raiz canônica declarada em
# .hbn/canonical-root. Defesa direta contra os incidentes de 2026-05-02 e
# 2026-05-24 (IA escrevendo em /private/tmp ou em pasta paralela).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-canonical-root"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

CANONICAL="$(guard_canonical_root)"
if [[ -z "$CANONICAL" ]]; then
    guard_fail "Arquivo .hbn/canonical-root ausente ou ilegível na raiz do repo. Não é possível validar a raiz canônica."
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
if [[ -d "$CANONICAL" ]]; then
    CANONICAL_REAL="$(cd "$CANONICAL" && pwd -P)"
else
    CANONICAL_REAL="$CANONICAL"
fi

FAIL=0
if [[ "$TOPLEVEL_REAL" != "$CANONICAL_REAL" ]]; then
    guard_fail "git toplevel ($TOPLEVEL_REAL) ≠ raiz canônica ($CANONICAL_REAL)."
    FAIL=1
fi

# Recusa worktrees em /tmp ou /private/tmp explicitamente, mesmo que canonical-root
# estivesse mal configurado.
case "$TOPLEVEL_REAL" in
    /tmp/*|/private/tmp/*|*/tmp/*)
        guard_fail "Worktree em área temporária ($TOPLEVEL_REAL). Pastas /tmp não podem hospedar trabalho HBN — ver auditoria/00_status/98_DIAGNOSTICO_RAIZ_CANONICA_V206_CODEX.md."
        FAIL=1
        ;;
esac

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Raiz canônica OK: $TOPLEVEL_REAL"
    exit 0
fi

echo "  Como corrigir:" >&2
echo "    1. Mover o trabalho de volta para: ${CANONICAL_REAL}" >&2
echo "    2. Em caso de worktree perdido: bash scripts/hbn-guards/forbid-tmp-worktree.sh para detalhes" >&2
echo "    3. Registrar P0 em .hbn/readbacks/ se entregáveis foram criados na raiz errada" >&2
echo "    4. NUNCA usar HBN_GUARDS_BYPASS=1 para contornar esta regra" >&2
exit 1
