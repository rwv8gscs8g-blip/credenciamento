---
titulo: RVS ou dirigido final - Onda 38.2.6
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# RVS ou dirigido final - Onda 38.2.6

## Decisao de gate

O gate minimo desta onda e dirigido: import V3, compile limpo e
`TV2_RunImpressaoIntegridade`.

RVS completo segue recomendado antes de qualquer freeze V206, mas esta onda
nao declara freeze.

## Evidencia do operador

Gate dirigido concluido em 2026-05-31:

- Importador V3: `modo=Estabilizado | dryRun=Falso | M=3 | F=1 | err=0 | skip=0`.
- Backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260531_215848-V3-FULL`.
- Compile VBAProject: limpo, conforme relato do operador.
- `TV2_RunImpressaoIntegridade`: execucao `TV2_20260531_215928`, `OK=6 | FALHA=0 | MANUAL=0`, sem CSV de falhas.

Resultado: gate dirigido da Onda 38.2.6 aprovado. RVS completo permanece
recomendado antes de qualquer freeze V206, mas este documento nao declara
freeze.
