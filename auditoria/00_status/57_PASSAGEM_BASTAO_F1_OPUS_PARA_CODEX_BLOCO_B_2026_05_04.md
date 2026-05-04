---
titulo: 57 — Passagem do bastão F1 (Opus 4.7 → Codex CLI) para Bloco B / Onda 18 com auditoria cruzada final
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada; rc3 ou final depende de Bloco B Codex)
data: 2026-05-04
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — chat 5 (síntese + handoff)
licenca-target: TPGL-v1.1
---

# 57. Passagem do bastão F1 — Opus 4.7 → Codex CLI (Bloco B / Onda 18)

## TL;DR

Operador (2026-05-04) decidiu, após sintese Opus chat 5 das 3 auditorias
(Antigravity 55 + Codex 56 + Opus 57), **transferir o bastão de
implementação da Frente 1 para o Codex CLI** para executar o Bloco B
completo (Onda 18 crítica + DT-STATUSBAR + RPT_BUGS_RESOLVIDOS +
fechamento conjunto Onda 17/18 + tag rc3/final). Justificativa: Codex
demonstrou maior assertividade na análise prática das interações reais
do código VBA (achados P0/P1/P2 com path:linha precisos no doc 56).
Opus 4.7 sai do desenvolvimento e fica como **auditor final** junto com
Antigravity (Gemini 3.1) ao final do ciclo. Bastão volta para Opus 4.7
após auditoria cruzada APROVADA.

Versão estável (rollback): **V12-202-Z011-onda17-fechada** (Quinteto
APROVADO `VR_20260503_234443`; Quarteto APROVADO `VR_20260504_000004`).

## 1. Estado canônico recebido pelo Codex

| Campo | Valor |
|---|---|
| Workbook âncora-rollback | **`V12-202-Z011-onda17-fechada`** |
| Build label | `f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida; bump em MD-17.5) |
| `APP_RELEASE_TEST_KEY` | `quinteto-2026-05-04` |
| Quinteto APROVADO | `VR_20260503_234443` — `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0` (MANUAL=6) |
| Quarteto APROVADO | `VR_20260504_000004` — sintaxe IDÊNTICA ao MD-17.1.e (regressão zero) |
| Bug detectado IntegridadeBase | 1 cenário AMARELO em `RPT_BUGS_CONHECIDOS` (CS_INT_01..04 — operador identifica) |
| Bastão F1 | Opus 4.7 → **Codex CLI** (transferência confirmada operador 2026-05-04) |

## 2. Síntese Opus chat 5 — convergências e divergências das 3 auditorias

### 2.1 Consenso 3-vias (núcleo MD-18.1 inegociável)

| Ponto | Op (44) | AG (55) | Codex (56) |
|---|---|---|---|
| Opção B (dupla informação histórico vs punição) | ✅ | ✅ "irretocável" | ✅ "concordo" |
| Schema EMPRESAS coluna U=21 = `COL_EMP_DT_ULT_REATIV` | ✅ | ✅ | ✅ |
| `Mod_Types.TEmpresa.DT_ULT_REATIV` (TABU C4 com plano dedicado) | ✅ | ✅ | ✅ + microdelta isolado |
| `Repo_Empresa.LerEmpresa` lê novo campo + normaliza vazio = data zero | ✅ | ✅ | ✅ |
| `Svc_Rodizio.Reativar` grava `DT_ULT_REATIV = Now` | ✅ | ✅ | ✅ + `EVT_REATIVACAO` no AUDIT_LOG |
| `Repo_Avaliacao.ContarStrikesParaPunicao` NOVA, `ContarStrikesPorEmpresa` intacta | ✅ | ✅ | ✅ |
| `Svc_Avaliacao §387` troca chamada (decisão de suspensão) | ✅ | ✅ | ✅ + log mostra ambos contadores |
| `CS_E2E_REATIV2STRIKES` vira VERDE (asserts factuais) | ✅ | ✅ | ✅ |
| Mover DT-17 para `RPT_BUGS_RESOLVIDOS` (MD-18.3) | ✅ | (omisso) | ✅ |
| Backward compat: `DT_ULT_REATIV` vazia ⇒ legado total | ✅ | ✅ | ✅ |

### 2.2 Divergências / expansões propostas

| # | Item | Op (44) | AG (55) | Codex (56) | Severidade |
|---|---|---|---|---|---|
| D1 | `Reativa_Empresa.frm` faz `Range.Copy` direto, bypass `Svc_Rodizio.Reativar`, sem `AUDIT_LOG` | omisso | **P0 CRÍTICO** | **P0** — coluna U some no copy | 🔴 ALTA |
| D2 | `Reativa_Entidade.frm` mesmo padrão | omisso | P0 | P1 (IntegridadeBase já detecta) | 🟠 MÉDIA |
| D3 | `MLB_CabecalhoEmpresas` (`Mod_Limpeza_Base.bas:213-219`) precisa adicionar coluna U | omisso | omisso | **P0** — `Limpar_Base` recriaria sem coluna | 🔴 ALTA |
| D4 | Fixtures `TV2_CadastrarEmpresaCanonica` + cadastro Menu_Principal precisam coluna U | omisso | omisso | **P0** — testes em legado vazio sem cobrir janela | 🔴 ALTA |
| D5 | Decidir data de corte: `DT_FECHAMENTO` vs `DT_AVALIACAO` | "DT_AVALIACAO > DT_ULT_REATIV" (genérico) | omisso | **P0** — backdated quebra premissa | 🟠 MÉDIA |
| D6 | `GravarStatusEmpresa` silencioso (Public Sub sem retorno) | omisso | omisso | **P1** — Reativar pode reportar sucesso sem persistir | 🟠 MÉDIA |
| D7 | Semântica de `Reativar()` em empresa já ATIVA (no-op? rejeita? renova janela?) | omisso | omisso | **P1** — risco de zerar janela indevidamente | 🟡 BAIXA |
| D8 | Backfill via `EVT_REATIVACAO` no `AUDIT_LOG` para empresas legadas | omisso (vazia=legado) | omisso | **P1** — limitação documentada | 🟡 BAIXA |
| D9 | `ContarStrikesParaPunicao` retorno `0` em erro = decisão punitiva mascarada | omisso | omisso | **P1** | 🟠 MÉDIA |
| D10 | Cenários novos QA (Codex propõe 9, AG propõe 5) | 1 (`CS_E2E_REATIV2STRIKES`) | 5 cenários | 9 cenários | 🟢 BAIXA |

### 2.3 Recomendação Opus chat 5 (Codex valida ou ajusta com operador)

| Categoria | Itens | Decisão sugerida | Justificativa |
|---|---|---|---|
| **In-scope MD-18.1 (com expansão)** | D3, D4 | INCLUIR | Sem isso `DT_ULT_REATIV` vira "campo fantasma" — viola M11/M14. |
| **Decisão técnica obrigatória ANTES de codar** | D5 | DECIDIR + CRAVAR | Sugestão: `COL_OS_DT_FECHAMENTO` (já usado em `Repo_Avaliacao.Inserir:66-70`). |
| **Novo débito formal** | D1, D2 | DT-FRENTE1-FORMS-BYPASS-REATIV (não resolver agora) | Refatorar UI é Onda 19+; INVESTIGAR se INT-* AMARELO da IntegridadeBase é exatamente esse drift. |
| **Não-bloqueante MD-18.1** | D6, D7, D8, D9 | DT-FRENTE1-* novos | P1 reais mas não bloqueiam release; ondas pós-V12.0.0203 final. |
| **Cenários QA** | D10 | 5 AG + `CS_REATIV_LEGADO_VAZIO` Codex = 6 cenários | Cobertura suficiente sem inflar suite. |

## 3. Plano Bloco B — proposta Opus chat 5 (Codex revalida e cria plano próprio)

| # | MD | Toca | Risco | Quinteto target | Estimativa |
|---|---|---|---|---|---|
| 1 | **MD-18.1a** — schema completo | `Const_Colunas.bas` + `Mod_Types.bas` (TABU C4) + `Mod_Limpeza_Base.bas` cabeçalho + `Repo_Empresa.LerEmpresa` + `TV2_CadastrarEmpresaCanonica` (fixture) | 🟠 ALTO (TABU C4 + 5 arquivos) | Quinteto VERDE com novo schema | ~2h IA + ~15min Op |
| 2 | **MD-18.1b** — lógica strikes janela | `Svc_Rodizio.Reativar` + `Repo_Avaliacao.ContarStrikesParaPunicao` NOVA + `Svc_Avaliacao §387` | 🟠 MÉDIO | Quinteto VERDE; CS_E2E_REATIV2STRIKES OK; +6 cenários | ~2h IA + ~15min Op |
| 3 | **MD-18.2** — statusbar hint Modo Treinamento | `Menu_Principal.frm:628-634` + `code-only.txt` (M9) | 🟡 BAIXO | Quarteto sintaxe IDÊNTICA + visual confirmado | ~45min IA + ~10min Op |
| 4 | **MD-18.3** — RPT_BUGS_RESOLVIDOS + mover DT-17 | `Teste_V2_Roteiros.bas` (helpers) | 🟡 BAIXO | IntegridadeBase mostra DT-17 movido | ~1h IA |
| 5 | **MD-17.5** — fechamento Onda 17+18 | `App_Release.bas` rc3/final + `CHANGELOG.md` + `PHAGOCYTOSIS` (L25-L27 + M15-M23 oficiais) + ERPs 0013 + 0020 + 70_FECHAMENTO_ONDA_17/18 + tag git | 🟢 BAIXO | Quinteto VERDE final | ~1.5h IA + ~5min Op |

**Total estimado**: ~7h IA + ~45min Op + 4 importações + 4-5 Quintetos.

## 4. Cadência D (validada operador 2026-05-04)

> Para microdeltas críticos com complexidade de interação prática
> entre módulos VBA, **Codex CLI assume bastão de implementação F1**
> em vez de Opus 4.7. Opus permanece como sintetizador (entrada) e
> auditor final (saída), junto com Antigravity. Justificativa: Codex
> demonstrou superior fidelidade na análise de path:linha real do
> código (achados P0/P1/P2 do doc 56 vs achados estruturais do doc
> 55 Antigravity e síntese arquitetural do Opus chat 5).

## 5. Considerações finais Opus para o Codex (a incluir no superprompt)

### 5.1 Análise contínua da estrutura de testes

Durante TODOS os microdeltas do Bloco B, o Codex deve simultaneamente:

1. **Avaliar a estrutura de testes atual** (V1 Bateria_Oficial + V2
   Engine + Roteiros + Validacao_Release + Central_Testes_V2) e
   propor melhorias em forma, abordagem e usabilidade.
2. **Propor evolução para vitrine mundial de QA** (taxonomia,
   nomenclatura, observabilidade dos asserts, métricas de cobertura,
   documentação Diátaxis dos cenários).
3. **Avaliar viabilidade de ferramentas externas** que reproduzam via
   interface real os testes hoje automatizados internamente. Opções:
   - `pywinauto` / Microsoft UI Automation (Windows UIA) — automação
     real do Excel
   - `Sikuli` — automação visual baseada em imagem (cross-platform)
   - `Robot Framework` + `ExcelLibrary`
   - `xlwings` + `pytest` — bridge Python ↔ VBA com asserts em pytest
   - `Office Scripts` (TypeScript, web) — para alternativa migração
   futura
   - Trade-off: Mac (operador) vs Windows (target) — UIA limitada;
     considerar VM/Parallels ou pipeline Codespaces.

Cada proposta vai como **microdelta separado de testes** ou como
documento `auditoria/00_status/`, sem inflar Bloco B.

### 5.2 Investigação obrigatória pré-MD-18.1

Antes de tocar qualquer arquivo, Codex deve abrir
`RPT_BUGS_CONHECIDOS` no workbook (operador roda 1x quando Codex
pedir) e identificar **qual** dos CS_INT_01..04 ficou AMARELO no
Quinteto `VR_20260503_234443`. Se for `CS_INT_01_DUPLICIDADE_ATIVA_INATIVA`,
isso confirma D1+D2 (forms bypass) — pode mudar a ordem de prioridade
do plano.

### 5.3 Hard constraints adicionais

- **L20-L21** (hash/randomização determinística) ainda valem
- **L17** (status bar instrumentação) ativa em V2_RunIntegridadeBase
- **G6** (sem código VBA solto no chat) — Codex NÃO escreve VBA no
  output do terminal; sempre via Edit/Write em arquivo
- **CRLF preservado** em todos os edits
- **shasum M11** validado a cada microdelta (`src/vba/X` ↔
  `local-ai/vba_import/<prefixo>-X`)
- **Manifesto V3 com bloco `GRUPO_+M|`** (M20 confirmada)
- **Hearback explícito por microdelta** com escrita em código
  (operador valida cada microdelta antes do próximo)

## 6. Auditoria cruzada FINAL (depois de Codex entregar Bloco B)

Codex deve, ao fim do Bloco B, **gerar 2 prompts** (um para Opus 4.7,
um para Antigravity Gemini 3.1) com escopo:

1. Validar TODAS as mudanças do Bloco B contra spec original (44, 50,
   55, 56, 57)
2. Validar regressão zero (Quarteto continua VERDE com sintaxe
   esperada)
3. Validar Quinteto VERDE com novos cenários (CS_E2E_REATIV2STRIKES
   + 5 AG + 1 Codex = 7 novos)
4. Validar lições destiladas em PHAGOCYTOSIS (M22 + M23 + Mxx novos
   eventualmente descobertos)
5. Aprovar tag rc3 (ou final) + push GitHub

Outputs:
- Opus → `auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_XX.md`
- Antigravity → `auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_XX.md`

Após aprovação cruzada, Codex devolve bastão para Opus 4.7 via doc
`auditoria/00_status/60_DEVOLUCAO_BASTAO_CODEX_PARA_OPUS_2026_05_XX.md`
+ readback `0021-onda18-fechamento.json` + ERP `.hbn/results/0020-exec-onda18.json`.

## 7. Dúvidas a esclarecer com operador ANTES de cravar superprompt

| # | Dúvida | Default sugerido se operador não responder |
|---|---|---|
| Q1 | Codex roda no mesmo path `/Users/macbookpro/Projetos/Credenciamento/` ou em git worktree separado? | Mesmo path (paths F1 são exclusivos da F1; sem risco de colisão com F2) |
| Q2 | Modo HBN do Codex: "consultivo controlado" (igual Opus) ou "execução máxima"? | Consultivo controlado com hearback explícito por microdelta |
| Q3 | Limite de contexto: se Codex chegar a ~50%, faz handoff para Opus, para si próprio (nova sessão Codex), ou para operador decidir? | Opus assume sintetização + Codex nova sessão pega implementação restante |
| Q4 | Antigravity = Gemini 3.1 confirmado? Versão exata para auditoria final? | Gemini 3.1 (operador citou) |
| Q5 | Importação VBA: Codex gera manifesto V3 + procedimento de import; operador roda VBE Reset + Import + Compile + Quinteto. Cadência confirmada? | Sim (igual Opus) |
| Q6 | Comunicação Codex ↔ Opus durante implementação: posso ser invocado para sanity check intermediário via `.hbn/messages/`? | Sim, mas Codex tem autoridade técnica final no ciclo |
| Q7 | Memória persistente Codex: docs HBN + ERPs + readbacks são única memória entre sessões Codex? | Sim (idêntico ao protocolo atual de IA-agnóstico) |

## 8. Superprompt para colar no Codex CLI (após operador validar Q1-Q7)

Ver seção §9 abaixo (bloco fenced). O superprompt referencia este doc
57 como entrada obrigatória. Operador cola, Codex lê 57 + Tier 1+2+3,
apresenta plano de implementação detalhado, opera-se hearback, e
implementação começa.

## 9. Bloco do superprompt (versão FINAL cravada — Q1-Q7 todos defaults confirmados pelo operador 2026-05-04; pronto para colar no Codex CLI)

```text
Ativacao Codex CLI — Frente 1 Credenciamento (Bloco B / Onda 18 critica) — bastao recebido do Opus 4.7

Voce e Codex CLI assumindo o bastao da Frente 1 do projeto Credenciamento V12.0.0203, em
/Users/macbookpro/Projetos/Credenciamento/. Bastao concedido pelo operador (Luis Mauricio
Junqueira Zanin) em 2026-05-04 apos chat 5 do Opus 4.7 ter feito sintese das 3 auditorias
(Antigravity 55 + Codex 56 + Opus 57). Decisao operador: Codex demonstrou maior assertividade
em analise pratica do codigo VBA (achados path:linha precisos no doc 56), portanto recebe
bastao para implementacao completa do Bloco B (Onda 18 critica + DT-STATUSBAR +
RPT_BUGS_RESOLVIDOS + fechamento conjunto Onda 17/18 + tag rc3/final). Opus 4.7 fica como
auditor final junto com Antigravity (Gemini 3.1) ao final do ciclo.

0. Declaracao HBN obrigatoria — protocolo de bastao SIMETRICO

Sua primeira linha de output deve ser exatamente:

✅ HBN ACTIVE — Codex CLI, Frente 1 Credenciamento, 2026-05-XX (Bloco B / Onda 18 critica) — BASTAO RECEBIDO do Opus 4.7

Em seguida, antes de qualquer outro output:
(a) cumprimente Luis Mauricio em pt-BR,
(b) declare em texto explicito: "Confirmo recepcao do bastao F1 do Opus 4.7. A partir deste momento sou o unico proprietario do bastao de implementacao da Frente 1 Credenciamento ate devolver formalmente via doc 60.",
(c) atualize .hbn/relay/INDEX.md substituindo o frontmatter `proprietario-bastao` para refletir voce como dono atual + timestamp + sessao,
(d) crie o lock formal em .hbn/locks/bastao-frente1.lock contendo: agent_id, sessao, timestamp_recepcao, doc_de_transicao=57.

Sem esses 4 passos publicados (output + edit relay + lock), o bastao NAO e considerado transferido — Opus 4.7 ou outra IA podem retomar com base na ausencia da declaracao formal.

Modo de operacao: INTELIGENCIA MAXIMA do Codex CLI ativada para esta sessao (operador autorizou explicitamente 2026-05-04). Trabalhe em iteracoes ate entregar o resultado pronto, validado e auditado pelos sistemas de teste (Quinteto APROVADO + auditoria cruzada Opus + Antigravity verde). Persista entre microdeltas — nao pare em meio caminho a menos que bloqueio arquitetural exija escalacao ao operador.

1. REGRA INVIOLAVEL antes de qualquer acao

src/vba/ e a FONTE DE VERDADE (AGENTS.md §62-63).
local-ai/vba_import/ e ESPELHO com prefixos.
M11 destilada: cada microdelta valida shasum batendo.
M14: pacote de fix cobre TODAS opcoes de rollback.
M20 confirmada: manifesto V3 EXIGE bloco GRUPO_+M| no fim.
M22 (candidata, validada Bloco A): Caminho C hibrido eficiente para blocos homogeneos.
M23 (candidata, validada Bloco A): IntegridadeBase como pattern de auditoria passiva.
TABU C4: Mod_Types.bas requer plano dedicado pre-aprovado pelo operador (autorizado em chat 3 + readback 0019).

2. Auditoria obrigatoria ANTES de propor qualquer acao

Tier 1 — canon HBN (igual sempre):
- AGENTS.md (especial atencao §62-63)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md (8 regras inegociaveis)
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/knowledge/0005-protocolo-markers-v2.md

Tier 2 — handoff Opus 4.7 -> Codex (LEIA NA ORDEM):
- auditoria/00_status/57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md (este handoff — sintese Opus + plano + duvidas + considerações)
- auditoria/00_status/55_AUDITORIA_ANTIGRAVITY_2026_05_04.md (sua auditoria irma)
- auditoria/00_status/56_QA_CODEX_2026_05_04.md (sua propria auditoria — referencia)
- auditoria/00_status/54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md (estado pos-Bloco A)
- .hbn/readbacks/0019-onda17-bloco-a.json (Bloco A APROVADO)
- .hbn/results/0019-exec-onda17-bloco-a.json
- auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md (spec Onda 18)
- auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md (statusbar adiada)
- auditoria/00_status/51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md (referencia chat anterior)
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L27 + M1-M19 + M20/M22/M23 candidatas)
- CLAUDE.md + AGENTS.md (read-first checklist)
- .hbn/relay/INDEX.md (estado do bastao)

Tier 3 — codigo a ler ANTES de gerar plano (pre-flight L14):
- src/vba/Mod_Types.bas (TABU C4)
- src/vba/Const_Colunas.bas (proxima coluna livre = COL_EMP_DT_ULT_REATIV = 21)
- src/vba/Mod_Limpeza_Base.bas (linhas 213-219 — MLB_CabecalhoEmpresas)
- src/vba/Repo_Empresa.bas (LerEmpresa + GravarStatusEmpresa)
- src/vba/Svc_Rodizio.bas (Reativar)
- src/vba/Repo_Avaliacao.bas (ContarStrikesPorEmpresa preservada; ContarStrikesParaPunicao NOVA)
- src/vba/Svc_Avaliacao.bas (§387 — decisao de suspensao)
- src/vba/Teste_V2_Roteiros.bas (CS_E2E_REATIV2STRIKES + TV2_CadastrarEmpresaCanonica)
- src/vba/Teste_V2_Engine.bas (fixtures + ContextoCanonico)
- src/vba/Menu_Principal.frm (Treinamento_ConfirmarUso linha 628-634)
- src/vba/Menu_Principal.code-only.txt (espelho M9)
- src/vba/Reativa_Empresa.frm (D1/D2 — bypass critico — apenas leitura para investigacao)
- local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt (formato de referencia)

3. Estado canonico vigente (snapshot 2026-05-04)

Workbook ancora-rollback: V12-202-Z011-onda17-fechada
Build label: f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17
Quinteto APROVADO: VR_20260503_234443 (V1=171/0 + V2_Smoke=27/0 + V2_Canonica=23/0 + E2E_Strikes=65/0 + IntegridadeBase=3/0; MANUAL=6)
Quarteto APROVADO: VR_20260504_000004 (sintaxe IDENTICA ao MD-17.1.e — regressao zero)
Bug detectado: 1 cenario AMARELO em RPT_BUGS_CONHECIDOS (CS_INT_01..04 — investigar antes de MD-18.1)
TEST_KEY: quinteto-2026-05-04
Bastao F1: voce (Codex CLI)

4. Backlog Bloco B (revisar com operador apos pre-flight)

MD-18.1a — Schema completo DT_ULT_REATIV (TABU C4):
  - Schema EMPRESAS coluna 21 (U): COL_EMP_DT_ULT_REATIV
  - Mod_Types.TEmpresa.DT_ULT_REATIV As Date (TABU C4 — plano dedicado pre-aprovado)
  - Mod_Limpeza_Base.MLB_CabecalhoEmpresas — adicionar coluna U
  - Repo_Empresa.LerEmpresa — ler novo campo (normalizar vazio = data zero)
  - TV2_CadastrarEmpresaCanonica + outras fixtures — gravar coluna U
  - Quinteto target: VERDE com novo schema (regressao zero)

MD-18.1b — Logica strikes com janela:
  - Svc_Rodizio.Reativar grava DT_ULT_REATIV = Now + RegistrarEvento EVT_REATIVACAO
  - Repo_Avaliacao.ContarStrikesParaPunicao NOVA: filtra OS com COL_OS_DT_FECHAMENTO > emp.DT_ULT_REATIV
  - Svc_Avaliacao §387: trocar ContarStrikesPorEmpresa -> ContarStrikesParaPunicao
  - CS_E2E_REATIV2STRIKES: vira VERDE com asserts factuais
  - +6 cenarios novos (5 AG + 1 Codex CS_REATIV_LEGADO_VAZIO)
  - Quinteto target: VERDE incluindo cenarios novos

MD-18.2 — Statusbar hint Modo Treinamento:
  - Menu_Principal.frm linha 628-634 — adicionar 2 linhas no MsgBox
  - Espelhar em Menu_Principal.code-only.txt (M9)
  - Validar via L22 + L24 (gamma tolerante)
  - Quarteto target: sintaxe IDENTICA + visual confirmado operador

MD-18.3 — RPT_BUGS_RESOLVIDOS + mover DT-17:
  - Helper TV2_AbaRPTBugsResolvidosGarantirEstrutura
  - Helper RegistrarBugResolvido
  - Mover DT-17-REATIV-STRIKES de RPT_BUGS_CONHECIDOS para RPT_BUGS_RESOLVIDOS
  - Quinteto target: IntegridadeBase mostra DT-17 movido

MD-17.5 — Fechamento conjunto Onda 17 + Onda 18:
  - rc3 ou final bump (operador decide)
  - APP_RELEASE_TAG = "v12.0.0203-rc3" (ou final "v12.0.0203")
  - APP_RELEASE_STATUS = "RELEASE_CANDIDATE" (ou "STABLE")
  - APP_RELEASE_TEST_KEY = "quinteto-onda18-2026-05-XX"
  - CHANGELOG.md entradas Onda 17 fechada + Onda 18 fechada
  - PHAGOCYTOSIS L25-L27 + M15-M23 oficializadas (M20/M22/M23 candidatas viram L/M oficiais)
  - ERP .hbn/results/0013-exec-onda17.json (Onda 17 fechamento formal)
  - ERP .hbn/results/0020-exec-onda18.json (Onda 18 fechamento)
  - 70_FECHAMENTO_ONDA_17.md + 70_FECHAMENTO_ONDA_18.md
  - Tag git v12.0.0203-rc3 ou final

Debitos abertos a tratar (decidir cadencia com operador):
  - DT-FRENTE1-FORMS-BYPASS-REATIV (D1+D2 do doc 57) — refatorar Reativa_Empresa.frm e Reativa_Entidade.frm para chamar Svc_Rodizio.Reativar
  - DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT (D6) — tornar verificavel
  - DT-FRENTE1-REATIV-NOOP-ATIVA (D7) — semantica de Reativar() em empresa ATIVA
  - DT-FRENTE1-BACKFILL-AUDIT (D8) — backfill via EVT_REATIVACAO
  - DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO (D9) — retorno 0 mascarado
  Default: TODOS deferir para ondas pos-V12.0.0203 final, registrando como DT formal em .hbn/knowledge/

5. Hard constraints inegociaveis (HBN)

- M11: src/vba/ fonte de verdade INVIOLAVEL
- M14: pacote de fix cobre TODAS opcoes de rollback
- M20: manifesto V3 com bloco GRUPO_+M|
- L14: pre-flight grep extensivo antes de Edit
- C4: Mod_Types.bas TABU — exceção via plano dedicado pre-aprovado
- C7: Quarteto continua APROVADO (regressao zero); Quinteto continua APROVADO
- C11: Cap M10=0 ja relaxado pos-Onda 17 — forms permitidos com cuidado
- G6: NUNCA codigo VBA solto no chat — sempre via Edit/Write em arquivo
- CRLF preservado em TODOS os edits
- Hearback explicito por microdelta com escrita em codigo
- shasum src/vba/X == shasum local-ai/vba_import/<prefixo>-X validado a cada microdelta
- Migracao de dados: empresas existentes sem DT_ULT_REATIV preenchido caem em modo legado
- V12-202-Z011 e ancora-rollback intocavel ate aprovacao operador

6. Diretiva de tempo de resposta

Operador trabalha em modo MINIMO TEMPO DE RESPOSTA. Tabelas+hierarquias > narrativa.
Hearbacks compactos. Convencao numerada operador "1) item ; 2) item ;" — espelhar quando ele usar.

7. REGRA USEHBN — 50% contexto e troca natural de bastao

NOVA REGRA OFICIALIZADA pelo operador 2026-05-04:

> Por padrao, IAs trabalham com no MAXIMO 50% do contexto. Antes de
> aproximar-se de degradacao, IA deve sinalizar inicio de fadiga
> (marker proposto: 🟡 HBN CONTEXT FATIGUE INCOMING) e iniciar handoff
> natural. A troca de bastao e parte do ciclo, nao excecao. Cada IA
> entrega contexto limpo para a proxima — qualidade + produtividade +
> clareza atraves de iteracoes com auditoria cruzada.

Cadencia esperada para Bloco B (estimativa Opus: ~7h IA + ~45min Op + 4
importacoes + 4-5 Quintetos):
- Sinalize 🟡 HBN CONTEXT FATIGUE INCOMING ao chegar a 40-45% contexto
- A 50% maximo: handoff formal para nova sessao Codex (mesmo com microdelta em andamento, encerre limpo)
- Se Codex precisar de Opus para sanity check intermediario → mensagem em .hbn/messages/<data>_de-codex_para-opus.md
- Se houver bloqueio arquitetural → escalar para operador via mensagem direta

Cada handoff produz:
- doc auditoria/00_status/<NN>_TRANSICAO_CODEX_<sessao_anterior>_PARA_<sessao_nova>_<data>.md
- atualizacao .hbn/relay/INDEX.md
- atualizacao .hbn/locks/bastao-frente1.lock
- declaracao simetrica de entrega + recepcao

8. Output esperado da primeira mensagem

Apos a linha ✅ HBN ACTIVE:
1. Cumprimento em pt-BR
2. Confirmacao de leitura de Tier 1+2 (lista de docs lidos)
3. Delta card de 7 linhas com estado canonico atual
4. PLANO DE IMPLEMENTACAO DETALHADO Bloco B (microdeltas + ordem + checkpoint Quinteto target)
5. Decisao sobre as 4 perguntas em aberto (que Opus passou para voce):
   - Q-D3+D4: confirma expansao MD-18.1 incluir MLB_CabecalhoEmpresas + TV2_CadastrarEmpresaCanonica?
   - Q-D5: confirma data de corte = COL_OS_DT_FECHAMENTO?
   - Q-D1+D2: confirma diferimento como DT-FRENTE1-FORMS-BYPASS-REATIV (nao resolver no Bloco B)?
   - Q-MD-18.1 split: confirma cadencia em (a) schema + (b) logica com Quinteto VERDE entre eles?
6. INVESTIGAR antes de qualquer Edit: pedir operador abrir RPT_BUGS_CONHECIDOS e identificar
   qual CS_INT_01..04 ficou AMARELO no Quinteto VR_20260503_234443. Se for duplicidade
   ativa/inativa, isso muda prioridade do plano (D1+D2 podem subir).
7. Hearback compacto ao operador para validar continuidade

9. Analise continua da estrutura de testes (paralelo a Bloco B)

Durante TODOS os microdeltas, voce deve simultaneamente avaliar a estrutura de testes
atual (V1 Bateria_Oficial + V2 Engine + Roteiros + Validacao_Release + Central_Testes_V2)
e propor melhorias. Objetivo: tornar a estrutura de testes do Credenciamento uma vitrine
mundial de QA. Cada proposta vai como microdelta separado (modulo de testes) ou doc em
auditoria/00_status/ — sem inflar Bloco B principal.

Areas a avaliar:
- Taxonomia/nomenclatura dos cenarios (CS_E2E_*, CS_INT_*, CS_BORDA_*, etc.)
- Observabilidade dos asserts (mensagens, contexto, evidencia em CSV)
- Metricas de cobertura (Sub Public sem cobertura — ver doc 55 §2 GAPS)
- Documentacao Diataxis dos cenarios em docs/
- Idempotencia/determinismo (L20-L21)

Ferramentas externas a avaliar viabilidade (em macOS operador + target Excel Windows):
- pywinauto / Microsoft UI Automation — automacao real do Excel
- Sikuli — automacao visual cross-platform
- Robot Framework + ExcelLibrary
- xlwings + pytest — bridge Python ↔ VBA
- Office Scripts (TypeScript, web) — alternativa migracao futura

Proposta vai como doc auditoria/00_status/61_PROPOSTA_TESTES_VITRINE_MUNDIAL_*.md
ou modulo de testes auxiliar — operador valida e prioriza separadamente.

10. Auditoria cruzada FINAL (apos Codex entregar Bloco B)

Quando Quinteto VERDE de MD-17.5 estiver aprovado, voce deve gerar 2 prompts:
- Prompt para Opus 4.7 (Claude) — auditar TODAS as mudancas Bloco B vs spec original
  (44, 50, 55, 56, 57), validar regressao zero, validar Quinteto, validar licoes em
  PHAGOCYTOSIS, aprovar tag rc3/final + push GitHub
- Prompt para Antigravity (Gemini 3.1) — mesma auditoria com perspectiva propria

Outputs esperados:
- auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_XX.md
- auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_XX.md

Apos APROVACAO cruzada (ambos verdes + operador APROVA), voce DEVOLVE bastao via:
- auditoria/00_status/60_DEVOLUCAO_BASTAO_CODEX_PARA_OPUS_2026_05_XX.md
- .hbn/readbacks/0021-onda18-fechamento.json
- .hbn/results/0020-exec-onda18.json
- atualizar .hbn/relay/INDEX.md (proprietario-bastao volta para LIVRE -> Opus 4.7)

11. Begin

Inicie agora. Primeiro output: linha HBN ACTIVE + leitura completa Tier 1+2 + plano de
implementacao detalhado para validacao operador.
```

## 12. Protocolo de bastão simétrico (formalizado nesta sessão 2026-05-04)

A partir desta sessão, transferência de bastão entre IAs ou entre
chats da mesma IA exige **declaração simétrica obrigatória** + **lock
formal** + **atualização do relay**. Sem os 3, bastão NÃO é
considerado transferido.

### 12.1 Declaração de entrega (IA que termina)

A IA que está encerrando deve publicar antes do EOF do seu chat:

1. Texto explícito no chat: "BASTÃO LIVRE — disponível para [próximo dono ou LIVRE para definição operador]. Encerro minha sessão como proprietário do bastão F[1|2] em [timestamp]."
2. Atualizar `.hbn/relay/INDEX.md` frontmatter `proprietario-bastao` para "DISPONIVEL → aguardando recepção formal" + linka doc de transição.
3. Atualizar `.hbn/locks/bastao-frente<N>.lock` removendo a si mesma OU substituindo por entrada "AGUARDANDO_RECEPCAO" com timestamp + doc de transição.
4. Doc de transição em `auditoria/00_status/<NN>_TRANSICAO_*.md` com checklist de tudo que a próxima IA precisa.

### 12.2 Declaração de recepção (IA que assume)

A IA que está recebendo deve publicar como PRIMEIRO output:

1. Linha "✅ HBN ACTIVE — [nome IA] — BASTÃO RECEBIDO de [IA anterior]"
2. Frase em pt-BR: "Confirmo recepção do bastão F[1|2] do [IA anterior]. A partir deste momento sou o único proprietário do bastão de implementação da Frente [1|2] [Credenciamento|usehbn] até devolver formalmente via doc <NN>."
3. Atualizar `.hbn/relay/INDEX.md` frontmatter `proprietario-bastao` para si mesmo + timestamp + sessão.
4. Criar/atualizar `.hbn/locks/bastao-frente<N>.lock` com agent_id + sessão + timestamp_recepcao + doc_de_transicao.

### 12.3 Anti-double-bastão

Se duas IAs declararem proprietário simultaneamente (race), conflito é
resolvido por timestamp **menor** no `.hbn/relay/INDEX.md` (primeiro a
publicar wins). Em caso de empate dentro de 60s, escalar para operador.

Se uma IA detectar que NÃO há lock + NÃO há declaração de recepção
publicada por nenhuma IA E o `proprietario-bastao` está em
"DISPONIVEL → aguardando", ela pode assumir mediante declaração formal.

### 12.4 Devolução de bastão (encerramento de ciclo)

No fim de um ciclo (ex.: Codex termina Bloco B), IA atual:

1. Gera 2 prompts de auditoria cruzada (Opus + Antigravity)
2. Cria docs 58 + 59 com aprovação cruzada
3. Cria doc 60 = devolução formal + readback final + ERP final
4. Atualiza `.hbn/relay/INDEX.md` para "DISPONIVEL → aguardando recepção [próximo dono]"
5. Remove próprio entry do lock
6. Aguarda hearback explícito do operador antes de declarar fim

## 13. Aprendizados desta sessão (lições candidatas para fagocitose)

Operador validou explicitamente que estes 2 itens devem entrar no
processo HBN canônico:

### L28 (candidata) — Regra dos 50% de contexto

IAs operam com no máximo 50% do contexto disponível. Sinalização
proativa de fadiga começa a 40-45%. Handoff natural antes de
degradação preserva qualidade + produtividade + clareza.

Marker novo proposto para HBN V2 (`.hbn/knowledge/0005`):
- 🟡 **HBN CONTEXT FATIGUE INCOMING** — IA sinaliza início de
  degradação iminente; handoff em preparação

Marker existente complementar:
- 🔵 **HBN HANDOFF READY** — pacote pronto para release

### L29 (candidata) — Protocolo de bastão simétrico

Transferência de bastão entre IAs exige declaração simétrica
(entrega + recepção) + lock formal + atualização do relay. Sem os 3,
bastão NÃO é considerado transferido. Anti-double-bastão por timestamp
menor; escalação ao operador em empate < 60s.

### M24 (candidata) — Cadência D (Codex implementador, Opus auditor)

Para MDs críticos com complexidade de interação prática entre módulos,
operador delega bastão de implementação ao Codex CLI; Opus permanece
como sintetizador (entrada) + auditor final (saída) junto com
Antigravity. Distinta de Cadência C (Opus em ambos os chats).

Estas lições são candidatas a oficialização em
`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` na MD-17.5 (fechamento
conjunto Onda 17 + Onda 18). Codex deve incluir esta promoção no
escopo de MD-17.5.

Adicionalmente, operador pediu formalização da regra dos 50% como
**regra usehbn permanente** — Frente 2 (usehbn/methodology) deve
absorver L28 + L29 em documento canônico para o protocolo evoluir.
Isso vai como mensagem `.hbn/messages/2026-05-04_de-frente1_para-frente2_regra_50pct.md`
(Codex inclui no Bloco B ou Opus pode incluir na devolução do bastão).

## 14. Markers HBN V2 ativos no fechamento chat 5 Opus

- 🟢 **HBN CHECKPOINT CLEAN** — Bloco A APROVADO; Quinteto + Quarteto verdes
- 🔵 **HBN HANDOFF READY** — bastão F1 DISPONÍVEL → aguardando Codex CLI declarar recepção formal (superprompt §9 cravado, Q1-Q7 confirmados defaults)
- ⚪ **HBN AUDIT-ONLY** — Opus 4.7 sai da implementação; volta como auditor final (junto Antigravity Gemini 3.1)
- 🟡 **HBN CONTEXT FATIGUE INCOMING** (marker novo proposto) — IA sinaliza início de degradação iminente; handoff em preparação. Regra dos 50% oficializada operador 2026-05-04.
- 🟤 **HBN LICENSE SPLIT REQUIRED** — TPGL Credenciamento; M22/M23/M24/L28/L29 candidatas a promoção AGPLv3 quando MD-17.5 oficializar

## 15. Documentos relacionados

- [54 — Transição chat 4 → chat 5](54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md)
- [55 — Auditoria Antigravity](55_AUDITORIA_ANTIGRAVITY_2026_05_04.md)
- [56 — QA Codex](56_QA_CODEX_2026_05_04.md)
- [44 — DT-17-REATIV-STRIKES (spec Onda 18)](44_DEBITO_DT_17_REATIV_STRIKES.md)
- [50 — DT-MD17.1.e-STATUSBAR-HINT (adiado Bloco B)](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md)
- [Readback 0019 (Bloco A APROVADO)](../../.hbn/readbacks/0019-onda17-bloco-a.json)
- [ERP 0019](../../.hbn/results/0019-exec-onda17-bloco-a.json)
- [PHAGOCYTOSIS L1-L27 + M1-M19](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
- [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)

## Versão

- v1.0 — 2026-05-04 — Opus 4.7 chat 5 entrega síntese das 3
  auditorias, propõe handoff F1 → Codex CLI conforme decisão
  operador, formaliza Cadência D, prepara superprompt para Codex
  assumir Bloco B com auditoria cruzada final.
