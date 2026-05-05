---
titulo: 21 - Procedimento Import MICRO31 Onda 20 V204 P0 UI
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Procedimento de Importacao - MICRO31

## 1. Comando unico

Copiar para a Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO31", "f7aa84f+ONDA20.MD20-p0-ui-reativacao"
```

## 2. Conferencias pos-import

1. O importador deve terminar com:

```text
M=5 | F=6 | err=0 | skip=0
```

2. No VBE, executar:

```text
Depurar > Compilar VBAProject
```

3. Na Janela Imediata:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA20.MD20-p0-ui-reativacao
```

4. Rodar Quinteto:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado:

```text
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```

## 3. Se falhar

1. Se falhar no compile: nao salvar o workbook; restaurar backup V3 gerado
   pelo importador.
2. Se falhar no Quinteto: enviar print, janela imediata e CSV de falhas.
3. Nao avancar para Onda 21 antes do Quinteto verde da Onda 20.
