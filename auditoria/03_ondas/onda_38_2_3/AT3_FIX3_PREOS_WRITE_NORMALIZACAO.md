---
titulo: AT-3 Fix3 PreOS Write Normalizacao
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-3 Fix3 PreOS Write Normalizacao

## Bloqueador

Depois do fix2, `TV2_RunRodizioStrikesEndToEnd` continuou com 37 falhas em `DIAG_PREOS_INTEGRITY`. O novo CSV mostrou:

`EMP_PRESEL=2 EMP_PRESEL_CANON=002 EMP_PREOS_BRUTO=2 EMP_PREOS_REPO=002 NF=@`

e o equivalente para `3/003`.

Isso prova que o formato da celula estava correto (`NF=@`), mas `Svc_PreOS.EmitirPreOS` ainda gravava `rodizio.Empresa.EMP_ID` cru. A leitura por `Repo_PreOS` normalizava para `002/003`, mas a celula bruta permanecia `2/3`.

## Correcao

`Svc_PreOS.EmitirPreOS` agora calcula variaveis locais textuais antes da gravacao:

- `entIdTexto`
- `ativIdTexto`
- `servIdTexto`
- `empIdTexto`
- `codServTexto`

A gravacao em `PRE_OS` usa esses valores depois de aplicar `NumberFormat="@"`. O normalizador e privado ao modulo e segue o contrato V206:

- valores vazios, `Null`, `Empty` ou `Error` retornam vazio;
- somente strings de digitos recebem zero-padding ate largura minima 3;
- valores `>= 1000` nao sao truncados;
- tokens textuais nao numericos sao preservados.

## Evidencia preservada

CSV copiado para:

`auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_220557.csv`

Hash SHA-256:

`bc51e593e21d9f6d4ba40252c35d8c47f1721bf7628db05a8a9680c72d214017`

## Import

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX3_PREOS_WRITE_NORMALIZACAO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_AT3_FIX3_PREOS_WRITE_NORMALIZACAO", "<sha>+ONDA38.2.3-AT3.fix3-PREOS-WRITE"
```

## Proximo gate

1. Importar fix3.
2. Rodar `Debug > Compile VBAProject`.
3. Se compile verde, rodar `TV2_RunRodizioStrikesEndToEnd`.
