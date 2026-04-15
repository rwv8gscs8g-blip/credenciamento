# Drop de Formularios (Excel -> Repo)

## Objetivo

Criar um lugar **explicito e seguro** para voce “descer” arquivos exportados do VBE sem misturar com deploy.

## Como usar (fluxo recomendado)

1. No Excel/VBE: exporte o formulario (ex.: `Menu_Principal`) para esta pasta:
   - `incoming/vba-forms/Menu_Principal.frm`
   - `incoming/vba-forms/Menu_Principal.frx` (sempre junto)

2. No terminal (na raiz do repo), rode:

```bash
bash scripts/ingressar_vba_drop.sh
```

3. Isso vai:
   - validar que `.frm` e `.frx` existem
   - normalizar CRLF + linha em branco final (padrao do projeto)
   - copiar para `vba_export/`
   - publicar o pacote de importacao com `scripts/publicar_vba_import.sh`

4. Importar no Excel a partir de:
   - `vba_import/002-formularios/Menu_Principal.frm` (+ `.frx` na mesma pasta)

## Regras

- **Nunca** editar `vba_import/` “na mao” como fonte de verdade.
- **Sempre** manter `vba_export/` como fonte de verdade do codigo + export do designer.

## Aviso importante (Excel)

O arquivo `.frm` exportado pelo VBE contem **codigo + referencia ao `.frx`**. Se voce importou no Excel uma versao antiga do modulo antes de exportar, o `ingressar` pode **sobrescrever** correcoes recentes no `vba_export/` com codigo antigo.

Fluxo seguro quando ha mudancas de codigo no Git:

1. Importar primeiro os modulos corretos do `vba_import/` no Excel (ou colar diff no VBE).
2. So entao exportar de volta para `incoming/vba-forms/`.
