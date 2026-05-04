---
titulo: Procedimento de importacao — Onda 18 MD-18.1b janela de strikes
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 16. Procedimento de Import — MD-18.1b Janela de Strikes

## Objetivo

Importar o `MICRO26`, que resolve a parte logica do
`DT-17-REATIV-STRIKES`: historico total de strikes continua consultavel,
mas a punicao passa a considerar apenas strikes com fechamento posterior
a `EMPRESAS.DT_ULT_REATIV`.

## Pre-condicao

`MICRO25-fix2` importado, compilado e salvo como checkpoint MD-18.1a.

## Arquivos

| # | Arquivo no repositorio | Acao |
|---|---|---|
| 1 | `local-ai/vba_import/001-modulo/AAN-Repo_Avaliacao.bas` | adiciona `ContarStrikesParaPunicao` |
| 2 | `local-ai/vba_import/001-modulo/AAS-Svc_Avaliacao.bas` | usa contador de punicao |
| 3 | `local-ai/vba_import/001-modulo/AAO-Repo_Empresa.bas` | grava `DT_ULT_REATIV` no status |
| 4 | `local-ai/vba_import/001-modulo/AAP-Svc_Rodizio.bas` | `Reativar` carimba `DT_ULT_REATIV` |
| 5 | `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | cenarios QA da janela |
| 6 | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | build label |

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO26", "f7aa84f+ONDA18.MD18.1b-reativ-strikes-window"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA18.MD18.1b-reativ-strikes-window
```

3. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=6 | F=0 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Quinteto | APROVADO |
| CS_E2E_REATIV2STRIKES | verde |
| RPT_BUGS_CONHECIDOS | DT-17 ainda ABERTO ate MD-18.3 |

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint MD-18.1a.
