---
titulo: 31 - Procedimento Import MICRO32 Onda 21 V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Procedimento de Importacao - MICRO32

## 1. Pre-requisito

1. Workbook com MICRO31 importada.
2. VBAProject compilando limpo.
3. Quinteto MICRO31 aprovado:
   `V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.

## 2. Comando para Janela Imediata

```vb
ImportarPacoteV3_Delta "MICRO32", "f7aa84f+ONDA21.MD21.1-status-empresa-result"
```

## 3. Pos-import

1. Confirmar importador com `err=0`.
2. Rodar `Depurar > Compilar VBAProject`.
3. Confirmar build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA21.MD21.1-status-empresa-result
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

## 5. Rollback

1. Se compile falhar, nao salvar o workbook.
2. Restaurar o backup completo gerado pelo Importador V3.
3. Enviar janela imediata + print do erro.
4. Se apenas Quinteto falhar, enviar CSV de falhas e manter workbook aberto sem
   novas importacoes ate triagem.
