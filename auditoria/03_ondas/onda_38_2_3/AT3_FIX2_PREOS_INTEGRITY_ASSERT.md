---
titulo: AT-3 Fix2 PreOS Integrity Assert
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-3 Fix2 PreOS Integrity Assert

## Bloqueador

Depois do fix1, o VBE compilou limpo e `TV2_RunRodizioStrikesEndToEnd` executou. O CSV `TesteV2_STRIKES_E2E_Falhas_TV2_20260527_213936.csv` registrou 37 falhas, todas em `DIAG_PREOS_INTEGRITY`.

O padrao das falhas foi:

- 14 ocorrencias: `EMP_PRESEL=2 EMP_PREOS=002`
- 23 ocorrencias: `EMP_PRESEL=3 EMP_PREOS=003`

Isso confirma que a correcao AT-3 preservou `PRE_OS.COL_PREOS_EMP_ID` como texto canonico. A falha restante era a assercao comparando o observador cru do rodizio (`2`/`3`) contra o ID persistido canonico (`002`/`003`).

## Correcao

`Teste_V2_Roteiros.bas` agora:

- normaliza a expectativa do observador com largura minima de 3 digitos, sem truncar valores `>= 1000`;
- le a celula bruta de `PRE_OS.COL_PREOS_EMP_ID` diretamente, sem passar por `RepoPreOS_BuscarPorId`;
- registra tambem o `NumberFormat` da celula;
- aprova `DIAG_PREOS_INTEGRITY` somente quando a celula bruta e o retorno do repo coincidirem com a expectativa canonica.

Assim, `002`/`003` passam; uma regressao para `2`/`3` bruto volta a falhar.

## Evidencia preservada

CSV copiado para:

`auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_213936.csv`

Hash SHA-256:

`2bd1889287ee8472d4e796e31aadf14f3a8fb821d3bf649cf1ef6455a2a7899c`

## Import

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX2_PREOS_INTEGRITY_ASSERT.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_AT3_FIX2_PREOS_INTEGRITY_ASSERT", "<sha>+ONDA38.2.3-AT3.fix2-PREOS-INTEGRITY"
```

## Proximo gate

1. Importar fix2.
2. Rodar `Debug > Compile VBAProject`.
3. Se compile verde, rodar `TV2_RunRodizioStrikesEndToEnd`.
