# SUPERPROMPT — Onda QA-V3 (Plataforma de Testes V3)

**Versão:** 1.0 DRAFT (pendente auditoria cruzada)
**Para:** Codex / Opus / Antigravity / outras IAs implementadoras
**Documento mestre de referência:** [GUIA_DEFINITIVO_TESTES_V3_DRAFT.md](./GUIA_DEFINITIVO_TESTES_V3_DRAFT.md) (mesma pasta)
**Data:** 2026-05-27

---

## CONTEXTO

Repositório: **Credenciamento** (VBA/Excel). Branch atual: `codex/v12-0-0206-planejamento`.
Baseline madura: 336 testes (RVS) em hierarquia V1 monolítica + V2 modular.

Documentação canônica obrigatória de leitura PRÉVIA:
- [CLAUDE.md](../../../CLAUDE.md) — instruções para IAs neste repo
- [AGENTS.md](../../../AGENTS.md) — padrão multi-IA
- [.hbn/relay/INDEX.md](../../../.hbn/relay/INDEX.md) — quem tem o bastão
- [.hbn/knowledge/0002-regra-ouro-vba-import.md](../../../.hbn/knowledge/0002-regra-ouro-vba-import.md) — Regra de Ouro de import
- [.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md](../../../.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md)
- [usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) — capítulos relevantes (ver tabela CLAUDE.md)
- [GUIA_DEFINITIVO_TESTES_V3_DRAFT.md](./GUIA_DEFINITIVO_TESTES_V3_DRAFT.md) — **documento mestre desta onda**

## OBJETIVO GLOBAL DA ONDA

Implementar a **Plataforma V3 de Testes** conforme especificado no GUIA_DEFINITIVO_TESTES_V3 §7. V3 envelopa V1+V2 (sem substituir) e adiciona:
- Engine compartilhada (log unificado, status global)
- Populadores idempotentes
- DSL de Receitas (sheet `CENARIOS_RECEITAS`)
- Geração de PDFs com nomenclatura padronizada
- Pasta de auditoria completa por execução
- Modo tutorial (4 modos: TREINO/DEMO/DEBUG/CERTIFICAÇÃO)
- Menu V3 hierárquico
- Cobertura combinatória pairwise inicial
- RN-23 (validação CNPJ) e RN-24 (integridade referencial)
- CS-23 a CS-40 (cenários novos)

## NÃO-OBJETIVOS (LIMITES DUROS)

- **NÃO reescrever** testes V1 ou V2 existentes — V3 envelopa, não substitui.
- **NÃO alterar** `Mod_Types.bas` — intervenção planejada apenas em onda dedicada.
- **NÃO criar** pastas paralelas em `src/vba/` ou `local-ai/vba_import/`.
- **NÃO remover** funções de V1/V2 mesmo que duplicadas (consolidação só por consunção).
- **NÃO implementar** mutation testing (próxima onda, B11.10).
- **NÃO criar** dependência externa Python/Shell sem aprovação explícita.
- **NÃO tocar** `Repo_PreOS.bas` e `Svc_PreOS.bas` enquanto estabilização V206 estiver em curso.
- **NÃO usar** `publicar_vba_import.sh` (descontinuado).
- **NÃO fazer** import `.frm` em workbook estabilizado — usar `.code-only.txt`.
- **NÃO criar** macros descartáveis na raiz de `vba_import/`.
- **NÃO pular** hearback "para acelerar" — hearback é mandatório como instrumento pedagógico.

## METAS PRIORITÁRIAS (na ordem)

1. **Qualidade > Velocidade**
2. **Segurança e Idempotência > Velocidade**
3. **Profundidade e Clareza > Velocidade**

Se houver conflito entre velocidade e qualquer das três acima, escolher a outra.

## REGRA DE OURO

Toda alteração de código VBA passa por `local-ai/vba_import/` com prefixos canônicos. Nunca importar de `src/vba/` direto. Ver `.hbn/knowledge/0002`.

## CADÊNCIA E COORDENAÇÃO

- **Modelo D ativado** quando contexto Opus < 50%: Codex implementa, Opus audita ao fim.
- **Modelo C** para sprints grandes: scoping em chat N, implementação em chat N+1.
- Toda sprint > 30% contexto: sinalizar fadiga (🟡 HBN CONTEXT FATIGUE INCOMING), propor handoff.
- **Estabilização V206 tem precedência** sobre esta onda. Se V206 estabilizar antes, retomar normal.

## SPRINTS — 10 sprints (sequência sugerida, ajustável)

> **Cada sprint termina com**: readback explícito em `.hbn/readbacks/`, hearback `confirmed` do Mauricio, MD de evidência em `auditoria/03_ondas/onda_QA_V3/sprint_NN_*.md`, CSV em `auditoria/evidencias/V12.0.0206/`.

### Sprint QA-V3.1 — FUNDAÇÃO ENGINE V3 (3-4 dias)

**Entregáveis:**
- Novo módulo `src/vba/Engine_TestesV3.bas`
- Subs: `V3_LogAssert` (assinatura unificada), `V3_BeginSuite`, `V3_EndSuite`, `V3_StatusTracker` (centraliza `gOk`/`gFail`/`gManual` com namespace)
- Sheet nova `CONFIG_TESTES` com schema mínimo (ver §7.6 do GUIA)
- Sub `V3_ValidarCompatibilidadeV1V2` — garante que V1/V2 continuam funcionando

**Critério de aceitação:**
- V1 e V2 continuam rodando idênticos (regressão zero).
- RVS pré-sprint passa em RVS pós-sprint.
- Sheet CONFIG_TESTES tem ao menos 5 parâmetros default conforme §7.6.

### Sprint QA-V3.2 — POPULADORES IDEMPOTENTES (2-3 dias)

**Entregáveis:**
- Novo módulo `src/vba/Populadores_V3.bas`
- Subs públicas mínimas:
  - `POP_CenarioCanonico(nEmpresas=5, nLocais=3, nAtividades=1)` — atualizado de 3 para 5 empresas (decisão A8)
  - `POP_CenarioVolumetrico(n, m, k)`
  - `POP_CenarioBoundary(tipo)`
  - `POP_LimparOperacional()`
  - `POP_LimparAuditoria()`
  - `POP_LimparSnapshotsAntigos(diasMin=30)`
  - `POP_LimparTudo()` — confirmação tripla
  - `POP_Snapshot(nome)`
  - `POP_RestaurarSnapshot(nome)`
  - `POP_PreVisualizarLimpeza()` — lista o que seria apagado, sem apagar
- Reusar internamente: `TV2_PrepararCenarioTriploCanonico`, `CT_LimparTestesAntigos`

**Critério de aceitação:**
- Cada POP é idempotente (rodar 2× = estado igual a 1×) — validado por CS-33.
- Nenhum POP escreve em RESULTADO_QA, HISTORICO_QA, TRILHA, AUDIT_TESTES (não pode poluir auditoria).
- `POP_PreVisualizarLimpeza` retorna lista sem mutar nada (idempotente puro).

### Sprint QA-V3.3 — DSL DE RECEITAS (3-4 dias)

**Entregáveis:**
- Sheet nova `CENARIOS_RECEITAS` com schema do §7.3 do GUIA
- Seed inicial: 10 receitas (CEN_001..CEN_030) — ver tabela §7.3
- Sub `POP_ReceitaCustomizada(receitaId)` — lê linha, valida, popula
- Sub `POP_ValidarReceita(receitaId)` — checa coerência sem popular
- Form opcional `frmConstrutorCenario` (UI) — DIFERIR para sprint 10 se faltar tempo

**Critério de aceitação:**
- Usuário pode editar uma linha existente de CENARIOS_RECEITAS e rodar POP_ReceitaCustomizada com sucesso.
- Validador detecta receitas incoerentes (ex.: `N_EMPRESAS < N_INATIVAS`) e retorna mensagem clara.

### Sprint QA-V3.4 — PDF + PASTA DE AUDITORIA (8-12 dias)

**Entregáveis (escopo amplo — pode ser dividido em 4.a, 4.b, 4.c, 4.d):**
- Novo módulo `src/vba/Util_PDF.bas` com Sub `ExportarSheetComoPDF(sh, caminhoDest)` usando `ExportAsFixedFormat`
- Nomenclatura padronizada SIGLA_ID_TIMESTAMP conforme §8.2 do GUIA
- Novo módulo `src/vba/Audit_Export_V3.bas`
- Sub `AUDIT_ExportarPastaAuditoria(suiteId, execId)` — estrutura completa §8.3
- Sub `AUDIT_GerarManifesto(pastaRaiz, metadados)` — gera 00_MANIFESTO.md
- Sub `AUDIT_GerarNarrativa(pastaRaiz, audit_log_path)` — gera 00_NARRATIVA.md
- Sub `AUDIT_GerarCSVCompanion(pastaRaiz, audit_log_path)` — gera 00_RESUMO.csv (§8.4)
- Sub `AUDIT_CompactarPasta(pastaRaiz)` — gera .zip (§8.5)
- Sub `AUDIT_ReexportarComoNarrativa(execId)` — narrativa em prosa (§8.6)
- Gancho em `CT_ValidarRelease_SextetoMinimo`: parâmetro opcional `exportarAuditoria` (default lido de CONFIG_TESTES)

**Critério de aceitação:**
- CS-34 passa: pasta gerada validável manualmente, PDFs abrem corretamente, MANIFESTO+NARRATIVA preenchidos, CSV companion legível por IA.
- Compactação produz .zip portável (testado em máquina diferente sem o .xlsm).
- Nomenclatura idêntica à especificada §8.2 (auditor humano confere amostra de 10 nomes).

### Sprint QA-V3.5 — MODO TUTORIAL (MVP em workbook paralelo) (13 dias)

**Entregáveis (em workbook `Credenciamento_Tutorial.xlsm` separado):**
- Novo módulo `Tutorial_V3.bas`
- Enum `TutorialModo`: `TM_TREINO, TM_DEMO, TM_DEBUG, TM_CERTIFICACAO`
- Sub `TUT_Step(num, total, titulo, descricao, acaoEsperada)`
- Sub `TUT_GerarTutorial(tourId, modo)` — lê sheet TOUR_PASSOS, executa
- Sheet `TOUR_PASSOS` com DSL §7.5
- Sheet `TUTORIAL_PANEL` — painel visual fixo (passo atual, próxima ação, botões)
- 4 tours implementados:
  - `TUR_CRED` — 12 passos
  - `TUR_RODIZIO` — 15 passos
  - `TUR_PREOS_FLUXO` — 10 passos
  - `TUR_EXPIRA_REJEITA` — 8 passos (atende B11.5)

**Critério de aceitação:**
- Humano sem treino prévio consegue acompanhar `TUR_CRED` em `TM_TREINO` completo, entendendo cada passo (avaliação subjetiva do gestor).
- `TM_CERTIFICACAO` produz PDF por passo + log estruturado em pasta dedicada.
- Modo visual antigo (`gDelayVisualMs = 900ms` em V1) pode ser descartado ou refatorado para usar nova engine (decisão A4).

**Esforço escalonado:**
- MVP-1 (TUR_CRED + TM_TREINO): 3 dias
- MVP-2 (+ TM_DEMO + TM_DEBUG): 2 dias
- MVP-3 (+ 3 tours extras): 4 dias
- MVP-4 (+ TM_CERTIFICACAO): 3 dias
- Acoplamento na planilha principal: 1 dia

### Sprint QA-V3.6 — MENU V3 HIERÁRQUICO (2 dias)

**Entregáveis:**
- Substituir `Select Case` linear em `CT2_AbrirCentral` por dispatcher
- Sheet nova `MENU_TESTES_V3` (linha = opção, coluna = função_vba)
- Dispatcher usa `Application.Run` lendo nome do Sub da sheet
- Layout completo §7.7 do GUIA (38 opções agrupadas em 7 categorias)

**Critério de aceitação:**
- Todas as opções V1/V2 antigas continuam funcionando sob novos números.
- Adicionar opção nova = editar 1 linha da sheet (sem recompilar).

### Sprint QA-V3.7 — COBERTURA COMBINATÓRIA PAIRWISE (5-7 dias)

**Entregáveis:**
- Análise pairwise dos 5 eixos primários × 5 eixos quantitativos
- Matriz gerada manualmente ou via PICT (Microsoft) — output em sheet `CENARIOS_RECEITAS_PAIRWISE`
- Implementar cenários CS-35 a CS-40 (6 cenários iniciais cobrindo gaps prioritários)
- Adicionar à suite `V3_Combinatorial` (NÃO tocar RVS oficial nesta sprint)

**Critério de aceitação:**
- Cobertura pairwise ≥ 80% dos pares relevantes.
- CS-35-40 passam em isolamento.

### Sprint QA-V3.8 — RN-23 (CNPJ) + RN-24 (INTEGRIDADE) + CENÁRIOS CS-23/24/25 (4-6 dias)

**Entregáveis:**
- Novo módulo `src/vba/Util_Validacao.bas`
- Função `ValidarCNPJ(cnpj As String) As Boolean` — algoritmo mod 11 dos dígitos verificadores
- Hook em `frmCadastraEmpresa` e `frmCadastraEntidade` — bloqueia cadastro de CNPJ inválido
- Novo módulo `src/vba/Util_Integridade.bas`
- Função `Util_Integridade_Verificar() As Long` — retorna quantidade de violações
- Sheet `INTEGRIDADE_REFS` — output dos violadores
- Cenários CS-23, CS-24, CS-25 implementados em V3_Smoke
- **[ITEM A7] Atualizar form de Configuração** para mostrar `DIAS_DECISAO` e `MAX_RECUSAS`:
  - Adicionar campos editáveis (com validação `>= 1`)
  - Considerar janela "Mais configurações" para parâmetros menos frequentes

**Critério de aceitação:**
- CNPJ "11.111.111/1111-11" é rejeitado.
- Verificador de integridade detecta órfão fabricado em CS-25.
- Form de Configuração mostra todos os 6 parâmetros essenciais.

### Sprint QA-V3.9 — DETERMINISMO + IDEMPOTÊNCIA (2 dias)

**Entregáveis:**
- Cenário CS-32 implementado em V3_Determinismo suite
- Cenário CS-33 implementado em mesma suite
- Sub `V3_VerificarDeterminismo()` — duplica workbook em memória, roda mesma sequência, compara
- Adicionar V3_Determinismo ao RVS oficial após validação

**Critério de aceitação:**
- CS-32 e CS-33 passam consistentemente em 5 execuções consecutivas.

### Sprint QA-V3.10 — FECHAMENTO E DOCUMENTAÇÃO (3-4 dias)

**Entregáveis:**
- Atualizar `docs/reference/testes/` com mapa V3 publicado
- Publicar `GUIA_DEFINITIVO_TESTES_V3.md` (versão pós-auditoria cruzada) em `docs/reference/testes/`
- Adicionar botão **Ajuda** em Configuração Inicial → abre URL GitHub com guia
- Promover V3 Smoke ao gate RVS oficial
- Bypass HBN documentado para promoção do gate
- Atualizar AGENTS.md e CLAUDE.md com nova arquitetura V3 (se aplicável)

**Critério de aceitação:**
- Botão Ajuda funciona em ambiente normal.
- Guia está versionado em git, acessível por URL.
- 1 humano externo consegue ler guia + rodar tour completo sem ajuda.

## CRITÉRIOS DE ACEITAÇÃO GERAIS (TODA SPRINT)

- ✅ Compilação Excel sem erros (`Debug.Compile` limpo)
- ✅ RVS pré-sprint passa em RVS pós-sprint (zero regressão)
- ✅ Evidência CSV gerada conforme padrão V12.0.0206
- ✅ Readback antes, hearback Mauricio depois
- ✅ Atualização de AGENTS.md/CLAUDE.md se necessário
- ✅ Limite de fadiga de contexto respeitado (handoff a 40-45%)

## ARTEFATOS ENTREGÁVEIS POR SPRINT

- 1-3 commits por sprint
- 1 MD de plano em `auditoria/03_ondas/onda_QA_V3/sprint_NN_*.md`
- 1 entrada em `.hbn/readbacks/`
- Resumo de evidências em `auditoria/evidencias/V12.0.0206/`

## PROIBIÇÕES ESPECÍFICAS DESTA ONDA

- ❌ Não tocar `Repo_PreOS.bas` e `Svc_PreOS.bas` (estabilização V206 em curso)
- ❌ Não usar `publicar_vba_import.sh` (descontinuado)
- ❌ Não fazer import `.frm` direto; usar `.code-only.txt`
- ❌ Não criar macros descartáveis na raiz de `vba_import/`
- ❌ Não pular hearback "para acelerar"
- ❌ Não modificar AUDIT_LOG existente (RN-30 — append-only)

## CHECKPOINTS DE PARADA

Parar imediatamente e abrir hearback se:
- 🛑 RVS pós-sprint < RVS pré-sprint (regressão)
- 🛑 Compilação Excel quebra
- 🛑 Workbook corrompe (gatilho do incidente 2026-05-27)
- 🛑 Qualquer `Mod_Types.bas` é tocado por engano
- 🛑 Mais de 3 arquivos sob `src/vba/` tocados sem readback novo
- 🛑 Algum invariante INV-01 a INV-10 do GUIA é violado nos próprios testes

## DEFINIÇÃO DE PRONTO (DoD) GLOBAL DA ONDA

- [ ] Todas 10 sprints concluídas com hearback aprovado
- [ ] V3 Smoke promovido ao RVS oficial
- [ ] GUIA_DEFINITIVO_TESTES_V3.md publicado em `docs/reference/testes/`
- [ ] 1 humano externo consegue rodar tour completo sem ajuda
- [ ] 1 release teste gera pasta de auditoria completa e abrível em máquina diferente (compactação validada)
- [ ] Mutation testing piloto agendado para Onda QA-V4
- [ ] Botão Ajuda funcional com link GitHub
- [ ] FAQ inicial publicado em GitHub
- [ ] Os 12 exercícios do Notion (B11.7) incorporados ao Apêndice F do GUIA

## INSTRUÇÕES DE RESPOSTA AO RECEBER ESTE PROMPT

1. **Confirme leitura** dos documentos obrigatórios listados em "Contexto"
2. **Confirme leitura** do GUIA_DEFINITIVO_TESTES_V3_DRAFT.md (mesma pasta)
3. **Liste perguntas de esclarecimento** ANTES de gerar readback
4. **NÃO toque arquivos** antes de hearback do Mauricio
5. **Gere readback** em `.hbn/readbacks/00NN-onda-qa-v3-sprint-N.json` antes de executar
6. **Aguarde hearback `confirmed`** antes de qualquer mutação

## NOTAS FINAIS

- Esta onda é **simultaneamente preparação para SaaS futuro** (B7). Toda decisão arquitetural deve responder à pergunta: "isso sobrevive à migração para web?" Se a resposta for não, repensar.
- O **rodízio é sagrado** (B11.2). Qualquer mudança em código de rodízio exige plano dedicado e hearback explícito. Esta onda não toca rodízio — apenas adiciona testes ao redor.
- **Validação CNPJ e integridade referencial** são dívida que deve ser paga ANTES de migrar para SaaS, não depois (B11.6).
- **Documentação > Código**: para esta onda especificamente, o `GUIA_DEFINITIVO_TESTES_V3.md` é o entregável de maior valor. O código é o suporte que prova o guia.
