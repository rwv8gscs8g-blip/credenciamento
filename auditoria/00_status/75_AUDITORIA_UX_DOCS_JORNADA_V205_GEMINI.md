---
titulo: Auditoria UX Docs Jornada V205 Gemini
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
autor: Gemini 3.5
origem: Superprompt 3
---

# Auditoria UX, Documentação e Jornada V12.0.0205 — Gemini

Este documento registra a síntese canônica do Superprompt 3.

## Veredito

SP1 e SP2 estão aptos para execução física, com um P0 de tooling confirmado:
`.github/scripts/verify_release_consistency.sh` estava defasado em relação à
linha V204/V205 e precisava ser corrigido no início da Onda 26.

## Strings críticas

| String | Regra V205 |
|---|---|
| `VALIDACAO_RELEASE` | nome físico da aba preservado |
| `CT_ValidarRelease_SextetoMinimo` | símbolo VBA preservado |
| `ValidacaoReleaseSexteto_` | histórico preservado; V205 passa a gerar prefixo novo |
| `Sexteto Mínimo` | label pode virar nome profissional |
| `APP_RELEASE_TEST_KEY` | atualizar apenas no fechamento V205 |

## Nomenclatura recomendada

| Nome histórico | Nome oficial V205 | Sigla |
|---|---|---|
| Sexteto Mínimo | Gate de Validação de Release | RVS |
| Quinteto | Suíte de Regressão Consolidada | SRC |
| Quarteto Direto | Bateria Rápida Legada | BRL |

## Regras de execução

- Não renomear símbolos VBA na V205.
- Não automatizar PDF por VBA na V205.
- Criar fallback manual de PDF com hash no manifesto.
- O Dossiê Markdown é fonte; DOCX/PDF são artefatos derivados.
- README e índices devem apontar a V205 como linha vigente apenas no fechamento.

## Documento de saída recomendado

O resultado deste SP3 alimenta o readback Codex, o roadmap V205 e os documentos
`NOMENCLATURA_BATERIAS_V205.md`, `ESPEC_PDF_AUTOMATICO_V205.md`,
`JORNADA_VALIDACAO_HUMANA_V205.md` e `DOSSIE_RELEASE_V12_0_0205.md`.
