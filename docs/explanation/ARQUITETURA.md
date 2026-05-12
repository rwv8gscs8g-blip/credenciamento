---
titulo: Arquitetura do Sistema V204
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Arquitetura do Sistema V204

## Visão geral

O sistema é um núcleo Excel/VBA organizado em camadas lógicas, com foco em:

- regras de negócio explícitas;
- rastreabilidade por auditoria;
- testes incrementais;
- evolução controlada por release;
- validação humana por interface, sem exigir Editor VBA do testador final.

## Camadas principais

### 1. Interface e operação

Formulários e módulos de orquestração visual:

- `Menu_Principal.frm`
- `Credencia_Empresa.frm`
- `Cadastro_Servico.frm`
- `Altera_*`, `Reativa_*`, `Rel_*`
- `Central_Testes*`

Responsabilidade:

- receber entrada do operador;
- acionar serviços;
- apresentar resultados;
- apoiar homologação assistida.

### 2. Serviços (`Svc_*`)

Módulos de regra de negócio e fluxo transacional:

- `Svc_PreOS.bas`
- `Svc_OS.bas`
- `Svc_Avaliacao.bas`
- `Svc_Rodizio.bas`
- `Svc_Transacao.bas`

Responsabilidade:

- aplicar validações de negócio;
- controlar transições de estado;
- acionar repositórios;
- registrar eventos críticos.

### 3. Repositórios (`Repo_*`)

Módulos de persistência sobre planilhas:

- `Repo_Credenciamento.bas`
- `Repo_PreOS.bas`
- `Repo_OS.bas`
- `Repo_Avaliacao.bas`
- `Repo_Empresa.bas`

Responsabilidade:

- ler e escrever nas abas estruturais;
- encapsular detalhes de coluna, linha e mapeamento;
- reduzir acoplamento entre regra e planilha.

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

- tipos e contratos;
- colunas, IDs e utilidades;
- proteção de abas e helpers operacionais;
- metadados de release.

### 5. Testes

Camadas de validação pública:

- `Teste_Bateria_Oficial.bas`
- `Teste_V2_Engine.bas`
- `Teste_V2_Roteiros.bas`
- `Teste_UI_Guiado.bas`
- `Teste_Validacao_Release.bas`
- `Central_Testes_Relatorio.bas`

Responsabilidade:

- regressão principal;
- baseline determinística;
- smoke/stress/assistido;
- evidência operacional;
- validação completa de release pela interface.

## Fluxo típico

1. a interface captura a intenção do operador;
2. o serviço valida a regra de negócio;
3. o repositório persiste em abas operacionais;
4. a auditoria registra evento crítico;
5. a bateria oficial e a camada V2 validam regressão;
6. o testador humano confirma os fluxos críticos pela interface.

## Fronteiras importantes

- o repositório público publica o **código-fonte VBA**, a documentação e as
  evidências;
- o `.xlsm` operacional validado é o artefato distribuído por canal próprio;
- a proteção de abas e do VBE é medida operacional, não controle criptográfico
  forte;
- a pasta `doc/` contém dados CNAE usados pela planilha, enquanto `docs/`
  contém documentação pública.

## Estado atual

A `V12.0.0204` é a linha pública vigente para:

- compilação limpa validada por operador humano;
- build `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`;
- gate `VR_20260511_175849` aprovado após App_Release final;
- guia humano por interface;
- regras de negócio e matriz de cobertura publicadas.

A próxima linha planejada é `V12.0.0205`, com foco em melhoria de nomenclatura
dos testes, simplificação da Central de Testes e novas evoluções funcionais.
