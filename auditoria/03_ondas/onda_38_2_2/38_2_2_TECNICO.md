# Onda 38.2.2 — Quick wins + filtros nativos + envelopamento .frm (V206 em validação)

> **2026-05-27 04:30 BRT — Diretiva Mauricio:** removida palavra "FREEZE" do título. A onda 38.2.2 está **ENTREGUE PARCIAL** com findings abertos. **NÃO faremos freeze** até a Onda 38.2.3+ corrigir todos os pontos identificados em validação tela-a-tela. "FREEZE" só entrará no nome quando a release for homologada (tag `v12.0.0206`). Convenção a partir de agora: build label = `<HEAD>+ONDA<N>` ou `<HEAD>+ONDA<N>.fix<NN>`, **sem sufixo "FREEZE"** até homologação. Ver seção §10 "Findings abertos" + §11 "Roadmap até freeze V206".

**Versão alvo:** V12.0.0206 (em validação iterativa via ondas 38.2.N)
**Branch:** `codex/v12-0-0206-planejamento`
**Build label histórico (5 hotfixes):** `c9bcd41` → `f855d0b` → `88b347b` → `854c392` → `255d3bc` → `a51b191` (HEAD pós-onda 38.2.2)
**Agente:** Claude Opus 4.7 (sessão sucessora pós-handoff `20260526-1730`)
**Readback:** [`.hbn/readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json`](../../../.hbn/readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json)
**ERP esperado:** `.hbn/results/0111-exec-onda-38-2-2-v206-freeze.json`
**Predecessor:** Onda 38.2.1-AR1-FIX2-PERF (commit `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`)
**Anchor de rollback:** commit `179bac5` (HEAD pós-consolidação 2ª rodada V207)
**Anchor V206 funcional:** `ee75b30`

---

## 1. Motivação

Esta é a **última onda V206 puro** antes do freeze oficial. Mistura 5 alvos
atômicos pré-aprovados na 2ª rodada de auditoria cruzada
([`112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md`](../../00_status/112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md)):

- **Quick wins Codex** (itens 68 e 69) aprovados como compatíveis com V206 puro.
- **F-NEW3 sistemático** — formato textual da coluna A em todos os 4 cadastros
  que escrevem direto em `.frm` (origem detectada em
  `Menu_Principal.frm` linha original `1622`, ID `5` ao invés de `005`).
- **Filtros nativos** — reverte definitivamente a regressão da Onda 38.2.1
  (commit `e9bcf42` `revert filtros menu principal`) substituindo a
  descoberta heurística por handlers estáticos.
- **Envelopamento `.frm`** — estende `Util_Excel_Performance` (criado na
  FIX2-PERF para `Repo_Empresa`) aos cadastros UI restantes.

Mauricio aprovou em chat 2026-05-26 ~16:30 BRT: abrir a onda imediatamente
e seguir todos os passos até validação tela-a-tela e freeze V206, "conforme
cronograma já aprovado" em
[`auditoria/03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md:79`](../onda_38_2_filtros_menu_principal/38_2_TECNICO.md).
Readback `0111` confirmed às ~16:45 BRT.

A onda NÃO antecipa nenhuma decisão V207 (cache in-memory, `Svc_Cadastro*`,
ORM primitivo) — esses ficam para readbacks 0120+ pós-knowledges 0018/0019/0020.

---

## 2. Escopo

### Arquivos tocados

| Path | Operação |
|---|---|
| [`src/vba/Util_Planilha.bas`](../../../src/vba/Util_Planilha.bas) | nova `Util_MaxIdOperacional` pair-aware + `ProximoId` redirecionado |
| [`src/vba/Util_Sanear_Contadores.bas`](../../../src/vba/Util_Sanear_Contadores.bas) | handler-before-flag em `SanearContadoresAR1` |
| [`src/vba/Repo_Empresa.bas`](../../../src/vba/Repo_Empresa.bas) | handler-before-flag em 4 funções |
| [`src/vba/Preencher.bas`](../../../src/vba/Preencher.bas) | nova `Preencher_FiltrarPorBoxEstatico` (despacho centralizado dos 7 filtros) |
| [`src/vba/Menu_Principal.frm`](../../../src/vba/Menu_Principal.frm) | envelopamento entidade + empresa-alt + NumberFormat + 7 handlers estáticos |
| [`src/vba/Credencia_Empresa.frm`](../../../src/vba/Credencia_Empresa.frm) | envelopamento + NumberFormat no loop de credenciamento |
| [`src/vba/Cadastro_Servico.frm`](../../../src/vba/Cadastro_Servico.frm) | envelopamento + NumberFormat em 2 blocos (atividade + serviço) |
| `src/vba/App_Release.bas` | **NÃO tocado** (Knowledge 0016) |
| `local-ai/vba_import/001-modulo/A*-*.bas` | gerado por `publicar_vba_import_v2.sh --apply` |
| `local-ai/vba_import/002-formularios/A*-*.frm + .code-only.txt + .frx` | gerado por `--apply` (`frx_sync, code_only_gen`) |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-2-V206-FREEZE.txt` | manifesto criado |
| `local-ai/vba_import/000-MAPA-PREFIXOS.txt` | sem alteração (todas as entradas já existiam) |

### Fora de escopo (`non_goals` do readback 0111)

- `Svc_*` blindados (Rodizio, Avaliacao, OS, PreOS, Entidade, Transacao)
- `Mod_Types.bas` (intervenção planejada apenas para V207.0)
- `Importador_V3.bas` (BUMP_NO_OP fica para V208.7)
- `Auto_Open.bas`
- `Repo_OS`, `Repo_PreOS`, `Repo_Avaliacao`, `Repo_Credenciamento` (V207.5)
- 10 forms blindados: `Altera_*`, `Reativa_*`, `Configuracao_Inicial`,
  `Limpar_Base`, `Fundo_Branco`, `ProgressBar`, `Rel_Emp_Serv`, `Rel_OSEmpresa`
- `.frx` binários (atualização via `--apply` apenas)
- Renomear controles `TextBox16..22` no designer (débito V207)
- `PreencherPreencheOS` / `PreencherAvaliarOS` ganhando `Optional filtro`
  (débito V207 — implementação do filtro real)
- Implementação de `Svc_Cadastro*`, cache in-memory, E2E_CADASTROS (V207.x)

---

## 3. Alvos atômicos

### AT-1 — `Util_MaxIdOperacional` pair-aware (item 68 Codex, sev. ALTO)

**Problema:** `ProximoId` chamava `Util_MaxIdNaColunaA(nomeAba)` apenas na
aba ativa. Se uma empresa deletada virou inativa (transferida para
`EMPRESAS_INATIVAS` com ID preservado), um novo cadastro em `EMPRESAS`
poderia receber o ID já usado em `EMPRESAS_INATIVAS` — colisão silenciosa.

**Solução em [`Util_Planilha.bas`](../../../src/vba/Util_Planilha.bas):**

```vba
Public Function Util_MaxIdOperacional(ByVal nomeAba As String) As Long
    Dim maxAtiva As Long, maxInativa As Long
    maxAtiva = Util_MaxIdNaColunaA(nomeAba)
    On Error Resume Next   ' aba inativa pode nao existir
    Select Case UCase$(Trim$(nomeAba))
        Case SHEET_EMPRESAS:
            maxInativa = Util_MaxIdNaColunaA(SHEET_EMPRESAS_INATIVAS)
        Case SHEET_ENTIDADE:
            maxInativa = Util_MaxIdNaColunaA(SHEET_ENTIDADE_INATIVOS)
    End Select
    On Error GoTo 0
    Util_MaxIdOperacional = IIf(maxAtiva > maxInativa, maxAtiva, maxInativa)
End Function
```

`ProximoId` agora chama `Util_MaxIdOperacional(nomeAba)` em vez de
`Util_MaxIdNaColunaA(nomeAba)` diretamente. Defesa em profundidade: cobre
EMPRESAS+INATIVAS e ENTIDADE+INATIVOS sem alterar comportamento das demais
abas.

### AT-2 — Handler-before-flag (item 69 Codex, sev. MÉDIO)

**Problema:** Em 5 funções envelopadas com `Util_IniciarBlocoRapido`, o
`On Error GoTo` estava DEPOIS da chamada `Util_IniciarBlocoRapido`. Se erro
precoce ocorresse durante o `Util_IniciarBlocoRapido` (improvável mas
possível), o handler nem seria instalado e a `TEstadoExcel` ficaria vazia.

**Solução:** mover `On Error GoTo` para ANTES de `estadoExcel = Util_IniciarBlocoRapido()`.
Aplicado em:

- [`Util_Sanear_Contadores.SanearContadoresAR1`](../../../src/vba/Util_Sanear_Contadores.bas)
- [`Repo_Empresa.Inserir`](../../../src/vba/Repo_Empresa.bas)
- [`Repo_Empresa.Atualizar`](../../../src/vba/Repo_Empresa.bas)
- [`Repo_Empresa.GravarStatusEmpresa`](../../../src/vba/Repo_Empresa.bas)
- [`Repo_Empresa.RepoEmpresa_BackfillDtUltReativPorAuditLog`](../../../src/vba/Repo_Empresa.bas)

### AT-3 — `NumberFormat = "@"` sistemático (F-NEW3)

**Problema cosmético:** ID `5` aparecia como literal `5` em alguns
cadastros, não `005` textual. Origem identificada na sessão anterior em
`Menu_Principal.frm:1622` (versão pré-onda) — gravação ocorreu em célula
com formato `General`, e o Excel armazenou como número.

**Solução:** garantir `NumberFormat = "@"` na coluna do ID **ANTES** de
gravar. Aplicado nos 4 cadastros que escrevem direto em `.frm`:

| Form | Sub | Linha-alvo |
|---|---|---|
| Menu_Principal | `C_Cadastrar_Click` (entidade) | `wsEnt.Cells(ultimaLinhaEnt, 1).NumberFormat = "@"` |
| Menu_Principal | `M_Cadastrar_Empresa_Click` (empresa-alt) | `wsEmpCad.Cells(linhaNovaEmp, COL_EMP_ID).NumberFormat = "@"` |
| Credencia_Empresa | `CR_Credenciar_Click` (loop credenciamento) | `wsCred.Cells(linhaNova, COL_CRED_ID).NumberFormat = "@"` dentro do `For` |
| Cadastro_Servico | `S_Cadastrar_SV_Click` (atividade) | `wsAtiv.Cells(linhaNova, 1).NumberFormat = "@"` |
| Cadastro_Servico | `S_Cadastrar_SV_Click` (serviço) | `wsServ.Cells(linhaNova, COL_SERV_ID).NumberFormat = "@"` |

### AT-4 — Filtros nativos (handlers estáticos `TextBox16..22_Change`)

**Problema:** A descoberta dos textboxes de filtro usava
`UI_TextBoxSeExisteRecursivo + UI_PegarTextBoxBuscaDaLista` (heurística
por nome canônico + nome legado + posição visual + criação dinâmica
fallback). Frágil — a Onda 38.2.1 (`e9bcf42 revert filtros menu principal`)
reverteu a versão estática da Onda 38.2 e o filtro de Empresa quebrou.

**Solução em [`Menu_Principal.frm`](../../../src/vba/Menu_Principal.frm):**
7 handlers estáticos canônicos, cada um chama
`Preencher.Preencher_FiltrarPorBoxEstatico(nomeContexto, termo)`:

```vba
Private Sub TextBox16_Change()   ' Cadastro de Entidades
    If mInicializando Then Exit Sub
    If Not mTxtFiltroEntidade Is Nothing Then
        If mTxtFiltroEntidade Is TextBox16 Then Exit Sub
    End If
    On Error Resume Next
    Call Preencher.Preencher_FiltrarPorBoxEstatico("entidade", CStr(TextBox16.Text))
    On Error GoTo 0
End Sub
' ... idem para 17 (empresa), 18 (atrib_servico), 19 (os), 20 (aval),
'              21 (cad_servico), 22 (atrib_empresa)
```

**Evitação de double-call:** cada handler estático checa se o handler
dinâmico `mTxtFiltro*` já está vinculado AO MESMO `TextBoxN` via `Is`.
Se sim, sai cedo (o dinâmico cuida). Handlers dinâmicos
`mTxtFiltro*_Change` mantidos como **fallback** (débito V207 conforme
[`38_2_TECNICO.md §70-78`](../onda_38_2_filtros_menu_principal/38_2_TECNICO.md)).

**Solução em [`Preencher.bas`](../../../src/vba/Preencher.bas):** novo
`Public Sub Preencher_FiltrarPorBoxEstatico(nomeContexto, termo)`:

```vba
Select Case LCase$(Trim$(nomeContexto))
    Case "entidade":      Call PreenchimentoEntidade(termo)
    Case "empresa":       Call PreenchimentoEmpresa(termo)
    Case "atrib_servico": Call PreenchimentoServico(termo)
    Case "os":            Call PreencherPreencheOS              ' termo ignorado — debito V207
    Case "aval":          Call PreencherAvaliarOS               ' termo ignorado — debito V207
    Case "cad_servico":   Call PreencherManutencaoValor(termo)
    Case "atrib_empresa": Call PreenchimentoEntidadeRodizio(termo)
End Select
```

**Mapeamento canônico — divergências conhecidas (débito V207):**

| TextBox | Tela (mapa 38_2) | Função despachada | Comentário |
|---|---|---|---|
| 16 | Entidade | `PreenchimentoEntidade` | OK |
| 17 | Empresa | `PreenchimentoEmpresa` | OK |
| 18 | Atribuição de Serviço | `PreenchimentoServico` | espelha `mTxtFiltroServico_Change` histórico; alinhamento `PreenchimentoCRServico` é débito V207 |
| 19 | OS | `PreencherPreencheOS` | **termo ignorado** — filtro real depende de `Optional filtro` (débito V207) |
| 20 | Avaliação | `PreencherAvaliarOS` | **termo ignorado** — idem 19 |
| 21 | Cad Serviço | `PreencherManutencaoValor` | espelha `mTxtFiltroCadServ_Change` |
| 22 | Atrib Empresa | `PreenchimentoEntidadeRodizio` | espelha `mTxtFiltroRodizio_Change` |

### AT-5 — Envelopamento `Util_Excel_Performance` em 3 `.frm`

**Padrão aplicado (handler-before-flag + flag boolean defensiva):**

```vba
Private Sub <Sub_Cadastrar>()
On Error GoTo erro_carregamento
    Dim estadoExcel As TEstadoExcel
    Dim blocoRapidoIniciado As Boolean
    blocoRapidoIniciado = False

    ' Validacoes UI iniciais (sem envelopamento)
    If <validacao_falhou> Then Exit Sub
    If MsgBox("Confirmar?") <> vbYes Then Exit Sub

    ' Inicia bloco rapido APOS confirmacao do usuario
    estadoExcel = Util_IniciarBlocoRapido()
    blocoRapidoIniciado = True

    ' Trabalho pesado: gravacoes, loops, etc.
    ...

    ' Finaliza antes de cada Exit Sub pos-Iniciar
    Util_FinalizarBlocoRapido estadoExcel
    blocoRapidoIniciado = False
    Exit Sub

erro_carregamento:
    ' Handler defensivo: so finaliza se foi iniciado (evita restaurar TEstadoExcel zerada)
    If blocoRapidoIniciado Then Util_FinalizarBlocoRapido estadoExcel
End Sub
```

Aplicado em 4 subs:

- `Menu_Principal.C_Cadastrar_Click` (entidade)
- `Menu_Principal.M_Cadastrar_Empresa_Click` (empresa-alt)
- `Credencia_Empresa.CR_Credenciar_Click` (loop credenciamento)
- `Cadastro_Servico.S_Cadastrar_SV_Click` (atividade + serviço)

**Speedup esperado** (PC antigo, complementa o já obtido em
`Repo_Empresa` na FIX2-PERF): 3-8× percebido em cadastros UI.

---

## 4. Padrão emergente: `blocoRapidoIniciado As Boolean`

Esta onda formalizou o padrão **handler + flag boolean defensiva** para
envelopamento `Util_Excel_Performance` em `.frm` com múltiplos `Exit Sub`:

- **Por quê?** Em forms, `Exit Sub` precoces são comuns (validações UI,
  confirmações canceladas, abas protegidas). Cada `Exit Sub` PÓS-`Iniciar`
  precisa de `Util_FinalizarBlocoRapido` — mas se o erro ocorreu ANTES de
  `Iniciar`, finalizar com `TEstadoExcel` zerada pode corromper estado do
  Excel (`Calculation = 0` é inválido, por exemplo).
- **Solução:** flag `blocoRapidoIniciado As Boolean` setada para `True`
  imediatamente após `Util_IniciarBlocoRapido()`. Handler de erro chama
  `If blocoRapidoIniciado Then Util_FinalizarBlocoRapido estadoExcel`.

**Candidato a knowledge 002X** (a maturar em V207 quando o pattern for
adotado em mais forms).

---

## 5. Gates funcionais (vide readback 0111)

| Gate | Responsável | Esperado |
|---|---|---|
| **GATE-IMPORT** | Mauricio | `ImportarPacoteV3_Delta` retorna M=8 F=0 err=0 + BUMP em AAX-App_Release.bas |
| **GATE-COMPILE** | Mauricio | Compile limpo (TEstadoExcel + handlers + Util_MaxIdOperacional + Preencher_FiltrarPorBoxEstatico) |
| **GATE-AT-1** | Mauricio | EMPRESAS_INATIVAS com IDs > EMPRESAS ativos não causa colisão em novo cadastro |
| **GATE-AT-2** | Mauricio | Erro precoce em Repo_Empresa.Inserir restaura `TEstadoExcel` (gate pode ser dispensado) |
| **GATE-AT-3** | Mauricio | Cadastro entidade grava '005' textual em coluna A (não '5' literal) |
| **GATE-AT-4** | Mauricio | 7 filtros TextBox16..22 respondem em tempo real (sem F5/refresh) |
| **GATE-AT-5** | Mauricio | Speedup 3-8× em PC antigo para cadastros UI |
| **GATE-RVS** | Mauricio | `CT_ValidarRelease_TrioMinimo` APROVADO V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0 |
| **GATE-VAL-TELA-A-TELA** | Mauricio | Passagem pelos 13 forms validando filtros, comandos, gravação, listas |
| **GATE-FREEZE** | Opus + Mauricio | Tag `v12.0.0206` (anotada) + push origin sob aprovação |

---

## 6. Riscos e mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| Edição em Menu_Principal.frm (>3700 linhas) introduz drift no .frx | medium | `--apply` gera .code-only.txt + .frm + .frx delta; PHAGOCYTOSIS L24 |
| Handlers estáticos vs `mTxtFiltro*` dinâmico causam double-call | medium | Guard `If mTxtFiltro... Is TextBoxN Then Exit Sub` em cada estático |
| `Util_MaxIdOperacional` retorna 0 silenciosamente se aba inativa não existir | medium | Fallback `Util_MaxIdNaColunaA` na aba ativa preservado |
| `Cadastro_Servico` aplica NumberFormat em coluna errada (2 blocos) | medium | NumberFormat dentro do `Worksheet` correto (`wsAtiv` vs `wsServ`) |
| `Credencia_Empresa` duplica CR_Lista filhote do Menu | medium | Lógica `UserForms.Add` intocada; apenas envelopamento + NumberFormat |
| 8 módulos no manifesto V3 estoura limite | low | FIX2-PERF entregou M=4; 8 está dentro do envelope |
| GATE-VAL-TELA-A-TELA revela findings menores | low | Aceitável: fechar em onda 38.2.2-FIX se preciso |
| Compile falha por TEstadoExcel não visível em .frm | low | Pre-confirmado: FIX2-PERF usa TEstadoExcel em Repo_Empresa; tipo é `Public` em `Util_Excel_Performance` |
| BUMP_NO_CHANGE no import | low | Knowledge 0016: `App_Release.bas` mantém label antigo; V3 detecta diff |

---

## 7. Rollback

Anchor de rollback: commit `179bac5` (HEAD pós-consolidação 2ª rodada V207).
Anchor V206 funcional: `ee75b30`.

Cenários:

- **`--apply`/`--check` falha:** abortar antes do commit.
- **Guards reprovam:** ajustar `scope.files_allowed` ou conteúdo staged.
- **GATE-IMPORT falha com BUMP_NO_CHANGE:** validar Knowledge 0016 e
  refazer `--apply`.
- **GATE-COMPILE falha:** restaurar workbook pelo backup do V3 + investigar.
- **GATE-AT-N isolado falha:** fechar em onda `38.2.2-FIX` (microdelta).
- **GATE-RVS reprova:** reset para `179bac5`.
- **GATE-VAL-TELA-A-TELA revela finding crítico em form blindado:** abrir
  onda 38.2.3 dedicada, adiar tag.
- **GATE-VAL-TELA-A-TELA revela finding menor em form tocado:** corrigir
  dentro do escopo OU `38.2.2-FIX`.

Tag `v12.0.0206` só é cravada após TODOS os gates verdes (ou findings
menores aceitos explicitamente por Mauricio em hearback formal).

---

## 8. Próxima onda

**V207.0** fica adiada até a versão V206 estar **homologada com testes E2E completos** (vide §11 Roadmap atualizado pela diretiva Mauricio em 2026-05-27 04:30 BRT).

---

## 9. Hotfixes desta onda — timeline real

| Commit | Falha que motivou | Causa raiz |
|---|---|---|
| `c9bcd41` | commit primário | — |
| `f855d0b` | GATE-IMPORT VALIDACAO_LINHAS | manifesto declarou `M\|` para .frm (devia ser `F\|`) |
| `88b347b` | GATE-COMPILE TEstadoExcel | tipo TEstadoExcel não existe (FIX2-PERF migrou para Variant) |
| `854c392` | GATE-COMPILE Preencher.X | L10 PHAGOCYTOSIS — qualificação `Modulo.Funcao` falha em standard module |
| `255d3bc` | GATE-AT-4 erro 424 | `mTxtFiltro*` não declaradas + sem Option Explicit → Variant Empty no `Is Nothing` |
| `a51b191` | GATE-AT-3 EMPRESAS falhou | `Repo_Empresa.Inserir` (Service path real) não tinha NumberFormat — só caminho UI alternativo recebeu |

Cada hotfix está documentado em commit individual + protocol-evolutions. Lições L33-L38 destiladas em [`.hbn/protocol-evolutions/20260526-1810-onda-38-2-2-proposals.md`](../../../.hbn/protocol-evolutions/20260526-1810-onda-38-2-2-proposals.md).

---

## 10. Findings abertos (a corrigir antes do freeze)

### F-NEW5 — BUG CRÍTICO: rodízio reporta "sem empresas disponíveis" apesar de credenciamento existir

**Cenário** (reportado por Mauricio 2026-05-27 04:30):
- Criou atividade "CULTIVO DE ALGODÃO HERBÁCEO" (ATIV_ID novo) ;
- Credenciou Empresa 5 nessa atividade via `Credencia_Empresa.frm` ;
- Relatório `Relatório de Empresas Credenciadas` confirma: Empresa 5 / posição 1 ;
- Tela "Atribuição de Empresa para Serviço" + Emite Pré-OS retornou: **"Não foi possível emitir a Pre-OS: não há empresas disponíveis para esta atividade."**

**Hipótese principal**: relatório mostra `STATUS_CRED` **VAZIO** para credenciamentos novos (CULTIVO DE TRIGO + CULTIVO DE ALGODÃO HERBÁCEO) mas mostra "ATIVO" para credenciamentos de fixture ("Atividade E2E Strikes"). Sugere que a gravação de `COL_CRED_STATUS = STATUS_CRED_ATIVO` em `Credencia_Empresa.CR_Credenciar_Click:178` está sendo **sobrescrita ou ignorada** após o loop For.

**Suspeito**: `Call ClassificaCredenciadoOrdem` (linha 189) ou outra sub que roda após o loop pode estar resetando STATUS_CRED. **Investigar na 38.2.3.**

**Severidade**: CRÍTICA — rodízio é a funcionalidade central do sistema. Sem isso, nenhuma Pre-OS é emitida.

**Validação rápida proposta** (Imediato):
```vba
? Sheets("CREDENCIADOS").Cells(<linha_da_emp5_em_algodao>, COL_CRED_STATUS).Value
' Esperado: "ATIVO"
' Real (a confirmar): provavelmente "" ou Empty
```

### F-FILTRO-1 — TextBox19 (OS) e TextBox20 (Avaliação) disparam mas não filtram

**Causa**: `PreencherPreencheOS()` e `PreencherAvaliarOS()` não têm parâmetro `Optional filtro` nem implementação de filtro de lista (vide [`Preencher.bas:861`](../../../src/vba/Preencher.bas#L861) e [`Preencher.bas:1306`](../../../src/vba/Preencher.bas#L1306)). Despacho `Preencher_FiltrarPorBoxEstatico` ignora termo nesses 2 contextos.

**Fix proposto**: adicionar `Optional ByVal filtro As String = ""` nas 2 funções + filtrar a lista por substring case-insensitive sobre campos relevantes (OS_ID, EMP_ID, ATIV_DESC, SERV_DESC). Espelhar padrão de `PreenchimentoEmpresa`.

### F-FILTRO-2 — Filtro de Empresas não busca telefone (inconsistente com Entidades)

**Causa**: `TextoEmpresaParaFiltro` ([`Preencher.bas:93`](../../../src/vba/Preencher.bas#L93)) concatena apenas ID + CNPJ + Razão + Responsável. **`TextoEntidadeParaFiltro` inclui** Tel.Celular + Contato1 Fone.

**Decisão de design pendente**: incluir telefone em empresas? Mauricio decide.

### F-FILTRO-3 — Filtros internos de forms modais ainda heurísticos

`Cadastro_Servico.frm.mTxtBuscaTopo` ([:267](../../../src/vba/Cadastro_Servico.frm#L267)) e outros forms modais (`Credencia_Empresa`, `Reativa_*`) ainda usam descoberta via `UI_TextBoxSeExiste`. **Onda 38.2.2 só corrigiu o Menu_Principal.**

### F-FILTRO-4 — `TextBox22` (Atrib Empresa Rodízio) não auditado nesta sessão

Despacho para `PreenchimentoEntidadeRodizio` — comportamento não verificado em código nesta sessão. Auditar na 38.2.3.

---

## 11. Roadmap até freeze V206 (atualizado por diretiva Mauricio 2026-05-27)

> **Princípio orientador (Mauricio)**: "Não temos pressa em congelar a versão, temos pressa em ter uma versão estável, testada e funcional que possa ser congelada para o público final. Precisamos validar inclusive se os testes estão corretos e são suficientes antes de validarmos e congelarmos a versão."

### Onda 38.2.3 — Bug crítico do rodízio + filtros OS/Aval (TextBox19/20)

**Escopo**:
- Resolver F-NEW5 (rodízio retornando "sem empresas") — investigação + fix
- Resolver F-FILTRO-1 (adicionar `Optional filtro` em `PreencherPreencheOS`/`PreencherAvaliarOS` + implementação)
- Cria teste E2E que valida ciclo completo: cadastrar atividade nova → credenciar empresa → emitir Pré-OS → confirmar empresa selecionada
- Padrão dos testes: **prevenir regressão por "trilha já validada"** (vide diretiva Mauricio §3) — testes devem cobrir fluxos NOVOS (atividade não-fixture, empresa não-fixture), não apenas reutilizar fixtures pré-existentes

### Onda 38.2.4 — Filtros completos (F-FILTRO-2/3/4)

**Escopo**:
- F-FILTRO-2: decisão design + implementação (telefone em empresas)
- F-FILTRO-3: padronizar filtros de `Cadastro_Servico`, `Credencia_Empresa`, `Reativa_*` para o pattern estático (espelhar Menu_Principal)
- F-FILTRO-4: auditar TextBox22 + qualquer filtro restante
- Suite de teste para CADA filtro: digitar termo conhecido, verificar resultado esperado (subset da lista)

### Onda 38.2.5 — Suite de testes E2E para validação tela-a-tela + meta-validação

**Escopo**:
- **Meta-validação dos testes**: revisar se `CT_ValidarRelease_TrioMinimo`, `V1`, `V2_Smoke`, `V2_Canonica`, `E2E_Strikes` cobrem fluxos NOVOS (não apenas fixture pré-existente). Se não, expandir.
- Suite E2E nova que exercita cada uma das 13 telas (Menu_Principal, Credencia_Empresa, Cadastro_Servico, Altera_*, Reativa_*, Configuracao_Inicial, Limpar_Base, Fundo_Branco, ProgressBar, Rel_Emp_Serv, Rel_OSEmpresa) com cenários reais
- Critério para freeze: **TODOS** os fluxos validados + testes correspondentes verdes + sem findings abertos

### Onda 38.2.N (até N necessárias) — Findings que aparecerem em validação tela-a-tela

Conforme cronograma de validação aprovado em [`38_2_TECNICO.md:79`](../onda_38_2_filtros_menu_principal/38_2_TECNICO.md#L79). Cada finding abre uma sub-onda dedicada.

### GATE-FREEZE — Tag `v12.0.0206`

Só quando:
- F-NEW5 + F-FILTRO-1/2/3/4 resolvidos
- Suite E2E validada por Mauricio em validação tela-a-tela formal
- RVS APROVADO `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0` mantido
- Mauricio aprova explicitamente via hearback

### V207 — Adiada até freeze V206

Conforme diretiva Mauricio: V207 não inicia até V206 ter caminho seguro testado.
