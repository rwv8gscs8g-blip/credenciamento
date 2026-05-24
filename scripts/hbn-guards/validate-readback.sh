#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/validate-readback.sh
# Guarda G-RB: valida um readback JSON contra .hbn/schemas/readback.schema.json.
# Uso:
#   bash scripts/hbn-guards/validate-readback.sh <caminho-do-json>
#   bash scripts/hbn-guards/validate-readback.sh --active   (valida o readback ativo)
# Sai 0 se válido, 1 se inválido, 2 se infraestrutura.
# =============================================================================
set -euo pipefail

GUARD_NAME="validate-readback"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCHEMA="${REPO_ROOT}/.hbn/schemas/readback.schema.json"

if [[ ! -f "$SCHEMA" ]]; then
    guard_fail "Schema ausente: $SCHEMA"
    exit 2
fi

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
    echo "uso: $0 <readback.json> | --active" >&2
    exit 2
fi

if [[ "$TARGET" == "--active" ]]; then
    # Lê o readback mais recente em .hbn/readbacks/ por ordem numérica
    TARGET="$(ls -1 "${REPO_ROOT}/.hbn/readbacks/"[0-9]*.json 2>/dev/null | sort | tail -1 || true)"
    if [[ -z "$TARGET" ]]; then
        guard_warn "Nenhum readback encontrado em .hbn/readbacks/."
        exit 0  # não-bloqueante se simplesmente não há readback ativo
    fi
fi

if [[ ! -f "$TARGET" ]]; then
    guard_fail "Readback não existe: $TARGET"
    exit 1
fi

# Tenta Python jsonschema primeiro
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import jsonschema" 2>/dev/null; then
        if python3 -c "
import json, sys, jsonschema
with open('$SCHEMA') as f: schema = json.load(f)
with open('$TARGET') as f: data = json.load(f)
try:
    jsonschema.validate(instance=data, schema=schema)
    print('OK')
except jsonschema.ValidationError as e:
    print('FAIL: ' + str(e).split(chr(10))[0], file=sys.stderr)
    sys.exit(1)
"; then
            guard_ok "Readback válido contra schema: $(basename "$TARGET")"
            exit 0
        else
            guard_fail "Readback INVÁLIDO contra schema. Arquivo: $TARGET"
            exit 1
        fi
    fi
fi

# Fallback: validação mínima em bash — checa presença dos campos obrigatórios top-level
guard_warn "python3-jsonschema ausente. Usando validação bash mínima (apenas campos top-level obrigatórios)."

REQUIRED=(readback_id data agent_id track version_target canonical_root branch intent scope risks validation_plan rollback_plan human_status created_at)
MISSING=()
for f in "${REQUIRED[@]}"; do
    if ! grep -q "\"$f\"" "$TARGET"; then
        MISSING+=("$f")
    fi
done

if [[ ${#MISSING[@]} -ne 0 ]]; then
    guard_fail "Readback faltando campos obrigatórios: ${MISSING[*]}"
    echo "  Arquivo: $TARGET" >&2
    echo "  Para validação completa: pip install --user jsonschema" >&2
    exit 1
fi

# Checa canonical_root
if ! grep -q "\"canonical_root\".*\"/Users/macbookpro/Projetos/Credenciamento\"" "$TARGET"; then
    guard_fail "Readback declara canonical_root diferente do esperado."
    exit 1
fi

guard_ok "Readback passou na validação bash mínima (instale jsonschema para validação completa)."
exit 0
