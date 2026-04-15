# Prompt Opus - Contexto Arquitetonico Profundo

**Direcao**: Leia isto quando precisar de mudancas arquitetonicas ou investigacao profunda.

**Versao Atual**: V12.0.0111

---

## Seu Papel

Voce é Claude Opus, o modelo mais avancado disponivel. Sua tarefa é fornecer contexto arquitetonico PROFUNDO do sistema Credenciamento, permitindo qualquer IA (inclusive voce mesmo em outro contexto) a fazer mudancas complexas com confiance maxima.

Prioridades:
1. Arquitetura global (nao apenas um modulo)
2. Relacionamentos entre componentes
3. Padroes de design e anti-patterns
4. Decisoes historicas e racional
5. Cenarios de failover e edge cases

---

## O Sistema em 30 Segundos

Sistema de gestao de credenciamento de pequenos reparos para prefeituras brasileiras. Dois componentes:

**Camada 1: Excel VBA** (27 modulos, 13 forms, 12 tipos)
- Input: Usuario preenche forms
- Processamento: Regras de negocio em VBA, rodizio de empresas
- Storage: 9 planilhas com 8.5k linhas de codigo
- Output: Ordens de servico, relatorios

**Camada 2: SaaS** (futuro, em planejamento)
- Framework: Next.js 16 + React 19 + NeonDB
- Sincronizacao bidirecional com Excel
- Dashboard web para prefeituras
- Multi-tenant (um tenant por prefeitura)

**Versao Atual**: V12.0.0111
**Repositorio**: git@github.com:rwv8gscs8g-blip/credenciamento.git

---

## Arquitetura em Camadas (Deep Dive)

### Camada 1: Dados Persistentes (Planilhas)

9 planilhas formam o banco de dados VBA:

```
EMPRESA
├── Id (PK)
├── Nome
├── CNPJ (UK)
├── Endereco
├── Contato
└── Ativo

ENTIDADE
├── Id (PK)
├── EmpresaId (FK)
├── Nome
├── Tipo (MATRIZ | FILIAL | PROCURACAO)
└── Ativo

ATIVIDADE
├── Id (PK)
├── Nome
├── Descricao
└── Ativo

CREDENCIAMENTO
├── Id (PK)
├── EmpresaId (FK)
├── AtividadeId (FK) [ou Entidade string]
├── DataCredenciamento
└── Ativo

PRE_OS
├── Id (PK)
├── EmpresaId (FK)
├── AtividadeId (FK)
├── DataCriacao
└── Status (RASCUNHO | VALIDADA | CONVERTIDA)

OS
├── Id (PK)
├── PreOSId (FK)
├── Numero (PREFEITURA-YYYYMMDD-SEQUENCIA)
├── DataEmissao
├── DataConclusao
└── Status (EMITIDA | EM_PROGRESSO | CONCLUIDA | CANCELADA)

AVALIACAO
├── Id (PK)
├── OSId (FK)
├── Nota (1.0-5.0)
├── Comentario
└── DataAvaliacao

CONFIGURACAO
├── Chave (PK)
└── Valor (JSON/String)

AUDITLOG
├── Id (PK)
├── Timestamp
├── Operacao
├── Modulo
├── Detalhes (JSON)
└── Usuario
```

**Padroes de Design Aqui**:
- Soft delete (Ativo = False) para nao perder dados historicos
- Foreign keys sem constraints DB (apenas validacao em VBA)
- AuditLog centralizado para conformidade regulatoria
- Configuracao como key-value (flexivel para futuro)

---

### Camada 2: Infraestrutura VBA (7 modulos)

Base do sistema. Qualquer mudanca afeta tudo.

#### Mod_Types.bas (FUNDACAO ABSOLUTA)
- 12 tipos publicos: TResult, TEmpresa, TEntidade, TAtividade, TServico, TCredenciamento, TPreOS, TOS, TAvaliacao, TConfig, TRodizioResultado, TAppContext
- NUNCA mude sem coordenacao
- NUNCA adicione tipo novo em outro modulo
- Se mudar structure existente, BUMP version (V12.0.0107 → V12.0.0108)

**Por que tipos publicos sao criticais**:
- VBA nao tem genericos, interfaces, heranca. Tipos e constantes sao unica forma de abstrair dados
- Uma mudanca em TOS propaga a todo sistema (25+ modulos)
- Compilador VBA é fragil. Se mudar, compilacao pode falhar em modulo nao relacionado (cascade error)

#### Const_Colunas.bas (MAGIC NUMBERS CENTRALIZADOS)
- Mapeamento: Coluna A = 1, B = 2, etc
- Para cada planilha: COL_EMPRESA_ID, COL_EMPRESA_NOME, etc
- Torna refactoring facil (se adicionar coluna, muda um lugar)

#### Util_Conversao.bas (VALIDACOES)
- ValidarEmpresa(), ValidarCNPJ(), ConvertParaEmpresa(), etc
- Regex patterns, regras de negocio
- Centraliza logica que pode mudar (ex: formato CNPJ)

#### Util_Config.bas (SINGLETON PATTERN)
- Uma unica instancia de TConfig em memoria
- Cache automatico
- Getter: ObterConfig(), ObterParametro()
- Setter: SalvarConfig(), SalvarParametro()

#### Util_Planilha.bas (ORM MINIMALISTA)
- CRUD generico: InserirLinha, AtualizarLinha, DeletarLinha, BuscarPorChave, ObterTodos
- Centraliza acesso a planilha (se mudar estrutura, muda um lugar)
- Auto-increment ID simples

**Por que nao usar Access ou SQL Server?**
- Excel é obrigatorio (client precisa usar .xlsm)
- SQL Server teria custo e complexidade
- Planilhas sao suficiente para capacidade atuais (50k ordens)
- Sinergia com SaaS (Postgres) no futuro

#### Audit_Log.bas (RASTREABILIDADE)
- Log de TODAS operacoes: INSERT, UPDATE, DELETE, TESTE, ERRO
- Timestamp, modulo origem, detalhes JSON, usuario
- Usado para debugging, conformidade legal, investigacoes

#### AppContext.bas (CONTEXTO DE SESSAO)
- Global singleton: TAppContext
- UsuarioId, PrefeituraId, PermissoesLevel
- Inicializado em Auto_Open, usado em toda codebase
- Futuro: multi-tenant (hoje apenas PermissoesLevel para admin features)

#### ErrorBoundary.bas (TRATAMENTO CENTRALIZADO DE ERROS)
- Captura Err.Number e Err.Description
- Chama StackTrace(), loga em AuditLog
- Oferece recovery (IsRecuperavel)
- Resultado: erros nao travam aplicacao

---

### Camada 3: Acesso a Dados (5 Repositorios)

Abstracao entre logica de negocio e planilhas. NUNCA acesse planilha diretamente fora destes modulos.

#### Repo_Credenciamento.bas (CRUD PRINCIPAL)
- Empresa: CriarEmpresa(), AtualizarEmpresa(), DeletarEmpresa(), ObterEmpresa(), ListarEmpresas(), BuscarEmpresaPorCNPJ()
- Entidade: similar para entidades
- Atividade: similar
- Credenciamento: CriarCredenciamento(), ObterCredenciamento(), ListarCredenciamentosPorEmpresa()

**Decisao de Design**: Consolidar 4 entidades em 1 modulo? Ou 4 modulos?
- Escolha: 1 modulo
- Racional: Entidades relacionadas, funcoes correlatas (criar empresa → criar entidade)
- Se separar, teria ciclo de dependencia (Empresa.frm precisa de EntidadeRepo e EmpresaRepo)

#### Repo_PreOS.bas, Repo_OS.bas, Repo_Avaliacao.bas (CRUD ESPECIALIZADOS)
- Cada uma trata seu dominio
- PreOS: rascunho, validacoes leves
- OS: numero unico, status transitions
- Avaliacao: nota entre 1-5, media

#### Repo_Empresa.bas (OPERACOES ESPECIALIZADAS)
- BuscarPorCNPJ(), BuscarPorNome(), ListarAtivas(), ListarComCredenciamento()
- Consultas mais complexas que generico CRUD

---

### Camada 4: Logica de Negocio (2 modulos)

Implementa regras de negocio (independente de UI, independente de storage).

#### Classificar.bas (AUTOMACAO)
- Classifica servico por nome
- Regex patterns: "eletri" → ELETRICA, "agua" → ENCANAMENTO, etc
- Saida: um de 5 classificacoes (ELETRICA, ENCANAMENTO, LIMPEZA, REFORMA, OUTRO)
- Usado em Cadastro_Servico form

**Motivacao**: Acelerar entrada de dados. Usuario digita "reparos de eletrica", sistema propoe classificacao correta.

#### Preencher.bas (DEFAULTS E INTEGRIDADE)
- PreencherDadosDefault(): se Nome vazio, tira de CNPJ; se Endereco vazio, seta "Endereco nao informado"
- ValidarIntegridade(): checa referencial (EmpresaId existe?)

---

### Camada 5: Servicos de Negocio (4 modulos)

Orquestra repositorios + logica de negocio. Publica "serviços" de alto nivel para UI.

#### Svc_Rodizio.bas (ALGORITMO CORE)
**Objetivo**: Alcar proxima empresa para ordem de servico, balanceando carga.

**Algoritmo**:
```
1. Listar empresas credenciadas em atividade X
2. Para cada empresa, calcular score:
   - Contar OS alocadas nos ultimos 30 dias
     Menos OS = mais pontos (100 - (count * 20))
   - Media de avaliacoes
     >= 4.5 → +15 pontos
     >= 4.0 → +10 pontos
     < 3.5 → -10 pontos
   - Aleatorio: +random(0,10)
3. Ordenar por score DESC
4. Retornar array TRodizioResultado[]: {EmpresaId, Sequencia, Prioridade}
```

**Decisao de Design**: Por que ponderado (score) e nao round-robin?
- RR: cada empresa alternada. Simples, justo, previsivel.
- Ponderado: leva em conta performance (avaliacoes), carga (OS recentes), aleatorio (surpresa)
- Escolha: Ponderado
- Racional: prefeituras preferem empresas melhores, performance importa

#### Svc_PreOS.bas (CRIACAO DE RASCUNHO)
- CriarPreOSParaEmpresa(empresaId, atividadeId)
- Valida empresa ativa, atividade existe, credenciamento existe
- Chama Repo_PreOS.CriarPreOS()
- Log em AuditLog

#### Svc_OS.bas (CONVERSAO PARA PRODUCAO)
- ConverterPreOSEmOS(preOSId)
- Gera numero unico: PREFEITURA-YYYYMMDD-SEQUENCIA
- Cria TOS com Status=EMITIDA
- Salva, loga, retorna ID

**Numero Unico**:
```vba
PREFEITURA: vem de Util_Config.ObterParametro("PREFEITURA") — "SAO_PAULO"
YYYYMMDD: data current
SEQUENCIA: contador na planilha Configuracao, incrementa diario

Exemplo: "SAO_PAULO-20260410-00001"
```

#### Svc_Avaliacao.bas (REGISTRAR E CALCULAR MEDIA)
- RegistrarAvaliacao(osId, nota, comentario)
- Cria TAvaliacao
- Chama AtualizarMediaEmpresa(empresaId) para recalcular
- Media afeta proxima alocacao via Svc_Rodizio

---

### Camada 6: Apresentacao (13 Forms)

Interface com usuario. Tudo passa por forms, nada de codigo direto em planilhas.

**Arquitetura de Forms**:
```
Menu_Principal (hub central)
  ├─ Credencia_Empresa (input: nome, CNPJ, endereco)
  ├─ Altera_Empresa (busca, edita)
  ├─ Reativa_Empresa (reativar soft-deleted)
  ├─ Altera_Entidade (CRUD entidades)
  ├─ Reativa_Entidade
  ├─ Cadastro_Servico (novo servico, classifica, aloca)
  ├─ Fundo_Branco (auxiliar generico)
  ├─ Limpar_Base (PERIGO! com confirmacoes multiplas)
  ├─ ProgressBar (visual para operacoes longas)
  ├─ Rel_Emp_Serv (grid empresa-servico)
  ├─ Rel_OSEmpresa (grid OS, pode registrar avaliacao inline)
  └─ Configuracao_Inicial (setup inicial)
```

**Padroes em Todos Forms**:
- Validacao em tempo real (cor feedback)
- On Error handler que chama ErrorBoundary
- Confirmacao para operacoes destrutivas
- Log em AuditLog de submit

---

### Camada 7: Carregamento e Testes (6 modulos)

#### Auto_Open.bas
Executado automaticamente quando Excel abre.

**Sequencia**:
1. DisableEvents() para nao disparar recursao
2. ValidarVersaoExcel() (minimo 2019)
3. CarregarConfiguracao() via Util_Config
4. InitializeContext() com usuario padrao
5. ValidarIntegridadeDados() (detecta corruptoes)
6. PrepararFormularios() (cache em memoria)
7. LogaInicio() em AuditLog
8. Menu_Principal.Show

Se ConfiguracaoInicial nao encontrada, oferece form para setup.

#### Variaveis.bas
Variaveis globais, bandeiras de debug, parametros.

```vba
Public gDebugMode As Boolean
Public gDebugTraceAll As Boolean
Public gCacheConfig As TConfig
Public Const RODIZIO_ALGORITMO = "PONDERADO"
Public Const AUDIT_LOG_RETENTION_DAYS = 365
```

#### Central_Testes.bas
Framework de testes (assertions, setup/teardown).

```vba
AssertTrue(condicao, mensagem)
AssertEqual(valor1, valor2)
AssertNotNull(valor)
Setup() ' antes de cada teste
Teardown() ' apos
ExecutarTeste("Teste_XXX", procName)
ExecutarTodosTestes() ' roda tudo
```

#### Teste_Bateria_Oficial.bas
Suite com ~47 testes covering todas funcionalidades.

#### Central_Testes_Relatorio.bas
Gera relatorio HTML com: total testes, passou/falhou/pulado, cobertura, tempo.

#### Teste_UI_Guiado.bas
Testes interativos com usuario guiando passos.

#### Treinamento_Painel.bas
Painel educacional para novos usuarios (opcional, nice-to-have).

---

## Padroes de Design Utilizados

### 1. Repository Pattern
Abstrai acesso a dados. UI chama Repo_*, nao acessa planilha diretamente.

### 2. Service Layer
Servicios (Svc_*) orquestram repositories + logica de negocio. UI chama servicos, nao repositories.

### 3. Singleton
AppContext e Util_Config sao singletons (uma instancia em memoria).

### 4. Result Type
TResult para TODOS retornos: Sucesso (bool) + Mensagem + Codigo + Dados.

### 5. Soft Delete
Ativo = False em lugar de hard delete. Preserva historico.

### 6. Centralized Logging
Audit_Log centralizado. Todo acesso loggado.

### 7. Error Boundary
ErrorBoundary.bas captura e trata erros consistentemente.

---

## Anti-Patterns Para Evitar (Aprendidos na Dor)

### 1. Colon Patterns (KILLER #1)
```vba
' NUNCA:
Dim x As T: x = v

' SEMPRE:
Dim x As T
x = v
```
Corrompe indice de modulo. Causa cascade "Nome repetido" falso.

### 2. Filesystem Nativo (KILLER #2)
```vba
' NUNCA:
MkDir, Kill, Dir(), RmDir

' SEMPRE:
CreateObject("Scripting.FileSystemObject").CreateFolder(...)
```

### 3. Chamadas Nao Qualificadas
```vba
' NUNCA:
res = ValidarEmpresa()

' SEMPRE:
res = Util_Conversao.ValidarEmpresa()
```

### 4. Multiplas Mudancas Simultaneas
Causa cross-module compiler corruption. Resultado: 3 meses de debug (historico de Bug-Nome-Repetido-TConfig).

```
NUNCA: Renomear VB_Name + Adicionar novo modulo + Atualizar referencias tudo junto

SEMPRE: Uma mudanca por iteracao, compilar cada vez
```

### 5. Acesso Direto a Planilha Fora de Repositories
```vba
' NUNCA:
Sheets("Empresa").Range("A2:F2").Value = Array(...)

' SEMPRE:
Dim emp As TEmpresa
res = Repo_Credenciamento.CriarEmpresa(emp)
```

### 6. Modificacoes de Excel Binary Diretamente
NUNCA edite Credenciamento_V12.xlsm direto no binary.

```
SEMPRE:
vba_export/Modulo.bas (editar)
         ↓
      Excel (importar)
         ↓
    Compilar (Debug > Compile)
         ↓
      Git (commit vba_export/)
```

---

## Fluxo de Negocio Principal (Detalhe Completo)

### Cenario: Prefeitura cria ordem de servico para empresa

```
1. USUARIO ABRE MENU_PRINCIPAL
   └─ Auto_Open ja executado
   └─ AppContext inicializado
   └─ Menu form mostra opcoes

2. USUARIO CLICA "CRIAR ORDEM DE SERVICO"
   └─ Form pede: Empresa? Atividade?

3. USUARIO SELECIONA EMPRESA E ATIVIDADE
   └─ Validacoes:
      └─ Empresa existe? Ativo? (via Repo_Credenciamento.ObterEmpresa)
      └─ Atividade existe? (via Repo_Credenciamento.ObterAtividade)
      └─ Credenciamento existe? (via Repo_Credenciamento.ObterCredenciamento)
   └─ Se tudo OK: form oferece button "Criar Pre-OS"

4. USUARIO CLICA "CRIAR PRE-OS"
   └─ Chama Svc_PreOS.CriarPreOSParaEmpresa(empresaId, atividadeId)
      └─ Cria TPreOS novo
      └─ Insere via Repo_PreOS.CriarPreOS()
      └─ Log em AuditLog: "PRE_OS_CRIADA"
   └─ Resultado: PreOS com Status="RASCUNHO"

5. USUARIO CLICA "CONVERTER EM ORDEM"
   └─ Chama Svc_OS.ConverterPreOSEmOS(preOSId)
      └─ Valida PreOS via Svc_PreOS.ValidarPreOSAntesDaOS()
      └─ Gera numero: Svc_OS.GerarNumeroOS()
         └─ PREFEITURA vem de Util_Config.ObterParametro("PREFEITURA")
         └─ YYYYMMDD = Today
         └─ SEQUENCIA = incrementa contador em Configuracao
      └─ Cria TOS novo: {PreOSId, Numero, DataEmissao=Today, Status="EMITIDA"}
      └─ Insere via Repo_OS.CriarOS()
      └─ Atualiza PreOS: Status="CONVERTIDA"
      └─ Log em AuditLog: "OS_CRIADA"
   └─ Resultado: OS emitida, numero unico gerado

6. EMPRESA EXECUTA SERVICO
   └─ (fora do sistema)

7. EMPRESA MARCA COMO CONCLUIDA
   └─ Via Menu_Principal > Rel_OSEmpresa
   └─ Usuario seleciona OS em grid
   └─ Button "Marcar Concluida"
   └─ Chama Svc_OS.ConcluirOS(osId, dataConclusao)
      └─ Atualiza TOS: Status="CONCLUIDA", DataConclusao=Today
      └─ Log: "OS_CONCLUIDA"

8. USUARIO AVALIA SERVICO
   └─ Via Rel_OSEmpresa > button "Avaliar" em linha
   └─ Form pede: Nota (1-5), Comentario
   └─ Chama Svc_Avaliacao.RegistrarAvaliacao(osId, nota, comentario)
      └─ Cria TAvaliacao novo
      └─ Insere via Repo_Avaliacao.CriarAvaliacao()
      └─ Chama AtualizarMediaEmpresa(empresaId)
         └─ Recalcula media de TODAS avaliacoes da empresa
         └─ Afeta prioridade em proxima alocacao
      └─ Log: "AVALIACAO_REGISTRADA"

9. PROXIMA ORDEM (PARA MESMA ATIVIDADE)
   └─ Svc_Rodizio.AplicarRodizio(atividadeId)
   └─ Score include: media nova da empresa (se 4.5+, mais pontos)
   └─ Empresa com melhor performance tem prioridade

FIM DE FLUXO
```

---

## Decisoes Arquitetonicas Importantes

### Por Que Dois Repositorios Separados? (Repo_Credenciamento vs Repo_Empresa)

**Repo_Credenciamento**: CRUD basico + operacoes principais
- CriarEmpresa, AtualizarEmpresa, DeletarEmpresa, ObterEmpresa, ListarEmpresas
- CriarEntidade, AtualizarEntidade, etc
- CriarCredenciamento, ListarCredenciamentosPorEmpresa

**Repo_Empresa**: Operacoes especializadas
- BuscarPorCNPJ (exato)
- BuscarPorNome (parcial/LIKE)
- ListarAtivas
- ListarComCredenciamento

**Por que separados?**
- Repo_Credenciamento = generico, reutilizavel
- Repo_Empresa = especializado, logica de negocio
- Separacao de concerns

---

### Por Que Algoritmo Ponderado e Nao Round-Robin?

**RR (Round-Robin)**: Empresa 1 → Empresa 2 → Empresa 3 → Empresa 1
- Pros: Justo, previsivel, simples
- Cons: Ignora performance, empresas ruins recebem mesmo que empresas boas

**Ponderado**: Score baseado em carga + performance + aleatorio
- Pros: Incentiva performance (media alta = mais ordens), balancea carga (menos ordens recentemente = prioridade)
- Cons: Mais complexo, pode ser imprevisivel (aleatorio)

**Escolha**: Ponderado
**Racional**: Prefeituras querem empresas boas. Se empresa A tem media 4.8 e empresa B tem 2.0, preferem alocar em A.

---

### Por Que Util_Config.bas Como Singleton e Nao Multiple Reads?

**Multiple Reads**:
```vba
Dim prefeitura As String
prefeitura = Util_Planilha.BuscarPorChave("Configuracao", 1, "PREFEITURA").Offset(0, 1).Value
```
Performance ruim. Lê planilha toda vez.

**Singleton Cache**:
```vba
Dim config As TConfig
config = Util_Config.ObterConfig()
prefeitura = config.Prefeitura
```
Cache em memoria. Performance OK.

**Invalidacao**: Qdo SalvarConfig(), cache invalidado.

---

### Por Que Soft Delete E Nao Hard Delete?

**Hard Delete**: Deleta linha, desaparece pra sempre
- Pro: Limpo, simples
- Con: Perde historico, quebra audit trail

**Soft Delete**: Ativo = False, linha permanece
- Pro: Historico preservado, audit trail completo, pode reativar
- Con: Mais complexo (sempre check Ativo = True em listas)

**Escolha**: Soft delete
**Racional**: Dados de prefeituras sao criticos. Se deletar errado, precisa recuperar.

---

## Escalabilidade e Limites

### Capacidade Atual

- **Empresas**: ~1.000 OK (testado ate 500)
- **Entidades**: ~5.000
- **Ordens de Servico**: ~50.000 (testado ate 10.000)
- **AuditLog**: ~1M entradas/ano (5 anos = 5M)
- **Memory**: ~50MB (com cache)

### Quando Escalar Para SaaS?

```
Se em uma prefeitura:
- Empresas > 1.000
- Ordens/ano > 100.000
- Users simultaneos > 10
- Necessidade de analytics real-time

Entao → Migrar para SaaS (Next.js + NeonDB)
```

### Performance Optimization Opportunities

1. **Planilha**: Particionar grandes tabelas (ex: OS por ano)
2. **Cache**: Aumentar cache em memoria (empresas, atividades)
3. **Indices**: Se SQL futuramente, add indices em CNPJ, numero OS
4. **Async**: Tasks longas (import CNAE) → background jobs

---

## Migracao Futura: Excel → SaaS

### Fase Atual (2026-04-10)
- Spreadsheet VBA produtivo
- Vault Obsidian criado para conhecimento
- SaaS em planejamento (Fase 1 Q2 2026)

### Fase 1 (Junho 2026)
- SaaS beta com 3 prefeituras testando
- Sincronizacao Excel → SaaS funcional
- Dashboard basico web

### Fase 2 (Outubro 2026)
- SaaS produtivo com 10+ prefeituras
- Edicao direto em SaaS, export para Excel
- Webhooks real-time

### Fase 3 (2027)
- Deprecate Excel? Ou manter indefinidamente?
- Decisao: Manter Excel para backward compat
- Usuarios que querem SaaS podem migrar incrementalmente

---

## Documentacao de Referencia

- **[[01-CONTEXTO-IA]]** - Comeco aqui
- **[[arquitetura/Visao-Geral]]** - Arquitetura dois-camadas
- **[[arquitetura/Modulos-VBA]]** - Catalogo detalhado de 27 modulos
- **[[arquitetura/Tipos-Publicos]]** - 12 tipos, definicao e uso
- **[[regras/Compilacao-VBA]]** - Regras obrigatorias
- **[[historico/Bug-Nome-Repetido-TConfig]]** - Case study de 3 meses

---

## Pontos de Extensao (Para Futuras IAs)

### 1. Adicionar Nova Atividade Type

**Sem Mudar Tipos**:
```vba
' Apenas adicionar em lista de classificacoes em Classificar.bas
Private Function PatternNovo(nome As String) As Boolean
  PatternNovo = (InStr(1, nome, "palavra-chave", vbTextCompare) > 0)
End Function

' Nao muda nada mais
```

### 2. Adicionar Nova Coluna em Empresa

**Passos**:
1. Adicionar coluna em planilha Empresa (manual)
2. Atualizar Const_Colunas.bas: `Public Const COL_EMPRESA_NOVOCAMPO = 7`
3. Atualizar Mod_Types: adicionar campo em TEmpresa
4. COMPILE (vai dar erro)
5. Atualizar Repo_Credenciamento.CriarEmpresa() para inserir novo campo
6. Atualizar forms: Credencia_Empresa, Altera_Empresa
7. COMPILE ate OK
8. Test, relase note, commit

### 3. Adicionar Novo Relatorio

**Sem Tocar em Logica Existente**:
1. Criar novo form: Rel_NovoRelatorio.frm
2. Grid com dados
3. Button "Exportar CSV"
4. Chamar Util_Planilha.BuscarTodas() para dados
5. Adicionar button em Menu_Principal
6. Done

---

## Troubleshooting Arquitetonico

### Erro: "Nome Repetido"
Culpado: Colon pattern + multiplas mudancas simultaneas. Ver [[historico/Bug-Nome-Repetido-TConfig]].

### Performance Lenta
Verificar: AuditLog cresceu demais? Cache desativado? Planilha corrompida?

### Compilacao Falha Randomicamente
Culpado: Encoding errado (UTF-8 vs ANSI) ou VB_Name corrompido.

### Sincronizacao SaaS Falha
Culpado: API endpoint falha, schema mismatch, permissoes insuficientes.

---

**Ultima Atualizacao**: 2026-04-10
**Para**: Claude Opus e modelos futuros
**Confiance**: MAXIMA - este é contexto completo e preciso
