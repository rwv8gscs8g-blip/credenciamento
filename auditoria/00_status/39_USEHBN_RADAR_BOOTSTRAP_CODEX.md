---
titulo: 39 - useHBN Radar Bootstrap Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Codex CLI
licenca-target: TPGL v1.1
---

# 39. useHBN Radar Bootstrap Codex

## Resumo executivo

A esteira E1 materializou a Camada 0 — Radar do useHBN com 55 tecnologias, estruturas ou dependências conceituais extraídas das fontes locais especificadas. O resultado é um conjunto de fichas individuais, um registry consolidado e uma matriz de convergência contra os 10 princípios constitucionais da tese 38.

O radar foi mantido conservador: itens citados como panorama 2026 entram em `in-radar`, alternativas arquiteturais ainda não decididas entram em `under-analysis`, e tecnologias já operacionais no Credenciamento/useHBN entram em `phagocytosed`. Nenhuma tecnologia foi promovida a `candidate` nesta esteira porque a spec não trouxe uma decisão humana de promoção.

O principal achado é que ferramentas de agentes e automação precisam de contenção explícita pelo protocolo; elas ajudam em coordenação, mas podem ferir o princípio 9 se virarem centro da arquitetura. Em contrapartida, documentação versionada, testes de caracterização, Glasswing, HBN e Diataxis já demonstram alta aderência por uso real.

A criação do repo local `~/Projetos/usehbn-phago/` foi preparada como scaffolding AGPLv3 sem código Python de produção, preservando a separação de licenças entre Credenciamento (TPGL v1.1) e useHBN público (AGPLv3).

## Inventário T1

Fontes varridas:

- `AGENTS.md`
- `.hbn/relay/INDEX.md`
- `.hbn/knowledge/0005-protocolo-markers-v2.md`
- `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md`
- `usehbn/methodology/INTER-CHAT-COORDINATION.md`
- `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`
- `local-ai/Time_AI/2026-05-02-V203-fechamento/301-PROTOCOLO-PINGPONG-OPUS-CODEX.md`
- `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
- `usehbn/docs/INTEGRATION-VBA-IMPORTER.md`
- `local-ai/Time_AI/2026-05-02-V203-fechamento/102*.md`
- `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md`

Total normalizado: **55** tecnologias/estruturas.

| Nome canônico | Slug | Categoria | Estado inicial | Fonte |
|---|---|---|---|---|
| LangGraph | langgraph | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| CrewAI | crewai | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| AutoGen | autogen | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| OpenAI Agents SDK | openai-agents-sdk | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| Google Agent Development Kit (ADK) | google-agent-development-kit-adk | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| Pydantic AI | pydantic-ai | agentes | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:191-198` |
| LangSmith | langsmith | observabilidade | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206` |
| Langfuse | langfuse | observabilidade | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206` |
| Arize Phoenix | arize-phoenix | observabilidade | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206` |
| MLflow | mlflow | observabilidade | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206` |
| OpenTelemetry | opentelemetry | observabilidade | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:200-206` |
| VBA | vba | legado | phagocytosed | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| COBOL | cobol | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Fortran | fortran | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Pascal | pascal | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Delphi | delphi | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Clipper | clipper | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Visual Basic 6 | visual-basic-6 | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Shell scripts | shell-scripts | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Procedural SQL | procedural-sql | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Microsoft Access | microsoft-access | legado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| Microsoft Excel | microsoft-excel | legado | phagocytosed | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219` |
| VBScript | vbscript | legado | in-radar | `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158` |
| Google Apps Script | google-apps-script | legado | in-radar | `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158` |
| Office Scripts | office-scripts | legado | in-radar | `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158` |
| FoxPro/dBase | foxpro-dbase | legado | in-radar | `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158` |
| Knowledge graphs | knowledge-graphs | conhecimento-estruturado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Ontologies | ontologies | conhecimento-estruturado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Abstract Syntax Trees (AST) | abstract-syntax-trees-ast | conhecimento-estruturado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Tree-sitter | tree-sitter | conhecimento-estruturado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Language Server Protocol (LSP) | language-server-protocol-lsp | conhecimento-estruturado | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Versioned documentation | versioned-documentation | conhecimento-estruturado | phagocytosed | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Characterization tests | characterization-tests | conhecimento-estruturado | phagocytosed | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229` |
| Markdown + YAML frontmatter | markdown-plus-yaml-frontmatter | conhecimento-estruturado | phagocytosed | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` |
| Obsidian | obsidian | conhecimento-estruturado | under-analysis | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` |
| SQLite | sqlite | conhecimento-estruturado | under-analysis | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` |
| JSON-LD | json-ld | conhecimento-estruturado | under-analysis | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` |
| JSONL event ledger | jsonl-event-ledger | conhecimento-estruturado | under-analysis | `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md` |
| Consent capsules | consent-capsules | conhecimento-estruturado | under-analysis | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` |
| Model Context Protocol (MCP) | model-context-protocol-mcp | conhecimento-estruturado | under-analysis | `.hbn/knowledge/0005-protocolo-markers-v2.md:31-83,108-142` |
| BOINC | boinc | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| Task queues | task-queues | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| Distributed workers | distributed-workers | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| Contribution reputation | contribution-reputation | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| Redundant validation | redundant-validation | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| Multi-agent consensus | multi-agent-consensus | computacao-distribuida | in-radar | `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:231-238` |
| agents.md | agents-md | outros | phagocytosed | `AGENTS.md:3-21,108-176` |
| llms.txt | llms-txt | outros | phagocytosed | `AGENTS.md:3-21,108-176` |
| Diataxis | diataxis | outros | phagocytosed | `AGENTS.md:3-21,108-176` |
| HBN | hbn | outros | phagocytosed | `AGENTS.md:3-21,108-176` |
| Glasswing | glasswing | outros | phagocytosed | `usehbn/docs/INTEGRATION-VBA-IMPORTER.md:1-25,63-79,145-158` |
| Typer | typer | outros | under-analysis | `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md` |
| uv | uv | outros | under-analysis | `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md` |
| GitHub Actions | github-actions | outros | under-analysis | `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md` |
| Signed commits and Sigstore | signed-commits-and-sigstore | outros | under-analysis | `local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md` |

## Deduplicações realizadas

- OpenAI Agents SDK consolidou variações "Agents SDK" e "OAI Agents".
- Google Agent Development Kit (ADK) consolidou "Google ADK".
- Arize Phoenix consolidou a menção curta "Phoenix".
- Microsoft Access e Microsoft Excel separaram a menção agregada "Access/Excel corporativo".
- Shell scripts consolidou "Shell scripts antigos".
- Procedural SQL consolidou "SQL procedural".
- Abstract Syntax Trees (AST) consolidou "ASTs".
- Language Server Protocol (LSP) consolidou "LSPs".
- Markdown + YAML frontmatter separou o storage da proposta A; Obsidian ficou como tecnologia de vault distinta.
- JSONL event ledger consolidou a proposta C; Consent capsules consolidou a proposta D.
- Signed commits and Sigstore consolidou signed commits, attestation e Sigstore como eixo único de integridade.

## Estrutura T3

```text
usehbn/radar/
├── README.md
├── REGISTRY.md
├── CONVERGENCE-MATRIX.md
└── _per-technology/
    ├── .gitkeep
    └── 55 fichas .md
```

## Fichas T4

Total criado: **55** fichas.

Distribuição por estado:

| in-radar | 35 |
| phagocytosed | 10 |
| under-analysis | 10 |

Distribuição por categoria:

| agentes | 6 |
| computacao-distribuida | 6 |
| conhecimento-estruturado | 14 |
| legado | 15 |
| observabilidade | 5 |
| outros | 9 |

## Achados notáveis

- Princípio 9 é o mais sensível para frameworks de agentes: o radar precisa impedir captura por ferramenta.
- Tecnologias legadas têm forte convergência com preservação de identidade, mas exigem camada de segurança e validação antes de qualquer execução.
- Observabilidade tem bom encaixe transversal, desde que logs e traces sejam evidência auxiliar, não autoridade final.
- MCP, JSONL e consent capsules são promissores, mas permanecem em `under-analysis` por exigirem decisão de arquitetura e política de privacidade.

## Bloqueios e decisões pendentes

- Sem bloqueio de coordenação: relay indicou E1 ativa e mensagens novas eram informativas.
- `.hbn/locks/` não existia; tratado como ausência de locks ativos.
- Decisão pendente: Opus/Maurício devem escolher quais itens `under-analysis` merecem experimento em E2/E3.
- Decisão pendente: quando promover fichas do Credenciamento para repo público, confirmar consentimento e licença por cápsula.

## Sugestão de próxima esteira E2

Executar ingestão do seed `PHAGOCYTOSIS-VBA-PATTERNS.md` no `usehbn-phago`, usando Markdown + YAML e campos de cápsula de consentimento desde o início. A CLI Python deve começar read-only com `hbn show <lesson-id>` ou equivalente, sem edição de conteúdo empírico até o schema estar validado.

## Arquivos gerados

- [`usehbn/radar/README.md`](../../usehbn/radar/README.md)
- [`usehbn/radar/REGISTRY.md`](../../usehbn/radar/REGISTRY.md)
- [`usehbn/radar/CONVERGENCE-MATRIX.md`](../../usehbn/radar/CONVERGENCE-MATRIX.md)
- [`usehbn/radar/_per-technology/`](../../usehbn/radar/_per-technology/)
- `~/Projetos/usehbn-phago/`
