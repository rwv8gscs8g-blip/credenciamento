# SaaS Roadmap - Fase 1 (Q2 2026)

**Status**: Em Planejamento
**Data Alvo**: Junho 2026
**Stack**: Next.js 16, React 19, Drizzle ORM, NeonDB (Postgres), Vercel

---

## Objetivo Fase 1

Criar dashboard SaaS que espelha dados do Excel VBA em tempo real e oferece funcionalidade basica de gestao de credenciamento para prefeituras em formato web.

---

## Requisitos Funcionais

### 1. Autenticacao Multi-Tenant

#### User Types
- **Admin Prefeitura**: Gerencia usuarios, configuracoes, dados
- **Usuario Standard**: Consulta dados, cria OS, registra avaliacoes
- **Visitante (futuro)**: Apenas leitura de relatorios publicos

#### Fluxo de Auth
```
1. Usuario acessa app.maiscompralocal.com
2. Redireciona para /login
3. Email + Senha (ou OAuth Google/GitHub)
4. Sistema cria sessao
5. Usuario associado a tenant_id (prefeitura)
6. Dashboard carrega dados da prefeitura especifica
```

#### Campos de Usuario
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255), -- NULL se OAuth
  nome VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(50), -- ADMIN, STANDARD, VISITANTE
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW()
);
```

#### Sessao
- Usar NextAuth.js ou similar
- Token JWT com tenant_id embutido
- Expiracao: 24 horas

### 2. Sincronizacao Excel ↔ SaaS

#### API Endpoint: POST /api/sync/import
**Entrada**: JSON com dados de Excel
```json
{
  "tenant_id": "prefeitura-123",
  "timestamp": "2026-04-10T14:30:00Z",
  "data": {
    "empresas": [...],
    "entidades": [...],
    "atividades": [...],
    "credenciamentos": [...],
    "pre_ordens": [...],
    "ordens": [...],
    "avaliacoes": [...]
  }
}
```

**Saida**:
```json
{
  "sucesso": true,
  "mensagem": "Importado com sucesso",
  "registros_processados": {
    "empresas": 5,
    "entidades": 3,
    "ordens": 12
  },
  "timestamp_sincronizacao": "2026-04-10T14:30:15Z"
}
```

**Logica**:
1. Validar tenant_id e usuario autenticado
2. Para cada tabela, fazer UPSERT (update se existe, insert se novo)
3. Comparar por chave unica (CNPJ para empresas, numero para OS)
4. Log de sincronizacao em tabela sync_log
5. Retornar resumo de mudancas

#### API Endpoint: GET /api/sync/export
**Query Params**:
- `tenant_id`: ID da prefeitura
- `formato`: "json" (default) ou "xlsx"
- `desde`: Data inicio (opcional)
- `ate`: Data fim (opcional)

**Saida JSON**:
```json
{
  "timestamp_geracao": "2026-04-10T14:30:00Z",
  "tenant_id": "prefeitura-123",
  "dados": {
    "empresas": [...],
    "entidades": [...],
    "ordens_servico": [...]
  }
}
```

**Saida XLSX**: Arquivo Excel estruturado (compativel com VBA para re-import)

#### Fluxo de Sincronizacao Manual
```
Usuario em Excel:
1. Menu_Principal > "Sincronizar com SaaS"
2. Form pede credenciais (email, senha)
3. Coleta todos dados
4. POST /api/sync/import
5. Mostra resultado (X empresas, Y ordens sincronizadas)
6. Log em AuditLog local

Resultado em SaaS:
1. Dashboard atualiza automaticamente
2. Dados disponiveis para consulta em tempo real
3. Relatorios recalculam
```

#### Fluxo de Webhooks (Futuro)
```
Quando OS criada/finalizada em Excel:
1. Audit_Log registra evento
2. Script monitora Audit_Log
3. Se OS CRIADA ou CONCLUIDA:
   - Envia POST a /api/webhooks/os-event
   - SaaS atualiza em tempo real (sem aguardar import)
4. Dashboard notifica usuarios (opcional)
```

### 3. Dashboard Next.js

#### Layout Principal
```
┌─────────────────────────────────────┐
│  Logo | Menu | Perfil Dropdown | X  │
├─────────────────────────────────────┤
│ [Dashboard] [Empresas] [Ordens]     │ ← Abas
├─────────────────────────────────────┤
│                                     │
│  ┌─ Dashboard Metrics ──────────┐  │
│  │ Empresas: 24                 │  │
│  │ Ordens Mes: 156              │  │
│  │ Media Avaliacao: 4.2/5       │  │
│  │ Ultima Sincronizacao: 2h     │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌─ Ultimas Ordens ──────────────┐ │
│  │ Num | Empresa | Status | Data│  │
│  │ ... | ...     | ...    | ... │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

#### Paginas Principais

**Aba: Dashboard**
- Cards com metricas (empresas ativas, ordens/mes, media avaliacao, ultima sync)
- Grafico de ordens por mes (ultimos 12 meses)
- Grafico de empresas por classificacao (pizza)
- Tabela de ultimas 10 ordens
- Status de sincronizacao (quando foi ultima)

**Aba: Empresas**
- Grid com todas empresas
- Colunas: CNPJ, Nome, Entidades, Ativo, Acoes (editar, inativar)
- Filtros: Nome (search), Ativo (dropdown)
- Sort: por CNPJ, Nome, Data Criacao
- Button "Nova Empresa"
- Button "Exportar CSV"

**Aba: Ordens**
- Grid com ordens de servico
- Colunas: Numero, Empresa, Data Emissao, Status, Avaliacao, Acoes (ver, editar status)
- Filtros: Periodo (datepicker), Status (multi-select), Empresa (autocomplete)
- Sort: por data, numero, status
- Button "Nova Ordem"
- Button "Exportar CSV"
- Inline: mudar status (dropdown em coluna Status), ver detalhes

**Aba: Relatorios**
- Tabela Empresas por Atividade
- Tabela Ordens por Periodo
- Grafico de Avaliacoes por Empresa
- Export CSV para cada relatorio

#### Componentes Reutilizaveis
- DataTable (grid paginada, sort, filter)
- Card com numero (metricas)
- Modal para edicao
- DatePicker para filtros
- Autocomplete para buscas
- Dropdown para status
- Button com loading state

### 4. Schema Postgres (Drizzle ORM)

#### Tabelas Principais

```sql
-- Tenants (Prefeituras)
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  plano VARCHAR(50) DEFAULT 'free', -- free, pro, enterprise
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_cancelamento TIMESTAMP,
  ativo BOOLEAN DEFAULT true
);

-- Usuarios
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  email VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255),
  nome VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(50) DEFAULT 'standard',
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW(),
  UNIQUE(tenant_id, email)
);

-- Empresas (espelhado de Excel)
CREATE TABLE empresas (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nome VARCHAR(255) NOT NULL,
  cnpj VARCHAR(18) NOT NULL,
  endereco TEXT,
  contato VARCHAR(255),
  ativo BOOLEAN DEFAULT true,
  sincronizado_em TIMESTAMP DEFAULT NOW(),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  UNIQUE(tenant_id, cnpj)
);

-- Entidades
CREATE TABLE entidades (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  empresa_id INTEGER REFERENCES empresas(id),
  nome VARCHAR(255) NOT NULL,
  tipo VARCHAR(50),
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Atividades
CREATE TABLE atividades (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  nome VARCHAR(255) NOT NULL,
  descricao TEXT,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Credenciamentos
CREATE TABLE credenciamentos (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  empresa_id INTEGER REFERENCES empresas(id),
  atividade_id INTEGER REFERENCES atividades(id),
  data_credenciamento DATE,
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Ordens de Servico
CREATE TABLE ordens_servico (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  empresa_id INTEGER REFERENCES empresas(id),
  atividade_id INTEGER REFERENCES atividades(id),
  numero VARCHAR(100) NOT NULL,
  data_emissao DATE,
  data_conclusao DATE,
  status VARCHAR(50),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  UNIQUE(tenant_id, numero)
);

-- Avaliacoes
CREATE TABLE avaliacoes (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  ordem_id INTEGER REFERENCES ordens_servico(id),
  nota DECIMAL(3,1),
  comentario TEXT,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Audit Log
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  usuario_id UUID REFERENCES users(id),
  tabela VARCHAR(100),
  operacao VARCHAR(50),
  dados_antes JSONB,
  dados_depois JSONB,
  criado_em TIMESTAMP DEFAULT NOW()
);

-- Sync Log
CREATE TABLE sync_log (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  timestamp_sync TIMESTAMP,
  registros_importados JSONB,
  status VARCHAR(50),
  erro_mensagem TEXT,
  criado_em TIMESTAMP DEFAULT NOW()
);
```

### 5. API Endpoints (MVP)

#### Autenticacao
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/logout
- GET /api/auth/me

#### Empresas
- GET /api/empresas
- POST /api/empresas
- GET /api/empresas/:id
- PUT /api/empresas/:id
- DELETE /api/empresas/:id (soft delete)

#### Ordens
- GET /api/ordens
- POST /api/ordens
- GET /api/ordens/:id
- PUT /api/ordens/:id (change status)
- POST /api/ordens/:id/avaliacao

#### Relatorios
- GET /api/relatorios/empresas-atividades
- GET /api/relatorios/ordens-periodo
- GET /api/relatorios/avaliacoes-empresa

#### Sincronizacao
- POST /api/sync/import
- GET /api/sync/export
- GET /api/sync/status

#### Admin (para Admins apenas)
- GET /api/admin/tenants
- POST /api/admin/tenants
- GET /api/admin/users
- PUT /api/admin/users/:id

---

## Roadmap Detalhado

### Sprint 1 (Semana 1-2)
- [ ] Setup Next.js + Drizzle + NeonDB
- [ ] Database schema Postgres
- [ ] Autenticacao (NextAuth.js)
- [ ] Layout principal (header, menu, footer)

### Sprint 2 (Semana 3-4)
- [ ] CRUD basico Empresas (backend + frontend)
- [ ] CRUD basico Ordens (backend + frontend)
- [ ] DataTable component reutilizavel
- [ ] Filtros e sort

### Sprint 3 (Semana 5-6)
- [ ] API /api/sync/import + /api/sync/export
- [ ] Dashboard com metricas
- [ ] Relatorios basicos
- [ ] Testes de API

### Sprint 4 (Semana 7-8)
- [ ] Polimento UI/UX
- [ ] Deploy em staging (Vercel)
- [ ] Testes manuais
- [ ] Documentacao de API

### Sprint 5 (Go Live)
- [ ] Deploy em producao
- [ ] Monitoramento e alertas
- [ ] Suporte inicial

---

## Tecnologias Especificas

### Frontend
- Next.js 16 (App Router)
- React 19
- TailwindCSS para estilos
- React Query para data fetching
- Zustand para estado global
- NextAuth.js para autenticacao

### Backend
- Next.js API Routes (ou separado com Express)
- Drizzle ORM (type-safe)
- Zod para validacao de schemas
- Pino para logging

### Database
- NeonDB (Postgres serverless)
- Migrations com Drizzle

### Deployment
- Vercel para frontend
- Neon para database
- Cloudflare R2 para storage (opcional, futuro para CSV exports)

### CI/CD
- GitHub Actions
- Testes automaticos pre-deploy

---

## Integracao Excel VBA

### Como Usuario Sincroniza
```
Excel:
1. Menu_Principal > "Sincronizar SaaS"
2. Form pede credenciais
3. Coleta dados em JSON
4. POST /api/sync/import
5. Mostra resultado

SaaS:
1. Dashboard atualiza
2. Usuarios veem dados novas
3. Podem criar ordens direto no SaaS
4. Ordens exportam de volta para Excel (futuro)
```

### Integracao Bidrecional (Futuro - Fase 2)
```
Excel → SaaS:
  Ordem criada em Excel
  Webhook POST a SaaS
  Dashboard atualiza em tempo real

SaaS → Excel:
  Usuario cria ordem no SaaS
  Webhook POST a Excel
  VBA importa automaticamente
```

---

## Pricing Model (Futuro)

- **Free**: 1 prefeitura, ate 100 empresas, relatorios basicos
- **Pro**: 1 prefeitura, ate 1000 empresas, relatorios avancados, API access
- **Enterprise**: Multiplas prefeituras, ilimitado, custom integrations, SLA

---

## Success Criteria para Fase 1

- [ ] Dashboard acessivel e responsivo
- [ ] Sincronizacao Excel ↔ SaaS funcional
- [ ] Testes de carga: 10k ordens, 1k empresas, performance OK
- [ ] Auditoria completa (todos acesso, mudancas loggadas)
- [ ] Documentacao de API para integradores
- [ ] 3 prefeituras em beta testando
- [ ] Zero erros criticos em producao por 2 semanas

---

**Data Alvo Conclusao**: Junho 2026
**Status Atual**: Em Planejamento (Pre-Fase 1)
