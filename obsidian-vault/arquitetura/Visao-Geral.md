# Visao Geral da Arquitetura

## Arquitetura de Duas Camadas

```
┌─────────────────────────────────────────────────────┐
│                  SAAS (Next.js)                    │
│  Dashboard | API | Webhooks | Multi-tenant         │
│  NeonDB (Postgres) | Cloudflare R2 | Vercel        │
└────────────┬────────────────────────────────────────┘
             │ API Sync (JSON)
             │ Import / Export
             │ Webhooks
┌────────────▼────────────────────────────────────────┐
│             EXCEL VBA (.xlsm)                       │
│  27 Modulos | 13 Forms | 12 Tipos Publicos        │
│  7 Planilhas | Auditoria | Rodizio               │
└─────────────────────────────────────────────────────┘
```

## Camada 1: Excel VBA - Detalhado

### Divisao em 5 Camadas Verticais

```
┌─────────────────────────────────────────┐
│         APRESENTACAO (13 Forms)         │
│  Menu | Empresa | Entidade | OS | Rel  │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│      SERVICOS DE NEGOCIO (4 Svc_*.bas)  │
│  Rodizio | PreOS | OS | Avaliacao      │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│    LOGICA DE NEGOCIO (2 módulos)        │
│  Classificar | Preencher                │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│   ACESSO A DADOS (5 Repo_*.bas)         │
│  Credenciamento | PreOS | OS | Empresa │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│      INFRAESTRUTURA (7 módulos)         │
│  Tipos | Const | Config | Planilha      │
│  Conversao | AuditLog | ErrorBoundary   │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│   DADOS PERSISTENTES (7 Planilhas)      │
│  Empresa | Entidade | Atividade | OS    │
│  Credenciamento | Avaliacao | Config    │
└─────────────────────────────────────────┘
```

### Camada 1: Dados Persistentes (7 Planilhas)

| Planilha | Finalidade | Colunas Chave | Capacidade |
|----------|-----------|-------------|-----------|
| Empresa | Cadastro de empresas | Id, CNPJ, Nome | 1.000 empresas |
| Entidade | Estrutura juridica | Id, EmpresaId, Tipo | 5.000 entidades |
| Atividade | Tipos de servicos | Id, Nome, Classificacao | 500 atividades |
| Credenciamento | Alocacao empresa-serviço | Id, EmpresaId, AtividadeId | 10.000 registros |
| PreOS | Rascunho de OS | Id, EmpresaId, Status | 10.000 pre-OS |
| OS | Ordens finalizadas | Id, Numero, Status, DataConclusao | 50.000 OS |
| Avaliacao | Avaliacoes de servico | Id, OSId, Nota, Data | 50.000 avaliacoes |
| Configuracao | Parametros de app | Chave, Valor | ~30 parametros |
| AuditLog | Log de operacoes | Operacao, Modulo, Timestamp, Detalhes | 1M entradas/ano |

### Camada 2: Infraestrutura (7 Módulos)

#### Mod_Types.bas (FUNDAÇÃO)
Defina todos os 12 tipos publicos aqui e APENAS aqui. Mudancas afetam todo sistema.

```vba
' Tipos de Retorno
Type TResult
  Sucesso As Boolean
  Mensagem As String
  Codigo As Long
  Dados As Variant
End Type

' Tipos de Dominio
Type TEmpresa: Id, Nome, CNPJ, Endereco, Contato, Ativo End Type
Type TEntidade: Id, EmpresaId, Nome, Tipo, Ativo End Type
Type TAtividade: Id, Nome, Descricao, Ativo End Type
Type TServico: Id, Nome, Classificacao, Ativo End Type
Type TCredenciamento: Id, EmpresaId, Entidade, DataCredenciamento, Ativo End Type
Type TPreOS: Id, EmpresaId, AtividadeId, DataCriacao, Status End Type
Type TOS: Id, PreOSId, Numero, DataEmissao, DataConclusao, Status End Type
Type TAvaliacao: Id, OSId, Nota, Comentario, DataAvaliacao End Type

' Tipos de Infraestrutura
Type TConfig: Prefeitura, Ambiente, VersaoVBA, DataUltAtualizacao, UsuarioAtualizacao End Type
Type TRodizioResultado: EmpresaId, Sequencia, Prioridade End Type
Type TAppContext: UsuarioId, PrefeituraId, DataSessao, TokenSessao, PermissoesLevel End Type
```

#### Const_Colunas.bas
Mapeia nome de coluna para índice em cada planilha. Centraliza magic numbers.

```vba
' Planilha Empresa
Public Const COL_EMPRESA_ID = 1
Public Const COL_EMPRESA_NOME = 2
Public Const COL_EMPRESA_CNPJ = 3
Public Const COL_EMPRESA_ENDERECO = 4
Public Const COL_EMPRESA_CONTATO = 5
Public Const COL_EMPRESA_ATIVO = 6
' ... e assim para todas as 7 planilhas
```

#### Util_Conversao.bas
Validacoes e conversoes de tipo. Centraliza regex e regras de negocio.

**Funcoes Principais**:
- ValidarEmpresa(emp As TEmpresa) As TResult
- ValidarCNPJ(cnpj As String) As Boolean
- ConvertParaEmpresa(linha As Range) As TEmpresa
- ConvertParaOS(linha As Range) As TOS

#### Util_Config.bas
Acesso centralizado a planilha Configuracao. Padrão Singleton.

**Funcoes**:
- ObterConfig() As TConfig
- SalvarConfig(config As TConfig) As TResult
- ObterParametro(chave As String) As Variant
- SalvarParametro(chave As String, valor As Variant) As TResult

#### Util_Planilha.bas
Operacoes CRUD abstratas em cualquier planilha.

**Funcoes Genericas**:
- AbrirPlanilha(nomePlanilha As String) As Worksheet
- BuscarPorChave(planilha As String, chaveCol As Long, chaveVal As Variant) As Range
- InserirLinha(planilha As String, dados As Variant()) As Long (retorna ID novo)
- AtualizarLinha(planilha As String, id As Long, dados As Variant()) As TResult
- DeletarLinha(planilha As String, id As Long) As TResult
- ObterTodos(planilha As String) As Collection

#### Audit_Log.bas
Log centralizado de TODAS operacoes.

**Funcoes**:
- LogOperacao(operacao As String, modulo As String, detalhes As String) As Long
- LogErro(erro As String, modulo As String, stackTrace As String) As Long
- ExportarLog(dataInicio As Date, dataFim As Date) As String (CSV path)

#### ErrorBoundary.bas
Tratamento centralizado de erros. Captura e loga excepcoes.

**Funcoes**:
- CatchError(numero As Long, descricao As String, modulo As String) As TResult
- IsRecuperavel(numero As Long) As Boolean
- StackTrace() As String (ja registra em Audit_Log)

### Camada 3: Acesso a Dados (5 Módulos Repository)

#### Repo_Credenciamento.bas
CRUD para entidades principais: Empresa, Entidade, Atividade, Credenciamento.

```vba
Public Function CriarEmpresa(emp As TEmpresa) As TResult
' Valida emp.CNPJ unico, insere em planilha, loga operacao
End Function

Public Function AtualizarEmpresa(id As Long, emp As TEmpresa) As TResult
' Busca empresa, valida novo CNPJ nao existe, atualiza, loga
End Function

Public Function DeletarEmpresa(id As Long) As TResult
' Soft delete (Ativo = False), nao remove dados, loga
End Function

Public Function ObterEmpresa(id As Long) As TEmpresa
' Busca por ID, converte Range para tipo TEmpresa
End Function

' Similar para Entidade, Atividade, Credenciamento
```

#### Repo_PreOS.bas
CRUD para pre-ordens de servico (rascunhos).

```vba
Public Function CriarPreOS(preOS As TPreOS) As Long
' Insere em planilha PreOS, retorna ID novo
End Function

Public Function AtualizarStatusPreOS(id As Long, novoStatus As String) As TResult
Public Function DeletarPreOS(id As Long) As TResult
Public Function ObterPreOS(id As Long) As TPreOS
Public Function ListarPreOSPorEmpresa(empresaId As Long) As Collection
```

#### Repo_OS.bas
CRUD para ordens de servico finalizadas.

```vba
Public Function CriarOS(os As TOS) As Long
Public Function AtualizarStatusOS(id As Long, novoStatus As String) As TResult
Public Function ConcluirOS(id As Long, dataConclusao As Date) As TResult
Public Function ObterOS(id As Long) As TOS
Public Function ListarOSPorEmpresa(empresaId As Long) As Collection
Public Function ListarOSPorPeriodo(dataInicio As Date, dataFim As Date) As Collection
```

#### Repo_Avaliacao.bas
CRUD para avaliacoes.

```vba
Public Function CriarAvaliacao(av As TAvaliacao) As Long
Public Function ObterAvaliacaoOS(osId As Long) As TAvaliacao
Public Function ObtMediaAvaliacaoEmpresa(empresaId As Long) As Single
```

#### Repo_Empresa.bas
Operacoes especializadas em empresas (nao presentes em Repo_Credenciamento).

```vba
Public Function BuscarPorCNPJ(cnpj As String) As TEmpresa
Public Function BuscarPorNome(nome As String) As Collection
Public Function ListarAtivas() As Collection
Public Function ListarComCredenciamento(atividadeId As Long) As Collection
```

### Camada 4: Lógica de Negócio (2 Módulos)

#### Classificar.bas
Classifica servicos por tipo automaticamente (CNAE-inspired).

```vba
Public Function ClassificarServico(nomeServico As String) As String
' Usa tabela interna de regex: "reparos eletricos" -> "ELETRICA"
' Resultado: "ELETRICA", "ENCANAMENTO", "LIMPEZA", "REFORMA", "OUTRO"
End Function

Public Function ValidarClassificacao(classificacao As String) As Boolean
' Verifica se classificacao está em lista permitida
End Function
```

#### Preencher.bas
Preenche dados faltantes e valida integridade.

```vba
Public Function PreencherDadosDefault(emp As TEmpresa) As TEmpresa
' Se Nome vazio, tira de CNPJ, etc.
End Function

Public Function ValidarIntegridade(tipo As String, dados As Variant) As TResult
' Checa referencial: EmpresaId existe? AtividadeId existe?
End Function
```

### Camada 5: Serviços de Negócio (4 Módulos Service)

#### Svc_Rodizio.bas
Algoritmo de rodizio entre empresas. Core do negocio.

```vba
Public Function AplicarRodizio(atividadeId As Long) As TRodizioResultado()
' Lista empresas credenciadas para atividade
' Ordena por: (1) numero de OS recentes, (2) media de avaliacao, (3) aleatorio
' Retorna sequencia recomendada para proxima alocacao
' Loga em AuditLog
End Function

Public Function ProximaEmpresaParaOS(atividadeId As Long) As Long
' Aplica rodizio, retorna EmpresaId da vez
End Function
```

#### Svc_PreOS.bas
Criar pre-ordens com validacoes.

```vba
Public Function CriarPreOSParaEmpresa(empresaId As Long, atividadeId As Long) As TResult
' Valida empresa existe e está ativa
' Valida atividade existe
' Cria PreOS com Status="RASCUNHO"
' Loga em AuditLog
End Function

Public Function ValidarPreOSAntesDaOS(preOSId As Long) As TResult
' Checa integridade antes de converter para OS
End Function
```

#### Svc_OS.bas
Converter pre-OS em OS, gerar numero unico.

```vba
Public Function ConverterPreOSEmOS(preOSId As Long) As TResult
' Busca PreOS validado
' Gera numero: PREFEITURA-YYYYMMDD-SEQUENCIA
' Cria OS com Status="EMITIDA"
' Atualiza PreOS com referencia a OS
' Loga insercao de OS
End Function

Public Function GerarNumeroOS() As String
' Formato: "PREFEITURA-20260410-00001"
' Sempre incrementa contador na planilha Configuracao
End Function
```

#### Svc_Avaliacao.bas
Registrar avaliacoes apos conclusao de OS.

```vba
Public Function RegistrarAvaliacao(osId As Long, nota As Single, comentario As String) As TResult
' Valida OS existe e esta CONCLUIDA
' Valida nota entre 1 e 5
' Cria Avaliacao
' Loga avaliacao
End Function

Public Function AtualizarMediaEmpresa(empresaId As Long) As Single
' Recalcula media de avaliacoes da empresa
' Afeta proxima alocacao via Svc_Rodizio
End Function
```

### Camada 6: Apresentacao (13 UserForms)

#### Menu_Principal
Ponto de entrada. Oferece opcoes:
- Credenciar Empresa → Abre Credencia_Empresa
- Gerenciar Entidades → Abre Altera_Entidade
- Cadastrar Servico → Abre Cadastro_Servico
- Ordens de Servico → Abre Menu secundario (criar, buscar)
- Relatorios → Abre Menu (por empresa, por atividade)
- Testes → Abre Central_Testes (se ambiente DEV)
- Sair → Fecha com confirmacao

#### Credencia_Empresa
- Input: Nome, CNPJ, Endereco, Contato
- Validacao em tempo real: CNPJ existe? Nome vazio?
- Button OK: Chama Repo_Credenciamento.CriarEmpresa()
- Feedback: Mensagem de sucesso ou erro com detalhes

#### Altera_Empresa
- Busca: CNPJ ou Nome (autocomplete)
- Form preenchido com dados existentes
- Edicao e validacao
- Button Salvar: Chama Repo_Credenciamento.AtualizarEmpresa()

#### Reativa_Empresa
- Lista empresas desativadas (Ativo=False)
- Filtro por CNPJ ou Nome
- Button Reativar: Seta Ativo=True, chama Repo_Credenciamento

#### Altera_Entidade, Reativa_Entidade
- Similar a Empresa, mas para Entidade (estrutura juridica)

#### Cadastro_Servico
- Input: Nome, Descricao (opcional)
- Click Button Classificar: Abre progressBar, chama Classificar.bas
- Dropdown resultado com 5 opcoes
- Button Registrar: Insere Atividade + Credenciamento

#### Fundo_Branco
- Tela auxiliar branca para operacoes especiais
- Flexivel para novos fluxos

#### Limpar_Base
- Warning: "Deseja deletar todos dados de teste?"
- Confirmacao multipla (3x "tem certeza?")
- Deleta planilhas PreOS, OS, Avaliacao (preserva Empresa)

#### ProgressBar
- Barra visual de progresso
- Usada em Classificar, Import CNAE, etc.

#### Rel_Emp_Serv
- Grid: Empresa | Atividade | DataCredenciamento | Ativo
- Filtros: Empresa (search), Atividade (dropdown)
- Export: CSV

#### Rel_OSEmpresa
- Grid: Numero OS | DataEmissao | Status | Nota Avaliacao
- Filtros: EmpresaId (dropdown), Periodo (data range)
- Pode registrar Avaliacao direto da grid

## Modelos de Dados (Diagrama ER)

```
EMPRESA (1)
  ├── (M) ENTIDADE
  ├── (M) CREDENCIAMENTO → ATIVIDADE
  └── (M) OS

ATIVIDADE (1)
  ├── (M) CREDENCIAMENTO → EMPRESA
  └── (M) PREOS → OS

PREOS (1)
  └── (1) OS

OS (1)
  └── (0..1) AVALIACAO

AVALIACAO
  └── → OS

CONFIGURACAO (global)
  └── parametros da app

AUDITLOG (global)
  └── todos operacoes
```

## Fluxo Crítico: Criacao de OS

```
Usuario seleciona Empresa X e Atividade Y

↓

Svc_PreOS.CriarPreOSParaEmpresa(X, Y)
  ├─ Valida empresa X ativa
  ├─ Valida atividade Y existe
  ├─ Cria PreOS em planilha
  └─ Loga em AuditLog

↓

Usuario clica "Gerar OS"

↓

Svc_OS.ConverterPreOSEmOS(preOSId)
  ├─ Busca PreOS validado
  ├─ Chama Svc_OS.GerarNumeroOS()
  │   ├─ Lê contador de Configuracao
  │   ├─ Incrementa
  │   └─ Retorna "PREFEITURA-20260410-00001"
  ├─ Cria OS com Status="EMITIDA"
  ├─ Salva em planilha OS
  └─ Loga em AuditLog

↓

Usuario conclui servico

↓

Usuario abre Rel_OSEmpresa

↓

Clica "Registrar Avaliacao" em linha OS

↓

Svc_Avaliacao.RegistrarAvaliacao(osId, nota, comentario)
  ├─ Cria Avaliacao
  ├─ Loga
  └─ Chama Svc_Avaliacao.AtualizarMediaEmpresa(empresaId)

↓

Proxima vez que Svc_Rodizio.AplicarRodizio() chamado

↓

Ordenacao considera media nova
```

## SaaS Layer (Next.js) - Visão Geral

Veja [[arquitetura/SaaS-Roadmap]] para detalhes.

Basicamente:
- Dashboard Next.js espelha dados VBA
- API REST sincroniza: Excel → SaaS (import), SaaS → Excel (export)
- Multi-tenant: cada Prefeitura = tenant_id no Postgres
- Escalavel para 1M+ registros

---

**Documentos Relacionados**:
- [[arquitetura/Modulos-VBA]] - Detalhe de cada modulo
- [[arquitetura/Tipos-Publicos]] - Definicao de tipos
- [[arquitetura/Fluxos-de-Negocio]] - Todos fluxos principais
- [[regras/Compilacao-VBA]] - Regras de mudanca segura
