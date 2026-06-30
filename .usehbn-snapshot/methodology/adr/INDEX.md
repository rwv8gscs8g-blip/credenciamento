# ADRs do useHBN — índice

> Architecture Decision Records do protocolo useHBN. Cada ADR é uma
> decisão arquitetural com status documentado. Decisões que afetam
> contratos públicos (schemas, principios, licença) sempre têm ADR.

## Convenções

- **ID**: `ADR-NNN-<kebab-slug>.md` (NNN ≥ 001).
- **Status**: PROPOSED → ACCEPTED → SUPERSEDED → DEPRECATED.
- **Cross-IA**: ADRs estruturais exigem ≥2 IAs revisoras (P10). ADRs
  constitucionais (mudança em P1-P13) exigem 3 IAs (Opus + Antigravity + Codex).
- **Append-only**: ADR antigo não é deletado. Quando substituído, ganha
  status SUPERSEDED + link para o sucessor.
- **Hearback humano** é obrigatório para mudança de status PROPOSED → ACCEPTED.

## Status atual (2026-06-10 — pós readback 0003 fechamento E)

| ADR | Título | Prioridade | Status | Cross-IA | Dependências |
|---|---|---|---|---|---|
| [ADR-001](ADR-001-quarta-de-sanitizacao.md) | Quarta de Sanitização — janela 12h BRT + manual | P0 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído | depende de 002, 003, 004, 005, 006, 009 |
| [ADR-002](ADR-002-tipologia-founding-consuming.md) | Tipologia Founding/Consuming Application vs Module | P0 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído | — |
| [ADR-003](ADR-003-topologia-repos-relay.md) | Topologia mono-repo modular + relay multi-camada | P0 | **ACCEPTED v1.2** (ratificado 2026-05-10; v1.2 absorve decisões topologia) | ✅ concluído | depende de 002 |
| [ADR-004](ADR-004-semver-protocolo.md) | SemVer do protocolo + sinalização para apps consumidoras | P0 | **ACCEPTED v2** (re-deposit 2026-05-10 absorvendo MD-H; PACKAGE_VERSION vs PROTOCOL_VERSION distinção) | ✅ concluído | depende de 002, 003 |
| [ADR-005](ADR-005-licenciamento-apache-cla.md) | Licenciamento — AGPLv3 → Apache 2.0 + DCO | P1 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído | direção decidida 2026-05-09 |
| [ADR-006](ADR-006-sinais-multi-repo.md) | Sinais HBN multi-repo (🌐, ⛓️, 🧊, 🪞, ⏳, 🔍) | P1 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído | — |
| [ADR-007](ADR-007-metricas-saude.md) | Métricas de saúde do protocolo + alarmes | P2 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído | implementação `hbn doctor --health` pós-v0.3.0 |
| [ADR-008](ADR-008-migracao-snapshot-credenciamento.md) | Migração `Credenciamento/usehbn/` → `.usehbn-snapshot/` | P0 | **NÃO_RATIFICAR** — bloqueado por MD-I + MD-K execução + v204 final | ✅ concluído — Codex REPROVOU | **MD-I implementação + Onda Documental + v204 final** |
| [ADR-009](ADR-009-constituicao-p1-p13.md) | Constituição P1-P13 — migração + processo de mudança | P0 | **ACCEPTED v1.1** (ratificado 2026-05-10) | ✅ concluído (3 IAs) | — |
| [ADR-010](ADR-010-autoevolve-cycle.md) | Autoevolve — microdeltas locais com scaffold distribuído | P1 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído | depende conceitualmente de 001 e 007 |
| [ADR-008 v2](ADR-008-migracao-snapshot-credenciamento-v2.md) | Re-deposit ADR-008: gatilho DATA 2026-06-30 + dono Maurício; inbox por projeto | P0 | **ACCEPTED** (hearback 0001, 2026-06-10; supersede v1) | ✅ concluído (Opus + Codex) | C2+C3 concluídos; reusa MD-K; desacoplado do freeze V206 |
| [ADR-011](ADR-011-enderecamento-numeracao-temperatura.md) | Endereçamento, numeração `AAAAMMDD-NN` e temperatura de artefatos | P0 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído (Opus + Codex) | — |
| [ADR-012](ADR-012-naming-versoes-ondas.md) | Naming canônico de versões e ondas (mata subnomes) | P0 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído (Opus + Codex) | depende de 011 (vocabulário de tipo) |
| [ADR-013](ADR-013-arquiteto-autonomo-classes-a-b.md) | Arquiteto autônomo 2.0 — classes A/B, rampa Q2, commit único | P0 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído (Opus + Codex) | promove ADR-010 → ACCEPTED no mesmo hearback |
| [ADR-014](ADR-014-cerimonia-proporcional-tiers.md) | Cerimônia proporcional ao risco — tiers T0–T3 com rito mínimo por tier | P0 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído (Opus + Codex) | refina ADR-013 |
| [ADR-015](ADR-015-perfis-de-modelo.md) | Perfis de capacidade por modelo — doutrina paramétrica | P1 | **ACCEPTED** (hearback 0001, 2026-06-10) | ✅ concluído (Opus + Codex) | depende de ADR-014 |
| [ADR-016](ADR-016-dual-run-caracterizacao.md) | Dual-run / teste de caracterização para reescrever legado | P1 | PROPOSED (corrente D; hearback lote H1-H6 pendente) | ✅ 0021/0022 | — |
| [ADR-017](ADR-017-freeze-gate-executavel.md) | Freeze-gate executável — "congelável" é veredicto de máquina | P0 | PROPOSED (corrente D; hearback lote H1-H6 pendente) | ✅ 0021/0022 | — |
| [ADR-018](ADR-018-papeis-chapeus-anti-groupthink.md) | Papéis como contrato, chapéus como atribuição, guard anti-groupthink | P0 | PROPOSED (corrente D; hearback lote H1-H6 pendente) | ✅ 0021/0022 | depende de ADR-015 |
| [ADR-019](ADR-019-diagnostico-seguranca-defensivo-obrigatorio.md) | Diagnóstico de segurança defensivo obrigatório | P0 | PROPOSED (corrente D; hearback lote H1-H6 pendente) | ✅ 0021/0022 | — |
| [ADR-020](ADR-020-anti-validacao-de-teatro.md) | Anti-Validação-de-Teatro — PASS só sobre substância + teste negativo obrigatório | P0 | **ACCEPTED** (readback 0002, 2026-06-10) | ✅ concluído (0025/0026, sem veto) | depende de ADR-017, ADR-018 |
| [ADR-021](ADR-021-documentos-auto-localizaveis.md) | Documentos auto-localizáveis — `path:` obrigatório + guard G-SLF | P1 | **ACCEPTED** (readback 0003, 2026-06-10) | ✅ concluído (0027/0028/0029 + hearback 0003) | estende ADR-011 |
| [ADR-022](ADR-022-saida-de-auditoria-legivel.md) | Saída de auditoria legível por humano — md é o veredito, json é anexo | P1 | **ACCEPTED** (readback 0003, 2026-06-10) | ✅ concluído (0027/0028/0029 + hearback 0003) | — |
| [ADR-023](ADR-023-integridade-de-hearback.md) | Integridade de hearback — anti-auto-assinatura (F-05) + guard G-HRB | P0 | **ACCEPTED** (readback 0003, 2026-06-10) | ✅ concluído (0027/0028/0029 + hearback 0003) | depende de ADR-020 |
| [ADR-024](ADR-024-orquestracao-start.md) | Orquestração-start consolidada — rito de elenco, orquestrador reinicializável, Ponteiro HBN, Relato de Estado, numeração paralela HHMMSS, tacit drift | P1 | PROPOSED (consolidação dos 3 brainstorms, 2026-06-10) | pendente (Codex + Antigravity — autor Anthropic não audita, ADR-018) | estende ADR-011; depende de ADR-015/018/020/021/022/023 |
| [ADR-025](ADR-025-nome-universal-artefato-ia.md) | Nome universal de artefato de IA — AAAAMMDD-HHMMSS-agente-slug incondicional para séries de evento; relógio do operador, UTC proibido; zona de corte | P0 | PROPOSED (onda 0006 I-02, 2026-06-11 — F-03 dos cross-audits 0036/0037) | pendente (Codex + Antigravity sobre a branch proposta/onda-0006) | revoga condicionalidade do ADR-024 D5.1; estende ADR-011 |

> Reparo de drift (fechamento corrente E): as linhas ADR-016–020 estavam
> ausentes deste índice desde as correntes D/E — adicionadas agora com o
> status real do front-matter de cada um, sem alterar os ADRs.

### Microdeltas geradas pela cross-IA (2026-05-10)

| MD | Tema | Status | Bloqueia |
|---|---|---|---|
| MD-H | Resolução divergência de versão (`PACKAGE_VERSION` vs `PROTOCOL_VERSION`) | spec entregue em `auditoria/00_status/06_MD_H_*.md`; patch em código pendente (Codex) | re-deposit ADR-004 |
| MD-I | Snapshot tooling (`bin/usehbn-fetch.sh`, `usehbn-verify.sh`, manifest determinístico, `hbn doctor` extension) | spec entregue em `auditoria/00_status/07_MD_I_*.md`; implementação pendente (Codex, pós-v204) | re-deposit ADR-008 |
| MD-J | Ajustes nos 7 ADRs ratificáveis + reescrita PRINCIPIOS-CONSTITUCIONAIS | ✅ CONCLUÍDO 2026-05-10 (este INDEX reflete) | promoção PROPOSED → ACCEPTED |
| MD-K | Matriz origem→destino do `Credenciamento/usehbn/` | ✅ entregue em `auditoria/00_status/08_MD_K_*.md` | execução de ADR-008 |

## Ordem de cross-IA serial (decisão operador 2026-05-09)

Para os 5 ADRs P0:

```
ADR-002  →  ADR-003  →  ADR-004  →  ADR-009  →  ADR-001
(tipologia)  (topologia)  (SemVer)   (constituição)  (Quarta — fecha)
```

Razão: ADR-001 depende dos outros 4 conceitualmente (tipologia + topologia
+ SemVer + constituição). Quarta é o ritual operacional que materializa
o resto.

ADRs P1 (005, 006) e P2 (007) ratificam após os P0. ADR-008 espera v204
final do Credenciamento independente da ordem dos demais.

## Histórico de revisões

- 2026-05-09 — Opus 4.7 chat arquiteto-mestre deposita os 9 ADRs como
  esqueletos PROPOSED em MD-B. Nenhum cross-IA review concluído ainda.
- 2026-05-10 — Cross-IA concluída: Codex CLI (10 JSONs `0001-0010-cross-ia-codex-*`)
  + Antigravity (10 MDs `0011-0020-cross-ia-antigravity-*`). Consolidação em
  `auditoria/00_status/05_CONSOLIDACAO_CROSS_IA_ADRS_2026_05_10.md`. Resultado:
  7 ADRs RATIFICAR_APÓS_AJUSTES (MD-J aplicado), 2 ADRs NÃO_RATIFICAR
  (ADR-004 bloqueado por MD-H; ADR-008 bloqueado por MD-I + MD-K + v204).
  Decisões do operador: emoji ⏳ para BILLING WINDOW DRIFT; MDs em paralelo.
- 2026-05-10 — **Hearback humano em bloco**: Mauricio ratificou os 7 ADRs
  PROPOSED v1.1 → **ACCEPTED**. ADR-003 promovido a v1.2 absorvendo as 3
  decisões de topologia (radar/ standalone, study-plans/ em methodology/,
  templates/ em methodology/). ADR-004 e ADR-008 mantêm-se NÃO_RATIFICAR
  até specs (MD-H/MD-I) virarem código + v204 final.
- 2026-05-10 — **Iteração 2 do cronograma autônomo (MD-H aplicado)**:
  patch em `__init__.py` + `cli.py` + `setup.cfg` separa `PACKAGE_VERSION`
  de `PROTOCOL_VERSION`; bug em `cli.py:1079` corrigido (records publicam
  PROTOCOL_VERSION agora); ambas constantes alinhadas em `0.3.0` mas
  semanticamente independentes. ADR-004 re-depositado como v2 e
  ratificado. 93 testes passing (+3 novos em `test_version_constants.py`).
  ADR-008 segue NÃO_RATIFICAR (aguarda MD-I + v204 final).

## Como adicionar novo ADR

1. Próximo número disponível: ADR-026 (ADR-025 depositado 2026-06-11, onda 0006 enforcement-sem-exceção, PROPOSED).
2. Criar `methodology/adr/ADR-NNN-<kebab-slug>.md` seguindo o template
   dos existentes (frontmatter, contexto, decisão, consequências,
   riscos, próximo passo, versão).
3. Atualizar este INDEX.md adicionando linha na tabela.
4. Status inicial: PROPOSED.
5. Cross-IA review por ≥1 IA distinta do autor (preferencialmente 2).
6. Hearback humano para promover a ACCEPTED.
