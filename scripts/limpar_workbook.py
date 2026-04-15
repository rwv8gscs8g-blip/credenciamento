#!/usr/bin/env python3
"""
limpar_workbook.py — Gera workbook LIMPO (sem VBA) a partir do atual.

Uso:
    python3 scripts/limpar_workbook.py

O que faz:
    1. Abre o .xlsm atual (PlanilhaCredenciamento-NOVO-Homologacao.xlsm)
    2. Remove completamente o vbaProject.bin (codigo VBA e fantasmas)
    3. Salva como .xlsx (dados puros, sem macros)
    4. Copia esse .xlsx como .xlsm (pronto para receber VBA limpo)

Depois de rodar:
    1. Feche o Excel completamente
    2. Abra o arquivo gerado: PlanilhaCredenciamento-LIMPO.xlsm
    3. Alt+F11 para abrir o VBA Editor
    4. Arquivo > Importar: importe todos os .bas de vba_import/001-modulo/ em ordem
    5. Arquivo > Importar: importe todos os .frm de vba_import/002-formularios/
    6. Cole o codigo de ThisWorkbook (vba_import/003-objetos/ThisWorkbook.code.txt)
       em EstaPastaDeTrabalho
    7. Depurar > Compilar VBAProject
    8. Ctrl+S para salvar
"""

import os
import sys
import shutil
import zipfile
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ORIGEM = os.path.join(ROOT, "PlanilhaCredenciamento-NOVO-Homologacao.xlsm")
SAIDA_XLSX = os.path.join(ROOT, "PlanilhaCredenciamento-LIMPO.xlsx")
SAIDA_XLSM = os.path.join(ROOT, "PlanilhaCredenciamento-LIMPO.xlsm")


def remover_vba_do_xlsm(caminho_entrada, caminho_saida):
    """Cria copia do .xlsm sem vbaProject.bin e sem referencias a ele."""

    with tempfile.TemporaryDirectory() as tmpdir:
        # Extrair ZIP
        with zipfile.ZipFile(caminho_entrada, "r") as zin:
            zin.extractall(tmpdir)

        # Remover vbaProject.bin
        vba_path = os.path.join(tmpdir, "xl", "vbaProject.bin")
        if os.path.exists(vba_path):
            os.remove(vba_path)
            print(f"  Removido: xl/vbaProject.bin")

        # Atualizar [Content_Types].xml — remover entrada do vbaProject
        ct_path = os.path.join(tmpdir, "[Content_Types].xml")
        if os.path.exists(ct_path):
            with open(ct_path, "r", encoding="utf-8") as f:
                ct = f.read()
            # Remover a linha Override para vbaProject.bin
            import re
            ct_new = re.sub(
                r'<Override[^>]*PartName="/xl/vbaProject\.bin"[^>]*/>\s*',
                "",
                ct,
            )
            with open(ct_path, "w", encoding="utf-8") as f:
                f.write(ct_new)
            if ct != ct_new:
                print("  Atualizado: [Content_Types].xml (removida ref ao vbaProject)")

        # Atualizar xl/_rels/workbook.xml.rels — remover relationship do vbaProject
        rels_path = os.path.join(tmpdir, "xl", "_rels", "workbook.xml.rels")
        if os.path.exists(rels_path):
            with open(rels_path, "r", encoding="utf-8") as f:
                rels = f.read()
            rels_new = re.sub(
                r'<Relationship[^>]*Target="vbaProject\.bin"[^>]*/>\s*',
                "",
                rels,
            )
            with open(rels_path, "w", encoding="utf-8") as f:
                f.write(rels_new)
            if rels != rels_new:
                print("  Atualizado: xl/_rels/workbook.xml.rels (removida ref ao vbaProject)")

        # Recriar ZIP
        with zipfile.ZipFile(caminho_saida, "w", zipfile.ZIP_DEFLATED) as zout:
            for dirpath, dirnames, filenames in os.walk(tmpdir):
                for fn in filenames:
                    full = os.path.join(dirpath, fn)
                    arcname = os.path.relpath(full, tmpdir)
                    zout.write(full, arcname)

    print(f"  Gerado: {os.path.basename(caminho_saida)}")


def main():
    if not os.path.exists(ORIGEM):
        print(f"ERRO: Arquivo nao encontrado: {ORIGEM}")
        print("Verifique se o workbook esta na pasta Credenciamento/")
        sys.exit(1)

    print("=" * 60)
    print("LIMPEZA DE WORKBOOK — Remocao total de vbaProject.bin")
    print("=" * 60)
    print()

    # Passo 1: Gerar .xlsx limpo (sem VBA)
    print("[1/2] Gerando .xlsx sem VBA...")
    remover_vba_do_xlsm(ORIGEM, SAIDA_XLSX)

    # Passo 2: Copiar como .xlsm (Excel aceitara e criara VBA project vazio ao salvar)
    print("[2/2] Copiando como .xlsm...")
    shutil.copy2(SAIDA_XLSX, SAIDA_XLSM)
    print(f"  Gerado: {os.path.basename(SAIDA_XLSM)}")

    print()
    print("=" * 60)
    print("PROXIMO PASSO:")
    print("=" * 60)
    print()
    print("1. FECHE o Excel completamente")
    print("2. Abra: PlanilhaCredenciamento-LIMPO.xlsm")
    print("   (Ignore avisos sobre macros — nao ha macros ainda)")
    print("3. Alt+F11 para abrir o VBA Editor")
    print("4. Menu: Arquivo > Importar Arquivo")
    print("5. Importe UM POR UM de vba_import/001-modulo/ (em ordem)")
    print("6. Importe os .frm de vba_import/002-formularios/")
    print("7. Cole o conteudo de vba_import/003-objetos/ThisWorkbook.code.txt")
    print("   em EstaPastaDeTrabalho")
    print("8. Depurar > Compilar VBAProject")
    print("9. Ctrl+S")
    print()
    print("Se o passo 8 der ERRO, reporte qual tipo causou o erro.")
    print("=" * 60)


if __name__ == "__main__":
    main()
