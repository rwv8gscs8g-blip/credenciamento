---
titulo: Glasswing
slug: glasswing
categoria: outros
estado: phagocytosed
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: padrão local; alvo AGPLv3
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Glasswing

## Por que está no radar

A entrada aparece nas fontes do radar como guardrails preventivos. Interesse específico do useHBN: avaliar se Glasswing ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158`. Estado atual: `phagocytosed`.

## Resumo da tecnologia

Glasswing é guardrails preventivos. Tecnicamente, define G6/G7/G8, checks de hash, invariantes e cultura de bloqueio. Recursos centrais:
- G6
- G7
- G8
- pre-commit
- fail-fast

Diferencial para o radar: permite estudar guardrails preventivos com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: padrão local; alvo AGPLv3. Mantenedor: useHBN/Credenciamento. Maturidade: ativo como segurança preventiva.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | G6 deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: G6. |
| 2 | Documentar antes de executar | sim | G7 facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: G7. |
| 3 | Testar antes de refatorar | sim | G8 pode virar fixture ou contrato; integração real ainda já consegue harness. Sinal E1.1: G8. |
| 4 | Explicar antes de automatizar | sim | Glasswing torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: pre-commit. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de glasswing; useHBN/Credenciamento não decide transições do radar. Sinal E1.1: fail-fast. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: glasswing. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: glasswing. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: glasswing. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença padrão local; alvo AGPLv3 e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: glasswing. |
| 10 | Segurança e não-regressão > velocidade | sim | pre-commit pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: glasswing. |

**Convergência média: 10/10 sim, 0/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: useHBN/Credenciamento. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: ativo como segurança preventiva; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se guardrails preventivos virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: padrão local; alvo AGPLv3; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência pública useHBN](https://usehbn.org)
- Referência oficial/base: `usehbn/docs/INTEGRATION-GLASSWING.md`
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158`
