---
titulo: 45 - Procedimento Import MICRO36
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Procedimento de Importacao - MICRO36

## 1. Comando para Janela Imediata

```vb
ImportarPacoteV3_Delta "MICRO36", "f7aa84f+ONDA21.MD21.6-transacao-aninhamento"
```

## 2. Pos-import

1. Confirmar `err=0`.
2. Rodar `Depurar > Compilar VBAProject`.
3. Confirmar build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA21.MD21.6-transacao-aninhamento
```

## 3. Gate

Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado:

```text
V1=171/0+V2_Smoke=29/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```
