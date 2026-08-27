---
phase: quick-260827-u7s
plan: 01
subsystem: software-page
tags: [content-fix, paper-link, pdllms, jekyll]
requires:
  - "jekyll serve --livereload running at 127.0.0.1:4000 (or bundle exec jekyll build fallback)"
provides:
  - "PDLLMs card Paper button opens the correct Molecular Plant fulltext article (byte-identical to publications.md entry #6)"
affects:
  - _pages/software.md
  - _site/software/index.html (regenerated)
tech-stack:
  added: []
  patterns:
    - "minimal unique href-only Edit (old URL occurs exactly once in file) for surgical single-link swap"
key-files:
  created: []
  modified:
    - _pages/software.md
decisions:
  - "Commit deferred to Task 2 per plan — one fix(quick/software) commit covers the single edit (both tasks touch the same line)"
  - "New URL transcribed verbatim from publications.md entry #6 with literal (unencoded) parentheses — safe inside the double-quoted href attribute and byte-identical to the usage already live in production"
metrics:
  duration: 1 min
  completed: 2026-08-27T13:51:48Z
status: complete
actuals:
  tokens: 304   # chars/4 over the realized diff (1218 diff bytes, 1 line swapped)
  tasks: 2
  commits: 1
requirements-completed: [SW-FIX-01]
---

# Quick Task 260827-u7s: Fix Wrong Paper Link on PDLLMs Card Summary

**One-liner:** Single-href swap on the PDLLMs card in `_pages/software.md` (line 50): wrong pubmed PMID 39733335 URL (an unrelated eyelid-anatomy paper) replaced by the Molecular Plant fulltext URL `https://www.cell.com/molecular-plant/fulltext/S1674-2052(24)00390-3` byte-identical to publications.md entry #6, proven on the live serve page and in regenerated artifacts, landed as one local `fix(quick/software)` commit (1 added / 1 deleted), not pushed.

## What Was Done

### Task 1 (tracer): the href swap + live-page proof

- Precondition met: `curl http://127.0.0.1:4000/software/` returned 200 (serve running; no `jekyll build` fallback needed).
- Pre-edit baseline confirmed the planner's map exactly: live page 39733335=1, 38146164=1, 33960617=1, `cell.com/molecular-plant/fulltext`=0; source 137 lines; clean tree.
- Exactly ONE Edit: old_string `https://pubmed.ncbi.nlm.nih.gov/39733335/` → new_string `https://www.cell.com/molecular-plant/fulltext/S1674-2052(24)00390-3` (occurs exactly once, line 50). Only the href inside the Paper anchor changed — surrounding `btn-pill btn-paper` markup, the `fa-file-lines` icon, button label, and every other line byte-identical. Parentheses kept literal (not percent-encoded), matching the publications.md usage verbatim.
- Livereload regenerated within the poll window; live battery printed `LIVE-LINK-OK`: live page has 0 occurrences of the old PMID, `cell.com/molecular-plant/fulltext` ≥1 with full fixed-string `S1674-2052(24)00390-3` present, both sibling PMIDs exactly 1 each, `PDLLMs` present as the positive render guard; source: old PMID 0, new URL exactly 1, both sibling PMIDs 1 each, file still 137 lines; `git diff --numstat` = 1 added / 1 deleted on `_pages/software.md` alone.
- Tracer feedback gate (autonomous run): tracer `<verify>` re-ran end-to-end green before expansion — logged, continued.

### Task 2: validator + smoke battery + single local commit

- `bash scripts/validate.sh` → exit 0 (YAML/BibTeX layers; software.md not in its file set — proves no collateral damage and pre-clears the CI Validate content step that runs the same validator).
- `bash scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor` (no assertion references the software page's link).
- Regenerated artifacts clean: `_site/software/index.html` old PMID 0 + full new URL present (fixed-string, parentheses literal); `_site/assets/search.json` old PMID 0 (planner-verified already 0 — hrefs unindexed — stays 0) with `PDLLMs` card text still indexed as the positive guard.
- Commit `a6d140fb` — `fix(quick/software): correct PDLLMs paper link (wrong pubmed PMID → Molecular Plant fulltext)` — touches exactly `_pages/software.md`, 1 added / 1 deleted, sits in the origin/main..HEAD ahead-set. **NOT pushed** (DEPLOY_ENABLED is live: push to main auto-deploys production zhangtaolab.org; push timing belongs to the user/orchestrator). Task 2 verify printed `SOFTWARE-LINK-FIX-OK`.
- Post-commit checks: no tracked file deletions in the commit, no untracked files left in the tree.

## Verification Evidence

| Check | Result |
|-------|--------|
| Live `/software/` old PMID 39733335 count | 0 (was 1) |
| Live `/software/` `cell.com/molecular-plant/fulltext` count | ≥1 |
| Live `/software/` full URL `S1674-2052(24)00390-3` (fixed-string) | present |
| Live `/software/` sibling PMIDs 38146164 / 33960617 | exactly 1 each (untouched) |
| Source `_pages/software.md` old PMID / new URL / siblings | 0 / 1 / 1 and 1 |
| `_pages/software.md` line count | 137 (unchanged) |
| `git diff --numstat` | 1 added / 1 deleted, single file |
| `_site/software/index.html` old PMID / full new URL | 0 / present |
| `_site/assets/search.json` old PMID / PDLLMs text | 0 / present |
| `scripts/validate.sh` | exit 0 |
| `scripts/ci-smoke.sh _site` | PASS (sitemap=11, anchor ok, feed valid, no vendor) |
| Commit ahead-set (local-only) | `a6d140fb` in origin/main..HEAD; nothing pushed |

## Deviations from Plan

None - plan executed exactly as written. (No auth gates, no auto-fixes; sibling CrisprStitch/Chorus2 links and all other lines byte-identical.)

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Steps

- Commit `a6d140fb` is local-only; the user/orchestrator decides push timing (push to main auto-deploys zhangtaolab.org via the live DEPLOY_ENABLED gate).
- No other consumer of the old PMID exists (planner-verified scoped grep: only software.md:50); no further action needed.

---
*Quick task: 260827-u7s*
*Completed: 2026-08-27*

## Self-Check: PASSED

- SUMMARY file exists on disk at the required path
- Commit a6d140fb present in git log (single fix(quick/software) commit)
- _pages/software.md modified file present
