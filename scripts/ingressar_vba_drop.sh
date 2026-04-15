#!/usr/bin/env bash
set -euo pipefail

# Copia formularios exportados do VBE (drop) -> vba_export/ e publica vba_import/.
#
# Uso:
#   bash scripts/ingressar_vba_drop.sh
#   bash scripts/ingressar_vba_drop.sh /caminho/para/pasta_drop

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DROP_DIR="${1:-$ROOT_DIR/incoming/vba-forms}"
EXPORT_DIR="$ROOT_DIR/vba_export"

normalizar_crlf() {
  local arquivo="$1"
  perl -0pi -e 's/\r?\n/\r\n/g' "$arquivo"
}

garantir_linha_final_vba() {
  local arquivo="$1"
  perl -0pi -e 's/\r\n*\z/\r\n\r\n/s' "$arquivo"
}

if [[ ! -d "$DROP_DIR" ]]; then
  echo "ERRO: pasta drop nao existe: $DROP_DIR" >&2
  exit 1
fi

shopt -s nullglob
frm_files=("$DROP_DIR"/*.frm)
if [[ ${#frm_files[@]} -eq 0 ]]; then
  echo "ERRO: nenhum .frm encontrado em: $DROP_DIR" >&2
  exit 1
fi

for frm in "${frm_files[@]}"; do
  base="$(basename "$frm" .frm)"
  frx="$DROP_DIR/$base.frx"

  if [[ ! -f "$frx" ]]; then
    echo "ERRO: falta o binario do formulario: $frx (obrigatorio junto com $frm)" >&2
    exit 1
  fi

  echo "OK: ingressando $base (.frm + .frx)"

  cp -f "$frm" "$EXPORT_DIR/$base.frm"
  cp -f "$frx" "$EXPORT_DIR/$base.frx"

  normalizar_crlf "$EXPORT_DIR/$base.frm"
  garantir_linha_final_vba "$EXPORT_DIR/$base.frm"
done

bash "$ROOT_DIR/scripts/publicar_vba_import.sh"

echo "OK: drop ingressado em vba_export/ e vba_import publicado."
