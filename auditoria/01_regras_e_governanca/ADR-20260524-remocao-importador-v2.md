---
titulo: ADR — Remocao futura de Importador_V2.bas
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# ADR — Remocao futura de Importador_V2.bas

## Status

Aceito como decisao documental. Execucao pendente em onda safe_track propria.

## Contexto

`Importador_V2.bas` esta presente em `src/vba/`, mas ausente no export V5. A
Onda 37 classificou o arquivo como `obsoleto_no_repo`, com base na trilha da
Onda 9 e no documento `DRIFT_G7_RESIDUAL_PRE_ONDA12.md`, que registra
`NAO REINTEGRAR` para o legado V13.

## Decisao

Manter `Importador_V2.bas` fora do workbook e preparar remocao futura do repo
em onda safe_track especifica. Esta ADR nao remove o arquivo.

## Consequencias

- Nenhum pacote futuro deve reintroduzir `Importador_V2.bas`.
- A remocao fisica deve declarar `src/vba/Importador_V2.bas` no scope do
  readback da onda que executar a remocao.
- Documentos historicos que referenciam o V2 permanecem como rastreabilidade,
  mas devem apontar o V3 como fluxo vigente quando forem tocados.

## Referencias

- `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
- `auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md`
- `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md`
