---
titulo: Procedimento de Importacao MICRO46
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Procedimento de Importacao MICRO46

## Comando

Cole na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "MICRO46", "f7aa84f+ONDA24.MD24.1-limpar-base-seguro"
```

## Gate Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Na Janela Imediata:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA24.MD24.1-limpar-base-seguro
```

3. Rodar a suite que prova o novo teste:

```vb
TV2_RunAdversarial_UI False
```

Esperado: `OK=12 | FALHA=0 | MANUAL=0`.

Importador esperado: `M=5 | F=1 | err=0 | skip=0`.

4. Rodar o gate oficial:

```vb
CT_ValidarRelease_SextetoMinimo
```

Esperado:

```text
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Rollback

Se a compilacao falhar, nao salvar o workbook. Fechar sem salvar e restaurar
do backup V3 informado pelo importador.
