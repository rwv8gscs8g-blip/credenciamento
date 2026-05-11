---
titulo: Onda 23 MICRO44 - Matriz de Rastreabilidade V204
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 23 MICRO44 - Matriz de Rastreabilidade V204

## Objetivo

Consolidar a ligacao `regra -> cenario -> assert -> evidencia` antes do
MD-23.5, onde o gate `Sexteto` passa a usar as suites adversariais da Onda
23 como sexta dimensao de release.

## Estado de Entrada

| Item | Evidencia |
|---|---|
| MICRO41 | `ADVERSARIAL_UI=10/0/0`, `TV2_20260507_022218`, Quinteto `VR_20260507_022355` |
| MICRO42 | `TRANSACAO_INTERRUPT=6/0/0`, `TV2_20260507_042944`, Quinteto `VR_20260507_043052` |
| MICRO43 | `BOUNDARY_DATES=9/0/0`, `TV2_20260509_020108`, Quinteto `VR_20260507_083959` |
| Quinteto vigente | `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0` |

## Entregas

| Arquivo | Papel |
|---|---|
| `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md` | matriz principal para humanos e IAs |
| `docs/reference/testes/INDEX.md` | indice atualizado da area de testes |
| `.hbn/results/0046-exec-onda23-md23-3-boundary-dates-micro43.json` | registro de aprovacao do MICRO43 |
| `.hbn/readbacks/0047-onda23-md23-4-matriz-rastreabilidade-micro44.json` | readback do MICRO44 |
| `.hbn/results/0047-exec-onda23-md23-4-matriz-rastreabilidade-micro44.json` | ERP do MICRO44 |

## Decisoes

1. MICRO44 e documental, sem importacao V3 e sem bump de `App_Release`.
2. A sexta dimensao recomendada para o Sexteto e o bloco adversarial Onda
   23, agregando `ADVERSARIAL_UI`, `TRANSACAO_INTERRUPT` e
   `BOUNDARY_DATES`.
3. A regra permanente "funcionalidade nova exige teste" fica refletida na
   matriz como contrato de manutencao.
4. A higiene documental recorrente fica marcada como gate antes de fase,
   onda, release e bastao.

## Proximo Microdelta

`MICRO45 / MD-23.5` deve implementar o gate `Sexteto`, preservando o
Quinteto como compatibilidade e adicionando a dimensao adversarial da Onda
23.
