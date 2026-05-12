---
titulo: 43 - Plano de documentação V2 do useHBN
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06 (v1.0); refatorado 2026-05-09 (v1.1 — alinhamento multi-braço)
autor: Claude Opus 4.7 (Frente 2)
licenca-target: TPGL v1.1 (este planejamento); V2 final em AGPLv3
status: ESBOÇO refatorado — estrutura agora alinhada à arquitetura multi-braço (6 módulos) formalizada em USEHBN-MODULES-ARCHITECTURE.md (2026-05-06) e materializada nas fichas individuais em usehbn/modules/ (2026-05-09, Tarefa 1 fechada)
predecessor: 38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md (V1 da tese — fagocitose-centrica)
referencia-arquitetural-canonica: usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md
---

# 43 — Plano de Documentação V2 do useHBN

## Por que V2 agora

Maurício pediu em 2026-05-06: "preparar para a documentação da versão V2 do useHBN assim que finalizarmos a análise dessas 5 tecnologias."

A V1 (`38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`) registrou a tese fundadora — 10 princípios, 8 camadas, modelo conceitual de fagocitose. Era o **mapa filosófico**, mas **fagocitose-cêntrico**.

Nas 72 horas entre 2026-05-02 e 2026-05-06 + a sessão Antigravity de continuidade em 2026-05-09, o useHBN ganhou:

- 3 princípios operacionais novos formalizados (P11/P12/P13 candidatos)
- Modelo arquitetural novo (3 árvores)
- Decisão de linguagem-base (Rust)
- Roadmap concreto da primeira tecnologia migrada (Consent Capsules)
- Permeabilidade do radar formalizada
- 11 markers V2 estendidos (3 grupos: princípios, árvores, auditoria) — total 21
- **Correção arquitetural fundamental**: useHBN ≠ sistema de fagocitose. useHBN é protocolo **multi-braço** — 6 módulos paralelos (Fagocitose, Cápsulas de Consentimento, Coordenação inter-IA, Segurança, Marcadores, Auditoria Cruzada) + Radar como infraestrutura transversal. Formalizado em `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` (2026-05-06) e materializado em fichas individuais em `usehbn/modules/` (2026-05-09).
- Protocolo de Auditoria Cruzada entre IAs aplicado em produção (relatório Antigravity 2026-05-09)

A V1 está obsoleta para esses elementos — em particular, a leitura "useHBN = fagocitose" é o que mais precisa ser corrigida. A V2 precisa **integrá-los** e **reposicionar** o conjunto.

## O que muda da V1 para a V2

| Aspecto | V1 (tese 38) | V2 (este plano) |
|---|---|---|
| **Visão arquitetural** | **fagocitose-cêntrica** (useHBN ≈ sistema de fagocitose) | **multi-braço** (6 módulos paralelos + Radar transversal; fagocitose é UM dos 6) |
| Princípios constitucionais | 10 | 10 + 3 candidatos a constitucionais (operacionais) |
| Camadas | 8 | 8 + Camada 0 (Radar) formalizada como módulo de observação |
| Modelo de progressão | implícito (fases F0-F5) | explícito (3 árvores: Estável/Desenvolvimento/Exploração) |
| Linguagem-base | Python implícita | Rust declarada (substrato comum aos módulos) |
| Markers | 10 V2 | 21 V2 (10 base + 11 estendidos: 3 princípios + 5 árvores + 3 auditoria) |
| Casos reais | hipotéticos | 1 promoção real em curso (Consent Capsules R-A→R-E) + 1 cross-audit real (Antigravity 2026-05-09) |
| Tom | exploratório | demonstrativo |
| Protocolo de auditoria | implícito | Auditoria Cruzada entre IAs como módulo formal (Módulo 6) |

## Estrutura proposta da V2

### Frontmatter da V2

```yaml
titulo: useHBN V2 — Protocolo Multi-Braço para Coordenação Humano-IA
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos (humanos + IAs)
versao-protocolo: usehbn 1.0 (oficial — saída de 0.4.0 alpha)
data: aguardando publicação (após R-D de Consent Capsules)
autor: Luís Maurício Junqueira Zanin (visão original) + Codex + Antigravity + Claude Opus 4.7 (síntese)
licenca-target: usehbn (AGPLv3) — repositório-mãe; cada módulo individual ganha repo próprio (usehbn-phago, usehbn-capsules, etc.)
substitui: 38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md (V1 — preservada como histórico fagocitose-cêntrico)
referencia-arquitetural: usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md
```

### Sumário proposto

**Parte I — Fundação (estável da V1)**

- Capítulo 1: Frase-mãe e tese central
- Capítulo 2: Os 10 princípios constitucionais (texto inalterado da V1)
- Capítulo 3: As 8 camadas + Camada 0 (Radar) formalizada
- Capítulo 4: Caso empírico fundador — Credenciamento V12.0.0203

**Parte II — Trinca de princípios operacionais (NOVA — capítulo central da V2)**

- Capítulo 5: Princípio do Minimalismo de Cadeia (P11 candidato)
  - Origem (Typer arquivamento)
  - 4 axiomas
  - Aplicação prática
  - Marker 🟦
- Capítulo 6: Princípio do Substrato Sólido (P12 candidato)
  - Origem (uv arquivamento)
  - 5 axiomas
  - Decisão Rust como linguagem-base
  - Marker 🟪
- Capítulo 7: Princípio AI-Language-Abstraction (P13 candidato)
  - Origem (decisão Rust apesar de Maurício nunca ter digitado Rust)
  - 5 axiomas
  - O paradigma fundador
  - Marker 🟧

**Parte III — Modelo arquitetural das 3 Árvores (NOVA — segunda inovação V2)**

- Capítulo 8: Visão geral das 3 árvores
- Capítulo 9: Árvore de Exploração e Estudo (qualquer linguagem; bordas)
- Capítulo 10: Árvore de Desenvolvimento (transição; testes; docs)
- Capítulo 11: Árvore Estável (Rust; décadas sem travar)
- Capítulo 12: Movimento entre árvores; filtros progressivos
- Capítulo 13: Como o radar mapeia para as árvores
- Markers 🌱 🔧 🪨 🟫

**Parte IV — Os módulos do useHBN (REFATORADA — capítulos por módulo, não por tecnologia)**

Esta parte materializa a tese central da V2: useHBN é multi-braço. Cada módulo recebe capítulo próprio que segue o template declarativo já consolidado em `usehbn/modules/<MODULO>.md` (8 blocos: O que é → Componentes → Movimento → Filtros → Marcadores → Conexão → Como adotar). A V2 referencia esses arquivos como fontes canônicas e expande com casos reais.

- Capítulo 14: O Radar — observação e categorização de tecnologias (infraestrutura transversal)
  - Camada 0 + 6 estados + 5 vias de entrada
  - Cadência de revisão semanal
  - Fonte: `usehbn/modules/RADAR.md`
- Capítulo 15: Módulo 1 — Fagocitose Tecnológica Segura
  - 6 fases F0-F5 + gates entre cada
  - Tecnologias incorporadas (Tree-sitter, OpenTelemetry)
  - Fonte: `usehbn/modules/FAGOCITOSE.md`
- Capítulo 16: Módulo 2 — Cápsulas de Consentimento
  - 6 arquivos canônicos da cápsula + ciclo type-state
  - Caso real: Consent Capsules R-A→R-E (primeira migração Python→Rust)
  - Fonte: `usehbn/modules/CAPSULAS-DE-CONSENTIMENTO.md`
- Capítulo 17: Módulo 3 — Coordenação inter-IA
  - 6 princípios + 4 esteiras + fluxo do bastão
  - Cadências A/C/D/Cross-IA
  - Fonte: `usehbn/modules/COORDENACAO-INTER-IA.md`
- Capítulo 18: Módulo 4 — Segurança (Glasswing-style)
  - 8 vetores G1-G8 + pipeline pré-resposta
  - Fonte: `usehbn/modules/SEGURANCA.md`
- Capítulo 19: Módulo 5 — Marcadores
  - 21 marcadores canônicos (V2 base + addendum estendido)
  - Delta card e formato canônico de retorno
  - Fonte: `usehbn/modules/MARCADORES.md`
- Capítulo 20: Módulo 6 — Auditoria Cruzada
  - 7 tipos de pedido + fluxo de 8 etapas
  - Caso real: cross-audit Antigravity sobre os 6 módulos (2026-05-09)
  - Fonte: `usehbn/modules/AUDITORIA-CRUZADA.md`
- Capítulo 21: Tecnologias fundadoras dentro dos módulos
  - Tree-sitter (no Fagocitose; 6 fases A-F)
  - Consent Capsules (Módulo 2 inteiro; demonstração viva das 3 árvores)
  - OpenTelemetry (no Fagocitose; observabilidade)
  - Rust como substrato comum dos 6 módulos
- Capítulo 22: Outros módulos previstos (espaço aberto)
  - Como novos módulos entram (permeabilidade ≠ explosão)
  - Critérios mínimos para módulo novo

**Parte V — Operação cotidiana**

- Capítulo 23: Delta card e ERP (formatos canônicos)
- Capítulo 24: Revisão semanal e permeabilidade do radar
- Capítulo 25: Ping-pong Opus ↔ Codex ↔ Maurício (cadências em ação)
- Capítulo 26: Cápsulas como veículo de promoção entre repos

**Parte VI — Aplicação em outros projetos**

- Capítulo 27: Como adotar useHBN em outro projeto (decisão modular: que módulos importar primeiro)
- Capítulo 28: Tutorial de primeira fagocitose
- Capítulo 29: Estudos de caso (Credenciamento → Tree-sitter → Consent Capsules)
- Capítulo 30: Cookbook de cápsulas comuns

**Parte VII — Apêndices**

- Apêndice A: Glossário (cápsula, árvore, fagocitose, marker, módulo, ADR, etc.)
- Apêndice B: Bibliografia (todas as fontes externas referenciadas)
- Apêndice C: Histórico de transições (registro append-only de todos os princípios + decisões; inclui correção 2026-05-06 da leitura fagocitose-cêntrica)
- Apêndice D: Tecnologias arquivadas (Typer, uv, AutoGen, etc. — radar histórico)
- Apêndice E: Adesão a padrões externos (Diataxis, agents.md, llms.txt, Glasswing, HBN markers V2, W3C VC referência)
- Apêndice F: Mapeamento intenção declarada → módulo materializado (ponte direta para `USEHBN-MODULES-ARCHITECTURE.md`)

## Conexão com outros documentos canônicos

A V2 não substitui — **integra** — os documentos já existentes:

| Documento | Papel na V2 |
|---|---|
| `38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md` (V1) | Preservado como anexo histórico; primeira articulação fagocitose-cêntrica |
| `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` | **Spec arquitetural canônica** — fonte direta da Parte IV completa |
| `usehbn/modules/INDEX.md` | Mapa de dependências dos 7 (Radar + 6 módulos) — fonte do Capítulo 14 e abertura da Parte IV |
| `usehbn/modules/RADAR.md` | Vira Capítulo 14 |
| `usehbn/modules/FAGOCITOSE.md` | Vira Capítulo 15 |
| `usehbn/modules/CAPSULAS-DE-CONSENTIMENTO.md` | Vira Capítulo 16 |
| `usehbn/modules/COORDENACAO-INTER-IA.md` | Vira Capítulo 17 |
| `usehbn/modules/SEGURANCA.md` | Vira Capítulo 18 |
| `usehbn/modules/MARCADORES.md` | Vira Capítulo 19 |
| `usehbn/modules/AUDITORIA-CRUZADA.md` | Vira Capítulo 20 |
| `MINIMALISM-PRINCIPLE.md` | Vira Capítulo 5 |
| `SUBSTRATO-SOLIDO-PRINCIPLE.md` | Vira Capítulo 6 |
| `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md` | Vira Capítulo 7 |
| `THREE-TREES-ARCHITECTURE.md` | Vira Capítulos 8-13 |
| `RADAR-PHAGOCYTOSIS-PIPELINE.md` | Suporte ao Capítulo 14 (Camada 0 detalhada) e Capítulo 15 |
| `INCORPORATION-PROGRESSIVE-PLAN.md` | Suporte ao Capítulo 15 (F0-F5 detalhado) |
| `INTER-CHAT-COORDINATION.md` | Suporte ao Capítulo 17 |
| `.hbn/knowledge/0003-glasswing-style-preventive-security.md` | Suporte ao Capítulo 18 |
| `.hbn/knowledge/0005-protocolo-markers-v2.md` (V2 base + addendums) | Suporte ao Capítulo 19 (21 marcadores) |
| `CROSS-IA-AUDIT-PROTOCOL.md` | Suporte ao Capítulo 20 |
| `LANGUAGE-PLATFORM-COMPARISON.md` | Apêndice ou seção do Capítulo 21 |
| `42_ROADMAP_CONSENT_CAPSULES_RUST.md` | Caso real expandido no Capítulo 16 |
| `usehbn/audits/RELATORIO-ANTIGRAVITY-MODULOS-2026-05-09.md` | Caso real do Capítulo 20 (cross-audit Antigravity sobre os 6 módulos) |

A V2 **não duplica** — **referencia** os documentos canônicos via links internos. Isso permite que cada documento canônico continue evoluindo de forma independente.

## Cronograma proposto

| Fase | Quando | Output |
|---|---|---|
| F1 — Esboço estrutural | esta semana | este documento (43) |
| F2 — Primeira redação completa | após análise OpenTelemetry | draft V2 em `auditoria/00_status/44_USEHBN_V2_DRAFT.md` |
| F3 — Revisão Maurício | semana após F2 | comentários integrados |
| F4 — Revisão Codex (técnica) | em paralelo | sugestões de clareza |
| F5 — Sincronização com R-D Consent Capsules | quando Consent Capsules promover à Estável | V2 ganha caso real fechado |
| F6 — Publicação no `usehbn-phago` | quando Árvore Estável for inaugurada | V2 oficial em `usehbn-phago/docs/usehbn-v2.md` |

**Início efetivo de F2**: agora **destravado pelo lado dos módulos** (Tarefa 1 fechou as fichas individuais em 2026-05-09 com cross-audit Antigravity 🤝 APPROVED). Permanece dependente de:

1. Análise OpenTelemetry concluída por Maurício (5ª das 5 tecnologias)
2. Decisão final sobre OTel (já APROVADA em 2026-05-06; pendente apenas detalhamento do roadmap O-A→O-E equivalente)
3. Geração do `46_PROMPT_UNIFICADO_CODEX.md` (Tarefa 6 da fila)

## Princípios editoriais para a V2

- **Densidade > narrativa** — cada parágrafo entrega substância; sem enchimento
- **Tabelas > prosa** quando há comparativo a fazer
- **Citações operacionais de Maurício** preservadas literalmente nos pontos críticos (frase-mãe, articulação dos 3 princípios, etc.)
- **Casos reais** (não hipotéticos) — Tree-sitter e Consent Capsules são exemplos vivos
- **Linguagem clara para devs puristas** — evitar marketing-speak; assumir leitor crítico
- **Estrutura Diataxis** — documento de tipo "explanation" mas com sub-elementos referenciando tutoriais e how-tos
- **Append-only para apêndice C (histórico)** — cada decisão registrada; revisão histórica preservada

## Conexão com os princípios operacionais (esta V2 deve respeitar os 3)

| Princípio | Como a V2 respeita |
|---|---|
| Minimalismo de Cadeia | V2 não introduz dependências externas; é Markdown puro com links |
| Substrato Sólido | V2 é texto compilável conceitualmente — pode virar HTML/PDF/EPUB sem perda |
| AI-Language-Abstraction | V2 escrita por IA (Opus); revisada por humano (Maurício); estilo prevê leitura por outras IAs |

## Decisões pendentes para Maurício durante F2

(Todas aprovadas em 2026-05-09 conforme registro abaixo. Mantidas
visíveis para histórico — nova decisão pendente eventualmente cabe
nesta seção.)

## Decisões aprovadas em 2026-05-09 (Maurício)

| # | Decisão pendente | Resolução |
|---|---|---|
| 1 | Promover P11/P12/P13 a constitucionais ou manter como operacionais? | **Aprovado promover** — V2 trata os 13 princípios como conjunto canônico (10 constitucionais originais + 3 operacionais formalizados com peso equivalente). Numeração P11-P13 mantida para preservar separação histórica entre os 10 fundadores e os 3 da janela 2026-05-02 → 2026-05-06. |
| 2 | Camada 0 (Radar) entra como camada constitucional ou permanece como módulo? | **Aprovada permanência como módulo** — Radar fica como Capítulo 14 (infraestrutura transversal de observação). Não vira camada constitucional; é meta-organizacional. |
| 3 | 3 árvores como capítulo central ou apêndice? | **Aprovada Parte III central** (Caps 8-13) — modelo é inovação arquitetural V2, merece centralidade. |
| 4 | Frente 1 (Credenciamento) como caso real? | **Aprovado** — Frente 1 V12.0.0203 entra como Caso Empírico Fundador (já é Capítulo 4 + estudo expandido em Capítulo 29). |
| 5 | Criar índice canônico P1-P10? | **Aprovado** — `usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md` é pré-requisito do Capítulo 2 da V2; criação executada nesta sessão. |

## Decisões já fechadas (que a V2 incorpora sem revisitar)

- **Arquitetura multi-braço** (6 módulos paralelos) — `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` é canônico
- **Rust como linguagem-base** do substrato comum dos módulos
- **Modelo das 3 Árvores** (Estável / Desenvolvimento / Exploração)
- **5 decisões de tecnologias** (Tree-sitter ✅, Typer ❌, uv ❌, OpenTelemetry ✅, Consent Capsules ✅)
- **3 princípios operacionais** formalizados (Minimalismo, Substrato Sólido, AI-Language-Abstraction)
- **21 marcadores canônicos** (V2 base 10 + addendum estendido 11)
- **Protocolo de Auditoria Cruzada** entre IAs (Módulo 6) — primeira aplicação real registrada em `usehbn/audits/RELATORIO-ANTIGRAVITY-MODULOS-2026-05-09.md`

Estas decisões NÃO retornam à mesa durante F2. Mudança exige onda específica com novo cross-audit.

## Versão

- v1.0 — 2026-05-06 — esboço inicial após pedido de Maurício de preparar V2.
- v1.1 — 2026-05-09 — refator de alinhamento multi-braço após Tarefa 1 fechar as fichas individuais dos 6 módulos com cross-audit 🤝 APPROVED. Mudanças principais: (a) frontmatter e título reposicionados ("Multi-Braço para Coordenação Humano-IA" em vez de "Maduro para Fagocitose Tecnológica Segura"); (b) "Por que V2 agora" inclui correção arquitetural fundamental como item explícito; (c) tabela "O que muda" ganha linha "Visão arquitetural" e linha "Protocolo de auditoria"; (d) Parte IV refatorada de "Tecnologias fundadoras" para "Os módulos do useHBN" com capítulos por módulo (14-22 em vez de 14-16); (e) renumeração das Partes V/VI/VII; (f) tabela "Conexão com documentos canônicos" expandida com 6 fichas + arquitetura + relatório cross-audit; (g) seção "Decisões já fechadas" adicionada; (h) cronograma F2 marcado como destravado pelo lado dos módulos.
