---
titulo: Procedimento de importacao — Onda 18 MD-18.2 statusbar hint
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 18. Procedimento de Import — MD-18.2 Statusbar Hint

## Objetivo

Importar o `MICRO28`, que adiciona no primeiro aviso do Modo Treinamento
a dica para acompanhar o progresso na barra de status do Excel.

## Pre-condicao

1. `MICRO27` importado, compilado e Quinteto aprovado.
2. Workbook salvo no checkpoint pos-`MICRO27`.

## Arquivos

| # | Arquivo no repositorio | Acao |
|---|---|---|
| 1 | `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` | fonte do form |
| 2 | `local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt` | codigo aplicado pelo V3 em modo estabilizado |
| 3 | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | build label |

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO28", "f7aa84f+ONDA18.MD18.2-statusbar-hint-treinamento"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA18.MD18.2-statusbar-hint-treinamento
```

3. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

4. Check visual manual: abrir o Modo Treinamento e conferir que o
primeiro `MsgBox` mostra:

```text
Acompanhe o progresso no canto inferior esquerdo da tela
(barra de status com cenario atual / total).
```

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=1 | F=1 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Quinteto | `APROVADO` |
| Visual | dica aparece no primeiro aviso do Modo Treinamento |

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint pos-`MICRO27`.
