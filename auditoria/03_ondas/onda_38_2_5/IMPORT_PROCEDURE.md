---
titulo: Procedimento de Import — Onda 38.2.5 UI de Regras de Negocio
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Procedimento de Import — Onda 38.2.5

## Pre-check

No VBE, antes do import:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

Caminho esperado: `\\Mac\Home\Projetos\Credenciamento`.

## Import V3

Executar na Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_5_UI_REGRAS_NEGOCIO", "fd45a5d+ONDA38.2.5-UI-REGRAS-NEGOCIO"
```

Resultado esperado:

```text
M=2 | F=1 | err=0
```

Componentes esperados:

- `Configuracao_Inicial` (`.frm` + `.frx` casados)
- `Teste_V2_Roteiros`
- `App_Release`

## Pos-import

1. Rodar `Depurar > Compilar VBAProject`.
2. Se compilar limpo, executar:

```vb
TV2_RunPersistenciaPainel
```

Resultado esperado: `OK=2 | FALHA=0 | MANUAL=0`.

A suite deve validar os seis campos do painel: `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`, `PR_Val_OS`, `TP_Valor` e `TxtMesesSuspensao`.

## Rollback

Se o import falhar, nao salvar o workbook. Fechar sem salvar e restaurar o backup V3 criado pelo importador.

Se o compile falhar, nao executar testes; registrar modulo/linha e fechar sem salvar.

Se `TV2_RunPersistenciaPainel` falhar, preservar o CSV de falhas e nao declarar BL-1 resolvido.
