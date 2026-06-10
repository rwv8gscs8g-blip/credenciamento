---
titulo: Handoff fim-de-sessao Codex 0175
agente: codex
sessao_inicio: 2026-06-09 23:30
sessao_fim: 2026-06-09 23:50
gatilho: contexto_50
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

## 1. Onda em curso

0175 — Onda 38.2.42, `aviso_rodape_relatorios_largos`.

## 2. Último readback

`.hbn/readbacks/0175-rb-onda-38-2-42-aviso-rodape-relatorios-largos.json`
com `human_status: confirmed`.

## 3. Último ERP

`.hbn/results/0175-exec-onda-38-2-42-aviso-rodape-relatorios-largos.json`
deve ser lido como `package_ready_gate_pending` apos este fechamento.

## 4. Hearbacks pendentes

Pendente apenas o gate humano pos-0175:

- Importador V3;
- compile VBE;
- `TV2_RunRelatoriosSuspensoesStrikesReset`;
- revisao visual dos PDFs equivalentes a 022-030.

## 5. Sinais HBN abertos

Nenhum sinal bloqueador aberto alem do gate visual da 0175.

## 6. Próxima ação obrigatória

Importar a 0175 pelo manifesto V3, compilar, rodar TV2 dirigido e revisar PDFs.

## 7. Arquivos no scope ativo

Principais:

- `src/vba/App_Release.bas`
- `src/vba/Util_Config.bas`
- `src/vba/Preencher.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_42_AVISO_RODAPE_RELATORIOS_LARGOS.txt`
- `local-ai/vba_import/001-modulo/AAD-Util_Config.bas`
- `local-ai/vba_import/001-modulo/AAU-Preencher.bas`
- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`
- `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas`
- `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas`

## 8. Decisões tomadas em chat mas não documentadas em .md

0175 documenta no relay/tecnico/procedimento a decisao de mover o aviso para
`B30:K30` e reduzir margens laterais dos relatorios. A proposta de auditoria
cruzada do protocolo useHBN ainda deve ser aberta como 0176 doc-only.

## 9. Riscos abertos

- A margem lateral menor pode nao resolver todos os relatorios densos; se o PDF
  ainda ficar comprimido, abrir nova onda com redistribuicao de colunas.
- `AAD-Util_Config.bas` e o manifesto V3 ficam sob `.gitignore` amplo de
  `local-ai/`; ao commitar, usar `git add -f` nesses artefatos importaveis.

## 10. Leituras obrigatórias do sucessor

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/readbacks/0175-rb-onda-38-2-42-aviso-rodape-relatorios-largos.json`
4. `.hbn/results/0175-exec-onda-38-2-42-aviso-rodape-relatorios-largos.json`
5. `auditoria/03_ondas/onda_38_2_42_aviso_rodape_relatorios_largos/0175_TECNICO.md`
6. `auditoria/03_ondas/onda_38_2_42_aviso_rodape_relatorios_largos/0175_PROCEDIMENTO_IMPORT.md`

## 11. Comando único para validar estado ao retomar

```bash
pwd && git rev-parse --show-toplevel && git status --short --branch && bash local-ai/scripts/publicar_vba_import_v2.sh --check
```

## 12. Sinal

🔵 HBN HANDOFF READY

## 13. Papel transferido

Implementador Codex para Cursor/Codex sucessor, se o operador abrir novo chat.

## 14. Para qual agente vai o bastão

Recomendacao: Codex/Cursor como implementador, porque a proxima etapa ainda e
iteracao curta de validação tela a tela em VBA; Claude Opus e Antigravity
devem ser acionados como auditores cruzados doc-only na 0176.

## 15. Checklist anti-viés de bastão

- Esta recomendacao inclui auto-indicacao? Sim, recomenda continuidade com
  Codex/Cursor para implementacao por contexto acumulado de VBA/HBN.
- Evidencia objetiva: 0175 esta documentada em readback, relay, tecnico,
  procedimento, manifesto e testes; o sucessor precisa seguir gate humano.
- Vies natural reconhecido: o implementador tende a preferir continuidade.
- Mitigacao sugerida: antes do freeze V206, rodar auditoria cruzada com Claude
  Opus 4.8 e Antigravity/Gemini 3.5 em chats novos.

## 16. Prompt de entrada do sucessor

Use este prompt no novo chat Cursor/Codex:

```text
Voce e Codex/Cursor, sob AGENTS.md, HBN e Cadencia D Estendida no projeto Sistema de Credenciamento.

Raiz canonica obrigatoria:
/Users/macbookpro/Projetos/Credenciamento

Antes de ler ou editar, valide:
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list

Leia, nesta ordem:
AGENTS.md
.hbn/relay/INDEX.md
.hbn/messages/20260609-2350-handoff-fim-sessao-codex-0175-cursor-retomada.md
.hbn/readbacks/0175-rb-onda-38-2-42-aviso-rodape-relatorios-largos.json
.hbn/results/0175-exec-onda-38-2-42-aviso-rodape-relatorios-largos.json
auditoria/03_ondas/onda_38_2_42_aviso_rodape_relatorios_largos/0175_TECNICO.md
auditoria/03_ondas/onda_38_2_42_aviso_rodape_relatorios_largos/0175_PROCEDIMENTO_IMPORT.md

Estado esperado:
- Branch codex/v12-0-0206-planejamento.
- 0175 package_ready_gate_pending.
- Proxima acao humana: importar o manifesto ONDA38_2_42_AVISO_RODAPE_RELATORIOS_LARGOS, compilar, rodar TV2_RunRelatoriosSuspensoesStrikesReset e revisar PDFs.

Nao implemente nada novo antes de consolidar o hearback humano da 0175.
Se a 0175 passar, proponha a 0176 doc-only para auditoria cruzada de pendencias,
handoffs e planejamento de fechamento V206/V207.
```
