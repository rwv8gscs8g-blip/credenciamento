---
titulo: Onda 37.2 — Reversao dos drift MD33 descartaveis
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Onda 37.2 — Reversao dos drift MD33 descartaveis

## Objetivo

Restaurar `src/vba/` ao estado equivalente ao export V5 apenas nos tres
arquivos classificados como `drift_md33_descartar` na Onda 37.1, sem tocar o
workbook V5 e sem usar `local-ai/incoming/` como fonte operacional de
importacao.

## Arquivos revertidos

| Arquivo | Origem do drift | Resultado |
|---|---|---|
| `src/vba/Importador_V3.bas` | cadeia MD33 reprovada | restaurado ao conteudo do export V5 |
| `src/vba/Menu_Principal.frm` | cadeia MD33 reprovada | restaurado ao conteudo do export V5 |
| `src/vba/Preencher.bas` | cadeia MD33 reprovada | restaurado ao conteudo do export V5 |

Os espelhos correspondentes em `local-ai/vba_import/` foram atualizados para
manter a Regra de Ouro antes do gate humano.

## Hashes de equivalencia

| Par | SHA-256 esperado |
|---|---|
| `src/vba/Importador_V3.bas` = `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas` | `949ac61884af9e1e8dc1b888bae673081750220a05fc15068c3b1f1cb344bd6f` |
| `src/vba/Preencher.bas` = `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | `8efe8005e8abe2df6b9cdd237a4b6ccac8e4cfd183d5d0c1fd51a7048a0c2d71` |
| `src/vba/Menu_Principal.frm` = `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` | `fbc9e2e964df3e19431fa72cdd69f2bbcd815cae3c0a299ab1ba7d241e600df5` |
| corpo importavel de `Menu_Principal.frm` = `AAM-Menu_Principal.code-only.txt` | `537b82d5c75f42a61cb833f426a23514a4391fd54a04bec77664d4e7b74460b9` |

## Gates executados por Codex

| Gate | Status | Evidencia |
|---|---|---|
| Diff limitado ao scope 0092 | pass | `git diff --name-only` mostrou somente os tres arquivos `src/vba/` antes do staging; os quatro espelhos importaveis sao ignorados por `.gitignore` e entram no commit apenas com `git add -f` dos paths declarados no readback. |
| Hash entre `src/vba/` e `local-ai/vba_import/` | pass | `shasum -a 256`, `diff -q` dos tres pares e `bash local-ai/scripts/publicar_vba_import_v2.sh --check` retornando G7/G8 OK. |
| Zero diff em forbidden paths | pass | `git status --short -- local-ai/incoming backups/vba src/vba/Svc_* src/vba/Mod_Types.bas src/vba/Rel_Emp_Serv.* src/vba/Rel_OSEmpresa.* src/vba/Menu_Principal.frx` sem saida. |
| Procedimento humano restringe import ao pacote oficial | pass | `37_2_PROCEDIMENTO_IMPORT.md`. |
| Compile humano no VBE antes do fechamento do ERP | pending_human | Esta onda fica entregue para gate humano; o ERP nao fecha funcionalmente antes da confirmacao de Mauricio. |

## Invariantes preservados

- O workbook V5 nao foi tocado.
- `local-ai/incoming/` foi lido como evidencia e permaneceu intacto.
- `Menu_Principal.frx` nao foi tocado.
- Nenhum `Svc_*`, `Mod_Types.bas`, `Rel_Emp_Serv.*` ou `Rel_OSEmpresa.*` foi tocado.
- RN-01 a RN-17 e contadores RVS permaneceram fora do escopo.

## Estado operacional

O commit desta onda entrega a reversao no repositório e o pacote importavel
correspondente. O fechamento funcional fica pendente ate Mauricio importar
somente de `local-ai/vba_import/` no workbook V5 e confirmar compile no VBE.
