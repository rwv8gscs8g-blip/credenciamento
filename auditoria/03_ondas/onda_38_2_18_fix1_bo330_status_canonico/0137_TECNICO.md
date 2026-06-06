---
titulo: Onda 38.2.18-fix1 - BO330 status canonico
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.18-fix1 - BO330 status canonico

## Contexto

Mauricio importou e compilou o pacote 0136. O teste dirigido
`TV2_RunBO330Diagnostico` executou como `TV2_20260602_105519` e retornou:

`OK=18 | FALHA=6 | MANUAL=0`

O CSV de falhas mostrou que a OS ficou vinculada a `EMP03` e que a suspensao
foi gravada no literal canonico:

- `OS_EMP_ID=003`;
- `STATUS_SEL=SUSPENSA_GLOBAL`;
- `STATUS_EMP03=SUSPENSA_GLOBAL`;
- `DT_FIM_SUSP=2026-07-02`.

A divergencia era a expectativa do proprio diagnostico, que comparava contra
`SUSPENSA`.

## Decisao Tecnica

Corrigir somente a constante do modulo diagnostico:

```vb
Private Const TV2_BO330_STATUS_SUSPENSA As String = "SUSPENSA_GLOBAL"
```

Nenhum modulo de producao foi alterado. A escolha do literal e consistente com
`Svc_Rodizio`, `Mod_Types`, `Teste_Bateria_Oficial` e `Teste_V2_Roteiros`.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_FIX1_BO330_STATUS_CANONICO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_18_FIX1_BO330_STATUS_CANONICO", "e157221+ONDA38.2.18-FIX1-BO330-STATUS"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/ABP-Teste_V2_BO330_Diagnostico.bas`.

Sem forms, sem `.frx`, sem `Auto_Open`, sem producao.

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunBO330Diagnostico
```

Resultado esperado:

`OK=24 | FALHA=0 | MANUAL=0`

## Resultado Humano

Mauricio reportou:

- Importador V3 OK: `M=2 | F=0 | err=0 | skip=0`;
- compile limpo no VBE;
- `TV2_RunBO330Diagnostico`: `TV2_20260602_111854` com
  `OK=24 | FALHA=0 | MANUAL=0`;
- `CT_ValidarRelease_TrioMinimo`: `VR_20260602_112011`, resultado
  `APROVADO`.

Resumo do Trio:

- V1 rapida `BO-20260602-112011`: `OK=171 | FALHA=0 | MANUAL=0`;
- V2 smoke `TV2_20260602_112944`: `OK=34 | FALHA=0 | MANUAL=4`;
- V2 canonico `TV2_20260602_113207`: `OK=24 | FALHA=0 | MANUAL=0`.

CSV de evidencia:

`auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseTrio_V12_0_0205_VR_20260602_112011.csv`

Hash SHA-256:

`30619777433b39571a6cff5099b7c05f2580a28051ff6c4e114da3af548fedb6`

## Veredito

38.2.18-fix1 validada. A falha BO_330 anterior estava ligada a expectativa
do diagnostico e a linha validada agora passa no Trio minimo.
