#!/usr/bin/env bash
# =============================================================================
# guards/assert-orq-entrada.sh
# G-ORQ-ENTRADA: bastao de orquestrador exige atestacao de leitura valida.
#
# Gatilho: STATE staged (local) ou HEAD (CI) com papel_bastao=orquestrador ou
# atribuicao.chapeu_atual contendo "orquestrador". Fora desse caso, nao opina.
#
# v2: desafio extrativo deterministico, recomputado do indice staged (:path);
# em CI, recomputado de HEAD:path quando HBN_DIFF_BASE esta presente.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-orq-entrada"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

REPO_ROOT="$(guard_repo_root)"
ACTIVE_ROOT="$(get_canonical_root || true)"
STATE_PATH=".hbn/relay/STATE.md"
STATE_REPO_PATH="$(guard_version_repo_path "$STATE_PATH" || true)"
READ_LIST_PATH="core/read-list-canonica.txt"
READ_LIST_REPO_PATH="$(guard_version_repo_path "$READ_LIST_PATH" || true)"

if [[ -z "$ACTIVE_ROOT" || -z "$STATE_REPO_PATH" || -z "$READ_LIST_REPO_PATH" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel localizar STATE/read-list."
    exit 1
fi

repo_path_content() {
    local repo_path="$1"
    if [[ -n "${HBN_ORQ_ENTRADA_GIT_REF:-}" ]]; then
        git show "${HBN_ORQ_ENTRADA_GIT_REF}:${repo_path}" 2>/dev/null
    elif [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${repo_path}" 2>/dev/null
    else
        git show ":${repo_path}" 2>/dev/null
    fi
}

STATE_CONTENT="$(repo_path_content "$STATE_REPO_PATH" || true)"
if [[ -z "$STATE_CONTENT" ]]; then
    guard_fail "STATE ausente/ilegivel no indice/HEAD: ${STATE_PATH}."
    exit 1
fi

state_value() {
    local key="$1"
    printf '%s\n' "$STATE_CONTENT" \
        | grep -E "^[[:space:]]*${key}:" \
        | head -1 \
        | sed -E 's/^[^:]+:[[:space:]]*//; s/[[:space:]]+#.*$//; s/^[[:space:]]+//; s/[[:space:]]+$//; s/^["'\'']//; s/["'\'']$//' \
        || true
}

PAPEL_BASTAO="$(state_value "papel_bastao" | tr '[:upper:]' '[:lower:]')"
CHAPEU_ATUAL="$(state_value "chapeu_atual" | tr '[:upper:]' '[:lower:]')"

if [[ "$PAPEL_BASTAO" != "orquestrador" && "$CHAPEU_ATUAL" != *"orquestrador"* ]]; then
    guard_ok "Bastao atual nao e de orquestrador — G-ORQ-ENTRADA nao opina."
    exit 0
fi

TOKEN_SHA="$(state_value "bastao_token_sha256" | grep -Eo '^[0-9a-fA-F]{64}$' || true)"
if [[ -z "$TOKEN_SHA" ]]; then
    guard_fail "STATE de orquestrador sem bastao_token_sha256 valido."
    exit 1
fi
TOKEN_FP="${TOKEN_SHA:0:8}"

HANDOFF_PATH="$(state_value "handoff_mais_recente")"
READBACK_PATH="$(state_value "readback_ativo")"
ATTEST_PATH=".hbn/attestations/${TOKEN_FP}-orq-entrada.json"
ATTEST_REPO_PATH="$(guard_version_repo_path "$ATTEST_PATH" || true)"

if [[ -z "$ATTEST_REPO_PATH" ]]; then
    guard_fail "Nao foi possivel resolver path da atestacao ${ATTEST_PATH}."
    exit 1
fi

CANON_CONTENT="$(repo_path_content "$READ_LIST_REPO_PATH" || true)"
if [[ -z "$CANON_CONTENT" ]]; then
    guard_fail "Read-list canonica ausente/ilegivel no indice/HEAD: ${READ_LIST_PATH}."
    exit 1
fi

EXPECTED_FILE="$(mktemp)"
trap 'rm -f "$EXPECTED_FILE"' EXIT

CANON_FAIL=0
while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
    line="${raw_line%%#*}"
    line="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    [[ -z "$line" ]] && continue

    if [[ "$line" =~ ^DYNAMIC[[:space:]]+([A-Za-z0-9_]+)$ ]]; then
        field="${BASH_REMATCH[1]}"
        case "$field" in
            handoff_mais_recente) resolved="$HANDOFF_PATH" ;;
            readback_ativo) resolved="$READBACK_PATH" ;;
            *)
                guard_fail "Read-list canonica contem DYNAMIC desconhecido: ${field}."
                CANON_FAIL=1
                continue
                ;;
        esac
        if [[ -z "$resolved" ]]; then
            guard_fail "STATE nao resolve campo dinamico obrigatorio: ${field}."
            CANON_FAIL=1
            continue
        fi
    elif [[ "$line" =~ ^[0-9a-fA-F]{7,40}[[:space:]]+(.+)$ ]]; then
        resolved="${BASH_REMATCH[1]}"
    else
        guard_fail "Linha invalida em core/read-list-canonica.txt: ${raw_line}"
        CANON_FAIL=1
        continue
    fi

    if [[ "$resolved" == *$'\t'* ]]; then
        guard_fail "Path invalido na read-list canonica (TAB): ${resolved}"
        CANON_FAIL=1
        continue
    fi
    resolved_repo="$(guard_version_repo_path "$resolved" || true)"
    if [[ -z "$resolved_repo" ]]; then
        guard_fail "Nao foi possivel resolver path da read-list: ${resolved}"
        CANON_FAIL=1
        continue
    fi
    printf '%s\t%s\n' "$resolved" "$resolved_repo" >> "$EXPECTED_FILE"
done <<< "$CANON_CONTENT"

EXPECTED_COUNT="$(sed '/^[[:space:]]*$/d' "$EXPECTED_FILE" | wc -l | tr -d '[:space:]')"
if [[ "$EXPECTED_COUNT" != "13" ]]; then
    guard_fail "Read-list canonica deve resolver 13 itens; resolveu ${EXPECTED_COUNT}."
    CANON_FAIL=1
fi
if [[ "$CANON_FAIL" -ne 0 ]]; then
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    guard_fail "python3 ausente — nao consigo validar JSON da atestacao com seguranca."
    exit 2
fi

if ! (
    cd "$REPO_ROOT"
        python3 - "$TOKEN_FP" "$ATTEST_REPO_PATH" "$EXPECTED_FILE" "$STATE_PATH" "$READBACK_PATH" "${HBN_ORQ_ENTRADA_GIT_REF:-}" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

ALGORITHM = "orq-entrada.v2/extractive-lines"
token_fp, attest_repo_path, expected_file, state_path, readback_path, git_ref = sys.argv[1:7]
use_head = bool(__import__("os").environ.get("HBN_DIFF_BASE"))
errors = []

def fail(message):
    errors.append(message)

def git_bytes(*args):
    return subprocess.check_output(["git", *args], stderr=subprocess.DEVNULL)

def blob_oid(repo_path):
    if git_ref:
        spec = f"{git_ref}:{repo_path}"
    elif use_head:
        spec = f"HEAD:{repo_path}"
    else:
        spec = f":{repo_path}"
    return git_bytes("rev-parse", spec).decode("utf-8").strip()

def blob_bytes(repo_path):
    oid = blob_oid(repo_path)
    return oid, git_bytes("cat-file", "-p", oid)

def sha256_bytes(value):
    return hashlib.sha256(value).hexdigest()

def sha256_text(value):
    return sha256_bytes(value.encode("utf-8"))

def canonical_json(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))

def state_value(state_text, key):
    pat = re.compile(rf"^\s*{re.escape(key)}:")
    for line in state_text.splitlines():
        if not pat.search(line):
            continue
        value = line.split(":", 1)[1]
        value = re.sub(r"\s+#.*$", "", value).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        return value
    return ""

expected = []
try:
    for raw in pathlib.Path(expected_file).read_text(encoding="utf-8").splitlines():
        if not raw.strip():
            continue
        path, repo_path = raw.split("\t", 1)
        expected.append((path, repo_path))
except Exception as exc:
    print(f"G-ORQ-ENTRADA: lista esperada ilegivel: {exc}", file=sys.stderr)
    sys.exit(1)

manifest = []
content_by_path = {}
repo_by_path = {}
for path, repo_path in expected:
    if path in repo_by_path:
        fail(f"path duplicado na read-list resolvida: {path}")
        continue
    repo_by_path[path] = repo_path
    try:
        oid, content = blob_bytes(repo_path)
    except subprocess.CalledProcessError:
        fail(f"item da read-list ausente no indice/HEAD: {path}")
        continue
    try:
        text = content.decode("utf-8")
    except UnicodeDecodeError:
        fail(f"item da read-list nao e UTF-8: {path}")
        continue
    nonempty = [(i, line) for i, line in enumerate(text.splitlines(), 1) if line.strip()]
    content_by_path[path] = (content, text, nonempty)
    manifest.append({
        "path": path,
        "blob_oid": oid,
        "sha256": sha256_bytes(content),
        "bytes": len(content),
        "nonempty_lines": len(nonempty),
    })

manifest_sha256 = sha256_text(canonical_json(manifest))

try:
    _, attest_content = blob_bytes(attest_repo_path)
except subprocess.CalledProcessError:
    fail(f"atestacao ausente no indice/HEAD: .hbn/attestations/{token_fp}-orq-entrada.json")
    attest_content = b"{}"

try:
    data = json.loads(attest_content.decode("utf-8"))
except Exception as exc:
    print(f"G-ORQ-ENTRADA: atestacao JSON ilegivel: {exc}", file=sys.stderr)
    sys.exit(1)

if not isinstance(data, dict):
    fail("atestacao deve ser um objeto JSON")
    data = {}

state_text = content_by_path.get(state_path, (b"", "", []))[1]
readback_execution_id = ""
if readback_path not in repo_by_path:
    fail(f"readback_ativo nao faz parte da read-list resolvida: {readback_path}")
else:
    try:
        readback_json = json.loads(content_by_path[readback_path][0].decode("utf-8"))
        if isinstance(readback_json, dict):
            readback_execution_id = readback_json.get("execution_id", "")
    except Exception as exc:
        fail(f"readback_ativo JSON ilegivel para extrair execution_id: {exc}")

if not isinstance(readback_execution_id, str) or not readback_execution_id.strip():
    fail("readback_ativo sem execution_id valido")

if data.get("algorithm") != ALGORITHM:
    fail(f"algorithm deve ser {ALGORITHM!r}")
if data.get("bastao_token_fp") != token_fp:
    fail(f"bastao_token_fp divergente: esperado {token_fp}, obtido {data.get('bastao_token_fp')!r}")
if data.get("papel") != "orquestrador":
    fail("campo papel deve ser 'orquestrador'")
state_owner = state_value(state_text, "proprietario_bastao")
if state_owner:
    if data.get("proprietario_bastao") != state_owner:
        fail(f"proprietario_bastao divergente do STATE: esperado {state_owner!r}")
state_identity = state_value(state_text, "identidade") or state_value(state_text, "identidade_bastao")
if state_identity:
    if data.get("identidade") != state_identity:
        fail(f"identidade divergente do STATE: esperado {state_identity!r}")
if data.get("read_list_ref") != "core/read-list-canonica.txt":
    fail("read_list_ref deve apontar para core/read-list-canonica.txt")
if data.get("execution_id") != readback_execution_id:
    fail(f"execution_id divergente do readback ativo: esperado {readback_execution_id!r}")
if data.get("manifest_sha256") != manifest_sha256:
    fail("manifest_sha256 divergente da read-list recomputada")
if "desafios" in data:
    fail("bloco legado 'desafios' nao e permitido no schema v2")
if "itens" in data:
    fail("bloco legado 'itens' nao e permitido no schema v2")

seed_sha256 = ""
if isinstance(readback_execution_id, str) and readback_execution_id.strip():
    seed_sha256 = sha256_text(f"orq-entrada.v2\n{readback_execution_id}\n{token_fp}\n{manifest_sha256}")

challenge = data.get("challenge")
if not isinstance(challenge, dict):
    fail("challenge deve ser objeto")
    challenge = {}
if challenge.get("seed_sha256") != seed_sha256:
    fail("challenge.seed_sha256 divergente")

line_responses = challenge.get("line_responses")
if not isinstance(line_responses, list):
    fail("challenge.line_responses deve ser lista")
    line_responses = []
if len(line_responses) < 3:
    fail("challenge.line_responses deve conter pelo menos 3 itens")

line_by_path = {}
for item in line_responses:
    if not isinstance(item, dict):
        fail("line_responses contem item nao-objeto")
        continue
    path = item.get("path")
    if not isinstance(path, str) or not path:
        fail("line_response sem path valido")
        continue
    if path in line_by_path:
        fail(f"line_response duplicada para path: {path}")
        continue
    if path not in repo_by_path:
        fail(f"line_response para path fora da read-list: {path}")
        continue
    line_by_path[path] = item

required_line_paths = [state_path, readback_path, "core/orchestrator-profile-spec.md"]
for path in required_line_paths:
    item = line_by_path.get(path)
    if item is None:
        fail(f"line_response obrigatoria ausente: {path}")
        continue
    record = next((r for r in manifest if r["path"] == path), None)
    if record is None:
        fail(f"path obrigatorio ausente do manifest: {path}")
        continue
    if record["nonempty_lines"] <= 0:
        fail(f"path obrigatorio sem linhas nao-vazias: {path}")
        continue
    challenge_hash = sha256_text(f"{seed_sha256}\n{path}\n{record['blob_oid']}")
    idx = int(challenge_hash[:8], 16) % record["nonempty_lines"]
    line_no, line_text = content_by_path[path][2][idx]
    line_sha256 = sha256_text(line_text)
    if item.get("line_no") != line_no:
        fail(f"line_no divergente para {path}: esperado {line_no}, obtido {item.get('line_no')!r}")
    if item.get("line_text") != line_text:
        fail(f"line_text divergente para {path}")
    if item.get("line_sha256") != line_sha256:
        fail(f"line_sha256 divergente para {path}")

field_responses = challenge.get("field_responses")
if not isinstance(field_responses, list):
    fail("challenge.field_responses deve ser lista")
    field_responses = []

expected_fields = {
    ("readback_ativo", state_value(state_text, "readback_ativo")),
    ("proxima_acao", state_value(state_text, "proxima_acao")),
}
field_seen = {}
for item in field_responses:
    if not isinstance(item, dict):
        fail("field_responses contem item nao-objeto")
        continue
    path = item.get("path")
    field = item.get("field")
    value = item.get("value")
    if path != state_path:
        fail(f"field_response deve apontar para {state_path}: {path!r}")
        continue
    if field not in {"readback_ativo", "proxima_acao"}:
        fail(f"field_response com campo desconhecido: {field!r}")
        continue
    if field in field_seen:
        fail(f"field_response duplicada para campo: {field}")
        continue
    field_seen[field] = value

for field, expected_value in sorted(expected_fields):
    if not expected_value:
        fail(f"STATE sem campo obrigatorio para challenge: {field}")
        continue
    if field not in field_seen:
        fail(f"field_response obrigatoria ausente: {field}")
        continue
    if field_seen[field] != expected_value:
        fail(f"field_response divergente para {field}")

if errors:
    for message in errors:
        print(f"G-ORQ-ENTRADA: {message}", file=sys.stderr)
    sys.exit(1)
PY
); then
    guard_fail "Atestacao de entrada do orquestrador invalida para bastao ${TOKEN_FP}."
    exit 1
fi

guard_ok "Atestacao de entrada v2 valida para bastao de orquestrador ${TOKEN_FP}."
exit 0
