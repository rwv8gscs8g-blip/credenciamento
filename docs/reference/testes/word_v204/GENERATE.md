---
titulo: Como regenerar o pacote Word V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Como regenerar o pacote Word V204

A partir do diretório raiz do repositório:

```bash
OUTDIR="docs/reference/testes/word_v204"
REF="$OUTDIR/reference.docx"
PANDOC=/opt/homebrew/bin/pandoc  # ou simplesmente "pandoc" se estiver no PATH

# Template de referência (já versionado em $OUTDIR/reference.docx).
# Para extrair de novo:
# $PANDOC --print-default-data-file reference.docx > "$REF"

convert() {
  local src="$1" out="$2" title="$3"
  $PANDOC "$src" -o "$OUTDIR/$out" \
    --from=markdown --to=docx \
    --toc --toc-depth=2 \
    --reference-doc="$REF" \
    --metadata title="$title" \
    --metadata lang=pt-BR \
    --metadata date="2026-05-12"
}

convert "docs/tutorials/GUIA_TESTES_HUMANOS_V204.md" \
        "01_GUIA_TESTES_HUMANOS_V204.docx" \
        "Guia de Testes Humanos V12.0.0204"

convert "docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md" \
        "02_ROTEIRO_TESTE_MANUAL_V204.docx" \
        "Roteiro de Teste Manual V12.0.0204"

convert "docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md" \
        "03_REGRAS_DE_NEGOCIO_V204.docx" \
        "Regras de Negócio V12.0.0204"

convert "docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md" \
        "04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.docx" \
        "Matriz de Cobertura de Regras V12.0.0204"

convert "docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md" \
        "05_MATRIZ_RASTREABILIDADE_TESTES_V204.docx" \
        "Matriz de Rastreabilidade de Testes V12.0.0204"

convert "docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md" \
        "06_COMO_LIBERAR_MACROS_NO_WINDOWS.docx" \
        "Como Liberar Macros no Windows"

convert "docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md" \
        "07_COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.docx" \
        "Como Rodar o Sexteto de Validação V12.0.0204"

convert "docs/reference/testes/08_PROTOCOLO_HOMOLOGACAO_HUMANA_V204.md" \
        "08_PROTOCOLO_HOMOLOGACAO_HUMANA_V204.docx" \
        "PROTOCOLO DE HOMOLOGAÇÃO HUMANA V12.0.0204"
```

## Empacotar para envio ao testador

```bash
cd docs/reference/testes/word_v204
zip -j ../pacote_homologacao_v204.zip *.docx INDEX_PACOTE_WORD_V204.md
```

O `.zip` resultante pode ser anexado ao e-mail de hand-off junto com o
`.xlsm` final.

## Customização de identidade visual

Para aplicar tema do município ou da organização:

1. Abrir `reference.docx` no Word.
2. Ir em **Design > Temas** e escolher o tema desejado.
3. Ajustar cores/fontes em **Design > Fontes** e **Design > Cores**.
4. Salvar como `reference.docx` substituindo o original.
5. Re-rodar o comando `convert` acima.

Para mudanças cirúrgicas (cor de cabeçalho, margem de página),
editar `word/styles.xml` ou `word/document.xml` diretamente após
descompactar o `.docx` com `unzip`, modificar e recompactar com `zip`.
