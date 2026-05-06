---
titulo: Procedimento de Importacao — MICRO38 Onda 22
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Procedimento de Importacao — MICRO38

## 1. Importar pacote

```vb
ImportarPacoteV3_Delta "MICRO38", "f7aa84f+ONDA22.MD22.2-ref-orfa-cad-os"
```

Resultado esperado do Importador V3:

```text
M=4 | F=0 | err=0 | skip=0
```

## 2. Compilar

Executar `VBE > Depurar > Compilar VBAProject`.

Se a compilacao falhar, nao salve o workbook. Feche sem salvar e restaure pelo backup informado pelo Importador V3.

## 3. Confirmar build

```vb
?GetBuildImportado
```

Resultado esperado:

```text
f7aa84f+ONDA22.MD22.2-ref-orfa-cad-os
```

## 4. Rodar migracao controlada

```vb
?RepoOS_MigrarRefOrfaLegado()
```

Resultado esperado:

```text
DEPOIS: ORFA_EMP=0; ORFA_ATIV=0; RESIDUOS=0
```

Se o resultado depois da limpeza ainda mostrar `ORFA_EMP>0` ou `ORFA_ATIV>0`, pare e envie a linha completa da Janela Imediata antes de salvar.

## 5. Rodar Quinteto

```vb
CT_ValidarRelease_QuintetoMinimo
```

Resultado esperado:

```text
V1=171/0+V2_Smoke=31/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```
