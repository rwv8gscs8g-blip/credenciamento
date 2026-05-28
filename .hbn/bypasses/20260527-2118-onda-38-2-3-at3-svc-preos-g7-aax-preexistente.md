---
titulo: Bypass AT-3 G7 AAX preexistente
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass AT-3 G7 AAX preexistente

## Contexto

O commit AT-3 foi bloqueado pelo pre-commit Glasswing G7 porque `local-ai/vba_import/001-modulo/AAX-App_Release.bas` permanece divergente no working tree.

Esse drift e herdado do estado recebido no bastao e ja foi documentado nos bypasses AT-1/AT-2. O AT-3 nao altera `AAX-App_Release.bas`, nao o inclui no stage e nao muda build label versionado.

## Validacoes antes do bypass

- `bash scripts/hbn-guards/hbn-guards-runner.sh`: passou com todos os staged dentro do scope do readback AT-3.
- `python3 local-ai/scripts/publicar_vba_import_v2.py check --only Svc_PreOS.bas --only Repo_PreOS.bas`: passou.
- `rg -n "Pad3\\(|IsNumeric\\(" src/vba/Repo_PreOS.bas src/vba/Svc_PreOS.bas`: sem ocorrencias.
- Espelhos `AAL-Repo_PreOS.bas` e `AAQ-Svc_PreOS.bas` sincronizados com `src/vba`.

## Decisao

Usar commit com header `[bypass-hbn-guards]` apenas para contornar o bloqueio G7 global causado por `AAX-App_Release.bas` preexistente. Nao rodar `--apply` global porque isso tocaria arquivo fora do readback AT-3.
