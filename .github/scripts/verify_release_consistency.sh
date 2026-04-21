#!/usr/bin/env bash
set -euo pipefail

APP_FILE="src/vba/App_Release.bas"
STATUS_FILE="obsidian-vault/releases/STATUS-OFICIAL.md"
CHANGELOG_FILE="CHANGELOG.md"
README_FILE="README.md"

extract_const() {
  local name="$1"
  sed -n "s/^Public Const ${name} As String = \"\\(.*\\)\"/\\1/p" "$APP_FILE" | head -n1
}

trim() {
  awk '{gsub(/^[ \t]+|[ \t]+$/, "", $0); print}'
}

normalize_status_for_public_table() {
  case "$1" in
    VALIDADO) echo "VALIDADA" ;;
    SUPERADO) echo "SUPERADA" ;;
    REVERTIDO) echo "REVERTIDA" ;;
    *) echo "$1" ;;
  esac
}

require_file() {
  local file="$1"
  test -f "$file" || { echo "Arquivo obrigatório ausente: $file" >&2; exit 1; }
}

require_dir() {
  local dir="$1"
  test -d "$dir" || { echo "Diretório obrigatório ausente: $dir" >&2; exit 1; }
}

require_file "$APP_FILE"
require_file "$STATUS_FILE"
require_file "$CHANGELOG_FILE"
require_file "$README_FILE"

app_version="$(extract_const APP_RELEASE_ATUAL)"
app_status="$(extract_const APP_RELEASE_STATUS)"
app_tag="$(extract_const APP_RELEASE_TAG)"
app_evidence_dir="$(extract_const APP_RELEASE_EVIDENCE_DIR)"
app_test_key="$(extract_const APP_RELEASE_TEST_KEY)"

test -n "$app_version" || { echo "APP_RELEASE_ATUAL não encontrado" >&2; exit 1; }
test -n "$app_status" || { echo "APP_RELEASE_STATUS não encontrado" >&2; exit 1; }
test -n "$app_tag" || { echo "APP_RELEASE_TAG não encontrado" >&2; exit 1; }
test -n "$app_evidence_dir" || { echo "APP_RELEASE_EVIDENCE_DIR não encontrado" >&2; exit 1; }
test -n "$app_test_key" || { echo "APP_RELEASE_TEST_KEY não encontrado" >&2; exit 1; }

expected_tag="v${app_version#V}"
if [[ "$app_tag" != "$expected_tag" ]]; then
  echo "Tag inconsistente. Esperado: $expected_tag | Encontrado: $app_tag" >&2
  exit 1
fi

status_line="$(grep -F "| ${app_version} |" "$STATUS_FILE" | head -n1 || true)"
test -n "$status_line" || { echo "Versão $app_version não encontrada em $STATUS_FILE" >&2; exit 1; }

status_value="$(printf '%s\n' "$status_line" | awk -F'|' '{print $3}' | trim)"
expected_public_status="$(normalize_status_for_public_table "$app_status")"
if [[ "$status_value" != "$expected_public_status" ]]; then
  echo "Status inconsistente. App_Release=$app_status | STATUS-OFICIAL=$status_value" >&2
  exit 1
fi

latest_status_line="$(grep -E '^\| V[0-9]+\.[0-9]+\.[0-9]{4} \|' "$STATUS_FILE" | head -n1 || true)"
latest_status_version="$(printf '%s\n' "$latest_status_line" | awk -F'|' '{print $2}' | trim)"
if [[ "$latest_status_version" != "$app_version" ]]; then
  echo "A primeira linha da tabela oficial não coincide com a versão do código. App_Release=$app_version | STATUS-OFICIAL=$latest_status_version" >&2
  exit 1
fi

release_note="obsidian-vault/releases/${app_version}.md"
require_file "$release_note"
grep -Fq "# ${app_version}" "$release_note" || { echo "Release note sem cabeçalho esperado: $release_note" >&2; exit 1; }
grep -Fq "Status: ${app_status}" "$release_note" || { echo "Release note sem status esperado: $release_note" >&2; exit 1; }

grep -Fq "## [${app_version}]" "$CHANGELOG_FILE" || { echo "CHANGELOG sem entrada da versão $app_version" >&2; exit 1; }
grep -Fq "Linha oficial: \`${app_version}\`" "$README_FILE" || { echo "README sem linha oficial $app_version" >&2; exit 1; }

require_dir "$app_evidence_dir"
require_file "${app_evidence_dir}/MANIFEST.md"
ls "${app_evidence_dir}"/BateriaOficial_*.csv >/dev/null 2>&1 || { echo "Sem CSVs da Bateria Oficial em $app_evidence_dir" >&2; exit 1; }
ls "${app_evidence_dir}"/BateriaOficial_Falhas_*.csv >/dev/null 2>&1 || { echo "Sem CSVs de falhas da Bateria Oficial em $app_evidence_dir" >&2; exit 1; }
ls "${app_evidence_dir}"/V2_VALIDACAO_HUMANA_*.md >/dev/null 2>&1 || { echo "Sem validação humana V2 em $app_evidence_dir" >&2; exit 1; }
grep -Fq "\`${app_version}\`" "${app_evidence_dir}/MANIFEST.md" || { echo "Manifesto de evidências sem versão $app_version" >&2; exit 1; }

git rev-parse -q --verify "refs/tags/${app_tag}" >/dev/null || { echo "Tag ausente no repositório local: $app_tag" >&2; exit 1; }

echo "Release consistente:"
echo "  versão: ${app_version}"
echo "  status: ${app_status} -> ${expected_public_status}"
echo "  tag: ${app_tag}"
echo "  evidência: ${app_evidence_dir}"
echo "  chave pública de teste: ${app_test_key}"
