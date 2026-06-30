#!/usr/bin/env bash
# =============================================================================
# guards/assert-start-cast.sh
# path: guards/assert-start-cast.sh · id-global: 20260610-205310-fable-5-guard-start-cast
# Guarda G-STR: dá dente ao ADR-024 Decisão 1 (rito `usehbn start`).
# Spec normativa: core/start-rite-spec.md §4.
#   (1) DELEGA família/aptidão/hearback ao assert-role-family.sh (chamada
#       direta — uma lógica, um lugar; nunca cópia da regra; ADR-018+ADR-020).
#   (2) BLOQUEADOR: campo `orquestrador` presente sem papel
#       `conversacional-orquestrador` (ou equivalente `orquestrador*`) em
#       papeis_aptos do perfil, sem exceção coberta por hearback confirmado.
#   (3) BLOQUEADOR: `escrita_paralela` contém apelido fora do elenco da
#       própria atribuição (orquestrador + implementador + auditores).
#
# status: accepted (adoção orquestração-start, readback 0004) — FORA do runner.
#   Ativação futura = onda própria (ADR-020 Decisão 2: suíte verde + hearback
#   + testes negativos dos 5 guards legados).
# Invocação sob demanda (mesmo padrão G-FAM): o insumo é o JSON IMPRESSO pelo
#   rito start ANTES de existir como blob — por isso este guard, ao contrário
#   de G-NUM/G-PTR/G-RLT, recebe arquivo por argumento e não lê o índice
#   (não há staged a ler; a spec §4 fixa esta forma de invocação).
#     bash guards/assert-start-cast.sh <atribuicao.json>
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-STR).
# Usa python3 só para JSON (precedente assert-scope-lock/assert-role-family).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-start-cast"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ATRIB="${1:-}"
if [[ -z "$ATRIB" || ! -f "$ATRIB" ]]; then
    guard_fail "Uso: assert-start-cast.sh <atribuicao.json> (arquivo não encontrado: '${ATRIB}')"
    exit 2
fi

# --- Regra 1: delegação integral ao G-FAM (família/aptidão/hearback) --------
if ! bash "${SCRIPT_DIR}/assert-role-family.sh" "$ATRIB"; then
    guard_fail "Atribuição reprovada na delegação ao assert-role-family.sh (ADR-018/ADR-020 — ver saída acima)."
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ACTIVE_ROOT="$(get_canonical_root 2>/dev/null || echo "$REPO_ROOT")"
MODELS_DIR="${HBN_MODELS_DIR:-${ACTIVE_ROOT}/.hbn/models}"

# --- Regras 2 e 3 (específicas do start-rite) --------------------------------
set +e
python3 - "$ATRIB" "$MODELS_DIR" "$REPO_ROOT" <<'PYEOF'
import json, os, sys

atrib_path, models_dir, repo_root = sys.argv[1], sys.argv[2], sys.argv[3]
a = json.load(open(atrib_path))
falhas = []

# Dereferência do hearback_ref (mesma semântica ADR-020 do G-FAM):
hearback = None
ref = a.get("hearback_ref")
if ref:
    hp = ref if os.path.isabs(ref) else os.path.join(repo_root, ref)
    try:
        h = json.load(open(hp))
        if h.get("status") == "confirmed":
            hearback = h
    except Exception:
        pass  # G-FAM (regra 1) já bloqueou ref inexistente/ilegível/não-confirmed

def cobre_papel(modelo, papel):
    return any(e.get("tipo") == "papel" and e.get("modelo") == modelo and e.get("papel") == papel
               for e in (hearback or {}).get("excecoes_cobertas", []) if isinstance(e, dict))

# Regra 2: orquestrador declarado precisa do papel apto (ou exceção coberta).
orq = a.get("orquestrador")
if orq:
    p = os.path.join(models_dir, f"{orq}.json")
    if not os.path.isfile(p):
        falhas.append(f"perfil inexistente para orquestrador '{orq}' ({p}) — IA sem perfil ADR-015 não entra no elenco")
    else:
        papeis = json.load(open(p)).get("papeis_aptos", [])
        apto = any(r == "conversacional-orquestrador" or r.startswith("orquestrador") for r in papeis)
        if not apto and not cobre_papel(orq, "conversacional-orquestrador"):
            falhas.append(f"'{orq}' não tem 'conversacional-orquestrador' em papeis_aptos (ADR-015) e nenhum hearback confirmado cobre a exceção (start-rite-spec §4.2)")

# Regra 3: escrita_paralela ⊆ elenco da própria atribuição.
elenco = set(a.get("auditores") or [])
for k in ("orquestrador", "implementador"):
    if a.get(k):
        elenco.add(a[k])
for w in (a.get("escrita_paralela") or []):
    if w not in elenco:
        falhas.append(f"escrita_paralela contém '{w}', que não está no elenco da atribuição ({sorted(elenco)}) — escritor paralelo fantasma (start-rite-spec §4.3)")

if falhas:
    for f in falhas:
        print(f"  ✗ {f}")
    sys.exit(1)
print(f"  ✓ start-cast ok: orquestrador={orq} · escrita_paralela={a.get('escrita_paralela') or []} ⊆ elenco")
sys.exit(0)
PYEOF
RC=$?
set -e
if [[ $RC -eq 0 ]]; then
    guard_ok "Atribuição do start válida: delegação G-FAM verde, orquestrador apto, escrita_paralela dentro do elenco."
else
    guard_fail "Atribuição do start inválida (lista acima — start-rite-spec §4)."
fi
exit $RC
