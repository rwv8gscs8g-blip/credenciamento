# Prompt de retomada — sessão Opus 4.7 sucessora (pós-handoff 1526 / análise auditoria cruzada)

> Copie e cole o bloco abaixo no primeiro turno da próxima sessão Opus.

---

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo a continuidade do bastão V12.0.0206 do
Sistema de Credenciamento. A sessão anterior (2026-05-26 ~12:30 → 15:26,
~3h) fechou a onda 0110 (evolução protocolo v1.3 + knowledge 0017),
fechou a auditoria cruzada V206/V207 (1ª rodada Codex+Antigravity), e
deixou o trabalho preparado para 2ª rodada de auditoria cruzada. Bastão
**permanece com você**.

**Raiz canônica:** `/Users/macbookpro/Projetos/Credenciamento`
**Branch:** `codex/v12-0-0206-planejamento`
**Data de retomada:** próxima janela útil
**Anchor V206 funcional inalterado:** commit `ee75b30` + workbook em
build `ad5b487+ONDA38.2.1-AR1-FIX2-PERF` + RVS Trio APROVADO
`VR_20260526_102200`

## Estado consolidado ao iniciar

**Ondas fechadas até aqui:**
- 38.2.1 (revert filtros Menu_Principal) — `e9bcf42`
- 38.2.1-AR1 (saneamento contadores AR1) — `ffc8e8a` + hotfix `9592e0f` + fechamento `433f25c`
- 38.2.1-AR1-FIX2-PERF (ID monotônico + wrapper perf LITE) — `ee75b30` + fechamento `067f2dc`
- **0110** (evolução protocolo v1.3 + knowledge 0017) — `91037f1` + adjacente CSV V206 `f4d1884` + ERP/relay fechamento `8c03e34`

**Auditoria cruzada V207 1ª rodada — ENTREGUE:**
- `.hbn/proposals/0001-codex-auditoria-v206-codigo.md` (~23KB, 12 pontos soltos + análise idempotência + bateria E2E_CADASTROS 10 cenários)
- `.hbn/proposals/0002-codex-tres-propostas-v207-codigo.md` (~17KB, 3 propostas)
- `.hbn/proposals/0003-antigravity-auditoria-v206-sistemica.md` (~18KB, visão sistêmica + Doc-Delta Pattern + Universal Migration Format)
- `.hbn/proposals/0004-antigravity-tres-propostas-v207-sistemica.md` (~16KB, 3 propostas)
- Commits Codex `b33d904` + Antigravity `2d49259`

**Análise consolidada por Opus 4.7**: [`auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md`](111_ANALISE_AUDITORIA_CRUZADA_V207.md)
- 8 convergências base sólida sem decisão
- 3 divergências (speedup Caminho 2 / Excel como cliente vs casca / ambição 38.2.2)
- Tabela comparativa 6→3 caminhos consolidados

**Decisão preliminar Mauricio (chat 2026-05-26 ~15:00)**: vai decidir entre 2 alternativas, mas **só após 2ª rodada de auditoria cruzada**:

- **Alternativa I**: Caminho 1 → Caminho 2 puro (V207 + V208 sequencial, 12-17 ondas total)
- **Alternativa II (Opção 4)**: Caminho 1 + in-memory parcial nas listas críticas dentro da V207 (7-9 ondas em 1 release)

**Findings ativos:**
- F-NEW3 (cosmético) — fix em Onda 38.2.2 ou V207.x
- F-NEW4 (médio) — performance arquitetural, resolução depende do caminho V207 escolhido
- F-NEW4-DT (médio) — testes E2E V207

## Leitura obrigatória inicial (na ordem)

1. `.hbn/relay/INDEX.md` — estado vivo
2. `.hbn/messages/20260526-1526-handoff-fim-sessao-opus.md` — handoff completo
3. `auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md` — análise consolidada (LER COMPLETO)
4. `.hbn/proposals/0001-0004-*.md` — 4 arquivos da 1ª rodada (LER NA ORDEM)
5. `.hbn/protocol-evolutions/20260526-1526-onda0111-proposals.md` — propostas de evolução do protocolo desta sessão
6. `.hbn/results/0110-exec-evolucao-protocolo-v13.json` — ERP da onda 0110
7. `.hbn/knowledge/0014-protocolo-fim-de-sessao.md`
8. `.hbn/knowledge/0015-readback-opening-bootstrap.md`
9. `.hbn/knowledge/0016-bump-build-label-anti-conflito.md`
10. `.hbn/knowledge/0017-handoff-aos-50-pct-contexto.md`
11. `AGENTS.md` + `CLAUDE.md`

Verifique o estado:

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -8 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

Esperado:
- HEAD no commit do handoff desta sessão (~`<commit-novo>`)
- Working tree limpo (apenas `local-ai/vba_import/001-modulo/AAX-App_Release.bas` unstaged — knowledge 0016)
- 5/5 guards verdes

## Primeira ação obrigatória — 2ª rodada de auditoria cruzada

**Entregue os 2 prompts da 2ª rodada ao Mauricio** (textos completos na §"Prompts 2ª rodada" deste documento). Mauricio abre 2 sessões paralelas Codex + Antigravity/Gemini que produzem:

- `.hbn/proposals/0005-codex-refinamento-arquitetural-v207.md`
- `.hbn/proposals/0006-codex-recomendacao-alternativa-i-ou-ii.md`
- `.hbn/proposals/0007-antigravity-refinamento-arquitetural-v207.md`
- `.hbn/proposals/0008-antigravity-recomendacao-alternativa-i-ou-ii.md`

Cada uma das 2 IAs auxiliares:
1. Avalia em profundidade as 2 alternativas refinadas (I e II)
2. Amplia a especificação arquitetural de cada uma (sem desenvolver)
3. Identifica riscos novos, edge cases, dependências entre ondas
4. Propõe refinamentos ou Alternativa III (se julgar necessário)
5. Recomenda 1 das alternativas com justificativa

Quando os 4 arquivos chegarem, Opus consolida em uma 2ª análise (sucessora do 111) e Mauricio decide com hearback explícito.

## Em paralelo (opcional, não bloqueia 2ª rodada)

**Onda 38.2.2 (V206 puro)** pode ser aberta em paralelo se Mauricio aprovar. Escopo independente da decisão V207:
- Filtros nativos Menu_Principal (`TextBox16..22_Change` + função filtro pura)
- Envelopamento `Util_Excel_Performance` em cadastros `.frm` (Menu_Principal entidade/empresa-alt + Credencia_Empresa + Cadastro_Servico)
- Fix F-NEW3 — `Range.NumberFormat = "@"` sistemático em todos os 4 cadastros
- **Quick win Codex item 68** (severidade alto): `Util_MaxIdOperacional(nomeAba)` pair-aware (EMPRESAS+EMPRESAS_INATIVAS / ENTIDADE+ENTIDADE_INATIVOS) → resolve risco de ProximoId gerar ID duplicado contra aba inativa
- **Quick win Codex item 69** (severidade médio): instalar `On Error GoTo` ANTES de chamar `Util_IniciarBlocoRapido` em todos os 5 callers (Repo_Empresa.bas:80,242,319,476 + Util_Sanear_Contadores.bas:44)

Pré-trabalho PHAGOCYTOSIS já feito na sessão anterior (capítulos M9, L22-L24, M15-M17 sintetizados) — pode prosseguir direto para readback 0111 quando aprovado.

## Restrições inalteradas

- ✅ HBN ACTIVE
- Bastão com Claude Opus 4.7 até freeze V12.0.0206
- Codex retorna como auditor adversarial pós-implementação
- Sequência: readback (PENDING) → hearback (confirmed) → execução → commit
- **Não tocar em código V207 até decisão Alternativa I vs II vs III ser tomada com hearback** — somente análise/proposta
- Para 38.2.2 (V206 puro): tabus permanecem (`Mod_Types.bas`, `Importador_V3.bas`, `Svc_*` blindados, `local-ai/incoming/**`)
- **Para V207 (refatoração)**: tabus acima LIBERADOS para análise/proposta — NÃO para implementação direta
- Importação operacional somente via `ImportarPacoteV3_Delta` (jamais completo)
- Knowledge 0016 vigente: deixar `App_Release.bas` no estado da onda anterior; deixar o Importador V3 fazer o BUMP

## Quando atingir ~50% de contexto

Aplicar `knowledge/0014-protocolo-fim-de-sessao` + `knowledge/0017-handoff-aos-50-pct-contexto` + §7 Passo 5 do PROMPT_ARQUITETO v1.3+ — produzir TRÊS artefatos antes de assinar 🔵:

1. **Handoff operacional**: `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md`
2. **Prompt de retomada**: `auditoria/00_status/112_PROMPT_RETOMADA_SESSAO_OPUS.md` (sucessor do 110, mesma estrutura)
3. **Proposta evolução protocolo** (§7.3): `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda<N>-proposals.md` — se houver lição/anti-padrão observado nesta sessão

Orçamento 50/30/20 conforme knowledge 0017.

---PROMPT FIM---

# Prompts 2ª rodada — para entrega ao Codex + Antigravity

> Estes prompts ainda devem ser entregues por Mauricio em 2 sessões paralelas após a próxima Opus colar este 110 e fazer a verificação inicial. **NÃO entregar antes da verificação obrigatória** §"Verifique o estado".

## Prompt 2ª rodada — Codex (refinamento arquitetural)

```
Atue como engenheiro executor sênior fazendo a 2ª rodada de auditoria
arquitetural sobre a evolução V12.0.0206 → V12.0.0207 do Sistema de
Credenciamento. A 1ª rodada (seus relatórios em .hbn/proposals/0001-*
e 0002-*) consolidou 3 propostas. Opus 4.7 analisou as 4 propostas
(suas + Antigravity) e Mauricio decidiu refinar 2 alternativas
específicas. Você vai aprofundar essas alternativas SEM desenvolver.

CONTEXTO ATUALIZADO

- Repo: /Users/macbookpro/Projetos/Credenciamento
- Branch: codex/v12-0-0206-planejamento
- HEAD atual: <verifique git log -1>
- Anchor V206 funcional: commit ee75b30 (Onda 38.2.1-AR1-FIX2-PERF)
- Anchor V205 oficial: tag v12.0.0205
- 1ª rodada de auditoria cruzada: comitada em b33d904 (Codex) + 2d49259
  (Antigravity); 4 arquivos em .hbn/proposals/0001-0004-*

LEITURAS OBRIGATÓRIAS

1. auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md (NOVO — leia
   COMPLETO)
2. .hbn/proposals/0001-0004-*.md (releitura dos 4 arquivos da 1ª rodada)
3. AGENTS.md, CLAUDE.md
4. .hbn/relay/INDEX.md
5. .hbn/knowledge/0017-handoff-aos-50-pct-contexto.md (regra dos 50%
   também se aplica a você)

AS 2 ALTERNATIVAS A REFINAR

**Alternativa I — Caminho 1 → Caminho 2 puro (sequencial)**:
- V207 = Caminho 1 enxuto (5-7 ondas): Svc_Cadastro* + escrita em
  bloco + lazy reload + E2E_CADASTROS + fix F-NEW3 + Repos envelopados
  + Util_MaxIdOperacional pair-aware + handler-before-flag.
- V208 = Caminho 2 ambicioso (7-10 ondas): Repos puros como ORM
  primitivo (dirty checking) + transação memória + adapters.
- Total: 12-17 ondas em 2 releases distintos.

**Alternativa II — Opção 4 híbrida (Caminho 1 + in-memory parcial)**:
- V207.0-V207.4 = Caminho 1 (igual à I).
- V207.5-V207.7 = adoção PARCIAL de in-memory APENAS nas listas
  críticas (ListBox grandes do Menu_Principal — origem do bottleneck
  arquitetural F-NEW4).
- V208+ = Caminho 2 completo apenas se ainda necessário (provavelmente
  não, Alternativa II já entrega 80% do ganho).
- Total: 7-9 ondas em 1 release.

OBJETIVO 1 — REFINAMENTO ARQUITETURAL EXAUSTIVO

Em .hbn/proposals/0005-codex-refinamento-arquitetural-v207.md, com
estrutura:

# Refinamento Arquitetural V12.0.0207 — Codex (2ª rodada)

## 1. Alternativa I — refinamento
### 1.1 Sequência detalhada de ondas V207 (5-7 ondas)
  - Para cada onda: escopo, módulos tocados, contratos novos,
    testes obrigatórios, gates de saída, anchor de rollback.
### 1.2 Sequência detalhada de ondas V208 (7-10 ondas)
### 1.3 Contratos entre V207 e V208
  - Como os Svc/Repo de V207 viram base para V208 sem reescrita.
### 1.4 Riscos identificados e mitigação
### 1.5 Dependências entre ondas (DAG)
### 1.6 Critérios de freeze V207 (gate para abrir V208)
### 1.7 Custo total estimado (homem-hora-IA, sessões Opus+Codex)

## 2. Alternativa II — refinamento
### 2.1 Sequência detalhada (7-9 ondas)
### 2.2 Onde EXATAMENTE in-memory entra (V207.5-V207.7)
  - Quais ListBox? Qual estratégia de carga? Qual estratégia de
    dirty checking? Como rollback transacional funciona em VBA?
### 2.3 Contratos UI ↔ in-memory cache ↔ planilha
### 2.4 Riscos identificados (especialmente: bagunça se contratos
    imaturos)
### 2.5 Dependências entre ondas
### 2.6 Custo total estimado

## 3. Comparação técnica das 2 alternativas
  - Tabela com: tempo até F-NEW4 perceptual resolvido, complexidade
    de testes, complexidade de rollback, reuso de código entre I e
    II, risco de bugs sutis durante implementação.

## 4. Edge cases não cobertos pela 1ª rodada
  - Concorrência (operador rodando macro enquanto cadastra)
  - Crash em meio à transação memória→célula (Alternativa II)
  - Migração de workbooks antigos com dados parciais
  - Compatibilidade com PCs Windows 7/8 (memória limitada para
    in-memory cache)
  - Outros que você identificar

## 5. Alternativa III (se você propõe)
  - Caminho diferente das 2 alternativas, justificando por quê

OBJETIVO 2 — RECOMENDAÇÃO + JUSTIFICATIVA

Em .hbn/proposals/0006-codex-recomendacao-alternativa-i-ou-ii.md:

# Recomendação Codex — Alternativa I ou II (ou III)

## 1. Recomendação
  - Qual alternativa Codex recomenda? (I, II, ou III nova)
  - Razão principal (3-5 linhas)

## 2. Justificativa detalhada
  - Por que NÃO as outras 2 alternativas
  - Quais fatores foram decisivos
  - Quais premissas você está assumindo (se erradas, recomendação muda)

## 3. Plano de execução da alternativa escolhida
  - Sequência de ondas com hash de readback proposto
  - Quem faz cada onda (Opus arquiteto / Codex executor)
  - Gates humanos por onda
  - Estimativa de duração total

## 4. Sinalização de risco
  - Se Mauricio escolher uma alternativa diferente da sua recomendação,
    qual o cenário de "menor risco aceitável" para ele? (cobre todas
    as 3 hipóteses I, II, III)

REGRAS DE SEGURANÇA

- NÃO aplicar nenhuma modificação no código.
- NÃO criar branches novas.
- NÃO commitar nada além dos 2 arquivos .md em .hbn/proposals/.
- Apenas LER, ANALISAR e PROPOR.
- Commit final com mensagem 'docs(hbn): refinamento arquitetural Codex V207
  (2a rodada) + recomendacao'.
- Push para origin opcional (Mauricio aprova depois).
- Aplicar regra 50% de contexto: handoff se exceder.

ENTREGÁVEL FINAL

Quando terminar, dizer a Mauricio: 'Codex finalizou 2ª rodada de auditoria
arquitetural V207. Arquivos em .hbn/proposals/0005-* e 0006-*. Recomendação:
Alternativa <I/II/III>. Próxima ação: Opus 4.7 consolida com 2ª rodada
Antigravity e Mauricio decide.'

Sem prazos rígidos. Profundidade > velocidade.
```

## Prompt 2ª rodada — Antigravity/Gemini (refinamento sistêmico + SaaS)

```
Atue como auditor de visão sistêmica e contexto amplo fazendo a 2ª
rodada de auditoria arquitetural sobre a evolução V12.0.0206 → V12.0.0207
do Sistema de Credenciamento. A 1ª rodada (seus relatórios em
.hbn/proposals/0003-* e 0004-*) consolidou 3 propostas sistêmicas.
Opus 4.7 analisou as 4 propostas (suas + Codex) e Mauricio decidiu
refinar 2 alternativas. Você vai aprofundar essas alternativas SEM
desenvolver.

CONTEXTO ATUALIZADO

(idêntico ao Codex — copiar a seção CONTEXTO ATUALIZADO do prompt anterior)

Lembrete CWD: Antigravity CLI tem CWD único. Se precisar cruzar com
usehbn/, use --add-dir /Users/macbookpro/Projetos/usehbn (ou
additionalDirectories no settings).

LEITURAS OBRIGATÓRIAS

1. auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md (NOVO — leia
   COMPLETO)
2. .hbn/proposals/0001-0004-*.md (releitura dos 4 arquivos da 1ª rodada)
3. AGENTS.md, CLAUDE.md
4. .hbn/relay/INDEX.md
5. obsidian-vault/ + docs/ (Diataxis)
6. usehbn/ (Founding Application)
7. .hbn/knowledge/0017-handoff-aos-50-pct-contexto.md

AS 2 ALTERNATIVAS A REFINAR

(idêntico ao Codex — copiar a seção AS 2 ALTERNATIVAS)

OBJETIVO 1 — REFINAMENTO SISTÊMICO EXAUSTIVO

Em .hbn/proposals/0007-antigravity-refinamento-arquitetural-v207.md, com
estrutura:

# Refinamento Arquitetural V12.0.0207 — Antigravity (2ª rodada)

## 1. Alternativa I — refinamento sistêmico
### 1.1 Impacto na metodologia HBN (knowledges novas que vão surgir)
### 1.2 Impacto na documentação Diataxis
  - Tutorials, How-to, Reference, Explanation: o que muda em cada
    release V207 e V208
### 1.3 Impacto no instalador/distribuição
### 1.4 Impacto na auditoria (Audit_Log, evidências, RVS)
### 1.5 Impacto na visão usuário-final (gestor do município)
### 1.6 Impacto na preparação SaaS futura
### 1.7 Riscos sistêmicos (governança, code-doc rot, friction operador)

## 2. Alternativa II — refinamento sistêmico
### 2.1-2.7 (mesma estrutura)
### 2.8 Risco específico do híbrido — "contratos imaturos antes do
    in-memory" — como mitigar com guard-rails sistêmicos

## 3. Comparação sistêmica das 2 alternativas
  - Tabela com: aderência ao princípio Universal Migration Format,
    cobertura da Doc-Delta Pattern (sua proposta da 1ª rodada),
    impacto no protocolo HBN, custo de manutenção de longo prazo.

## 4. Edge cases sistêmicos não cobertos pela 1ª rodada
  - O que acontece se 1 município sair antes da V207 terminar?
  - Como migrar workbooks históricos para o novo formato?
  - Como manter compatibilidade com PDFs gerados em V206?
  - Outros que você identificar

## 5. Alternativa III sistêmica (se você propõe)

OBJETIVO 2 — RECOMENDAÇÃO + JUSTIFICATIVA

Em .hbn/proposals/0008-antigravity-recomendacao-alternativa-i-ou-ii.md:

# Recomendação Antigravity — Alternativa I ou II (ou III)

(mesma estrutura do Codex, com perspectiva sistêmica)

PRINCÍPIO ESTRATÉGICO (não negociável)

A planilha continua sendo porta de entrada/saída, formato de migração
e garantia de independência do município. Toda recomendação respeita:
- Offline-First Client
- Universal Migration Format
- "Ejetar Monolito" sob demanda (se Alternativa III for backend)

REGRAS DE SEGURANÇA

(idêntico ao Codex)

ENTREGÁVEL FINAL

Quando terminar, dizer a Mauricio: 'Antigravity finalizou 2ª rodada de
auditoria arquitetural sistêmica V207. Arquivos em .hbn/proposals/0007-*
e 0008-*. Recomendação: Alternativa <I/II/III>. Próxima ação: Opus 4.7
consolida com 2ª rodada Codex e Mauricio decide.'

Sem prazos rígidos. Profundidade > velocidade.
```

---

## Referências

- Handoff origem desta sessão: [`.hbn/messages/20260526-1526-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260526-1526-handoff-fim-sessao-opus.md)
- Análise consolidada 1ª rodada: [`111_ANALISE_AUDITORIA_CRUZADA_V207.md`](111_ANALISE_AUDITORIA_CRUZADA_V207.md)
- Propostas 1ª rodada Codex: [`.hbn/proposals/0001-codex-auditoria-v206-codigo.md`](../../.hbn/proposals/0001-codex-auditoria-v206-codigo.md) + [`0002-codex-tres-propostas-v207-codigo.md`](../../.hbn/proposals/0002-codex-tres-propostas-v207-codigo.md)
- Propostas 1ª rodada Antigravity: [`.hbn/proposals/0003-antigravity-auditoria-v206-sistemica.md`](../../.hbn/proposals/0003-antigravity-auditoria-v206-sistemica.md) + [`0004-antigravity-tres-propostas-v207-sistemica.md`](../../.hbn/proposals/0004-antigravity-tres-propostas-v207-sistemica.md)
- Proposta evolução protocolo: [`.hbn/protocol-evolutions/20260526-1526-onda0111-proposals.md`](../../.hbn/protocol-evolutions/20260526-1526-onda0111-proposals.md)
- ERP último fechado: [`.hbn/results/0110-exec-evolucao-protocolo-v13.json`](../../.hbn/results/0110-exec-evolucao-protocolo-v13.json)
- Relay vivo: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
