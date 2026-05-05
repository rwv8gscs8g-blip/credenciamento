---
titulo: 04 - Roadmap Onda 23 V204 Baterias Adversariais
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Onda 23 V204 - Baterias adversariais e cobertura combinatoria

## 1. Objetivo

Converter as lacunas das auditorias 64/65 em baterias formais e
documentadas.

## 2. Entregas

| MD | Entrega | Cobre |
|---|---|---|
| MD-23.1 | `TV2_RunAdversarial_UI` | reentrada e duplo clique |
| MD-23.2 | `TV2_RunTransaction_Interrupt` | rollback e falha parcial |
| MD-23.3 | `TV2_RunBoundary_Dates` | datas vazias, invalidas, iguais e futuras |
| MD-23.4 | Sexteto de validacao | Quinteto + adversarial |
| MD-23.5 | Matriz `regra -> cenario -> assert -> evidencia` | auditabilidade humana |

## 3. Criterio de aceite

1. Sexteto verde.
2. Cada P0/P1 fechado possui pelo menos um cenario automatizado.
3. Documentacao de testes lista o que cobre e o que permanece fora.
