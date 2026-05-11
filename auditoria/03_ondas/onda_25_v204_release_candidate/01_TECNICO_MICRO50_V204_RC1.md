---
titulo: MICRO50 — V12.0.0204 rc1
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# MICRO50 — V12.0.0204 rc1

## Decisao

MICRO50 transforma a base segura MICRO48 em `v12.0.0204-rc1`.

MICRO49, MICRO49-fix1 e MICRO49-fix2 permanecem reprovados e revertidos.
MD-24.4 fica deferido para V205 porque o ganho de documentar
side-effects de `SelecionarEmpresa` nao compensa o risco observado de
compile crash/build stale na reta de release.

## Escopo

1. Atualizar `App_Release.bas` para o build `f7aa84f+v12.0.0204-rc1`.
2. Atualizar `APP_RELEASE_TAG` para `v12.0.0204-rc1`.
3. Atualizar `APP_RELEASE_TEST_KEY` para `sexteto-v204-rc1-2026-05-09`.
4. Atualizar `Teste_Validacao_Release.bas` para exportar o resumo do
   gate em `auditoria/evidencias/V12.0.0204`.
5. Registrar changelog com o rollback MICRO49 e o debito tecnico V205.

## Sem funcionalidade nova

Este microdelta nao cria regra de negocio, UI nova, servico novo ou fluxo
novo. E um bump de release candidate e correcao de evidencia. A validacao
correspondente e o Sexteto minimo ja vigente.

## Gate esperado

Sexteto minimo:

`V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Resultado pos-import

MICRO50 foi aprovado pelo operador em 2026-05-10.

- Importador V3: `mode=Estabilizado`, `dryRun=False`, `M=2`, `F=0`,
  `err=0`, `skip=0`.
- Build validado: `f7aa84f+v12.0.0204-rc1`.
- Sexteto: `VR_20260510_000428`, resultado `APROVADO`.
- Sintaxe: `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- CSV localizado em
  `auditoria/evidencias/V12.0.0204/ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv`.

Observacao: o diretorio V204 esta correto. O prefixo `V12_0_0203` no
nome do arquivo permanece como debito P2 de nomenclatura/evidencia para
MICRO51 ou Onda 26.

## Debitos deferidos

1. MD-24.4 `SelecionarEmpresa` side-effects: deferido para V205.
2. `glasswing-checks.sh --strict`: G1 historico e warnings G2/G5 serao
   tratados em Onda 26/V205, sem bloquear o rc1 enquanto G7/G8 estiverem OK.
