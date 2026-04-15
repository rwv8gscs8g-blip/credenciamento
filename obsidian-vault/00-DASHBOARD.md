---
titulo: Dashboard - Credenciamento
ultima-atualizacao: 2026-04-14
autor-ultima-alteracao: GPT-5.2 (Cursor)
tags: [vivo]
versao-sistema: V12.0.0163
---

# Dashboard - Credenciamento

## Status Atual

**Versao**: V12.0.0163
**Data**: 2026-04-14
**Status**: EM_VALIDACAO (relatorios profissionais, dashboard QA, rodizio fix)
**Ambiente**: Windows 10+, Excel 2019/2021/365
**Planilha**: PlanilhaCredenciamento-Homologacao.xlsm

## Para IAs — Leitura Obrigatoria

1. **[[ai/REGRAS]]** — Regras inviolaveis (killers, formato CNAE, protecao)
2. **[[ai/PIPELINE]]** — Ciclo de iteracao (auditar > editar > versionar > compilar)
3. **[[ai/ESTADO-ATUAL]]** — O que funciona, o que precisa de validacao
4. **[[ai/GOVERNANCA]]** — Tabela de autoria por release
5. **[[ai/bastao/INDICE]]** — Sistema de bastao (ler ao assumir)
6. **[[ai/handoffs/]]** — Handoff especifico por IA

## Checklist de Funcionalidades

### Nucleo do Sistema (Estavel)
- [x] Autenticacao e Contexto (AppContext)
- [x] Auditoria centralizada (Audit_Log)
- [x] Tratamento de erros (ErrorBoundary)
- [x] Carregamento automatico (Auto_Open)
- [x] Release metadata centralizada (App_Release)

### Gestao de Credenciamento
- [x] Cadastro de empresas (Credencia_Empresa)
- [x] Alteracao de dados (Altera_Empresa)
- [x] Reativacao de empresas (Reativa_Empresa)
- [x] Gestao de entidades (Altera_Entidade, Reativa_Entidade)
- [x] Filtros de busca (empresas, entidades)
- [x] Importacao de CNAEs (612 atividades via ImportarCNAE_Emergencia)
- [x] Cadastro de servicos com edicao (CAD_SERV, Alterar Dados)
- [ ] Validacao de lista de servicos (SV_Lista sem duplicatas)

### Rodizio e Ordens de Servico
- [x] Rodizio de empresas (Svc_Rodizio) — pendente validacao com dados
- [x] Criacao de pre-ordens (Svc_PreOS)
- [x] Processamento de ordens (Svc_OS)
- [x] Avaliacao de servicos (Svc_Avaliacao)
- [ ] Fluxo completo: Empresa > Atividade > Servico > Rodizio > OS

### Relatorios
- [x] Relatorio de empresas por servico (Rel_Emp_Serv)
- [x] Relatorio de ordens por empresa (Rel_OSEmpresa)
- [x] Central de testes com cobertura (Central_Testes_Relatorio)

### Roadmap SaaS (Next.js + NeonDB)
- [ ] Autenticacao multi-tenant (Prefeituras)
- [ ] Sincronizacao Excel <> SaaS
- [ ] Dashboard web de gestao

## Estrutura do Repositorio

```
credenciamento/
├── vba_export/            Codigo-fonte VBA (fonte de verdade)
├── vba_import/            Artefato de deploy
├── obsidian-vault/        Documentacao centralizada
│   ├── 00-DASHBOARD.md    Este arquivo
│   ├── 01-CONTEXTO-IA.md  Contexto completo
│   ├── ai/                Governanca IA
│   │   ├── REGRAS.md
│   │   ├── PIPELINE.md
│   │   ├── ESTADO-ATUAL.md
│   │   ├── GOVERNANCA.md
│   │   ├── known-issues.md
│   │   ├── bastao/        Documentos da IA com o bastao
│   │   └── handoffs/      1 arquivo por IA
│   ├── releases/          Release notes (V10 a V145+)
│   ├── backlog/           Tarefas pendentes
│   └── historico/         Decisoes e artefatos arquivados
├── doc/                   Dados estruturais (CSVs, JSONs)
├── .cursorrules           Ponteiro para vault
└── README.md              Ponto de entrada do repo
```

## Navegacao Rapida

### Historico e Decisoes
- **[[historico/Decisoes-Arquiteturais]]** — Decisoes de design
- **[[historico/Bug-Nome-Repetido-TConfig]]** — Bug dos colon patterns
- **[[historico/Colon-Patterns]]** — Padrao mortifero detectado

### Backlog
- **[[backlog/CNAE-Import]]** — Importacao de CNAEs
- **[[backlog/Filtros-Busca-Forms]]** — Filtros de busca
- **[[backlog/Impressao-Relatorios]]** — Relatorios
- **[[backlog/SaaS-Fase1]]** — Fase 1 do SaaS

---
**Ultima Verificacao**: 2026-04-12
**Mantido por**: Mauricio Zanin + Time IA
