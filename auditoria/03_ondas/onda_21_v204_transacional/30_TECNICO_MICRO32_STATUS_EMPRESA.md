---
titulo: 30 - Tecnico MICRO32 Onda 21 V204 Status Empresa Estruturado
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO32 - Onda 21 V204

## 1. Objetivo

Fechar a primeira raiz de sucesso falso da Onda 21: `GravarStatusEmpresa`
era `Sub`, engolia falhas internas e deixava `Suspender`/`Reativar`
declararem sucesso mesmo quando a escrita em `EMPRESAS` podia nao ter
persistido.

## 2. Mudancas

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_Empresa.bas` | `GravarStatusEmpresa` passa a retornar `TResult`, valida linha, preparo da aba, restore de protecao e persistencia dos campos gravados. |
| `src/vba/Svc_Rodizio.bas` | `Suspender` e `ReativarLinhaEmpresa` consomem o `TResult` e retornam falha se a gravacao nao persistir. |
| `src/vba/Svc_Rodizio.bas` | `AvancarFila` deixa de mascarar falha de `Suspender` apos recusa punivel e registra evento transacional de falha. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.1-status-empresa-result`. |

## 3. Risco fechado

| Debito | Estado apos MICRO32 |
|---|---|
| `DT-V204-GRAVARSTATUS-RESULT` | Fechado no nucleo `Repo_Empresa` + `Svc_Rodizio`. |
| Sucesso falso em `Suspender` | Mitigado: gravacao e releitura precisam confirmar status suspenso. |
| Sucesso falso em `ReativarLinhaEmpresa` | Mitigado: falha de gravacao vira `TResult.sucesso=False`. |
| Recusa punivel com falha de suspensao | Mitigado: `AvancarFila` nao retorna sucesso quando `Suspender` falha. |

## 4. Escopo adiado

1. `AvaliarOS` ainda sera tratado em MD-21.2/MD-21.3 para propagar falha de
   `Suspender` e de `AvancarFila` no fechamento de OS.
2. `ContarStrikes*` com resultado estruturado fica para MD-21.4.
3. Rollback completo de `EmitirOS`/`PRE_OS` fica para MD-21.5.
4. Guard de aninhamento de `Svc_Transacao` fica para MD-21.6.

## 5. Validacao esperada

Comportamento nominal deve permanecer identico ao Quinteto verde da Onda 20.
Como a mudanca atua em caminhos de erro, o gate esperado continua:

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## 6. Trilha de exploracao

1. CSV `TesteV2_SMOKE_Falhas_TV2_20260505_150246.csv` analisado; falha era
   drift de `.code-only.txt`, nao regressao funcional.
2. `local-ai/scripts/publicar_vba_import_v2.sh --check` confirmou G7 verde
   apos ressincronizacao do espelho.
3. Roadmap Onda 21 lido em
   `auditoria/03_ondas/onda_20_v204_roadmaps_preparatorios/02_ROADMAP_ONDA_21_TRANSACIONAL.md`.
4. Chamadores de `GravarStatusEmpresa` mapeados com `rg`.
