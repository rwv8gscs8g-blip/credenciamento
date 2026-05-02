---
titulo: Characterization tests
slug: characterization-tests
categoria: conhecimento-estruturado
estado: phagocytosed
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229"
licenca-target: usehbn (AGPLv3)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
---

# Characterization tests

## Por que está no radar

Characterization tests foi identificado no inventário E1 como tecnologia, estrutura ou dependência conceitual citada no ecossistema useHBN/Credenciamento. Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`.

Está marcado como `phagocytosed` porque já aparece incorporado no modo de trabalho do Credenciamento/useHBN ou no caso empírico VBA. A ficha registra o estado atual e preserva a identidade do artefato para que futuras promoções públicas não apaguem a origem local.

## Resumo da tecnologia

Tecnologia ou formato para representar conhecimento, estrutura de código, semântica ou documentação versionável. Entra no radar como infraestrutura possível para fichas, lições, mapas, schemas e ingestão segura. O critério central é se ela ajuda humanos e IAs a explicar antes de automatizar.

No radar, a tecnologia é tratada de forma neutra: o registro não equivale a adoção. A função desta ficha é preservar contexto, explicitar riscos e manter uma trilha de decisão para Opus/Maurício antes de qualquer avanço de estado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa (1-2 linhas) |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 2 | Documentar antes de executar | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 3 | Testar antes de refatorar | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 4 | Explicar antes de automatizar | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 5 | Humano no controle por padrão | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 6 | Toda evolução deve ser reversível | parcial | Characterization tests ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 8 | O protocolo importa mais que a ferramenta | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 10 | Segurança e não-regressão > velocidade | sim | Characterization tests pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |

## Divergências e riscos

- Risco de captura por ferramenta se Characterization tests for promovido sem prova empírica.
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
| 2026-05-02 | n/a | phagocytosed | Entrada inicial no bootstrap E1 do Radar. | Codex CLI, sob spec Opus |

## Referências

- https://martinfowler.com/bliki/CharacterizationTest.html
- ../../../auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229
