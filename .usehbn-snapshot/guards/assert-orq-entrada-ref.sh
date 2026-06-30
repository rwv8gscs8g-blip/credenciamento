#!/usr/bin/env bash
# =============================================================================
# guards/assert-orq-entrada-ref.sh
# G-ORQ-REF: atos de autoridade do orquestrador devem apontar para a
# atestacao de entrada vigente por orq_entrada_ref.
#
# Escopo do gate: despacho (.hbn/dispatch/*.md e .hbn/messages/*.md com
# tipo=despacho no front matter YAML), selagem (readback com authority_act=
# selagem, status selado/vigente ou nome contendo selagem) e freeze
# (.hbn/freeze/*.json). Entregas de implementacao e pareceres nao sao gateados
# por este guard.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-orq-entrada-ref"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

REPO_ROOT="$(guard_repo_root)"
if [[ -z "$REPO_ROOT" ]]; then
    guard_fail "Nao foi possivel resolver a raiz Git."
    exit 1
fi

ACTIVE_PREFIX="$(guard_active_version_prefix || true)"
if [[ -z "${ACTIVE_PREFIX+x}" ]]; then
    guard_fail "Versao ativa invalida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}."
    exit 1
fi

FILES_LIST="$(mktemp)"
ERR_FILE="$(mktemp)"
trap 'rm -f "$FILES_LIST" "$ERR_FILE"' EXIT

while IFS= read -r version_path; do
    [[ -z "$version_path" ]] && continue
    repo_path="$(guard_version_repo_path "$version_path" || true)"
    [[ -z "$repo_path" ]] && continue
    printf '%s\t%s\n' "$version_path" "$repo_path" >> "$FILES_LIST"
done < <(guard_diff_files)

PY_OUT="$(
    cd "$REPO_ROOT"
    python3 - "$ACTIVE_PREFIX" "$FILES_LIST" "$SCRIPT_DIR" 2>"$ERR_FILE" <<'PY'
import json
import os
import re
import subprocess
import sys

active_prefix, files_list, script_dir = sys.argv[1:4]
diff_base = os.environ.get("HBN_DIFF_BASE", "")
ci_mode = bool(diff_base)
errors = []
ATTEST_RE = re.compile(r"^\.hbn/attestations/([0-9a-fA-F]{8})-orq-entrada\.json$")

def fail(message):
    errors.append(message)

def repo_path(version_path):
    return f"{active_prefix}{version_path}" if active_prefix else version_path

def version_path_from_repo(path):
    if active_prefix and path.startswith(active_prefix):
        return path[len(active_prefix):]
    return path

def spec_for_ref(ref, version_path):
    repo = repo_path(version_path)
    if ref == "index":
        return f":{repo}"
    return f"{ref}:{repo}"

def git(*args, check=True, env=None):
    result = subprocess.run(
        ["git", *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env=env,
    )
    if check and result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, ["git", *args], result.stdout, result.stderr)
    return result

def read_version_blob(ref, version_path):
    return subprocess.check_output(
        ["git", "show", spec_for_ref(ref, version_path)],
        stderr=subprocess.DEVNULL,
    ).decode("utf-8")

def blob_exists(ref, version_path):
    return subprocess.call(
        ["git", "cat-file", "-e", spec_for_ref(ref, version_path)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    ) == 0

def unquote(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
        return value[1:-1]
    return value

def state_value(state_text, key):
    pat = re.compile(rf"^\s*{re.escape(key)}:")
    for line in state_text.splitlines():
        if not pat.search(line):
            continue
        value = re.sub(r"\s+#.*$", "", line.split(":", 1)[1]).strip()
        return unquote(value)
    return ""

def front_matter_value(ref, path, key, label):
    try:
        text = read_version_blob(ref, path)
    except Exception as exc:
        fail(f"{label}: {path}: mensagem ilegivel no indice/HEAD ({exc})")
        return ""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return ""
    end = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end = idx
            break
    if end is None:
        fail(f"{label}: {path}: front matter YAML nao fechado")
        return ""
    pat = re.compile(rf"^\s*{re.escape(key)}\s*:")
    for raw in lines[1:end]:
        if pat.search(raw):
            return unquote(raw.split(":", 1)[1])
    return ""

def is_message_dispatch(ref, path, label):
    if not blob_exists(ref, path):
        return False
    tipo = front_matter_value(ref, path, "tipo", label).strip().lower()
    return tipo == "despacho"

def parse_name_status(text):
    entries = []
    for raw in text.splitlines():
        if not raw.strip():
            continue
        parts = raw.rstrip("\n").split("\t")
        status = parts[0]
        code = status[0]
        old_path = None
        new_path = None
        if code in {"R", "C"} and len(parts) >= 3:
            old_path = version_path_from_repo(parts[1])
            new_path = version_path_from_repo(parts[2])
        elif code == "D" and len(parts) >= 2:
            old_path = version_path_from_repo(parts[1])
        elif len(parts) >= 2:
            new_path = version_path_from_repo(parts[1])
        entries.append({"status": status, "code": code, "old": old_path, "new": new_path})
    return entries

def changed_paths_from_entries(entries):
    paths = []
    for entry in entries:
        if entry.get("new"):
            paths.append(entry["new"])
        elif entry.get("old"):
            paths.append(entry["old"])
    return paths

def dispatch_readback_path(ref, path):
    try:
        text = read_version_blob(ref, path)
    except Exception as exc:
        fail(f"{path}: despacho ilegivel no indice/HEAD ({exc})")
        return ""
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        fail(f"{path}: despacho sem front matter YAML")
        return ""
    end = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end = idx
            break
    if end is None:
        fail(f"{path}: front matter YAML nao fechado")
        return ""
    readback_id = ""
    for raw in lines[1:end]:
        if raw.startswith("readback_id:"):
            readback_id = unquote(raw.split(":", 1)[1])
            break
        if raw.startswith("readback_alvo:"):
            readback_id = unquote(raw.split(":", 1)[1])
            break
    if not readback_id:
        fail(f"{path}: despacho sem readback_id")
        return ""
    if readback_id.startswith(".hbn/readbacks/"):
        return readback_id
    return f".hbn/readbacks/{readback_id}.json"

def is_authority_readback(path, data):
    values = []
    for key in ("authority_act", "ato_autoridade", "tipo_ato", "act", "kind"):
        value = data.get(key)
        if isinstance(value, str):
            values.append(value.lower())
    if any(value in {"despacho", "selagem", "freeze"} for value in values):
        return True

    readback_id = data.get("readback_id", "")
    status = data.get("status", "")
    haystack = f"{path} {readback_id}".lower()
    if "selagem" in haystack:
        return True
    if isinstance(status, str) and status.lower() in {"selado", "sealed", "vigente"}:
        return True
    return False

def load_json(ref, path, label):
    try:
        data = json.loads(read_version_blob(ref, path))
    except subprocess.CalledProcessError as exc:
        fail(f"{label}: blob ausente para {path} ({exc})")
        return None
    except Exception as exc:
        fail(f"{label}: JSON ilegivel em {path} ({exc})")
        return None
    if not isinstance(data, dict):
        fail(f"{label}: JSON deve ser objeto em {path}")
        return None
    return data

def attest_fp(path):
    match = ATTEST_RE.fullmatch(path or "")
    return match.group(1).lower() if match else ""

def collect_authority(new_ref, changed_paths, label):
    authority_targets = []
    authority_paths = []
    for path in sorted(set(p for p in changed_paths if p)):
        if re.match(r"^\.hbn/dispatch/.*\.md$", path):
            authority_paths.append(path)
            target = dispatch_readback_path(new_ref, path)
            if target:
                authority_targets.append(target)
            continue

        if re.match(r"^\.hbn/messages/.*\.md$", path) and is_message_dispatch(new_ref, path, label):
            authority_paths.append(path)
            target = dispatch_readback_path(new_ref, path)
            if target:
                authority_targets.append(target)
            continue

        if re.match(r"^\.hbn/freeze/.*\.json$", path):
            authority_paths.append(path)
            authority_targets.append(path)
            continue

        if re.match(r"^\.hbn/readbacks/.*\.json$", path):
            try:
                data = json.loads(read_version_blob(new_ref, path))
            except Exception as exc:
                if "selagem" in path.lower():
                    authority_paths.append(path)
                    fail(f"{label}: {path}: readback de selagem ilegivel/ausente ({exc})")
                continue
            if isinstance(data, dict) and is_authority_readback(path, data):
                authority_paths.append(path)
                authority_targets.append(path)
    return authority_paths, authority_targets

def validate_authority_context(new_ref, old_ref, changed_paths, entries, label, validate_attestation_ref=None):
    authority_paths, authority_targets = collect_authority(new_ref, changed_paths, label)
    if not authority_paths:
        return 0, ""

    try:
        state_text = read_version_blob(new_ref, ".hbn/relay/STATE.md")
    except Exception as exc:
        fail(f"{label}: STATE ausente/ilegivel para ato de autoridade ({exc})")
        state_text = ""

    try:
        old_state_text = read_version_blob(old_ref, ".hbn/relay/STATE.md")
    except Exception as exc:
        fail(f"{label}: STATE base ausente/ilegivel para comparar bastao ({exc})")
        old_state_text = ""

    token_sha = state_value(state_text, "bastao_token_sha256")
    old_token_sha = state_value(old_state_text, "bastao_token_sha256")
    if not re.fullmatch(r"[0-9a-fA-F]{64}", token_sha or ""):
        fail(f"{label}: STATE sem bastao_token_sha256 valido para dereferenciar orq_entrada_ref")
        token_fp = ""
    else:
        token_fp = token_sha[:8].lower()
    if old_state_text and not re.fullmatch(r"[0-9a-fA-F]{64}", old_token_sha or ""):
        fail(f"{label}: STATE base sem bastao_token_sha256 valido para comparar bastao")

    expected_ref = f".hbn/attestations/{token_fp}-orq-entrada.json" if token_fp else ""
    if expected_ref and not blob_exists(new_ref, expected_ref):
        fail(f"{label}: atestacao orq_entrada_ref ausente: {expected_ref}")

    seen = set()
    for target in authority_targets:
        if target in seen:
            continue
        seen.add(target)
        data = load_json(new_ref, target, label)
        if data is None:
            continue
        value = data.get("orq_entrada_ref")
        if not isinstance(value, str) or not value.strip():
            fail(f"{label}: {target}: campo orq_entrada_ref ausente")
            continue
        if expected_ref and value != expected_ref:
            fail(f"{label}: {target}: orq_entrada_ref '{value}' diverge do esperado '{expected_ref}'")

    attestation_entries = []
    for entry in entries:
        paths = [p for p in (entry.get("old"), entry.get("new")) if p]
        if any(ATTEST_RE.fullmatch(p) for p in paths):
            attestation_entries.append(entry)

    if not attestation_entries:
        return len(authority_paths), expected_ref

    if len(attestation_entries) != 1:
        changed = sorted({p for e in attestation_entries for p in (e.get("old"), e.get("new")) if p})
        fail(f"{label}: multiplas atestacoes alteradas em ato de autoridade: {' '.join(changed)}")
        return len(authority_paths), expected_ref

    entry = attestation_entries[0]
    changed_att_paths = [p for p in (entry.get("old"), entry.get("new")) if p and ATTEST_RE.fullmatch(p)]
    if entry.get("status") != "M" or entry.get("old") is not None or entry.get("new") != expected_ref:
        fail(f"{label}: ato de autoridade so pode MODIFICAR a atestacao esperada {expected_ref}; status={entry.get('status')} paths={' '.join(changed_att_paths)}")
        return len(authority_paths), expected_ref
    if any(path != expected_ref for path in changed_att_paths):
        fail(f"{label}: atestacao fora do fp esperado alterada em ato de autoridade: {' '.join(changed_att_paths)}")
        return len(authority_paths), expected_ref

    path_fp = attest_fp(expected_ref)
    old_data = load_json(old_ref, expected_ref, f"{label} base")
    new_data = load_json(new_ref, expected_ref, f"{label} novo")
    if old_data is None or new_data is None:
        return len(authority_paths), expected_ref

    for data_label, data in (("base", old_data), ("novo", new_data)):
        for field in ("bastao_token_fp", "manifest_sha256", "proprietario_bastao", "identidade"):
            if not isinstance(data.get(field), str) or not data.get(field).strip():
                fail(f"{label}: atestacao {data_label} com campo {field} ausente/nao-string")

    for source, value in (
        ("nome", path_fp),
        ("JSON base", str(old_data.get("bastao_token_fp", "")).lower()),
        ("JSON novo", str(new_data.get("bastao_token_fp", "")).lower()),
        ("STATE novo", token_fp),
    ):
        if value != token_fp:
            fail(f"{label}: fp divergente em {source}: esperado {token_fp}, obtido {value}")

    if old_token_sha and token_sha and old_token_sha != token_sha:
        fail(f"{label}: bastao_token_sha256 completo mudou no ato de autoridade")
    if old_data.get("manifest_sha256") == new_data.get("manifest_sha256"):
        fail(f"{label}: regeneracao de atestacao nao alterou manifest_sha256")
    if old_data.get("proprietario_bastao") != new_data.get("proprietario_bastao"):
        fail(f"{label}: proprietario_bastao diverge do HEAD/base")
    if old_data.get("identidade") != new_data.get("identidade"):
        fail(f"{label}: identidade diverge do HEAD/base")

    if validate_attestation_ref:
        env = os.environ.copy()
        env["HBN_ORQ_ENTRADA_GIT_REF"] = validate_attestation_ref
        result = subprocess.run(
            ["bash", os.path.join(script_dir, "assert-orq-entrada.sh")],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            env=env,
        )
        if result.returncode != 0:
            detail = result.stderr.strip().splitlines()[-1] if result.stderr.strip() else f"rc={result.returncode}"
            fail(f"{label}: nova atestacao nao passa assert-orq-entrada.sh ({detail})")

    return len(authority_paths), expected_ref

local_changed = []
with open(files_list, encoding="utf-8") as handle:
    for raw in handle:
        raw = raw.rstrip("\n")
        if not raw:
            continue
        version_path, repo = raw.split("\t", 1)
        local_changed.append(version_path)

auth_count = 0
expected_ref = ""
if ci_mode:
    revs = git("rev-list", "--reverse", f"{diff_base}..HEAD", check=False).stdout.splitlines()
    for commit in revs:
        if not commit.strip():
            continue
        parent_result = git("rev-parse", f"{commit}^", check=False)
        if parent_result.returncode != 0:
            fail(f"commit {commit[:12]} sem parent para comparar ato de autoridade")
            continue
        parent = parent_result.stdout.strip()
        entries = parse_name_status(git("diff-tree", "--no-commit-id", "--name-status", "-r", "-M", commit).stdout)
        count, ref = validate_authority_context(
            commit,
            parent,
            changed_paths_from_entries(entries),
            entries,
            f"commit {commit[:12]}",
            validate_attestation_ref=commit,
        )
        auth_count += count
        expected_ref = ref or expected_ref
else:
    entries = parse_name_status(git("diff", "--cached", "--name-status", "--diff-filter=ACMRD", "-M").stdout)
    count, ref = validate_authority_context("index", "HEAD", local_changed or changed_paths_from_entries(entries), entries, "staged")
    auth_count += count
    expected_ref = ref or expected_ref

if errors:
    for message in errors:
        print(f"G-ORQ-REF: {message}", file=sys.stderr)
    sys.exit(1)

print(f"AUTH\t{auth_count}\t{expected_ref}")
PY
)" || {
    while IFS= read -r err; do
        [[ -z "$err" ]] && continue
        guard_fail "$err"
    done < "$ERR_FILE"
    exit 1
}

AUTH_COUNT="$(printf '%s\n' "$PY_OUT" | awk -F'\t' '$1=="AUTH"{print $2; exit}')"
EXPECTED_REF="$(printf '%s\n' "$PY_OUT" | awk -F'\t' '$1=="AUTH"{print $3; exit}')"

if [[ "${AUTH_COUNT:-0}" == "0" ]]; then
    guard_ok "Nenhum ato de autoridade do orquestrador staged/HEAD — G-ORQ-REF nao opina."
    exit 0
fi

if ! bash "${SCRIPT_DIR}/assert-orq-entrada.sh"; then
    guard_fail "Atestacao referenciada por orq_entrada_ref nao passa o assert-orq-entrada.sh vigente (${EXPECTED_REF})."
    exit 1
fi

guard_ok "orq_entrada_ref dereferenciado e atestacao vigente validada para ${AUTH_COUNT} ato(s) de autoridade."
exit 0
