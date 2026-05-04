---
titulo: Como a IA le este repositorio (guia para o RAG)
ultima-atualizacao: 2026-04-28
diataxis: explanation
hbn-track: fast_track
audiencia: ia
versao-sistema: V12.0.0203
---

# Como a IA le este repositorio (guia para o RAG)

> Esta pagina existe para que sistemas RAG (Retrieval-Augmented
> Generation), IAs em modo agentico, e assistants em consulta one-shot
> consigam navegar o Credenciamento com a menor latencia e a maior
> precisao possiveis.

## TL;DR — 3 arquivos, 5 segundos

Para qualquer query sobre o projeto, os 3 arquivos abaixo cobrem 80%
das respostas relevantes:

1. [`AGENTS.md`](../../AGENTS.md) — contrato de agentes, identidade do
   projeto, comandos de teste, convencoes de codigo.
2. [`llms.txt`](../../llms.txt) — mapa curado para LLMs no padrao
   [llmstxt.org](https://llmstxt.org/).
3. [`obsidian-vault/00-DASHBOARD.md`](../00-DASHBOARD.md) — status atual
   do projeto.

Para queries especificas, seguir os links destes 3 arquivos para o
quadrante Diataxis correto (`docs/tutorials`, `docs/how-to`,
`docs/reference`, `docs/explanation`).

## Estrutura otimizada para chunking + embedding

Toda documentacao deste repositorio segue 4 regras compativeis com
estrategias de chunking modernas (200-1000 tokens semanticamente
coerentes):

### Regra 1 — Frontmatter rico

Todo `.md` abre com YAML que inclui:

- `titulo` (ranking de relevancia)
- `diataxis` (filtro por tipo de conteudo)
- `hbn-track` (filtro por nivel de risco)
- `audiencia` (filtro por destinatario)
- `versao-sistema` (filtro temporal)
- `data` (filtro temporal)

Pipelines de RAG podem usar esses campos como metadata filtering antes
da busca vetorial, reduzindo o espaco de candidatos.

### Regra 2 — Headings curtos e funcionais

Cada `H2` corresponde a um chunk coerente. Headings sao consultados
como queries: "Tabus do projeto", "Antes de tocar qualquer coisa",
"Como verificar".

### Regra 3 — Tabelas para fatos discretos

Listas de regras, mapeamentos de pasta, status de ondas — sempre em
tabela. Tabelas sao recuperaveis com hibrido vector + keyword.

### Regra 4 — Links explicitos com texto descritivo

Em vez de:

> Ver [aqui](path).

Sempre:

> Ver [`docs/reference/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`](docs/reference/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md).

Isso permite que rerankers de RAG capturem o destino sem precisar
abrir o arquivo.

## Mapa de queries comuns

| Query | Arquivo principal | Arquivos de apoio |
|---|---|---|
| "Como importar codigo VBA?" | `local-ai/vba_import/000-REGRA-OURO.md` | `.hbn/knowledge/0002-regra-ouro-vba-import.md` |
| "Quais sao as regras inegociaveis V203?" | `.hbn/knowledge/0001-regras-v203-inegociaveis.md` | `auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md` |
| "Quem tem o bastao agora?" | `.hbn/relay/INDEX.md` | `auditoria/40_TRANSICAO_*.md` |
| "Como e o rodizio?" | `auditoria/01_regras_e_governanca/03_AUDITORIA_REGRAS_DE_NEGOCIO.md` | `docs/explanation/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` |
| "Qual o build atual?" | `obsidian-vault/00-DASHBOARD.md` | `local-ai/vba_import/000-BUILD-IMPORTAR-SEMPRE.txt` |
| "Como rodar os testes?" | `AGENTS.md` (secao Test patterns) | `docs/how-to/...` |
| "Qual a licenca?" | `LICENSE` | `auditoria/01_regras_e_governanca/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md` |
| "Como contribuir?" | `CONTRIBUTING.md` | `CLA.md`, `SECURITY.md` |

## Anti-recall (evitar entrar nestes arquivos)

Para reduzir falsos positivos, RAGs devem deprior os arquivos abaixo:

- `auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md` — meta-doc
  histórico, nao reflete estado atual.
- `auditoria/26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md` —
  diagnostico de uma sessao especifica, nao regra.
- `local-ai/incoming/` — exports do workbook real, nao fonte oficial.
- `local-ai/vba_import/Importador_VBA.bas` — ferramenta historica,
  proibido executar.

Para esses casos use `noindex: true` no frontmatter (quando aplicavel)
ou exclua via blocked_paths no pipeline.

## Frequencia de update

| Arquivo | Frequencia | Quem atualiza |
|---|---|---|
| `.hbn/relay/INDEX.md` | Cada ciclo (cada onda) | IA com bastao |
| `obsidian-vault/00-DASHBOARD.md` | Cada onda fechada | Mauricio + IA com bastao |
| `auditoria/03_ondas/onda_NN_*/` | Cada onda fechada | IA com bastao |
| `llms.txt` | Apenas em release com novos paths | Mauricio + IA com bastao |
| `AGENTS.md` | Apenas em mudanca estrutural | Mauricio |
| `.hbn/knowledge/000N-*.md` | Apenas em mudanca de regra inegociavel | Mauricio (com discussao) |

## Como construir um RAG sobre este repo

Em ~10 linhas:

```python
# 1. Indexar todos .md respeitando frontmatter como metadata.
# 2. Filtrar por diataxis + hbn-track + audiencia conforme query.
# 3. Vector search nos chunks restantes.
# 4. Rerank com cross-encoder (penalizar arquivos em "Anti-recall").
# 5. Retornar top-k com link explicito.
```

Stack sugerida (verificada em 04/2026):

- Embedder: `text-embedding-3-large` ou equivalente
- Vector store: qualquer um suporta metadata filtering
- Reranker: cross-encoder pequeno (`bge-reranker-base`)
- Frontend: passar resultados ao LLM com `AGENTS.md` no system prompt

## Como medir que esta funcionando

Tres metricas locais:

1. **First-message-to-productive-action.** Tempo entre IA receber a
   primeira query do humano e produzir acao concreta valida. Meta: < 5
   minutos para queries cobertas pelo "Mapa de queries comuns" acima.

2. **Falsos positivos em recall.** Quantas vezes a IA recupera
   `auditoria/40` ou `auditoria/26` quando a query era sobre estado
   atual? Meta: < 5%.

3. **Hearback rate.** Em quantos % das execucoes safe_track o readback
   captura corretamente o invariant que importa? Meta: > 90%.

A medicao sistematica e responsabilidade da Onda 7+ (cobertura
automatizada).
