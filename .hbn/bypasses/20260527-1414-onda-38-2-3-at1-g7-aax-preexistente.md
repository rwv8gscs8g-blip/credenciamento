---
titulo: Bypass HBN guards — Onda 38.2.3 AT-1
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass HBN guards — Onda 38.2.3 AT-1

## Motivo

O pre-commit executa `local-ai/scripts/publicar_vba_import_v2.sh --check` global quando o commit toca `local-ai/vba_import/**`. Esse check global reprova por drift preexistente em `local-ai/vba_import/001-modulo/AAX-App_Release.bas`, explicitamente herdado no bootstrap e fora do escopo do readback 0114.

## Autorização

Mauricio confirmou o readback 0114 em chat: "ok autorizo". O bypass não amplia o escopo funcional; apenas permite commitar o GATE-A1 já validado manualmente apesar do drift AAX preexistente.

## Guard bypassed

- Pre-commit Glasswing G7/G8 global acionado pelo hook.
- HBN guards foram rodados manualmente antes do commit e passaram com o readback 0114 confirmado.

## Remediação

AAX permanece unstaged e fora do commit AT-1. O drift de `AAX-App_Release.bas` deve ser tratado no ciclo/commit apropriado conforme knowledge 0016, sem misturar com o GATE-A1.
