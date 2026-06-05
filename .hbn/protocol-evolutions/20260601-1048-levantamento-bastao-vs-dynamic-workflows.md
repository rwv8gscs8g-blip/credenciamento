---
titulo: Levantamento — passagem/recepção de bastão do useHBN vs Dynamic Workflows (Claude Code, Opus 4.8)
diataxis: explanation
hbn-track: fast_track
hbn-status: consolidated
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
autoria: Claude Opus (Cowork, modo levantamento de protocolo) em consulta a Mauricio
gatilho: Mauricio pediu análise honesta do protocolo useHBN — em particular do sistema de passagem e recepção do bastão — comparado aos Dynamic Workflows do Claude Code, antes de rodar a próxima versão manual do PROMPT_ARQUITETO_USEHBN_AUTONOMO.md
status: consolidated
prioridade_sugerida: P1
consolidada-em: onda 0114 (2026-06-05) — 4 decisões de Mauricio no hearback 0145; ver auditoria/00_status/123
relaciona-se:
  - /Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md (v1.5, §12 Cadência D Estendida)
  - .hbn/knowledge/0017-handoff-aos-50-pct-contexto.md
  - .hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md
  - .hbn/protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md
  - .hbn/protocol-evolutions/20260527-1410-backlog-ponto-execucao-vs-comunicacao.md
  - .hbn/protocol-evolutions/20260527-2245-l45-cross-audit-output-lock-formalizacao.md
fonte-externa: https://claude.com/blog/introducing-dynamic-workflows-in-claude-code + https://code.claude.com/docs/en/workflows
restricao: NÃO aplica nada. Não toca código de domínio. É levantamento + estratégia + roadmap de ondas para hearback. Nenhuma onda é executada neste turno.
---

# Levantamento — bastão useHBN vs Dynamic Workflows

> **Aviso de escopo (§7.3 + pedido de Mauricio):** este documento é
> **levantamento e estratégia**, não implementação. Nenhuma regra é aplicada,
> nenhum schema é editado, nenhum guard é tocado, nenhuma onda é executada. A
> saída é uma proposta para hearback. O roadmap da §7 descreve ondas
> **sugeridas**, cada uma com seu próprio readback/hearback futuro.

---

## 0. Resumo executivo (a tese em 5 linhas)

O HBN e os Dynamic Workflows resolvem o **mesmo problema** — orquestrar trabalho
grande demais para uma só passagem de um só agente — com **filosofias opostas
sobre onde mora o controle**. O HBN põe o controle no **humano e em arquivos
auditáveis** (hearback antes de escrever, contratos versionados, multi-modelo);
o Dynamic Workflow põe o controle num **script automático com auto-verificação
adversarial** (fan-out de centenas de subagentes, sem humano no laço interno). A
recomendação **não** é trocar um pelo outro: é **manter a constituição do HBN**
(ponto de execução humano para escrita VBA `safe_track` e diversidade de modelos)
e **mecanizar a cerimônia** que hoje é feita à mão (roteamento de auditoria,
coleta de pareceres, consolidação, descarregamento de contexto) — exatamente as
partes onde o Workflow é superior e que **não** violam o ponto de execução
humano.

**Princípio-firewall proposto (a decisão central para hearback):**

> Workflows/orquestração automática podem ser usados em HBN **somente** para
> trabalho de **leitura / análise / auditoria / fan-out** (`fast_track`,
> doc-only). A **escrita `safe_track`** em VBA (`src/vba/`,
> `local-ai/vba_import/`) permanece **aplicada pelo humano**, hearback-gated,
> uma onda por vez — **nunca** dentro de um run autônomo. Isto preserva a razão
> de existir do protocolo e impede que a autonomia do Workflow erode o gate
> humano que protege um workbook que já corrompeu uma vez (V206).

---

## 1. O que é cada sistema (para o arquiteto sucessor que ler este arquivo a frio)

### 1.1 O bastão useHBN (como de fato funciona hoje)

Mecânica de coordenação inter-IA no Credenciamento, camada por camada:

- **Readback** (`.hbn/schemas/readback.schema.json`): contrato JSON que a IA
  emite **antes** de tocar arquivo — intent, scope (`files_allowed`/`forbidden`),
  ≥ 3 riscos com mitigação, gates de validação, rollback, `human_status`. Em
  `safe_track`, o pre-commit bloqueia se o readback faltar ou for violado.
- **Hearback** (`.hbn/schemas/hearback.schema.json`): confirmação **humana** de
  Mauricio (`status: confirmed`). Sem ela, nenhuma escrita `safe_track`.
- **ERP** (`.hbn/results/`): resultado de execução, o que de fato aconteceu.
- **Relay/INDEX.md**: o arquivo "quem tem o bastão" — estado, proprietário,
  próxima ação. Fonte única de verdade do ciclo (hoje com ~96 KB).
- **Handoff de fim-de-sessão** (`.hbn/knowledge/0014`, gatilho dos **50%** de
  contexto em `0017`): snapshot estruturado que o sucessor lê para retomar.
- **Cadência D Estendida** (§12 do PROMPT_ARQUITETO + `knowledge 0019`): 1
  implementador por onda + 2 auditores cruzados em **chat novo** + Mauricio
  (hearback/executor); severidade **BLOQUEADOR/FORTE/MARGINAL** + veto; checklist
  anti-viés de bastão; numeração de proposals.
- **Contratos executáveis** (Onda 36): schemas + guards de pre-commit
  (`assert-canonical-root`, `assert-scope-lock`, `assert-hearback`,
  `forbid-tmp-worktree`).
- **Auto-evolução** (§7.3): cada handoff produz um `.hbn/protocol-evolutions/…md`
  com micro-evoluções que o próximo arquiteto consome no pré-flight.
- **L45 output-lock** (`20260527-2245…`): auditoria cruzada reserva os caminhos
  de saída **antes** do disparo (um auditor, um path, política de colisão).
- **Sinais HBN**: ✅ ACTIVE, 🟡 NEEDS HUMAN DECISION, ❌ SECURITY BLOCKED,
  🔵 HANDOFF READY, 🔍 GROUPTHINK, 🪞 MIRROR DRIFT, 🟠 SOURCE DRIFT.

Características estruturais: **humano é o ponto de execução** (Mauricio importa o
V3, compila, salva/reabre, roda a TV2 e reporta); **coordenação vive em arquivos
git, assíncrona**; **serializado** (uma onda por vez); **auditoria cruzada
multi-modelo** é o mecanismo de qualidade; **cerimônia pesada por onda**, mas
**rastreável e enforçada por código**.

### 1.2 Dynamic Workflows (Claude Code, a partir de Opus 4.8 — research preview)

Fonte: blog de 2026-05-28 + `code.claude.com/docs/en/workflows`. Mecânica:

- O Claude **escreve um script de orquestração (JavaScript)** que um runtime
  executa **em segundo plano**, fora da conversa.
- **Fan-out de dezenas a centenas de subagentes** em paralelo (até 16
  concorrentes, teto de 1.000 por run).
- **Resultados intermediários ficam em variáveis do script**, não no contexto do
  Claude — o contexto guarda só a resposta final.
- **Auto-verificação adversarial**: agentes atacam o problema por ângulos
  independentes, outros agentes **tentam refutar** os achados, e o run **itera
  até convergir**.
- **Resumível** dentro da mesma sessão (progresso salvo).
- **Aprovação no lançamento** (mostra as fases planejadas), depois roda sozinho —
  **"sem input humano mid-run"**; para sign-off entre etapas, **cada etapa é um
  workflow próprio**.
- O plano é **código**: inspecionável, re-executável, salvável como comando
  (`/deep-research` é o workflow embutido).
- Casos de uso: varreduras de bug no repo inteiro, auditorias de segurança,
  migrações grandes (Bun Zig→Rust, ~750k linhas, 11 dias, centenas de agentes),
  planos estressados por vários ângulos.
- **Custa muito mais tokens** que uma sessão normal.

Características estruturais: **a máquina é a orquestradora** (o script segura o
laço, o branching e os resultados); **massivamente paralelo**; **auto-verificável
sem humano no laço**; **plano-como-código repetível**; **autônomo e longo**
(horas/dias); **mesma família de modelo** (todos os subagentes são Claude — a
diversidade vem de tentativas independentes + papéis adversariais, **não** de
pesos diferentes); **sem gate humano mid-run**.

---

## 2. Comparação estrutural

| Dimensão | Bastão useHBN | Dynamic Workflows |
|---|---|---|
| Quem segura o plano | Relay/INDEX + readbacks (arquivos) + modelo mental do humano; orquestração **manual**, IA propõe 1 onda | O **script** (código); orquestração **automática** |
| Quem decide o próximo passo | **Humano** (hearback gateia cada passo `safe_track`) | O **script**; humano só aprova no lançamento |
| Onde vivem os resultados intermediários | **Arquivos git** (readbacks, ERPs, proposals) — duráveis e auditáveis | **Variáveis do script** — efêmeras; durável = resposta final + estado do run |
| Paralelismo | Serial, 1 implementador/onda; cruzada = 2-3 auditores (disparo manual) | **10s-100s** de subagentes, automatizado |
| Verificação | Adversarial **multi-modelo**, hearback-gated, severidade + veto | Adversarial **mesmo-modelo**, convergência automática |
| Papel do humano | **Ponto de execução** + root of trust (roda Excel, hearback) | Aprova no lançamento; revisa o final |
| Diversidade de modelo | **Opus + Codex + Gemini/Antigravity** (pesos distintos) | Família única (Claude) |
| Auditabilidade | **Máxima** — cada contrato é arquivo versionado, enforçado por guard | Nível-run (script + progresso salvo); trilha granular não é o default |
| Recuperação de falha | Rollback por readback + âncoras estáveis; manual | Run **resumível** (resultados em cache) na mesma sessão |
| Cadência | 6h agendada ou manual; assíncrona (humano responde no dia seguinte) | Background contínuo, horas-dias |
| Custo | Baixo token (1 IA, 1 onda); **alto tempo humano/elapsed** | **Alto token**; baixo tempo humano |
| Domínio-alvo | VBA legado de alto risco, **humano aplica** no Excel, escrita errada corrompe | Codebase grande onde **o agente executa direto** (arquivos, shell) |

### 2.1 O insight central

Os dois sistemas divergem num único eixo: **onde mora o controle**.

- O HBN põe o controle **no humano e em arquivos duráveis**, ao custo de
  paralelismo e velocidade. Foi desenhado para um domínio onde **a IA não pode
  executar com segurança** (VBA num workbook vivo que já corrompeu — V206) e onde
  **uma escrita errada é catastrófica**. Por isso o humano é estruturalmente o
  ponto de execução, e cada escrita é um contrato hearback-gated.
- O Dynamic Workflow põe o controle **num script + auto-checagem adversarial**, ao
  custo de supervisão granular e diversidade de modelo. Foi desenhado para
  domínios onde **o agente pode executar direto** e onde o gargalo é **escala**
  (centenas de arquivos), não risco-de-escrita-catastrófica.

**Conclusão honesta:** o HBN **não deve virar** um Dynamic Workflow. O domínio
(VBA-no-Excel, aplicado-por-humano, regressão-catastrófica) torna o
ponto-de-execução-humano inegociável. Mas o HBN **pode tomar emprestada a
maquinaria** do Workflow onde ela não fere essa restrição — e há bastante.

---

## 3. Pontos fortes do HBN que NÃO se deve perder (resista ao brinquedo novo)

1. **Execução hearback-gated para domínio de escrita catastrófica.** O Workflow
   auto-aprova edições de arquivo e roda sozinho; para um workbook que já
   corrompeu, isso é exatamente o errado. O "hearback antes de escrever" do HBN é
   a postura de segurança correta aqui. **É a joia da coroa e o Workflow não tem
   equivalente.**
2. **Diversidade de MODELO.** Os agentes adversariais do Workflow são todos
   Claude (mesmos pesos). O HBN usa Opus + Codex + Gemini/Antigravity — modos de
   falha genuinamente independentes. O checklist anti-viés (P4) e a observação
   documentada de que "Codex, Antigravity e Opus, cada um, preservaram a própria
   relevância" são um nível de consciência de viés que o paralelismo
   mesmo-família **não consegue** replicar.
3. **Trilha de auditoria durável, versionada e enforçada por contrato.** Cada
   readback/hearback/ERP é arquivo, schema-validado, guard-enforçado no commit.
   Para um sistema de **credenciamento** (auditável por natureza), isso vale
   ouro. O estado de um run de Workflow é mais efêmero.
4. **O protocolo aprende (sedimentação).** §7.3 + knowledge files fazem cada
   fricção virar regra permanente. O Workflow é uma **ferramenta**, não um sistema
   de governança que se auto-endurece.
5. **Contratos executáveis (guards).** O pre-commit recusa mecanicamente commit
   fora de escopo / fora de raiz / sem hearback. É a contribuição genuinamente
   nova do HBN — governança enforçada por código, não por convenção.
6. **Desenhado para a realidade "humano-aplica".** L27 (comandos atômicos
   copiáveis) e L28 (entrega operacional minimalista) são adaptações ao fato de
   que **o humano é a mão**. O Workflow assume que o agente é a mão.

---

## 4. Fraquezas do HBN que o Dynamic Workflow expõe (a parte desconfortável)

1. **Serialização tem custo real de throughput.** "Uma onda por vez, um
   implementador" é seguro mas lento. O exemplo do Bun (750k linhas, 11 dias,
   centenas de agentes) mostra o que o paralelismo destrava. No HBN, o **único**
   ponto que paraleliza é a auditoria cruzada — e mesmo ela é disparada à mão.
2. **Overhead de orquestração manual.** Tudo que o Workflow automatiza (fan-out,
   coleta de resultados, reserva de caminhos, laço de convergência), o HBN faz à
   mão: o humano cola prompts em chats novos, reserva paths, junta proposals,
   consolida. **O L45 output-lock é literalmente o HBN reinventando, à mão e
   depois de um incidente, o roteamento de resultados que um runtime de workflow
   dá de graça.**
3. **Resultados intermediários incham o contexto.** O HBN lê tudo para dentro do
   contexto da IA (readback + ERP + proposals + 96 KB de relay). A regra dos
   **50%** (`knowledge 0017`) existe justamente porque a fadiga de contexto
   degrada a qualidade — o Workflow resolve isso **na arquitetura** (resultados em
   variáveis, fora do contexto). A resposta do HBN é **disciplina humana**; a do
   Workflow é **arquitetura**.
4. **O "ponto de execução" é gargalo E ponto único de falha.** Mauricio é root of
   trust, autoridade de hearback **e** executor operacional. Tudo bloqueia nele —
   o próprio `knowledge 0017` lista "aguardando hearback que não chega em janela
   útil" como gatilho de fim-de-sessão. O Workflow tira o humano do laço interno
   (aprova uma vez, depois autônomo).
5. **Sem laço de convergência/auto-refutação automático.** A auditoria
   adversarial do HBN é poderosa mas **episódica e disparada por humano**. O
   Workflow roda o refutar-até-convergir **automaticamente**. O HBN tem a
   **filosofia** (cruzada, GROUPTHINK, anti-viés) mas não a **maquinaria** para
   rodá-la em escala ou continuamente.
6. **Plano-como-prosa vs plano-como-código.** O "plano" do HBN está espalhado em
   relay/INDEX (96 KB), readbacks, knowledge e no PROMPT_ARQUITETO. É legível mas
   **não é executável/repetível como unidade**. O plano do Workflow é um script —
   re-rodável, inspecionável, salvável como comando. O análogo mais próximo do
   HBN (os guards) só **enforça restrição**, não **orquestra**.

> Conexão com o backlog já registrado: a §4 acima é exatamente a tensão do doc
> `20260527-1410-backlog-ponto-execucao-vs-comunicacao.md`. O Workflow é uma
> lente afiada sobre ela — "a coordenação acontece fora da conversa" é o que
> Mauricio intuiu ao separar **ponto de execução** de **ponto de comunicação**.

---

## 5. Onde explicitamente NÃO imitar (o firewall)

1. **Escrita `safe_track` em VBA permanece humano-aplicada.** Jamais dentro de um
   run autônomo. O Workflow auto-aprova edição de arquivo; isso é incompatível
   com a razão de existir do HBN. (É o princípio-firewall da §0.)
2. **Não sacrificar diversidade de modelo por paralelismo de família única.** Um
   workflow de auditoria roda subagentes Claude (mesmos pesos). Útil para a
   parte Claude da cruzada, mas **não substitui** Codex/Gemini como olhares de
   pesos distintos. Adotar workflow na auditoria **não pode** virar desculpa para
   abandonar a auditoria multi-modelo.
3. **Não adicionar cerimônia.** O HBN já carrega muito ritual (96 KB de relay,
   ~21 knowledge files, múltiplos esquemas de numeração, o próprio incidente L45
   sendo "processo sobre processo"). O `MINIMALISM-PRINCIPLE` do projeto vale aqui:
   **automação só se justifica se REDUZIR a cerimônia líquida.** A meta é
   **substituir** orquestração manual por automática, não empilhar uma sobre a
   outra.
4. **Não ligar `ultracode`/workflow autônomo como default.** Custa muito mais
   token e roda sozinho. Para um delta VBA de 1-2 arquivos é overkill e risco. O
   default permanece a cadência manual; o workflow é a exceção justificada por
   escala.

---

## 6. Estratégia de melhoria (a síntese em 3 camadas)

A estratégia não é "substituir HBN" nem "tornar HBN autônomo". É **separar o que
é decisão (humano) do que é coordenação (mecanizável)** e mover só a segunda para
maquinaria estilo-Workflow:

- **Camada 1 — Constituição (intocável).** Ponto de execução humano para escrita
  `safe_track`; hearback-antes-de-escrever; auditoria multi-modelo; contratos
  duráveis enforçados por guard. Nada disso muda.
- **Camada 2 — Mecanizar a cerimônia.** As partes que são **pura coordenação**
  (reserva de paths L45, disparo de auditoria, coleta de proposals, consolidação,
  atualização de relay, descarregamento de contexto no pré-flight) são exatamente
  o que um script de workflow faz de graça. É aqui que as lições do Workflow se
  aplicam **diretamente** e onde a §4 dói hoje.
- **Camada 3 — Tomar os padrões, não necessariamente o produto.** Mesmo que
  Mauricio não adote o recurso literal "Dynamic Workflows", os **padrões**
  (plano-como-código; resultados-fora-do-contexto; laço adversarial-até-convergir;
  estado-de-run-resumível; fan-out-com-verificação) podem ser **codificados nas
  próprias convenções do HBN** e no PROMPT_ARQUITETO.

### 6.1 Convergência tranquilizadora (HBN já está parcialmente certo)

A doc do Workflow diz: *"sem input humano mid-run — para sign-off entre etapas,
rode cada etapa como seu próprio workflow."* Isso **valida** a granularidade de
onda do HBN: cada onda HBN **é** uma etapa que precisa de sign-off (hearback).
Logo **uma onda = um workflow, com o hearback ENTRE workflows.** As fronteiras de
onda do HBN caem exatamente onde o Workflow manda dividir. A arquitetura não está
errada — falta-lhe só a maquinaria dentro de cada etapa.

---

## 7. Roadmap de ondas HBN sugeridas (estratégia → ondas atômicas)

> Cada item é uma **onda HBN inteira** com readback/hearback próprios (§3 do
> PROMPT_ARQUITETO). Todas `fast_track` (protocolo/doc, nunca código VBA).
> Sequenciadas por dependência e risco. **Nenhuma é executada aqui.** Convenção de
> ID provisória `EW-n` (Evolução-Workflow) até o arquiteto atribuir numeração.

| Onda | Tema | Track | Depende de | Entrega (sem texto final — só o quê) |
|---|---|---|---|---|
| **EW-1** | Decisão de princípio: o firewall da §0 | fast_track | — | Hearback do firewall + registro em `knowledge` novo (escrita/`safe_track` nunca em run autônomo) |
| **EW-2** | Mapear a cadência atual como "plano-como-código" | fast_track | EW-1 | `usehbn/methodology/ORCHESTRATION-AS-CODE.md` + esqueleto de §13 no PROMPT_ARQUITETO (descrever o laço onda como orquestração inspecionável, **sem** automatizar ainda) |
| **EW-3** | Piloto: auditoria cruzada via workflow (Claude-only) | fast_track (experimental) | EW-2 | Rodar 1 gate real de cruzada como workflow estilo `/deep-research`; medir se elimina a colisão L45 e se **não perde** achado BLOQUEADOR/FORTE vs cruzada manual (metodologia P9 já existente). Cruzada multi-modelo segue em paralelo como controle |
| **EW-4** | `audit-request.schema.json` + guard L45 executável | fast_track | EW-3 | Schema do bloco de audit-request + guard que recusa proposal de auditoria sem path reservado. Endurece o caminho manual **e** vira a interface que um workflow futuro mira (já recomendado na §6 do doc L45) |
| **EW-5** | Descarregamento de contexto no pré-flight do arquiteto | fast_track | EW-2 | Padrão "destilar estado em subagente/Task, devolver resumo enxuto" para a leitura dos 96 KB de relay + N readbacks. Ataca a fadiga que o `0017` gerencia por disciplina |
| **EW-6** | §13 do PROMPT_ARQUITETO: "Quando usar workflow vs cadência manual" | fast_track | EW-3, EW-5 | Regra de decisão explícita (delta pequeno = manual; fan-out grande = workflow; escrita `safe_track` VBA = nunca workflow). Consolida lições EW-1..EW-5 em doutrina |
| **EW-7** | Métricas de orquestração (recorrente) | fast_track | EW-3 | Registrar por onda: elapsed, nº de idas-e-voltas de hearback, nº de colisões, % de contexto no handoff, achados de auditoria pegos. Decide "automação vale a pena?" com **dado**, não opinião |

Itens de backlog já existentes que este roadmap absorve/conecta:

- `20260527-1410-backlog-ponto-execucao-vs-comunicacao.md` → EW-2/EW-6 (a
  fronteira execução×comunicação vira parte do plano-como-código).
- §6 do `20260527-2245-l45-cross-audit-output-lock-formalizacao.md` (incorporação
  da L45 em schema/guard) → EW-4.
- P9 (auditoria curta, em teste) → metodologia reusada em EW-3.

### 7.1 Caminho mínimo (se Mauricio quiser só o maior ganho com menor risco)

Se a banda for estreita: **EW-1 → EW-3 → EW-4**. EW-1 fixa a segurança; EW-3
prova (ou refuta) empiricamente o ganho no único ponto já paralelo do HBN (a
auditoria); EW-4 entrega valor durável (L45 executável) **independentemente** de
o piloto de workflow ser adotado. As demais (EW-2, EW-5, EW-6, EW-7) são
sedimentação posterior.

---

## 8. Riscos da própria adoção + mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| Autonomia do workflow erode o gate humano (auto-aprova edição) | BLOQUEADOR | Firewall da §0: workflow só em `fast_track` leitura/análise/auditoria; escrita `safe_track` VBA nunca em run autônomo. Registrar como knowledge antes de qualquer piloto (EW-1) |
| Perda de diversidade multi-modelo se a cruzada virar "só workflow Claude" | FORTE | Workflow cobre os auditores Claude; Codex/Gemini seguem manuais. EW-3 mantém a cruzada multi-modelo como controle |
| Automação **adiciona** cerimônia em vez de substituir | FORTE | `MINIMALISM-PRINCIPLE` como gate de aceitação: cada EW só promove se reduzir overhead humano líquido (medido em EW-7) |
| Custo de token alto para deltas pequenos | FORTE | Regra EW-6: workflow só para fan-out grande; delta de 1-2 arquivos permanece manual |
| Dependência de feature em research preview (Dynamic Workflows pode mudar) | MARGINAL | Camada 3: codificar os **padrões** nas convenções HBN, que sobrevivem mesmo se o produto mudar; o piloto EW-3 é descartável por desenho |
| Piloto de workflow toca código de domínio por engano | BLOQUEADOR | EW-3 é doc/auditoria-only; o alvo do workflow é **ler e auditar**, nunca escrever VBA; guards de scope continuam ativos |

---

## 9. Métricas para decidir com dado (não opinião)

Coerente com o ethos empírico do protocolo (critério objetivo da P9). Antes/depois
de cada EW, medir:

- **Idas-e-voltas de hearback por onda** (proxy do gargalo humano).
- **% de contexto consumido no handoff** (proxy de fadiga; meta ≤ 50%, `0017`).
- **Nº de colisões/improvisos de roteamento** (a classe de erro do L45; meta: 0).
- **Achados BLOQUEADOR/FORTE pegos por modo** (cruzada manual vs workflow vs
  ambos) — para provar que automação não baixa o rigor.
- **Elapsed por onda** (manual vs com mecanização).

Critério de promoção (estilo P9): uma EW só vira regra vigente se **reduzir
overhead humano sem perder nenhum achado BLOQUEADOR/FORTE** em ≥ 2 ondas reais.

---

## 10. Não-propostas (registradas, mas que NÃO viram regra)

- **Tornar o arquiteto autônomo via `ultracode`.** Rejeitado: viola o firewall e
  o "Mauricio é o controlador; a scheduled task é só marca-passo" (§5 do
  PROMPT_ARQUITETO).
- **Migrar a auditoria multi-modelo inteira para workflow Claude.** Rejeitado:
  perde diversidade de pesos (§3.2, §5.2).
- **Substituir os guards de pre-commit por orquestração de workflow.** Rejeitado:
  guards são a camada de **enforcement**, ortogonal à de **orquestração**; os dois
  coexistem.
- **Reescrever o PROMPT_ARQUITETO inteiro numa nova versão "workflow-native".**
  Rejeitado por violar o princípio micro-evolutivo (§7.3): a evolução é por
  sedimentação atômica (EW-1..EW-7), não por big-bang.

---

## 11. Perguntas abertas para o hearback de Mauricio

1. **Firewall (§0):** confirma o princípio de que orquestração automática/workflow
   é permitida **só** em `fast_track` leitura/análise/auditoria, e que escrita
   `safe_track` VBA permanece humano-aplicada e hearback-gated? Esta é a decisão
   que destrava (ou não) todo o resto.
2. **Profundidade do roadmap:** topa o caminho mínimo **EW-1 → EW-3 → EW-4**
   (§7.1), ou quer o roadmap completo EW-1..EW-7 priorizado no backlog do §4 do
   PROMPT_ARQUITETO?
3. **Piloto empírico (EW-3):** autoriza um piloto **descartável** de auditoria
   cruzada via workflow Claude-only num gate real, mantendo a cruzada multi-modelo
   em paralelo como controle — medido pelo critério P9 (zero achado
   BLOQUEADOR/FORTE perdido)?
4. **Onde versionar a doutrina nova:** a §13 do PROMPT_ARQUITETO (transversal) +
   knowledge no Credenciamento, como manda a §1 do `20260527-1300…`? Ou prefere
   segurar a doutrina até o piloto EW-3 dar dado?

---

## 12. Sinal HBN

🔵 HBN HANDOFF READY — levantamento completo, comparação e roadmap de ondas
prontos para hearback. **Nada aplicado.** Aguardando decisão de Mauricio nas 4
perguntas da §11 antes de qualquer onda EW-n entrar no backlog do §4 do
PROMPT_ARQUITETO_USEHBN_AUTONOMO.md.

🔍 GROUPTHINK CHECK — este documento **discorda** parcialmente do impulso de
adotar a novidade: recomenda preservar a constituição do HBN (ponto de execução
humano + multi-modelo) e tratar o Workflow como fonte de **padrões de
mecanização**, não como substituto. Se o arquiteto sucessor concordar com tudo
sem atrito, releia a §3 (o que NÃO perder) antes de promover qualquer EW.

---

## 13. Consolidação (onda 0114, 2026-06-05)

**CONSOLIDADA** por decisão de Mauricio (hearback 0145). Respostas às 4
perguntas da §11:

1. **Firewall (§0): CONFIRMADO como princípio permanente.** Workflow/orquestração
   automática só em `fast_track` leitura/análise/auditoria; escrita `safe_track`
   VBA permanece humano-aplicada e hearback-gated. Formalização como knowledge
   0022 = item **G1** do backlog §4 do PROMPT v1.6.
2. **Profundidade: caminho mínimo EW-1 → EW-3 → EW-4** (§7.1). EW-2/5/6/7 ficam
   como sedimentação posterior (não entram no §4 agora).
3. **Piloto EW-3: AUTORIZADO** — descartável, Claude-only, cruzada multi-modelo
   em paralelo como controle, critério P9 (zero BLOQUEADOR/FORTE perdido).
   Item **G2** do backlog.
4. **Versionamento da doutrina**: PROMPT_ARQUITETO (Trilha G) + knowledge no
   Credenciamento, conforme §1 do `20260527-1300…` (default mantido).

EW-4 = item **G3**. Registro completo: `auditoria/00_status/123`.
