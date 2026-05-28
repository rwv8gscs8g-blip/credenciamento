---
titulo: Bypass HBN — AT-3 Fix3 G7 AAX herdado
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass HBN — AT-3 Fix3 G7 AAX herdado

## Contexto

O AT-3 Fix3 altera somente `Svc_PreOS` e seu espelho importavel. O guard HBN de escopo passa com o readback `0117-rb-onda-38-2-3-at3-fix3-preos-write-normalizacao`.

O pre-commit Glasswing G7 global continua sensivel ao drift herdado em `local-ai/vba_import/001-modulo/AAX-App_Release.bas`, produzido por import operacional anterior e mantido unstaged conforme knowledge 0016.

## Acao tomada

- Publicado `AAQ-Svc_PreOS.bas` com `python3 local-ai/scripts/publicar_vba_import_v2.py apply --only Svc_PreOS.bas`.
- Validado `python3 local-ai/scripts/publicar_vba_import_v2.py check --only Svc_PreOS.bas`.
- Mantido `AAX-App_Release.bas` fora do stage.
- Commit sera feito com `HBN_GUARDS_BYPASS=1` e header `[bypass-hbn-guards]`.

## Risco residual

O bypass nao cobre divergencia do artefato alterado neste fix (`AAQ-Svc_PreOS.bas`), que foi validado por `--only`. O unico ponto cego remanescente e o AAX herdado, ja conhecido e propositalmente nao staged.
