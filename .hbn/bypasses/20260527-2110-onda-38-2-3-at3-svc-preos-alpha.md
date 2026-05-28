---
titulo: Bypass alpha AT-3 Svc_PreOS
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Bypass alpha AT-3 Svc_PreOS

## Contexto

A regra da sequencia V206 blindava `Svc_*`, mas Mauricio pre-aprovou a excecao alfa para `Svc_PreOS.EmitirPreOS`: aplicar somente `NumberFormat="@"` antes das gravacoes textuais nas linhas de emissao de PRE_OS.

## Escopo aplicado

- Arquivo: `src/vba/Svc_PreOS.bas`.
- Funcao: `EmitirPreOS`.
- Alteracao: `NumberFormat="@"` antes da gravacao de `COL_PREOS_ID`, `COL_PREOS_ENT_ID`, `COL_PREOS_COD_SERV`, `COL_PREOS_EMP_ID`, `COL_PREOS_ATIV_ID` e `COL_PREOS_OS_ID`.
- Sem alteracao no fluxo de rodizio, validacao, auditoria, status, datas ou valores monetarios.

## Decisao de IDs acima de 999

Tres digitos seguem como largura minima, nao maxima. A correcao nao trunca `1000` para `000`; ela apenas impede que o Excel converta `001` para `1`.

## Legado

Mauricio confirmou que os dados atuais do workbook sao descartaveis, entao nao sera feito backfill de linhas PRE_OS antigas neste AT-3.
