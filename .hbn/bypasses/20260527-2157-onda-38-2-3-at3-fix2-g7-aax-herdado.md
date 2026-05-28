---
titulo: Bypass HBN — AT-3 Fix2 G7 AAX herdado
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass HBN — AT-3 Fix2 G7 AAX herdado

## Contexto

Durante o commit do AT-3 Fix2, `scripts/hbn-guards/hbn-guards-runner.sh` passou com todos os arquivos staged dentro do escopo do readback `0116-rb-onda-38-2-3-at3-fix2-preos-integrity-assert`.

O pre-commit adicional Glasswing G7 executou `publicar_vba_import_v2.py check` em modo global e bloqueou o commit porque `local-ai/vba_import/001-modulo/AAX-App_Release.bas` permanece divergente no working tree desde o import operacional anterior. Esse drift e herdado, deve ficar unstaged conforme knowledge 0016 e nao pertence ao escopo do Fix2.

## Acao tomada

- Regerado `ABG-Teste_V2_Roteiros.bas` com `python3 local-ai/scripts/publicar_vba_import_v2.py apply --only Teste_V2_Roteiros.bas`.
- Confirmado `check --only Teste_V2_Roteiros.bas` em sync.
- Mantido `AAX-App_Release.bas` fora do stage.
- Commit sera feito com `HBN_GUARDS_BYPASS=1` e header `[bypass-hbn-guards]`.

## Risco residual

O bypass nao cobre divergencia do artefato alterado neste fix (`ABG-Teste_V2_Roteiros.bas`), que foi validado por `--only`. O unico ponto cego remanescente e o AAX herdado, ja conhecido e propositalmente nao staged.
