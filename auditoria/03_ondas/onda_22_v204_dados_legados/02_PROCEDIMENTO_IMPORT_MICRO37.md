---
titulo: Procedimento de Importacao — MICRO37 Onda 22
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Procedimento de Importacao — MICRO37

## Comando para a janela imediata

```vb
ImportarPacoteV3_Delta "MICRO37", "f7aa84f+ONDA22.MD22.1-backfill-dt-ult-reativ"
```

## Gate manual

1. Rodar o comando acima na Janela Imediata.
2. Confirmar Importador V3 com `M=5 | F=0 | err=0 | skip=0`.
3. Executar `VBE > Depurar > Compilar VBAProject`.
4. Na Janela Imediata, confirmar:

```vb
?GetBuildImportado
```

Resultado esperado:

```text
f7aa84f+ONDA22.MD22.1-backfill-dt-ult-reativ
```

5. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Resultado esperado:

```text
V1=171/0+V2_Smoke=30/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```

## Observacao operacional

Se a compilacao falhar, nao salve o workbook. Feche sem salvar e restaure a partir do backup informado pelo Importador V3.

