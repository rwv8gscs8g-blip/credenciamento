#!/usr/bin/env bash
# =============================================================================
# guards/assert-baton-token.sh
# path: guards/assert-baton-token.sh · id-global: 20260611-161804-fable5-guard-baton-token
# Guarda G-TOK v2: token de POSSE do bastão (onda 0006 I-13 — pedido do gate
# humano; redesenho v2 pelos bloqueadores B1/B3 dos pareceres 170633/172049).
# O bastão deixa de ser uma string declarada no STATE (que qualquer janela
# pode escrever) e passa a ter prova de posse SEM segredo no histórico:
#   - o HUMANO gera o token (`openssl rand -hex 16`) e o entrega SÓ à janela
#     detentora; o token vive APENAS em `.git/hbn-baton-token` (dentro de
#     `.git/`, jamais versionável por construção);
#   - o STATE versiona apenas o HASH: campo `bastao_token_sha256: <hex>`
#     (state-report-spec §6);
#   - todo commit local exige: (1) sha256(arquivo local) == campo do STATE
#     STAGED (posse); (2) trailer `HBN-Token-FP: <8 hex>` == primeiros 8 hex
#     do campo (fingerprint PÚBLICO, não-segredo — rastreia QUAL token
#     assinou sem revelá-lo). Replay por leitura do log é impossível: o log
#     só tem o fingerprint, e o fingerprint não abre o hook;
#   - ROTAÇÃO obrigatória a cada passagem de bastão: arquivo novo + hash novo
#     no MESMO commit do handoff (o token antigo deixa de validar).
#
# O QUE PROVA / NÃO PROVA: ver core/state-report-spec.md §6 (declaração
# honesta: posse do arquivo local entregue pelo humano; NÃO prova posse
# exclusiva nem identidade; em CI prova só consistência do fingerprint).
#
# Modos:
#   assert-baton-token.sh <commit-msg-file>   ← hook commit-msg (uso normal)
#   HBN_DIFF_BASE=<sha> assert-baton-token.sh ← CI: fingerprint dos commits
#       do range vs hash do STATE em HEAD (consistência, não posse — o
#       runner de CI não tem nem deve ter o arquivo de token)
#
# Regras: campo presente + arquivo ausente → BLOCK; arquivo com token errado
#   → BLOCK; trailer ausente ou fingerprint ≠ hash → BLOCK; campo AUSENTE ou
#   vazio → exigência inativa (rampa: o hash entra no STATE na cerimônia de
#   token, APÓS o último cherry-pick — tabela v2), SALVO
#   HBN_REQUIRE_BATON_TOKEN=1 (política de CI/branch) em que campo ausente
#   também BLOQUEIA.
#
# INSTALAÇÃO (runbook — hook TOLERANTE, correção C-03a do parecer 170633:
# guard ausente no worktree = avisa e libera; antes dos cherry-picks de
# I-08/I-13 os guards não existem na main e o hook não pode quebrá-la):
#   cat > .git/hooks/commit-msg <<'EOF'
#   #!/usr/bin/env bash
#   TOP="$(git rev-parse --show-toplevel)"
#   for g in assert-baton-token.sh assert-exception-traceable.sh; do
#       if [ -f "$TOP/guards/$g" ]; then
#           bash "$TOP/guards/$g" "$1" || exit 1
#       else
#           echo "hook commit-msg: guards/$g ausente no worktree — liberado (vale após o cherry-pick que o cria)" >&2
#       fi
#   done
#   exit 0
#   EOF
#   chmod +x .git/hooks/commit-msg
#
# Compatibilidade: Bash 3.2 (macOS) — sem ${var,,}/${var^^}, sem mapfile,
#   sem arrays associativos (precedente: assert-scope-lock.sh, nota de
#   compatibilidade); normalização de caixa via tr.
# status: criado na onda 0006 (I-13); v2 na onda 0006-v2 (correções C-01/
#   C-02/C-03 dos pareceres 20260611-170633-codex / 20260611-172049-gemini).
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-TOK).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-baton-token"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

MSG_FILE="${1:-}"
STATE_PATH=".hbn/relay/STATE.md"
STATE_REPO_PATH="$(guard_version_repo_path "$STATE_PATH" || true)"
if [[ -z "$STATE_REPO_PATH" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar o STATE da versão ativa."
    exit 1
fi

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$1" | sha256sum | awk '{print $1}'
    else
        printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
    fi
}

lc() { # minúsculas — compatível com Bash 3.2 (sem ${var,,})
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

state_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${STATE_REPO_PATH}" 2>/dev/null || true
    else
        git show ":${STATE_REPO_PATH}" 2>/dev/null || true
    fi
}

EXPECTED="$(state_content | grep -E '^[[:space:]]*bastao_token_sha256:' | head -1 \
    | sed -E 's/^[[:space:]]*bastao_token_sha256:[[:space:]]*//; s/["'"'"']//g; s/[[:space:]]+$//' || true)"
EXPECTED="$(lc "$EXPECTED")"

if [[ -z "$EXPECTED" ]]; then
    if [[ "${HBN_REQUIRE_BATON_TOKEN:-0}" == "1" ]]; then
        guard_fail "STATE staged sem campo bastao_token_sha256 e HBN_REQUIRE_BATON_TOKEN=1 — a política exige token de posse do bastão (onda 0006 I-13). O humano gera (openssl rand -hex 16), grava em .git/hbn-baton-token e o sha256 no STATE (cerimônia da tabela v2)."
        exit 1
    fi
    guard_ok "bastao_token_sha256 ausente/vazio no STATE — exigência de token inativa (rampa I-13; ativa na cerimônia de token, após o último cherry-pick)."
    exit 0
fi

EXPECTED_FP="$(printf '%s' "$EXPECTED" | cut -c1-8)"

# Arquivo local do token: .git/hbn-baton-token (resolve worktrees via
# --git-common-dir; fallback --git-dir para gits antigos).
token_file_path() {
    local gd
    gd="$(git rev-parse --git-common-dir 2>/dev/null || true)"
    [[ -z "$gd" ]] && gd="$(git rev-parse --git-dir 2>/dev/null || echo .git)"
    case "$gd" in
        /*) ;;
        *) gd="$(git rev-parse --show-toplevel)/$gd" ;;
    esac
    printf '%s/hbn-baton-token' "$gd"
}

check_possession() { # posse: sha256(arquivo local) == hash do STATE staged
    local tf tok
    tf="$(token_file_path)"
    if [[ ! -f "$tf" ]]; then
        guard_fail "Arquivo de token AUSENTE (${tf}) com bastao_token_sha256 ativo no STATE — esta janela/clone NÃO detém o bastão. O token é entregue pelo humano SÓ à janela detentora (state-report-spec §6)."
        return 1
    fi
    tok="$(tr -d '[:space:]' < "$tf")"
    if [[ "$(sha256_of "$tok")" != "$EXPECTED" ]]; then
        guard_fail "Token do arquivo local INVÁLIDO: sha256(.git/hbn-baton-token) ≠ bastao_token_sha256 do STATE staged (token errado ou de bastão anterior; rotação a cada handoff)."
        return 1
    fi
    return 0
}

check_msg_fp() { # rastro: trailer HBN-Token-FP == primeiros 8 hex do hash
    local txt="$1" origem="$2" fp
    fp="$(grep -E '^HBN-Token-FP:' <<< "$txt" | head -1 | sed -E 's/^HBN-Token-FP:[[:space:]]*//; s/[[:space:]]+$//' || true)"
    if [[ -z "$fp" ]]; then
        guard_fail "Sem trailer 'HBN-Token-FP: <8 hex>' em ${origem} — com bastao_token_sha256 ativo, todo commit carrega o fingerprint público do token (rastreia QUAL token assinou sem revelá-lo; state-report-spec §6)."
        return 1
    fi
    if [[ "$(lc "$fp")" != "$EXPECTED_FP" ]]; then
        guard_fail "Fingerprint INVÁLIDO em ${origem}: HBN-Token-FP ≠ primeiros 8 hex de bastao_token_sha256 do STATE (fingerprint de token errado ou de bastão anterior)."
        return 1
    fi
    return 0
}

if [[ -n "$MSG_FILE" ]]; then
    if [[ ! -f "$MSG_FILE" ]]; then
        guard_fail "Uso: assert-baton-token.sh <commit-msg-file> (arquivo '${MSG_FILE}' não encontrado)."
        exit 1
    fi
    check_possession || exit 1
    check_msg_fp "$(cat "$MSG_FILE")" "mensagem do commit em curso" || exit 1
elif [[ -n "${HBN_DIFF_BASE:-}" ]]; then
    # CI: só consistência do fingerprint (o runner não tem o arquivo de token).
    RC=0
    while IFS= read -r c; do
        [[ -z "$c" ]] && continue
        check_msg_fp "$(git log -1 --format='%(trailers)' "$c")" "commit ${c:0:7} do range pushed" || RC=1
    done <<< "$(git rev-list "${HBN_DIFF_BASE}..HEAD" 2>/dev/null || true)"
    [[ $RC -ne 0 ]] && exit 1
else
    guard_fail "Uso: assert-baton-token.sh <commit-msg-file> (hook commit-msg) ou HBN_DIFF_BASE=<sha> (CI). Sem mensagem nem range não há o que conferir."
    exit 1
fi

guard_ok "Posse do bastão comprovada: sha256(.git/hbn-baton-token) == bastao_token_sha256 do STATE staged; fingerprint do trailer confere."
exit 0
