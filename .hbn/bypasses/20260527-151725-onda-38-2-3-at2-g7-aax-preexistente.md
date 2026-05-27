---
titulo: Bypass AT-2 G7 AAX preexistente
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass AT-2 G7 AAX preexistente

## Contexto

O commit do AT-2 foi bloqueado pelo pre-commit Glasswing G7 porque o arquivo `local-ai/vba_import/001-modulo/AAX-App_Release.bas` permanece divergente no working tree.

Esse drift e herdado do estado recebido no bastao e ja estava documentado no bootstrap/readback AT-1. O AT-2 nao altera `AAX-App_Release.bas`, nao o inclui no stage e nao muda build label versionado.

## Validacoes antes do bypass

- `bash scripts/hbn-guards/hbn-guards-runner.sh`: passou com todos os staged dentro do scope do readback AT-2.
- `bash local-ai/scripts/publicar_vba_import_v2.sh --check --only Credencia_Empresa.frm`: passou.
- Paridade code-only de `Credencia_Empresa`: `code_only_equal=True`.
- `ProgressBar` permaneceu fora de escopo.

## Decisao

Usar commit com header `[bypass-hbn-guards]` apenas para contornar o bloqueio G7 global causado por `AAX-App_Release.bas` preexistente. Nao usar `--apply` global, porque isso tocaria arquivo fora do readback AT-2 e violaria a decisao de manter AAX unstaged.
