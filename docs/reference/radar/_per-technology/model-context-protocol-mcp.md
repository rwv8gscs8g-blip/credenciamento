---
titulo: Model Context Protocol (MCP)
slug: model-context-protocol-mcp
categoria: conhecimento-estruturado
estado: convergence-mapped
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (promovida a convergence-mapped após hearback Maurício)
proxima-revisao: 2026-06-02
fonte-radar: ".hbn/knowledge/0005-protocolo-markers-v2.md:31-83,108-142"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT (especificação) + MIT (SDKs oficiais)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Model Context Protocol (MCP)

## Por que está no radar

MCP foi citado em `0005-protocolo-markers-v2.md` como camada possível para expor regras ativas do useHBN como "tools" consumíveis por LLMs (Claude, OpenAI, etc.). A decisão Codex 103 foi adotar **MCP read-only inicialmente; enforcement vive em CLI local**. Esta ficha captura por que essa escolha faz sentido e o que muda quando MCP virar camada de leitura ativa do useHBN.

## Resumo da tecnologia

MCP (Model Context Protocol) é um **protocolo aberto** publicado pela Anthropic em novembro/2024 para padronizar como modelos de linguagem se conectam a fontes externas de contexto (arquivos, APIs, bancos de dados, ferramentas).

Arquitetura cliente-servidor:
- **Servidor MCP**: expõe três tipos de capacidade — `resources` (dados read-only com URI), `tools` (funções invocáveis com side-effect), `prompts` (templates parametrizados).
- **Cliente MCP**: aplicação host (Claude Desktop, Claude Code, IDEs com MCP support) que descobre servidores via configuração e roteia chamadas.
- **Transporte**: stdio (processo local) ou SSE/HTTP (remoto).

SDKs oficiais em Python, TypeScript, Java, Kotlin, C#. Adotado por Claude Desktop, Claude Code, Cline, Continue.dev, Zed; ecossistema com ~200 servidores em 2026 (filesystem, git, databases, GitHub, Slack, etc.).

Para o useHBN, MCP responde uma necessidade concreta: como expor radar, readbacks, relay/INDEX para que IAs (Claude, Codex) consultem **sem reler os arquivos toda vez**? Servidor MCP `hbn-server` expondo `resources` (radar://, relay://, knowledge://) seria a interface natural.

Licença: especificação MIT, SDKs MIT.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | MCP é leitura sobre dados existentes; não força reescrita do underlying. Servidor MCP expõe os arquivos `.md` e `.json` do useHBN sem alterá-los. |
| 2 | Documentar antes de executar | sim | Recursos MCP têm `description` obrigatória; tools têm schema JSON. Auto-documentação por design. |
| 3 | Testar antes de refatorar | sim | Servidores MCP são processos isoláveis testáveis com mock client; SDK Python tem `MCPInspector` para debug interativo. |
| 4 | Explicar antes de automatizar | sim | Modo `resources` é inerentemente read-only — IA explica/responde com base em contexto, não age. Encaixe direto. |
| 5 | Humano no controle por padrão | sim | Cliente MCP precisa **autorização explícita** para conectar a servidor; cada `tool call` pode exigir aprovação. Match perfeito com workflow Cowork. |
| 6 | Toda evolução deve ser reversível | sim | Servidor MCP pode ser desligado sem afetar dados subjacentes. Versionamento da especificação é semântico. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | MCP é camada *sobre* dados — VBA continua VBA, Markdown continua Markdown, expostos via URI. Identidade intacta. |
| 8 | O protocolo importa mais que a ferramenta | sim | MCP **é protocolo**, não framework. Múltiplas implementações concorrem; padrão aberto. Encaixe arquitetural ideal. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Implementação trocável (SDK Python, TS, etc.); especificação estável. Lock-in baixo. |
| 10 | Segurança e não-regressão > velocidade | parcial | Modelo de segurança ainda em maturação: validação de servidor, sandbox de tools, escopos de permissão são responsabilidade do cliente. Risco se host não implementar bem. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.** Uma das tecnologias com encaixe mais forte da matriz inteira.

## Divergências e riscos

- **Maturidade do modelo de segurança**: especificação delega muito ao cliente; servidor mal-escrito pode vazar dados sensíveis (contexto integral de arquivo, p.ex.).
- **Dependência da Anthropic** como mantenedora primária da especificação (mitigado por adoção multi-vendor crescente).
- **Performance em recursos grandes**: ler arquivo de 10MB via MCP cria context bloat; precisa estratégia de paginação/projeção.
- **Ecossistema jovem**: ~200 servidores em 2026, mas qualidade variável; auditar antes de adotar.
- **Risco de license-leak**: servidor MCP exposto sem proteção pode servir conteúdo TPGL para clientes que assumem AGPLv3.

## O que precisa para avançar de estado

Para `convergence-mapped`:
- POC: servidor MCP `hbn-server` em Python expondo `resource://radar/{slug}` e `resource://relay/index` em modo read-only
- Testar em Claude Desktop (cliente MCP nativo) e validar latência + isolamento
- Definir política de redação: nenhum servidor MCP pode expor `.hbn/readbacks/` sem consentimento explícito (proposta D — capsule fields)

Para `candidate`:
- Decisão de Maurício após ver POC + medir tradeoffs (vale o overhead vs ler arquivos direto?)

Para `phagocytosed`:
- `hbn-server` virar parte da CLI `hbn` (Wave 11+); mencionado em PROTOCOL.md do `usehbn-phago`

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | under-analysis | Entrada inicial; já mencionado em propostas Codex 103 | Codex CLI, sob spec Opus |
| 2026-05-02 | under-analysis | under-analysis | Reescrita de conteúdo (Opus análise individual) | Claude Opus 4.7 (Frente 2) |
| 2026-05-02 | under-analysis | convergence-mapped | Convergência 9/10 confirmada por análise individual; aprovação explícita do operador no hearback "sim para todas as quatro" | Maurício + Opus |

## Referências

- [Especificação oficial](https://modelcontextprotocol.io/) — protocolo, schemas, exemplos
- [Repositório GitHub (specification)](https://github.com/modelcontextprotocol/specification) — MIT License
- [SDK Python](https://github.com/modelcontextprotocol/python-sdk)
- [Anúncio Anthropic (nov/2024)](https://www.anthropic.com/news/model-context-protocol)
- [Lista de servidores](https://github.com/modelcontextprotocol/servers) — ~200 implementações
- [MCP Inspector (debug tool)](https://github.com/modelcontextprotocol/inspector)
- Fontes internas: `.hbn/knowledge/0005-protocolo-markers-v2.md:31-83,108-142` + Codex 103/103b
