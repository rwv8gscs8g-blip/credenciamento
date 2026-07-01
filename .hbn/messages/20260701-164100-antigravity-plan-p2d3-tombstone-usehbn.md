---
titulo: "Implementation Plan - Preparar a sub-onda P2-D3 no repo Credenciamento"
tipo: plan
status: aprovado
created_at: "2026-07-01T16:41:00-03:00"
autor: gemini-3-5-antigravity
papel: implementador
destino: humano
---

# Implementation Plan - Preparar a sub-onda P2-D3 no repo Credenciamento

The goal of this sub-wave (P2-D3) is to establish a controlled tombstone for the legacy versioned mirror `usehbn/` following P2-D1 (router) and P2-D2 (untangle). The mirror contents under `usehbn/methodology/**` and `usehbn/modules/**` will be removed using git rm, and replaced by a controlled `usehbn/TOMBSTONE.md` document indicating that the mirror has been deprecated and its assets relocated to `docs/reference/`.

We will also create the corresponding readback manifest `.hbn/readbacks/0184-rb-p2d3-tombstone-usehbn.json` linking it to the predecessor `0183-rb-p2d2-untangle`.

No commits or pushes will be performed. All changes will remain staged for validation.

## User Review Required

Human gate required and already recorded for this cycle. Although this is a controlled deprecation wave, it deletes tracked files via `git rm` under `usehbn/methodology/**` and `usehbn/modules/**`, so it must remain staged for review before commit.

## Open Questions

None.

## Proposed Changes

### Credenciamento Repository Configuration & Docs

#### [NEW] [.hbn/readbacks/0184-rb-p2d3-tombstone-usehbn.json](file:///Users/macbookpro/Projetos/Credenciamento/.hbn/readbacks/0184-rb-p2d3-tombstone-usehbn.json)
- Create a valid JSON readback manifest following the HBN schema with:
  - `readback_id`: `"0184-rb-p2d3-tombstone-usehbn"`
  - `track`: `"safe_track"`
  - `human_status`: `"confirmed"`
  - `predecessor_readback_id`: `"0183-rb-p2d2-untangle"`
  - Enforce validation rules, documenting scope, risks, and rollback plans.

#### [NEW] [usehbn/TOMBSTONE.md](file:///Users/macbookpro/Projetos/Credenciamento/usehbn/TOMBSTONE.md)
- Create `usehbn/TOMBSTONE.md` documenting the tombstone and the relocation of all active folders/files to `docs/reference/`.

#### [DELETE] [usehbn/methodology/**](file:///Users/macbookpro/Projetos/Credenciamento/usehbn/methodology/)
- Remove versioned methodology files from Git.

#### [DELETE] [usehbn/modules/**](file:///Users/macbookpro/Projetos/Credenciamento/usehbn/modules/)
- Remove versioned modules files from Git.

#### [NEW] [.hbn/messages/20260701-163300-antigravity-handoff-p2d3-tombstone-usehbn.md](file:///Users/macbookpro/Projetos/Credenciamento/.hbn/messages/20260701-163300-antigravity-handoff-p2d3-tombstone-usehbn.md)
- Create the final handoff file documenting the wave completion.

---

## Verification Plan

### Automated Tests
- Command 6: `git -C /Users/macbookpro/Projetos/Credenciamento diff --cached --name-status`
- Command 7: `git -C /Users/macbookpro/Projetos/Credenciamento diff --cached --check`
- Command 8: `git -C /Users/macbookpro/Projetos/Credenciamento ls-files usehbn`
- Command 9: `bash /Users/macbookpro/Projetos/Credenciamento/scripts/hbn-guards/validate-readback.sh /Users/macbookpro/Projetos/Credenciamento/.hbn/readbacks/0184-rb-p2d3-tombstone-usehbn.json`
- Command 10: `cd /Users/macbookpro/Projetos/Credenciamento && bash scripts/hbn-guards/hbn-guards-runner.sh`
- Command 11: `git -C /Users/macbookpro/Projetos/Credenciamento status --short`

### Manual Verification
- Verify the staged files list contains only the tombstone, readback, deletion of methodology/modules, and handoff.
- Verify no `implementation_plan.md` residue exists in the repository.
- Verify rollback guidance does not use destructive cleanup commands without a new explicit human gate.
