#!/usr/bin/env bash
# assert-snapshot-integrity.sh (LOCAL) — bloqueia drift/edicao de .usehbn-snapshot/.
set -euo pipefail; export LC_ALL=C
G="assert-snapshot-integrity"
TOP="$(git rev-parse --show-toplevel)"; SNAP="$TOP/.usehbn-snapshot"
sha256(){ if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi | cut -d' ' -f1; }
[[ -d "$SNAP" ]] || { echo "[$G] sem .usehbn-snapshot — nada a verificar."; exit 0; }
[[ -e "$SNAP/.git" ]] && { echo "[$G] ✗ .git dentro do snapshot" >&2; exit 1; }
if find "$SNAP" -type l | grep -q .; then echo "[$G] ✗ symlink no snapshot" >&2; exit 1; fi
if git -C "$TOP" diff --cached --name-only -- .usehbn-snapshot 2>/dev/null | grep -q .; then
  echo "[$G] ✗ mudancas staged em .usehbn-snapshot/ (read-only; use install-snapshot.sh --upgrade)" >&2; exit 1; fi
MAN="$SNAP/PROTOCOL_MANIFEST.sha256"; [[ -f "$MAN" ]] || { echo "[$G] ✗ manifesto ausente" >&2; exit 1; }
RC=0
while read -r mode csha path; do
  f="$SNAP/$path"
  [[ -f "$f" ]] || { echo "[$G] ✗ faltando $path" >&2; RC=1; continue; }
  cur="$(tr -d '\r' < "$f" | sha256)"
  [[ "$cur" == "$csha" ]] || { echo "[$G] ✗ drift em $path" >&2; RC=1; }
done < "$MAN"
ndisk="$(find "$SNAP" -type f -not -name 'PROTOCOL_MANIFEST.sha256' -not -name 'PROTOCOL_SHA256.txt' -not -name 'VERSION' -not -name 'USEHBN-HEADER.txt' -not -name 'CONSUMER-PROFILE.md' | wc -l | tr -d ' ')"
nman="$(grep -c . "$MAN")"
[[ "$ndisk" == "$nman" ]] || { echo "[$G] ✗ arquivos extra no snapshot (disco=$ndisk manifesto=$nman)" >&2; RC=1; }
[[ $RC -eq 0 ]] && echo "[$G] ✓ snapshot integro ($nman arquivos)" || exit 1
