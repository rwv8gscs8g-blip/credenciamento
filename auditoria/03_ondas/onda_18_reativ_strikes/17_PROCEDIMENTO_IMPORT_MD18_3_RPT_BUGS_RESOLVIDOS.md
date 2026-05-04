---
titulo: Procedimento de importacao — Onda 18 MD-18.3 RPT_BUGS_RESOLVIDOS
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 17. Procedimento de Import — MD-18.3 RPT_BUGS_RESOLVIDOS

## Objetivo

Importar o `MICRO27`, que fecha administrativamente o
`DT-17-REATIV-STRIKES`: o bug sai de `RPT_BUGS_CONHECIDOS` e passa a
aparecer em `RPT_BUGS_RESOLVIDOS` como `RESOLVIDO`.

## Pre-condicao

1. `MICRO25-fix2` importado, compilado e Quinteto aprovado.
2. `MICRO26` importado, compilado e Quinteto aprovado.
3. Workbook salvo no checkpoint pos-`MICRO26`.

## Arquivos

| # | Arquivo no repositorio | Acao |
|---|---|---|
| 1 | `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | cria `RPT_BUGS_RESOLVIDOS` e move DT-17 |
| 2 | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | build label |

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO27", "f7aa84f+ONDA18.MD18.3-rpt-bugs-resolvidos"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA18.MD18.3-rpt-bugs-resolvidos
```

3. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=2 | F=0 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Quinteto | `APROVADO` |
| Sintaxe esperada | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |
| `RPT_BUGS_RESOLVIDOS` | contem `DT-17-REATIV-STRIKES` com `STATUS=RESOLVIDO` |
| `RPT_BUGS_CONHECIDOS` | nao contem `DT-17-REATIV-STRIKES`; `INT-CAD-OS-REF-ORFA` pode permanecer aberto |

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint pos-`MICRO26`.
