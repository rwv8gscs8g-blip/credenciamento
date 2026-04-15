# 27 Modulos VBA - Catalogo Completo

## Fundacao (5 modulos)

### 1. Mod_Types.bas
**Proposito**: Definicao de todos 12 tipos publicos estruturados.

**Tipos Definidos**:
- TResult (bool Sucesso, string Mensagem, long Codigo, variant Dados)
- TAtividade (id, nome, descricao, ativo)
- TServico (id, nome, classificacao, ativo)
- TEmpresa (id, nome, cnpj, endereco, contato, ativo)
- TCredenciamento (id, empresaId, entidade, dataCred, ativo)
- TEntidade (id, empresaId, nome, tipo, ativo)
- TPreOS (id, empresaId, atividadeId, dataCriacao, status)
- TOS (id, preOSId, numero, dataEmissao, dataConclusao, status)
- TAvaliacao (id, osId, nota, comentario, dataAvaliacao)
- TConfig (prefeitura, ambiente, versaoVBA, dataUltAtualizacao, usuarioAtualizacao)
- TRodizioResultado (empresaId, sequencia, prioridade)
- TAppContext (usuarioId, prefeituraId, dataSessao, tokenSessao, permissoesLevel)

**Restricoes**:
- NUNCA adicione tipos novos sem coordenacao
- Mudancas aqui requerem recompilacao de todo sistema
- Sempre mantenha backward compatibility com versoes antigas

**Dependencias**: Nenhuma

---

### 2. Const_Colunas.bas
**Proposito**: Mapeamento central de columnas em cada planilha para evitar magic numbers.

**Estrutura**:
```vba
' Planilha Empresa (A, B, C, ...)
Public Const COL_EMPRESA_ID = 1
Public Const COL_EMPRESA_NOME = 2
Public Const COL_EMPRESA_CNPJ = 3
Public Const COL_EMPRESA_ENDERECO = 4
Public Const COL_EMPRESA_CONTATO = 5
Public Const COL_EMPRESA_ATIVO = 6

' Planilha Entidade
Public Const COL_ENTIDADE_ID = 1
Public Const COL_ENTIDADE_EMPRESA_ID = 2
Public Const COL_ENTIDADE_NOME = 3
Public Const COL_ENTIDADE_TIPO = 4
Public Const COL_ENTIDADE_ATIVO = 5

' ... similar para Atividade, Credenciamento, PreOS, OS, Avaliacao, Configuracao
```

**Funcoes Principais**: Nenhuma (apenas constantes)

**Dependencias**: Nenhuma

---

### 3. Util_Conversao.bas
**Proposito**: Conversao de tipos e validacoes centralizadas.

**Funcoes Principais**:
```vba
Public Function ValidarEmpresa(emp As TEmpresa) As TResult
' Valida: CNPJ unico, nome nao vazio, endereco valido
' Retorna: TResult com Sucesso=True/False e Mensagem detalhada

Public Function ValidarCNPJ(cnpj As String) As Boolean
' Valida formato XX.XXX.XXX/XXXX-XX e digitos verificadores

Public Function ConvertParaEmpresa(linha As Range) As TEmpresa
' Converte range com 6 colunas para tipo TEmpresa

Public Function ConvertParaOS(linha As Range) As TOS
' Converte range para tipo TOS

Public Function IsNull(valor As Variant) As Boolean
' Checa se valor é vazio ou nao foi atribuido

Public Function DefaultValue(tipo As String) As Variant
' Retorna valor default para tipo ("", 0, False, etc)
```

**Dependencias**: Mod_Types, Const_Colunas

---

### 4. Util_Config.bas
**Proposito**: Acesso centralizado a planilha Configuracao. Padrão Singleton.

**Funcoes Principais**:
```vba
Private gConfig As TConfig ' Cache para performance

Public Function ObterConfig() As TConfig
' Lê planilha Configuracao se nao estiver em cache
' Retorna TConfig populado

Public Function SalvarConfig(config As TConfig) As TResult
' Escreve TConfig em planilha Configuracao
' Invalida cache
' Loga em AuditLog

Public Function ObterParametro(chave As String) As Variant
' Busca parametro especifico na planilha
' Ex: ObterParametro("PREFEITURA") = "Sao Paulo"

Public Function SalvarParametro(chave As String, valor As Variant) As TResult
' Atualiza parametro, loga alteracao
```

**Dependencias**: Mod_Types, Const_Colunas, Util_Planilha (abaixo), AuditLog

---

### 5. Util_Planilha.bas
**Proposito**: Operacoes CRUD abstratas em cualquier planilha. Base de dados VBA.

**Funcoes Principais**:
```vba
Public Function AbrirPlanilha(nomePlanilha As String) As Worksheet
' Retorna objeto Worksheet para planilha nome ou erro

Public Function BuscarPorChave(planilha As String, chaveCol As Long, chaveVal As Variant) As Range
' Busca primeira linha onde coluna chaveCol = chaveVal
' Retorna Range ou Nothing

Public Function BuscarTodas(planilha As String, chaveCol As Long, chaveVal As Variant) As Collection
' Retorna Collection com todas linhas que correspondem criterio

Public Function InserirLinha(planilha As String, dados As Variant()) As Long
' Insere nova linha, auto-incrementa ID (Col1)
' Retorna ID novo

Public Function AtualizarLinha(planilha As String, id As Long, dados As Variant()) As TResult
' Busca linha por ID, atualiza colunas
' Loga em AuditLog

Public Function DeletarLinha(planilha As String, id As Long) As TResult
' Delete logic: se tem coluna "Ativo", seta False (soft delete)
' Senao deleta linha (hard delete)
' Loga operacao

Public Function ObterTodos(planilha As String) As Collection
' Retorna Collection com todas linhas nao deletadas

Public Function ObterUltimoId(planilha As String) As Long
' Retorna ID maximo + 1 para proxima insercao

Public Function ContarRegistros(planilha As String) As Long
' Retorna numero de linhas nao deletadas
```

**Nota Especial**: Esta é a base de dados do sistema. Todas operacoes passam por aqui ou via funcoes wrapper em Repo_*.bas.

**Dependencias**: Const_Colunas

---

## Auditoria e Contexto (3 modulos)

### 6. Audit_Log.bas
**Proposito**: Log centralizado de TODAS operacoes do sistema para auditoria, debug e rastreamento.

**Funcoes Principais**:
```vba
Public Function LogOperacao(operacao As String, modulo As String, detalhes As String) As Long
' operacao: "INSERT", "UPDATE", "DELETE", "TESTE_INICIADO", "TESTE_OK", "TESTE_FALHOU"
' modulo: nome do modulo que originou log
' detalhes: string JSON com dados relevantes
' Insere linha em planilha AuditLog com timestamp
' Retorna ID do log

Public Function LogErro(erro As String, modulo As String, stackTrace As String) As Long
' Registra erro com stack trace
' Similar a LogOperacao mas com tag de ERRO

Public Function LogAvaliacao(osId As Long, empresaId As Long, nota As Single) As Long
' Log especializado para avaliacoes

Public Function ExportarLog(dataInicio As Date, dataFim As Date) As String
' Gera CSV com logs entre datas
' Retorna path do arquivo gerado

Public Function LimparLogAntigo(diasRetencao As Long) As TResult
' Deleta logs com mais de diasRetencao dias
' Loga a limpeza
```

**Colunas de AuditLog**: Id, Timestamp, Operacao, Modulo, Detalhes (JSON), Usuario (AppContext.UsuarioId)

**Dependencias**: Util_Planilha, Const_Colunas

---

### 7. AppContext.bas
**Proposito**: Contexto global de sessao (usuario, prefeitura, permissoes).

**Funcoes Principais**:
```vba
Private gAppContext As TAppContext

Public Function GetContext() As TAppContext
' Retorna contexto atual

Public Sub InitializeContext(usuarioId As Long, prefeituraId As Long)
' Inicializa contexto de sessao
' Chamado em Auto_Open.bas

Public Function ValidarPermissao(level As Long) As Boolean
' Checa se usuario tem permissao para operacao (level)

Public Function GetUsuarioId() As Long
' Retorna UsuarioId do contexto

Public Function GetPrefeituraId() As Long
' Retorna PrefeituraId (para multi-tenant futuro)
```

**Estrutura TAppContext**:
- UsuarioId: Long (quem esta logado)
- PrefeituraId: Long (qual prefeitura)
- DataSessao: Date (quando iniciou)
- TokenSessao: String (para futuro: validacao)
- PermissoesLevel: Long (0=visitante, 1=usuario, 2=admin)

**Dependencias**: Mod_Types

---

### 8. ErrorBoundary.bas
**Proposito**: Tratamento centralizado de erros. Captura, loga e oferece recovery.

**Funcoes Principais**:
```vba
Public Function CatchError(numero As Long, descricao As String, modulo As String) As TResult
' Recebe erro de On Error handler
' Chama LogErro em Audit_Log
' Chama StackTrace() para capturar contexto
' Retorna TResult com Sucesso=False

Public Function IsRecuperavel(numero As Long) As Boolean
' Checa se erro é recuperavel (ex: Err.Number = 11 é "Division by zero", nao recuperavel)

Public Function StackTrace() As String
' Reconstroi stack trace do erro
' Loga em AuditLog automaticamente

Public Sub RaiseCustomError(codigo As Long, mensagem As String)
' Levanta erro customizado com prefixo "CREDENCIAMENTO_" + codigo
' Usado em toda codebase para erros previstos
```

**Exemplo de Uso**:
```vba
On Error GoTo ErrorHandler
' ... codigo
Exit Sub
ErrorHandler:
    Dim res As TResult
    res = ErrorBoundary.CatchError(Err.Number, Err.Description, "Repo_Empresa")
    MsgBox res.Mensagem
End Sub
```

**Dependencias**: Audit_Log, AppContext

---

## Repositórios (5 modulos)

### 9. Repo_Credenciamento.bas
**Proposito**: CRUD para entidades principais: Empresa, Entidade, Atividade, Credenciamento.

**Funcoes Principais**:
```vba
' --- EMPRESA ---
Public Function CriarEmpresa(emp As TEmpresa) As TResult
' Valida: CNPJ unico, nome nao vazio
' Insere em planilha Empresa via Util_Planilha.InserirLinha()
' Loga em AuditLog
' Retorna TResult com ID novo em Dados

Public Function AtualizarEmpresa(id As Long, emp As TEmpresa) As TResult
' Busca empresa por id
' Valida CNPJ nao duplicado (exceto self)
' Atualiza via Util_Planilha.AtualizarLinha()
' Loga alteracao

Public Function DeletarEmpresa(id As Long) As TResult
' Soft delete: seta Ativo=False
' Loga delecao
' Nota: nao deleta relacionamentos (Entidade, Credenciamento), apenas marca inativa

Public Function ObterEmpresa(id As Long) As TEmpresa
' Busca por ID, converte Range para TEmpresa

Public Function ListarEmpresas() As Collection
' Retorna Collection com todas empresas ativas

Public Function BuscarEmpresaPorCNPJ(cnpj As String) As TEmpresa
' Busca exato por CNPJ

Public Function BuscarEmpresasPorNome(nome As String) As Collection
' Busca parcial (LIKE)

' --- ENTIDADE ---
Public Function CriarEntidade(ent As TEntidade) As TResult
Public Function AtualizarEntidade(id As Long, ent As TEntidade) As TResult
Public Function DeletarEntidade(id As Long) As TResult
Public Function ObterEntidade(id As Long) As TEntidade
Public Function ListarEntidadesPorEmpresa(empresaId As Long) As Collection

' --- ATIVIDADE ---
Public Function CriarAtividade(ativ As TAtividade) As TResult
Public Function AtualizarAtividade(id As Long, ativ As TAtividade) As TResult
Public Function DeletarAtividade(id As Long) As TResult
Public Function ObterAtividade(id As Long) As TAtividade
Public Function ListarAtividades() As Collection

' --- CREDENCIAMENTO ---
Public Function CriarCredenciamento(cred As TCredenciamento) As TResult
' Cria relacionamento entre Empresa e Atividade
Public Function ObterCredenciamento(id As Long) As TCredenciamento
Public Function ListarCredenciamentosPorEmpresa(empresaId As Long) As Collection
Public Function ListarCredenciamentosPorAtividade(atividadeId As Long) As Collection
Public Function DeletarCredenciamento(id As Long) As TResult
```

**Dependencias**: Util_Planilha, Util_Conversao, Audit_Log, ErrorBoundary, Mod_Types, Const_Colunas

---

### 10. Repo_PreOS.bas
**Proposito**: CRUD para pre-ordens de servico (rascunhos antes de serem OS).

**Funcoes Principais**:
```vba
Public Function CriarPreOS(preOS As TPreOS) As TResult
' Insere em planilha PreOS com Status="RASCUNHO"
' Retorna ID novo

Public Function AtualizarStatusPreOS(id As Long, novoStatus As String) As TResult
' Valida Status em lista permitida: "RASCUNHO", "VALIDADA", "CONVERTIDA"
' Atualiza

Public Function DeletarPreOS(id As Long) As TResult
' Soft delete (Ativo=False) ou hard delete se Status="RASCUNHO"

Public Function ObterPreOS(id As Long) As TPreOS

Public Function ListarPreOSPorEmpresa(empresaId As Long) As Collection
' Retorna todas PreOS da empresa (ativas)

Public Function ListarPreOSPorAtividade(atividadeId As Long) As Collection

Public Function ListarPreOSPorStatus(status As String) As Collection
' Ex: ListarPreOSPorStatus("RASCUNHO") para processar lote

Public Function ContarPreOSPendentes() As Long
```

**Dependencias**: Util_Planilha, Audit_Log, Mod_Types, Const_Colunas

---

### 11. Repo_OS.bas
**Proposito**: CRUD para ordens de servico finalizadas.

**Funcoes Principais**:
```vba
Public Function CriarOS(os As TOS) As TResult
' Insere em planilha OS com Status="EMITIDA"
' Retorna ID novo

Public Function AtualizarStatusOS(id As Long, novoStatus As String) As TResult
' Valida Status: "EMITIDA", "EM_PROGRESSO", "CONCLUIDA", "CANCELADA"
' Atualiza

Public Function ConcluirOS(id As Long, dataConclusao As Date) As TResult
' Atualiza Status="CONCLUIDA" e seta DataConclusao

Public Function ObterOS(id As Long) As TOS

Public Function BuscarOSPorNumero(numero As String) As TOS
' Busca exato por numero de OS

Public Function ListarOSPorEmpresa(empresaId As Long) As Collection

Public Function ListarOSPorPeriodo(dataInicio As Date, dataFim As Date) As Collection

Public Function ListarOSPorStatus(status As String) As Collection

Public Function ContarOSConcluidas() As Long

Public Function ContarOSEmProgresso() As Long
```

**Dependencias**: Util_Planilha, Audit_Log, Mod_Types, Const_Colunas

---

### 12. Repo_Avaliacao.bas
**Proposito**: CRUD para avaliacoes de servicos.

**Funcoes Principais**:
```vba
Public Function CriarAvaliacao(av As TAvaliacao) As TResult
' Valida: OSId existe, Nota entre 1 e 5
' Insere em planilha Avaliacao

Public Function ObterAvaliacaoOS(osId As Long) As TAvaliacao
' Retorna primeira avaliacao para OS

Public Function ObtMediaAvaliacaoEmpresa(empresaId As Long) As Single
' Calcula media de todas avaliacoes da empresa
' Usado por Svc_Rodizio para ordenacao

Public Function AtualizarAvaliacao(id As Long, nota As Single, comentario As String) As TResult
```

**Dependencias**: Util_Planilha, Audit_Log, Mod_Types, Const_Colunas

---

### 13. Repo_Empresa.bas
**Proposito**: Operacoes especializadas em empresas (complementa Repo_Credenciamento).

**Funcoes Principais**:
```vba
Public Function BuscarPorCNPJ(cnpj As String) As TEmpresa
' Alias para Repo_Credenciamento.BuscarEmpresaPorCNPJ()

Public Function BuscarPorNome(nome As String) As Collection
' Alias com busca case-insensitive

Public Function ListarAtivas() As Collection
' Apenas Ativo=True

Public Function ListarComCredenciamento(atividadeId As Long) As Collection
' Retorna empresas que tem credenciamento para atividade especifica

Public Function ContarEmpresas() As Long

Public Function ContarEmpresasAtivas() As Long
```

**Dependencias**: Repo_Credenciamento, Mod_Types

---

## Serviços de Negócio (4 modulos)

### 14. Svc_Rodizio.bas
**Proposito**: Algoritmo de rodizio entre empresas. Core do negocio.

**Fluxo**:
1. Lista empresas credenciadas para atividade X
2. Ordena por: (a) quantidade de OS recentes, (b) media de avaliacao, (c) aleatorio
3. Retorna sequencia recomendada

**Funcoes Principais**:
```vba
Public Function AplicarRodizio(atividadeId As Long) As TRodizioResultado()
' Entrada: atividadeId (tipo de servico)
' Saida: Array de TRodizioResultado[] ordenado por Sequencia
' TRodizioResultado.EmpresaId = ID da empresa
' TRodizioResultado.Sequencia = 1, 2, 3, ...
' TRodizioResultado.Prioridade = score (0-100)
' Loga aplicacao de rodizio em AuditLog

Public Function ProximaEmpresaParaOS(atividadeId As Long) As Long
' Wrapper: chama AplicarRodizio(), retorna [0].EmpresaId

Public Function MarcarOSAlocada(empresaId As Long, atividadeId As Long) As TResult
' Registra alocacao na tabela interna (Credenciamento)
' Afeta proxima chamada de AplicarRodizio()

Private Function ConsolidacaoOSRecentes(empresaId As Long, atividadeId As Long, diasRetro As Long) As Long
' Conta quantas OS empresa recebeu nos ultimos diasRetro dias
' Usado para balanceamento

Private Function CalculoMediaAvaliacao(empresaId As Long) As Single
' Chama Repo_Avaliacao.ObtMediaAvaliacaoEmpresa()
' Retorna 0 se nenhuma avaliacao
```

**Algoritmo Detalhe**:
```
1. Para cada empresa credenciada em atividadeId:
   score = 0

2. Contar OS alocadas nos ultimos 30 dias:
   Menos OS = mais pontos
   score += (100 - (countOS * 20))

3. Calcular media avaliacao:
   Media >= 4.5 = +15 pontos
   Media >= 4.0 = +10 pontos
   Media >= 3.5 = +5 pontos
   Media < 3.5 = -10 pontos

4. Aleatorio:
   score += random(0, 10)

5. Ordenar por score DESC
```

**Dependencias**: Repo_Credenciamento, Repo_OS, Repo_Avaliacao, Audit_Log, Mod_Types

---

### 15. Svc_PreOS.bas
**Proposito**: Criar pre-ordens com validacoes.

**Funcoes Principais**:
```vba
Public Function CriarPreOSParaEmpresa(empresaId As Long, atividadeId As Long) As TResult
' Valida:
'   - Empresa existe e Ativo=True
'   - Atividade existe e Ativo=True
'   - Credenciamento existe (empresa tem direito)
' Cria PreOS com Status="RASCUNHO"
' Loga criacao
' Retorna TResult com ID em Dados

Public Function ValidarPreOSAntesDaOS(preOSId As Long) As TResult
' Antes de converter PreOS em OS, valida:
'   - PreOS existe
'   - Status="RASCUNHO"
'   - EmpresaId valida
'   - AtividadeId valida
' Retorna TResult com resultado

Public Function ListarPreOSPendentes() As Collection
' Retorna todas PreOS com Status="RASCUNHO" para revisao
```

**Dependencias**: Repo_Credenciamento, Repo_PreOS, ErrorBoundary, Audit_Log, Mod_Types

---

### 16. Svc_OS.bas
**Proposito**: Converter pre-OS em OS, gerar numero unico.

**Funcoes Principais**:
```vba
Public Function ConverterPreOSEmOS(preOSId As Long) As TResult
' Entrada: ID de uma PreOS
' Processo:
'   1. Valida PreOS (call Svc_PreOS.ValidarPreOSAntesDaOS)
'   2. Gera numero unico (call GerarNumeroOS)
'   3. Cria TOS novo com numero
'   4. Insere em planilha OS (call Repo_OS.CriarOS)
'   5. Atualiza PreOS Status="CONVERTIDA"
'   6. Loga em AuditLog
' Retorna TResult com ID de OS em Dados

Private Function GerarNumeroOS() As String
' Formato: "PREFEITURA-YYYYMMDD-SEQUENCIA"
' Exemplo: "SAO_PAULO-20260410-00001"
' PREFEITURA vem de Util_Config.ObterParametro("PREFEITURA")
' YYYYMMDD = data corrente
' SEQUENCIA = incrementa contador em planilha Configuracao
' Garante unicidade per dia per prefeitura

Public Function ProximoNumeroDia() As Long
' Retorna numero de sequencia para proximo OS do dia
' Incrementa contador em Configuracao

Public Function BuscarOSPorNumero(numero As String) As TOS
' Wrapper para Repo_OS.BuscarOSPorNumero()
```

**Dependencias**: Svc_PreOS, Repo_OS, Repo_PreOS, Util_Config, Audit_Log, Mod_Types

---

### 17. Svc_Avaliacao.bas
**Proposito**: Registrar avaliacoes apos conclusao de OS.

**Funcoes Principais**:
```vba
Public Function RegistrarAvaliacao(osId As Long, nota As Single, comentario As String) As TResult
' Valida:
'   - OS existe
'   - OS Status="CONCLUIDA"
'   - Nota entre 1 e 5
' Cria TAvaliacao
' Insere via Repo_Avaliacao.CriarAvaliacao()
' Chama AtualizarMediaEmpresa()
' Loga avaliacao especializada (LogAvaliacao)

Public Function AtualizarMediaEmpresa(empresaId As Long) As Single
' Recalcula media de TODAS avaliacoes da empresa
' Afeta proxima alocacao via Svc_Rodizio (score melhor se media alta)
' Retorna media calculada

Public Function ObterMediaEmpresa(empresaId As Long) As Single
' Alias para Repo_Avaliacao.ObtMediaAvaliacaoEmpresa()
```

**Dependencias**: Repo_Avaliacao, Repo_OS, Audit_Log, Mod_Types

---

## Lógica de Negócio (2 modulos)

### 18. Classificar.bas
**Proposito**: Classificar servicos por tipo automaticamente (CNAE-inspired).

**Funcoes Principais**:
```vba
Public Function ClassificarServico(nomeServico As String) As String
' Entrada: string descritivo do servico (ex: "reparos de eletrica")
' Saida: classificacao em lista pre-definida
' Usa regex patterns internos para matching
' Retorna uma das: "ELETRICA", "ENCANAMENTO", "LIMPEZA", "REFORMA", "OUTRO"

Private Function Classificacoes() As String()
' Array interno: {"ELETRICA", "ENCANAMENTO", "LIMPEZA", "REFORMA", "OUTRO"}

Private Function PatternEletrica(nome As String) As Boolean
' Regex: "eletri|fio|chave|tomada|luz"
' Case insensitive

Private Function PatternEncanamento(nome As String) As Boolean
' Regex: "cana|agua|torneira|vaza|hidra"

Private Function PatternLimpeza(nome As String) As Boolean
' Regex: "limpa|varredura|piso|parede"

Private Function PatternReforma(nome As String) As Boolean
' Regex: "reforma|construc|alvenaria|reboco"

Public Function ValidarClassificacao(classificacao As String) As Boolean
' Verifica se string está em lista permitida
' Retorna True/False

Public Function ListarClassificacoes() As String()
' Retorna array de classificacoes validas
```

**Dependencias**: Nenhuma

---

### 19. Preencher.bas
**Proposito**: Preencher dados faltantes e validar integridade.

**Funcoes Principais**:
```vba
Public Function PreencherDadosDefaultEmpresa(emp As TEmpresa) As TEmpresa
' Se Nome vazio, tira de CNPJ ou fornecedor externo
' Se Endereco vazio, seta "Endereco nao informado"
' Se Contato vazio, seta "Sem contato"
' Sempre seta Ativo=True se nao especificado

Public Function ValidarIntegridade(tipoEntidade As String, dados As Variant) As TResult
' Valida referencial integrity:
'   - Se TEmpresa: CNPJ formato correto, nome nao vazio
'   - Se TOS: PreOSId existe em planilha PreOS, Numero unico
'   - Se TAvaliacao: OSId existe, OSId Status="CONCLUIDA", Nota 1-5
' Retorna TResult

Public Function ValidarReferencialIntegrity(tipo As String, id As Long) As TResult
' Exemplo: ValidarReferencialIntegrity("OS", 123)
' Checa se todos campos referidos existem
' Retorna TResult

Public Function ProximoIdDisponivel(planilha As String) As Long
' Calcula proximo ID sequencial
' Considera soft deletes
```

**Dependencias**: Util_Planilha, Mod_Types, ErrorBoundary

---

## Carregamento e Inicializacao (2 modulos)

### 20. Auto_Open.bas
**Proposito**: Executado automaticamente ao abrir Excel com Credenciamento_V12.xlsm. Carrega config, valida dados, prepara contexto.

**Executado em**:
```vba
' Em VBA: Menu Tools > Options > Miscellaneous > Startup
' Quando Workbook_Open() disparado
```

**Funcoes Principais**:
```vba
Public Sub Auto_Open()
' Ponto de entrada, executado automaticamente
' Fluxo:
'   1. DisableEvents() para nao disparar multiplos events
'   2. MostrarSplashScreen() (opcional)
'   3. ValidarVersaoExcel()
'   4. CarregarConfiguracao()
'   5. InitializeContext() com usuario padrao
'   6. ValidarIntegridadeDados()
'   7. PrepararFormularios()
'   8. LogaInicio() em AuditLog
'   9. ExibirMenu_Principal

Private Sub ValidarVersaoExcel()
' Checa se Excel >= 2019
' Se Excel < 2019, aviso e pode desabilitar funcoes avancadas

Private Sub CarregarConfiguracao()
' Chama Util_Config.ObterConfig()
' Se falhar, oferece Configuracao_Inicial form

Private Sub ValidarIntegridadeDados()
' Checa:
'   - Planilha Empresa nao vazia (se nao, oferece Limpar_Base)
'   - Nenhuma OS duplicada por numero
'   - Nenhuma Empresa com CNPJ duplicado
' Log erros em AuditLog, nao bloqueia inicializacao

Private Sub PrepararFormularios()
' Pre-carrega formularios em memoria (cache)
' Melhora performance na abertura

Public Sub AoFecharAplicacao()
' Executado em Workbook_BeforeClose
' LogaFim() em AuditLog
' Salva arquivo
```

**Dependencias**: Util_Config, AppContext, Audit_Log, Repo_Credenciamento, Menu_Principal (form)

---

### 21. Variaveis.bas
**Proposito**: Variaveis globais, bandeiras, opcoes de debug.

**Conteudo**:
```vba
' Bandeiras de Debug
Public gDebugMode As Boolean ' True = mostrar Debug.Print
Public gDebugTraceAll As Boolean ' True = logar todo acesso de planilha

' Bandeiras de Performance
Public gCacheConfig As TConfig
Public gCacheEmpresas As Collection ' Cache de leitura

' Opcoes de Rodizio
Public Const RODIZIO_ALGORITMO = "PONDERADO" ' ou "RR" para round-robin

' Validacoes
Public Const CNPJ_OBRIGATORIO = True
Public Const EMAIL_OBRIGATORIO = False
Public Const ENDERECO_OBRIGATORIO = True

' Retention
Public Const AUDIT_LOG_RETENTION_DAYS = 365
Public Const SOFT_DELETE_LIFETIME_DAYS = 30

' Misc
Public gVersaoVBA As String ' "V12.0.0107"
```

**Dependencias**: Nenhuma

---

## Testes (4 modulos)

### 22. Central_Testes.bas
**Proposito**: Framework de testes (assertions, setup/teardown).

**Funcoes Principais**:
```vba
Public Type TTestResult
  Nome As String
  Status As String ' "OK", "FALHOU", "PULADO"
  Mensagem As String
  DuracaoMs As Long
End Type

Public Function AssertTrue(condicao As Boolean, mensagem As String) As TTestResult
Public Function AssertFalse(condicao As Boolean, mensagem As String) As TTestResult
Public Function AssertEqual(valor1 As Variant, valor2 As Variant, mensagem As String) As TTestResult
Public Function AssertNotNull(valor As Variant, mensagem As String) As TTestResult

Public Sub Setup()
' Executado antes de cada teste
' Cria ambiente limpo (copia Credenciamento_V12.xlsm para temp)

Public Sub Teardown()
' Executado apos cada teste
' Limpa dados de teste, restaura estado original

Public Function ExecutarTeste(nomeTeste As String, proc As String) As TTestResult
' Executa procedimento de teste (ex: Teste_Bateria_Oficial.Teste_CriarEmpresa)
' Chama Setup, executa, chama Teardown
' Retorna TTestResult

Public Function ExecutarTodosTestes() As Collection
' Itera sobre todos Teste_* procedures
' Retorna Collection de TTestResult
```

**Dependencias**: Mod_Types

---

### 23. Teste_Bateria_Oficial.bas
**Proposito**: Suite completa de testes de unidade e integracao.

**Testes Inclusos** (exemplos):
```vba
Public Sub Teste_CriarEmpresa()
' Arrange: prep dados
' Act: chama Repo_Credenciamento.CriarEmpresa()
' Assert: verifica retorno Sucesso=True, ID > 0, empresa salvou em planilha

Public Sub Teste_ValidarCNPJ()
' Testa Util_Conversao.ValidarCNPJ()
' Casos: CNPJ valido, invalido, formato errado

Public Sub Teste_RodizioBalanceado()
' Cria 3 empresas, aloca 10 OS a cada uma via Svc_Rodizio
' Verifica balanceamento (cada empresa deve receber ~3-4 OS)

Public Sub Teste_GerarNumeroOS()
' Gera 5 numeros consecutivos
' Verifica formato e unicidade

Public Sub Teste_RegistrarAvaliacao()
' Cria OS, marca como CONCLUIDA, registra avaliacao
' Verifica media empresa atualiza corretamente

Public Sub Teste_AuditLogCompleto()
' Executa operacoes, verifica que cada uma logou em AuditLog
' Verifica timestamps e detalhes

' ... mais ~30 testes
```

**Dependencias**: Central_Testes, Repo_Credenciamento, Svc_*, Audit_Log

---

### 24. Central_Testes_Relatorio.bas
**Proposito**: Relatorio de cobertura e resultados de testes.

**Funcoes Principais**:
```vba
Public Function GerarRelatorioTestes() As String
' Executa todos testes via Teste_Bateria_Oficial
' Coleta resultados
' Gera relatorio HTML com:
'   - Total testes
'   - OK / Falhou / Pulado
'   - Cobertura por modulo
'   - Tempo total
' Salva em Relatorios/ e abre em browser

Public Function ExportarRelatorioCSV() As String
' Exporta resultados como CSV
' Retorna path do arquivo

Public Function CalcularCobertura() As Single
' Estima cobertura de codigo (0-100%)
' Baseado em quantos modulos tiveram teste executado

Public Sub MostrarRelatorioUI()
' Abre form com resultados tabulados
```

**Dependencias**: Teste_Bateria_Oficial, Central_Testes, Audit_Log

---

### 25. Teste_UI_Guiado.bas
**Proposito**: Testes interativos de UI com usuario guiando.

**Funcoes Principais**:
```vba
Public Sub TesteInterativoCredenciarEmpresa()
' Abre Menu_Principal
' Mostra passos: "1. Clique em Credenciar Empresa..."
' Usuario segue passos
' Framework verifica cada acao
' Log resultado

Public Sub TesteInterativoRelatorio()
' Similar para relatorios

Public Sub MostrarGuiaUsuario()
' Exibe guia com screenshots e instrucoes
```

**Dependencias**: Menu_Principal (form), Audit_Log

---

## Utilitários Especializados (2 modulos)

### 26. Treinamento_Painel.bas
**Proposito**: Painel educacional para novos usuarios.

**Funcoes Principais**:
```vba
Public Sub AbrirPainelTreinamento()
' Abre form Treinamento_Painel
' Exibe sequencia de videos/screenshots

Public Function ObterConteudoTreinamento(topico As String) As String
' Topicos: "INICIO", "CREDENCIAR", "ALOKACAO", "OS", "RELATORIOS", "RODIZIO"

Public Sub MostrarVideoTutorial(topico As String)
' Se arquivo video existe, abre em Windows Media Player ou browser

Public Function ExibirPontoQuente(x As Long, y As Long)
' Exibe tooltip explicativo na posicao (x, y)
```

**Dependencias**: Treinamento_Painel (form)

---

### 27. Funcoes.bas
**Proposito**: Funcoes auxiliares variadas (string, data, math).

**Funcoes Principais**:
```vba
Public Function StringIsEmpty(s As String) As Boolean
' Case-insensitive vazio check

Public Function FormatarData(d As Date) As String
' Formata em "DD/MM/YYYY" ou "DD/MM/YYYY HH:MM"

Public Function ParseData(s As String) As Date
' Parse string para Date

Public Function FormatarMoeda(valor As Currency) As String
' Formata em "R$ 1.234,56"

Public Function RemoverEspacos(s As String) As String
Public Function ConverterMaiuscula(s As String) As String
Public Function ConverterMinuscula(s As String) As String

Public Function GeradorUUID() As String
' Gera UUID simplificado para TokenSessao

Public Function TempoTranscorrido(dataInicio As Date) As Long
' Retorna millisegundos

Public Function RandInt(min As Long, max As Long) As Long
```

**Dependencias**: Nenhuma

---

## Resumo de Dependencias

```
Mod_Types
  ├── Util_Conversao
  ├── Util_Config
  ├── Util_Planilha
  ├── Audit_Log
  ├── AppContext
  ├── ErrorBoundary
  ├── Repo_* (5 modulos)
  ├── Svc_* (4 modulos)
  ├── Central_Testes
  └── Variaveis

Const_Colunas
  ├── Util_Planilha
  ├── Util_Conversao
  └── Repo_* (5 modulos)

Auto_Open
  ├── Util_Config
  ├── AppContext
  ├── Audit_Log
  ├── Menu_Principal (form)
  └── ValidarIntegridadeDados() chama Repo_*

Svc_Rodizio
  ├── Repo_Credenciamento
  ├── Repo_OS
  └── Repo_Avaliacao
```

---

**Ultima Atualizacao**: 2026-04-10
