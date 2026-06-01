---
titulo: Onda 38.2.5 — UI de Regras de Negocio
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Onda 38.2.5 — UI de Regras de Negocio

## Objetivo

Resolver BL-1 do parecer `0024`: restaurar a UI de parametros de regras de negocio no form `Configuracao_Inicial` e impedir que a ausencia de controles seja mascarada por `On Error Resume Next`.

## Semantica dos campos

- `TxtNotaCorte`: media abaixo deste valor conta 1 strike.
- `TxtMaxStrikes`: quantidade de strikes que dispara a suspensao.
- `TxtDiasSuspensao`: duracao da suspensao quando o limite de strikes e atingido.
- `PR_Val_OS`: prazo de validade da Pre-OS em dias.
- `TP_Valor`: quantidade de recusas que dispara a suspensao.
- `TxtMesesSuspensao`: duracao da suspensao por recusas, em meses, usando a logica existente de `DT_FIM_SUSP`.

Exemplo: nota abaixo de 5, apos 3 strikes, punicao de 90 dias.

## Implementacao

- O `.frx` exportado por Mauricio em `local-ai/incoming/vba-forms/` foi validado com `strings` e contem os controles canonicos: `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`, `PR_Val_OS`, `TP_Valor` e `TxtMesesSuspensao`.
- O binario foi promovido para `src/vba/Configuracao_Inicial.frx` e `local-ai/vba_import/002-formularios/Configuracao_Inicial.frx`.
- O code-behind em `src/vba/Configuracao_Inicial.frm` foi preservado e ajustado para exigir os controles em runtime. Se qualquer controle faltar, a persistencia falha com erro explicito.
- `PR_Val_OS`, `TP_Valor` e `TxtMesesSuspensao` sao persistidos em `COL_CFG_PRAZO_PREOS`, `COL_CFG_MAX_RECUSAS` e `COL_CFG_MESES_SUSPENSAO`, sem alterar `Svc_Rodizio`.
- O `.frm` exportado pelo VBE nao foi promovido como codigo porque continha code-behind anterior e apagaria a instrumentacao desta onda.
- A suite `TV2_RunPersistenciaPainel` foi adicionada em `Teste_V2_Roteiros.bas` para validar existencia dos controles e persistencia em `CONFIG`.

## Arquivos do Delta

- `src/vba/Configuracao_Inicial.frm`
- `src/vba/Configuracao_Inicial.frx`
- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/App_Release.bas`
- `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.frm`
- `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`
- `local-ai/vba_import/002-formularios/Configuracao_Inicial.frx`
- `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas`
- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_5_UI_REGRAS_NEGOCIO.txt`

## Gates

1. D1: diff de escopo restrito aos arquivos do readback 0121.
2. D2: inventario do `.frx` confirma os controles canonicos.
3. Importador V3 delta `ONDA38_2_5_UI_REGRAS_NEGOCIO` executa com `M=2 | F=1 | err=0`.
4. VBE `Depurar > Compilar VBAProject` passa limpo.
5. D3: `TV2_RunPersistenciaPainel` passa com `OK=2 | FALHA=0 | MANUAL=0`.
6. RVS ou dirigido final nao regride apos o delta.

## Status

Pacote importado e compilado no workbook por Mauricio. `TV2_RunPersistenciaPainel` aprovado em 2026-05-31 16:49 com `OK=2 | FALHA=0 | MANUAL=0`.

A onda fecha o gate dirigido de BL-1, mas nao declara freeze V206.
