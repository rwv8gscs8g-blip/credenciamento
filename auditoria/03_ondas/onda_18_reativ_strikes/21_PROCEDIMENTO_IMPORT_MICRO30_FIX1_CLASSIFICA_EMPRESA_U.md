---
titulo: Procedimento de importacao — MICRO30-fix1 ClassificaEmpresa coluna U
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 21. Procedimento de Import — MICRO30-fix1 ClassificaEmpresa Coluna U

## Objetivo

Corrigir a reprovação do Quinteto `VR_20260504_163656`, cenário `CS_23`.
O `MICRO30` gravava `DT_ULT_REATIV`, mas `ClassificaEmpresa` ordenava só
`A:T`; como a nova data fica em `U`, o sort deixava a coluna fora da linha
reativada.

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO30-fix1", "f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u
```

3. Conferir tag:

```vb
?GetReleaseTag
```

Esperado:

```text
v12.0.0203-rc4
```

4. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=2 | F=0 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Build | `f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u` |
| Tag | `v12.0.0203-rc4` |
| Quinteto | `APROVADO` |
| Sintaxe esperada | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |

## Resultado Obtido

| Gate | Resultado |
|---|---|
| Importador V3 | Importou |
| Compile manual | Passou |
| Quinteto | `VR_20260504_171048` **APROVADO** |
| Sintaxe | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |
| Evidência | `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv` |

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint anterior ao `MICRO30` ou o backup V3 gerado no import.
