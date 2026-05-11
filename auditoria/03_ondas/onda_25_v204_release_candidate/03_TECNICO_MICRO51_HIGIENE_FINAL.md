---
titulo: MICRO51 — Higiene final da V204 rc1
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-10
---

# MICRO51 — Higiene final da V204 rc1

## Decisao

MICRO51 e documental. Ele consolida o estado aprovado do MICRO50 e
prepara a etapa de auditoria/publicacao sem novo pacote V3.

Nao ha alteracao em `src/vba/` nem `local-ai/vba_import/` neste
microdelta. O build validado permanece:

`f7aa84f+v12.0.0204-rc1`

## Evidencia consolidada

| Item | Valor |
|---|---|
| Importador V3 | `mode=Estabilizado`, `dryRun=False`, `M=2`, `F=0`, `err=0`, `skip=0` |
| Gate | `CT_ValidarRelease_SextetoMinimo` |
| Validacao | `VR_20260510_000428` |
| Resultado | `APROVADO` |
| Sintaxe | `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| CSV | `auditoria/evidencias/V12.0.0204/ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv` |

## Debitos aceitos

| ID | Debito | Decisao |
|---|---|---|
| D-MICRO50-CSV-FILENAME | CSV V204 gravado na pasta correta, mas filename ainda usa `V12_0_0203` | Nao bloqueia rc1; corrigir em Onda 26/V205 ou em microdelta especifico se houver nova rodada de gate |
| D-V205-MD24-4 | MD-24.4 `SelecionarEmpresa` com side-effects explicitos | Deferido para V205; nao reabrir MICRO49 |
| D-STRICT-G1-G2-G5 | `glasswing-checks.sh --strict` falha por G1 historico e warnings antigos G2/G5 | Nao bloqueia enquanto G7/G8 estiverem OK; tratar em Onda 26/V205 |

## Checklist de auditoria/publicacao

Antes de promover V204 final:

1. Executar auditoria cruzada final com foco em P0/P1, regressao e
   seguranca preventiva.
2. Confirmar que nao ha P0/P1 aberto em docs de status e bugs conhecidos.
3. Confirmar G7/G8 localmente antes de qualquer pacote adicional.
4. Confirmar que `CHANGELOG.md`, relay, ERPs, roadmap e evidencias
   apontam para `VR_20260510_000428` como gate rc1.
5. Preparar release notes publicas sem expor detalhes internos
   desnecessarios.
6. Apos aprovacao humana, publicar tag/release V12.0.0204.

## Proxima onda recomendada

MICRO52 deve ser a auditoria cruzada final Opus + Antigravity. O gate de
saida e "sem P0/P1"; qualquer achado P0/P1 vira MICRO53 corretivo com
novo gate. Se a auditoria nao trouxer P0/P1, MICRO54 pode cuidar de
tag/push/release e devolucao formal do bastao.
