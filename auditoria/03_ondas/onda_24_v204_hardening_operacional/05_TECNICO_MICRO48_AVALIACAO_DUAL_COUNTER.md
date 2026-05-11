---
titulo: Onda 24 MICRO48 - Avaliacao Dual Counter
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 24 MICRO48 - Avaliacao Dual Counter

## Objetivo

Tornar auditavel a diferenca entre o historico bruto de strikes e o
contador punitivo usado apos reativacao. A avaliacao com nota baixa agora
registra ambos no `AUDIT_LOG`.

## Estado de Entrada

| Gate | Evidencia | Resultado |
|---|---|---:|
| `TV2_RunSmoke False` | `TV2_20260509_150814` | `33/0/4` |
| Sexteto | `VR_20260509_163840` | `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Build de entrada | `f7aa84f+ONDA24.MD24.2-config-invalida-audit` | aprovado pelo operador |

## Entregas

| Arquivo | Papel |
|---|---|
| `src/vba/Svc_Avaliacao.bas` | registra `STRIKES_TOTAL` e `STRIKES_PUNICAO` na auditoria de nota baixa |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `CS_REATIV_AUDIT_DUAL_COUNTER` em E2E Strikes |
| `src/vba/Teste_V2_Engine.bas` | registra catalogo e roteiro V2 do novo assert |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO48.txt` | manifesto importavel do microdelta |

## Decisoes

1. O token legado `STRIKES=x/max` foi preservado para compatibilidade.
2. O campo novo `STRIKES_TOTAL` representa o historico bruto, sem janela.
3. O campo novo `STRIKES_PUNICAO` representa a janela efetiva para suspensao.
4. O evento inclui `DUAL_COUNTER=SIM` e `EMP_ID=...` para facilitar busca no
   `AUDIT_LOG`.
5. A funcionalidade nova tem teste no mesmo microdelta:
   `CS_REATIV_AUDIT_DUAL_COUNTER`.

## Contrato de Teste

`TV2_RunRodizioStrikesEndToEnd False` sobe de 75 para 76 asserts:

| Cenario | Objetivo |
|---|---|
| `CS_REATIV_AUDIT_DUAL_COUNTER` | validar `AUDIT_LOG` com `DUAL_COUNTER=SIM`, `STRIKES_TOTAL>=4` e `STRIKES_PUNICAO=1` apos reativacao |

O Sexteto passa a esperar:

`V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Riscos Residuais

| Risco | Mitigacao |
|---|---|
| A auditoria aumenta texto no campo `DEPOIS` | Mantem tokens compactos e preserva o token legado `STRIKES=` |
| Falha ao contar historico total apos avaliacao salva | Retorna `TResult` explicito, `OS_JA_AVALIADA=SIM`, e registra falha contextual |
| Regressao no comportamento punitivo | Teste usa a mesma sequencia de reativacao e janela ja validada por DT-17 |

## Validacao Local

1. `src/vba` sincronizado para `local-ai/vba_import` via `publicar_vba_import_v2.py apply`.
2. `publicar_vba_import_v2.py check` verde para 53 arquivos.
3. `shasum` pareado validado para os 4 arquivos importaveis.
4. Manifesto MICRO48 criado com `M=4 | F=0`.

## Validacao Esperada no Workbook

1. Importador V3: `M=4 | F=0 | err=0 | skip=0`.
2. Compilacao manual limpa no VBE.
3. `TV2_RunRodizioStrikesEndToEnd False` retorna `OK=76 | FALHA=0 | MANUAL=0`.
4. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`.
