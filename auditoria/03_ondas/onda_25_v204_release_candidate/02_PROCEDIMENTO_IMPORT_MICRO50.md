---
titulo: Procedimento de Importacao MICRO50
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Procedimento de Importacao MICRO50

## Pre-check

Na Janela Imediata do VBE:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter
```

## Import

Cole na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "MICRO50", "f7aa84f+v12.0.0204-rc1"
```

Esperado do Importador V3:

```text
M=2 | F=0 | err=0 | skip=0
```

## Gate Pos-Import

1. Rodar `VBE > Depurar > Compilar VBAProject`.
2. Confirmar build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+v12.0.0204-rc1
```

3. Rodar gate oficial:

```vb
CT_ValidarRelease_SextetoMinimo
```

Esperado:

```text
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
CSV: auditoria/evidencias/V12.0.0204
```

## Se falhar

Se a compilacao fechar o Excel ou `GetBuildImportado` nao retornar o build
rc1, nao salvar o workbook. Reabrir a ancora MICRO48 e informar o ultimo
build exibido.
