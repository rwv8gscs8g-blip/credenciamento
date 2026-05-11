# Sistema de Credenciamento e Rodízio de Pequenos Reparos

> Repositório público source-available, auditável e orientado a evidência para
> gestão municipal de credenciamento, rodízio, Pre-OS, OS e avaliação de
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
2. revisar as regras em [auditoria/01_regras_e_governanca/03_AUDITORIA_REGRAS_DE_NEGOCIO.md](auditoria/01_regras_e_governanca/03_AUDITORIA_REGRAS_DE_NEGOCIO.md)
3. revisar a matriz de testes em [auditoria/01_regras_e_governanca/04_MATRIZ_MESTRE_DE_TESTES.md](auditoria/01_regras_e_governanca/04_MATRIZ_MESTRE_DE_TESTES.md)
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

### Para humanos

- [docs/INDEX.md](docs/INDEX.md) — indice publico Diataxis-aware
- [obsidian-vault/releases/V12.0.0204.md](obsidian-vault/releases/V12.0.0204.md) — release note publica da versao oficial vigente
- [docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md](docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md) — liberar macros no Windows antes do teste
- [docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md](docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md) — reproduzir o gate automatizado da V204
- [docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md](docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md) — roteiro humano de homologacao da V204
- [docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md) — cobertura das regras de negocio da V204
- [docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md) — matriz de rastreabilidade da V204
- [auditoria/03_ondas/onda_25_v204_release_candidate/10_FECHAMENTO_MICRO54_PUBLICACAO_V204.md](auditoria/03_ondas/onda_25_v204_release_candidate/10_FECHAMENTO_MICRO54_PUBLICACAO_V204.md) — fechamento de publicacao V204
- [docs/explanation/ARQUITETURA.md](docs/explanation/ARQUITETURA.md)
- [docs/reference/COMPLIANCE_CMMI_ISO.md](docs/reference/COMPLIANCE_CMMI_ISO.md)
- [docs/how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md](docs/how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md)
- [obsidian-vault/00-DASHBOARD.md](obsidian-vault/00-DASHBOARD.md) — dashboard executivo
- [SECURITY.md](SECURITY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CLA.md](CLA.md)
- [LICENSE](LICENSE)

### Para IAs

- [AGENTS.md](AGENTS.md) — entrada canonica (padrao [agents.md](https://agents.md/))
- [llms.txt](llms.txt) — mapa curado para LLMs (padrao [llmstxt.org](https://llmstxt.org/))
- [llms-full.txt](llms-full.txt) — indice exaustivo
- [.hbn/relay/INDEX.md](.hbn/relay/INDEX.md) — bastao + ciclo ativo (HBN)
- [.hbn/knowledge/0001-regras-v203-inegociaveis.md](.hbn/knowledge/0001-regras-v203-inegociaveis.md) — 10 regras V203

## Metodologia

Este projeto adotou em 28/04/2026 a metodologia hibrida composta por:

| Protocolo | Papel |
|---|---|
| [HBN](https://usehbn.org) | core de coordenacao inter-IA (relay, readback, hearback, truth barrier) |
| [Diataxis](https://diataxis.fr/) | docs/ para humanos (4 quadrantes) |
| [llms.txt](https://llmstxt.org/) | docs/ para LLMs (mapa curado) |
| [agents.md](https://agents.md/) | contrato unificado de agentes |
| Glasswing-style preventive | seguranca preventiva (5 vetores domain-specific) |

Detalhes em [obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md](obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md).
Este projeto e o primeiro [case study](https://github.com/...) production-scale do `usehbn`.

## Créditos

- **Criação da Planilha**: Sergio Cintra
- **Atualização e Desenvolvimento**: Luís Maurício Junqueira Zanin

## Status atual

Linha oficial: `V12.0.0204`

Build final validado no workbook: `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`

- compilacao limpa validada por operador humano
- teste manual final validado por operador humano
- Smoke V2 `TV2_20260511_131824` com `OK=34 | FALHA=0 | MANUAL=4`
- gate consolidado `VR_20260511_154433` aprovado para publicacao e gate adicional `VR_20260511_175849` aprovado apos App_Release final, ambos com sintaxe `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- evidencias publicas arquivadas em `auditoria/evidencias/V12.0.0204/`
- pacote humano de teste V204 atualizado com liberacao de macros, Sexteto e roteiro manual
- V12.0.0205 abrira a proxima etapa com auditoria cruzada, melhoria de nomenclatura da taxonomia de testes e lista mestra de evolucoes
