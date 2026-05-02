---
titulo: JSONL event ledger
slug: jsonl-event-ledger
categoria: conhecimento-estruturado
estado: under-analysis
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-06-02
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: formato aberto; conteúdo varia
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# JSONL event ledger

## Por que está no radar

A entrada aparece nas fontes do radar como eventos append-only. Interesse específico do useHBN: avaliar se JSONL event ledger ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`. Estado atual: `under-analysis`.

## Resumo da tecnologia

JSONL event ledger é eventos append-only. Tecnicamente, cada linha é JSON independente, bom para replay, jq e append sem reescrita. Recursos centrais:
- append-only
- replay
- jq/grep
- streaming
- eventos versionados

Diferencial para o radar: permite estudar eventos append-only com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: formato aberto; conteúdo varia. Mantenedor: jsonlines.org/práticas append-only. Maturidade: maduro como log simples.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | append-only deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: append-only. |
| 2 | Documentar antes de executar | sim | replay facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: replay. |
| 3 | Testar antes de refatorar | sim | jq/grep pode virar fixture ou contrato; integração real ainda já consegue harness. Sinal E1.1: jq/grep. |
| 4 | Explicar antes de automatizar | parcial | JSONL event ledger torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: streaming. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de jsonl event ledger; jsonlines.org/práticas append-only não decide transições do radar. Sinal E1.1: eventos versionados. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: jsonl event ledger. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: jsonl event ledger. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: jsonl event ledger. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença formato aberto; conteúdo varia e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: jsonl event ledger. |
| 10 | Segurança e não-regressão > velocidade | sim | streaming pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: jsonl event ledger. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: jsonlines.org/práticas append-only. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro como log simples; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se eventos append-only virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: formato aberto; conteúdo varia; confirmar licença de código e termos de serviço antes de incorporar implementação.

## O que precisa para avançar de estado

- Definir POC pequeno, reversível e com dados sintéticos.
- Registrar entrada, saída, custo e rollback no ERP da esteira.
- Comparar contra alternativa mais simples baseada em arquivos/protocolo HBN puro.
- Só avançar de `under-analysis` se o ganho for evidenciado por teste, log ou redução de risco.
- Se houver conteúdo TPGL envolvido, exigir consentimento e redaction-map antes de qualquer promoção pública.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | under-analysis | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | under-analysis | under-analysis | Reescrita de conteúdo (E1.1 — Codex análise individual) | Codex CLI |

## Referências

- [Referência oficial/base](https://jsonlines.org/)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`
