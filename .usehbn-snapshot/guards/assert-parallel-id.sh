#!/usr/bin/env bash
# =============================================================================
# guards/assert-parallel-id.sh
# path: guards/assert-parallel-id.sh · id-global: 20260610-205320-fable-5-guard-parallel-id
# Guarda G-NUM: dá dente ao ADR-024 Decisão 5 e ao ADR-025 (nome universal).
# Spec normativa: core/start-rite-spec.md §5 + ADR-025 Decisão 1-3.
#   (1) BLOQUEADOR (ADR-025, onda 0006 I-03 — INCONDICIONAL, revoga a
#       condição de `escrita_paralela` do ADR-024 D5.1): artefato NOVO em
#       série de EVENTO (.hbn/proposals|messages|results, reports/,
#       docs/prompts/) cujo nome não casa ^AAAAMMDD-HHMMSS-<agente>-<slug>.
#       com <agente> conhecido (perfis .hbn/models/ + atribuição do STATE
#       staged). Nome serial NOVO nessas séries = BLOCK. Em ciclo paralelo,
#       adicionalmente <agente> ∈ escrita_paralela. Legado serial é
#       SÓ-LEITURA: arquivo modificado (M) não dispara (diff-filter=AR).
#   (2) BLOQUEADOR: linha NOVA do REGISTRY staged sem coluna created_at
#       ISO8601 com offset, com sufixo Z/UTC (ADR-025 Decisão 2.2 — relógio
#       único é o do OPERADOR), ou com HHMMSS/data do id divergente do
#       created_at da mesma linha. Vale também FORA de ciclo paralelo. O
#       parser é column-aware: aceita o bloco legado de 6 colunas e o bloco
#       novo de 7 colunas com arvore (R2/readback 0049).
#   (3) BLOQUEADOR: dois artefatos novos com id idêntico no mesmo diff.
#
# status: accepted (adoção orquestração-start, readback 0004) — FORA do runner.
# E-FECH-01/02: lê SEMPRE o blob staged (git show :path local; HEAD:path em
#   CI via HBN_DIFF_BASE), nunca a working tree — STATE e REGISTRY incluídos.
# Interpretações registradas para cross-audit (spec §5 deixa em aberto):
#   - "pasta de série não-local" (proxy de autoria paralela, já que o diff
#     não tem autor): .hbn/proposals/, .hbn/messages/, .hbn/results/,
#     reports/, docs/prompts/. Séries locais ESTÁVEIS seguem isentas da
#     regra 1 (ADR-024 D5.2): methodology/adr/ADR-NNN, .hbn/knowledge/NNNN,
#     core/*.md e demais nomes-endereço.
#   - `escrita_paralela` é lida do bloco `atribuicao` do STATE staged; só a
#     forma inline `escrita_paralela: [a, b]` é suportada (forma da
#     start-rite-spec §3); ausente/vazia ⇒ ciclo serial.
#   - TOKEN EXATO do agente (FIX cross-audit 0030 F-01 / 0031 F-05): o
#     <agente> do nome é o apelido conhecido MAIS LONGO que casa o trecho
#     após o carimbo, comparado por igualdade (==), nunca por prefixo —
#     `alpha-1` NÃO passa como `alpha` + slug `1-…`. Universo de apelidos
#     conhecidos: atribuicao do STATE staged (orquestrador, implementador,
#     auditores, escrita_paralela) + perfis ${HBN_MODELS_DIR:-.hbn/models}.
#   - Data de id SERIAL (FIX 0031 F-01): linha nova AAAAMMDD-NN exige
#     YYYYMMDD == data do created_at da mesma linha.
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-NUM), incluindo o
#   caso de compatibilidade G-REG (risco R5 do ADR-024).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-parallel-id"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

STATE_PATH=".hbn/relay/STATE.md"
REGISTRY="REGISTRY.md"
STATE_REPO_PATH="$(guard_version_repo_path "$STATE_PATH" || true)"
REGISTRY_REPO_PATH="$(guard_version_repo_path "$REGISTRY" || true)"
if [[ -z "$STATE_REPO_PATH" || -z "$REGISTRY_REPO_PATH" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar STATE/REGISTRY da versão."
    exit 1
fi

# Blob a validar: índice (staged) localmente; HEAD em CI (E-FECH-01/02).
blob_ref() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$1"
    else
        echo ":$1"
    fi
}

state_content() {
    git show "$(blob_ref "$STATE_REPO_PATH")" 2>/dev/null || true
}

guard_added_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=AR "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=AR 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

# Linhas ADICIONADAS ao REGISTRY neste diff (staged local; range em CI).
registry_added_lines() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff "${HBN_DIFF_BASE}...HEAD" -- "$REGISTRY_REPO_PATH" 2>/dev/null
    else
        git diff --cached -- "$REGISTRY_REPO_PATH" 2>/dev/null
    fi | grep -E '^\+\|' | sed 's/^+//' || true
}

# escrita_paralela do STATE STAGED (forma inline [a, b]; ausente ⇒ vazio).
PARALELO=""
PARALELO_LINHA="$(state_content | grep -E '^[[:space:]]*escrita_paralela:' | head -1 || true)"
if [[ "$PARALELO_LINHA" =~ \[([^]]*)\] ]]; then
    PARALELO="$(echo "${BASH_REMATCH[1]}" | tr ',' ' ' | tr -d '"' | tr -d "'" | xargs || true)"
fi

# Universo de apelidos conhecidos para o casamento por TOKEN EXATO
# (0030 F-01 / 0031 F-05): atribuicao do STATE staged + perfis de modelo.
KNOWN="$PARALELO"
for key in orquestrador implementador; do
    v="$(state_content | grep -E "^[[:space:]]*${key}:" | head -1 \
        | sed -E "s/^[[:space:]]*${key}:[[:space:]]*//; s/[[:space:]]+$//" || true)"
    [[ -n "$v" && "$v" != "null" ]] && KNOWN="$KNOWN $v"
done
AUD_LINHA="$(state_content | grep -E '^[[:space:]]*auditores:' | head -1 || true)"
if [[ "$AUD_LINHA" =~ \[([^]]*)\] ]]; then
    KNOWN="$KNOWN $(echo "${BASH_REMATCH[1]}" | tr ',' ' ' | tr -d '"' | tr -d "'" | xargs || true)"
fi
ACTIVE_ROOT="$(get_canonical_root || true)"
MODELS_DIR="${HBN_MODELS_DIR:-${ACTIVE_ROOT}/.hbn/models}"
if [[ -d "$MODELS_DIR" ]]; then
    for p in "$MODELS_DIR"/*.json; do
        [[ -e "$p" ]] || continue
        KNOWN="$KNOWN $(basename "$p" .json)"
    done
fi

ADDED="$(guard_added_files)"
FAIL=0

# --- Regra 1 (ADR-025 D1, INCONDICIONAL): nome universal em série de evento --
is_event_series_path() {
    case "$1" in
        .hbn/proposals/*|.hbn/messages/*|.hbn/results/*|reports/*|docs/prompts/*) return 0 ;;
    esac
    return 1
}

if [[ -n "$ADDED" ]]; then
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        is_event_series_path "$f" || continue
        base="$(basename "$f")"
        # Captura por TOKEN EXATO (0030 F-01 / 0031 F-05): o agente do nome
        # é o apelido conhecido MAIS LONGO que casa após o carimbo; match
        # por igualdade ==, nunca prefixo.
        rest=""
        if [[ "$base" =~ ^[0-9]{8}-[0-9]{6}-(.+)$ ]]; then
            rest="${BASH_REMATCH[1]}"
        fi
        token=""
        if [[ -n "$rest" ]]; then
            for k in $KNOWN; do
                [[ "$rest" == "$k"-* ]] || continue
                slug="${rest#"$k"-}"
                [[ "$slug" =~ ^[a-z0-9][a-z0-9-]*\. ]] || continue
                if (( ${#k} > ${#token} )); then token="$k"; fi
            done
        fi
        if [[ -z "$rest" ]]; then
            guard_fail "Artefato NOVO em série de evento '${f}' sem nome ^AAAAMMDD-HHMMSS-<agente>-<slug> (ADR-025 Decisão 1 — regra INCONDICIONAL, F-03 dos cross-audits 0036/0037: nome serial novo nessas séries = BLOCK; legado serial é só-leitura e não se renomeia)."
            FAIL=1
        elif [[ -z "$token" ]]; then
            guard_fail "Artefato NOVO em série de evento '${f}': <agente> não reconhecido após o carimbo (universo: perfis ${MODELS_DIR} + atribuição do STATE staged; token exato, não prefixo — 0030 F-01 / 0031 F-05). ADR-025 Decisão 1."
            FAIL=1
        elif [[ -n "$PARALELO" ]]; then
            ok=0
            for ag in $PARALELO; do
                if [[ "$token" == "$ag" ]]; then
                    ok=1
                    break
                fi
            done
            if [[ "$ok" -ne 1 ]]; then
                guard_fail "Ciclo PARALELO (escrita_paralela: ${PARALELO}) e '${f}' tem agente '${token}' fora de escrita_paralela do STATE staged (start-rite-spec §5.1 — escritor paralelo não declarado no rito)."
                FAIL=1
            fi
        fi
    done <<< "$ADDED"
fi

# --- Regra 2: linha nova do REGISTRY exige created_at coerente ---------------
ISO_RE='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{2}:[0-9]{2}$'
registry_last_cell() {
    awk -F'|' '{ idx=NF-1; gsub(/^[ \t]+|[ \t]+$/,"",$idx); print $idx }' <<< "$1"
}
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    id_col="$(awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$2); print $2}' <<< "$line")"
    [[ -z "$id_col" || "$id_col" == "id" ]] && continue
    [[ "$id_col" =~ ^:?-+:?$ ]] && continue
    created="$(registry_last_cell "$line")"
    if [[ -z "$created" || "$created" == "—" ]]; then
        guard_fail "Linha nova do ${REGISTRY} staged sem coluna created_at: '| ${id_col} | …' (ADR-024 Decisão 5.3 + R2/readback 0049: linhas novas usam created_at como ultima coluna, em bloco legado de 6 colunas ou novo de 7 colunas com arvore)."
        FAIL=1
        continue
    fi
    if [[ "$created" =~ (Z|z|[+-]00:00)$ ]]; then
        guard_fail "Linha nova do ${REGISTRY} staged com created_at '${created}' em UTC — relógio único é a hora LOCAL do OPERADOR com offset explícito (ADR-025 Decisão 2.2; F-02 do cross-audit: o 0035 nasceu em Z e divergiu do REGISTRY)."
        FAIL=1
        continue
    fi
    if [[ ! "$created" =~ $ISO_RE ]]; then
        guard_fail "Linha nova do ${REGISTRY} staged com created_at '${created}' fora de ISO8601 com offset explícito (ADR-024 Decisão 5.4 — ex.: 2026-06-10T20:52:05-03:00)."
        FAIL=1
        continue
    fi
    if [[ "$id_col" =~ ^([0-9]{8})-([0-9]{6})- ]]; then
        id_ymd="${BASH_REMATCH[1]}" ; id_hms="${BASH_REMATCH[2]}"
        ct_ymd="${created:0:4}${created:5:2}${created:8:2}"
        ct_hms="${created:11:2}${created:14:2}${created:17:2}"
        if [[ "$id_ymd" != "$ct_ymd" || "$id_hms" != "$ct_hms" ]]; then
            guard_fail "Linha '${id_col}' do ${REGISTRY} staged: id declara ${id_ymd}-${id_hms} mas created_at é ${created} — o HHMMSS do id DERIVA do mesmo carimbo (ADR-024 Decisão 5.4); um dos dois é de memória."
            FAIL=1
        fi
    elif [[ "$id_col" =~ ^([0-9]{8})-[0-9]{2}$ ]]; then
        # FIX 0031 F-01: id SERIAL também tem data autoritativa no created_at.
        id_ymd="${BASH_REMATCH[1]}"
        ct_ymd="${created:0:4}${created:5:2}${created:8:2}"
        if [[ "$id_ymd" != "$ct_ymd" ]]; then
            guard_fail "Linha '${id_col}' do ${REGISTRY} staged: id serial declara data ${id_ymd} mas created_at é ${created} — a data do id DERIVA do mesmo carimbo (ADR-024 Decisão 5.4; cross-audit 0031 F-01); um dos dois é de memória."
            FAIL=1
        fi
    fi
done <<< "$(registry_added_lines)"

# --- Regra 3: id idêntico em dois artefatos novos do mesmo diff --------------
if [[ -n "$ADDED" ]]; then
    DUP="$(while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        b="$(basename "$f")"
        if [[ "$b" =~ ^[0-9]{8}-[0-9]{6}- ]]; then
            echo "${b%.*}"
        elif [[ "$b" =~ ^([0-9]{8}-[0-9]{2})- ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    done <<< "$ADDED" | sort | uniq -d)"
    if [[ -n "$DUP" ]]; then
        guard_fail "Dois artefatos novos com id idêntico no mesmo diff: $(echo "$DUP" | xargs) (start-rite-spec §5.3 — colisão de numeração)."
        FAIL=1
    fi
fi

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

if [[ -n "$PARALELO" ]]; then
    guard_ok "Ciclo paralelo (${PARALELO}): nomes AAAAMMDD-HHMMSS-<agente> ok; linhas novas do REGISTRY com created_at coerente; sem id duplicado."
else
    guard_ok "Nomes de série de evento conformes (ADR-025, incondicional); linhas novas do REGISTRY com created_at coerente (sem UTC); sem id duplicado."
fi
exit 0
