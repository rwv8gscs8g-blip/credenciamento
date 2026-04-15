#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EXPORT_DIR="vba_export"
IMPORT_MOD_DIR="vba_import/001-modulo"
IMPORT_FRM_DIR="vba_import/002-formularios"
IMPORT_OBJ_DIR="vba_import/003-objetos"
ORDER_DOC="vba_import/000-ORDEM-IMPORTACAO.txt"

module_order=(
  "000:Mod_Types.bas"
  "001:Const_Colunas.bas"
  "004:Util_Conversao.bas"
  "005:Util_Config.bas"
  "006:Util_Planilha.bas"
  "007:Funcoes.bas"
  "008:Audit_Log.bas"
  "009:AppContext.bas"
  "010:ErrorBoundary.bas"
  "011:Repo_Credenciamento.bas"
  "012:Repo_PreOS.bas"
  "013:Repo_OS.bas"
  "014:Repo_Avaliacao.bas"
  "015:Repo_Empresa.bas"
  "016:Svc_Rodizio.bas"
  "017:Svc_PreOS.bas"
  "018:Svc_OS.bas"
  "019:Svc_Avaliacao.bas"
  "020:Classificar.bas"
  "021:Preencher.bas"
  "022:Variaveis.bas"
  "023:Emergencia_CNAE.bas"
  "024:App_Release.bas"
  "025:Auto_Open.bas"
  "030:Central_Testes.bas"
  "031:Teste_Bateria_Oficial.bas"
  "032:Central_Testes_Relatorio.bas"
  "033:Treinamento_Painel.bas"
  "034:Teste_UI_Guiado.bas"
)

form_order=(
  "101:Fundo_Branco"
  "102:ProgressBar"
  "103:Configuracao_Inicial"
  "104:Cadastro_Servico"
  "105:Altera_Entidade"
  "106:Reativa_Entidade"
  "107:Altera_Empresa"
  "108:Reativa_Empresa"
  "109:Credencia_Empresa"
  "110:Limpar_Base"
  "111:Rel_Emp_Serv"
  "112:Rel_OSEmpresa"
  "113:Menu_Principal"
)

mkdir -p "$IMPORT_MOD_DIR" "$IMPORT_FRM_DIR" "$IMPORT_OBJ_DIR"

prefixo_alfabetico_3() {
  local n="$1"
  local a b c
  local A B C

  a=$((n / (26 * 26)))
  b=$(((n / 26) % 26))
  c=$((n % 26))

  A=$(printf "\\$(printf '%03o' $((65 + a)))")
  B=$(printf "\\$(printf '%03o' $((65 + b)))")
  C=$(printf "\\$(printf '%03o' $((65 + c)))")

  printf "%s%s%s" "$A" "$B" "$C"
}

normalizar_crlf() {
  local arquivo="$1"
  perl -0pi -e 's/\r?\n/\r\n/g' "$arquivo"
}

garantir_linha_final_vba() {
  local arquivo="$1"
  perl -0pi -e 's/\r\n*\z/\r\n\r\n/s' "$arquivo"
}

contains_item() {
  local needle="$1"
  shift
  local item

  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done

  return 1
}

modulos_teste_nao_producao=(
  "DiagnosticoV5.bas"
  "Teste_Sprint3.bas"
  "AAA_Types.bas"
)

modulos_utilitarios_export=(
  "Util_PDF.bas"
  "Importador_VBA.bas"
)

validar_modulos_export() {
  local arquivo

  for arquivo in "$EXPORT_DIR"/*.bas; do
    arquivo="$(basename "$arquivo")"

    if [[ "$arquivo" == *.DEPRECATED ]]; then
      continue
    fi

    if contains_item "$arquivo" "${modulos_teste_nao_producao[@]}"; then
      continue
    fi

    if contains_item "$arquivo" "${modulos_utilitarios_export[@]}"; then
      continue
    fi

    if ! contains_item "$arquivo" "${ordered_modules[@]}"; then
      echo "ERRO: modulo sem ordem definida em scripts/publicar_vba_import.sh: $arquivo" >&2
      exit 1
    fi
  done

  for arquivo in "${ordered_modules[@]}"; do
    if [[ ! -f "$EXPORT_DIR/$arquivo" ]]; then
      echo "ERRO: modulo esperado ausente em $EXPORT_DIR: $arquivo" >&2
      exit 1
    fi
  done
}

validar_formularios_export() {
  local arquivo
  local base

  for arquivo in "$EXPORT_DIR"/*.frm; do
    arquivo="$(basename "$arquivo")"
    if ! contains_item "$arquivo" "${ordered_forms[@]}"; then
      echo "ERRO: formulario sem ordem definida em scripts/publicar_vba_import.sh: $arquivo" >&2
      exit 1
    fi
  done

  for arquivo in "${ordered_forms[@]}"; do
    base="${arquivo%.frm}"

    if [[ ! -f "$EXPORT_DIR/$arquivo" ]]; then
      echo "ERRO: formulario esperado ausente em $EXPORT_DIR: $arquivo" >&2
      exit 1
    fi

    if [[ ! -f "$EXPORT_DIR/$base.frx" ]]; then
      echo "ERRO: arquivo binario do formulario ausente em $EXPORT_DIR: $base.frx" >&2
      exit 1
    fi
  done
}

limpar_import() {
  find "$IMPORT_MOD_DIR" -type f -name '*.bas' -delete
  find "$IMPORT_MOD_DIR" -type f \( -name '*.frm' -o -name '*.frx' -o -name '*.log' \) -delete
  find "$IMPORT_FRM_DIR" -type f \( -name '*.frm' -o -name '*.frx' -o -name '*.log' \) -delete
  find "$IMPORT_OBJ_DIR" -type f \( -name '*.cls' -o -name '*.bas' -o -name '*.frm' -o -name '*.frx' \) -delete
}

copiar_modulos() {
  local item
  local base
  local idx
  local prefixo

  idx=0
  for item in "${module_order[@]}"; do
    base="${item#*:}"
    prefixo="$(prefixo_alfabetico_3 "$idx")"
    cp -f "$EXPORT_DIR/$base" "$IMPORT_MOD_DIR/${prefixo}-${base}"
    normalizar_crlf "$IMPORT_MOD_DIR/${prefixo}-${base}"
    garantir_linha_final_vba "$IMPORT_MOD_DIR/${prefixo}-${base}"
    idx=$((idx + 1))
  done
}

copiar_formularios() {
  local item
  local base
  local idx
  local prefixo

  idx=0
  for item in "${form_order[@]}"; do
    base="${item#*:}"
    prefixo="$(prefixo_alfabetico_3 "$idx")"

    cp -f "$EXPORT_DIR/$base.frm" "$IMPORT_FRM_DIR/${prefixo}-${base}.frm"
    normalizar_crlf "$IMPORT_FRM_DIR/${prefixo}-${base}.frm"
    garantir_linha_final_vba "$IMPORT_FRM_DIR/${prefixo}-${base}.frm"
    # IMPORTANTE: o .frm referencia o .frx pelo nome ORIGINAL dentro do arquivo (OleObjectBlob = "Base.frx").
    # Portanto o .frx deve permanecer SEM prefixo.
    cp -f "$EXPORT_DIR/$base.frx" "$IMPORT_FRM_DIR/${base}.frx"
    idx=$((idx + 1))
  done
}

gerar_documento_ordem() {
  cat > "$ORDER_DOC" <<'EOF'
PACOTE ORDENADO DE IMPORTACAO VBA — V12-CLEAN (gerado automaticamente)

Fonte de verdade:
- vba_export/

Pacote para importacao manual no Excel:
- 001-modulo/ -> importar em ordem alfabetica (prefixos AAA-, AAB-, ...)
- 002-formularios/ -> importar em ordem alfabetica (prefixos AAA-, AAB-, ...)
- Importador_VBA.bas e 000-MANIFESTO-IMPORTACAO.txt ficam na raiz de vba_import/

IMPORTANTE:
- V12-CLEAN: Repo_Empresa.bas CRIADO. LerEmpresa/GravarStatusEmpresa extraidas de Repo_Credenciamento.
- App_Release.bas CENTRALIZA a versao exibida no Menu_Principal e as URLs do GitHub.
- IdsIguais CENTRALIZADA em Util_Planilha.bas. Removida de todos os modulos.
- UltimaLinhaAba/ProximoId/PrimeiraLinhaDadosEmpresas MOVIDAS para Util_Planilha.bas.
- Modulos de teste reincorporados (030-034). DiagnosticoV5 e Teste_Sprint3 removidos.
- Arquivos .frx mantem o nome original, sem prefixo numerico.

ORDEM DOS MODULOS:
Importar em ordem alfabetica (AAA-, AAB-, ...) conforme os arquivos em 001-modulo/.

ORDEM DOS FORMULARIOS:
Importar em ordem alfabetica (AAA-, AAB-, ...) conforme os arquivos em 002-formularios/.

MODULOS DE TESTE INCLUIDOS:
- 030-Central_Testes.bas (orquestrador da central de testes)
- 031-Teste_Bateria_Oficial.bas (132 testes automatizados + 4 manuais)
- 032-Central_Testes_Relatorio.bas (relatorios de teste)
- 033-Treinamento_Painel.bas (painel de treinamento)
- 034-Teste_UI_Guiado.bas (10 testes visuais com instrucoes manuais)

MODULOS REMOVIDOS (NAO IMPORTAR):
- DiagnosticoV5.bas (modulo de diagnostico descontinuado)
- Teste_Sprint3.bas (testes da sprint 3 descontinuados)

IMPORTACAO AUTOMATICA (recomendado):
0. Excel: Central de Confianca > Confiar no acesso ao modelo de objeto do projeto VBA.
1. Importar apenas o arquivo vba_import/Importador_VBA.bas no livro .xlsm.
2. Executar a macro ImportarPacoteCredenciamentoV12 e selecionar a pasta vba_import.
3. Depurar > Compilar VBAProject. Opcional: remover o modulo Importador_VBA apos validar.

REGRA OPERACIONAL (manual):
1. Excluir do VBAProject todos os modulos e formularios antigos.
2. Garantir que EstaPastaDeTrabalho e todos os objetos de planilha estejam vazios.
3. Importar todos os .bas de 001-modulo em ordem alfabetica (AAA-, AAB-, ...).
4. Importar todos os .frm de 002-formularios em ordem alfabetica (AAA-, AAB-, ...).
5. Rodar Depurar > Compilar VBAProject.
6. Salvar como .xlsm.
EOF
  normalizar_crlf "$ORDER_DOC"
  garantir_linha_final_vba "$ORDER_DOC"
}

gerar_manifesto_importacao() {
  local manifest="$ROOT_DIR/vba_import/000-MANIFESTO-IMPORTACAO.txt"
  local item
  local base
  local idx
  local prefixo

  {
    echo "# Manifesto gerado por scripts/publicar_vba_import.sh (nao editar)"
    echo "# Formato: M|caminho relativo .bas  ou  F|caminho relativo .frm"
    idx=0
    for item in "${module_order[@]}"; do
      base="${item#*:}"
      prefixo="$(prefixo_alfabetico_3 "$idx")"
      echo "M|001-modulo/${prefixo}-${base}"
      idx=$((idx + 1))
    done
    idx=0
    for item in "${form_order[@]}"; do
      base="${item#*:}"
      prefixo="$(prefixo_alfabetico_3 "$idx")"
      echo "F|002-formularios/${prefixo}-${base}.frm"
      idx=$((idx + 1))
    done
  } >"$manifest"
  normalizar_crlf "$manifest"
  garantir_linha_final_vba "$manifest"

  if [[ -f "$EXPORT_DIR/Importador_VBA.bas" ]]; then
    cp -f "$EXPORT_DIR/Importador_VBA.bas" "$ROOT_DIR/vba_import/Importador_VBA.bas"
    normalizar_crlf "$ROOT_DIR/vba_import/Importador_VBA.bas"
    garantir_linha_final_vba "$ROOT_DIR/vba_import/Importador_VBA.bas"
  fi
}

gerar_objetos_referencia() {
  cat > "$IMPORT_OBJ_DIR/LEIA-ME.txt" <<'EOF'
PASTA DE REFERENCIA (NAO IMPORTAR)

Esta pasta e reservada para objetos nativos do projeto (Sheets/ThisWorkbook)
que sao gerenciados pelo proprio Excel.

IMPORTACAO MANUAL:
- Modulos (.bas): usar arquivos em 001-modulo/
- Formularios (.frm): usar arquivos em 002-formularios/
  (o .frx correspondente deve estar na MESMA pasta, e ja esta)

SNIPPET OPCIONAL:
- ThisWorkbook.code.txt pode ser colado em EstaPastaDeTrabalho
  para disparar IniciarSistema no evento Workbook_Open.
EOF
  normalizar_crlf "$IMPORT_OBJ_DIR/LEIA-ME.txt"
  garantir_linha_final_vba "$IMPORT_OBJ_DIR/LEIA-ME.txt"

  cat > "$IMPORT_OBJ_DIR/ThisWorkbook.code.txt" <<'EOF'
Option Explicit

Private Sub Workbook_Open()
    On Error Resume Next
    IniciarSistema
    On Error GoTo 0
End Sub
EOF
  normalizar_crlf "$IMPORT_OBJ_DIR/ThisWorkbook.code.txt"
  garantir_linha_final_vba "$IMPORT_OBJ_DIR/ThisWorkbook.code.txt"
}

ordered_modules=()
ordered_forms=()

for item in "${module_order[@]}"; do
  ordered_modules+=("${item#*:}")
done

for item in "${form_order[@]}"; do
  ordered_forms+=("${item#*:}.frm")
done

validar_modulos_export
validar_formularios_export
limpar_import
copiar_modulos
copiar_formularios
gerar_manifesto_importacao
gerar_documento_ordem
gerar_objetos_referencia

echo "OK: vba_import publicado a partir de vba_export"
