---
titulo: Procedimento de importacao - Onda 38.2.6
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Procedimento de importacao - Onda 38.2.6

## Pre-check no VBE

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

Esperado: `\\Mac\Home\Projetos\Credenciamento`.

## Import

```vb
ImportarPacoteV3_Delta "ONDA38_2_6_IMPRESSAO_INTEGRIDADE", "fd45a5d+ONDA38.2.6-IMPRESSAO-INTEGRIDADE"
```

Resultado esperado do Importador V3:

```text
M=3 | F=1 | err=0 | skip=0
```

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunImpressaoIntegridade
```

Esperado:

```text
OK=6 | FALHA=0 | MANUAL=0
```

## Arquivos importados

- `local-ai/vba_import/001-modulo/AAU-Preencher.bas`
- `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm`
- `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas`
- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`
