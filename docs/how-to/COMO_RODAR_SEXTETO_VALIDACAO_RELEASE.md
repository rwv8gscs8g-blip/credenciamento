---
titulo: Como Rodar o Sexteto de Validacao da Release
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Como Rodar o Sexteto de Validacao da Release

Este e o procedimento canonico da V12.0.0204 para reproduzir o gate automatizado
da release em uma maquina Windows com Excel Desktop.

## Pre-requisitos

1. A planilha `.xlsm` esta salva localmente.
2. As macros foram liberadas conforme
   [Como Liberar Macros no Windows](COMO_LIBERAR_MACROS_NO_WINDOWS.md).
3. O VBA compila limpo em **VBE > Depurar > Compilar VBAProject**.
4. A janela **Imediato** retorna o build esperado:

```vb
?GetBuildImportado
```

Retorno esperado:

```text
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

## Macro oficial

Na janela **Imediato** do VBE, execute:

```vb
CT_ValidarRelease_SextetoMinimo
```

O Excel deve preencher a aba `VALIDACAO_RELEASE`, exibir uma mensagem de
conclusao e gerar um CSV de resumo em:

```text
auditoria/evidencias/V12.0.0204/
```

## Resultado esperado

Para a V12.0.0204 validada, a sintaxe aprovada e:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

O resultado geral deve ser `APROVADO`.

## Evidencias oficiais da V204

| Evidencia | Papel |
|---|---|
| `VR_20260511_154433` | Gate final usado para publicacao da V12.0.0204 |
| `VR_20260511_175849` | Gate adicional apos MICRO55 App_Release final |

Ambas estao em `auditoria/evidencias/V12.0.0204/`.

## Regra de decisao

| Situacao | Decisao |
|---|---|
| Compilacao falha | Reprovar e nao salvar o workbook |
| Build diferente do esperado | Reprovar e registrar o valor retornado |
| Qualquer suite com falha maior que zero | Reprovar e anexar CSV de falhas |
| `MANUAL` diferente do esperado sem justificativa | Registrar como anomalia P2 |
| Sintaxe igual ao esperado e resultado `APROVADO` | Gate automatizado aprovado |

## Depois do Sexteto

Execute o roteiro humano da V204:

- [Roteiro de Teste Manual V204](../reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md)

O roteiro manual cobre o uso real da planilha, incluindo Limpar Base,
cadastro de servicos, credenciamento, rodizio, OS, avaliacao, strikes e
reativacao.
