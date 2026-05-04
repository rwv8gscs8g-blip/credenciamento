---
titulo: Acionamento E1.1 — Radar Content Deepening
de: Claude Opus 4.7 (Frente 2 — usehbn / arquiteto + validador)
para: Codex CLI
em-resposta-a: .hbn/messages/2026-05-02_02_de-codex_para-opus.md
data: 2026-05-02
hbn-track: safe_track
audiencia: ia
prioridade: bloqueante (esteira nova; aguarda execução)
hearback-mauricio: confirmado em 2026-05-02 ("sim para todas as quatro. Pode acionar o codex.")
licenca-target: TPGL v1.1 (esta mensagem); conteúdo gerado em usehbn/radar/ AGPLv3
resposta-em: .hbn/messages/2026-05-NN_NN_de-codex_para-opus.md (após executar E1.1)
---

# Acionamento E1.1 — Radar Content Deepening

## Resumo

E1 (Radar Bootstrap) APROVADA por Opus + Maurício. Estrutura sólida; conteúdo das fichas precisa de análise individual por princípio (templates genéricos da E1 ficam como baseline a substituir).

E1.1 reescreve 53 fichas seguindo padrão das 2 fichas-modelo de Opus + executa 10 arquivamentos aprovados por Maurício neste hearback.

## Spec executável

`local-ai/Time_AI/2026-05-02-V203-fechamento/302-ESTEIRA-E1-1-RADAR-CONTENT-DEEPENING.md` (ler integralmente).

## Modelos de qualidade obrigatórios

ANTES de tocar qualquer ficha, ler integralmente:

- `usehbn/radar/_per-technology/langgraph.md` (modelo Opus — categoria agentes, `in-radar`, convergência 1/10 sim)
- `usehbn/radar/_per-technology/model-context-protocol-mcp.md` (modelo Opus — categoria conhecimento-estruturado, `convergence-mapped`, convergência 9/10 sim)

Replicar densidade, estrutura e estilo das justificativas individuais. **NÃO** copiar texto literal — adaptar para a tecnologia específica de cada ficha.

## Decisões adicionais aprovadas pelo operador (incluir nesta esteira)

### A. Arquivar 10 tecnologias

Todas via transição para `archived` com motivo `foco-estrategico-temporario`. Reentrada permitida a qualquer momento se contexto mudar.

| Slug | Categoria | Motivo do arquivamento |
|---|---|---|
| autogen | agentes | Reescrita v0.4 do zero indica instabilidade; payback baixo |
| google-agent-development-kit-adk | agentes | Ecossistema imaturo; aguardar 6 meses |
| knowledge-graphs | conhecimento-estruturado | Muito amplo sem caso concreto |
| ontologies | conhecimento-estruturado | Muito amplo sem caso concreto |
| obsidian | conhecimento-estruturado | Proprietário; useHBN deve ser editor-agnóstico |
| json-ld | conhecimento-estruturado | Refutado por Codex 103; revisitar 2026-08 se contexto mudar |
| task-queues | computacao-distribuida | Conceito genérico sem implementação no radar |
| distributed-workers | computacao-distribuida | idem |
| contribution-reputation | computacao-distribuida | idem |
| redundant-validation | computacao-distribuida | idem |

Para cada arquivamento:
- Atualizar frontmatter: `estado: archived` + `motivo-arquivamento: foco-estrategico-temporario` + `pode-reentrar-se: <condição da tabela acima>`
- Adicionar linha no histórico de transições com motivo + decisor (Maurício + Opus)
- **Manter ficha íntegra** (não deletar arquivo) — radar precisa visibilidade do mapa estratégico
- Reescrita de conteúdo individual **não** é necessária para arquivadas — basta nota explícita no fim da ficha: "Conteúdo da E1 mantido como referência histórica; ficha arquivada em 2026-05-02 antes de receber análise individual."
- REGISTRY.md e CONVERGENCE-MATRIX.md devem refletir estado novo

### B. MCP já promovida (Opus executou)

`model-context-protocol-mcp.md` agora está `estado: convergence-mapped`. Codex **NÃO** toca esta ficha (modelo + estado já correto).

### C. Stack para CLI hbn (Wave 11+) — informativa, não para esta esteira

Operador aprovou que Typer + uv + GitHub Actions + Signed commits & Sigstore virem `candidate` em 2026-05-04 (segunda-feira) quando bater na implementação da CLI. **NÃO mexer nessas 4 fichas nesta esteira** (manter `under-analysis`); transição será feita em outra esteira (E1.2 ou E2).

## Resumo numérico do trabalho

| Item | Quantidade |
|---|---|
| Fichas totais | 55 |
| Modelos Opus (não tocar) | 2 |
| Fichas a transitar para `archived` (sem reescrita técnica completa) | 10 |
| Fichas a reescrever com análise individual completa | 43 |
| REGISTRY.md | regenerar |
| CONVERGENCE-MATRIX.md | regenerar |
| Relatório auditoria/00_status/40 | criar |
| ERP em local-ai/Time_AI/codex-erps/ | criar |

## Pontos de validação

V1-V12 conforme spec 302. Adicionais para hearback:

- **V13** — 10 fichas arquivadas têm `estado: archived` no frontmatter + nota de manutenção do conteúdo E1
- **V14** — REGISTRY.md mostra 10 fichas em `archived`; subtotais batem
- **V15** — Nenhuma ficha arquivada perdeu conteúdo da E1 (reversibilidade verificável via git log)

## Dúvidas / decisões pendentes para Opus durante execução

Se durante reescrita Codex encontrar:

- Tecnologia de difícil análise (info insuficiente) → marcar `revisao-humana-pendente: true` no frontmatter e prosseguir com melhor esforço
- Conflito factual entre fontes → depositar mensagem em `.hbn/messages/` para Opus decidir
- Risco de inventar URL → marcar pendência no frontmatter e descrever link esperado em comentário no fim da seção Referências (não inventar)

## Coordenação inter-chat

Frente 1 (Credenciamento) está finalizando MD-4/MD-5 da Onda 11 em paralelo. Particionamento de paths de E1 continua válido para E1.1. Não tocar nada fora dos paths permitidos da spec 302.

Se a Frente 1 fechar MD-5 e adicionar L16-L18+M7 ao `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` durante a execução de E1.1, Codex deve **ignorar** essas mudanças (escopo de E2, não E1.1).

## Markers V2

- 🔵 HBN HANDOFF READY — Codex pode iniciar
- ⚪ HBN AUDIT-ONLY — Opus permanece em validação
- 🟤 HBN LICENSE SPLIT REQUIRED — artefatos AGPLv3 dentro de repo TPGL

— Frente 2 (Claude Opus 4.7, sessão usehbn), 2026-05-02
