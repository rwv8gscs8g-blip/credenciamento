#!/usr/bin/env bash
# =============================================================================
# guards/forbid-env-files.sh
# Guarda G-ENV: recusa commit que contenha .env, .env.local, .env.production,
# *.dump, *.pem, *.p12, chaves SSH ou outros segredos comuns.
# Permite explicitamente: .env.example, .env.sample, .env.template
# =============================================================================
set -euo pipefail

GUARD_NAME="forbid-env-files"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

if guard_check_bypass; then
    exit 0
fi

STAGED="$(guard_diff_files)"
if [[ -z "$STAGED" ]]; then
    guard_ok "Sem arquivos staged."
    exit 0
fi

FAIL=0
VIOLATIONS=()

while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    base="$(basename "$f")"
    case "$base" in
        # Permitidos
        .env.example|.env.sample|.env.template|*.example|*.sample|*.template)
            continue
            ;;
        # Proibidos: arquivos .env
        .env|.env.*|env.local|env.production|env.preview|env.staging)
            VIOLATIONS+=("$f (arquivo .env)")
            FAIL=1
            ;;
        # Proibidos: dumps e backups de DB
        *.dump|*.sql.gz|*.bak|*.backup)
            VIOLATIONS+=("$f (dump/backup binário)")
            FAIL=1
            ;;
        # Proibidos: chaves
        *.pem|*.p12|*.pfx|*.key|id_rsa|id_ed25519|id_ecdsa)
            VIOLATIONS+=("$f (chave/certificado privado)")
            FAIL=1
            ;;
    esac
done <<< "$STAGED"

if [[ $FAIL -eq 0 ]]; then
    guard_ok "Nenhum arquivo sensível staged."
    exit 0
fi

echo "  Arquivos bloqueados:" >&2
for v in "${VIOLATIONS[@]}"; do
    echo "    - $v" >&2
done
echo "" >&2
echo "  Como corrigir:" >&2
echo "    1. git rm --cached <arquivo>" >&2
echo "    2. Adicionar ao .gitignore" >&2
echo "    3. Se o conteúdo precisa ser versionado: criar versão .example/.template SEM segredos reais" >&2
exit 1
