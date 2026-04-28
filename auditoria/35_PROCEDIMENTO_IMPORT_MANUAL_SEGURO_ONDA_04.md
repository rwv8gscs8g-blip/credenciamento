---
titulo: Procedimento de Importacao Manual Segura — ONDA 4 (wire-up Configuracao_Inicial + diagnostico)
natureza-do-documento: passo a passo operacional, com tratamento especial para .frm via edicao no VBE
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
documento-irmao: auditoria/34_ONDA_04_CONFIG_STRIKES_NA_INTERFACE_E_DIAG_RODIZIO.md
---

# 35. Procedimento de Importacao Manual Segura — ONDA 4

## 00. Aviso especifico desta onda

Esta onda toca **um formulario** (`Configuracao_Inicial.frm`) pela
primeira vez na esteira. Como voce ja modificou o **designer** do
formulario no Excel (3 TextBoxes novos para a regra de strikes), o
`.frx` no seu workbook esta diferente do `src/vba/Configuracao_Inicial.frx`
do repositorio. **Nao use `File > Import` para o `.frm` desta onda** —
isso sobrescreveria o designer e voce perderia os 3 TextBoxes.

Caminho seguro: **editar somente o codigo** dentro do VBE, mantendo
o designer atual intacto. O codigo novo e identifica TextBoxes por
heuristica (Label adjacente), nao depende dos nomes que voce deu.

## 01. Regras inviolaveis

1. **NAO rodar** `bash local-ai/scripts/publicar_vba_import.sh`.
2. **NAO importar** `Mod_Types.bas`.
3. **NAO importar** `Importador_VBA.bas`.
4. **NAO importar** o `Configuracao_Inicial.frm` via `File > Import` —
   editar o codigo direto no VBE (passo 04.5).
5. Backup obrigatorio antes do primeiro arquivo importado.
6. Compilar (`Depurar > Compilar VBAProject`) apos cada arquivo / cada
   bloco de codigo colado.
7. Em caso de erro, abortar e voltar ao backup.

## 02. Lista exata da ONDA 4

### Por `File > Import` (4 arquivos `.bas`)

| # | Caminho | Modulo |
|---|---|---|
| 0 | `src/vba/App_Release.bas` | `App_Release` |
| 1 | `src/vba/Svc_Rodizio.bas` | `Svc_Rodizio` |
| 2 | `src/vba/Teste_V2_Roteiros.bas` | `Teste_V2_Roteiros` |
| 3 | `src/vba/Central_Testes_V2.bas` | `Central_Testes_V2` |

### Por copia/cola no VBE (1 formulario)

| # | Arquivo | Editor |
|---|---|---|
| 4 | `src/vba/Configuracao_Inicial.frm` | VBE -> View Code de `Configuracao_Inicial` |

## 03. Identificador do build

Ja gravado em `src/vba/App_Release.bas`:
- `APP_BUILD_IMPORTADO = "f7aa84f+ONDA04-em-homologacao"`
- `APP_BUILD_BRANCH = "codex/v12-0-0203-governanca-testes"`
- `APP_BUILD_GERADO_EM = "2026-04-28 06:30"`

## 04. Procedimento

### 04.0 Backup obrigatorio

Copiar `PlanilhaCredenciamento-Homologacao.xlsm` para
`V12-202-K/PlanilhaCredenciamento-Homologacao_PRE_ONDA_04_<DATA>.xlsm`.

### 04.1 Importar arquivo 0 — `App_Release.bas`

1. VBE > Project Explorer > clique direito em `App_Release` > **Remove
   App_Release** > **No** ao "exportar?".
2. `File > Import File...` -> `src/vba/App_Release.bas`.
3. `Depurar > Compilar VBAProject`. Tem que ficar limpo.
4. Conferir tela `Sobre`:
   - **Build importado:** `f7aa84f+ONDA04 (em homologação)`
   - **Pacote gerado em:** `2026-04-28 06:30`

### 04.2 Importar arquivo 1 — `Svc_Rodizio.bas`

1. VBE > Project Explorer > clique direito em `Svc_Rodizio` > **Remove**
   > **No**.
2. `File > Import File...` -> `src/vba/Svc_Rodizio.bas`.
3. Compilar.

### 04.3 Importar arquivo 2 — `Teste_V2_Roteiros.bas`

1. Remover `Teste_V2_Roteiros`.
2. Importar `src/vba/Teste_V2_Roteiros.bas`.
3. Compilar.

### 04.4 Importar arquivo 3 — `Central_Testes_V2.bas`

1. Remover `Central_Testes_V2`.
2. Importar `src/vba/Central_Testes_V2.bas`.
3. Compilar.

### 04.5 Atualizar codigo do `Configuracao_Inicial.frm` (sem importar)

> **Importante:** este passo NAO usa `File > Import`. Voce edita o
> codigo direto no VBE, mantendo o designer (TextBoxes novos) intacto.

#### 04.5.1 Abrir o code-behind do formulario

1. VBE > Project Explorer > duplo-clique em `Configuracao_Inicial`.
2. Painel direito do VBE: clique no botao "View Code" (icone `[=]`)
   para abrir a janela de codigo (NAO a janela do designer).
3. Pressione `Ctrl+Home` para ir ao topo do codigo.

#### 04.5.2 Diff a aplicar — bloco 1 (`B_Parametros_Click`)

Localize a linha `Private Sub B_Parametros_Click()` e
**substitua o conteudo inteiro do Sub** (de `Private Sub B_Parametros_Click()`
ate `End Sub`) pelo bloco que esta em
`src/vba/Configuracao_Inicial.frm` linhas 63 a 137 (esse e o `Sub`
inteiro, com as linhas novas marcadas como `V12.0.0203 ONDA 4`).

Procedimento operacional:
1. No arquivo `src/vba/Configuracao_Inicial.frm` (abrir num editor
   externo, ex.: VS Code, Notepad++): copiar o trecho que vai de
   `Private Sub B_Parametros_Click()` ate o proximo `End Sub`.
2. No VBE, seleciona o `Sub B_Parametros_Click()` antigo inteiro
   (de `Private Sub B_Parametros_Click()` ate o `End Sub` correspondente).
3. `Delete`.
4. Cola o novo bloco no mesmo lugar.
5. Compilar.

#### 04.5.3 Diff a aplicar — bloco 2 (helpers heuristicos novos)

Logo apos o `End Sub` do `B_Parametros_Click` ja substituido, **cole
3 funcoes novas** que nao existem no formulario antigo. Estao em
`src/vba/Configuracao_Inicial.frm` aproximadamente entre as linhas
139 e 199:

- `Private Function CI_TextoTextBoxPorLabel(...)`
- `Private Sub CI_DefinirTextoTextBoxPorLabel(...)`
- `Private Function CI_BuscarTextBoxPorLabel(...)`

Procedimento:
1. No editor externo, copiar do comentario
   `' V12.0.0203 ONDA 4 — Helpers heuristicos para os 3 campos novos`
   ate o ultimo `End Function` desses 3 helpers.
2. No VBE, posicionar o cursor logo apos o `End Sub` do
   `B_Parametros_Click` (espaco em branco).
3. Colar.
4. Compilar.

#### 04.5.4 Diff a aplicar — bloco 3 (`UserForm_Initialize`)

Localize `Private Sub UserForm_Initialize()`. Logo apos a linha:

```vba
TP_Valor = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value
```

inserir as **6 linhas novas** que estao em
`src/vba/Configuracao_Inicial.frm` (procurar pelo comentario
`V12.0.0203 ONDA 4 — popular campos novos da regra de strikes`).

Procedimento:
1. No VBE, posicionar o cursor logo apos a linha
   `TP_Valor = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value`.
2. Colar o bloco que comeca com
   `' V12.0.0203 ONDA 4 — popular campos novos da regra de strikes.`
   e termina em `On Error GoTo erro_carregamento`.
3. Compilar.

### 04.6 Salvar

`Ctrl+S` no Excel. Confirmar manter `.xlsm`.

## 05. Verificacao final

1. Compilar uma ultima vez. Tem que ficar limpo.
2. Conferir tela `Sobre`: `f7aa84f+ONDA04 (em homologação)`.
3. **Trio minimo** verde:
   - V1 rapida (Bateria Oficial)
   - V2 Smoke (Central V2 `[1]`)
   - V2 Canonica (Central V2 `[5]`)
4. **Suite Onda 1** (regressao): `[14]` Strikes — esperado `OK=7`,
   `FALHA=0`.
5. **Suite Onda 2 + 3**: `[15]` CNAE — esperado `OK=6`, `FALHA=0`.
6. **Suite Onda 4**: `[17]` Configuracao de strikes — esperado `OK=2`,
   `FALHA=0`.
7. **Verificacao manual da interface**:
   1. Abrir `Configuracao_Inicial`.
   2. Os 3 campos (avaliacoes / menores que / dias) devem aparecer
      pre-preenchidos com os valores da CONFIG (default
      `MAX_STRIKES=3`, `NOTA_MINIMA=5.0`, `DIAS_SUSPENSAO_STRIKE=90`).
   3. Mudar para `MAX_STRIKES=5`, `NOTA_MINIMA=6.0`,
      `DIAS_SUSPENSAO_STRIKE=30`.
   4. Clicar **Salvar Parametros**.
   5. Reabrir `Configuracao_Inicial`. Os 3 campos devem mostrar os
      novos valores.
8. **Verificacao do diagnostico**: rodar `[16] Diag rodizio`,
   informar `001` no InputBox, abrir `RPT_DIAG_RODIZIO` e conferir
   que cada linha tem decisao preenchida.

## 06. Plano de rollback

1. Fechar Excel sem salvar.
2. Restaurar do backup.
3. Abrir backup, rodar trio minimo + `[14]` + `[15]` para confirmar
   estado anterior.
4. Reportar mensagem exata do erro.

## 07. Por que nao gera regressao

- nenhum `.frx` tocado;
- `Mod_Types`, `Audit_Log`, `Const_Colunas`, `Util_Config`,
  `Preencher` intocados;
- `Svc_Rodizio` so adiciona helpers publicos `Diag_*` no final do
  arquivo (nao altera nenhuma assinatura existente);
- `Configuracao_Inicial.frm` mantem todos os controles originais; a
  logica nova depende de Labels que voce ja criou no designer;
- a heuristica de busca tem **validacao defensiva**: nao acha o
  TextBox -> nao grava nada -> CONFIG fica intacta;
- a faixa permitida em cada campo preserva valor anterior se
  invalido;
- `Diag_RodizioStatus` apenas LE dados (nao escreve em EMPRESAS,
  CREDENCIADOS, etc.) — apenas grava em `RPT_DIAG_RODIZIO`.

## 08. Politica para a proxima onda

Apos OK desta onda, sigo para a **ONDA 5** com 2 caminhos possiveis:

- **5A — Setup Manual de cenario limpo**: helper na Central V2 para
  popular base operacional com 3 empresas + 3 entidades + 3
  credenciamentos prontos para teste manual sem rodar a Canonica.
  Resolve a friccao de "Canonica deixa base contaminada".
- **5B — Cenario E2E `CS_25_CREDENCIAMENTO_ENDtoEND`**: PE-10 do
  parecer 25, automacao do fluxo completo de credenciamento.

Voce escolhe a ordem. Recomendo 5A primeiro, porque resolve uma
friccao operacional concreta que voce relatou hoje.
