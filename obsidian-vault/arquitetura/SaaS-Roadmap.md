# Roadmap: Planilha VBA para SaaS

Relacionado: [[Visao-Geral]], [[SaaS-Fase1]], [[Fluxos-de-Negocio]]

---

## Visao Estrategica

A planilha Excel e o SaaS sao dois frontends para o MESMO dominio de negocio. A planilha e codigo aberto e serve como ferramenta autonoma para prefeituras que preferem Excel. O SaaS (maiscompralocal-core) e um servico pago por assinatura com interface web moderna, multi-tenant, com seguranca e navegabilidade de padrao corporativo.

**Principio fundamental:** Os dados fluem nos dois sentidos. O usuario pode migrar da planilha para o SaaS e voltar para a planilha a qualquer momento, sem perda de dados.

---

## Stack do SaaS

- **Framework:** Next.js 16 (App Router, React Server Components)
- **Banco:** NeonDB (Serverless Postgres) via Drizzle ORM
- **Storage:** Cloudflare R2 (S3-compatible)
- **Email:** Resend
- **Auth:** JWT via jose + SSO municipal
- **Deploy:** Vercel
- **Repo:** /Users/macbookpro/Projetos/maiscompralocal-core

---

## Mapeamento de Dados: Excel para SaaS

| Aba Excel | Tabela Postgres | Notas |
|-----------|-----------------|-------|
| EMPRESAS | empresas | CNPJ, razao_social, status_global, contato |
| EMPRESAS_INATIVAS | empresas (status='INATIVA') | Mesma tabela, filtro por status |
| ENTIDADE | entidades | Ate 3 contatos por entidade |
| ENTIDADE_INATIVOS | entidades (deleted_at != null) | Soft-delete |
| ATIVIDADES | atividades | CNAE + descricao |
| CAD_SERV | servicos | FK para atividades |
| CREDENCIADOS | credenciamentos | Posicao na fila, status |
| PRE_OS | pre_ordens_servico | Status, datas, valores |
| CAD_OS | ordens_servico | Notas de avaliacao integradas |
| AUDIT_LOG | audit_log | Append-only, dados_antes/depois em JSON |
| CONFIG | Configuracao por tenant | DIAS_DECISAO, MAX_RECUSAS, etc. |

---

## API de Integracao

### Importacao: Planilha para SaaS

```
POST /api/import/excel
Content-Type: multipart/form-data
Body: file=planilha.xlsm

Resposta: { imported: { empresas: 45, entidades: 12, ... }, errors: [] }
```

O backend:
1. Le o .xlsm via biblioteca de parsing (SheetJS ou similar)
2. Valida dados contra schema Drizzle
3. Insere no Postgres com tenant_id do usuario
4. Gera relatorio de importacao

### Exportacao: SaaS para Planilha

```
GET /api/export/excel?tenant_id=xxx

Resposta: arquivo .xlsm com dados do tenant
```

O backend:
1. Consulta todas as tabelas do tenant
2. Gera .xlsm com abas correspondentes
3. Inclui formatacao padrao
4. NAO inclui codigo VBA (usuario baixa e adiciona macros se quiser)

---

## Diferencas de Interface

| Aspecto | Planilha | SaaS |
|---------|----------|------|
| Interface | Forms VBA (metodologia fixa) | Web moderna (padrao de excelencia) |
| Multi-usuario | Nao (arquivo local) | Sim (multi-tenant) |
| Seguranca | Senha simples nas abas | JWT + SSO + audit trail |
| Mobilidade | Apenas desktop | Responsivo |
| Custo | Gratuito (open source) | Assinatura mensal |

**Regra:** A interface da planilha NAO muda porque ha uma metodologia associada. O SaaS e livre para ter UX completamente diferente.

---

## Fases do SaaS

### Fase 1 — Infraestrutura (ja iniciada)
- Schema Drizzle ja escrito
- Login geografico (mapa MT)
- OCR mock para CNPJ
- Suite QA corporativa

### Fase 2 — CRUD Core
- Empresas, Entidades, Servicos
- Rodizio automatico
- Pre-OS e OS

### Fase 3 — Integracao
- Import/Export Excel
- Relatorios PDF
- Notificacoes por email

### Fase 4 — Producao
- Multi-tenant real
- Certificado digital (ICP-Brasil)
- Auditoria completa
