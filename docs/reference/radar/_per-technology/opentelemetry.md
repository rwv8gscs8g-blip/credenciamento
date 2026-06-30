---
titulo: OpenTelemetry
slug: opentelemetry
categoria: observabilidade
estado: candidate
data-entrada: 2026-05-02
ultima-revisao: 2026-05-06 (APROVADA por Maurício — em processo de fagocitose progressiva)
proxima-revisao: 2026-06-06 (após O-A inicial)
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: Apache-2.0
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
arvore-hbn: development-branch (entrando); alvo: stable-trunk (Rust own implementation prevista)
papel-no-protocolo: tecnologia do módulo de fagocitose (instrumentação) + produto derivado usehbn-otel-rust (módulo separado eventualmente)
recomendacao-opus: APROVADA — fagocitose progressiva; alternativas Rust mais rápidas como padrão de mercado
decisao-final: APROVADA — em processo de fagocitose; integração com Consent Capsules (Rust) prevista
---

# OpenTelemetry

## Por que está no radar

OpenTelemetry (OTel) é a única tecnologia da categoria observabilidade que **é protocolo aberto, não produto**. Para o useHBN — onde P8 (protocolo > ferramenta) é princípio fundacional — OTel é a escolha arquitetural óbvia para instrumentação. Permite trocar Langfuse → Phoenix → vendor X → arquivo JSON local sem reescrever código instrumentado.

Para ciclos HBN (readback → execução → ERP), OTel pode capturar trace estruturado de cada etapa, exportar para arquivo local, e abrir caminho para análise posterior (regressões, tempo de cada microdelta, taxa de tokens por LLM call).

Fonte inicial: tese 38 §8, categoria observabilidade.

## Resumo da tecnologia

OpenTelemetry é especificação aberta + SDKs para telemetria de aplicações. Cobre três pilares: **traces** (cadeias causais de execução com timing e atributos), **métricas** (números agregados — counters, gauges, histograms), **logs** (eventos pontuais com timestamp e contexto). Mantida pela CNCF (Cloud Native Computing Foundation), graduada em maio/2024 (segundo projeto mais ativo da CNCF, atrás do Kubernetes).

Arquitetura:
- **API**: contratos abstratos por linguagem (Python, JS, Java, Go, .NET, Rust, Ruby, PHP, Swift, etc.)
- **SDK**: implementação default da API (Python: `opentelemetry-sdk`)
- **OTLP** (OpenTelemetry Protocol): formato wire para enviar telemetria — gRPC ou HTTP+protobuf/JSON
- **Collector**: processo intermediário que recebe OTLP, processa (filtros, sampling, redação), exporta para backends (Jaeger, Prometheus, Loki, Tempo, vendor SaaS)
- **Semantic Conventions**: nomes padronizados de atributos (HTTP, database, AI/LLM via `gen-ai`)

Ponto-chave arquitetural: **instrumentação é independente do backend**. Você usa OTel SDK uma vez; troca destino sem reescrever código.

Adoção em 2026: padrão de fato para observabilidade em aplicações cloud-native. Maior parte de APMs comerciais (Datadog, New Relic, Honeycomb) suporta OTLP nativamente. `gen-ai` semantic conventions cobrem LLM calls (input, output, tokens, model, temperature, latency).

Licença: Apache-2.0. Mantenedor: CNCF (foundation neutra). Maturidade: graduado, produção em escala global.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Instrumentação é aditiva: spans são lateral à execução; não alteram lógica do código instrumentado. Identidade do que é observado preservada. |
| 2 | Documentar antes de executar | sim | Traces viram documentação operacional viva — "como esse comando se executou em produção?". `gen-ai` semantic conventions definem campos obrigatórios. |
| 3 | Testar antes de refatorar | sim | Traces servem como **golden snapshot**: mudou trace = comportamento mudou. Útil para detectar regressões silenciosas em código LLM-based onde printf-debug é fraco. |
| 4 | Explicar antes de automatizar | sim | Traces tornam fluxo de execução explícito; debugging vira leitura visual de spans, não printf. Camada 3 (Compreensão) da tese 38 fica acessível. |
| 5 | Humano no controle por padrão | parcial | Telemetria é coleta, não decisão. Mas pode criar pressão "porque o gráfico fala" sobre humanos — risco de delegar julgamento ao dashboard. Mitigação: traces são entrada para decisão humana, nunca substituto. |
| 6 | Toda evolução deve ser reversível | sim | Trocar backend é trocar URL do Collector. Lock-in zero por design do protocolo. Pode-se desligar instrumentação a qualquer momento sem afetar comportamento. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | VBA, agentes, CLI continuam sendo o que são; OTel apenas observa. Spans não interferem em execução. |
| 8 | O protocolo importa mais que a ferramenta | sim | Este é o ponto fundacional do OTel — protocolo aberto > vendor. Match perfeito com P8 do useHBN. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | SDK trocável (cada linguagem tem implementação independente); especificação é fonte. Pode-se escrever instrumentação manual seguindo OTLP sem usar SDK oficial. |
| 10 | Segurança e não-regressão > velocidade | parcial | Traces podem capturar dados sensíveis (prompts LLM com PII, valores em queries SQL); precisa **redação no Collector ou via processador** antes de exportar. Sampling agressivo pode esconder regressões raras (mitigar com tail-based sampling). |

**Convergência média: 8/10 sim, 2/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: BAIXÍSSIMO — CNCF é foundation neutra; especificação é OSS Apache-2.0; múltiplas implementações independentes
- **Velocidade de evolução**: especificação OTLP estável (v1.0+ desde 2023); semantic conventions ainda evoluindo (`gen-ai` foi GA em 2025; pode mudar levemente)
- **Custo operacional**: Collector consome RAM (~100-500MB típico); traces volumosos exigem decisão de sampling. Para uso local (arquivo JSON), zero custo extra.
- **Lock-in técnico**: MÍNIMO (é o motivo de existir do OTel)
- **Compatibilidade AGPLv3**: Apache-2.0 é compatível (sublicenciável em AGPLv3)
- **Risco de over-instrumentation**: facilmente vira spam de spans sem valor; precisa disciplina de "instrumente o que importa" + revisão semanal
- **Complexidade inicial**: SDK Python tem ~5 conceitos (TracerProvider, Tracer, Span, Resource, SpanProcessor) — curva de aprendizado de 1-2 dias

## O que precisa para avançar de estado

Para `convergence-mapped` (recomendação Opus):
- POC: instrumentar um ciclo de readback HBN com OTel Python; exportar para arquivo OTLP-JSON local (zero deps de infra); validar leitura manual
- Decidir backend default para useHBN: arquivo JSON local (zero-deps, recomendado inicial) vs Jaeger self-hosted vs Langfuse open-source
- Definir semantic conventions específicas do useHBN: `hbn.esteira.id`, `hbn.marker`, `hbn.frente`, `hbn.principio.violado`, `hbn.licenca.target`
- Documentar pattern: "todo ciclo HBN cria trace; cada microdelta vira span; markers V2 viram events"

Para `candidate`:
- Decisão Maurício após POC mostrando trace lendo um readback → ERP completo
- Confirmar política de redação de payloads sensíveis antes de export (lições TPGL não vazam para trace público)
- Integração com `hbn weekly-review` (Wave 11+): comando lê traces e gera estatísticas

Para `phagocytosed`:
- OTel SDK em `usehbn-phago/pyproject.toml`
- Decorator `@hbn_traced` (helper) para instrumentação consistente
- Documentação operacional: como ler `.otlp-json` localmente

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | in-radar | in-radar | Reescrita E1.1 (Codex — análise template) | Codex CLI |
| 2026-05-02 | in-radar | in-radar | Análise profunda Opus — recomenda promoção a convergence-mapped | Claude Opus 4.7 (Frente 2) |
| **2026-05-06** | **in-radar** | **candidate** | **APROVADA por Maurício após estudo NotebookLM. Citação: "Open telemetry vai fazer parte do protocolo. Tem completa aderência. Podemos fazer uma evolução rica em termos de processo. Vamos analisar e incorporar progressivamente a evolução e as bordas da tecnologia até incorporá-la completamente, montarmos mapas de teste e criarmos alternativas em Rust mais rápidas e estáveis para funcionarem como padrão de mercado. Elas poderão utilizar integração com o Consent Capsules que já estarão em Rust." Promoção saltou convergence-mapped (decisão direta a candidate por aprovação explícita).** | **Maurício (palavra final)** |

## Nota de aprovação — racional Maurício 2026-05-06

OpenTelemetry entra em **processo de fagocitose progressiva** com 4 vetores:

1. **Análise das bordas da tecnologia** — entender API, SDK, OTLP, semantic conventions, Collector, exporters em profundidade
2. **Mapas de teste** — instrumentar casos reais (ciclos HBN, Tree-sitter parsing, Consent Capsules creation/validation)
3. **Alternativas Rust mais rápidas e estáveis** — implementar partes da spec em Rust nativo, podendo virar padrão de mercado se a comunidade adotar
4. **Integração com Consent Capsules** — spans assinados criptograficamente com Ed25519 (auditabilidade de telemetria); Consent Capsules já estará em Rust quando OTel atingir Árvore Estável

**Posicionamento estratégico**: OTel é o segundo grande módulo de fagocitose do useHBN, depois de Tree-sitter (parsing). Consent Capsules é módulo PARALELO (assinatura de código), não dentro do módulo de fagocitose.

**Roadmap de fagocitose progressiva** (a detalhar em documento dedicado após geração do prompt unificado ao Codex):

- Fase O-A: Estudo de bordas + mapas de teste em Python (Exploração)
- Fase O-B: Implementação Rust de partes críticas (instrumentação core + OTLP serializer)
- Fase O-C: Integração com Consent Capsules (spans com signed evidence)
- Fase O-D: Comparativo Rust own implementation vs `opentelemetry-rust` crate oficial — escolha entre adotar crate ou manter own
- Fase O-E: Promoção ao protocolo público com proposta de spec extension (semantic conventions `hbn.*` para integração com cápsulas)

## Referências

- [Documentação oficial](https://opentelemetry.io/docs/) — guia, conceitos, tutoriais
- [Repositório especificação](https://github.com/open-telemetry/opentelemetry-specification) — Apache-2.0
- [SDK Python](https://github.com/open-telemetry/opentelemetry-python) — implementação Python oficial
- [OTLP specification](https://opentelemetry.io/docs/specs/otlp/) — formato wire
- [Semantic conventions gen-ai](https://opentelemetry.io/docs/specs/semconv/gen-ai/) — para LLM/agents (relevante para hbn-phago)
- [Graduação CNCF (mai/2024)](https://www.cncf.io/announcements/2024/05/01/cncf-graduates-opentelemetry/) — anúncio oficial
- [Charity Majors — Observability vs Monitoring](https://charity.wtf/2017/02/22/why-observability-vs-monitoring/) — fundamentos do espaço
- Fonte interna: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206`
