---
titulo: FoxPro/dBase
slug: foxpro-dbase
categoria: legado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02
proxima-revisao: 2026-08-02
fonte-radar: "usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158"
licenca-target: usehbn (AGPLv3)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
---

# FoxPro/dBase

## Por que está no radar

FoxPro/dBase foi identificado no inventário E1 como tecnologia, estrutura ou dependência conceitual citada no ecossistema useHBN/Credenciamento. Fonte inicial: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158`.

Está marcado como `in-radar` porque foi citado como referência, alvo ou dependência conceitual, mas ainda não há ciclo operacional dedicado. O próximo passo é decidir se merece análise comparativa mais profunda.

## Resumo da tecnologia

Tecnologia ou ambiente legado com presença operacional em organizações reais. Entra no radar como alvo possível de fagocitose: preservar comportamento, extrair regras, documentar decisões e construir validação antes de refatorar. O foco inicial é conhecer a identidade da tecnologia, não convertê-la automaticamente para uma stack moderna.

No radar, a tecnologia é tratada de forma neutra: o registro não equivale a adoção. A função desta ficha é preservar contexto, explicitar riscos e manter uma trilha de decisão para Opus/Maurício antes de qualquer avanço de estado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa (1-2 linhas) |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | FoxPro/dBase pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 2 | Documentar antes de executar | parcial | FoxPro/dBase ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 3 | Testar antes de refatorar | parcial | FoxPro/dBase ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 4 | Explicar antes de automatizar | sim | FoxPro/dBase pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 5 | Humano no controle por padrão | parcial | FoxPro/dBase ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 6 | Toda evolução deve ser reversível | parcial | FoxPro/dBase ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | FoxPro/dBase pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 8 | O protocolo importa mais que a ferramenta | sim | FoxPro/dBase pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | FoxPro/dBase pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 10 | Segurança e não-regressão > velocidade | parcial | FoxPro/dBase ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |

## Divergências e riscos

- Risco de captura por ferramenta se FoxPro/dBase for promovido sem prova empírica.
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

- https://learn.microsoft.com/en-us/previous-versions/visualstudio/foxpro/
- ../../../usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25
