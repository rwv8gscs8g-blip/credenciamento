---
titulo: Prompt Planejamento V12.0.0206 — Claude Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Superprompt V206-P1 — Claude Opus

## Objetivo

Executar uma auditoria estratégica, positiva e crítica do planejamento da
V12.0.0206. O objetivo é propor uma sequência realista de ondas incrementais
que preserve a estabilidade da V12.0.0205 e prepare a V12.0.0207.

## Documento de Saída Obrigatório

Entregue o conteúdo como:

```text
auditoria/00_status/88_AUDITORIA_PLANEJAMENTO_V206_CLAUDE_OPUS.md
```

Não edite arquivos nem implemente código. A execução física cabe ao Codex.

## Leia Antes

- `README.md`
- `CHANGELOG.md`
- `AGENTS.md`
- `llms.txt`
- `.hbn/relay/INDEX.md`
- `obsidian-vault/releases/STATUS-OFICIAL.md`
- `obsidian-vault/releases/V12.0.0205.md`
- `auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md`
- `auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md`
- `auditoria/00_status/82_CONSOLIDACAO_FINAL_FREEZE_V205_CODEX.md`
- `auditoria/evidencias/V12.0.0205/INDEX.md`
- `docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`
- `docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md`

## Perguntas

1. O roadmap preliminar da V12.0.0206 está adequadamente limitado a uma release
   incremental?
2. Quais ondas devem ser P0/P1 para gerar valor sem reabrir risco funcional?
3. Quais itens devem ser explicitamente adiados para V12.0.0207?
4. O PDF automático deve entrar como primeira onda de código ou após higiene
   documental?
5. Há alguma inconsistência de versão, numeração, paths ou protocolo HBN?
6. A documentação atual ainda serve como vitrine positiva após o freeze V205?

## Formato da Resposta

Use esta estrutura:

1. Veredito executivo.
2. Pontos fortes da base V12.0.0205.
3. Avaliação do roadmap V12.0.0206.
4. Ondas recomendadas em ordem.
5. Riscos e bloqueios.
6. Itens para V12.0.0207.
7. Recomendação final ao Codex.

Classifique achados em P0/P1/P2/P3.

