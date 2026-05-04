---
titulo: 59 - Prompt auditoria final Antigravity Bloco B
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 59. Prompt — Auditoria Final Antigravity do Bloco B

Voce e Antigravity (Gemini 3.1 ou versao mais recente disponivel) em
modo **AUDITORIA FINAL CRUZADA**. Nao implemente. Nao edite arquivos.
Seu papel e tentar encontrar regressao, erro de import, drift fonte/espelho
ou lacuna de teste que Codex e Opus possam ter perdido.

Sua saida deve ser um unico documento markdown com decisao objetiva:
`APROVADO`, `APROVADO_COM_RESSALVAS`, `REPROVADO` ou `BLOQUEADO`.

## Leia em ordem

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `auditoria/00_status/55_AUDITORIA_ANTIGRAVITY_2026_05_04.md`
4. `auditoria/00_status/56_QA_CODEX_2026_05_04.md`
5. `auditoria/00_status/57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md`
6. `auditoria/03_ondas/onda_17_test_first/70_FECHAMENTO_ONDA_17.md`
7. `auditoria/03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md`
8. `.hbn/results/0020-exec-onda18-md18-1a-schema.json`
9. `.hbn/results/0021-exec-onda18-md18-1b-reativ-strikes.json`
10. `.hbn/results/0022-exec-onda18-md18-3-rpt-bugs-resolvidos.json`
11. `.hbn/results/0023-exec-onda18-md18-2-statusbar-hint.json`
12. `.hbn/results/0024-exec-onda17-18-fechamento-rc3.json`
13. `CHANGELOG.md`

## Foco tecnico

Audite com postura adversarial:

1. `DT_ULT_REATIV`:
   - constante correta na coluna U;
   - UDT atualizado;
   - cabecalho `EMPRESAS`;
   - leitura/escrita em repo;
   - migracao de dados antigos com vazio/zero.
2. Janela de strikes:
   - corte usa `COL_OS_DT_FECHAMENTO`;
   - comparacao e estritamente posterior a reativacao;
   - linhas sem data de fechamento nao causam falso positivo;
   - historico total continua acessivel.
3. Reativacao:
   - `Svc_Rodizio.Reativar` grava data;
   - evento de auditoria contem sinal suficiente;
   - no-op em empresa ativa permanece deferido, nao resolvido por engano.
4. Testes:
   - `CS_E2E_REATIV2STRIKES` verde cobre o bug original;
   - seis asserts novos realmente exercitam a janela;
   - Quinteto final `VR_20260504_075624` e coerente com as mudancas.
5. Relatorios:
   - `RPT_BUGS_RESOLVIDOS` nao apaga outros bugs;
   - `INT-CAD-OS-REF-ORFA` permanece visivel como debito.
6. Forms/import:
   - `Menu_Principal.frm` e `.code-only.txt` coerentes;
   - `MICRO28` usa `F|...frm` corretamente para o V3 estabilizado;
   - nao houve drift de `.frx`.
7. Release:
   - `v12.0.0203-rc3` e metadata coerente;
   - final nao foi antecipado antes da auditoria cruzada.

## Evidencias de gate

- `VR_20260504_054106` — MICRO25-fix2 — APROVADO
- `VR_20260504_060256` — MICRO26 — APROVADO
- `VR_20260504_064117` — MICRO27 — APROVADO
- `VR_20260504_070441` — MICRO28 — APROVADO
- `VR_20260504_075624` — MICRO29 / rc3 — APROVADO
- Sintaxe final:
  `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## Output exigido

Escreva o resultado em:

`auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_04.md`

Estrutura:

1. Decisao final
2. Achados P0/P1/P2 com path:linha
3. Checks fonte↔espelho executados
4. Checks de comportamento/teste executados
5. Debitos aceitos e recomendacao de release
6. Markers HBN finais
