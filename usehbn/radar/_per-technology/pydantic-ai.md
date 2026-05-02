---
titulo: Pydantic AI
slug: pydantic-ai
categoria: agentes
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198"
licenca-target: usehbn (AGPLv3)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
---

# Pydantic AI

## Por que está no radar

Pydantic AI foi identificado no inventário E1 como tecnologia, estrutura ou dependência conceitual citada no ecossistema useHBN/Credenciamento. Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198`.

Está marcado como `in-radar` porque foi citado como referência, alvo ou dependência conceitual, mas ainda não há ciclo operacional dedicado. O próximo passo é decidir se merece análise comparativa mais profunda.

## Resumo da tecnologia

Tecnologia de orquestração ou construção de agentes de IA. Entra no radar porque promete coordenação, memória operacional, ferramentas e papéis especializados. Para o useHBN, o interesse não é adotar o framework por hype, mas observar se seus padrões ajudam a tornar ciclos humano-IA mais previsíveis, auditáveis e reversíveis.

No radar, a tecnologia é tratada de forma neutra: o registro não equivale a adoção. A função desta ficha é preservar contexto, explicitar riscos e manter uma trilha de decisão para Opus/Maurício antes de qualquer avanço de estado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa (1-2 linhas) |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 2 | Documentar antes de executar | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 3 | Testar antes de refatorar | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 4 | Explicar antes de automatizar | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 5 | Humano no controle por padrão | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 6 | Toda evolução deve ser reversível | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 8 | O protocolo importa mais que a ferramenta | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 9 | Frameworks são descartáveis; princípios são permanentes | não | Pydantic AI tende a competir com este princípio se virar dependência central; por isso fica apenas observado. |
| 10 | Segurança e não-regressão > velocidade | parcial | Pydantic AI ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |

## Divergências e riscos

- Risco de captura por ferramenta se Pydantic AI for promovido sem prova empírica.
- Risco de documentação alucinatória se a ficha virar premissa sem validação por fonte oficial, código real ou caso de uso local.
- Risco de licença, privacidade ou reversibilidade quando a tecnologia cruza dados do Credenciamento e artefatos AGPLv3 do useHBN.

## O que precisa para avançar de estado

- Confirmar fontes oficiais e casos de uso mínimos.
- Definir um experimento pequeno, reversível e auditável.
- Registrar evidência objetiva no ERP da esteira correspondente.
- Obter decisão humana explícita quando a transição for `convergence-mapped` → `candidate`.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar. | Codex CLI, sob spec Opus |

## Referências

- https://ai.pydantic.dev/
- ../../../auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198
