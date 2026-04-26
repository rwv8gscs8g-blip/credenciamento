---
titulo: Plano de Hardening Pos-Estabilizacao da V12.0.0203
natureza-do-documento: plano executivo de microevolucoes, mapa tela a tela, simulador UI, matriz de cobertura, redesign assistidos, doc narrada e backlog Codex
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
build-candidato-atual: 20e400b-dirty
data: 2026-04-26
autor: Claude Opus 4.7 (sessao Cowork)
solicitante: Luis Mauricio Junqueira Zanin
documentos-irmaos: auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md, auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md, auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md, auditoria/24_FECHAMENTO_V12_0203.md
escopo: planejamento, sem edicao de codigo, sem refatoracao ampla, sem alterar Mod_Types, sem unificacao fisica V1/V2, sem reescrever importador automatico
---

# 25. Plano de Hardening Pos-Estabilizacao da V12.0.0203

> Este documento e um plano executivo. Ele assume que a `V12.0.0203` esta em
> fase de fechamento (auditoria 24, build candidato `20e400b-dirty`, trio
> minimo verde, validador consolidado `APROVADO`) e organiza o trabalho que
> vem **antes, durante e depois** da promocao oficial. O documento foi escrito
> para ser executado por Codex em ciclos curtos, com aprovacao humana em cada
> gate. Nenhum codigo foi alterado nesta rodada.

## 00. Veredito executivo

A linha `0203` esta tecnicamente pronta para fechamento, mas apresenta
**tres pontos de atrito de estabilizacao** que merecem virar microevolucoes
controladas **antes** da abertura de qualquer frente arquitetural ampla:

1. **dependencia residual de filtros no `Menu_Principal.frm`** (cinco
   `WithEvents` de filtros para Empresa, Entidade, Servico, Rodizio e
   CAD_SERV, todos chamando `PreenchimentoXxx` com texto livre);
2. **risco operacional do reset de CNAE** (`Preencher.ResetarECarregarCNAE_Padrao`
   apaga `ATIVIDADES` antes de associacao e zera vinculos em `CAD_SERV` via
   `LimparCadServParaAssociacaoManual`, sem trilha auditavel);
3. **ausencia de teste end-to-end de credenciamento puro** ("uma empresa
   nova, uma atividade nova, um servico novo, um credenciamento, uma
   primeira indicacao") — cobertura existe via cenarios `CS_*`, mas nao
   ha um caminho automatizado que valide `Credencia_Empresa.frm` em
   superficie de UI.

Os outros sete pontos da demanda (relatorios, simulador UI, redesign
assistidos, doc narrada, unificacao fisica V1/V2, revisao de `Mod_Types`,
reescrita do importador, organizacao documental) sao reais e merecem ser
endereçados, mas com cadencia controlada e dependencia explicita nos
gates abaixo. O risco principal nao e tecnico — e de abrir frentes
demais em paralelo e perder a janela atual de "tudo verde".

A regra desta rodada e **uma microevolucao por vez, gate de teste por
microevolucao, decisao humana antes de avancar**. O backlog na secao 13
ja vem priorizado para Codex.

## 01. Premissas e fronteiras de trabalho

- a release oficial vigente continua sendo `V12.0.0202`;
- a release alvo continua sendo `V12.0.0203`, com fechamento pendente
  apenas de pacote limpo, reimportacao do `App_Release.bas` carimbado
  como `OFICIAL`, atualizacao de `STATUS-OFICIAL`, release note,
  `CHANGELOG`, tag e dashboard;
- nao tocar em `Mod_Types.bas` sem plano isolado documentado e aprovado;
- nao reescrever o importador automatico antes de o restante do hardening
  estabilizar; o importador ja causou erro `TConfig` historico e e tratado
  como frente isolada pos-hardening (secao 11);
- nao unificar fisicamente V1 e V2 antes de comparador, contrato semantico
  publicado e cobertura cruzada provada (secao 10);
- nenhuma microevolucao desta lista pode entrar sem trio minimo verde
  (V1 rapida, V2 Smoke, V2 Canonica) no build candidato resultante.

## 02. Estado real consolidado

| Eixo | Estado em 2026-04-26 |
|---|---|
| Compilacao | limpa no build `20e400b-dirty` |
| Bateria Oficial V1 rapida | `OK=171`, `FALHA=0`, `MANUAL=0` |
| V2 Smoke | `OK=14`, `FALHA=0`, `MANUAL=0` |
| V2 Canonica | `OK=20`, `FALHA=0`, `MANUAL=0` |
| Validador consolidado | `VR_20260426_111549`, `APROVADO` |
| Cobertura R-01..R-59 | 58/59 (R-48 transacao aninhada permanece teorica) |
| Documentacao narrada de testes | adiada para pos-0203 (parecer 23) |
| Frentes adiadas explicitamente | desacoplamento total, reescrita do importador, revisao de `Mod_Types`, redesign assistidos, padronizacao visual profunda dos relatorios, unificacao fisica V1/V2 |

Filtros vivos no `Menu_Principal.frm` e que sao alvo de desacoplamento:

- `mTxtFiltroRodizio` -> `PreenchimentoEntidadeRodizio(text)`;
- `mTxtFiltroServico` -> `PreenchimentoServico(text)`;
- `mTxtFiltroEmpresa` -> `PreenchimentoEmpresa(text)`;
- `mTxtFiltroEntidade` -> `PreenchimentoEntidade(text)`;
- `mTxtFiltroCadServ` -> `PreencherManutencaoValor(text)`.

Funcoes alvo do desacoplamento residem em `Preencher.bas` (3297 linhas) e
acessam diretamente as abas operacionais.

## 03. Plano executivo de microevolucoes (PE-NN)

A regra de cada item: **escopo de 1 a 3 arquivos**, gate de teste explicito,
arquivo provavel listado, criterio de aceite mensuravel.

### PE-01 Fechamento limpo da V12.0.0203 (gate-zero)

- Objetivo: regerar pacote sem `-dirty`, reimportar `App_Release.bas`,
  rodar validador consolidado, atualizar STATUS-OFICIAL/CHANGELOG/release
  note, criar tag `v12.0.0203`.
- Arquivos provaveis: `src/vba/App_Release.bas`,
  `obsidian-vault/releases/STATUS-OFICIAL.md`,
  `obsidian-vault/releases/V12.0.0203.md`, `CHANGELOG.md`,
  `auditoria/24_FECHAMENTO_V12_0203.md`,
  `auditoria/evidencias/V12.0.0203/MANIFEST.md`,
  `obsidian-vault/00-DASHBOARD.md`.
- Risco: baixo. Mexe apenas em metadado de release e em arquivos doc.
- Gate: validador consolidado `APROVADO` no build limpo + confirmacao
  humana antes da tag.
- Criterio de aceite: tag `v12.0.0203` publicada, `App_Release.bas` com
  `APP_RELEASE_ATUAL = "V12.0.0203"`, `APP_RELEASE_STATUS = "VALIDADO"`,
  `APP_RELEASE_CANAL = "OFICIAL"`, evidencia arquivada.

### PE-02 Helper unico de filtro deterministico (`Util_Filtro_Lista`)

- Objetivo: extrair de `Preencher.bas` um helper publico que normalize
  termo de busca (UCase + Trim + remocao de acento), aplique filtro a
  uma colecao em memoria e retorne array para alimentar `ListBox`.
- Arquivos provaveis: novo `src/vba/Util_Filtro_Lista.bas` (1 modulo
  novo, sem reescrever nenhum existente).
- Risco: baixo. Helper novo, ainda nao consumido por ninguem.
- Gate: compilacao limpa + V1 rapida + V2 Smoke verde.
- Criterio de aceite: helper expoe ao menos
  `Util_Filtro_Lista.Normalizar(text)`,
  `Util_Filtro_Lista.LinhaAtende(linhaConcatenada, termoNormalizado)`,
  `Util_Filtro_Lista.AplicarSobreMatriz(matriz, colsBusca, termo)` com
  testes unitarios determinasticos em `Teste_V2_Roteiros.bas` familia
  nova `FLT_*`.

### PE-03 Plug do helper de filtro em `Reativa_Empresa.frm`

- Objetivo: substituir, em uma so tela, a logica artesanal de filtro por
  chamada ao helper `Util_Filtro_Lista`.
- Arquivos provaveis: `src/vba/Reativa_Empresa.frm`.
- Risco: medio. Tela de homologacao critica historica.
- Gate: compilacao limpa + V1 rapida + V2 Smoke + cenario assistido novo
  `ASS_REATIVA_EMP_FILTRO`.
- Criterio de aceite: digitar `"abc"` no filtro produz a mesma lista
  determinastica que digitar `"ABC "` ou `"abç"`; teste assistido prova
  visualmente.

### PE-04 Plug do helper em `Reativa_Entidade.frm`

- Espelho de PE-03, em entidade.
- Arquivos provaveis: `src/vba/Reativa_Entidade.frm`.
- Gate identico ao PE-03 mais cenario `ASS_REATIVA_ENT_FILTRO`.

### PE-05 Plug do helper em `Cadastro_Servico.frm` (busca topo)

- Objetivo: usar `Util_Filtro_Lista` em `mTxtBuscaTopo_Change`.
- Arquivos provaveis: `src/vba/Cadastro_Servico.frm`.
- Gate identico mais cenario `ASS_CAD_SERV_FILTRO`.

### PE-06 Mover filtros do `Menu_Principal.frm` para o helper

- Objetivo: atualizar somente os 5 handlers `mTxtFiltro*_Change` para
  delegar normalizacao ao helper, **sem** mover `PreenchimentoXxx` ainda.
- Arquivos provaveis: `src/vba/Menu_Principal.frm`.
- Risco: medio-alto (e a tela mais sensivel).
- Gate: trio minimo + 5 cenarios `FLT_MENU_*` cobrindo os 5 filtros.
- Criterio de aceite: nenhum filtro perde linha esperada e nenhum produz
  linha duplicada.

### PE-07 CNAE: dry-run e diff antes do reset

- Objetivo: criar uma microevolucao em `Preencher.bas` que adiciona
  `Public Sub ResetarECarregarCNAE_Padrao_DryRun()` simulando todo o reset
  e gerando um relatorio `RPT_CNAE_DIFF` com:
  - quantidade de linhas atuais em `ATIVIDADES`;
  - quantidade de linhas a serem importadas;
  - quantos `CAD_SERV` perderiam vinculo;
  - lista resumida das atividades que seriam adicionadas/removidas.
- Arquivos provaveis: `src/vba/Preencher.bas`, alvo limitado a um Sub novo
  e um helper privado.
- Risco: baixo. Sub novo nao executa escrita.
- Gate: compilacao + V1 rapida + V2 Smoke.
- Criterio de aceite: chamar `ResetarECarregarCNAE_Padrao_DryRun()` em
  base canonica produz relatorio nao destrutivo.

### PE-08 CNAE: reset com snapshot de `CAD_SERV`

- Objetivo: adicionar etapa antes da `LimparCadServParaAssociacaoManual()`
  que copia `CAD_SERV` para `CAD_SERV_SNAPSHOT_YYYYMMDD_HHMMSS` e registra
  evento `CNAE_RESET_INICIADO` em `AUDIT_LOG`.
- Arquivos provaveis: `src/vba/Preencher.bas`,
  `src/vba/Audit_Log.bas` (apenas se for adicionar constante de evento;
  nao alterar logica).
- Risco: baixo, comportamento aditivo.
- Gate: compilacao + cenario `CNAE_001` em `Teste_V2_Roteiros.bas`
  validando snapshot existe e contagem antes/depois bate.
- Criterio de aceite: reset preserva snapshot reaproveitavel; auditoria
  registra inicio e fim com hash da contagem.

### PE-09 CNAE: deduplicacao garantida na importacao

- Objetivo: garantir que apos `ResetarECarregarCNAE_Padrao` nao exista
  par `(CNAE, DESCRICAO)` duplicado em `ATIVIDADES`.
- Arquivos provaveis: `src/vba/Preencher.bas`.
- Risco: baixo, ja escreve em aba limpa; vai endurecer com checagem
  pos-import.
- Gate: cenario `CNAE_002` validando duplicidade zero.
- Criterio de aceite: contagem distinta = contagem total apos reset.

### PE-10 Teste end-to-end determinastico de credenciamento

- Objetivo: novo cenario `CS_25_CREDENCIAMENTO_ENDtoEND` cobrindo:
  cadastro de entidade canonica, cadastro de empresa canonica, cadastro
  de atividade canonica via API direta, cadastro de servico via API
  direta, credenciamento da empresa na atividade-servico, primeira
  indicacao via `Svc_Rodizio.SelecionarEmpresa`, asserts de fila e
  auditoria.
- Arquivos provaveis: `src/vba/Teste_V2_Roteiros.bas`.
- Risco: baixo, cenario aditivo que reaproveita helpers `TV2_*`.
- Gate: V2 Canonica continua verde + novo cenario verde.
- Criterio de aceite: o cenario passa com `OK >= 6` asserts e zero falha.

### PE-11 Padronizacao incremental do rodape de relatorios

- Objetivo: validar que `Util_Config.Rel_ConfigurarPagina` ja produz
  rodape `<nome amigavel> | Pagina X de N | Ref <NOME_AUDITAVEL> | <release>`
  e ampliar para incluir hash curto do build (3 caracteres) na direita.
- Arquivos provaveis: `src/vba/Util_Config.bas`.
- Risco: baixo (apenas string do PageSetup).
- Gate: V1 rapida + V2 Smoke + cenario assistido `ASS_RELATORIO_RODAPE`.
- Criterio de aceite: impressao em `Rel_OSEmpresa` e `Rel_Emp_Serv`
  exibe rodape uniforme.

### PE-12 Exportacao automatica de PDF com nome controlado

- Objetivo: criar `Public Sub Rel_ExportarPDF(ByVal ws, ByVal titulo)`
  em `Util_Config.bas` que use `ExportAsFixedFormat(xlTypePDF)` com nome
  `Rel_NomeArquivoSugerido(titulo, "pdf")` em pasta padrao
  `<workbook>/relatorios/`.
- Arquivos provaveis: `src/vba/Util_Config.bas`,
  `src/vba/Rel_OSEmpresa.frm`, `src/vba/Rel_Emp_Serv.frm`.
- Risco: medio (envolve sistema de arquivos do usuario).
- Gate: V1 rapida + V2 Smoke + cenario assistido `ASS_PDF_EXPORT`.
- Criterio de aceite: PDF gerado com nome timestampado e log em
  `RPT_PDFs_EMITIDOS`.

### PE-13 Log de relatorios emitidos (`RPT_PDFs_EMITIDOS`)

- Objetivo: aba de log que registra (data/hora, titulo, nome de arquivo,
  caminho, build, usuario), preenchida sempre que `Rel_ExportarPDF` rodar.
- Arquivos provaveis: `src/vba/Util_Config.bas`.
- Risco: baixo.
- Gate: V1 rapida + V2 Smoke.
- Criterio de aceite: cada chamada gera linha no log.

### PE-14 Redesign minimo dos testes assistidos

- Objetivo: ver secao 06.
- Arquivos provaveis: `src/vba/Central_Testes_V2.bas`,
  `src/vba/Teste_V2_Engine.bas` (apenas helpers novos).
- Risco: medio.
- Gate: trio minimo + cenarios assistidos `ASS_*` ainda passam.

### PE-15 Simulador UI VBA deterministico (camada A)

- Objetivo: ver secao 05.
- Arquivos provaveis: novo `src/vba/Teste_UI_Simulador.bas`.
- Risco: medio.
- Gate: trio minimo + suite nova `UISIM_*` verde.

### PE-16 Documentacao narrada dos testes

- Objetivo: ver secao 07.
- Arquivos provaveis: `docs/testes/02..05.md`, `docs/testes/INDEX.md`.
- Risco: baixo (so doc).
- Gate: revisao humana.

## 04. Mapa tela a tela (formularios, controles, filtros, regra, alvo, teste)

A leitura de cada linha e: o que a tela tem hoje, qual servico/helper ela
deveria delegar e qual cenario de teste deve cobrir o desacoplamento.
Nao ha proposta de mover regra de negocio agora — o objetivo do mapa e
servir de roteiro para Codex.

### 04.1 `Menu_Principal.frm`

| Item | Hoje | Alvo proposto | Teste necessario |
|---|---|---|---|
| `mTxtFiltroRodizio_Change` | `PreenchimentoEntidadeRodizio(text)` | normalizar via `Util_Filtro_Lista` antes de chamar `PreenchimentoEntidadeRodizio` | `FLT_MENU_RODIZIO` |
| `mTxtFiltroServico_Change` | `PreenchimentoServico(text)` | igual | `FLT_MENU_SERVICO` |
| `mTxtFiltroEmpresa_Change` | `PreenchimentoEmpresa(text)` | igual | `FLT_MENU_EMPRESA` |
| `mTxtFiltroEntidade_Change` | `PreenchimentoEntidade(text)` | igual | `FLT_MENU_ENTIDADE` |
| `mTxtFiltroCadServ_Change` | `PreencherManutencaoValor(text)` | igual | `FLT_MENU_CADSERV` |
| `B_Empresa_Cadastro_Click` | abre `Credencia_Empresa.frm` | manter | `CS_25` (E2E) |
| `B_Emite_OS_Click` | dispara emissao Pre-OS via `Svc_PreOS.MontarParametrosEmissaoPreOS` + `Svc_PreOS.EmitirPreOS` | manter (ja desacoplado) | smoke V2 |
| `BE_ImprimeOS_Click` | renderiza OS na aba `RELATORIO` e chama PageSetup | mover formatacao para helper unico | `ASS_RELATORIO_RODAPE` |
| `AV_Lista_Click` / `AV_Vl_OS_AfterUpdate` | usa defaults de `MontarDefaultsAvaliacao` | manter | smoke V2 |

### 04.2 `Credencia_Empresa.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `mTxtFiltroCredLista_Change` | filtro artesanal sobre `CR_Lista` | usar `Util_Filtro_Lista` | `FLT_CRED_LISTA` |
| `CR_Credenciar_Click` | grava em `CREDENCIADOS` via leitura de `EMPRESAS`, `CAD_SERV`, `ATIVIDADES` | extrair `Svc_Credenciamento.RegistrarCredenciamento` em microevolucao futura (PE-17, opcional) | `CS_25_CREDENCIAMENTO_ENDtoEND` |
| `CR_Lista_Click` | popula campos a partir da linha selecionada | manter | `CS_25` |
| `ProximaPosicaoAtividade` | usa varredura sobre `CREDENCIADOS` para definir nova `POSICAO_FILA` | extrair para helper testavel `Svc_Credenciamento.ProximaPosicao(ativId)` | `CS_25` + cenario `STR_002` (stress) |

### 04.3 `Altera_Empresa.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `M_Alterar_Click` | edita `EMPRESAS` direto, com varios `Trim/Replace` para padronizar campos | extrair `Svc_CadastroEmpresa.AlterarDados(empresaId, payload)` (microevolucao futura) | novo `ALT_EMP_001` |
| `Empresa_InativarSelecionada` | move linha de `EMPRESAS` para `EMPRESAS_INATIVAS` em ate 524 linhas no formulario | extrair para `Svc_CadastroEmpresa.Inativar(empresaId)`; manter `Repo_Empresa` como repositorio | `CS_20` reforcado e `ALT_EMP_002` |
| `mBtnInativarEmpresa_Click` | atalho do botao de inativar | manter; passa a delegar ao serviço | mesmo |

### 04.4 `Reativa_Empresa.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `mTxtBusca_Change` | filtro artesanal | `Util_Filtro_Lista` | `FLT_REATIVA_EMP` |
| `RM_Lista_DblClick` | reativa empresa selecionada | extrair `Svc_CadastroEmpresa.Reativar(empresaId)` | `CS_23` reforcado |
| `UI_PreencherListaEmpresasInativas` | varredura linha a linha em `EMPRESAS_INATIVAS` | extrair query para `Repo_Empresa.ListarInativasFiltradas(filtro)` | `FLT_REATIVA_EMP` |
| `UI_EmpresaInativosTemConflito` | dedupe em UI | manter aqui por enquanto | `CS_23` |

### 04.5 `Altera_Entidade.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `B_Altera_Entidade_Click` | grava direto em `ENTIDADE` | extrair `Svc_CadastroEntidade.Alterar(payload)` (microevolucao futura) | `ALT_ENT_001` |
| `C_Inativa_Entidade_Click` | move para `ENTIDADE_INATIVOS` | extrair `Svc_CadastroEntidade.Inativar(id)` | `CS_24` reforcado |

### 04.6 `Reativa_Entidade.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `mTxtBusca_Change` | filtro artesanal | `Util_Filtro_Lista` | `FLT_REATIVA_ENT` |
| `R_Lista_DblClick` | reativa entidade | extrair `Svc_CadastroEntidade.Reativar(id)` | `CS_24` reforcado |

### 04.7 `Cadastro_Servico.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `mTxtBuscaTopo_Change` | filtro artesanal sobre `SV_Lista` | `Util_Filtro_Lista` | `FLT_CAD_SERV` |
| `S_Cadastrar_SV_Click` | mistura cadastro de atividade + servico, com `InputBox` para CNAE quando atividade nao existe | extrair fluxo de criacao de atividade para `Svc_Catalogo.CriarAtividadeMinima(cnae, descricao)` e fluxo de criacao de servico para `Svc_Catalogo.CriarServico(payload)` (microevolucoes futuras) | novo `CAT_001` (atividade + servico criadas) e `CAT_002` (servico duplicado rejeitado) |
| `S_Atividade_Change`/`AfterUpdate` | combo de atividade | manter | smoke V2 |
| `Descricao_SV_AfterUpdate` | normaliza descricao | manter | smoke V2 |

### 04.8 `Rel_Emp_Serv.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `SV_CR_Lista_Click` | gera relatorio em `RELATORIO`, configura PageSetup, oferece imprimir | adicionar opcao `Rel_ExportarPDF` apos render | `ASS_RELATORIO_PDF` |
| Limpeza pos-impressao | `wsRel.Range("A:D").ClearContents` | manter | smoke V2 |

### 04.9 `Rel_OSEmpresa.frm`

| Item | Hoje | Alvo | Teste |
|---|---|---|---|
| `B_RelEmpresaOS_Click` | imprime e limpa | adicionar opcao `Rel_ExportarPDF` antes de imprimir | `ASS_RELATORIO_PDF` |
| `RO_Lista_Click` | popula `RELATORIO` por empresa | manter | smoke V2 |

### 04.10 `Configuracao_Inicial.frm`, `Limpar_Base.frm`, `Fundo_Branco.frm`, `ProgressBar.frm`

- `Configuracao_Inicial.frm` carrega CNAE, define parametros, oferece backup.
  Alvo: encapsular `Carrega_CAD_SERV_Click` em `Svc_Catalogo.RecargaInicial`
  apenas em microevolucao futura. Teste alvo: `CAT_RECARGA_001`.
- `Limpar_Base.frm` chama `LimparBaseCompleta` (Funcoes.bas). Manter,
  isolar em microevolucao posterior.
- `Fundo_Branco.frm`, `ProgressBar.frm` sao utilitarios visuais; nao
  exigem mudanca neste plano.

## 05. Proposta tecnica do simulador UI (duas camadas)

A demanda de "simular cliques reais" tem duas leituras possiveis,
complementares, que devem ser entregues em ordem.

### 05.1 Camada A — Simulador VBA deterministico (curto prazo)

- Como funciona: um modulo `Teste_UI_Simulador.bas` capaz de instanciar
  formularios via `VBA.UserForms.Add("NomeDoForm")` e chamar diretamente
  os handlers publicos/empacotados (`UI_Simulador_DigitarFiltro`,
  `UI_Simulador_ClicarBotao`, `UI_Simulador_DuploClicarLista`).
- O simulador nao invoca o sistema operacional; ele invoca os mesmos
  pontos de entrada que o usuario aciona via mouse.
- Vantagens: deterministico, gravavel em `RESULTADO_QA_V2`, executavel
  em CI, nao depende de sessao interativa de Excel.
- Limitacoes: nao prova evento `MouseDown`/`KeyPress` real do Windows;
  prova fluxo de eventos VBA.
- Estrutura sugerida do modulo:

```vba
Public Sub UI_SIM_AbrirFormulario(ByVal nomeForm As String)
Public Sub UI_SIM_FecharFormulario(ByVal nomeForm As String)
Public Sub UI_SIM_DigitarTexto(ByVal nomeForm As String, ByVal nomeControle As String, ByVal texto As String)
Public Sub UI_SIM_ClicarBotao(ByVal nomeForm As String, ByVal nomeBotao As String)
Public Sub UI_SIM_SelecionarLinhaLista(ByVal nomeForm As String, ByVal nomeLista As String, ByVal indice As Long)
Public Sub UI_SIM_DispararChange(ByVal nomeForm As String, ByVal nomeControle As String)
Public Function UI_SIM_LerCelula(ByVal nomeAba As String, ByVal linha As Long, ByVal coluna As Long) As Variant
```

- Cenarios obrigatorios da suite `UISIM_*`:
  - `UISIM_001` abrir `Reativa_Empresa.frm`, digitar filtro, validar
    contagem;
  - `UISIM_002` abrir `Cadastro_Servico.frm`, digitar nova descricao,
    clicar `S_Cadastrar_SV`, validar nova linha;
  - `UISIM_003` abrir `Credencia_Empresa.frm`, simular fluxo completo
    de credenciamento.

### 05.2 Camada B — Automacao externa de clique real (medio prazo)

- Como funciona: script externo (PowerShell + UIAutomation, ou Python +
  `pywinauto`) abre o `.xlsm` de homologacao, espera o `Auto_Open`
  carregar, navega pelo `Menu_Principal`, executa cliques reais e
  registra resultado.
- Vantagens: prova o caminho que um operador real percorre, incluindo
  comportamento do `MsgBox`, `InputBox` e protecao de aba.
- Limitacoes: nao roda em CI sem maquina Windows; depende de Excel
  instalado; pode ser fragil entre versoes.
- Estrutura proposta do diretorio `local-ai/scripts/ui-automacao/`:

```text
local-ai/scripts/ui-automacao/
├── runner.ps1                # ponto de entrada
├── cenarios/
│   ├── 001_reativa_empresa.ps1
│   ├── 002_cadastro_servico.ps1
│   └── 003_credenciamento_e2e.ps1
├── helpers/
│   ├── excel_open_close.ps1
│   └── form_clicker.ps1
└── evidencias/
    └── <data>/<cenario>/screenshot.png
```

- Regra: os cenarios externos precisam ter equivalente na camada A.
  A camada B existe apenas para validar visualmente o que a camada A
  ja prova logicamente.

### 05.3 Decisao recomendada

Implementar a **camada A primeiro** (PE-15). A camada B vira backlog
formal apos a camada A estar verde por duas releases consecutivas.

## 06. Redesign dos testes assistidos

### 06.1 Diagnostico atual

- a Central V2 ja oferece `CT2_ExecutarSmokeAssistido` e
  `CT2_ExecutarStressAssistido`, mas o "assistido" hoje e apenas
  variante visual da execucao automatica;
- o operador nao tem painel proprio: ele ve a planilha pular para
  abas e perde o cursor;
- nao ha pausa explicita por cenario, nem botao "proximo cenario";
- o `RPT_TESTES_V2` e gerado ao final, nao ao vivo.

### 06.2 Proposta de redesign (UX + fluxo + evidencia)

| Bloco | Hoje | Proposto |
|---|---|---|
| Painel | ausente | novo formulario `Painel_Testes_Assistido.frm` com lista de cenarios, status por cenario, botao "executar proximo", botao "interromper" |
| Pausa | global por DoEvents | pausa por cenario com botao de avanco; `TV2_LogManual` ja registra |
| Visualizacao | planilha rola | painel mostra ultimo `assert`, `obtido` vs `esperado`, link "abrir aba de evidencia" |
| Evidencia | `RESULTADO_QA_V2` ao final | linha gravada ao vivo apos cada `TV2_LogAssert`, painel atualizado a cada 250 ms |
| Captura | manual | botao "exportar print" gera screenshot do painel + aba ativa em `evidencias/assistido/<data>/` |

### 06.3 Estrutura do painel

- `Lista_Cenarios` (ListBox): id, descricao, status (`PENDENTE`, `OK`, `FALHA`, `MANUAL`);
- `Lbl_Cenario_Atual`, `Lbl_Assert_Atual`, `Lbl_Esperado`, `Lbl_Obtido`;
- `Btn_Executar_Proximo`, `Btn_Interromper`, `Btn_Abrir_Evidencia`,
  `Btn_Exportar_Print`;
- `Lbl_Status_Geral` (`OK x / FAIL y / MANUAL z`).

### 06.4 Restricoes

- redesign **nao altera** a logica determinastica do motor `TV2_*`;
- redesign **adiciona** o painel como camada de apresentacao;
- a primeira versao deve servir Smoke e Canonica; Stress e segunda fase;
- nada disso entra antes de PE-01 (fechamento da 0203).

## 07. Documentacao narrada dos testes (proposta de padrao)

### 07.1 Padrao narrativo obrigatorio

Cada cenario, em qualquer familia, segue exatamente este formato:

```markdown
### CS_NN — <titulo curto>

**Leitura do cenario.** Uma frase explicando, em linguagem humana, o que
o teste prova e por que o projeto se importa com isso.

**Matriz de estado (pre-condicao).**
| Entidade | Campo | Valor |
|---|---|---|
| EMPRESAS | EMP_ID 001 | STATUS_GLOBAL = ATIVA |
| ATIVIDADES | ATIV_ID 001 | DESCRICAO = Pintura |

**Acao.** Verbo unico do dicionario canonico DI-02 (`EmitirPreOS`,
`AceitarPreOS`, etc.) com parametros explicitos.

**Resultado esperado.**
- assercao 1
- assercao 2
- evento de auditoria esperado em `AUDIT_LOG`

**Razao.** Qual regra (R-XX) o teste prova; qual regressao impede; por
que o cenario foi escolhido.

**Regra coberta.** R-XX, R-YY.

**Evidencia.**
- Aba: `RESULTADO_QA_V2`, filtro `cenarioId = CS_NN`
- Trilha cumulativa: `TESTE_TRILHA`, `AUDIT_TESTES`
- Relatorio: `RPT_TESTES_V2`
```

### 07.2 Distribuicao por documento

| Documento | Conteudo | Status |
|---|---|---|
| `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` | blocos `BO_*` da V1 | criar pos-0203 |
| `docs/testes/03_CATALOGO_SMOKE_V2.md` | `SMK_*`, `EXP_*`, `ATM_*`, `MIG_*`, `MUT_*` | criar pos-0203 |
| `docs/testes/04_CATALOGO_ASSISTIDOS.md` | UI-* e P01..P16 | criar pos-0203 |
| `docs/testes/05_DICIONARIO_INTERFACE.md` | DI-01..DI-04 | criar pos-0203 |
| `docs/testes/06_CATALOGO_CANONICO_V2.md` | `CS_00..CS_24` (referenciar e estender o ja existente em `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`) | criar pos-0203 |
| `docs/testes/07_CATALOGO_FILTROS.md` | `FLT_*` (gerados pelas microevolucoes PE-02..PE-06) | criar junto com PE-06 |
| `docs/testes/08_CATALOGO_CNAE.md` | `CNAE_*` (PE-08, PE-09) | criar junto com PE-09 |
| `docs/testes/09_CATALOGO_CREDENCIAMENTO.md` | `CS_25` E2E e `CAT_*` | criar junto com PE-10 |

### 07.3 Regras de ouro

- nao escrever doc narrada para teste que ainda nao esta verde;
- nao duplicar texto entre catalogos — usar `[ver ...]` para referencia;
- toda doc narrada deve citar a regra do `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md`;
- nenhum cenario novo entra em release sem entrada no catalogo correspondente.

## 08. Matriz de cobertura proposta (sete eixos)

A matriz abaixo lista, eixo a eixo, cenarios obrigatorios; marca o que ja
existe e o que vai ser produzido pelos `PE-*`.

### 08.1 Credenciamento

| Cenario | Status | Cria em |
|---|---|---|
| `CS_25_CREDENCIAMENTO_ENDtoEND` | criar | PE-10 |
| `FLT_CRED_LISTA` | criar | PE-06 |
| `ALT_EMP_001` (alterar dados) | adiar | pos-PE-10 |
| `ALT_EMP_002` (inativar e reativar) | reforco de `CS_20`/`CS_23` | PE-04, PE-06 |

### 08.2 CNAE

| Cenario | Status | Cria em |
|---|---|---|
| `CNAE_001` (snapshot antes do reset) | criar | PE-08 |
| `CNAE_002` (deduplicacao garantida) | criar | PE-09 |
| `CNAE_003` (CSV ausente) | adiar | pos-PE-09 |
| `CAT_001` (atividade nova + servico novo) | criar | PE-05 |
| `CAT_002` (servico duplicado rejeitado) | criar | PE-05 |

### 08.3 Rodizio

| Cenario | Status | Cria em |
|---|---|---|
| R-01..R-11 cobertos | feito (auditoria 21 secao 03) | manter |
| `STR_002` (1000 ciclos com PE-02 helper) | criar | apos PE-15 |

### 08.4 Pre-OS

| Cenario | Status | Cria em |
|---|---|---|
| R-12..R-25 cobertos | feito | manter |
| `EXP_002` (expiracao multipla) | adiar | pos-0203 |

### 08.5 OS

| Cenario | Status | Cria em |
|---|---|---|
| R-26..R-33 cobertos | feito | manter |

### 08.6 Avaliacao

| Cenario | Status | Cria em |
|---|---|---|
| R-34..R-43 cobertos | feito | manter |
| `AV_DEF_001` (defaults editados exigem justificativa) | reforcar `SMK_007` | adiar para PE-14 |

### 08.7 Relatorios

| Cenario | Status | Cria em |
|---|---|---|
| `ASS_RELATORIO_RODAPE` | criar | PE-11 |
| `ASS_RELATORIO_PDF` | criar | PE-12 |
| `RPT_LOG_001` (log de PDFs emitidos) | criar | PE-13 |

### 08.8 Inativacao/Reativacao

| Cenario | Status | Cria em |
|---|---|---|
| `CS_20`, `CS_23`, `CS_24` cobertos | feito | manter |
| reforco com `Util_Filtro_Lista` | criar | PE-03, PE-04 |

## 09. Organizacao documental (sem mover arquivo agora)

A leitura abaixo amplia o que o parecer 23 ja registrou. Esta secao foca
no que precisa **virar acao Codex** apos o fechamento da 0203, sem
movimentacao destrutiva nesta rodada.

### 09.1 Diagnostico atual

| Pasta | Estado | Acao recomendada (pos-0203) |
|---|---|---|
| `docs/` | publica, organizada, com `INDEX.md` | adicionar `docs/testes/06..09.md` conforme PE-* |
| `doc/` | dados brutos de CNAE | renomear para `docs/dados/cnae/` em microevolucao posterior, com auditoria de paths em `Preencher.bas` |
| `auditoria/` | publica, indexada | adicionar `25_PLANO_HARDENING_POS_0203.md` (este) ao `INDEX.md` |
| `obsidian-vault/` | publica, leve | atualizar dashboard apos cada microevolucao concluida |
| `local-ai/` | interna, gitignored | manter; adicionar `local-ai/auditoria/planos/MODELO_MICROEVOLUCAO.md` |
| `local-ai/incoming/vba-forms/` | referencia operacional | manter sem usar como fonte de import |
| `V12-202-*` na raiz | snapshots de homologacao | mover para `backups/homologacao/` em microevolucao posterior |

### 09.2 Arquivos a criar (lista completa, prioridade decrescente)

| Arquivo | Quando | Quem cria | Para que |
|---|---|---|---|
| `auditoria/25_PLANO_HARDENING_POS_0203.md` | agora | Claude Opus | este plano |
| `auditoria/26_BACKLOG_CODEX_PE_01..16.md` | proxima sessao | Claude Opus + Codex | backlog operacional, derivado da secao 13 |
| `local-ai/auditoria/planos/MODELO_MICROEVOLUCAO.md` | proxima sessao | Claude Opus | template do parecer 23 secao 07 |
| `docs/RELEASE_V12_0_0203.md` | apos PE-01 | Claude Opus | nota publica |
| `obsidian-vault/releases/V12.0.0203.md` | apos PE-01 | Codex + Opus | release note institucional |
| `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` | apos PE-01 | IA-doc | catalogo V1 |
| `docs/testes/03_CATALOGO_SMOKE_V2.md` | apos PE-01 | IA-doc | catalogo Smoke V2 |
| `docs/testes/04_CATALOGO_ASSISTIDOS.md` | apos PE-01 | IA-doc | catalogo assistidos |
| `docs/testes/05_DICIONARIO_INTERFACE.md` | apos PE-01 | IA-doc | dicionario |
| `docs/testes/06_CATALOGO_CANONICO_V2.md` | apos PE-01 | IA-doc | extensao da proposta canonica |
| `docs/testes/07_CATALOGO_FILTROS.md` | junto com PE-06 | Codex + IA-doc | familia FLT_* |
| `docs/testes/08_CATALOGO_CNAE.md` | junto com PE-09 | Codex + IA-doc | familia CNAE_* |
| `docs/testes/09_CATALOGO_CREDENCIAMENTO.md` | junto com PE-10 | Codex + IA-doc | CS_25 e CAT_* |
| `docs/SIMULADOR_UI_VBA.md` | junto com PE-15 | Claude Opus | manual da camada A |
| `docs/SIMULADOR_UI_EXTERNO.md` | quando camada B for aprovada | Claude Opus | manual da camada B |
| `docs/PADRAO_VISUAL_RELATORIOS.md` | junto com PE-11 e PE-12 | Claude Opus | padronizacao visual e PDF |
| `auditoria/27_PROPOSTA_REVISAO_MOD_TYPES.md` | apenas se humano autorizar | Claude Opus | plano isolado |
| `auditoria/28_PROPOSTA_REESCRITA_IMPORTADOR.md` | apenas se humano autorizar | Claude Opus | plano isolado |

### 09.3 Arquivos a consolidar/mover (somente apos aprovacao explicita)

- `doc/cnae-fonte-bruta/`, `doc/cnae-normalizado/` -> `docs/dados/cnae/...`
  (auditar paths em `Preencher.bas` antes; a constante de busca CSV
  precisa acompanhar);
- `V12-202-E..K/` -> `backups/homologacao/V12-202-X/` (ja gitignored);
- `local-ai/root/` -> `local-ai/handoff/` (renomeacao opcional).

Nenhuma movimentacao destrutiva nesta rodada.

## 10. Unificacao fisica V1 e V2 (decisao adiada com criterio objetivo)

A unificacao fisica permanece **adiada**. O parecer 21 ja explicou por
que e o parecer 23 reforcou. O criterio objetivo para abrir a frente e:

1. ter cobertura cruzada V1<->V2 publicada em
   `docs/testes/05_DICIONARIO_INTERFACE.md` e na matriz da auditoria 21;
2. ter um comparador estrutural automatizado (suite `CMP_*`) que prove,
   para cada regra R-XX coberta, que V1 e V2 produzem o mesmo veredito;
3. ter o simulador UI camada A verde por duas releases consecutivas;
4. ter aprovacao humana explicita.

Antes disso, a unificacao continua semantica e nao fisica. **Nenhuma
microevolucao deste plano cria a frente fisica.**

## 11. Revisao de `Mod_Types.bas` e reescrita do importador automatico

Permanecem como **frentes isoladas**, fora deste plano. Cada uma
exige plano dedicado, com criterios proprios:

### 11.1 Revisao de `Mod_Types.bas`

- so abrir se houver bug funcional confirmado em homologacao;
- plano em `auditoria/27_PROPOSTA_REVISAO_MOD_TYPES.md` (a criar);
- pre-requisitos: backup do `.xlsm`, snapshot de `Mod_Types.bas` real do
  workbook (`local-ai/incoming/vba-forms/Mod_Types.bas`), reproducao
  isolada do erro `TConfig` em workbook descartavel;
- gate: compilacao limpa em workbook recem-importado a partir do
  `Importador_VBA`.

### 11.2 Reescrita do importador automatico

- so abrir apos cobertura E2E em PE-10 e camada A do simulador UI estavel;
- plano em `auditoria/28_PROPOSTA_REESCRITA_IMPORTADOR.md` (a criar);
- pre-requisitos: catalogo completo de modulos atuais com hash, ordem
  determinastica de importacao publicada, teste de "import limpo a partir
  do zero" em workbook descartavel.

## 12. Riscos e mitigacoes

| Risco | Probabilidade | Impacto | Mitigacao |
|---|---|---|---|
| Abrir frentes em paralelo | alta | atrasa fechamento da 0203 | aplicar regra "uma microevolucao por vez" da secao 03 |
| Quebrar filtro do `Menu_Principal` ao mover handler para helper | media | regressao visivel | PE-02 entrega helper sem consumir; PE-06 so consome apos `Util_Filtro_Lista` ja estar verde por duas suites |
| `ResetarECarregarCNAE_Padrao` apagar `CAD_SERV` sem trilha | media | perda silenciosa de vinculo | PE-08 obriga snapshot de `CAD_SERV` antes da limpeza |
| `Rel_ExportarPDF` falhar por permissao de pasta | media | exportacao silenciosamente falha | PE-12 valida path, cria pasta `relatorios/` se nao existir, registra falha em `RPT_PDFs_EMITIDOS` |
| Simulador UI camada A induzir falsa confianca na camada B | baixa | regressao visual real escapa | secao 05.3 obriga camada A primeiro; camada B vira backlog formal |
| Painel assistido alterar logica determinastica | media | quebra de cobertura | regra na secao 06.4: painel **adiciona**, nao altera motor |
| Documentacao narrada divergir de codigo | baixa | doc envelhece | secao 07.3 proibe doc para teste nao verde |
| Renomear pasta `doc/` quebrar caminho de CSV | media | reset CNAE quebra | secao 09.3 obriga auditoria de paths em `Preencher.bas` antes do mv |
| Mexer em `Mod_Types.bas` sem plano | alta | erro `TConfig` historico | secao 11.1 exige plano dedicado e backup |
| Reescrever importador antes do hardening | alta | onda de regressao | secao 11.2 trava ate PE-10 + simulador A estaveis |

## 13. Backlog priorizado para Codex (executavel)

A sequencia abaixo e a ordem recomendada de execucao. Cada item assume
arvore limpa, branch de microevolucao curta, gate de teste obrigatorio
e atualizacao de `local-ai/root/HANDOFF.md` ao concluir.

| # | ID | Titulo | Esforco | Dependencias | Gate de teste | Criterio de aceite curto |
|---|---|---|---|---|---|---|
| 1 | PE-01 | Fechamento limpo da 0203 e tag `v12.0.0203` | M | nenhuma | trio minimo + validador consolidado APROVADO | tag publicada e App_Release.bas com OFICIAL |
| 2 | PE-02 | Helper `Util_Filtro_Lista` + suite `FLT_*` | S | PE-01 | trio minimo + suite FLT verde | helper publica 3 funcoes citadas |
| 3 | PE-07 | CNAE dry-run e diff (`RPT_CNAE_DIFF`) | S | PE-01 | trio minimo | sub novo nao destrutivo |
| 4 | PE-08 | CNAE snapshot de CAD_SERV antes do reset | M | PE-07 | trio minimo + CNAE_001 | snapshot existe e auditoria registra |
| 5 | PE-09 | CNAE deduplicacao garantida pos-import | S | PE-08 | trio minimo + CNAE_002 | duplicidade zero |
| 6 | PE-10 | Cenario E2E `CS_25_CREDENCIAMENTO_ENDtoEND` | M | PE-01 | V2 Canonica + CS_25 | OK >= 6 asserts |
| 7 | PE-03 | Plug helper em Reativa_Empresa.frm | M | PE-02 | trio minimo + ASS_REATIVA_EMP_FILTRO | filtro deterministico |
| 8 | PE-04 | Plug helper em Reativa_Entidade.frm | M | PE-02 | trio minimo + ASS_REATIVA_ENT_FILTRO | idem |
| 9 | PE-05 | Plug helper em Cadastro_Servico.frm | M | PE-02 | trio minimo + ASS_CAD_SERV_FILTRO | idem |
| 10 | PE-06 | Plug helper em Menu_Principal.frm (5 filtros) | M | PE-02..PE-05 | trio minimo + 5 cenarios FLT_MENU_* | nenhuma linha perdida |
| 11 | PE-11 | Padronizacao de rodape de relatorios | S | PE-01 | trio minimo + ASS_RELATORIO_RODAPE | rodape uniforme |
| 12 | PE-12 | Exportacao automatica de PDF | M | PE-11 | trio minimo + ASS_PDF_EXPORT | PDF gerado com nome timestampado |
| 13 | PE-13 | Log `RPT_PDFs_EMITIDOS` | S | PE-12 | trio minimo | linha registrada por chamada |
| 14 | PE-15 | Simulador UI camada A (`UISIM_*`) | L | PE-10 | trio minimo + UISIM_001..003 | 3 cenarios verdes |
| 15 | PE-14 | Painel assistido (`Painel_Testes_Assistido.frm`) | L | PE-15 | trio minimo + ASS_* ainda verdes | painel funcional sem alterar motor |
| 16 | PE-16 | Documentacao narrada dos testes (lote 02..06) | L | PE-01 | revisao humana | catalogos publicados |

Esforco: S = ate 2h de Codex; M = 2 a 6h; L = mais de 6h.

## 14. Decisao agora / adiar / autorizacao humana

### 14.1 Fazer agora (sem aprovacao adicional alem deste parecer)

- PE-01: fechamento limpo da 0203 e tag `v12.0.0203`;
- PE-02: helper `Util_Filtro_Lista` (modulo novo, sem consumir);
- PE-07: CNAE dry-run (sub novo, nao destrutivo);
- PE-10: cenario E2E `CS_25` (cenario novo, aditivo);
- inicio das doc narradas (`docs/testes/02..06.md`) em paralelo, **somente
  apos PE-01 publicar a tag**.

### 14.2 Adiar para apos PE-01

- PE-03 a PE-06 (consumo do helper de filtro nas 4 telas);
- PE-08, PE-09 (snapshot e deduplicacao CNAE com escrita);
- PE-11, PE-12, PE-13 (relatorios e PDF);
- PE-14, PE-15 (painel assistido e simulador UI);
- PE-16 (doc narrada).

### 14.3 Exige aprovacao humana explicita

- qualquer alteracao em `src/vba/Mod_Types.bas`;
- reescrita do importador automatico;
- qualquer movimentacao destrutiva de pastas (`doc/`, `V12-202-*`, etc.);
- abertura da frente de unificacao fisica V1/V2;
- abertura da frente da camada B do simulador UI (automacao externa).

## 15. Gates de teste por microevolucao

Para cada `PE-*` o ciclo Codex obrigatorio e:

1. branch curta `codex/pe-NN-descricao`;
2. um arquivo principal (no maximo tres);
3. compilacao limpa local;
4. `bash local-ai/scripts/publicar_vba_import.sh`;
5. reimportacao manual no workbook de homologacao (sempre carregar
   `AAX-App_Release.bas`);
6. confirmacao do build na tela `Sobre`;
7. trio minimo: V1 rapida + V2 Smoke + V2 Canonica;
8. `Teste_Validacao_Release.CT_ValidarRelease_TrioMinimo` (validador
   consolidado) e CSV em `auditoria/evidencias/V12.0.0203/`;
9. atualizacao de `local-ai/root/HANDOFF.md` com data, build, status,
   arquivo, proximo passo;
10. PR/commit + nota curta no `CHANGELOG.md` em `[Unreleased]`.

A regra `nenhum item passa para `feito` sem o passo 7 verde` nao admite
excecao.

## 16. Conclusao operacional

A janela atual e estreita e valiosa: tudo verde, ninguem editando codigo.
A primeira acao deve ser **PE-01**. Depois disso, o Codex executa os
itens 2 a 6 do backlog (helper de filtro, CNAE dry-run/snapshot/dedup, e
o E2E de credenciamento) — todos aditivos, baixo risco.

Os itens 7 a 10 (plug do helper nas telas) abrem a frente real de
desacoplamento, mas o fazem com uma rede de seguranca: o helper ja foi
provado por suite propria antes de ser conectado.

Os itens 11 a 13 entregam a primeira parcela visivel ao usuario externo
(rodape uniforme + PDF + log).

Os itens 14 e 15 sao a fundacao do redesign assistido e do simulador
UI; a partir dai, o projeto deixa de depender do operador para validar
fluxos de tela.

O item 16 (doc narrada) acompanha o ritmo das microevolucoes — escreve
quando o teste fica verde, nao antes.

Reescrita de importador, revisao de `Mod_Types`, unificacao fisica V1/V2
e camada B do simulador permanecem fora deste plano. Cada um tera seu
proprio parecer dedicado quando humano autorizar.

Bastao: **Codex** com aprovacao humana de Mauricio. Claude Opus
permanece em modo parecer/auditoria para cada bloco de microevolucoes,
sem editar codigo.
