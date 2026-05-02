---
titulo: agents.md
slug: agents-md
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

# agents.md

## Por que está no radar

A entrada aparece nas fontes do radar como instruções repo-local para IAs. Interesse específico do useHBN: avaliar se agents.md ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `AGENTS.md:3-21,108-176`. Estado atual: `phagocytosed`.

## Resumo da tecnologia

agents.md é instruções repo-local para IAs. Tecnicamente, arquivo Markdown no root com identidade, regras, comandos e limites. Recursos centrais:
- entrada única
- regras versionadas
- limites
- comandos
- contexto IA

Diferencial para o radar: permite estudar instruções repo-local para IAs com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: convenção comunitária. Mantenedor: agents.md community. Maturidade: emergente e já incorporado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | entrada única deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: entrada única. |
| 2 | Documentar antes de executar | sim | regras versionadas facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: regras versionadas. |
| 3 | Testar antes de refatorar | parcial | limites pode virar fixture ou contrato; integração real ainda precisa harness. Sinal E1.1: limites. |
| 4 | Explicar antes de automatizar | sim | agents.md torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: comandos. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de agents.md; agents.md community não decide transições do radar. Sinal E1.1: contexto IA. |
| 6 | Toda evolução deve ser reversível | sim | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: agents md. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: agents md. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: agents md. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | A licença convenção comunitária e o exit plan já conseguem permitir troca sem perda de conhecimento. Sinal E1.1: agents md. |
| 10 | Segurança e não-regressão > velocidade | sim | comandos pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: agents md. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: agents.md community. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: emergente e já incorporado; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se instruções repo-local para IAs virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
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

- [Referência oficial/base](https://agents.md/)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `AGENTS.md:3-21,108-176`
