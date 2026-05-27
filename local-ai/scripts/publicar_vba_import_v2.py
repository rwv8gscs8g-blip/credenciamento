#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# =============================================================================
# RESTRITO CLA — ferramenta operacional CLA-controlada
# =============================================================================
# Esta ferramenta faz parte do conteudo CLA-controlado do projeto Credenciamento
# (modelo B — release zip). Distribuicao apenas para contribuidores que
# assinaram o CLA conforme `CLA.md` secao 8.
#
# Documentacao publica do modelo:
#   - docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md
#   - docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md
#   - docs/reference/MATRIZ_PUBLICO_VS_CLA.md
#   - .hbn/knowledge/0007-acesso-controlado-via-cla.md
#
# NAO redistribuir esta ferramenta para terceiros sem CLA validado.
# A restricao expira automaticamente com a auto-conversao TPGL -> Apache 2.0.
# =============================================================================
"""
publicar_vba_import_v2.py
==========================
Sincroniza `src/vba/` para `local-ai/vba_import/` aplicando normalizacao
G6 + G8 + regra 13 (Glasswing/HBN) e atualiza manifesto + mapa + build.

Substitui o `publicar_vba_import.sh` legacy descontinuado em 28/04/2026
durante a Onda 5/6 (que foi descontinuado sem substituto, causando a
regressao em massa que motivou a Onda 9 antecipada).

CONTRATO DE NORMALIZACAO (regra 13 V203 inegociavel):
  1. Encoding: UTF-8 (com fallback Windows-1252 -> UTF-8)
  2. Line endings: CRLF (\\r\\n)
  3. EOF: 3 CRLFs trailing (`\\r\\n\\r\\n\\r\\n` apos End Sub/End Function)
  4. Caracteres unicode raros substituidos por equivalente ASCII:
     em-dash (-), en-dash (-), ellipsis (...), smart quotes (' "), etc.

GLASSWING G7: pacote vba_import sincronizado com src/vba (md5sum bate).
GLASSWING G8: Public Type apenas em Mod_Types.bas.

MODOS:
  --check    : valida sincronizacao SEM alterar arquivos. Codigo 0 se OK,
               1 se houver divergencia. Usado pelo git pre-commit hook.
  --dry-run  : mostra o que seria feito, sem alterar arquivos.
  --apply    : (default) aplica normalizacao + sincronizacao + atualiza
               manifesto/mapa/build.

USO:
  python3 publicar_vba_import_v2.py [--check | --dry-run | --apply] [--verbose]
  python3 publicar_vba_import_v2.py --apply --only Cadastro_Servico.frm

OU (via wrapper bash):
  bash publicar_vba_import_v2.sh [--check | --dry-run] [--verbose]
"""

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# =============================================================================
# Configuracao
# =============================================================================

SCRIPT_DIR = Path(__file__).parent.resolve()
REPO = SCRIPT_DIR.parent.parent  # local-ai/scripts/ -> Credenciamento/
SRC_DIR = REPO / 'src' / 'vba'
PKG_ROOT = REPO / 'local-ai' / 'vba_import'
PKG_MOD_DIR = PKG_ROOT / '001-modulo'
PKG_FRM_DIR = PKG_ROOT / '002-formularios'
MANIFESTO_PATH = PKG_ROOT / '000-MANIFESTO-IMPORTACAO.txt'
MAPA_PATH = PKG_ROOT / '000-MAPA-PREFIXOS.txt'
BUILD_DOC_PATH = PKG_ROOT / '000-BUILD-IMPORTAR-SEMPRE.txt'

# Modulos legacy a IGNORAR (foram movidos para backups/macros_descartaveis)
LEGACY_BAS_TO_SKIP = {'AAA_Types.bas'}

# Caracteres unicode proibidos (regra 13 V203) e seus substitutos ASCII
UNICODE_REPLACEMENTS = {
    '—': '-',    # em-dash
    '–': '-',    # en-dash
    '…': '...',  # horizontal ellipsis
    '‘': "'",    # left single quotation mark
    '’': "'",    # right single quotation mark
    '“': '"',    # left double quotation mark
    '”': '"',    # right double quotation mark
    '«': '<<',   # left chevron
    '»': '>>',   # right chevron
    '﻿': '',     # BOM (sempre remove)
}

# =============================================================================
# Cores (ANSI) — opcional, falha gracioso se terminal nao suporta
# =============================================================================

class C:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    END = '\033[0m'

def disable_colors():
    for attr in ['GREEN', 'RED', 'YELLOW', 'BLUE', 'BOLD', 'DIM', 'END']:
        setattr(C, attr, '')

if not sys.stdout.isatty():
    disable_colors()

# =============================================================================
# Helpers
# =============================================================================

def md5(path):
    """Calcula md5 de um arquivo."""
    return hashlib.md5(path.read_bytes()).hexdigest()

def normalize_bytes(content_bytes):
    """
    Aplica normalizacao G6 + G8 + regra 13:
      1. Substitui caracteres unicode proibidos por ASCII
      2. Converte para UTF-8 (fallback Windows-1252)
      3. Normaliza line endings para CRLF
      4. Garante EOF = 3 CRLFs

    Retorna: (bytes_normalizados, dict_de_substituicoes_feitas, encoding_origem)
    """
    # Conta substituicoes unicode antes de decodificar
    replacements = {}

    # Tenta UTF-8 primeiro, fallback para Windows-1252
    encoding_origem = 'utf-8'
    try:
        text = content_bytes.decode('utf-8')
    except UnicodeDecodeError:
        try:
            text = content_bytes.decode('cp1252')
            encoding_origem = 'cp1252'
        except UnicodeDecodeError:
            text = content_bytes.decode('latin-1')
            encoding_origem = 'latin-1'

    # Substitui unicode raros
    for unicode_char, ascii_replacement in UNICODE_REPLACEMENTS.items():
        if unicode_char in text:
            count = text.count(unicode_char)
            replacements[unicode_char] = count
            text = text.replace(unicode_char, ascii_replacement)

    # Normaliza line endings: tudo para LF primeiro
    text = text.replace('\r\n', '\n').replace('\r', '\n')

    # EOF: rstrip + 3 LFs trailing (= 3 CRLFs apos conversao)
    text = text.rstrip() + '\n\n\n'

    # Converte LF -> CRLF
    text = text.replace('\n', '\r\n')

    return text.encode('utf-8'), replacements, encoding_origem

def load_mapa_prefixos():
    """
    Le 000-MAPA-PREFIXOS.txt e retorna 2 dicts:
      mapa_modulos: {'Mod_Types.bas': 'AAA', 'Const_Colunas.bas': 'AAB', ...}
      mapa_forms:   {'Fundo_Branco.frm': 'AAA', 'ProgressBar.frm': 'AAB', ...}
    """
    mapa_modulos = {}
    mapa_forms = {}
    if not MAPA_PATH.exists():
        return mapa_modulos, mapa_forms

    secao = None
    with open(MAPA_PATH, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line.startswith('MODULOS'):
                secao = 'mod'
                continue
            if line.startswith('FORMULARIOS'):
                secao = 'frm'
                continue
            m = re.match(r'^-\s+([A-Z]{3})-([\w_]+\.(bas|frm))\s+=>', line)
            if m:
                prefix, full_name, ext = m.groups()
                if secao == 'mod' and ext == 'bas':
                    mapa_modulos[full_name] = prefix
                elif secao == 'frm' and ext == 'frm':
                    mapa_forms[full_name] = prefix
    return mapa_modulos, mapa_forms

def find_pkg_path(simple_name, pkg_dir, mapa):
    """
    Dado nome simples (ex: 'Const_Colunas.bas') e mapa de prefixos,
    retorna o Path com prefixo (ex: vba_import/001-modulo/AAB-Const_Colunas.bas).
    """
    prefix = mapa.get(simple_name)
    if prefix:
        return pkg_dir / f"{prefix}-{simple_name}"
    # Fallback: procura por qualquer arquivo terminando com simple_name
    if pkg_dir.exists():
        for p in pkg_dir.iterdir():
            if p.name.endswith(simple_name) and re.match(r'^[A-Z]{3}-', p.name):
                return p
    return None

def gerar_code_only_txt(frm_content_bytes):
    """
    Gera o conteudo .code-only.txt a partir do .frm normalizado.
    Pula apenas o cabecalho estrutural do form, preservando declaracoes
    module-level e atributos per-symbol que o Importador V3 limpa antes do
    AddFromString.
    """
    text = frm_content_bytes.decode('utf-8')
    lines = text.split('\r\n')

    # Caminho principal (L22): o codigo comeca apos Attribute VB_Exposed.
    for i, line in enumerate(lines):
        if line.strip().startswith('Attribute VB_Exposed'):
            return '\r\n'.join(lines[i + 1:]).encode('utf-8')

    # Fallback para forms minimos/legados sem os 5 attributes de form.
    code_start = 0
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith(('Private Sub ', 'Public Sub ',
                                'Private Function ', 'Public Function ',
                                'Friend Sub ', 'Friend Function ')):
            code_start = i
            break
    # Tambem inclui declaracoes module-level que ficam ANTES da primeira Sub.
    real_start = code_start
    for i in range(code_start - 1, -1, -1):
        stripped = lines[i].strip()
        if stripped == '' or stripped.startswith("'"):
            continue
        if stripped.startswith('Attribute VB_'):
            break
        if stripped.startswith('Attribute ') and '.VB_' in stripped:
            real_start = i
            continue
        # Variavel module-level (Dim/Private/Public ... As ...)
        if (stripped.startswith(('Private ', 'Public ', 'Dim '))
            and ' As ' in stripped):
            real_start = i
        else:
            break

    code_lines = lines[real_start:]
    return '\r\n'.join(code_lines).encode('utf-8')

# =============================================================================
# Glasswing checks G7 + G8
# =============================================================================

def glasswing_g8_public_type():
    """
    G8: Public Type apenas em Mod_Types.bas.
    Retorna lista de violacoes.
    """
    violations = []
    if not SRC_DIR.exists():
        return violations
    for f in sorted(SRC_DIR.glob('*.bas')):
        if f.name == 'Mod_Types.bas':
            continue
        try:
            content = f.read_text(encoding='utf-8', errors='replace')
        except Exception:
            continue
        for ln, line in enumerate(content.split('\n'), 1):
            if re.match(r'^\s*Public\s+Type\s+\w', line):
                violations.append((f.name, ln, line.strip()))
    return violations

# =============================================================================
# Processamento por arquivo
# =============================================================================

def process_file(src_path, mapa_mod, mapa_frm, mode, sync_existing_code_only=False):
    """
    Processa um arquivo src/vba/X.bas ou src/vba/X.frm.
    Retorna dict com resultado.
    """
    name = src_path.name
    ext = src_path.suffix
    result = {
        'name': name,
        'status': 'unknown',
        'prefix': None,
        'pkg_path': None,
        'replacements': {},
        'encoding_origem': None,
        'frx_synced': False,
        'code_only_generated': False,
        'message': '',
    }

    # Skip legacy
    if name in LEGACY_BAS_TO_SKIP:
        result['status'] = 'skipped_legacy'
        result['message'] = f'legacy a apagar (vazio, residuo bug TConfig)'
        return result

    # Determina pkg_path
    if ext == '.bas':
        pkg_path = find_pkg_path(name, PKG_MOD_DIR, mapa_mod)
    elif ext == '.frm':
        pkg_path = find_pkg_path(name, PKG_FRM_DIR, mapa_frm)
    else:
        result['status'] = 'skipped_ext'
        return result

    if pkg_path is None:
        result['status'] = 'no_prefix'
        result['message'] = f'sem prefixo no mapa — adicionar entrada em 000-MAPA-PREFIXOS.txt'
        return result

    result['pkg_path'] = str(pkg_path.relative_to(REPO))
    result['prefix'] = pkg_path.name.split('-')[0]

    # Le src
    src_bytes = src_path.read_bytes()

    # Normaliza
    new_bytes, replacements, encoding = normalize_bytes(src_bytes)
    result['replacements'] = replacements
    result['encoding_origem'] = encoding

    # Compara com pkg atual (se existe)
    if pkg_path.exists():
        pkg_bytes = pkg_path.read_bytes()
        if hashlib.md5(new_bytes).hexdigest() == hashlib.md5(pkg_bytes).hexdigest():
            result['status'] = 'in_sync'
            result['message'] = 'hash bate, nada a fazer'
            # Hotfix Onda 9 v11 (2026-04-29): garantir .code-only.txt para
            # TODOS os .frm. Forms que nunca foram modificados ficavam sem
            # .code-only.txt e o Importador V2 caia no fallback Import API
            # que falha em Excel Mac. Gera o arquivo se ausente, mesmo em
            # in_sync.
            if ext == '.frm' and mode == 'apply':
                code_only_path = pkg_path.parent / pkg_path.name.replace('.frm', '.code-only.txt')
                if sync_existing_code_only or not code_only_path.exists():
                    code_only_bytes = gerar_code_only_txt(new_bytes)
                    old_code_only = code_only_path.read_bytes() if code_only_path.exists() else b''
                    if old_code_only != code_only_bytes:
                        code_only_path.write_bytes(code_only_bytes)
                        result['status'] = 'applied'
                        result['code_only_generated'] = True
                        result['message'] = 'hash bate, mas .code-only.txt regenerado'
                        return result
            return result

    # Modo check: reporta divergencia mas nao altera
    if mode == 'check':
        result['status'] = 'diverged'
        result['message'] = 'divergencia detectada (use --apply)'
        return result

    # Modo dry-run
    if mode == 'dry-run':
        result['status'] = 'would_apply'
        result['message'] = f'normalizaria + copiaria (encoding={encoding})'
        return result

    # Modo apply: escreve
    src_path.write_bytes(new_bytes)
    pkg_path.write_bytes(new_bytes)
    result['status'] = 'applied'
    result['message'] = 'normalizado e espelhado'

    # Para .frm: copia .frx + gera .code-only.txt
    if ext == '.frm':
        frx_src = src_path.with_suffix('.frx')
        if frx_src.exists():
            frx_dst = PKG_FRM_DIR / frx_src.name  # sem prefixo
            shutil.copyfile(frx_src, frx_dst)
            result['frx_synced'] = True

        # Gera .code-only.txt
        code_only_bytes = gerar_code_only_txt(new_bytes)
        code_only_path = pkg_path.with_suffix('.code-only.txt')
        # garante mesmo nome base do .frm com prefixo
        code_only_path = pkg_path.parent / pkg_path.name.replace('.frm', '.code-only.txt')
        code_only_path.write_bytes(code_only_bytes)
        result['code_only_generated'] = True

    return result

# =============================================================================
# Atualizacao de manifesto e build
# =============================================================================

# Classificacao topologica dos modulos por grupo (para Importador_V2)
# A ordem dos grupos define a ordem de import; dentro do grupo, ordem alfabetica.
GRUPOS_MODULOS = {
    'TYPES': ['Mod_Types'],
    'BASE': ['Const_Colunas', 'Util_Conversao', 'Util_Config', 'Util_Planilha',
             'Funcoes', 'Variaveis'],
    'INFRA': ['Audit_Log', 'AppContext', 'ErrorBoundary', 'Svc_Transacao'],
    'REPOS': ['Repo_Credenciamento', 'Repo_PreOS', 'Repo_OS', 'Repo_Avaliacao',
              'Repo_Empresa'],
    'SERVICES': ['Svc_Rodizio', 'Svc_PreOS', 'Svc_OS', 'Svc_Avaliacao'],
    'DOMAIN': ['Classificar', 'Preencher', 'Emergencia_CNAE', 'Mod_Limpeza_Base',
               'Util_Filtro_Lista'],
    'RELEASE': ['App_Release'],
    'STARTUP': ['Auto_Open'],
    'TESTS': ['Central_Testes', 'Teste_Bateria_Oficial', 'Central_Testes_Relatorio',
              'Treinamento_Painel', 'Teste_UI_Guiado', 'Central_Testes_V2',
              'Teste_V2_Engine', 'Teste_V2_Roteiros', 'Teste_Validacao_Release'],
    # Importador_V2 e o proprio importador — nao entra no manifesto
}

GRUPOS_DESCRICAO = {
    'TYPES': 'sempre primeiro (Public Type isolado em Mod_Types - Glasswing G8). '
             'Importador_V2 trata como TABU: pula se hash bate, aborta se diverge.',
    'BASE': 'constantes, identidade, utils basicos',
    'INFRA': 'logging, contexto, error, transacao',
    'REPOS': 'repositorios CRUD que tocam abas',
    'SERVICES': 'logica de negocio',
    'DOMAIN': 'operacoes que tocam varias abas',
    'RELEASE': 'identidade do build',
    'STARTUP': 'entry point',
    'TESTS': 'cenarios automatizados',
    'FORMS': 'apos todos os modulos (workbook estabilizado usa .code-only.txt)',
}

def atualizar_manifesto(results, mapa_mod, mapa_frm):
    """Regenera 000-MANIFESTO-IMPORTACAO.txt enriquecido com grupos."""
    lines = [
        '# Manifesto V2 do pacote VBA - fonte de verdade para Importador_V2.bas',
        '# Formato: M|caminho relativo .bas  ou  F|caminho relativo .frm',
        '# Linhas comecando com # sao comentarios.',
        '# Linhas em branco separam GRUPOS.',
        '# Importador_V2 valida compilacao apos cada grupo.',
        '# Atualizado automaticamente por publicar_vba_import_v2.sh',
        f'# Ultima atualizacao: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}',
        '',
    ]

    # Modulos por grupo
    for grupo_nome, modulos in GRUPOS_MODULOS.items():
        descricao = GRUPOS_DESCRICAO.get(grupo_nome, '')
        lines.append(f'# GRUPO_{grupo_nome} - {descricao}')
        for mod_simple in modulos:
            full_name = f'{mod_simple}.bas'
            if full_name in mapa_mod:
                prefix = mapa_mod[full_name]
                lines.append(f'M|001-modulo/{prefix}-{full_name}')
            else:
                lines.append(f'# AVISO: {full_name} no grupo {grupo_nome} '
                             f'mas sem prefixo no mapa - adicionar em 000-MAPA-PREFIXOS.txt')
        lines.append('')  # separador

    # Forms (sempre por ultimo)
    lines.append(f'# GRUPO_FORMS - {GRUPOS_DESCRICAO["FORMS"]}')
    frm_lines = sorted([
        f'F|002-formularios/{mapa_frm[name]}-{name}'
        for name in mapa_frm
    ])
    lines.extend(frm_lines)
    lines.append('')

    MANIFESTO_PATH.write_text('\n'.join(lines), encoding='utf-8')

def atualizar_build_doc():
    """Atualiza 000-BUILD-IMPORTAR-SEMPRE.txt com sha do commit atual."""
    try:
        sha = subprocess.check_output(
            ['git', 'rev-parse', '--short', 'HEAD'],
            cwd=str(REPO), stderr=subprocess.DEVNULL
        ).decode().strip()
    except Exception:
        sha = 'unknown'

    content = (
        f'# Build atual sincronizado em vba_import/\n'
        f'# Atualizado automaticamente por publicar_vba_import_v2.sh\n'
        f'BUILD_SHA={sha}\n'
        f'BUILD_DATA={datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n'
    )
    BUILD_DOC_PATH.write_text(content, encoding='utf-8')

# =============================================================================
# Relatorio
# =============================================================================

def print_report(results, g8_violations, mode):
    """Imprime relatorio detalhado."""
    print()
    print(f'{C.BOLD}=== publicar_vba_import_v2.py — modo {mode} ==={C.END}')
    print()

    # Tabela por status
    by_status = {}
    for r in results:
        by_status.setdefault(r['status'], []).append(r)

    status_colors = {
        'in_sync': C.DIM,
        'applied': C.GREEN,
        'would_apply': C.BLUE,
        'diverged': C.YELLOW,
        'no_prefix': C.RED,
        'skipped_legacy': C.DIM,
        'skipped_ext': C.DIM,
    }

    for status in sorted(by_status):
        color = status_colors.get(status, '')
        items = by_status[status]
        print(f'{color}{C.BOLD}[{status}]{C.END} {len(items)} arquivo(s):')
        for r in sorted(items, key=lambda x: x['name']):
            extra = []
            if r.get('replacements'):
                extra.append(f"unicode_subst={sum(r['replacements'].values())}")
            if r.get('encoding_origem') and r['encoding_origem'] != 'utf-8':
                extra.append(f"enc={r['encoding_origem']}")
            if r.get('frx_synced'):
                extra.append('frx_sync')
            if r.get('code_only_generated'):
                extra.append('code_only_gen')
            extra_str = f" ({', '.join(extra)})" if extra else ''
            prefix = r.get('prefix') or '???'
            print(f"  {color}{prefix}-{r['name']}{C.END}{extra_str}")
            if r.get('message') and status not in ('in_sync', 'applied'):
                print(f"    {C.DIM}-> {r['message']}{C.END}")
        print()

    # Glasswing G8
    print(f'{C.BOLD}=== Glasswing G8 — Public Type apenas em Mod_Types.bas ==={C.END}')
    if g8_violations:
        print(f'{C.RED}{C.BOLD}VIOLATED — {len(g8_violations)} declaracoes Public Type fora de Mod_Types.bas:{C.END}')
        for fname, ln, line in g8_violations:
            print(f"  {C.RED}{fname}:{ln}{C.END}: {line}")
    else:
        print(f'{C.GREEN}OK — nenhuma violacao G8.{C.END}')
    print()

    # Glasswing G7
    print(f'{C.BOLD}=== Glasswing G7 — vba_import sincronizado ==={C.END}')
    n_diverged = len(by_status.get('diverged', []))
    n_no_prefix = len(by_status.get('no_prefix', []))
    if mode == 'check':
        if n_diverged == 0 and n_no_prefix == 0:
            print(f'{C.GREEN}OK — vba_import 100% sincronizado com src/vba.{C.END}')
            return 0
        print(f'{C.RED}{C.BOLD}VIOLATED — {n_diverged} divergente(s), {n_no_prefix} sem prefixo.{C.END}')
        print(f'{C.YELLOW}    Rode: python3 local-ai/scripts/publicar_vba_import_v2.py --apply{C.END}')
        return 1
    return 0

# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Sincroniza src/vba/ -> local-ai/vba_import/ (regra 13 V203)'
    )
    parser.add_argument('mode', choices=['check', 'dry-run', 'apply'],
                        nargs='?', default='apply',
                        help='Modo de operacao (default: apply)')
    parser.add_argument('--verbose', action='store_true')
    parser.add_argument('--only', action='append', default=[],
                        help='Processa apenas o arquivo informado (ex.: Cadastro_Servico.frm). Pode repetir.')
    args = parser.parse_args()

    # Pre-flight
    if not SRC_DIR.exists():
        print(f"{C.RED}ERRO: src/vba nao existe em {SRC_DIR}{C.END}")
        return 2

    # Carrega mapa
    mapa_mod, mapa_frm = load_mapa_prefixos()
    if args.verbose:
        print(f'Mapa de modulos: {len(mapa_mod)} entradas')
        print(f'Mapa de forms: {len(mapa_frm)} entradas')

    # G8 check (sempre)
    g8 = glasswing_g8_public_type()
    if g8 and args.mode == 'apply':
        print(f"{C.RED}ERRO: G8 violado — abortando apply.{C.END}")
        for fname, ln, line in g8:
            print(f"  {fname}:{ln}: {line}")
        return 1

    # Processa arquivos
    results = []
    only = set(args.only or [])
    for f in sorted(SRC_DIR.iterdir()):
        if only and f.name not in only:
            continue
        if f.suffix in ('.bas', '.frm'):
            r = process_file(f, mapa_mod, mapa_frm, args.mode,
                             sync_existing_code_only=bool(only))
            results.append(r)

    # Atualiza manifesto + build (sempre em apply completo, mesmo se ja sincronizado).
    # Em apply com --only, preserva escopo de microdelta e nao toca artefatos globais.
    if args.mode == 'apply' and not only:
        atualizar_manifesto(results, mapa_mod, mapa_frm)
        atualizar_build_doc()

    # Relatorio
    return print_report(results, g8, args.mode)

if __name__ == '__main__':
    sys.exit(main())
