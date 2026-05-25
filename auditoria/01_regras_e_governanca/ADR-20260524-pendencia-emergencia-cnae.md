---
titulo: ADR — Pendencia Emergencia_CNAE.bas fora da V206
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# ADR — Pendencia Emergencia_CNAE.bas fora da V206

## Status

Aceito como decisao documental: manter fora do workbook e fora de
`local-ai/vba_import/` nesta V206. Remocao, arquivamento ou reincorporacao
exigem decisao futura especifica.

## Contexto

`Emergencia_CNAE.bas` esta presente em `src/vba/` e ausente no export V5. A
Onda 37 classificou o arquivo como `precisa_decisao_humana`; o hearback da
Onda 37.1 preconfirmou manter fora e documentar a pendencia.

## Decisao

Nao importar `Emergencia_CNAE.bas` no workbook V5 e nao incluir o arquivo em
pacotes V206. O arquivo fica como pendencia documentada ate decisao futura de
arquivar, remover ou reincorporar.

## Consequencias

- Nenhum procedimento V206 deve orientar importacao de `Emergencia_CNAE.bas`.
- Uma onda futura que remova ou arquive o arquivo deve declarar o path
  explicitamente no readback.
- Se houver demanda de reincorporacao, a justificativa deve citar ADR/ERP e
  gate de compile/RVS aplicavel.

## Referencias

- `auditoria/03_ondas/onda_12_cnae_prorrogada/00_PRORROGACAO.md`
- `.hbn/readbacks/0009-onda09-v3-phase1.json`
- `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md`
