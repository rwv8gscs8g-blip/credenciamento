---
titulo: Procedimento de importacao — MICRO30 R1 forms reativacao
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 20. Procedimento de Import — MICRO30 R1 Forms Reativacao

## Objetivo

Importar a correcao final R1 antes de liberar `V12.0.0203` para testes
manuais. O fluxo manual de `Reativa_Empresa.frm` passa a gravar
`EMPRESAS.DT_ULT_REATIV`, removendo o bypass apontado nas auditorias 58/59.

Esta liberacao continua sendo **homologacao/testes**, nao producao.

## Pre-condicao

1. `MICRO29` importado.
2. Compile manual limpo.
3. Quinteto `VR_20260504_075624` aprovado.
4. Workbook salvo no checkpoint rc3 antes deste import.

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO30", "f7aa84f+v12.0.0203-rc4-r1-forms-reativ"
```

## Gates

1. `Depurar > Compilar VBAProject` deve passar limpo.
2. Conferir build:

```vb
?GetBuildImportado
```

Esperado:

```text
f7aa84f+v12.0.0203-rc4-r1-forms-reativ
```

3. Conferir tag:

```vb
?GetReleaseTag
```

Esperado:

```text
v12.0.0203-rc4
```

4. Rodar:

```vb
CT_ValidarRelease_QuintetoMinimo
```

Esperado: `APROVADO`.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=4 | F=1 | err=0 | skip=0` |
| Compile manual | 0 erros |
| Build | `f7aa84f+v12.0.0203-rc4-r1-forms-reativ` |
| Tag | `v12.0.0203-rc4` |
| Quinteto | `APROVADO` |
| Sintaxe esperada | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |

## Check Manual Sugerido

Depois do Quinteto verde, testar manualmente:

1. Inativar uma empresa pelo fluxo normal.
2. Reativar a empresa pelo form `Reativa_Empresa`.
3. Conferir na aba `EMPRESAS` que a coluna `DT_ULT_REATIV` da empresa
   ficou preenchida.
4. Conferir no `AUDIT_LOG` evento `Empresa Reativada` com usuario
   `Reativa_Empresa.frm`.

## Rollback

Se qualquer gate falhar, nao salvar. Fechar sem salvar e reabrir o
checkpoint `v12.0.0203-rc3` pos-`MICRO29`.
