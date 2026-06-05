---
titulo: Registro da Onda 0116 (A3) — hbn-guards-ci (rede CI anti-regressão)
diataxis: explanation
hbn-track: fast_track
data: 2026-06-05
autoria: claude-opus (modo arquiteto, via Cowork) em consulta a Mauricio
onda: 0116 (linha arquiteto; sucede 0115 do doc 124)
readback: .hbn/readbacks/0147-rb-onda-0116-a3-guards-ci.json
hearback: .hbn/hearbacks/0147-a3-guards-ci.json (confirmed 2026-06-05)
erp: .hbn/results/0147-exec-onda-0116-a3-guards-ci.json
---

# Onda 0116 (A3) — guards em CI

Item A3 da Trilha A: `.github/workflows/hbn-guards-ci.yml` roda em todo
push (main, codex/**) e PR. Motivação de Mauricio: rede mecânica
anti-regressão madura antes do refatoramento V12.0.0207.

## Entregas

| Arquivo | Função |
|---|---|
| `.github/workflows/hbn-guards-ci.yml` | workflow: range do push/PR → validação de contratos (ratchet) + scope-lock por commit |
| `scripts/hbn-guards/ci/validate-contracts.py` | parse global bloqueante + schema ESTRITO só nos contratos tocados no range + relatório do passivo + coerência canonical-root×schema |
| `scripts/hbn-guards/ci/scope-lock-range.py` | espelha `assert-scope-lock.sh` (fonte canônica da semântica) por commit, com resolução HISTÓRICA do readback ativo (ls-tree/show na árvore de cada commit) e tratamento de `[bypass-hbn-guards]` (skip + exige nota no range) |

Guards locais (.sh, lib/) byte-a-byte intocados. `assert-canonical-root`/
`forbid-tmp-worktree` ficam deliberadamente fora do CI (environment-bound,
knowledge 0021). `forbid-env-files`/`forbid-legacy-paths` ficam para A3.1
(evitar cópia divergente apressada).

## Achado empírico central (alimenta o item A5)

Validação estrita de TODO o histórico: **80/126 readbacks e 11/36 hearbacks
fora do schema 1.0.0**. Não é só legado pré-Onda-36 — há **drift recente**:

- `evidence_kind` na prática usa `command_output`, `git_diff`,
  `git_diff_review`, `file_exists` — o enum 1.0.0 não os contempla.
- `hearback.schema` exige `signed_by`/`signed_at` com
  `additionalProperties:false`, mas a prática usa `by`, `confirmed_at`,
  `agent_id`, etc.
- Enum `agent_id` sem `claude-opus-4-8` (já registrado no 0021).

**Decisão de desenho decorrente: CI em modo RATCHET** — estrito apenas nos
contratos tocados no range (impede drift novo a partir de agora), passivo
visível em relatório não-bloqueante. O bump 1.1.0 (A5) deve legitimar os
valores reais observados em vez de forçar retrofit de 91 arquivos.

## Evidência de teste (sandbox, plumbing só-leitura, 2026-06-05)

- T0: YAML do workflow parseado OK.
- T1: ratchet repo-wide sem tocados → exit 0 + relatório do passivo.
- T2: 6 contratos das ondas 0114-0116 estritos → válidos, exit 0.
- T3: hearback driftado (0141) como "tocado" → **exit 1**, violação apontada.
- T4a: range `e157221..HEAD` (ondas 0114-0115) → 3 commits, resolução
  histórica por commit, fast_track skip, exit 0.
- T4b: range com bypasses reais (`35217c0`, `fd45a5d`) → warnings + nota
  exigida no range presente, exit 0.
- Primeiro run real no GitHub Actions: pendência leve no ERP (próximo push).

## Fricções observadas (candidatas a evolução)

- Padrão "micro-commit de fechamento de ERP" repetiu 3× (0114/0115/0116):
  candidato a regra — fechar ERP da onda N no commit da onda N+1, ou campo
  `commit_sha: "ver git log"` — decidir em ciclo futuro do arquiteto.
- jsonschema precisou de `--break-system-packages` no sandbox; no runner
  ubuntu-latest instala limpo.
