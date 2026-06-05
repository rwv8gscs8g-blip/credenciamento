#!/usr/bin/env python3
# =============================================================================
# scripts/hbn-guards/ci/validate-contracts.py
# CI v1 (onda 0116/A3): validação de contratos HBN em modo RATCHET.
#
# Por quê ratchet (achado empírico 2026-06-05, doc 125): 79/126 readbacks e
# 11/36 hearbacks do histórico NÃO validam contra os schemas 1.0.0 — parte é
# legado pré-Onda-36, parte é drift recente (enum evidence_kind estreito,
# hearback additionalProperties:false). Validar tudo estrito = CI vermelho
# permanente por passivo. O ratchet impede drift NOVO sem exigir retrofit:
#
#   - ESTRITO (bloqueia): contratos TOCADOS no range (--changed f1 f2 ...)
#     devem validar contra o schema.
#   - SEMPRE (bloqueia): todo contrato do repo deve ser JSON parseável;
#     .hbn/canonical-root deve coincidir com o const do readback.schema.
#   - RELATÓRIO (não bloqueia): contagem repo-wide de contratos fora do
#     schema — passivo visível, insumo do item A5 (schema 1.1.0).
#
# Uso: python3 validate-contracts.py <repo_root> [--changed f1 f2 ...]
# Requer: jsonschema (instalado pelo workflow).
# =============================================================================
import glob
import json
import os
import sys

try:
    import jsonschema
except ImportError:
    print("[validate-contracts] ERRO: jsonschema ausente (pip install jsonschema)", file=sys.stderr)
    sys.exit(2)

args = sys.argv[1:]
ROOT = os.path.abspath(args[0]) if args else os.getcwd()
CHANGED = []
if "--changed" in args:
    CHANGED = [a for a in args[args.index("--changed") + 1:] if a]
FAILS = []


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def schema_errors(validator, doc):
    return [
        ("/".join(str(x) for x in e.path) or "(raiz)") + ": " + e.message[:120]
        for e in validator.iter_errors(doc)
    ]


def main():
    schemas_dir = os.path.join(ROOT, ".hbn", "schemas")
    validators = {
        ".hbn/readbacks": jsonschema.Draft7Validator(load(os.path.join(schemas_dir, "readback.schema.json"))),
        ".hbn/hearbacks": jsonschema.Draft7Validator(load(os.path.join(schemas_dir, "hearback.schema.json"))),
        ".hbn/results": None,  # ERP sem schema em 1.0.0 — JSON-parse apenas
    }

    debt = {}
    for d, validator in validators.items():
        total, invalid = 0, 0
        for p in sorted(glob.glob(os.path.join(ROOT, d, "[0-9]*.json"))):
            rel = os.path.relpath(p, ROOT)
            total += 1
            try:
                doc = load(p)
            except Exception as e:
                FAILS.append(f"{rel}: JSON inválido — {e}")  # parse SEMPRE bloqueia
                continue
            if validator is None:
                continue
            errs = schema_errors(validator, doc)
            if errs:
                invalid += 1
                if rel in CHANGED:  # ratchet: tocado no range → estrito
                    for e in errs[:6]:
                        FAILS.append(f"{rel} (TOCADO no range): {e}")
        debt[d] = (invalid, total)

    for d, (invalid, total) in debt.items():
        if validators[d] is not None:
            print(f"[validate-contracts] {d}: {total - invalid}/{total} no schema "
                  f"(passivo legado/drift: {invalid} — não bloqueia; ver item A5)")
        else:
            print(f"[validate-contracts] {d}: {total} JSON-parse OK")

    # Coerência canonical-root × const do schema (sempre bloqueia)
    try:
        cr = open(os.path.join(ROOT, ".hbn", "canonical-root"), encoding="utf-8").read().strip()
        const = load(os.path.join(schemas_dir, "readback.schema.json"))["properties"]["canonical_root"]["const"]
        if cr != const:
            FAILS.append(f".hbn/canonical-root ('{cr}') ≠ const do readback.schema ('{const}')")
        else:
            print(f"[validate-contracts] canonical-root coerente com schema: {cr}")
    except FileNotFoundError:
        FAILS.append(".hbn/canonical-root ausente")

    if CHANGED:
        contract_changed = [c for c in CHANGED if c.startswith((".hbn/readbacks/", ".hbn/hearbacks/"))]
        print(f"[validate-contracts] modo ratchet: {len(contract_changed)} contrato(s) tocados no range validados estritos")

    if FAILS:
        print(f"\n[validate-contracts] ✗ {len(FAILS)} violação(ões) bloqueantes:", file=sys.stderr)
        for f in FAILS:
            print(f"  - {f}", file=sys.stderr)
        sys.exit(1)
    print("[validate-contracts] ✓ OK (parse global + estrito nos tocados + canonical-root).")


if __name__ == "__main__":
    main()
