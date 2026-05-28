---
titulo: Bypass AT-3 Fix1 G7 AAX preexistente
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass AT-3 Fix1 G7 AAX preexistente

## Contexto

O commit do AT-3 Fix1 foi bloqueado pelo pre-commit Glasswing G7 porque `local-ai/vba_import/001-modulo/AAX-App_Release.bas` permanece divergente no working tree.

Esse drift vem do BUMP executado pelo Importador V3 no workbook e ja era conhecido como estado herdado/operacional. O Fix1 nao altera `AAX-App_Release.bas`, nao o inclui no stage e nao muda build label versionado em fonte.

## Validacoes antes do bypass

- `bash scripts/hbn-guards/hbn-guards-runner.sh`: passou com todos os staged dentro do scope do readback `0115`.
- `python3 local-ai/scripts/publicar_vba_import_v2.py check --only Repo_PreOS.bas --only Teste_V2_Roteiros.bas`: passou.
- Diff de `Teste_V2_Roteiros.bas`: 4 substituicoes mecanicas de `Repo_PreOS.BuscarPorId(...)` para `RepoPreOS_BuscarPorId(...)`.

## Decisao

Usar commit com header `[bypass-hbn-guards]` apenas para contornar o G7 global causado por `AAX-App_Release.bas` fora do escopo. Nao rodar `--apply` global.
