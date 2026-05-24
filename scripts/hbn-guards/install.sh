#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/install.sh
# Instala o pre-commit unificado que encadeia:
#   1) hbn-guards-runner.sh (governança HBN — Onda 36)
#   2) Glasswing G7+G8 existente (publicar_vba_import_v2.sh --check)
#
# Faz backup do pre-commit anterior se for diferente do nosso. Idempotente.
# =============================================================================
set -euo pipefail

if [[ -t 1 ]]; then
    C_GREEN=$'\033[0;32m'
    C_YELLOW=$'\033[0;33m'
    C_BOLD=$'\033[1m'
    C_END=$'\033[0m'
else
    C_GREEN="" ; C_YELLOW="" ; C_BOLD="" ; C_END=""
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="${REPO_ROOT}/.git/hooks"
TARGET="${HOOKS_DIR}/pre-commit"
HEADER_MARK="# HBN-GUARDS PRE-COMMIT (Onda 36+)"

if [[ ! -d "$HOOKS_DIR" ]]; then
    echo "ERRO: $HOOKS_DIR não existe. Estamos num git repo?" >&2
    exit 1
fi

# Backup do pre-commit atual se existir e não for o nosso
if [[ -f "$TARGET" ]] && ! grep -q "$HEADER_MARK" "$TARGET"; then
    BACKUP="${TARGET}.pre-onda36.$(date +%Y%m%d_%H%M%S).bak"
    echo "${C_YELLOW}[install.sh] Fazendo backup do pre-commit atual em:${C_END}"
    echo "             $BACKUP"
    cp -p "$TARGET" "$BACKUP"
fi

cat > "$TARGET" <<'PRECOMMIT_EOF'
#!/usr/bin/env bash
# HBN-GUARDS PRE-COMMIT (Onda 36+)
# =============================================================================
# Encadeia em ordem:
#   1) scripts/hbn-guards/hbn-guards-runner.sh — Onda 36 governança executável
#   2) local-ai/scripts/publicar_vba_import_v2.sh --check — G7+G8 legados
#
# Bypass (deixa rastro):
#   HBN_GUARDS_BYPASS=1 GLASSWING_BYPASS=1 git commit -m "[bypass-hbn-guards] motivo:…"
# =============================================================================
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
RUNNER="${REPO_ROOT}/scripts/hbn-guards/hbn-guards-runner.sh"
PUB_SH="${REPO_ROOT}/local-ai/scripts/publicar_vba_import_v2.sh"

# === FASE 1: hbn-guards ======================================================
if [[ -x "$RUNNER" ]]; then
    bash "$RUNNER"
else
    echo "[pre-commit] AVISO: $RUNNER ausente ou não executável. Pulei FASE 1." >&2
fi

# === FASE 2: Glasswing G7/G8 (legado, mantido) ==============================
# Só roda se commit toca VBA.
STAGED_FILES="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
TOCA_VBA=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        src/vba/*.bas|src/vba/*.frm|src/vba/*.frx|local-ai/vba_import/*)
            TOCA_VBA=1
            ;;
    esac
done <<< "$STAGED_FILES"

if [[ $TOCA_VBA -eq 1 ]]; then
    if [[ "${GLASSWING_BYPASS:-0}" == "1" || "${HBN_GUARDS_BYPASS:-0}" == "1" ]]; then
        echo "[pre-commit] Bypass ativo — pulando G7+G8." >&2
    elif [[ -f "$PUB_SH" ]]; then
        echo "[pre-commit] Validando Glasswing G7+G8 (VBA sync + Public Type)…"
        bash "$PUB_SH" --check
    else
        echo "[pre-commit] ERRO: $PUB_SH ausente — não consigo validar G7/G8." >&2
        exit 2
    fi
fi

echo "[pre-commit] ✓ Todas as fases passaram." >&2
exit 0
PRECOMMIT_EOF

chmod +x "$TARGET"

# Marca todos os guards como executáveis
chmod +x "${REPO_ROOT}/scripts/hbn-guards/"*.sh

echo ""
echo "${C_GREEN}${C_BOLD}[install.sh] ✓ pre-commit instalado em${C_END}"
echo "             $TARGET"
echo ""
echo "Smoke test rápido:"
echo "  bash scripts/hbn-guards/hbn-guards-runner.sh"
echo ""
echo "Bypass de emergência (deixa rastro em commit msg + .hbn/bypasses/):"
echo "  HBN_GUARDS_BYPASS=1 git commit -m '[bypass-hbn-guards] motivo: …'"
