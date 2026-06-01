#!/usr/bin/env bash
# Checagem curta de higiene do repositorio. Nao altera arquivos.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
CANONICAL_ROOT="$(cat "$REPO_ROOT/.hbn/canonical-root" 2>/dev/null | tr -d '[:space:]')"

echo "[hbn-hygiene] root=$REPO_ROOT"
if [[ "$REPO_ROOT" != "$CANONICAL_ROOT" ]]; then
  echo "[hbn-hygiene] ERRO: raiz canonica esperada=$CANONICAL_ROOT" >&2
  exit 1
fi

echo "[hbn-hygiene] branch=$(git branch --show-current)"
echo
echo "[hbn-hygiene] diff --check"
git diff --check

echo
echo "[hbn-hygiene] readback ativo"
ACTIVE_RB="$(ls -1 .hbn/readbacks/[0-9]*.json 2>/dev/null | sort | tail -1 || true)"
if [[ -n "$ACTIVE_RB" ]]; then
  echo "  $ACTIVE_RB"
  scripts/hbn-guards/validate-readback.sh "$ACTIVE_RB"
else
  echo "  nenhum readback encontrado"
fi

echo
echo "[hbn-hygiene] arquivos nao rastreados nao ignorados"
UNTRACKED="$(git ls-files --others --exclude-standard)"
if [[ -z "$UNTRACKED" ]]; then
  echo "  nenhum"
else
  echo "$UNTRACKED" | sed 's/^/  /'
fi

echo
echo "[hbn-hygiene] status curto"
git status --short --branch
