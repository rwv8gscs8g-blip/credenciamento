---
titulo: Diagnostico do Looping do Codex e Prompt de Retomada da Esteira
natureza-do-documento: diagnostico operacional + prompt pronto para nova janela do Codex
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
build-candidato-anterior: 20e400b-em-homologacao
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork)
solicitante: Luis Mauricio Junqueira Zanin
documentos-irmaos: auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md, auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md, auditoria/24_FECHAMENTO_V12_0203.md, auditoria/25_PLANO_HARDENING_POS_0203.md
---

# 26. Diagnostico do Looping do Codex e Prompt de Retomada

## 00. Veredito executivo (em 5 linhas)

O Codex avancou bem mais do que o `HANDOFF.md` registra: PE-02 ja esta
commitado, PE-03/PE-05/PE-06/PE-07 estao em working tree (`git status`
lista 8 arquivos modificados nao commitados). O looping nao e por
falha de codigo — e por **dessincronia entre nomes canonicos esperados
no codigo e os controles existentes no `.frx` do designer**. O usuario ja
comecou a ajustar o designer (`incoming/vba-forms/Configuracao_Inicial.frm`
chegou em 27/04 com `Label49` novo), mas o ciclo "renomear no Excel ->
reexportar -> commitar" nao fechou. Para a regra nova de suspensao por
contagem de avaliacoes ruins, faz sentido **uma passada cirurgica do Opus**:
e uma frente isolada (Util_Config + Svc_Avaliacao + Repo_Avaliacao + 1
cenario novo) que NAO depende do gap de UI.

## 01. O que o Codex realmente fez (estado real do `git`)

### 01.1 Commits ja no log (branch `codex/v12-0-0203-governanca-testes`)

| Commit | Mensagem | Cobre |
|---|---|---|
| `f7aa84f` | chore: localize build state labels | textos de UI |
| `2db7f1d` | test: add deterministic filter helper suite | **PE-02** (Util_Filtro_Lista) |
| `3b685ce` | docs: index post-0203 hardening plan | indexou parecer 25 |
| `49913ea` | chore: checkpoint v12.0.0203 validation hardening | checkpoint validador |
| `20e400b` | docs: anchor v12.0.0203 stabilization checkpoint | doc 22 |
| `88107f1` | fix: avoid direct menu instance call in v2 navigation | base estavel |

### 01.2 Working tree nao commitado

```text
modified:   src/vba/Cadastro_Servico.frm     <- PE-05 (plug helper)
modified:   src/vba/Credencia_Empresa.frm    <- PE-06 (renomear TextBox canonico)
modified:   src/vba/Menu_Principal.frm       <- PE-06 (5 filtros + Rodizio_RecarregarAtribuicao)
modified:   src/vba/Preencher.bas            <- PE-07 (CNAE Dry-Run, +385 linhas)
modified:   src/vba/Reativa_Empresa.frm      <- PE-03 (plug helper)
modified:   src/vba/Teste_V2_Engine.bas      <- helpers para PE-02/PE-07
modified:   src/vba/Teste_V2_Roteiros.bas    <- suite FLT_* ampliada
modified:   src/vba/Util_Filtro_Lista.bas    <- ampliado com busca por digitos

Untracked:
  auditoria/evidencias/V12.0.0203/ValidacaoRelease_V12_0_0203_VR_20260427_025031.csv
```

### 01.3 Mapeamento contra o backlog do parecer 25

| PE | Status real | Observacao |
|---|---|---|
| PE-01 fechamento limpo + tag `v12.0.0203` | NAO FEITO | `App_Release.bas` ainda em V12.0.0202; sem tag |
| PE-02 Util_Filtro_Lista | FEITO + AMPLIADO | commit + ampliacao em working tree |
| PE-03 Reativa_Empresa | EM WORKING TREE | usa fallback canonico-or-legado |
| PE-04 Reativa_Entidade | NAO FEITO | unico arquivo das 4 telas que ficou de fora |
| PE-05 Cadastro_Servico | EM WORKING TREE | usa fallback canonico-or-legado |
| PE-06 Menu_Principal (5 filtros) | EM WORKING TREE | conectou nomes canonicos para Empresa/Servico/Rodizio/CadServ + helper UI_TextoFiltro + Rodizio_RecarregarAtribuicao |
| PE-07 CNAE Dry-Run | EM WORKING TREE | `ResetarECarregarCNAE_Padrao_DryRun()` + `RPT_CNAE_DIFF` (340+ linhas em Preencher.bas) |
| PE-08 CNAE snapshot CAD_SERV | NAO FEITO | proximo natural |
| PE-09 CNAE dedup garantido | NAO FEITO | depende de PE-08 |
| PE-10 CS_25 E2E credenciamento | NAO FEITO | proximo cenario aditivo |
| PE-11..16 | NAO FEITO | nao iniciados |

### 01.4 Drop em `local-ai/incoming/vba-forms/`

Hoje a pasta tem **so** `Configuracao_Inicial.frm` + `.frx`, atualizados
em 2026-04-27 10:46. O diff mostra:

- `Label49_Click()` vazio adicionado -> **um Label novo foi criado no
  designer**, e o usuario clicou nele duas vezes (gerou handler vazio);
- `.frx` cresceu de `353304` -> `354328` bytes -> **conteudo binario do
  designer mudou** (controle novo, propriedades novas);
- mudancas de capitalizacao (`Caption` -> `caption`, `TypeName` ->
  `typeName`) sao normais quando o VBA reexporta apos clique no designer.

Isso confirma que o usuario ja iniciou no Excel a preparacao do campo
novo de configuracao (provavelmente para "max avaliacoes abaixo de 4
antes da suspensao").

## 02. Causa raiz do looping

O Codex fez exatamente o que o parecer 25 mandou para PE-02..PE-07. O
**gargalo nao e tecnico, e operacional**:

1. PE-03..PE-06 dependem de **renomear TextBox no designer** para os
   nomes canonicos (`TxtFiltro_Empresa`, `TxtFiltro_RodizioServico`,
   `TxtFiltro_RodizioEntidade`, `TxtFiltro_CadServ`,
   `TxtFiltro_CredenciamentoServico`, `TxtFiltro_CadastroServicoAtividade`,
   `TxtFiltro_ReativaEmpresa`).
2. Hoje o codigo busca **canonico primeiro, com fallback legado** (linhas
   tipo `If mTxtFiltroEmpresa Is Nothing Then Set ... = "TextBox17"`).
   Funciona, mas o gate de validacao do PE so fecha quando o canonico
   existe e o fallback some.
3. A unica forma de fechar e: o usuario abrir o `.xlsm`, renomear cada
   TextBox no designer, exportar `.frm/.frx` para
   `local-ai/incoming/vba-forms/`, Codex sincroniza o `src/vba/`,
   reimporta no Excel e roda o trio minimo.
4. O Codex provavelmente entrou em looping tentando **adicionar mais
   fallbacks** ou **inferir nomes de controle** sem ter o `.frx` real,
   porque o ciclo de UI nao fechou.

A confirmacao e que PE-07 (CNAE Dry-Run, que NAO toca em UI) avancou
sem problema; e PE-04 (Reativa_Entidade), que e a unica tela cujo
designer **ainda nao foi tocado pelo usuario** no `incoming/`, ficou
de fora.

## 03. Recomendacao: Codex ou Opus?

### 03.1 Continuar com Codex em microevolucoes

Vale para tudo que **toca formulario** ou **exige reexportacao do
.frx**, porque cada PE precisa do ciclo "renomear no designer ->
exportar para incoming -> publicar pacote -> reimportar -> rodar trio
minimo". Codex faz isso bem em ciclos curtos com aprovacao humana.
Itens que se beneficiam: PE-01, PE-03, PE-04, PE-05, PE-06.

### 03.2 Salto cirurgico com Opus em uma passada

Vale para frentes que sao **isoladas, sem mexer em formulario,
testaveis sem reexportacao do .frx**. Opus pode entregar o pacote
fechado: codigo + cenario novo + doc, em arquivos pequenos e numerados,
para o operador apenas reimportar e validar.

A regra nova de suspensao por contagem de avaliacoes ruins se encaixa
**perfeitamente** nesse perfil: e regra de negocio em
`Util_Config.bas` + `Svc_Avaliacao.bas` + um helper novo, sem tocar em
formulario, sem mexer em `Mod_Types.bas`, sem reexportar `.frx`, com
gate de teste claro (cenarios `CS_AVAL_*`).

### 03.3 Decisao recomendada

| Frente | Onde executar | Motivo |
|---|---|---|
| Regra nova de suspensao por contagem de notas ruins | **Opus em uma passada** | nao toca UI, nao toca Mod_Types, e isolada |
| PE-01 fechamento da V12.0.0203 (tag) | Codex | exige confirmacao humana + criar tag |
| Renomeacao final dos TextBox + reexportar `.frx` | **Humano + Codex** | so o operador consegue fazer no Excel |
| PE-04 Reativa_Entidade (espelho do PE-03) | Codex | depende do designer da Reativa_Entidade |
| PE-08, PE-09 (CNAE snapshot e dedup) | Opus em uma passada | isolado em Preencher.bas, sem UI |
| PE-10 CS_25 E2E | Opus em uma passada | cenario aditivo, sem UI |

## 04. O que Opus entrega em UMA passada (previsao)

A passada abaixo cabe em uma sessao unica. Todos os arquivos sao
pequenos, isolados, e o operador valida com o trio minimo.

### 04.1 Pacote da regra de suspensao por contagem de notas ruins

**Frente: PE-NEW-01 — Suspensao por contagem configuravel de notas baixas**

**Diagnostico da regra atual.** Hoje, em `Svc_Avaliacao.AvaliarOS`
(linha 369-372), a empresa e suspensa **na primeira avaliacao** com
`media < GetNotaMinimaAvaliacao()` (default 5). A nova regra deve
trocar isso por:

> Suspender so quando a quantidade acumulada de avaliacoes com media
> abaixo de um limite configuravel (ex: 4) atingir um teto configuravel
> (ex: 3 strikes), dentro de uma janela opcional (ex: ultimas 12
> avaliacoes ou ultimos 12 meses).

**Arquivos que mudam:**

1. `src/vba/Const_Colunas.bas` — adicionar duas constantes novas:
   - `Public Const COL_CFG_NOTA_CORTE_STRIKE As Long = 12` (coluna L)
   - `Public Const COL_CFG_MAX_STRIKES As Long = 13` (coluna M)
2. `src/vba/Util_Config.bas` — adicionar 2 funcoes publicas novas:
   - `GetNotaCorteStrike() As Double` (default 4.0)
   - `GetMaxStrikes() As Long` (default 3)
   - **NAO mexer em `TConfig`** (manter regra: nao tocar Mod_Types).
3. `src/vba/Repo_Avaliacao.bas` — adicionar `ContarStrikesPorEmpresa(EMP_ID, notaCorte) As Long` que varre `RESULTADO_AVALIACAO` (ou aba equivalente) e conta avaliacoes com `MEDIA < notaCorte` em janela opcional.
4. `src/vba/Svc_Avaliacao.bas` — substituir o bloco "7b" por:

   ```vba
   ' 7b. Regra: suspender so apos N strikes abaixo da nota de corte.
   Dim notaCorte As Double
   Dim maxStrikes As Long
   Dim strikesAtuais As Long
   notaCorte = GetNotaCorteStrike()
   maxStrikes = GetMaxStrikes()
   If media < notaCorte Then
       strikesAtuais = Repo_Avaliacao.ContarStrikesPorEmpresa(os.EMP_ID, notaCorte)
       ' strikesAtuais ja inclui a avaliacao recem-inserida.
       RegistrarEvento _
           EVT_AVALIACAO, ENT_EMP, os.EMP_ID, _
           "STRIKES=" & CStr(strikesAtuais - 1), _
           "STRIKES=" & CStr(strikesAtuais) & "; CORTE=" & Format$(notaCorte, "0.00") & _
           "; MAX=" & CStr(maxStrikes), _
           "Svc_Avaliacao"
       If strikesAtuais >= maxStrikes Then
           resSusp = Suspender(os.EMP_ID)
       End If
   End If
   ```

5. `src/vba/Configuracao_Inicial.frm` — adicionar gravacao das duas
   colunas novas no `B_Parametros_Click` (espelho do que ja faz para
   `MAX_RECUSAS`). O usuario ja preparou o Label49 no designer; basta
   ler `NotaCorteStrike` e `MaxStrikes` e gravar nas colunas L e M.
   **Esse passo precisa do `.frx` reexportado pelo usuario** com os
   TextBox de fato renomeados — e o unico ponto onde a passada do
   Opus depende do humano.
6. `src/vba/Teste_V2_Roteiros.bas` — adicionar familia `CS_AVAL_*`:
   - `CS_AVAL_001` — primeira avaliacao ruim NAO suspende (`OK`)
   - `CS_AVAL_002` — duas avaliacoes ruins NAO suspendem
   - `CS_AVAL_003` — terceira avaliacao ruim suspende
   - `CS_AVAL_004` — avaliacao boa entre duas ruins NAO zera contador
     (decisao de produto: registrar essa decisao na doc)
   - `CS_AVAL_005` — `MAX_STRIKES = 1` reproduz o comportamento atual
     (compatibilidade com a logica antiga via parametrizacao)
7. `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md` — adicionar regra
   nova **R-60** "Suspensao por contagem de notas baixas" e atualizar
   **R-35** para citar que ela agora opera com strikes parametrizados.
8. `docs/testes/INDEX.md` — apontar a nova familia `CS_AVAL_*`.
9. `CHANGELOG.md` — entrada `[Unreleased]` -> "regra de suspensao por
   contagem configuravel de notas baixas, com defaults `NOTA_CORTE=4`
   e `MAX_STRIKES=3`, retro-compativel via `MAX_STRIKES=1`".

**Risco:** baixo a medio. A unica fronteira sensivel e `Repo_Avaliacao`,
que precisa de varredura confiavel da aba de avaliacoes. Se a aba nao
existir ainda, criar tambem o helper `Repo_Avaliacao.GarantirAbaResultado`.

**Gate de teste:** trio minimo + 5 cenarios novos `CS_AVAL_*` verdes.

**Criterio de aceite:** `MAX_STRIKES = 1` reproduz comportamento atual
(prova de retro-compatibilidade); `MAX_STRIKES = 3` exige 3 reprovacoes
para suspender.

### 04.2 PE-08 + PE-09 (CNAE snapshot + dedup)

**Frente: PE-08 + PE-09**

- adicionar em `Preencher.bas`, antes da `LimparCadServParaAssociacaoManual`,
  copia de `CAD_SERV` para `CAD_SERV_SNAPSHOT_<timestamp>`;
- adicionar evento `CNAE_RESET_INICIADO` e `CNAE_RESET_CONCLUIDO` em
  `Audit_Log.bas` (nova constante);
- no fim da `ResetarECarregarCNAE_Padrao`, validar contagem distinta
  versus contagem total e abortar (com restauracao a partir do snapshot)
  se houver duplicata;
- novo cenario `CNAE_001` (snapshot existe) e `CNAE_002` (dedup zero).

**Risco:** baixo. Aditivo, com snapshot reversivel.

**Gate:** trio minimo + `CNAE_001` + `CNAE_002`.

### 04.3 PE-10 (CS_25 E2E credenciamento)

**Frente: PE-10**

- novo cenario em `Teste_V2_Roteiros.bas` que executa, em sequencia
  determinastica, `CadastrarEntidade` -> `CadastrarEmpresa` ->
  `CadastrarAtividade` -> `CadastrarServico` -> `Credenciar` ->
  `Svc_Rodizio.SelecionarEmpresa`;
- 6 asserts: empresa indicada e a credenciada, fila tem 1 entrada,
  AUDIT_LOG tem `RODIZIO_INDICOU`, `STATUS_CRED = ATIVO`,
  posicao 1, sem duplicidade.

**Risco:** baixissimo. Cenario aditivo. Reaproveita helpers `TV2_*`.

**Gate:** V2 Canonica continua verde + `CS_25` verde.

### 04.4 Total da passada Opus

3 frentes, 1 sessao, ~10 arquivos tocados (4 codigo + 3 teste + 3 doc),
1 unico ponto de dependencia humana (reexportar `Configuracao_Inicial.frx`
com TextBox renomeados).

## 05. Prompt completo para nova janela do Codex

> Cole o bloco abaixo em uma nova sessao do Codex. Ele assume contexto
> zero, da o estado real do branch, e foca em fechar PE-04 + reexportar
> `.frx` faltantes + commit limpo. A frente da regra de suspensao
> deve ser feita por Opus em paralelo, conforme item 04.1.

```text
Voce esta retomando a esteira de microevolucoes do projeto Excel/VBA
Credenciamento, branch `codex/v12-0-0203-governanca-testes`. A sessao
anterior travou e perdeu contexto. Antes de qualquer mudanca, leia
estes arquivos NESSA ORDEM:

1. local-ai/root/HANDOFF.md
2. auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md
3. auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md
4. auditoria/24_FECHAMENTO_V12_0203.md
5. auditoria/25_PLANO_HARDENING_POS_0203.md
6. auditoria/26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md (este)
7. local-ai/vba_import/README.md

Estado real do branch (verificar com `git status` e `git log -10`):

- Ultimo commit: f7aa84f "chore: localize build state labels"
- 8 arquivos modificados nao commitados:
  src/vba/Cadastro_Servico.frm, Credencia_Empresa.frm, Menu_Principal.frm,
  Preencher.bas, Reativa_Empresa.frm, Teste_V2_Engine.bas,
  Teste_V2_Roteiros.bas, Util_Filtro_Lista.bas
- 1 arquivo untracked:
  auditoria/evidencias/V12.0.0203/ValidacaoRelease_V12_0_0203_VR_20260427_025031.csv
- Drop do operador em local-ai/incoming/vba-forms/Configuracao_Inicial.frm
  + .frx (data 2026-04-27 10:46) — contem novo Label49, indicio de que
  o usuario adicionou um campo no designer da Configuracao Inicial.

Regras de execucao (NAO QUEBRAR):

- 1 microevolucao por vez (1 a 3 arquivos por commit);
- compilacao limpa antes de qualquer commit;
- gate de teste obrigatorio: V1 rapida + V2 Smoke + V2 Canonica;
- NAO tocar em src/vba/Mod_Types.bas;
- NAO reescrever src/vba/Importador_VBA.bas;
- NAO renomear nenhum VB_Name;
- nao alterar src/vba/App_Release.bas para "OFICIAL" antes do PE-01;
- a fonte de verdade e src/vba/, e local-ai/incoming/vba-forms/ NAO e
  origem de import — e referencia do workbook real.

Sua sequencia obrigatoria nesta sessao (parar e pedir aprovacao humana
antes de avancar para a proxima):

PASSO 1 — Higiene do estado atual.
- Rodar `git diff --stat` e me mostrar.
- Confirmar que os 8 arquivos modificados implementam PE-02 ampliado,
  PE-03 (Reativa_Empresa), PE-05 (Cadastro_Servico), PE-06
  (Menu_Principal + Credencia_Empresa) e PE-07 (CNAE Dry-Run em
  Preencher.bas).
- Pedir ao operador para abrir o workbook de homologacao, importar o
  pacote em local-ai/vba_import/ (rodar `bash
  local-ai/scripts/publicar_vba_import.sh` antes), compilar e rodar
  Teste_Validacao_Release.CT_ValidarRelease_TrioMinimo. Se passar,
  arquivar o CSV de evidencia e commitar os 8 arquivos em ate 3 commits
  semanticos:
    a) `feat(filtros): canonical names + helper plug for empresa,
       servico, rodizio, cad_serv, credenciamento, reativa_empresa,
       cadastro_servico` (formularios + Menu_Principal)
    b) `feat(filtros): expand Util_Filtro_Lista with digit-only fallback`
    c) `feat(cnae): add ResetarECarregarCNAE_Padrao_DryRun and diff
       report` (Preencher.bas + helpers de teste)

PASSO 2 — PE-04 Reativa_Entidade.frm (espelho do PE-03).
- Padrao identico ao PE-03: declarar `mTxtBusca`, no `UserForm_Initialize`
  buscar primeiro `TxtFiltro_ReativaEntidade` e cair em fallback legado.
- Conectar `mTxtBusca_Change` para chamar
  `UI_PreencherListaEntidadesInativas(mTxtBusca.Text)`.
- Esse PE NAO precisa de reexportar designer agora — o codigo cai no
  fallback legado se TxtFiltro_ReativaEntidade nao existir.
- Gate: trio minimo verde.
- Commit: `feat(filtros): plug Util_Filtro_Lista in Reativa_Entidade`

PASSO 3 — Pedir reexportacao dos `.frx` ao operador.
- Para cada formulario que recebeu nome canonico, instruir o operador
  a abrir o designer no Excel, RENOMEAR (propriedade Name, NAO mudar
  nada mais) os TextBox legados:
    Reativa_Empresa: TextBox16 -> TxtFiltro_ReativaEmpresa
    Reativa_Entidade: TextBox?? -> TxtFiltro_ReativaEntidade (descobrir
      indice atual antes)
    Cadastro_Servico: TextBox topo direita -> TxtFiltro_CadastroServicoAtividade
    Menu_Principal pagina Empresa: TextBox17 -> TxtFiltro_Empresa
    Menu_Principal pagina Rodizio: TextBox18 -> TxtFiltro_RodizioServico,
      TextBox22 -> TxtFiltro_RodizioEntidade
    Menu_Principal pagina CAD_SERV: TextBox?? -> TxtFiltro_CadServ
- Apos a renomeacao, exportar cada formulario via VBE > File > Export
  e colocar `.frm` + `.frx` em local-ai/incoming/vba-forms/.
- Voce sincroniza o `.frm` para `src/vba/` (so o `.frm`, nunca editar
  `.frx` a mao) e remove os fallbacks legados em UM commit por
  formulario.
- Gate: trio minimo + cenario assistido por formulario (ASS_*_FILTRO).

PASSO 4 — PE-01 fechamento da V12.0.0203.
- So depois de tudo acima verde:
  a) atualizar src/vba/App_Release.bas para
     APP_RELEASE_ATUAL = "V12.0.0203", APP_RELEASE_STATUS = "VALIDADO",
     APP_RELEASE_CANAL = "OFICIAL", APP_RELEASE_EVIDENCE_DIR =
     "auditoria/evidencias/V12.0.0203/";
  b) atualizar obsidian-vault/releases/STATUS-OFICIAL.md (V12.0.0203 ->
     VALIDADA, V12.0.0202 -> SUPERADA);
  c) criar obsidian-vault/releases/V12.0.0203.md;
  d) mover bloco [Unreleased] do CHANGELOG.md para
     [V12.0.0203] - 2026-04-27;
  e) atualizar obsidian-vault/00-DASHBOARD.md;
  f) PEDIR confirmacao humana antes de criar tag `v12.0.0203`.

PASSO 5 — Atualizar HANDOFF.md.
- Editar local-ai/root/HANDOFF.md com data atual, build final,
  resultado do trio minimo, lista de PEs concluidos e proximo passo
  (PE-08, PE-09, PE-10 ou regra nova de suspensao por strikes — Opus
  cuida desta ultima em paralelo).

NAO FACA, sem aprovacao humana explicita:
- mexer em Mod_Types.bas;
- alterar a logica do rodizio;
- reescrever importador automatico;
- renomear VB_Name de qualquer modulo/form;
- abrir nova frente arquitetural antes do trio minimo verde;
- iniciar a regra nova de suspensao por strikes (Claude Opus ja vai
  entregar essa frente em pacote separado, via auditoria/27_*.md).

Se nao tiver certeza de algo, pare e pergunte. Nao adicione fallbacks
adicionais sem necessidade comprovada.
```

## 06. Pre-requisitos para a passada do Opus (regra de strikes)

Antes que Opus entregue o pacote da secao 04.1, e desejavel que o
operador confirme:

1. existe (ou Opus pode criar) uma aba ou estrutura confiavel para
   contar avaliacoes ruins por empresa — recomendado usar varredura de
   `RESULTADO_AVALIACAO`/`AUDIT_LOG` por `EMP_ID` filtrando
   `MEDIA_NOTAS < notaCorte`;
2. defaults aceitos: `NOTA_CORTE = 4.0`, `MAX_STRIKES = 3`;
3. politica do contador: **acumulativo** (nao zera com avaliacao boa),
   **sem janela temporal** na primeira versao (decisao de produto a
   ser registrada no CHANGELOG);
4. retro-compatibilidade: com `MAX_STRIKES = 1` o sistema reproduz a
   logica atual (1 strike => suspende). Esse cenario sera o `CS_AVAL_005`.

Se algum desses pontos exigir decisao diferente, sinalizar antes da
passada do Opus.

## 07. Conclusao operacional

- Codex nao esta tecnicamente travado: ele avancou PE-02..PE-07
  corretamente, mas perdeu o foco no gap UI ↔ codigo.
- Recomeco com Codex deve ser pelo PASSO 1 do prompt (commit higienico
  do trabalho ja feito) antes de qualquer coisa nova.
- Em paralelo, Opus pode entregar em uma unica passada a regra de
  suspensao por contagem de notas baixas (item 04.1), que e isolada e
  nao depende do gap de UI.
- PE-08, PE-09 e PE-10 tambem podem virar uma segunda passada de Opus
  se o operador preferir velocidade (todos sao isolados).
- A unica fronteira que continua exigindo o ciclo Codex+humano e a
  reexportacao dos `.frx` apos renomeacao no designer, tarefa que
  Opus nao consegue executar do desktop.
