---
titulo: Auditoria-árbitro GATE-A4 / L43 — triagem de freeze V12.0.0206 vs refatoramento V12.0.0207
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
papel-autor: Claude Opus3-4-MAX — auditor-árbitro de qualidade e priorização (Cadência D Estendida §12.B2, chat novo)
escopo: confrontar L43 × código `35217c0+ONDA38.2.3-A4-F2-FORMS` × RVS `VR_20260529_223908`; arbitrar divergências entre 0022 (Opus) e 0023 (Antigravity)
output_path: .hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md
predecessor: 0022 (Opus) + 0023 (Antigravity) + L43 PDF (676 linhas) + RVS final pós-uso + verificação direta de código
---

# 0024 — Auditoria-árbitro GATE-A4 / L43 V12.0.0206

> **Recado curto ao Codex e ao Mauricio.** Confirmo o veredito das duas auditoras-irmãs: **BLOQUEAR o freeze da V12.0.0206**. O RVS `VR_20260529_223908` (336 OK / 0 falha / 5 manuais) está APROVADO e continua válido como evidência de que o *motor* (Repo/Svc/idempotência/strikes E2E) é sólido — mas é **estruturalmente cego** ao que o L43 expôs. Minha contribuição como terceiro auditor não é repetir 0022/0023: é que **reli o código-fonte e arbitrei onde elas divergem**. Resultado objetivo: as duas convergem no veredito mas **divergem em causa-raiz na maioria dos achados graves**, e em três pontos **0022 errou o diagnóstico** enquanto **0023 acertou o mecanismo** — e em um ponto é o inverso. O "mistério" central de 0022 (base populada colapsa, base zerada funciona) **não é um bug isolado**: dissolve-se em dois defeitos verificados (`xlGuess` na ordenação + inativação não-atômica). Há **7 BLOQUEADORES**, **11 FORTES** e **9 MARGINAIS**. A versão **não é segura para produção** no estado atual.

---

## 1. Inputs auditados

| Input | Identificador | Estado |
|---|---|---|
| Código-alvo | `35217c0+ONDA38.2.3-A4-F2-FORMS` | importado, compilado |
| RVS sexteto pós-uso | `VR_20260529_223908` — V1=171/0 · V2_Smoke=34/0/4M · V2_Canônico=24/0 · E2E_Strikes=76/0 · IntegridadeBase=4/0/1M · Onda23Adv=27/0 | **APROVADO** (0 falha; 5 manuais) |
| Relatório humano | `Primeiro GATE-USO-PROLONGADO L43.pdf` (676 linhas extraídas) | ~30 (BUG) + 8 homologados + restrições |
| Doutrina de severidade | `.hbn/knowledge/0019` §5 (BLOQUEADOR/FORTE/MARGINAL + veto) | aplicada |
| Auditoras-irmãs | `0022-opus` (consolidador) + `0023-antigravity` (sistêmico) | **arbitradas** abaixo |
| Governança | `AGENTS.md`, `.hbn/relay/INDEX.md` (bastão = Codex, GATE-A4 aberto, 🟡 NEEDS HUMAN DECISION) | lida |

**Método (não-delegação de entendimento — CLAUDE.md L6).** Não confiei na evidência textual de nenhuma das duas auditoras. Reabri `src/vba/` e verifiquei cada claim falsificável diretamente (números de linha no Anexo §13). Onde a evidência de uma auditora era metodologicamente frágil, refiz o teste — caso do `.frx`, abaixo.

**Não-objetivos desta proposta.** (i) Não reescrevo o roadmap V207 (Alternativa II-bis confirmada permanece); (ii) não escrevo microdeltas de código (papel do Codex); (iii) não substituo a homologação do Mauricio; (iv) não edito código — auditoria pura.

---

## 2. Arbitragem das divergências 0022 × 0023 (o núcleo desta proposta)

As duas auditoras chegaram ao mesmo veredito por caminhos diferentes. Onde divergem, decidi por leitura de código. Tabela de arbitragem:

| Tema L43 | 0022 (Opus) disse | 0023 (Antigravity) disse | **Árbitro (0024) — verificado** |
|---|---|---|---|
| **Fila/ordenação** §3.3 | F2 FORTE: "regressão de designer da Onda 38.2.1" (especulativo) | BLOQUEADOR 2.3: `.Header = xlGuess` em `Classificar.bas` | **0023 CORRETO.** `Classificar.bas:18` (ClassificaEntidade) e `:248` (ClassificaServico) são os **únicos dois** sorts com `xlGuess`; todos os outros 9 usam `xlNo`. Defeito assimétrico, concreto, data-dependente. **0022 não viu a causa-raiz.** → **BL-2.** |
| **Base populada colapsa / zerada funciona** §3 (concl) | B2 BLOQUEADOR: hipótese de **dupla submissão** por falta de feedback | (sem equivalente direto; tratou via 2.2) | **Nenhuma das duas.** Não é bug isolado nem dupla submissão. É **emergente de BL-2 + BL-3**: `xlGuess` reordena com dados reais → índices de linha calculados ficam obsoletos → cópia/exclusão atinge linha errada. `xlGuess` é por natureza data-dependente, o que **explica exatamente** "zerada funciona, populada colapsa". Dissolve o mistério. |
| **ATIVA+INATIVA simultâneo** §3.4 | B3 BLOQUEADOR: "duplicação ou cache" (vago) | BLOQUEADOR 2.2: inativação copia p/ INATIVOS antes de excluir da ativa, sem rollback | **0023 CORRETO no mecanismo** (refino: o código *checa* o retorno de `Util_ExcluirLinhaSegura`; o que falta é **rollback/atomicidade**, não a checagem). `Altera_Entidade.frm:197-207`. → **BL-3.** |
| **Impressão nota > 10** §7.1 | B5 BLOQUEADOR: clamp existe na persistência, falta no caminho de impressão | 2.x: bug de **formatação** `"##,#"` mostrando "98,0 em vez de 9.8"; fix em `Repo_Avaliacao.Inserir` | **0022 CORRETO** no mecanismo **e no local do fix.** `SvcAvaliacao_NotaSegura` (clamp) é `Private` e só roda na persistência (`Svc_Avaliacao.bas:153`); a impressão grava `AvN01..AvN10` **brutos** (`Preencher.bas:3260-3269`). **0023 errou o sintoma** ("98,0" não se sustenta — notas são inteiras 0-10) **e propôs o fix no lugar errado** (`Repo_Avaliacao.Inserir` não toca o caminho de impressão). Ressalva válida de 0023: `"##,#"` é formato suspeito — corrigir junto. → **BL-5.** |
| **Local não aparece na OS** §6.4 | F12 FORTE: "célula não preenchida em Preencher" (vago) | BLOQUEADOR 2.4: `END_ENTIDADE` omitido no loop + Pré-OS recebe ID composto | **0023 CORRETO e preciso.** São **dois** defeitos distintos: (a) `BE_ImprimeOS_Click` (`Menu_Principal.frm:461-468`) carrega `cont/telcont` mas **omite `END_ENTIDADE`**; (b) `GarantirDadosPreOSParaImpressao(N_OS)` recebe `"PROVISÓRIA - 003"` e busca por ID numérico → falha silenciosa → `Exit Sub`. → **BL-6 + BL-7.** |
| **Lentidão cadastro 24s** §3.11 | B6 BLOQUEADOR: falta envelopamento + ProgressBar tardia | FORTE 3.2: busy-wait `timedelay` + `ThisWorkbook.Save` síncrono embutido a 90% | **0023 CORRETO no mecanismo.** `ProgressBar.frm:87-99` é busy-wait de CPU; `:70` faz `Save` redundante dentro do loop de render. **Rebaixo de BLOQUEADOR para FORTE**: não é a causa-raiz da corrupção (essa é BL-2+BL-3). Mas o `Save` embutido é **risco de integridade** (force-quit a 90% corrompe `.xlsm`) → FORTE de alta prioridade. → **FT-3.** |
| **GitHub trava 1-2 min** §1.2 | M1 MARGINAL: "externo ao código" | FORTE 3.4: `FollowHyperlink` antes do `Shell open` no Mac | **0023 CORRETO; 0022 errou ao chamar "externo".** `AbrirURLExterna` (`Menu_Principal.frm:3510-3533`) tenta `Application.FollowHyperlink` e `ThisWorkbook.FollowHyperlink` **antes** do fallback `Shell "open"`. É **code-internal e fix trivial.** Mantenho MARGINAL **por impacto** (botão informativo), mas é quick-win de 2 linhas → bundle. → **MG-1.** |
| **Campos de strikes sumiram** §1.4.4+§2 | B1 BLOQUEADOR: `strings .frx \| grep strike` = vazio | 2.1 BLOQUEADOR: `.frx` sobrescrito por versão legada | **Ambas CORRETAS na conclusão**, mas a evidência de 0022 era frágil (controles vivem no `OleObjectBlob` do `.frx`, não como ASCII trivial). **Refiz o teste e confirmei o método**: `strings` *sí* recupera nomes de controle (vê `TextBox16`, `CR_*` nos forms-irmãos). Em `Configuracao_Inicial.frx` o inventário é **só** `CommandButton1` + `Label41/42/43/45/46` — **nenhum TextBox**. → **BL-1, com agravante** (degradação mais ampla que ambas relataram). |

**Síntese de credibilidade.** Em achado-a-achado de causa-raiz: **0023 foi mais preciso** (4 de 5 mecanismos graves corretos e acionáveis); **0022 foi mais forte na moldura e nos critérios de freeze** (achado #0, separação "parar de mentir" vs "ir mais rápido", critérios C1-C6) **mas errou 3 diagnósticos** (fila, impressão-fix, GitHub) e deixou o mistério da base como especulação. Esta proposta **mantém a moldura de 0022 e os mecanismos de 0023.**

---

## 3. Classificação reconciliada (grade `.hbn/knowledge/0019` §5)

Natureza (pergunta 4 do prompt): **B**=regra de negócio · **U**=estado de UI · **P**=proteção · **S**=persistência · **I**=impressão · **T**=teste insuficiente · **X**=cross-cutting.

### 3.1 BLOQUEADORES (7) — vetam o freeze V206

| # | L43 | Sintoma | Nat. | Causa-raiz **verificada** | Fonte |
|---|---|---|---|---|---|
| **BL-1** | §1.4.4, §2 | Campos `TxtNotaCorte/TxtMaxStrikes/TxtDiasSuspensao` ausentes da UI Configurações | U+S+T | `.frx` contém só 6 Labels + 1 CommandButton — **zero TextBox**; código lê via `Me.Controls(...)` sob `On Error Resume Next` que **mascara** o erro. **Agravante:** degradação pode ser mais ampla que strikes (forma-fonte sem nenhum campo de entrada) — investigar se afeta área gestora/município/prazo e se `.frx`-fonte diverge do workbook (violação da Regra de Ouro 0002). | 0022+0023; refinado |
| **BL-2** | §3.3, §3, §8.1 | Entidades/serviços fora de ordem; base populada "colapsa" | B+U+T | `Classificar.bas:18` e `:248` usam `.Header = xlGuess` (únicos; resto usa `xlNo`). Excel "adivinha" linha 2 como cabeçalho e a fixa no topo. **Data-dependente** → causa-raiz do mistério "zerada OK / populada colapsa". | **0023; 0022 errou** |
| **BL-3** | §3.4, §3.8-3.10 | Entidade ATIVA e INATIVA ao mesmo tempo; reativação bloqueada | B+S | `Altera_Entidade.frm`: copia linha p/ INATIVOS (`:198`) **antes** de excluir da ativa (`:204`); handler de erro (`:213-219`) restaura proteção mas **não faz rollback** da cópia. Operação **não-atômica**. | **0023; 0022 vago** |
| **BL-4** | §3.15, §5.2 | Proteção das células não funciona; edição manual indevida possível | P+S | `ProtegerAbasCriticas` cobre as abas certas mas usa `UserInterfaceOnly:=True`, que **não persiste** no save/reopen, e depende de `Auto_Open` disparar. Contagem prepare/restore (121/196) **não indica leak** → **nem 0022 (restore esquecido) nem 0023 (só inativação) acertaram a raiz.** Raiz provável: dependência de `Auto_Open` + não-persistência de `UserInterfaceOnly`. | refinado por 0024 |
| **BL-5** | §7.1 | Impressão de avaliação não aplica clamp ≥10 | B+I | clamp `If numero > 10 Then numero = 10` é `Private` em `SvcAvaliacao_NotaSegura`, só usado na persistência (`:153`). Impressão grava `AvN01..AvN10` brutos (`Preencher.bas:3260-3269`) com `Format("##,#")`. Regra implementada em um caminho só. | **0022 (mecanismo+fix); 0023 (formato)** |
| **BL-6** | §6.4 | "Local para prestação de serviço" em branco na OS impressa | I+B | `BE_ImprimeOS_Click` (`Menu_Principal.frm:461-468`) carrega `cont_entidade`/`telcont_entidade` mas **omite `END_ENTIDADE`**; `Preencher` grava `F18 = END_ENTIDADE` (vazio). | **0023** |
| **BL-7** | §6.4 (Pré-OS) | Dados do demandante/local em branco na Pré-OS impressa | I+B | `N_OS = "PROVISÓRIA - " & res.IdGerado` (`Menu_Principal.frm:1920`) passado a `GarantirDadosPreOSParaImpressao`, que só faz `preId = Trim$(CStr(preosId))` (`Preencher.bas:1598`) — sem remover prefixo → `IdsIguais("003","PROVISÓRIA - 003")` falha → `If linhaPre = 0 Then Exit Sub`. | **0023** |

> **Desafio de prioridade (para Mauricio decidir).** **BL-1** bloqueia por quê? O *motor* de strikes funciona (E2E 76/0). O que sumiu é a **UI de configuração**. Existe uma triagem pragmática: congelar V206 com strikes em defaults seguros + **procedimento manual documentado** (editar célula `CONFIG` direto) e adiar a reconstrução do designer para V207. **Risco dessa via:** o §5.1 já mostra o operador confuso ("não consigo verificar nem alterar strikes"); sem UI, o gestor público não se autoatende e perde auditabilidade. **Minha recomendação:** manter BL-1 como BLOQUEADOR — mas registro a alternativa porque a decisão é do operador, não do auditor.

> **Desafio de prioridade — BL-6/BL-7.** São conteúdo faltando em **documento oficial público** (OS/Pré-OS entregue a fornecedor). Classifiquei BLOQUEADOR pelo princípio "parar de mentir no papel" (uma OS sem local de execução é falha operacional real, não cosmética). Se o local for comunicado por outro meio na prática, Mauricio pode rebaixar a FORTE. Decisão dele; minha leitura é BLOQUEADOR.

### 3.2 FORTES (11) — incorporar no V206 ou justificar por escrito

| # | L43 | Sintoma | Nat. | Causa-raiz verificada/provável | Fonte |
|---|---|---|---|---|---|
| FT-1 | §3.1, §3.12, §4.7 | Seleção na lista principal mostra dados incompletos; completos só no form de edição | U+S | `C_Lista_Click` (`Menu_Principal.frm:1458`) popula subconjunto dos campos; o form de edição lê tudo. Falta paridade. | 0022 F1 / 0023 3.1 |
| FT-2 | §3.6, §4.3 | Form não limpa para novo cadastro | U | Não existe `LimparCamposCadastroEntidade`; `LimparCamposCadastroEmpresa` (`:2339`) só é chamada **pós**-cadastro, não na entrada. | 0022 F3 / 0023 4.1 |
| FT-3 | §3.11, §3 | Cadastro 24s, barra "enrosca", sem feedback | U+T+**S(risco)** | `ProgressBar.frm`: busy-wait `timedelay` (`:87-99`) + `ThisWorkbook.Save` embutido a 90% (`:70`). O Save embutido é **risco de corrupção** se houver force-quit. | **0023 3.2** |
| FT-4 | §4.4 | Credenciamento 10s | U+T | `CR_Credenciar_Click` chama `ProximoId(SHEET_CREDENCIADOS)` **dentro** do loop; `ProximoId` desprotege/reprotege + `Util_MaxIdOperacional` (scan completo) **a cada iteração** → O(n²). | **0023 3.3** |
| FT-5 | §5.1, §5.3 | Empresa com strikes some de "disponíveis" mas relatório a mostra disponível; nome/telefone não aparecem na seleção do rodízio | B+U | descasamento `Svc_Rodizio` (suspende por strike) × relatório (não checa suspensão); handler de seleção do rodízio não popula visualização. Conecta com BL-1 (gestor não vê o nº de strikes). | 0022 F9/F10 |
| FT-6 | §6.1 | Filtros não funcionam em "Imprime Solicitação de Serviços" | U | painel PreOS/Emite OS ficou fora do wire-up de filtros estáticos da Onda 38.2.2 AT-4. | 0022 F11 |
| FT-7 | §6.5 | Empenho não aparece corretamente na OS | I | mesmo cluster de impressão de BL-6 (célula não preenchida no caminho OS). | 0022 F13 |
| FT-8 | §4.1, §4.6 | Não exibe código/ID da empresa antes do CNPJ nem do credenciamento | U+B | backend já normaliza ID 3 dígitos (Onda 38.2.3); frontend não exibe a coluna. | 0022 F5 |
| FT-9 | §4.2 | Tempo de experiência não editável | U+B | provável control readonly por engano no designer — auditar `Credencia_Empresa`/`Altera_Empresa`. | 0022 F6 |
| FT-10 | §3.7, §4.5 | Sobreposição de imagens/componentes (botões entidade; busca credenciamento) | U | regressão de designer `.frx` (mesma classe de BL-1); filtro dinâmico via `Controls.Add` sobrepõe layout. | 0022 F4/F8 / 0023 4.2 |
| FT-11 | §1.4.4 | Persistência de parâmetros regride após "atualização via janela imediata" | S+T | suspeita de macro de manutenção/`ImportarPacoteV3` reaplicando defaults da CONFIG. Exige roteiro de regressão. | 0022 F15 |

### 3.3 MARGINAIS (9) — aceitáveis no V206; melhoram no V207

| # | L43 | Sintoma | Nat. | Nota |
|---|---|---|---|---|
| MG-1 | §1.2 | GitHub trava 1-2 min | U | **code-internal** (não "externo" como disse 0022); fix de 2 linhas — bundle como quick-win na onda de performance. |
| MG-2 | §1.4.1 | Submenu "Ajuda" sem ação | U | já planejado (FAQ HBN pós-V206). |
| MG-3 | §6.2 | Máscara cinza em nome/endereço na OS impressa | I | cosmético de impressão. |
| MG-4 | §6.3 | Borda extra fora do formulário OS | I | cosmético de impressão. |
| MG-5 | §8.1 | Rolagem horizontal em Cadastro de Serviço | U | ajuste de layout. |
| MG-6 | §9.1 | Descrição truncada nos botões de Relatórios | U | ajuste de caption/largura. |
| MG-7 | §9.2 | Padronização visual dos relatórios (cores/sombras/bordas) | U | trabalho de template V207.2; exige aprovação visual do operador. |
| MG-8 | §1.1 (obs) | Versionamento difícil de interpretar | U | observação evolutiva (Sobre) — V207+. |
| MG-9 | §3.7 (obs) | Espaçamento dos botões para "visualização plena" | U | refino de layout junto com FT-10. |

### 3.4 Homologados pelo L43 (não-ação para Codex)

Botão Sobre (§1.1) · Central de Testes (§1.3) · Configurações Iniciais raiz (§1.4) · Iniciar Novo Período (§1.4.2) · Limpar Base (§1.4.3) · Filtros em Entidades/Inabilitados (§3.5) · Filtros em Indica Empresa (§5.4) · Inativação/Reativação na bateria com base zerada (§3.13).

---

## 4. Achado #0 (cobertura de teste) — refinado e corrigido

0022 elevou a "cobertura RVS cega" a achado arquitetural #0. **Concordo com o veredito, mas a formulação precisa de correção factual** que muda a recomendação:

**Correção.** 0022 afirmou "não há assert de invariante `ATIVA XOR INATIVA`". **Falso:** existe `TV2_DetectarEntidadeDuplicadaAtivaInativa` (e a versão Empresa) em `Teste_V2_Roteiros.bas`. O assert **existe e passou** no RVS. Logo o problema **não é ausência de invariante** — é que **nenhum roteiro dirige o *fluxo de UI* que produz a violação** (inativação com falha de proteção / reordenação por `xlGuess`). O teste valida o invariante sobre **base semeada limpa**; o defeito nasce no **caminho de erro** e em **dados herdados**.

**Lacunas reais de cobertura (verificadas):**

1. **Path-coverage, não invariant-coverage** — falta roteiro que *exercite* inativação UI com falha de exclusão forçada e verifique não-duplicação (cobre BL-3).
2. **Ordenação pós-sort com base populada** — nenhum assert de ordem após `ClassificaEntidade`/`ClassificaServico` com dados reais (cobre BL-2; `xlGuess` passa invisível em base pequena).
3. **Persistência de painel Config** — nenhum roteiro abre `Configuracao_Inicial`, lê `.Controls("TxtMaxStrikes")`, e **falha se o controle não existir** (cobre BL-1; o `On Error Resume Next` mascara hoje).
4. **Integridade de impressão** — nenhum roteiro compara células `IMP_*`/`EMITE_*` contra a regra (clamp, `END_ENTIDADE`, empenho) **antes** do `PrintOut` (cobre BL-5/BL-6/BL-7).
5. **Proteção close/reopen** — nenhum roteiro fecha/reabre e afirma `ProtectContents = True` por aba sensível (cobre BL-4).
6. **Cycle-time perceptível** — nenhum assert `tempo < N s` (cobre FT-3/FT-4).

**Meta-lacuna (o achado #0 real, melhor enunciado).** O RVS roda sobre **dados puros/descartáveis**; o L43 colapsou sobre **base herdada suja**. A falha é **data-dependente** (`xlGuess`) e **path-dependente** (handlers de erro). Enquanto a bateria não tiver um **corpus de regressão com base suja herdada**, regressões de UI-com-dados-reais reincidirão invisíveis. **Severidade: BLOQUEADOR estrutural.** Veto o uso isolado de `VR_20260529_223908` como evidência única de freeze.

---

## 5. Segurança para produção — veredito

**NÃO é seguro para produção** no estado atual. Justificativa objetiva, independente de cosmética:

- **BL-2 + BL-3** produzem **corrupção de estado de domínio** sobre base real: uma entidade pode aparecer simultaneamente ativa e inativa, e a fila de rodízio pode ser embaralhada. Num sistema de **rodízio de credenciamento público**, isso significa risco de **seleção indevida de prestador** e quebra de auditabilidade da fila — consequência regulatória, não estética.
- **BL-4** significa que **edição manual silenciosa** pode corromper a base sem rastro — o oposto do contrato de um sistema de gestão pública.
- **BL-5/BL-6/BL-7** emitem **documentos oficiais com dados errados ou faltando** (nota fora de escala, sem local de execução, sem empenho/demandante).

Qualquer um dos três clusters acima isoladamente já reprovaria o freeze. Os três juntos tornam a decisão de bloquear **inequívoca**.

---

## 6. Critérios de freeze V12.0.0206

Adoto e endosso os critérios C1-C6 de 0022 (são bons e objetivos), com **uma emenda ao C1** vinda do §4 desta proposta:

- **C1 — Cobertura RVS expandida (BLOQUEADOR estrutural).** Antes do freeze, a bateria V2 ganha roteiros **que dirigem fluxos de UI e caminhos de erro**, não só asserts sobre base semeada: `V2_PERSISTENCIA_PAINEL`, `V2_CICLO_VIDA_ENTIDADE` (inativação com falha forçada), `V2_ORDENACAO_FILA` (base populada), `V2_IMPRESSAO_INTEGRIDADE` (clamp + `END_ENTIDADE` + empenho), `V2_PROTECAO_PERSISTE` (close/reopen). **Emenda:** incluir um **corpus de base suja herdada** como fixture (o L43 colapsou justamente fora da base limpa).
- **C2 — BLOQUEADORES BL-1…BL-7 resolvidos** (ou BL-1 explicitamente diferido por decisão registrada do Mauricio, conforme §3.1).
- **C3 — Auditoria cruzada A4 por ≥2 IAs em chat novo** — esta (0024) é a terceira; cumpre e excede o mínimo.
- **C4 — Re-execução RVS sexteto + roteiros novos** sobre build `<HEAD>+ONDA38.2.X-freeze-v206`, evidência textual em `auditoria/evidencias/V12.0.0206/csv/`.
- **C5 — Re-validação manual L44** (2ª passada tela-a-tela do L43 sobre a build corrigida, incluindo **teste explícito sobre base herdada**). Sem novos BLOQUEADORES.
- **C6 — Higiene documental** (CHANGELOG, release notes V206, INDEX evidências, relay, AGENTS `versao-sistema`, `App_Release.bas`).

**Sem C1 + C2 + C5 não há freeze.** C3 já cumprido; C4/C6 procedimentais.

---

## 7. Separação V206 / V207

Regra de corte (mantida de 0022, que estava certa): **V206 = parar de mentir** (UI mostra a regra real, planilha protege de fato, impressão respeita a regra, cadastro não corrompe estado). **V207 = ir mais rápido e mais bonito** (cache, padronização, microcopy, telemetria).

- **Entra V206 (obrigatório):** todos os 7 BLOQUEADORES + FT-1, FT-2, FT-3, FT-4, FT-5, FT-6, FT-7, FT-8, FT-10, FT-11. Quick-win MG-1 (GitHub Mac) por ser code-internal trivial.
- **Fica V207 (refatoramento):** FT-9 (tempo de experiência — auditar; se for risco arquitetural de permissão, V207) + MG-2…MG-9. **Alternativa II-bis** (commit full V207.0–V207.8) e os **3 guard-rails** (Fase-Lock, Invalidação Stateless, Callback Explícito) **permanecem**. Acrescento um **4º guard-rail recomendado** (já sugerido por 0022, que endosso): **Contrato UI-Domínio** — toda regra de negócio com controle de UI correspondente deve ter roteiro V2 que **falhe quando o controle some**. BL-1 só passou porque esse contrato não existia.
- **V207.0 deve incluir** o catálogo `Teste_V3_*` UI-driven (compatível com o FAC do §1.3 do L43).

---

## 8. Sequência executável para Codex (ondas Cadência D Estendida)

Reorganizei as ondas **por causa-raiz verificada** (não pela clusterização especulativa de 0022). Cada onda: readback novo → hearback → ERP → auditoria cruzada por 2 IAs em chat novo. Implementador (Codex) não audita.

### Onda 38.2.4 — Integridade de estado (BL-2, BL-3, BL-4) — **a mais crítica**
- **Escopo (`scope.files_allowed`):** `Classificar.bas` (`xlGuess`→`xlNo` nas linhas 18 e 248); `Altera_Entidade.frm` (tornar inativação atômica: excluir-antes-de-confirmar-cópia ou rollback no handler); `Util_Planilha.bas` (`ProtegerAbasCriticas` — avaliar persistência real vs `UserInterfaceOnly`); `Auto_Open.bas` (garantir disparo no Mac + log de `ProtectContents`); espelho `local-ai/vba_import/*`; `App_Release.bas`.
- **Testes esperados:** `V2_ORDENACAO_FILA` (base populada), `V2_CICLO_VIDA_ENTIDADE` (inativação com falha de proteção forçada → assert não-duplicação), `V2_PROTECAO_PERSISTE` (close/reopen) + reexecução E2E_Strikes/Onda23Adv.
- **Não-objetivos:** não tocar impressão (`Preencher`), não tocar `Configuracao_Inicial`, não tocar `Mod_Types.bas`.

### Onda 38.2.5 — UI de regras de negócio (BL-1)
- **Escopo:** reconstruir no designer VBE os TextBoxes `TxtNotaCorte`/`TxtMaxStrikes`/`TxtDiasSuspensao` em `Configuracao_Inicial` (+ verificar área gestora/município/prazo); reconciliar `.frx` ↔ workbook (Regra de Ouro 0002); auditar **quando** os controles sumiram (git-blame do `.frx`); espelho.
- **Testes esperados:** `V2_PERSISTENCIA_PAINEL` (falha se `.Controls("TxtMaxStrikes")` lançar erro).
- **Não-objetivos:** não importar `.frm` sem `.frx` casado; não usar "Import File" para `.frm` em workbook estabilizado (usar `.code-only.txt`).

### Onda 38.2.6 — Integridade de impressão (BL-5, BL-6, BL-7, FT-7)
- **Escopo:** `Preencher.bas` (aplicar clamp ≥10 no caminho de impressão 3260-3269 + `Format` explícito; corrigir `GarantirDadosPreOSParaImpressao` para receber `res.IdGerado`/ID numérico); `Menu_Principal.frm` (`BE_ImprimeOS_Click`: carregar `END_ENTIDADE` + empenho); `App_Release.bas`.
- **Testes esperados:** `V2_IMPRESSAO_INTEGRIDADE` (assert `N27:N36 ≤ 10`, `F18 ≠ ""`, empenho preenchido) antes do `PrintOut`.

### Onda 38.2.7 — Leitura/exibição (FT-1, FT-5, FT-6, FT-8)
- **Escopo:** `Menu_Principal.frm` (`C_Lista_Click` completo; nome/tel na seleção de rodízio; exibir ID; filtros em Imprime SS); `Preencher.bas` (popular visualização).
- **Testes esperados:** estender `V2_CICLO_VIDA_ENTIDADE` com assert de seleção; assert de filtro em Imprime SS.

### Onda 38.2.8 — Performance/UX (FT-3, FT-4, FT-2, MG-1)
- **Escopo:** `ProgressBar.frm` (remover `Save` embutido a 90% e o busy-wait `timedelay`); `Credencia_Empresa.frm` (hoist proteção fora do loop / alocar IDs em lote); `Menu_Principal.frm` (`LimparCamposCadastroEntidade`; Mac-first em `AbrirURLExterna`).
- **Testes esperados:** assert de cycle-time (`< N s`) no cadastro de entidade e credenciamento.

### Onda 38.2.9 — Designer residual + regressão de parâmetros + higiene de freeze (FT-9?, FT-10, FT-11, C6)
- **Escopo:** designer (`.frx` sobreposições FT-10); roteiro de regressão de persistência de CONFIG (FT-11); decidir FT-9 (V206 se trivial, V207 se arquitetural); CHANGELOG/evidências/AGENTS/release notes.

### Não-objetivos transversais
- Nada em `Mod_Types.bas` (proibido fora da Onda 9).
- Nada que importe `.frm` sem `.frx` casado (Regra de Ouro 0002).
- Nada de cache/refatoração V207 antes do freeze V206.
- `On Error Resume Next` só em blocos curtos comentados (knowledge 0001) — **e nunca** mascarando ausência de controle como em BL-1.

> **Risco de regressão cruzada — Onda 38.2.4.** É a onda de maior risco (mexe em ordenação + ciclo de vida + proteção, tudo cross-cutting). Recomendo **3 auditores** ao final dela, e que BL-2 e BL-3 sejam **gates intra-onda separados** (P3): primeiro `xlGuess` com seu teste verde, depois atomicidade da inativação com o seu, depois proteção. Não fechar a onda monoliticamente.

---

## 9. Avaliação por natureza (resposta à pergunta 4)

| Natureza | Itens | Severidade dominante | Leitura sistêmica |
|---|---|---|---|
| Estado de UI (U) | 16 | FORTE | designer `.frx` regrediu silenciosamente em ≥2 ondas → **a Regra de Ouro 0002 foi desrespeitada de fato.** |
| Persistência/estado (S) | 6 | BLOQUEADOR | combinada com U vira corrupção (BL-3, BL-4, FT-11). |
| Regra de negócio (B) | 8 | FORTE→BLOQUEADOR | regras existem no backend (strikes, clamp, status, rodízio) mas o frontend desconecta → **front/back sem contrato testável.** |
| Impressão (I) | 7 | BLOQUEADOR | clamp assimétrico (BL-5) + OS/Pré-OS com campos faltando (BL-6/BL-7/FT-7). |
| Proteção (P) | 1 | BLOQUEADOR | concentrado em `ProtegerAbasCriticas` + `UserInterfaceOnly` não-persistente. |
| Teste (T) | 7 | BLOQUEADOR | achado #0: o RVS testa o lado limpo; a falha é data/path-dependente. |
| Cross-cutting (X) | — | BLOQUEADOR | BL-2+BL-3 são o cluster que produz o "colapso" da base populada. |

**Conclusão arquitetural.** A V206 não tem "bugs cosméticos". Tem **2 quebras de invariante de domínio** (status simultâneo, fila embaralhada), **1 falha de proteção de dados**, **3 saídas oficiais incorretas** e **1 lacuna estrutural de cobertura**. Tratar como polimento subestima o risco; tratar como reescrita superestima o custo. O caminho honesto: **6 ondas safe_track curtas com auditoria cruzada e ampliação cirúrgica da bateria**, exatamente como abaixo.

---

## 10. Checklist anti-viés §12.4 do PROMPT_ARQUITETO

| Item | Resposta |
|---|---|
| Auto-indicação | **Não.** Não me indico para implementar nem para futuras auditorias. |
| Evidência objetiva | Releitura direta de `src/vba/` com números de linha (Anexo §13): `Classificar.bas:18/248`; `Altera_Entidade.frm:197-219`; `Svc_Avaliacao.bas:153/226-239`; `Preencher.bas:1597/3260-3269`; `Menu_Principal.frm:461-468/1920/3510-3533`; `ProgressBar.frm:70/87-99`; `Util_Planilha.bas:462-477/607-635`; inventário `.frx` por `strings` (método validado em forms-irmãos). |
| Viés natural | Opus tende a endossar o auditor Opus (0022). **Mitigação consciente:** arbitrei **contra** 0022 em 3 dos 5 mecanismos graves (fila, GitHub, fix da impressão) e **corrigi** seu achado #0 factualmente, dando crédito a 0023 onde foi mais preciso. Não há favorecimento de modelo. |
| Recomendação de bastão | **Manter Codex como implementador V206** (continuidade <50% contexto, conhece os manifestos e a estrutura) — convergente com 0022 e 0023, por evidência objetiva, não por afinidade. Auditores por onda: 2-3 IAs em chat novo, sem o implementador. |
| Mitigação final | Mauricio pesa 0022 + 0023 + 0024 (esta) antes de liberar o readback da Onda 38.2.4. Conflito BLOQUEADOR×BLOQUEADOR → Mauricio decide (nenhuma IA sobrescreve BLOQUEADOR alheio). |

---

## 11. Próxima ação concreta

1. Mauricio registra esta proposta (`0024`).
2. Com 0022 + 0023 + 0024 convergentes no **veredito BLOQUEAR** e na **classificação dos BLOQUEADORES**, Mauricio decide o ponto aberto do §3.1 (BL-1 bloqueia ou é diferido com config manual documentada).
3. Mauricio entrega ao Codex o readback `0120-rb-onda-38-2-4-integridade-estado` (escopo §8, ordenação + atomicidade + proteção), com gates intra-onda separados.
4. Codex executa 38.2.4 → auditoria cruzada (3 IAs) → 38.2.5 → … → 38.2.9.
5. Tag `v12.0.0206` **somente** após C1+C2+C3+C4+C5+C6.

---

## 12. Coerência com governança

- **Knowledge 0019 (Cadência D Estendida §5):** severidades BLOQUEADOR/FORTE/MARGINAL aplicadas; veto formal ao freeze e ao uso isolado do RVS exercido.
- **Knowledge 0002 (Regra de Ouro vba_import):** **reforçada** — BL-1 e FT-10 (`.frx`) só entraram porque `.frm` foi importado sem `.frx` casado em algum ponto. A Onda 38.2.5/38.2.9 deve incluir verificação git-histórica de quando os controles sumiram.
- **Knowledge 0010 (funcionalidade nova exige teste):** corolário explicitado — **regressão de funcionalidade existente exige teste novo que falhe pela regressão antes de fechar.**
- **CLAUDE.md "Never delegate understanding":** cumprido — reabri o pipeline e não aceitei o diff/evidência das irmãs sem verificar (a evidência `strings .frx` de 0022 era frágil e foi refeita).
- **Tabu `Mod_Types.bas`:** nenhuma onda proposta o toca.

---

## 13. Anexo — recortes verificados em `src/vba/` (build `35217c0+ONDA38.2.3-A4-F2-FORMS`)

```
BL-1  Configuracao_Inicial.frm:95-98   On Error Resume Next; Me.Controls("TxtNotaCorte"/"TxtMaxStrikes"/"TxtDiasSuspensao").Value (leitura)
      Configuracao_Inicial.frm:331-334 idem (popular no load)
      Configuracao_Inicial.frx          inventário ASCII de controles = {CommandButton1, Label41,42,43,45,46} — ZERO TextBox
                                         (método validado: strings recupera TextBox16/CR_* em Reativa_*/Credencia_Empresa.frx)
BL-2  Classificar.bas:18                .Header = xlGuess  (ClassificaEntidade)
      Classificar.bas:248               .Header = xlGuess  (ClassificaServico)
      Classificar.bas:50,75,101,124,145,164,184,204,223  .Header = xlNo  (todos os outros — assimetria)
BL-3  Altera_Entidade.frm:197-199       Util_PrepararAbaParaEscrita(wsEntInativas...) ; EncontrarID.EntireRow.Copy Destination:=wsEntInativas...
      Altera_Entidade.frm:203-207       Util_PrepararAbaParaEscrita(wsEnt...) ; If Not Util_ExcluirLinhaSegura(wsEnt, EncontrarID.row) Then Err.Raise
      Altera_Entidade.frm:213-219       erro_carregamento: restaura proteção das duas abas; NÃO faz rollback da cópia → duplicidade
BL-4  Util_Planilha.bas:462-477         ProtegerAbasCriticas: Array(EMPRESAS,...,AUDIT) ; ws.Protect ... UserInterfaceOnly:=True
      Auto_Open.bas:15                  Call ProtegerAbasCriticas   (única reaplicação no open)
      contagem global                   PrepararAbaParaEscrita=121  RestaurarProtecaoAba=196  (sem leak aparente → raiz é persistência/Auto_Open)
BL-5  Svc_Avaliacao.bas:226-239         Private Function SvcAvaliacao_NotaSegura: If numero > 10 Then numero = 10
      Svc_Avaliacao.bas:153             uso ÚNICO, no caminho de persistência (MontarPayload)
      Preencher.bas:3260-3269           ws.Range("N27..N36").Value = Format(AvN01..AvN10, "##,#")  — brutos, sem clamp
BL-6  Menu_Principal.frm:461-468        loop carrega cont_entidade/telcont_entidade; END_ENTIDADE AUSENTE
      Menu_Principal.frm:537            END_ENTIDADE = ...List(...,6)  (caminho de rodízio que funciona — contraste)
      Preencher.bas:3252                ws.Range("F18").Value = END_ENTIDADE  (grava vazio na OS)
BL-7  Menu_Principal.frm:1920           N_OS = "PROVIS" & ChrW(211) & "RIA - " & res.IdGerado
      Preencher.bas:1061                Call GarantirDadosPreOSParaImpressao(N_OS)
      Preencher.bas:1598                preId = Trim$(CStr(preosId))  — sem remover prefixo
      Preencher.bas:~1605               If linhaPre = 0 Then Exit Sub  — busca por IdsIguais falha → dados em branco
FT-3  ProgressBar.frm:70                If (y / a) = 90 Then Application.ThisWorkbook.Save  (Save embutido no loop de render)
      ProgressBar.frm:87-99             timedelay: While DateTime.Timer - x < segundos: Wend  (busy-wait de CPU)
FT-4  Credencia_Empresa.frm:~161-208    For i ... : credId = ProximoId(SHEET_CREDENCIADOS) [dentro do loop] ... Next i
      Util_Planilha.bas:607-635         ProximoId: Util_PrepararAbaParaEscrita + Util_MaxIdOperacional(scan) + Restaurar — POR CHAMADA
FT-2  Menu_Principal.frm:2339           LimparCamposCadastroEmpresa (só chamada pós-cadastro, :2300) ; sem equivalente p/ entidade
MG-1  Menu_Principal.frm:3510-3533      AbrirURLExterna: FollowHyperlink (3513/3520) ANTES do Shell "open" Mac (3530)
#0    Teste_V2_Roteiros.bas             TV2_DetectarEntidadeDuplicadaAtivaInativa EXISTE (assert presente; falta dirigir o fluxo que viola)
```

---

**FIM 0024-Opus3-4-MAX.** Três auditorias cruzadas (0022 Opus consolidador · 0023 Antigravity sistêmico · 0024 Opus3-4-MAX árbitro) **convergem no veredito BLOQUEAR**. Esta árbitro mantém a moldura de 0022, adota os mecanismos verificados de 0023, corrige 4 diagnósticos, e dissolve o mistério da base populada em causas-raiz concretas. Decisão de freeze/diferimento de BL-1 e severidade de BL-6/BL-7: do Mauricio.
