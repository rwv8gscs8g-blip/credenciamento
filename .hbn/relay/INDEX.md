---
titulo: Relay HBN — coordenacao inter-IA do Credenciamento
versao-protocolo: HBN 0.2.0
proprietario-bastao: Claude Opus 4.7 (sessao Cowork de 2026-04-28)
ciclo-ativo: ONDA 6 — consolidacao documental + cleanup
proxima-acao: executar tarefas #2..#11 da TaskList ate fechar Onda 6
ultima-atualizacao: 2026-04-28
---

# Relay HBN — Credenciamento

## Bastao atual

| Campo | Valor |
|---|---|
| Proprietario | Claude Opus 4.7 (Cowork) |
| Concedido por | Luis Mauricio Junqueira Zanin |
| Data de concessao | 2026-04-28 |
| Validade | ate fechamento estavel da V12.0.0203 no GitHub |
| Reverte para | Codex (apoio) + Claude Opus em modo auditoria |
| Justificativa | retrabalho da Onda 5 nao estabilizada; concentracao em uma IA reduz risco de perda de contexto durante a estabilizacao |

## Ciclo ativo

| Campo | Valor |
|---|---|
| Ciclo | ONDA 6 — consolidacao documental + cleanup |
| Track HBN | safe_track |
| Readback | [readbacks/0001-onda06.json](../readbacks/0001-onda06.json) |
| Hearback | confirmed (2026-04-28) |
| Ciclo origem | [relay/0001-onda06-consolidacao-documental.md](0001-onda06-consolidacao-documental.md) |

## Ondas previstas (a partir desta)

| Onda | Tema | Status |
|---|---|---|
| 6 | consolidacao documental + cleanup + integracao Diataxis/llms.txt/AGENTS.md/HBN | EM EXECUCAO |
| 5 (resgate) | homologacao final do form deterministico + Limpa_Base robusta (ja entregue, em homologacao manual) | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | PROXIMA APOS ONDA 6 |
| 8 | heuristica zero em todos os 13 forms | DEPOIS DA 7 |
| 9 | reescrita do Importador_VBA + auditoria de Mod_Types (com aprovacao explicita) | DEPOIS DA 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | DEPOIS DA 9 |

## Proxima acao explicita

Executar tarefas #2..#11 da TaskList:

- apagar auditoria/39 (duplicacao consolidada em .hbn/knowledge/0002 e local-ai/vba_import/000-REGRA-OURO.md)
- mover backups historicos para Projetos/backups/credenciamento/
- mover macros descartaveis para Projetos/backups/credenciamento/macros_descartaveis_v0203/
- reorganizar auditoria/ por tipo preservando numero historico
- criar AGENTS.md, llms.txt, llms-full.txt, docs/ Diataxis
- refinar CLAUDE.md (Mod_Types como Onda 9)
- atualizar CHANGELOG, README, docs/INDEX, vba_import/README, vault dashboard
- reviver vault Obsidian Opcao A com metodologia D (HBN+Diataxis+llms.txt+AGENTS.md)
- atualizar usehbn em paralelo com integracoes adotadas
- escrever auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md
- verificacao final (md5, links, grep, git status)

## Standard HBN markers

Esta sessao usa os marcadores visiveis do adapter HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `❌ HBN SECURITY BLOCKED SUGGESTION` — gate de seguranca
- `🟡 HBN NEEDS HUMAN DECISION` — aprovacao requerida
