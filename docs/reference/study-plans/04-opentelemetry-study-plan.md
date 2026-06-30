---
titulo: Plano de Estudo Profundo — OpenTelemetry (3 pilares + gen-ai)
diataxis: tutorial
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
tempo-estimado: 5-7 horas (incluindo Notebook LM)
licenca-target: usehbn (AGPLv3)
ficha-radar: ../radar/_per-technology/opentelemetry.md
---

# Plano de Estudo Profundo — OpenTelemetry

## Por que estudar profundo

Maurício: "Open telemetry faz uma proposta de integração muito objetiva e também merece a linha de estudo."

OTel é o protocolo de observabilidade do ecossistema cloud-native. Para o useHBN, é a forma arquiteturalmente correta de instrumentar ciclos HBN sem lock-in de fornecedor. Este plano cobre os 3 pilares (traces, métricas, logs), arquitetura cliente-Collector-backend, e o caso específico `gen-ai` semantic conventions (relevante para LLM calls).

## Visão geral em 3 níveis

### Nível 1 — uma frase
OpenTelemetry (OTel) é um padrão aberto para coleta, processamento e export de telemetria de aplicações (traces, métricas, logs), mantido pela CNCF.

### Nível 2 — um parágrafo
Lançado em 2019 da fusão de OpenTracing (CNCF, 2016) + OpenCensus (Google, 2017), OpenTelemetry consolidou o espaço fragmentado de instrumentação. Define APIs, SDKs e o protocolo wire OTLP para enviar dados a backends (Jaeger, Tempo, Prometheus, Loki, vendors SaaS). A separação **API ↔ SDK ↔ Exporter** permite trocar destino sem reescrever código instrumentado — propriedade rara que match perfeito com P8 do useHBN. Graduado pela CNCF em maio/2024 (segundo projeto mais ativo, atrás do Kubernetes).

### Nível 3 — visão arquitetural
A inovação não é técnica (traces e spans existem desde Dapper 2010); é **organizacional**. CNCF como casa neutra evita que cada vendor tenha SDK próprio incompatível. Resultado: um SDK Python único; troca-se Datadog → New Relic → Honeycomb → Jaeger self-hosted via configuração. Para useHBN, OTel resolve o problema de "como instrumentar ciclos HBN sem amarrar a um fornecedor".

## Pré-requisitos

| Pré-req | Por que importa |
|---|---|
| Conceito de logging estruturado | Spans são logs estruturados com timing |
| Async Python | OTel SDK Python suporta sync e async |
| Context propagation conceitual | Como spans relacionam entre threads/processos |
| Distributed systems básico | Para entender por que traces importam |

## Conceitos fundamentais

### Bloco A — 3 pilares da observabilidade (1.5h)

1. **Traces** (cadeias causais)
   - Span = unidade de trabalho (com nome, timing, atributos, eventos)
   - Trace = árvore de spans relacionados (root → children)
   - Trace ID = UUID que liga tudo
   - Span ID = identificador único de span
   - Parent-child = relação causal
2. **Métricas** (números agregados)
   - Counter (monotônico crescente)
   - Gauge (valor atual)
   - Histogram (distribuição)
   - Asynchronous instruments (pull vs push)
3. **Logs** (eventos pontuais)
   - Estruturados (JSON com fields)
   - Linked com traces via trace_id

### Bloco B — Arquitetura OTel (1h)

```text
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Aplicação      │     │   OTel SDK      │     │  Backend(s)     │
│ (instrumentada) │────▶│  + Processors   │────▶│  Jaeger/Tempo/  │
│                 │ API │  + Exporters    │OTLP │  Prometheus/etc │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │
                                ▼ (opcional intermediário)
                        ┌─────────────────┐
                        │ OTel Collector  │
                        │ (filtros, sampl,│
                        │  redação, fan-out)
                        └─────────────────┘
```

Componentes:
- **API**: contratos abstratos por linguagem (`Tracer`, `Span`, `Meter`, `Logger`)
- **SDK**: implementação default (Python: `opentelemetry-sdk`)
- **Exporter**: como dados saem (OTLP, Console, Jaeger, Zipkin, file)
- **Processor**: middleware (BatchSpanProcessor, SimpleSpanProcessor)
- **Resource**: metadata do "produtor" (service.name, service.version)
- **Context**: propaga trace_id entre threads/processos
- **Collector**: processo Go autônomo entre app e backend (filtragem, redação, sampling, fan-out)

### Bloco C — OTLP wire protocol (1h)

- Protobuf-defined (alternativamente JSON)
- Transporte: gRPC (default) ou HTTP/protobuf ou HTTP/JSON
- Endpoint padrão: `localhost:4317` (gRPC) / `localhost:4318` (HTTP)
- Compressão: gzip
- Authentication: headers (`Authorization`, `api-key`)

### Bloco D — Semantic Conventions (1h)

OTel define vocabulário padrão de attribute names. Áreas:

- **HTTP**: `http.method`, `http.status_code`, `http.url`
- **Database**: `db.system`, `db.statement`, `db.operation`
- **Messaging**: `messaging.system`, `messaging.destination`
- **gen-ai** (relevante para LLMs):
  - `gen_ai.system` (openai, anthropic, etc.)
  - `gen_ai.request.model`
  - `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens`
  - `gen_ai.response.finish_reasons`
  - `gen_ai.request.temperature`, `top_p`, etc.

Para useHBN: definir extensões próprias `hbn.*`:
- `hbn.esteira.id`
- `hbn.marker` (ex.: "🟢 HBN CHECKPOINT CLEAN")
- `hbn.frente` (1 ou 2)
- `hbn.principio.violado` (se aplicável)

## Fontes primárias

### Documentação
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/) — entrada principal
- [Concepts](https://opentelemetry.io/docs/concepts/) — fundamentos
- [Python SDK](https://opentelemetry.io/docs/languages/python/) — guia Python específico
- [OTLP Specification](https://opentelemetry.io/docs/specs/otlp/) — wire protocol
- [Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/) — todos os domínios
- [Gen-AI conventions](https://opentelemetry.io/docs/specs/semconv/gen-ai/) — LLM/agents

### Código-fonte
- [opentelemetry-python](https://github.com/open-telemetry/opentelemetry-python) — Apache-2.0
- [opentelemetry-collector](https://github.com/open-telemetry/opentelemetry-collector) — Go
- [opentelemetry-specification](https://github.com/open-telemetry/opentelemetry-specification) — spec authoritative

### Anúncios e graduação
- [CNCF Graduation announcement (mai/2024)](https://www.cncf.io/announcements/2024/05/01/cncf-graduates-opentelemetry/)
- [OpenTelemetry Project History](https://opentelemetry.io/community/) — fusão OpenTracing+OpenCensus

## Fontes secundárias

### Livros (escolher 1)
- **"Cloud-Native Observability" — Charity Majors et al.** (O'Reilly) — fundamentos
- **"Observability Engineering" — Charity Majors, Liz Fong-Jones, George Miranda** (O'Reilly) — práticas

### Artigos seminais
- **"Dapper, a Large-Scale Distributed Systems Tracing Infrastructure" — Google (2010)** — paper original que originou OpenTracing/OTel
- [Charity Majors — "Why Observability Matters Now"](https://charity.wtf/) — blog inspiracional
- [Honeycomb — "Observability ≠ Three Pillars"](https://www.honeycomb.io/blog/) — visão alternativa

### Vídeos
- [KubeCon talks on OpenTelemetry](https://www.youtube.com/c/cloudnativefdn) — vários
- [Liz Fong-Jones talks](https://www.youtube.com/results?search_query=liz+fong-jones+observability)

## Hands-on exercises

### Exercício 1 — Setup local (30 min)
```bash
uv add opentelemetry-api opentelemetry-sdk opentelemetry-exporter-otlp-proto-grpc
```
Hello World tracing — span único exportado para console.

### Exercício 2 — Trace estruturado (45 min)
Função fictícia com spans aninhados:
```python
def parse_file(path):
    with tracer.start_as_current_span("parse_file") as span:
        span.set_attribute("file.path", path)
        with tracer.start_as_current_span("read_bytes"):
            ...
        with tracer.start_as_current_span("tree_sitter_parse"):
            ...
```

### Exercício 3 — Exportar para arquivo OTLP-JSON (45 min)
- Custom exporter que escreve em arquivo `.otlp-json` local
- Útil para useHBN onde Maurício prefere file vs SaaS inicialmente
- Verificar parseabilidade do arquivo

### Exercício 4 — Collector local (1h)
- Rodar Collector em Docker
- Configurar receiver OTLP + exporter file
- Demonstrar fan-out: mesmo trace para arquivo + Jaeger UI

### Exercício 5 — gen-ai conventions (1h)
- Instrumentar chamada para Anthropic API
- Usar atributos `gen_ai.*` corretos
- Visualizar trace em Jaeger/Tempo

### Exercício 6 — Semantic conventions HBN próprias (1h)
- Definir vocabulário `hbn.*`
- Instrumentar simulação de ciclo HBN
- Trace deve mostrar etapas do readback → execução → ERP

## Perguntas para aprofundamento

1. Diferença prática entre OTel e OpenTracing/OpenCensus que ele substituiu?
2. Quando usar Collector e quando não usar?
3. Sampling: head-based vs tail-based — quando cada um?
4. Como redact dados sensíveis (PII, API keys) antes de exportar?
5. Performance overhead de instrumentação — típico vs pior caso?
6. Auto-instrumentation vs manual — quando preferir cada?
7. Como compor com logs estruturados existentes?
8. Backends self-hosted (Tempo, Jaeger, SigNoz) — comparativo?
9. Como instrumentar código async (asyncio) corretamente?
10. Context propagation entre processos (subprocess, distributed)?

## Conexão com os 10 princípios useHBN

| Princípio | Como OTel encarna |
|---|---|
| **P1 — Preservar antes de transformar** | Instrumentação aditiva, não-modificativa |
| **P2 — Documentar antes de executar** | Traces = doc operacional viva |
| **P3 — Testar antes de refatorar** | Traces como golden snapshots de comportamento |
| **P6 — Reversibilidade** | Trocar backend é trocar URL do Collector |
| **P8 — Protocolo > ferramenta** | OTel **é** protocolo (encaixe fundamental) |
| **P9 — Frameworks descartáveis** | SDK trocável; spec é fonte |
| **P10 — Segurança > velocidade** | Redação no Collector pode sanitizar antes de exportar |

## Critérios de "estudei o suficiente"

- [ ] Explicar 3 pilares (traces, métricas, logs) e quando usar cada um
- [ ] Diferenciar API, SDK, Exporter, Processor, Collector
- [ ] Instrumentar função Python e visualizar trace
- [ ] Definir 5 semantic conventions `hbn.*` próprias
- [ ] Decidir se vale incorporar OTel no `hbn-phago` (gate G2/G3)

## Sequência sugerida (6 horas distribuídas)

1. **Hora 1** — Docs OTel Concepts + 3 pilares
2. **Hora 2** — Python SDK docs + arquitetura
3. **Hora 3** — Notebook LM podcast (gerado pelo superprompt)
4. **Hora 4** — Exercícios 1-3
5. **Hora 5** — Exercícios 4-5
6. **Hora 6** — Exercício 6 + perguntas

## Versão

- v1.0 — 2026-05-02 — plano inicial.
