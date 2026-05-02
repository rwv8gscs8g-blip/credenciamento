---
titulo: Abstract Syntax Trees (AST)
slug: abstract-syntax-trees-ast
categoria: conhecimento-estruturado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: conceito; implementações variam
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Abstract Syntax Trees (AST)

## Por que está no radar

A entrada aparece nas fontes do radar como estrutura sintática. Interesse específico do useHBN: avaliar se Abstract Syntax Trees (AST) ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`. Estado atual: `in-radar`.

## Resumo da tecnologia

Abstract Syntax Trees (AST) é estrutura sintática. Tecnicamente, representa código como árvore de nós tipados com ranges e filhos. Recursos centrais:
- nós tipados
- ranges
- análise estática
- refactors
- geração de docs

Diferencial para o radar: permite estudar estrutura sintática com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: conceito; implementações variam. Mantenedor: toolchains de linguagem. Maturidade: maduro em compiladores.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | nós tipados deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: nós tipados. |
| 2 | Documentar antes de executar | sim | ranges facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: ranges. |
| 3 | Testar antes de refatorar | sim | análise estática pode virar fixture ou contrato; integração real ainda já consegue harness. Sinal E1.1: análise estática. |
| 4 | Explicar antes de automatizar | sim | Abstract Syntax Trees (AST) torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: refactors. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de abstract syntax trees (ast); toolchains de linguagem não decide transições do radar. Sinal E1.1: geração de docs. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: abstract syntax trees ast. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: abstract syntax trees ast. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: abstract syntax trees ast. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença conceito; implementações variam e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: abstract syntax trees ast. |
| 10 | Segurança e não-regressão > velocidade | parcial | refactors pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: abstract syntax trees ast. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: toolchains de linguagem. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro em compiladores; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se estrutura sintática virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: conceito; implementações variam; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://tree-sitter.github.io/tree-sitter/using-parsers)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`
