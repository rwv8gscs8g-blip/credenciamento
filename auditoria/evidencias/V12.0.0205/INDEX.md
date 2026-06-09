---
titulo: Índice de Evidências V12.0.0205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-24
---

# Índice de Evidências V12.0.0205

Esta pasta é a fonte canônica das evidências da V12.0.0205.

## Estrutura

```text
auditoria/evidencias/V12.0.0205/
  INDEX.md
  MANIFEST.md
  MANIFESTO.csv
  csv/
  pdf/
  prints/
  intermediarios/
```

## Convenções

- CSV final: `csv/ValidacaoReleaseRVS_V12_0_0205_<VALIDATION_ID>.csv`
- PDF manual: `pdf/V2_VALIDACAO_HUMANA_RVS_V12_0_0205_<VALIDATION_ID>.pdf`
- Prints: `prints/Assinatura_RVS_Aprovada_<timestamp>.png`

## Papel do `MANIFESTO.csv`

`MANIFESTO.csv` é o espelho tabular e legível por ferramentas do manifesto
humano `MANIFEST.md`. Ele deve conter uma linha por artefato de evidência,
com o mesmo `sha256`, caminho e papel registrados no manifesto Markdown.

O `MANIFEST.md` continua sendo a leitura canônica para humanos. O
`MANIFESTO.csv` é mantido para automações, conferência de hash e ingestão por
planilhas ou scripts. Novos PDFs ou prints complementares devem ser incluídos
nos dois arquivos no mesmo delta documental.

## Evidências Registradas

| Artefato | Papel | Status | Observação |
|---|---|---|---|
| [`csv/ValidacaoReleaseVCR_V12_0_0205_VR_20260609_082732.csv`](csv/ValidacaoReleaseVCR_V12_0_0205_VR_20260609_082732.csv) | checkpoint VCR V206 pós-0169/0170 | APROVADO | VCR aprovada; freeze V206 ainda bloqueado por finding visual C16 |
| [`pdf/079_PRE_OS_PROVISORIA_001_C16_PENDENTE.pdf`](pdf/079_PRE_OS_PROVISORIA_001_C16_PENDENTE.pdf) | evidência visual 0169 | FINDING | C16 existe, mas fica pequeno demais para leitura humana |
| [`pdf/080_PRE_OS_PROVISORIA_002_C16_PENDENTE.pdf`](pdf/080_PRE_OS_PROVISORIA_002_C16_PENDENTE.pdf) | evidência visual 0169 | FINDING | C16 existe, mas fica pequeno demais para leitura humana |
| [`pdf/081_OS_001_C16_OS_EXECUCAO.pdf`](pdf/081_OS_001_C16_OS_EXECUCAO.pdf) | evidência visual 0169 | FINDING | C16 existe, mas fica pequeno demais para leitura humana |
| [`pdf/082_AVALIACAO_002_C16_OBS_DISPONIVEL.pdf`](pdf/082_AVALIACAO_002_C16_OBS_DISPONIVEL.pdf) | evidência visual 0169 | FINDING PARCIAL | C16 ilegível; aviso em Observações fica legível |
| [`pdf/083_REL_ENTIDADES_CADASTRADAS.pdf`](pdf/083_REL_ENTIDADES_CADASTRADAS.pdf) | evidência visual relatórios | OK | Relatório tabular sem status operacional esperado |
| [`pdf/084_REL_EMPRESAS_CADASTRADAS_STATUS.pdf`](pdf/084_REL_EMPRESAS_CADASTRADAS_STATUS.pdf) | evidência visual relatórios | OK | Status/disponibilidade/strikes aparecem em relatório |
| [`pdf/085_REL_EMPRESAS_CREDENCIADAS_DISPONIBILIDADE.pdf`](pdf/085_REL_EMPRESAS_CREDENCIADAS_DISPONIBILIDADE.pdf) | evidência visual relatórios | OK | Disponibilidade atual mostra suspensões, Pre-OS pendente e OS em execução |
| [`pdf/086_REL_OS_ABERTAS_STATUS.pdf`](pdf/086_REL_OS_ABERTAS_STATUS.pdf) | evidência visual relatórios | OK | OS aberta mostra disponibilidade e resumo operacional |
| [`pdf/087_REL_EMPRESAS_CREDENCIADAS_SERVICO_STATUS.pdf`](pdf/087_REL_EMPRESAS_CREDENCIADAS_SERVICO_STATUS.pdf) | evidência visual relatórios | OK | Relatório por serviço mostra status e disponibilidade |
| [`pdf/088_REL_OS_POR_EMPRESA_STATUS.pdf`](pdf/088_REL_OS_POR_EMPRESA_STATUS.pdf) | evidência visual relatórios | OK | OS por empresa mostra resumo operacional |
| [`csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv`](csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv) | gate final RVS pós-MICRO61 | APROVADO | Evidência final de freeze V205 |
| [`csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv`](csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv) | gate funcional RVS | APROVADO | Homologação interna V205, preservada como evidência complementar |

## Checkpoint V206 Pos-0169/0170

| Campo | Valor |
|---|---|
| Validation ID | `VR_20260609_082732` |
| Build | `10c1750+ONDA38.2.37-DISPONIBILIDADE-COMPOSTA` |
| Resultado geral | `APROVADO` |
| Sintaxe | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0+PunicoesDias=8/0` |
| Veredito HBN | VCR aprovada; freeze V206 ainda bloqueado ate corrigir ou aceitar explicitamente o finding visual C16 |

## Resultado do Gate RVS

| Campo | Valor |
|---|---|
| Validation ID | `VR_20260523_215637` |
| Build | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Resultado geral | `APROVADO` |
| Sintaxe | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |

## Evidências Complementares

- PDF manual da aba `VALIDACAO_RELEASE` pode ser anexado em `pdf/` como
  evidência humana complementar histórica, sem alterar o freeze V205.
- Print de homologação pode ser arquivado em `prints/` como evidência humana
  complementar, sem alterar a assinatura RVS.
- Hashes dos artefatos manuais devem ser adicionados ao manifesto se forem
  anexados.
