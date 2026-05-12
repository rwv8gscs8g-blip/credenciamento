---
titulo: Protocolo de Auditoria Cruzada entre IAs — antes de fechar esteira de desenvolvimento
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06
autor: Claude Opus 4.7 (Frente 2) após pedido de Maurício 2026-05-06
licenca-target: usehbn (AGPLv3)
status: protocolo declarado nesta sessão; primeira aplicação prevista no fechamento R-A do Consent Capsules
modulo-do-usehbn: Módulo 6 — Auditoria Cruzada (ver USEHBN-MODULES-ARCHITECTURE.md)
---

# Protocolo de Auditoria Cruzada entre IAs

## Origem — pedido operacional de Maurício

Em 2026-05-06, ao aprovar Consent Capsules e OpenTelemetry, Maurício pediu (citação operacional):

> "Antes do desenvolvimento vamos fazer a auditoria cruzada entre as IAs para documentar todos os processos de pedir soluções antes de fecharmos a esteira de desenvolvimento."

Este documento formaliza a auditoria cruzada como **processo padrão** antes de qualquer fechamento de esteira no useHBN. Estabelece o **6º módulo** declarado do useHBN (junto com fagocitose, Consent Capsules, coordenação inter-IA, segurança e markers V2).

## Por que auditoria cruzada importa

Sem auditoria cruzada, o useHBN seria refém da IA que primeiro tocou o problema. Com auditoria cruzada:

- **Decisões ganham robustez** — múltiplas perspectivas testam o mesmo problema
- **Vieses individuais de IAs são neutralizados** — Claude tem padrões; Codex tem padrões; Antigravity tem padrões; cruzar reduz blind spots
- **Documentação fica completa** — cada IA registra "pedido de solução" + "racional" + "alternativas consideradas"
- **Maurício decide com mais informação** — vê o que cada IA articulou antes de aprovar
- **Princípios constitucionais ficam ativados** — P3 (testar antes de refatorar), P4 (explicar antes de automatizar), P5 (humano no controle)

## Modelo de auditoria cruzada

### IAs envolvidas (em 2026-05-06)

| IA | Papel típico no useHBN |
|---|---|
| **Claude Opus 4.7 (Cowork)** | Arquiteto + validador (esta sessão) |
| **Codex CLI (OpenAI)** | Executor de tarefas estruturais (já em uso) |
| **Antigravity (Codex Heavy variant)** | Diagnóstico arquitetural; revisão pesada (usado anteriormente) |
| **Gemini Pro/Ultra** | Revisão arquitetural longa; crítica de design (`gemini/ARCHITECTURE-BRIEF.md`) |
| **Notebook LM** | Síntese de fontes externas + podcasts; estudo profundo de tecnologias |
| **Outras IAs** | Conforme surgirem; permeabilidade similar ao radar |

Maurício é sempre o decisor final.

### Tipos de pedidos de solução

Cada esteira gera múltiplos "pedidos de solução" — momentos em que uma IA pede a outra (ou ao humano) algo. Tipos identificados:

| Tipo | Quem pede para quem | Exemplo |
|---|---|---|
| **Spec request** | Maurício → Opus | "Monte um plano detalhado de incorporação" |
| **Implementation request** | Opus → Codex | "Implemente conforme spec X" |
| **Validation request** | Opus → si mesmo (validação) ou outra IA | "Audite os arquivos entregues por Codex" |
| **Synthesis request** | Maurício → Opus + Notebook LM | "Sintetize os 5 estudos em prompt unificado" |
| **Critique request** | Maurício → Gemini | "Critique a arquitetura proposta" |
| **Diagnostic request** | Maurício → Antigravity | "Diagnostique drift na cadeia X" |
| **Decision request** | Opus → Maurício | "Aprove ou rejeite esta promoção" |

### Estrutura mínima de documentação por pedido

Cada pedido de solução documentado deve conter:

```yaml
# Exemplo de entrada em audit-trail
pedido_id: "AUDIT-CC-RA-001"
esteira: "R-A Consent Capsules"
de: "Maurício"
para: "Opus"
tipo: "spec request"
data: "2026-05-06"
artefato_pedido: "Schema Pydantic dos 6 arquivos da cápsula"
contexto: "Migração estruturada Python → Rust; cápsula é primeiro módulo"
alternativas_consideradas:
  - "JSON Schema bruto (declarativo, simples)"
  - "Pydantic com validators (mais rigor; biblioteca extra)"
  - "msgspec (performance; menos maturidade)"
opcao_escolhida: "Pydantic com validators"
racional: "Maturidade ecosistema; tipo seguro; fácil migração para serde Rust"
trade_offs_aceitos: "1 dep externa em vez de stdlib; mitigado por princípio Substrato Sólido (futura migração para Rust)"
ia_responsavel: "Opus"
revisor_cruzado: "Codex (após implementação)"
maurício_decisao: "aprovado"
gate_de_fechamento: "schema valida 1 cápsula real (L18) end-to-end"
```

Esses YAML/JSON ficam em `audit-trail/<esteira>/<pedido_id>.yaml` para cada esteira.

## Fluxo de auditoria cruzada por esteira

```text
┌──────────────────────────────────────────────────────────┐
│ 1. ABERTURA da esteira (Maurício abre; Opus desenha spec)│
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 2. PEDIDOS DE SOLUÇÃO (cada um documentado em audit-trail)│
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 3. EXECUÇÃO (Codex/Opus implementa conforme spec)        │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 4. VALIDAÇÃO INTERNA (Opus auto-valida)                  │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 5. AUDITORIA CRUZADA — esta etapa NOVA                   │
│    ├─ IA-A revisa output de IA-B (e vice-versa)          │
│    ├─ Crítica documentada                                │
│    ├─ Sugestões de melhoria registradas                  │
│    └─ Itens consensuais ✅ vs divergentes 🟡              │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 6. SÍNTESE DE AUDITORIA (Opus consolida e apresenta a Maurício) │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 7. DECISÃO MAURÍCIO (aprova / itera / arquiva)           │
└──────────────────────┬───────────────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────────────┐
│ 8. FECHAMENTO da esteira (cápsula de auditoria + ERP)    │
└──────────────────────────────────────────────────────────┘
```

## Etapa 5 detalhada — auditoria cruzada propriamente dita

### Quem audita quem

Sugestão de pares por tipo de esteira:

| Tipo de esteira | Auditor primário | Auditor secundário (cruzado) |
|---|---|---|
| Implementação Rust de módulo | Codex (implementa) | Opus (auditoria de arquitetura) + Gemini (auditoria de design) |
| Spec arquitetural de módulo | Opus (escreve) | Gemini (auditoria de design) + Codex (auditoria de viabilidade) |
| Documentação V2 do useHBN | Opus (escreve) | Notebook LM (síntese externa) + Gemini (crítica) |
| Cápsulas de promoção pública | Opus (monta) | Maurício (decisão final) + Codex (validação técnica) |
| Análise de tecnologia para radar | Opus (análise individual) | Notebook LM (estudo Maurício) — auditoria já foi natural |

### O que cada auditor verifica

**Opus auditando Codex:**
- Aderência à spec original
- Princípios constitucionais respeitados (P1-P10 + P11/P12/P13 candidatos)
- Cadeia de dependências dentro do mínimo aceitável
- Documentação completa
- Testes presentes e verdes

**Codex auditando Opus:**
- Viabilidade de implementação da spec
- Edge cases não considerados
- Trade-offs explicitados
- Compatibilidade com tooling Rust/Python existente

**Gemini auditando arquitetura:**
- Padrões similares em projetos open-source maduros
- Riscos de longo prazo (5+ anos) não considerados
- Alternativas arquiteturais não exploradas
- Cobertura dos princípios constitucionais

**Maurício auditando síntese:**
- Aderência à intenção declarada
- Coerência com decisões anteriores
- Aprovação final (palavra do operador)

### Output da auditoria cruzada

Documento padrão `audit-trail/<esteira>/CROSS-AUDIT-REPORT.md`:

```markdown
# Auditoria Cruzada — Esteira <ID>

## Auditores
- Auditor primário: <IA + papel>
- Auditor cruzado 1: <IA + papel>
- Auditor cruzado 2: <IA + papel>

## Itens consensuais ✅
- [item 1] — todos auditores concordam
- [item 2] ...

## Itens divergentes 🟡
- [item X] — Opus diz A; Codex diz B; síntese sugere C
- [item Y] ...

## Sugestões de iteração antes de fechar
1. ...
2. ...

## Veredito da auditoria
- ✅ aprovado para fechamento
- 🟡 iteração requerida em N pontos
- ❌ retornar para Etapa 3 (re-execução)

## Decisão Maurício pós-auditoria
[a preencher após hearback]
```

## Marker HBN V2 derivado (proposta)

Adendum proposto ao `0005-protocolo-markers-v2.md`:

| Marker | Quando usar |
|---|---|
| `🔍 HBN CROSS-AUDIT IN PROGRESS` | Etapa 5 do fluxo está em curso |
| `🤝 HBN CROSS-AUDIT APPROVED` | Auditoria cruzada concluiu com consenso |
| `⚖️ HBN CROSS-AUDIT ITERATION` | Auditoria identificou divergências; iteração requerida |

Já existe `🟣 HBN PEER REVIEW REQUESTED` no V2 vigente — pode ser usado para etapas iniciais de pedido de auditoria. Os 3 acima formalizam o fluxo completo.

> **Nota 2026-05-09**: a proposta original deste documento sugeria `🔄`, `✅` e `🟡` para os 3 marcadores acima. A canonização final em `.hbn/knowledge/0005-protocolo-markers-v2.md` (após auditoria cruzada Antigravity sobre os módulos públicos) trocou para `🔍`, `🤝` e `⚖️` — símbolos univocamente relacionados a auditoria, sem reuso visual com markers V1. Esta tabela reflete a versão canônica vigente.

## Conexão com Consent Capsules

Cada esteira que passa pela auditoria cruzada **gera uma cápsula** ao final, conforme proposta D já implementada em Consent Capsules:

- `lesson.md` — o que foi aprendido na esteira
- `evidence.json` — refs e hashes do código + audit-trail
- `redaction-map.json` — substituições aplicadas (se promoção pública)
- `consent.json` — assinatura de Maurício + assinatura das IAs auditoras (futuro)
- `license-target.txt` — licença alvo
- `hashes.json` — integridade

A **cápsula de auditoria cruzada** vira o veículo padrão de conclusão de esteira. Reforça o papel de Consent Capsules como infraestrutura transversal.

## Implicação para Roadmap Consent Capsules (R-A → R-E)

A Fase R-A (POC Python) deve incluir, como teste real, a **primeira cápsula de auditoria cruzada** — gerada como parte do fechamento de R-A. Auto-referencial: a primeira cápsula é a auditoria da própria implementação inicial das cápsulas.

Isso testa simultaneamente:
- Schema de cápsulas (R-A)
- Fluxo de auditoria cruzada (este documento)
- Conexão Cápsulas + Auditoria

Marker da estreia: 🔍 HBN CROSS-AUDIT IN PROGRESS na execução de R-A.

## Conexão com decisões já tomadas

- ✅ **Princípio do AI-Language-Abstraction** — auditoria cruzada é prática viva deste princípio (múltiplas IAs validam mutuamente)
- ✅ **Modelo das 3 Árvores** — auditoria cruzada é gate de transição entre Desenvolvimento e Estável
- ✅ **Markers V2** — gates da auditoria expressos com markers
- ✅ **Permeabilidade do radar** — novas IAs podem entrar conforme aparecem (LLMs futuros)

## Versão

- v1.0 — 2026-05-06 — primeira formalização do protocolo de auditoria cruzada entre IAs.
