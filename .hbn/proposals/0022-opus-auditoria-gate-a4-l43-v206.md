---
titulo: Auditoria arquitetural GATE-A4 / L43 — V12.0.0206 (estabilização) vs V12.0.0207 (refatoramento)
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
papel-autor: Claude Opus 4.7 — auditor arquitetural / consolidador (Cadência D Estendida §12.B3)
escopo: confrontar L43 × código `35217c0+ONDA38.2.3-A4-F2-FORMS` × RVS `VR_20260529_223908`
output_path: .hbn/proposals/0022-opus-auditoria-gate-a4-l43-v206.md
predecessor: 0020 (Opus GATE-A3) + 0021 (Antigravity GATE-A3) + L43 PDF + RVS final pós-uso
---

# 0022 — Auditoria GATE-A4 / L43 V12.0.0206

> **Recado curto ao Codex (implementador V206):** o RVS pós-uso prolongado `VR_20260529_223908` está APROVADO (336/0/5). Isso **não** valida a release. O L43 expõe 28 BUGs reais em 9 módulos de UI, dos quais **6 são BLOQUEADORES de freeze**, **15 são FORTES** e **7 são MARGINAIS**. A cobertura RVS atual não enxerga regressão de UI nem persistência de painel de Configurações, e isso é, em si, um achado arquitetural. Antes de fechar V206 é preciso: (a) recuperar UI de Strikes, (b) eliminar duas regressões de cadastro de entidade que indicam corrupção quando a base não está zerada, (c) reaplicar proteção de planilhas, (d) reativar clamp ≥10 na impressão, (e) reorganizar fila de cadastro e (f) restituir feedback durante operação lenta. O resto entra V207 como refatoração compatível.

---

## 1. Inputs auditados

| Input | Identificador | Estado |
|---|---|---|
| Código-alvo operacional | `35217c0+ONDA38.2.3-A4-F2-FORMS` | importado, compilado |
| RVS sexteto pós-uso | `VR_20260529_223908` (V1=171/0, V2_Smoke=34/0/4M, V2_Canonico=24/0, E2E_Strikes=76/0, IntegridadeBase=4/0/1M, Onda23Adv=27/0) | **APROVADO** |
| Relatório humano | `Primeiro GATE-USO-PROLONGADO L43.pdf` (676 linhas extraídas) | **28 BUGs + 4 homologados + 2 com restrição** |
| Doutrina | `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md` §5 (BLOQUEADOR/FORTE/MARGINAL) | aplicado |
| Predecessores | proposals 0020 (Opus GATE-A3) + 0021 (Antigravity GATE-A3) | sem BLOQUEADORES abertos antes do L43 |

**Não-objetivos desta proposta:** (i) reescrever roadmap V207 — isso foi consolidado em `auditoria/00_status/112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md` (Alternativa II-bis confirmada); (ii) propor microdeltas concretos de código — função do implementador Codex; (iii) substituir homologação humana — Mauricio decide com base nesta proposta + auditoria cruzada de uma segunda IA em chat novo.

---

## 2. Achado arquitetural #0 — A cobertura RVS é estruturalmente cega para o L43

Este é o achado mais importante do GATE-A4 e precede qualquer correção pontual.

**Fato observado.** O sexteto RVS `VR_20260529_223908` retorna 336 OK / 0 falha sobre o exato workbook que, em uso humano de ~48 h, colapsou no fluxo Cadastrar Entidade, perdeu campos de Strikes na UI, imprimiu nota > 10 e exibiu Entidade 4 com status "ativa + inativa" simultâneo. Nenhum desses sintomas reproduz pelos roteiros V1, V2_Smoke, V2_Canonico, E2E_Strikes, IntegridadeBase nem Onda23Adv.

**Causa-raiz.** A bateria atual cobre repositórios (`Repo_*`), serviços (`Svc_*`), idempotência de gravação e adversarial UI de transação interrompida. Não cobre:

1. **Persistência de UI configurável** — não há roteiro que abra `Configuracao_Inicial`, leia Strikes/Dias/NotaCorte da tela, fecha, reabre, valida persistência.
2. **State machine de Cadastro de Entidade** — não há roteiro que faça `Cadastrar → Inativar → Reativar → editar Informações Completas → reselecionar` e valide que dados batem entre tela e aba.
3. **Fila / ordenação visual** — não há assert sobre `Entidades_Cadastradas.List` ordenação ativos-acima-inativos.
4. **Status simultâneo (corrupção lógica)** — não há assert de invariante `ENT_STATUS = ATIVA XOR ENT_STATUS = INATIVA`.
5. **Saídas impressas** — IMP_AVALIA / IMP_PREOS / IMP_OS gravam células e são impressas, mas nenhum teste compara o conteúdo dessas células contra clamp/regra de negócio antes do `PrintOut`.
6. **Proteção das abas** — nenhum teste fecha workbook, reabre e mede `ProtectContents = True` por aba sensível.
7. **Cycle-time perceptível** — nenhum teste afirma `tempo_cadastro_entidade < N s`.

**Severidade.** **BLOQUEADOR de freeze.** O Codex não pode fechar V206 com a hipótese implícita "RVS verde = release verde" enquanto o operador documenta colapso. **Antes do freeze é preciso ampliar o RVS para cobrir o gap categórico observado no L43**, mesmo que minimamente — caso contrário toda futura regressão de UI reincidirá invisível.

**Veto formal.** Esta proposta veta o uso isolado de `VR_20260529_223908` como evidência única de freeze V206. O hearback do Mauricio deve exigir, no mínimo, a entrega de **um roteiro novo `V2_PERSISTENCIA_PAINEL`** + **um roteiro novo `V2_CICLO_VIDA_ENTIDADE`** antes da tag `v12.0.0206`.

---

## 3. Classificação dos 28 BUGs do L43

Aplicada a grade `.hbn/knowledge/0019` §5: **BLOQUEADOR** = veto até resolver; **FORTE** = incorpora ou justifica por escrito; **MARGINAL** = pode ignorar.

Coluna "Natureza" responde à pergunta 4 do prompt: **B**=regra de negócio · **U**=estado de UI · **P**=proteção/segurança · **S**=persistência · **I**=impressão · **T**=teste insuficiente · **X**=cross-cutting (mais de uma).

### 3.1 BLOQUEADORES (6) — vetam freeze V206

| # L43 | Sintoma | Natureza | Causa-raiz provável (já verificada no código) |
|---|---|---|---|
| **B1** | §1.4.4 + §2 — Campos **strikes** e **dias de punição** desapareceram da UI `Configuracao_Inicial`. Regra de negócio existe (`COL_CFG_MAX_STRIKES`, `COL_CFG_DIAS_SUSPENSAO_STRIKE`, `Svc_Rodizio`), código de leitura existe (`Configuracao_Inicial.frm:97-98`), **mas o `.frx` não contém os controles `TxtMaxStrikes` / `TxtDiasSuspensao` / `TxtNotaCorte`** (verificado por `strings`). | U+S+T | regressão de designer `.frx`: a Onda V204/24 entregou os campos; alguma onda posterior (suspeita: rollback ad-hoc do form ou import de `.frm` sem o `.frx` casado — exatamente o anti-padrão da Regra de Ouro 0002) eliminou os controles. Código tolera silenciosamente via `On Error Resume Next` — **isso mascarou o bug em V204→V206**. |
| **B2** | §3 (todo o bloco) — Bateria 1 (base não zerada) colapsa Cadastro de Entidade; Bateria 2 (base zerada) funciona. Implica **estado pré-existente em alguma aba corrompe fluxo**. | X (B+S+T) | duas hipóteses convergentes a investigar: (a) `Util_Sanear_Contadores.SanearContadoresAR1` não cobre ENTIDADE / ENTIDADE_INATIVOS após alguma operação histórica; (b) `Repo_Entidade` (na verdade espelho em Menu_Principal + Svc_Entidade) usa `ProximoId` sem o pair-aware da Onda 38.2.2 AT-1 (verificar se ENTIDADES + ENTIDADE_INATIVOS está coberto). |
| **B3** | §3.4 — Entidade 4 aparece simultaneamente como **ATIVA e INATIVA**. | B+S | quebra de invariante de domínio. Indica duplicação de linha ou cache não invalidado em `Entidades_Cadastradas`. Compatível com falha de `Svc_Transacao` em algum caminho de inativação. **Risco real** para Rodízio (LerEmpresa-like): rodízio pode selecionar entidade inativa. |
| **B4** | §3.15 + §5.2 — Planilhas **não estão mais protegidas** ("proteção das células não está funcionando"). | P | `Util_PrepararAbaParaEscrita` desprotege e espera `Util_RestaurarProtecaoAba` no fim. Caminho de erro provavelmente esquece o restore (ver `IMP_AVALIA`/`Imprimir_AvaliacaoOS` com `mImpAvaliaEmUso`). Em V206 confiabilidade de proteção é parte do contrato público com gestor público — não é opcional. |
| **B5** | §7.1 — Avaliação **imprime nota > 10**. Verificado em código: `Svc_Avaliacao.SvcAvaliacao_NotaSegura` faz clamp em `AvaliarOS` (persistência), mas `Preencher.PreencherAvaliacaoOS` (linhas 3259-3268) grava `AvN01..AvN10` brutos em `N27:N36` antes do `PrintOut`. | B+I | clamp existe no caminho de **persistência** e não no caminho de **impressão**. Bug arquitetural clássico (mesma regra implementada em dois lugares assimetricamente). |
| **B6** | §3.11 + §3 (concl) — Cadastro de entidade **leva 24 s sem feedback**; usuário tenta digitar de novo achando que travou. | X (U+T) | combinação de: (i) ausência de `Util_Excel_Performance` no caminho de cadastro de entidade (envelopamento foi aplicado em Empresa/Credencia/Serviço pela 38.2.2 AT-5; entidade ficou de fora); (ii) `ProgressBar` aparece tarde ("80% que enrosca"); (iii) tela não fica em `Application.Cursor = xlWait`. Em uso real, isso induz **dupla submissão** que provavelmente é o gatilho do B2 e B3. |

**Conexão B2↔B3↔B6.** Hipótese arquitetural: o operador, sem feedback, clica duas vezes em "Cadastrar"; a segunda submissão entra em condição de corrida com a primeira e produz a linha extra que aparece como "ATIVA+INATIVA". Se confirmado, **B6 é causa-raiz operacional de B2 e B3** — corrigir feedback + envelopamento pode resolver os três.

### 3.2 FORTES (15) — devem entrar V206 ou ser justificadas por escrito

| # L43 | Sintoma | Natureza | Diagnóstico |
|---|---|---|---|
| F1 | §3.1 + §3.12 + §4.7 — Dados de Entidade aparecem completos só no modo edição, não na seleção. | U+S | divergência entre `B_Entidade_Click` (apenas troca PAGINAS) e o handler de seleção que popula a área de leitura. Falta um `Preencher_LeituraEntidade(idEnt)` análogo à edição. |
| F2 | §3.3 — Entidades cadastradas aparecem **no topo da fila** em vez de respeitar ordem. | B+U | regressão da Onda 38.2.1-AR1 já listou F2 do ERP 0105 ("cadastro entidade nova no topo"). Knowledge 0016 dizia que AR1 cobriria — não cobriu. |
| F3 | §3.6 + §4.3 — Form **não limpa** ao abrir para novo cadastro (entidade e empresa). | U | verificado: `B_Entidade_Click` (linha 176-205) só troca página; não chama `LimparCamposCadastroEntidade()` (que sequer existe). `LimparCamposCadastroEmpresa` existe (linha 2339) mas só é chamada em `AtualizarPosCadastroEmpresa` (após cadastro), não na entrada. Microdelta: criar `LimparCamposCadastroEntidade` + chamar nos dois eventos. |
| F4 | §3.7 — Botões "Reativa Entidade" e "Cadastrar Entidade" com **imagens sobrepostas**. | U | regressão de designer `.frx` (mesma classe do B1). |
| F5 | §4.1 + §4.6 — Não aparece **código** (ID) da empresa antes do CNPJ nem código do credenciamento. | U+B | regra "ID 3 dígitos" da Onda 38.2.3 está no backend (`Svc_PreOS` normaliza ENT_ID/EMP_ID). Frontend não exibe. Microdelta: adicionar coluna ID nos cabeçalhos da pasta de Cadastro de Empresa e do Credenciamento. |
| F6 | §4.2 — Não dá para preencher/editar **tempo de experiência** da empresa. | U+B | provável field readonly por engano no designer. Verificar `Credencia_Empresa.frm` controles `TXT_TpExperiencia` / similar. |
| F7 | §4.4 — Credenciamento demora **10 s**. | U+T | Onda 38.2.2 AT-5 envelopou `Credencia_Empresa` com `Util_Excel_Performance`. Ganho parcial atingido. Resíduo: reload de ListBox no `.frm`. Trade-off V206 = aceitar 10 s com feedback claro; ganho maior fica V207 com cache (Alternativa II-bis). |
| F8 | §4.5 — **Sobreposição de componentes** no campo de busca de credenciamento. | U | regressão de designer `.frx` em `Credencia_Empresa.frx`. |
| F9 | §5.1 — Empresa cadastrada toma 2 rodízios com nota < 7 e "não há disponíveis"; relatório diz que está disponível. | B+U | descasamento entre `Svc_Rodizio.SelecionarEmpresa` (suspende por strikes) e o relatório de "empresas por serviço" (não checa suspensão). Conecta com B1: gestor não consegue ajustar strikes/dias na UI, então também não consegue auditar o número. |
| F10 | §5.3 — Nome e telefone da empresa **não aparecem** quando ela é selecionada para o rodízio; opção de imprimir oculta. | U | provável que o handler "empresa selecionada para rodízio" não populariza os controles de visualização. |
| F11 | §6.1 — Filtros não funcionam na "Imprime Solicitação de Serviços". | U | filtros foram entregues no Menu Principal (Onda 38.2.2 AT-4) mas o painel de PreOS / Emite OS provavelmente ficou de fora. |
| F12 | §6.4 — Local para prestação de serviço **não aparece** na OS impressa. | I+B | célula correspondente em IMP_OS não está sendo preenchida em `Preencher` para o ramo "PreencherPreencheOS". |
| F13 | §6.5 — Campo **empenho** não aparece corretamente na OS impressa. | I | similar a F12. |
| F14 | §3.8 + §3.9 + §3.10 — Inativação de entidade comportamento errático: às vezes desaparece sem retornar, às vezes dá erro. | B+S | mesmo cluster do B2/B3 — provavelmente resolve junto com causa-raiz comum. Mantido como FORTE separado porque pode existir sub-bug específico de `Reativa_Entidade.frm` não detectado. |
| F15 | §1.4.4 — **Persistência** dos parâmetros **regride** após "atualização da planilha via janela imediata" (texto original do operador). | S+T | indica que algum macro de manutenção sobrescreve `CONFIG`. Compatível com a hipótese de que `ImportarPacoteV3` em ambiente atual reaplica defaults. Precisa de roteiro automatizado. |

### 3.3 MARGINAIS (7) — aceitáveis em V206, melhoram em V207

| # L43 | Sintoma | Natureza |
|---|---|---|
| M1 | §1.2 — Botão GitHub demora 1-2 min para abrir. Externo ao código. | U (externo) |
| M2 | §1.4.1 — Submenu "Ajuda" sem ação. Já planejado pós-V206 (FAQ HBN). | U (futuro) |
| M3 | §6.2 — Máscara cinza no nome da empresa/endereço da OS impressa. | I |
| M4 | §6.3 — Borda extra fora do formulário OS. | I |
| M5 | §8.1 — Rolagem horizontal em Cadastro de Serviço. | U |
| M6 | §9.1 — Descrição truncada nos botões de Relatórios. | U |
| M7 | §9.2 — Padronização visual dos relatórios (cores, sombras, bordas). | U |

### 3.4 Homologados pelo L43 (não-ação para Codex)

Botão Sobre (§1.1), Central de Testes (§1.3), Configurações Iniciais nível raiz (§1.4), Iniciar Novo Período (§1.4.2), Limpar Base (§1.4.3), Filtros em Entidades e em Inabilitados (§3.5), Filtros em Indica Empresa (§5.4), Inativação/Reativação na bateria 2 (§3.13).

---

## 4. Critérios de freeze V12.0.0206

Esta proposta define os critérios objetivos que o Mauricio deve exigir antes de tagar `v12.0.0206`:

### 4.1 Critério C1 — Cobertura RVS expandida (BLOQUEADOR estrutural)

Antes do freeze, a bateria V2 ganha **2 roteiros novos**:

- `V2_PERSISTENCIA_PAINEL`: abre Configuracao_Inicial, lê via `.Controls("TxtMaxStrikes")` etc., grava valor diferente, fecha form, reabre, valida persistência em CONFIG; reabre workbook; revalida. Falha se algum `.Controls(...)` lançar `Err.Number <> 0`.
- `V2_CICLO_VIDA_ENTIDADE`: cria entidade, valida invariante `Status = ATIVA XOR Status = INATIVA`, inativa, valida que aparece em INATIVOS e some de ATIVAS, reativa, valida volta, edita Informações Completas, valida que tela popula com o gravado.

### 4.2 Critério C2 — BLOQUEADORES B1–B6 resolvidos

Sem exceção. B6 deve incluir: `Application.Cursor = xlWait` no entry-point e `ProgressBar` visível desde o primeiro `Application.ScreenUpdating = False`.

### 4.3 Critério C3 — Auditoria cruzada A4 com pelo menos 2 IAs em chat novo

`.hbn/proposals/0023-*-auditoria-gate-a4-l43-v206.md` e `0024-*-auditoria-gate-a4-l43-v206.md`, ambas com severidade calibrada por `.hbn/knowledge/0019`.

### 4.4 Critério C4 — Re-execução RVS Sexteto + 2 roteiros novos

Build `<HEAD>+ONDA38.2.5-freeze-v206`. Aprovação textual em `auditoria/evidencias/V12.0.0206/csv/`.

### 4.5 Critério C5 — Re-validação manual L43.2

Mauricio repete tela-a-tela uma 2ª passada do L43 (versão `L44`) sobre a build pós-correção. Sem novos BLOQUEADORES. FORTES residuais documentados em CHANGELOG como débito V207.

### 4.6 Critério C6 — Higiene documental

CHANGELOG, release notes V206, INDEX evidências, relay/INDEX.md, AGENTS.md `versao-sistema`, `App_Release.bas`.

**Sem C1 + C2 + C5 não há freeze.** C3, C4 e C6 são procedimentais — recusa qualquer atalho.

---

## 5. Separação V206 / V207

A regra de corte é: **V206 = parar de mentir** (a UI mostra a regra real, a planilha protege de fato, a impressão respeita o clamp, o cadastro não corrompe estado). **V207 = ir mais rápido e mais bonito** (cache, padronização visual, microcopy, telemetria).

### 5.1 Entra V206 (obrigatório)

Todos os 6 BLOQUEADORES (B1–B6) + 11 dos 15 FORTES (F1, F2, F3, F4, F5, F8, F9, F10, F11, F12, F13, F14, F15). FORTES que ficam V207 explicitamente: F6 (tempo de experiência — pode estar mascarado por permissão de aba; auditar mas se for risco arquitetural vira V207), F7 (latência credenciamento — quick win possível mas ganho real depende de cache V207).

### 5.2 Fica V207 (refatoramento)

Todos os 7 MARGINAIS (M1–M7) + F7 parcial. **Continua valendo a Alternativa II-bis** (commit full V207.0–V207.8) já confirmada por Mauricio em 2026-05-26 ~16:30, com os 3 guard-rails sistêmicos (Fase-Lock, Invalidação Stateless, Callback Explícito). Os MARGINAIS de UI viram trabalho da V207.2 (padronização visual + microcopy) e V207.3 (relatórios consolidados).

### 5.3 Re-cobertura de testes V207

O achado #0 implica que **V207.0 deve incluir** um catálogo `Teste_V3_*` de roteiros UI-driven (não só Svc-driven). Isso é compatível com o "FAC" mencionado no L43 §1.3 e fecha o ciclo prometido no plano original V207.

---

## 6. Sequência executável para Codex

Sequência proposta em ondas safe_track Cadência D Estendida. Cada onda abre readback novo, aguarda hearback, entrega ERP, encerra com auditoria cruzada.

### Onda 38.2.4 — Restaurar UI de Strikes + clamp na impressão + proteção (BLOQUEADORES B1, B4, B5)

**Escopo (`scope.files_allowed`):**
- `src/vba/Configuracao_Inicial.frm` + `.frx`
- `src/vba/Preencher.bas` (apenas `PreencherAvaliacaoOS` linhas 3259-3268)
- `src/vba/Util_Planilha.bas` (`Util_RestaurarProtecaoAba` + auditoria de calls)
- `local-ai/vba_import/*` (espelho)
- `src/vba/App_Release.bas`

**Testes esperados:** roteiro novo `V2_PERSISTENCIA_PAINEL` + reuso de V1/V2 + asserção `(NX27..NX36) <= 10` no painel V2.

**Não-objetivos:** não tocar Menu_Principal, Cadastro_Servico, Credencia_Empresa, Repo_*, Svc_*.

### Onda 38.2.5 — Limpar estado de Cadastro de Entidade + envelopamento + feedback (BLOQUEADORES B2, B3, B6 + F3, F14)

**Escopo:**
- `src/vba/Menu_Principal.frm` (criar `LimparCamposCadastroEntidade`, chamar em `B_Entidade_Click`; envelopamento `Util_Excel_Performance` no cadastro entidade; `Application.Cursor = xlWait`; instrumentação de `ProgressBar`).
- `src/vba/Svc_Entidade.bas` (assert invariante `ATIVA XOR INATIVA`; idempotência idem 38.2.3 AT-3).
- `src/vba/Util_Sanear_Contadores.bas` (estender para ENTIDADE/ENTIDADE_INATIVOS pair-aware se ainda não estiver).
- `src/vba/Reativa_Entidade.frm` (verificar handler do erro de F14).

**Testes esperados:** roteiro novo `V2_CICLO_VIDA_ENTIDADE` + reexecução de E2E_Strikes e Onda23Adv.

**Não-objetivos:** não tocar Credencia_Empresa, Cadastro_Servico, Rel_*.

### Onda 38.2.6 — Persistência de leitura/exibição (FORTES F1, F5, F10, F11)

**Escopo:** `Menu_Principal.frm` (criar `Preencher_LeituraEntidade`; adicionar colunas ID); `Preencher.bas` (popular nome/telefone na seleção de Rodízio); auditar filtros em Imprime SS.

**Testes esperados:** estender `V2_CICLO_VIDA_ENTIDADE` com asserção de seleção, novos asserts em V2_Smoke para Rodízio.

### Onda 38.2.7 — Saídas impressas (FORTES F12, F13)

**Escopo:** `Preencher.bas` (paths `PreencherPreencheOS`) + `App_Release.bas`.

**Testes esperados:** novo `V2_OS_PRINT_INTEGRIDADE` que valida `IMP_OS!<celulas>` após `PreencherPreencheOS`.

### Onda 38.2.8 — Designer e ordenação (FORTES F2, F4, F8, F9)

**Escopo:** auditoria de `.frx` (B_Entidade, B_ReativaEntidade, Credencia_Empresa); review de `Entidades_Cadastradas_Click` para ordem de inserção; review de "empresas disponíveis" cruzando `Svc_Rodizio` × relatório.

### Onda 38.2.9 — Higiene de freeze (Critério C6)

**Escopo:** CHANGELOG, evidências, AGENTS.md, App_Release, release notes V206.

### Auditorias cruzadas

A cada Onda 38.2.X com BLOQUEADOR/FORTE entregue: 2 auditorias em chat novo (Antigravity + Gemini, ou Codex auditor adversarial + Antigravity). Implementador (Codex) não audita. Conflito BLOQUEADOR×BLOQUEADOR ⇒ Mauricio decide. Onda 38.2.5 é a mais crítica — exigir 3 auditores se possível pelo risco de regressão cruzada.

### Não-objetivos transversais

- Nada que toque `Mod_Types.bas` (proibido até Onda 9 reaberta).
- Nada que importe `.frm` sem `.frx` casado (Regra de Ouro 0002).
- Nada que rode V207 cache antes do freeze V206.
- Nada que use `On Error Resume Next` por mais de 3 linhas sem comentário (knowledge 0001).

---

## 7. Avaliação por natureza (resposta à pergunta 4 do prompt)

| Natureza | Quantidade | Severidade média | Comentário |
|---|---|---|---|
| Estado de UI (U) | 14 | FORTE | dominante; designer `.frx` regrediu silenciosamente em ≥2 ondas. **Sinal: protocolo Regra de Ouro 0002 está sendo desrespeitado de fato.** |
| Persistência / estado (S) | 6 | BLOQUEADOR | quando combinada com U vira corrupção (B2/B3/F15). |
| Regra de negócio (B) | 7 | FORTE | regras existem em backend (strikes, clamp, status, rodízio), mas frontend desconecta. **Sintoma sistêmico: front/back separados sem contrato testável.** |
| Impressão (I) | 6 | BLOQUEADOR/FORTE | clamp duplicado assimétrico (B5) + IMP_OS faltando campos (F12/F13). |
| Proteção (P) | 1 | BLOQUEADOR | mas único — vetor concentrado em `Util_PrepararAbaParaEscrita`/`Util_RestaurarProtecaoAba`. |
| Teste insuficiente (T) | 7 | BLOQUEADOR | achado #0. RVS cobre o lado errado do iceberg. |
| Cross-cutting (X) | 4 | BLOQUEADOR | B2/B3/B6 são o mesmo cluster operacional. |

**Conclusão arquitetural.** V206 não é uma release "com bugs cosméticos"; é uma release com **3 quebras de invariante de domínio** (status simultâneo, clamp assimétrico, proteção ausente), **1 regressão de UI silenciosa** (campos de Strikes) e **1 lacuna estrutural de cobertura** (RVS cego para fluxo humano). Tratar tudo como "polimento" subestima o risco. Tratar tudo como "reescrever" superestima o custo. O caminho honesto é o desta proposta: 6 ondas safe_track curtas, com auditoria cruzada em cada uma, e ampliação cirúrgica da bateria V2.

---

## 8. Coerência com roadmap pré-existente

- **Alternativa II-bis V207** (commit full V207.0–V207.8): **mantida**. Esta proposta não substitui nem antecipa V207.
- **3 guard-rails V207** (Fase-Lock, Invalidação Stateless, Callback Explícito): **mantidos**. Esta proposta acrescenta um **4º guard-rail recomendado**: **Contrato UI-Domínio explícito** — toda regra de negócio que tenha controle de UI correspondente deve ter um roteiro V2 que falhe quando o controle some.
- **Knowledge 0019 (Cadência D Estendida)**: **aplicada nesta proposta**. Severidades BLOQUEADOR/FORTE/MARGINAL substituem P0/P1/P2.
- **Knowledge 0002 (Regra de Ouro vba_import)**: **reforçada**. Os BUGs de `.frx` (B1, F4, F8) só conseguiram entrar porque alguém importou `.frm` sem o `.frx` casado em algum ponto. Onda 38.2.9 deve incluir verificação git-historica de quando os controles sumiram.
- **Knowledge 0010 (funcionalidade nova exige teste)**: esta proposta torna explícito o corolário: **funcionalidade existente que regride exige teste novo que falha pela regressão antes de ser fechada**.

---

## 9. Checklist anti-viés §12.4 do PROMPT_ARQUITETO

Aplicado por honestidade (esta proposta avalia o trabalho do Codex GATE-A4):

| Item | Resposta |
|---|---|
| Auto-indicação | Não. Esta proposta não indica IA executora para a Onda 38.2.4 em diante. |
| Evidência objetiva | RVS verde + L43 28 BUGs + verificação textual no código (Configuracao_Inicial.frm:97-98, Preencher.bas:3259-3268, Menu_Principal.frm:176-205, ausência de `TxtMaxStrikes` no `.frx`). |
| Viés natural | Opus 4.7 tende a recomendar Opus 4.7. Mitigação: esta proposta recomenda **manter Codex como implementador V206** (continuidade preferencial por <50% de contexto na linha 38.2.3) e usar **Opus + Antigravity como auditores em chat novo** por onda. |
| Mitigação | Mauricio pesa esta proposta + 0023 (Antigravity) + 0024 (Gemini ou Codex auditor) antes de decidir. |

---

## 10. Próxima ação concreta

1. Mauricio commita esta proposta (`.hbn/proposals/0022-*.md`).
2. Mauricio abre 1 ou 2 chats novos com prompt §12.B2 sobre o mesmo L43 + RVS + esta proposta para auditoria cruzada (`0023-*`, `0024-*`).
3. Se as auditoras independentes confirmarem o achado #0 e a classificação dos 6 BLOQUEADORES, Mauricio entrega ao Codex o readback `0120-rb-onda-38-2-4-restaurar-strikes-clamp-protecao` com o escopo da §6 desta proposta.
4. Codex executa a Onda 38.2.4 em chat continuado (ainda <50% de contexto provável) com auditoria cruzada A4-correção por 2 IAs ao final.
5. Iterar 38.2.5 → 38.2.9.
6. Tag `v12.0.0206` somente depois de C1+C2+C3+C4+C5+C6.

---

## 11. Anexo — Recortes verificados no código

Trechos textuais usados para fundamentar os BLOQUEADORES (todos lidos diretamente em `src/vba/` durante esta auditoria):

**B1 — UI de Strikes**: `Configuracao_Inicial.frm:95-98` declara `On Error Resume Next` antes de `Me.Controls("TxtMaxStrikes").Value` etc. `strings src/vba/Configuracao_Inicial.frx | grep -i strike` retorna vazio (0 matches). Conclusão: backend lê o controle, mas o controle não existe no designer atual. O `On Error Resume Next` esconde o erro.

**B5 — clamp na impressão**: `Svc_Avaliacao.bas:226-240` define `SvcAvaliacao_NotaSegura` com `If numero > 10 Then numero = 10`. `Preencher.bas:3259-3268` (`PreencherAvaliacaoOS`) grava `ws.Range("N27..N36").Value = Format(AvN01..AvN10, "##,#")` sem chamar `SvcAvaliacao_NotaSegura`. Variáveis `AvN01..AvN10` são preenchidas direto do `Avalia_OS.frm` antes da chamada.

**F3 — form não limpa**: `Menu_Principal.frm:176-205` (`B_Entidade_Click`) só faz troca de `PAGINAS.Value` e ajustes de visibilidade de `C_Tel_*`. Não há `Call LimparCamposCadastroEntidade`. `Menu_Principal.frm:2339` define `LimparCamposCadastroEmpresa` (usada só em `AtualizarPosCadastroEmpresa:2471`). Não existe equivalente para entidade. Microdelta: criar a função simétrica e chamar nos dois `B_*_Click` na entrada.

**Achado #0 — cobertura cega**: RVS `VR_20260529_223908` (linhas 2-7) cobre V1_RAPIDA, V2_SMOKE, V2_CANONICO, V2_E2E_STRIKES, V2_INTEGRIDADE_BASE, V2_ONDA23_ADV. Nenhum roteiro com nome que sugira teste de UI Forms (Configuracao_Inicial, Menu_Principal, Credencia_Empresa, Cadastro_Servico). Cross-check em `Teste_V2_Roteiros.bas` e `Teste_V2_Engine.bas` recomendado pela auditoria cruzada (0023/0024) para confirmar.

---

**FIM 0022-opus.** Próximo: 0023 (Antigravity) + 0024 (Gemini/Codex-auditor) em chats novos com mesmo input.
