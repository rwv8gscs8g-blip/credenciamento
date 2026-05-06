---
titulo: Procedimento de Importacao — MICRO39 Onda 22
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Procedimento de Importacao — MICRO39

## 1. Importar pacote

```vb
ImportarPacoteV3_Delta "MICRO39", "f7aa84f+ONDA22.MD22.3-dt-ult-reativ-invalida"
```

Resultado esperado do Importador V3:

```text
M=5 | F=0 | err=0 | skip=0
```

## 2. Compilar

Executar `VBE > Depurar > Compilar VBAProject`.

Se a compilacao falhar, nao salve o workbook. Feche sem salvar e restaure
pelo backup informado pelo Importador V3.

## 3. Confirmar build

```vb
?GetBuildImportado
```

Resultado esperado:

```text
f7aa84f+ONDA22.MD22.3-dt-ult-reativ-invalida
```

## 4. Rodar Quinteto

```vb
CT_ValidarRelease_QuintetoMinimo
```

Resultado esperado:

```text
V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=4/0
```

Se `IntegridadeBase` aparecer como `MANUAL=1`, envie tambem o campo
`PRIMEIRA_FALHA` para confirmar se ha `INT-DT-ULT-REATIV-INVALIDA`
pendente na base.
