# Sistema de Credenciamento e Rodízio de Pequenos Reparos

> Repositório público source-available, auditável e orientado a evidência para
> gestão municipal de credenciamento, rodízio, Pré-OS, OS e avaliação de
> prestadores de pequenos reparos em Excel/VBA.

[![Release](https://img.shields.io/badge/release-V12.0.0205-blue)](obsidian-vault/releases/V12.0.0205.md)
[![Gate](https://img.shields.io/badge/gate-VR_20260521_182816-brightgreen)](auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260521_182816.csv)
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
2. revisar as regras em [docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md](docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md)
3. revisar a matriz de testes em [docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md](docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md)
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
- [obsidian-vault/releases/V12.0.0205.md](obsidian-vault/releases/V12.0.0205.md) — release note pública da versão oficial vigente
- [docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md](docs/tutorials/DOSSIE_RELEASE_V12_0_0205.md) — dossiê consolidado da V205
- [docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md](docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md) — jornada principal para operador, auditor ou testador validar pela interface do Excel
- [docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md](docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md) — liberar macros no Windows antes do teste
- [docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md](docs/how-to/COMO_RODAR_GATE_RELEASE_V205.md) — reproduzir o Gate de Validação de Release (RVS)
- [docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md](docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md) — regras de negócio que a release não pode violar
- [docs/reference/testes/NOMENCLATURA_BATERIAS_V205.md](docs/reference/testes/NOMENCLATURA_BATERIAS_V205.md) — crosswalk RVS/SRC/BRL
- [docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md](docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md) — matriz de cobertura da V205
- [auditoria/evidencias/V12.0.0205/INDEX.md](auditoria/evidencias/V12.0.0205/INDEX.md) — índice das evidências públicas V205
- [auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md](auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md) — roadmap de estabilização V205
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

Linha oficial: `V12.0.0205`

Build final validado no workbook: `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`

- compilação limpa validada por operador humano
- import V3 do delta V205 aprovado com `M=5 | F=0 | err=0 | skip=0`
- suíte adversarial UI aprovada em `TV2_20260521_182645` com `OK=12 | FALHA=0 | MANUAL=0`
- Gate RVS `VR_20260521_182816` aprovado com sintaxe `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- evidências públicas arquivadas em `auditoria/evidencias/V12.0.0205/`
- pacote humano de teste V205 atualizado para uso por interface: liberar macros, Central de Testes, Gate RVS, jornada humana e dossiê
- V12.0.0206 concentrará ajustes incrementais, pendências manuais, PDF automático e débitos técnicos pequenos; V12.0.0207 fica reservada para code review profundo, performance, componentização e preparação SaaS
