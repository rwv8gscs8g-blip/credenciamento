---
titulo: Arize Phoenix
slug: arize-phoenix
categoria: observabilidade
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: Apache-2.0
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Arize Phoenix

## Por que está no radar

A entrada aparece nas fontes do radar como observabilidade local/OSS. Interesse específico do useHBN: avaliar se Arize Phoenix ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206`. Estado atual: `in-radar`.

## Resumo da tecnologia

Arize Phoenix é observabilidade local/OSS. Tecnicamente, usa OpenInference/OpenTelemetry para traces, UI local e avaliação de RAG/LLM. Recursos centrais:
- tracing OpenInference
- UI local
- evals RAG/LLM
- datasets
- OTel

Diferencial para o radar: permite estudar observabilidade local/OSS com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: Apache-2.0. Mantenedor: Arize AI + comunidade. Maturidade: maduro para tracing/evals LLM e RAG.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Registra contexto de execução, mas preservação depende de apontar traces para commits e artefatos originais. Sinal E1.1: tracing OpenInference. |
| 2 | Documentar antes de executar | sim | tracing OpenInference transforma execução em evidência auditável quando os campos são descritos no ERP. Sinal E1.1: UI local. |
| 3 | Testar antes de refatorar | sim | UI local permite comparar runs e detectar regressões com mais precisão que leitura manual. Sinal E1.1: evals RAG/LLM. |
| 4 | Explicar antes de automatizar | parcial | Explica latência, inputs e outputs; interpretação final ainda precisa de comentário humano. Sinal E1.1: datasets. |
| 5 | Humano no controle por padrão | parcial | Dashboards informam, mas não aprovam transição de estado; Maurício/Opus continuam decisores. Sinal E1.1: OTel. |
| 6 | Toda evolução deve ser reversível | sim | Reversibilidade funciona melhor quando de exportar evals RAG/LLM para formato local, não apenas UI do fornecedor. Sinal E1.1: arize phoenix. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Observa VBA/agentes/CLI sem alterar sua identidade; trace é evidência, não fonte primária. Sinal E1.1: arize phoenix. |
| 8 | O protocolo importa mais que a ferramenta | sim | Converge se arize phoenix for backend trocável; delta card e ERP seguem canônicos. Sinal E1.1: arize phoenix. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Arize AI + comunidade não pode virar guardião exclusivo da verdade operacional. Sinal E1.1: arize phoenix. |
| 10 | Segurança e não-regressão > velocidade | sim | Ajuda segurança ao revelar vazamentos/regressões, mas dados TPGL em spans exigem redação. Sinal E1.1: arize phoenix. |

**Convergência média: 7/10 sim, 3/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Arize AI + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro para tracing/evals LLM e RAG; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se observabilidade local/OSS virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: Apache-2.0; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://docs.arize.com/phoenix)
- [Documentação técnica](https://github.com/Arize-ai/phoenix)
- [Referência complementar](https://github.com/Arize-ai/openinference)
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206`
