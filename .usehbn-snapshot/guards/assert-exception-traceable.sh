#!/usr/bin/env bash
# =============================================================================
# guards/assert-exception-traceable.sh
# path: guards/assert-exception-traceable.sh · id-global: 20260611-161405-fable5-guard-exception-traceable
# Guarda G-EXC: exceção rastreável (F-01 BLOQUEADOR dos cross-audits 0036 P7
# / 0037 P7) — quando o implementador da atribuição do STATE é o MESMO agente
# do readback ativo (desenhista=implementador=commitador, o caso do readback
# 0005), a onda só anda com 4 SINAIS SIMULTÂNEOS:
#   (a) authorization{} no readback ativo com citação humana (human+evidence);
#   (b) trailer `HBN-Readback: <id>` no commit;
#   (c) trailer `HBN-Human-Authorization: <ref>` no commit;
#   (d) sinal 🔴 de exceção em sinais_abertos do STATE staged + marca
#       PROPOSED_UNTIL_CROSS_AUDIT (adoção posterior exige 2 pareceres de
#       famílias ≠ do implementador + hearback humano).
# Faltando QUALQUER sinal visível no ponto de checagem → BLOCK.
#
# DIVISÃO DE VISIBILIDADE (desenho §4.1 — documentada aqui por ordem):
#   - pre-commit (runner, SEM argumento): os trailers do commit EM CURSO
#     ainda não existem — valida (a) e (d), os sinais legíveis
#     (readback ativo + STATE staged/HEAD).
#   - commit-msg (argumento = arquivo da mensagem): valida (b) e (c) no
#     texto da mensagem em curso (o hook commit-msg do I-13 chama assim).
#   - CI (HBN_DIFF_BASE não-vazio): valida (b) e (c) no texto bruto (%B) de
#     TODOS os commits do range pushed, igual ao commit-msg local.
#
# status: criado na onda 0006 (I-08) com testes negativos verdes (ADR-020);
#   ENTRA NO RUNNER no commit I-09 — junto com o 4º sinal no STATE, porque
#   ativá-lo antes bloquearia a própria onda 0006 (e o guard estaria CERTO:
#   o sinal ainda não existia no STATE).
# Fix 0027: CI deixou de usar %(trailers), porque o parser nativo normaliza
# trailers separados por linha em branco. O guard usa %B.
# W2/readback 0034: a busca dos trailers fica ancorada no ultimo paragrafo
# nao-vazio da mensagem, fechando falso verde de prosa no corpo.
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-EXC).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-exception-traceable"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MSG_FILE="${1:-}"
STATE_PATH=".hbn/relay/STATE.md"
STATE_REPO_PATH="$(guard_version_repo_path "$STATE_PATH" || true)"
ACTIVE_ROOT="$(get_canonical_root || true)"
if [[ -z "$STATE_REPO_PATH" || -z "$ACTIVE_ROOT" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar STATE/readbacks da versão ativa."
    exit 1
fi
READBACKS_DIR="${HBN_READBACKS_DIR:-${ACTIVE_ROOT}/.hbn/readbacks}"

blob_ref() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$1"
    else
        echo ":$1"
    fi
}

state_content() {
    git show "$(blob_ref "$STATE_REPO_PATH")" 2>/dev/null || cat "${ACTIVE_ROOT}/${STATE_PATH}" 2>/dev/null || true
}

# Readback ativo = último numérico (mesma regra do G-SCO); conteúdo do blob
# staged quando disponível (E-FECH-01), senão do disco (readbacks são
# force-added; untracked recém-criado também governa — G-SCO já o lê assim).
ACTIVE_RB="$(ls -1 "${READBACKS_DIR}"/[0-9]*.json 2>/dev/null | sort | tail -1 || true)"
ACTIVE_RB_REPO_PATH=""
if [[ -n "$ACTIVE_RB" ]]; then
    ACTIVE_RB_REPO_PATH="$(guard_version_repo_path ".hbn/readbacks/$(basename "$ACTIVE_RB")" || true)"
fi
rb_content() {
    [[ -z "$ACTIVE_RB" ]] && return 0
    git show "$(blob_ref "$ACTIVE_RB_REPO_PATH")" 2>/dev/null || cat "$ACTIVE_RB" 2>/dev/null || true
}

if [[ -z "$ACTIVE_RB" ]]; then
    guard_ok "Sem readback ativo — sem exceção a rastrear."
    exit 0
fi

AGENT_ID="$(rb_content | grep -oE '"agent_id"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/' || true)"
IMPL="$(state_content | grep -E '^[[:space:]]*implementador:' | head -1 \
    | sed -E 's/^[[:space:]]*implementador:[[:space:]]*//; s/["'"'"']//g; s/[[:space:]]+$//' || true)"

if [[ -z "$AGENT_ID" || -z "$IMPL" || "$AGENT_ID" != "$IMPL" ]]; then
    guard_ok "Implementador do STATE ('${IMPL:-—}') ≠ agente do readback ativo ('${AGENT_ID:-—}') — sem exceção F-01 em curso."
    exit 0
fi

guard_log "EXCEÇÃO EM CURSO: implementador == agente do readback ativo (${AGENT_ID}). Exigindo sinais (F-01)."
FAIL=0

# --- Sinais (a)+(d): SO no modo pre-commit (runner, sem argumento) ----------
# Alinhamento ao contrato do header (secao DIVISAO DE VISIBILIDADE): em
# commit-msg (MSG_FILE nao-vazio) e em CI (HBN_DIFF_BASE nao-vazio) o STATE
# staged pode preceder o commit que cria os sinais (a)/(d) — ex.: o pick de
# I-08 sobre a main ainda SEM o 🔴 de excecao. Checa-los nesses modos
# reintroduz o deadlock C-03c (mesma classe corrigida no G-TOK): o guard
# bloquearia o proprio commit que criaria o sinal. (b)/(c) abaixo cobrem
# commit-msg e CI; aqui validamos so os sinais legiveis do pre-commit.
# (bash ignora indentacao: o bloco abaixo permanece sem reindentar de proposito
#  para preservar byte-a-byte o here-string Python do sinal (a).)
if [[ -z "$MSG_FILE" && -z "${HBN_DIFF_BASE:-}" ]]; then
# --- Sinal (a): authorization{} com citação humana no readback ---------------
AUTH_OK="$(rb_content | python3 -c '
import json, sys
try:
    rb = json.load(sys.stdin)
    a = rb.get("authorization") or {}
    print("ok" if (a.get("human") or "").strip() and (a.get("evidence") or "").strip() else "no")
except Exception:
    print("no")
' 2>/dev/null || echo "no")"
if [[ "$AUTH_OK" != "ok" ]]; then
    guard_fail "Sinal (a) AUSENTE: readback ativo $(basename "$ACTIVE_RB") sem bloco authorization{human, evidence} com citação humana (F-01 — exceção sem ordem rastreável não anda)."
    FAIL=1
fi

# --- Sinal (d): 🔴 de exceção + PROPOSED_UNTIL_CROSS_AUDIT no STATE ----------
EXC_SIGNAL_COUNT="$(state_content | grep -E '^[[:space:]]*-' | grep '🔴' | grep -ciE 'exce' || true)"
if [[ "${EXC_SIGNAL_COUNT:-0}" -eq 0 ]]; then
    guard_fail "Sinal (d) AUSENTE: STATE staged sem sinal 🔴 de EXCEÇÃO em sinais_abertos (F-01 — a exceção precisa estar visível a quem retoma)."
    FAIL=1
fi
PROPOSED_SIGNAL_COUNT="$(state_content | grep -c 'PROPOSED_UNTIL_CROSS_AUDIT' || true)"
if [[ "${PROPOSED_SIGNAL_COUNT:-0}" -eq 0 ]]; then
    guard_fail "Sinal (d) INCOMPLETO: STATE staged sem a marca PROPOSED_UNTIL_CROSS_AUDIT — adoção da exceção exige 2 pareceres de famílias ≠ implementador + hearback humano (0036 P7)."
    FAIL=1
fi

fi  # fim dos sinais (a)+(d) restritos ao pre-commit

# --- Sinais (b)+(c): trailers — onde forem legíveis ---------------------------
last_paragraph() {
    awk '
        /^[[:space:]]*$/ {
            if (current != "") {
                last = current
                current = ""
            }
            next
        }
        {
            current = current (current == "" ? "" : "\n") $0
        }
        END {
            if (current != "") {
                last = current
            }
            print last
        }
    '
}

require_trailers_in() { # <texto> <origem-para-log>
    local txt="$1" origem="$2" trailer_block miss=0
    trailer_block="$(printf '%s\n' "$txt" | last_paragraph)"
    grep -qE '^HBN-Readback:[[:space:]]*[^[:space:]]' <<< "$trailer_block" || { guard_fail "Sinal (b) AUSENTE em ${origem}: trailer 'HBN-Readback: <id>' no ultimo paragrafo."; miss=1; }
    grep -qE '^HBN-Human-Authorization:[[:space:]]*[^[:space:]]' <<< "$trailer_block" || { guard_fail "Sinal (c) AUSENTE em ${origem}: trailer 'HBN-Human-Authorization: <ref>' no ultimo paragrafo."; miss=1; }
    return $miss
}

if [[ -n "$MSG_FILE" ]]; then
    if [[ ! -f "$MSG_FILE" ]]; then
        guard_fail "Arquivo de mensagem '${MSG_FILE}' não encontrado (uso: assert-exception-traceable.sh [<commit-msg-file>])."
        FAIL=1
    elif ! require_trailers_in "$(cat "$MSG_FILE")" "mensagem do commit em curso"; then
        FAIL=1
    fi
elif [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    while IFS= read -r c; do
        [[ -z "$c" ]] && continue
        if ! require_trailers_in "$(git log -1 --format='%B' "$c")" "commit ${c:0:7} do range pushed"; then
            FAIL=1
        fi
    done <<< "$(git rev-list "${HBN_DIFF_BASE}..HEAD" 2>/dev/null || true)"
else
    guard_log "Sinais (b)/(c): trailers do commit EM CURSO não são legíveis no pre-commit — cobertos pelo hook commit-msg (G-EXC com argumento) e pelo CI via range (header deste guard)."
fi

if [[ "$FAIL" -ne 0 ]]; then
    echo "  Exceção F-01 SEM os sinais exigidos. Como corrigir:" >&2
    echo "    1. authorization{human,evidence} no readback ativo (citação da ordem humana)" >&2
    echo "    2. sinal 🔴 de exceção + PROPOSED_UNTIL_CROSS_AUDIT no STATE staged" >&2
    echo "    3. trailers HBN-Readback e HBN-Human-Authorization em TODO commit da onda" >&2
    echo "    4. adoção: 2 pareceres de famílias ≠ implementador + hearback humano" >&2
    exit 1
fi

guard_ok "Exceção F-01 RASTREÁVEL: authorization no readback, sinais no STATE$( [[ -n "$MSG_FILE" || -n "${HBN_DIFF_BASE:-}" ]] && echo ", trailers verificados" ) — PROPOSED_UNTIL_CROSS_AUDIT vigente."
exit 0
