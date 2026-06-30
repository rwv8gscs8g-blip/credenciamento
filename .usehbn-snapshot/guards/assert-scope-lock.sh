#!/usr/bin/env bash
# =============================================================================
# guards/assert-scope-lock.sh
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
ACTIVE_ROOT="$(get_canonical_root || true)"
if [[ -z "$ACTIVE_ROOT" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar readbacks da versão ativa."
    exit 1
fi
READBACKS_DIR="${ACTIVE_ROOT}/.hbn/readbacks"
READBACKS_REPO_DIR="$(guard_version_repo_path ".hbn/readbacks" || true)"

# Identifica readback ativo pelo que esta versionado para o commit: indice no
# pre-commit local, HEAD no CI. Readback solto na working tree nao amplia escopo.
if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    ACTIVE_RB_REPO_PATH="$(git ls-tree -r --name-only HEAD -- "$READBACKS_REPO_DIR" 2>/dev/null | sort | tail -1 || true)"
else
    ACTIVE_RB_REPO_PATH="$(git ls-files -- "$READBACKS_REPO_DIR" 2>/dev/null | sort | tail -1 || true)"
fi
ACTIVE_RB_VERSION_PATH=""
if [[ -n "$ACTIVE_RB_REPO_PATH" ]]; then
    ACTIVE_RB_VERSION_PATH="$(guard_repo_path_to_version_path "$ACTIVE_RB_REPO_PATH")"
fi
ACTIVE_RB="${ACTIVE_ROOT}/${ACTIVE_RB_VERSION_PATH}"

if [[ -z "$ACTIVE_RB_REPO_PATH" || -z "$ACTIVE_RB_VERSION_PATH" ]]; then
    guard_log "Sem readback ativo em $READBACKS_DIR — guard sem alvo."
    exit 0
fi

POST_RB_FILE="$(mktemp)"
BASE_RB_FILE="$(mktemp)"
ALLOWED_FILE="$(mktemp)"
OLD_ALLOWED_FILE="$(mktemp)"
FORBIDDEN_FILE="$(mktemp)"
ADDED_ALLOWED_FILE="$(mktemp)"
EXTENSION_META_FILE="$(mktemp)"
trap 'rm -f "$POST_RB_FILE" "$BASE_RB_FILE" "$ALLOWED_FILE" "$OLD_ALLOWED_FILE" "$FORBIDDEN_FILE" "$ADDED_ALLOWED_FILE" "$EXTENSION_META_FILE"' EXIT

if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    if ! git show "HEAD:${ACTIVE_RB_REPO_PATH}" > "$POST_RB_FILE" 2>/dev/null; then
        guard_fail "Nao foi possivel ler o readback ativo em HEAD:${ACTIVE_RB_REPO_PATH}."
        exit 1
    fi
else
    if ! git show ":${ACTIVE_RB_REPO_PATH}" > "$POST_RB_FILE" 2>/dev/null; then
        guard_fail "Nao foi possivel ler o readback ativo no indice: ${ACTIVE_RB_REPO_PATH}. Use git add do readback antes de operar."
        exit 1
    fi
fi

BASE_RB_AVAILABLE=0
BASE_REF="${HBN_DIFF_BASE:-HEAD}"
if git show "${BASE_REF}:${ACTIVE_RB_REPO_PATH}" > "$BASE_RB_FILE" 2>/dev/null; then
    BASE_RB_AVAILABLE=1
fi

# Extrai track e human_status sem depender de jq (regex tolerante)
TRACK="$(grep -oE '"track"[[:space:]]*:[[:space:]]*"[^"]+"' "$POST_RB_FILE" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
HUMAN_STATUS="$(grep -oE '"human_status"[[:space:]]*:[[:space:]]*"[^"]+"' "$POST_RB_FILE" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"

guard_log "Readback ativo: $(basename "$ACTIVE_RB_VERSION_PATH") | track=$TRACK | human_status=$HUMAN_STATUS"

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

STAGED="$(guard_diff_files)"
if [[ -z "$STAGED" ]]; then
    guard_ok "Sem arquivos staged — nada a verificar contra scope."
    exit 0
fi

if command -v python3 >/dev/null 2>&1; then
    python3 - "$POST_RB_FILE" "$ALLOWED_FILE" "$OLD_ALLOWED_FILE" "$FORBIDDEN_FILE" "$BASE_RB_FILE" "$BASE_RB_AVAILABLE" "$ADDED_ALLOWED_FILE" "$EXTENSION_META_FILE" <<'PY'
import json, sys
(
    rb_path,
    allowed_out,
    old_allowed_out,
    forbidden_out,
    base_path,
    base_available,
    added_allowed_out,
    extension_meta_out,
) = sys.argv[1:9]

def load_json(path):
    with open(path) as f:
        return json.load(f)

rb = load_json(rb_path)
allowed = rb.get('scope', {}).get('files_allowed', []) or []
forbidden = rb.get('scope', {}).get('files_forbidden', []) or []

old_allowed = []
if base_available == "1":
    old = load_json(base_path)
    old_allowed = old.get('scope', {}).get('files_allowed', []) or []

added = [p for p in allowed if p not in old_allowed] if base_available == "1" else []
removed = [p for p in old_allowed if p not in allowed] if base_available == "1" else []

extensions = []
for key, value in rb.items():
    if key == "scope_extension" or key.startswith("scope_extension_"):
        if isinstance(value, dict):
            extensions.append(value)

required = ("human", "evidence", "created_at", "allowed_delta")
extension_valid = True
if added:
    extension_valid = False
    for ext in extensions:
        delta = ext.get("allowed_delta")
        if not isinstance(delta, list):
            continue
        if all(ext.get(field) for field in required) and all(p in delta for p in added):
            extension_valid = True
            break

with open(allowed_out, 'w') as f:
    for p in allowed:
        f.write(p + "\n")
with open(old_allowed_out, 'w') as f:
    for p in old_allowed:
        f.write(p + "\n")
with open(forbidden_out, 'w') as f:
    for p in forbidden:
        f.write(p + "\n")
with open(added_allowed_out, 'w') as f:
    for p in added:
        f.write(p + "\n")
with open(extension_meta_out, 'w') as f:
    f.write(f"added_count={len(added)}\n")
    f.write(f"removed_count={len(removed)}\n")
    f.write(f"extension_valid={1 if extension_valid else 0}\n")
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

OLD_ALLOWED_PATTERNS=()
while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    OLD_ALLOWED_PATTERNS+=("$_line")
done < "$OLD_ALLOWED_FILE"

FORBIDDEN_PATTERNS=()
while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    FORBIDDEN_PATTERNS+=("$_line")
done < "$FORBIDDEN_FILE"

if [[ ${#ALLOWED_PATTERNS[@]} -eq 0 ]]; then
    guard_fail "Readback ativo é safe_track mas scope.files_allowed está vazio. Inválido."
    exit 1
fi

# Meta-paths auto-permitidos — artefatos de coordenação do protocolo HBN.
# B17: a dispensa de scope.files_allowed e restrita por tipo+nome. Somente
# .json/.md com basename de evento ADR-025, hearback do readback ativo, ou
# nome-endereco conhecido entram aqui; payload arbitrario cai no scope normal.
# B18/B19: symlink em arquivo staged avaliado por este guard nunca e permitido;
# modo git 120000 bloqueia antes do scope normal ou da dispensa de meta-path.
# Documentado em guards/README.md §Meta-paths.
READBACK_NUM="$(basename "$ACTIVE_RB" | grep -oE '^[0-9]{4}' || echo "")"
META_ALLOWED_DESCRIPTIONS=(
    ".hbn/hearbacks/${READBACK_NUM}-*.{json,md}"
    ".hbn/bypasses/AAAAMMDD-HHMMSS-<agente>-<slug>.{json,md}"
    ".hbn/messages/AAAAMMDD-HHMMSS-<agente>-<slug>.{json,md}"
    ".hbn/relay/INDEX.md"
)

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

is_meta_auto_allowed() {
    local file="$1" base
    base="${file##*/}"

    case "$file" in
        .hbn/relay/INDEX.md) return 0 ;;
        .hbn/hearbacks/*)
            [[ -n "$READBACK_NUM" && "$base" =~ ^${READBACK_NUM}-[a-z0-9][a-z0-9-]*\.(json|md)$ ]] && return 0
            ;;
        .hbn/bypasses/*|.hbn/messages/*)
            [[ "$base" =~ ^[0-9]{8}-[0-9]{6}-[a-z0-9][a-z0-9-]*-[a-z0-9][a-z0-9-]*\.(json|md)$ ]] && return 0
            ;;
    esac
    return 1
}

is_governed_symlink() {
    local file="$1" repo_file
    repo_file="$(guard_version_repo_path "$file" || echo "$file")"

    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r HEAD -- "$repo_file" 2>/dev/null | grep -q '^120000[[:space:]]'
    else
        git ls-files --stage -- "$repo_file" 2>/dev/null | grep -q '^120000[[:space:]]'
    fi
}

scope_allows() {
    local file="$1"; shift
    is_meta_auto_allowed "$file" || matches_any "$file" "$@"
}

READBACK_CHANGED=0
if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    if git diff --name-only "${HBN_DIFF_BASE}...HEAD" -- "$ACTIVE_RB_REPO_PATH" 2>/dev/null | grep -qxF "$ACTIVE_RB_REPO_PATH"; then
        READBACK_CHANGED=1
    fi
else
    if git diff --cached --name-only -- "$ACTIVE_RB_REPO_PATH" 2>/dev/null | grep -qxF "$ACTIVE_RB_REPO_PATH"; then
        READBACK_CHANGED=1
    fi
fi

ADDED_ALLOWED_COUNT="$(grep -E '^added_count=' "$EXTENSION_META_FILE" | sed -E 's/^added_count=//')"
EXTENSION_VALID="$(grep -E '^extension_valid=' "$EXTENSION_META_FILE" | sed -E 's/^extension_valid=//')"

if [[ "$READBACK_CHANGED" -eq 1 && "${ADDED_ALLOWED_COUNT:-0}" -gt 0 ]]; then
    OTHER_STAGED=()
    DEPENDS_ON_EXTENSION=()
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        [[ "$f" == "$ACTIVE_RB_VERSION_PATH" ]] && continue
        OTHER_STAGED+=("$f")
        if ! scope_allows "$f" "${OLD_ALLOWED_PATTERNS[@]}" && scope_allows "$f" "${ALLOWED_PATTERNS[@]}"; then
            DEPENDS_ON_EXTENSION+=("$f")
        fi
    done <<< "$STAGED"

    if [[ "$EXTENSION_VALID" != "1" ]]; then
        guard_fail "scope.files_allowed do readback ativo foi estendido sem scope_extension valido (human, evidence, created_at, allowed_delta cobrindo o delta)."
        echo "  Readback ativo: $ACTIVE_RB_REPO_PATH" >&2
        echo "  Patterns adicionados:" >&2
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue
            echo "    + $p" >&2
        done < "$ADDED_ALLOWED_FILE"
        exit 1
    fi

    if [[ ${#OTHER_STAGED[@]} -gt 0 ]]; then
        guard_fail "scope.files_allowed do readback ativo foi estendido no mesmo commit com outros arquivos staged. Extensao legitima e commit isolado que altera apenas o JSON do readback."
        echo "  Readback ativo: $ACTIVE_RB_REPO_PATH" >&2
        echo "  Patterns adicionados:" >&2
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue
            echo "    + $p" >&2
        done < "$ADDED_ALLOWED_FILE"
        if [[ ${#DEPENDS_ON_EXTENSION[@]} -gt 0 ]]; then
            echo "  Arquivos cuja cobertura depende da emenda:" >&2
            for f in "${DEPENDS_ON_EXTENSION[@]}"; do
                echo "    - $f" >&2
            done
        fi
        echo "  Outros arquivos staged no mesmo commit:" >&2
        for f in "${OTHER_STAGED[@]}"; do
            echo "    - $f" >&2
        done
        exit 1
    fi
fi

FAIL=0
OUT_SCOPE=()
IN_FORBIDDEN=()
GOVERNED_SYMLINKS=()

while IFS= read -r f; do
    [[ -z "$f" ]] && continue

    if is_governed_symlink "$f"; then
        GOVERNED_SYMLINKS+=("$f")
        FAIL=1
        continue
    fi

    if [[ ${#FORBIDDEN_PATTERNS[@]} -gt 0 ]] && matches_any "$f" "${FORBIDDEN_PATTERNS[@]}"; then
        IN_FORBIDDEN+=("$f")
        FAIL=1
        continue
    fi

    if ! scope_allows "$f" "${ALLOWED_PATTERNS[@]}"; then
        OUT_SCOPE+=("$f")
        FAIL=1
    fi
done <<< "$STAGED"

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Todos arquivos staged dentro do scope declarado em $(basename "$ACTIVE_RB")."
    exit 0
fi

if [[ ${#GOVERNED_SYMLINKS[@]} -gt 0 ]]; then
    for f in "${GOVERNED_SYMLINKS[@]}"; do
        guard_fail "symlink não permitido em path governado: $f"
    done
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
echo "  Meta-paths auto-permitidos (tipo+nome; symlinks sempre bloqueados):" >&2
for p in "${META_ALLOWED_DESCRIPTIONS[@]}"; do
    echo "    + $p" >&2
done
echo "" >&2
echo "  Como corrigir:" >&2
echo "    A) Desfazer staging dos arquivos fora-de-escopo: git restore --staged <arquivo>" >&2
echo "    B) Atualizar readback ativo em commit isolado de scope_extension (human, evidence, created_at, allowed_delta); depositar os arquivos em commit posterior" >&2
echo "    C) Bypass de emergência só com [bypass-hbn-guards] no commit msg + nota em .hbn/bypasses/" >&2
exit 1
