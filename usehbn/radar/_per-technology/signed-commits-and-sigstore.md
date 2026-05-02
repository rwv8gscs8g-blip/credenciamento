---
titulo: Signed commits and Sigstore
slug: signed-commits-and-sigstore
categoria: outros
estado: under-analysis
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02
proxima-revisao: 2026-06-02
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md"
licenca-target: usehbn (AGPLv3)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
---

# Signed commits and Sigstore

## Por que está no radar

Signed commits and Sigstore foi identificado no inventário E1 como tecnologia, estrutura ou dependência conceitual citada no ecossistema useHBN/Credenciamento. Fonte inicial: `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`.

Está marcado como `under-analysis` porque as fontes o citam como alternativa arquitetural ou ferramenta provável, mas ainda falta decisão humana ou validação empírica no `hbn-phago`. A ficha é conservadora e evita promover a tecnologia a candidata sem evidência operacional.

## Resumo da tecnologia

Tecnologia de governança, documentação, empacotamento ou automação do ecossistema useHBN. Entra no radar porque já aparece como parte do modo de trabalho ou como ferramenta candidata para futuras esteiras. O uso deve continuar subordinado aos princípios, especialmente licença, controle humano e reversibilidade.

No radar, a tecnologia é tratada de forma neutra: o registro não equivale a adoção. A função desta ficha é preservar contexto, explicitar riscos e manter uma trilha de decisão para Opus/Maurício antes de qualquer avanço de estado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa (1-2 linhas) |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 2 | Documentar antes de executar | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 3 | Testar antes de refatorar | parcial | Signed commits and Sigstore ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 4 | Explicar antes de automatizar | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 5 | Humano no controle por padrão | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 6 | Toda evolução deve ser reversível | parcial | Signed commits and Sigstore ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 8 | O protocolo importa mais que a ferramenta | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Signed commits and Sigstore pode reforçar este princípio quando usado como suporte explícito ao protocolo, com evidência e rastreabilidade. |
| 10 | Segurança e não-regressão > velocidade | parcial | Signed commits and Sigstore ajuda em parte, mas depende de disciplina de uso, limites claros e validação humana antes de virar regra. |

## Divergências e riscos

- Risco de captura por ferramenta se Signed commits and Sigstore for promovido sem prova empírica.
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
| 2026-05-02 | n/a | under-analysis | Entrada inicial no bootstrap E1 do Radar. | Codex CLI, sob spec Opus |

## Referências

- https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification
- ../../../local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md
