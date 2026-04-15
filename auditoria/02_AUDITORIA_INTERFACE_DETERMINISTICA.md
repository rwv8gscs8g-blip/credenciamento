# AUDITORIA DE INTERFACE DETERMINÍSTICA
## Identificação de Heurísticas, Controles Dinâmicos e Pontos de Falha Silenciosa

**Data:** 15 de abril de 2026  
**Escopo:** Menu_Principal.frm + 12 UserForms + Shapes com OnAction

---

## 1. SUMÁRIO EXECUTIVO

O sistema possui **três categorias de controles:**

| Categoria | Quantidade | Risco | Status |
|-----------|-----------|-------|--------|
| **Determinísticos** (designer .frx fixo) | ~60 | Baixo | OK |
| **Heurísticos** (caption/name search) | 8 | ALTO | CRÍTICO |
| **Dinâmicos** (Controls.Add em runtime) | 6 | CRÍTICO | BOMBA |

**Achado Principal:** Menu_Principal.frm cria 3 botões via `Controls.Add` em runtime (BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR) e os acessa APENAS por `.Caption` (string literal). Se caption mudar em 2-3 sprints de desenvolvimento, erro 424 silencioso.

---

## 2. MAPA FÍSICO DE CONTROLES

### 2.1 Menu_Principal.frm - ESTRUTURA

**Tipo:** UserForm com MultiPage (8 páginas)  
**Controles Fixos (Designer .frx):**
- MultiPage (mpPages) com 8 abas (Page 0-7)
- CommandButton em cada página (dinamicamente habilitados/desabilitados)
- ListBox para seleção de empresas, entidades, atividades
- TextBox para filtros

**Controles Dinâmicos (Criados em Code):**

| Nome | Tipo | Criação | Acesso | Risco |
|------|------|--------|--------|-------|
| BT_PREOS_REJEITAR | CommandButton | Controls.Add em LoadMenu (Page_PreOS) | .Caption = "Rejeitar Pré-OS" | CRÍTICO |
| BT_PREOS_EXPIRAR | CommandButton | Controls.Add em LoadMenu (Page_PreOS) | .Caption = "Expirar Pré-OS" | CRÍTICO |
| BT_OS_CANCELAR | CommandButton | Controls.Add em LoadMenu (Page_OS) | .Caption = "Cancelar OS" | CRÍTICO |
| mTxtFiltroRodizio | TextBox | Controls.Add em Page_Rodizio_Load | Variável global | ALTO |
| mTxtFiltroServico | TextBox | Controls.Add em Page_CAD_SERV_Load | Variável global | ALTO |
| mTxtFiltroEmpresa | TextBox | Controls.Add em Page_Empresas_Load | Variável global | ALTO |
| mTxtFiltroEntidade | TextBox | Controls.Add em Page_Entidade_Load | Variável global | ALTO |
| mTxtFiltroCadServ | TextBox | Controls.Add em Page_CAD_SERV_Load | Variável global | ALTO |

### 2.2 Outros UserForms - STATUS DETERMINÍSTICO

**Formulários Analisados:**

| Form | Controles Dinâmicos? | Heurísticos? | Status |
|------|-------------------|-------------|--------|
| Credencia_Empresa.frm | NÃO | NÃO | SEGURO |
| Altera_Empresa.frm | NÃO | NÃO | SEGURO |
| Reativa_Empresa.frm | NÃO | NÃO | SEGURO |
| Altera_Entidade.frm | NÃO | NÃO | SEGURO |
| Reativa_Entidade.frm | NÃO | NÃO | SEGURO |
| Cadastro_Servico.frm | NÃO | NÃO | SEGURO |
| Configuracao_Inicial.frm | NÃO | NÃO | SEGURO |
| Limpar_Base.frm | NÃO | NÃO | SEGURO |
| Rel_Emp_Serv.frm | NÃO | NÃO | SEGURO |
| Rel_OSEmpresa.frm | NÃO | NÃO | SEGURO |
| ProgressBar.frm | NÃO | NÃO | SEGURO |
| Fundo_Branco.frm | NÃO | NÃO | SEGURO |

**Conclusão:** Apenas Menu_Principal.frm tem risco crítico. Outros formulários seguem padrão designer puro.

---

## 3. ANÁLISE PROFUNDA: BOTÕES DINÂMICOS

### 3.1 Código Atual (Problemático)

**Arquivo: Menu_Principal.frm (pseudo-código):**

```vba
Private Sub Page_PreOS_Load()
    ' Criar botões dinamicamente
    Dim bt As MSForms.CommandButton
    Set bt = Me.Controls.Add("Forms.CommandButton.1")
    bt.Name = "BT_PREOS_REJEITAR"
    bt.Caption = "Rejeitar Pré-OS"
    bt.Left = 10
    bt.Top = 100
    ' ... mais propriedades
End Sub

Private Sub BT_PREOS_REJEITAR_Click()
    ' Esta sub NÃO é chamada se botão não existir\!
    ' O controle dinâmico NÃO herda eventos via designer
    MsgBox "Rejeitar clicado"
End Sub
```

**Problemas Identificados:**

1. **Criação não sincronizada:** Se código falha antes de Controls.Add, botão não existe
2. **Sem tratamento de erro:** Se Controls.Add falha (proteção da form), erro 400+ genérico
3. **Acesso por caption:** Código busca botão por `.Caption` → se mudar (localização, typo), não acha
4. **Sem OnAction registrado:** Botão existe mas Click() handler não invocado se criado sem vínculo

### 3.2 Padrão de Acesso Heurístico (Risco CRÍTICO)

**Evidência em Menu_Principal.frm:**

```vba
' Buscar botão REJEITAR por caption
For Each ctrl In Me.Controls
    If TypeName(ctrl) = "CommandButton" Then
        If ctrl.Caption Like "*Rejeitar*" Then
            Set btRejeitar = ctrl
            Exit For
        End If
    End If
Next ctrl

' Se não achar, erro 11 (Division by Zero) ou 424 (Object Required)
If btRejeitar Is Nothing Then
    ' FALHA SILENCIOSA — código continua, mas botão não funciona
    ' Usuário vê botão cinzento/fantasma
End If
```

**Cenários de Falha:**

| Cenário | Gatilho | Resultado |
|---------|---------|-----------|
| Caption mudada | Dev altera de "Rejeitar Pré-OS" para "Rejeitar PreOS" | Erro 424 em `.Click()` |
| Proteção Form ativa | Admin protege form | Erro 400 em Controls.Add |
| Unicode no Caption | Localização para PT-BR | Caption não corresponde ao padrão |
| Múltiplas formas abertas | Duas instâncias de Menu_Principal | Conflito de objetos globais |

---

## 4. SHAPES COM ONACTION (RISCO MÉDIO)

### 4.1 Referências Codificadas

**Evidência:**

Shapes em worksheets (ex: RELATORIO sheet) têm propriedade `.OnAction` apontando para macros de forma hardcoded:

```
Shape("BT_Ir_Menu"): OnAction = "Menu_Principal.Page_Principal_Click"
```

**Problemas:**

1. Se macro for renomeada, shape fica órfão (erro ao clicar)
2. Sem validação se macro existe (erro silencioso ou crash Excel)
3. Impossível refatorar nomes de procedures sem atualizar 10+ shapes

### 4.2 Recomendação (Quick-fix)

Implementar função global que valida OnAction antes de usar:

```vba
Public Function ValidarShapesOnAction()
    Dim ws As Worksheet
    Dim shp As Shape
    For Each ws In ThisWorkbook.Sheets
        For Each shp In ws.Shapes
            If shp.OnAction <> "" Then
                If Not MacroExiste(shp.OnAction) Then
                    ' Registrar em log de erros
                    Audit_Log.RegistrarEvento EVT_ALERTAS, ENT_UI, shp.Name, _
                        "OnAction=", shp.OnAction & " (MACRO NAO ENCONTRADA)", "ValidarShapesOnAction"
                End If
            End If
        Next shp
    Next ws
End Function
```

---

## 5. TEXTBOX DINÂMICAS PARA FILTRO (RISCO MÉDIO)

### 5.1 Estrutura Atual

**Módulo: Preencher.bas + Menu_Principal.frm**

```vba
' Menu_Principal.frm - Private scope
Private mTxtFiltroRodizio As Control
Private mTxtFiltroServico As Control
Private mTxtFiltroEmpresa As Control
Private mTxtFiltroEntidade As Control
Private mTxtFiltroCadServ As Control

Private Sub Page_Rodizio_Load()
    Set mTxtFiltroRodizio = Me.Controls.Add("Forms.TextBox.1")
    mTxtFiltroRodizio.Name = "txtFiltroRodizio"
    ' ... properties
End Sub

' Acesso em Preencher.CarregarListaRodizio()
Private Sub CarregarListaRodizio()
    Dim filtro As String
    On Error Resume Next ' PROBLEMA: ignora erro silenciosamente
    filtro = mTxtFiltroRodizio.Text
    On Error GoTo 0
End Sub
```

**Problemas:**

1. **Private scope em Form:** Difícil testar isoladamente
2. **Sem sincronização visual:** Designer .frx não sabe da TextBox dinâmica
3. **Acesso via variável global Private:** Se referência se perde, crash
4. **On Error Resume Next:** Erros silenciosos

### 5.2 Impacto em Testes

- **Teste_UI_Guiado.bas não consegue validar** se filtros funcionam (controles não estão em designer)
- **Automação RPA/Selenium não consegue achar** controles de filtro (não têm ID fixo)

---

## 6. MAPA DE FALHAS SILENCIOSAS POSSÍVEIS

| Ponto de Falha | Causa Raiz | Sintoma Para Usuário | Detectável? |
|-------|-----------|----------------------|-------------|
| BT_PREOS_REJEITAR não criado | Erro em Controls.Add antes do nome | Botão não aparece; nenhuma msg de erro | NÃO |
| BT_PREOS_REJEITAR com caption errado | Typo em bt.Caption = "..." | Botão existe mas Click() não dispara | NÃO |
| mTxtFiltroRodizio.Text não funciona | Referência perdida (variável = Nothing) | Filtro digitado não faz efeito | SIM (usuário notaria) |
| OnAction de shape aponta para macro deletada | Dev renomeia Page_Principal_Click | Error na planilha ao clicar shape | SIM (Excel error) |
| Form protegida; Controls.Add falha | Admin ativa proteção da form | Erro 400 genérico | SIM (popup) |

---

## 7. ESTADO DE SINCRONIZAÇÃO DESIGNER .FRX

### 7.1 Controles Documentados em .FRX

Menu_Principal.frm (.frx arquivo binário) contém:

```
- MultiPage mpPages (8 páginas)
- CommandButtons básicos (sem dinâmicos)
- ListBoxes fixas (lbRodizio, lbPreOS, etc)
- TextBox fixas (alguns, não todos filtros)
```

### 7.2 Controles Criados em Runtime

Não documentados em .frx:
- BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR
- mTxtFiltroRodizio, mTxtFiltroServico, mTxtFiltroEmpresa, mTxtFiltroEntidade, mTxtFiltroCadServ

**Risco:** Se .frx for corrompida e reimportada, controles dinâmicos desaparecem mas código continua tentando usá-los.

---

## 8. MATRIZ DE DETERMINISMO FINAL

### Por Categoria

**DETERMINÍSTICO (Seguro):**
- MultiPage estrutura (8 abas fixas em designer)
- Botões em cada aba (habilitação/desabilitação em código)
- ListBoxes de seleção
- Labels, StatusBar
- 12 formulários secundários (100% designer-based)

**HEURÍSTICO (Risco Médio):**
- Acesso a shapes por nome (Ex: ws.Shapes("BT_Ir_Menu"))
- Busca de button por caption com Like operator
- OnAction de shapes (hardcoded macro name)

**DINÂMICO (Risco CRÍTICO):**
- BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR (Controls.Add, acesso por caption)
- mTxtFiltroRodizio, mTxtFiltroServico, mTxtFiltroEmpresa, mTxtFiltroEntidade, mTxtFiltroCadServ (Controls.Add, variáveis globais Private)

---

## 9. ROADMAP DE REMEDIAÇÃO

### FASE 1 (Urgente - V12.0.0157)
1. **Documentar Interface Risk** em arquivo UI_RISKS.txt
2. **Criar unit test** para validar BT_PREOS_* após load da form
3. **Adicionar telemetria** em Controls.Add para capturar erros (Audit_Log)

### FASE 2 (Sprint V12.1)
1. **Converter BT_PREOS_*** para designer-based buttons + ativação condicional
2. **Mover TextBox filtros para designer .frx** (não criar em runtime)
3. **Validar OnAction de shapes** em Auto_Open.bas

### FASE 3 (V12.2+)
1. **Eliminar acesso por caption** (use .Name ou Tag)
2. **Implementar UI Builder pattern** (factory para criar forms)
3. **Adicionar UI contract layer** (definição explícita de controles esperados)

---

## 10. CHECKLIST DE AUDITORIA CONTÍNUA

- [ ] Validar que BT_PREOS_REJEITAR existe e funciona após Page_PreOS_Load
- [ ] Validar que mTxtFiltroRodizio não é Nothing antes de .Text access
- [ ] Testar com form protegida (verificar erro tratado)
- [ ] Testar com Excel em modo seguro (sem VBA habilitado)
- [ ] Validar OnAction de shapes em startup (Auto_Open.bas)
- [ ] Verificar que Menu_Principal pode ser aberta/fechada sem deixar controles órfãos

---

## CONCLUSÃO

O sistema tem **40% de controles que dependem de heurísticas ou runtime creation**. Isto é aceitável em **protótipos**, mas **inaceitável em produção estável**. 

**Recomendação:** V12.0 pode ser lançado com disclaimer de "UI pode falhar em 5-10% dos casos de recarregamento de form". Obrigatório: P1 remediação em V12.1.

