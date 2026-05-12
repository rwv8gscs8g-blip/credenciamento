---
titulo: Superprompt Notebook LM — OpenTelemetry (3 pilares + gen-ai)
diataxis: how-to
hbn-track: knowledge
audiencia: humano
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Superprompt Notebook LM — OpenTelemetry

## Como usar

1. Crie novo notebook: "useHBN — OpenTelemetry Deep Dive (com gen-ai)"
2. Upload das fontes
3. Cole "CONTEXTO"
4. Gere Audio Overview + Briefing + Mind map + FAQ

---

## CONTEXTO PARA COLAR

```text
Estudo profundo de OpenTelemetry (OTel) no contexto do projeto useHBN — protocolo aberto para evolução segura de tecnologias. Quero instrumentar ciclos HBN (readback → execução → ERP) para auditoria, detecção de regressão e análise de performance. OTel é candidata por ser PROTOCOLO ABERTO, não produto — alinhamento perfeito com o princípio P8 do useHBN ("o protocolo importa mais que a ferramenta").

Quero entender OTel em profundidade nas seguintes dimensões:

(a) **3 pilares** — traces, métricas, logs. Quando usar cada um? Como se complementam? Para o caso useHBN (ciclos HBN com chamadas LLM), quais pilares importam mais?

(b) **Arquitetura cliente-Collector-backend** — papel de cada componente. Quando usar Collector? Quando exportar direto da app? Como redação de dados sensíveis funciona?

(c) **Semantic conventions** — vocabulário padrão para HTTP, database, gen-ai (LLMs/agents). Como usar conventions corretas para que ferramentas downstream entendam? Como definir conventions próprias (`hbn.*`) para semântica useHBN?

(d) **Backends e ecossistema** — Jaeger, Tempo, Prometheus, Loki, Honeycomb, Datadog, Langfuse. Como Collector permite trocar backend sem reescrever código instrumentado? Trade-offs de cada backend?

(e) **Caso useHBN específico** — instrumentar 1 ciclo HBN com OTel; exportar para arquivo OTLP-JSON local (zero infra); definir conventions `hbn.esteira.id`, `hbn.marker`, `hbn.frente`. Como redact prompts LLM com PII antes de exportar?

CONTEXTO useHBN:
Os 10 princípios:
1. Preservar antes de transformar
2. Documentar antes de executar
3. Testar antes de refatorar
4. Explicar antes de automatizar
5. Humano no controle por padrão
6. Toda evolução deve ser reversível
7. Nenhuma tecnologia fagocitada perde sua identidade
8. O protocolo importa mais que a ferramenta
9. Frameworks são descartáveis; princípios são permanentes
10. Segurança e não-regressão > velocidade

OTel encarna especialmente P8 (protocolo aberto neutro), P6 (trocar backend = trocar URL do Collector — reversibilidade trivial) e P3 (traces = golden snapshots para detectar regressão).

PREOCUPAÇÃO OPERACIONAL: traces podem capturar dados sensíveis (prompts LLM com PII, valores em queries SQL). Como redação no Collector funciona? Como sampling agressivo pode esconder regressões raras (e como evitar com tail-based sampling)?
```

---

## FONTES PARA UPLOAD

### Fontes obrigatórias (5)

1. **[OpenTelemetry Documentation — Concepts](https://opentelemetry.io/docs/concepts/)** — fundamentos
2. **[OpenTelemetry Documentation — Python SDK](https://opentelemetry.io/docs/languages/python/)** — guia Python específico
3. **[OTLP Specification](https://opentelemetry.io/docs/specs/otlp/)** — wire protocol
4. **[Semantic Conventions — gen-ai](https://opentelemetry.io/docs/specs/semconv/gen-ai/)** — para LLM/agents
5. **[CNCF Graduation announcement (mai/2024)](https://www.cncf.io/announcements/2024/05/01/cncf-graduates-opentelemetry/)** — maturidade institucional

### Fundamentos teóricos (3)

6. **[Dapper paper (Google 2010)](https://research.google/pubs/dapper-a-large-scale-distributed-systems-tracing-infrastructure/)** — paper que originou tudo
7. **[W3C Trace Context standard](https://www.w3.org/TR/trace-context/)** — propagação cross-service
8. **[Charity Majors — Why Observability Matters Now (blog)](https://charity.wtf/2017/02/22/why-observability-vs-monitoring/)** — fundamentos do espaço

### Implementação prática (3)

9. **[opentelemetry-python GitHub](https://github.com/open-telemetry/opentelemetry-python)** — SDK Python oficial
10. **[OpenTelemetry Collector docs](https://opentelemetry.io/docs/collector/)** — Collector arquitetura
11. **[Honeycomb — sampling strategies](https://www.honeycomb.io/blog/dynamic-sampling-by-example)** — head-based vs tail-based

### Backends comparativos (3)

12. **[Jaeger documentation](https://www.jaegertracing.io/docs/)** — open-source backend tradicional
13. **[Grafana Tempo](https://grafana.com/oss/tempo/)** — alternativa open-source moderna
14. **[Langfuse open-source LLM observability](https://langfuse.com/docs/integrations/opentelemetry)** — LLM-specific backend

---

## PERGUNTAS PARA GERAÇÃO

```text
Deep Dive de 35-40 minutos sobre OpenTelemetry. Estruturem em cinco blocos:

BLOCO 1 — Fundamentos (8 min)
1. Por que tracing distribuído surgiu? Qual problema do Dapper?
2. Diferença entre observability e monitoring (Charity Majors)?
3. 3 pilares — quando cada um se aplica?
4. Trace, span, context — modelo mental claro

BLOCO 2 — Arquitetura OTel (10 min)
5. API vs SDK vs Exporter vs Processor — papel de cada
6. Quando usar Collector? Quando exportar direto?
7. Como Collector funciona (receivers, processors, exporters)?
8. OTLP wire protocol — gRPC vs HTTP, quando usar cada?
9. Resource (service.name, service.version) — por que importa?

BLOCO 3 — Semantic Conventions (8 min)
10. Por que conventions importam (interoperabilidade)?
11. HTTP, DB conventions — exemplos
12. gen-ai conventions especificamente — atributos para LLM calls
13. Como definir conventions próprias (`hbn.*`) sem quebrar interop?

BLOCO 4 — Sampling e dados sensíveis (8 min)
14. Head-based vs tail-based sampling — tradeoffs
15. Como redact dados sensíveis (PII, API keys) no Collector?
16. Como evitar over-instrumentation (spam de spans)?

BLOCO 5 — Adoção prática (8 min)
17. Como instrumentar Python (manual vs auto-instrumentation)?
18. Backends self-hosted — Jaeger vs Tempo vs Prometheus+Loki+Grafana?
19. Quando OTel é overkill (apps pequenos)?
20. Como começar pequeno (arquivo OTLP-JSON local) e crescer?

DESEJO ESPECIAL: na parte de gen-ai conventions e na parte de redação de dados sensíveis, sejam específicos e práticos — não fiquem em generalidades.
```

---

## PERSONA DE AUDIÊNCIA

```text
Audiência: arquiteto técnico construindo protocolo de evolução de tecnologias. Já fez logging estruturado mas nunca implementou tracing distribuído. Apreciou o argumento de que OTel "é protocolo, não produto" e quer validar isso em profundidade. Preocupado com (a) overhead de instrumentação, (b) vazamento de dados sensíveis em traces, (c) lock-in acidental por backend escolhido. Tom: técnico-prático; mostre código quando útil; explique tradeoffs sem religiosidade.
```

---

## OUTPUTS SOLICITADOS

- [ ] Audio Overview (~35-40 min)
- [ ] Briefing document com diagrama de arquitetura OTel
- [ ] Mind map: 3 pilares + arquitetura + semantic conventions
- [ ] FAQ sobre adoção pragmática

## Versão

- v1.0 — 2026-05-02 — superprompt inicial.
