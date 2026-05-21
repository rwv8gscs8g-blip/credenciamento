---
titulo: Prompt Consolidacao Final V205 Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Superprompt AF3 — Codex

## Objetivo

Consolidar as auditorias finais do Claude Opus e do Gemini/Antigravity,
executar apenas correções documentais ou de governança realmente necessárias e
preparar a V12.0.0205 para congelamento público no GitHub.

## Documento de saída obrigatório

Grave o relatório final como:

`auditoria/00_status/82_CONSOLIDACAO_FINAL_FREEZE_V205_CODEX.md`

## Prompt para uso

Você é Codex com bastão único de execução da V12.0.0205. Leia os relatórios:

- `auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`
- `auditoria/00_status/81_AUDITORIA_FINAL_DOCS_GITHUB_V205_GEMINI.md`

Leia também os documentos canônicos:

- `README.md`
- `CHANGELOG.md`
- `AGENTS.md`
- `llms.txt`
- `.hbn/relay/INDEX.md`
- `.hbn/results/INDEX.md`
- `obsidian-vault/releases/STATUS-OFICIAL.md`
- `obsidian-vault/releases/V12.0.0205.md`
- `docs/INDEX.md`
- `docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`
- `docs/reference/testes/NOMENCLATURA_BATERIAS_V205.md`
- `docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md`
- `docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`
- `docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md`
- `docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md`
- `auditoria/evidencias/V12.0.0205/INDEX.md`
- `auditoria/evidencias/V12.0.0205/MANIFEST.md`
- `src/vba/App_Release.bas`
- `.github/scripts/verify_release_consistency.sh`

Regras de execução:

1. A grafia canônica é `V12.0.0205`. Não introduza `V12.0.205`.
2. Não altere lógica de negócio, rodízio, avaliação, persistência, OS,
   transações, cálculos ou símbolos VBA internos.
3. Aceite correções documentais, metadados de release, índices, links,
   manifestos, status e prompts.
4. Se os auditores apontarem inconsistência P0/P1, corrija antes do freeze.
5. Se apontarem melhorias P2/P3 que não bloqueiam, registre para V12.0.0206 ou
   V12.0.0207 conforme natureza.
6. Preserve o roadmap:
   - V12.0.0206: estabilização incremental, ajustes manuais, PDF automático,
     pequenos débitos técnicos e melhorias prorrogadas;
   - V12.0.0207: code review profundo, performance, componentização e preparação
     SaaS, salvo decisão posterior.
7. Rode verificações locais possíveis:
   - `bash -n .github/scripts/verify_release_consistency.sh`
   - `git diff --check`
   - validação JSON dos ERPs novos
   - consistência de links/caminhos por busca textual
8. Antes de tag/push, confirme que `App_Release.bas`, `STATUS-OFICIAL.md`,
   `README.md`, `CHANGELOG.md`, release note, evidências e tag `v12.0.0205`
   estão coerentes.

Saída final esperada:

1. Veredito consolidado.
2. Correções aplicadas.
3. Pendências que foram aceitas para V12.0.0206.
4. Pendências que foram movidas para V12.0.0207.
5. Evidências e comandos de verificação.
6. Recomendação clara: congelar, congelar com ressalvas documentais ou não
   congelar.
