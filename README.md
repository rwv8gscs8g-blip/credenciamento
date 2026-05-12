# Sistema de Credenciamento e Rodízio de Pequenos Reparos

> Repositório público source-available, auditável e orientado a evidência para
> gestão municipal de credenciamento, rodízio, Pré-OS, OS e avaliação de
> prestadores de pequenos reparos em Excel/VBA.

[![Release](https://img.shields.io/badge/release-V12.0.0204-blue)](obsidian-vault/releases/V12.0.0204.md)
[![Gate](https://img.shields.io/badge/gate-VR_20260511_175849-brightgreen)](auditoria/evidencias/V12.0.0204/ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_175849.csv)
[![Status](https://img.shields.io/badge/status-VALIDADO-brightgreen)](obsidian-vault/releases/STATUS-OFICIAL.md)
[![Licença](https://img.shields.io/badge/licenca-TPGL%20v1.1-6f42c1)](LICENSE)
[![Auditoria](https://img.shields.io/badge/auditoria-publica-0a7f5a)](auditoria/00_status/00_SUMARIO_EXECUTIVO.md)

Este repositório publica o código-fonte VBA vivo, a trilha de auditoria, a
matriz de testes e a documentação mínima de governança da linha oficial do
sistema. O foco é preservar leitura objetiva, rastreabilidade e capacidade de
auditoria externa.

Também mantém uma checagem automatizada de coerência entre:

- versão declarada no código
- status oficial publicado
- release note vigente
- tag da release
- pacote público de evidências

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
- emissão de Pré-OS com aceite, recusa e expiração
- conversão de Pré-OS em OS
- avaliação com nota mínima, justificativa de divergência e suspensão automática
- relatórios e trilha de auditoria operacional
- bateria oficial e camada V2 de testes

## O que este repositório publica

- [src/vba](src/vba) — código VBA fonte
- [auditoria](auditoria) — auditorias, evidências e matriz de testes
- [docs/INDEX.md](docs/INDEX.md) — índice documental público
- [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md) — status oficial das versões
- [doc](doc) — dados CNAE estruturais usados pela planilha; não é a pasta de documentação

O repositório **não** expõe como narrativa principal workflows internos,
sincronização local, upload, importação pessoal ou automações privadas.

## Uso do código

O repositório entrega o código-fonte VBA para leitura, auditoria e incorporação
nos fluxos de compilação/importação definidos por cada integrador. Não há
dependência pública de um instalador ou compilador específico deste repositório.

Integradores podem:

1. baixar o código em [src/vba](src/vba)
2. revisar as regras em [docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md](docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md)
3. revisar a matriz de testes em [docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md)
4. compilar/incorporar o VBA no processo que julgarem adequado

## Materiais operacionais complementares

O guia detalhado de importação do código-fonte e o vídeo tutorial operacional
não fazem parte da superfície pública principal deste repositório.

Esses materiais são fornecidos em canal controlado aos:

- contribuidores públicos com aceite rastreável de [CLA.md](CLA.md)
- municípios usuários formalmente vinculados ao projeto

O objetivo é preservar a pureza da árvore pública e separar documentação
operacional controlada da documentação institucional auditável.

## Leitura recomendada

### Para humanos

- [docs/INDEX.md](docs/INDEX.md) — índice público Diataxis-aware
- [obsidian-vault/releases/V12.0.0204.md](obsidian-vault/releases/V12.0.0204.md) — release note pública da versão oficial vigente
- [docs/tutorials/PROTOCOLO_HOMOLOGACAO_HUMANA_V12_0_0204.docx](docs/tutorials/PROTOCOLO_HOMOLOGACAO_HUMANA_V12_0_0204.docx) — protocolo completo aprovado para homologação humana externa da V204
- [docs/tutorials/GUIA_TESTES_HUMANOS_V204.md](docs/tutorials/GUIA_TESTES_HUMANOS_V204.md) — guia principal para testador humano validar pela interface do Excel
- [docs/tutorials/GUIA_TESTES_HUMANOS_V204.docx](docs/tutorials/GUIA_TESTES_HUMANOS_V204.docx) — guia Word para encaminhar com a planilha ao testador humano
- [docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md](docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md) — liberar macros no Windows antes do teste
- [docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md](docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md) — reproduzir o gate automatizado da V204 pela Central de Testes
- [docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md](docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md) — regras de negócio que a release não pode violar
- [docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md](docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md) — roteiro humano de homologação da V204
- [docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md) — cobertura das regras de negócio da V204
- [docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md) — matriz de rastreabilidade da V204
- [auditoria/evidencias/V12.0.0204/INDEX.md](auditoria/evidencias/V12.0.0204/INDEX.md) — índice das evidências públicas V204
- [auditoria/03_ondas/onda_25_v204_release_candidate/10_FECHAMENTO_MICRO54_PUBLICACAO_V204.md](auditoria/03_ondas/onda_25_v204_release_candidate/10_FECHAMENTO_MICRO54_PUBLICACAO_V204.md) — fechamento de publicação V204
- [docs/explanation/ARQUITETURA.md](docs/explanation/ARQUITETURA.md)
- [docs/reference/COMPLIANCE_CMMI_ISO.md](docs/reference/COMPLIANCE_CMMI_ISO.md)
- [docs/how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md](docs/how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md)
- [obsidian-vault/00-DASHBOARD.md](obsidian-vault/00-DASHBOARD.md) — dashboard executivo
- [SECURITY.md](SECURITY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md)
- [LICENSE](LICENSE)

### Para IAs

- [AGENTS.md](AGENTS.md) — entrada canônica (padrão [agents.md](https://agents.md/))
- [llms.txt](llms.txt) — mapa curado para LLMs (padrão [llmstxt.org](https://llmstxt.org/))
- [llms-full.txt](llms-full.txt) — índice exaustivo
- [.hbn/relay/INDEX.md](.hbn/relay/INDEX.md) — bastão + ciclo ativo (HBN)
- [.hbn/knowledge/0001-regras-v203-inegociaveis.md](.hbn/knowledge/0001-regras-v203-inegociaveis.md) — regras operacionais históricas ainda aplicáveis até consolidação V205

## Metodologia

Este projeto adotou em 28/04/2026 a metodologia híbrida composta por:

| Protocolo | Papel |
|---|---|
| [HBN](https://usehbn.org) | core de coordenação inter-IA (relay, readback, hearback, truth barrier) |
| [Diataxis](https://diataxis.fr/) | `docs/` para humanos |
| [llms.txt](https://llmstxt.org/) | docs para LLMs |
| [agents.md](https://agents.md/) | contrato unificado de agentes |
| Glasswing-style preventive | segurança preventiva domain-specific |

Detalhes em [obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md](obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md).
Este projeto é o primeiro case study production-scale do `usehbn`.

## Créditos

- **Criação da Planilha**: Sergio Cintra
- **Atualização e Desenvolvimento**: Luís Maurício Junqueira Zanin

## Status atual

Linha oficial: `V12.0.0204`

Build final validado no workbook: `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`

- compilação limpa validada por operador humano
- teste manual final validado por operador humano
- Smoke V2 `TV2_20260511_131824` com `OK=34 | FALHA=0 | MANUAL=4`
- gate consolidado `VR_20260511_154433` aprovado para publicação e gate adicional `VR_20260511_175849` aprovado após App_Release final, ambos com sintaxe `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- evidências públicas arquivadas em `auditoria/evidencias/V12.0.0204/`
- pacote humano de teste V204 atualizado para uso por interface: liberar macros, botão Central de Testes, Sexteto e roteiro manual
- V12.0.0205 abrirá a próxima etapa com auditoria cruzada, melhoria de nomenclatura da taxonomia de testes e lista mestra de evoluções
