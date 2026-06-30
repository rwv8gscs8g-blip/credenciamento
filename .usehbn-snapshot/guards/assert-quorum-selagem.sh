#!/usr/bin/env bash
# =============================================================================
# guards/assert-quorum-selagem.sh
# G-QUORUM: nenhuma selagem sem quorum canonico no disco.
#
# Gatilho forward-only: readbacks .hbn/readbacks/NNNN-*.json ADICIONADOS.
# Se o readback adicionado nao tem status="vigente", nao e selagem e o guard
# nao opina. Para cada selagem nova, exige seals_proposal=NNNN e pelo menos
# duas familias distintas != OpenAI com APROVA_NNNN: SIM em .hbn/results/.
#
# Local valida blobs staged (:path). CI valida HEAD:path no range HBN_DIFF_BASE.
# Nunca le a working tree para decidir.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-quorum-selagem"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MAP_PATH="guards/data/auditor-families.txt"
MAP_REPO_PATH="$(guard_version_repo_path "$MAP_PATH" || true)"
if [[ -z "$MAP_REPO_PATH" ]]; then
    guard_fail "G-QUORUM: mapa canonico ausente/ilegivel em ${MAP_PATH}"
    exit 1
fi

added_readbacks() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=A "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=A 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/readbacks/[0-9]{4}-[^/]+\.json$' || true
}

blob_ref() {
    local version_path="$1" repo_path
    repo_path="$(guard_version_repo_path "$version_path" || true)"
    [[ -n "$repo_path" ]] || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        printf 'HEAD:%s\n' "$repo_path"
    else
        printf ':%s\n' "$repo_path"
    fi
}

list_results() {
    local results_repo_dir
    results_repo_dir="$(guard_version_repo_path ".hbn/results" || true)"
    [[ -n "$results_repo_dir" ]] || return 0
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git ls-tree -r --name-only HEAD -- "$results_repo_dir" 2>/dev/null || true
    else
        git ls-files -- "$results_repo_dir" 2>/dev/null || true
    fi | guard_paths_to_version_paths | grep -E '^\.hbn/results/[^/]+\.md$' || true
}

READBACKS="$(added_readbacks)"
if [[ -z "$READBACKS" ]]; then
    guard_ok "Nenhum readback adicionado no diff — G-QUORUM nao opina."
    exit 0
fi

if ! command -v python3 >/dev/null 2>&1; then
    guard_fail "python3 ausente — nao consigo validar quorum de selagem com seguranca."
    exit 2
fi

FAIL=0
while IFS= read -r rb_path; do
    [[ -z "$rb_path" ]] && continue
    rb_ref="$(blob_ref "$rb_path" || true)"
    if [[ -z "$rb_ref" ]] || ! git cat-file -e "$rb_ref" 2>/dev/null; then
        guard_fail "G-QUORUM: readback adicionado sem blob staged/HEAD legivel: ${rb_path}"
        FAIL=1
        continue
    fi

    results_file="$(mktemp)"
    refs_file="$(mktemp)"
    trap 'rm -f "${results_file:-}" "${refs_file:-}"' EXIT
    while IFS= read -r result_path; do
        [[ -z "$result_path" ]] && continue
        result_ref="$(blob_ref "$result_path" || true)"
        if [[ -z "$result_ref" ]] || ! git cat-file -e "$result_ref" 2>/dev/null; then
            guard_fail "G-QUORUM: result listado mas sem blob staged/HEAD legivel: ${result_path}"
            FAIL=1
            continue
        fi
        printf '%s\n' "$result_path" >> "$results_file"
        printf '%s\t%s\n' "$result_path" "$result_ref" >> "$refs_file"
    done < <(list_results)

    if [[ "$FAIL" -ne 0 ]]; then
        rm -f "$results_file" "$refs_file"
        continue
    fi

    map_ref="$(blob_ref "$MAP_PATH" || true)"
    if [[ -z "$map_ref" ]] || ! git cat-file -e "$map_ref" 2>/dev/null; then
        guard_fail "G-QUORUM: mapa canonico ausente/ilegivel no indice/HEAD: ${MAP_PATH}"
        rm -f "$results_file" "$refs_file"
        FAIL=1
        continue
    fi

    if ! python3 - "$rb_path" "$rb_ref" "$map_ref" "$results_file" "$refs_file" <<'PY'
import json
import os
import re
import subprocess
import sys

rb_path, rb_ref, map_ref, results_file, refs_file = sys.argv[1:6]
errors = []


def fail(message):
    errors.append(message)


def git_text(ref):
    return subprocess.check_output(
        ["git", "show", ref],
        stderr=subprocess.DEVNULL,
    ).decode("utf-8")


def parse_map(text):
    alias_to_family = {}
    families = set()
    for line_no, raw in enumerate(text.splitlines(), 1):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != 2:
            fail(f"{map_ref}: linha invalida ({line_no}): {line}")
            continue
        alias, family = parts
        if alias in alias_to_family:
            fail(f"{map_ref}: apelido duplicado: {alias}")
            continue
        alias_to_family[alias] = family
        families.add(family)
    if not alias_to_family:
        fail(f"{map_ref}: mapa vazio")
    return alias_to_family, families


def parse_frontmatter(text, path):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        fail(f"{path}: front-matter ausente")
        return {}, text
    end = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end = idx
            break
    if end is None:
        fail(f"{path}: front-matter nao fechado")
        return {}, text
    fields = {}
    for line_no, raw in enumerate(lines[1:end], 2):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        if raw[0].isspace():
            continue
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*)$", raw)
        if not match:
            continue
        key, value = match.group(1), match.group(2).strip()
        value = re.sub(r"\s+#.*$", "", value).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        if key in fields:
            fail(f"{path}: campo duplicado no front-matter: {key}")
            continue
        fields[key] = value
    return fields, "\n".join(lines[end + 1 :])


try:
    rb_data = json.loads(git_text(rb_ref))
except Exception as exc:
    print(f"G-QUORUM: {rb_path}: JSON ilegivel ({exc})", file=sys.stderr)
    sys.exit(1)

if not isinstance(rb_data, dict):
    print(f"G-QUORUM: {rb_path}: readback deve ser objeto JSON", file=sys.stderr)
    sys.exit(1)

status = rb_data.get("status")
if status != "vigente":
    sys.exit(0)

proposal = rb_data.get("seals_proposal")
if not isinstance(proposal, str) or not re.fullmatch(r"[0-9]{4}", proposal):
    fail(f"{rb_path}: readback vigente sem seals_proposal NNNN")
else:
    rb_num = os.path.basename(rb_path).split("-", 1)[0]
    if rb_num == proposal:
        fail(f"{rb_path}: seals_proposal nao pode apontar para a propria selagem {proposal}")

try:
    alias_to_family, known_families = parse_map(git_text(map_ref))
except Exception as exc:
    fail(f"{map_ref}: mapa ilegivel ({exc})")
    alias_to_family, known_families = {}, set()

refs = {}
try:
    for raw in open(refs_file, encoding="utf-8"):
        raw = raw.rstrip("\n")
        if not raw:
            continue
        path, ref = raw.split("\t", 1)
        refs[path] = ref
except Exception as exc:
    fail(f"lista de refs de results ilegivel: {exc}")

matching = []
if isinstance(proposal, str) and re.fullmatch(r"[0-9]{4}", proposal):
    suffix = f"-{proposal}.md"
    try:
        for raw in open(results_file, encoding="utf-8"):
            path = raw.strip()
            if path and os.path.basename(path).endswith(suffix):
                matching.append(path)
    except Exception as exc:
        fail(f"lista de results ilegivel: {exc}")

families_with_sim = set()
approval_re = re.compile(rf"^APROVA_{re.escape(str(proposal))}: SIM$", re.MULTILINE)
for path in matching:
    ref = refs.get(path)
    if not ref:
        fail(f"{path}: sem ref staged/HEAD resolvida")
        continue
    try:
        text = git_text(ref)
    except Exception as exc:
        fail(f"{path}: blob ilegivel ({exc})")
        continue
    fields, body = parse_frontmatter(text, path)
    autor = fields.get("autor", "")
    familia = fields.get("familia", "")
    if not autor:
        fail(f"{path}: front-matter sem autor")
        continue
    if not familia:
        fail(f"{path}: front-matter sem familia")
        continue
    expected = alias_to_family.get(autor)
    if expected is None:
        fail(f"{path}: autor fora do mapa canonico: {autor}")
        continue
    if familia not in known_families:
        fail(f"{path}: familia fora do mapa canonico: {familia}")
        continue
    if familia != expected:
        fail(f"{path}: familia incoerente para {autor}: declarou {familia}, esperado {expected}")
        continue
    if not approval_re.search(body):
        continue
    if familia != "OpenAI":
        families_with_sim.add(familia)

if isinstance(proposal, str) and re.fullmatch(r"[0-9]{4}", proposal):
    if len(families_with_sim) < 2:
        found = ",".join(sorted(families_with_sim)) or "nenhuma"
        fail(
            f"{rb_path}: seals_proposal {proposal} tem {len(families_with_sim)} "
            f"familia(s) distintas != OpenAI com APROVA_{proposal}: SIM; exige >=2; encontradas={found}"
        )

if errors:
    for error in errors:
        print(f"G-QUORUM: {error}", file=sys.stderr)
    sys.exit(1)
PY
    then
        guard_fail "G-QUORUM: quorum de selagem invalido para ${rb_path}"
        rm -f "$results_file" "$refs_file"
        FAIL=1
        continue
    fi
    rm -f "$results_file" "$refs_file"
done <<< "$READBACKS"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Quorum de selagem satisfeito ou nenhuma selagem nova no diff."
exit 0
