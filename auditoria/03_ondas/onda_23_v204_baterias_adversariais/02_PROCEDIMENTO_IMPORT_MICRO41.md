---
titulo: Procedimento de Importacao — MICRO41 Onda 23
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-07
---

# Procedimento de Importacao — MICRO41

## 1. Importar pacote

```vb
ImportarPacoteV3_Delta "MICRO41", "f7aa84f+ONDA23.MD23.1-adversarial-ui"
```

Resultado esperado do Importador V3:

```text
M=4 | F=0 | err=0 | skip=0
```

## 2. Compilar

No VBE:

```text
Depurar > Compilar VBAProject
```

Se falhar, nao salvar o workbook e reportar a linha destacada.

## 3. Confirmar build

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA23.MD23.1-adversarial-ui
```

## 4. Rodar suite nova

```vb
TV2_RunAdversarial_UI False
```

Esperado:

```text
ADVERSARIAL_UI=10/0/0
```

## 5. Rodar Quinteto

```vb
CT_ValidarRelease_QuintetoMinimo
```

Gate esperado:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0
```
