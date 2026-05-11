---
titulo: Readback HBN — Onda 24 Rollback MICRO49 para MICRO48
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Readback HBN — Onda 24 Rollback MICRO49 para MICRO48

## Identificacao

| Campo | Valor |
|---|---|
| Frente | Frente 1 — Credenciamento V12.0.0204 |
| Executor | Codex CLI |
| Onda | Onda 24 — hardening operacional |
| Acao | Rollback formal do pacote MICRO49 para MICRO48 |
| Status | READBACK ENTREGUE — aguardando hearback humano |
| Track | safe_track |
| Hearback necessario | `confirmed` antes de qualquer edicao em codigo ou pacote importavel |

## Objetivo

Executar rollback formal do pacote MICRO49, incluindo MICRO49-fix1 e
MICRO49-fix2, para o ultimo ponto verde operacional:
MICRO48 / MD-24.3.

Build alvo:

`f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`

MD-24.4 fica deferido. Nao ha MICRO49-fix3 planejado nesta retomada.

## Contexto aceito

1. MICRO48 / MD-24.3 foi aprovado pelo operador com E2E
   `TV2_20260509_172616` e Sexteto `VR_20260509_173629`.
2. MICRO49, MICRO49-fix1 e MICRO49-fix2 foram reprovados por fechamento
   do Excel durante compile ou por build stale apos recovery.
3. Apos recovery do incidente MICRO49-fix2, o workbook retornou
   `GetBuildImportado = f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`.
4. O RCA Codex identificou G7 violado no pacote atual por divergencia em
   `App_Release.bas` entre `src/vba` e `local-ai/vba_import`.
5. O operador e o Opus arquiteto useHBN ratificaram rollback formal para
   MICRO48 antes de continuar a esteira rumo ao MICRO50.

## Diff planejado

| Arquivo | Acao planejada |
|---|---|
| `src/vba/Svc_Rodizio.bas` | Reverter qualquer comentario ou linha introduzida por MICRO49, MICRO49-fix1 ou MICRO49-fix2. |
| `src/vba/App_Release.bas` | Restaurar build, carimbo e linhas finais ao estado MICRO48. |
| `src/vba/Teste_V2_Engine.bas` | Reverter apenas alteracoes pertinentes ao MICRO49, se ainda existirem. |
| `src/vba/Teste_V2_Roteiros.bas` | Reverter apenas alteracoes pertinentes ao MICRO49, se ainda existirem. |
| `local-ai/vba_import/001-modulo/AAP-Svc_Rodizio.bas` | Alinhar ao `src/vba/Svc_Rodizio.bas` apos rollback. |
| `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | Alinhar ao `src/vba/App_Release.bas` apos rollback. |
| `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` | Alinhar ao `src/vba/Teste_V2_Engine.bas` apos rollback. |
| `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | Alinhar ao `src/vba/Teste_V2_Roteiros.bas` apos rollback. |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ROLLBACK-MICRO49-PARA-MICRO48.txt` | Criar manifesto operacional de rollback, se aprovado no hearback. |
| `.hbn/results/0055-exec-onda24-md24-rollback-micro48.json` | Registrar ERP apos execucao e evidencias, se aprovado no hearback. |

Regra de fonte: `src/vba` continua sendo fonte de verdade; o pacote
`local-ai/vba_import` sera apenas espelho com prefixos.

## Asserts pos-rollback

| Assert | Esperado |
|---|---|
| Glasswing G7 | `local-ai/scripts/glasswing-checks.sh G7` retorna OK. |
| Glasswing strict | `local-ai/scripts/glasswing-checks.sh --strict` sem bloqueio G7/G8. |
| Build no VBE | `GetBuildImportado` retorna `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`. |
| Smoke | `TV2_RunSmoke False` retorna `OK=33 | FALHA=0 | MANUAL=4`. |
| Sexteto minimo | Sintaxe canonica de `VR_20260509_173629`: `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`. |

## Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| R1 — esquecer arquivo divergente nao mapeado | Antes de declarar rollback completo, rodar comparacao de diff contra a base de referencia e revisar todos os arquivos em `src/vba` e `local-ai/vba_import` tocados pela esteira MICRO49. |
| R2 — confundir teste verde do build anterior com aprovacao do rollback | O primeiro gate humano apos import sera conferir `GetBuildImportado` antes de aceitar Smoke ou Sexteto como evidencia. |
| R3 — reabrir MD-24.4 durante estabilizacao | MD-24.4 fica explicitamente deferido; nao ha fix3 planejado nesta execucao. |
| R4 — drift fonte/espelho persistir | A execucao so pode ser declarada pronta se G7 retornar OK. |

## Rollback do rollback

Se o operador mudar a decisao no futuro, o caminho de retomada sera abrir
novo readback para MICRO49-fix3 cumulativo, partindo de MICRO48 verde e
reintroduzindo MD-24.4 em microdelta minimo, com teste ou justificativa
formal conforme regra 0010. Esse caminho nao esta planejado agora.

## Gate operador previsto

Depois do hearback e da execucao do rollback, o operador deve:

1. Importar o pacote rollback no Excel.
2. Rodar compile manual em `VBE > Depurar > Compilar VBAProject`.
3. Confirmar que o Excel nao fecha durante o compile.
4. Conferir `GetBuildImportado`.
5. Rodar Smoke.
6. Rodar Sexteto minimo.

Se qualquer passo falhar, a execucao volta para readback/RCA antes de
qualquer novo microdelta.

## Proximo passo

PARAR e aguardar hearback humano explicito antes da Etapa 2.
