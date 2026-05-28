---
titulo: Onda 38.2.3 — estabilizacao emergencial V206
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Onda 38.2.3 — estabilizacao emergencial V206

## Estado

GATE-A1, GATE-A2 e GATE-A3 aprovados por auditoria cruzada. GATE-A4 Fase 1 e Fase 2 importaram, compilaram e passaram RVS completo. Pendente GATE-USO-PROLONGADO L43 e RVS final pos-uso.

## Entregas

| Gate | Entrega | Status |
|---|---|---|
| A1 | Corrigir gerador `.code-only.txt` para preservar declarações module-level/`WithEvents`; regenerar `AAD-Cadastro_Servico.code-only.txt` | aprovado |
| A2 | Instrumentar `Credencia_Empresa` com `ATIVAR_DIAG_FNEW5`, ressincronizar `AAI-Credencia_Empresa.code-only.txt` e interpretar CSV real | aprovado |
| A3 | Preservar IDs textuais na escrita/leitura de `PRE_OS` em `Svc_PreOS` e `Repo_PreOS` | aprovado por auditoria cruzada |
| A3 Fix1 | Wrapper público `RepoPreOS_BuscarPorId` para destravar compile em `Teste_V2_Roteiros` | importado; compile aprovado |
| A3 Fix2 | Ajustar `DIAG_PREOS_INTEGRITY` para comparar expectativa canonica contra celula bruta de `PRE_OS` | importado; compile aprovado; revelou `EMP_PREOS_BRUTO=2/3` |
| A3 Fix3 | Normalizar IDs antes da gravacao textual em `Svc_PreOS.EmitirPreOS` | importado; compile aprovado; `TV2_RunRodizioStrikesEndToEnd` OK=76/FALHA=0 |
| A4 H1 | Desligar diagnostico temporario F-NEW5 antes de import de release | entregue no pacote A4 |
| A4 F1 | Manifesto L41 fase 1 — modulos | importado; compile aprovado; RVS `VR_20260528_063131` aprovado |
| A4 F2 | Manifesto L41 fase 2 — forms/code-only | importado; compile aprovado; RVS `VR_20260528_090314` aprovado |
| A4 L43 | Uso prolongado 30 min | pendente operador |

## Evidências AT-1

- Proposta técnica: `.hbn/proposals/0013-codex-at1-gerador-codeonly.md`
- Auditoria Opus: `.hbn/proposals/0014-opus-auditoria-gate-a1-onda-38-2-3.md`
- Auditoria Antigravity: `.hbn/proposals/0015-antigravity-auditoria-gate-a1-onda-38-2-3.md`
- Readback: `.hbn/readbacks/0114-rb-onda-38-2-3-at1-gerador-codeonly.json`
- Hearback: `.hbn/hearbacks/0114-rb-onda-38-2-3-at1-gerador-codeonly-confirmed.json`

## Evidências AT-2

- Readback: `.hbn/readbacks/0114-rb-onda-38-2-3-at2-diagnostico-fnew5.json`
- Hearback: `.hbn/hearbacks/0114-rb-onda-38-2-3-at2-diagnostico-fnew5-confirmed.json`
- Manifesto delta: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT2_DIAG_FNEW5.txt`
- Proposta Codex: `.hbn/proposals/0016-codex-at2-diagnostico-fnew5.md`
- Auditorias: `.hbn/proposals/0017-opus-auditoria-gate-a2-onda-38-2-3.md`, `.hbn/proposals/0018-antigravity-auditoria-gate-a2-onda-38-2-3.md`, `.hbn/proposals/0019-opus-reauditoria-gate-a2-onda-38-2-3.md`
- CSVs: `auditoria/evidencias/V12.0.0206/csv/DIAG_FNEW5_20260527_200546.csv` e `auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_202518.csv`

## Evidências AT-3

- Readback: `.hbn/readbacks/0114-rb-onda-38-2-3-at3-svc-preos.json`
- Hearback: `.hbn/hearbacks/0114-rb-onda-38-2-3-at3-svc-preos-confirmed.json`
- Bypass alfa: `.hbn/bypasses/20260527-2110-onda-38-2-3-at3-svc-preos-alpha.md`
- Manifesto delta: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_PREOS_IDS.txt`
- Procedimento: `auditoria/03_ondas/onda_38_2_3/AT3_PROCEDIMENTO_PREOS_IDS.md`
- Validação estática: `auditoria/03_ondas/onda_38_2_3/AT3_VALIDACAO_ESTATICA_PREOS_IDS.md`

## Evidências AT-3 Fix1

- Readback: `.hbn/readbacks/0115-rb-onda-38-2-3-at3-fix1-compile-preos-wrapper.json`
- Hearback: `.hbn/hearbacks/0115-rb-onda-38-2-3-at3-fix1-compile-preos-wrapper-confirmed.json`
- Manifesto delta: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX1_COMPILE_PREOS_WRAPPER.txt`
- Técnico: `auditoria/03_ondas/onda_38_2_3/AT3_FIX1_COMPILE_PREOS_WRAPPER.md`

## Evidências AT-3 Fix2

- Readback: `.hbn/readbacks/0116-rb-onda-38-2-3-at3-fix2-preos-integrity-assert.json`
- Hearback: `.hbn/hearbacks/0116-rb-onda-38-2-3-at3-fix2-preos-integrity-assert-confirmed.json`
- Manifesto delta: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX2_PREOS_INTEGRITY_ASSERT.txt`
- Técnico: `auditoria/03_ondas/onda_38_2_3/AT3_FIX2_PREOS_INTEGRITY_ASSERT.md`
- CSV de falha preservado: `auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_213936.csv`

## Evidências AT-3 Fix3

- Readback: `.hbn/readbacks/0117-rb-onda-38-2-3-at3-fix3-preos-write-normalizacao.json`
- Hearback: `.hbn/hearbacks/0117-rb-onda-38-2-3-at3-fix3-preos-write-normalizacao-confirmed.json`
- Manifesto delta: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX3_PREOS_WRITE_NORMALIZACAO.txt`
- Técnico: `auditoria/03_ondas/onda_38_2_3/AT3_FIX3_PREOS_WRITE_NORMALIZACAO.md`
- CSV de falha preservado: `auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_220557.csv`
- ERP: `.hbn/results/0117-exec-onda-38-2-3-at3-fix3-preos-write-normalizacao.json`
- Auditoria Opus: `.hbn/proposals/0020-opus-auditoria-gate-a3-onda-38-2-3.md`
- Auditoria Antigravity: `.hbn/proposals/0021-antigravity-auditoria-gate-a3-onda-38-2-3.md`

## Evidências GATE-A4

- Readback: `.hbn/readbacks/0118-rb-onda-38-2-3-gate-a4-import-uso-prolongado.json`
- Hearback: `.hbn/hearbacks/0118-rb-onda-38-2-3-gate-a4-import-uso-prolongado-confirmed.json`
- Consolidacao GATE-A3: `auditoria/03_ondas/onda_38_2_3/GATE_A3_CONSOLIDACAO_AUDITORIA.md`
- Diagnostico F-NEW5 desligado: `auditoria/03_ondas/onda_38_2_3/GATE_A4_H1_DIAG_FNEW5_OFF.md`
- Procedimento L41: `auditoria/03_ondas/onda_38_2_3/IMPORT_PROCEDURE_2_FASES.md`
- Uso prolongado L43: `auditoria/03_ondas/onda_38_2_3/GATE_USO_PROLONGADO_REPORT.md`
- Manifesto F1: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_A4_F1_MODULOS.txt`
- Manifesto F2: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_A4_F2_FORMS.txt`
- Resultado F1/F2: `auditoria/03_ondas/onda_38_2_3/GATE_A4_FASES12_RESULTADO.md`
- CSV F1: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260528_063131.csv`
- CSV F2: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260528_090314.csv`
- Output lock L45 para auditoria A4: `.hbn/audits/20260527-2345-gate-a4-output-lock.md`

## Próxima ação

Mauricio executa uso operacional por pelo menos 30 minutos, registra incidentes ou sucesso, e roda RVS completo final pos-uso. Se passar, Codex consolida GATE-A4 para auditoria cruzada Opus + Antigravity usando output lock L45.
