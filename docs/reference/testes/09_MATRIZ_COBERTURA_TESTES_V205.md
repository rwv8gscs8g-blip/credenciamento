---
titulo: Matriz de Cobertura de Testes V205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Matriz de Cobertura de Testes — V12.0.0205

Esta matriz mantém a cobertura funcional da V204 e atualiza a nomenclatura
pública para a V205.

## Gate Funcional

| Bloco | Resultado esperado | Papel |
|---|---:|---|
| V1 | `171/0` | regressão ampla |
| V2 Smoke | `34/0` | fumaça e integridade mínima |
| V2 Canônica | `24/0` | fluxos canônicos |
| E2E Strikes | `76/0` | penalidade, reativação e janela punitiva |
| IntegridadeBase | `4/0` | varredura passiva de integridade |
| Onda23Adv | `27/0` | UI adversarial, transação e datas |

Sintaxe esperada:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Cobertura Por Regra de Negócio

| Regra | Cobertura automática | Cobertura humana | Status V205 |
|---|---|---|---|
| RN-01 | RVS, SRC, V2 Canônica, IntegridadeBase | Jornada V205 | Sem mudança semântica |
| RN-02 | RVS, V2 Canônica, E2E Strikes | Jornada V205 | Sem mudança semântica |
| RN-03 | RVS, V2 Canônica, E2E Strikes, IntegridadeBase | Jornada V205 | Sem mudança semântica |
| RN-04 | RVS, E2E Strikes | Jornada V205 + `AUDIT_LOG` | Sem mudança semântica |
| RN-05 | RVS, V2 Canônica, E2E Strikes | Jornada V205 | Sem mudança semântica |
| RN-06 | RVS, V2 Canônica, IntegridadeBase | Jornada V205 | Sem mudança semântica |
| RN-07 | RVS, E2E Strikes, Smoke `MIG_008` | Jornada V205 | Sem mudança semântica |
| RN-08 | RVS, E2E Strikes, Boundary Dates | Jornada V205 | Sem mudança semântica |
| RN-09 | RVS, E2E Strikes, Dual Counter | Jornada V205 | Sem mudança semântica |
| RN-10 | RVS, E2E Strikes, Boundary Dates | Jornada V205 | Sem mudança semântica |
| RN-11 | RVS, SRC, V1, V2, E2E | Jornada V205 | Sem mudança semântica |
| RN-12 | RVS, IntegridadeBase | Revisão de relatório | Sem mudança semântica |
| RN-13 | RVS, Onda23Adv `ADVERSARIAL_UI` | Observação de UI | Sem mudança semântica |
| RN-14 | RVS, Onda23Adv `TRANSACAO_INTERRUPT` | Não exigido | Sem mudança semântica |
| RN-15 | RVS, Onda23Adv `BOUNDARY_DATES` | Não exigido | Sem mudança semântica |
| RN-16 | RVS, Smoke `MIG_009` | PDF/print manual da Jornada V205 | Sem mudança semântica |
| RN-17 | RVS pela interface | Checklist humano + dossiê | Sem mudança semântica |

## Gate Complementar V205

| Item | Evidência |
|---|---|
| Nomenclatura RVS/SRC/BRL aplicada | crosswalk + UI/docs |
| Prefixo CSV V205 | `ValidacaoReleaseRVS_V12_0_0205_*.csv` |
| Dossiê Markdown | `docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md` |
| Fallback PDF manual | PDF e hash no manifesto |
| CI/CD atualizado | `.github/scripts/verify_release_consistency.sh` passa |

## Regra de Bloqueio

Alteração de contador funcional sem justificativa P0 aprovada reprova a V205.
