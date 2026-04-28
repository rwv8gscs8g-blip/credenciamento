---
titulo: Indice publico de documentacao
ultima-atualizacao: 2026-04-28
diataxis: reference
hbn-track: fast_track
audiencia: ambos
versao-sistema: V12.0.0203
---

# Indice Publico (Diataxis-aware)

Este indice usa o framework [Diataxis](https://diataxis.fr/). Cada
documento fica em UM dos 4 quadrantes, conforme sua audiencia primaria.

## Comece por aqui

- [`README.md`](../README.md) — posicionamento publico humano
- [`AGENTS.md`](../AGENTS.md) — entrada canonica para IAs
- [`llms.txt`](../llms.txt) — mapa curado para LLMs
- [`obsidian-vault/00-DASHBOARD.md`](../obsidian-vault/00-DASHBOARD.md) — dashboard executivo

## docs/tutorials/ — aprender (passo-a-passo)

> Conteudo em construcao na Onda 6+. Sera populado com tutoriais para:
>
> - Operador municipal: primeira vez usando o sistema
> - Contribuidor publico: primeiro pull request
> - Auditor externo: primeiro audit completo

## docs/how-to/ — cookbook (problema concreto)

- [`how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md`](how-to/GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md) — acesso a materiais operacionais controlados

## docs/reference/ — consulta (regras, API, governanca)

- [`reference/COMPLIANCE_CMMI_ISO.md`](reference/COMPLIANCE_CMMI_ISO.md) — mapeamento CMMI/ISO
- [`reference/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`](reference/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md) — governanca de release
- [`reference/testes/INDEX.md`](reference/testes/INDEX.md) — indice de testes
- [`reference/licenca/README.md`](reference/licenca/README.md) — modelo de licenca
- [`reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md`](reference/legal/CLA_INSTITUCIONAL_TEMPLATE.md) — template CLA institucional

## docs/explanation/ — entender (arquitetura, decisoes)

- [`explanation/ARQUITETURA.md`](explanation/ARQUITETURA.md) — arquitetura do sistema
- [`explanation/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`](explanation/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md) — racional dos cenarios V2

## auditoria/ — historia + evidencias publicas

- [`auditoria/00_status/`](../auditoria/00_status/) — snapshots de estado (00, 22, 24, 26)
- [`auditoria/01_regras_e_governanca/`](../auditoria/01_regras_e_governanca/) — regras canonicas (00 inegociaveis, 03, 04, 14, 16, 17, 18, 19, 21, 23)
- [`auditoria/02_planos/`](../auditoria/02_planos/) — planos (15, 20, 25, 27)
- [`auditoria/03_ondas/`](../auditoria/03_ondas/) — documentacao tecnica de cada onda (28-41)
- [`auditoria/04_evidencias/`](../auditoria/04_evidencias/) — CSVs e manifestos hashados
- [`auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md`](../auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md) — auditoria honesta + plano (raiz)

## .hbn/ — coordenacao inter-IA (HBN-native)

- [`.hbn/relay/INDEX.md`](../.hbn/relay/INDEX.md) — bastao + ciclo ativo
- [`.hbn/knowledge/INDEX.md`](../.hbn/knowledge/INDEX.md) — decisoes reutilizaveis
- [`.hbn/readbacks/`](../.hbn/readbacks/) — snapshots safe_track
- [`.hbn/results/`](../.hbn/results/) — ERPs

## Releases e status (vitrine institucional)

- [`obsidian-vault/00-DASHBOARD.md`](../obsidian-vault/00-DASHBOARD.md)
- [`obsidian-vault/releases/STATUS-OFICIAL.md`](../obsidian-vault/releases/STATUS-OFICIAL.md)
- [`obsidian-vault/releases/V12.0.0202.md`](../obsidian-vault/releases/V12.0.0202.md)
- [`obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md`](../obsidian-vault/metodologia/00-MAPA-DOCUMENTAL.md)
- [`obsidian-vault/metodologia/01-COMO-A-IA-LE-ESTE-REPO.md`](../obsidian-vault/metodologia/01-COMO-A-IA-LE-ESTE-REPO.md)
- [`obsidian-vault/metodologia/02-INTEGRACAO-USEHBN.md`](../obsidian-vault/metodologia/02-INTEGRACAO-USEHBN.md)
- [`obsidian-vault/metodologia/03-PROTOCOLO-GLASSWING.md`](../obsidian-vault/metodologia/03-PROTOCOLO-GLASSWING.md)

## Arquivos canonicos da raiz

- [`README.md`](../README.md)
- [`LICENSE`](../LICENSE)
- [`CLA.md`](../CLA.md)
- [`SECURITY.md`](../SECURITY.md)
- [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [`CHANGELOG.md`](../CHANGELOG.md)
- [`AGENTS.md`](../AGENTS.md)
- [`CLAUDE.md`](../CLAUDE.md)
- [`llms.txt`](../llms.txt)
- [`llms-full.txt`](../llms-full.txt)

## Codigo

- [`src/vba/`](../src/vba/) — fonte de verdade VBA
- [`local-ai/vba_import/`](../local-ai/vba_import/) — pacote oficial de import
- [`local-ai/vba_import/000-REGRA-OURO.md`](../local-ai/vba_import/000-REGRA-OURO.md)
- [`doc/`](../doc/) — dados estruturais de referencia
