---
titulo: llms.txt
slug: llms-txt
categoria: outros
estado: phagocytosed
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "AGENTS.md:3-21,108-176"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: convenção comunitária
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# llms.txt

## Por que está no radar

A entrada aparece nas fontes do radar como mapa curado para LLMs. Interesse específico do useHBN: avaliar se llms.txt ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `AGENTS.md:3-21,108-176`. Estado atual: `phagocytosed`.

## Resumo da tecnologia

llms.txt é mapa curado para LLMs. Tecnicamente, lista links e contexto priorizado para leitura por LLMs. Recursos centrais:
- links curados
- contexto semântico
- baixo atrito
- RAG manual
- site docs

Diferencial para o radar: permite estudar mapa curado para LLMs com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: convenção comunitária. Mantenedor: llmstxt.org community. Maturidade: emergente e já usado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | links curados deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: links curados. |
| 2 | Documentar antes de executar | sim | contexto semântico facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: contexto semântico. |
| 3 | Testar antes de refatorar | parcial | baixo atrito pode virar fixture ou contrato; integração real ainda precisa harness. Sinal E1.1: baixo atrito. |
| 4 | Explicar antes de automatizar | sim | llms.txt torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: RAG manual. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de llms.txt; llmstxt.org community não decide transições do radar. Sinal E1.1: site docs. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: llms txt. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: llms txt. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: llms txt. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença convenção comunitária e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: llms txt. |
| 10 | Segurança e não-regressão > velocidade | parcial | RAG manual pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: llms txt. |

**Convergência média: 8/10 sim, 2/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: llmstxt.org community. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: emergente e já usado; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se mapa curado para LLMs virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: convenção comunitária; confirmar licença de código e termos de serviço antes de incorporar implementação.

## O que precisa para avançar de estado

- Definir POC pequeno, reversível e com dados sintéticos.
- Registrar entrada, saída, custo e rollback no ERP da esteira.
- Comparar contra alternativa mais simples baseada em arquivos/protocolo HBN puro.
- Só avançar de `phagocytosed` se o ganho for evidenciado por teste, log ou redução de risco.
- Se houver conteúdo TPGL envolvido, exigir consentimento e redaction-map antes de qualquer promoção pública.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | phagocytosed | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | phagocytosed | phagocytosed | Reescrita de conteúdo (E1.1 — Codex análise individual) | Codex CLI |

## Referências

- [Referência oficial/base](https://llmstxt.org/)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `AGENTS.md:3-21,108-176`
