---
titulo: Prompt Auditoria Docs GitHub V205 Gemini
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Superprompt AF2 — Gemini 3.5 Flash High via Antigravity

## Objetivo

Executar auditoria cruzada adversarial da documentação, navegação GitHub,
numeração, versões, caminhos, protocolos e consistência de arquivos da
V12.0.0205, usando o relatório do Claude Opus como entrada, mas verificando tudo
de forma independente.

## Documento de saída obrigatório

Grave ou entregue o conteúdo final como:

`auditoria/00_status/81_AUDITORIA_FINAL_DOCS_GITHUB_V205_GEMINI.md`

Não implemente código, não edite arquivos e não altere o repositório. A decisão
e a execução física cabem ao Codex.

## Prompt para uso

Você é Gemini 3.5 Flash High via Antigravity atuando como auditor adversarial de
documentação, GitHub readiness, consistência de release, UX textual, navegação
para humanos e legibilidade para IAs.

Leia completamente o repositório na branch `codex/v12-0-0205-estabilizacao-docs`
e trate `V12.0.0205` como grafia canônica. Qualquer ocorrência pública que
confunda `V12.0.0205`, `V12.0.205`, `V205`, `v12.0.0205`, tags, paths ou nomes
de evidência deve ser analisada.

Leia obrigatoriamente:

- o relatório do Claude Opus:
  `auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`
- todos os arquivos de entrada pública:
  `README.md`, `CHANGELOG.md`, `AGENTS.md`, `llms.txt`, `docs/INDEX.md`,
  `obsidian-vault/releases/STATUS-OFICIAL.md`,
  `obsidian-vault/releases/V12.0.0205.md`
- a documentação de validação:
  `docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`,
  `docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md`,
  `docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md`,
  `docs/how-to/COMO_GERAR_DOSSIE_V205.md`
- a documentação de referência:
  `docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`,
  `docs/reference/testes/NOMENCLATURA_BATERIAS_V205.md`,
  `docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md`,
  `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`
- evidências e governança:
  `auditoria/evidencias/V12.0.0205/INDEX.md`,
  `auditoria/evidencias/V12.0.0205/MANIFEST.md`,
  `auditoria/evidencias/V12.0.0205/MANIFESTO.csv`,
  `.hbn/relay/INDEX.md`,
  `.hbn/results/INDEX.md`,
  `auditoria/INDEX.md`
- scripts e código relacionados:
  `.github/scripts/verify_release_consistency.sh`,
  `src/vba/App_Release.bas`,
  `src/vba/Teste_Validacao_Release.bas`,
  `src/vba/Central_Testes.bas`,
  `src/vba/Central_Testes_V2.bas`

Tarefas obrigatórias:

1. Varra a documentação para localizar inconsistências de versão, status,
   tag, build, evidence dir, validation ID, nomes de CSV e rotas de links.
2. Verifique se todos os arquivos citados existem no local indicado e se os
   documentos novos estão nos diretórios corretos de acordo com Diataxis.
3. Verifique se a documentação explica corretamente que:
   - V12.0.0205 é a linha oficial validada;
   - V12.0.0206 recebe melhorias incrementais, débitos técnicos pequenos,
     ajustes manuais e PDF automático;
   - V12.0.0207 recebe code review profundo, performance, componentização e
     preparação SaaS, salvo novo roadmap.
4. Teste mentalmente a navegação de um auditor externo que chega pelo GitHub:
   `README -> docs/INDEX -> release note -> regras -> matriz -> jornada -> gate
   -> evidências`.
5. Verifique se a documentação evidencia positivamente a ferramenta sem exagerar
   claims não provados.
6. Classifique achados em P0/P1/P2/P3 e indique correção objetiva para cada um.

Estrutura mínima do relatório:

1. Veredito executivo.
2. Checagem de versão e numeração.
3. Checagem de links e caminhos.
4. Checagem de Diataxis e localização dos arquivos.
5. Checagem da vitrine GitHub para humanos.
6. Checagem da legibilidade para IAs.
7. Achados P0/P1/P2/P3.
8. Lista de correções recomendadas ao Codex.
9. Confirmação ou negativa de prontidão para congelamento.
