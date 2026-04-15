# 13 UserForms - Interface de Usuario

## Organizacao por Funcionalidade

### Menu e Configuracao (2 forms)

#### Menu_Principal
**Uso**: Tela inicial apos Auto_Open, acesso a todas funcionalidades.

**Elementos**:
- Button "Credenciar Empresa" → Abre Credencia_Empresa form
- Button "Alterar Empresa" → Abre Altera_Empresa form
- Button "Reativar Empresa" → Abre Reativa_Empresa form
- Button "Gerenciar Entidades" → Submenu (Alterar / Reativar)
- Button "Cadastrar Servico" → Abre Cadastro_Servico form
- Button "Criar Ordem de Servico" → Abre Menu secundario (Pre-OS / OS)
- Button "Relatorios" → Submenu (Empresa-Servico / OS-Empresa)
- Button "Testes" (se gDebugMode=True) → Abre Central_Testes relatorio
- Button "Configuracoes" → Abre Configuracao_Inicial form
- Button "Treinamento" → Abre Treinamento_Painel form
- Button "Sair" → Confirma fechamento

**Validacoes**:
- Nenhuma (menu nao restringe)

**Dependencias**: Todas as forms citadas

**Campo de Auditoria**: Log em AuditLog qdo form abre, qdo usuario clica button

---

#### Configuracao_Inicial
**Uso**: Setup de prefeitura, usuarios, opcoes (executado primeira vez).

**Elementos**:
- TextBox "Nome da Prefeitura" (obrigatorio)
- TextBox "Usuario Padrao" (obrigatorio)
- Dropdown "Ambiente" (DEV / PROD)
- Checkbox "Ativar Debug Mode"
- Checkbox "Ativar Cache"
- TextBox "Dias Retencao AuditLog" (default 365)
- Dropdown "Algoritmo Rodizio" (PONDERADO / RR)
- Button "Salvar Configuracao"
- Button "Cancelar"

**Validacoes**:
- Nome Prefeitura nao vazio
- Usuario Padrao nao vazio
- Dias Retencao >= 30

**Fluxo**:
1. Usuario preenche campos
2. Clica Salvar
3. Form chama Util_Config.SalvarConfig(config)
4. Se sucesso, fecha form e continua Auto_Open
5. Se erro, mostra MsgBox e deixa form aberto

**Dependencias**: Util_Config

**Campo de Auditoria**: Log em AuditLog ao salvar configuracao

---

### Gestao de Empresas (3 forms)

#### Credencia_Empresa
**Uso**: Criar nova empresa com validacao em tempo real.

**Elementos**:
- TextBox "CNPJ" (mascara: XX.XXX.XXX/XXXX-XX)
  - OnChange: valida formato e unicidade em tempo real
  - Feedback: cor vermelha se erro, verde se OK
- TextBox "Nome da Empresa"
  - OnChange: nao vazio check
- TextBox "Endereco"
  - OnChange: nao vazio check
- TextBox "Contato (telefone ou email)"
  - OnChange: regex de telefone ou email
- Button "Buscar Dados Externo" (futuro: integrar com API publica CNPJ)
- Button "Limpar Campos"
- Button "OK" (ativado so se todos campos OK)
- Button "Cancelar"

**Validacoes Integracao**:
```vba
Private Sub CNPJ_Change()
    Dim resultado As Boolean
    resultado = Util_Conversao.ValidarCNPJ(Me.CNPJ.Value)
    If resultado Then
        Me.CNPJ.BackColor = RGB(144, 238, 144) ' verde
    Else
        Me.CNPJ.BackColor = RGB(255, 99, 71) ' vermelho
    End If
End Sub

Private Sub OK_Click()
    Dim emp As TEmpresa
    emp.Nome = Me.Nome.Value
    emp.CNPJ = Me.CNPJ.Value
    emp.Endereco = Me.Endereco.Value
    emp.Contato = Me.Contato.Value
    emp.Ativo = True
    
    Dim res As TResult
    res = Repo_Credenciamento.CriarEmpresa(emp)
    
    If res.Sucesso Then
        MsgBox "Empresa criada com sucesso! ID: " & res.Dados
        Unload Me
    Else
        MsgBox "Erro: " & res.Mensagem
    End If
End Sub
```

**Fluxo**:
1. Form abre
2. Usuario digita CNPJ
3. Validacao em tempo real (cor feedback)
4. Se tudo OK, button OK ativado
5. Clica OK
6. Repo_Credenciamento.CriarEmpresa() executado
7. AuditLog registra insercao
8. Form fecha com sucesso

**Dependencias**: Repo_Credenciamento, Util_Conversao, Audit_Log

**Campo de Auditoria**: Log de insercao

---

#### Altera_Empresa
**Uso**: Editar dados de empresa existente.

**Elementos**:
- TextBox "Buscar por CNPJ ou Nome"
  - OnChange: autocomplete com lista de empresas ativas
  - Dropdown abaixo mostra resultados
- Form preenchido com dados existentes (read-only inicialmente)
- Button "Editar" → Libera TextBoxes para edicao
- Button "Salvar" (so visivel apos editar)
- Button "Cancelar"

**Fluxo**:
1. Usuario digita CNPJ/Nome em busca
2. Dropdown mostra empresas que correspondem
3. Usuario seleciona uma
4. Form popula com dados da empresa (read-only)
5. Clica "Editar"
6. TextBoxes ficam editaveis
7. Usuario muda dados
8. Clica "Salvar"
9. Repo_Credenciamento.AtualizarEmpresa() executado
10. AuditLog registra atualizacao (campos mudados)
11. Form fecha

**Validacoes**:
- CNPJ nao pode virar duplicado (exceto self)
- Nome nao pode ficar vazio
- Endereco validacao

**Dependencias**: Repo_Credenciamento, Util_Conversao, Audit_Log

**Campo de Auditoria**: Log de atualizacao com detalhes de campo antigo → novo

---

#### Reativa_Empresa
**Uso**: Reativar empresa que foi desativada (soft delete).

**Elementos**:
- TextBox "Buscar por CNPJ ou Nome"
  - Mostra APENAS empresas onde Ativo=False
- Dropdown com resultados
- Grid com coluna: CNPJ | Nome | DataDesativacao | Button Reativar
- Button "Reativar" por linha
- Button "Fechar"

**Fluxo**:
1. Usuario digita busca
2. Grid mostra empresas desativadas que correspondem
3. Clica "Reativar" em uma linha
4. Confirmacao: "Tem certeza?"
5. Repo_Credenciamento.AtualizarEmpresa() com Ativo=True
6. AuditLog registra reativacao
7. Grid atualiza (linha desaparece)

**Dependencias**: Repo_Credenciamento, Audit_Log

**Campo de Auditoria**: Log de reativacao

---

### Gestao de Entidades (2 forms)

#### Altera_Entidade
**Uso**: Editar estrutura juridica de empresa (CNPJ Matriz, CNPJ Filial, etc).

**Elementos**:
- Dropdown "Selecionar Empresa"
- Grid: Id | CNPJ | Nome | Tipo | Button Editar | Button Deletar
  - Tipos: "MATRIZ", "FILIAL", "PROCURACAO"
- Button "Nova Entidade" → Abre dialog com TextBoxes
- Button "Fechar"

**Fluxo Edicao**:
1. Usuario seleciona empresa
2. Grid mostra todas entidades (Ativo=True)
3. Clica "Editar" em uma linha
4. Dialog abre com CNPJ, Nome, Tipo editaveis
5. Clica "Salvar"
6. Repo_Credenciamento.AtualizarEntidade() executado
7. AuditLog registra
8. Grid atualiza

**Fluxo Nova Entidade**:
1. Button "Nova Entidade"
2. Dialog abre
3. Usuario preenche CNPJ, Nome, Tipo
4. Clica OK
5. Repo_Credenciamento.CriarEntidade() executado
6. Grid atualiza

**Dependencias**: Repo_Credenciamento, Audit_Log

**Campo de Auditoria**: Log de alteracao/insercao

---

#### Reativa_Entidade
**Uso**: Reativar entidade desativada.

**Elementos**:
- Dropdown "Selecionar Empresa"
- Grid com entidades desativadas (Ativo=False)
- Button "Reativar" por linha
- Button "Fechar"

**Fluxo**:
1. Usuario seleciona empresa
2. Grid mostra entidades desativadas
3. Clica "Reativar"
4. Confirmacao
5. Repo_Credenciamento.AtualizarEntidade() com Ativo=True
6. AuditLog registra
7. Grid atualiza

**Dependencias**: Repo_Credenciamento, Audit_Log

**Campo de Auditoria**: Log de reativacao

---

### Cadastro de Servicos (1 form)

#### Cadastro_Servico
**Uso**: Registrar novo servico (atividade) e alocar para empresa(s).

**Elementos**:
- TextBox "Nome do Servico" (ex: "Reparos de eletrica residencial")
- TextBox "Descricao" (opcional)
- Button "Classificar Automaticamente"
  - Chama Classificar.ClassificarServico(nomeServico)
  - Mostra ProgressBar enquanto classifica
  - Popula Label "Classificacao Detectada: ELETRICA"
- Dropdown "Classificacao" (override manual se necessario)
  - Opcoes: ELETRICA, ENCANAMENTO, LIMPEZA, REFORMA, OUTRO
- Label "Empresa(s) Credenciadas"
- Grid: EmpresaId | Nome | DataCredenciamento | Checkbox Alocar
- Button "Registrar Servico e Alocar" (so ativado se >= 1 empresa selecionada)
- Button "Cancelar"

**Fluxo**:
1. Usuario digita nome servico
2. Clica "Classificar Automaticamente"
3. ProgressBar mostra progresso
4. Label mostra resultado (ex: "ELETRICA")
5. Usuario confirma ou muda classificacao
6. Grid popula com empresas que podem oferecer este tipo de servico
7. Usuario seleciona checkbox para empresas que quer alocar
8. Clica "Registrar Servico e Alocar"
9. Fluxo:
   - Repo_Credenciamento.CriarAtividade() cria novo servico
   - Para cada empresa selecionada:
     - Repo_Credenciamento.CriarCredenciamento(empresaId, atividadeId)
   - AuditLog registra alocacoes
10. Form fecha com mensagem de sucesso

**Dependencias**: Classificar, Repo_Credenciamento, Audit_Log, ProgressBar (form)

**Campo de Auditoria**: Log de criacao de atividade + log de alocacoes

---

### Operacional (3 forms)

#### Fundo_Branco
**Uso**: Tela auxiliar branca para operacoes especiais (flexivel).

**Elementos**:
- Tela em branco
- Pode ser populada dinamicamente por outros modulos

**Proposito**: Auxilia em operacoes que nao cabem em forms pre-definidas.

**Exemplo de Uso**:
```vba
' Em algum modulo Service
Dim frm As Object
Set frm = New Fundo_Branco
frm.Label1.Caption = "Processando..."
frm.Show
' ... processamento
frm.Hide
```

**Dependencias**: Nenhuma (generico)

---

#### Limpar_Base
**Uso**: Limpeza de dados de teste. PERIGOSO - requer confirmacoes multiplas.

**Elementos**:
- Label "AVISO: Esta operacao e IRREVERSIVEL"
- Label "Selecione o que deletar:"
- Checkbox "Deletar Pre-Ordens de Servico (PreOS)"
- Checkbox "Deletar Ordens de Servico (OS)"
- Checkbox "Deletar Avaliacoes"
- Checkbox "Deletar Todas Empresas" (PERIGO!)
- TextBox "Digite 'SIM' para confirmar"
- Button "Deletar" (desativado ate TextBox="SIM")
- Button "Cancelar"

**Validacoes**:
- Se Deletar Todas Empresas checked: aviso adicional
- TextBox deve conter exatamente "SIM" (case-sensitive)
- Confirmacao multipla: "Tem certeza? Esta nao pode ser desfeita"

**Fluxo**:
1. Usuario marca checkboxes
2. Se algum importante (Empresas), aviso adicional
3. Digita "SIM"
4. Button Deletar ativado
5. Clica Deletar
6. Confirmacao final: "Tem certeza? Esta operacao e IRREVERSIVEL"
7. Se sim:
   - Para cada checkbox marcada:
     - Deleta linhas correspondentes em planilha (hard delete)
   - AuditLog registra limpeza
   - MsgBox "Limpeza concluida"
8. Form fecha

**Dependencias**: Util_Planilha, Audit_Log

**Campo de Auditoria**: Log DETALHADO de limpeza (qdo, por quem, quanto deletou)

---

#### ProgressBar
**Uso**: Barra visual de progresso para operacoes longas.

**Elementos**:
- Label "Processando..."
- ProgressBar (0-100%)
- Label com numero "X / Y" (progresso)
- Button "Cancelar" (cancela operacao em progresso)

**Uso Programatico**:
```vba
Dim frm As Fundo_Branco
Set frm = New Fundo_Branco
frm.Show

Dim progBar As New ProgressBar
progBar.Label1.Caption = "Importando CNAE..."
progBar.Show

For i = 1 To 10000
    ' ... processamento
    progBar.ProgressBar1.Value = (i / 10000) * 100
    progBar.Label2.Caption = i & " / 10000"
    DoEvents ' Permite cancelamento
Next i

Unload progBar
```

**Dependencias**: Nenhuma

---

### Relatórios (2 forms)

#### Rel_Emp_Serv
**Uso**: Relatorio de empresas e servicos que elas oferece(m).

**Elementos**:
- Label "Relatorio: Empresas por Servico"
- TextBox "Buscar Empresa (CNPJ ou Nome)" + Button "Buscar"
- Dropdown "Filtrar por Classificacao" (ELETRICA, ENCANAMENTO, etc)
- Button "Limpar Filtros"
- Grid: EmpresaId | Nome | CNPJ | Servico | Classificacao | DataCredenciamento | Status
- Button "Exportar como CSV"
- Button "Imprimir"
- Button "Fechar"

**Fluxo**:
1. Form abre, carrega todas empresas com credenciamentos
2. Usuario pode filtrar:
   - Por nome empresa (search)
   - Por classificacao (dropdown)
3. Grid atualiza em tempo real
4. Pode exportar como CSV ou imprimir
5. CSV path: Documents\Relatorios\Rel_EmpServ_[timestamp].csv

**Dependencias**: Repo_Credenciamento, Audit_Log

**Campo de Auditoria**: Log qdo relatorio exportado/impresso

---

#### Rel_OSEmpresa
**Uso**: Relatorio de ordens de servico por empresa. Pode registrar avaliacao direto.

**Elementos**:
- Label "Relatorio: Ordens de Servico por Empresa"
- Dropdown "Selecionar Empresa"
- DatePicker "De Data"
- DatePicker "Ate Data"
- Button "Filtrar"
- Grid: NumeroOS | DataEmissao | Status | NotaAvaliacao | Button Avaliar
- Button "Exportar como CSV"
- Button "Imprimir"
- Button "Fechar"

**Grid Columns**:
- NumeroOS (ex: "SAO_PAULO-20260410-00001")
- DataEmissao
- Status (EMITIDA, EM_PROGRESSO, CONCLUIDA)
- NotaAvaliacao (1-5, ou vazio se nao avaliada)
- Button "Avaliar" ou "Ver Avaliacao"

**Fluxo Avaliacao**:
1. Usuario clica "Avaliar" em uma linha
2. Dialog abre com:
   - Label: "Nota (1-5):"
   - Spinner ou RadioButtons 1-5
   - TextBox "Comentario"
   - Button OK / Cancelar
3. Usuario seleciona nota e digita comentario (opcional)
4. Clica OK
5. Svc_Avaliacao.RegistrarAvaliacao() executado
6. AuditLog registra
7. Grid atualiza com nota nova
8. Media empresa recalculada

**Dependencias**: Repo_OS, Svc_Avaliacao, Audit_Log

**Campo de Auditoria**: Log de registracao de avaliacao

---

## Padroes Comuns em Todos Forms

### Tratamento de Erro
```vba
Private Sub Form_Load()
    On Error GoTo ErrorHandler
    ' ... inicializacao
    Exit Sub
ErrorHandler:
    Dim res As TResult
    res = ErrorBoundary.CatchError(Err.Number, Err.Description, "Form_NomeDaForm")
    MsgBox res.Mensagem
End Sub
```

### Validacao em Tempo Real
```vba
Private Sub TextBox1_Change()
    Dim res As TResult
    res = Util_Conversao.ValidarEmpresa(/* ... */)
    
    If res.Sucesso Then
        Me.TextBox1.BackColor = RGB(144, 238, 144) ' verde
        Me.CommandButton_OK.Enabled = True
    Else
        Me.TextBox1.BackColor = RGB(255, 99, 71) ' vermelho
        Me.CommandButton_OK.Enabled = False
    End If
End Sub
```

### Auditoria de Interacao
```vba
Private Sub CommandButton_OK_Click()
    ' Log de tentativa
    Audit_Log.LogOperacao("FORM_SUBMIT", "Credencia_Empresa", "Usuario tentou criar empresa")
    
    ' ... fluxo
    
    ' Log de sucesso
    Audit_Log.LogOperacao("FORM_SUCCESS", "Credencia_Empresa", "Empresa criada ID=" & novoId)
End Sub
```

### Confirmacoes de Risco
```vba
Private Sub CommandButton_Deletar_Click()
    Dim resposta As VbMsgBoxResult
    resposta = MsgBox("Tem certeza que deseja deletar?", vbYesNo + vbQuestion, "Confirmacao")
    
    If resposta = vbYes Then
        ' Executa delecao
        ' Log
    End If
End Sub
```

---

**Total de Forms**: 13
**Linhas de Codigo (estimado)**: ~2.500
**Ultima Atualizacao**: 2026-04-10
