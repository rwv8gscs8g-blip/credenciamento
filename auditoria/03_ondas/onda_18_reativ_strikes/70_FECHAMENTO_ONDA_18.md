---
titulo: 70 - Fechamento Onda 18 - DT_ULT_REATIV e Bloco B
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
autor: Codex CLI - Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 70. Fechamento Onda 18 — DT_ULT_REATIV e Bloco B

## TL;DR

Onda 18 fechou o débito crítico `DT-17-REATIV-STRIKES` e o R1 final
apontado pela auditoria cruzada. A solução adotou dupla informação:
contador histórico total preservado e contador de punição com janela após
`DT_ULT_REATIV`. Gate final para testes manuais da V12.0.0203-rc4:
`VR_20260504_171048` **APROVADO** com sintaxe
`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.

Adendo pós-auditoria cruzada: R1 (`DT-FRENTE1-FORMS-BYPASS-REATIV`)
foi promovido de débito deferido para correção pré-teste manual em
`MICRO30`, gerando o candidato `v12.0.0203-rc4`. O primeiro gate
`VR_20260504_163656` reprovou em `CS_23` porque `ClassificaEmpresa`
ordenava apenas `A:T`; `MICRO30-fix1` corrige a ordenação até a coluna
`U` (`DT_ULT_REATIV`).

## Status final

| Campo | Valor |
|---|---|
| Onda | 18 |
| Track HBN | safe_track |
| Status | FECHADA PARA TESTES MANUAIS |
| Bastão | Codex CLI |
| Build final antes do fechamento rc3 | `f7aa84f+ONDA18.MD18.2-statusbar-hint-treinamento` |
| Build de fechamento | `f7aa84f+v12.0.0203-rc3` |
| Release tag | `v12.0.0203-rc3` |
| Candidato pós-auditoria | `f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u` / `v12.0.0203-rc4` |
| Gate oficial | `CT_ValidarRelease_QuintetoMinimo` |
| Quinteto final Bloco B | `VR_20260504_171048` APROVADO |
| Uso autorizado | Testes manuais formais |
| Uso não autorizado | Produção |

## Microdeltas

| Delta | Tema | Gate |
|---|---|---|
| `MICRO25-fix2` | Schema `DT_ULT_REATIV` | `VR_20260504_054106` APROVADO |
| `MICRO26` | Janela de punição por strikes | `VR_20260504_060256` APROVADO |
| `MICRO27` | `RPT_BUGS_RESOLVIDOS` + mover DT-17 | `VR_20260504_064117` APROVADO |
| `MICRO28` | Statusbar hint Modo Treinamento | `VR_20260504_070441` APROVADO + visual confirmado |
| `MICRO29` | Bump rc3 + fechamento formal | `VR_20260504_075624` APROVADO |
| `MICRO30` | Correção R1 form `Reativa_Empresa` grava `DT_ULT_REATIV` | `VR_20260504_163656` REPROVADO em `CS_23` |
| `MICRO30-fix1` | `ClassificaEmpresa` passa a ordenar `EMPRESAS` até a coluna `U` | `VR_20260504_171048` APROVADO |

## Decisão técnica

| Ponto | Decisão |
|---|---|
| Informação histórica | `ContarStrikesPorEmpresa` preserva histórico total |
| Informação punitiva | `ContarStrikesParaPunicao` conta apenas OS concluída com fechamento posterior a `DT_ULT_REATIV` |
| Reativação | `Svc_Rodizio.Reativar` grava `DT_ULT_REATIV=Now` |
| Legado | Empresa com `DT_ULT_REATIV` vazia usa modo legado |
| Auditoria | `DT-17-REATIV-STRIKES` movido para `RPT_BUGS_RESOLVIDOS` |

## Débitos remanescentes

| ID | Estado |
|---|---|
| `INT-CAD-OS-REF-ORFA` | aberto em `RPT_BUGS_CONHECIDOS` quando a base contém órfãs |
| `DT-FRENTE1-FORMS-BYPASS-REATIV` | corrigido em `MICRO30` + `MICRO30-fix1`; gate `VR_20260504_171048` aprovado |
| `DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT` | deferido |
| `DT-FRENTE1-REATIV-NOOP-ATIVA` | deferido |
| `DT-FRENTE1-BACKFILL-AUDIT` | deferido |
| `DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO` | deferido |

## Evidências

- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_054106.csv`
- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_060256.csv`
- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_064117.csv`
- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_070441.csv`
- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_075624.csv`
- `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv`
- `.hbn/results/0020-exec-onda18-md18-1a-schema.json`
- `.hbn/results/0021-exec-onda18-md18-1b-reativ-strikes.json`
- `.hbn/results/0022-exec-onda18-md18-3-rpt-bugs-resolvidos.json`
- `.hbn/results/0023-exec-onda18-md18-2-statusbar-hint.json`
- `.hbn/results/0024-exec-onda17-18-fechamento-rc3.json`
- `.hbn/results/0026-exec-onda18-micro30-fix1-classifica-empresa-u.json`

## Próximo passo

Iniciar testes manuais formais da `v12.0.0203-rc4`. A versão continua
fora de produção; a linha `V12.0.0204` deve abrir em seguida para revisão
dos débitos técnicos remanescentes e estabilização pública.
