---
titulo: 70 - Fechamento Onda 17 - Test-first e Quinteto
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
autor: Codex CLI - Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 70. Fechamento Onda 17 — Test-first e Quinteto

## TL;DR

Onda 17 fechada operacionalmente em 2026-05-04. O Bloco A entregou
`TV2_RunIntegridadeBase`, `RPT_BUGS_CONHECIDOS`, `CT_ValidarRelease_QuintetoMinimo`
e renumeração da Central V2. Gate final do Bloco A:
`VR_20260503_234443` **APROVADO** com sintaxe
`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0`.

## Status final

| Campo | Valor |
|---|---|
| Onda | 17 |
| Track HBN | safe_track |
| Status | FECHADA |
| Bastão no fechamento formal | Codex CLI |
| Build Bloco A | `f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17` |
| Gate oficial novo | `CT_ValidarRelease_QuintetoMinimo` |
| Quinteto Bloco A | `VR_20260503_234443` APROVADO |
| Quarteto regressão | `VR_20260504_000004` APROVADO |
| Readback | `.hbn/readbacks/0019-onda17-bloco-a.json` |
| ERP | `.hbn/results/0019-exec-onda17-bloco-a.json` |

## Entregas

| Item | Resultado |
|---|---|
| MD-17.2 | `TV2_RunIntegridadeBase` + `RPT_BUGS_CONHECIDOS` |
| MD-17.3 | `CT_ValidarRelease_QuintetoMinimo` + Central V2 com Quinteto oficial |
| MD-17.4 | Quinteto + Quarteto verdes simultaneamente |
| Débito deslocado | Statusbar hint movido para Onda 18 MD-18.2 |

## Débitos transferidos para Onda 18

| ID | Estado final |
|---|---|
| DT-17-REATIV-STRIKES | Resolvido na Onda 18 MD-18.1a/1b e movido para `RPT_BUGS_RESOLVIDOS` |
| DT-MD17.1.e-STATUSBAR-HINT | Resolvido na Onda 18 MD-18.2 |

## Evidências

- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260503_234443.csv`
- `auditoria/03_ondas/onda_17_test_first/14_PROCEDIMENTO_IMPORT_BLOCO_A.md`
- `.hbn/results/0019-exec-onda17-bloco-a.json`

## Próximo passo

Onda 18 fechada em documento próprio:
`auditoria/03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md`.
