---
phase: quick-260827-jvt
plan: 01
subsystem: content
tags: [bibtex, publications, doi, jekyll-scholar, ci-smoke]

# Dependency graph
requires:
  - phase: quick-260827-f7z
    provides: volume/issue info for bao2026oryza (17:6877) + he2026trna (44(8):2446-2471) in ref.bib + publications.md (commit 8df20a2f)
provides:
  - bao2026oryza + he2026trna entries conform to the site's complete-entry convention (no trailing DOI placeholder suffix in publications.md, no doi field in ref.bib)
affects: [publications page, ref.bib bibliography, future volume-info quick tasks for liao2026glycosylase/zheng2025larch]

actuals:
  tokens: 709        # 2837 chars over the realized diff / 4 (estimate was 12000 — pure-deletion task, estimate scale high)
  tasks: 2
  commits: 1

tech-stack:
  added: []
  patterns:
    - "Complete-entry convention now uniformly applied: entries with volume info end at the journal citation (no trailing DOI suffix) and carry no bib doi field; placeholders remain only while volume info is pending"

key-files:
  created: []
  modified:
    - _pages/publications.md
    - papers/ref.bib

key-decisions:
  - "Kept liao2026glycosylase (Science Bulletin) and zheng2025larch (HPJ) DOI placeholders untouched in both files — volume info still pending; the placeholder convention exists exactly for that state"
  - "Retained the [title](https://doi.org/...) hyperlinks on both edited entries — ci-smoke assertion ② greps s41467-026-73769-8 in _site/publications/index.html via the href"

patterns-established:
  - "Trailing DOI placeholder removal checklist for future volume-info landings: (1) delete suffix after journal citation in publications.md, keep title href; (2) drop bib doi field AND the year-line trailing comma; (3) linter battery = live-page occurrence counts + validate.sh + ci-smoke.sh"

requirements-completed: [BIB-02]  # quick-task directive (not a REQUIREMENTS.md milestone requirement — no checkbox to mark)

coverage:
  - id: D1
    description: "DOI placeholder suffixes removed from bao2026oryza + he2026trna on both surfaces (publications.md trailing text, ref.bib doi fields), title hyperlinks and volume info retained, liao/zheng placeholders untouched"
    requirement: BIB-02
    verification:
      - kind: other
        ref: "live-page occurrence battery on http://127.0.0.1:4000/publications/ (removed-suffix counts 0, title hrefs >=1, scib placeholder exactly 1, volumes render) — LIVE-PAGE-OK"
        status: pass
      - kind: other
        ref: "bash scripts/validate.sh — PASS: bib=12, 键唯一, exit 0"
        status: pass
      - kind: other
        ref: "bash scripts/ci-smoke.sh _site — PASS: sitemap=11, anchor ok, feed valid, no vendor"
        status: pass
      - kind: other
        ref: "ref.bib shape battery — 12 @ entries, exactly 2 doi={ lines remaining (scib + hpj), both edited entries end at comma-less year={2026} — BIB-02-OK"
        status: pass
    human_judgment: false

duration: 3min
completed: 2026-08-27
status: complete
---

# Quick Task 260827-jvt: Remove DOI placeholders from two entries Summary

**Trailing `DOI: URL` placeholder suffixes deleted from the bao2026oryza and he2026trna publication entries (page + bib), matching the site's complete-entry convention once volume info landed in quick task 260827-f7z**

## Performance

- **Duration:** 3 min (203s)
- **Started:** 2026-08-27T06:26:58Z
- **Completed:** 2026-08-27T06:30:21Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- `_pages/publications.md`: bao2026oryza line now ends at `*Nature Communications* 2026, 17:6877.` and he2026trna at `*Trends in Biotechnology* 2026, 44(8):2446&ndash;2471.` — trailing DOI placeholder suffixes gone, `[title](https://doi.org/...)` hyperlinks retained (ci-smoke assertion ② anchor `s41467-026-73769-8` intact via the href)
- `papers/ref.bib`: doi field lines dropped from both entries; year lines normalized to comma-less `  year={2026}` per the complete-entry convention (wang2026maize / liu2025pdllms / yang2025rice); entry count stays 12, file-wide doi lines drop 4 → 2
- Proof battery fully green on the live livereload serve page (edit-to-render confirmed within the poll window): both removed-suffix texts occur 0 times, both title hrefs ≥1, Science Bulletin placeholder exactly once, volumes render intact
- `validate.sh` (PASS, bib=12, 键唯一) and `ci-smoke.sh _site` (PASS: sitemap=11, anchor ok, feed valid, no vendor) — the identical validator runs in deploy.yml, so the future push will clear the Validate content step

## Task Commits

Both tasks share one commit (same logical change, per plan):

1. **Task 1: End-to-end publications.md placeholder removal + live-page proof** - `772d23c5` (fix)
2. **Task 2: ref.bib doi field removal + validator/smoke battery + local commit** - `772d23c5` (fix)

**Plan metadata:** orchestrator handles the docs commit (constraint: executor does not commit .planning/ artifacts)

## Files Created/Modified
- `_pages/publications.md` - 2 lines shortened (bao2026oryza, he2026trna); no other line touched
- `papers/ref.bib` - 2 doi field lines removed + 2 year-line commas normalized; 12 entries intact

## Decisions Made
- None beyond plan scope - followed plan as specified (liao2026glycosylase + zheng2025larch placeholders deliberately preserved: volume info still pending)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - verify-script bug] Corrected the Task 1 added-line diff-count pattern**
- **Found during:** Task 1 (live-page verify battery)
- **Issue:** The plan's assertion `git diff -U0 | grep -c '^+[^-]'` = 2 is inherently off-by-one: the diff's `+++ b/_pages/publications.md` header line also matches (`+` followed by non-dash `+`), so it counts 3 for a 2-line change. The mirror `^-[^-]'` happens to work only because `---`'s second char IS a dash. First run failed on this assertion with zero source-file problems.
- **Fix:** Re-ran the battery with the true mirror pattern `'^+[^+]'` (excludes the `+++` header); confirmed the diff body shows exactly 2 removed + 2 added lines, both pure line-shortenings
- **Files modified:** none (verification expression only; source edits were already correct)
- **Verification:** Corrected battery prints LIVE-PAGE-OK; manual diff body inspection confirms exactly 2 changed lines
- **Committed in:** n/a (no source change; deviation recorded in .planning/windows ledger)

---

**Total deviations:** 1 auto-fixed (1 verification-expression bug)
**Impact on plan:** None on shipped artifacts — source edits matched the plan exactly; only the plan's own verify one-liner needed the pattern correction. No scope creep.

## Issues Encountered
None beyond the deviation above. Precondition (jekyll serve live at 127.0.0.1:4000) was met, so no `_site` fallback was needed.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Commit `772d23c5` is local-only on main and NOT pushed (DEPLOY_ENABLED is live — push to main auto-deploys production zhangtaolab.org; push timing belongs to the user/orchestrator)
- Remaining DOI placeholders (intentional): liao2026glycosylase (Science Bulletin) + zheng2025larch (HPJ) in both files — remove via the same checklist once their volume info exists
- validate.sh green locally guarantees the CI Validate content step will pass on the eventual push

## Known Stubs
None - pure-deletion content task; no stubs introduced. The two remaining DOI placeholders are intentional plan scope (volume info pending), not defects.

## Self-Check: PASSED

- FOUND: .planning/quick/260827-jvt-remove-doi-placeholders-from-two-entries/260827-jvt-SUMMARY.md
- FOUND: _pages/publications.md
- FOUND: papers/ref.bib
- FOUND: commit 772d23c5 (git log, also confirmed in origin/main..HEAD ahead-set = local-only, not pushed)

---
*Phase: quick-260827-jvt*
*Completed: 2026-08-27*
