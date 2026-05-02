---
titulo: Typer
slug: typer
categoria: outros
estado: under-analysis
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-06-02
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Typer

## Por que está no radar

A entrada aparece nas fontes do radar como framework CLI Python. Interesse específico do useHBN: avaliar se Typer ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`. Estado atual: `under-analysis`.

## Resumo da tecnologia

Typer é framework CLI Python. Tecnicamente, transforma funções tipadas em comandos Click com help e autocompletion. Recursos centrais:
- type hints
- Click
- autocompletion
- help automático
- nested commands

Diferencial para o radar: permite estudar framework CLI Python com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: MIT. Mantenedor: Sebastián Ramírez + comunidade. Maturidade: maduro para CLIs Python.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | type hints deve operar sobre artefatos existentes sem virar fonte única. Sinal E1.1: type hints. |
| 2 | Documentar antes de executar | sim | Click facilita documentação se schema, limites e decisão local vierem antes do uso. Sinal E1.1: Click. |
| 3 | Testar antes de refatorar | parcial | autocompletion pode virar fixture ou contrato; integração real ainda precisa harness. Sinal E1.1: autocompletion. |
| 4 | Explicar antes de automatizar | sim | Typer torna estrutura ou fluxo visível, mas automação só depois de exemplos revisados. Sinal E1.1: help automático. |
| 5 | Humano no controle por padrão | sim | Controle humano fica fora de typer; Sebastián Ramírez + comunidade não decide transições do radar. Sinal E1.1: nested commands. |
| 6 | Toda evolução deve ser reversível | parcial | Reversível quando saídas são pequenas, diffáveis e recriáveis; estado oculto é bloqueio. Sinal E1.1: typer. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Funciona como camada de leitura/índice sem apagar a tecnologia fagocitada. Sinal E1.1: typer. |
| 8 | O protocolo importa mais que a ferramenta | sim | Permanece peça descartável ao redor do protocolo; registry e histórico seguem infunciona melhor quandontes. Sinal E1.1: typer. |
| 9 | Frameworks são descartáveis; princípios são permanentes | parcial | A licença MIT e o exit plan precisam permitir troca sem perda de conhecimento. Sinal E1.1: typer. |
| 10 | Segurança e não-regressão > velocidade | parcial | help automático pode expor dados ou acionar serviços; sandbox e threat model são obrigatórios. Sinal E1.1: typer. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Sebastián Ramírez + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro para CLIs Python; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se framework CLI Python virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: MIT; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://typer.tiangolo.com/)
- Documentação técnica: `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- Fonte radar: `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`
