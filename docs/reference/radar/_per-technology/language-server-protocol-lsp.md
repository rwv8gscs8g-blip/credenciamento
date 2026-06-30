---
titulo: Language Server Protocol (LSP)
slug: language-server-protocol-lsp
categoria: conhecimento-estruturado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: standard aberto; implementações variam
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Language Server Protocol (LSP)

## Por que está no radar

A entrada aparece nas fontes do radar como protocolo editor-servidor. Interesse específico do useHBN: avaliar se Language Server Protocol (LSP) ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`. Estado atual: `in-radar`.

## Resumo da tecnologia

Language Server Protocol (LSP) é protocolo editor-servidor. Tecnicamente, JSON-RPC para diagnostics, completion, hover, definition e symbols. Recursos centrais:
- diagnostics
- completion
- hover
- references
- workspace symbols

Diferencial para o radar: permite estudar protocolo editor-servidor com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: standard aberto; implementações variam. Mantenedor: Microsoft + comunidade. Maturidade: maduro em IDEs.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | diagnostics deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: diagnostics. |
| 2 | Documentar antes de executar | sim | completion facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: completion. |
| 3 | Testar antes de refatorar | sim | hover pode virar fixture ou contrato; integração real ainda já consegue harness. Sinal E1.1: hover. |
| 4 | Explicar antes de automatizar | sim | Language Server Protocol (LSP) torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: references. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de language server protocol (lsp); Microsoft + comunidade não decide transições do radar. Sinal E1.1: workspace symbols. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: language server protocol lsp. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: language server protocol lsp. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: language server protocol lsp. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença standard aberto; implementações variam e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: language server protocol lsp. |
| 10 | Segurança e não-regressão > velocidade | parcial | references pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: language server protocol lsp. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Microsoft + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro em IDEs; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se protocolo editor-servidor virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: standard aberto; implementações variam; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://microsoft.github.io/language-server-protocol/)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`
