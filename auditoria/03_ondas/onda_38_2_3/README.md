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

GATE-A1 / AT-1 aprovado por Opus + Antigravity. AT-2 em implementacao Codex.

## Entregas

| Gate | Entrega | Status |
|---|---|---|
| A1 | Corrigir gerador `.code-only.txt` para preservar declarações module-level/`WithEvents`; regenerar `AAD-Cadastro_Servico.code-only.txt` | aprovado |
| A2 | Instrumentar `Credencia_Empresa` com `ATIVAR_DIAG_FNEW5`, ressincronizar `AAI-Credencia_Empresa.code-only.txt` e gerar manifesto delta para import V3 | em implementacao |

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

## Próxima ação

Codex fecha o pacote AT-2. Em seguida Mauricio importa pelo V3, compila o projeto no VBE, reproduz F-NEW5 e devolve o CSV `DIAG_FNEW5_<timestamp>.csv`.
