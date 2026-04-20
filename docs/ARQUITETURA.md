# Arquitetura do Sistema

## Visão geral

O sistema é um núcleo Excel/VBA organizado em camadas lógicas, com foco em:

- regras de negócio explícitas
- rastreabilidade por auditoria
- testes incrementais
- evolução controlada por release

## Camadas principais

### 1. Interface e operação

Formulários e módulos de orquestração visual:

- `Menu_Principal.frm`
- `Credencia_Empresa.frm`
- `Cadastro_Servico.frm`
- `Altera_*`, `Reativa_*`, `Rel_*`
- `Central_Testes*`

Responsabilidade:

- receber entrada do operador
- acionar serviços
- apresentar resultados
- apoiar homologação assistida

### 2. Serviços (`Svc_*`)

Módulos de regra de negócio e fluxo transacional:

- `Svc_PreOS.bas`
- `Svc_OS.bas`
- `Svc_Avaliacao.bas`
- `Svc_Rodizio.bas`
- `Svc_Transacao.bas`

Responsabilidade:

- aplicar validações de negócio
- controlar transições de estado
- acionar repositórios
- registrar eventos críticos

### 3. Repositórios (`Repo_*`)

Módulos de persistência sobre planilhas:

- `Repo_Credenciamento.bas`
- `Repo_PreOS.bas`
- `Repo_OS.bas`
- `Repo_Avaliacao.bas`
- `Repo_Empresa.bas`

Responsabilidade:

- ler e escrever nas abas estruturais
- encapsular detalhes de coluna, linha e mapeamento
- reduzir acoplamento entre regra e planilha

### 4. Utilitários e tipos

Base técnica compartilhada:

- `Mod_Types.bas`
- `Const_Colunas.bas`
- `Util_*`
- `Funcoes.bas`
- `ErrorBoundary.bas`
- `Audit_Log.bas`
- `AppContext.bas`
- `App_Release.bas`

Responsabilidade:

- tipos e contratos
- colunas, IDs e utilidades
- proteção de abas e helpers operacionais
- metadados de release

### 5. Testes

Camadas de validação pública:

- `Teste_Bateria_Oficial.bas`
- `Teste_V2_Engine.bas`
- `Teste_V2_Roteiros.bas`
- `Teste_UI_Guiado.bas`
- `Central_Testes_Relatorio.bas`

Responsabilidade:

- regressão principal
- baseline determinística
- smoke/stress/assistido
- evidência operacional

## Fluxo típico

1. interface captura a intenção do operador
2. serviço valida regra de negócio
3. repositório persiste em abas operacionais
4. auditoria registra evento crítico
5. bateria oficial e V2 validam regressão

## Fronteiras importantes

- o repositório público publica o **código-fonte VBA**, não um processo único de build/import
- o `.xlsm` operacional não é a narrativa principal do repositório público
- a proteção de abas existe como medida operacional, não como controle criptográfico forte

## Estado atual

A `V12.0.0202` é a linha pública estável vigente para:

- compilação limpa
- bateria oficial verde
- consolidação documental
- preparação de nova auditoria externa
