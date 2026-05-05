---
titulo: 43 - Procedimento Import MICRO35 Fix3
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Procedimento de Importacao - MICRO35-fix3

## 1. Acao antes do import

1. Fechar a mensagem de erro do VBE.
2. Parar/resetar a execucao atual, se o VBE ainda estiver interrompido.
3. Nao salvar o workbook antes de importar o fix.

## 2. Comando para Janela Imediata

```vb
ImportarPacoteV3_Delta "MICRO35-fix3", "f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix3"
```

## 3. Pos-import

1. Confirmar `err=0`.
2. Rodar `Depurar > Compilar VBAProject`.
3. Confirmar build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix3
```

## 4. Gate

Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado:

```text
V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```
