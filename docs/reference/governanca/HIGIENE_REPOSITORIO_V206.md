---
titulo: Higiene de repositorio V206
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Higiene de repositorio V206

## Politica

O repositorio usa `git diff --check` como gate de higiene, mas arquivos
exportados pelo VBE (`.bas`, `.cls`, `.frm` e `code-only.txt` importavel)
seguem regras proprias:

- podem sair do VBE com CRLF;
- nao devem ser normalizados em massa sem onda propria;
- devem ser validados por import V3, compile manual e teste dirigido;
- `.frx` deve ser tratado como binario.

Por isso `.gitattributes` desativa a checagem de whitespace para exportaveis
VBA e marca `.frx` como binario. Essa decisao evita falsos positivos em cada
linha adicionada por arquivos CRLF e preserva o pacote que foi importado e
compilado no workbook.

## Comandos

Relatorio de EOL/whitespace dos exportaveis:

```bash
scripts/hbn-guards/report-vba-eol-whitespace.sh
```

Checagem curta de higiene:

```bash
scripts/hbn-guards/check-repo-hygiene.sh
```

## Organizacao de artefatos

Arquivos avulsos grandes na raiz devem ir para `local-ai/incoming/`, que e
area local ignorada. Evidencias pequenas e auditaveis devem ir para
`auditoria/evidencias/<versao>/csv/` ou pasta equivalente.

Na Onda 38.2.10:

- `Primeiro GATE-USO-PROLONGADO L43.pdf` foi movido para
  `local-ai/incoming/artefatos-avulsos/20260531/`.
- `TESTES.docx` foi movido para
  `local-ai/incoming/artefatos-avulsos/20260531/`.
- `TesteV2_INTEGRIDADE_ESTADO_Falhas_TV2_20260530_145447.csv` foi movido para
  `auditoria/evidencias/V12.0.0205/csv/`.

## Regra para proximas ondas

Se uma onda precisar normalizar fisicamente EOL/whitespace de VBA, ela deve
abrir readback proprio com lista fechada de arquivos, regenerar espelhos
`local-ai/vba_import/` quando aplicavel e exigir compile/teste no workbook.
