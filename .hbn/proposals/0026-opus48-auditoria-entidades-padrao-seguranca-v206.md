---
titulo: Auditoria Opus 4.8 — Entidades e Padrao de Seguranca V206
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
papel-autor: Claude Opus 4.8 — auditoria arquitetural independente
escopo: Onda 38.2.4 Entidades, protecao de abas criticas, D5, RVS pos-Fix5, padrao de seguranca, teste automatizado e FAQ HBN futuro
output_path: .hbn/proposals/0026-opus48-auditoria-entidades-padrao-seguranca-v206.md
---

# 0026 — Auditoria Opus 4.8: Entidades e Padrão de Segurança V206

> **Recado curto ao Codex e ao Maurício.** Este documento cumpre o gate 7 do
> `validation_plan` do readback `0120` (auditoria cruzada pós-onda). Verifiquei
> o código direto em `src/vba/` por `git diff HEAD`, confirmei sincronismo
> src↔espelho por contagem de tokens, validei o SHA-256 do CSV e auditei o
> estado git real do repositório. **Veredito objetivo: a Onda 38.2.4 PODE
> fechar o ERP 0120** (não encontrei BLOQUEADOR de fechamento, sujeito a UMA
> confirmação — §1.3). **Mas a entrega ainda NÃO é um padrão pronto para
> propagar**, e o freeze V206 segue bloqueado por causas alheias a esta onda
> (BL-1/BL-5/BL-6/BL-7 do parecer 0024). Recomendação: **opção B** — fechar a
> onda, travar a propagação até os FORTES, evoluir o FAQ HBN, depois propagar.

Notas de método: (i) números de linha citados são da **árvore de trabalho
pós-delta (não commitada)** — ver FT-6; (ii) não li o parecer-irmão `0025`
(Antigravity/Gemini) para preservar independência — ele deve entrar na
consolidação; (iii) não implemento nem edito código.

---

## 1. VEREDITO

### 1.1 A Onda 38.2.4 pode fechar o ERP 0120?

**Sim.** A onda cumpriu o contrato do readback `0120`:

| Gate `0120` | Exigência | Estado verificado |
|---|---|---|
| D1 | diff só toca escopo | **OK** — `git diff --name-only HEAD` em `src/vba/` = exatamente `Classificar.bas`, `Altera_Entidade.frm`, `Util_Planilha.bas`, `Teste_V2_Roteiros.bas`; **zero** arquivo proibido (Auto_Open, Mod_Types, Importador, Engine, Svc_*, Menu_Principal, Preencher, Config). |
| D2 ordenação | teste dirigido base populada | **OK com ressalva visual** (scroll/foco — fora 0120). |
| D3 atomicidade | ativa+inativa + rollback | **OK** — fix real e validado manualmente (ciclo 1º/intermediário/último item). |
| D4 proteção | bloqueio sem Auto_Open | **OK pós-Fix4** (Maurício confirmou bloqueio em ENTIDADE/ENTIDADE_INATIVOS/PRE_OS/CAD_OS/EMPRESAS). |
| D5 objetos | limpeza + DrawingObjects | **OK pós-Fix5** (ENTIDADE_INATIVOS limpa; colagem de imagem bloqueada). |
| Compile/RVS | compile limpo + RVS aprovado | **OK** — `VR_20260531_092609`, SHA-256 `ee0bbd98…` **confere byte-a-byte**. |
| Cross-audit | proposal em `.hbn/proposals/` | **este 0026** (+ `0025`). |

As três correções centrais são **reais, presentes e sincronizadas** entre
fonte e espelho de import (verificado por token-count idêntico). Não inventarei
um BLOQUEADOR onde não há (veracidade > diplomacia).

### 1.2 Está apta a ser padrão de segurança para outros fluxos?

**Não ainda.** O *design* é bom e merece virar padrão, mas a *prova* é fraca em
três eixos: (a) a suíte dirigida é majoritariamente **varredura textual
estática**, não comportamental (FT-1); (b) a limpeza de `Shapes` é
**indiscriminada** e perigosa fora de abas puramente de dados (FT-4); (c) não há
prova automatizada de **persistência da proteção em close/reopen** (FT-3).
Propagar antes de fechar esses FORTES replicaria as lacunas em mais telas.

### 1.3 O que impede fechar — a única confirmação pendente

O `MAPA_TESTES_ENTIDADES_V206` declara **`ENT_MAN_23` (rodar RVS e repetir
ENT_MAN_19..22) como Bloqueador**, e o `GATE_D4` (linhas 101-103) alerta para o
modo de falha exato que já ocorreu no **Fix3** (RVS aprovado → abas editáveis
logo depois). As evidências (`GATE_D5`, `RVS_FINAL`) reportam D5-manual e
RVS-aprovado, **mas não registram explicitamente a reverificação do bloqueio de
edição APÓS o RVS final `VR_20260531_092609` no build salvo**.

→ **Confirmar com Maurício se o `ENT_MAN_23` foi executado no build Fix5 já
salvo, depois do RVS.** Se SIM, fecha sem ressalva. Se NÃO, é o único item que
vira BLOQUEADOR de fechamento (re-teste de 2 minutos resolve).

### 1.4 O que impede o freeze V206 (≠ fechar a onda)

| "Fechar Onda 38.2.4" | "Tagar V12.0.0206" |
|---|---|
| Resolver BL-2/BL-3/BL-4 (escopo 0120). **Atingido.** | Resolver **todos** os 7 BLOQUEADORES de 0024. |
| Gates D1-D5 + RVS + cross-audit. **Atingido.** | Faltam **BL-1** (UI strikes), **BL-5/BL-6/BL-7** (impressão) — ondas 38.2.5–38.2.6. |
| ERP 0120 assinado. | + C1 (cobertura comportamental), C4 (evidência em `evidencias/V12.0.0206/`), C5 (L44 tela-a-tela), C6 (higiene + **commit do delta**). |

**Conclusão:** a onda fecha; o freeze está a **4 BLOQUEADORES + cobertura +
higiene** de distância. São decisões disjuntas e não devem ser confundidas.

---

## 2. AUDITORIA TÉCNICA DA ENTREGA

### 2.1 `Classificar.bas` — eliminação de `xlGuess` (BL-2)

`Classificar.bas:18` (`ClassificaEntidade`) e `:248` (`ClassificaServico`):
`.Header = xlGuess` → `.Header = xlNo`. As faixas de sort são `A2:V` e `A2:I`
— **começam na linha 2, já excluindo o cabeçalho real (linha 1)**; portanto
`xlNo` é o valor correto e determinístico. `grep` confirma **0 ocorrências
remanescentes de `xlGuess`** e 10 de `xlNo` em ambos fonte e espelho. Corrige a
causa-raiz data-dependente apontada por 0024 (BL-2): a ordenação deixa de
"adivinhar" e some o sintoma "base zerada funciona, populada colapsa".
**Impacto em entidades e serviços: positivo e simétrico.** ✔

### 2.2 `Altera_Entidade.frm` — inativação atômica (BL-3)

Fluxo novo de `C_Inativa_Entidade_Click` (≈ linhas 110-230) + helper
`Entidade_RemoverInativasDuplicadas` (≈ 233-275):

| Item auditado | Resultado |
|---|---|
| Clipboard / `EntireRow.Copy` | **Eliminado.** Substituído por cópia de faixa `A:COL_ENT_DT_CAD` por **valor + formato** (`destinoDados.Value = origemDados.Value`). |
| `ActiveCell`/`Selection`/`.Select` | **Ausentes** no caminho operacional (opera por ID persistido). |
| Faixa de cópia vs dados | `COL_ENT_DT_CAD = 22 = V` (`Const_Colunas.bas:105`) = **exatamente** a faixa de sort `A:V`. **Nenhuma coluna é perdida.** ✔ |
| Atomicidade/rollback | Flags `copiaInativaCriada`/`ativaExcluida`. Janela crítica: cópia criada → ativa excluída. Falha **antes** de excluir a ativa ⇒ handler apaga a cópia (`If copiaInativaCriada And Not ativaExcluida` → `Util_ExcluirLinhaSegura(wsEntInativas, linhaEntInativa)`). Invariante **ATIVA XOR INATIVA** preservada. ✔ |
| Preservação do erro | `erroNumero/erroMensagem` capturados **antes** do `On Error Resume Next` — corrige perda de `Err.Description`. ✔ |
| Restauração de proteção | Ambas as abas restauradas em sucesso **e** em erro. ✔ |

**Lacuna (MG-2):** se a atribuição `destinoDados.Value` lançar **no meio** da
escrita, `copiaInativaCriada` fica `False` e um resíduo parcial poderia restar
em INATIVOS sem rollback. Probabilidade baixa (atribuição de `Range.Value` é
quase atômica), mas o invariante depende disso. Marginal.

### 2.3 `Util_Planilha.bas` — proteção verificável + objetos + última linha

| Função nova (≈ linha) | O que faz | Avaliação |
|---|---|---|
| `Util_AbaEhCritica` (≈53) | match das 10 abas críticas | OK |
| `Util_CelulasTodasBloqueadas` (≈63) | `ws.Cells.Locked`; `Null`→`False` | OK (trata mistura) |
| `Util_AplicarProtecaoCriticaAba` (≈100) | desprotege → `Cells.Locked=True` → `Protect(DrawingObjects, Contents, Scenarios, UserInterfaceOnly, AllowFiltering, AllowSorting)` → **verifica** `ProtectContents`+`ProtectDrawingObjects`+`Locked` | **Forte** — aplica E confirma |
| `Util_RestaurarProtecaoAba` (≈199) | aba crítica ⇒ re-aplica proteção crítica **mesmo se iniciou desprotegida** | **Forte** — auto-cura por operação |
| `Util_ExcluirLinhaSegura` (≈231) | `ListRows.count <= 1` ⇒ `ClearContents` (preserva tabela) | OK — corrige erro "linha única de ListObject" |
| `Util_ProtegerAbasCriticasVerificado` / `Util_LimparObjetosAbasCriticas` / `Util_Verificar*` (≈593+) | iteram as 10 abas, devolvem `ok` + `detalhes` | OK funcional |

`Cells.Locked`, `ProtectContents` e `ProtectDrawingObjects` **persistem** no
save/reopen (são propriedades de planilha). O único atributo volátil é
`UserInterfaceOnly`, que afeta apenas a escrita-VBA-sem-desproteger — coberto
pelo par `Preparar/Restaurar`. Logo, para o **invariante de segurança**
(operador não edita), a proteção persiste **desde que o workbook seja salvo no
estado protegido**. É exatamente aqui que mora o risco residual (FT-3).

### 2.4 `Teste_V2_Roteiros.bas` — `TV2_RunIntegridadeEstado` (8 asserts)

| Assert | Natureza | O que prova |
|---|---|---|
| CS_EST_01 (xlGuess) | **estático** (InStr no código) | que o texto `xlGuess` não existe |
| CS_EST_02 (atomicidade) | **estático** | que tokens `copiaInativaCriada`/`ativaExcluida`/… existem |
| CS_EST_04 (sem EntireRow/ActiveCell) | **estático** | que tokens proibidos não existem |
| CS_EST_05 (última linha tabela) | **estático** | que tokens `ListRows.count <= 1`/`ClearContents` existem |
| CS_EST_06 (proteção bloqueia células) | **estático** | que tokens de proteção existem |
| CS_EST_07 (objetos) | **estático** | que tokens de limpeza existem |
| CS_EST_03 (proteção crítica) | **runtime** | aplica E verifica proteção na sessão |
| CS_EST_08 (objetos zero) | **runtime** | limpa E verifica objetos na sessão |

**Achado central (FT-1).** 6 de 8 asserts são **varredura textual**: provam que
o código *contém os tokens certos*, não que ele *se comporta certo*. Os dois
runtime (CS_EST_03/08) são **auto-atuantes** — a própria suíte chama
`Util_LimparObjetosAbasCriticas`/`Util_ProtegerAbasCriticasVerificado` e em
seguida confere o resultado da sua própria ação. Portanto **NÃO há cobertura
comportamental** de: (i) rollback da inativação sob falha forçada; (ii)
ordenação após `ClassificaEntidade` em base populada; (iii) persistência da
proteção em close/reopen. É precisamente a "achado #0 / C1" de 0024. O
`OK=8 | FALHA=0` é verdadeiro, mas atesta sobretudo **presença de código + ação
em sessão**, não invariantes de domínio.

Mérito: ler via `Application.VBE...VBComponents` (origem `VBE`) faz a varredura
incidir sobre o **módulo importado**, não só o `.frm`/`.bas` em disco — bom
toque que mitiga o risco de espelho desatualizado. **Ressalva (MG-4):** o
fallback de filesystem lê `src/vba`; o CSV não registra a `ORIGEM` por assert,
então não é possível provar, pela evidência, que foi `VBE` e não `FS`.

### 2.5 Pacote de import / `App_Release` / evidências

- **Sincronismo src↔espelho:** `AAE-Util_Planilha.bas`, `ABG-Teste_V2_Roteiros.bas`,
  `AAT-Classificar.bas` têm **contagem de tokens idêntica** à fonte. Sem
  divergência de conteúdo. ✔
- **`App_Release`:** o espelho `AAX-App_Release.bas:254` traz
  `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS` (correto, igual ao campo BUILD do
  CSV). Mas `src/vba/App_Release.bas:254` está **defasado** em
  `7bca168+ONDA38.2.1-revert-filtros-menu`. Como `src/vba/App_Release.bas`
  **não estava em `files_allowed`**, a defasagem é *scope-compliant*, porém
  deixa a fonte-de-verdade mentindo sobre o build (ver FT-6).
- **CSV RVS final:** SHA-256 confere; 8 linhas; sintaxe
  `V1=171/0 + V2_Smoke=34/0/4M + V2_Canonica=24/0 + E2E_Strikes=76/0 + IntegridadeBase=4/0/1M + Onda23Adv=27/0`.
  **Discrepância menor (MG-1):** `RVS_FINAL.md` diz "Bytes: 1378"; o arquivo
  tem **1371**. O SHA bate sobre 1371 ⇒ o "1378" é erro de transcrição, não de
  integridade.
- **Histórico Fix1→Fix5** é a melhor evidência de que **RVS verde ≠ liberado**:
  Fix1 (erro no 1º item ativo, TV2 com falso-positivo `ActiveCell`), Fix3 (RVS
  aprovado, depois abas editáveis no D4), Fix4 (escrita bloqueada, mas objeto
  residual), Fix5 (objetos). Cada RVS passou e ainda assim o teste manual achou
  bloqueador real. Corrobora 0022/0023/0024.

---

## 3. PADRÃO DE SEGURANÇA E USO PARA PROPAGAÇÃO

### 3.1 Qual é o padrão (design técnico)

1. **Envelope Preparar/Restaurar** com **re-proteção forçada** de abas críticas
   no restore (auto-cura por operação).
2. **Proteção verificável**: aplicar E *assertar* `ProtectContents` +
   `ProtectDrawingObjects` + `Cells.Locked`, devolvendo `detalhes` estruturado.
3. **Mutação atômica** com flags de estágio (`copiaInativaCriada`/`ativaExcluida`)
   + captura de erro antes de `Resume Next` + rollback no handler.
4. **Cópia por valor/formato** em faixa de colunas delimitada — nunca
   `EntireRow`/clipboard/`ActiveCell`/`Selection` em formulário modal.
5. **`ListObject` seguro**: `ClearContents` quando resta 1 linha.
6. **Sort determinístico** (`xlNo` em faixa sem cabeçalho).
7. **Tripwire estático** contra tokens proibidos (`xlGuess`, `EntireRow.Copy`,
   `ActiveCell`).

### 3.2 Invariantes que devem virar regra permanente

| # | Invariante | Como exigir |
|---|---|---|
| INV-1 | ATIVA **XOR** INATIVA (nunca ambos) | teste **comportamental** com falha forçada |
| INV-2 | aba crítica = `ProtectContents` + `ProtectDrawingObjects` + todas as células `Locked`, **persistidas em save/reopen** | teste close/reopen |
| INV-3 | proibido clipboard/`EntireRow`/`ActiveCell`/`Selection` em forms | tripwire estático (já existe) |
| INV-4 | sort sempre `xlNo` em faixa sem cabeçalho | tripwire estático |
| INV-5 | toda mutação destrutiva (limpeza/proteção/exclusão) registra `Audit_Log` | revisão + assert |
| INV-6 | mutação atômica: estágio→commit→rollback | revisão + teste |

### 3.3 Helpers generalizáveis

Prontos para reuso: `Util_AbaEhCritica`, `Util_AplicarProtecaoCriticaAba`,
`Util_VerificarProtecaoAbasCriticas`, `Util_ExcluirLinhaSegura`, envelope
`Util_Preparar/RestaurarProtecaoAba`. **A extrair:** um helper genérico
`Util_TransicaoAtomicaEntreAbas(origem, destino, faixa)` que encapsule o padrão
copy-por-valor + flags + rollback hoje embutido em `Altera_Entidade.frm` — isso
evita reescrever o rollback à mão em Empresas, Serviços etc.

### 3.4 Comportamentos de UI a exigir

Bloqueio de edição direta; bloqueio de inserir/mover/redimensionar/excluir
objeto; proteção persistente; **feedback ao operador** (hoje só `MsgBox` de
sucesso/erro — recomendo status estruturado); **reversibilidade** (rollback +
caminho de reativação).

### 3.5 Onde aplicar (e onde NÃO)

| Fluxo | Proteção células | Limpeza de `Shapes` | Transição atômica |
|---|---|---|---|
| **Empresas / Empresas Inativas** | **SIM** (mesmo desenho copy-row) | SIM (aba de dados) | **SIM — alvo nº 1** |
| **Serviços / Atividades** | SIM | SIM | parcial (não há par ativo/inativo) |
| **Credenciamentos** | SIM | SIM | SIM (qualquer move/delete) |
| **PRE_OS / CAD_OS** | SIM (já críticas) | SIM, com cautela | SIM (escrita transacional) |
| **Relatórios / abas de impressão** | **tunado** (não travar controles de impressão) | **NÃO** (logos/botões/layout) | n/a |
| **Menu_Principal / abas-formulário** | **NÃO** (não são dados) | **NÃO** (destrói UI) | n/a |

### 3.6 Riscos de proteção/limpeza indiscriminada

`Util_LimparObjetosAbaCritica` apaga **todos** os `Shapes` (form controls,
ActiveX, gráficos, imagens, logos). Em aba de dados pura é correto; aplicado em
abas com botões/relatórios **destrói UI legítima**. `Cells.Locked = True` em
massa quebra células de entrada se existirem na própria aba. Custo de performance
(apagar shapes + reproteger 10 abas a cada operação). **Regra:** limpeza de
objetos deve ser **allowlist por aba, nunca blanket**, e idealmente disparada
por gate, não silenciosamente em cada execução de teste.

---

## 4. PROPOSTA DE TESTE AUTOMATIZADO

`MAPA_TESTES_ENTIDADES_V206` é uma boa matriz manual (25 cenários), mas a
conversão para automático ainda é **estática**. Proposta de suíte
**comportamental** complementar (mantendo `TV2_RunIntegridadeEstado` como
tripwire):

- **Nome:** `TV2_RunEntidadeCicloVida` (suite `ENTIDADE_CICLO_VIDA`).
- **Pré-condições:** workbook importado/compilado; backup V3 no início;
  `Audit_Log` ativo.
- **Fixture/base:** base semeada determinística (N=5 entidades) **+** variante
  "base herdada suja" (IDs fora de ordem, linha duplicada plantada) — atende ao
  corpus de base suja exigido por 0024 (C1).
- **Passos:** (1) cadastrar entidade completa; (2) editar todos os campos; (3)
  reler a linha e comparar com o gravado (persistência ≠ exibição); (4) inativar
  intermediária / 1ª / última; (5) `ClassificaEntidade` e **assertar ordem**;
  (6) **forçar falha**: proteger `ENTIDADE` com senha divergente para que
  `Util_ExcluirLinhaSegura` lance, e **assertar rollback** (linha permanece na
  ativa, sem cópia em INATIVOS); (7) reativar; (8) assertar ATIVA XOR INATIVA.
- **Asserts:** persistência por célula; `count(ativa)+count(inativa)` sem
  interseção por `ENT_ID`; ordem ascendente pós-sort em base suja; rollback
  pós-falha; `ProtectContents/DrawingObjects/Locked` por aba.
- **Rollback/limpeza:** restaurar backup V3 **ou** remover linhas semeadas e
  reaplicar proteção; sem efeito no estado persistido entre execuções.
- **Critério de aprovação:** todos os asserts OK em **ambas** as bases (limpa e
  suja); falha em qualquer um reprova.

| Camada | Itens |
|---|---|
| **V2 agora** | ciclo cadastrar/editar/inativar/reativar; XOR; ordenação base suja; **rollback por falha forçada**; proteção em sessão; persistência por leitura de célula (tela principal vs modal) |
| **V3 / UI-driven** | acionar os botões reais do `.frm` (Show/click) e validar paridade tela-principal × modal de edição |
| **Permanece manual** | close/reopen real do workbook (proteção persiste após salvar); colar/mover imagem (UI do Excel); `ENT_MAN_23` pós-RVS |

Cobre o mínimo pedido: cadastrar, editar, inativar, validar XOR, reativar,
validar ordenação, leitura tela vs modal e proteção (quando tecnicamente
possível).

---

## 5. FAQ HBN COMO PROTOCOLO FUTURO

Esta entrega **é candidata forte** a FAQ HBN, mas **não retroativamente
bloqueante** (o protocolo não é vigente — respeito a ressalva de Maurício).

- **Nome sugerido:** `FAQ-HBN — Integridade de Estado de Entidades (ATIVA XOR
  INATIVA) e Proteção de Abas Críticas`.
- **Maturidade hoje (4 × 25%):**

| Critério | Estado | % |
|---|---|---|
| a. Regra de negócio | bem documentada (XOR; proteção das 10 abas) | **25/25** |
| b. Comprovação da arquitetura | desenho documentado; persistência sem Auto_Open **não provada** em close/reopen | **15/25** |
| c. Evidência do código | file:line verificável, src↔espelho sincronizado; **enfraquecida** por delta não-commitado + `local-ai/` gitignored | **18/25** |
| d. Mapa de testes aprovado | mapa manual passou; **suíte automatizada é estática, não comportamental** | **12/25** |
| **Total** | — | **≈ 70%** |

- **Para 100%:** (d) suíte comportamental do §4 verde; (b) prova de persistência
  close/reopen; (c) commit do delta + versionar o pacote de import.
- **Quando evoluir o protocolo:** **depois** de fechar a Onda 38.2.4 e **antes**
  de propagar o padrão. Formalizar o FAQ HBN agora como gate retroativo
  atrasaria uma onda tecnicamente sólida sem ganho de risco real.

---

## 6. SEVERIDADES

### BLOQUEADOR (impede fechar 38.2.4)
- **Nenhum incondicional.** Único condicional → **§1.3 / FT-2**: se `ENT_MAN_23`
  (re-teste de bloqueio **após** o RVS final, no build salvo) **não** foi
  executado, vira BLOQUEADOR até ser feito.

### FORTE (incorporar/justificar antes de propagar ou antes do freeze)
- **FT-1** — Suíte dirigida majoritariamente **estática**; falta cobertura
  comportamental de rollback, ordenação em base populada e persistência (achado
  #0 / C1 de 0024). *(propagação + freeze)*
- **FT-2** — Reverificação de proteção **pós-RVS no build final** não evidenciada
  (modo de falha do Fix3). *(fechar/freeze — ver §1.3)*
- **FT-3** — Persistência da proteção sem `Auto_Open` **não tem prova
  automatizada de close/reopen**; depende de o workbook ser salvo protegido.
  0024 apontou `Auto_Open` como provável necessário. *(freeze)*
- **FT-4** — Limpeza de `Shapes` **indiscriminada**; perigosa fora de abas de
  dados. Tornar allowlist por aba. *(propagação)*
- **FT-5** — Operações destrutivas **sem `Audit_Log.Registrar`** (convenção
  `AGENTS.md`). *(propagação)*
- **FT-6** — **Versionamento frágil:** delta inteiro **não commitado**;
  `local-ai/` **gitignored** (`.gitignore:40`) → manifestos, `AAT-Classificar`
  e **todo o artefato do form `AAE-Altera_Entidade.code-only.txt`** não
  versionados; `src/vba/App_Release.bas` defasado. Gate D1 sem `git_sha` que
  capture o diff. *(freeze — commitar no fechamento)*

### MARGINAL (pode ficar para V207)
- **MG-1** — `RVS_FINAL.md` diz 1378 bytes; arquivo tem 1371 (SHA confere → erro
  de transcrição).
- **MG-2** — Resíduo parcial se `destinoDados.Value` falhar no meio (baixíssima
  probabilidade).
- **MG-3** — Resíduos de UI: campos completos só no modal (ENT-UI-01), scroll/foco
  pós-reativação (ENT-UI-03), limpeza de form pós-cadastro (ENT-UI-02) — exibição;
  persistência está correta. *(onda de leitura/exibição; V207)*
- **MG-4** — CSV não registra `ORIGEM=VBE/FS` por assert; e CSV V206 ainda
  emitido sob caminho/nome `V12.0.0205` (C4 exige `evidencias/V12.0.0206/`).

---

## 7. CHECKLIST ANTI-VIÉS E BASTÃO

| Item | Resposta |
|---|---|
| Auto-indicação para implementar | **Não.** Sou auditor; implementador ≠ auditor (knowledge 0019 §1). |
| Quem consolida as auditorias | Papel **consolidador** distinto, em chat novo, pesando 0024 + **0026 (este)** + **0025** — como 0024 fez com 0022/0023. Decisão final de Maurício. |
| Quem implementa a propagação | **Codex** (continuidade, conhece manifestos/estrutura), convergente com 0024 §10. |
| Quem audita a propagação | 2-3 IAs em chat novo, **sem o implementador**; ao menos uma que **não** escreveu o padrão original. |
| Meu viés | (1) sou Opus, risco de endossar 0024 (família Opus) e a narrativa "OK=8 = pronto". (2) viés de confirmação por verde. |
| Mitigação | Verifiquei código/diff/git/SHA direto; **divergi** do enquadramento otimista expondo o gap estático×comportamental (FT-1) e o versionamento (FT-6) que os gate-docs subdimensionam; **não li 0025** para não me ancorar. Conflito BLOQUEADOR×BLOQUEADOR → Maurício decide. |

---

## 8. DECISÃO RECOMENDADA PARA MAURÍCIO

**Opção B — Fechar a Onda 38.2.4 (ERP 0120) e BLOQUEAR a propagação do padrão
até os FORTES.** Justificativa: não há BLOQUEADOR de fechamento (sujeito à
confirmação única do §1.3), mas o padrão não está provado para replicação
segura (FT-1/FT-3/FT-4/FT-5) e o versionamento precisa ser sanado (FT-6) antes
de virar referência.

Sequência recomendada:

1. **Confirmar `ENT_MAN_23`** no build Fix5 salvo, pós-RVS (§1.3). Se pendente,
   executar antes de assinar o ERP.
2. **Fechar ERP 0120** + **commitar o delta da onda** (resolve parte de FT-6 e dá
   `git_sha` real ao D1).
3. **Auditoria cruzada/consolidação agora** (0024 + 0026 + 0025 → consolidador).
4. **Evoluir o protocolo FAQ HBN + padrão de teste comportamental** (suíte do §4)
   — *depois* de fechar a onda, *antes* de propagar.
5. **Propagar** para Empresas/Serviços/Credenciamentos/PRE_OS/CAD_OS com os
   FORTES já incorporados; **não** aplicar limpeza de objetos em relatórios/abas
   de impressão.

**Cruzada agora, evolução do protocolo depois** — não o inverso: travar uma onda
sólida atrás de um protocolo ainda não vigente seria bloqueio retroativo sem
risco técnico que o justifique.

> **Sobre o freeze V206 (fora desta onda):** permanece **BLOQUEADO** por BL-1,
> BL-5, BL-6, BL-7 (0024), pela cobertura comportamental (C1) e pela higiene de
> release (C4/C5/C6). Fechar a 38.2.4 é progresso real, não é o freeze.

---

**FIM 0026-Opus-4.8.** Três auditorias-mãe (0022/0023/0024) convergiram em
BLOQUEAR o freeze; esta auditoria confirma que a **Onda 38.2.4 cumpre seu
escopo** (BL-2/BL-3/BL-4 reais e sincronizados, escopo limpo, evidência
íntegra), **separa fechar-onda de tagar-V206**, e condiciona a **propagação do
padrão** ao fechamento dos FORTES — com destaque para transformar a suíte
estática em **comportamental** e sanar o **versionamento** do delta e do pacote
de import.
