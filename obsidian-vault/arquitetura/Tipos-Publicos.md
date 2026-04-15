# 12 Tipos Publicos (Mod_Types.bas)

**CRITICIDADE**: MAXIMA. Estes tipos sao a base de todo sistema.

---

## Lei de Tipos

1. TODOS tipos publicos definidos APENAS em Mod_Types.bas
2. NUNCA defina Type fora de Mod_Types.bas
3. NUNCA copie Type definition entre modulos
4. Se mudar Type existente, BUMP version (V12.0.0107 → V12.0.0108)
5. Se adicionar Type novo, mesma versao OK

---

## Diagrama de Tipos

```
TResult (return type)
  ├── Sucesso: Boolean
  ├── Mensagem: String
  ├── Codigo: Long
  └── Dados: Variant (contem qualquer resultado)

Tipos de Dominio (Entidades)
  ├── TEmpresa
  ├── TEntidade
  ├── TAtividade
  ├── TServico
  ├── TCredenciamento
  ├── TPreOS
  ├── TOS
  └── TAvaliacao

Tipos de Infraestrutura
  ├── TConfig (parametros da app)
  ├── TRodizioResultado (output do algoritmo)
  └── TAppContext (contexto de sessao)
```

---

## 1. TResult (Type de Retorno)

**Uso**: Retorno padrao de TODAS funcoes que podem falhar.

**Definicao**:
```vba
Type TResult
  Sucesso As Boolean
  Mensagem As String
  Codigo As Long
  Dados As Variant
End Type
```

**Campos**:
- **Sucesso** (Boolean): True se operacao completou, False se erro
- **Mensagem** (String): Mensagem descritiva (sucesso ou erro detalhado)
- **Codigo** (Long): Codigo de erro (0 = sem erro, >0 = erro especifico)
- **Dados** (Variant): Resultado da operacao (ID novo, collection, etc)

**Exemplos de Uso**:

```vba
' Exemplo 1: Criar empresa
Dim res As TResult
res = Repo_Credenciamento.CriarEmpresa(emp)

If res.Sucesso Then
  Dim novoId As Long
  novoId = CLng(res.Dados)
  MsgBox "Empresa criada com ID " & novoId
Else
  MsgBox "Erro: " & res.Mensagem & " (Codigo: " & res.Codigo & ")"
End If

' Exemplo 2: Listar empresas
res = Repo_Credenciamento.ListarEmpresas()
If res.Sucesso Then
  Dim empresas As Collection
  Set empresas = CType(res.Dados, Collection)
  ' ... processar collection
End If
```

**Codigos de Erro Comuns**:
- 0: Sucesso
- 1001: Validacao falhou
- 1002: Duplicado encontrado
- 1003: Nao encontrado
- 2001: Erro de banco de dados
- 3001: Erro de compilacao/runtime

---

## 2. TEmpresa

**Uso**: Representa empresa cadastrada no sistema.

**Definicao**:
```vba
Type TEmpresa
  Id As Long
  Nome As String
  CNPJ As String
  Endereco As String
  Contato As String
  Ativo As Boolean
End Type
```

**Campos**:
- **Id** (Long): Chave primaria, auto-increment
- **Nome** (String): Nome da empresa, obrigatorio, max 255 chars
- **CNPJ** (String): XX.XXX.XXX/XXXX-XX, obrigatorio, unico, validado
- **Endereco** (String): Endereco completo, obrigatorio
- **Contato** (String): Telefone ou email, obrigatorio
- **Ativo** (Boolean): True = ativa, False = desativada (soft delete)

**Regras**:
- CNPJ deve ser unico no sistema
- CNPJ deve passar validacao de digitos verificadores
- Nome nao pode ser vazio
- Soft delete: nunca hard delete (Ativo = False)

**Exemplo de Uso**:
```vba
Dim emp As TEmpresa
emp.Nome = "Empresa XYZ"
emp.CNPJ = "12.345.678/0001-90"
emp.Endereco = "Rua A, 123"
emp.Contato = "(11) 98765-4321"
emp.Ativo = True

Dim res As TResult
res = Repo_Credenciamento.CriarEmpresa(emp)
```

---

## 3. TEntidade

**Uso**: Representa estrutura juridica dentro empresa (Matriz, Filial, Procuracao).

**Definicao**:
```vba
Type TEntidade
  Id As Long
  EmpresaId As Long
  Nome As String
  Tipo As String
  Ativo As Boolean
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **EmpresaId** (Long): Chave estrangeira para TEmpresa.Id
- **Nome** (String): Nome da entidade (ex: "Filial Sao Paulo")
- **Tipo** (String): "MATRIZ", "FILIAL", "PROCURACAO"
- **Ativo** (Boolean): True = ativa

**Regras**:
- EmpresaId deve existir em planilha Empresa
- Tipo deve estar em lista permitida
- Uma empresa pode ter multiplas entidades
- Soft delete (Ativo = False)

**Exemplo de Uso**:
```vba
Dim ent As TEntidade
ent.EmpresaId = 1
ent.Nome = "Filial Rio de Janeiro"
ent.Tipo = "FILIAL"
ent.Ativo = True

Dim res As TResult
res = Repo_Credenciamento.CriarEntidade(ent)
```

---

## 4. TAtividade

**Uso**: Tipo de servico/atividade disponivel na prefeitura.

**Definicao**:
```vba
Type TAtividade
  Id As Long
  Nome As String
  Descricao As String
  Ativo As Boolean
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **Nome** (String): Nome descritivo (ex: "Reparos de Eletrica")
- **Descricao** (String): Descricao detalhada (opcional)
- **Ativo** (Boolean): True = disponivel

**Regras**:
- Nome obrigatorio, max 255 chars
- Uma atividade pode ter multiplas empresas credenciadas
- Soft delete

**Exemplo de Uso**:
```vba
Dim ativ As TAtividade
ativ.Nome = "Reparos de Encanamento"
ativ.Descricao = "Servicos de encanamento residencial e comercial"
ativ.Ativo = True

Dim res As TResult
res = Repo_Credenciamento.CriarAtividade(ativ)
```

---

## 5. TServico

**Uso**: Atualmente nao utilizado (TAtividade já serve). Reservado para futuro.

**Definicao**:
```vba
Type TServico
  Id As Long
  Nome As String
  Classificacao As String
  Ativo As Boolean
End Type
```

**Nota**: Implementacao pode divergir de TAtividade no futuro se precisar diferenca entre tipo generico (Atividade) e instancia (Servico).

---

## 6. TCredenciamento

**Uso**: Relacionamento entre empresa e atividade (quem pode fazer o que).

**Definicao**:
```vba
Type TCredenciamento
  Id As Long
  EmpresaId As Long
  Entidade As String
  DataCredenciamento As Date
  Ativo As Boolean
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **EmpresaId** (Long): Chave estrangeira para TEmpresa.Id
- **Entidade** (String): Nome da entidade ou atividade (campo flexivel)
- **DataCredenciamento** (Date): Quando empresa foi credenciada
- **Ativo** (Boolean): True = credenciamento ativo

**Regras**:
- Uma empresa pode ter multiplos credenciamentos (uma por atividade)
- DataCredenciamento nao pode ser futura
- Soft delete

**Exemplo de Uso**:
```vba
Dim cred As TCredenciamento
cred.EmpresaId = 1
cred.Entidade = "Reparos de Eletrica"
cred.DataCredenciamento = Date
cred.Ativo = True

Dim res As TResult
res = Repo_Credenciamento.CriarCredenciamento(cred)
```

---

## 7. TPreOS (Pre-Ordem de Servico)

**Uso**: Rascunho de ordem de servico antes de ser finalizado.

**Definicao**:
```vba
Type TPreOS
  Id As Long
  EmpresaId As Long
  AtividadeId As Long
  DataCriacao As Date
  Status As String
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **EmpresaId** (Long): Empresa selecionada
- **AtividadeId** (Long): Atividade/servico
- **DataCriacao** (Date): Quando pre-OS foi criada
- **Status** (String): "RASCUNHO", "VALIDADA", "CONVERTIDA"

**Fluxo de Status**:
```
RASCUNHO (criada, pode editar)
    ↓
VALIDADA (validacao passada, pronta para converter)
    ↓
CONVERTIDA (virou TOS, pre-OS nao mais usada)
```

**Exemplo de Uso**:
```vba
Dim preOS As TPreOS
preOS.EmpresaId = 1
preOS.AtividadeId = 5
preOS.DataCriacao = Date
preOS.Status = "RASCUNHO"

Dim res As TResult
res = Repo_PreOS.CriarPreOS(preOS)
```

---

## 8. TOS (Ordem de Servico)

**Uso**: Ordem de servico finalizada, pronta para executar.

**Definicao**:
```vba
Type TOS
  Id As Long
  PreOSId As Long
  Numero As String
  DataEmissao As Date
  DataConclusao As Date
  Status As String
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **PreOSId** (Long): Referencia para pre-OS origem
- **Numero** (String): Numero unico (PREFEITURA-YYYYMMDD-SEQUENCIA)
- **DataEmissao** (Date): Quando OS foi emitida
- **DataConclusao** (Date): Quando servico foi concluido (opcional ate Status=CONCLUIDA)
- **Status** (String): "EMITIDA", "EM_PROGRESSO", "CONCLUIDA", "CANCELADA"

**Fluxo de Status**:
```
EMITIDA (criada, enviada para empresa)
    ↓
EM_PROGRESSO (empresa comecou trabalho)
    ↓
CONCLUIDA (servico finalizado)

Ou:
EMITIDA → CANCELADA (em qualquer momento)
```

**Regras**:
- Numero sempre unico
- DataConclusao obrigatoria quando Status=CONCLUIDA
- Uma OS pode ter zero ou uma avaliacao
- Soft delete nao usado (hard delete se cancelar)

**Exemplo de Uso**:
```vba
Dim os As TOS
os.PreOSId = 1
os.Numero = "SAO_PAULO-20260410-00001"
os.DataEmissao = Date
os.Status = "EMITIDA"

Dim res As TResult
res = Repo_OS.CriarOS(os)
```

---

## 9. TAvaliacao

**Uso**: Avaliacao de servico executado apos conclusao de OS.

**Definicao**:
```vba
Type TAvaliacao
  Id As Long
  OSId As Long
  Nota As Single
  Comentario As String
  DataAvaliacao As Date
End Type
```

**Campos**:
- **Id** (Long): Chave primaria
- **OSId** (Long): Chave estrangeira para TOS.Id
- **Nota** (Single): 1.0 a 5.0 (validado)
- **Comentario** (String): Comentario opcional, max 500 chars
- **DataAvaliacao** (Date): Quando avaliacao foi registrada

**Regras**:
- Uma OS pode ter zero ou uma avaliacao (nao multiplas)
- Nota deve estar entre 1.0 e 5.0
- OS deve estar Status=CONCLUIDA para permitir avaliacao
- Media de avaliacoes da empresa afeta prioridade em rodizio

**Exemplo de Uso**:
```vba
Dim av As TAvaliacao
av.OSId = 1
av.Nota = 4.5
av.Comentario = "Servico bem executado, equipe atenciosa"
av.DataAvaliacao = Date

Dim res As TResult
res = Repo_Avaliacao.CriarAvaliacao(av)
```

---

## 10. TConfig

**Uso**: Parametros globais de configuracao da aplicacao.

**Definicao**:
```vba
Type TConfig
  Prefeitura As String
  Ambiente As String
  VersaoVBA As String
  DataUltimaAtualizacao As Date
  UsuarioAtualizacao As String
End Type
```

**Campos**:
- **Prefeitura** (String): Nome da prefeitura (ex: "Sao Paulo")
- **Ambiente** (String): "DEV" ou "PROD"
- **VersaoVBA** (String): Versao do sistema (ex: "V12.0.0107")
- **DataUltimaAtualizacao** (Date): Timestamp da ultima mudanca
- **UsuarioAtualizacao** (String): Quem fez ultima mudanca

**Armazenamento**: Planilha Configuracao (chave-valor)

**Parametros Adicionais** (na planilha):
- DIAS_RETENCAO_LOG: 365
- ALGORITMO_RODIZIO: "PONDERADO"
- CACHE_ENABLED: True
- DEBUG_MODE: False

**Exemplo de Uso**:
```vba
Dim config As TConfig
config = Util_Config.ObterConfig()

MsgBox "Prefeitura: " & config.Prefeitura
MsgBox "Versao: " & config.VersaoVBA
```

---

## 11. TRodizioResultado

**Uso**: Output do algoritmo de rodizio. Array destes tipos retorna lista ordenada.

**Definicao**:
```vba
Type TRodizioResultado
  EmpresaId As Long
  Sequencia As Long
  Prioridade As Single
End Type
```

**Campos**:
- **EmpresaId** (Long): ID da empresa
- **Sequencia** (Long): Ordem recomendada (1, 2, 3, ...)
- **Prioridade** (Single): Score calculado (0-100)

**Uso Tipico**:
```vba
' Retorno de Svc_Rodizio.AplicarRodizio()
Dim resultado() As TRodizioResultado
resultado = Svc_Rodizio.AplicarRodizio(atividadeId:=5)

' resultado[0].EmpresaId = 1, Sequencia = 1, Prioridade = 95
' resultado[1].EmpresaId = 3, Sequencia = 2, Prioridade = 87
' resultado[2].EmpresaId = 2, Sequencia = 3, Prioridade = 72

' Proxima empresa a receber OS:
Dim proximaEmpresa As Long
proximaEmpresa = resultado(0).EmpresaId
```

---

## 12. TAppContext

**Uso**: Contexto global de sessao (usuario, prefeitura, permissoes).

**Definicao**:
```vba
Type TAppContext
  UsuarioId As Long
  PrefeituraId As Long
  DataSessao As Date
  TokenSessao As String
  PermissoesLevel As Long
End Type
```

**Campos**:
- **UsuarioId** (Long): ID do usuario logado
- **PrefeituraId** (Long): ID da prefeitura (multi-tenant futuro)
- **DataSessao** (Date): Quando sessao iniciou
- **TokenSessao** (String): Token de validacao (futuro)
- **PermissoesLevel** (Long): 0=visitante, 1=usuario, 2=admin

**Inicializacao**: Em Auto_Open.bas via AppContext.InitializeContext()

**Uso Tipico**:
```vba
Dim ctx As TAppContext
ctx = AppContext.GetContext()

If ctx.PermissoesLevel >= 2 Then
  ' Usuario é admin, permitir limpeza de base
  Call Limpar_Base.Show
End If
```

---

## Regras de Conversao Entre Tipos

### Excel Range → Type
```vba
Dim linha As Range
Set linha = Sheets("Empresa").Range("A2:F2")

Dim emp As TEmpresa
emp = Util_Conversao.ConvertParaEmpresa(linha)
```

### Type → Excel Range
```vba
Dim emp As TEmpresa
emp.Id = 1
emp.Nome = "XYZ"

' Salvar em planilha
Dim id As Long
id = Util_Planilha.InserirLinha("Empresa", Array(emp.Id, emp.Nome, emp.CNPJ, ...))
```

### Type → JSON (para SaaS)
```vba
' Futuro: Svc_Sync.ConvertParaJSON(emp As TEmpresa) As String
' Retorna: {"id": 1, "nome": "XYZ", "cnpj": "..."}
```

---

## Restricoes Absolutas

1. **NUNCA** defina Type fora de Mod_Types.bas
2. **NUNCA** modifique Type existente sem BUMP version
3. **NUNCA** copie Type definition
4. **NUNCA** use Variant sem necessidade (use tipos especificos)
5. **NUNCA** anide Types (Type dentro de Type) - nao suportado VBA

---

## Diagrama de Relacionamentos

```
TEmpresa (1)
  ├─ (1..M) TEntidade
  ├─ (1..M) TCredenciamento → TAtividade
  ├─ (1..M) TPreOS
  └─ (1..M) TOS

TAtividade (1)
  ├─ (1..M) TCredenciamento → TEmpresa
  └─ (1..M) TPreOS

TPreOS (1)
  └─ (0..1) TOS

TOS (1)
  └─ (0..1) TAvaliacao

TAvaliacao
  └─ → TOS

TConfig (global)
  └─ parametros da app

TAppContext (global)
  └─ contexto de sessao

TRodizioResultado (output)
  └─ → TEmpresa
```

---

**Ultima Atualizacao**: 2026-04-10
**Versao Compativel**: V12.0.0107+
