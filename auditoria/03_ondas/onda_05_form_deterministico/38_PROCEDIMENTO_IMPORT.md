---
titulo: Procedimento manual seguro de import — Onda 5
natureza-do-documento: passo-a-passo de import via VBE (sem script)
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork)
---

# 38. Procedimento manual seguro — Import da Onda 5

> **Lembrete da regra do projeto**: NAO usar
> `local-ai/vba_import/publicar_vba_import.sh` (instavel; pacote tenta
> reimportar `Mod_Types.bas` e quebra o projeto). Importar manualmente
> via VBE.

## 00. Arquivos da Onda 5

| Arquivo | Status | Acao no VBE |
|---|---|---|
| `src/vba/App_Release.bas` | modificado (build bumped) | Substituir |
| `src/vba/Mod_Limpeza_Base.bas` | NOVO | Importar |
| `src/vba/Preencher.bas` | modificado (`Sub Limpa_Base`) | Substituir |
| `src/vba/Configuracao_Inicial.frm` | modificado (codigo, NAO design) | Substituir o codigo apenas |

## 01. Pre-requisitos

1. Salvar o workbook atual (Ctrl+B).
2. Fazer backup `.xlsm` para `backups/` (renomear com timestamp).
3. Ter a pasta `src/vba/` do repositorio sincronizada na maquina.
4. Confirmar no designer do `Configuracao_Inicial.frm` que os 3
   textboxes da regra de strikes ja estao renomeados:
   - `TxtNotaCorte`
   - `TxtMaxStrikes`
   - `TxtDiasSuspensao`

   Se nao estiverem, abrir o form em modo design e renomear pela aba
   "Propriedades" do VBE antes do import.

## 02. Sequencia de import (ordem importa)

### 02.1 `App_Release.bas` (substituir)

1. Ribbon: Desenvolvedor > Visual Basic.
2. VBE > Project Explorer > duplo-clique em `App_Release`.
3. Selecionar todo o codigo da janela (Ctrl+T, Ctrl+A — ou marcar
   manualmente).
4. Apagar.
5. Abrir `src/vba/App_Release.bas` em editor de texto, copiar tudo
   (a partir da linha `Attribute VB_Name = "App_Release"`).
6. Colar no modulo do VBE.
7. Salvar projeto (Ctrl+B).

> Nao usar Import File aqui porque o nome do modulo ja existe e o VBE
> criaria `App_Release1`. Substituir conteudo e mais seguro.

### 02.2 `Mod_Limpeza_Base.bas` (novo modulo — Import File)

1. VBE > File > Import File...
2. Selecionar `src/vba/Mod_Limpeza_Base.bas`.
3. Confirmar que aparece em Project Explorer > Modulos.
4. Salvar projeto (Ctrl+B).

### 02.3 `Preencher.bas` (substituir)

`Preencher.bas` e um modulo grande com muitas Subs. Vamos substituir
APENAS a `Sub Limpa_Base()` para minimizar risco.

1. VBE > duplo-clique em `Preencher`.
2. `Ctrl+F` > buscar `Sub Limpa_Base()`.
3. Selecionar todo o conteudo da Sub (de `Sub Limpa_Base()` ate o
   `End Sub` correspondente, **antes** de
   `' V12.0.0203 ONDA 3 — exposta como Public...`).
4. Apagar.
5. Abrir `src/vba/Preencher.bas` em editor de texto, localizar a nova
   `Sub Limpa_Base()` (a partir do comentario
   `' V12.0.0203 ONDA 5 — agora delega para Mod_Limpeza_Base...`
   ate o `End Sub`).
6. Copiar e colar no lugar.
7. Salvar projeto (Ctrl+B).

### 02.4 `Configuracao_Inicial.frm` — substituir somente o codigo (NAO o design)

> **Regra inegociavel:** como o `.frx` (binario com posicao/tamanho/nome
> dos controles) ja foi customizado pelo gestor, NAO usar `File > Import`
> para o `.frm`. Substituir apenas o codigo atras do form, usando o
> arquivo `.code-only.txt` que ja vem **puro** (so codigo VBA, sem
> cabecalho FRM nem comentarios de instrucao).

#### Passo 0 — saneamento obrigatorio (adicionado no hotfix v3 da Onda 6, 2026-04-28)

> **Bug conhecido:** `File > Import` apontando para `.frm` em workbook
> estabilizado pode (a) criar form com sufixo numerico
> (`Configuracao_Inicial1`), (b) criar **modulo padrao** com cabecalho FRM
> como codigo solto, ou (c) sobrescrever `.frx`. Documentado integralmente
> em [`.hbn/knowledge/0005-bug-form-importado-como-modulo.md`](../../../.hbn/knowledge/0005-bug-form-importado-como-modulo.md).
> Toda IA executora deve referenciar esse doc e toda IA assistente deve
> avisar o operador antes do passo 02.4.
>
> **Root cause comprovada na hotfix v4 (2026-04-28):** o
> `Configuracao_Inicial.frm` foi salvo com line endings LF (Unix) +
> 3 LFs trailing + 7 em-dashes UTF-8 — combinacao toxica para o parser
> do VBE. Apos hotfix v4, o `.frm` foi normalizado para CRLF (Windows) +
> EOF correto (3 CRLFs) + em-dashes substituidos por hyphen-minus.
> Padrao permanente em
> [`.hbn/knowledge/0006-padronizacao-encoding-line-endings-frm.md`](../../../.hbn/knowledge/0006-padronizacao-encoding-line-endings-frm.md).

Antes dos 8 passos abaixo, voce **DEVE** verificar se o Project Explorer
do VBE esta limpo. Se algum dos sintomas abaixo aparecer, sanear antes
de prosseguir, senao a compilacao falhara com "Invalido fora de um procedimento".

| Sintoma | Onde aparece | Causa | Acao corretiva |
|---|---|---|---|
| `Configuracao_Inicial` duplicado em pasta `Modulos` (alem do form em `Formulários`) | Project Explorer (esquerda do VBE) | `File > Import` foi feito apontando para `.frm` ou para `.code-only.txt` renomeado, em conflito com o form ja existente | Clique direito no item duplicado em `Modulos` > `Remove Configuracao_Inicial...` > **No** (nao exportar) |
| `Configuracao_Inicial1`, `Configuracao_Inicial2` etc. em `Formulários` | Project Explorer (pasta `Formulários`) | re-import sucessivo do `.frm` criou copias com sufixo numerico | Clique direito em CADA copia com sufixo > `Remove...` > **No** (manter apenas o `Configuracao_Inicial` original sem sufixo) |
| Codigo da janela do form comeca com `VERSION 5.00`, `Begin {GUID}`, `Caption =`, `End`, ou `Attribute VB_*` | Janela de codigo do VBE quando voce abre `Configuracao_Inicial` (form, nao modulo) | colado o `.frm` cru por engano em vez do `.code-only.txt` | apos saneamento acima, seguir os 8 passos. Se ainda assim aparecer apos colar, verificar passo 5 (deve comecar em `Private Sub Carrega_CAD_SERV_Click()`) |

Apos saneamento:

1. Salvar workbook (Ctrl+S).
2. Compilar VBE (Debug > Compile VBAProject) — deve passar sem erro
   ANTES de qualquer alteracao nesta secao 02.4. Se ainda houver erro
   apos saneamento, parar e reportar. Nao prosseguir com copy-paste.
>
> Arquivo a usar:
> **`local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`**
>
> Atualizado em V12.0.0203 ONDA 6 (hotfix): a partir de agora o
> `.code-only.txt` contem APENAS codigo VBA. A primeira linha do arquivo
> e `Private Sub Carrega_CAD_SERV_Click()` e a ultima linha do codigo
> e `End Function`. Voce pode fazer Ctrl+A do arquivo inteiro sem
> precisar localizar onde comeca a primeira `Private Sub`.

Procedimento copy-paste (8 passos, em ordem rigorosa):

1. No VBE, Project Explorer (esquerda), em `Formulários`, **duplo-clique**
   em `Configuracao_Inicial` — abre o designer (ver os textboxes).
2. Tecle `F7` (ou clique direito > "Visualizar Codigo") — abre a
   janela com o VBA atras do form.
3. Na janela de codigo, `Ctrl+A` (selecionar tudo) seguido de `Delete`.
   A janela fica vazia.
4. Em outra janela do sistema (Finder/TextEdit/VS Code/Notepad++),
   abrir o arquivo:
   `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`.
5. Confirmar visualmente que a primeira linha do arquivo e
   `Private Sub Carrega_CAD_SERV_Click()`. Se NAO for, parar e abrir
   issue — o pacote esta corrompido.
6. `Ctrl+A` (selecionar tudo do arquivo) e `Ctrl+C` (copiar).
7. Voltar no VBE, na janela de codigo (que esta vazia), `Ctrl+V`
   (colar). Conferir que a primeira linha colada e
   `Private Sub Carrega_CAD_SERV_Click()` — sem nada antes (sem
   `VERSION 5.00`, sem `Begin {GUID}`, sem `Attribute VB_*`).
8. `Ctrl+S` para salvar projeto, depois `Debug > Compile VBAProject`.

Esperado: compilacao limpa, sem erro.

> **Erro "Invalido fora de um procedimento"** apos colar significa
> uma de duas coisas:
>
> 1. Voce abriu e colou de `src/vba/Configuracao_Inicial.frm` (cabecalho
>    FRM) por engano em vez do `.code-only.txt`. Solucao: refazer do
>    passo 1 usando o arquivo certo (caminho exato no passo 4).
> 2. Voce fez `File > Import` em algum momento. Solucao: rollback ao
>    backup `.xlsm` (secao 04) e refazer.
>
> Em qualquer caso, a primeira linha visivel no editor de codigo do
> VBE deve ser `Private Sub Carrega_CAD_SERV_Click()`. Se nao for,
> NAO compilar — apagar e refazer.

> **Erro "controle nao encontrado"** apos compilar significa que os
> 3 textboxes do designer nao foram renomeados (passo 01.4):
> `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`. Renomear em
> "Propriedades" do VBE com o form em modo design e recompilar.

## 03. Validacao pos-import

### 03.1 Compilacao

VBE > Debug > Compile VBAProject.

Esperado: nenhum erro.

### 03.2 Tela Sobre

No Excel, abrir o menu "Sobre" (ou rodar `App_Release.AppRelease_BuildImportadoRotulo`
no Imediato).

Esperado: rotulo `f7aa84f+ONDA05 (em homologação)`.

### 03.3 Configuracoes Iniciais

1. Menu Configuracoes > Configuracoes Iniciais.
2. Os 3 campos da regra de strikes mostram:
   - Nota de corte: `5,0`
   - Max strikes: `3`
   - Dias de suspensao: `90`
   (Se vierem com valores diferentes, e porque CONFIG ja tem outros
   valores gravados — esta CORRETO. Exemplo: o relato do dia 28/04
   mostrou MAX_STRIKES=1332 contaminado; basta ajustar para 3 e
   clicar Salvar.)
3. Ajustar se necessario, clicar Salvar.
4. Abrir aba CONFIG no Excel: confirmar que linha 2 colunas K, L, M
   tem os valores certos.

### 03.4 Limpar Base (caminho da interface)

1. Menu Configuracoes > Configuracoes Iniciais > Limpar Base.
2. Digite a senha de protecao.
3. Confirme a operacao.
4. Aguarde mensagem "Base de Dados Limpa com Sucesso!" com o
   relatorio detalhado.
5. Abrir abas EMPRESAS, ENTIDADE, CREDENCIADOS, PRE_OS, CAD_OS:
   esperado linha 1 com cabecalho canonico, linha 2 vazia.
6. Abrir aba `RPT_LIMPEZA_TOTAL` (recem-criada): contem o resumo
   da operacao.
7. Abrir abas ATIVIDADES, CAD_SERV, CONFIG: esperado intactas.
8. Salvar workbook (Ctrl+B).

### 03.5 Cenario "3 strikes"

Com NOTA_CORTE=5, MAX_STRIKES=3, DIAS_SUSPENSAO_STRIKE=90:

1. Cadastrar 1 empresa, 1 entidade, 1 credenciamento na atividade 001.
2. Emitir Pre-OS, fechar OS, avaliar com nota MEDIA < 5 (ex.: 3,0).
   Empresa permanece no rodizio (1 strike registrado).
3. Repetir 2x. Apos 3o strike, empresa e suspensa por 90 dias e
   removida do rodizio.
4. Conferir AUDIT_LOG: deve ter 3 eventos `EVT_AVALIACAO` e 1 evento
   de suspensao com `BASE=DIAS DIAS=90`.

## 04. Rollback

Se aparecer qualquer regressao:

1. Fechar Excel sem salvar.
2. Restaurar o backup `.xlsm` da pasta `backups/`.
3. Reportar o erro com print da MsgBox / print do AUDIT_LOG.

Os 4 arquivos da Onda 5 sao independentes: rollback parcial e possivel
trocando individualmente cada modulo.

## 05. Apos validacao final

1. Macro descartavel `Set_Config_Strikes_Padrao` no Project Explorer:
   clique direito > Remove Set_Config_Strikes_Padrao > No (nao exportar).
2. (Opcional) Macros `Limpa_Base_Total`, `Diag_Imediato`, `Diag_Simples`,
   `Reset_CNAE_Total` tambem podem ser removidas — toda a logica delas
   esta agora no projeto oficial. Mantenha em `local-ai/vba_import/`
   apenas como fallback de campo.
3. Salvar workbook (Ctrl+B).
4. Atualizar a tag em `App_Release.bas`:
   `f7aa84f+ONDA05-em-homologacao` -> `f7aa84f+ONDA05-homologado`
   apos commitar a onda no git.
