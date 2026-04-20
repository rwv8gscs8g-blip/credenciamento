# Sistema de Credenciamento e Rodizio de Pequenos Reparos

Sistema Excel VBA (.xlsm) para gestao de credenciamento, rodizio e ordens de servico de empresas prestadoras em instalacoes publicas municipais. Funciona como porta de entrada e de saida do SaaS de rodizio de credenciamento da metodologia do Sebrae.

O foco deste repositorio e manter a versao oficial do codigo VBA, a estrategia de testes, a trilha de auditoria e a evolucao progressiva dos procedimentos. A intencao e oferecer leitura objetiva, codigo auditavel e historico tecnico consistente.

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
- Protecao de abas com senha centralizada e nao exposta em texto literal no repositorio
- Audit log de todas as operacoes criticas
- Validacao de dados em todos os formularios de entrada
- Anti-regressao: checklist de verificacao em cada release

## Estrutura Logica

- `src/vba/` — codigo VBA fonte do sistema
- `auditoria/` — auditorias publicas e matriz de testes
- `obsidian-vault/releases/` — status oficial e release validada atual
- `doc/` — dados estruturais de apoio

## Como usar

1. Baixe o release mais recente (.xlsm) da aba Releases
2. Abra no Microsoft Excel (2019/2021/365) com macros habilitadas
3. O menu principal aparecera automaticamente
4. Configure o municipio e gestor em Config. Inicial

## Documentacao

A documentacao canônica para leitura do projeto esta concentrada em:

- `auditoria/` — auditorias, matriz mestre de testes e cobertura
- `src/vba/` — codigo VBA puro para leitura e compilacao
- `obsidian-vault/releases/STATUS-OFICIAL.md` — situacao oficial das versoes
- `obsidian-vault/releases/` — notas de release
- `doc/` — dados de referencia

O material operacional de IA e automacao interna nao faz parte da superficie publica recomendada do projeto.

## Creditos

- **Criacao da Planilha**: Sergio Cintra
- **Atualizacao e Desenvolvimento**: Luis Mauricio Junqueira Zanin

## Licenca

Codigo-fonte aberto e auditavel. A planilha e ferramenta autonoma gratuita, disponibilizada aos municipios para validacao e uso. O SaaS associado (maiscompralocal-core) e servico separado por assinatura.

## Versao

V12.0.0202 — Estabilizacao tecnica validada com compilacao limpa e bateria oficial verde
