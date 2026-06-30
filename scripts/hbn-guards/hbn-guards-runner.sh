#!/usr/bin/env bash
# =============================================================================
# scripts/hbn-guards/hbn-guards-runner.sh  (P2-C — runner project-mode)
# Entrypoint do .git/hooks/pre-commit (FASE 1). Proposta-ponte v2 §5.
# Ordem: (1) integridade da membrana; (2) subset bloqueante de .usehbn-snapshot/guards/.
# assert-knowledge-index NÃO entra aqui (warning->bloqueante só após higiene do INDEX = P2-C2).
# Guards internos do genoma NÃO rodam aqui (§2). Fail-fast; sem bypass mascarado.
# =============================================================================
set -euo pipefail
TOP="$(git rev-parse --show-toplevel)"; cd "$TOP"
INTEGRITY="${TOP}/scripts/hbn-snapshot/assert-snapshot-integrity.sh"
SNAP_GUARDS="${TOP}/.usehbn-snapshot/guards"
if [[ -t 1 ]]; then C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_END=$'\033[0m'; else C_BOLD=""; C_DIM=""; C_END=""; fi
echo "${C_BOLD}[hbn-guards] runner project-mode (membrana usehbn@v1-estavel)…${C_END}" >&2
# 1) integridade da membrana ANTES de usar os guards dela
echo "${C_DIM}--- assert-snapshot-integrity ---${C_END}" >&2
if [[ -x "$INTEGRITY" ]]; then bash "$INTEGRITY"; else
  echo "[hbn-guards] ERRO: $INTEGRITY ausente/nao-executavel — fail-closed." >&2; exit 2; fi
# 2) subset bloqueante, a partir da membrana (NAO o runner do genoma)
SUBSET=( "assert-canonical-root.sh" "forbid-tmp-worktree.sh" "forbid-env-files.sh" \
         "forbid-legacy-paths.sh" "assert-scope-lock.sh" "assert-hearback-integrity.sh" )
OVERALL=0
for g in "${SUBSET[@]}"; do
  echo "${C_DIM}--- ${g} (.usehbn-snapshot/guards) ---${C_END}" >&2
  if [[ ! -r "${SNAP_GUARDS}/${g}" ]]; then
    echo "[hbn-guards] ERRO: ${SNAP_GUARDS}/${g} ausente/ilegivel — fail-closed." >&2; OVERALL=2; break; fi
  rc=0; bash "${SNAP_GUARDS}/${g}" || rc=$?
  if [[ $rc -ne 0 ]]; then OVERALL=$rc; break; fi
done
echo "${C_DIM}---${C_END}" >&2
if [[ $OVERALL -eq 0 ]]; then
  echo "${C_BOLD}[hbn-guards] Subset project-mode verde (integridade + 6 guards).${C_END}" >&2
else
  echo "${C_BOLD}[hbn-guards] Guards FALHARAM (codigo $OVERALL).${C_END}" >&2
fi
exit $OVERALL
