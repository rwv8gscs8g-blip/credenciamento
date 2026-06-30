# HBN — Maturity Matrix

> Tabela viva por componente. Locked em v0.3.0 para fins de honestidade publica.
> Aberta para evoluir em versoes posteriores via Pull Request com evidencia.
> Documento normativo: o README e os docs publicos NAO podem afirmar nada que
> contradiga esta tabela.

## Por que este documento existe

HBN tem oito conceitos doutrinarios fortes (Readback, Hearback, Guardian, Truth
Barrier, ERP, Relay, Baton, Consent, Handoff) e uma visao publica que mira muito
adiante (Universal Translator, Phagocytosis, governanca multi-tecnologia). Sem
uma matriz unica e datada, qualquer doc pode prometer demais ou afirmar
maturidade que o codigo nao sustenta.

Este documento e a fonte unica de verdade para responder:

> "O que do HBN e implementado hoje, o que e parcial, o que e scaffold, o que e
> stub, e o que ainda e visao?"

## Cinco estados oficiais

| Estado | Significado tecnico | O que pode ser dito publicamente |
|---|---|---|
| **Implementado** | Codigo em producao, com testes verdes cobrindo o caminho feliz e ao menos um caminho de erro. Comportamento estavel. Documentado. | "Funciona hoje." |
| **Parcial** | Codigo existe e e testado, mas tem lacunas conhecidas e listadas. | "Funciona com limites X e Y." Lacunas devem ser citadas. |
| **Scaffold** | Estrutura de codigo presente. Comportamento mocado, conceitual ou superficial. Nao executa o que o nome promete. | "Ha estrutura, mas o comportamento ainda e conceitual." |
| **Stub** | Funcao/arquivo placeholder. Retorna constante, dict descritivo, ou levanta `NotImplementedError`. | "Apenas placeholder. Nada acontece em runtime." |
| **Visao** | Apenas em documentacao, roadmap ou doutrina. Nenhum codigo correspondente. | "Linha de pesquisa. Sem codigo associado." |

## Regra de evolucao de estado

Um componente sobe de estado APENAS quando:

1. PR explicito atualiza esta tabela com a nova classificacao.
2. PR cita evidencia (commit + arquivos + testes) para a nova classificacao.
3. Hearback humano confirma a transicao.

Nao se promove componente por consenso ou por "esta quase la". A transicao e
ato registrado.

## Localização canônica

A partir de 2026-05-10 (Iteração 9 do cronograma autônomo, ADR-003 §B
"Plano de compatibilidade core/ → modules/"), a fonte canônica desta
matriz vive em `methodology/MATURITY-MATRIX.md` (este arquivo). O
arquivo `docs/MATURITY-MATRIX.md` permanece com banner SUPERSEDED
apontando para cá, preservado pelo P7.

## Tabela canonica v0.3.0

| Componente | Estado | Evidencia (codigo / teste) | Risco principal | O que precisa para subir de estado |
|---|---|---|---|---|
| **CLI** | Implementado | `src/usehbn/cli.py`; ~17 subcomandos roteados em `main()`; integracao com Readback, Hearback, ERP, Relay, Handoff, Connector; golden tests em `tests/test_cli_golden_contract.py`; exit codes honestos (`2` erro CLI, `3` violacao de protocolo). | God-object (~1700 LOC). | Refatoracao interna (Onda 7) sem mudar contrato externo. |
| **Trigger / Ativacao semantica** | Implementado | `src/usehbn/trigger.py`; usado em `engine.py`. | Baixo. | Manter como esta. |
| **Intent (estruturacao)** | Parcial | `src/usehbn/protocol/intent.py`; regex-based; testes em `tests/`. | Falha em PT, multi-clausulas e dominios fora do ingles. | Schema estruturado de intent + caminho fallback regex. |
| **Truth Barrier** | Parcial (advisory) | `src/usehbn/protocol/truth_barrier.py`; regex; emite `warnings`; nao bloqueia (`engine.py:_validation_summary`). | Falsa sensacao de protecao. | RFC-0001 + modo `--enforce` opt-in (roadmap). |
| **Guardian** | Parcial (advisory) | `src/usehbn/protocol/guardian.py`; 2 checks; loga em `.hbn/logs/guardian.jsonl`. | Idem Truth Barrier. | RFC-0001 + modo `--enforce` opt-in (roadmap). |
| **Consent (CCP)** | Implementado | `src/usehbn/protocol/consent.py`; integrado em `engine.py`. | Sem expiracao enforced; sem revogacao. | Onda futura: enforcement de duracao + revocation log. |
| **Readback** | Implementado | `src/usehbn/protocol/readback.py`; campos `understanding`, `invariants_preserved`, `action_plan`, `out_of_scope`, `residual_risks`; schema `readback.schema.json` completo. | Nao chamado pelo `engine.py`; criado manualmente via CLI. | Documentar limite. Nao mudar contrato em v0.3.0. |
| **Hearback** | Implementado | `update_hearback_status` + `find_readback_by_execution`; bloqueia ERP se `hearback_status != "confirmed"` (ver `result.py:54`). | Efetivo apenas quando ha Readback associado. | Manter. |
| **ERP (Result)** | Implementado | `src/usehbn/protocol/result.py`; gates de hearback, readback_id em safe_track, bloqueio de overwrite, schema completo. | Lista fixa de risk_flags. | Onda futura: `protocol_version` obrigatorio (bump major). |
| **Relay** | Parcial honesto | `cli.py:_find_pending_readbacks` lê o canônico `.hbn/readbacks/` e o legado `.usehbn/readbacks/` em modo read-only, com dedup; `cli.py:_load_relay_state` tolera `audit_trail` ausente; testes `tests/test_relay.py` cobrem canonical write, fallback legado e migração tolerante. | Fallback legado ainda existe para compatibilidade; lacunas restantes: nenhum sistema de notificação multi-repo unificado em runtime (sinais multi-repo são marcadores, não daemons). | Implementação de schema mínimo para `signals-log.jsonl` em onda futura (já documentado em ADR-006). |
| **Baton** | Parcial honesto (Onda 3) | `relay/state.json` carrega `audit_trail` (capped 10 entries) com `{from, to, at, summary}`; `baton_staleness_seconds` opcional gera `baton_stale: bool` advisory em `run_relay_status`. | Sem alarme automático de staleness; `baton_stale` é apenas reportado. | Notificação automática quando `baton_stale: true` ultrapassa N reports (onda futura). |
| **Handoff** | Implementado | `cli.py:run_handoff` arquiva relay, atualiza state/INDEX. | Rename sem rollback automatico. | Dry-run + backup (Onda futura). |
| **Universal Translator** | Scaffold (com nome canonico de visao mantido) | `src/usehbn/translation/universal.py` + `connectors/`. Hoje: deteccao de ancora + perfil de ambiente + connector strategy. NAO traduz semanticamente entre linguas humanas ou tecnologias. | Promessa publica vs realidade. | Acompanhar `docs/PHAGOCYTOSIS.md`: o tradutor cresce com a fagocitose progressiva de cada tecnologia. |
| **Runtime Adapters** | Implementado | `src/usehbn/runtime.py:_adapter_body`; 7 runtimes (claude-code, codex, chatgpt, gemini, antigravity, copilot, cursor). | Body monolitico (string de ~250 LOC); mistura PT/EN. | Templating em onda futura. |
| **Connectors (resolver)** | Parcial | `src/usehbn/connectors/{catalog,profiles,resolver,contracts,storage,discovery,remote,trust}.py`; testes cobrindo VBA, COBOL, Java, C#. | "active" por mera presenca de arquivo. | Lifecycle FSM (Onda 4). |
| **Connectors (lifecycle)** | Scaffold (Onda 4 ratificada e aplicada) | `src/usehbn/connectors/storage.py:LIFECYCLE_STATES` (6 estados: detected/resolved/installed/verified/active/revoked); `load_registry`/`append_registry_record` aplicam migração tolerante e normalização para o default `detected`. Sem FSM ainda; sem transições automáticas. | Risco de Codex/IA confundir registro com enforcement. | FSM com verify por tecnologia em v0.4+ (sub-ADR dedicado). |
| **Connectors (verify)** | Stub | Sem implementacao. | Falsa ativacao. | Bridge Contributor Interface (BCI) + verify por tecnologia (v0.4+). |
| **Connectors (remote lookup)** | Scaffold | `src/usehbn/connectors/remote.py`; sem registry remoto real; default off em v0.3.0. | Promessa nao cumprida. | Registry GitHub-based em v0.5+. |
| **State (json append-only)** | Parcial honesto | `src/usehbn/state/store.py` escreve em `.hbn/state/hbn-state.json` (canônico); `load_state_document` lê legados `.usehbn/hbn-state.json` e `state/hbn-state.json` em modo read-only, com merge dedup por `execution_id` para `executions`/`results`, por `(execution_id, category)` para `decisions` e por conteúdo quando necessário; `protocol_version` opcional gravado nos records (Onda 2 ratificada e aplicada). | Crescimento ilimitado de records ainda existe — sem compactação/snapshot ainda. | `protocol_version` required + compactação periódica em v1.0.0 (decisão Q4 do plano v0.3.0). |
| **Autoevolve (audit/report)** | Parcial | `src/usehbn/autoevolve/audit.py`; `hbn autoevolve status/audit` leem JSONL, agregam status e renderizam markdown/HTML; testes em `tests/test_autoevolve.py` e `tests/test_audit_aggregator.py`. | Usuario/IA confundir trilha de auditoria com execucao autonoma real. | Popular `commit`/diff reais e amarrar reports a ciclos executados por worker funcional. |
| **Autoevolve (orchestrator/worker/queue/approval)** | Scaffold | `orchestrator.py` declara scaffold; `worker.py` documenta `apply` no-op; `contract.py` deixa `diff_added`/`diff_removed` como 0 por default; `approval.py` aplica gate sobre esses campos. | Teatro de automacao: nome sugere evolucao autonoma que nao existe em v0.3.0. | Worker que aplique mudancas, mensure diff real, fila acionavel e enforcement de budget antes de qualquer promocao. |
| **Autoevolve CLI** | Parcial | `hbn autoevolve status/audit/approve/rollback`; help raiz declara que nao ha evolucao autonoma em v0.3.0; sem `plan`/`run`; rollback imprime comando `git revert`, nao executa. | Superficie CLI pode parecer mais capaz que o runtime. | Subcomandos `plan/run` com worker real e rollback operacional testado. |
| **Schemas** | Implementado | 7 schemas em `schemas/`; `src/usehbn/utils/validators.py` suporta `minLength`, `maxLength`, `enum`, `required`, `properties`. | Validador customizado (nao jsonschema). | Manter em v0.3.0. Avaliar `jsonschema` em v0.5+. |
| **Privacy Contract** | Parcial / declarativo | `src/usehbn/connectors/contracts.py` + `connectors/remote.py:build_remote_lookup_descriptor` filtra payload. Demais campos sao declarativos. | Discrepancia promessa x runtime. | Onda 8: `hbn doctor --privacy` reporta inventario; sem alterar comportamento. |
| **Bridge generation (legado)** | Stub | `src/usehbn/bridge/vba.py` retorna dict descritivo. Conectores geram `.bas`, `.cbl`, `.java`, `.cs` com header "HBN bridge scaffold" sem logica funcional. | Promessa de bridge executavel. | `docs/PHAGOCYTOSIS.md` define caminho de evolucao por tecnologia. v0.4+: BCI por tecnologia. |
| **Tests** | Parcial | Suite verde 213/213 (`.venv/bin/pytest -q`, R1-fix-2); inclui version split, signals multi-repo, connector lifecycle, golden tests do CLI, exit codes honestos, estado canônico `.hbn/`, migração legada e regressão engine-real de decisions no merge. Foco em happy-path mais regressões dirigidas; sem testes adversariais sistemáticos ainda. | Sem testes adversariais amplos, concorrência, malformados, property-based. | Cada onda v0.3.0 obriga teste novo se tocar componente; testes adversariais sistemáticos em v0.4+. |
| **Distribuicao** | Parcial | `pyproject.toml` + `setup.cfg`; nao publicado em PyPI. `get-hbn` para bootstrap local. | Friccao de adocao. | Onda 5: TestPyPI primeiro (ver `docs/PUBLISHING-DECISION.md`). |
| **Phagocytosis (doutrina)** | Visao (doutrina canonica em v0.3.0) | `docs/PHAGOCYTOSIS.md`. | Conceito sem codigo associado. | Tornar-se Scaffold quando primeiro estagio de uma tecnologia for documentado em `.hbn/knowledge/by-tech/`. |
| **Credenciamento (caso de uso)** | Visao / referencia externa | `docs/CASE-STUDY-CREDENCIAMENTO.md`; nenhum codigo de Credenciamento neste repo. | Tratar como prova social externa. | Push publico de V12.0.0203 + autorizacao dos autores. |

## Como o publico le esta tabela

Antes de afirmar qualquer capacidade do HBN em README, blog, vitrine ou
release notes, consulte esta tabela. Se a afirmacao depende de algo no estado
**Scaffold**, **Stub** ou **Visao**, a afirmacao deve usar linguagem condicional
("o caminho de evolucao", "linha de pesquisa", "esqueleto inicial") e nunca
verbo no presente do indicativo absoluto.

Exemplos validos:

- "HBN inclui um Universal Translator hoje em estado Scaffold: ele e um
  roteador honesto que conecta a tecnologia detectada ao adapter correto. A
  evolucao para tradutor semantico e descrita em `docs/PHAGOCYTOSIS.md`."
- "Bridges legados sao Stubs em v0.3.0: produzem arquivos de scaffold
  documental. Bridges executaveis aparecem por tecnologia conforme cada
  comunidade abre PRs de Phagocytosis."

Exemplos invalidos (proibidos):

- "HBN traduz qualquer linguagem natural em qualquer tecnologia."
- "HBN gera bridges executaveis em VBA, COBOL, Java e C# automaticamente."
- "HBN garante privacidade local."

## Auditoria desta tabela

A cada release minor, o mantenedor (Luis Mauricio Junqueira Zanin) deve abrir
uma onda de auditoria que reconfere cada linha desta tabela contra o codigo
real e atualiza a coluna **Estado** se necessario. Sem essa auditoria, a
release nao sai.
