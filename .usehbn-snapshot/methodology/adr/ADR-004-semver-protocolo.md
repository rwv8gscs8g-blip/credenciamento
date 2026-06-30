---
adr-id: ADR-004
titulo: SemVer do protocolo + sinalização para aplicações consumidoras
status: ACCEPTED
data-deposito: 2026-05-09
data-redeposit-v2: 2026-05-10
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Codex (cross-IA inicial detectou bloqueador; MD-H aplicado; v2 ratificado)
hearback-status: ratificado por Mauricio 2026-05-10 via aprovação do cronograma autônomo (proposta 09); patch MD-H aplicado na Iteração 2
prioridade: P0
ordem-cross-ia: 3 de 5 (concluído)
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.4
  - doc 66 v2.0 (Credenciamento) §7.3
  - ADR-002 (tipologia)
  - ADR-006 (sinais multi-repo)
  - ADR-008 (migração snapshot)
  - Onda 2 nova já implementada (`protocol_version` opcional em schemas)
---

# ADR-004 — SemVer do protocolo + sinalização para aplicações consumidoras

## Status

**ACCEPTED v2** — ratificado 2026-05-10 após MD-H aplicado.

Histórico de status:
- v1 (2026-05-09): depositado como PROPOSED.
- v1 cross-IA (2026-05-10): Codex REPROVOU por divergência de versão
  (`PROTOCOL_VERSION 0.3.0` ≠ `__version__ 0.2.0` ≠ `setup.cfg 0.2.0`)
  + bug em `cli.py:1079-1084` que publicava `protocol_version` usando
  `__version__`. Status virou NÃO_RATIFICAR.
- MD-H (2026-05-10): especificação em `auditoria/00_status/06_MD_H_*`;
  patch aplicado na Iteração 2 do cronograma autônomo aprovado pela
  proposta 09.
- v2 (2026-05-10): re-deposit como ACCEPTED. Decisão original do v1
  preservada e ampliada com a distinção `PACKAGE_VERSION` vs
  `PROTOCOL_VERSION` (§1.5 abaixo).

## Contexto

O protocolo useHBN precisa de versionamento semântico claro
(`MAJOR.MINOR.PATCH`) e mecanismo de propagação para aplicações
consumidoras quando MAJOR ou MINOR mudam. A Onda 2 nova do plano v0.3.0
já implementou `protocol_version` opcional em `readback.schema.json` e
`result.schema.json` (commit `4a09523`). Falta:

- Definir regras de bump por tipo de mudança.
- Definir contrato de declaração da versão consumida em apps.
- Definir sinais que disparam quando MAJOR/MINOR muda.
- Estabelecer caminho para tornar `protocol_version` required em v1.0.0
  (decisão Q4 do plano v0.3.0).

## Decisão

### 1.5 PACKAGE_VERSION vs PROTOCOL_VERSION (acrescido v2 — MD-H)

O useHBN expõe **duas constantes de versão semanticamente distintas**:

| Constante | Significado | Onde vive | Bump quando |
|---|---|---|---|
| `PACKAGE_VERSION` (alias de `__version__`) | versão do pacote Python/CLI publicado no PyPI | `src/usehbn/__init__.py`, `setup.cfg` (mantido alinhado por convenção) | qualquer release de pacote (fix de bug em CLI, refactor interno, etc.) |
| `PROTOCOL_VERSION` | versão do **protocolo** (schemas, princípios, contratos doutrinários) | `src/usehbn/__init__.py` | conforme regras §1 (MAJOR = mudança em P1-P13; MINOR = novo sinal/schema/partição; PATCH = redação) |

As duas **podem divergir legitimamente**. Exemplo: `PACKAGE_VERSION
0.3.1` com `PROTOCOL_VERSION 0.3.0` = fix de bug no CLI sem mudança
no protocolo. O que NÃO pode é o CLI publicar a constante errada em
records ou em `hbn version`.

**Estado atual (2026-05-10 pós-MD-H)**: ambas alinhadas em `0.3.0`.
Daqui pra frente são independentes.

**Saída do `hbn version`** (publica ambas):

```json
{
  "project": "HBN — Human Brain Net",
  "package_version": "0.3.0",
  "protocol_version": "0.3.0",
  "cli": "hbn"
}
```

**Records ERP** (`hbn result`, `hbn readback`) gravam apenas
`protocol_version` — porque records descrevem o protocolo, não o
pacote que os gerou.

### 1. Regras de bump SemVer

| Bump | Quando | Exemplo |
|---|---|---|
| **MAJOR** | mudança em princípio constitucional (P1-P13); remoção/renomeação de campo `required` em schema; renomeação de termo doutrinário (lista imutável de v0.3.0); promoção de `protocol_version` a required | `0.3.x` → `1.0.0` quando `protocol_version` virar required |
| **MINOR** | novo princípio (P14+); novo sinal HBN; nova partição de docs; novo schema; novo subcomando CLI; novo connector; mudança em redação de princípio existente (que apenas clarifica, sem alterar semântica — caso ambíguo, escolher MAJOR) | `0.3.0` → `0.4.0` quando ADR-007 (métricas) implementar |
| **PATCH** | correção de redação; fusão de docs sem mudança normativa; fix de bug em código sem mudança de contrato externo | `0.3.0` → `0.3.1` para fix de bug em `Repo_Avaliacao` análogo |

Casos de fronteira:
- Adição de campo opcional em schema = **MINOR** (apps existentes não
  quebram).
- Adição de campo required em schema = **MAJOR**.
- Mudança de comportamento default de subcomando CLI = **MAJOR**.

### 2. Contrato de declaração na aplicação consumidora

Aplicação consumidora declara em `AGENTS.md` raiz (ver MD-C do plano):

```yaml
useHBN-version: ^X.Y.Z       # SemVer compatível (caret = aceita Y.* e Z.*)
useHBN-snapshot-path: .usehbn-snapshot/
useHBN-snapshot-checksum: <SHA256 do PROTOCOL_SHA256.txt>
```

Operador SemVer aceito:
- `^X.Y.Z` (default — recomendação Opus): aceita patches e minors compatíveis
- `~X.Y.Z`: aceita só patches
- `=X.Y.Z` ou `X.Y.Z`: pinning exato (apenas se app não pode tolerar nenhuma mudança)

### 3. Sinais multi-repo (formalizados em ADR-006)

| Sinal | Quando dispara |
|---|---|
| ⛓️ **HBN PROTOCOL DEP CHANGE** | Tag MAJOR ou MINOR publicada no useHBN; apps consumidoras recebem PR ou nota informativa |
| 🪞 **HBN MIRROR DRIFT** | Auditor cruzado detecta que `.usehbn-snapshot/` da app diverge do checksum esperado da versão declarada |

### 4. Caminho para v1.0.0 (`protocol_version` required)

- v0.3.0 (atual): `protocol_version` **opcional** em readback/result schemas (Onda 2 nova entregue).
- v0.4.0+: introduzir validação warning quando ausente.
- v1.0.0: tornar `protocol_version` **required** + bump MAJOR.
- Records legados (v0.2.x, v0.3.x) sem `protocol_version` permanecem
  válidos até v1.0.0 — após, exigem migração explícita.

### 5. Vocabulário de termos imutáveis em v0.3.0 (lembrete)

`Readback`, `Hearback`, `Guardian`, `Truth Barrier`, `ERP`, `Relay`,
`Baton`, `Consent`, `Handoff`, `Track` (`fast_track`/`safe_track`),
`Universal Translator`, `Phagocytosis`, `usehbn`, `hbn`, `use hbn`.

Renomeação de qualquer destes = bump MAJOR + RFC explícito.

## Consequências

**Positivas:**
- Apps consumidoras têm contrato claro de versionamento.
- ADRs futuros (008 migração, 006 sinais) ganham referência.
- Cadência da Quarta de Sanitização (ADR-001) usa SemVer para decidir
  quando bumpa.

**Negativas:**
- Adiciona complexidade: cada Quarta precisa decidir bump (mas é
  trabalho de minutos).
- App consumidora desatualizada que ignora `⛓️ HBN PROTOCOL DEP CHANGE`
  pode acumular drift até `🪞 HBN MIRROR DRIFT` ser emitido.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Bump errado (PATCH onde devia ser MINOR) | Cross-IA review na Quarta debate cada bump. Erro corrigível: bumpa MAJOR no próximo ciclo declarando `superseded-by` |
| R2 | App não declara `useHBN-version` em AGENTS.md | `hbn doctor --target <app>` (a estender) detecta ausência e emite warning |
| R3 | `protocol_version` em records gravados antes desta decisão sem valor | Default fallback "0.3.0" assumido em leitura; sem migração forçada até v1.0.0 |
| R4 | Records gravados antes de MD-H têm `protocol_version` errado (recebeu `__version__ "0.2.0"` em vez de `PROTOCOL_VERSION "0.3.0"`) | Aceitar como dívida histórica — não migrar (P7 preserva identidade do que foi gravado). Loader tolerante aceita ambos. Bug fix em `cli.py:1079-1084` previne novos casos a partir de 2026-05-10 |

## Próximo passo

1. ✅ ADR-002 e ADR-003 ratificados (2026-05-10).
2. ✅ Cross-IA review por Codex concluído (`0003-cross-ia-codex-ADR-004.json`) — REPROVOU em v1.
3. ✅ MD-H executado (Iteração 2 do cronograma autônomo).
4. ✅ Re-deposit v2 + ratificação 2026-05-10.
5. CHANGELOG do useHBN passa a citar tipo de bump por release (a partir do release v0.3.0 — Iteração 12).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
- v2 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — re-deposit absorvendo MD-H. Adicionada §1.5 distinguindo PACKAGE_VERSION de PROTOCOL_VERSION; §3 (`hbn version` publica ambos); R4 sobre dívida histórica de records pré-MD-H. Status ACCEPTED.
