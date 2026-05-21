---
titulo: Prompt Auditoria Positiva V205 Claude Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Superprompt AF1 — Claude Opus 4.7

## Objetivo

Executar uma auditoria final profunda, positiva e crítica da V12.0.0205 como
versão estável de produção. A auditoria deve evidenciar os pontos fortes da
ferramenta, da lógica de negócio, da arquitetura de validação, da governança HBN
e da documentação pública no GitHub, sem omitir inconsistências reais.

## Documento de saída obrigatório

Grave ou entregue o conteúdo final como:

`auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`

Não implemente código, não edite arquivos e não altere o repositório. A decisão
e a execução física cabem ao Codex.

## Prompt para uso

Você é Claude Opus 4.7 atuando como auditor sênior de release, governança,
produto público e documentação institucional.

Leia completamente o repositório na branch `codex/v12-0-0205-estabilizacao-docs`
e trate `V12.0.0205` como a grafia canônica da versão. Não use `V12.0.205`.

Leia obrigatoriamente:

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
- `auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md`
- `src/vba/App_Release.bas`
- `src/vba/Teste_Validacao_Release.bas`
- `src/vba/Central_Testes.bas`
- `src/vba/Central_Testes_V2.bas`

Critérios de análise:

1. Verifique se a V12.0.0205 está coerentemente posicionada como linha
   `VALIDADO/OFICIAL`, com V12.0.0206 como próxima estabilização incremental e
   V12.0.0207 como linha recomendada para code review profundo, performance,
   componentização e preparação SaaS.
2. Verifique se não há inconsistência de numeração, status, tag, evidência,
   build, `validation_id`, nome de arquivo ou caminho canônico.
3. Avalie se a documentação pública funciona como vitrine positiva da solução:
   clareza para humanos, rastreabilidade para IAs, maturidade de governança e
   narrativa institucional adequada para ambiente governamental.
4. Descreva os aspectos positivos da ferramenta: valor público, lógica de
   rodízio, trilha de auditoria, testes automatizados, governança HBN, validação
   por evidência, controle de regressão e organização documental.
5. Avalie se o padrão documental está em nível de excelência ou quais ajustes
   faltam para chegar lá.
6. Aponte inconsistências reais, se existirem, classificadas como P0/P1/P2/P3.
7. Diferencie claramente:
   - bloqueadores para congelar a V12.0.0205;
   - pendências aceitáveis para V12.0.0206;
   - temas mais adequados para V12.0.0207 ou roadmap SaaS.

Use tom de auditoria: profundo, objetivo, mas positivo. A release já tem gate
funcional aprovado em `VR_20260521_182816`; não rebaixe a versão por pendências
que pertençam corretamente a V12.0.0206/V12.0.0207, mas sinalize qualquer
inconsistência que possa confundir humanos, IAs ou GitHub.

Estrutura mínima do relatório:

1. Veredito executivo.
2. Pontos fortes da V12.0.0205.
3. Coerência de versão, numeração e status.
4. Excelência documental e vitrine GitHub.
5. Arquitetura de validação e lógica de negócio.
6. Riscos ou inconsistências encontradas.
7. Pendências por versão: V12.0.0206, V12.0.0207 e roadmap SaaS.
8. Recomendação final ao Codex para congelamento.
