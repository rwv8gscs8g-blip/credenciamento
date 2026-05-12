---
titulo: 41 - Decisões em curso sobre as 5 tecnologias selecionadas (semana 2026-W18)
diataxis: status
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06 (criado); atualizado a cada decisão
licenca-target: TPGL v1.1
sucesso: 42_PROMPT_UNIFICADO_CODEX (a ser criado quando todas as 5 decisões estiverem fechadas)
---

# 41 — Decisões em curso sobre as 5 tecnologias

## Propósito deste documento

Maurício decidiu (2026-05-06) **estudar todas as 5 tecnologias antes de implementar qualquer uma**. Decisões individuais são acumuladas aqui. Quando as 5 estiverem fechadas, será gerado um **prompt unificado para o Codex** consolidando o que foi aprovado.

Este documento é **append-only por tecnologia** — cada análise concluída adiciona seção. Atualização sequencial até as 5 estarem decididas.

## Mudança de processo (vs plano original)

### Plano original (2026-05-02)
1. Estudo individual por tecnologia
2. Decisão imediata após cada estudo
3. Implementação imediata da aprovada
4. Próxima tecnologia em paralelo

### Plano revisado (2026-05-06 — após primeira análise)
1. **Estudo individual por tecnologia** (mantido)
2. **Decisão registrada aqui** (novo — não imediata em código)
3. **Aguardar conclusão das 5** (novo)
4. **Gerar prompt unificado para Codex** (novo) — implementação em batch
5. **Codex executa esteira nova** (E2 ou similar) com tudo aprovado de uma vez

Vantagem: visão de conjunto antes de mexer em código. Risco mitigado: incorporações inconsistentes entre tecnologias.

## Status das 5 tecnologias

| # | Tecnologia | Estudo Mauricio | Decisão final | Estado radar atual |
|---|---|---|---|---|
| 1 | Tree-sitter | ✅ concluído 2026-05-06 | aprovada — quer fagocitar como tecnologia fundadora; pendente prompt unificado | `in-radar` (estudo concluído; promoção pendente) |
| 2 | Typer | ✅ concluído 2026-05-06 | ❌ ARQUIVADA — filosofia minimalista de dependências | `archived` (efetivado) |
| 3 | uv | ✅ concluído 2026-05-06 | ❌ ARQUIVADA — argumento pró-Rust virou decisão de trocar linguagem-base do useHBN | `archived` (efetivado) |
| 4 | OpenTelemetry | ✅ concluído 2026-05-06 | ✅ APROVADA — em processo de fagocitose progressiva; alternativa Rust como padrão de mercado; integração com Consent Capsules | `candidate` (efetivado; roadmap O-A→O-E declarado) |
| 5 | Consent capsules | ✅ concluído 2026-05-06 | ✅ APROVADA — primeira migração estruturada Python → Rust; módulo à parte de assinatura de código (não dentro do módulo de fagocitose) | `candidate` (efetivado; roadmap em 42; migração imediata) |

**TODAS AS 5 ANÁLISES CONCLUÍDAS EM 2026-05-06.** Próximo marco: aprovação do documento 44 → publicação GitHub → início R-A.

**Correção crítica de entendimento** (Maurício 2026-05-06): useHBN é **multi-braço**. Fagocitose é apenas UM dos 6 módulos. Documento canônico de referência: `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md`. Documento de consolidação para aprovação: `auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md`.

**Decisão arquitetural maior TOMADA** (2026-05-06 tarde): linguagem-base do useHBN é **Rust** — declarada por Maurício após arquivamento de uv e articulação dos princípios do Substrato Sólido + AI-Language-Abstraction. Ficha formal em `usehbn/radar/_per-technology/rust.md` (estado `phagocytosed`).

**Modelo das 3 Árvores formalizado** (2026-05-06 tarde): Árvore Estável (Rust, compilada, décadas sem travar), Árvore de Desenvolvimento (migração Python → Rust), Árvore de Exploração (qualquer linguagem para conexão com bordas de tecnologias). Documento canônico em `usehbn/methodology/THREE-TREES-ARCHITECTURE.md`.

**Trinca de princípios operacionais formalizada** (2026-05-06):
- Minimalismo de Cadeia (P11 candidato)
- Substrato Sólido (P12 candidato)
- AI-Language-Abstraction (P13 candidato)

## Decisões fechadas (preencher conforme cada estudo termina)

### #1 — Tree-sitter — APROVADA, fagocitação prevista

**Data decisão**: 2026-05-06
**Status decisão**: APROVADA com plano de incorporação em 6 fases (A-F) — ver detalhamento abaixo.
**Estado radar**: `in-radar` (transição para `convergence-mapped` e além acontece via prompt unificado, não agora).

**Resumo da posição de Maurício** (citação operacional):

> "Tree-sitter pareceu-me absolutamente fundamental, quero que fique no radar. Preciso aprender mais sobre LR parser e GLR parser. Há um longo caminho de conhecimento, mas as arquiteturas estão completamente aderentes com a evolução pretendida no longo prazo e no uso coletivo pela comunidade."

**Após estudo NotebookLM concluído**:

> "Quero que apresente um plano detalhado de incorporação da metodologia no processo, na documentação, na construção da arquitetura de forma evolutiva. Essa pode partir do processo de radar para a fagocitose e incorporação como parte do ferramental de justificativa do porque utilizar o useHBN. Que por hora vai propor essa linguagem do tree-sitter como forma de comunicação da ferramenta sobre a orquestração do useHBN."

**Papéis pretendidos** (3):
- (a) Ferramenta técnica — parsing real de código legado (substitui regex frágil)
- (b) Linguagem comum — ASTs e queries S-expression como notação canônica entre humanos e IAs
- (c) Justificativa de adoção — argumento técnico para "porquê useHBN"

**Plano de incorporação aprovado** (6 fases A-F):

| Fase | Quando (após prompt unificado Codex) | Resumo |
|---|---|---|
| A — Promoção radar | imediato no prompt unificado | `in-radar` → `convergence-mapped`; ADR-001; adendum tese 38 |
| B — POC isolado | semana 1 pós-prompt | `modules/parsing/`; tree-sitter + tree-sitter-vba; POCs com Const_Colunas.bas |
| C — Integração protocolar | semana 2 pós-prompt | Queries canônicas; AST artifact schema; markers V2 derivados (🟠 AST DRIFT, 🟢 AST CHECKPOINT, 🟣 QUERY REVIEW) |
| D — Documentação pública | semana 3 pós-prompt | README/PRINCIPLES/METHODOLOGY do usehbn-phago atualizados; tutorial Diataxis |
| E — Adoção operacional | semana 4 e diante (30 dias mín) | `hbn parse`, `hbn drift check --ast` no CLI; uso real em Onda 12+ |
| F — Promoção pública (cápsula) | Q3/2026 | Cápsula promovida ao repo público |

**Detalhes completos** do plano: ver mensagem Opus → Maurício 2026-05-06 (registrada nesta sessão Cowork).

**Marker novo proposto** ao protocolo HBN: `🟦 HBN MINIMALIST GATE` (decisão de adoção sob princípio do Minimalismo de Cadeia).

### #2 — Typer — ARQUIVADA

**Data decisão**: 2026-05-06
**Status decisão**: ARQUIVADA com motivo `purista-anti-dependencias-pro-compilacao`.
**Estado radar**: `archived` (já efetivado em ficha + REGISTRY).

**Resumo da posição de Maurício** (citação operacional):

> "A Typer não foi aprovada, ela pode sair do radar. O risco de dependências é grande e a queda de performance pode ser concreta em sistemas concretos. Desenvolvedores puristas desistiriam de usar o useHBN pelo simples preconceito de estar acumulando dependências. A ideia é retirar dependências e compilar."

**Implicação para a CLI hbn (Wave 11+)**:

A decisão original era usar Typer + uv + GitHub Actions + Signed commits como stack CLI. Com Typer arquivada, a CLI hbn precisa de alternativa **zero-deps ou cadeia mínima**:

| Alternativa | Cadeia | Vantagem | Desvantagem |
|---|---|---|---|
| **argparse (stdlib)** | 0 deps | Zero footprint extra; sempre disponível | Mais boilerplate; sem autocompletion gratuito |
| **Click puro** | 1 dep (BSD-3, zero transitivas) | Decoradores ergonômicos; comunidade massiva | 1 dep externa (mas mínima e madura) |
| **Custom (sem framework)** | 0 deps | Total controle; auditável linha-a-linha | Mais código próprio; reinventando roda |

**Decisão final fica para o prompt unificado** ao Codex, após análise das 5. Sugestão Opus: avaliar Click puro como compromisso bom (1 dep mínima, ergonomia, fácil migrar para argparse depois).

**Filosofia formalizada**: este arquivamento gerou o **Princípio do Minimalismo de Cadeia** — ver `usehbn/methodology/MINIMALISM-PRINCIPLE.md`.

### #3 — uv — ARQUIVADA (com inversão arquitetural radical)

**Data decisão**: 2026-05-06
**Status decisão**: ARQUIVADA com motivo `argumentation-flip-pro-rust-base-language`.
**Estado radar**: `archived` (já efetivado em ficha + REGISTRY).

**Resumo da posição de Maurício** (citação operacional, em sequência ao arquivamento de Typer):

> "Se a grande vantagem é que ele foi escrito em Rust, para uma linguagem compilada, por que não voltamos nossa base de comunicação criando uma linguagem com alicerces sólidos em Rust, Go, Swift ou outra linguagem moderna que permita uma reconstrução estrutural profunda e sólida?"

**Inversão arquitetural radical**: o argumento PRÓ uv (escrito em Rust) foi VIRADO para "se Rust é a vantagem, escrevamos a base em Rust direto". Isso desencadeia decisão MUITO maior: **trocar linguagem-base do `usehbn-phago` de Python para linguagem compilada**.

**Filosofia formalizada**: este arquivamento gerou o **Princípio do Substrato Sólido** — ver `usehbn/methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md`. Complementar ao Princípio do Minimalismo de Cadeia formalizado horas antes.

**Citação adicional sobre lógica formal portável**:

> "Lógica formal não vai ficar presa a armadilhas ou insuficiências da linguagem. Precisamos atacar a raiz dos problemas. Voltar à origem da computação binária, se necessário, para lapidar os caminhos entre zeros e uns."

**Implicação operacional**: comparativo de linguagens candidatas em `usehbn/methodology/LANGUAGE-PLATFORM-COMPARISON.md`. Top 3:
- **Rust** — recomendação primária Opus (match arquitetural máximo + Tree-sitter Rust nativo)
- **Go** — alternativa pragmática (compilação ultra-rápida; simples)
- **Zig** — match filosófico mais radical mas pre-1.0 em 2026 (revisitar 2027)

**Sub-decisão pendente**: implementação CLI hbn — Rust (`clap`)? Go (`cobra`)? Stdlib em qualquer? Decisão consequente da decisão de linguagem-base.

**Reentrada permitida** se: (a) mantivermos Python como linguagem-base; (b) Astral entregar uv compilado standalone (Rust nativo binário) sem dependência de Python instalado.

### #4 — OpenTelemetry — PENDENTE (estudo a iniciar)

(Aguardando análise de Maurício via Notebook LM)

**Pergunta-chave**:

OpenTelemetry tem cadeia de dependências significativa quando usado completo (SDK + exporters + Collector). Como compor com Princípio do Minimalismo?

Opções:
- (a) Usar API mínima sem SDK (instrumentação manual)
- (b) Usar SDK mas exportar só para arquivo OTLP-JSON (sem Collector)
- (c) Adiar adoção; usar logging estruturado próprio com formato OTLP-compatível

### #5 — Consent capsules — APROVADA com plano de migração estruturada

**Data decisão**: 2026-05-06
**Status decisão**: APROVADA — primeira tecnologia a percorrer fluxo estruturado Python → Rust no modelo das 3 Árvores. Designada como **veículo canônico de promoção** entre as 3 árvores (Exploração → Desenvolvimento → Estável).
**Estado radar**: `candidate` (já efetivado em ficha + REGISTRY).

**Resumo da posição de Maurício** (citação operacional):

> "Consent Capsules absolutamente fundamental, aderente à nossa tecnologia, deve ser incorporado como tecnologia do fluxo do useHBN e deve ser o primeiro projeto com fluxo estruturado para conversar para uma modelo em Rust, que evolua da linguagem atual para um repositório que trate as características da segurança. Absolutamente fundamental. Pode ser uma tecnologia de assinatura, de compatibilidade e redução de erros, bem em linha com os objetivos da linguagem de declarar o que está em funcionamento e em controle."

**Papel ampliado** (vs proposta D original):

| Aspecto | Proposta D original (Codex 103b) | Aprovação Maurício 2026-05-06 |
|---|---|---|
| Escopo | "Veículo de promoção pública de lições" | "Tecnologia de assinatura, compatibilidade e redução de erros" + veículo canônico das 3 árvores |
| Posição | Implementação eventual | **Primeiro projeto em ordem de prioridade** após decisão Rust |
| Importância | Alta | "Absolutamente fundamental" |

**Roadmap formal**: `auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md` — plano em 5 fases (R-A a R-E):

| Fase | Foco | Linguagem | Duração |
|---|---|---|---|
| R-A | Spec + POC manual | Python | 1 semana |
| R-B | Tradução Rust 1:1 | Rust | 1-2 semanas |
| R-C | Refinamentos idiomáticos | Rust idiomatic | 2-3 semanas |
| R-D | Promoção à Árvore Estável | Rust v2 | 2-3 semanas |
| R-E | Adoção em V2 useHBN | docs | 1 semana |

**Total estimado**: ~10 semanas de trabalho efetivo após início.

**Demonstração viva dos 3 princípios operacionais**:

- **Minimalismo de Cadeia**: Rust com cadeia mínima (~10 transitivas, todas auditadas)
- **Substrato Sólido**: migração Python (interpretado) → Rust (compilado)
- **AI-Language-Abstraction**: operador não digita Rust; IA traduz e operador aprova

**Conexão com V2 useHBN**: Consent Capsules vira capítulo 15 da V2 (ver `auditoria/00_status/43_PLANO_DOCUMENTACAO_V2_USEHBN.md`).

## Próximos passos (após conclusão das 5)

Quando Maurício concluir as 5 análises, eu (Opus) gero documento sucessor:

**`auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md`** — prompt único contendo:

- Lista das 5 decisões consolidadas
- Para cada APROVADA: spec executável (paths, fases, gates, validation)
- Para cada ARQUIVADA: nota explicativa + alternativas para responsabilidades não cobertas
- Cronograma de implementação em batch (4-6 semanas)
- Pontos de validação por tecnologia

Esse será o input único do Codex para esteira E2 (ou esteira nova nomeada após decisões).

## Markers V2 nesta sessão

- ✅ HBN ACTIVE — Frente 2 acumulando decisões
- 🟦 HBN MINIMALIST GATE (proposto) — primeira invocação registrada (Typer arquivada)
- ⚪ HBN AUDIT-ONLY — Maurício no estudo; Opus em registro
- 🔵 HBN HANDOFF READY — após cada decisão, prontos para próxima

## Versão

- v1.0 — 2026-05-06 — primeira versão após decisão Maurício de mudar processo (acumular antes de implementar) e arquivamento de Typer
