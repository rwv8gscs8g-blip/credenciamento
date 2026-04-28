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

> Estrategia: como o `.frx` (binario com a posicao/tamanho dos
> controles) ja foi customizado pelo gestor com os textboxes renomeados,
> NAO reimportar o form. Substituir apenas o codigo atras do form.
>
> **ATENCAO:** o arquivo `.frm` em si tem 15 linhas iniciais de
> cabecalho que NAO sao codigo VBA (sao metadados do designer:
> `VERSION 5.00`, `Begin {GUID} ... End`, blocos `Attribute VB_*`).
> Se essas linhas forem coladas no editor de codigo do VBE, voce
> recebe "Erro de compilacao: Invalido fora de um procedimento".
>
> Para evitar esse erro, use o arquivo CODE-ONLY:
> **`local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`**

1. VBE > duplo-clique em `Configuracao_Inicial` (aparece o designer).
2. Clicar em "Visualizar Codigo" (F7) — abre a janela com o VBA do form.
3. Selecionar TODO o codigo da janela (Ctrl+A) e Delete.
4. Abrir o arquivo `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt`
   em um editor de texto (Notepad, VS Code, etc.).
5. **Pular o cabecalho de comentarios** desse arquivo (de
   `' ============================================================` ate
   a linha em branco logo apos `' ============================================================`
   — sao as primeiras ~40 linhas, todas comecando com aspa simples).
6. Selecionar a partir da primeira `Private Sub` ate o final do arquivo.
7. Copiar (Ctrl+C) e colar (Ctrl+V) na janela de codigo do VBE.
8. Salvar projeto (Ctrl+B).
9. Debug > Compile VBAProject.

> **Recuperacao se voce ja colou errado** (erro "Invalido fora de
> um procedimento"):
>
> - O codigo no editor comeca com `VERSION 5.00` ou `Begin {GUID}`.
> - Apague essas linhas iniciais ate a primeira `Private Sub` (apague
>   tambem as linhas `Attribute VB_*` se aparecerem — o VBE gerencia
>   esses atributos automaticamente).
> - Compilar de novo (Debug > Compile VBAProject).
> - Salvar (Ctrl+B).
>
> Se aparecer outro erro de compilacao "controle nao encontrado",
> confirmar que os 3 textboxes foram renomeados no designer
> (passo 01.4).

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
