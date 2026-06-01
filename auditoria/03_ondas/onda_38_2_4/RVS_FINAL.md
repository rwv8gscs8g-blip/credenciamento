---
titulo: RVS Final — Onda 38.2.4
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# RVS Final — Onda 38.2.4

## Resultado

Status: RVS APROVADO POS-FIX5; D5 MANUAL APROVADO; ONDA 38.2.4 PRONTA PARA AUDITORIA CRUZADA CURTA.

Execucao reportada por Mauricio apos import Fase 1, compile Fase 1, import Fase 2, compile Fase 2 e `TV2_RunIntegridadeEstado` aprovado.

## Evidencia

- Validacao ID: `VR_20260530_112945`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-F2-FORMS`
- Data/hora do fechamento: `30/05/2026 11:45:56`
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260530_112945.csv`
- SHA-256 do CSV: `139cdd66ed4393f2920cd4e35a5f65bef3a0ec17cfcc7f2be9055a7b73dc80d1`

## Sintaxe Validada

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Linhas do CSV

| Etapa | Execucao | OK | Falha | Manual | Status |
|---|---:|---:|---:|---:|---|
| V1_RAPIDA | `BO-20260530-112948` | 171 | 0 | 0 | OK |
| V2_SMOKE | `TV2_20260530_113638` | 34 | 0 | 4 | OK |
| V2_CANONICO | `TV2_20260530_113812` | 24 | 0 | 0 | OK |
| V2_E2E_STRIKES | `TV2_20260530_114148` | 76 | 0 | 0 | OK |
| V2_INTEGRIDADE_BASE | `TV2_20260530_114534` | 4 | 0 | 1 | OK |
| V2_ONDA23_ADV | `ADVERSARIAL_UI:TV2_20260530_114539|TRANSACAO_INTERRUPT:TV2_20260530_114545|BOUNDARY_DATES:TV2_20260530_114551` | 27 | 0 | 0 | OK |
| GERAL | - | - | - | - | APROVADO |

## Interpretacao

O RVS confirma que a importacao final da Onda 38.2.4 nao introduziu regressao detectada pelas baterias automatizadas atuais.

Este resultado nao libera freeze V206 por si so. Pelo arbitro `0024`, o RVS e necessario, mas nao suficiente: ainda e obrigatoria a revalidacao manual dirigida dos itens L43 cobertos por esta onda e a auditoria cruzada pos-onda.

## RVS Fix1

Novo RVS reportado por Mauricio apos Fix1:

- Validacao ID: `VR_20260530_145839`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX1-ENTIDADE`
- Resultado: APROVADO
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260530_145839.csv`
- SHA-256 do CSV: `9d9ab332ded7dc745ad7710ad5e497dcc64ea835d6acf5aa17d3f6b3fd76556a`

Sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Observacao: apesar do RVS aprovado, a suite dirigida `TV2_RunIntegridadeEstado` falhou no Fix1 por falso positivo textual (`CS_EST_04`, token `ActiveCell` em comentario historico). O Fix2 remove esse token do form importavel e deve ser validado com `TV2_RunIntegridadeEstado`.

## RVS Fix3

Novo RVS reportado por Mauricio apos Fix3:

- Validacao ID: `VR_20260530_164422`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX3-LAST-ROW-TABLE`
- Resultado: APROVADO
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260530_164422.csv`
- SHA-256 do CSV: `1f84abd83125a31926224ca837c9ff90c79ae719883a3850fc0756733173e6e7`
- Bytes: `1385`

Sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Observacao: o RVS Fix3 aprovado foi seguido por reteste manual D4 reprovado. Foi possivel editar diretamente `ENTIDADE`, `ENTIDADE_INATIVOS` e `PRE_OS`. Portanto o RVS segue necessario, mas nao suficiente, e a Onda 38.2.4 permanece bloqueada ate o Fix4 passar tambem no reteste manual pos-RVS.

## RVS Fix4

Novo RVS reportado por Mauricio apos Fix4:

- Validacao ID: `VR_20260530_210350`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS`
- Resultado: APROVADO
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260530_210350.csv`
- SHA-256 do CSV: `807613ac5481455a8a2cccbeac81f93b32be9ae99d6dda21d6cdf0ef3958de57`
- Bytes: `1371`

Sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Linhas do CSV:

| Etapa | Execucao | OK | Falha | Manual | Status |
|---|---:|---:|---:|---:|---|
| V1_RAPIDA | `BO-20260530-210350` | 171 | 0 | 0 | OK |
| V2_SMOKE | `TV2_20260530_213122` | 34 | 0 | 4 | OK |
| V2_CANONICO | `TV2_20260530_213608` | 24 | 0 | 0 | OK |
| V2_E2E_STRIKES | `TV2_20260530_214411` | 76 | 0 | 0 | OK |
| V2_INTEGRIDADE_BASE | `TV2_20260530_214909` | 4 | 0 | 1 | OK |
| V2_ONDA23_ADV | `ADVERSARIAL_UI:TV2_20260530_214913|TRANSACAO_INTERRUPT:TV2_20260530_214921|BOUNDARY_DATES:TV2_20260530_214927` | 27 | 0 | 0 | OK |
| GERAL | - | - | - | - | APROVADO |

Observacao: Mauricio reportou duracao operacional aproximada de 45 minutos para o RVS completo. Isso reforca a necessidade de uma fase pre-freeze de melhoria de testes: manter o RVS completo como gate de release, mas introduzir gates modulares mais rapidos para iteracoes de estabilizacao.

## RVS Fix5

Novo RVS reportado por Mauricio apos Fix5 e reteste manual D5:

- Validacao ID: `VR_20260531_092609`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`
- Resultado: APROVADO
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv`
- SHA-256 do CSV: `ee0bbd9840cce362592aa856ee9224b921ff8467fdc8aea8dc1e5ee240c48056`
- Bytes: `1371`

Sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Linhas do CSV:

| Etapa | Execucao | OK | Falha | Manual | Status |
|---|---:|---:|---:|---:|---|
| V1_RAPIDA | `BO-20260531-092609` | 171 | 0 | 0 | OK |
| V2_SMOKE | `TV2_20260531_105736` | 34 | 0 | 4 | OK |
| V2_CANONICO | `TV2_20260531_105959` | 24 | 0 | 0 | OK |
| V2_E2E_STRIKES | `TV2_20260531_110504` | 76 | 0 | 0 | OK |
| V2_INTEGRIDADE_BASE | `TV2_20260531_111116` | 4 | 0 | 1 | OK |
| V2_ONDA23_ADV | `ADVERSARIAL_UI:TV2_20260531_111201|TRANSACAO_INTERRUPT:TV2_20260531_111407|BOUNDARY_DATES:TV2_20260531_111513` | 27 | 0 | 0 | OK |
| GERAL | - | - | - | - | APROVADO |

## Interpretacao Pos-Fix5

O RVS pos-Fix5 confirma que a limpeza/protecao de objetos em abas criticas nao introduziu regressao detectada pelas baterias automatizadas atuais.

Mauricio tambem reportou reteste manual D5 aprovado: `ENTIDADE_INATIVOS` sem objeto residual, edicao direta bloqueada em planilhas criticas e tentativa de colar imagem bloqueada corretamente.

Em 2026-05-31 12:22, Mauricio executou o reteste `ENT_MAN_23` pos-RVS no build salvo. A janela imediata confirmou `ThisWorkbook.Path = \\Mac\Home\Projetos\Credenciamento`, `GetBuildImportado() = fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS` e horario `2026-05-31 12:22:07`. As telas reportadas confirmam bloqueio habilitado em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS`, `EMPRESAS` e aba de empresas inativas, incluindo bloqueio de colagem/alteracao.

Com isso, a Onda 38.2.4 deixa de estar bloqueada por D5/RVS/ENT_MAN_23 e pode fechar o ERP 0120. Este resultado ainda nao declara freeze V206.
