---
titulo: Procedimento de Importacao — MICRO49-fix2
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Procedimento de Importacao — MICRO49-fix2

## Comando

Na janela imediata do VBE:

```vb
ImportarPacoteV3_Delta "MICRO49-fix2", "f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos-fix2"
```

## Gates

1. Conferir importador: `M=4 | F=0 | err=0 | skip=0`.
2. Rodar `VBE > Depurar > Compilar VBAProject`.
3. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos-fix2
```

4. Rodar Smoke:

```vb
TV2_RunSmoke False
```

Esperado:

```text
OK=33 | FALHA=0 | MANUAL=4
```

5. Rodar Sexteto:

```vb
CT_ValidarRelease_SextetoMinimo
```

Esperado:

```text
V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Se falhar

Se o Excel fechar novamente ao compilar, nao salve o workbook. Reabra a ancora
anterior aprovada em MICRO48 e informe o ultimo build exibido por
`?GetBuildImportado`.

