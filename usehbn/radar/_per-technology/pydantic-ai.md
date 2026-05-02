---
titulo: Pydantic AI
slug: pydantic-ai
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

# Pydantic AI

## Por que está no radar

A entrada aparece nas fontes do radar como agentes tipados. Interesse específico do useHBN: avaliar se Pydantic AI ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`. Estado atual: `in-radar`.

## Resumo da tecnologia

Pydantic AI é agentes tipados. Tecnicamente, combina Agent, tools tipadas, providers e validação Pydantic para structured output. Recursos centrais:
- schemas Pydantic
- tools tipadas
- providers múltiplos
- retry de validação
- dependency injection

Diferencial para o radar: permite estudar agentes tipados com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: MIT. Mantenedor: Pydantic Services Inc. + comunidade. Maturidade: jovem, com base Pydantic madura.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Orquestra ações novas; só preserva se usado primeiro para leitura e documentação do legado. Sinal E1.1: schemas Pydantic. |
| 2 | Documentar antes de executar | sim | schemas Pydantic já consegue virar instrução versionada, não prompt invisível. Sinal E1.1: tools tipadas. |
| 3 | Testar antes de refatorar | sim | tools tipadas podem ser testadas em isolamento, mas decisões LLM exigem fixtures e modelos fixados. Sinal E1.1: providers múltiplos. |
| 4 | Explicar antes de automatizar | parcial | Passos intermediários ajudam explicação; raciocínio do modelo não substitui evidência verificável. Sinal E1.1: retry de validação. |
| 5 | Humano no controle por padrão | parcial | Sem interrupt/hearback externo, pydantic ai tende a agir rápido demais para o padrão HBN. Sinal E1.1: dependency injection. |
| 6 | Toda evolução deve ser reversível | parcial | Logs e outputs voltam; side effects de tools precisam rollback separado. Sinal E1.1: pydantic ai. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | O alvo mantém identidade se o agente não converter tudo para abstrações próprias. Sinal E1.1: pydantic ai. |
| 8 | O protocolo importa mais que a ferramenta | sim | Pydantic AI deve executar dentro do protocolo, não substituir ERP, markers ou registry. Sinal E1.1: pydantic ai. |
| 9 | Frameworks são descartáveis; princípios são permanentes | parcial | Como framework, precisa ser descartável; acoplamento a memória/handoffs enfraquece P9. Sinal E1.1: pydantic ai. |
| 10 | Segurança e não-regressão > velocidade | sim | Agentes combinam LLM e tools; permissões mínimas e dados sintéticos são pré-condição. Sinal E1.1: pydantic ai. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Pydantic Services Inc. + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: jovem, com base Pydantic madura; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se agentes tipados virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
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

- [Referência oficial/base](https://ai.pydantic.dev/)
- [Documentação técnica](https://github.com/pydantic/pydantic-ai)
- [Referência complementar](https://docs.pydantic.dev/)
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`
