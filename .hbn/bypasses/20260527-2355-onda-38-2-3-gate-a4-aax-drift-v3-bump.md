---
titulo: Bypass HBN — GATE-A4 AAX drift V3 BUMP
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass HBN — GATE-A4 AAX drift V3 BUMP

## Motivo

`local-ai/vba_import/001-modulo/AAX-App_Release.bas` esta modificado no working tree por efeito operacional esperado do `ImportarPacoteV3_Delta`, que reescreve `APP_BUILD_IMPORTADO` e `APP_BUILD_GERADO_EM` antes de cada import.

Esse drift ja estava presente antes da abertura do GATE-A4 e deve permanecer **unstaged**, conforme knowledge 0016 / pratica operacional desta linha V206. O readback 0118 declara explicitamente `AAX-App_Release.bas` como forbidden para commit nesta abertura.

## Escopo do bypass

Bypass autorizado somente para permitir commit dos artefatos GATE-A4 e do desligamento de `ATIVAR_DIAG_FNEW5`. O bypass nao autoriza staging de `AAX-App_Release.bas`.

## Evidencia

`python3 local-ai/scripts/publicar_vba_import_v2.py check` reporta um unico divergente:

`AAX-App_Release.bas`

Todos os demais 52 artefatos reportados pelo gerador estao `in_sync`.
