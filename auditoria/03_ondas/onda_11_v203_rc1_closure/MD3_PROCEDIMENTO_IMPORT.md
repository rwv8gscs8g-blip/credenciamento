---
titulo: Procedimento MD-3 — Quarteto release gate (DT-1) — Onda 11 V12.0.0203-rc1 closure
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-3 — Procedimento de import e validacao (Quarteto release gate)

## O que entrega

Adiciona o gate `CT_ValidarRelease_QuartetoMinimo` ao orquestrador
`Teste_Validacao_Release`, sem mexer no `CT_ValidarRelease_TrioMinimo`
existente. Resolve o debito tecnico DT-1 (release gate honesty):
release nao pode ser declarada verde sem rodar a suite E2E de strikes.

| Campo | Valor |
|---|---|
| Onda | 11 (V12.0.0203-rc1 closure) |
| Microdelta | MD-3 |
| Build label | `f7aa84f+ONDA11.MD3-DT1-quarteto-release-gate-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO10.txt` |
| Arquivos modificados | `ABH-Teste_Validacao_Release.bas` + `AAX-App_Release.bas` |
| Espelho src/vba | sincronizado (drift G7 cosmetico residual resolvido) |
| Risco | Baixo — adicao isolada; Trio intocado |

## Pre-flight L14 (ja cumprido pela IA antes de gerar codigo)

Reuso de assinaturas publicas estaveis do projeto:

- V1: `BA_SetModoExecucaoVisual`, `RunBateriaOficial` (Teste_Bateria_Oficial)
- V2: `TV2_RunSmoke`, `TV2_RunCanonicoFundacao`, `TV2_RunRodizioStrikesEndToEnd`,
  `TV2_ExecucaoAtualId` (Teste_V2_Engine + Teste_V2_Roteiros)
- Helpers internos do modulo: `VR_PrepararSheet`, `VR_RegistrarEtapaV1`,
  `VR_RegistrarEtapaV2`, `VR_LinhaResumoIA`, `VR_BuildImportado`,
  `VR_PastaSaida`, `VR_CsvLinha`, `VR_CsvCell`, `VR_TextoCurto`

Nenhum `Public Type` novo (G8 nao acionado). Nenhuma macro descartavel.
Sem heuristica em form (G3 nao aplica). G6 enforced (codigo VBA novo
foi escrito em arquivo, nao em chat).

## Layout esperado em `VALIDACAO_RELEASE` apos rodar Quarteto

| Linha | Conteudo |
|---|---|
| 1 | "VALIDACAO RELEASE - TRIO MINIMO" (header reusado; Trio + Quarteto compartilham sheet) |
| 2-4 | VALIDACAO_ID, BUILD, RELEASE_ALVO |
| 6 | Cabecalho da tabela (12 colunas) |
| 7 | V1_RAPIDA |
| 8 | V2_SMOKE |
| 9 | V2_CANONICO |
| 10 | V2_E2E_STRIKES |
| 12 | RESULTADO_GERAL = APROVADO/REPROVADO |
| 13 | "BLOCO_COPIAVEL_PARA_IA" |
| 14 | bloco merge (multi-linha) |

Bloco copiavel inclui linha:

```
SINTAXE=V1=A/F+V2_Smoke=A/F+V2_Canonica=A/F+E2E_Strikes=A/F
```

CSV exportado em `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuarteto_V12_0_0203_<id>.csv`.

## Passos no Excel

1. Abrir `V12-202-Z/PlanilhaCredenciamento-Homologacao-V3.xlsm`.
2. Confirmar build atual no Imediato:
   - `?GetBuildImportado` → deve retornar `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental`
3. Importar pacote MICRO10 via Importador V3:
   - `ImportarPacoteV3_Delta "MICRO10", "f7aa84f+ONDA11.MD3-DT1-quarteto-release-gate-incremental"`
   - Confirmar 2 modulos atualizados: `Teste_Validacao_Release.bas`, `App_Release.bas`
4. Compile manual (`Debug → Compile VBAProject`) — esperado: limpo.
5. Validar build label apos import:
   - `?GetBuildImportado` → deve retornar `f7aa84f+ONDA11.MD3-DT1-quarteto-release-gate-incremental`
6. Regressao Trio (gate honesty: Trio nao pode ter regredido):
   - `CT_ValidarRelease_TrioMinimo`
   - Esperado: `VR_<id>` APROVADO com V1=171/0, V2_SMOKE=14/0, V2_CANONICO=20/0
7. Novo gate Quarteto:
   - `CT_ValidarRelease_QuartetoMinimo`
   - Esperado: `VR_<id>` APROVADO com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`
   - CSV em `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuarteto_V12_0_0203_<id>.csv`
8. Salvar workbook como `V12-202-AA-onda11-md3` (ou convencao local).
9. Reportar de volta: VR_id do Quarteto + sintaxe + status REPROVADO/APROVADO.

## Gate

MD-3 fica **APROVADO** quando:

- [ ] Compile manual limpo apos import
- [ ] `CT_ValidarRelease_TrioMinimo` continua 171/0+14/0+20/0 (regressao zero)
- [ ] `CT_ValidarRelease_QuartetoMinimo` retorna 171/0+14/0+20/0+64/0
- [ ] Build label persistido = `f7aa84f+ONDA11.MD3-DT1-quarteto-release-gate-incremental`
- [ ] CSV Quarteto em `auditoria/evidencias/V12.0.0203/`
- [ ] Workbook salvo como ancora pos-MD3

## Rollback (se gate falhar)

```bash
git diff src/vba/Teste_Validacao_Release.bas src/vba/App_Release.bas
git checkout src/vba/Teste_Validacao_Release.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/ABH-Teste_Validacao_Release.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO10.txt
```

Workbook ancora estavel para restauracao: `V12-202-Z` (Onda 11 MD-2.3).

## Apos APROVADO

Prosseguir para MD-4 (mover CSVs antigos da raiz para
`auditoria/04_evidencias/V12.0.0203/`) + MD-5 (rc1 bump + CHANGELOG +
PHAGOCYTOSIS L16-L18+M7 + ERP + fechamento Onda 11). Sequencia
operacional Q3 do hearback: MD-3 sozinho primeiro, MD-4+MD-5 juntos
depois.

## Versao

- v1.0 — 2026-05-02 — procedimento inicial MD-3.
