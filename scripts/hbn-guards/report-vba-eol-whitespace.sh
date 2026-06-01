#!/usr/bin/env bash
# Reporta politica EOL/whitespace dos exportaveis VBA sem alterar arquivos.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[hbn-hygiene] root=$REPO_ROOT"
echo
echo "[hbn-hygiene] atributos whitespace relevantes:"
git check-attr whitespace -- \
  src/vba/Teste_V2_Roteiros.bas \
  src/vba/App_Release.bas \
  local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas \
  local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt

echo
echo "[hbn-hygiene] EOL dos arquivos VBA/importaveis rastreados modificados:"
git diff --name-only --diff-filter=ACMR | \
  while IFS= read -r path; do
    case "$path" in
      src/vba/*|local-ai/vba_import/*)
        git ls-files --eol -- "$path"
        ;;
    esac
  done

echo
echo "[hbn-hygiene] git diff --check:"
git diff --check
echo "[hbn-hygiene] OK"
