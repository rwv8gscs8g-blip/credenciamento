---
titulo: Onda 5 — Configuracao_Inicial deterministico + Limpeza Total na interface
natureza-do-documento: documentacao tecnica da Onda 5
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork)
---

# 37. Onda 5 — Determinismo no formulario de configuracao + Limpeza Total robusta

## 00. Objetivo

Fechar dois gaps observados em homologacao 28/04/2026:

1. O formulario `Configuracao_Inicial.frm` ainda dependia de **heuristica
   de Label adjacente** (`CI_BuscarTextBoxPorLabel`) para localizar os
   3 textboxes da regra de strikes — em conflito direto com a regra
   da V203 ("ELIMINAR toda eurística e deixar os comandos
   DETERMINISTICOS", aprovada pelo Mauricio em 28/04).
2. O botao "Limpar Base" do formulario chamava `Preencher.Limpa_Base`,
   que NAO detectava cabecalho corrompido. Em workbooks reais isso
   deixou empresas-zumbi sobreviverem ao reset (Empresa 1 com CNPJ
   na linha 1, observada no print da homologacao).

## 01. Mudancas

### 01.1 `src/vba/Configuracao_Inicial.frm`

**Eliminadas as 3 funcoes heuristicas:**

- `CI_TextoTextBoxPorLabel(palavraChave)`
- `CI_DefinirTextoTextBoxPorLabel(palavraChave, valor)`
- `CI_BuscarTextBoxPorLabel(palavraChave)`

**`B_Parametros_Click`** agora le os 3 campos por nome canonico:

```vba
On Error Resume Next
notaCorteTxt   = Trim$(CStr(Me.Controls("TxtNotaCorte").Value))
maxStrikesTxt  = Trim$(CStr(Me.Controls("TxtMaxStrikes").Value))
diasSuspensaoTxt = Trim$(CStr(Me.Controls("TxtDiasSuspensao").Value))
On Error GoTo erro_carregamento
```

**`UserForm_Initialize`** popula direto os 3 campos:

```vba
On Error Resume Next
Me.Controls("TxtNotaCorte").Value     = Format$(GetNotaMinimaAvaliacao(), "0.0")
Me.Controls("TxtMaxStrikes").Value    = CStr(GetMaxStrikes())
Me.Controls("TxtDiasSuspensao").Value = CStr(GetDiasSuspensaoStrike())
On Error GoTo erro_carregamento
```

`On Error Resume Next` curto e a unica concessao — protege contra um
workbook antigo que ainda nao tenha os controles renomeados; nesse caso
o campo e ignorado e o valor anterior em CONFIG e preservado pela
validacao defensiva (`If notaCorteTxt <> "" Then ...`).

**Persistencia em CONFIG inalterada** (mesma logica de protecao):

```vba
Util_PrepararAbaParaEscrita(wsCfg, estavaProtegida, senhaProtecao)
' grava cells K, L, M
Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
```

E por isso que esse caminho funciona mesmo com CONFIG protegida e a
macro descartavel `Set_Config_Strikes_Padrao.bas` falhava com 1004 — a
descartavel nao chamava `Util_PrepararAbaParaEscrita`.

### 01.2 NOVO `src/vba/Mod_Limpeza_Base.bas`

Modulo oficial do projeto com a logica testada em homologacao via
`local-ai/vba_import/Limpa_Base_Total.bas v2`:

- **Funcao publica:** `LimpaBaseTotalReset(Optional ByRef relatorioOut As String) As Boolean`
- **Helpers privados:**
  - `MLB_LimparAba(nomeAba, cabecalhoCanonico)` — desproteja, calcula
    `MAX(End(xlUp))` em colunas 1..50, detecta se linha 1 e cabecalho,
    apaga, reescreve cabecalho canonico se preciso, reseta contador
    em `Cells(1, 44)`, reproteja.
  - `MLB_LinhaEhCabecalho(ws)` — heuristica defensiva que reconhece
    palavras-chave conhecidas (EMP_ID, CNPJ, RAZAO_SOCIAL, etc.) e
    rejeita CNPJ formatado em A1 como dado.
  - `MLB_Cabecalho<Aba>()` — listas canonicas por aba (EMPRESAS,
    ENTIDADE, CREDENCIADOS, PRE_OS, CAD_OS, AUDIT_LOG).
  - `MLB_GravarRelatorio(texto)` — cria/atualiza aba `RPT_LIMPEZA_TOTAL`
    com o resumo da operacao.

**Abas que limpa:** `EMPRESAS`, `EMPRESAS_INATIVAS`, `ENTIDADE`,
`ENTIDADE_INATIVOS`, `CREDENCIADOS`, `PRE_OS`, `CAD_OS`, `AUDIT_LOG`,
`RELATORIO`.

**Abas que PRESERVA:** `ATIVIDADES`, `CAD_SERV`, `CONFIG`.

**Idempotencia:** N execucoes seguidas deixam todas as abas
operacionais com cabecalho canonico + zero linhas de dados.

### 01.3 `src/vba/Preencher.bas` — `Sub Limpa_Base()`

A rotina antiga (que iterava manualmente em 5 abas com colunas-fim
hardcoded "T", "V", "O", "N", "AD") foi substituida por um **wrapper
de uma linha** sobre `Mod_Limpeza_Base.LimpaBaseTotalReset`. A nova
versao mantem:

- A pergunta de confirmacao;
- A chamada subsequente a `PreenchimentoServico`,
  `AtualizarListaEntidadeMenuAtual`, `AtualizarListaEmpresaMenuAtual`,
  `PreenchimentoEntidadeRodizio`, `PreencherAvaliarOS`,
  `PreencherManutencaoValor`;
- A chamada a `Util_SalvarWorkbookSeguro`;
- A MsgBox final de sucesso com o relatorio detalhado.

A mensagem de confirmacao foi atualizada para listar TODAS as abas
limpas (incluindo as `_INATIVAS`, `AUDIT_LOG` e `RELATORIO`) — essa e
uma mudanca de comportamento intencional.

### 01.4 `src/vba/App_Release.bas`

Bumped:

```vba
APP_BUILD_IMPORTADO = "f7aa84f+ONDA05-em-homologacao"
APP_BUILD_GERADO_EM = "2026-04-28 08:45"
```

## 02. Por que essa Onda fecha o gap relatado

### 02.1 Erro 1004 da macro descartavel

A macro `Set_Config_Strikes_Padrao.bas` falhou com **1004 — planilha
protegida** porque escrevia direto em `wsCfg.Cells(2, 11..13).Value`
sem desproteger. Apos a Onda 5 a configuracao entra pelo formulario
oficial, que **ja desproteja e reproteja** via os utilitarios do
projeto. A descartavel pode ser apagada do workbook (`Project Explorer
> clique direito > Remove Set_Config_Strikes_Padrao`).

### 02.2 Empresa-zumbi na linha 1

`Preencher.Limpa_Base` antigo:

```vba
intervalo = "A" & LINHA_DADOS & ":" & ultimaColuna & CStr(ultimaLinha)
ws.Range(intervalo).ClearContents
```

`LINHA_DADOS = 2` em projeto. Se a linha 1 contem dado (cabecalho
corrompido), a Empresa 1 sobrevive ao reset porque o range comeca em
`A2`. A nova versao detecta cabecalho ausente, apaga linha 1 tambem,
e reescreve `EMP_ID | CNPJ | RAZAO_SOCIAL | ...`.

### 02.3 Heuristica eliminada

Em conformidade com a regra V203 ("eliminar toda heuristica"). Os
nomes canonicos `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`
sao agora a unica fonte de verdade — ja foram renomeados pelo gestor
no designer do form em 28/04.

## 03. O que NAO mudou

- `Mod_Types.bas` — nao tocado (regra do projeto);
- `Importador_VBA.bas` — nao tocado;
- `Const_Colunas.bas` — nao tocado (constantes de strikes ja existem
  desde a Onda 1);
- `Util_Config.bas` — nao tocado (getters ja retornam defaults
  corretos: 5, 3, 90);
- `Repo_Avaliacao.bas`, `Svc_Rodizio.bas`, `Svc_Avaliacao.bas` —
  inalterados;
- Designer do `Configuracao_Inicial.frm` — apenas o codigo atras do
  form mudou; o `.frx` (binario com posicoes/tamanhos dos controles)
  fica como o gestor deixou.

## 04. Limites conhecidos / proximos passos

1. **Cenarios automatizados RDZ_001 e IDM_001** ainda nao foram
   adicionados a `Teste_V2_Roteiros.bas`. Continuam pendentes para
   a proxima onda (RDZ_001 = 3 empresas + 3 emissoes sucessivas;
   IDM_001 = limpa base x3 = mesmo estado final).
2. **`TV2_LimparBaseAposSuite`** pode chamar `Mod_Limpeza_Base.LimpaBaseTotalReset`
   diretamente — wire-up trivial para a proxima onda.
3. **Macro descartavel `Set_Config_Strikes_Padrao.bas`** continua em
   `local-ai/vba_import/` mas obsoleta. Pode ser apagada quando todos
   os workbooks tiverem o form da Onda 5 importado.
4. **`Limpa_Base_Total.bas` em `local-ai/vba_import/`** continua util
   como fallback de campo (workbooks que ainda nao receberam a Onda 5
   podem rodar a macro descartavel para chegar ao mesmo estado).
5. **Padronizacao visual dos cabecalhos** (cor, fonte, congelamento de
   linha) e separada — pertence a uma onda de UI, nao a essa.

## 05. Compatibilidade

- Workbooks que ja rodaram a Onda 4: o form ja tem os 3 textboxes;
  apenas reimportar Configuracao_Inicial.frm (codigo) atualiza o
  comportamento sem necessidade de tocar no `.frx`.
- Workbooks anteriores: precisam ter os textboxes renomeados no
  designer para `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`
  antes da Onda 5 entrar em vigor. Se nao renomear, o form ainda
  funciona — apenas os 3 campos novos ficam vazios e CONFIG preserva
  os valores anteriores.
