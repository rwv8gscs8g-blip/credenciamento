# Sistema de Credenciamento e Rodízio de Pequenos Reparos

> Repositório público source-available, auditável e orientado a evidência para
> gestão municipal de credenciamento, rodízio, Pre-OS, OS e avaliação de
> prestadores de pequenos reparos em Excel/VBA.

[![Release](https://img.shields.io/badge/release-V12.0.0202-blue)](obsidian-vault/releases/V12.0.0202.md)
[![Status](https://img.shields.io/badge/status-VALIDADO-brightgreen)](obsidian-vault/releases/STATUS-OFICIAL.md)
[![Licença](https://img.shields.io/badge/licenca-TPGL%20v1.1-6f42c1)](LICENSE)
[![Auditoria](https://img.shields.io/badge/auditoria-publica-0a7f5a)](auditoria/00_SUMARIO_EXECUTIVO.md)

Este repositório publica o código-fonte VBA vivo, a trilha de auditoria, a
matriz de testes e a documentação mínima de governança da linha oficial do
sistema. O foco é preservar leitura objetiva, rastreabilidade e capacidade de
auditoria externa.

## Posicionamento público

- **Licença pública:** TPGL v1.1
- **Modelo:** source-available e auditável
- **Conversão automática:** Apache License 2.0 após 4 anos de cada release
- **Contribuições públicas:** exigem aceite de `CLA.md`
- **Superfície pública:** código, testes, auditoria, releases e documentação viva

Este projeto **não** se apresenta como software livre ou open source sob a
definição da OSI. A abertura futura ocorre por conversão automática da licença
de cada release para Apache 2.0 na respectiva Data de Conversão.

## O que o sistema faz

- credenciamento de empresas por atividade
- gestão de entidades demandantes
- seleção automática por rodízio equitativo
- emissão de Pre-OS com aceite, recusa e expiração
- conversão de Pre-OS em OS
- avaliação com nota mínima, justificativa de divergência e suspensão automática
- relatórios e trilha de auditoria operacional
- bateria oficial e camada V2 de testes

## O que este repositório publica

- [src/vba](src/vba) — código VBA fonte
- [auditoria](auditoria) — auditorias e matriz de testes
- [docs/INDEX.md](docs/INDEX.md) — índice documental público
- [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md) — status oficial das versões
- [doc](doc) — dados estruturais de referência

O repositório **não** expõe como narrativa principal workflows internos,
sincronização local, upload, importação pessoal ou automações privadas.

## Uso do código

O repositório entrega o código-fonte VBA para leitura, auditoria e incorporação
nos fluxos de compilação/importação definidos por cada integrador. Não há
dependência pública de um instalador ou compilador específico deste repositório.

Integradores podem:

1. baixar o código em [src/vba](src/vba)
2. revisar as regras em [auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md](auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md)
3. revisar a matriz de testes em [auditoria/04_MATRIZ_MESTRE_DE_TESTES.md](auditoria/04_MATRIZ_MESTRE_DE_TESTES.md)
4. compilar/incorporar o VBA no processo que julgarem adequado

## Materiais operacionais complementares

O guia detalhado de importação do código-fonte e o vídeo tutorial operacional
não fazem parte da superfície pública deste repositório.

Esses materiais são fornecidos em canal controlado aos:

- contribuidores públicos com aceite rastreável de [CLA.md](CLA.md)
- municípios usuários formalmente vinculados ao projeto

O objetivo é preservar a pureza da árvore pública e separar documentação
operacional controlada da documentação institucional auditável.

## Leitura recomendada

- [docs/INDEX.md](docs/INDEX.md)
- [docs/ARQUITETURA.md](docs/ARQUITETURA.md)
- [docs/COMPLIANCE_CMMI_ISO.md](docs/COMPLIANCE_CMMI_ISO.md)
- [docs/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md](docs/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md)
- [SECURITY.md](SECURITY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md)
- [LICENSE](LICENSE)

## Créditos

- **Criação da Planilha**: Sergio Cintra
- **Atualização e Desenvolvimento**: Luís Maurício Junqueira Zanin

## Status atual

Linha oficial: `V12.0.0202`

- compilação limpa validada por operador humano
- bateria oficial recente sem falhas bloqueantes
- evidência pública da bateria oficial já publicada nesta linha
- evidência fresca da V2 ainda pendente para a auditoria externa final
- repositório em fase de consolidação documental para nova auditoria externa
