---
titulo: Prompt Planejamento V12.0.0206 — Gemini via Antigravity
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Superprompt V206-P2 — Gemini 3.5 via Antigravity

## Objetivo

Executar uma revisão adversarial do planejamento da V12.0.0206, procurando
inconsistências, escopo escondido, riscos de regressão, caminhos quebrados,
duplicidade documental e mudanças que deveriam ser adiadas para V12.0.0207.

## Documento de Saída Obrigatório

Entregue o conteúdo como:

```text
auditoria/00_status/89_AUDITORIA_ADVERSARIAL_PLANEJAMENTO_V206_GEMINI.md
```

Não edite arquivos nem implemente código. A execução física cabe ao Codex.

## Leia Antes

- `README.md`
- `AGENTS.md`
- `llms.txt`
- `.hbn/relay/INDEX.md`
- `.hbn/results/INDEX.md`
- `obsidian-vault/00-DASHBOARD.md`
- `obsidian-vault/releases/V12.0.0205.md`
- `auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md`
- `auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md`
- `docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md`
- `docs/how-to/COMO_GERAR_DOSSIE_V205.md`
- `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`
- `auditoria/evidencias/V12.0.0205/MANIFEST.md`

## Foco Adversarial

- Verificar se o roadmap V206 tenta fazer refatoração disfarçada.
- Verificar se alguma pendência de V207 foi puxada cedo demais.
- Verificar se o PDF automático é especificável e testável sem quebrar o Gate
  RVS.
- Verificar se os caminhos `docs/`, `doc/`, `auditoria/evidencias/` e `.hbn/`
  estão adequados.
- Verificar se a grafia canônica `V12.0.0206` está preservada.
- Verificar se há risco de o Importador V3 induzir o operador ao gate legado.

## Formato da Resposta

Use esta estrutura:

1. Veredito adversarial.
2. Achados P0/P1/P2/P3.
3. Escopo que deve permanecer em V12.0.0206.
4. Escopo que deve ir para V12.0.0207.
5. Correções obrigatórias antes de codificar.
6. Ordem sugerida de ondas.
7. Recomendação final.

