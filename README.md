# Sistema de Credenciamento e Rodizio de Pequenos Reparos

> Repositorio publico source-available, auditavel e orientado a evidencia para
> gestao municipal de credenciamento, rodizio, Pre-OS, OS e avaliacao de
> prestadores de pequenos reparos em Excel/VBA.

[![Release](https://img.shields.io/badge/release-V12.0.0202-blue)](obsidian-vault/releases/V12.0.0202.md)
[![Status](https://img.shields.io/badge/status-VALIDADO-brightgreen)](obsidian-vault/releases/STATUS-OFICIAL.md)
[![Licenca](https://img.shields.io/badge/licenca-TPGL%20v1.1-6f42c1)](LICENSE)
[![Auditoria](https://img.shields.io/badge/auditoria-publica-0a7f5a)](auditoria/00_SUMARIO_EXECUTIVO.md)

Este repositorio publica o codigo-fonte VBA vivo, a trilha de auditoria, a
matriz de testes e a documentacao minima de governanca da linha oficial do
sistema. O foco e preservar leitura objetiva, rastreabilidade e capacidade de
auditoria externa.

## Posicionamento publico

- **Licenca publica:** TPGL v1.1
- **Modelo:** source-available e auditavel
- **Conversao automatica:** Apache License 2.0 apos 4 anos de cada release
- **Contribuicoes publicas:** exigem aceite de `CLA.md`
- **Superficie publica:** codigo, testes, auditoria, releases e documentacao viva

Este projeto **nao** se apresenta como software livre ou open source sob a
definicao da OSI. A abertura futura ocorre por conversao automatica da licenca
de cada release para Apache 2.0 na respectiva Data de Conversao.

## O que o sistema faz

- credenciamento de empresas por atividade
- gestao de entidades demandantes
- selecao automatica por rodizio equitativo
- emissao de Pre-OS com aceite, recusa e expiracao
- conversao de Pre-OS em OS
- avaliacao com nota minima, justificativa de divergencia e suspensao automatica
- relatorios e trilha de auditoria operacional
- bateria oficial e camada V2 de testes

## O que este repositorio publica

- [src/vba](src/vba) — codigo VBA fonte
- [auditoria](auditoria) — auditorias e matriz de testes
- [docs/INDEX.md](docs/INDEX.md) — indice documental publico
- [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md) — status oficial das versoes
- [doc](doc) — dados estruturais de referencia

O repositorio **nao** expõe como narrativa principal workflows internos,
sincronizacao local, upload, importacao pessoal ou automacoes privadas.

## Uso do codigo

O repositorio entrega o codigo-fonte VBA para leitura, auditoria e incorporacao
nos fluxos de compilacao/importacao definidos por cada integrador. Nao ha
dependencia publica de um instalador ou compilador especifico deste repositorio.

Integradores podem:

1. baixar o codigo em [src/vba](src/vba)
2. revisar as regras em [auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md](auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md)
3. revisar a matriz de testes em [auditoria/04_MATRIZ_MESTRE_DE_TESTES.md](auditoria/04_MATRIZ_MESTRE_DE_TESTES.md)
4. compilar/incorporar o VBA no processo que julgarem adequado

## Leitura recomendada

- [docs/INDEX.md](docs/INDEX.md)
- [docs/ARQUITETURA.md](docs/ARQUITETURA.md)
- [docs/COMPLIANCE_CMMI_ISO.md](docs/COMPLIANCE_CMMI_ISO.md)
- [SECURITY.md](SECURITY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md)
- [LICENSE](LICENSE)

## Creditos

- **Criacao da Planilha**: Sergio Cintra
- **Atualizacao e Desenvolvimento**: Luis Mauricio Junqueira Zanin

## Status atual

Linha oficial: `V12.0.0202`

- compilacao limpa validada por operador humano
- bateria oficial recente sem falhas bloqueantes
- repositorio em fase de consolidacao documental para nova auditoria externa
