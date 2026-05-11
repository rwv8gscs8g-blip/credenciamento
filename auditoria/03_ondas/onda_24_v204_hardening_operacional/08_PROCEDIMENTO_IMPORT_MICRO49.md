---
titulo: Procedimento de Importacao MICRO49
diataxis: how-to
hbn-track: safe_track
hbn-status: archived
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Procedimento de Importacao MICRO49

> Status: substituido por MICRO49-fix1. Nao usar este procedimento; usar
> `10_PROCEDIMENTO_IMPORT_MICRO49_FIX1.md`.

## Comando

Cole na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "MICRO49", "f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos"
```

## Gate Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Na Janela Imediata:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos
```

3. Rodar a suite que prova o novo teste:

```vb
TV2_RunSmoke False
```

Esperado: `OK=34 | FALHA=0 | MANUAL=4`.

Importador esperado: `M=4 | F=0 | err=0 | skip=0`.

4. Rodar o gate oficial:

```vb
CT_ValidarRelease_SextetoMinimo
```

Esperado:

```text
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Rollback

Se a compilacao falhar, nao salvar o workbook. Fechar sem salvar e restaurar
do backup V3 informado pelo importador.
