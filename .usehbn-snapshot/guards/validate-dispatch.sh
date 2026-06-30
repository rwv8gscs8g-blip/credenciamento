#!/usr/bin/env bash
# =============================================================================
# guards/validate-dispatch.sh
# G-DSP-FMT: valida a forma do despacho auto-declarante em .hbn/dispatch/.
# Lê o blob staged localmente e HEAD em CI; nunca confia na working tree.
# =============================================================================
set -euo pipefail

GUARD_NAME="validate-dispatch"
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

blob_mode() {
    local p repo_file
    repo_file="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r HEAD -- "$repo_file" 2>/dev/null | awk '{print $1}' | head -1
    else
        git ls-files --stage -- "$repo_file" 2>/dev/null | awk '{print $1}' | head -1
    fi
}

dispatch_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=ACMR "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/dispatch/' || true
}

SCHEMA_REF="$(blob_ref "schemas/dispatch.schema.json")"
if ! git cat-file -e "$SCHEMA_REF" 2>/dev/null; then
    guard_fail "Schema obrigatório ausente no índice/HEAD: schemas/dispatch.schema.json."
    exit 1
fi

SCHEMA_FILE="$(mktemp)"
trap 'rm -f "$SCHEMA_FILE"' EXIT
if ! git show "$SCHEMA_REF" > "$SCHEMA_FILE" 2>/dev/null; then
    guard_fail "Schema obrigatório ilegível: schemas/dispatch.schema.json."
    exit 1
fi

DISPATCHES="$(dispatch_files)"
if [[ -z "$DISPATCHES" ]]; then
    guard_ok "Nenhum dispatch staged em .hbn/dispatch/."
    exit 0
fi

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue

    mode="$(blob_mode "$f" || true)"
    if [[ "$f" != *.md ]]; then
        guard_fail "Arquivo em .hbn/dispatch/ deve ser Markdown .md: ${f}."
        FAIL=1
        continue
    fi
    if [[ "$mode" != "100644" ]]; then
        guard_fail "Dispatch '${f}' deve ser arquivo regular git mode 100644; modo atual: ${mode:-desconhecido}."
        FAIL=1
        continue
    fi

    ref="$(blob_ref "$f")"
    DISPATCH_FILE="$(mktemp)"
    ERR_FILE="$(mktemp)"
    if ! git show "$ref" > "$DISPATCH_FILE" 2>/dev/null; then
        guard_fail "${f}: não foi possível ler blob staged/HEAD."
        rm -f "$DISPATCH_FILE" "$ERR_FILE"
        FAIL=1
        continue
    fi
    if ! python3 - "$SCHEMA_FILE" "$f" "$DISPATCH_FILE" >"$ERR_FILE" 2>&1 <<'PY'
import json
import os
import re
import sys

schema_path, dispatch_path, dispatch_file = sys.argv[1:4]
text = open(dispatch_file).read()
errors = []

def unquote(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
        return value[1:-1]
    return value

def scalar(value):
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        inside = value[1:-1].strip()
        if not inside:
            return []
        return [unquote(part.strip()) for part in inside.split(",")]
    return unquote(value)

def parse_front_matter(lines):
    root = {}
    current = None
    current_child = None
    for lineno, raw in enumerate(lines, start=2):
        if not raw.strip():
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        item = raw.strip()
        if indent == 0:
            if ":" not in item:
                raise ValueError(f"linha {lineno}: entrada YAML sem ':'")
            key, value = item.split(":", 1)
            key = key.strip()
            value = value.strip()
            if not key:
                raise ValueError(f"linha {lineno}: chave YAML vazia")
            if value == "":
                root[key] = None
                current = key
                current_child = None
            else:
                root[key] = scalar(value)
                current = None
                current_child = None
        elif indent == 2:
            if current is None:
                raise ValueError(f"linha {lineno}: indentacao sem chave pai")
            if item.startswith("- "):
                if root.get(current) is None:
                    root[current] = []
                if not isinstance(root[current], list):
                    raise ValueError(f"linha {lineno}: lista misturada com objeto em {current}")
                root[current].append(scalar(item[2:]))
            else:
                if ":" not in item:
                    raise ValueError(f"linha {lineno}: entrada YAML sem ':'")
                if root.get(current) is None:
                    root[current] = {}
                if not isinstance(root[current], dict):
                    raise ValueError(f"linha {lineno}: objeto misturado com lista em {current}")
                key, value = item.split(":", 1)
                key = key.strip()
                value = value.strip()
                if value == "":
                    root[current][key] = []
                    current_child = (current, key)
                else:
                    root[current][key] = scalar(value)
                    current_child = None
        elif indent == 4 and item.startswith("- "):
            if current_child is None:
                raise ValueError(f"linha {lineno}: item de lista sem chave pai")
            parent, key = current_child
            root[parent][key].append(scalar(item[2:]))
        else:
            raise ValueError(f"linha {lineno}: YAML fora do subconjunto suportado")
    return root

def validate(schema, value, path="$"):
    want = schema.get("type")
    if want == "object":
        if not isinstance(value, dict):
            errors.append(f"{path}: esperado objeto")
            return
        for req in schema.get("required", []):
            if req not in value or value[req] in (None, ""):
                errors.append(f"{path}.{req}: campo obrigatório ausente ou vazio")
        props = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            for key in value:
                if key not in props:
                    errors.append(f"{path}.{key}: campo não permitido pelo schema")
        for key, subschema in props.items():
            if key in value and value[key] is not None:
                validate(subschema, value[key], f"{path}.{key}")
    elif want == "array":
        if not isinstance(value, list):
            errors.append(f"{path}: esperado array")
            return
        if len(value) < schema.get("minItems", 0):
            errors.append(f"{path}: array abaixo de minItems={schema.get('minItems')}")
        item_schema = schema.get("items")
        if item_schema:
            for idx, item in enumerate(value):
                validate(item_schema, item, f"{path}[{idx}]")
    elif want == "string":
        if not isinstance(value, str):
            errors.append(f"{path}: esperado string")
            return
        if len(value) < schema.get("minLength", 0):
            errors.append(f"{path}: string vazia ou curta demais")
        if "pattern" in schema and not re.match(schema["pattern"], value):
            errors.append(f"{path}: valor '{value}' não casa pattern {schema['pattern']}")
        if "enum" in schema and value not in schema["enum"]:
            errors.append(f"{path}: valor '{value}' fora de enum {schema['enum']}")

try:
    schema = json.load(open(schema_path))
except Exception as exc:
    print(f"schema inválido ou ilegível: {exc}", file=sys.stderr)
    sys.exit(1)

lines = text.splitlines()
if not lines or lines[0].strip() != "---":
    print("front matter YAML obrigatório na primeira linha", file=sys.stderr)
    sys.exit(1)

end = None
for idx in range(1, len(lines)):
    if lines[idx].strip() == "---":
        end = idx
        break
if end is None:
    print("front matter YAML não foi fechado com ---", file=sys.stderr)
    sys.exit(1)

try:
    data = parse_front_matter(lines[1:end])
except Exception as exc:
    print(f"front matter inválido: {exc}", file=sys.stderr)
    sys.exit(1)

validate(schema, data)

expected_id = os.path.basename(dispatch_path)[:-3]
if data.get("dispatch_id") != expected_id:
    errors.append(f"$.dispatch_id: esperado '{expected_id}' para o basename do arquivo")
if data.get("path") and data.get("path") != dispatch_path:
    errors.append(f"$.path: declarado '{data.get('path')}' difere de '{dispatch_path}'")

for offset, body_line in enumerate(lines[end + 1 :], start=end + 2):
    if re.match(r"^\s*#", body_line):
        errors.append(f"corpo colável linha {offset}: não pode iniciar com '#'")

if errors:
    for err in errors:
        print(err, file=sys.stderr)
    sys.exit(1)
PY
    then
        while IFS= read -r err; do
            [[ -z "$err" ]] && continue
            guard_fail "${f}: ${err}"
        done < "$ERR_FILE"
        FAIL=1
    fi
    rm -f "$DISPATCH_FILE" "$ERR_FILE"
done <<< "$DISPATCHES"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Dispatches staged validam contra schemas/dispatch.schema.json e respeitam zsh-safe."
exit 0
