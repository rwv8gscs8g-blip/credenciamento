---
titulo: OpenAI Agents SDK
slug: openai-agents-sdk
categoria: agentes
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# OpenAI Agents SDK

## Por que está no radar

A entrada aparece nas fontes do radar como SDK oficial de agentes. Interesse específico do useHBN: avaliar se OpenAI Agents SDK ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`. Estado atual: `in-radar`.

## Resumo da tecnologia

OpenAI Agents SDK é SDK oficial de agentes. Tecnicamente, usa Agent, Runner, tools, guardrails, handoffs e tracing sobre APIs OpenAI. Recursos centrais:
- handoffs
- guardrails
- function tools
- tracing
- structured outputs

Diferencial para o radar: permite estudar SDK oficial de agentes com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: MIT. Mantenedor: OpenAI. Maturidade: recente, oficial e em evolução.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Orquestra ações novas; só preserva se usado primeiro para leitura e documentação do legado. Sinal E1.1: handoffs. |
| 2 | Documentar antes de executar | parcial | handoffs precisa virar instrução versionada, não prompt invisível. Sinal E1.1: guardrails. |
| 3 | Testar antes de refatorar | parcial | guardrails podem ser testadas em isolamento, mas decisões LLM exigem fixtures e modelos fixados. Sinal E1.1: function tools. |
| 4 | Explicar antes de automatizar | parcial | Passos intermediários ajudam explicação; raciocínio do modelo não substitui evidência verificável. Sinal E1.1: tracing. |
| 5 | Humano no controle por padrão | parcial | Sem interrupt/hearback externo, openai agents sdk tende a agir rápido demais para o padrão HBN. Sinal E1.1: structured outputs. |
| 6 | Toda evolução deve ser reversível | parcial | Logs e outputs voltam; side effects de tools precisam rollback separado. Sinal E1.1: openai agents sdk. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | parcial | O alvo mantém identidade se o agente não converter tudo para abstrações próprias. Sinal E1.1: openai agents sdk. |
| 8 | O protocolo importa mais que a ferramenta | parcial | OpenAI Agents SDK deve executar dentro do protocolo, não substituir ERP, markers ou registry. Sinal E1.1: openai agents sdk. |
| 9 | Frameworks são descartáveis; princípios são permanentes | não | No estado atual, OpenAI Agents SDK conflita com este princípio: Como framework, precisa ser descartável; acoplamento a memória/handoffs enfraquece P9. O risco supera o ganho até haver experimento controlado. Sinal E1.1: openai agents sdk. |
| 10 | Segurança e não-regressão > velocidade | parcial | Agentes combinam LLM e tools; permissões mínimas e dados sintéticos são pré-condição. Sinal E1.1: openai agents sdk. |

**Convergência média: 0/10 sim, 9/10 parcial, 1/10 não.**

## Divergências e riscos

- **Vendor risk**: OpenAI. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: recente, oficial e em evolução; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se SDK oficial de agentes virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: MIT; confirmar licença de código e termos de serviço antes de incorporar implementação.

## O que precisa para avançar de estado

- Definir POC pequeno, reversível e com dados sintéticos.
- Registrar entrada, saída, custo e rollback no ERP da esteira.
- Comparar contra alternativa mais simples baseada em arquivos/protocolo HBN puro.
- Só avançar de `in-radar` se o ganho for evidenciado por teste, log ou redução de risco.
- Se houver conteúdo TPGL envolvido, exigir consentimento e redaction-map antes de qualquer promoção pública.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | in-radar | in-radar | Reescrita de conteúdo (E1.1 — Codex análise individual) | Codex CLI |

## Referências

- [Referência oficial/base](https://openai.github.io/openai-agents-python/)
- [Documentação técnica](https://github.com/openai/openai-agents-python)
- [Referência complementar](https://openai.github.io/openai-agents-python/tracing/)
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`
