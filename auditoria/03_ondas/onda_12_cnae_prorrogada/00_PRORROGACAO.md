---
titulo: 00 - Onda 12 (CNAE snapshot/dedup) — PRORROGADA
diataxis: status
hbn-track: safe_track
hbn-status: deferred
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada)
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento, com decisão do operador
licenca-target: TPGL-v1.1 (Credenciamento)
---

# Onda 12 (CNAE snapshot/dedup) — PRORROGADA

## Decisão

Em **2026-05-02 06:5x BRT**, após fechamento físico da V12.0.0203-rc1
e tag publicada em GitHub, o operador Luís Maurício Junqueira Zanin
decidiu **prorrogar a Onda 12 e a Onda 13** (ambas no domínio CNAE),
com a justificativa direta:

> "A questão do cnae já está normalizada nesta versão. Não quero
> mexer nesta funcionalidade, vamos deixar para revisão para uma
> versão futura. Vamos marcar como prorrogada."

## Escopo das Ondas prorrogadas

### Onda 12 — Reincorporação Onda 2 (CNAE snapshot/dedup)

Plano original previa reincorporar do `src/vba` para o canônico:

- 3 helpers públicos em `Preencher.bas`: `CnaeSnapshotCadServ`,
  `CnaeContarDuplicatasAtividades`, `CnaeListarSnapshots`
- 1 helper privado em `Preencher.bas`: `CnaeAbaExiste`
- Constante `SHEET_PREFIX_CAD_SERV_SNAP` em `Const_Colunas.bas`
- Suite `TV2_RunCnae` com cenários `CNAE_001..003` em `Teste_V2_Roteiros.bas`
- Opção `[15] CNAE: snapshot, dedup e housekeeping` na `Central_Testes_V2`
- Decisão sobre `Emergencia_CNAE.bas` (4.3KB, só em src/vba)

Documento técnico de referência:
[`auditoria/03_ondas/onda_02_cnae_snapshot/30_TECNICO.md`](../onda_02_cnae_snapshot/30_TECNICO.md)

### Onda 13 — Reincorporação Onda 3 (CNAE dedup automático)

Refinamento da Onda 12 — dedup automático contínuo. Sem escopo
adicional além de CNAE.

## Estado funcional atual

CNAE em produção (V12.0.0203-rc1) opera de forma normalizada
conforme uso operacional declarado pelo operador. Os helpers de
snapshot/dedup do `src/vba` são **incremento documental e de
auditoria**, não correção de regressão. A linha pública atual não
sofre prejuízo funcional pela ausência deles.

## Implicações no roadmap

A renumeração das ondas seguintes **não muda** — Ondas 14-19
continuam com numeração estável conforme roadmap original. Apenas
12 e 13 ficam marcadas como `deferred` no campo `hbn-status` deste
registro.

| Onda | Tema | Status |
|---|---|---|
| 12 | Reincorporação CNAE snapshot/dedup | **PRORROGADA** (esta decisão) |
| 13 | Reincorporação CNAE dedup automático | **PRORROGADA** (mesma justificativa) |
| 14 | Reincorporação Onda 4 (Diag rodízio + form) | a abrir |
| 15 | Phase A.6 — auditoria caso-a-caso divergentes residuais | a abrir |
| 16 | Reincorporação Onda 7 (IDM_*/RDZ_*) | a abrir (alta prioridade) |
| 17 | Reincorporação Onda 8 (heurística zero forms) | a abrir |
| 18 | DT-2 (padronização baterias V1/V2) | a abrir |
| 19 | DT-4 (limpeza semântica vba_import) | a abrir |
| FECH | tag `v12.0.0203` final + push GitHub público | após Ondas 14-19 |

## Drift G7 residual relacionado a CNAE — preservado

Os arquivos `Funcoes.bas` (drift cosmético — 1 linha em branco) e
`Preencher.bas` (drift V2 com hotfixes não-CNAE), bem como
`Central_Testes_V2.bas` opção `[15]` no src/vba, **permanecem em
drift G7 residual** (D1 do roadmap). Não serão sincronizados nesta
linha pública, conforme decisão.

`Emergencia_CNAE.bas` permanece apenas em `src/vba/`, tratado como
ferramenta externa de uso operacional pontual.

## Reabertura futura

Quando uma versão futura (V12.0.0204+ ou V12.0.0210, conforme o
operador definir) reabrir a discussão sobre CNAE, este registro
servirá de ponto de partida. Critério mínimo para reabertura:

1. Operador declara explicitamente intenção de reincorporar.
2. Pre-flight L14 sobre `Preencher.bas` para verificar que hotfixes
   V2 não afetam o domínio CNAE.
3. Readback novo (`.hbn/readbacks/00NN-onda<NN>-cnae-reincorporacao.json`)
   com Q1-QN antes de tocar código.
4. Gate Quarteto Mínimo verde após import.

## Marcadores HBN V2

- 🟡 HBN NEEDS HUMAN DECISION — ressolvido pela decisão registrada
  acima
- ⚪ HBN AUDIT-ONLY — Onda 12-13 ficam em modo auditoria/proposta
  até reabertura

## Versão

- v1.0 — 2026-05-02 — registro inicial da prorrogação por decisão
  do operador.
