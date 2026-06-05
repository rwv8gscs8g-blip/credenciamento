#!/usr/bin/env python3
# =============================================================================
# scripts/hbn-guards/ci/scope-lock-range.py
# CI v1 (onda 0116/A3): scope-lock sobre um RANGE de commits, por commit.
#
# FONTE CANÔNICA DA SEMÂNTICA: scripts/hbn-guards/assert-scope-lock.sh
# (guard local de pre-commit). Este script REPLICA aquela semântica para o
# contexto de CI (sem index/staged). Qualquer mudança no .sh DEVE ser
# replicada aqui — acoplamento registrado em auditoria/00_status/125.
#
# Semântica por commit C do range:
#   1. Readback ativo histórico = maior NNNN em .hbn/readbacks/ NA ÁRVORE de C.
#   2. Sem readback → skip (sem onda em curso).
#   3. track=fast_track → skip (não obrigatório; igual ao .sh).
#   4. track=safe_track e human_status≠confirmed → FALHA.
#   5. Arquivos alterados (ACMR) de C devem casar com files_allowed +
#      meta-paths sempre permitidos; files_forbidden tem precedência.
#   6. Mensagem contém [bypass-hbn-guards] → commit pulado com WARNING;
#      exige ao menos 1 nota .hbn/bypasses/ tocada no RANGE (senão FALHA).
#
# Uso: python3 scope-lock-range.py <base_sha> <head_sha> [repo_root]
# Só usa plumbing de LEITURA (rev-list, diff-tree, ls-tree, show, log).
# =============================================================================
import fnmatch
import json
import re
import subprocess
import sys

BASE, HEAD = sys.argv[1], sys.argv[2]
ROOT = sys.argv[3] if len(sys.argv) > 3 else "."
FAILS = []
WARNINGS = []


def git(*args):
    return subprocess.run(
        ["git", "-C", ROOT, *args], capture_output=True, text=True, check=False
    ).stdout


def matches(file, patterns):
    """Replica matches_any() do assert-scope-lock.sh: glob simples + '**'."""
    for pat in patterns:
        if fnmatch.fnmatch(file, pat):
            return True
        if "**" in pat:
            prefix, _, suffix = pat.partition("**")
            if file.startswith(prefix) and file.endswith(suffix):
                return True
    return False


def active_readback_at(sha):
    """Maior NNNN-*.json em .hbn/readbacks/ na árvore do commit sha."""
    out = git("ls-tree", "-r", "--name-only", sha, ".hbn/readbacks/")
    rbs = sorted(
        p for p in out.splitlines() if re.search(r"/[0-9]{4}[^/]*\.json$", p)
    )
    if not rbs:
        return None, None
    path = rbs[-1]
    try:
        rb = json.loads(git("show", f"{sha}:{path}"))
    except json.JSONDecodeError:
        FAILS.append(f"{sha[:7]}: readback ativo {path} é JSON inválido")
        return path, None
    return path, rb


def check_commit(sha):
    msg = git("log", "-1", "--format=%B", sha)
    if "[bypass-hbn-guards]" in msg:
        WARNINGS.append(f"{sha[:7]}: bypass declarado na mensagem — scope-lock pulado")
        return "bypass"

    changed = [
        f
        for f in git(
            "diff-tree", "--no-commit-id", "--name-only", "--diff-filter=ACMR",
            "-r", sha,
        ).splitlines()
        if f
    ]
    if not changed:
        return "empty"

    rb_path, rb = active_readback_at(sha)
    if rb_path is None:
        return "no-readback"
    if rb is None:
        return "bad-readback"

    track = rb.get("track", "")
    status = rb.get("human_status", "")
    num = re.search(r"([0-9]{4})", rb_path.rsplit("/", 1)[-1]).group(1)

    if track == "fast_track":
        return "fast_track"
    if track == "safe_track" and status != "confirmed":
        FAILS.append(
            f"{sha[:7]}: safe_track com human_status='{status}' (≠ confirmed) em {rb_path}"
        )
        return "unconfirmed"

    allowed = list(rb.get("scope", {}).get("files_allowed", []) or [])
    forbidden = list(rb.get("scope", {}).get("files_forbidden", []) or [])
    # Meta-paths sempre permitidos — idem assert-scope-lock.sh
    allowed += [
        f".hbn/hearbacks/{num}-*.json",
        f".hbn/hearbacks/{num}-*.md",
        ".hbn/bypasses/**",
        ".hbn/messages/**",
        ".hbn/relay/INDEX.md",
    ]

    for f in changed:
        if forbidden and matches(f, forbidden):
            FAILS.append(f"{sha[:7]}: '{f}' em files_forbidden de {rb_path}")
        elif not matches(f, allowed):
            FAILS.append(f"{sha[:7]}: '{f}' FORA do files_allowed de {rb_path}")
    return "checked"


def main():
    shas = git("rev-list", "--reverse", f"{BASE}..{HEAD}").split()
    if not shas:
        print(f"[scope-lock-range] Range vazio ({BASE[:7]}..{HEAD[:7]}) — nada a verificar.")
        return

    bypass_used = False
    for sha in shas:
        if check_commit(sha) == "bypass":
            bypass_used = True

    if bypass_used:
        touched = git("diff", "--name-only", f"{BASE}..{HEAD}", "--", ".hbn/bypasses/")
        if not touched.strip():
            FAILS.append(
                "Range contém commit(s) [bypass-hbn-guards] sem nenhuma nota nova em .hbn/bypasses/"
            )

    for w in WARNINGS:
        print(f"[scope-lock-range] AVISO: {w}")
    if FAILS:
        print(f"\n[scope-lock-range] ✗ {len(FAILS)} violação(ões) em {len(shas)} commit(s):", file=sys.stderr)
        for f in FAILS:
            print(f"  - {f}", file=sys.stderr)
        print("\n  Como corrigir: ver assert-scope-lock.sh (A/B/C) — atualizar readback exige NOVO hearback.", file=sys.stderr)
        sys.exit(1)
    print(f"[scope-lock-range] ✓ {len(shas)} commit(s) verificados — scope respeitado.")


if __name__ == "__main__":
    main()
