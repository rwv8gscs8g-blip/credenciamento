#!/usr/bin/env bash
# =============================================================================
# guards/tests/run-guard-tests.sh
# path: guards/tests/run-guard-tests.sh · id-global: 20260610-65
# Suíte anti-teatro (ADR-020 Decisão 2): por guard, ≥1 caso-bom (passa) e
# ≥1 caso-ruim (BLOQUEIA). Guard sem teste negativo verde = proibido de ativar.
# Os casos-ruins incluem os 3 bugs provados pela auditoria cruzada 0021/0022:
#   F-03 hearback_ref inexistente · F-02 substring de path · F-01 na-sem-hearback.
# Hermética: perfis de modelo sintéticos em fixtures/models (HBN_MODELS_DIR);
# G-REG/G-SLF/G-HRB rodam em repo git descartável (mktemp). Não toca o repo real.
# Uso: bash guards/tests/run-guard-tests.sh   (exit 0 = suíte verde)
# status: accepted (corrente E 50%, hearback humano no readback 0002);
#   seções do FECHAMENTO da corrente E (G-REG novos casos, G-SLF, G-HRB):
#   accepted no readback 0003 — cobrem E-RE-01 (0025), F-01/F-02/F-04 (0026), ADR-021, ADR-023.
#   FIX staged-skew (re-auditoria 0027, E-FECH-01/02): casos de skew
#   index×worktree — staged ruim + worktree boa DEVE bloquear (e o espelho:
#   staged boa + worktree ruim DEVE passar, provando que o guard lê o índice).
#   Seções G-STR/G-NUM/G-PTR/G-RLT (metade 2 da onda orquestração-start,
#   ADR-024): status accepted pelo readback 0004 — casos das specs core/start-rite-spec.md §4-§5,
#   core/pointer-spec.md §3, core/state-report-spec.md §4, incluindo skew
#   E-FECH-01/02 e o caso de compatibilidade G-REG×created_at (risco R5).
#   CONTAGEM HONESTA (FIX cross-audit 0030 F-03): a seção ADR-024 soma
#   30 checks, dos quais 20 são negativos de bloqueio (block); os demais
#   são casos-bons, compatibilidade G-REG e pass-com-aviso (o aviso em si
#   não é assertado — só o rc). Antes do FIX 0030/0031: 26 checks, 17
#   negativos de bloqueio — NÃO "26 testes negativos".
#   SEÇÃO GUARDS LEGADOS (2026-06-11, readback 0005): 12 checks (8 block,
#   4 pass) para G-CR/G-TMP/G-ENV/G-LEG/G-SCO — paga a pré-condição do
#   STATE para ativar os guards novos no runner.
#   SEÇÃO G-STRAY (2026-06-11, readback 0005): 4 checks (2 block, 2 pass)
#   para o .hbn órfão (incidente opus-4-8). Total da suíte: 79.
#   SEÇÃO READ-LIST VIVA (onda 0006 I-01, readback 0006): 2 checks
#   (1 pass, 1 block) — F-08: path citado em template/spec deve existir.
#   Total da suíte após I-01: 81.
#   I-03 (ADR-025, onda 0006): +4 checks G-NUM (serial novo em results,
#   agente desconhecido em ciclo serial, created_at UTC → 3 block; legado
#   serial modificado → 1 pass) e o caso "serial fora de paralelo passa"
#   foi CONVERTIDO de pass→block (a condicionalidade D5.1 morreu).
#   Total da suíte após I-03: 85.
#   I-05 (F-05, onda 0006): +4 checks G-CR (CI=true local block; CI real
#   pass; alt-root autorizada pass; alt-roots vazio block). Total: 89.
#   I-06 (F-10, onda 0006): +3 checks bypass (2 env sem nota → block;
#   env com nota staged → pass). Total: 92.
#   I-07 (F-04+F-09, onda 0006): G-STRAY v2 (+6: órfão fundo, symlink,
#   backups2, fail-closed → 4 block; sweep-aviso, rm-negado-tolerado →
#   2 pass; o caso backups vira allowlist) + G-SCO files_forbidden isolado
#   (+1 block) + G-TMP worktree linkado (+1 block) + trap global de
#   limpeza (TMPDIR=SUITE_TMP; tolera rm negado). Total: 100.
#   I-08 (F-01, onda 0006): G-EXC (+8: 4 block, 4 pass — 2 de regressao do
#     deadlock C-03c/G-EXC, corretor v3), G-HRB runner+
#   assinatura SSH (+5: 3 block, 2 pass), G-FAM runner (+2: 1 block,
#   1 pass). Total: 113.
#   I-10 (rito de entrada, onda 0006): G-RLT regra 6 (+3: 2 block,
#   1 pass). Total: 116.
#   I-13 (G-TOK, onda 0006): +5 checks (3 block, 2 pass). Total: 121.
#   FIX cross-audits 0030/0031 (3 FORTE + marginais): G-NUM token exato
#   (0030 F-01 / 0031 F-05) + data de id serial (0031 F-01); G-RLT heading
#   exato da cápsula (0030 F-02) + parser do chapéu por campo (0031 F-03);
#   G-PTR ignora ⟦HBN⟧ em code-fence (0031 F-02).
#   S1 (readback 0017): +3 checks G-SCO contra auto-emenda de files_allowed
#   (ca69ef9): emenda+uso bloqueia; extensão isolada passa; depósito em escopo
#   vigente passa.
#   B17 (readback 0019): +5 checks G-SCO para meta-path tipo+nome (2 block:
#   payload.sh/exploit.py fora do escopo; 3 pass: handoff ADR-025, hearback
#   ativo e nota de bypass ADR-025). Total: 140.
#   B18 (readback 0021): +1 check G-SCO bloqueando symlink staged sob .hbn/**
#   com basename ADR-025 e modo git 120000. Total: 141.
#   B19 (readback 0023): +4 checks G-SCO generalizando bloqueio de symlink
#   para todo path governado, mantendo arquivos regulares e hardlink como
#   arquivo regular. Total: 145.
#   S2 (readback 0025): +6 checks G-DSP-FMT/G-DSP-INT para despacho
#   auto-declarante (1 pass, 5 block). Total: 151.
#   Faxina 0027: +3 checks G-EXC em modo CI para mensagem bruta (%B):
#   trailers separados por linha em branco passam; ausencia real de
#   HBN-Readback ou HBN-Human-Authorization bloqueia. Total: 154.
#   S3.1 (readback 0029): +2 checks G-KNOW-INDEX (1 pass, 1 block)
#   garantindo INDEX completo e knowledge nova sem índice bloqueada. Total: 156.
#   S3.2 (readback 0031): +4 checks G-FRONTDOOR (1 pass, 3 block)
#   garantindo role-cards presente, <=140 linhas e read-list <=6. Total: 160.
#   P-CAND-04 (readback 0033): +5 checks G-SCRATCH-* (2 pass, 3 block)
#   cobrindo README versionado, .gitignore protegido, arquivo proibido em
#   scratch/, symlink em scratch/ e remocao sorrateira de /scratch/. Total: 165.
#   W2 C2 (readback 0034): +2 checks G-KNOW-INDEX para token inteiro e
#   anti-ponteiro-morto no INDEX. Total: 167.
#   W2 C3 (readback 0034): +3 checks G-FRONTDOOR para teto em bytes,
#   marcador robusto e existencia de paths da read-list. Total: 170.
#   W2 C4 (readback 0034): +2 checks G-EXC ancorando trailers no ultimo
#   paragrafo em commit-msg e CI. Total: 172.
#   W2 C5 (readback 0034): +3 checks G-SCRATCH fail-closed quando
#   active-version nao resolve. Total: 175.
#   W3 (readback 0036): +3 checks G-ZONA-LIVRE (curadoria passa; sem
#   marcador bloqueia; readback ilegivel bloqueia). Total: 178.
#   G-AUDITOR-ID (readback 0047): +5 checks (1 pass, 4 block) para SOU
#   canonico, familia fora do mapa, apelido divergente e familia incoerente.
#   Total: 183.
#   R2 arvores (readback 0049): +4 checks G-ARVORE-LABEL (1 pass, 3 block)
#   para fronteira valida, arvore invalida, estavel sem promocao e
#   estavel nao-quente. Total: 187.
#   R3a G-TRAILERS (readback 0051): +4 checks (2 pass, 2 block) para
#   trailers HBN contiguos em commit governado, nao-contiguidade, trailer
#   ausente e zona livre isenta. Total: 191.
#   R3b G-DIVERSITY (readback 0053): +4 checks (1 pass, 3 block) para
#   >=2 familias distintas != implementador com APROVA SIM na selagem,
#   incluindo tracked+added, so 1 nao-impl, ambos impl-family e misto
#   1 nao-impl + 1 impl-family. Total: 195.
#   G-ORQ-ENTRADA (readback 0056): +5 checks (1 pass, 4 block) para
#   atestacao valida, ausente, hash divergente, item ausente e resposta de
#   desafio invalida. Total: 200.
#   W-ORQ-2 (readback 0058): substitui desafio aberto+regex por prova
#   extrativa deterministica v2 e remove gabarito fisico. Bloco G-ORQ agora
#   soma 7 checks (1 pass, 6 block): valido sem gabarito, sem atestacao,
#   linha errada, line_sha256 errado, seed de manifest velho, field ausente e
#   arquivo da read-list mudado. Total: 202.
#   W-ORQ-3 (readback 0061): +6 checks G-ORQ-REF (2 pass, 4 block) para
#   despacho com orq_entrada_ref valido, ref omitido, atestacao dangling,
#   fp trocado, auto-repin no mesmo commit e entrega nao-autoridade isenta.
#   Total: 208.
#   W-ORQ-3b (readback 0062): +9 checks G-ORQ-REF (2 pass, 7 block) para
#   P1 selagem real same-fp, N1-N6 e simetria CI same-fp/fp-trocado.
#   Total: 217.
#   G-COPY (readback 0064): +10 checks (2 pass, 8 block) para bloco copiavel
#   unico, destinos canonicos, payload nao-vazio, nao-colisao com G-PTR e
#   skew staged/worktree. Total: 227.
#   G-NEXT (readback 0066): +6 checks (1 pass, 5 block) para proximo_ponto
#   valido, ausencia do mapa, ato invalido, destino nao-canonico, bloco_ref
#   inexistente e mapa duplicado. Total: 233.
#   G-QUORUM (readback 0070): +6 checks (1 pass, 5 block) para selagem
#   vigente com seals_proposal e >=2 familias distintas != OpenAI com
#   APROVA SIM, bloqueando sem seals, 1 parecer, mesma familia, OpenAI e
#   parecer sem APROVA. Total: 239.
#   G-READLIST-RITE (readback 0074): +5 checks (2 pass, 3 block) para
#   read-list A/M com rito declarado, sem readback, sem read_list_rite,
#   human_status != confirmed e diff neutro sem read-list. Total: 244.
#   W-ORQ-4b (readback 0076): +4 checks G-ORQ-REF para despachos em
#   .hbn/messages/*.md com tipo: despacho (1 pass, 2 block) e mensagens
#   nao-despacho neutras (1 pass). Total: 248.
#   W-ORQ-4c (readback 0078): +2 checks G-FRZ para meta-deref-propostas
#   e meta-deref-atestacao bloqueantes. Total: 250.
#   W-ORQ-4d (readback 0080): +3 checks G-CI-BATTERY para workflow com
#   suite+bateria no CI (pass) e remocoes de run-guard-tests/adversarial
#   bloqueadas. Total: 253.
#   W-ORQ-4d-fix (readback 0081): +2 checks G-CI-BATTERY bloqueando
#   bypass por comentario inline e echo. Total: 255.
#   W-ORQ-4d-fix-2 (readback 0082): redesenho para entrypoint canonico
#   por igualdade exata; secao G-CI-BATTERY passa a 6 checks (1 pass,
#   5 block), incluindo heredoc-data e ci-entry.sh fingido. Total: 256.
#   FIX G-EXC SIGPIPE (readback 0083): +1 check G-EXC com STATE grande
#   provando que grep -q sob pipefail nao gera falso negativo. Total: 257.
#   Despromocao-P6 (readback 0086): +5 checks G-ARVORE-LABEL (2 pass,
#   3 block) para promocao rastreavel e despromocao rastreavel, bloqueando
#   rebaixamento sem evento e evento sem readback. Total: 262.
#   FIX-FREEZE-METADEREF (readback 0088): +2 checks G-FRZ para propostas
#   PROPOSED resolvidas por seals_proposal ou por ledger no STATE. Total: 264.
# =============================================================================
set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARDS_DIR="$(dirname "$TESTS_DIR")"
REPO_ROOT="$(cd "$GUARDS_DIR/.." && pwd)"
FIX="$TESTS_DIR/fixtures"
unset HBN_GUARDS_BYPASS GLASSWING_BYPASS HBN_DIFF_BASE 2>/dev/null || true

# Trap GLOBAL de limpeza (onda 0006 I-07 — F-09/0037 P3): todo mktemp -d sem
# -p cai em SUITE_TMP (via TMPDIR); crash/abort não deixa lixo. TOLERANTE a
# rm negado (sandbox pode negar unlink — ordem do gate 2026-06-11): nunca
# derruba o exit code da suíte.
SUITE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/hbn-suite.XXXXXX")"
export TMPDIR="$SUITE_TMP"
suite_cleanup() {
    rm -rf "$SUITE_TMP" \
        "$TESTS_DIR"/cr-pass.* "$TESTS_DIR"/tmp-pass.* "$TESTS_DIR"/cr-alt.* \
        "$TESTS_DIR"/wt-main.* /tmp/hbn-tmp-worktree-test.* /tmp/hbn-wt-linked.* \
        2>/dev/null || true
    return 0
}
trap suite_cleanup EXIT INT TERM

PASS=0; FAIL=0; FALHAS=()

check() { # <nome> <esperado: pass|block> <rc>
    local nome="$1" esperado="$2" rc="$3"
    if { [[ "$esperado" == "pass" ]] && [[ "$rc" -eq 0 ]]; } || \
       { [[ "$esperado" == "block" ]] && [[ "$rc" -ne 0 ]]; }; then
        echo "  ✓ ${nome} (esperado: ${esperado})"
        PASS=$((PASS + 1))
    else
        echo "  ✗ ${nome} — esperado ${esperado}, obtido rc=${rc}"
        FAIL=$((FAIL + 1)); FALHAS+=("$nome")
    fi
}

# --- G-FAM: assert-role-family ----------------------------------------------
echo "== assert-role-family (G-FAM) =="
run_fam() {
    ( cd "$REPO_ROOT" && HBN_MODELS_DIR="$FIX/models" \
        bash "$GUARDS_DIR/assert-role-family.sh" "$1" >/dev/null 2>&1 )
    echo $?
}
check "fam: famílias cruzadas, papéis aptos"            pass  "$(run_fam "$FIX/atribuicoes/good-cross.json")"
check "fam: groupthink sem hearback"                    block "$(run_fam "$FIX/atribuicoes/bad-groupthink.json")"
check "fam: hearback_ref INEXISTENTE (bug F-03)"        block "$(run_fam "$FIX/atribuicoes/bad-hearback-inexistente.json")"
check "fam: hearback existe mas status=pendente"        block "$(run_fam "$FIX/atribuicoes/bad-hearback-pendente.json")"
check "fam: hearback confirmado SEM a exceção"          block "$(run_fam "$FIX/atribuicoes/bad-hearback-sem-excecao.json")"
check "fam: hearback confirmado COBRINDO a exceção"     pass  "$(run_fam "$FIX/atribuicoes/good-hearback-cobre.json")"

# --- G-REG: assert-registry-line (repo git descartável por caso) -------------
echo "== assert-registry-line (G-REG) =="
make_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p methodology/adr core docs/prompts reports \
            .hbn/models .hbn/hearbacks .github/workflows guards/sub
        echo "." > .hbn/active-version
        cat > REGISTRY.md <<'EOF'
| id | artefato (path) | tipo | temperatura | superseded_by |
|---|---|---|---|---|
| 20260101-01 | methodology/adr/ADR-011-exemplo.md | adr | quente | — |
EOF
        echo "exemplo" > methodology/adr/ADR-011-exemplo.md
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_reg() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-registry-line.sh" >/dev/null 2>&1 )
    echo $?
}

# caso-ruim F-02: path substring de linha existente (ADR-01 ⊂ ADR-011-exemplo.md)
d="$(make_repo)"
( cd "$d" && echo "novo" > "methodology/adr/ADR-01" && echo "" >> REGISTRY.md && git add -A ) >/dev/null 2>&1
check "reg: substring de path registrado (bug F-02)"    block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim F-01: spec core novo sem linha no REGISTRY
d="$(make_repo)"
( cd "$d" && echo "spec" > core/nova-fn-spec.md && echo "" >> REGISTRY.md && git add -A ) >/dev/null 2>&1
check "reg: core/*.md novo sem REGISTRY (bug F-01)"     block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim marginal 0022/F-04: prompt órfão em docs/prompts/
d="$(make_repo)"
( cd "$d" && echo "p" > docs/prompts/prompt-solto.md && git add -A ) >/dev/null 2>&1
check "reg: prompt órfão em docs/prompts/"              block "$(run_reg "$d")"
rm -rf "$d"

# caso-bom: artefato novo com linha exata de coluna no REGISTRY
d="$(make_repo)"
(
    cd "$d"
    echo "r" > reports/20260101-02-report-teste.md
    echo "| 20260101-02 | reports/20260101-02-report-teste.md | report | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "reg: depósito correto com linha exata"           pass  "$(run_reg "$d")"
rm -rf "$d"

# --- G-REG: casos do fechamento da corrente E (E-RE-01 + 0026 F-01/F-02/F-04) -
# caso-ruim E-RE-01: .hbn/models/*.json novo sem linha exata no REGISTRY
d="$(make_repo)"
( cd "$d" && echo '{}' > .hbn/models/novo-modelo.json && echo "" >> REGISTRY.md && git add -A ) >/dev/null 2>&1
check "reg: .hbn/models/*.json sem REGISTRY (E-RE-01)"  block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim E-RE-01: .github/workflows/* novo sem linha exata no REGISTRY
d="$(make_repo)"
( cd "$d" && echo 'on: push' > .github/workflows/ci.yml && echo "" >> REGISTRY.md && git add -A ) >/dev/null 2>&1
check "reg: .github/workflows/* sem REGISTRY (E-RE-01)" block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim 0026/F-01: RENAME de artefato numerado sem nova linha (diff-filter=AR)
d="$(make_repo)"
( cd "$d" && git mv methodology/adr/ADR-011-exemplo.md methodology/adr/ADR-012-renomeado.md ) >/dev/null 2>&1
check "reg: rename sem nova linha no REGISTRY (0026/F-01)" block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim 0026/F-02: guard ANINHADO sem REGISTRY (prova que guards/*.sh cruza /)
d="$(make_repo)"
( cd "$d" && echo '#!/bin/bash' > guards/sub/novo-util.sh && echo "" >> REGISTRY.md && git add -A ) >/dev/null 2>&1
check "reg: guard aninhado guards/sub/*.sh sem REGISTRY (0026/F-02)" block "$(run_reg "$d")"
rm -rf "$d"

# caso-ruim 0026/F-04: doc órfão em docs/ (fora de docs/prompts/), sem id nem REGISTRY
d="$(make_repo)"
( cd "$d" && echo "solto" > docs/nota-solta.md && git add -A ) >/dev/null 2>&1
check "reg: doc órfão em docs/ sem id nem REGISTRY (0026/F-04)" block "$(run_reg "$d")"
rm -rf "$d"

# caso-bom: nome estável em methodology/ REGISTRADO ao nascer (linha exata)
d="$(make_repo)"
(
    cd "$d"
    echo "pratica" > methodology/pratica-nova.md
    echo "| 20260101-03 | methodology/pratica-nova.md | spec | quente | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "reg: doc estável em methodology/ com linha exata" pass "$(run_reg "$d")"
rm -rf "$d"

# --- G-REG: skew index×worktree (E-FECH-02, re-auditoria 0027) ----------------
# caso-ruim: REGISTRY staged SEM a linha; linha exata só na working tree
# (unstaged). O commit sairia sem a linha — DEVE bloquear.
d="$(make_repo)"
(
    cd "$d"
    echo "r" > reports/20260101-04-skew.md
    echo "" >> REGISTRY.md
    git add -A
    echo "| 20260101-04 | reports/20260101-04-skew.md | report | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
) >/dev/null 2>&1
check "reg: linha só na working tree, staged sem (E-FECH-02)" block "$(run_reg "$d")"
rm -rf "$d"

# espelho-bom: linha exata STAGED; working tree depois perde a linha.
# O commit sairia COM a linha — deve passar (prova que o guard lê o índice).
d="$(make_repo)"
(
    cd "$d"
    echo "r" > reports/20260101-05-skew-ok.md
    echo "| 20260101-05 | reports/20260101-05-skew-ok.md | report | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
    grep -v "20260101-05" REGISTRY.md > REGISTRY.tmp && mv REGISTRY.tmp REGISTRY.md
) >/dev/null 2>&1
check "reg: linha staged, working tree sem (espelho E-FECH-02)" pass "$(run_reg "$d")"
rm -rf "$d"

# --- G-REG version-aware: paths do Git com prefixo versao_* ------------------
make_version_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn versao_1_0_0/reports
        echo "versao_1_0_0" > .hbn/active-version
        cat > versao_1_0_0/REGISTRY.md <<'EOF'
| id | artefato (path) | tipo | temperatura | superseded_by |
|---|---|---|---|---|
EOF
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
d="$(make_version_repo)"
(
    cd "$d"
    echo "r" > versao_1_0_0/reports/20260101-09-versioned.md
    echo "" >> versao_1_0_0/REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "reg: versão ativa remove prefixo versao_* e bloqueia sem REGISTRY" block "$(run_reg "$d")"
rm -rf "$d"
d="$(make_version_repo)"
(
    cd "$d"
    echo "r" > versao_1_0_0/reports/20260101-10-versioned-ok.md
    echo "| 20260101-10 | reports/20260101-10-versioned-ok.md | report | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> versao_1_0_0/REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "reg: versão ativa valida contra REGISTRY local sem prefixo" pass "$(run_reg "$d")"
rm -rf "$d"

# --- G-SLF: assert-self-path (ADR-021 — repo git descartável por caso) -------
echo "== assert-self-path (G-SLF) =="
run_slf() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-self-path.sh" >/dev/null 2>&1 )
    echo $?
}

# caso-bom: artefato declara path: idêntico ao caminho real
d="$(make_repo)"
( cd "$d" && printf -- '---\npath: methodology/adr/ADR-099-teste.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md && git add -A ) >/dev/null 2>&1
check "slf: path: declarado == caminho real"            pass  "$(run_slf "$d")"
rm -rf "$d"

# caso-ruim canônico ADR-021: path: declarado ≠ caminho real
d="$(make_repo)"
( cd "$d" && printf -- '---\npath: docs/outro-lugar.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md && git add -A ) >/dev/null 2>&1
check "slf: path: declarado ≠ real (auto-localização mentirosa)" block "$(run_slf "$d")"
rm -rf "$d"

# caso-ruim: artefato governado novo SEM path: no front-matter
d="$(make_repo)"
( cd "$d" && printf -- '---\ntitulo: sem path\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md && git add -A ) >/dev/null 2>&1
check "slf: artefato governado sem path: declarado"     block "$(run_slf "$d")"
rm -rf "$d"

# caso-ruim: hearback .json novo sem chave "path"
d="$(make_repo)"
( cd "$d" && echo '{"status":"pendente"}' > .hbn/hearbacks/0009-sem-path.json && git add -A ) >/dev/null 2>&1
check "slf: hearback .json sem campo path"              block "$(run_slf "$d")"
rm -rf "$d"

# --- G-SLF: skew index×worktree (E-FECH-01, re-auditoria 0027) ----------------
# caso-ruim: artefato STAGED com path: mentiroso; working tree corrigida
# depois, sem re-stage. O commit levaria a mentira — DEVE bloquear.
d="$(make_repo)"
(
    cd "$d"
    printf -- '---\npath: docs/outro-lugar.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md
    git add -A
    printf -- '---\npath: methodology/adr/ADR-099-teste.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md
) >/dev/null 2>&1
check "slf: staged mente, working tree corrigida (E-FECH-01)" block "$(run_slf "$d")"
rm -rf "$d"

# espelho-bom: STAGED correto; working tree quebrada depois, sem re-stage.
# O commit levaria o conteúdo certo — deve passar (prova leitura do índice).
d="$(make_repo)"
(
    cd "$d"
    printf -- '---\npath: methodology/adr/ADR-099-teste.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md
    git add -A
    printf -- '---\npath: docs/outro-lugar.md\n---\ncorpo\n' > methodology/adr/ADR-099-teste.md
) >/dev/null 2>&1
check "slf: staged correto, working tree mente (espelho E-FECH-01)" pass "$(run_slf "$d")"
rm -rf "$d"

# --- G-AUDITOR-ID: auto-ID canonico do auditor ------------------------------
echo "== assert-auditor-id (G-AUDITOR-ID) =="
make_auditor_id_repo() {
    local d; d="$(make_repo)"
    (
        cd "$d"
        mkdir -p guards/data .hbn/results
        cp "$REPO_ROOT/guards/data/auditor-families.txt" guards/data/auditor-families.txt
        git add guards/data/auditor-families.txt
        git commit -qm auditor-map
    ) >/dev/null 2>&1
    echo "$d"
}
write_auditor_result() { # <repo> <apelido-arquivo> <onda> <sou-line|NONE>
    local d="$1" file_alias="$2" wave="$3" sou_line="$4" f
    f=".hbn/results/20260617-160000-${file_alias}-cross-ia-${wave}.md"
    (
        cd "$d"
        mkdir -p .hbn/results
        {
            echo "---"
            echo "path: ${f}"
            echo "---"
            echo "APROVA_0047: SIM"
            if [[ "$sou_line" != "NONE" ]]; then
                echo "$sou_line"
            fi
            echo ""
            echo "Parecer de teste."
        } > "$f"
        git add "$f"
    ) >/dev/null 2>&1
}
run_auditor_id() { ( cd "$1" && bash "$GUARDS_DIR/assert-auditor-id.sh" >/dev/null 2>&1 ); echo $?; }

d="$(make_auditor_id_repo)"
write_auditor_result "$d" "grok" "positivo" "SOU: grok · familia xAI · papel auditor"
check "auditor-id: grok/xAI canonico passa" pass "$(run_auditor_id "$d")"
rm -rf "$d"

d="$(make_auditor_id_repo)"
write_auditor_result "$d" "grok" "sem-sou" "NONE"
check "auditor-id: result sem SOU → BLOCK" block "$(run_auditor_id "$d")"
rm -rf "$d"

d="$(make_auditor_id_repo)"
write_auditor_result "$d" "grok" "familia-fora-mapa" "SOU: grok · familia Klingon · papel auditor"
check "auditor-id: familia fora do mapa → BLOCK" block "$(run_auditor_id "$d")"
rm -rf "$d"

d="$(make_auditor_id_repo)"
write_auditor_result "$d" "grok" "apelido-divergente" "SOU: antigravity · familia Google · papel auditor"
check "auditor-id: apelido arquivo != SOU → BLOCK" block "$(run_auditor_id "$d")"
rm -rf "$d"

d="$(make_auditor_id_repo)"
write_auditor_result "$d" "cursor" "familia-incoerente" "SOU: cursor · familia Google · papel auditor"
check "auditor-id: cursor/Google incoerente → BLOCK" block "$(run_auditor_id "$d")"
rm -rf "$d"

# --- G-DIVERSITY: diversidade de familia na selagem --------------------------
echo "== assert-audit-diversity (G-DIVERSITY) =="
make_audit_diversity_repo() {
    local d; d="$(make_repo)"
    (
        cd "$d"
        mkdir -p guards/data .hbn/readbacks .hbn/results
        cp "$REPO_ROOT/guards/data/auditor-families.txt" guards/data/auditor-families.txt
        cat > .hbn/readbacks/0099-diversity-fixture.json <<'EOF'
{"readback_id":"0099-diversity-fixture","implementador_id":"codex","track":"safe_track","human_status":"confirmed","scope":{"files_allowed":[".hbn/results/*.md"],"files_forbidden":[]}}
EOF
        git add guards/data/auditor-families.txt .hbn/readbacks/0099-diversity-fixture.json
        git commit -qm diversity-base
    ) >/dev/null 2>&1
    echo "$d"
}
write_diversity_result() { # <repo> <alias> <stamp> <familia> <veredito>
    local d="$1" alias="$2" stamp="$3" family="$4" verdict="$5" f
    f=".hbn/results/20260617-${stamp}-${alias}-cross-ia-diversity-0099.md"
    (
        cd "$d"
        mkdir -p .hbn/results
        {
            echo "---"
            echo "path: ${f}"
            echo "---"
            echo "SOU: ${alias} · familia ${family} · papel auditor"
            echo "APROVA_0099: ${verdict}"
            echo ""
            echo "Parecer de diversidade."
        } > "$f"
        git add "$f"
    ) >/dev/null 2>&1
}
run_diversity() { ( cd "$1" && bash "$GUARDS_DIR/assert-audit-diversity.sh" >/dev/null 2>&1 ); echo $?; }

d="$(make_audit_diversity_repo)"
write_diversity_result "$d" "grok" "170001" "xAI" "SIM"
( cd "$d" && git commit -qm tracked-grok ) >/dev/null 2>&1
write_diversity_result "$d" "antigravity" "170002" "Google" "SIM"
check "diversity: tracked xAI + added Google != OpenAI passa" pass "$(run_diversity "$d")"
rm -rf "$d"

d="$(make_audit_diversity_repo)"
write_diversity_result "$d" "grok" "170003" "xAI" "SIM"
check "diversity: so 1 familia nao-impl -> BLOCK" block "$(run_diversity "$d")"
rm -rf "$d"

d="$(make_audit_diversity_repo)"
write_diversity_result "$d" "codex" "170004" "OpenAI" "SIM"
write_diversity_result "$d" "cursor" "170005" "OpenAI" "SIM"
check "diversity: 2 results ambos familia do impl -> BLOCK" block "$(run_diversity "$d")"
rm -rf "$d"

d="$(make_audit_diversity_repo)"
write_diversity_result "$d" "grok" "170006" "xAI" "SIM"
write_diversity_result "$d" "cursor" "170007" "OpenAI" "SIM"
check "diversity: 1 nao-impl + 1 impl-family -> BLOCK" block "$(run_diversity "$d")"
rm -rf "$d"

# --- G-HRB: assert-hearback-integrity (ADR-023 — anti-auto-assinatura F-05) --
echo "== assert-hearback-integrity (G-HRB) =="
make_hrb_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/hearbacks docs
        echo "." > .hbn/active-version
        echo base > docs/base.md
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_hrb() { # <repo> <hearback> [change=HEAD]
    ( cd "$1" && bash "$GUARDS_DIR/assert-hearback-integrity.sh" "$2" "${3:-HEAD}" >/dev/null 2>&1 )
    echo $?
}

# caso-bom: hearback em commit PURO anterior; mudança em commit posterior
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed","path":".hbn/hearbacks/0009-ok.json"}' > .hbn/hearbacks/0009-ok.json \
    && git add -A && git commit -qm "hearback puro do humano" \
    && echo mudou >> docs/base.md && git add -A && git commit -qm "mudanca autorizada" ) >/dev/null 2>&1
check "hrb: commit puro anterior à mudança"             pass  "$(run_hrb "$d" ".hbn/hearbacks/0009-ok.json")"
rm -rf "$d"

# caso-ruim canônico F-05: hearback nasce no MESMO commit da mudança
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed","signed_by":"Mauricio"}' > .hbn/hearbacks/0009-fake.json \
    && echo mudou >> docs/base.md && git add -A && git commit -qm "obra + autorizacao juntas" ) >/dev/null 2>&1
check "hrb: hearback no MESMO commit da mudança (0026/F-05)" block "$(run_hrb "$d" ".hbn/hearbacks/0009-fake.json")"
rm -rf "$d"

# caso-ruim: commit do hearback IMPURO (mistura obra com autorização)
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0009-mix.json \
    && echo outra > docs/outra.md && git add -A && git commit -qm "hearback misturado" \
    && echo mudou >> docs/base.md && git add -A && git commit -qm "mudanca" ) >/dev/null 2>&1
check "hrb: commit do hearback impuro (mistura obra)"   block "$(run_hrb "$d" ".hbn/hearbacks/0009-mix.json")"
rm -rf "$d"

# caso-ruim: hearback apenas staged — não pré-existe à mudança
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0009-staged.json && git add -A ) >/dev/null 2>&1
check "hrb: hearback staged/untracked (não commitado)"  block "$(run_hrb "$d" ".hbn/hearbacks/0009-staged.json")"
rm -rf "$d"

# --- G-STR: assert-start-cast (ADR-024 D1 / start-rite-spec §4) --------------
echo "== assert-start-cast (G-STR) =="
run_str() {
    ( cd "$REPO_ROOT" && HBN_MODELS_DIR="$FIX/models" \
        bash "$GUARDS_DIR/assert-start-cast.sh" "$1" >/dev/null 2>&1 )
    echo $?
}
check "str: elenco cruzado válido, ciclo serial"          pass  "$(run_str "$FIX/atribuicoes/good-cast-serial.json")"
check "str: groupthink sem hearback (delegação G-FAM)"    block "$(run_str "$FIX/atribuicoes/bad-groupthink.json")"
check "str: orquestrador sem papel apto e sem exceção"    block "$(run_str "$FIX/atribuicoes/bad-orq-sem-aptidao.json")"
check "str: escrita_paralela com apelido fora do elenco"  block "$(run_str "$FIX/atribuicoes/bad-paralelo-forasteiro.json")"
check "str: bypass liveness com hearback confirmado"      pass  "$(run_str "$FIX/atribuicoes/good-hearback-cobre.json")"

# --- G-NUM: assert-parallel-id (ADR-024 D5 / start-rite-spec §5) --------------
echo "== assert-parallel-id (G-NUM) =="
# Repo descartável com STATE (escrita_paralela parametrizável) + REGISTRY de
# 6 colunas — o G-NUM lê AMBOS do staged (E-FECH-01/02).
make_num_repo() { # $1 = conteúdo inline de escrita_paralela, ex: "[alpha-1, beta-1]"
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/messages .hbn/proposals reports docs/prompts docs
        echo "." > .hbn/active-version
        cat > .hbn/relay/STATE.md <<EOF
---
proxima_acao: "auditar os guards da orquestracao-start"
ultima_atualizacao: "2026-06-10T21:00:00-03:00"
atribuicao:
  chapeu_atual: conversacional-orquestrador
  implementador: alpha-1
  auditores: [beta-1]
  escrita_paralela: ${1}
---
EOF
        cat > REGISTRY.md <<'EOF'
| id | artefato (path) | tipo | temperatura | superseded_by |
|---|---|---|---|---|
| 20260101-01 | docs/base.md | doc | frio | — |

| id | artefato (path) | tipo | temperatura | superseded_by | created_at |
|---|---|---|---|---|---|
EOF
        echo base > docs/base.md
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_num() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-parallel-id.sh" >/dev/null 2>&1 )
    echo $?
}

# caso-bom: paralelo com AAAAMMDD-HHMMSS-<agente> + created_at coerente
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-alpha-1-ideia.md
    echo "| 20260610-101010-alpha-1-ideia | .hbn/proposals/20260610-101010-alpha-1-ideia.md | proposal | quente | — | 2026-06-10T10:10:10-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: paralelo com HHMMSS-agente válido + created_at" pass "$(run_num "$d")"
rm -rf "$d"

# caso-ruim: formato serial AAAAMMDD-NN em ciclo paralelo (colisão 0001×0001)
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-01-ideia.md
    echo "| 20260610-01 | .hbn/proposals/20260610-01-ideia.md | proposal | quente | — | 2026-06-10T10:10:10-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: paralelo com AAAAMMDD-NN antigo (colisão 0001×0001)" block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim: agente do nome fora de escrita_paralela
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-delta-9-ideia.md
    echo "| 20260610-101010-delta-9-ideia | .hbn/proposals/20260610-101010-delta-9-ideia.md | proposal | quente | — | 2026-06-10T10:10:10-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: agente do nome fora de escrita_paralela"          block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim 0030/F-01 · 0031/F-05: colisão de PREFIXO — escrita_paralela
# declara só `alpha`; arquivo de `alpha-1` (apelido conhecido: é o
# implementador do STATE) NÃO pode passar como agente alpha + slug "1-…".
d="$(make_num_repo "[alpha]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-alpha-1-ideia.md
    echo "| 20260610-101010-alpha-1-ideia | .hbn/proposals/20260610-101010-alpha-1-ideia.md | proposal | quente | — | 2026-06-10T10:10:10-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: prefixo de apelido (alpha-1 vs alpha) NÃO passa como slug (0030/F-01·0031/F-05)" block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim: linha nova do REGISTRY sem coluna created_at (5 colunas)
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-alpha-1-ideia.md
    echo "| 20260610-101010-alpha-1-ideia | .hbn/proposals/20260610-101010-alpha-1-ideia.md | proposal | quente | — |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: linha REGISTRY nova sem created_at"               block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim: created_at diverge do HHMMSS do id (um dos dois é de memória)
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-alpha-1-ideia.md
    echo "| 20260610-101010-alpha-1-ideia | .hbn/proposals/20260610-101010-alpha-1-ideia.md | proposal | quente | — | 2026-06-10T10:20:30-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: created_at diverge do HHMMSS do id"               block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim (ADR-025, onda 0006 I-03 — antes era caso-bom): serial AAAAMMDD-NN
# NOVO em série de evento é BLOQUEADO mesmo fora de ciclo paralelo (F-03).
d="$(make_num_repo "[]")"
(
    cd "$d"
    echo "r" > reports/20260101-07-relatorio.md
    echo "| 20260101-07 | reports/20260101-07-relatorio.md | report | frio | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: serial NOVO em série de evento → BLOCK (ADR-025 F-03)" block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim (ADR-025): serial NNNN novo em .hbn/results/ (o caso 0036/0037)
d="$(make_num_repo "[]")"
(
    cd "$d"
    mkdir -p .hbn/results
    echo "parecer" > .hbn/results/0099-parecer-novo.md
    git add -A
) >/dev/null 2>&1
check "num: serial NNNN novo em results → BLOCK (caso 0036/0037)"  block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim (ADR-025): agente desconhecido em ciclo SERIAL
d="$(make_num_repo "[]")"
(
    cd "$d"
    mkdir -p .hbn/results
    echo "parecer" > .hbn/results/20260611-101010-zeta-9-parecer.md
    git add -A
) >/dev/null 2>&1
check "num: agente desconhecido em série de evento → BLOCK"        block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim (ADR-025 D2.2): created_at em UTC na linha nova do REGISTRY
d="$(make_num_repo "[]")"
(
    cd "$d"
    echo "x" > docs/20260611-101010-alpha-1-nota.md
    echo "| 20260611-101010-alpha-1-nota | docs/20260611-101010-alpha-1-nota.md | doc | frio | — | 2026-06-11T10:10:10Z |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: created_at UTC (sufixo Z) → BLOCK (ADR-025/F-02)"      block "$(run_num "$d")"
rm -rf "$d"

# caso-bom (ADR-025): legado serial MODIFICADO (não-adicionado) é só-leitura
d="$(make_num_repo "[]")"
(
    cd "$d"
    mkdir -p .hbn/results
    echo "legado" > .hbn/results/0001-legado.md
    git add -A && git commit -qm "legado"
    echo "anotacao nova" >> .hbn/results/0001-legado.md
    git add -A
) >/dev/null 2>&1
check "num: legado serial modificado (M) segue passando"           pass  "$(run_num "$d")"
rm -rf "$d"

# caso-ruim 0031/F-01: id SERIAL com data divergente do created_at (linha do
# REGISTRY; arquivo fora de série de evento para isolar a regra 2)
d="$(make_num_repo "[]")"
(
    cd "$d"
    echo "r" > docs/20260101-08-data-errada.md
    echo "| 20260101-08 | docs/20260101-08-data-errada.md | doc | frio | — | 2026-06-10T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: id serial com data ≠ created_at (0031/F-01)"      block "$(run_num "$d")"
rm -rf "$d"

# caso-ruim skew (herda E-FECH-02): created_at só na working tree; staged sem
d="$(make_num_repo "[alpha-1, beta-1]")"
(
    cd "$d"
    echo "ideia" > .hbn/proposals/20260610-101010-alpha-1-ideia.md
    echo "| 20260610-101010-alpha-1-ideia | .hbn/proposals/20260610-101010-alpha-1-ideia.md | proposal | quente | — |" >> REGISTRY.md
    git add -A
    # conserta a working tree SEM re-stage — o commit sairia sem created_at
    sed -i.bak 's/| quente | — |$/| quente | — | 2026-06-10T10:10:10-03:00 |/' REGISTRY.md && rm -f REGISTRY.md.bak
) >/dev/null 2>&1
check "num: REGISTRY staged sem created_at; working tree com (skew)" block "$(run_num "$d")"
rm -rf "$d"

# compatibilidade G-REG × created_at/arvore (R2): linha de 7 colunas continua
# casando por coluna exata do assert-registry-line.
d="$(make_repo)"
(
    cd "$d"
    echo "r" > reports/20260101-06-compat.md
    echo "| 20260101-06 | reports/20260101-06-compat.md | report | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add -A
) >/dev/null 2>&1
check "num: linha de 7 colunas com arvore+created_at passa no G-REG" pass "$(run_reg "$d")"
rm -rf "$d"

# --- G-ARVORE-LABEL: anti-mislabel registry-centric --------------------------
echo "== assert-arvore-label (G-ARVORE-LABEL) =="
make_arvore_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/readbacks docs
        echo "." > .hbn/active-version
        cat > .hbn/relay/STATE.md <<'EOF'
---
proxima_acao: "testar arvores"
---
EOF
        cat > .hbn/readbacks/0001-selado.json <<'EOF'
{"readback_id":"0001-selado","track":"safe_track","human_status":"confirmed","hearback_status":"confirmed","path":".hbn/readbacks/0001-selado.json"}
EOF
        cat > REGISTRY.md <<'EOF'
| id | artefato (path) | tipo | temperatura | arvore | superseded_by | created_at |
|---|---|---|---|---|---|---|
EOF
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_arvore() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-arvore-label.sh" >/dev/null 2>&1 )
    echo $?
}
seed_arvore_base() {
    local d="$1" line="$2"
    (
        cd "$d"
        printf '%s\n' "$line" >> REGISTRY.md
        git add REGISTRY.md
        git commit -qm "seed arvore"
    ) >/dev/null 2>&1
}

d="$(make_arvore_repo)"
(
    cd "$d"
    echo "| 20260101-01 | docs/fronteira.md | doc | frio | fronteira | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: linha fronteira valida passa" pass "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
(
    cd "$d"
    echo "| 20260101-02 | docs/experimental.md | doc | frio | experimental | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: valor invalido bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
(
    cd "$d"
    echo "| 20260101-03 | docs/nasce-estavel.md | doc | quente | estavel | — | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: nascer estavel sem promocao bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
(
    cd "$d"
    echo "| 20260101-04 | docs/fria-estavel.md | arvore-promocao | frio | estavel | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: estavel nao-quente bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
(
    cd "$d"
    echo "| 20260101-05 | docs/promovida.md | arvore-promocao | quente | estavel | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: promocao com readback passa" pass "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
seed_arvore_base "$d" "| 20260101-06 | docs/rebaixada.md | arvore-promocao | quente | estavel | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |"
(
    cd "$d"
    echo "| 20260101-07 | docs/rebaixada.md | arvore-despromocao | frio | fronteira | .hbn/readbacks/0001-selado.json | 2026-01-01T10:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: despromocao com readback passa" pass "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
seed_arvore_base "$d" "| 20260101-08 | docs/rebaixa-comum.md | arvore-promocao | quente | estavel | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |"
(
    cd "$d"
    echo "| 20260101-09 | docs/rebaixa-comum.md | doc | frio | fronteira | — | 2026-01-01T10:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: despromocao estavel->fronteira sem evento bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
seed_arvore_base "$d" "| 20260101-10 | docs/rebaixa-intermediaria.md | arvore-promocao | frio | intermediaria | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |"
(
    cd "$d"
    echo "| 20260101-11 | docs/rebaixa-intermediaria.md | doc | frio | fronteira | — | 2026-01-01T10:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: despromocao intermediaria->fronteira sem evento bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

d="$(make_arvore_repo)"
seed_arvore_base "$d" "| 20260101-12 | docs/rebaixa-sem-readback.md | arvore-promocao | quente | estavel | .hbn/readbacks/0001-selado.json | 2026-01-01T09:00:00-03:00 |"
(
    cd "$d"
    echo "| 20260101-13 | docs/rebaixa-sem-readback.md | arvore-despromocao | frio | fronteira | — | 2026-01-01T10:00:00-03:00 |" >> REGISTRY.md
    git add REGISTRY.md
) >/dev/null 2>&1
check "arvore: despromocao sem readback bloqueia" block "$(run_arvore "$d")"
rm -rf "$d"

# --- G-PTR: assert-pointer-honest (ADR-024 D3 / pointer-spec §3) --------------
echo "== assert-pointer-honest (G-PTR) =="
# Repo descartável com destino íntegro (front-matter path: == caminho real).
make_ptr_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/messages docs/prompts core
        echo "." > .hbn/active-version
        printf -- '---\npath: core/alvo-spec.md\n---\ncorpo\n' > core/alvo-spec.md
        printf -- '---\npath: docs/outro-lugar.md\n---\ncorpo\n' > core/mentiroso.md
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_ptr() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-pointer-honest.sh" >/dev/null 2>&1 )
    echo $?
}

# caso-bom: ponteiro íntegro (path existe no staged, == front-matter, com ação)
d="$(make_ptr_repo)"
( cd "$d" && printf -- '⟦HBN⟧ [core/alvo-spec.md](file:///x/core/alvo-spec.md) · sinal: 🔵 · ação: ler a spec\n' > .hbn/messages/20260610-90-h.md && git add -A ) >/dev/null 2>&1
check "ptr: ponteiro íntegro (path existe, == front-matter, com ação)"  pass  "$(run_ptr "$d")"
rm -rf "$d"

# caso-ruim: path inexistente no staged
d="$(make_ptr_repo)"
( cd "$d" && printf -- '⟦HBN⟧ [core/nao-existe.md](file:///x/core/nao-existe.md) · sinal: 🔵 · ação: ler\n' > .hbn/messages/20260610-90-h.md && git add -A ) >/dev/null 2>&1
check "ptr: path inexistente no staged"                                 block "$(run_ptr "$d")"
rm -rf "$d"

# caso-ruim: destino existe mas front-matter declara outro path:
d="$(make_ptr_repo)"
( cd "$d" && printf -- '⟦HBN⟧ [core/mentiroso.md](file:///x/core/mentiroso.md) · sinal: 🔵 · ação: ler\n' > .hbn/messages/20260610-90-h.md && git add -A ) >/dev/null 2>&1
check "ptr: path existe mas front-matter declara outro path:"           block "$(run_ptr "$d")"
rm -rf "$d"

# caso-ruim: linha ⟦HBN⟧ sem ação:
d="$(make_ptr_repo)"
( cd "$d" && printf -- '⟦HBN⟧ [core/alvo-spec.md](file:///x/core/alvo-spec.md) · sinal: 🔵\n' > .hbn/messages/20260610-90-h.md && git add -A ) >/dev/null 2>&1
check "ptr: linha sem ação:"                                            block "$(run_ptr "$d")"
rm -rf "$d"

# pass-com-aviso: href cuja cauda não termina no path relativo (só AVISO)
d="$(make_ptr_repo)"
( cd "$d" && printf -- '⟦HBN⟧ [core/alvo-spec.md](file:///tmp/outra-coisa.md) · sinal: 🔵 · ação: ler\n' > .hbn/messages/20260610-90-h.md && git add -A ) >/dev/null 2>&1
check "ptr: href divergente do path relativo (pass-com-aviso)"          pass  "$(run_ptr "$d")"
rm -rf "$d"

# caso-bom 0031/F-02: exemplo de ⟦HBN⟧ dentro de code-fence é IGNORADO
# (path fictício de template não vira falso-positivo de ponteiro mentiroso)
d="$(make_ptr_repo)"
(
    cd "$d"
    {
        printf -- '⟦HBN⟧ [core/alvo-spec.md](file:///x/core/alvo-spec.md) · sinal: 🔵 · ação: ler a spec\n'
        printf -- '```\n⟦HBN⟧ [caminho/falso-exemplo.md](file:///x/caminho/falso-exemplo.md) · sinal: 🔵 · ação: exemplo de template\n```\n'
    } > .hbn/messages/20260610-90-h.md
    git add -A
) >/dev/null 2>&1
check "ptr: exemplo ⟦HBN⟧ em code-fence ignorado (0031/F-02)"           pass  "$(run_ptr "$d")"
rm -rf "$d"

# caso-bom G-COPY/G-PTR: sentinelas ⟦HBN-COPY ...⟧ NAO sao o gatilho ⟦HBN⟧
d="$(make_ptr_repo)"
(
    cd "$d"
    printf -- '⟦HBN-COPY dest=codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧\n' > .hbn/messages/20260610-90-h.md
    git add -A
) >/dev/null 2>&1
check "ptr: sentinela HBN-COPY nao dispara G-PTR"                      pass  "$(run_ptr "$d")"
rm -rf "$d"

# caso-ruim skew (herda E-FECH-01/02): destino bom só na working tree
d="$(make_ptr_repo)"
(
    cd "$d"
    printf -- '⟦HBN⟧ [core/so-na-worktree.md](file:///x/core/so-na-worktree.md) · sinal: 🔵 · ação: ler\n' > .hbn/messages/20260610-90-h.md
    git add -A
    printf -- '---\npath: core/so-na-worktree.md\n---\ncorpo\n' > core/so-na-worktree.md
) >/dev/null 2>&1
check "ptr: destino bom só na working tree, ausente do staged (skew)"   block "$(run_ptr "$d")"
rm -rf "$d"

# --- G-COPY: assert-copy-block (bloco copiavel deterministico) ---------------
echo "== assert-copy-block (G-COPY) =="
make_copy_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/messages docs/prompts guards/data
        echo "." > .hbn/active-version
        cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
opus Anthropic
grok xAI
antigravity Google
EOF
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_copy() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-copy-block.sh" >/dev/null 2>&1 )
    echo $?
}
write_copy_doc() { # <path> <tipo> <body>
    local path="$1" tipo="$2" body="$3"
    {
        printf -- '---\n'
        printf 'tipo: %s\n' "$tipo"
        printf 'path: %s\n' "$path"
        printf -- '---\n'
        printf '%s\n' "$body"
    } > "$path"
}

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc "docs/prompts/20260101-010101-opus-prompt.md" "prompt" $'⟦HBN-COPY dest=codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: bloco unico bem-formado passa"                            pass  "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" "sem bloco copiavel"
    git add -A
) >/dev/null 2>&1
check "copy: zero blocos bloqueia"                                     block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\num\n⟦HBN-COPY END⟧\n⟦HBN-COPY dest=human⟧ BEGIN\ndois\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: dois blocos bloqueia"                                     block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\npayload'
    git add -A
) >/dev/null 2>&1
check "copy: BEGIN sem END bloqueia"                                   block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY END⟧\n⟦HBN-COPY dest=codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: END antes de BEGIN bloqueia"                              block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=desconhecido⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: dest fora do mapa bloqueia"                               block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest =codex⟧ BEGIN\npayload\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: dest malformado bloqueia"                                 block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\n⟦HBN-COPY END⟧'
    git add -A
) >/dev/null 2>&1
check "copy: payload vazio bloqueia"                                   block "$(run_copy "$d")"
rm -rf "$d"

d="$(make_copy_repo)"
(
    cd "$d"
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" "sem bloco no staged"
    git add -A
    write_copy_doc ".hbn/messages/20260101-010101-opus-despacho.md" "despacho" $'⟦HBN-COPY dest=codex⟧ BEGIN\npayload so na working tree\n⟦HBN-COPY END⟧'
) >/dev/null 2>&1
check "copy: bloco bom so na working tree nao salva staged ruim"       block "$(run_copy "$d")"
rm -rf "$d"

# --- G-RLT: assert-report-fresh (ADR-024 D4+D6 / state-report-spec §4) --------
echo "== assert-report-fresh (G-RLT) =="
# Repo descartável com STATE; handoff parametrizável por heredoc nos casos.
make_rlt_repo() { # $1 = proxima_acao do STATE  $2 = ultima_atualizacao do STATE
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/messages docs
        echo "." > .hbn/active-version
        cat > .hbn/relay/STATE.md <<EOF
---
proxima_acao: "${1}"
ultima_atualizacao: "${2}"
---
EOF
        echo base > docs/base.md
        git add -A
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_rlt() {
    ( cd "$1" && bash "$GUARDS_DIR/assert-report-fresh.sh" >/dev/null 2>&1 )
    echo $?
}
# relato canônico: $1=proxima_acao citada  $2=ultima_atualizacao citada  $3=capsula? (s/n)  $4..=linhas extra de SINAIS
write_handoff() { # imprime em stdout
    local pa="$1" ua="$2" capsula="$3"; shift 3
    echo "RELATO DE ESTADO — alpha-1 · conversacional-orquestrador · ${ua}"
    echo "STATE: ultima_atualizacao=${ua} · bastão → beta-1 · contexto ~40% do threshold"
    echo "SINAIS: nenhum novo"
    for extra in "$@"; do echo "SINAIS: ${extra}"; done
    echo "FEITO: guards implementados"
    echo "PENDENTE: cross-audit"
    echo "PONTEIROS: ⟦HBN⟧ docs/base.md · sinal: 🔵 · ação: auditar"
    echo "PRÓXIMA AÇÃO: ${pa}"
    echo "PARA O HUMANO: rodar a suíte e revisar o diff"
    echo ""
    if [[ "$capsula" == "s" ]]; then
        echo "## Decisões informais (cápsula)"
        echo "nenhuma"
    fi
}

PA="auditar os guards da orquestracao-start"
UA="2026-06-10T21:00:00-03:00"

# caso-bom: relato íntegro, proxima_acao idêntica, cápsula presente
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && write_handoff "$PA" "$UA" s > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: relato íntegro, proxima_acao idêntica, cápsula presente"   pass  "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim: handoff sem bloco RELATO DE ESTADO
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && echo "handoff sem relato nenhum" > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: handoff sem bloco RELATO DE ESTADO"                        block "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim: proxima_acao parafraseada (≠ string exata do STATE)
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && write_handoff "auditar guards" "$UA" s > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: proxima_acao parafraseada (≠ string do STATE)"             block "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim: ultima_atualizacao de memória (≠ STATE staged)
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && write_handoff "$PA" "2026-06-10T20:00:00-03:00" s > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: ultima_atualizacao de memória (≠ STATE staged)"            block "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim: chapéu orquestrador sem seção de cápsula
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && write_handoff "$PA" "$UA" n > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: orquestrador sem seção cápsula"                            block "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim 0030/F-02: palavra "(cápsula)" solta fora do heading exato é
# teatro de cápsula — não satisfaz a Decisão 6 do ADR-024.
d="$(make_rlt_repo "$PA" "$UA")"
(
    cd "$d"
    {
        write_handoff "$PA" "$UA" n
        echo "NOTA: a seção de (cápsula) ainda não existe neste handoff"
    } > .hbn/messages/20260610-91-h.md
    git add -A
) >/dev/null 2>&1
check "rlt: '(cápsula)' fora do heading exato (teatro) (0030/F-02)"    block "$(run_rlt "$d")"
rm -rf "$d"

# caso-ruim skew (E-FECH-02): STATE bom só na working tree; staged velho
d="$(make_rlt_repo "acao antiga que ficou no staged" "2026-06-10T19:00:00-03:00")"
(
    cd "$d"
    write_handoff "$PA" "$UA" s > .hbn/messages/20260610-91-h.md
    git add -A
    # atualiza o STATE na working tree SEM re-stage — o commit levaria o velho
    cat > .hbn/relay/STATE.md <<EOF
---
proxima_acao: "${PA}"
ultima_atualizacao: "${UA}"
---
EOF
) >/dev/null 2>&1
check "rlt: STATE bom só na working tree; staged velho (skew)"         block "$(run_rlt "$d")"
rm -rf "$d"

# pass-com-aviso: relato de 12 linhas (só AVISO de inflação)
d="$(make_rlt_repo "$PA" "$UA")"
( cd "$d" && write_handoff "$PA" "$UA" s "extra 1" "extra 2" "extra 3" "extra 4" > .hbn/messages/20260610-91-h.md && git add -A ) >/dev/null 2>&1
check "rlt: relato de 12 linhas (pass-com-aviso)"                      pass  "$(run_rlt "$d")"
rm -rf "$d"

# --- G-RLT regra 6 (onda 0006 I-10): rito de ENTRADA checável (spec §5) ------
write_entrada() { # $1=pa $2=ua $3=com_heading(s/n) $4=com_citacao(s/n) — handoff tipo: entrada
    local pa="$1" ua="$2" heading="$3" citacao="$4"
    printf -- '---\ntipo: entrada\n---\n'
    write_handoff "$pa" "$ua" "s"
    if [[ "$heading" == "s" ]]; then
        echo "## RELATO DE LEITURA"
        if [[ "$citacao" == "s" ]]; then
            echo "- STATE lido: bastão com alpha-1 (.hbn/relay/STATE.md:3)"
            echo "- readback ativo confirmado (docs/base.md:1)"
        else
            echo "- li o STATE e estava tudo certo, confia"
        fi
    fi
}
d="$(make_rlt_repo "$PA" "2026-06-10T21:00:00-03:00")"
( cd "$d" && write_entrada "$PA" "2026-06-10T21:00:00-03:00" n n > .hbn/messages/20260611-160000-alpha-1-entrada.md && git add -A ) >/dev/null 2>&1
check "rlt: tipo entrada sem RELATO DE LEITURA → BLOCK (I-10)"  block "$(run_rlt "$d")"
rm -rf "$d"
d="$(make_rlt_repo "$PA" "2026-06-10T21:00:00-03:00")"
( cd "$d" && write_entrada "$PA" "2026-06-10T21:00:00-03:00" s n > .hbn/messages/20260611-160001-alpha-1-entrada.md && git add -A ) >/dev/null 2>&1
check "rlt: entrada com item SEM citação arquivo:linha → BLOCK" block "$(run_rlt "$d")"
rm -rf "$d"
d="$(make_rlt_repo "$PA" "2026-06-10T21:00:00-03:00")"
( cd "$d" && write_entrada "$PA" "2026-06-10T21:00:00-03:00" s s > .hbn/messages/20260611-160002-alpha-1-entrada.md && git add -A ) >/dev/null 2>&1
check "rlt: entrada íntegra (itens com arquivo:linha) → passa"  pass  "$(run_rlt "$d")"
rm -rf "$d"

# --- Guards LEGADOS: testes negativos (pré-condição do STATE para ativar os
# guards novos no runner — sinal 🟡 de 2026-06-10; pagos em 2026-06-11,
# readback 0005). Cada legado ganha ≥1 caso-ruim (block) + 1 caso-bom (pass).
# G-CR e G-TMP usam repo FORA de /tmp (mktemp -p $TESTS_DIR) no caso-bom,
# porque ambos recusam /tmp por construção. -----------------------------------
echo "== guards legados (G-CR/G-TMP/G-ENV/G-LEG/G-SCO) =="

# G-ENV: forbid-env-files
d="$(make_repo)"
( cd "$d" && echo "SECRET=x" > .env && git add .env ) >/dev/null 2>&1
check "env: .env staged"                                block "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(make_repo)"
( cd "$d" && echo "ok" > nota-comum.txt && git add nota-comum.txt ) >/dev/null 2>&1
check "env: arquivo comum passa"                        pass  "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# G-LEG: forbid-legacy-paths (lista em .hbn/forbidden-paths.txt)
d="$(make_repo)"
( cd "$d" && mkdir -p .hbn legacy && printf 'legacy/*\n' > .hbn/forbidden-paths.txt && echo x > legacy/velho.md && git add -A ) >/dev/null 2>&1
check "leg: arquivo em path proibido staged"            block "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-legacy-paths.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(make_repo)"
( cd "$d" && mkdir -p .hbn && printf 'legacy/*\n' > .hbn/forbidden-paths.txt && echo ok > core/livre.md && git add -A ) >/dev/null 2>&1
check "leg: lista presente, nada casa"                  pass  "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-legacy-paths.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# G-SCO: assert-scope-lock (readback ativo governa o staged)
make_sco_repo() { # $1=track $2=human_status $3=allowed $4=forbidden (JSON arrays)
    local d forb; d="$(make_repo)"; forb="${4:-[]}"
    ( cd "$d" && mkdir -p .hbn/readbacks && cat > .hbn/readbacks/0001-t.json <<EOF
{"readback_id":"0001-t","track":"${1}","human_status":"${2}","scope":{"files_allowed":${3},"files_forbidden":${forb}}}
EOF
        git add .hbn/readbacks/0001-t.json
        git commit -qm "readback"
    ) >/dev/null 2>&1
    echo "$d"
}
run_sco() { ( cd "$1" && bash "$GUARDS_DIR/assert-scope-lock.sh" >/dev/null 2>&1 ); echo $?; }
d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && echo fora > core/fora-do-escopo.md && git add core/fora-do-escopo.md ) >/dev/null 2>&1
check "sco: staged FORA do files_allowed"               block "$(run_sco "$d")"
rm -rf "$d"
d="$(make_sco_repo safe_track pendente '["docs/**"]')"
( cd "$d" && echo x > docs/dentro.md && git add docs/dentro.md ) >/dev/null 2>&1
check "sco: safe_track sem human_status=confirmed"      block "$(run_sco "$d")"
rm -rf "$d"
d="$(make_sco_repo safe_track confirmed '[]')"
( cd "$d" && echo x > docs/dentro.md && git add docs/dentro.md ) >/dev/null 2>&1
check "sco: files_allowed VAZIO é inválido (caso 0004)" block "$(run_sco "$d")"
rm -rf "$d"
d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && echo x > docs/dentro.md && git add docs/dentro.md ) >/dev/null 2>&1
check "sco: staged dentro do files_allowed"             pass  "$(run_sco "$d")"
rm -rf "$d"
# I-07 (F-09/0037 P2): files_forbidden ISOLADO — staged permitido pelo
# allowed mas listado no forbidden → violação direta, BLOCK
d="$(make_sco_repo safe_track confirmed '["docs/**"]' '["docs/segredo/**"]')"
( cd "$d" && mkdir -p docs/segredo && echo x > docs/segredo/oculto.md && git add docs/segredo/oculto.md ) >/dev/null 2>&1
check "sco: staged em files_forbidden → BLOCK (isolado, F-09)" block "$(run_sco "$d")"
rm -rf "$d"

# S1/ca69ef9: mesmo uma scope_extension formal nao pode autorizar e usar o
# novo escopo no mesmo commit.
d="$(make_sco_repo safe_track confirmed '[".hbn/readbacks/0001-t.json","docs/vigente/**"]')"
(
    cd "$d"
    cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope_extension": {
    "human": "Tester Humano",
    "evidence": "autoriza somente extensao isolada",
    "created_at": "2026-06-15T10:43:09-03:00",
    "allowed_delta": ["docs/novo/**"]
  },
  "scope": {
    "files_allowed": [".hbn/readbacks/0001-t.json", "docs/vigente/**", "docs/novo/**"],
    "files_forbidden": []
  }
}
EOF
    mkdir -p docs/novo
    echo artefato > docs/novo/artefato.md
    git add .hbn/readbacks/0001-t.json docs/novo/artefato.md
) >/dev/null 2>&1
check "sco: emenda files_allowed + uso no mesmo commit (ca69ef9) → BLOCK" block "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '[".hbn/readbacks/0001-t.json","docs/vigente/**"]')"
(
    cd "$d"
    cat > .hbn/readbacks/0001-t.json <<'EOF'
{
  "readback_id": "0001-t",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope_extension": {
    "human": "Tester Humano",
    "evidence": "autoriza somente extensao isolada",
    "created_at": "2026-06-15T10:43:09-03:00",
    "allowed_delta": ["docs/novo/**"]
  },
  "scope": {
    "files_allowed": [".hbn/readbacks/0001-t.json", "docs/vigente/**", "docs/novo/**"],
    "files_forbidden": []
  }
}
EOF
    git add .hbn/readbacks/0001-t.json
) >/dev/null 2>&1
check "sco: scope_extension isolada altera só readback → passa" pass "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '[".hbn/readbacks/0001-t.json","docs/novo/**"]')"
( cd "$d" && mkdir -p docs/novo && echo artefato > docs/novo/artefato.md && git add docs/novo/artefato.md ) >/dev/null 2>&1
check "sco: depósito em escopo já vigente → passa" pass "$(run_sco "$d")"
rm -rf "$d"

# B17: meta-path deixa de ser diretorio sempre permitido; so tipo+nome
# protocolar passa sem files_allowed.
d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/bypasses && echo 'echo payload' > .hbn/bypasses/payload.sh && git add .hbn/bypasses/payload.sh ) >/dev/null 2>&1
check "sco: B17 bloqueia .hbn/bypasses/payload.sh fora do escopo" block "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/messages && echo 'print(1)' > .hbn/messages/exploit.py && git add .hbn/messages/exploit.py ) >/dev/null 2>&1
check "sco: B17 bloqueia .hbn/messages/exploit.py fora do escopo" block "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/messages && echo handoff > .hbn/messages/20260615-120000-codex-handoff-x.md && git add .hbn/messages/20260615-120000-codex-handoff-x.md ) >/dev/null 2>&1
check "sco: B17 handoff ADR-025 .md auto-permitido" pass "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/hearbacks && echo '{"status":"confirmed"}' > .hbn/hearbacks/0001-ok.json && git add .hbn/hearbacks/0001-ok.json ) >/dev/null 2>&1
check "sco: B17 hearback do readback ativo .json auto-permitido" pass "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/bypasses && echo motivo > .hbn/bypasses/20260615-120000-codex-motivo-teste.md && git add .hbn/bypasses/20260615-120000-codex-motivo-teste.md ) >/dev/null 2>&1
check "sco: B17 nota de bypass ADR-025 .md auto-permitida" pass "$(run_sco "$d")"
rm -rf "$d"

# B18: symlink em meta-path governado nao pode passar pela dispensa ADR-025.
d="$(make_sco_repo safe_track confirmed '["docs/**"]')"
( cd "$d" && mkdir -p .hbn/messages && echo 'echo payload' > payload.sh && ln -s ../../payload.sh .hbn/messages/20260615-120000-codex-handoff-x.md && git add .hbn/messages/20260615-120000-codex-handoff-x.md ) >/dev/null 2>&1
check "sco: B18 bloqueia symlink ADR-025 em .hbn/messages/" block "$(run_sco "$d")"
rm -rf "$d"

# B19: symlink em qualquer path governado avaliado pelo scope-lock deve bloquear,
# mesmo quando o path casa com files_allowed permissivo.
d="$(make_sco_repo safe_track confirmed '["guards/**"]')"
( cd "$d" && mkdir -p guards && echo 'echo payload' > payload.sh && ln -s ../payload.sh guards/falso-guard.sh && git add guards/falso-guard.sh ) >/dev/null 2>&1
check "sco: B19 bloqueia symlink em guards/ permitido" block "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '[".hbn/notes/**"]')"
( cd "$d" && mkdir -p .hbn/notes && echo nota > .hbn/notes/regular.md && git add .hbn/notes/regular.md ) >/dev/null 2>&1
check "sco: B19 arquivo regular .hbn/ declarado passa" pass "$(run_sco "$d")"
rm -rf "$d"

d="$(make_sco_repo safe_track confirmed '["guards/**","core/**","src/**"]')"
( cd "$d" && mkdir -p guards core src && echo '#!/usr/bin/env bash' > guards/regular.sh && echo core > core/regular.md && echo 'print("ok")' > src/regular.py && git add guards/regular.sh core/regular.md src/regular.py ) >/dev/null 2>&1
check "sco: B19 arquivos regulares guards/core/src passam" pass "$(run_sco "$d")"
rm -rf "$d"

# Hardlink e non-issue: o Git o materializa no indice como arquivo regular
# 100644, sem semantica de link no commit.
d="$(make_sco_repo safe_track confirmed '["guards/**"]')"
( cd "$d" && mkdir -p guards && echo regular > alvo-regular.txt && ln alvo-regular.txt guards/hardlink-regular.sh && git add guards/hardlink-regular.sh ) >/dev/null 2>&1
check "sco: B19 hardlink regular passa como arquivo" pass "$(run_sco "$d")"
rm -rf "$d"

# G-CR: assert-canonical-root
d="$(mktemp -d)"
( cd "$d" && git init -q && mkdir .hbn && echo "." > .hbn/active-version && echo "/outro/lugar/canonico" > .hbn/canonical-root ) >/dev/null 2>&1
check "cr: toplevel ≠ canonical-root (e em /tmp)"       block "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(mktemp -d -p "$TESTS_DIR" cr-pass.XXXXXX)"
( cd "$d" && git init -q && mkdir .hbn && echo "." > .hbn/active-version && pwd -P > .hbn/canonical-root ) >/dev/null 2>&1
check "cr: toplevel == canonical-root (fora de /tmp)"   pass  "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
# I-05 (F-05): CI=true SOLTO em ambiente local é bypass → BLOCK, mesmo com raiz certa
check "cr: CI=true local (sem GITHUB_ACTIONS+HBN_DIFF_BASE) → BLOCK (F-05)" block "$( ( cd "$d" && CI=true bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
# I-05: skip de CI REAL (provedor + range) continua funcionando
check "cr: CI real (GITHUB_ACTIONS=true + HBN_DIFF_BASE) → skip legítimo" pass "$( ( cd "$d" && GITHUB_ACTIONS=true HBN_DIFF_BASE=abc123 CI=true bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
# I-05: raiz divergente AUTORIZADA por .hbn/alt-roots (glob) → PASS
d="$(mktemp -d -p "$TESTS_DIR" cr-alt.XXXXXX)"
(
    cd "$d" && git init -q && mkdir .hbn
    echo "." > .hbn/active-version
    echo "/outro/lugar/canonico" > .hbn/canonical-root
    printf '# raizes alternativas de teste\n%s\n' "$(pwd -P)" > .hbn/alt-roots
) >/dev/null 2>&1
check "cr: raiz divergente em .hbn/alt-roots → PASS (rastreável)" pass "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
# I-05: alt-roots VAZIO (só comentário) + raiz divergente → BLOCK (fail-closed)
( cd "$d" && printf '# vazio de proposito\n' > .hbn/alt-roots ) >/dev/null 2>&1
check "cr: alt-roots vazio + raiz divergente → BLOCK"   block "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
# M-A: ponteiro de versão ativa é obrigatório e fail-closed.
d="$(mktemp -d -p "$TESTS_DIR" cr-missing-active.XXXXXX)"
( cd "$d" && git init -q && mkdir .hbn && pwd -P > .hbn/canonical-root ) >/dev/null 2>&1
check "cr: active-version ausente → BLOCK (M-A fail-closed)" block "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(mktemp -d -p "$TESTS_DIR" cr-conflict-active.XXXXXX)"
(
    cd "$d" && git init -q && mkdir .hbn
    pwd -P > .hbn/canonical-root
    printf '<<<<<<< ours\n.\n=======\nversao_1_0_0\n>>>>>>> theirs\n' > .hbn/active-version
) >/dev/null 2>&1
check "cr: active-version com conflito de merge → BLOCK" block "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(mktemp -d -p "$TESTS_DIR" cr-version-root.XXXXXX)"
(
    cd "$d" && git init -q && mkdir -p .hbn versao_1_0_0
    pwd -P > .hbn/canonical-root
    echo "versao_1_0_0" > .hbn/active-version
) >/dev/null 2>&1
check "cr: active-version aponta para versao_* existente → PASS" pass "$( ( cd "$d" && bash "$GUARDS_DIR/assert-canonical-root.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# G-TMP: forbid-tmp-worktree — caso-ruim FORÇA /tmp literal (mktemp honra
# TMPDIR e pode cair fora de /tmp — ex.: sandbox/macOS), o guard cobre
# /tmp/* e /private/tmp/* (symlink macOS).
d="/tmp/hbn-tmp-worktree-test.$$"
( mkdir -p "$d" && cd "$d" && git init -q && git config user.email t@h && git config user.name t && git commit -q --allow-empty -m i ) >/dev/null 2>&1
check "tmp: worktree principal em /tmp"                 block "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-tmp-worktree.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(mktemp -d -p "$TESTS_DIR" tmp-pass.XXXXXX)"
( cd "$d" && git init -q && git config user.email t@h && git config user.name t && git commit -q --allow-empty -m i ) >/dev/null 2>&1
check "tmp: worktree fora de áreas voláteis"            pass  "$( ( cd "$d" && bash "$GUARDS_DIR/forbid-tmp-worktree.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
# I-07 (0036 P2): worktree LINKADO em /tmp — a promessa "QUALQUER worktree"
# do guard agora tem prova (antes só o worktree principal era testado).
m="$(mktemp -d -p "$TESTS_DIR" wt-main.XXXXXX)"
w="/tmp/hbn-wt-linked.$$"
(
    cd "$m" && git init -q && git config user.email t@h && git config user.name t \
    && git commit -q --allow-empty -m i && git worktree add -q "$w" -b teste-wt
) >/dev/null 2>&1
check "tmp: worktree LINKADO em /tmp → BLOCK"           block "$( ( cd "$w" && bash "$GUARDS_DIR/forbid-tmp-worktree.sh" >/dev/null 2>&1 ); echo $? )"
( cd "$m" && git worktree remove --force "$w" ) >/dev/null 2>&1 || rm -rf "$w" 2>/dev/null || true
rm -rf "$m" 2>/dev/null || true

# --- G-EXC: assert-exception-traceable (onda 0006 I-08 — F-01) ---------------
echo "== assert-exception-traceable (G-EXC) =="
make_exc_repo() { # $1=implementador $2=agent_id $3=com_auth(y/n) $4=state_extra
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/readbacks docs
        echo "." > .hbn/active-version
        local auth=""
        [[ "$3" == "y" ]] && auth='"authorization":{"human":"Tester Humano","evidence":"ordem em chat 2026-06-11"},'
        cat > .hbn/readbacks/0007-t.json <<EOF
{"readback_id":"0007-t","agent_id":"${2}",${auth}"track":"safe_track","human_status":"confirmed","scope":{"files_allowed":["**"],"files_forbidden":[]}}
EOF
        cat > .hbn/relay/STATE.md <<EOF
---
proxima_acao: "teste"
ultima_atualizacao: "2026-06-11T10:00:00-03:00"
sinais_abertos:
${4}
atribuicao:
  chapeu_atual: implementador
  implementador: ${1}
  auditores: [outro-1]
---
EOF
        git add -A -f
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_exc() { ( cd "$1" && bash "$GUARDS_DIR/assert-exception-traceable.sh" ${2:+"$2"} >/dev/null 2>&1 ); echo $?; }
run_exc_ci() { ( cd "$1" && HBN_DIFF_BASE="$2" bash "$GUARDS_DIR/assert-exception-traceable.sh" >/dev/null 2>&1 ); echo $?; }
SINAL_OK='  - "🔴 EXCEÇÃO F-01 ATIVA — PROPOSED_UNTIL_CROSS_AUDIT"'
SINAL_SEM='  - "🟢 tudo normal"'

# caso-bom: implementador ≠ agente do readback → sem exceção, passa
d="$(make_exc_repo "impl-a" "agente-b" y "$SINAL_SEM")"
check "exc: implementador ≠ agente do readback → passa"        pass  "$(run_exc "$d")"
rm -rf "$d"
# caso-ruim: exceção SEM authorization no readback
d="$(make_exc_repo "mesmo-1" "mesmo-1" n "$SINAL_OK")"
check "exc: exceção sem authorization{} no readback → BLOCK"   block "$(run_exc "$d")"
rm -rf "$d"
# caso-ruim: exceção SEM sinal 🔴/PROPOSED_UNTIL_CROSS_AUDIT no STATE
d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_SEM")"
check "exc: exceção sem sinal 🔴 no STATE staged → BLOCK"      block "$(run_exc "$d")"
rm -rf "$d"
# caso-bom: exceção com (a)+(d) legíveis no pre-commit
d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK")"
check "exc: exceção com authorization + sinais no STATE → passa" pass "$(run_exc "$d")"
# modo commit-msg: mensagem SEM trailer HBN-Human-Authorization → BLOCK
printf 'feat: x\n\nHBN-Readback: 0007\n' > "$d/msg-incompleta.txt"
check "exc: msg sem HBN-Human-Authorization → BLOCK"           block "$(run_exc "$d" "$d/msg-incompleta.txt")"
# modo commit-msg: mensagem com os 2 trailers → passa
printf 'feat: x\n\nHBN-Readback: 0007\nHBN-Human-Authorization: ordem-tester\n' > "$d/msg-ok.txt"
check "exc: msg com os 2 trailers → passa"                     pass  "$(run_exc "$d" "$d/msg-ok.txt")"
rm -rf "$d"

# REGRESSAO fix-gexc-sigpipe: STATE grande com sinal (d) presente deve passar.
# Antes do fix, as pipelines com grep -q podiam fechar cedo e retornar 141 sob
# pipefail, produzindo falso "Sinal (d) AUSENTE".
SINAL_OK_GRANDE="$SINAL_OK"
for i in $(seq 1 1800); do
    SINAL_OK_GRANDE+=$'\n'"  - \"🔴 ruido vermelho padding-${i} para manter a entrada grande e exercitar pipefail apos o primeiro match do sinal d\""
done
d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK_GRANDE")"
state_bytes="$(wc -c < "$d/.hbn/relay/STATE.md" | tr -d '[:space:]')"
large_rc="$(run_exc "$d")"
[[ "$state_bytes" -ge 80000 ]] || large_rc=1
check "exc: STATE grande com sinal (d) presente -> passa" pass "$large_rc"
rm -rf "$d"

# REGRESSAO deadlock C-03c/G-EXC (corretor v3): no modo commit-msg o guard valida
# SO (b)+(c). STATE SEM sinais 🔴/PROPOSED e readback SEM authorization: com (a)/(d)
# restritos ao pre-commit, a mensagem com os 2 trailers LIBERA (antes do fix: BLOCK,
# travando o pick de I-08 sobre a main sem 🔴 de excecao). Espelha o pick na main.
d="$(make_exc_repo "mesmo-1" "mesmo-1" n "$SINAL_SEM")"
printf 'feat: x\n\nHBN-Readback: 0006\nHBN-Human-Authorization: ordem-mauricio\n' > "$d/msg-cm-ok.txt"
check "exc: commit-msg STATE SEM sinais + 2 trailers -> LIBERA (regressao deadlock)" pass  "$(run_exc "$d" "$d/msg-cm-ok.txt")"
# commit-msg ainda EXIGE (b)+(c): mesma STATE, msg sem HBN-Human-Authorization -> BLOCK
printf 'feat: x\n\nHBN-Readback: 0006\n' > "$d/msg-cm-bad.txt"
check "exc: commit-msg STATE SEM sinais + msg sem trailer (c) -> BLOCK"              block "$(run_exc "$d" "$d/msg-cm-bad.txt")"
rm -rf "$d"

# W2: commit-msg so aceita trailers no ultimo paragrafo. Prosa no corpo com
# linhas HBN-* nao substitui trailers reais.
d="$(make_exc_repo "mesmo-1" "mesmo-1" n "$SINAL_SEM")"
printf 'feat: x\n\nCorpo menciona trailers antigos:\nHBN-Readback: 0006\nHBN-Human-Authorization: ordem-mauricio\n\nResumo final sem trailers reais.\n' > "$d/msg-prosa-b31.txt"
check "exc: commit-msg prosa HBN-* no corpo sem trailers finais -> BLOCK" block "$(run_exc "$d" "$d/msg-prosa-b31.txt")"
rm -rf "$d"

# Faxina 0027 + W2: em CI o G-EXC le a mensagem bruta (%B), mas so aceita os
# trailers quando eles aparecem contiguos no ultimo paragrafo.
d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK")"
base="$(git -C "$d" rev-parse HEAD)"
(
    cd "$d"
    echo ok > docs/ci-trailers-contiguos.md
    git add docs/ci-trailers-contiguos.md
    git commit -qm $'feat: ci trailers contiguos\n\nHBN-Readback: 0007\nHBN-Human-Authorization: ordem-tester'
) >/dev/null 2>&1
check "exc: CI trailers contiguos no ultimo paragrafo -> passa" pass "$(run_exc_ci "$d" "$base")"
rm -rf "$d"

d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK")"
base="$(git -C "$d" rev-parse HEAD)"
(
    cd "$d"
    echo bad > docs/ci-prosa-b31.md
    git add docs/ci-prosa-b31.md
    git commit -qm $'feat: ci prosa b31\n\nCorpo menciona trailers antigos:\nHBN-Readback: 0007\nHBN-Human-Authorization: ordem-tester\n\nResumo final sem trailers reais.'
) >/dev/null 2>&1
check "exc: CI prosa HBN-* no corpo sem trailers finais -> BLOCK" block "$(run_exc_ci "$d" "$base")"
rm -rf "$d"

d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK")"
base="$(git -C "$d" rev-parse HEAD)"
(
    cd "$d"
    echo bad > docs/ci-sem-readback.md
    git add docs/ci-sem-readback.md
    git commit -qm $'feat: ci sem readback\n\nHBN-Human-Authorization: ordem-tester'
) >/dev/null 2>&1
check "exc: CI sem HBN-Readback -> BLOCK" block "$(run_exc_ci "$d" "$base")"
rm -rf "$d"

d="$(make_exc_repo "mesmo-1" "mesmo-1" y "$SINAL_OK")"
base="$(git -C "$d" rev-parse HEAD)"
(
    cd "$d"
    echo bad > docs/ci-sem-human.md
    git add docs/ci-sem-human.md
    git commit -qm $'feat: ci sem human authorization\n\nHBN-Readback: 0007\nHBN-Token-FP: 34a7f2f9'
) >/dev/null 2>&1
check "exc: CI sem HBN-Human-Authorization -> BLOCK" block "$(run_exc_ci "$d" "$base")"
rm -rf "$d"

# --- G-TRAILERS: contiguidade dos 3 trailers HBN (R3a/readback 0051) ---------
echo "== assert-trailers-contiguous (G-TRAILERS) =="
make_trailers_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay docs/brainstorm
        echo "." > .hbn/active-version
        cat > .hbn/relay/STATE.md <<'EOF'
---
atribuicao:
  implementador: null
---
EOF
        git add -A -f
        git commit -qm "init"
    ) >/dev/null 2>&1
    echo "$d"
}
run_trailers() { ( cd "$1" && bash "$GUARDS_DIR/assert-trailers-contiguous.sh" "$2" >/dev/null 2>&1 ); echo $?; }

d="$(make_trailers_repo)"
(
    cd "$d"
    echo x >> REGISTRY.md
    git add REGISTRY.md
    printf 'feat: governado trailers ok\n\nHBN-Readback: 0007\nHBN-Human-Authorization: ordem-tester\nHBN-Token-FP: 34a7f2f9\n' > msg-ok.txt
) >/dev/null 2>&1
check "trailers: commit governado com 3 trailers contiguos -> passa" pass "$(run_trailers "$d" "$d/msg-ok.txt")"
rm -rf "$d"

d="$(make_trailers_repo)"
(
    cd "$d"
    echo x >> REGISTRY.md
    git add REGISTRY.md
    printf 'feat: governado trailers quebrados\n\nHBN-Readback: 0007\nHBN-Human-Authorization: ordem-tester\n\nHBN-Token-FP: 34a7f2f9\n' > msg-nao-contiguos.txt
) >/dev/null 2>&1
check "trailers: commit governado com trailers nao-contiguos -> BLOCK" block "$(run_trailers "$d" "$d/msg-nao-contiguos.txt")"
rm -rf "$d"

d="$(make_trailers_repo)"
(
    cd "$d"
    echo x >> REGISTRY.md
    git add REGISTRY.md
    printf 'feat: governado sem human\n\nHBN-Readback: 0007\nHBN-Token-FP: 34a7f2f9\n' > msg-falta-human.txt
) >/dev/null 2>&1
check "trailers: commit governado faltando um trailer -> BLOCK" block "$(run_trailers "$d" "$d/msg-falta-human.txt")"
rm -rf "$d"

d="$(make_trailers_repo)"
(
    cd "$d"
    echo ideia > docs/brainstorm/ideia-livre.md
    git add docs/brainstorm/ideia-livre.md
    printf 'docs: zona livre sem trailers\n' > msg-zona-livre.txt
) >/dev/null 2>&1
check "trailers: commit so de zona livre sem trailers -> passa" pass "$(run_trailers "$d" "$d/msg-zona-livre.txt")"
rm -rf "$d"

# --- G-HRB modo runner + assinatura SSH (onda 0006 I-08) ---------------------
echo "== assert-hearback-integrity: runner + assinatura (I-08) =="
run_hrb_runner() { ( cd "$1" && ${2:+env "$2"} bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $?; }
# runner: hearback staged JUNTO com obra → BLOCK
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0010-x.json && echo obra >> docs/base.md && git add -A ) >/dev/null 2>&1
check "hrb-run: hearback staged junto com obra → BLOCK"        block "$(run_hrb_runner "$d")"
rm -rf "$d"
# runner: hearback staged PURO, sem chave registrada → passa com aviso
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0010-puro.json && git add .hbn/hearbacks/0010-puro.json ) >/dev/null 2>&1
check "hrb-run: hearback puro sem chave → passa (aviso pendente)" pass "$(run_hrb_runner "$d")"
rm -rf "$d"
# assinatura: chave registrada + hearback ASSINADO → passa
kd="$(mktemp -d)"
ssh-keygen -q -t ed25519 -N "" -f "$kd/operador" >/dev/null 2>&1
mkdir -p "$kd/ops" && cp "$kd/operador.pub" "$kd/ops/operador.pub"
d="$(make_hrb_repo)"
(
    cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0011-ass.json \
    && ssh-keygen -Y sign -q -f "$kd/operador" -n hbn-hearback .hbn/hearbacks/0011-ass.json >/dev/null 2>&1 \
    && git add .hbn/hearbacks/0011-ass.json .hbn/hearbacks/0011-ass.json.sig
) >/dev/null 2>&1
check "hrb-sig: hearback assinado por chave registrada → passa" pass "$( ( cd "$d" && HBN_OPERATORS_DIR="$kd/ops" bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
# assinatura: chave registrada + hearback SEM .sig → BLOCK
d="$(make_hrb_repo)"
( cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0012-semsig.json && git add .hbn/hearbacks/0012-semsig.json ) >/dev/null 2>&1
check "hrb-sig: chave registrada e hearback sem .sig → BLOCK"   block "$( ( cd "$d" && HBN_OPERATORS_DIR="$kd/ops" bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
# assinatura: .sig de CONTEÚDO adulterado → BLOCK
d="$(make_hrb_repo)"
(
    cd "$d" && echo '{"status":"confirmed"}' > .hbn/hearbacks/0013-adult.json \
    && ssh-keygen -Y sign -q -f "$kd/operador" -n hbn-hearback .hbn/hearbacks/0013-adult.json >/dev/null 2>&1 \
    && echo '{"status":"confirmed","escopo":"AMPLIADO DEPOIS DA ASSINATURA"}' > .hbn/hearbacks/0013-adult.json \
    && git add .hbn/hearbacks/0013-adult.json .hbn/hearbacks/0013-adult.json.sig
) >/dev/null 2>&1
check "hrb-sig: conteúdo adulterado após assinar → BLOCK"       block "$( ( cd "$d" && HBN_OPERATORS_DIR="$kd/ops" bash "$GUARDS_DIR/assert-hearback-integrity.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d" "$kd"

# --- G-FAM modo runner (onda 0006 I-08 — backlog 0022/F-05 mínimo) -----------
echo "== assert-role-family: modo runner (I-08) =="
make_fam_state_repo() { # $1=implementador $2=auditores inline
    local d; d="$(mktemp -d)"
    (
        cd "$d" && git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay
        echo "." > .hbn/active-version
        printf -- '---\natribuicao:\n  implementador: %s\n  auditores: %s\n---\n' "$1" "$2" > .hbn/relay/STATE.md
        git add -A && git commit -qm init
    ) >/dev/null 2>&1
    echo "$d"
}
d="$(make_fam_state_repo "fulano-1" "[fulano-1, beltrano-2]")"
check "fam-run: implementador ∈ auditores no STATE staged → BLOCK" block "$( ( cd "$d" && bash "$GUARDS_DIR/assert-role-family.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"
d="$(make_fam_state_repo "fulano-1" "[beltrano-2, sicrano-3]")"
check "fam-run: implementador ∉ auditores → passa"              pass  "$( ( cd "$d" && bash "$GUARDS_DIR/assert-role-family.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# --- Bypass com nota staged (onda 0006 I-06 — F-10) --------------------------
echo "== bypass env só com nota staged (F-10) =="
# env=1 SEM nota: o caso-ruim continua BLOQUEADO (bypass ignorado)
d="$(make_repo)"
( cd "$d" && echo "SECRET=x" > .env && git add .env ) >/dev/null 2>&1
check "byp: HBN_GUARDS_BYPASS=1 sem nota → caso-ruim ainda BLOCK" block "$( ( cd "$d" && HBN_GUARDS_BYPASS=1 bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
check "byp: GLASSWING_BYPASS=1 sem nota → caso-ruim ainda BLOCK"  block "$( ( cd "$d" && GLASSWING_BYPASS=1 bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
# env=1 COM nota ADICIONADA no diff staged: bypass vale (com aviso)
( cd "$d" && mkdir -p .hbn/bypasses && echo "motivo: teste" > .hbn/bypasses/20260611-120000-tester-motivo-teste.md && git add .hbn/bypasses/20260611-120000-tester-motivo-teste.md ) >/dev/null 2>&1
check "byp: HBN_GUARDS_BYPASS=1 com nota staged → skip com aviso" pass  "$( ( cd "$d" && HBN_GUARDS_BYPASS=1 bash "$GUARDS_DIR/forbid-env-files.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# --- G-STRAY: assert-no-stray-hbn (árvore sintética via HBN_SCAN_ROOT) -------
echo "== assert-no-stray-hbn (G-STRAY) =="
run_stray() { ( HBN_SCAN_ROOT="$1" bash "$GUARDS_DIR/assert-no-stray-hbn.sh" >/dev/null 2>&1 ); echo $?; }
# caso-bom: .hbn dentro de raiz de repo git
r="$(mktemp -d)"
( mkdir -p "$r/repoA/.git" "$r/repoA/.hbn" ) >/dev/null 2>&1
check "stray: .hbn em raiz de repo git"                 pass  "$(run_stray "$r")"
# caso-ruim: .hbn órfão direto na raiz varrida (o incidente opus-4-8)
( mkdir -p "$r/.hbn/results" ) >/dev/null 2>&1
check "stray: .hbn órfão na raiz varrida"               block "$(run_stray "$r")"
rm -rf "$r"
# caso-ruim: .hbn órfão em subpasta que não é repo
r="$(mktemp -d)"
( mkdir -p "$r/projetos/soltinho/.hbn" ) >/dev/null 2>&1
check "stray: .hbn órfão em subpasta sem .git"          block "$(run_stray "$r")"
rm -rf "$r"
# M-A: .hbn dentro de uma pasta de versão registrada não é órfão.
r="$(mktemp -d)"
( mkdir -p "$r/repoV/.git" "$r/repoV/.hbn" "$r/repoV/versao_1_0_0/.hbn" && echo "versao_1_0_0" > "$r/repoV/.hbn/active-version" ) >/dev/null 2>&1
check "stray: .hbn dentro de versao_* registrada → PASS" pass "$(run_stray "$r")"
rm -rf "$r"
# Sem ponteiro, versao_* não ganha allowlist implícita.
r="$(mktemp -d)"
( mkdir -p "$r/repoSemPtr/.git" "$r/repoSemPtr/versao_1_0_0/.hbn" ) >/dev/null 2>&1
check "stray: .hbn em versao_* sem active-version → BLOCK" block "$(run_stray "$r")"
# caso-bom: .hbn sob backups/ agora passa pela ALLOWLIST (*/backups/* em
# .hbn/stray-allowlist — v2 I-07; a poda hardcoded morreu)
rm -rf "$r"; r="$(mktemp -d)"
( mkdir -p "$r/backups/copia-antiga/.hbn" "$r/repoB/.git" "$r/repoB/.hbn" ) >/dev/null 2>&1
check "stray: .hbn sob backups/ é allowlisted (cópia fria)" pass "$(run_stray "$r")"
rm -rf "$r"

# v2 I-07 (F-04): órfão FUNDO (5 níveis) agora é detectado (maxdepth 6)
r="$(mktemp -d)"
( mkdir -p "$r/a/b/c/d/.hbn" ) >/dev/null 2>&1
check "stray: .hbn órfão a 5 níveis → BLOCK (era falso negativo)" block "$(run_stray "$r")"
rm -rf "$r"

# v2 I-07 (F-04): SYMLINK chamado .hbn órfão é detectado
r="$(mktemp -d)"
( mkdir -p "$r/alvo-longe" "$r/proj" && ln -s "$r/alvo-longe" "$r/proj/.hbn" ) >/dev/null 2>&1
check "stray: symlink .hbn órfão → BLOCK (era invisível)"        block "$(run_stray "$r")"
rm -rf "$r"

# v2 I-07 (F-04): pasta 'backups2' NÃO está na allowlist → órfão detectado
r="$(mktemp -d)"
( mkdir -p "$r/backups2/x/.hbn" ) >/dev/null 2>&1
check "stray: .hbn sob backups2/ (fora da allowlist) → BLOCK"    block "$(run_stray "$r")"
rm -rf "$r"

# v2 I-07 (F-04): SCAN_ROOT inválido = fail-CLOSED no modo guard…
check "stray: HBN_SCAN_ROOT inválido → BLOCK (fail-closed)"      block "$(run_stray "/caminho/que/nao/existe")"
# …mas --sweep mantém o aviso informativo (rc 0)
check "stray: HBN_SCAN_ROOT inválido em --sweep → aviso, passa"  pass  "$( ( HBN_SCAN_ROOT=/caminho/que/nao/existe bash "$GUARDS_DIR/assert-no-stray-hbn.sh" --sweep >/dev/null 2>&1 ); echo $? )"

# I-07 (ordem do gate 2026-06-11): limpeza tolera rm NEGADO sem derrubar a
# suíte — sub-dir sem permissão de escrita simula o sandbox que nega unlink.
r="$(mktemp -d)"
( mkdir -p "$r/teimoso" && touch "$r/teimoso/f" && chmod 555 "$r/teimoso" ) >/dev/null 2>&1
check "cleanup: rm negado é tolerado (rc 0 da rotina de limpeza)" pass "$( ( rm -rf "$r" 2>/dev/null || true; exit 0 ); echo $? )"
chmod -R 755 "$r" 2>/dev/null; rm -rf "$r" 2>/dev/null || true

# --- G-TOK: assert-baton-token (onda 0006 I-13 — posse do bastão, v2) --------
# v2 (correções C-01/C-02 dos pareceres 170633/172049): token vive APENAS em
# .git/hbn-baton-token; trailer é o fingerprint público HBN-Token-FP (8 hex);
# sha256 com fallback shasum (macOS) — compatível com Bash 3.2.
echo "== assert-baton-token (G-TOK v2: arquivo local + fingerprint) =="
tok_sha256() { # stdin → sha256 hex (sha256sum ou shasum -a 256, como o guard)
    if command -v sha256sum >/dev/null 2>&1; then sha256sum | awk '{print $1}'
    else shasum -a 256 | awk '{print $1}'; fi
}
TOK_TESTE="tok-de-teste-1234"
TOK_HASH="$(printf '%s' "$TOK_TESTE" | tok_sha256)"
TOK_FP="$(printf '%s' "$TOK_HASH" | cut -c1-8)"
make_tok_repo() { # $1 = campo bastao_token_sha256 (vazio = sem campo)
    local d; d="$(mktemp -d)"
    (
        cd "$d" && git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay
        echo "." > .hbn/active-version
        {
            echo '---'
            echo 'proxima_acao: "teste"'
            [[ -n "$1" ]] && echo "bastao_token_sha256: $1"
            echo '---'
        } > .hbn/relay/STATE.md
        git add -A && git commit -qm init
    ) >/dev/null 2>&1
    echo "$d"
}
write_tok_file() { # <repo> <token> → grava o arquivo local de posse
    printf '%s\n' "$2" > "$1/.git/hbn-baton-token"
}
run_tok() { # <repo> <msg-conteudo> [env]
    local d="$1" msg="$2"
    printf '%s\n' "$msg" > "$d/msg.txt"
    ( cd "$d" && ${3:+env "$3"} bash "$GUARDS_DIR/assert-baton-token.sh" "$d/msg.txt" >/dev/null 2>&1 )
    echo $?
}
d="$(make_tok_repo "$TOK_HASH")"
check "tok: campo presente + ARQUIVO .git/hbn-baton-token ausente → BLOCK" block "$(run_tok "$d" "feat: x

HBN-Token-FP: ${TOK_FP}")"
write_tok_file "$d" "token-errado-no-arquivo"
check "tok: arquivo com token ERRADO → BLOCK"                   block "$(run_tok "$d" "feat: x

HBN-Token-FP: ${TOK_FP}")"
write_tok_file "$d" "$TOK_TESTE"
check "tok: msg SEM trailer HBN-Token-FP → BLOCK"               block "$(run_tok "$d" $'feat: x\n\nHBN-Readback: 0006')"
check "tok: fingerprint do trailer ≠ hash do STATE → BLOCK"     block "$(run_tok "$d" $'feat: x\n\nHBN-Token-FP: deadbeef')"
check "tok: arquivo correto + fingerprint correto → passa"      pass  "$(run_tok "$d" "feat: x

HBN-Token-FP: ${TOK_FP}")"
rm -rf "$d"
d="$(make_tok_repo "")"
check "tok: STATE sem campo + exigência ativa → BLOCK"          block "$(run_tok "$d" $'feat: x' "HBN_REQUIRE_BATON_TOKEN=1")"
check "tok: STATE sem campo (rampa) → passa com aviso"          pass  "$(run_tok "$d" $'feat: x')"
rm -rf "$d"

# --- G-DSP-FMT / G-DSP-INT: dispatch auto-declarante (S2) -------------------
echo "== dispatch auto-declarante (G-DSP-FMT/G-DSP-INT) =="
DSP_HASH="34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf"
make_dispatch_repo() {
    local d; d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/readbacks .hbn/dispatch schemas
        echo "." > .hbn/active-version
        cp "$REPO_ROOT/schemas/dispatch.schema.json" schemas/dispatch.schema.json
        cat > .hbn/relay/STATE.md <<EOF
---
bastao_token_sha256: ${DSP_HASH}
readback_ativo: ".hbn/readbacks/0025-s2-dispatch-auto-declarante.json"
atribuicao:
  implementador: codex
  auditores: [gemini-3-5, cursor]
---
EOF
        cat > .hbn/readbacks/0025-s2-dispatch-auto-declarante.json <<'EOF'
{
  "readback_id": "0025-s2-dispatch-auto-declarante",
  "track": "safe_track",
  "human_status": "confirmed",
  "scope": {
    "files_allowed": [".hbn/dispatch/0025-s2-dispatch-auto-declarante.md"],
    "files_forbidden": []
  }
}
EOF
        git add -A
        git commit -qm init
    ) >/dev/null 2>&1
    echo "$d"
}
write_good_dispatch() {
    local d="$1"
    (
        cd "$d"
        cat > .hbn/dispatch/0025-s2-dispatch-auto-declarante.md <<'EOF'
---
schema_version: dispatch.v1
dispatch_id: 0025-s2-dispatch-auto-declarante
path: .hbn/dispatch/0025-s2-dispatch-auto-declarante.md
readback_id: 0025-s2-dispatch-auto-declarante
token_fp: 34a7f2f9
human_authorization: Mauricio (Luis Mauricio Junqueira Zanin)
agent_id: codex
role: implementador
status: ready_for_execution
created_at: 2026-06-16T00:23:31-03:00
summary: Dispatch S2
scope:
  files_allowed:
    - schemas/dispatch.schema.json
  files_forbidden:
    - main
action_plan:
  - Executar S2
invariants:
  - Nao tocar main
validation_commands:
  - bash guards/hbn-guards-runner.sh
---
Executar S2 com paths explicitamente stageados.
Validar guards antes do commit.
EOF
        git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md
    ) >/dev/null 2>&1
}
run_dsp_fmt() { ( cd "$1" && bash "$GUARDS_DIR/validate-dispatch.sh" >/dev/null 2>&1 ); echo $?; }
run_dsp_int() { ( cd "$1" && bash "$GUARDS_DIR/assert-dispatch-integrity.sh" >/dev/null 2>&1 ); echo $?; }
run_dsp_both() {
    ( cd "$1" && bash "$GUARDS_DIR/validate-dispatch.sh" >/dev/null 2>&1 \
        && bash "$GUARDS_DIR/assert-dispatch-integrity.sh" >/dev/null 2>&1 )
    echo $?
}

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
check "dsp: despacho bem-formado e coerente passa" pass "$(run_dsp_both "$d")"
rm -rf "$d"

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
( cd "$d" && grep -v '^human_authorization:' .hbn/dispatch/0025-s2-dispatch-auto-declarante.md > dispatch.tmp \
    && mv dispatch.tmp .hbn/dispatch/0025-s2-dispatch-auto-declarante.md \
    && git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md ) >/dev/null 2>&1
check "dsp-fmt: campo obrigatório ausente → BLOCK" block "$(run_dsp_fmt "$d")"
rm -rf "$d"

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
( cd "$d" && printf '# comentario proibido\n' >> .hbn/dispatch/0025-s2-dispatch-auto-declarante.md \
    && git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md ) >/dev/null 2>&1
check "dsp-fmt: linha iniciada por # no corpo colavel → BLOCK" block "$(run_dsp_fmt "$d")"
rm -rf "$d"

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
( cd "$d" && sed -i.bak 's/token_fp: 34a7f2f9/token_fp: zzzzzzzz/' .hbn/dispatch/0025-s2-dispatch-auto-declarante.md \
    && rm -f .hbn/dispatch/0025-s2-dispatch-auto-declarante.md.bak \
    && git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md ) >/dev/null 2>&1
check "dsp-fmt: token_fp mal-formado → BLOCK" block "$(run_dsp_fmt "$d")"
rm -rf "$d"

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
( cd "$d" && sed -i.bak 's/readback_id: 0025-s2-dispatch-auto-declarante/readback_id: 0099-inexistente/' .hbn/dispatch/0025-s2-dispatch-auto-declarante.md \
    && rm -f .hbn/dispatch/0025-s2-dispatch-auto-declarante.md.bak \
    && git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md ) >/dev/null 2>&1
check "dsp-int: readback inexistente/não-ativo → BLOCK" block "$(run_dsp_int "$d")"
rm -rf "$d"

d="$(make_dispatch_repo)"
write_good_dispatch "$d"
( cd "$d" && sed -i.bak 's/token_fp: 34a7f2f9/token_fp: deadbeef/' .hbn/dispatch/0025-s2-dispatch-auto-declarante.md \
    && rm -f .hbn/dispatch/0025-s2-dispatch-auto-declarante.md.bak \
    && git add .hbn/dispatch/0025-s2-dispatch-auto-declarante.md ) >/dev/null 2>&1
check "dsp-int: token_fp divergente do STATE → BLOCK" block "$(run_dsp_int "$d")"
rm -rf "$d"

# --- G-KNOW-INDEX: INDEX vivo da knowledge (S3.1) ---------------------------
echo "== assert-knowledge-index (G-KNOW-INDEX) =="
make_know_repo() {
    local d; d="$(make_repo)"
    (
        cd "$d"
        mkdir -p .hbn/knowledge
        cat > .hbn/knowledge/INDEX.md <<'EOF'
# Knowledge Index

| Entrada | Uso |
|---|---|
| `0001-base.md` | Base testada. |
EOF
        echo "# Base" > .hbn/knowledge/0001-base.md
        git add -A
        git commit -qm init
    ) >/dev/null 2>&1
    echo "$d"
}
run_know() { ( cd "$1" && bash "$GUARDS_DIR/assert-knowledge-index.sh" >/dev/null 2>&1 ); echo $?; }

d="$(make_know_repo)"
check "know: INDEX completo passa" pass "$(run_know "$d")"
rm -rf "$d"

d="$(make_know_repo)"
( cd "$d" && echo "# Nova" > .hbn/knowledge/0002-nova.md && git add .hbn/knowledge/0002-nova.md ) >/dev/null 2>&1
check "know: knowledge nova sem linha no INDEX → BLOCK" block "$(run_know "$d")"
rm -rf "$d"

d="$(make_know_repo)"
(
    cd "$d"
    echo "# Nova" > .hbn/knowledge/0002-nova.md
    printf '| `10002-nova.md` | Substring nao pode contar como token. |\n' >> .hbn/knowledge/INDEX.md
    git add .hbn/knowledge/0002-nova.md .hbn/knowledge/INDEX.md
) >/dev/null 2>&1
check "know: substring 0002 dentro de 10002 nao conta → BLOCK" block "$(run_know "$d")"
rm -rf "$d"

d="$(make_know_repo)"
(
    cd "$d"
    printf '| `9999-ponteiro-morto.md` | Arquivo inexistente. |\n' >> .hbn/knowledge/INDEX.md
    git add .hbn/knowledge/INDEX.md
) >/dev/null 2>&1
check "know: INDEX citando arquivo inexistente → BLOCK" block "$(run_know "$d")"
rm -rf "$d"

# --- G-FRONTDOOR: porta da frente minima (S3.2) -----------------------------
echo "== assert-frontdoor (G-FRONTDOOR) =="
write_frontdoor_valid() {
    cat > core/role-cards.md <<'EOF'
# Porta Da Frente De Papeis

## PARTE A - READ-LIST DA PORTA DA FRENTE

1. `.hbn/relay/STATE.md`
2. O readback ativo apontado no STATE.
3. `core/role-cards.md`
4. `.hbn/knowledge/0001-comandos-atomicos-copiaveis.md`
5. `.hbn/knowledge/0002-entrega-operacional-minimalista.md`
6. `.hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md`

## PARTE B - TRES CARTOES

### Orquestrador
FAZ: Decide a proxima onda.
ENTREGA COMO: Despacho colavel.
NAO FAZ: Nao implementa no lugar do implementador.
SPEC COMPLETA: `core/orchestrator-profile-spec.md`.
EOF
}
make_frontdoor_repo() {
    local d; d="$(make_repo)"
    (
        cd "$d"
        mkdir -p core .hbn/relay .hbn/knowledge
        echo "---" > .hbn/relay/STATE.md
        echo "# Comandos atomicos" > .hbn/knowledge/0001-comandos-atomicos-copiaveis.md
        echo "# Entrega operacional" > .hbn/knowledge/0002-entrega-operacional-minimalista.md
        echo "# Area temporaria" > .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
        write_frontdoor_valid
        git add core/role-cards.md .hbn/relay/STATE.md \
            .hbn/knowledge/0001-comandos-atomicos-copiaveis.md \
            .hbn/knowledge/0002-entrega-operacional-minimalista.md \
            .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
        git commit -qm frontdoor
    ) >/dev/null 2>&1
    echo "$d"
}
run_frontdoor() { ( cd "$1" && bash "$GUARDS_DIR/assert-frontdoor.sh" >/dev/null 2>&1 ); echo $?; }

d="$(make_frontdoor_repo)"
check "frontdoor: role-cards valido passa" pass "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
( cd "$d" && git rm -q core/role-cards.md ) >/dev/null 2>&1
check "frontdoor: role-cards ausente → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
(
    cd "$d"
    write_frontdoor_valid
    for i in {1..130}; do echo "linha extra $i"; done >> core/role-cards.md
    git add core/role-cards.md
) >/dev/null 2>&1
check "frontdoor: role-cards >140 linhas → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
(
    cd "$d"
    awk '1; /^6\. / { print "7. `extra/read-list-estourada.md`" }' core/role-cards.md > core/role-cards.tmp
    mv core/role-cards.tmp core/role-cards.md
    git add core/role-cards.md
) >/dev/null 2>&1
check "frontdoor: read-list com 7 itens → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
(
    cd "$d"
    {
        echo "# Porta Da Frente De Papeis"
        printf 'x%.0s' {1..9000}
        echo
        echo "## PARTE A - READ-LIST DA PORTA DA FRENTE"
        echo "1. \`.hbn/relay/STATE.md\`"
        echo "## PARTE B - TRES CARTOES"
    } > core/role-cards.md
    git add core/role-cards.md
) >/dev/null 2>&1
check "frontdoor: linha unica densa >8192 bytes → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
(
    cd "$d"
    sed -i.bak 's/^3\. `core\/role-cards.md`/3.`core\/role-cards.md`/' core/role-cards.md
    rm -f core/role-cards.md.bak
    git add core/role-cards.md
) >/dev/null 2>&1
check "frontdoor: marcador sem espaco na read-list → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

d="$(make_frontdoor_repo)"
(
    cd "$d"
    sed -i.bak 's#^4\. `\.hbn/knowledge/0001-comandos-atomicos-copiaveis.md`#4. `core/inexistente-na-read-list.md`#' core/role-cards.md
    rm -f core/role-cards.md.bak
    git add core/role-cards.md
) >/dev/null 2>&1
check "frontdoor: path concreto inexistente na read-list → BLOCK" block "$(run_frontdoor "$d")"
rm -rf "$d"

# --- G-SCRATCH: area temporaria deny-by-default (P-CAND-04) ------------------
echo "== scratch guards (G-SCRATCH-LOCK/SYMLINK/IGNORE) =="
run_scratch_lock() { ( cd "$1" && bash "$GUARDS_DIR/assert-scratch-lock.sh" >/dev/null 2>&1 ); echo $?; }
run_scratch_symlink() { ( cd "$1" && bash "$GUARDS_DIR/assert-scratch-symlink.sh" >/dev/null 2>&1 ); echo $?; }
run_scratch_ignore() { ( cd "$1" && bash "$GUARDS_DIR/assert-scratch-ignore.sh" >/dev/null 2>&1 ); echo $?; }
run_scratch_all() {
    ( cd "$1" \
        && bash "$GUARDS_DIR/assert-scratch-lock.sh" >/dev/null 2>&1 \
        && bash "$GUARDS_DIR/assert-scratch-symlink.sh" >/dev/null 2>&1 \
        && bash "$GUARDS_DIR/assert-scratch-ignore.sh" >/dev/null 2>&1 )
    echo $?
}

d="$(make_repo)"
( cd "$d" && mkdir -p scratch && echo "# scratch" > scratch/README.md && git add scratch/README.md ) >/dev/null 2>&1
check "scratch: README staged passa" pass "$(run_scratch_all "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && printf '/scratch/\n!/scratch/README.md\n' > .gitignore && git add .gitignore ) >/dev/null 2>&1
check "scratch-ignore: .gitignore com linhas obrigatorias passa" pass "$(run_scratch_ignore "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && mkdir -p scratch && echo segredo > scratch/segredo.txt && git add scratch/segredo.txt ) >/dev/null 2>&1
check "scratch-lock: arquivo qualquer em scratch/ → BLOCK" block "$(run_scratch_lock "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && mkdir -p scratch && ln -s ../core scratch/link && git add scratch/link ) >/dev/null 2>&1
check "scratch-symlink: symlink em scratch/ → BLOCK" block "$(run_scratch_symlink "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && printf '!/scratch/README.md\n' > .gitignore && git add .gitignore ) >/dev/null 2>&1
check "scratch-ignore: .gitignore sem /scratch/ → BLOCK" block "$(run_scratch_ignore "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && rm -f .hbn/active-version && mkdir -p scratch && echo segredo > scratch/segredo.txt && git add scratch/segredo.txt ) >/dev/null 2>&1
check "scratch-lock: active-version ausente + arquivo scratch/ → BLOCK" block "$(run_scratch_lock "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && rm -f .hbn/active-version && mkdir -p scratch && ln -s ../core scratch/link && git add scratch/link ) >/dev/null 2>&1
check "scratch-symlink: active-version ausente + symlink scratch/ → BLOCK" block "$(run_scratch_symlink "$d")"
rm -rf "$d"

d="$(make_repo)"
( cd "$d" && rm -f .hbn/active-version && printf '/scratch/\n!/scratch/README.md\n' > .gitignore && git add .gitignore ) >/dev/null 2>&1
check "scratch-ignore: active-version ausente + .gitignore staged → BLOCK" block "$(run_scratch_ignore "$d")"
rm -rf "$d"

# --- G-ZONA-LIVRE: deny-by-default da zona livre (W3) -----------------------
echo "== assert-zona-livre (G-ZONA-LIVRE) =="
run_zona() { ( cd "$1" && bash "$GUARDS_DIR/assert-zona-livre.sh" >/dev/null 2>&1 ); echo $?; }
make_zona_repo() {
    local mode="$1" d
    d="$(make_repo)"
    (
        cd "$d"
        mkdir -p .hbn/relay .hbn/readbacks
        cat > .hbn/relay/STATE.md <<'EOF'
---
readback_ativo: ".hbn/readbacks/0001-zona.json"
---
EOF
        case "$mode" in
            curada)
                cat > .hbn/readbacks/0001-zona.json <<'EOF'
{"readback_id":"0001-zona","zona_livre_curada":true,"zona_livre_nota":"Mauricio aprovou curadoria humana explicita."}
EOF
                ;;
            sem-marcador)
                cat > .hbn/readbacks/0001-zona.json <<'EOF'
{"readback_id":"0001-zona"}
EOF
                ;;
            ilegivel)
                printf '{"readback_id":"0001-zona",\n' > .hbn/readbacks/0001-zona.json
                ;;
        esac
        git add .hbn/relay/STATE.md .hbn/readbacks/0001-zona.json
        git commit -qm zona
    ) >/dev/null 2>&1
    echo "$d"
}

d="$(make_zona_repo curada)"
( cd "$d" && mkdir -p docs/brainstorm && echo ideia > docs/brainstorm/ideia.md && git add docs/brainstorm/ideia.md ) >/dev/null 2>&1
check "zona: brainstorm com curadoria no readback passa" pass "$(run_zona "$d")"
rm -rf "$d"

d="$(make_zona_repo sem-marcador)"
( cd "$d" && mkdir -p docs/brainstorm && echo ideia > docs/brainstorm/sem-curadoria.md && git add docs/brainstorm/sem-curadoria.md ) >/dev/null 2>&1
check "zona: brainstorm sem marcador no readback → BLOCK" block "$(run_zona "$d")"
rm -rf "$d"

d="$(make_zona_repo ilegivel)"
( cd "$d" && mkdir -p docs/brainstorm && echo ideia > docs/brainstorm/readback-ilegivel.md && git add docs/brainstorm/readback-ilegivel.md ) >/dev/null 2>&1
check "zona: readback ativo ilegivel → BLOCK" block "$(run_zona "$d")"
rm -rf "$d"

# --- G-ORQ-ENTRADA: atestacao de leitura do orquestrador --------------------
run_orq_entrada() { ( cd "$1" && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 ); echo $?; }

write_valid_orq_attestation() {
    local d="$1"
    (
        cd "$d"
        python3 - <<'PY'
import hashlib, json, re, subprocess

TOKEN_FP = "34a7f2f9"
ALGORITHM = "orq-entrada.v2/extractive-lines"
STATE = ".hbn/relay/STATE.md"
READ_LIST = "core/read-list-canonica.txt"

def git_bytes(*args):
    return subprocess.check_output(["git", *args], stderr=subprocess.DEVNULL)

def blob(path):
    oid = git_bytes("rev-parse", f":{path}").decode().strip()
    return oid, git_bytes("cat-file", "-p", oid)

def sha256_b(value):
    return hashlib.sha256(value).hexdigest()

def sha256_s(value):
    return sha256_b(value.encode())

def canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))

def state_value(text, key):
    for line in text.splitlines():
        if not re.match(rf"^\s*{re.escape(key)}:", line):
            continue
        value = re.sub(r"\s+#.*$", "", line.split(":", 1)[1]).strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in ("'", '"'):
            value = value[1:-1]
        return value
    return ""

_, state_content = blob(STATE)
state_text = state_content.decode()
handoff = state_value(state_text, "handoff_mais_recente")
readback = state_value(state_text, "readback_ativo")

_, read_list_content = blob(READ_LIST)
paths = []
for raw in read_list_content.decode().splitlines():
    line = raw.split("#", 1)[0].strip()
    if not line:
        continue
    if line == "DYNAMIC handoff_mais_recente":
        paths.append(handoff)
    elif line == "DYNAMIC readback_ativo":
        paths.append(readback)
    else:
        paths.append(line.split(None, 1)[1])

manifest = []
content_by_path = {}
for path in paths:
    oid, content = blob(path)
    text = content.decode()
    nonempty = [(i, line) for i, line in enumerate(text.splitlines(), 1) if line.strip()]
    content_by_path[path] = (content, nonempty)
    manifest.append({
        "path": path,
        "blob_oid": oid,
        "sha256": sha256_b(content),
        "bytes": len(content),
        "nonempty_lines": len(nonempty),
    })

manifest_sha = sha256_s(canonical(manifest))
readback_data = json.loads(content_by_path[readback][0].decode())
execution_id = readback_data["execution_id"]
seed = sha256_s(f"orq-entrada.v2\n{execution_id}\n{TOKEN_FP}\n{manifest_sha}")

line_responses = []
for path in [STATE, readback, "core/orchestrator-profile-spec.md"]:
    record = next(item for item in manifest if item["path"] == path)
    idx = int(sha256_s(f"{seed}\n{path}\n{record['blob_oid']}")[:8], 16) % record["nonempty_lines"]
    line_no, line_text = content_by_path[path][1][idx]
    line_responses.append({
        "path": path,
        "line_no": line_no,
        "line_text": line_text,
        "line_sha256": sha256_s(line_text),
    })

data = {
    "papel": "orquestrador",
    "identidade": "opus-4-8",
    "proprietario_bastao": "claude-opus-4-8",
    "bastao_token_fp": TOKEN_FP,
    "algorithm": ALGORITHM,
    "execution_id": execution_id,
    "read_list_ref": READ_LIST,
    "atestado_por": "opus-4-8",
    "atestado_em": "2026-06-18T01:58:00-03:00",
    "manifest_sha256": manifest_sha,
    "challenge": {
        "seed_sha256": seed,
        "line_responses": line_responses,
        "field_responses": [
            {"path": STATE, "field": "readback_ativo", "value": readback},
            {"path": STATE, "field": "proxima_acao", "value": state_value(state_text, "proxima_acao")},
        ],
    },
}
with open(".hbn/attestations/34a7f2f9-orq-entrada.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
    )
}

make_orq_entrada_repo() {
    local d; d="$(make_repo)"
    (
        cd "$d"
        mkdir -p .hbn/relay .hbn/readbacks .hbn/messages .hbn/attestations \
            .hbn/knowledge agents core guards/data
        cat > .hbn/relay/STATE.md <<'EOF'
---
bastao_token_sha256: 34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf
proprietario_bastao: claude-opus-4-8
papel_bastao: "orquestrador"
readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"
handoff_mais_recente: ".hbn/messages/20260618-003300-codex-handoff-g-orq-entrada.md"
proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."
atribuicao:
  chapeu_atual: orquestrador
  implementador: codex
---
EOF
        echo '{"readback_id":"0056-g-orq-entrada","execution_id":"g-orq-entrada-test-2026-06-18","agent_id":"codex","track":"safe_track","human_status":"confirmed","authorization":{"human":"Mauricio","evidence":"teste"}}' > .hbn/readbacks/0056-g-orq-entrada.json
        echo "# Handoff G-ORQ-ENTRADA" > .hbn/messages/20260618-003300-codex-handoff-g-orq-entrada.md
        echo "# role templates" > agents/role-templates.md
        echo "# firewall 0022" > .hbn/knowledge/0022-firewall-workflow-fast-track.md
        echo "# role cards" > core/role-cards.md
        echo "# comandos" > .hbn/knowledge/0001-comandos-atomicos-copiaveis.md
        echo "# entrega" > .hbn/knowledge/0002-entrega-operacional-minimalista.md
        echo "# temporaria" > .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
        echo "# gate enforcado falha fechado" > .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md
        echo "# auditor read-only" > .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md
        echo "# fornecedor(implementador) != fornecedor(orquestrador)" > core/orchestrator-profile-spec.md
        echo "# STATE <= 80 linhas" > core/relay-spec.md
        cat > core/read-list-canonica.txt <<EOF
$(git hash-object .hbn/relay/STATE.md) .hbn/relay/STATE.md
DYNAMIC handoff_mais_recente
DYNAMIC readback_ativo
$(git hash-object agents/role-templates.md) agents/role-templates.md
$(git hash-object .hbn/knowledge/0022-firewall-workflow-fast-track.md) .hbn/knowledge/0022-firewall-workflow-fast-track.md
$(git hash-object core/role-cards.md) core/role-cards.md
$(git hash-object .hbn/knowledge/0001-comandos-atomicos-copiaveis.md) .hbn/knowledge/0001-comandos-atomicos-copiaveis.md
$(git hash-object .hbn/knowledge/0002-entrega-operacional-minimalista.md) .hbn/knowledge/0002-entrega-operacional-minimalista.md
$(git hash-object .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md) .hbn/knowledge/0023-area-temporaria-e-fixtures-efemeras.md
$(git hash-object .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md) .hbn/knowledge/0024-orquestrador-nao-sela-zona-livre-sem-aprovacao.md
$(git hash-object .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md) .hbn/knowledge/0025-auditor-read-only-sem-no-verify.md
$(git hash-object core/orchestrator-profile-spec.md) core/orchestrator-profile-spec.md
$(git hash-object core/relay-spec.md) core/relay-spec.md
EOF
        git add -A
    ) >/dev/null 2>&1
    write_valid_orq_attestation "$d"
    ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm orq-entrada ) >/dev/null 2>&1
    echo "$d"
}

# --- G-FRZ: freeze-gate ------------------------------------------------------
echo "== freeze-gate (G-FRZ) =="
make_frz_repo() { # [ok|pending-readback|resolved-by-seal|resolved-by-state|bad-atestacao]
    local variant="${1:-ok}" d
    d="$(make_orq_entrada_repo)"
    (
        cd "$d"
        mkdir -p guards/tests/fixtures/hearbacks
        cat > guards/tests/fixtures/hearbacks/confirmado-com-excecao.json <<'EOF'
{"hearback_id":"fixture-confirmado-com-excecao","path":"guards/tests/fixtures/hearbacks/confirmado-com-excecao.json","status":"confirmed","signed_by":"fixture-teste","signed_at":"2026-06-10T00:00:00-03:00","excecoes_cobertas":[{"tipo":"familia","entre":["alpha-1","alpha-2"]}],"notes":"FIXTURE de teste (ADR-020) — hearback confirmado que COBRE a exceção de família alpha-1×alpha-2. Não é decisão real."}
EOF
        git add guards/tests/fixtures/hearbacks/confirmado-com-excecao.json
        git commit -qm frz-hearback

        case "$variant" in
            ok)
                ;;
            pending-readback)
                cat > .hbn/readbacks/0099-freeze-pendente.json <<'EOF'
{"readback_id":"0099-freeze-pendente","execution_id":"freeze-pendente-test","track":"safe_track","human_status":"confirmed","status":"implemented_pending_cross_audit","activation_status":"PROPOSED_UNTIL_CROSS_AUDIT"}
EOF
                git add .hbn/readbacks/0099-freeze-pendente.json
                git commit -qm frz-pending-readback
                ;;
            resolved-by-seal)
                cat > .hbn/readbacks/0099-freeze-pendente.json <<'EOF'
{"readback_id":"0099-freeze-pendente","execution_id":"freeze-pendente-test","track":"safe_track","human_status":"confirmed","status":"implemented_pending_cross_audit","activation_status":"PROPOSED_UNTIL_CROSS_AUDIT"}
EOF
                cat > .hbn/readbacks/0100-freeze-selagem.json <<'EOF'
{"readback_id":"0100-freeze-selagem","execution_id":"freeze-selagem-test","track":"safe_track","human_status":"confirmed","status":"vigente","seals_proposal":"0099"}
EOF
                git add .hbn/readbacks/0099-freeze-pendente.json .hbn/readbacks/0100-freeze-selagem.json
                git commit -qm frz-resolved-by-seal
                ;;
            resolved-by-state)
                cat > .hbn/readbacks/0098-freeze-pendente.json <<'EOF'
{"readback_id":"0098-freeze-pendente","execution_id":"freeze-pendente-state-test","track":"safe_track","human_status":"confirmed","status":"implemented_pending_cross_audit","activation_status":"PROPOSED_UNTIL_CROSS_AUDIT"}
EOF
                python3 - <<'PY'
from pathlib import Path

path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace(
    'papel_bastao: "orquestrador"\n',
    'papel_bastao: "orquestrador"\nprotocolo: "fixture: 0098 selado e vigente via ledger"\n',
    1,
)
path.write_text(text, encoding="utf-8")
PY
                git add .hbn/relay/STATE.md .hbn/readbacks/0098-freeze-pendente.json
                write_valid_orq_attestation "$d"
                git add .hbn/attestations/34a7f2f9-orq-entrada.json
                git commit -qm frz-resolved-by-state
                ;;
            bad-atestacao)
                python3 - <<'PY'
import json
path = ".hbn/attestations/34a7f2f9-orq-entrada.json"
data = json.load(open(path, encoding="utf-8"))
data["manifest_sha256"] = "0" * 64
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
                git add .hbn/attestations/34a7f2f9-orq-entrada.json
                ;;
            *)
                echo "variant desconhecida: $variant" >&2
                exit 2
                ;;
        esac
    ) >/dev/null 2>&1
    echo "$d"
}

run_frz() { # <checklist> [repo-variant]
    local checklist="$1" variant="${2:-ok}" d rc
    d="$(make_frz_repo "$variant")"
    ( cd "$d" && bash "$GUARDS_DIR/freeze-gate.sh" "$checklist" >/dev/null 2>&1 )
    rc=$?
    rm -rf "$d"
    echo "$rc"
}
check "frz: tudo ok com evidência + meta-deref verde"  pass  "$(run_frz "$FIX/freeze/good-all-ok.json")"
check "frz: na obrigatório COM hearback verificável"    pass  "$(run_frz "$FIX/freeze/good-na-com-hearback.json")"
check "frz: na obrigatório SEM hearback (bug F-01)"     block "$(run_frz "$FIX/freeze/bad-na-sem-hearback.json")"
check "frz: ok sem evidência (Truth Barrier)"           block "$(run_frz "$FIX/freeze/bad-ok-sem-evidencia.json")"
check "frz: bloqueador aberto"                          block "$(run_frz "$FIX/freeze/bad-bloqueador.json")"
check "frz: proposta PROPOSED resolvida por seals_proposal" pass "$(run_frz "$FIX/freeze/good-all-ok.json" resolved-by-seal)"
check "frz: proposta PROPOSED resolvida por STATE"       pass  "$(run_frz "$FIX/freeze/good-all-ok.json" resolved-by-state)"
check "frz: proposta PROPOSED sem seal nem ledger"       block "$(run_frz "$FIX/freeze/good-all-ok.json" pending-readback)"
check "frz: atestação de entrada não-verde"             block "$(run_frz "$FIX/freeze/good-all-ok.json" bad-atestacao)"

echo "== assert-orq-entrada (G-ORQ-ENTRADA) =="
d="$(make_orq_entrada_repo)"
check "orq-entrada: atestacao v2 valida sem gabarito.txt passa" pass "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
( cd "$d" && git rm -q .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-entrada: sem atestacao → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["line_responses"][0]["line_text"] = "linha forjada"
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-entrada: linha extrativa errada → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["line_responses"][0]["line_sha256"] = "0" * 64
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-entrada: line_sha256 errado → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import hashlib, json, sys
path = sys.argv[1]
data = json.load(open(path))
old_manifest = "1" * 64
data["manifest_sha256"] = old_manifest
data["challenge"]["seed_sha256"] = hashlib.sha256(
    f"orq-entrada.v2\n{data['execution_id']}\n34a7f2f9\n{old_manifest}".encode()
).hexdigest()
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-entrada: seed de manifest velho → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
data["challenge"]["field_responses"] = [
    item for item in data["challenge"]["field_responses"]
    if item.get("field") != "proxima_acao"
]
json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-entrada: field ausente → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
( cd "$d" && printf '\ndrift staged\n' >> core/relay-spec.md && git add core/relay-spec.md ) >/dev/null 2>&1
check "orq-entrada: arquivo da read-list mudado → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

# --- G-ORQ-REF: orq_entrada_ref em atos de autoridade ------------------------
echo "== assert-orq-entrada-ref (G-ORQ-REF) =="
run_orq_ref() { ( cd "$1" && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $?; }

set_orq_ref_on_active_readback() { # <repo> <ref>
    local d="$1" ref="$2"
    python3 - "$d/.hbn/readbacks/0056-g-orq-entrada.json" "$ref" <<'PY'
import json, sys
path, ref = sys.argv[1:3]
data = json.load(open(path, encoding="utf-8"))
data["orq_entrada_ref"] = ref
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
    ( cd "$d" && git add .hbn/readbacks/0056-g-orq-entrada.json ) >/dev/null 2>&1
    write_valid_orq_attestation "$d"
    ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm orq-ref-base ) >/dev/null 2>&1
}

stage_orq_dispatch() {
    local d="$1"
    (
        cd "$d"
        mkdir -p .hbn/dispatch
        cat > .hbn/dispatch/0056-g-orq-entrada.md <<'EOF'
---
dispatch_id: 0056-g-orq-entrada
path: .hbn/dispatch/0056-g-orq-entrada.md
readback_id: 0056-g-orq-entrada
token_fp: 34a7f2f9
human_authorization: Mauricio
---
Executar despacho de autoridade.
EOF
        git add .hbn/dispatch/0056-g-orq-entrada.md
    ) >/dev/null 2>&1
}

stage_orq_message_dispatch() {
    local d="$1"
    (
        cd "$d"
        mkdir -p .hbn/messages
        cat > .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md <<'EOF'
---
tipo: despacho
path: .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md
readback_alvo: 0056-g-orq-entrada
token_fp: 34a7f2f9
human_authorization: Mauricio
---
Executar despacho de autoridade em .hbn/messages.
EOF
        git add .hbn/messages/20260621-020000-opus-4-8-despacho-w-orq-4b-orqref.md
    ) >/dev/null 2>&1
}

stage_orq_neutral_messages() {
    local d="$1"
    (
        cd "$d"
        mkdir -p .hbn/messages
        for tipo in handoff prompt entrada; do
            cat > ".hbn/messages/20260621-020000-codex-${tipo}-neutro.md" <<EOF
---
tipo: ${tipo}
path: .hbn/messages/20260621-020000-codex-${tipo}-neutro.md
---
Mensagem ${tipo} sem orq_entrada_ref.
EOF
            git add ".hbn/messages/20260621-020000-codex-${tipo}-neutro.md"
        done
    ) >/dev/null 2>&1
}

make_orq_ref_base() { # [ref]
    local ref="${1:-.hbn/attestations/34a7f2f9-orq-entrada.json}" d
    d="$(make_orq_entrada_repo)"
    set_orq_ref_on_active_readback "$d" "$ref"
    echo "$d"
}

d="$(make_orq_ref_base)"
stage_orq_dispatch "$d"
check "orq-ref: despacho com ref valida passa" pass "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
stage_orq_dispatch "$d"
check "orq-ref: despacho com ref omitido → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
( cd "$d" && git rm -q .hbn/attestations/34a7f2f9-orq-entrada.json && git commit -qm remove-orq-attestation ) >/dev/null 2>&1
stage_orq_dispatch "$d"
check "orq-ref: ref dangling/atestacao ausente → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base ".hbn/attestations/deadbeef-orq-entrada.json")"
stage_orq_dispatch "$d"
check "orq-ref: fp trocado no ref → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_message_dispatch "$d"
check "orq-ref: .hbn/messages despacho com ref valida passa" pass "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
stage_orq_message_dispatch "$d"
check "orq-ref: .hbn/messages despacho sem ref → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base ".hbn/attestations/deadbeef-orq-entrada.json")"
stage_orq_message_dispatch "$d"
check "orq-ref: .hbn/messages despacho ref divergente → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
stage_orq_neutral_messages "$d"
check "orq-ref: .hbn/messages handoff/prompt/entrada sem ref passa" pass "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_dispatch "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["nota_repin"] = "alteracao no mesmo commit de autoridade"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref: auto-repin no mesmo commit → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_entrada_repo)"
(
    cd "$d"
    cat > .hbn/readbacks/0061-w-orq-3.json <<'EOF'
{"readback_id":"0061-w-orq-3","execution_id":"w-orq-3-test","track":"safe_track","status":"in_progress","human_status":"confirmed"}
EOF
    git add .hbn/readbacks/0061-w-orq-3.json
) >/dev/null 2>&1
check "orq-ref: entrega nao-autoridade sem ref passa" pass "$(run_orq_ref "$d")"
rm -rf "$d"

stage_orq_selagem_same_fp() { # <repo>
    local d="$1"
    (
        cd "$d"
        cat > .hbn/readbacks/0062-selagem-w-orq-3b.json <<'EOF'
{"readback_id":"0062-selagem-w-orq-3b","execution_id":"w-orq-3b-selagem-test","track":"safe_track","human_status":"confirmed","status":"selado","authority_act":"selagem","orq_entrada_ref":".hbn/attestations/34a7f2f9-orq-entrada.json"}
EOF
        python3 - <<'PY'
from pathlib import Path
path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace('readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"', 'readback_ativo: ".hbn/readbacks/0062-selagem-w-orq-3b.json"')
text = text.replace('proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."', 'proxima_acao: "Cross-audit W-ORQ-3b apos dogfood P1."')
path.write_text(text, encoding="utf-8")
PY
        git add .hbn/relay/STATE.md .hbn/readbacks/0062-selagem-w-orq-3b.json
    ) >/dev/null 2>&1
    write_valid_orq_attestation "$d"
    ( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
}

stage_orq_selagem_no_regen() { # <repo>
    local d="$1"
    (
        cd "$d"
        cat > .hbn/readbacks/0062-selagem-w-orq-3b.json <<'EOF'
{"readback_id":"0062-selagem-w-orq-3b","execution_id":"w-orq-3b-selagem-test","track":"safe_track","human_status":"confirmed","status":"selado","authority_act":"selagem","orq_entrada_ref":".hbn/attestations/34a7f2f9-orq-entrada.json"}
EOF
        python3 - <<'PY'
from pathlib import Path
path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace('readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"', 'readback_ativo: ".hbn/readbacks/0062-selagem-w-orq-3b.json"')
text = text.replace('proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."', 'proxima_acao: "Cross-audit W-ORQ-3b apos dogfood P1."')
path.write_text(text, encoding="utf-8")
PY
        git add .hbn/relay/STATE.md .hbn/readbacks/0062-selagem-w-orq-3b.json
    ) >/dev/null 2>&1
}

run_orq_both() {
    ( cd "$1" \
        && bash "$GUARDS_DIR/assert-orq-entrada.sh" >/dev/null 2>&1 \
        && bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 )
    echo $?
}

d="$(make_orq_ref_base)"
stage_orq_selagem_same_fp "$d"
check "orq-ref P1: selagem real same-fp passa G-ORQ + G-ORQ-REF" pass "$(run_orq_both "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_selagem_no_regen "$d"
check "orq-ref N1: selagem sem regenerar atestacao → BLOCK" block "$(run_orq_entrada "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_selagem_no_regen "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["nota_repin"] = "decorativo sem manifest novo"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref N2: atestacao decorativa sem manifest novo → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_selagem_same_fp "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["bastao_token_fp"] = "deadbeef"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref N3: atestacao esperada com fp JSON trocado → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_selagem_same_fp "$d"
( cd "$d" && cp .hbn/attestations/34a7f2f9-orq-entrada.json .hbn/attestations/deadbeef-orq-entrada.json && git add .hbn/attestations/deadbeef-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref N4: atestacao extra staged junto → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
(
    cd "$d"
    cat > .hbn/readbacks/0062-selagem-w-orq-3b.json <<'EOF'
{"readback_id":"0062-selagem-w-orq-3b","execution_id":"w-orq-3b-selagem-test","track":"safe_track","human_status":"confirmed","status":"selado","authority_act":"selagem","orq_entrada_ref":".hbn/attestations/34a7f2f9-orq-entrada.json"}
EOF
    python3 - <<'PY'
from pathlib import Path
path = Path(".hbn/relay/STATE.md")
text = path.read_text(encoding="utf-8")
text = text.replace("34a7f2f9882b7f4a8a5d54bfa40b957ae4369d8d3c4ba8bdbe52543b0d616daf", "34a7f2f900000000000000000000000000000000000000000000000000000000")
text = text.replace('readback_ativo: ".hbn/readbacks/0056-g-orq-entrada.json"', 'readback_ativo: ".hbn/readbacks/0062-selagem-w-orq-3b.json"')
text = text.replace('proxima_acao: "Cross-audit do gate G-ORQ-ENTRADA."', 'proxima_acao: "Cross-audit W-ORQ-3b apos dogfood P1."')
path.write_text(text, encoding="utf-8")
PY
    git add .hbn/relay/STATE.md .hbn/readbacks/0062-selagem-w-orq-3b.json
) >/dev/null 2>&1
write_valid_orq_attestation "$d"
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref N5: bastao_token_sha256 completo trocado com mesmo fp → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
stage_orq_selagem_same_fp "$d"
python3 - "$d/.hbn/attestations/34a7f2f9-orq-entrada.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["identidade"] = "opus-4-8-alterado"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/attestations/34a7f2f9-orq-entrada.json ) >/dev/null 2>&1
check "orq-ref N6: identidade divergente do HEAD/base → BLOCK" block "$(run_orq_ref "$d")"
rm -rf "$d"

d="$(make_orq_ref_base)"
base="$(cd "$d" && git rev-parse HEAD)"
stage_orq_selagem_same_fp "$d"
( cd "$d" && git commit -qm selagem-same-fp ) >/dev/null 2>&1
check "orq-ref CI: selagem same-fp passa no range" pass "$( ( cd "$d" && HBN_DIFF_BASE="$base" bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

d="$(make_orq_ref_base)"
base="$(cd "$d" && git rev-parse HEAD)"
stage_orq_selagem_same_fp "$d"
python3 - "$d/.hbn/readbacks/0062-selagem-w-orq-3b.json" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data["orq_entrada_ref"] = ".hbn/attestations/deadbeef-orq-entrada.json"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2, ensure_ascii=False)
open(path, "a", encoding="utf-8").write("\n")
PY
( cd "$d" && git add .hbn/readbacks/0062-selagem-w-orq-3b.json && git commit -qm selagem-fp-trocado ) >/dev/null 2>&1
check "orq-ref CI: fp trocado bloqueia no range" block "$( ( cd "$d" && HBN_DIFF_BASE="$base" bash "$GUARDS_DIR/assert-orq-entrada-ref.sh" >/dev/null 2>&1 ); echo $? )"
rm -rf "$d"

# --- G-NEXT: proximo ponto de conferencia em STATE ---------------------------
echo "== assert-next-checkpoint (G-NEXT) =="
run_next() { ( cd "$1" && bash "$GUARDS_DIR/assert-next-checkpoint.sh" >/dev/null 2>&1 ); echo $?; }

make_next_repo() { # <good|sem-mapa|ato-invalido|destino-invalido|bloco-inexistente|duplicado>
    local variant="$1" d
    d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/relay .hbn/messages guards/data
        echo "." > .hbn/active-version
        cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
opus Anthropic
grok xAI
antigravity Google
EOF
        echo "# Despacho G-NEXT" > .hbn/messages/next.md
        case "$variant" in
            good)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
                ;;
            sem-mapa)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proxima_acao: "texto legado sem campo de maquina"
---
EOF
                ;;
            ato-invalido)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: teleporte
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
                ;;
            destino-invalido)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: bard
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
                ;;
            bloco-inexistente)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/ausente.md
  status: pendente
---
EOF
                ;;
            duplicado)
                cat > .hbn/relay/STATE.md <<'EOF'
---
state_version: 1
proximo_ponto:
  passo: "cross-audit do G-NEXT"
  ato: cross-audit
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
proximo_ponto:
  passo: "hearback duplicado"
  ato: hearback
  destino: human
  gate: hearback_humano
  bloco_ref: .hbn/messages/next.md
  status: pendente
---
EOF
                ;;
        esac
        git add .hbn/active-version guards/data/auditor-families.txt .hbn/relay/STATE.md
        if [[ "$variant" != "bloco-inexistente" ]]; then
            git add .hbn/messages/next.md
        fi
    ) >/dev/null 2>&1
    echo "$d"
}

d="$(make_next_repo good)"
check "next: STATE com proximo_ponto bem-formado passa" pass "$(run_next "$d")"
rm -rf "$d"

d="$(make_next_repo sem-mapa)"
check "next: STATE sem proximo_ponto → BLOCK" block "$(run_next "$d")"
rm -rf "$d"

d="$(make_next_repo ato-invalido)"
check "next: ato fora do enum → BLOCK" block "$(run_next "$d")"
rm -rf "$d"

d="$(make_next_repo destino-invalido)"
check "next: destino nao-canonico → BLOCK" block "$(run_next "$d")"
rm -rf "$d"

d="$(make_next_repo bloco-inexistente)"
check "next: bloco_ref inexistente → BLOCK" block "$(run_next "$d")"
rm -rf "$d"

d="$(make_next_repo duplicado)"
check "next: proximo_ponto duplicado → BLOCK" block "$(run_next "$d")"
rm -rf "$d"

# --- G-QUORUM: quorum canonico de selagem -----------------------------------
echo "== assert-quorum-selagem (G-QUORUM) =="
run_quorum() { ( cd "$1" && bash "$GUARDS_DIR/assert-quorum-selagem.sh" >/dev/null 2>&1 ); echo $?; }

make_quorum_repo() { # <good|sem-seals|um-parecer|mesma-familia|openai-nao-conta|sem-aprova>
    local variant="$1" d
    d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/readbacks .hbn/results guards/data
        echo "." > .hbn/active-version
        cat > guards/data/auditor-families.txt <<'EOF'
codex OpenAI
gpt-5 OpenAI
grok xAI
grok2 xAI
antigravity Google
EOF
        if [[ "$variant" == "sem-seals" ]]; then
            cat > .hbn/readbacks/0100-selagem-teste.json <<'EOF'
{"readback_id":"0100-selagem-teste","status":"vigente"}
EOF
        else
            cat > .hbn/readbacks/0100-selagem-teste.json <<'EOF'
{"readback_id":"0100-selagem-teste","status":"vigente","seals_proposal":"0099"}
EOF
        fi
        write_quorum_result() {
            local path="$1" autor="$2" familia="$3" verdict="$4"
            {
                printf -- '---\n'
                printf 'autor: %s\n' "$autor"
                printf 'familia: %s\n' "$familia"
                printf -- '---\n'
                printf '# Parecer\n'
                if [[ -n "$verdict" ]]; then
                    printf '%s\n' "$verdict"
                else
                    printf 'Sem aprovacao canonica.\n'
                fi
            } > "$path"
        }
        case "$variant" in
            good|sem-seals)
                write_quorum_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
                write_quorum_result .hbn/results/20260101-010102-antigravity-cross-ia-quorum-0099.md antigravity Google "APROVA_0099: SIM"
                ;;
            um-parecer)
                write_quorum_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
                ;;
            mesma-familia)
                write_quorum_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
                write_quorum_result .hbn/results/20260101-010102-grok2-cross-ia-quorum-0099.md grok2 xAI "APROVA_0099: SIM"
                ;;
            openai-nao-conta)
                write_quorum_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
                write_quorum_result .hbn/results/20260101-010102-codex-cross-ia-quorum-0099.md codex OpenAI "APROVA_0099: SIM"
                ;;
            sem-aprova)
                write_quorum_result .hbn/results/20260101-010101-grok-cross-ia-quorum-0099.md grok xAI "APROVA_0099: SIM"
                write_quorum_result .hbn/results/20260101-010102-antigravity-cross-ia-quorum-0099.md antigravity Google ""
                ;;
        esac
        git add .hbn/active-version guards/data/auditor-families.txt .hbn/readbacks/0100-selagem-teste.json .hbn/results
    ) >/dev/null 2>&1
    echo "$d"
}

d="$(make_quorum_repo good)"
check "quorum: selagem com seals_proposal + 2 familias != OpenAI passa" pass "$(run_quorum "$d")"
rm -rf "$d"

d="$(make_quorum_repo sem-seals)"
check "quorum: readback vigente sem seals_proposal → BLOCK" block "$(run_quorum "$d")"
rm -rf "$d"

d="$(make_quorum_repo um-parecer)"
check "quorum: so 1 parecer != OpenAI → BLOCK" block "$(run_quorum "$d")"
rm -rf "$d"

d="$(make_quorum_repo mesma-familia)"
check "quorum: 2 pareceres da mesma familia → BLOCK" block "$(run_quorum "$d")"
rm -rf "$d"

d="$(make_quorum_repo openai-nao-conta)"
check "quorum: parecer OpenAI nao conta para quorum → BLOCK" block "$(run_quorum "$d")"
rm -rf "$d"

d="$(make_quorum_repo sem-aprova)"
check "quorum: parecer sem APROVA_NNNN SIM → BLOCK" block "$(run_quorum "$d")"
rm -rf "$d"

# --- G-READLIST-RITE: read-list canonica exige rito declarado ----------------
echo "== assert-readlist-rite (G-READLIST-RITE) =="
run_readlist_rite_guard() { ( cd "$1" && bash "$GUARDS_DIR/assert-readlist-rite.sh" >/dev/null 2>&1 ); echo $?; }

make_readlist_rite_repo() { # <good|sem-readback|sem-rite|human-pendente|neutro>
    local variant="$1" d
    d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn/readbacks core docs
        echo "." > .hbn/active-version
        printf 'base .hbn/relay/STATE.md\n' > core/read-list-canonica.txt
        git add .hbn/active-version core/read-list-canonica.txt
        git commit -qm init
        case "$variant" in
            good)
                printf 'base .hbn/relay/STATE.md\nnovo core/role-cards.md\n' > core/read-list-canonica.txt
                cat > .hbn/readbacks/0100-rite.json <<'EOF'
{"readback_id":"0100-rite","human_status":"confirmed","read_list_rite":"0100-rite"}
EOF
                git add core/read-list-canonica.txt .hbn/readbacks/0100-rite.json
                ;;
            sem-readback)
                printf 'base .hbn/relay/STATE.md\nnovo core/role-cards.md\n' > core/read-list-canonica.txt
                git add core/read-list-canonica.txt
                ;;
            sem-rite)
                printf 'base .hbn/relay/STATE.md\nnovo core/role-cards.md\n' > core/read-list-canonica.txt
                cat > .hbn/readbacks/0100-sem-rite.json <<'EOF'
{"readback_id":"0100-sem-rite","human_status":"confirmed"}
EOF
                git add core/read-list-canonica.txt .hbn/readbacks/0100-sem-rite.json
                ;;
            human-pendente)
                printf 'base .hbn/relay/STATE.md\nnovo core/role-cards.md\n' > core/read-list-canonica.txt
                cat > .hbn/readbacks/0100-human-pendente.json <<'EOF'
{"readback_id":"0100-human-pendente","human_status":"pending","read_list_rite":"0100-human-pendente"}
EOF
                git add core/read-list-canonica.txt .hbn/readbacks/0100-human-pendente.json
                ;;
            neutro)
                printf 'outro arquivo\n' > docs/neutro.md
                git add docs/neutro.md
                ;;
        esac
    ) >/dev/null 2>&1
    echo "$d"
}

d="$(make_readlist_rite_repo good)"
check "readlist-rite: read-list A/M com rito confirmado passa" pass "$(run_readlist_rite_guard "$d")"
rm -rf "$d"

d="$(make_readlist_rite_repo sem-readback)"
check "readlist-rite: read-list A/M sem readback staged → BLOCK" block "$(run_readlist_rite_guard "$d")"
rm -rf "$d"

d="$(make_readlist_rite_repo sem-rite)"
check "readlist-rite: readback staged sem read_list_rite → BLOCK" block "$(run_readlist_rite_guard "$d")"
rm -rf "$d"

d="$(make_readlist_rite_repo human-pendente)"
check "readlist-rite: read_list_rite com human_status != confirmed → BLOCK" block "$(run_readlist_rite_guard "$d")"
rm -rf "$d"

d="$(make_readlist_rite_repo neutro)"
check "readlist-rite: diff neutro sem read-list passa" pass "$(run_readlist_rite_guard "$d")"
rm -rf "$d"

# --- G-CI-BATTERY: HBN Shield preserva entrypoint exato ----------------------
echo "== assert-ci-battery (G-CI-BATTERY) =="
run_ci_battery_guard() { ( cd "$1" && bash "$GUARDS_DIR/assert-ci-battery.sh" >/dev/null 2>&1 ); echo $?; }

make_ci_battery_repo() { # <good|sem-entrypoint|echo-entrypoint|heredoc-entrypoint|entry-missing-battery|entry-fake-battery>
    local variant="$1" d
    d="$(mktemp -d)"
    (
        cd "$d"
        git init -q
        git config user.email "tests@hbn.local"
        git config user.name "hbn-guard-tests"
        mkdir -p .hbn .github/workflows guards/tests
        echo "." > .hbn/active-version

        cat > guards/ci-entry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash guards/hbn-guards-runner.sh
bash guards/tests/run-guard-tests.sh
bash guards/tests/adversarial-battery.sh
EOF

        case "$variant" in
            good)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: hbn-ci-entry
        env:
          HBN_DIFF_BASE: ${{ github.event.pull_request.base.sha || github.event.before }}
        run: bash guards/ci-entry.sh
EOF
                ;;
            sem-entrypoint)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash guards/hbn-guards-runner.sh
      - run: bash guards/tests/run-guard-tests.sh
      - run: bash guards/tests/adversarial-battery.sh
EOF
                ;;
            echo-entrypoint)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "bash guards/ci-entry.sh"
EOF
                ;;
            heredoc-entrypoint)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          cat <<EOF2
          bash guards/ci-entry.sh
          EOF2
EOF
                ;;
            entry-missing-battery)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash guards/ci-entry.sh
EOF
                cat > guards/ci-entry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash guards/hbn-guards-runner.sh
bash guards/tests/run-guard-tests.sh
EOF
                ;;
            entry-fake-battery)
                cat > .github/workflows/hbn-shield.yml <<'EOF'
name: HBN Shield
on: [pull_request]
jobs:
  guards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash guards/ci-entry.sh
EOF
                cat > guards/ci-entry.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
bash guards/hbn-guards-runner.sh
bash guards/tests/run-guard-tests.sh
cat <<EOF2
bash guards/tests/adversarial-battery.sh
EOF2
echo "bash guards/tests/adversarial-battery.sh"
EOF
                ;;
        esac
        git add .hbn/active-version .github/workflows/hbn-shield.yml guards/ci-entry.sh
    ) >/dev/null 2>&1
    echo "$d"
}

d="$(make_ci_battery_repo good)"
check "ci-battery: workflow com entrypoint exato passa" pass "$(run_ci_battery_guard "$d")"
rm -rf "$d"

d="$(make_ci_battery_repo sem-entrypoint)"
check "ci-battery: workflow sem step exato de ci-entry.sh -> BLOCK" block "$(run_ci_battery_guard "$d")"
rm -rf "$d"

d="$(make_ci_battery_repo echo-entrypoint)"
check "ci-battery: workflow com echo de ci-entry.sh -> BLOCK" block "$(run_ci_battery_guard "$d")"
rm -rf "$d"

d="$(make_ci_battery_repo heredoc-entrypoint)"
check "ci-battery: workflow com heredoc-data de ci-entry.sh -> BLOCK" block "$(run_ci_battery_guard "$d")"
rm -rf "$d"

d="$(make_ci_battery_repo entry-missing-battery)"
check "ci-battery: ci-entry.sh sem adversarial-battery.sh -> BLOCK" block "$(run_ci_battery_guard "$d")"
rm -rf "$d"

d="$(make_ci_battery_repo entry-fake-battery)"
check "ci-battery: ci-entry.sh com invocacao fingida -> BLOCK" block "$(run_ci_battery_guard "$d")"
rm -rf "$d"

# --- Read-list viva (onda 0006 I-01 — F-08 dos cross-audits 0036/0037) -------
# Todo path .hbn/ | core/ | guards/ | schemas/ CITADO em agents/role-templates.md
# e nos 4 specs core do rito deve EXISTIR no disco. A "referência quebrada"
# (knowledge 0019/0022 citadas sem existir) vira classe de erro permanente.
echo "== read-list viva (referência citada deve existir) =="
readlist_scan() { # <arquivo...> ; rc=0 se todos os paths citados existem
    local missing=0 f p
    for f in "$@"; do
        [[ -f "$f" ]] || { echo "    arquivo da read-list ausente: $f"; missing=1; continue; }
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue
            p="${p%.}"          # pontuação final de frase
            [[ "$p" == *NNNN* || "$p" == *AAAAMMDD* || "$p" == *\<* ]] && continue
            if compgen -G "$REPO_ROOT/${p}*" >/dev/null; then continue; fi
            echo "    referência quebrada: ${p} (citada em $(basename "$f"))"
            missing=1
        done < <(grep -ohE '(\.hbn/[A-Za-z0-9_./-]+|core/[A-Za-z0-9_./-]+|guards/[A-Za-z0-9_./-]+|schemas/[A-Za-z0-9_./-]+)' "$f" 2>/dev/null | sort -u)
    done
    return $missing
}
run_readlist() { ( readlist_scan "$@" >/dev/null 2>&1 ); echo $?; }
check "readlist: templates+4 specs core sem referência quebrada" pass "$(run_readlist \
    "$REPO_ROOT/agents/role-templates.md" \
    "$REPO_ROOT/core/start-rite-spec.md" \
    "$REPO_ROOT/core/orchestrator-profile-spec.md" \
    "$REPO_ROOT/core/pointer-spec.md" \
    "$REPO_ROOT/core/state-report-spec.md")"
# caso-ruim (ADR-020): citação de path inexistente DEVE reprovar
r="$(mktemp -d)"
printf 'leia .hbn/knowledge/9999-inexistente.md antes de tudo\n' > "$r/template-quebrado.md"
check "readlist: referência quebrada é detectada (F-08)"        block "$(run_readlist "$r/template-quebrado.md")"
rm -rf "$r"

# --- Resumo humano (Bloco 4 dogfood) -----------------------------------------
echo ""
echo "== resumo: ${PASS} passaram, ${FAIL} falharam =="
if [[ "$FAIL" -ne 0 ]]; then
    for f in "${FALHAS[@]}"; do echo "  ✗ $f"; done
    echo "SUÍTE VERMELHA — nenhum guard pode ser ativado no runner (ADR-020 Decisão 2)."
    exit 1
fi
echo "SUÍTE VERDE — todos os casos-ruins BLOQUEADOS, todos os casos-bons passam."
exit 0
