#!/usr/bin/env bash
# =============================================================================
# guards/assert-report-fresh.sh
# path: guards/assert-report-fresh.sh · id-global: 20260610-205340-fable-5-guard-report-fresh
# Guarda G-RLT: dá dente ao ADR-024 Decisões 4 e 6 (Relato de Estado fresco).
# Spec normativa: core/state-report-spec.md §4.
#   (1) BLOQUEADOR: handoff staged em .hbn/messages/ sem bloco RELATO DE ESTADO.
#   (2) BLOQUEADOR: PRÓXIMA AÇÃO do relato ≠ proxima_acao do STATE STAGED
#       (igualdade EXATA de string — paráfrase não conta).
#   (3) BLOQUEADOR: ultima_atualizacao citado no relato ≠ o do STATE STAGED
#       (valor que só existe no arquivo novo denuncia relato de memória).
#   (4) BLOQUEADOR: chapéu orquestrador sem o heading EXATO
#       `^## Decisões informais \(cápsula\)$` (ADR-024 Decisão 6; FIX
#       cross-audit 0030 F-02 — substring solta '(cápsula)' não conta).
#       Header do relato fora da forma fixa §1 também BLOQUEIA (0031 F-03).
#   (5) AVISO: bloco de relato com >10 linhas (inflação — ADR-022).
#   (6) BLOQUEADOR (onda 0006 I-10 — spec §5, rito de entrada checável):
#       handoff com `tipo: entrada` no front-matter exige heading EXATO
#       `## RELATO DE LEITURA` com ≥1 item, e CADA item com citação
#       arquivo:linha (prova de leitura do disco — Truth Barrier).
#
# status: accepted (adoção orquestração-start, readback 0004) — FORA do runner.
# E-FECH-01/02: handoff E STATE são lidos do blob STAGED (git show :path;
#   HEAD:path em CI), nunca da working tree — STATE bom só na working tree
#   com staged velho DEVE bloquear (caso de skew na suíte).
# Fecha o triângulo com o guard-state-fresh (relay-spec): aquele garante
#   STATE ↔ handoff; este garante RELATO ↔ STATE (state-report-spec §3).
# Teste negativo: guards/tests/run-guard-tests.sh (seção G-RLT).
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-report-fresh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

STATE_PATH=".hbn/relay/STATE.md"

blob_ref() {
    local p
    p="$(guard_version_repo_path "$1")" || return 1
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        echo "HEAD:$p"
    else
        echo ":$p"
    fi
}

# Handoffs tocados neste diff (A/M/R — "commit que toca handoff", spec §4).
HANDOFFS="$(guard_diff_files | grep -E '^\.hbn/messages/.*\.md$' || true)"
if [[ -z "$HANDOFFS" ]]; then
    guard_ok "Nenhum handoff em .hbn/messages/ no diff."
    exit 0
fi

STATE_CONTENT="$(git show "$(blob_ref "$STATE_PATH")" 2>/dev/null || true)"
if [[ -z "$STATE_CONTENT" ]]; then
    guard_fail "Handoff staged mas ${STATE_PATH} inexistente na revisão staged — não há STATE contra o qual conferir o relato (state-report-spec §4; E-FECH-02)."
    exit 1
fi

# Valor de uma chave simples do front-matter do STATE (strip de aspas).
state_value() {
    local line
    line="$(grep -E "^${1}:" <<< "$STATE_CONTENT" | head -1 || true)"
    line="${line#"${1}":}"
    line="$(echo "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/^["'"'"']//; s/["'"'"']$//')"
    echo "$line"
}

STATE_PROXIMA="$(state_value proxima_acao)"
STATE_ULTIMA="$(state_value ultima_atualizacao)"

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    ref="$(blob_ref "$f")"
    git cat-file -e "$ref" 2>/dev/null || continue
    content="$(git show "$ref" 2>/dev/null || true)"

    # Regra 1: bloco RELATO DE ESTADO presente.
    if ! grep -qF 'RELATO DE ESTADO' <<< "$content"; then
        guard_fail "Handoff '${f}' sem bloco RELATO DE ESTADO (state-report-spec §1: todo bastão sai com o relato fixo de ≤10 linhas)."
        FAIL=1
        continue
    fi

    # Bloco: do header até PARA O HUMANO (ou linha em branco/EOF).
    bloco="$(awk '/RELATO DE ESTADO/{f=1} f && /^[[:space:]]*$/{exit} f{print} f && /^PARA O HUMANO/{exit}' <<< "$content")"
    nlinhas="$(wc -l <<< "$bloco" | xargs)"

    # Regra 5 (AVISO): inflação de relato.
    if [[ "$nlinhas" -gt 10 ]]; then
        guard_warn "Relato de Estado em '${f}' com ${nlinhas} linhas (>10) — inflação de relato (ADR-022; state-report-spec §1)."
    fi

    # Regra 2: PRÓXIMA AÇÃO == STATE.proxima_acao (string exata).
    pa_line="$(grep -F 'PRÓXIMA AÇÃO:' <<< "$bloco" | head -1 || true)"
    if [[ -z "$pa_line" ]]; then
        guard_fail "Relato em '${f}' sem linha PRÓXIMA AÇÃO (state-report-spec §1)."
        FAIL=1
    else
        pa="${pa_line#*PRÓXIMA AÇÃO:}"
        pa="$(echo "$pa" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        if [[ "$pa" != "$STATE_PROXIMA" ]]; then
            guard_fail "Relato em '${f}': PRÓXIMA AÇÃO '${pa}' ≠ proxima_acao do STATE staged '${STATE_PROXIMA}' (state-report-spec §2.2: igualdade EXATA, não paráfrase; E-FECH-02: o STATE que vale é o staged)."
            FAIL=1
        fi
    fi

    # Regra 3: ultima_atualizacao citado == o do STATE staged.
    ua_line="$(grep -F 'ultima_atualizacao=' <<< "$bloco" | head -1 || true)"
    if [[ -z "$ua_line" ]]; then
        guard_fail "Relato em '${f}' não cita ultima_atualizacao= na linha STATE (state-report-spec §2.1: o valor exato do arquivo é a prova de que houve leitura do disco)."
        FAIL=1
    else
        ua="${ua_line#*ultima_atualizacao=}"
        ua="${ua%% *}"
        if [[ "$ua" != "$STATE_ULTIMA" ]]; then
            guard_fail "Relato em '${f}': ultima_atualizacao citado '${ua}' ≠ '${STATE_ULTIMA}' do STATE staged — relato de MEMÓRIA (ADR-020; state-report-spec §2.1)."
            FAIL=1
        fi
    fi

    # Regra 6 (onda 0006 I-10 — spec §5): rito de ENTRADA checável.
    tipo_fm="$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' <<< "$content" \
        | grep -E '^tipo:' | head -1 | sed -E 's/^tipo:[[:space:]]*//; s/["'"'"']//g; s/[[:space:]]+$//' || true)"
    if [[ "$tipo_fm" == "entrada" ]]; then
        if ! grep -qE '^## RELATO DE LEITURA$' <<< "$content"; then
            guard_fail "Handoff de ENTRADA '${f}' (tipo: entrada) sem o heading EXATO '## RELATO DE LEITURA' (state-report-spec §5: a entrada de janela prova a leitura da read-list)."
            FAIL=1
        else
            itens="$(awk '/^## RELATO DE LEITURA$/{f=1; next} f && /^#/{exit} f' <<< "$content" \
                | grep -E '^[[:space:]]*([-*]|[0-9]+\.)[[:space:]]' || true)"
            if [[ -z "$itens" ]]; then
                guard_fail "RELATO DE LEITURA vazio em '${f}' — a entrada exige ≥1 item da read-list com citação (spec §5.2)."
                FAIL=1
            else
                while IFS= read -r item; do
                    [[ -z "$item" ]] && continue
                    if ! grep -qE '[A-Za-z0-9_./-]+\.(md|sh|json|ya?ml|txt):[0-9]+' <<< "$item"; then
                        guard_fail "Item do RELATO DE LEITURA em '${f}' SEM citação arquivo:linha: '$(echo "$item" | cut -c1-70)…' (spec §5.2 — citação é a prova de leitura do disco, Truth Barrier)."
                        FAIL=1
                    fi
                done <<< "$itens"
            fi
        fi
    fi

    # Regra 4: chapéu orquestrador exige seção de cápsula no handoff.
    # FIX 0031 F-03: parser do chapéu por campo (awk -F'·'), não por sufixo
    # de string — header fora da forma fixa da spec §1 BLOQUEIA em vez de
    # capturar lixo (anti-teatro: relato malformado não dribla a regra).
    header="$(grep -F 'RELATO DE ESTADO' <<< "$content" | head -1)"
    chapeu="$(awk -F'·' '{ if (NF >= 3) { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2 } }' <<< "$header")"
    if [[ -z "$chapeu" ]]; then
        guard_fail "Header do RELATO em '${f}' fora da forma fixa '— <apelido> · <chapéu> · <carimbo>' (state-report-spec §1; 0031 F-03) — chapéu não extraível."
        FAIL=1
    elif [[ "$chapeu" == *orquestrador* ]]; then
        # FIX 0030 F-02: heading EXATO, não substring — '(cápsula)' solto
        # em qualquer linha não satisfaz a Decisão 6.
        if ! grep -qE '^## Decisões informais \(cápsula\)$' <<< "$content"; then
            guard_fail "Handoff '${f}' de chapéu '${chapeu}' sem o heading EXATO '## Decisões informais (cápsula)' (ADR-024 Decisão 6; state-report-spec §2.4; 0030 F-02 — menção solta a '(cápsula)' não conta; vazia = 'nenhuma')."
            FAIL=1
        fi
    fi
done <<< "$HANDOFFS"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Todo relato staged é fresco: PRÓXIMA AÇÃO e ultima_atualizacao idênticos ao STATE staged; cápsula presente onde devida."
exit 0
