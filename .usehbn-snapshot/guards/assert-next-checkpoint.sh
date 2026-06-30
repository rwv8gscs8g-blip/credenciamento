#!/usr/bin/env bash
# =============================================================================
# guards/assert-next-checkpoint.sh
# G-NEXT: STATE.md deve declarar o proximo ponto de conferencia em campo
# legivel por maquina.
#
# Escopo: commits em que .hbn/relay/STATE.md seja adicionado/modificado.
# Local: valida o blob staged (:path). CI: valida HEAD:path no range
# HBN_DIFF_BASE...HEAD. Nunca le a working tree de STATE.md.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-next-checkpoint"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

STATE_PATH=".hbn/relay/STATE.md"
MAP_PATH="guards/data/auditor-families.txt"

if ! ACTIVE_PREFIX="$(guard_active_version_prefix)"; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Nao e possivel validar ${STATE_PATH}."
    exit 1
fi

state_diff_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=AM "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=AM 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

blob_ref() {
    local p repo_path
    p="$1"
    repo_path="$(guard_version_repo_path "$p")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$repo_path"
    else
        printf ':%s\n' "$repo_path"
    fi
}

STATE_TOUCHED=0
while IFS= read -r f; do
    [[ "$f" == "$STATE_PATH" ]] && STATE_TOUCHED=1
done < <(state_diff_files)

if [[ "$STATE_TOUCHED" -ne 1 ]]; then
    guard_ok "STATE nao foi adicionado/modificado neste diff — G-NEXT nao opina."
    exit 0
fi

STATE_REF="$(blob_ref "$STATE_PATH" || true)"
MAP_REF="$(blob_ref "$MAP_PATH" || true)"
if [[ -z "$STATE_REF" || -z "$MAP_REF" ]]; then
    guard_fail "Nao foi possivel resolver referencias staged/HEAD para STATE ou mapa de auditores."
    exit 1
fi

if ! git cat-file -e "$STATE_REF" 2>/dev/null; then
    guard_fail "STATE ausente/ilegivel no indice/HEAD: ${STATE_PATH}."
    exit 1
fi
if ! git cat-file -e "$MAP_REF" 2>/dev/null; then
    guard_fail "Mapa de apelidos ausente/ilegivel no indice/HEAD: ${MAP_PATH}."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    guard_fail "python3 ausente — nao consigo validar front-matter YAML de ${STATE_PATH}."
    exit 2
fi

if ! python3 - "$STATE_REF" "$MAP_REF" "$ACTIVE_PREFIX" "${HBN_DIFF_BASE:-}" <<'PY'
import re
import subprocess
import sys

state_ref, map_ref, active_prefix, diff_base = sys.argv[1:5]
use_head = bool(diff_base)
errors = []

ACTOS = {"implementacao", "cross-audit", "hearback", "selagem", "freeze", "fim"}
GATES = {"nenhum", "hearback_humano"}
STATUS = {"pendente", "em_curso", "concluido"}
REQUIRED = {"passo", "ato", "destino", "gate", "bloco_ref", "status"}
PATH_RE = re.compile(r"^[A-Za-z0-9._/\-]+$")
KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$")
FIELD_RE = re.compile(r"^[ \t]+([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$")


def fail(message):
    errors.append(message)


def git_text(*args):
    return subprocess.check_output(["git", *args], stderr=subprocess.DEVNULL).decode("utf-8")


def strip_comment(value):
    in_single = False
    in_double = False
    escaped = False
    for idx, char in enumerate(value):
        if escaped:
            escaped = False
            continue
        if char == "\\" and in_double:
            escaped = True
            continue
        if char == "'" and not in_double:
            in_single = not in_single
            continue
        if char == '"' and not in_single:
            in_double = not in_double
            continue
        if char == "#" and not in_single and not in_double:
            if idx == 0 or value[idx - 1].isspace():
                return value[:idx].rstrip()
    return value.strip()


def scalar(value):
    value = strip_comment(value).strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def version_to_repo_path(path):
    return f"{active_prefix}{path}" if active_prefix else path


def valid_version_path(path):
    if not path or path == "nenhum":
        return False
    if path.startswith("/") or "\\" in path or ":" in path:
        return False
    if not PATH_RE.fullmatch(path):
        return False
    parts = path.split("/")
    if any(part in {"", ".", ".."} for part in parts):
        return False
    return True


def blob_exists(path):
    repo_path = version_to_repo_path(path)
    ref = f"HEAD:{repo_path}" if use_head else f":{repo_path}"
    return subprocess.call(
        ["git", "cat-file", "-e", ref],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    ) == 0


def parse_aliases(text):
    aliases = {"codex", "human", "nenhum"}
    for line_no, raw in enumerate(text.splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != 2:
            fail(f"{map_ref}: linha invalida no mapa de familias ({line_no}): {line}")
            continue
        aliases.add(parts[0])
    return aliases


def frontmatter_lines(text):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        fail(f"{state_ref}: front-matter YAML ausente.")
        return []
    end = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end = idx
            break
    if end is None:
        fail(f"{state_ref}: front-matter YAML nao fechado.")
        return []
    return lines[1:end]


def parse_proximo_ponto(fm):
    occurrences = []
    for idx, line in enumerate(fm):
        if not line or line[0].isspace() or line.lstrip().startswith("#"):
            continue
        match = KEY_RE.match(line)
        if match and match.group(1) == "proximo_ponto":
            occurrences.append((idx, match.group(2).strip()))

    if len(occurrences) != 1:
        fail(f"{state_ref}: esperado exatamente 1 proximo_ponto top-level; encontrados {len(occurrences)}.")
        return {}

    start, inline_value = occurrences[0]
    if strip_comment(inline_value):
        fail(f"{state_ref}: proximo_ponto deve ser mapeamento em bloco, nao valor inline.")
        return {}

    end = len(fm)
    for idx in range(start + 1, len(fm)):
        line = fm[idx]
        if not line or line.lstrip().startswith("#"):
            continue
        if not line[0].isspace() and KEY_RE.match(line):
            end = idx
            break

    fields = {}
    for rel_idx, raw in enumerate(fm[start + 1:end], start + 2):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        match = FIELD_RE.match(raw)
        if not match:
            fail(f"{state_ref}: linha invalida dentro de proximo_ponto ({rel_idx}): {raw}")
            continue
        key, raw_value = match.group(1), match.group(2)
        if key in fields:
            fail(f"{state_ref}: campo duplicado em proximo_ponto: {key}")
            continue
        value = scalar(raw_value)
        if value == "":
            fail(f"{state_ref}: campo vazio em proximo_ponto: {key}")
        fields[key] = value
    return fields


try:
    state_text = git_text("show", state_ref)
except Exception as exc:
    fail(f"{state_ref}: blob ilegivel ({exc})")
    state_text = ""

try:
    map_text = git_text("show", map_ref)
except Exception as exc:
    fail(f"{map_ref}: blob ilegivel ({exc})")
    map_text = ""

aliases = parse_aliases(map_text)
fields = parse_proximo_ponto(frontmatter_lines(state_text))

if fields:
    missing = sorted(REQUIRED - set(fields))
    extra = sorted(set(fields) - REQUIRED)
    for key in missing:
        fail(f"{state_ref}: proximo_ponto sem campo obrigatorio: {key}")
    for key in extra:
        fail(f"{state_ref}: proximo_ponto contem campo extra nao permitido: {key}")

    passo = fields.get("passo", "")
    ato = fields.get("ato", "")
    destino = fields.get("destino", "")
    gate = fields.get("gate", "")
    bloco_ref = fields.get("bloco_ref", "")
    status = fields.get("status", "")

    if not passo.strip():
        fail(f"{state_ref}: proximo_ponto.passo deve ser string nao-vazia.")
    if ato not in ACTOS:
        fail(f"{state_ref}: proximo_ponto.ato invalido: {ato}")
    if destino not in aliases:
        fail(f"{state_ref}: proximo_ponto.destino nao-canonico: {destino}")
    if gate not in GATES:
        fail(f"{state_ref}: proximo_ponto.gate invalido: {gate}")
    if status not in STATUS:
        fail(f"{state_ref}: proximo_ponto.status invalido: {status}")

    if ato == "fim":
        if bloco_ref != "nenhum":
            fail(f"{state_ref}: proximo_ponto.bloco_ref deve ser 'nenhum' quando ato=fim.")
    else:
        if bloco_ref == "nenhum":
            fail(f"{state_ref}: proximo_ponto.bloco_ref so pode ser 'nenhum' quando ato=fim.")
        elif not valid_version_path(bloco_ref):
            fail(f"{state_ref}: proximo_ponto.bloco_ref nao e caminho versionado seguro: {bloco_ref}")
        elif not blob_exists(bloco_ref):
            fail(f"{state_ref}: proximo_ponto.bloco_ref inexistente no indice/HEAD: {bloco_ref}")

if errors:
    for error in errors:
        print(f"G-NEXT: {error}", file=sys.stderr)
    sys.exit(1)
PY
then
    guard_fail "${STATE_PATH} sem proximo_ponto valido no blob staged/HEAD."
    exit 1
fi

guard_ok "STATE contem proximo_ponto valido no blob staged/HEAD."
exit 0
