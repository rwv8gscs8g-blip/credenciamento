#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/assert-scope-lock.sh
# Guarda G-SCOPE: extrai scope.files_allowed do readback ATIVO e verifica que
# todo arquivo staged casa com pelo menos um padrão. Recusa commit se algum
# arquivo staged ficar fora do escopo declarado.
#
# Esta é a guarda que faltou nos incidentes de 02/05 e 24/05 — converte
# o "O Que NÃO Será Feito" do markdown em verificação automatizada.
#
# Pula a verificação se:
#   - não há readback ativo (não há onda HBN em curso)
#   - o readback é fast_track (só doc/auditoria)
#   - HBN_GUARDS_BYPASS=1
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-scope-lock"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
READBACKS_DIR="${REPO_ROOT}/.hbn/readbacks"

# Identifica readback ativo (último numericamente em .hbn/readbacks/)
ACTIVE_RB="$(ls -1 "${READBACKS_DIR}"/[0-9]*.json 2>/dev/null | sort | tail -1 || true)"

if [[ -z "$ACTIVE_RB" ]]; then
    guard_log "Sem readback ativo em $READBACKS_DIR — guard sem alvo."
    exit 0
fi

# Extrai track e human_status sem depender de jq (regex tolerante)
TRACK="$(grep -oE '"track"[[:space:]]*:[[:space:]]*"[^"]+"' "$ACTIVE_RB" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
HUMAN_STATUS="$(grep -oE '"human_status"[[:space:]]*:[[:space:]]*"[^"]+"' "$ACTIVE_RB" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"

guard_log "Readback ativo: $(basename "$ACTIVE_RB") | track=$TRACK | human_status=$HUMAN_STATUS"

# fast_track não exige scope lock (mas registra)
if [[ "$TRACK" == "fast_track" ]]; then
    guard_ok "track=fast_track — scope lock não obrigatório."
    exit 0
fi

# safe_track sem hearback confirmed = bloqueio
if [[ "$TRACK" == "safe_track" && "$HUMAN_STATUS" != "confirmed" ]]; then
    guard_fail "safe_track exige human_status=confirmed no readback ativo. Atual: $HUMAN_STATUS"
    echo "  Arquivo: $ACTIVE_RB" >&2
    echo "  Como corrigir: obter hearback humano (atualizar human_status para 'confirmed' OU criar .hbn/hearbacks/<id>.json status='confirmed')" >&2
    exit 1
fi

STAGED="$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)"
if [[ -z "$STAGED" ]]; then
    guard_ok "Sem arquivos staged — nada a verificar contra scope."
    exit 0
fi

# Tenta usar python para extrair scope.files_allowed (mais robusto que regex)
ALLOWED_FILE="$(mktemp)"
FORBIDDEN_FILE="$(mktemp)"
trap 'rm -f "$ALLOWED_FILE" "$FORBIDDEN_FILE"' EXIT

if command -v python3 >/dev/null 2>&1; then
    python3 - "$ACTIVE_RB" "$ALLOWED_FILE" "$FORBIDDEN_FILE" <<'PY'
import json, sys
rb_path, allowed_out, forbidden_out = sys.argv[1:4]
with open(rb_path) as f:
    rb = json.load(f)
allowed = rb.get('scope', {}).get('files_allowed', []) or []
forbidden = rb.get('scope', {}).get('files_forbidden', []) or []
with open(allowed_out, 'w') as f:
    for p in allowed:
        f.write(p + "\n")
with open(forbidden_out, 'w') as f:
    for p in forbidden:
        f.write(p + "\n")
PY
else
    guard_fail "python3 ausente — não consigo extrair scope.files_allowed com segurança."
    exit 2
fi

# NOTA: usar `while read` em vez de `mapfile` para compatibilidade com bash 3.2
# (padrão do macOS — Apple não atualiza bash por questão de licença GPLv3).
ALLOWED_PATTERNS=()
while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    ALLOWED_PATTERNS+=("$_line")
done < "$ALLOWED_FILE"

FORBIDDEN_PATTERNS=()
while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    FORBIDDEN_PATTERNS+=("$_line")
done < "$FORBIDDEN_FILE"

if [[ ${#ALLOWED_PATTERNS[@]} -eq 0 ]]; then
    guard_fail "Readback ativo é safe_track mas scope.files_allowed está vazio. Inválido."
    exit 1
fi

# Meta-paths SEMPRE permitidos — são artefatos de coordenação do próprio protocolo
# HBN (hearbacks, bypasses, mensagens inter-IA, relay). Não exigem declaração
# explícita no scope.files_allowed porque sua existência já é parte do contrato.
# Documentado em scripts/hbn-guards/README.md §Meta-paths.
READBACK_NUM="$(basename "$ACTIVE_RB" | grep -oE '^[0-9]{4}' || echo "")"
META_ALWAYS_ALLOWED=(
    ".hbn/hearbacks/${READBACK_NUM}-*.json"
    ".hbn/hearbacks/${READBACK_NUM}-*.md"
    ".hbn/bypasses/**"
    ".hbn/messages/**"
    ".hbn/relay/INDEX.md"
)
ALLOWED_PATTERNS+=("${META_ALWAYS_ALLOWED[@]}")

# Função de match (glob simples)
matches_any() {
    local file="$1"; shift
    local pat
    for pat in "$@"; do
        # shellcheck disable=SC2053
        if [[ "$file" == $pat ]]; then
            return 0
        fi
        # Suporte a ** (qualquer prefixo)
        if [[ "$pat" == *"**"* ]]; then
            local prefix="${pat%%\*\**}"
            local suffix="${pat##*\*\*}"
            if [[ "$file" == "${prefix}"* && "$file" == *"${suffix}" ]]; then
                return 0
            fi
        fi
    done
    return 1
}

FAIL=0
OUT_SCOPE=()
IN_FORBIDDEN=()

while IFS= read -r f; do
    [[ -z "$f" ]] && continue

    if [[ ${#FORBIDDEN_PATTERNS[@]} -gt 0 ]] && matches_any "$f" "${FORBIDDEN_PATTERNS[@]}"; then
        IN_FORBIDDEN+=("$f")
        FAIL=1
        continue
    fi

    if ! matches_any "$f" "${ALLOWED_PATTERNS[@]}"; then
        OUT_SCOPE+=("$f")
        FAIL=1
    fi
done <<< "$STAGED"

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Todos arquivos staged dentro do scope declarado em $(basename "$ACTIVE_RB")."
    exit 0
fi

if [[ ${#IN_FORBIDDEN[@]} -gt 0 ]]; then
    guard_fail "Arquivos staged em scope.files_forbidden (violação direta):"
    for f in "${IN_FORBIDDEN[@]}"; do
        echo "    - $f" >&2
    done
fi

if [[ ${#OUT_SCOPE[@]} -gt 0 ]]; then
    guard_fail "Arquivos staged FORA do scope.files_allowed do readback:"
    for f in "${OUT_SCOPE[@]}"; do
        echo "    - $f" >&2
    done
fi

echo "" >&2
echo "  Readback ativo: $ACTIVE_RB" >&2
echo "  Patterns permitidos:" >&2
for p in "${ALLOWED_PATTERNS[@]}"; do
    echo "    + $p" >&2
done
echo "" >&2
echo "  Como corrigir:" >&2
echo "    A) Desfazer staging dos arquivos fora-de-escopo: git restore --staged <arquivo>" >&2
echo "    B) Atualizar readback ativo para incluir esses paths (requer NOVO hearback)" >&2
echo "    C) Bypass de emergência só com [bypass-hbn-guards] no commit msg + nota em .hbn/bypasses/" >&2
exit 1
