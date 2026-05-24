---
titulo: Técnico Onda 31 V206 — Higiene Documental e Evidências
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Onda 31 — Higiene Documental e Evidências

## Contexto

A Onda 31 abre a execução da V12.0.0206 após hearback humano aprovando o
roadmap consolidado. A V12.0.0205 permanece congelada em `v12.0.0205`, commit
`f24e535`, com evidência final `VR_20260523_215637`.

## Escopo Executado

- Criação do readback HBN `0079-onda31-v206-higiene-documental-evidencias`.
- Link scan dos documentos canônicos de retomada V206 e evidências V205.
- Frontmatter scan dos documentos V206/V205 relevantes.
- Conferência de hash do `MANIFESTO.csv` V205 contra os CSVs reais.
- Inicialização da pasta de evidências V206.
- Decisão documental sobre o papel de `MANIFESTO.csv`.
- Decisão sobre espelho físico das Ondas 26-30 em `auditoria/03_ondas/`.

## Resultado do Link Scan

O primeiro scan encontrou quatro links Markdown quebrados em
`.hbn/relay/INDEX.md`, todos apontando para specs históricas em
`local-ai/Time_AI/2026-05-02-V203-fechamento/` que não estão presentes neste
worktree público/controlado.

Decisão da Onda 31: esses caminhos permanecem citados como paths históricos em
texto monoespaçado, mas deixam de ser links Markdown. Assim o relay continua
preservando a trilha histórica sem prometer navegação para arquivos ausentes.

## Resultado do Frontmatter Scan

Os documentos V206/V205 diretamente escaneados abrem com frontmatter YAML:

- `83_READBACK_ABERTURA_V206_CODEX.md`
- `88_AUDITORIA_PLANEJAMENTO_V206_CLAUDE_OPUS.md`
- `89_AUDITORIA_ADVERSARIAL_PLANEJAMENTO_V206_GEMINI.md`
- `90_CONSOLIDACAO_ROADMAP_V206_CODEX.md`
- `91_PROMPT_RETOMADA_CODEX_V206_NOVO_CHAT.md`
- `31_ROADMAP_V206_PRELIMINAR.md`
- `32_ROADMAP_V206_CONSOLIDADO.md`
- `auditoria/evidencias/V12.0.0205/INDEX.md`
- `auditoria/evidencias/V12.0.0205/MANIFEST.md`
- `obsidian-vault/releases/V12.0.0205.md`
- `docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`
- `docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`

## Decisão Sobre `MANIFESTO.csv`

`MANIFESTO.csv` fica mantido como espelho tabular do `MANIFEST.md`, com uma
linha por artefato e os mesmos campos de hash, caminho, build e papel.

Critério de manutenção:

- `MANIFEST.md` é a leitura canônica para humanos.
- `MANIFESTO.csv` é a leitura canônica para automações e planilhas.
- Qualquer novo PDF, print ou CSV deve atualizar os dois arquivos no mesmo
  delta documental.

## Decisão Sobre Ondas 26-30 Físicas

As Ondas 26-29 da V205 e a Onda 30 de planejamento V206 já estão preservadas
em ERPs HBN, status, roadmaps e evidências. A Onda 31 decidiu não retrocriar
pastas físicas para essas ondas em `auditoria/03_ondas/`, porque isso
duplicaria documentação histórica sem acrescentar nova evidência.

A partir da V12.0.0206, novas ondas executivas voltam a ter pasta física em
`auditoria/03_ondas/` quando houver entrega técnica própria. A Onda 31 inaugura
esse padrão com este documento.

## Limites Observados

- Nenhum código VBA foi alterado.
- `src/vba/` não foi tocado.
- `local-ai/vba_import/` não foi tocado.
- `doc/` não foi tocado.
- RN-01 a RN-17 não foram alteradas.
- Os contadores RVS não foram alterados.
- Nenhum teste de PDF foi incluído no RVS.

## Validações Locais

| Validação | Resultado |
|---|---|
| Link scan dos documentos canônicos | `BROKEN_LINKS 0` |
| Frontmatter scan dos documentos tocados | OK |
| Hash de `MANIFESTO.csv` V205 | 2/2 artefatos existentes com `sha256` conferindo |
| `MANIFESTO.csv` V206 | Cabeçalho válido, sem evidência própria ainda |
| JSON HBN do readback 0079 | válido |
| `.github/scripts/verify_release_consistency.sh` | release V12.0.0205 consistente |
| `git diff --check` | sem problemas |
| Diff em `src/vba`, `local-ai/vba_import` e `doc` | vazio |
