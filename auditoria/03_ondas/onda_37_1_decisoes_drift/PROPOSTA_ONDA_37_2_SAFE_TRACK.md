---
titulo: Proposta Onda 37.2 — Reverter drift MD33 descartavel
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Proposta Onda 37.2 — Reverter drift MD33 descartavel

## Objetivo

Restaurar `src/vba/` ao estado equivalente ao export V5 apenas nos arquivos
classificados como `drift_md33_descartar`, sem usar `local-ai/incoming/` como
fonte de importacao e sem tocar o workbook.

## Arquivos candidatos

- `src/vba/Importador_V3.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Preencher.bas`

## Arquivos tocados por MD33 mas nao classificados como drift funcional

- `src/vba/Rel_Emp_Serv.frm`
- `src/vba/Rel_OSEmpresa.frm`

Esses dois ficaram `drift_export_benigno` na Onda 37 por normalizacao gamma.
Nao entram automaticamente na proposta de reversao funcional; podem ser
avaliados apenas se o readback 37.2 declarar tambem normalizacao cosmetica.

## Scope sugerido para readback 37.2

`files_allowed`:

- `src/vba/Importador_V3.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Preencher.bas`
- `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas`
- `local-ai/vba_import/001-modulo/AAU-Preencher.bas`
- `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm`
- `local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt`
- `auditoria/03_ondas/onda_37_2_reversao_md33/**`
- `.hbn/readbacks/0092-onda37-2-reversao-md33.json`
- `.hbn/results/0092-exec-onda37-2-reversao-md33.json`
- `.hbn/relay/INDEX.md`
- `CHANGELOG.md`

`files_forbidden`:

- `src/vba/Svc_*.bas`
- `src/vba/Mod_Types.bas`
- `local-ai/incoming/**`
- `backups/vba/**`

## Gates sugeridos

1. `git diff` deve mostrar somente os tres arquivos `src/vba/` e seus espelhos
   importaveis declarados.
2. Hash de cada `src/vba/` deve bater com o espelho em `local-ai/vba_import/`.
3. Nenhum `Svc_*`, `Mod_Types.bas` ou regra RN-01 a RN-17 deve mudar.
4. Operador deve importar apenas de `local-ai/vba_import/`, compilar no VBE e
   confirmar que a V5 permanece compilavel.

## Observacao

Esta proposta nao autoriza execucao. A Onda 37.2 precisa de readback
safe_track proprio e hearback humano antes de qualquer escrita em VBA.
