---
titulo: MICRO49-fix2 — SelecionarEmpresa Com Efeitos Como Contrato Documentado
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# MICRO49-fix2 — SelecionarEmpresa com efeitos como contrato documentado

## Decisao

O operador confirmou que `MICRO49-fix1` importou e atualizou
`GetBuildImportado`, mas a compilacao manual continuou fechando o Excel. O
Smoke executado apos a reabertura voltou a `33/0/4`, indicando que o novo
`SMK_008` nao deve entrar no gate neste ciclo.

## Implementacao

1. `Svc_Rodizio.SelecionarEmpresa` permanece como contrato publico unico.
2. Os efeitos colaterais continuam documentados em comentario no proprio
   contrato: atualizacao de `DT_ULTIMA_IND`, reativacao automatica por
   suspensao vencida e skip tecnico por OS aberta.
3. `SMK_008` e o helper `TV2_DtUltimaIndicacaoCred` foram removidos.
4. O Smoke esperado volta a `33/0/4`; o Sexteto esperado volta a
   `V2_Smoke=33/0`.

## Racional

Este microdelta nao cria nova funcionalidade nem nova superficie publica. Ele
reduz risco removendo o teste experimental que alterava o modulo grande de
roteiros e preserva a cobertura existente por `SMK_002`, E2E Strikes e
Sexteto. A regra "funcionalidade nova exige teste" continua vigente; aqui a
mudanca funcional foi retirada.

## Rollback

Se o Excel fechar novamente ao compilar depois do fix2, nao salvar o workbook.
Voltar para a ancora operacional anterior aprovada: MICRO48 /
`f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`, validada por E2E
`TV2_20260509_172616` e Sexteto `VR_20260509_173629`.

