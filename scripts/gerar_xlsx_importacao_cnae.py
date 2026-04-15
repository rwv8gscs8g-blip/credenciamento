#!/usr/bin/env python3
"""Gera um XLSX simples de importacao a partir do CSV normalizado de CNAE.

Sem dependencias externas. Usa apenas a biblioteca padrao e grava um workbook
Open XML minimo, suficiente para abrir no Excel.
"""

from __future__ import annotations

import csv
from pathlib import Path
from xml.sax.saxutils import escape
from zipfile import ZIP_DEFLATED, ZipFile


ROOT = Path("/Users/macbookpro/Projetos/Credenciamento")
CSV_PATH = ROOT / "doc/cnae-normalizado/cnae_servicos_normalizado.csv"
XLSX_PATH = ROOT / "doc/cnae-normalizado/cnae_servicos_importacao.xlsx"
SHEET_NAME = "ATIVIDADES_IMPORT"


def col_ref(index: int) -> str:
    """Converte 1 -> A, 27 -> AA."""
    result = ""
    while index > 0:
        index, remainder = divmod(index - 1, 26)
        result = chr(65 + remainder) + result
    return result


def cell_inline(ref: str, value: str) -> str:
    return (
        f'<c r="{ref}" t="inlineStr">'
        f"<is><t>{escape(value)}</t></is>"
        f"</c>"
    )


def cell_number(ref: str, value: str) -> str:
    return f'<c r="{ref}"><v>{escape(value)}</v></c>'


def row_xml(row_idx: int, values: list[str]) -> str:
    cells: list[str] = []
    for col_idx, value in enumerate(values, start=1):
        ref = f"{col_ref(col_idx)}{row_idx}"
        if col_idx == 1 and row_idx > 1 and value.isdigit():
            cells.append(cell_number(ref, value))
        else:
            cells.append(cell_inline(ref, value))
    return f'<row r="{row_idx}">{"".join(cells)}</row>'


def load_rows() -> list[list[str]]:
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV nao encontrado: {CSV_PATH}")

    rows: list[list[str]] = []
    with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as handle:
        reader = csv.reader(handle)
        header = next(reader)
        rows.append([header[0].replace("\ufeff", ""), header[1], header[2]])
        for row in reader:
            if not row or len(row) < 3:
                continue
            rows.append([row[0].strip(), row[1].strip(), row[2].strip()])
    return rows


def build_sheet(rows: list[list[str]]) -> str:
    dimension = f"A1:C{len(rows)}"
    xml_rows = "".join(row_xml(idx, row) for idx, row in enumerate(rows, start=1))
    return f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <dimension ref="{dimension}"/>
  <sheetViews>
    <sheetView workbookViewId="0"/>
  </sheetViews>
  <sheetFormatPr defaultRowHeight="15"/>
  <cols>
    <col min="1" max="1" width="10" customWidth="1"/>
    <col min="2" max="2" width="16" customWidth="1"/>
    <col min="3" max="3" width="80" customWidth="1"/>
  </cols>
  <sheetData>{xml_rows}</sheetData>
</worksheet>
"""


def write_xlsx(rows: list[list[str]]) -> None:
    sheet_xml = build_sheet(rows)
    workbook_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="{escape(SHEET_NAME)}" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>
"""
    workbook_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"
    Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
    Target="styles.xml"/>
</Relationships>
"""
    root_rels = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
    Target="xl/workbook.xml"/>
  <Relationship Id="rId2"
    Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
    Target="docProps/core.xml"/>
  <Relationship Id="rId3"
    Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
    Target="docProps/app.xml"/>
</Relationships>
"""
    content_types = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml"
    ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/docProps/core.xml"
    ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml"
    ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>
"""
    styles_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>
  <fills count="2">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
  </fills>
  <borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
</styleSheet>
"""
    core_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:dcterms="http://purl.org/dc/terms/"
 xmlns:dcmitype="http://purl.org/dc/dcmitype/"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>Codex</dc:creator>
  <cp:lastModifiedBy>Codex</cp:lastModifiedBy>
</cp:coreProperties>
"""
    app_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties"
 xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>Microsoft Excel</Application>
</Properties>
"""

    XLSX_PATH.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(XLSX_PATH, "w", ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", content_types)
        zf.writestr("_rels/.rels", root_rels)
        zf.writestr("docProps/core.xml", core_xml)
        zf.writestr("docProps/app.xml", app_xml)
        zf.writestr("xl/workbook.xml", workbook_xml)
        zf.writestr("xl/_rels/workbook.xml.rels", workbook_rels)
        zf.writestr("xl/styles.xml", styles_xml)
        zf.writestr("xl/worksheets/sheet1.xml", sheet_xml)


def main() -> None:
    rows = load_rows()
    write_xlsx(rows)
    print(f"XLSX gerado com {len(rows) - 1} registros em: {XLSX_PATH}")


if __name__ == "__main__":
    main()
