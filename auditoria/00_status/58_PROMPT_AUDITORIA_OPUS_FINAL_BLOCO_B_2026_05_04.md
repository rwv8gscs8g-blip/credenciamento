---
titulo: 58 - Prompt auditoria final Opus Bloco B
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 58. Prompt — Auditoria Final Opus 4.7 do Bloco B

Voce e Claude Opus 4.7 em modo **AUDITORIA FINAL** da Frente 1 do
projeto Credenciamento V12.0.0203. Nao implemente. Nao edite arquivos.
Sua saida deve ser um unico documento markdown com decisao objetiva:
`APROVADO`, `APROVADO_COM_RESSALVAS`, `REPROVADO` ou `BLOQUEADO`.

## Contexto

Codex CLI recebeu o bastao F1 pelo doc 57 e implementou o Bloco B /
Onda 18 critica. O estado final e `v12.0.0203-rc3`, build
`f7aa84f+v12.0.0203-rc3`.

## Leia em ordem

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/locks/bastao-frente1.lock`
4. `auditoria/00_status/57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md`
5. `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`
6. `auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md`
7. `auditoria/03_ondas/onda_17_test_first/70_FECHAMENTO_ONDA_17.md`
8. `auditoria/03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md`
9. `.hbn/results/0020-exec-onda18-md18-1a-schema.json`
10. `.hbn/results/0021-exec-onda18-md18-1b-reativ-strikes.json`
11. `.hbn/results/0022-exec-onda18-md18-3-rpt-bugs-resolvidos.json`
12. `.hbn/results/0023-exec-onda18-md18-2-statusbar-hint.json`
13. `.hbn/results/0024-exec-onda17-18-fechamento-rc3.json`
14. `CHANGELOG.md`
15. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`

## Codigo e pacotes a auditar

- `src/vba/Const_Colunas.bas`
- `src/vba/Mod_Types.bas`
- `src/vba/Mod_Limpeza_Base.bas`
- `src/vba/Repo_Empresa.bas`
- `src/vba/Svc_Rodizio.bas`
- `src/vba/Repo_Avaliacao.bas`
- `src/vba/Svc_Avaliacao.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/Teste_Bateria_Oficial.bas`
- `src/vba/Preencher.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/App_Release.bas`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO25-fix2.txt`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO26.txt`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO27.txt`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO28.txt`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO29.txt`

## Evidencias de gate

- `VR_20260504_054106` — MICRO25-fix2 — APROVADO
- `VR_20260504_060256` — MICRO26 — APROVADO
- `VR_20260504_064117` — MICRO27 — APROVADO
- `VR_20260504_070441` — MICRO28 — APROVADO
- `VR_20260504_075624` — MICRO29 / rc3 — APROVADO
- Sintaxe final esperada:
  `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## Perguntas obrigatorias

1. A implementacao de `DT_ULT_REATIV` respeita fonte de verdade `src/vba`
   e espelho `local-ai/vba_import`?
2. A decisao dupla informacao esta correta?
   - `ContarStrikesPorEmpresa` preserva historico total.
   - `ContarStrikesParaPunicao` aplica janela punitiva.
3. `Svc_Rodizio.Reativar` grava `DT_ULT_REATIV` em todos os caminhos
   relevantes?
4. `Svc_Avaliacao` usa o contador punitivo correto?
5. Os testes novos cobrem:
   - data gravada;
   - historico preservado;
   - janela exclui historico;
   - re-suspensao apos tres novos strikes;
   - modo legado com `DT_ULT_REATIV` vazia?
6. `RPT_BUGS_RESOLVIDOS` move DT-17 sem esconder `INT-CAD-OS-REF-ORFA`?
7. `Menu_Principal.frm` e `AAM-Menu_Principal.code-only.txt` estao
   coerentes com M9/M15/L22/L24?
8. O bump `v12.0.0203-rc3` e conservador o bastante antes do final?
9. Ha algum P0/P1 que bloqueie a devolucao do bastao?

## Output exigido

Escreva o resultado em:

`auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_04.md`

Estrutura:

1. Decisao final
2. P0/P1/P2 encontrados
3. Evidencias verificadas
4. Riscos remanescentes aceitos/deferidos
5. Recomendacao sobre seguir para auditoria Antigravity/devolucao de bastao
6. Markers HBN finais
