---
titulo: L44 — diff "cosmético" reportado por sub-agente é suspeito até prova do pipeline
data: 2026-05-27
autoria: claude-opus-4-7 (arquiteto, onda 0112) — lição empírica do Codex 0012
aplica-a: qualquer IA que delegue comparação de versões de código a um sub-agente (Explore/Task)
revisar-em: 2026-07-01
hbn-track: fast_track
hbn-status: knowledge
audiencia: ia
versao-sistema: V12.0.0206
---

# L44 — diff "cosmético" de sub-agente é suspeito

## Regra

Quando um sub-agente (Explore/Task) reporta um diff como "cosmético" ou
"refatoração benigna" entre duas versões de código, isso é **suspeito até prova
em contrário**. Inspecione o **pipeline gerador** do artefato antes de
classificar como benigno — não confie só no texto do diff resultante.

## Evidência empírica (2026-05-27)

Opus 4.7 lançou um Explore agent para comparar
`local-ai/incoming/V206-Rollback-*/Cadastro_Servico.frm` vs
`src/vba/Cadastro_Servico.frm`. O agent reportou "9 linhas alteradas… remoção de
variáveis privadas de estado… refatoração de limpeza" e classificou como
**benigno**.

Era **BLOQUEADOR real**: `Private mIgnorarFiltro` e
`Private WithEvents mTxtBuscaTopo` faziam parte do contrato do form. O
`.code-only.txt` gerado tinha bug em `publicar_vba_import_v2.py:212-248`, que
parava antes das declarações `WithEvents` ao encontrar
`Attribute mTxtBuscaTopo.VB_VarHelpID = -1`. O Codex (0012) inspecionou o
**pipeline gerador** (não só o diff) e pegou. O Explore agent, que só compara
texto, perdeu.

## Lição transversal

Delegação a sub-agentes corta atalhos justamente onde a investigação do pipeline
é necessária. Reforça o princípio "**Never delegate understanding**": o diff é o
sintoma; o gerador é a causa. Para mudanças que tocam `.frm`/`.code-only.txt`,
sempre verifique o script que produziu o artefato.

## Como verificar

- Antes de aceitar um diff "cosmético" em `.frm`/`.bas`/`.code-only.txt`,
  abra o gerador (`local-ai/scripts/publicar_vba_import_v2.sh` /
  `publicar_vba_import_v2.py`) e confirme que ele não trunca declarações
  (`WithEvents`, `Attribute`, `Private` de contrato).
- Conferir presença das variáveis de contrato declaradas no topo do form no
  artefato gerado.
- Conteúdo técnico definitivo migra para `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
  na onda documental pós-GATE-FREEZE (P10).
