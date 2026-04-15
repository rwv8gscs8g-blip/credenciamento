# Contexto Completo para Inteligência Artificial

## Identidade do Projeto

**Nome**: Sistema de Gestao de Credenciamento de Pequenos Reparos para Prefeituras
**Sigla**: Credenciamento
**Propósito**: Gerenciar credenciamento de empresas prestadoras de serviço de pequenos reparos em prefeituras brasileiras. Inclui cadastro de empresas, alocação de serviços, criação de ordens de serviço, avaliação e rodizio entre empresas.

**Versão Estável**: V12.0.0111
**Data de Liberação**: 2026-04-11
**Status**: Produção - baseline estabilizado e compilado no Excel
**Repositório Principal**: git@github.com:rwv8gscs8g-blip/credenciamento.git

## Arquitetura em Duas Camadas

### Camada 1: Excel VBA (.xlsm)
- **Arquivo Principal**: Credenciamento_V12.xlsm
- **Tamanho**: ~28 módulos .bas + 13 UserForms
- **Linhas de Código**: ~8.500
- **Idioma**: Visual Basic for Applications (VBA)
- **Requisitos**: Excel 2019, 2021 ou 365 em Windows 10+

### Camada 2: SaaS (Next.js + NeonDB)
- **Localização**: /Users/macbookpro/Projetos/maiscompralocal-core
- **Stack**: Next.js 16, React 19, Drizzle ORM, NeonDB (PostgreSQL), Cloudflare R2, Resend, Vercel
- **Propósito**: Dashboard web, importação de dados Excel, exportação para terceiros, relatórios avançados
- **Modelo**: Pagamento por Prefeitura (multi-tenant com tenant_id)
- **Sincronização**: Bidirecional com Excel (import/export)

## Estrutura de Pastas do Repositório

```
credenciamento/
├── vba_export/                      # Código VBA exportado
│   ├── Mod_Types.bas               # 12 tipos publicos
│   ├── Const_Colunas.bas           # Constantes de coluna
│   ├── Util_Conversao.bas          # Validacao e conversao
│   ├── Util_Config.bas             # Acesso a configuracoes
│   ├── Util_Planilha.bas           # Operacoes de planilha
│   ├── App_Release.bas             # Metadata centralizada da release atual
│   ├── Funcoes.bas                 # Funcoes utilitarias
│   ├── Audit_Log.bas               # Auditoria centralizada
│   ├── AppContext.bas              # Contexto de aplicacao
│   ├── ErrorBoundary.bas           # Tratamento de erros
│   ├── Auto_Open.bas               # Carregamento automatico
│   ├── Repo_*.bas                  # 5 modulos repositorio
│   ├── Svc_*.bas                   # 4 modulos servico
│   ├── Classificar.bas             # Classificacao de servicos
│   ├── Preencher.bas               # Preenchimento de dados
│   ├── Variaveis.bas               # Variaveis globais
│   ├── Central_Testes.bas          # Sistema de testes
│   ├── Teste_*.bas                 # 3 modulos teste
│   ├── Treinamento_Painel.bas      # Painel de treinamento
│   └── Formularios/                # 13 UserForms
│       ├── Menu_Principal.frm
│       ├── Configuracao_Inicial.frm
│       ├── Credencia_Empresa.frm
│       ├── Altera_Empresa.frm
│       ├── Reativa_Empresa.frm
│       ├── Altera_Entidade.frm
│       ├── Reativa_Entidade.frm
│       ├── Cadastro_Servico.frm
│       ├── Fundo_Branco.frm
│       ├── Limpar_Base.frm
│       ├── ProgressBar.frm
│       ├── Rel_Emp_Serv.frm
│       └── Rel_OSEmpresa.frm
└── docs/                            # Documentacao
```

## 28 Módulos VBA - Funções Críticas

### Fundação (5 módulos)
1. **Mod_Types.bas** - Define 12 tipos publicos: TResult, TAtividade, TServico, TEmpresa, TCredenciamento, TEntidade, TPreOS, TOS, TAvaliacao, TConfig, TRodizioResultado, TAppContext
2. **Const_Colunas.bas** - Mapeamento de colunas para todas as 7 planilhas
3. **Util_Conversao.bas** - Conversao de tipos, validacao de dados, tratamento de NULL
4. **Util_Config.bas** - Leitura/escrita de planilha Configuracao
5. **Util_Planilha.bas** - Acesso a dados, busca por chave, insercao, atualizacao, delecao

### Auditoria e Contexto (3 módulos)
6. **Audit_Log.bas** - Log de todas as operacoes (insert, update, delete, testes)
7. **AppContext.bas** - Contexto global: usuario, prefeitura, timestamp, permissoes
8. **ErrorBoundary.bas** - Tratamento centralizado de erros, stack trace

### Repositórios (5 módulos)
9. **Repo_Credenciamento.bas** - CRUD para empresa, entidade, serviço, credenciamento
10. **Repo_PreOS.bas** - Acesso a pre-ordens de servico
11. **Repo_OS.bas** - Acesso a ordens de servico completas
12. **Repo_Avaliacao.bas** - Acesso a avaliacoes de servicos
13. **Repo_Empresa.bas** - Operacoes especializadas em empresas

### Serviços (4 módulos)
14. **Svc_Rodizio.bas** - Algoritmo de rodizio entre empresas (RR ou ponderado)
15. **Svc_PreOS.bas** - Criar pre-ordens, validar empresas, alcar servicos
16. **Svc_OS.bas** - Converter pre-OS em OS completa, gerar numero
17. **Svc_Avaliacao.bas** - Registrar avaliacao, atualizar historico

### Lógica de Negócio (2 módulos)
18. **Classificar.bas** - Classificar servicos por tipo (eletrica, encanamento, etc)
19. **Preencher.bas** - Preencher dados faltantes, validar integridade

### Carregamento e Inicializacao (2 módulos)
20. **App_Release.bas** - Versao atual, status da release e URLs oficiais do projeto
21. **Auto_Open.bas** - Executado ao abrir Excel: carrega config, valida dados, prepara contexto
22. **Variaveis.bas** - Variaveis globais, bandeiras, opcoes de debug

### Testes (4 módulos)
23. **Central_Testes.bas** - Framework de testes (assertions, setup/teardown)
24. **Teste_Bateria_Oficial.bas** - Suite completa de testes de unidade
25. **Central_Testes_Relatorio.bas** - Relatorio de cobertura e resultados
26. **Teste_UI_Guiado.bas** - Testes interativos de UI

### Utilitários Especializados (2 módulos)
27. **Treinamento_Painel.bas** - Painel educacional para novos usuarios
28. **Funcoes.bas** - Funcoes auxiliares variadas (string, data, math)

## 13 UserForms - Interface do Usuário

### Menu e Configuracao
- **Menu_Principal** - Menu inicial com opcoes de operacao
- **Configuracao_Inicial** - Setup de prefeitura, usuarios, opcoes

### Gestão de Empresas (3 forms)
- **Credencia_Empresa** - Novo cadastro com validacao em tempo real
- **Altera_Empresa** - Edicao de dados existentes com auditoria
- **Reativa_Empresa** - Reativar empresa desativa com filtros de busca

### Gestão de Entidades (2 forms)
- **Altera_Entidade** - Edicao de estrutura de empresa
- **Reativa_Entidade** - Reativacao de entidades

### Cadastro de Serviços
- **Cadastro_Servico** - Novo servico com classificacao automatica

### Operacional (3 forms)
- **Fundo_Branco** - Tela auxiliar para operacoes especiais
- **Limpar_Base** - Limpeza de dados com confirmacao multipla
- **ProgressBar** - Barra de progresso para operacoes longas

### Relatórios (2 forms)
- **Rel_Emp_Serv** - Empresas por servico com filtros
- **Rel_OSEmpresa** - Ordens de servico por empresa

## 12 Tipos Públicos (Mod_Types.bas)

```vba
Type TResult
  Sucesso As Boolean
  Mensagem As String
  Codigo As Long
  Dados As Variant
End Type

Type TAtividade
  Id As Long
  Nome As String
  Descricao As String
  Ativo As Boolean
End Type

Type TServico
  Id As Long
  Nome As String
  Classificacao As String
  Ativo As Boolean
End Type

Type TEmpresa
  Id As Long
  Nome As String
  CNPJ As String
  Endereco As String
  Contato As String
  Ativo As Boolean
End Type

Type TCredenciamento
  Id As Long
  EmpresaId As Long
  Entidade As String
  DataCredenciamento As Date
  Ativo As Boolean
End Type

Type TEntidade
  Id As Long
  EmpresaId As Long
  Nome As String
  Tipo As String
  Ativo As Boolean
End Type

Type TPreOS
  Id As Long
  EmpresaId As Long
  AtividadeId As Long
  DataCriacao As Date
  Status As String
End Type

Type TOS
  Id As Long
  PreOSId As Long
  Numero As String
  DataEmissao As Date
  DataConclusao As Date
  Status As String
End Type

Type TAvaliacao
  Id As Long
  OSId As Long
  Nota As Single
  Comentario As String
  DataAvaliacao As Date
End Type

Type TConfig
  Prefeitura As String
  Ambiente As String
  VersaoVBA As String
  DataUltimaAtualizacao As Date
  UsuarioAtualizacao As String
End Type

Type TRodizioResultado
  EmpresaId As Long
  Sequencia As Long
  Prioridade As Single
End Type

Type TAppContext
  UsuarioId As Long
  PrefeituraId As Long
  DataSessao As Date
  TokenSessao As String
  PermissoesLevel As Long
End Type
```

## Banco de Dados VBA (7 Planilhas)

1. **Empresa** - Cadastro de empresas com CNPJ, endereco, contato
2. **Entidade** - Estrutura juridica de cada empresa
3. **Atividade** - Tipos de atividades/servicos disponiveis
4. **Credenciamento** - Registro de credenciamento por empresa
5. **PreOS** - Pre-ordens de servico (rascunho)
6. **OS** - Ordens de servico finalizadas
7. **Avaliacao** - Avaliacoes de servicos executados
8. **Configuracao** - Parametros da aplicacao
9. **AuditLog** - Log completo de operacoes

## Fluxo de Negócio Principal

```
1. CADASTRO
   Usuario abre Menu_Principal
   → Seleciona "Credenciar Empresa"
   → Abre Credencia_Empresa (form)
   → Valida CNPJ, endereco, contato
   → Insere em planilha Empresa via Repo_Credenciamento
   → Audit_Log registra insercao
   → Sucesso mensagem

2. ALOKACAO DE SERVICO
   Usuario seleciona empresa
   → Abre Cadastro_Servico
   → Classificar.bas classifica automaticamente por tipo
   → Svc_Rodizio.bas aloca equitativamente entre empresas
   → Registra em Credenciamento e Atividade
   → Audit_Log registra alocacao

3. GERACAO DE OS
   Quando necessario uma ordem de servico
   → Cria PreOS via Svc_PreOS.bas
   → Valida empresa e serviço
   → Aplica regras de rodizio
   → Svc_OS.bas converte PreOS em OS
   → Gera numero unico (Prefeitura-Data-Seq)
   → Emite para empresa

4. AVALIACAO
   Apos conclusao da OS
   → Usuario abre Rel_OSEmpresa
   → Registra Avaliacao (nota, comentario)
   → Svc_Avaliacao.bas atualiza historico
   → Afeta proxima alocacao via Svc_Rodizio
   → Audit_Log registra avaliacao
```

## SaaS Integration (NeonDB Postgres)

### Schema Espelhado
```sql
CREATE TABLE empresas (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL,
  nome VARCHAR(255) NOT NULL,
  cnpj VARCHAR(18) UNIQUE NOT NULL,
  endereco TEXT,
  contato VARCHAR(255),
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE entidades (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL,
  empresa_id INTEGER REFERENCES empresas(id),
  nome VARCHAR(255) NOT NULL,
  tipo VARCHAR(50),
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP,
  atualizado_em TIMESTAMP
);

-- Similar para: atividades, servicos, credenciamentos, 
-- pre_ordens_servico, ordens_servico, audit_log
```

### Fluxo de Sincronizacao
- **Excel → SaaS**: Import via API (POST /api/sync/import)
- **SaaS → Excel**: Export via API (GET /api/sync/export?formato=xlsx)
- **Real-time**: Webhook quando OS criada/concluida

## Regras Críticas de Compilacao VBA

### REGRA KILLER #1: Colon Patterns
NUNCA use padrão `Dim x As T: x = v` em uma linha. Causa corruptao do indice de modulo e cascade de erros "Nome repetido".

**ERRADO**:
```vba
Dim empresa As TEmpresa: empresa.Id = 1
```

**CERTO**:
```vba
Dim empresa As TEmpresa
empresa.Id = 1
```

### REGRA KILLER #2: Operacoes de Filesystem Nativo
NUNCA use MkDir, Kill, Dir() diretamente em VBA. Causam modulos invisiveis e perda de referencias.

**ERRADO**:
```vba
Kill App.Path & "\temp.txt"
```

**CERTO**:
```vba
CreateObject("Scripting.FileSystemObject").DeleteFile App.Path & "\temp.txt"
```

### REGRA #3: Chamadas Qualificadas
SEMPRE use nome do modulo: `Modulo.Procedimento`, nunca apenas `Procedimento`.

**ERRADO**:
```vba
Dim res As TResult
res = ValidarEmpresa(1)
```

**CERTO**:
```vba
Dim res As TResult
res = Util_Conversao.ValidarEmpresa(1)
```

### REGRA #4: Uma Mudanca por Iteracao
NUNCA faça multiplas mudancas de arquivo VBA em uma iteracao. Sempre:
1. Editar UMA mudanca em vba_export/
2. Importar em Excel
3. Compilar (Debug > Compile)
4. Testar
5. Criar release note
6. Commit no Git

### REGRA #5: Compilacao Obrigatoria
SEMPRE compilar apos cada mudanca:
1. Abrir Excel com Credenciamento_V12.xlsm
2. Ir a Tools > Macros > Visual Basic Editor
3. Clicar Debug > Compile
4. Se houver erros, nao fazer commit

## Como Fazer Mudancas com Seguranca

### Processo Passo a Passo

1. **Preparacao**
   - Leia [[regras/Compilacao-VBA]] inteiramente
   - Leia [[regras/Checklist-Pre-Deploy]]
   - Identifique qual modulo editar

2. **Edicao de Codigo**
   - Edite arquivo .bas em vba_export/
   - NUNCA renomeie VB_Name sem testar isoladamente
   - Siga padroes: sem colons, chamadas qualificadas, tipos completos

3. **Import em Excel**
   - Abra Credenciamento_V12.xlsm
   - Tools > Macros > Visual Basic Editor
   - File > Import File (select .bas editado)
   - Confirme sobrescrita de modulo existente

4. **Compilacao e Teste**
   - Debug > Compile (deve completar sem erros)
   - Teste a funcao modificada manualmente ou via Central_Testes
   - Verifique Audit_Log para erros inesperados

5. **Release Note**
   - Crie arquivo releases/V12.0.XXXX.md
   - Liste: modulos alterados, funcionalidades adicionadas, bugs corrigidos, testes executados

6. **Commit Git**
   ```bash
   git add vba_export/Modulo_Editado.bas
   git add releases/V12.0.XXXX.md
   git commit -m "V12.0.XXXX: Descricao curta da mudanca"
   git push origin main
   ```

## O Que NÃO Fazer

1. NUNCA edite Mod_Types.bas para adicionar tipos NOVOS sem coordenar com toda equipe
2. NUNCA mude VB_Name sem testar em workbook novo primeiro
3. NUNCA use variaveis globais nao documentadas em Variaveis.bas
4. NUNCA faça mais de 1 mudanca de modulo por iteracao
5. NUNCA compile sem antes corrigir todos os erros de sintaxe
6. NUNCA commite codigo nao testado ao repositorio
7. NUNCA use UTF-16 em arquivos .bas (use UTF-8 com BOM)
8. NUNCA deixe Debug.Print sem comentar antes de release

## Integracao SaaS - Roadmap

### Fase 1 (Q2 2026)
- [ ] Autenticacao multi-tenant com tenant_id por Prefeitura
- [ ] API de import: POST /api/sync/import (recebe JSON de Excel)
- [ ] API de export: GET /api/sync/export?tenant_id=XXX

### Fase 2 (Q3 2026)
- [ ] Dashboard Next.js para visualizar empresas, OS, avaliacoes
- [ ] Import CNAE automatico via tableauontax API
- [ ] Filtros avancados de busca por empresa, servico, periodo

### Fase 3 (Q4 2026)
- [ ] Geracao de relatorios em PDF
- [ ] Integracao com sistema de pagamento
- [ ] Webhooks para notificacao de OS em tempo real

### Open Source vs Pago
- **Excel VBA**: Codigo aberto no GitHub (git@github.com:rwv8gscs8g-blip/credenciamento.git)
- **SaaS**: Software proprietary. Acesso por subscription (Prefeitura paga por tenant)
- **Dados**: Completamente separados. SaaS importa dados Excel, pode exportar para usuarios que cancelam

## Documentos Relacionados

Leia nesta ordem:
1. **00-DASHBOARD.md** - Visao geral e status
2. **01-CONTEXTO-IA.md** (este arquivo) - Toda informacao necessaria
3. **arquitetura/Visao-Geral.md** - Arquitetura detalhada
4. **regras/Compilacao-VBA.md** - Regras absolutas de mudanca
5. **historico/Bug-Nome-Repetido-TConfig.md** - Caso de estudo importante

## Questoes Frequentes

**P: Posso renomear um modulo?**
R: Nao sem testar isoladamente. Se renomear (ex: AppContext → Mod_AppContext), SEMPRE compile em workbook novo primeiro.

**P: Como adicionar tipo novo?**
R: Adicione em Mod_Types.bas, compile, crie novo arquivo .bas que use o tipo, importe ambos, compile novamente. Sempre 2 etapas.

**P: Qual é a causa do erro "Nome repetido: TConfig"?**
R: Bug resolvido. Era cascade de erro ao adicionar Util_CNAE.bas + renomear AppContext. V12-093 compila perfeitamente. Ver [[historico/Bug-Nome-Repetido-TConfig]].

**P: Como testar codigo novo?**
R: Use Central_Testes.bas. Adicione Sub Teste_XXX() em Teste_Bateria_Oficial.bas, execute via Menu_Principal > Testes > Executar Bateria, veja relatorio.

---

**VERSAO**: V12.0.0111
**ULTIMA ATUALIZACAO**: 2026-04-10
**PROXIMO ARQUIVO A LER**: [[arquitetura/Visao-Geral]]
