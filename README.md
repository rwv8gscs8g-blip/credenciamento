# Sistema de Credenciamento e Rodizio de Pequenos Reparos

Sistema Excel VBA (.xlsm) para gestao de credenciamento, rodizio e ordens de servico de empresas prestadoras em instalacoes publicas municipais. Funciona como porta de entrada e de saida do SaaS de rodizio de credenciamento da metodologia do Sebrae.

O sistema implementa controle rigoroso de seguranca, compliance e validacao automatizada. Municipios que adotarem o sistema terao acesso ao codigo-fonte completo para auditoria e validacao independente.

## Funcionalidades

- Credenciamento de empresas prestadoras de servico com rodizio equitativo
- Gestao de entidades demandantes (escolas, centros de saude, unidades administrativas)
- Catalogo de atividades por CNAE (612 atividades oficiais IBGE)
- Cadastro de servicos por atividade com valores e horarios
- Emissao de Pre-Ordens de Servico com selecao automatica por rodizio
- Gestao completa de Ordens de Servico (emissao, execucao, fechamento)
- Avaliacao pos-servico com nota minima configuravel e suspensao automatica
- Relatorios profissionais com acentuacao, municipio e timestamp
- Auditoria completa de eventos com rastreabilidade total
- Central de Testes integrada com 200+ cenarios automatizados
- Dashboard RESULTADO_QA ao vivo com contadores e visualizacao em tempo real

## Seguranca e Compliance

- Codigo-fonte aberto e auditavel no GitHub
- Bateria automatizada de testes com relatorio detalhado
- Protecao de abas com senhas configuradas por aba
- Audit log de todas as operacoes criticas
- Validacao de dados em todos os formularios de entrada
- Anti-regressao: checklist de verificacao em cada release

## Estrutura do Repositorio

```
vba_export/            Codigo-fonte VBA — FONTE DE VERDADE
vba_import/            Artefato de deploy (copia para importacao no VBA Editor)
obsidian-vault/        Documentacao centralizada (Obsidian vault)
  00-DASHBOARD.md      Ponto de entrada para IAs e humanos
  ai/                  Governanca IA, regras, prompts, estado atual
  releases/            Release notes de cada versao
  backlog/             Tarefas pendentes
  historico/           Decisoes e artefatos arquivados
doc/                   Dados estruturais (CSVs CNAE, fontes IBGE)
```

## Como usar

1. Baixe o release mais recente (.xlsm) da aba Releases
2. Abra no Microsoft Excel (2019/2021/365) com macros habilitadas
3. O menu principal aparecera automaticamente
4. Configure o municipio e gestor em Config. Inicial

## Documentacao

A documentacao completa esta em `obsidian-vault/`. Abra a pasta no Obsidian para navegacao com backlinks, ou leia os arquivos .md diretamente.

Ponto de entrada: `obsidian-vault/00-DASHBOARD.md`

## Para desenvolvedores / IAs

Leia obrigatoriamente antes de modificar qualquer codigo:
1. `obsidian-vault/ai/REGRAS.md` — Regras inviolaveis
2. `obsidian-vault/ai/PIPELINE.md` — Ciclo de iteracao
3. `obsidian-vault/ai/ESTADO-ATUAL.md` — Versao e status
4. `obsidian-vault/ai/GOVERNANCA.md` — Rastreabilidade de autoria
5. `obsidian-vault/ai/prompt-iteracao-segura.md` — Processo de iteracao anti-regressao

## Creditos

- **Criacao da Planilha**: Sergio Cintra
- **Atualizacao e Desenvolvimento**: Luis Mauricio Junqueira Zanin

## Licenca

Codigo-fonte aberto e auditavel. A planilha e ferramenta autonoma gratuita, disponibilizada aos municipios para validacao e uso. O SaaS associado (maiscompralocal-core) e servico separado por assinatura.

## Versao

V12.0.0149 — Relatorios profissionais, dashboard QA, rodizio fix, iteracao segura
