---
titulo: ONDA 10 — Procedimento Microdelta 1.5 (TV2_RunStrikes suite + opcao [14] - ULTIMO da Onda 10)
natureza-do-documento: procedimento operacional + fechamento de onda
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 66. Procedimento Microdelta 1.5 — Suite TV2_RunStrikes + Central [14]

> **Microdelta 1.5 e o ULTIMO da Onda 10.** Adiciona a infraestrutura
> de teste para a regra de strikes (7 cenarios CS_AVAL_001..007) e
> opcao [14] na Central V2 para invocar a suite. Apos verde, RODAMOS
> O TRIO MINIMO COMPLETO (~12 min) - primeiro e unico trio da Onda 10.
> Apos trio verde, Onda 10 fecha e workbook vira ancora V12-202-T-onda10.

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Microdelta 1.3 | APROVADO (TV2_20260501_194706 SMOKE 14/0) |
| Build label atual | `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental` |
| Manifesto delta | `000-MANIFESTO-V3-DELTA-MICRO05.txt` (criado) |
| Espelho `ABG-Teste_V2_Roteiros.bas` | atualizado (1378 → 1631 linhas, +253 — TV2_RunStrikes + 2 helpers apenddos) |
| Espelho `ABE-Central_Testes_V2.bas` | atualizado (102 → ~110 linhas — opcao [14] + Case 14 + CT2_ExecutarStrikes) |
| Espelho `AAX-App_Release.bas` | bumpado para MICRO05 |

## 1. Comando de import (fix4 — suite end-to-end aprovada)

> **HISTORICO COMPLETO:**
> - fix1: removida qualificacao `.ContarStrikesPorEmpresa` (L10).
> - fix2: defaults `GetMaxStrikes` 3→1 e `GetDiasSuspensaoStrike` 90→0 (L11).
> - fix3: removido filtro `mediaVal > 0` em `ContarStrikesPorEmpresa` (L12 — corrige BO_330d).
> - **fix4 (atual):** SUITE END-TO-END nova. Deletados `TV2_RunStrikes`/
>   `TV2_SetStrikesConfig`/`TV2_ConsumirStrikeEmpresa`. Adicionada
>   `TV2_RunRodizioStrikesEndToEnd` que usa cenario isolado (ATIV=999,
>   SERV=001, EMP1/2/3 dedicados) e exercita strikes via rodizio
>   natural sem manipular fila. 11 etapas (A-J) com ~14 asserts
>   intermediarios. Central V2 opcao [14] passa a chamar a nova suite.
>   Idempotente por design.

```
ImportarPacoteV3_Delta "MICRO05", "f7aa84f+ONDA10.MICRO05-Strikes-Suite-fix4-EndToEnd-incremental"
```

Esperado: M=5 (Repo_Avaliacao + Util_Config + Central_Testes_V2 + Teste_V2_Roteiros + App_Release).

Esperado em IMPORT_LOG_V3:
- BACKUP OK
- BUMP_BUILD_LABEL OK
- GRUPO_INICIO MICRO05 (itens=3)
- MODULO_OK Teste_V2_Roteiros (~1631 linhas)
- MODULO_OK Central_Testes_V2 (~110 linhas)
- MODULO_OK App_Release (~171 linhas)
- MsgBox: M=3 | F=0 | err=0 | skip=0

## 2. Compile manual

VBE → Depurar → Compilar VBAProject — passa limpo.

## 3. Smoke - via infraestrutura oficial

```
TV2_RunSmoke
```

Esperado: `OK=14 | FALHA=0 | MANUAL=0` (~30s). Nenhuma regressao.

## 4. **Validacao da suite NOVA** — TV2_RunRodizioStrikesEndToEnd

```
TV2_RunRodizioStrikesEndToEnd
```

Esperado: `OK=14 (aprox) | FALHA=0` (~2 min). 11 etapas (A-J) com
asserts intermediarios todos verdes:

- ETAPA C (3 asserts por volta + 1 final): EMP1 acumula 3 strikes -> SUSPENDE
- ETAPA D: rodizio pula EMP1 corretamente
- ETAPA E (3 asserts + 1 final): EMP2 acumula 3 strikes -> SUSPENDE
- ETAPA E.2: EMP3 sozinha mantem 0 strikes
- ETAPA F: EMP1 reativa via DT_FIM_SUSP vencido + EMP3 ganha 1 strike
- ETAPA H: EMP3 atinge 3 strikes (1 de F + 2 de H) -> SUSPENDE; EMP2 reativa em paralelo
- ETAPA H.2: notas altas, sem novos strikes
- ETAPA J: ciclo final com todas regularizadas, sistema funcional

> Alternativa: pelo menu, opcao [14] na Central V2 chama a mesma suite.

Se algum assert falhar, capture o `CS_E2E_*` que falhou + esperado/obtido,
reporte.

## 5. Trio mínimo completo - FECHAMENTO da Onda 10

> **Politica oficializada:** trio mínimo so e rodado UMA VEZ ao final
> de cada onda completa. Microdelta 1.5 e o ultimo de Onda 10, logo
> agora roda o trio.

```
CT_ValidarRelease_TrioMinimo
```

Aguarde ~12 minutos.

Esperado: V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0 — APROVADO.

## 6. Promocao para ancora V12-202-T-onda10

Apos trio verde:

6.1. **NAO salve sobre V12-202-S.** Use Save As para criar nova ancora.

6.2. Em uma pasta nova `V12-202-T-onda10/` no diretorio do projeto:
- File → Save As → `V12-202-T-onda10/PlanilhaCredenciamento-Homologacao.xlsm`

6.3. Apos salvar, reporte para Claude.

## 7. Reportar fechamento da Onda 10

```
ONDA 10 FECHADA. V12-202-T-onda10 salvo. Build f7aa84f+ONDA10.MICRO05-Strikes-Suite-incremental.
TV2_RunSmoke 14/0. TV2_RunStrikes 7/0. Trio 171/0+14/0+20/0 APROVADO.
Pode prosseguir para Onda 11 (CNAE).
```

## 8. Em caso de problemas

| Sintoma | Acao |
|---|---|
| Compile falha em TV2_E2E_* ou TV2_RunRodizioStrikesEndToEnd | Capturar erro + linha + reportar |
| CS_E2E_C_VOLTA_1 falha (1 strike) | Regressao em fix3 (`ContarStrikesPorEmpresa`) — verificar AAN-Repo_Avaliacao |
| CS_E2E_C_FINAL_SUSP falha (3 strikes nao suspende) | Regressao em fix2 (`GetMaxStrikes`) — verificar AAD-Util_Config defaults |
| CS_E2E_F_REATIVA1 falha (EMP1 nao reativou) | Verificar `SelecionarEmpresa` em `Svc_Rodizio` — pode ser bug em mecanismo de reativacao |
| V1 BO_330d ainda falha | fix3 nao foi importado — verificar IMPORT_LOG_V3 |
| Trio quebra em V2 Canonica CS_14 | Regressao critica em integracao Microdelta 1.3 — restore + reportar |

## 9. Checklist de fechamento Onda 10

- [ ] `ImportarPacoteV3_Delta "MICRO05", "...fix4-EndToEnd-incremental"` executou (M=5)
- [ ] IMPORT_LOG_V3: BACKUP + BUMP + 5x MODULO_OK
- [ ] Compile manual passou limpo
- [ ] TV2_RunSmoke 14/0 (sem regressao)
- [ ] **TV2_RunRodizioStrikesEndToEnd ~14/0** (suite NOVA aprovada — opcao [14] da Central V2)
- [ ] **Trio minimo 171/0+14/0+20/0 APROVADO** (V1 BO_330d corrigido pelo fix3)
- [ ] `?GetBuildImportado` mostra `f7aa84f+ONDA10.MICRO05-Strikes-Suite-fix4-EndToEnd-incremental`
- [ ] Workbook salvo como `V12-202-T-onda10/PlanilhaCredenciamento-Homologacao.xlsm`
- [ ] Reportei fechamento da Onda 10 no chat
