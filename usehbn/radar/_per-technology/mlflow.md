---
titulo: MLflow
slug: mlflow
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

# MLflow

## Por que está no radar

A entrada aparece nas fontes do radar como tracking de experimentos ML. Interesse específico do useHBN: avaliar se MLflow ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206`. Estado atual: `in-radar`.

## Resumo da tecnologia

MLflow é tracking de experimentos ML. Tecnicamente, registra runs com parâmetros, métricas, artefatos e modelos em backend configurável. Recursos centrais:
- experiment tracking
- artifact store
- model registry
- projects
- integrações ML

Diferencial para o radar: permite estudar tracking de experimentos ML com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: Apache-2.0. Mantenedor: Databricks + comunidade. Maturidade: muito maduro em MLOps.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | parcial | Registra contexto de execução, mas preservação depende de apontar traces para commits e artefatos originais. Sinal E1.1: experiment tracking. |
| 2 | Documentar antes de executar | sim | experiment tracking transforma execução em evidência auditável quando os campos são descritos no ERP. Sinal E1.1: artifact store. |
| 3 | Testar antes de refatorar | sim | artifact store permite comparar runs e detectar regressões com mais precisão que leitura manual. Sinal E1.1: model registry. |
| 4 | Explicar antes de automatizar | parcial | Explica latência, inputs e outputs; interpretação final ainda precisa de comentário humano. Sinal E1.1: projects. |
| 5 | Humano no controle por padrão | parcial | Dashboards informam, mas não aprovam transição de estado; Maurício/Opus continuam decisores. Sinal E1.1: integrações ML. |
| 6 | Toda evolução deve ser reversível | sim | Reversibilidade funciona melhor quando de exportar model registry para formato local, não apenas UI do fornecedor. Sinal E1.1: mlflow. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | parcial | Observa VBA/agentes/CLI sem alterar sua identidade; trace é evidência, não fonte primária. Sinal E1.1: mlflow. |
| 8 | O protocolo importa mais que a ferramenta | parcial | Converge se mlflow for backend trocável; delta card e ERP seguem canônicos. Sinal E1.1: mlflow. |
| 9 | Frameworks são descartáveis; princípios são permanentes | parcial | Databricks + comunidade não pode virar guardião exclusivo da verdade operacional. Sinal E1.1: mlflow. |
| 10 | Segurança e não-regressão > velocidade | sim | Ajuda segurança ao revelar vazamentos/regressões, mas dados TPGL em spans exigem redação. Sinal E1.1: mlflow. |

**Convergência média: 4/10 sim, 6/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Databricks + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: muito maduro em MLOps; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se tracking de experimentos ML virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
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

- [Referência oficial/base](https://mlflow.org/docs/latest/)
- [Documentação técnica](https://github.com/mlflow/mlflow)
- [Referência complementar](https://mlflow.org/docs/latest/tracking.html)
- Fonte radar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206`
