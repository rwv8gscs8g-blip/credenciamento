---
titulo: AT-2 Procedimento Diagnostico F-NEW5
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-2 Procedimento Diagnostico F-NEW5

## Objetivo

Capturar o estado real da aba `CREDENCIADOS` imediatamente apos um credenciamento novo feito pela interface, antes de atribuir F-NEW5 a gravacao stale, cascata F-NEW6 ou artefato de exibicao.

## Import

1. Abrir o workbook operacional de referencia.
2. Abrir o VBE.
3. Na Janela Imediata, executar o comando informado pelo Codex no fechamento do AT-2:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_AT2_DIAG_FNEW5", "<sha_AT2>+ONDA38.2.3-AT2-DIAG"
```

4. Confirmar no retorno do Importador V3: `M=0 | F=1 | err=0`.
5. No VBE, executar `Debug > Compile VBAProject`.
6. Se o compile falhar, parar e devolver o erro ao Codex. Nao seguir para a reproducao.

## Reproducao

1. Pela interface, cadastrar uma atividade nova claramente identificavel, por exemplo `TESTE_DIAG_NEW5`.
2. Cadastrar pelo menos um servico nessa atividade.
3. Selecionar uma empresa ativa.
4. Abrir o credenciamento e credenciar a empresa na atividade nova.
5. Confirmar que a mensagem de credenciamento aparece.

## Evidencia esperada

O diagnostico deve criar:

```text
auditoria/evidencias/V12.0.0206/csv/DIAG_FNEW5_<timestamp>.csv
```

O CSV deve ter uma linha para cada credenciamento novo gravado e incluir valor, `VarType` e `NumberFormat` de:

- `CRED_ID`
- `EMP_ID`
- `ATIV_ID`
- `COD_ATIV_SERV`
- `STATUS_CRED`
- `ULT_OS`

## Proxima decisao

Depois de gerar o CSV, Mauricio devolve a evidencia ao Codex. Codex produz a analise tecnica em `.hbn/proposals/0016-codex-at2-diagnostico-fnew5.md` e para para auditoria cruzada Opus + Antigravity antes de qualquer AT-3.
