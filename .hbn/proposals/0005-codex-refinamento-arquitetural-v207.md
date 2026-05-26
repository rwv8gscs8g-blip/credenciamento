---
titulo: Refinamento Arquitetural V12.0.0207 — Codex (2ª rodada)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-26
---

# Refinamento Arquitetural V12.0.0207 — Codex (2ª rodada)

Este documento aprofunda as duas alternativas selecionadas por Mauricio após a auditoria cruzada V207. A análise considera o estado de V206 em `146aaf7`, o anchor funcional `ee75b30`, a análise Opus `111_ANALISE_AUDITORIA_CRUZADA_V207.md`, as propostas 0001-0004 e a leitura pontual dos módulos VBA envolvidos. Nenhuma modificação funcional de código é proposta como delta pronto; o objetivo aqui é arquitetura, sequência e gates.

Premissa central: a planilha continua sendo porta de entrada, porta de saída, formato de migração, formato de auditoria e garantia de independência tecnológica do município. Qualquer caminho SaaS futuro precisa preservar exportação completa e operação local.

## 1. Alternativa I — refinamento

A Alternativa I separa a evolução em duas releases distintas. A V207 corrige o caminho monolítico com serviços, repositórios, escrita em bloco e testes E2E. A V208 introduz o Caminho 2 completo: repositórios como ORM primitivo, dirty checking e transação em memória.

### 1.1 Sequência detalhada de ondas V207 (5-7 ondas)

#### Onda V207.0 — Base de contratos e quick wins defensivos

- Escopo: consolidar os invariantes antes de mexer em cadastros. Inclui `Util_MaxIdOperacional` pair-aware para abas ativas/inativas, fix F-NEW3 por `NumberFormat = "@"` em coluna A, hardening `handler-before-flag` em `Util_Excel_Performance` e padronização de métricas simples de tempo.
- Módulos tocados: `Util_Planilha.bas`, `Util_Sanear_Contadores.bas`, `Util_Excel_Performance.bas`, módulos de teste e documentação de contratos. Evitar `Menu_Principal.frm` nesta onda, exceto se o fix de formato precisar de chamada explícita de saneamento.
- Contratos novos: `CONTRACT_ID_MONOTONICO_OPERACIONAL`, `CONTRACT_COLUNA_A_TEXTO_PAD3`, `CONTRACT_EXCEL_PERF_RESTAURA_SEMPRE`.
- Testes obrigatórios: unitários VBA para `ProximoId` em pares ativo/inativo, saneamento idempotente, wrapper de performance com erro simulado antes e depois de alterar flags.
- Gates de saída: RVS Trio verde, E2E unitário de IDs verde, workbook sem regressão de AR1, evidência de `5` vs `005` corrigida no cadastro de entidade.
- Anchor de rollback: commit de fechamento da própria onda; fallback direto para `ee75b30` se o saneamento mexer em dados reais de forma inesperada.

#### Onda V207.1 — E2E_CADASTROS como gate antes da refatoração

- Escopo: criar a bateria `E2E_CADASTROS` antes de trocar rotas. Ela deve reproduzir cadastros por fluxo real de UI ou por fachada equivalente, e não apenas por fixtures artificiais.
- Módulos tocados: `Teste_V2_Engine.bas`, módulos auxiliares de teste, catálogo de testes, procedimento de importação e documentação de evidências.
- Contratos novos: `CONTRACT_E2E_CADASTROS_REAL_ROUTE`, `CONTRACT_FIXTURE_RESTORE_IDEMPOTENTE`, `CONTRACT_ASSERT_LISTBOX_REFLETE_CADASTRO`.
- Testes obrigatórios: empresa nova, entidade nova, serviço/atividade, credenciamento empresa-serviço, duplicate CNPJ, reativação, cancelamento pelo usuário, erro de proteção de aba, cadastro seguido de reload de lista.
- Gates de saída: bateria falha em baseline quando F-NEW3/F-NEW4-DT está exposto e passa depois dos fixes; nenhum teste depende de ordem física acidental fora dos contratos.
- Anchor de rollback: commit anterior à introdução da bateria, porque esta onda não deve alterar comportamento de produção.

#### Onda V207.2 — Rota Empresa por Svc_CadastroEmpresa

- Escopo: retirar o cadastro de empresa do bloco direto de `Menu_Principal.frm:2242-2269` e passar por `Svc_CadastroEmpresa`, mantendo `Repo_Empresa` como ponto único de persistência. Trocar escrita célula a célula por array de linha, preservar validações de CNPJ e mensagens.
- Módulos tocados: `Menu_Principal.frm`, `Repo_Empresa.bas`, novo `Svc_CadastroEmpresa.bas`, `Util_Excel_Performance.bas`, testes.
- Contratos novos: `CONTRACT_CADASTRO_EMPRESA_COMMAND`, `CONTRACT_REPO_EMPRESA_SEM_UI`, `CONTRACT_POS_CADASTRO_LAZY_RELOAD`.
- Testes obrigatórios: cadastrar empresa ativa, bloquear CNPJ duplicado, validar ID monotônico, validar atualização de `EMP_Lista`, validar que `PreenchimentoCRServico` só roda quando necessário.
- Gates de saída: `E2E_CADASTROS.Empresa` verde, reload pós-cadastro medido, `Repo_Empresa` sem `MsgBox` novo, `Audit_Log` registrado para mutação.
- Anchor de rollback: commit V207.1; a UI antiga ainda deve poder ser restaurada por revert de um único delta.

#### Onda V207.3 — Rota Entidade e correção F-NEW3 na origem

- Escopo: retirar o cadastro de entidade de `Menu_Principal.frm:1611-1676`, criar `Svc_CadastroEntidade` e `Repo_Entidade` ou equivalente mínimo, escrever a linha por bloco e garantir coluna A textual antes da gravação. Esta é a correção definitiva do F-NEW3.
- Módulos tocados: `Menu_Principal.frm`, novo `Svc_CadastroEntidade.bas`, novo/ajustado `Repo_Entidade.bas`, `Util_Planilha.bas`, testes.
- Contratos novos: `CONTRACT_CADASTRO_ENTIDADE_COMMAND`, `CONTRACT_ENTIDADE_ID_PAD3_VISUAL`, `CONTRACT_RELOAD_ENTIDADE_INVALIDAVEL`.
- Testes obrigatórios: entidade nova, CNPJ vazio/duplicado se aplicável, ID `005` preservado como texto, `C_Lista` e `C_ListaRodizio` refletindo inclusão, rollback de proteção de aba.
- Gates de saída: F-NEW3 fechado por E2E, nenhum `.Select`/`ActiveCell`, nenhuma nova escrita célula a célula em bloco de cadastro.
- Anchor de rollback: commit V207.2; se a rota nova falhar, reverter somente entidade e manter empresa estável.

#### Onda V207.4 — Serviços, credenciamento e Preencher crítico

- Escopo: estabilizar cadastro de serviço/atividade e credenciamento com serviços explícitos. Reduzir loops massivos em `Preencher.bas`, especialmente `PreenchimentoServico`, `PreenchimentoCRServico`, `PreencherServicoFormatado`, `PreencherManutencaoValor`, `PreencherPreencheOS` e `PreencherAvaliarOS`.
- Módulos tocados: `Cadastro_Servico.frm`, `Credencia_Empresa.frm`, `Menu_Principal.frm`, `Preencher.bas`, `Repo_Credenciamento.bas`, `Repo_PreOS.bas`, `Repo_OS.bas`, `Repo_Avaliacao.bas`, novos `Svc_CadastroServico.bas` e `Svc_CredenciamentoCadastro.bas`.
- Contratos novos: `CONTRACT_SERVICO_VIEWMODEL_ARRAY`, `CONTRACT_CREDENCIAMENTO_COMMAND`, `CONTRACT_LISTBOX_LIST_ASSIGNMENT`.
- Testes obrigatórios: serviço novo, manutenção de valor, credenciamento de empresa em serviço, emissão Pre-OS depois de cadastro, atualização de listas dependentes.
- Gates de saída: `PreencherServicoFormatado` não usa `AddItem` em loop principal; ListBoxes críticas recebem array 2D; RVS Trio + E2E_CADASTROS verde.
- Anchor de rollback: commit V207.3; se credenciamento falhar, preservar rotas Empresa/Entidade.

#### Onda V207.5 — Repositórios residuais, lazy reload e medição

- Escopo: envelopar `Repo_Credenciamento.bas`, `Repo_OS.bas`, `Repo_PreOS.bas` e `Repo_Avaliacao.bas` com wrapper de performance endurecido; implantar lazy reload determinístico nas listas; medir tempo antes/depois em PC antigo ou perfil simulado.
- Módulos tocados: `Repo_Credenciamento.bas`, `Repo_OS.bas`, `Repo_PreOS.bas`, `Repo_Avaliacao.bas`, `Preencher.bas`, `Menu_Principal.frm`, testes de performance assistida.
- Contratos novos: `CONTRACT_REPO_MUTATION_PERF_WRAPPED`, `CONTRACT_RELOAD_SOMENTE_SE_DIRTY`, `CONTRACT_PERF_MARKERS`.
- Testes obrigatórios: smoke de Pre-OS/OS/avaliação, reload seletivo, erro em repo restaurando Application flags, medição de tempo em cadastro completo.
- Gates de saída: ganho perceptual mínimo documentado, nenhuma lista reconstruída sem dirty flag após cadastro não relacionado, sem regressão de relatórios.
- Anchor de rollback: commit V207.4; esta onda deve ser reversível sem perder serviços de cadastro.

#### Onda V207.6 — Freeze V207 e preparação controlada para V208

- Escopo: consolidar docs, catalogar contratos como conhecimento HBN, atualizar procedimentos de importação, decidir se `Importador_V3` recebe apenas fix pequeno de `BUMP_NO_OP` ou se isso fica para V208. Nenhum novo paradigma em memória entra aqui.
- Módulos tocados: documentação, testes, possivelmente `Importador_V3.bas` se Mauricio liberar explicitamente delta isolado.
- Contratos novos: `CONTRACT_RELEASE_FREEZE_V207`, `CONTRACT_EXPORT_IMPORT_SOBERANIA`, `CONTRACT_NO_CACHE_INMEMORY_IN_V207_I`.
- Testes obrigatórios: RVS Trio completo, E2E_CADASTROS completo, teste assistido de workbook antigo, teste de exportação para município.
- Gates de saída: tag/anchor de freeze V207, matriz de cobertura atualizada, zero bug aberto crítico/alto em cadastros.
- Anchor de rollback: commit V207.5; para release oficial, tag `v12.0.0207` somente após validação humana.

### 1.2 Sequência detalhada de ondas V208 (7-10 ondas)

#### Onda V208.0 — Tipos, DTOs e contrato de resultado

- Escopo: mover o retorno `Variant` frágil para tipos explícitos quando fizer sentido, criar DTOs simples para Empresa, Entidade, Serviço, Credenciamento, Pre-OS, OS e Avaliação, e padronizar `TResult`/`TRepoResult`.
- Módulos tocados: `Mod_Types.bas`, `Svc_*`, `Repo_*`, testes de compile.
- Contratos novos: `CONTRACT_DTO_SEM_RANGE`, `CONTRACT_RESULT_SEM_MSGBOX`.
- Testes obrigatórios: compile limpo após importação, serialização básica dos DTOs, nenhum DTO com referência a `Worksheet`/`Range`.
- Anchor de rollback: freeze V207.

#### Onda V208.1 — Repos puros como ORM primitivo de leitura

- Escopo: cada `Repo_*` passa a carregar linhas para registros em memória com índice por ID e por chave natural. Nesta onda a escrita ainda pode continuar pela rota antiga para reduzir risco.
- Módulos tocados: `Repo_Empresa`, `Repo_Entidade`, `Repo_Credenciamento`, `Repo_PreOS`, `Repo_OS`, `Repo_Avaliacao`, novos helpers de índice.
- Contratos novos: `CONTRACT_REPO_LOAD_ALL`, `CONTRACT_INDEX_BY_ID`.
- Testes obrigatórios: contagem de linhas, busca por ID, busca por CNPJ/chave composta, equivalência com leitura direta da planilha.
- Anchor de rollback: V208.0.

#### Onda V208.2 — Dirty checking por linha e hash lógico

- Escopo: armazenar `rowIndex`, `rowHash`, `loadedAtVersion` e `dirty` nos registros. Antes de escrever, comparar hash atual da planilha com hash carregado; se divergir, abortar e pedir reload.
- Módulos tocados: repositórios, `Util_Hash`/helper equivalente, testes.
- Contratos novos: `CONTRACT_DIRTY_CHECK_ROW_HASH`, `CONTRACT_ABORT_ON_STALE_ROW`.
- Testes obrigatórios: alteração manual de célula após carga, conflito detectado, atualização sem conflito, linha apagada entre carga e commit.
- Anchor de rollback: V208.1.

#### Onda V208.3 — UnitOfWork e transação memória -> planilha

- Escopo: introduzir uma unidade de trabalho em VBA que agrupa mutações, captura snapshot de ranges afetados, escreve em bloco, registra `TX_PENDING`, limpa `TX_PENDING` ao final e executa compensação se erro ocorrer enquanto o processo ainda está vivo.
- Módulos tocados: novo `Svc_UnitOfWork.bas` ou `Repo_Transaction.bas`, `Audit_Log`, repositórios mutadores.
- Contratos novos: `CONTRACT_TX_PENDING`, `CONTRACT_TX_ROLLBACK_IN_PROCESS`, `CONTRACT_TX_RECOVERY_ON_OPEN`.
- Testes obrigatórios: erro no meio do commit, restauração de snapshot, crash simulado com marcador pendente, abertura seguinte propondo recuperação.
- Anchor de rollback: V208.2.

#### Onda V208.4 — Adapters UI e remoção de leitura direta em forms

- Escopo: forms deixam de ler planilha diretamente para popular campos; passam por view models/adapters. `Menu_Principal.frm` consome DTOs e listas, não `Cells`.
- Módulos tocados: `Menu_Principal.frm`, `Credencia_Empresa.frm`, `Cadastro_Servico.frm`, `Preencher.bas`, novos adapters.
- Contratos novos: `CONTRACT_UI_SEM_CELLS`, `CONTRACT_VIEWMODEL_LISTBOX`.
- Testes obrigatórios: clique em `EMP_Lista`, `C_Lista`, `A_Lista`, `H_Lista`, `OS_Lista`, `AV_Lista`; todos preservam preenchimento de controles.
- Anchor de rollback: V208.3.

#### Onda V208.5 — Cache completo de listas e invalidadores

- Escopo: o cache passa a ser infraestrutura comum, não apenas otimização de tela. Invalidação por domínio e reconstrução stateless quando necessário.
- Módulos tocados: cache comum, repositórios, `Preencher.bas`, forms.
- Contratos novos: `CONTRACT_CACHE_DOMAIN_INVALIDATION`, `CONTRACT_CACHE_REBUILD_FROM_SHEET`.
- Testes obrigatórios: cadastro invalida listas corretas, alteração de OS invalida listas de OS/avaliação, rebuild preserva ordenação.
- Anchor de rollback: V208.4.

#### Onda V208.6 — Export/import roundtrip soberano

- Escopo: provar que a nova camada em memória não enfraquece a planilha como formato de migração. Exportar, importar em workbook limpo e comparar contagens, IDs, chaves e logs.
- Módulos tocados: export/import, testes, docs, possivelmente `Importador_V3.bas` se necessário para artefatos de contrato.
- Contratos novos: `CONTRACT_EXPORT_IMPORT_ROUNDTRIP`, `CONTRACT_PLANILHA_EGRESSO_TOTAL`.
- Testes obrigatórios: roundtrip de base com empresas inativas, entidades inativas, Pre-OS, OS, avaliações e credenciamentos.
- Anchor de rollback: V208.5.

#### Onda V208.7 — Importador V3 hardening

- Escopo: corrigir `BUMP_NO_CHANGE` para `BUMP_NO_OP`, validar ordem de importação de tipos/classes, reforçar preflight `.frm/.frx` sem alterar semântica de importação.
- Módulos tocados: `Importador_V3.bas`, manifesto, docs de importação, testes manuais assistidos.
- Contratos novos: `CONTRACT_IMPORTADOR_BUMP_NO_OP`, `CONTRACT_IMPORT_ORDER_TYPES_FIRST`.
- Testes obrigatórios: importação sem mudança de build, importação com build alterado, `.frm` com `.frx` ausente/corrompido detectável.
- Anchor de rollback: V208.6.

#### Onda V208.8 — Freeze V208 e decisão SaaS

- Escopo: congelar arquitetura em memória, medir performance final e decidir se o próximo salto é backend/API ou manutenção local.
- Módulos tocados: documentação, evidências, testes, release notes.
- Contratos novos: `CONTRACT_V208_FREEZE`, `CONTRACT_SAAS_READINESS_DECISION`.
- Testes obrigatórios: RVS completo, E2E_CADASTROS completo, roundtrip completo, teste assistido de PC antigo.
- Anchor de rollback: V208.7 e tag oficial V207 como fallback operacional.

### 1.3 Contratos entre V207 e V208

- `Svc_*` não pode depender de `Worksheet`, `Range`, `UserForm`, `MsgBox` ou variáveis globais de tela. Se V207 mantiver alguma exceção, ela deve ser registrada como dívida bloqueante para V208.
- `Repo_*` em V207 deve ser a única fronteira de persistência mutadora. Isso permite trocar a implementação interna por ORM primitivo em V208 sem reescrever os forms.
- IDs devem sair sempre de `Util_MaxIdOperacional`/`ProximoId` e nunca de cálculo local em form.
- ListBoxes devem receber view models ou arrays 2D por helpers centralizados. O form não deve conhecer a aba física que originou cada coluna.
- Toda mutação deve retornar um resultado estruturado com sucesso, mensagem, ID gerado e domínios de lista invalidados.
- A bateria `E2E_CADASTROS` vira contrato de compatibilidade. V208 só é aceita se passar os mesmos cenários sem alterar o roteiro humano.

### 1.4 Riscos identificados e mitigação

| Risco | Severidade | Mitigação |
|---|---:|---|
| F-NEW4 perceptual continuar até V208 | Alto | Medir V207.5; se o reload de ListBox ainda for gargalo, abrir gate humano para migrar à Alternativa II. |
| Fadiga operacional por 12-17 ondas | Alto | Agrupar ondas pequenas, manter cada importação com pacote mínimo e evitar alterações em `Importador_V3` antes de freeze. |
| V207 criar serviços que ainda vazam planilha | Alto | Gate `Svc_* sem Worksheet/Range` antes de freeze. |
| V208 virar reescrita disfarçada | Médio/alto | Introduzir leitura em memória antes de escrita, e dirty checking antes de transação. |
| `Mod_Types.bas` quebrar compile global | Alto | Entrar só em V208.0 com readback próprio, import order explícita e teste de compile dedicado. |
| Docs V207 ficarem obsoletos logo na V208 | Médio | Doc-delta por onda e marcação clara de contratos transitórios. |

### 1.5 Dependências entre ondas (DAG)

```text
V207.0
  -> V207.1
      -> V207.2
      -> V207.3
          -> V207.4
              -> V207.5
                  -> V207.6 freeze
                      -> V208.0
                          -> V208.1
                              -> V208.2
                                  -> V208.3
                                      -> V208.4
                                          -> V208.5
                                              -> V208.6
                                                  -> V208.7
                                                      -> V208.8 freeze
```

Dependência crítica: V208.0 só pode começar se V207.6 fechar com serviços sem vazamento de UI/planilha, E2E_CADASTROS verde e baseline de performance documentado.

### 1.6 Critérios de freeze V207 (gate para abrir V208)

- RVS Trio verde no workbook importado.
- `E2E_CADASTROS` verde cobrindo empresa, entidade, serviço, credenciamento, reativação e listas pós-cadastro.
- F-NEW3 fechado com evidência visual e de célula: ID na coluna A como texto padronizado `000`.
- `Util_MaxIdOperacional` provado em abas pareadas ativas/inativas.
- Nenhuma rotina pública nova sem `ErrorBoundary` ou handler equivalente.
- Nenhum cadastro principal escrevendo linha campo a campo dentro de form.
- Medição de F-NEW4 residual documentada. Se reload pós-cadastro ainda for acima do limiar humano definido, a decisão de seguir para V208 deve ser reavaliada.
- Exportação de dados para planilha e auditoria preservada.

### 1.7 Custo total estimado (homem-hora-IA, sessões Opus+Codex)

- V207: 32-48 homem-hora-IA, 6-8 sessões Opus para arquitetura/readbacks/gates e 7-10 sessões Codex para execução/auditoria de delta.
- V208: 55-85 homem-hora-IA, 8-12 sessões Opus e 10-16 sessões Codex, porque `Mod_Types`, dirty checking, transação e importador exigem isolamento.
- Total: 87-133 homem-hora-IA, 21-34 sessões entre Opus+Codex, 12-17 gates humanos de importação/validação.
- Custo humano dominante: repetição de importação VBE, compile, RVS e evidências. Este é o principal ponto fraco da Alternativa I.

## 2. Alternativa II — refinamento

A Alternativa II mantém as ondas V207.0-V207.4 do Caminho 1, mas adiciona em V207.5-V207.7 um cache parcial em memória apenas para listas grandes do `Menu_Principal` e fluxos diretamente ligados a F-NEW4. Ela não tenta transformar todos os repositórios em ORM na V207.

### 2.1 Sequência detalhada (7-9 ondas)

#### Onda V207.0 — Base defensiva idêntica à Alternativa I

- Escopo: `Util_MaxIdOperacional`, F-NEW3, `handler-before-flag`, wrappers idempotentes, medição inicial.
- Módulos tocados: `Util_Planilha.bas`, `Util_Sanear_Contadores.bas`, `Util_Excel_Performance.bas`, testes.
- Gate: IDs, AR1, wrapper e formato de coluna A verdes.
- Rollback: anchor `ee75b30` ou commit anterior à onda.

#### Onda V207.1 — E2E_CADASTROS e baseline de performance

- Escopo: criar a bateria E2E e medir tempo real de cadastro + reload das listas antes de otimizar.
- Módulos tocados: testes, docs, helpers de medição.
- Gate: bateria executável, com cenários de UI/cadastro e métricas registradas.
- Rollback: sem impacto funcional.

#### Onda V207.2 — Empresa por serviço/repositorio

- Escopo: `Svc_CadastroEmpresa`, rota única por `Repo_Empresa`, escrita em bloco, reload preguiçoso.
- Módulos tocados: `Menu_Principal.frm`, `Repo_Empresa.bas`, novo serviço, testes.
- Gate: empresa nova, duplicidade, lista pós-cadastro e auditoria verdes.
- Rollback: commit V207.1.

#### Onda V207.3 — Entidade por serviço/repositorio

- Escopo: `Svc_CadastroEntidade`, `Repo_Entidade`, F-NEW3 fechado na rota real, listas de entidade invalidáveis.
- Módulos tocados: `Menu_Principal.frm`, serviço/repo de entidade, testes.
- Gate: cadastro de entidade com ID `005` textual e `C_Lista`/`C_ListaRodizio` coerentes.
- Rollback: commit V207.2.

#### Onda V207.4 — Serviço, credenciamento e ListBox por array

- Escopo: serviço/atividade e credenciamento em contratos; `Preencher.bas` trocando loops `AddItem` por array onde ainda houver gargalo óbvio; repos residuais envelopados se o escopo couber.
- Módulos tocados: `Cadastro_Servico.frm`, `Credencia_Empresa.frm`, `Preencher.bas`, `Repo_Credenciamento.bas`, `Repo_PreOS.bas`, `Repo_OS.bas`, `Repo_Avaliacao.bas`, serviços novos.
- Gate: RVS + E2E_CADASTROS verde; medição pós-Caminho 1; decisão humana formal para entrar ou não em V207.5.
- Rollback: commit V207.3.

#### Onda V207.5 — Cache read-only de listas críticas

- Escopo: criar cache em memória somente de leitura para listas grandes e filtros. Nenhuma escrita via cache nesta onda.
- Módulos tocados: novo `Cache_Listas_Menu.bas` ou equivalente, `Preencher.bas`, `Menu_Principal.frm`, testes de consistência.
- ListBoxes prioritárias: `EMP_Lista`, `C_Lista`, `C_ListaRodizio`, `A_Lista`, `H_Lista`, `CR_Lista` em `Credencia_Empresa`. ListBoxes secundárias sob medição: `OS_Lista` e `AV_Lista`, porque hoje fazem joins repetidos contra `PREOS`, `CAD_OS`, `EMPRESAS`, `ENTIDADE` e `CAD_SERV`.
- Gate: cache gera as mesmas linhas e colunas que o `Preencher` antigo, com tempo medido menor, e pode ser desligado por flag de fallback.
- Rollback: desativar flag de cache e retornar aos `Preencher*` baseados em planilha.

#### Onda V207.6 — Invalidação, dirty checking leve e lazy reload

- Escopo: registrar domínios de cache (`EMPRESAS`, `ENTIDADE`, `CAD_SERV`, `CREDENCIAMENTO`, `PREOS`, `CAD_OS`) e invalidar após cada serviço mutador. Dirty checking é leve: `rowIndex + rowHash + ultimaLinha + ar1 + cacheVersion`; se divergente, o cache reconstrói tudo.
- Módulos tocados: cache, serviços, repos mutadores, `Preencher.bas`, testes.
- Gate: cadastro invalida apenas os domínios corretos; edição manual simulada de planilha invalida/reconstrói; nenhuma lista fica stale após operação.
- Rollback: manter serviços e escrita em bloco, desligar cache por domínio.

#### Onda V207.7 — Commit transacional mínimo para operações com cache

- Escopo: se alguma rota passar a montar payload de escrita a partir do estado em memória, ela deve usar transação mínima. Antes do writeback, capturar snapshot persistente das linhas/ranges afetados, gravar marcador `TX_PENDING`, escrever em bloco, validar, limpar marcador. Se ocorrer erro em processo vivo, restaurar snapshot. Se o Excel crashar, a abertura seguinte detecta marcador pendente e oferece recuperação.
- Módulos tocados: helper transacional, serviços que gravam cadastros, `Audit_Log`, testes de falha.
- Gate: erro simulado no meio do writeback restaura estado; crash simulado deixa rastro recuperável; sem marcador pendente após fluxo normal.
- Rollback: desligar writeback via cache e manter cache read-only.

#### Onda V207.8 — Freeze híbrido e decisão V208+

- Escopo: estabilizar docs, evidências, thresholds de performance e decidir se V208 completo ainda é necessário.
- Módulos tocados: docs, testes, release notes, HBN knowledge.
- Gate: RVS + E2E_CADASTROS + teste assistido em PC antigo; sem bugs críticos/altos em cache/invalidação.
- Rollback: tag/anchor V207.4 como baseline sem cache, mais fallback por flag em V207.8.

### 2.2 Onde EXATAMENTE in-memory entra (V207.5-V207.7)

O in-memory entra como cache de leitura e view model de ListBox, não como fonte primária de dados.

- `EMP_Lista`: hoje populada por `PreenchimentoEmpresa`, lendo `EMPRESAS` em duas passagens e atribuindo array. O cache deve carregar `EMPRESAS` uma vez por invalidação, manter índice por ID e CNPJ, e produzir o array filtrado.
- `C_Lista` e `C_ListaRodizio`: devem carregar `ENTIDADE` uma vez por invalidação, com índice por ID/CNPJ e filtro por ativa/inativa quando aplicável. O F-NEW3 entra aqui porque o cache deve preservar ID textual padronizado.
- `A_Lista` e `H_Lista`: ambas dependem de `CAD_SERV` e de `BuscarCnaeAtividade`. O cache deve pré-montar `cnaeAtual`, texto de busca e colunas visíveis para evitar recalcular em cada tecla/filtro.
- `CR_Lista` em `Credencia_Empresa`: deve compartilhar a visão cacheada de `CAD_SERV`, mas nunca manter referência ao form. O form recebe apenas array 2D.
- `OS_Lista` e `AV_Lista`: entram somente se a medição confirmar gargalo. Elas fazem joins repetidos com `ENTIDADE`, `EMPRESAS` e `CAD_SERV`; o cache pode fornecer índices para evitar loops aninhados.

Estratégia de carga:

- Carregar ranges inteiros em `Variant 2D` usando `Range.Value2`.
- Normalizar campos de busca uma vez por linha.
- Criar índices late-bound (`Scripting.Dictionary`) por ID/chave, com fallback para busca linear se o ambiente não suportar dicionário.
- Não carregar abas inteiras com colunas vazias; usar `UltimaLinhaAba` e faixa de colunas contratada.
- Ter limite de memória e fallback automático: se total de linhas ou erro de memória exceder limiar, desativar cache do domínio e voltar ao caminho V207.4.

Estratégia de dirty checking:

- Cada domínio guarda `ultimaLinha`, `ar1`, `rowHash` por linha e `cacheVersion`.
- Antes de usar cache após mutação ou foco de form, comparar versão esperada com versão atual. Divergência força rebuild total.
- Em edição/cadastro, o serviço retorna `DominiosInvalidar`. O cache não tenta corrigir item isolado como regra geral; reconstrói o domínio inteiro para manter idempotência.
- Para operações que realmente dependerem de linha carregada em memória, comparar `rowHash` atual da planilha antes do writeback. Se divergir, abortar com mensagem de conflito e reconstruir cache.

Rollback transacional em VBA:

- Rollback puramente em memória só vale enquanto o processo VBA está vivo. Portanto, ele não é suficiente para crash de Excel, queda de energia ou fechamento forçado.
- O contrato mínimo precisa de marcador persistente em workbook, por exemplo uma aba técnica oculta de transação ou registro auditável com `TX_PENDING`, domínio, linhas afetadas e snapshot das células antigas.
- Fluxo normal: `TX_PENDING` -> snapshot persistente -> writeback em bloco -> validação -> `TX_COMMITTED`/limpeza.
- Fluxo com erro vivo: restaurar snapshot, registrar `TX_ROLLED_BACK`, restaurar Application flags e proteção de abas.
- Fluxo com crash: na abertura seguinte, detectar `TX_PENDING` sem commit e orientar recuperação automática ou assistida antes de permitir novos cadastros.

### 2.3 Contratos UI <-> in-memory cache <-> planilha

- UI chama `Preencher*` ou adapter equivalente. UI não chama cache mutador e não escreve planilha.
- Cache lê planilha e devolve arrays/view models. Cache não é fonte de verdade.
- Serviços validam comandos, chamam repositórios e retornam resultado + domínios invalidados.
- Repositórios escrevem planilha em bloco, com wrapper de performance e proteção restaurada.
- Após commit, o serviço invalida cache; o próximo reload reconstrói do workbook.
- Se cache falhar, fallback é o caminho V207.4 sem cache. O usuário pode continuar operando.
- `Audit_Log` registra inicialização, invalidação, rebuild e fallback do cache, mas não registra cada leitura para evitar ruído.

### 2.4 Riscos identificados (especialmente: bagunça se contratos imaturos)

| Risco | Severidade | Mitigação |
|---|---:|---|
| Cache começar antes de `Svc_*`/`Repo_*` estabilizarem | Crítico | Fase-lock: V207.5 só abre após V207.4 com RVS + E2E_CADASTROS verde e aceite humano. |
| UI e cache virarem segunda fonte de verdade | Crítico | Cache read-only em V207.5; escrita via cache só com contrato transacional em V207.7. |
| Dados stale após cadastro | Alto | Invalidação por domínio retornada pelo serviço, rebuild total por domínio e teste E2E pós-cadastro. |
| Crash no meio de writeback | Alto | Marcador persistente `TX_PENDING` e snapshot antes de escrita. Sem isso, não permitir writeback originado de cache. |
| Memória limitada em Windows 7/8 | Médio/alto | Cache por domínio, limite de linhas, fallback automático e evitar objetos pesados por linha. |
| Dicionário late-bound indisponível | Médio | Fallback linear e teste em ambiente sem referência explícita. |
| ListBox receber array com base 0/1 incorreta | Médio | Helper único para shape de array por controle, testes de contagem/colunas. |
| Mudança manual direta na aba | Médio | Hash/version check e rebuild; operações críticas abortam se houver divergência. |

### 2.5 Dependências entre ondas

```text
V207.0 -> V207.1 -> V207.2 -> V207.3 -> V207.4
                                             |
                                             | gate humano: contratos maduros?
                                             v
                                          V207.5 -> V207.6 -> V207.7 -> V207.8
```

Dependências fortes:

- V207.5 depende de `E2E_CADASTROS` e de medição de F-NEW4. Sem métrica, o cache pode otimizar o ponto errado.
- V207.6 depende de serviços retornarem domínios invalidados. Se forms ainda mutarem planilha diretamente, a invalidação fica incompleta.
- V207.7 depende de `TX_PENDING` persistente. Sem recuperação pós-crash, transação em memória é uma promessa falsa.

### 2.6 Custo total estimado

- 45-70 homem-hora-IA para 7-9 ondas.
- 5-8 sessões Opus para arquitetura, readbacks e gates.
- 8-12 sessões Codex para execução/auditoria de código em ondas futuras.
- 7-9 gates humanos de importação/validação.
- Custo menor que a Alternativa I porque evita abrir V208 completa antes de saber se o cache parcial já resolveu a dor operacional.

## 3. Comparação técnica das 2 alternativas

| Critério | Alternativa I | Alternativa II |
|---|---|---|
| Tempo até F-NEW4 perceptual resolvido | Lento: melhora parcial em V207, resolução forte só em V208. | Rápido: V207.5-V207.7 atacam diretamente reload e filtros de ListBox. |
| Complexidade de testes | Alta em duas releases: E2E_CADASTROS em V207 e contratos ORM/transação em V208. | Alta, mas concentrada: E2E_CADASTROS + consistência de cache na mesma V207. |
| Complexidade de rollback | Menor em V207, maior em V208 quando ORM entra completo. | Média: exige flag de fallback e anchor V207.4 antes do cache. |
| Reuso de código entre I e II | Alto nas ondas V207.0-V207.4; V208 reaproveita serviços. | Alto até V207.4; cache parcial pode virar laboratório para V208, mas não substitui ORM completo. |
| Risco de bugs sutis durante implementação | Baixo/médio em V207, alto em V208. | Médio/alto em V207.5-V207.7 por cache stale e transação parcial. |
| Fadiga de operador | Alta: 12-17 ondas em 2 releases. | Moderada: 7-9 ondas em 1 release. |
| Preparação SaaS | Melhor no fim da V208. | Suficiente para curto prazo; SaaS completo ainda exigirá V208+ ou backend. |
| Preservação da planilha soberana | Forte. | Forte, desde que cache seja derivado da planilha e export/import permaneça gate. |

## 4. Edge cases não cobertos pela 1ª rodada

### Concorrência: operador rodando macro enquanto cadastra

Excel/VBA é majoritariamente single-thread no processo, mas eventos, botões duplos, timers, `DoEvents`, mudança de seleção e chamadas de form podem reentrar em momentos ruins. As duas alternativas precisam de um contrato de operação crítica:

- Flag global curta, por domínio, para bloquear duplo clique/cadastro simultâneo.
- Desabilitar botões mutadores enquanto serviço grava.
- Não usar `DoEvents` dentro de transação de escrita.
- Se outra macro tentar mutar domínio com `TX_PENDING` ou operação crítica ativa, abortar com mensagem controlada.

### Crash em meio à transação memória -> célula (Alternativa II)

O rollback em memória não sobrevive a crash. Portanto:

- V207.5 deve ser read-only.
- V207.6 pode ter dirty checking e invalidação, mas não writeback transacional complexo.
- V207.7 só pode escrever a partir de estado cacheado se houver snapshot persistente e marcador de recuperação.
- Sem recuperação persistente, a alternativa aceitável é abortar cache e usar repositório direto V207.4.

### Migração de workbooks antigos com dados parciais

Workbooks V204/V205 podem ter IDs sem formato textual, AR1 menor que dados reais, colunas inseridas manualmente ou abas inativas com IDs maiores que as ativas. Gates:

- Sanear AR1 pair-aware antes de qualquer cadastro.
- Reaplicar `NumberFormat = "@"` em coluna A de abas operacionais.
- Detectar cabeçalhos esperados e colunas críticas antes de cachear.
- Cache deve falhar fechado: se schema divergir, volta para caminho de planilha e orienta saneamento.

### Compatibilidade com PCs Windows 7/8 e memória limitada

- Evitar dependências externas e referências que não existam em Office antigo.
- Usar late binding para dicionários.
- Cache por domínio, não workbook inteiro.
- Limitar strings normalizadas e liberar arrays após uso.
- Medir memória/tempo com bases sintéticas de 1x, 5x e 10x o tamanho atual.
- Fallback automático para `Preencher` direto se `Out of memory` ocorrer.

### Usuário editando abas manualmente

- Dirty checking deve tratar edição manual como conflito ou invalidação.
- Se uma linha cacheada mudou fora da rota de serviço, abortar operação mutadora e reconstruir cache.
- Se a edição manual ocorrer em coluna não contratada para a lista, apenas invalidar domínio.

### Proteção de abas e restauração de estado Excel

- Todo writeback deve ter handler armado antes de alterar flags.
- Proteção de aba deve ser restaurada em sucesso, erro vivo e rollback.
- `Util_FinalizarBlocoRapido` deve ser tolerante a estado vazio, já restaurado ou parcialmente inválido.

### Multiple workbooks e `ActiveWorkbook`

- Cache, repos e serviços devem usar `ThisWorkbook`, nunca `ActiveWorkbook`.
- Se houver outro workbook aberto, os testes precisam confirmar que cadastros não escrevem no arquivo errado.

### `.frm/.frx` e importação

- Alterar forms no V207 aumenta risco de drift `.frx`. Sempre que tocar em `.frm`, o procedimento de importação precisa validar abertura do UserForm e compile.
- Não introduzir controles novos se a mesma função puder ser feita com código em módulos.

## 5. Alternativa III (se você propõe)

Não proponho uma terceira arquitetura substantiva para substituir I ou II. A única alternativa útil é uma variação operacional: **Alternativa III-G — Gate de Bifurcação Controlada**.

Ela executa V207.0-V207.4 exatamente como as duas alternativas e só decide entre I e II após métrica real:

- Se V207.4 resolver F-NEW4 dentro do limiar humano, congela V207 e abre V208 planejada depois: vira Alternativa I.
- Se V207.4 ainda deixar reload perceptualmente lento, abre V207.5-V207.7 com cache parcial: vira Alternativa II.
- Se V207.4 revelar que o gargalo está fora das listas, não implementa cache e redireciona para o ponto medido.

Vantagem: reduz aposta antecipada em cache.

Desvantagem: posterga a decisão e pode alongar a coordenação HBN. Como Mauricio já sabe que o bottleneck perceptual está no reload de listas grandes, minha recomendação prática permanece escolher a Alternativa II com fase-lock, não manter a decisão em aberto.
