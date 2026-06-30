#!/usr/bin/env bash
# =============================================================================
# guards/assert-hearback-integrity.sh
# path: guards/assert-hearback-integrity.sh · id-global: 20260610-83
# Guarda G-HRB: dá dente ao ADR-023 (integridade de hearback / anti-auto-
# assinatura — responde ao FORTE F-05 da re-auditoria 0026, "Teatro de 3º
# Nível": IA forja hearback confirmed e o commita junto com a violação).
#
# Uso:
#   bash guards/assert-hearback-integrity.sh <hearback-path> [commit-da-mudanca]
#     (commit-da-mudanca default: HEAD — o commit de adoção que CITA o hearback)
#   bash guards/assert-hearback-integrity.sh
#     (SEM argumento = modo runner, onda 0006 I-08: hearback staged junto com
#      obra → BLOCK; com chave em .hbn/operators/*.pub, exige <hb>.sig válido)
#
# Veredicto — o hearback é válido como autorização? Recusa quando:
#   (1) hearback NÃO commitado antes da mudança (staged/untracked não
#       pré-existe a nada — ADR-023 Decisão 1b);
#   (2) hearback nasceu/foi alterado no MESMO commit da mudança
#       (auto-assinatura clássica — caso-ruim canônico do teste negativo);
#   (3) o commit do hearback NÃO é puro: toca arquivos fora de
#       .hbn/hearbacks/ (autorização misturada com obra).
# Critério de autor (autor do hearback = autor da mudança): AVISO, não
#   bloqueio, enquanto o repo usar identidade git única (shell compartilhado
#   — a igualdade é o caso legítimo normal). Elevação a bloqueio quando
#   houver identidades separadas / assinatura GPG-SSH (ADR-023 Decisão 4,
#   backlog). LIMITE HONESTO: a trava lógica é parcial; a barreira final é a
#   revisão humana do diff de .hbn/hearbacks/ (ADR-023 Decisão 3).
#
# status: accepted (corrente E — fechamento, readback 0003, 2026-06-10);
#   ENTRA NO RUNNER na onda 0006 (I-08), em modo sem-argumento, com testes
#   negativos verdes ANTES da ativação (ADR-020).
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-HRB) — ADR-020.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-hearback-integrity"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

HB="${1:-}"
CHANGE="${2:-HEAD}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
ACTIVE_ROOT="$(get_canonical_root 2>/dev/null || echo "$REPO_ROOT")"

# --- Assinatura SSH do humano (onda 0006 I-08 — ADR-023 Decisão 4 sai do
# backlog): chaves públicas registradas em .hbn/operators/*.pub (versionado).
# COM chave registrada: todo hearback exige <hearback>.sig válido
# (ssh-keygen -Y verify, namespace hbn-hearback) — auto-assinatura por IA
# vira IMPOSSÍVEL (a IA não tem a chave privada), não apenas proibida.
# SEM chave registrada: comportamento anterior + aviso "assinatura pendente
# de chave" (ativação plena = decisão humana de gerar/registrar a chave).
OPS_DIR="${HBN_OPERATORS_DIR:-${ACTIVE_ROOT}/.hbn/operators}"
have_operator_keys() { compgen -G "${OPS_DIR}/*.pub" >/dev/null 2>&1; }
verify_hearback_sig() { # <hearback-path> → 0 assinado por operador registrado
    local hb="$1" sig="${hb}.sig" pub principal allowed rc=1
    [[ -f "$sig" ]] || return 1
    allowed="$(mktemp)"
    for pub in "${OPS_DIR}"/*.pub; do
        [[ -e "$pub" ]] || continue
        principal="$(basename "$pub" .pub)"
        printf '%s %s\n' "$principal" "$(cat "$pub")" > "$allowed"
        if ssh-keygen -Y verify -f "$allowed" -I "$principal" -n hbn-hearback -s "$sig" < "$hb" >/dev/null 2>&1; then
            rc=0
            break
        fi
    done
    rm -f "$allowed"
    return $rc
}
check_signature() { # <hearback-path>; respeita o modo sem-chave
    local hb="$1"
    if ! have_operator_keys; then
        guard_warn "Assinatura de hearback PENDENTE DE CHAVE: nenhum .pub em ${OPS_DIR} — G-HRB segue com as travas de histórico (ADR-023 D2) até o humano registrar a chave (D4)."
        return 0
    fi
    if verify_hearback_sig "$hb"; then
        guard_log "Assinatura SSH de '${hb}' VÁLIDA (operador registrado em ${OPS_DIR})."
        return 0
    fi
    guard_fail "Hearback '${hb}' SEM assinatura SSH válida (${hb}.sig) de operador registrado em ${OPS_DIR} (ADR-023 D4 ativo: com chave registrada, hearback sem assinatura não autoriza NADA — auto-assinatura por IA é impossível, não proibida)."
    return 1
}

# --- MODO RUNNER (onda 0006 I-08, sem argumento): fiscaliza o DIFF staged ----
# (1) hearback staged JUNTO com obra = auto-assinatura no chokepoint → BLOCK
#     (ADR-023 D1b: commit do hearback é PURO e do humano);
# (2) com chave registrada, hearback staged exige .sig válido.
if [[ -z "$HB" ]]; then
    STAGED="$(guard_diff_files)"
    HB_TOUCHED="$(grep -E '^\.hbn/hearbacks/' <<< "$STAGED" | grep -v '\.sig$' || true)"
    if [[ -z "$HB_TOUCHED" ]]; then
        guard_ok "Nenhum hearback no diff staged."
        exit 0
    fi
    OUTROS="$(grep -vE '^\.hbn/hearbacks/' <<< "$STAGED" | grep -v '^$' || true)"
    if [[ -n "$OUTROS" ]]; then
        guard_fail "Hearback staged JUNTO com obra ($(echo "$OUTROS" | head -3 | xargs)…) — autorização misturada com mudança é o caso-ruim canônico (ADR-023 D1b). Commit do hearback toca APENAS .hbn/hearbacks/."
        exit 1
    fi
    RC=0
    while IFS= read -r hb; do
        [[ -z "$hb" ]] && continue
        hb_disk="$(guard_version_repo_path "$hb" || echo "$hb")"
        check_signature "$hb_disk" || RC=1
    done <<< "$HB_TOUCHED"
    [[ $RC -ne 0 ]] && exit 1
    guard_ok "Diff staged toca apenas .hbn/hearbacks/ (commit puro)$(have_operator_keys && echo " com assinatura válida")."
    exit 0
fi

CHANGE_SHA="$(git rev-parse --verify "${CHANGE}^{commit}" 2>/dev/null || true)"
if [[ -z "$CHANGE_SHA" ]]; then
    guard_fail "Commit da mudança '${CHANGE}' não resolve para um commit."
    exit 1
fi
HB_REPO_PATH="$(guard_version_repo_path "$HB" || echo "$HB")"

# (1) O hearback precisa estar COMMITADO no histórico até a mudança.
HB_COMMIT="$(git log -1 --format=%H "$CHANGE_SHA" -- "$HB_REPO_PATH" 2>/dev/null || true)"
if [[ -z "$HB_COMMIT" ]]; then
    guard_fail "Hearback '${HB}' não existe no histórico até '${CHANGE}' (ADR-023 Decisão 1b: a autorização PRÉ-EXISTE à mudança; hearback staged/untracked não vale)."
    exit 1
fi

# (2) Auto-assinatura: hearback nasceu/foi alterado no MESMO commit da mudança.
if [[ "$HB_COMMIT" == "$CHANGE_SHA" ]]; then
    guard_fail "Hearback '${HB}' nasceu ou foi alterado no MESMO commit da mudança (${CHANGE_SHA:0:7}) — auto-assinatura (ADR-023: hearback é commit SEPARADO, anterior, do humano)."
    exit 1
fi

# (3) Pureza: o commit do hearback toca APENAS .hbn/hearbacks/.
IMPUROS="$(git show --name-only --format= "$HB_COMMIT" | guard_paths_to_version_paths | grep -v '^\.hbn/hearbacks/' | grep -v '^$' || true)"
if [[ -n "$IMPUROS" ]]; then
    guard_fail "O commit do hearback (${HB_COMMIT:0:7}) NÃO é puro — toca também: $(echo "$IMPUROS" | tr '\n' ' ')(ADR-023 Decisão 1b: o commit do hearback só pode tocar .hbn/hearbacks/)."
    exit 1
fi

# (4) Assinatura SSH (onda 0006 I-08 — ADR-023 D4): com chave registrada,
#     hearback sem .sig válido não autoriza; sem chave, aviso.
if ! check_signature "$HB_REPO_PATH"; then
    exit 1
fi

# (autor) Aviso — não bloqueio — enquanto identidade git única (ADR-023 Dec. 2).
A_HB="$(git show -s --format='%an <%ae>' "$HB_COMMIT")"
A_CH="$(git show -s --format='%an <%ae>' "$CHANGE_SHA")"
if [[ "$A_HB" == "$A_CH" ]]; then
    guard_warn "Autor do commit do hearback == autor da mudança (${A_HB}). Em shell compartilhado isto é o caso normal e NÃO distingue humano de IA — trava lógica PARCIAL (ADR-023 Decisão 3). Barreira final: revisão humana do diff de .hbn/hearbacks/ + assinatura SSH quando a chave estiver registrada (D4, onda 0006)."
fi

guard_ok "Hearback '${HB}' íntegro: commit puro ${HB_COMMIT:0:7}, anterior à mudança ${CHANGE_SHA:0:7}."
exit 0
