---
titulo: Onda 38.2.10 - higiene de repositorio
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Onda 38.2.10 - higiene de repositorio

## Escopo confirmado

Readback: `.hbn/readbacks/0126-rb-onda-38-2-10-higiene-repositorio.json`
Hearback: `.hbn/hearbacks/0126-rb-onda-38-2-10-higiene-repositorio-confirmed.json`

Objetivo: deixar o repositorio em estado commitavel, sem ampliar risco em VBA,
e consolidar os avancos validados das ondas 38.2.4 a 38.2.9.

## Diagnostico

`git diff --check` falhava por falsos positivos em arquivos VBA/exportaveis
com CRLF ou EOL misto. O problema aparecia como `trailing whitespace` em massa
em `.bas`, `.frm` e espelhos importaveis, embora o conteudo ja tivesse passado
por import V3, compile manual e testes dirigidos.

Tambem havia artefatos avulsos na raiz:

- `Primeiro GATE-USO-PROLONGADO L43.pdf` (`17M`);
- `TESTES.docx` (`25M`);
- `TesteV2_INTEGRIDADE_ESTADO_Falhas_TV2_20260530_145447.csv`.

## Alteracoes de higiene

- Criado `.gitattributes`:
  - desativa `whitespace` para `.bas`, `.cls`, `.frm` e `code-only.txt`;
  - marca `.frx` como binario.
- Criado `.editorconfig`:
  - LF para documentos/scripts;
  - CRLF para exportaveis VBA;
  - sem trim automatico em VBA e `.frx`.
- Atualizado `.gitignore`:
  - ignora PDFs/DOCX soltos na raiz;
  - ignora CSVs `TesteV2_*_Falhas_*.csv` quando gerados na raiz.
- Criados scripts read-only:
  - `scripts/hbn-guards/report-vba-eol-whitespace.sh`;
  - `scripts/hbn-guards/check-repo-hygiene.sh`.
- Movidos artefatos grandes da raiz para
  `local-ai/incoming/artefatos-avulsos/20260531/`.
- Movido CSV de falha V2 para
  `auditoria/evidencias/V12.0.0205/csv/`.

## Validacoes locais

- `scripts/hbn-guards/validate-readback.sh` passou para o readback 0126.
- `scripts/hbn-guards/report-vba-eol-whitespace.sh` executou e terminou com
  `git diff --check` OK.
- `scripts/hbn-guards/check-repo-hygiene.sh` executou sem alterar arquivos.
- `git diff --check` passou limpo apos `.gitattributes`.

## Limites

Esta onda nao normalizou fisicamente os arquivos VBA. Essa decisao e
intencional: normalizacao em massa de exportaveis VBA gera diff grande, pode
mascarar mudanca funcional e exige novo import/compile/teste.

## Commit

O commit desta onda consolida os avancos ja validados das ondas 38.2.4 a
38.2.9, alem da higiene estrutural 38.2.10. Nao declara freeze V206.
