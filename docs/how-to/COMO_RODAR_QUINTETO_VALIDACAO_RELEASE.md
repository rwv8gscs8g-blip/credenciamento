---
titulo: Como Rodar o Quinteto de Validacao Release
diataxis: how-to
hbn-track: fast_track
hbn-status: archived
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Como Rodar o Quinteto de Validacao Release

> Documento historico da V12.0.0203/rc4. Para validar a V12.0.0204, use
> [Como Rodar o Sexteto de Validacao da Release](COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md).

Use este procedimento quando precisar validar formalmente a release no
workbook de homologacao.

## Pre-condicoes

1. Workbook correto aberto.
2. Macros habilitadas.
3. VBE acessivel.
4. Importacao concluida sem erro.
5. `Depurar > Compilar VBAProject` passou limpo.

## Comando principal

Copie na Janela Imediata:

```vb
CT_ValidarRelease_Quinteto
```

## Comandos auxiliares

Conferir build:

```vb
?GetBuildImportado
```

Conferir ultimo status do importador V3:

```vb
ImportarPacoteV3_Status
```

## Resultado esperado para V203 rc4

| Suite | OK | Falha |
|---|---:|---:|
| V1 rapida | 171 | 0 |
| V2 Smoke | 27 | 0 |
| V2 Canonica | 23 | 0 |
| E2E Strikes | 71 | 0 |
| IntegridadeBase | 3 | 0 |

Sintaxe esperada:

```text
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```

## Se passar

1. Copie o `VALIDACAO_ID`.
2. Copie o build.
3. Registre o caminho do CSV.
4. Tire print da aba `VALIDACAO_RELEASE`.
5. Registre no fechamento da onda/release.

## Se reprovar

1. Nao promova a release.
2. Abra o CSV em `CSV resumo (gerado)`.
3. Copie a primeira falha.
4. Classifique a falha como codigo, teste, dado, importacao ou operacao.
5. Se houver falha em `V2_CANONICO`, trate como candidata a bloqueio ate
   prova contraria.

## Evidencia canonica da rc4

| Campo | Valor |
|---|---|
| Validacao | `VR_20260504_171048` |
| Resultado | `APROVADO` |
| CSV | `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv` |

## Regra de decisao

Quinteto verde autoriza teste manual formal e publicacao de vitrine. Nao
autoriza producao quando ainda existem debitos tecnicos conhecidos que
precisam entrar na V204.
