---
titulo: Procedimento de importacao — MD-17.5 fechamento Onda 17+18 rc3
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 19. Procedimento de Import — MD-17.5 Fechamento RC3

## Objetivo

Importar o `MICRO29`, que carimba o workbook como
`v12.0.0203-rc3` após o fechamento verde das Ondas 17 e 18.

## Pre-condicao

1. `MICRO28` importado.
2. Compilação manual limpa.
3. Check visual do Modo Treinamento confirmado.
4. Quinteto `VR_20260504_070441` aprovado.

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO29", "f7aa84f+v12.0.0203-rc3"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+v12.0.0203-rc3
```

3. Conferir tag:

```vb
?GetReleaseTag
```

Esperado:

```text
v12.0.0203-rc3
```

4. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=1 | F=0 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Build | `f7aa84f+v12.0.0203-rc3` |
| Tag | `v12.0.0203-rc3` |
| Quinteto | `APROVADO` |
| Sintaxe esperada | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint pos-`MICRO28`.
