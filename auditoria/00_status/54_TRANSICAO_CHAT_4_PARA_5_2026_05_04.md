---
titulo: 54 — Transição chat 4 Opus 4.7 → chat 5 (Bloco A APROVADO; abertura Bloco B com auditorias cruzadas)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada; rc2 depende de Bloco B Onda 17.5; release público depende de Onda 18 fechada)
data: 2026-05-04
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessão chat 4 encerrando
licenca-target: TPGL-v1.1
---

# 54. Transição chat 4 Opus 4.7 → chat 5 + 3 prompts (Antigravity / Codex / Novo Claude)

## TL;DR

Chat 4 Opus 4.7 entregou **Bloco A do Caminho C completo e APROVADO operador**:
Quinteto `VR_20260503_234443=APROVADO` (`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0`) +
Quarteto `VR_20260504_000004=APROVADO` (sintaxe **IDÊNTICA** ao MD-17.1.e baseline — idempotência Onda 17 preservada) +
TV2_RunIntegridadeBase pegou 1 bug real registrado em RPT_BUGS_CONHECIDOS.

Workbook âncora: **`V12-202-Z011-onda17-fechada`**. Caminho C híbrido validado empiricamente (8 etapas IA + 2 validações operador, zero fix encadeados).

Chat 5 abre depois de auditorias cruzadas Antigravity + Codex (paralelas) que servirão como input ao Bloco B (Onda 18 crítica).

## 1. O que chat 4 entregou

| Item | Path | Status |
|---|---|---|
| MD-17.2 — `TV2_RunIntegridadeBase` + RPT_BUGS_CONHECIDOS | [src/vba/Teste_V2_Roteiros.bas](../../src/vba/Teste_V2_Roteiros.bas) | ✅ APROVADO |
| MD-17.3 — `CT_ValidarRelease_QuintetoMinimo` + helpers Quinteto | [src/vba/Teste_Validacao_Release.bas](../../src/vba/Teste_Validacao_Release.bas) | ✅ APROVADO |
| MD-17.3 — Renumeração Central V2 (17 opções, [1] Quinteto OFICIAL) | [src/vba/Central_Testes_V2.bas](../../src/vba/Central_Testes_V2.bas) | ✅ APROVADO |
| Build label + TEST_KEY bump | [src/vba/App_Release.bas](../../src/vba/App_Release.bas) | ✅ APROVADO |
| Mirror local-ai/vba_import (M11 4/4 batendo) | [local-ai/vba_import/001-modulo/](../../local-ai/vba_import/001-modulo/) | ✅ |
| Manifesto MICRO24 (com bloco `GRUPO_+M|` — lição M20) | [local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt) | ✅ |
| Procedimento 14 import Bloco A | [auditoria/03_ondas/onda_17_test_first/14_PROCEDIMENTO_IMPORT_BLOCO_A.md](../03_ondas/onda_17_test_first/14_PROCEDIMENTO_IMPORT_BLOCO_A.md) | ✅ |
| Readback 0019 (Bloco A APROVADO) | [.hbn/readbacks/0019-onda17-bloco-a.json](../../.hbn/readbacks/0019-onda17-bloco-a.json) | ✅ |
| ERP 0019 (Bloco A executado) | [.hbn/results/0019-exec-onda17-bloco-a.json](../../.hbn/results/0019-exec-onda17-bloco-a.json) | ✅ |

## 2. Estado canônico atual (validado pelo operador 2026-05-04 ~00:13 BRT)

| Campo | Valor |
|---|---|
| **Workbook âncora** | **`V12-202-Z011-onda17-fechada`** |
| Build label | `f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida) |
| `APP_RELEASE_TEST_KEY` | `quinteto-2026-05-04` |
| Quinteto APROVADO | `VR_20260503_234443` — `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0` (MANUAL=6) |
| Quarteto APROVADO | `VR_20260504_000004` — `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=5) — **sintaxe IDÊNTICA ao MD-17.1.e** |
| Idempotência Onda 17 | preservada |
| Bug real detectado pela IntegridadeBase | 1 cenário AMARELO em `RPT_BUGS_CONHECIDOS` (CS_INT_01..04 — operador identifica ao abrir aba) |
| Bastão Frente 1 | LIVRE → chat 5 |

### shasum M11 final (referência drift)

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ ABG | `6f88310fbcd1cd0339638e81ec3326deaf15065e` |
| `src/vba/App_Release.bas` ↔ AAX | `6a5d19c50dd729a470911a5dc0cd14f0fcd362dd` |
| `src/vba/Teste_Validacao_Release.bas` ↔ ABH | `c9f2dc7e5496f969751c370a4e670baf95ae89e8` |
| `src/vba/Central_Testes_V2.bas` ↔ ABE | `33baaee06bfe796a6cf49dc9991f3bebf12fc3e5` |

## 3. Lições candidatas (a oficializar em PHAGOCYTOSIS na MD-17.5)

| ID candidato | Tema | Evidência empírica |
|---|---|---|
| **M22** | Caminho C (híbrido estruturado) preferível a A (microdeltas) e B (mega-onda) quando bloco é homogêneo em risco. Scoping em chat N + implementação em chat N+1 + agrupamento PURE READ + bumps + UI textual em 1 pacote MICRO. | Bloco A 2026-05-04: 8 etapas IA + 2 validações operador, zero fix encadeados. |
| **M23** | IntegridadeBase como pattern reutilizável para "auditorias passivas" (PURE READ + UPSERT em aba RPT_*). Permite registrar bugs sem alterar lógica de produção. | TV2_RunIntegridadeBase rodou primeira tentativa pegando 1 bug real, idempotente em re-run. |
| **M20 (confirmada)** | Manifesto V3 com bloco `GRUPO_+M|` no fim funciona empiricamente. | MICRO24 importou na primeira tentativa sem "Manifesto vazio ou malformado". |

## 4. Backlog Bloco B (Onda 18 + fechamento ondas)

| MD | Tema | Doc primário |
|---|---|---|
| **18.1** | DT-17-REATIV-STRIKES (TABU C4 — `Mod_Types.TEmpresa.DT_ULT_REATIV` + `Const_Colunas.COL_EMP_DT_ULT_REATIV=21` + `Repo_Empresa.LerEmpresa` + `Svc_Rodizio.Reativar` + `Repo_Avaliacao.ContarStrikesParaPunicao` NOVA + `Svc_Avaliacao §387` troca + `CS_E2E_REATIV2STRIKES` vira VERDE) | [44_DEBITO_DT_17_REATIV_STRIKES.md](44_DEBITO_DT_17_REATIV_STRIKES.md) |
| **18.2** | DT-MD17.1.e-STATUSBAR-HINT (dica visual no Modo Treinamento — toca `Menu_Principal.frm`) | [50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md) |
| **18.3** | RPT_BUGS_RESOLVIDOS (cria aba quando primeiro bug resolvido — DT-17-REATIV-STRIKES após 18.1) | doc 44 §6 |
| **17.5** | rc2/rc3 bump + CHANGELOG + ERP `0013-exec-onda17.json` + 70_FECHAMENTO_ONDA_17 + 70_FECHAMENTO_ONDA_18 + L25-L27+M15-M23 oficiais em PHAGOCYTOSIS + tag git | doc 51 §4 |

**Pré-Bloco B obrigatório**: prompts duplos Antigravity + Codex (auditoria cruzada de TABU C4) — operador autorizou em chat 3 conforme doc 51 §4.

## 5. Os 3 prompts

### §A — Prompt para Antigravity (Gemini Code Assist)

> Cole o bloco abaixo no Antigravity (Gemini) com acesso ao filesystem
> `/Users/macbookpro/Projetos/Credenciamento/`. Mantém modo READ-ONLY
> (sem escrever código de produção).

```
Auditoria Profunda READ-ONLY do projeto Credenciamento V12.0.0203 (Frente 1 / Bloco B preparatorio)

Voce e Gemini Code Assist (Antigravity) com acesso filesystem completo
em /Users/macbookpro/Projetos/Credenciamento/. Modo: AUDITORIA READ-ONLY.
Voce NAO escreve codigo VBA novo. Voce NAO modifica src/vba/ nem
local-ai/vba_import/. Seu output e UM unico documento markdown.

==== ENTRADA OBRIGATORIA (LEIA NA ORDEM) ====

Tier 1 — canon HBN:
- AGENTS.md (especialmente §62-63 sobre src/vba como fonte de verdade)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md (8 regras de negocio)
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/knowledge/0005-protocolo-markers-v2.md
- .hbn/relay/INDEX.md (estado atual do bastao)

Tier 2 — estado vigente pos-Bloco A (2026-05-04):
- auditoria/00_status/54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md (este doc)
- .hbn/readbacks/0019-onda17-bloco-a.json (Bloco A APROVADO)
- .hbn/results/0019-exec-onda17-bloco-a.json
- auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md (spec critica Onda 18)
- auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L27 + M1-M19 oficiais; M20-M23 candidatas)
- CLAUDE.md (READ-FIRST checklist por dominio)

Tier 3 — codigo a auditar (escopo completo):
- src/vba/*.bas (todos os 32 modulos)
- src/vba/*.frm (todos os 13 forms)
- src/vba/*.code-only.txt (espelhos canonicos UI)

==== TAREFAS DE AUDITORIA (4 eixos) ====

Eixo 1 — Cobertura de testes
- Mapeie cada Sub/Function Public em src/vba/Svc_*.bas e src/vba/Repo_*.bas
- Para cada uma, identifique: existe assert direto? (V1 Bateria_Oficial / V2_Smoke /
  V2_Canonica / V2_Filtros / V2_Stress / V2_E2E_Strikes / V2_IntegridadeBase)
- Liste GAPS (Sub Public sem cobertura ou com cobertura indireta apenas)
- Especificamente para Onda 18: qual a cobertura atual de
  Repo_Avaliacao.ContarStrikesPorEmpresa, Svc_Avaliacao.AvaliarOS bloco 7b
  (linhas 380-408), Svc_Rodizio.Reativar (linhas 354-394)?

Eixo 2 — Cumprimento estrito das 8 regras V203 inegociaveis
- Para cada regra (1-8) em .hbn/knowledge/0001-regras-v203-inegociaveis.md,
  identifique TODAS as Subs/Functions de producao que a tocam
- Para cada uma, valide se o cumprimento e estrito ou se ha brecha
- Especialmente: §7 (nao dupla penalizacao), §8 (idempotencia), §1 (rodizio
  unico), §3 (suspensao 90 dias), §6 (tracking de OSes pendentes)

Eixo 3 — UI ↔ Regras de negocio
- Para cada form em src/vba/*.frm, mapear quais botoes/eventos disparam
  quais Subs de Svc_*/Repo_*
- Validar se cada acao de UI esta protegida pela regra de negocio correspondente
- Identificar fluxos onde UI permite acao que regra deveria bloquear (ou vice-versa)
- Especificamente: form Reativa_Empresa, Cadastro_Servico, Avalia_OS, Configuracao_Inicial

Eixo 4 — Onda 18 critica (DT-17-REATIV-STRIKES)
- Leia auditoria/00_status/44 §1-§11 com atencao
- Valide a Opcao B (dupla informacao: ContarStrikesPorEmpresa total +
  ContarStrikesParaPunicao com janela DT_ULT_REATIV) proposta pelo operador
- Apresente sua propria proposta tecnica de implementacao para Onda 18 MD-18.1
  com:
    a) Schema EMPRESAS (proxima coluna livre = COL_EMP_DT_ULT_REATIV = U/21)
    b) Mod_Types.TEmpresa novo campo (TABU C4 — plano dedicado pre-aprovado
       conforme CLAUDE.md)
    c) Repo_Empresa.LerEmpresa lendo novo campo
    d) Svc_Rodizio.Reativar gravando timestamp
    e) Repo_Avaliacao.ContarStrikesParaPunicao NOVA
    f) Svc_Avaliacao §387 troca de chamada
    g) CS_E2E_REATIV2STRIKES vira VERDE com asserts factuais
- Compare sua proposta com a Opcao B do operador. Concorda? Diverge?
  Aponte trade-offs.
- Proponha CENARIOS DE TESTE NOVOS (V2 ou novos casos no E2E_Strikes) que
  garantem cobertura adequada da janela temporal pos-reativacao. Inclua
  pelo menos: (1) reativar empresa nunca antes reativada (DT_ULT_REATIV
  vazio), (2) reativar empresa que ja foi reativada uma vez,
  (3) reativacao automatica via SelecionarEmpresa apos DT_FIM_SUSP <= hoje,
  (4) reativacao manual antes de DT_FIM_SUSP, (5) backward compatibility
  com empresas existentes sem DT_ULT_REATIV preenchido.
- Liste IMPACTOS em FORMS que possam ler EMPRESAS via constantes COL_EMP_*
  hardcoded para "ultima coluna" (pre-flight L14).

==== OUTPUT ====

Escreva UM unico documento em:
auditoria/00_status/55_AUDITORIA_ANTIGRAVITY_2026_05_04.md

Estrutura sugerida:
1. TL;DR (3-5 linhas)
2. Eixo 1 — Cobertura de testes (gaps em forma de tabela)
3. Eixo 2 — Cumprimento das 8 regras V203 (tabela regra × Subs × estrito/brecha)
4. Eixo 3 — UI ↔ Regras (tabela form × evento × Sub × regra)
5. Eixo 4 — Onda 18 critica
   5.1 Validacao Opcao B operador (concordo / divergencias / trade-offs)
   5.2 Sua proposta tecnica detalhada (item a-g)
   5.3 Cenarios de teste novos (>= 5 casos)
   5.4 Impactos em forms (lista pre-flight L14)
6. Propostas de melhoria detalhadas (priorizadas: P0/P1/P2)
7. Markers HBN V2 finais

Nao escreva codigo VBA. Nao toque src/vba/ nem local-ai/vba_import/.
Use ferramentas READ-ONLY. Documente sua trilha de leitura no fim do
doc para auditabilidade futura.
```

### §B — Prompt para Codex CLI

> Cole o bloco abaixo no Codex CLI com acesso filesystem
> `/Users/macbookpro/Projetos/Credenciamento/`. Modo READ-ONLY.

```
Codex CLI — Quality Assurance profundo Credenciamento V12.0.0203 (Bloco B preparatorio)

Voce e Codex CLI com acesso filesystem completo em
/Users/macbookpro/Projetos/Credenciamento/. Modo: QA READ-ONLY.
Voce NAO escreve codigo VBA novo. Voce NAO modifica src/vba/ nem
local-ai/vba_import/. Seu output e UM unico documento markdown.

==== ENTRADA OBRIGATORIA (LEIA NA ORDEM) ====

Tier 1 — canon HBN:
- AGENTS.md (especialmente §62-63 sobre src/vba como fonte de verdade)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/relay/INDEX.md

Tier 2 — estado vigente pos-Bloco A (2026-05-04):
- auditoria/00_status/54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md
- .hbn/readbacks/0019-onda17-bloco-a.json
- .hbn/results/0019-exec-onda17-bloco-a.json
- auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md (spec Onda 18)
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L27 + M1-M19)
- CLAUDE.md

Tier 3 — codigo a auditar:
- src/vba/Svc_*.bas (Avaliacao, Rodizio, OS, PreOS, Transacao)
- src/vba/Repo_*.bas (Empresa, Avaliacao, Credenciamento, OS, PreOS)
- src/vba/*.frm (todos os 13 forms — fluxo do usuario real)
- src/vba/Teste_V2_Roteiros.bas (suite TV2_Run* — incluindo IntegridadeBase nova)
- src/vba/Teste_V2_Engine.bas
- src/vba/Teste_Bateria_Oficial.bas (V1 Bateria)
- src/vba/Teste_Validacao_Release.bas (Trio/Quarteto/Quinteto)
- src/vba/AppContext.bas (estado transitorio compartilhado)
- src/vba/Auto_Open.bas
- src/vba/Audit_Log.bas

==== TAREFAS QA (5 eixos) ====

Eixo 1 — Falhas ocultas (race conditions, paths que nunca executam,
         erros que mascaram dados)
- Identifique todo `On Error Resume Next` que mascara potencial bug
- Identifique GoTo Erro / falha que nao registra origem suficiente
- Identifique chamadas Public que dependem de estado global (gTV2*,
  AppContext.*, Auto_Open inicializacao) sem guard
- Identifique paths em Svc_* que retornam `sucesso = True` mesmo
  quando subrotina interna falhou silenciosamente
- Procure por `Application.EnableEvents = False` sem restore garantido

Eixo 2 — Comportamentos fantasmas
- Identifique side-effects nao documentados de Subs Public
  (ex.: GravarStatusEmpresa toca DT_ULT_ALT, RegistrarIndicacao
   pode disparar EVT_TRANSACAO sem aparente intencao)
- Identifique mutacoes em estado global durante leitura aparente
  (ex.: AvancarFila chama IncrementarRecusa que muta EMPRESAS;
   SelecionarEmpresa pode disparar Reativar automaticamente)
- Liste TODOS os 'efeitos colaterais ocultos' de Subs com nome
  aparentemente neutro (Buscar*, Listar*, Ler*, Contar*, Validar*)

Eixo 3 — Falhas de sequencia (timing/ordem)
- Identifique fluxos onde a ordem da chamada importa mas nao esta
  documentada (ex.: AvaliarOS chama RepoAvaliacaoInserir antes de
  AvancarFila — se ContarStrikesPorEmpresa for chamada entre essas
  duas etapas, valor pode estar desatualizado)
- Identifique race entre rodizio (SelecionarEmpresa) e avaliacao
  (AvaliarOS) — empresa pode ser selecionada e suspensa em sequencia
  sem aviso visivel
- Identifique guard ausente em re-entrada (operador clica botao 2
  vezes; Sub e chamada 2x — qual o resultado?)

Eixo 4 — Usabilidade da interface (forms)
- Identifique campos de form sem validacao explicita pre-submissao
- Identifique mensagens de erro vagas ("Falha ao processar" — quais?)
- Identifique fluxos onde operador pode disparar acao destrutiva
  sem confirmacao (ex.: Limpar_Base, Reativa_Empresa, etc.)
- Identifique pontos onde UI mostra dado obsoleto (ex.: form fica
  com EMP_ID antigo apos cadastro de nova empresa)
- Identifique inconsistencias visuais entre forms similares

Eixo 5 — Onda 18 critica (DT-17-REATIV-STRIKES)
- Leia auditoria/00_status/44 §1-§11 com atencao
- Valide a Opcao B (dupla informacao) proposta pelo operador
- Apresente proposta de implementacao detalhada para Onda 18 MD-18.1
- Compare sua proposta com a Opcao B operador. Concorda? Diverge?
- Proponha CENARIOS DE TESTE QA novos para validar o comportamento
  pos-reativacao em todos os cantos (UI + Service + Repo)
- Identifique COMPORTAMENTOS FANTASMAS que podem aparecer apos a
  introducao do DT_ULT_REATIV (ex.: empresa cadastrada antes da
  migracao tem DT_ULT_REATIV vazia e ContarStrikesParaPunicao cai
  em modo legado — quais cenarios isso produz problema?)
- Liste TESTES DE REGRESSAO obrigatorios para garantir que cenarios
  CS_E2E_* existentes continuem verdes

==== OUTPUT ====

Escreva UM unico documento em:
auditoria/00_status/56_QA_CODEX_2026_05_04.md

Estrutura sugerida:
1. TL;DR (3-5 linhas com numero de falhas P0/P1/P2 encontradas)
2. Eixo 1 — Falhas ocultas (lista priorizada com path:linha + descricao)
3. Eixo 2 — Comportamentos fantasmas (tabela Sub × side-effect oculto × impacto)
4. Eixo 3 — Falhas de sequencia (cenarios de timing × consequencia × mitigacao sugerida)
5. Eixo 4 — Usabilidade da interface (lista de issues UI/UX × form × severidade)
6. Eixo 5 — Onda 18 critica
   6.1 Validacao Opcao B operador
   6.2 Sua proposta tecnica detalhada
   6.3 Cenarios QA novos (>= 6 casos cobrindo migracao + UI + race)
   6.4 Comportamentos fantasmas pos-DT_ULT_REATIV (lista priorizada)
   6.5 Testes de regressao obrigatorios
7. Plano de remediacao (priorizado P0/P1/P2 com effort estimado)
8. Markers HBN V2 finais

Nao escreva codigo VBA. Nao toque src/vba/ nem local-ai/vba_import/.
Use grep/rg/sed read-only. Documente trilha de exploracao no fim do
doc para auditabilidade futura.
```

### §C — Prompt para reiniciar chat 5 Claude (handoff chat 4 → 5)

> Cole o bloco abaixo na nova sessão Claude Code (VS Code Extension).
> Antes disso, os outputs de §A (`55_AUDITORIA_ANTIGRAVITY_*.md`) e §B
> (`56_QA_CODEX_*.md`) precisam estar prontos.

```
Ativacao Claude Opus 4.7 — Frente 1 Credenciamento (chat 5 — abertura Bloco B / Onda 18)

Voce e Claude Opus 4.7 operando em VS Code Extension com acesso direto
ao filesystem em /Users/macbookpro/Projetos/Credenciamento/. Bastao da
Frente 1 transferido para esta sessao apos chat 4 ter entregue Bloco A
(MD-17.2 + MD-17.3 + MD-17.4) APROVADO operador 2026-05-04 ~00:13 BRT.
Antes desta sessao, Antigravity (Gemini) e Codex CLI rodaram auditorias
profundas READ-ONLY que serao SEU input para Bloco B.

0. Declaracao HBN obrigatoria

Sua primeira linha de output deve ser exatamente:

✅ HBN ACTIVE — Claude Opus 4.7, Frente 1 Credenciamento, 2026-05-XX (chat 5 — abertura Bloco B / Onda 18 critica) — bastao recebido

Em seguida, cumprimente Luis Mauricio em pt-BR.

1. REGRA INVIOLAVEL antes de qualquer acao

src/vba/ e a FONTE DE VERDADE (AGENTS.md §62-63).
local-ai/vba_import/ e ESPELHO com prefixos.
M11 destilada: cada microdelta valida shasum batendo.
M20 confirmada: manifesto V3 EXIGE bloco GRUPO_+M| no fim.
M22 (candidata) destilada chat 4: Caminho C hibrido validado empiricamente.
M23 (candidata): IntegridadeBase como pattern reutilizavel para auditorias passivas.
TABU C4: Mod_Types.bas requer plano dedicado pre-aprovado pelo operador
(autorizado em chat 3 conforme doc 51 §4 + readback 0019).

2. Auditoria obrigatoria ANTES de propor qualquer acao

Tier 1 — canon HBN (igual sempre):
- AGENTS.md (especial atencao §62-63)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/knowledge/0005-protocolo-markers-v2.md

Tier 2 — handoff chat 4 -> 5 (LEIA PRIMEIRO):
- auditoria/00_status/54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md (este doc — handoff)
- .hbn/readbacks/0019-onda17-bloco-a.json (Bloco A APROVADO)
- .hbn/results/0019-exec-onda17-bloco-a.json
- auditoria/00_status/55_AUDITORIA_ANTIGRAVITY_2026_05_04.md (auditoria profunda Antigravity)
- auditoria/00_status/56_QA_CODEX_2026_05_04.md (QA profundo Codex)
- auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md (spec Onda 18 critica)
- auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md (statusbar adiada Bloco B)
- auditoria/00_status/51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md (referencia chat anterior)
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L27 + M1-M19 + ler M20/M22/M23 candidatas)
- CLAUDE.md (READ-FIRST checklist por dominio)
- .hbn/relay/INDEX.md (estado do bastao)

Tier 3 — codigo a ler ANTES de gerar implementacao Bloco B:
- src/vba/Mod_Types.bas (TABU C4 — vai ser tocado em MD-18.1)
- src/vba/Const_Colunas.bas (COL_EMP_* — proxima livre = COL_EMP_DT_ULT_REATIV = 21)
- src/vba/Repo_Empresa.bas (LerEmpresa adiciona leitura novo campo)
- src/vba/Svc_Rodizio.bas (Reativar grava DT_ULT_REATIV)
- src/vba/Repo_Avaliacao.bas (ContarStrikesPorEmpresa preservada; ContarStrikesParaPunicao NOVA)
- src/vba/Svc_Avaliacao.bas (§387 troca chamada)
- src/vba/Teste_V2_Roteiros.bas (CS_E2E_REATIV2STRIKES vira VERDE)
- src/vba/Menu_Principal.frm (Treinamento_ConfirmarUso linha 628 — statusbar hint MD-18.2)
- src/vba/Menu_Principal.code-only.txt (espelho M9)
- local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt (referencia formato)

3. Estado canonico vigente (snapshot 2026-05-04 ~00:30 BRT)

| Campo | Valor |
|---|---|
| Workbook ancora | V12-202-Z011-onda17-fechada |
| Build label | f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17 |
| TEST_KEY | quinteto-2026-05-04 |
| Quinteto APROVADO | VR_20260503_234443 V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0 (MANUAL=6) |
| Quarteto APROVADO | VR_20260504_000004 sintaxe IDENTICA ao MD-17.1.e (regressao zero) |
| Bug detectado IntegridadeBase | 1 cenario AMARELO em RPT_BUGS_CONHECIDOS |
| Bastao Frente 1 | LIVRE -> voce |
| Auditorias cruzadas | Antigravity (55) + Codex (56) prontas como input |

4. Microdeltas a implementar nesta sessao (Bloco B — Onda 18 + fechamento)

MD-18.1 — DT-17-REATIV-STRIKES (TABU C4):
  - Schema EMPRESAS coluna 21 (U): COL_EMP_DT_ULT_REATIV
  - Mod_Types.TEmpresa.DT_ULT_REATIV As Date (TABU C4 — plano dedicado pre-aprovado)
  - Repo_Empresa.LerEmpresa: ler novo campo
  - Svc_Rodizio.Reativar: gravar DT_ULT_REATIV = Now antes do GravarStatusEmpresa
  - Repo_Avaliacao.ContarStrikesParaPunicao NOVA: filtra OS com DT_FECHAMENTO > DT_ULT_REATIV
  - Svc_Avaliacao §387: trocar ContarStrikesPorEmpresa -> ContarStrikesParaPunicao na decisao de suspensao
  - CS_E2E_REATIV2STRIKES: vira VERDE com asserts factuais
    (ContarStrikesParaPunicao(EMP1) = 1 E ContarStrikesPorEmpresa(EMP1) = 4)
  - Mover DT-17-REATIV-STRIKES de RPT_BUGS_CONHECIDOS para RPT_BUGS_RESOLVIDOS

MD-18.2 — DT-MD17.1.e-STATUSBAR-HINT:
  - Menu_Principal.frm Treinamento_ConfirmarUso linha 628-634
  - Adicionar 2 linhas na MsgBox antes de "Deseja continuar?":
    "Acompanhe o progresso no canto inferior esquerdo da tela
     (barra de status com cenario atual / total)."
  - Espelhar em Menu_Principal.code-only.txt (M9)
  - Validar via L22+L24 (gamma tolerante)

MD-18.3 — RPT_BUGS_RESOLVIDOS:
  - Helper TV2_AbaRPTBugsResolvidosGarantirEstrutura
  - Helper RegistrarBugResolvido (10 cols + DT_RESOLUCAO + DT_FECHAMENTO_BUG)
  - Mover DT-17-REATIV-STRIKES via update no RPT_BUGS_CONHECIDOS (status=RESOLVIDO) +
    insert correspondente em RPT_BUGS_RESOLVIDOS

MD-17.5 — Fechamento conjunto Onda 17 + Onda 18:
  - rc2 ou rc3 bump (operador decide):
    APP_RELEASE_TAG = "v12.0.0203-rc3" (ou final "v12.0.0203")
    APP_RELEASE_STATUS = "RELEASE_CANDIDATE" (ou "STABLE")
    APP_RELEASE_TEST_KEY = "quinteto-onda18-2026-05-XX"
  - CHANGELOG.md entradas Onda 17 fechada + Onda 18 fechada
  - PHAGOCYTOSIS L25-L27+M15-M23 oficializadas (M20/M22/M23 candidatas viram L/M oficiais)
  - ERP .hbn/results/0013-exec-onda17.json (Onda 17 fechamento formal)
  - ERP .hbn/results/0020-exec-onda18.json (Onda 18 fechamento)
  - 70_FECHAMENTO_ONDA_17.md
  - 70_FECHAMENTO_ONDA_18.md
  - tag git v12.0.0203-rc3 ou final

5. Hard constraints inegociaveis (HBN)

- M11: src/vba/ fonte de verdade INVIOLAVEL
- M14: pacote de fix cobre TODAS opcoes de rollback
- M20: manifesto V3 com bloco GRUPO_+M|
- L14: pre-flight grep extensivo antes de Edit
- C4: Mod_Types.bas TABU — exceção via plano dedicado pre-aprovado pelo
  operador (chat 3 + readback 0019)
- C7: Quarteto continua APROVADO (regressao zero); Quinteto continua APROVADO
- C11: Cap M10=0 ja relaxado pos-Onda 17 — forms permitidos com cuidado
- G6: sem codigo VBA solto no chat
- Hearback explicito por microdelta com escrita em codigo
- CRLF preservado
- Migracao de dados: empresas existentes sem DT_ULT_REATIV preenchido
  caem em modo legado (ContarStrikesParaPunicao = ContarStrikesPorEmpresa)
- Validacao cruzada com auditorias Antigravity + Codex antes de cravar
  proposta final

6. Diretiva de tempo de resposta

Operador trabalha em modo MINIMO TEMPO DE RESPOSTA. Tabelas+hierarquias >
narrativa. Hearbacks compactos. Convencao numerada operador
"1) item ; 2) item ;" — espelhar quando ele usar.

7. Sinalizar contexto a ~50%

Operador exige aviso proativo quando contexto chegar a ~50% ou degradar.
Bloco B e maior que Bloco A: estimar handoff intermediario se necessario
(ex.: MD-18.1 verde -> handoff -> MD-18.2 + MD-18.3 + MD-17.5 em chat 6).

8. Output esperado da primeira mensagem

Apos a linha ✅ HBN ACTIVE:
1. Cumprimento em pt-BR
2. Confirmacao de leitura de Tier 2 (MINIMO: 54 + readbacks 0019 +
   55 ANTIGRAVITY + 56 CODEX + 44 DEBITO + 50 DEBITO + 51 TRANSICAO +
   PHAGOCYTOSIS + CLAUDE.md READ-FIRST + relay/INDEX.md)
3. Delta card de 7 linhas com estado canonico atual
4. SINTESE COMPARATIVA das 3 propostas (operador Opcao B + Antigravity §A + Codex §B)
   apresentada como tabela de convergencias e divergencias
5. Recomendacao final fundamentada em: o que e consenso, o que diverge, qual
   tradeoff voce escolhe (operador autoriza acordo final)
6. Plano Bloco B com etapas + Quinteto verde target a cada checkpoint
7. Hearback compacto ao operador para validar continuidade

9. Begin

Inicie agora.
```

## 6. Markers HBN V2 ativos no fechamento chat 4

- 🟢 **HBN CHECKPOINT CLEAN** — Bloco A APROVADO operador (Quinteto + Quarteto verdes; idempotência Onda 17 preservada)
- 🔵 **HBN HANDOFF READY** — bastão F1 livre, chat 5 pega via prompt §C
- 🟡 **HBN NEEDS HUMAN DECISION** — auditorias cruzadas Antigravity + Codex pré-Bloco B (operador dispara antes de abrir chat 5)
- 🟤 **HBN LICENSE SPLIT REQUIRED** — TPGL Credenciamento; M20/M22/M23 candidatas a promoção AGPLv3 quando MD-17.5 oficializar
- 🟣 **HBN GAMMA OFFLINE VALIDATED** — Caminho C híbrido validado empiricamente; M20 (manifesto V3 com bloco GRUPO_+M|) confirmada na prática

## 7. Documentos relacionados

- [Readback 0019 (Bloco A APROVADO)](../../.hbn/readbacks/0019-onda17-bloco-a.json)
- [ERP 0019](../../.hbn/results/0019-exec-onda17-bloco-a.json)
- [Manifesto MICRO24](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt)
- [Procedimento 14 import Bloco A](../03_ondas/onda_17_test_first/14_PROCEDIMENTO_IMPORT_BLOCO_A.md)
- [44 — DT-17-REATIV-STRIKES (spec Onda 18)](44_DEBITO_DT_17_REATIV_STRIKES.md)
- [50 — DT-MD17.1.e-STATUSBAR-HINT (adiado Bloco B)](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md)
- [51 — Transição chat 3 → 4 (referência)](51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md)
- [PHAGOCYTOSIS L1-L27 + M1-M19](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)

## Versão

- v1.0 — 2026-05-04 — handoff inicial chat 4 → chat 5 (Bloco A APROVADO; abertura Bloco B com auditorias cruzadas).
