---
titulo: LangGraph
slug: langgraph
categoria: agentes
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (reescrita por Opus — análise individual)
proxima-revisao: 2026-06-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# LangGraph

## Por que está no radar

A tese 38 §8 lista LangGraph como referência da camada "núcleo de agentes". Interesse específico para o useHBN: LangGraph oferece **controle por grafos direcionais**, o que potencialmente alinha com o princípio HBN de fluxos previsíveis e auditáveis (ao invés de cadeias ReAct livres tipicamente opacas). É a alternativa "explícita" da LangChain ao seu próprio AgentExecutor clássico — vale estudar o tradeoff entre controle declarativo e custo de framework.

## Resumo da tecnologia

LangGraph é framework Python da LangChain Inc para construir aplicações com agentes IA usando **grafos de estado**. Núcleo: `StateGraph` com nós (funções que mutam estado) e edges (transições condicionais). Estado é objeto compartilhado mutável passado entre nós.

Recursos centrais:
- `interrupt()` para pausar execução e devolver controle a humano
- Checkpointing pluggable (SQLite, Postgres, Redis) para persistência e replay
- Streaming de eventos em tempo real
- Diagrama Mermaid auto-gerado do grafo (`get_graph().draw_mermaid()`)
- Subgrafos para composição modular

Diferencia-se do AgentExecutor clássico da LangChain por ser **mais explícito** — fluxo é declarado, não inferido por LLM. Casos de uso típicos: pipelines multi-agente, RAG complexo, customer support com escalonamento humano, workflows que precisam interromper-e-resumir.

Licença: MIT. Mantenedor: LangChain Inc (empresa privada). Ecossistema acoplado a `langchain-core`. Versão estável v0.2.x em maio/2026.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Grafo explícito preserva controle do fluxo. Mas LangGraph encoraja substituir lógica imperativa por nós; risco se sistema legado for "transformado em grafo" sem preservar registro da lógica original. |
| 2 | Documentar antes de executar | parcial | Definição do grafo é código Python, não documento. Mitigação: `draw_mermaid()` exporta diagrama; pode-se versionar o SVG ao lado do código como documentação derivada. |
| 3 | Testar antes de refatorar | parcial | Nós são funções puras isoláveis (testáveis unitariamente). Mas testar fluxos completos é difícil porque LLMs em nós são não-determinísticos. Snapshot/golden tests só parcialmente. |
| 4 | Explicar antes de automatizar | parcial | Grafo declarado é mais "explicável" que cadeia ReAct livre. Mas LLMs em nós continuam introduzindo opacidade. Diagrama ajuda visualmente; conteúdo dos prompts ainda precisa de explicação humana. |
| 5 | Humano no controle por padrão | sim | `interrupt()` é primeira classe; checkpointing permite pausar/retomar; tutorial human-in-the-loop é caso de uso documentado de primeira ordem. Convergência forte. |
| 6 | Toda evolução deve ser reversível | parcial | Checkpointing dá rollback **dentro de uma execução** (resumir do último estado). Mas evolução do **grafo entre versões** (mudança do schema do state) não tem migração automática. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | parcial | Se LangGraph orquestra agentes que tocam VBA, o VBA permanece VBA — ok. Se LangGraph virar centro de tudo, viola P9 e indiretamente P7. |
| 8 | O protocolo importa mais que a ferramenta | parcial | LangGraph é ferramenta; pode encaixar protocolo HBN se usado como executor de readbacks/heartbacks. Risco se virar "o protocolo" na prática. |
| 9 | Frameworks são descartáveis; princípios são permanentes | não | Lock-in mediano-alto: state schema, checkpointing format, integrações `langchain-*`. Migrar para Pydantic AI ou Python puro exige reescrita não-trivial. |
| 10 | Segurança e não-regressão > velocidade | parcial | Testes de integração existem; comunidade ativa. Mas LLM em nó pode introduzir regressão silenciosa (mudança de modelo subjacente altera comportamento sem alarme). |

**Convergência média: 1/10 sim, 8/10 parcial, 1/10 não.**

## Divergências e riscos

- **Velocidade de evolução agressiva**: breaking changes entre minor versions em 2024 (v0.0.x → v0.2.x). Custo de manutenção alto.
- **Acoplamento ao ecossistema LangChain**: alguns recursos exigem `langchain-core`; risco se LangChain Inc mudar política comercial.
- **Estado mutável compartilhado**: aumenta complexidade de debugging em fluxos longos.
- **Custo operacional**: cresce com número de nós × LLM calls; sem instrumentação OTel out-of-the-box.
- **Vendor risk**: 100% mantido pela LangChain Inc; sem foundation neutra.

## O que precisa para avançar de estado

Para `under-analysis`:
- POC pequeno: orquestrar 1 ciclo HBN (readback → execução → ERP) usando LangGraph como motor; comparar com Python puro
- Medir custo extra de dependência (instalação, runtime, RAM)
- Avaliar checkpointing: dá para resumir um ciclo se Maurício pausar?

Para `convergence-mapped`:
- Estudo paralelo de 2 alternativas (CrewAI, Pydantic AI) com mesmo POC; matriz comparativa
- Confirmar compatibilidade de licença (MIT é OK com AGPLv3)

Para `candidate`:
- Decisão explícita do Maurício após ver POC funcionando

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | in-radar | in-radar | Reescrita de conteúdo (Opus análise individual) | Claude Opus 4.7 (Frente 2) |

## Referências

- [Documentação oficial](https://langchain-ai.github.io/langgraph/) — guia, tutoriais, API reference
- [Repositório GitHub](https://github.com/langchain-ai/langgraph) — MIT License
- [Anúncio inicial (blog LangChain)](https://blog.langchain.dev/langgraph/) — racional do projeto
- [Tutorial Human-in-the-loop](https://langchain-ai.github.io/langgraph/how-tos/human_in_the_loop/) — relevante para princípio 5
- [Comparação multi-agent workflows](https://blog.langchain.dev/langgraph-multi-agent-workflows/) — comparativo com CrewAI e AutoGen
- Fonte interna: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`
