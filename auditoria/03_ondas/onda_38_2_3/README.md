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

GATE-A1 e GATE-A2 aprovados por auditoria cruzada. AT-3 em validacao iterativa para corrigir F-NEW6 em `PRE_OS` / `Repo_PreOS`.

## Entregas

| Gate | Entrega | Status |
|---|---|---|
| A1 | Corrigir gerador `.code-only.txt` para preservar declarações module-level/`WithEvents`; regenerar `AAD-Cadastro_Servico.code-only.txt` | aprovado |
| A2 | Instrumentar `Credencia_Empresa` com `ATIVAR_DIAG_FNEW5`, ressincronizar `AAI-Credencia_Empresa.code-only.txt` e interpretar CSV real | aprovado |
| A3 | Preservar IDs textuais na escrita/leitura de `PRE_OS` em `Svc_PreOS` e `Repo_PreOS` | importado; compile bloqueado no primeiro delta |
| A3 Fix1 | Wrapper público `RepoPreOS_BuscarPorId` para destravar compile em `Teste_V2_Roteiros` | importado; compile aprovado |
| A3 Fix2 | Ajustar `DIAG_PREOS_INTEGRITY` para comparar expectativa canonica contra celula bruta de `PRE_OS` | importado; compile aprovado; revelou `EMP_PREOS_BRUTO=2/3` |
| A3 Fix3 | Normalizar IDs antes da gravacao textual em `Svc_PreOS.EmitirPreOS` | pacote pronto para import |

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

## Próxima ação

Mauricio importa o pacote AT-3 Fix3 pelo V3, compila o projeto no VBE e roda `TV2_RunRodizioStrikesEndToEnd`. Se passar, Codex consolida o readback parcial AT-3 para auditoria cruzada GATE-A3.
