#!/usr/bin/env bash
# =============================================================================
# guards/assert-registry-line.sh
# Guarda G-REG: dá dente ao ADR-011.
#   (1) Recusa commit que ADICIONE artefato de tipo numerado (ADR-011 Decisão 2)
#       sem a linha correspondente no REGISTRY.md no MESMO commit.
#   (2) Recusa commit que ADICIONE prompt/doc solto na raiz do canônico sem
#       id AAAAMMDD-NN (o anti-padrão dos PROMPT_*.md órfãos de 2026-06-10,
#       criados por orquestrador ignorando a regra que ele mesmo deveria servir).
#
# status: accepted (correntes D/E + fechamento E, readbacks 0002/0003, 2026-06-10) — ESTA no runner.
#   Ativado em hbn-guards-runner.sh após testes negativos de todos os guards
#   cobertos pela suíte.
# Padrão C3: usa guard_diff_files (staged local; HBN_DIFF_BASE...HEAD em CI).
# Knowledge 0021: em sandbox o guard é informativo; conclusivo no Terminal.
# Escopo: arquivos ADICIONADOS ou RENOMEADOS (diff-filter=AR — rename gera
#   path novo que re-paga a linha; F-01 marginal da re-auditoria 0026).
#   Tocar arquivo legado existente (M) não dispara — o legado é mapeado pela
#   seção "Legado" do REGISTRY.
# ADR-020 (anti-teatro, corrente E):
#   (a) casamento de path no REGISTRY é EXATO por coluna de tabela (| path |),
#       nunca substring (bug F-02 da auditoria 0022 — 'ADR-01' casava 'ADR-011');
#       consequência: artefato novo exige a SUA linha, 1 artefato por linha;
#   (b) cobertura ampliada: core/*.md, .hbn/models/*.json, .github/workflows/*
#       (bug F-01 da auditoria 0021 — spec-core novo passava sem REGISTRY);
#   (c) órfãos também em docs/prompts/ (F-04 marginal da 0022).
# E-FECH-02 (re-auditoria 0027): a linha exata é procurada no REGISTRY
#   STAGED (git show :REGISTRY.md), nunca na working tree — linha só
#   unstaged NÃO salva o commit que sairia sem ela. Em CI lê HEAD:REGISTRY.md.
# Fechamento corrente E (re-auditorias 0025/0026):
#   (d) NOTA guards aninhados (F-02 da 0026): em `case` bash o `*` cruza `/`,
#       logo o padrão guards/*.sh JÁ casa guards/tests/x.sh e subpastas —
#       comportamento PROVADO por teste negativo na suíte (não era bug, mas
#       agora há prova em vez de fé);
#   (e) doc órfão também em docs/** e methodology/** (F-04 da 0026): .md novo
#       nessas pastas exige id AAAAMMDD-NN OU linha exata no REGISTRY (nome
#       estável registrado ao nascer — ADR-011 Decisão 2).
# R2/readback 0049:
#   (f) o bloco going-forward do REGISTRY tem 7 colunas:
#       id | path | tipo | temperatura | arvore | superseded_by | created_at.
#       Artefato novo que paga linha no REGISTRY precisa declarar arvore valida
#       (fronteira|intermediaria|estavel). Linhas legadas 5/6-col seguem
#       toleradas como historico, mas nao servem para nascimento novo.
# =============================================================================
set -euo pipefail

GUARD_NAME="assert-registry-line"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

REGISTRY="REGISTRY.md"
REGISTRY_REPO_PATH="$(guard_version_repo_path "$REGISTRY" || true)"
if [[ -z "$REGISTRY_REPO_PATH" ]]; then
    guard_fail "Versão ativa inválida: ${HBN_ACTIVE_VERSION_ERROR:-erro desconhecido}. Não é possível localizar o REGISTRY da versão."
    exit 1
fi

# Conteúdo do REGISTRY que SERÁ commitado: índice (staged) localmente;
# HEAD em CI (E-FECH-02 — a working tree não prova nada sobre o commit).
registry_content() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git show "HEAD:${REGISTRY_REPO_PATH}" 2>/dev/null || true
    else
        git show ":${REGISTRY_REPO_PATH}" 2>/dev/null || true
    fi
}

# Arquivos ADICIONADOS ou RENOMEADOS neste diff (AR: rename gera path novo
# que precisa de linha própria — 0026/F-01; M não re-paga: histórico tocado).
guard_added_files() {
    if [[ -n "${HBN_DIFF_BASE:-}" ]]; then
        git diff --name-only --diff-filter=AR "${HBN_DIFF_BASE}...HEAD" 2>/dev/null || true
    else
        git diff --cached --name-only --diff-filter=AR 2>/dev/null || true
    fi | guard_paths_to_version_paths
}

ADDED="$(guard_added_files)"
if [[ -z "$ADDED" ]]; then
    guard_ok "Nenhum arquivo novo no diff."
    exit 0
fi

ALL_CHANGED="$(guard_diff_files)"

# --- Regra 1: tipo numerado (ADR-011 Decisão 2) exige linha no REGISTRY -----
# Padrões de path que caracterizam artefato numerado:
is_numbered_artifact() {
    local f="$1"
    case "$f" in
        methodology/adr/ADR-[0-9]*) return 0 ;;
        .hbn/knowledge/[0-9][0-9][0-9][0-9]-*) return 0 ;;
        .hbn/readbacks/[0-9][0-9][0-9][0-9]-*) return 0 ;;
        .hbn/hearbacks/[0-9][0-9][0-9][0-9]-*) return 0 ;;
        .hbn/proposals/[0-9][0-9][0-9][0-9]-*) return 0 ;;
        .hbn/results/[0-9][0-9][0-9][0-9]-*) return 0 ;;
        .hbn/messages/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9]*) return 0 ;;
        reports/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9]-*) return 0 ;;
        inbox/*/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9]-*) return 0 ;;
        docs/prompts/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9]-*) return 0 ;;
        schemas/*.schema.json) return 0 ;;
        # NOTA (0026/F-02): em `case` bash o `*` cruza `/` — guards/*.sh casa
        # também guards/tests/x.sh e qualquer subpasta. Provado na suíte.
        guards/*.sh) return 0 ;;
        core/*.md) return 0 ;;
        .hbn/models/*.json) return 0 ;;
        .github/workflows/*) return 0 ;;
    esac
    # Qualquer arquivo já nomeado com id global em qualquer pasta — formato
    # serial legado (AAAAMMDD-NN, leitura) OU carimbo ADR-025
    # (AAAAMMDD-HHMMSS, obrigatório para evento novo desde a onda 0006):
    if [[ "$(basename "$f")" =~ ^[0-9]{8}-([0-9]{2}|[0-9]{6})- ]]; then
        return 0
    fi
    return 1
}

# Casamento EXATO: o path precisa estar na coluna 2 da tabela do REGISTRY.
# Substring em outra coluna NÃO conta (ADR-020; bug F-02). Le o REGISTRY
# STAGED, não a working tree (E-FECH-02), e tolera blocos 5/6/7-col.
registry_lines_for_exact() {
    local f="$1"
    registry_content | awk -F'|' -v target="$f" '
        /^[[:space:]]*\|/ {
            path = $3
            gsub(/^[ \t]+|[ \t]+$/, "", path)
            if (path == target) print $0
        }
    '
}

registry_has_exact() {
    [[ -n "$(registry_lines_for_exact "$1")" ]]
}

registry_col_count() {
    awk -F'|' '{ print (NF >= 2 ? NF - 2 : 0) }' <<< "$1"
}

registry_col() {
    local line="$1" logical="$2" field
    field=$((logical + 1))
    awk -F'|' -v idx="$field" '{ gsub(/^[ \t]+|[ \t]+$/, "", $idx); print $idx }' <<< "$line"
}

valid_arvore() {
    case "$1" in
        fronteira|intermediaria|estavel) return 0 ;;
    esac
    return 1
}

registry_has_valid_arvore_for_path() {
    local f="$1" line cols arvore
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        cols="$(registry_col_count "$line")"
        if [[ "$cols" -ge 7 ]]; then
            arvore="$(registry_col "$line" 5)"
            if valid_arvore "$arvore"; then
                return 0
            fi
        fi
    done <<< "$(registry_lines_for_exact "$f")"
    return 1
}

FAIL=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if is_numbered_artifact "$f"; then
        # REGISTRY precisa estar no mesmo diff E conter o path como coluna exata.
        if ! grep -qxF "$REGISTRY" <<< "$ALL_CHANGED"; then
            guard_fail "Artefato governado novo '${f}' sem ${REGISTRY} no mesmo commit (ADR-011 Decisão 4: linha de nascimento no mesmo commit do depósito)."
            FAIL=1
        elif ! registry_has_exact "$f"; then
            guard_fail "Artefato governado novo '${f}' não aparece como coluna exata (| path |) em nenhuma linha do ${REGISTRY} STAGED (ADR-011 Decisão 4 + ADR-020: substring não conta; E-FECH-02: linha só na working tree não conta — git add ${REGISTRY})."
            FAIL=1
        elif ! registry_has_valid_arvore_for_path "$f"; then
            guard_fail "Artefato governado novo '${f}' aparece no ${REGISTRY} staged sem coluna arvore valida (fronteira|intermediaria|estavel) em linha 7-col (R2/readback 0049)."
            FAIL=1
        fi
    fi
done <<< "$ADDED"

# --- Regra 2: órfão na raiz — doc/prompt novo na raiz sem id AAAAMMDD-NN ----
# Nomes estáveis permitidos na raiz (endereços, não eventos — ADR-011 Decisão 2):
ROOT_ALLOWLIST="README.md CHANGELOG.md REGISTRY.md AGENTS.md CLAUDE.md CONTRIBUTING.md GOVERNANCE.md MAINTAINERS.md SECURITY.md SUPPORT.md CODE_OF_CONDUCT.md LICENSE ROADMAP.md"

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    # docs/prompts/ também não aceita prompt sem id (ADR-011 Decisão 2; ADR-020)
    if [[ "$f" == docs/prompts/*.md ]]; then
        if [[ ! "$(basename "$f")" =~ ^[0-9]{8}-([0-9]{2}|[0-9]{6})- ]]; then
            guard_fail "Prompt órfão em docs/prompts/: '${f}' sem id AAAAMMDD-NN (legado) nem carimbo AAAAMMDD-HHMMSS-<agente> (ADR-025 — formato obrigatório para evento novo)."
            FAIL=1
        fi
        continue
    fi
    # docs/** e methodology/** não aceitam doc órfão novo (0026/F-04):
    # ou o basename tem id AAAAMMDD-NN, ou é nome estável REGISTRADO ao
    # nascer (linha exata no REGISTRY — ADR-011 Decisão 2: specs/endereços
    # "entram no REGISTRY"). Artefatos numerados já pagam na regra 1.
    if [[ "$f" == docs/*.md || "$f" == methodology/*.md ]]; then
        if is_numbered_artifact "$f"; then
            continue
        fi
        case "$(basename "$f")" in
            README.md|INDEX.md) continue ;;
        esac
        if registry_has_exact "$f" && registry_has_valid_arvore_for_path "$f"; then
            continue
        fi
        guard_fail "Doc órfão em pasta de documentação: '${f}' sem id AAAAMMDD-NN e sem linha exata 7-col com arvore valida no ${REGISTRY} (ADR-011 Decisão 2; 0026/F-04; R2/readback 0049)."
        FAIL=1
        continue
    fi
    # só raiz (sem "/" no path) e só .md
    [[ "$f" == */* ]] && continue
    [[ "$f" != *.md ]] && continue
    if grep -qw "$f" <<< "$ROOT_ALLOWLIST"; then
        continue
    fi
    if [[ ! "$f" =~ ^[0-9]{8}-([0-9]{2}|[0-9]{6})- ]]; then
        guard_fail "Doc/prompt órfão na raiz: '${f}' sem id AAAAMMDD-NN (ADR-011 Decisão 1) nem carimbo AAAAMMDD-HHMMSS-<agente> (ADR-025). Deposite com id ou em docs/prompts/."
        FAIL=1
    fi
done <<< "$ADDED"

if [[ "$FAIL" -ne 0 ]]; then
    exit 1
fi

guard_ok "Todo artefato numerado novo tem linha no REGISTRY; nenhum órfão na raiz."
exit 0
