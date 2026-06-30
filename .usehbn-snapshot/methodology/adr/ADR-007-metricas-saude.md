---
adr-id: ADR-007
titulo: Métricas de saúde do protocolo + alarmes
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Codex + Antigravity
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco)
prioridade: P2 (não bloqueia v0.3.0; implementação `hbn doctor --health` fica para roadmap pós-v0.3.0)
ordem-cross-ia: após ADRs P0 e ADR-005, ADR-006
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.7
  - doc 66 v2.0 (Credenciamento) §7.5
  - ADR-001 (Quarta — começa cada ciclo lendo health.json)
  - ADR-006 (sinais — alarmes podem disparar sinais)
---

# ADR-007 — Métricas de saúde do protocolo + alarmes

## Status

**PROPOSED** — P2, não bloqueia outros ADRs. Pode ser ratificado na 2ª
ou 3ª Quarta.

## Contexto

Sem métricas mensuráveis, o ritual da Quarta vira culto sem feedback
loop. Doc 66 v2.0 §7.5 propôs 6 métricas. Este ADR formaliza coleta,
limites de alarme e ações.

## Decisão

### 1. Conjunto canônico de métricas (output em `.hbn/meta/health.json`)

| Métrica | Definição operacional | Limite de alarme | Ação no alarme |
|---|---|---|---|
| `total_docs_canonicos` | contagem de `.md` em `methodology/` + `modules/` + `docs/` (durante a transição core/docs → modules/methodology; após a Onda Documental Sanitization, conta só `methodology/` + `modules/`); exclui sempre `auditoria/` | crescimento >10%/mês = hipertrofia | Quarta seguinte ativa "candidatos a fusão" como prioridade |
| `adrs_ativos` | ADRs com status PROPOSED ou ACCEPTED (não SUPERSEDED) em `methodology/adr/` | razão `total_docs_canonicos / adrs_ativos > 5` = falta de formalização | Quarta seguinte ativa "candidatos a ADR" |
| `principios_constitucionais` | linhas P\d+ na fonte canônica (PRINCIPIOS-CONSTITUCIONAIS.md) | crescimento >1/trimestre = deriva | Bloqueio: ADR-009 §4 já exige ≥2 incidências reais |
| `quartas_sem_merge_consecutivas` | Quartas que produziram apenas DEFER ou DELETE | >3 = ritual virou burocracia | Revisar pauta da 4ª Quarta consecutiva |
| `cross_ia_divergencia_pct` | percentual de ciclos cross-IA onde Opus/Antigravity/Codex emitiram pareceres conflitantes sobre o mesmo MERGE | **> 40% = princípios mal redigidos** (sub-revisão ADR-009); **< 10% = 🔍 HBN GROUPTHINK ALARM** — viés de prompt ou subserviência de IA (rever prompts de cross-IA, considerar 4ª IA distinta) | redação ou prompts |
| `app_consumidoras_em_drift` | apps com `🪞 HBN MIRROR DRIFT` ativo | >0 sem plano de retomada = falha de propagação | Operador dispara `bin/usehbn-fetch.sh` na app; **nunca force-push** — usar PR auditável (MIRROR-PROPAGATE) |
| `quartas_manuais_por_mes` | contagem de invocações `hbn quarta --manual` no mês | > 2 sem revisão expressa = abuso do ritual (ADR-001 §5.1) | operador revisa frequência |

### 2. Coleta

**Superfície escolhida (ajuste MD-J cross-IA Codex):** `hbn doctor --health`
(subcomando a estender), **não** um shell script `bin/hbn-health.sh`
paralelo. Razão: `hbn doctor` já existe (`cli.py:1096-1199`); reaproveitar
reduz scripts paralelos e mantém uma única superfície de diagnóstico.

**Status atual: contrato futuro pós-v0.3.0** — `hbn doctor --health` não
existe ainda. Documentado aqui para preservar contrato; implementação
fica para roadmap pós-v0.3.0.

Frequência:
- **Automática**: terça-noite antes do AGENT-INTAKE (input para Quarta).
- **On-demand**: `hbn doctor --health`.

Output:

```json
{
  "schema_version": "1.0",
  "collected_at": "2026-05-XXTHH:MM:SSZ",
  "metrics": {
    "total_docs_canonicos": <int>,
    "adrs_ativos": <int>,
    "principios_constitucionais": <int>,
    "quartas_sem_merge_consecutivas": <int>,
    "cross_ia_divergencia_pct": <float>,
    "app_consumidoras_em_drift": <int>
  },
  "alarmes_ativos": ["<lista de chaves cujo limite foi cruzado>"]
}
```

### 3. Métricas derivadas (futuro v0.4+)

Não bloqueiam ratificação:

- `truth_barrier_hits_por_semana`
- `glasswing_violations_por_release`
- `adoption_per_runtime` (claude-code, codex, gemini, antigravity, etc.)
- `time_to_quarta_close` (do INTAKE ao COMMIT-DRAFT)

## Consequências

**Positivas:**
- Quarta tem input mensurável em vez de impressão subjetiva.
- Hipertrofia documental detectável quantitativamente.
- Stagnation detectável (`quartas_sem_merge_consecutivas`).

**Negativas:**
- Manutenção do subcomando `hbn doctor --health` como dependência de cada Quarta.
- Risco de "dirigir pela métrica" (Goodhart): mitigado por revisão
  trimestral dos limites pela própria Quarta.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | `hbn doctor --health` falhar antes de uma Quarta | Quarta procede sem `health.json`; métricas são reportadas manualmente pelo operador no boletim; ausência de health.json não bloqueia o ciclo |
| R2 | Limites de alarme arbitrários | ADR-007 v1 estabelece valores iniciais; Quarta N+12 revisa com base em série temporal real |
| R3 | Métricas viesadas pelo próprio mantenedor | Cross-IA na Quarta debate; minimum 2 IAs para qualquer ajuste de limite |

## Próximo passo

1. ✅ Cross-IA review concluído (Codex `0008-cross-ia-codex-ADR-007.json` + Antigravity `0018-cross-ia-antigravity-ADR-007.md`).
2. ✅ Ajustes MD-J aplicados (2026-05-10).
3. Hearback humano → status PROPOSED → ACCEPTED.
4. MD subsequente (pós-v0.3.0): implementar `hbn doctor --health` em `src/usehbn/cli.py` (estende `run_doctor`).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) `cross_ia_divergencia_pct < 10%` = 🔍 HBN GROUPTHINK ALARM (insight Antigravity — consenso unânime permanente é falha de design em cross-audit); (b) superfície escolhida `hbn doctor --health`, não shell script paralelo (insight Codex); (c) `total_docs_canonicos` conta `docs/` durante a transição; (d) substituído "force-push" por "PR auditável" em MIRROR-PROPAGATE; (e) métrica nova `quartas_manuais_por_mes` (>2 = abuso, ADR-001 §5.1).
