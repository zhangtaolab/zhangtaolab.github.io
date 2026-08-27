---
phase: quick-260827-uf8
plan: 01
subsystem: software-page
tags: [content-fix, paper-link, pdllms, doi, jekyll]
requires:
  - "jekyll serve --livereload running at 127.0.0.1:4000 (or bundle exec jekyll build fallback)"
provides:
  - "PDLLMs card Paper button opens the canonical DOI resolver https://doi.org/10.1016/j.molp.2024.12.006 (verified PMID 39659015 / Crossref for the exact citation the card displays)"
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
  - "DOI URL transcribed verbatim from the verified directive (no trailing slash, no http downgrade, no percent-encoding — plain ASCII, no parentheses)"
metrics:
  duration: 2 min
  completed: 2026-08-27T14:01:07Z
status: complete
actuals:
  tokens: 498   # chars/4 over the realized diff (1992 diff bytes, 1 line swapped) vs estimate 8000
  tasks: 2
  commits: 1
requirements-completed: [SW-FIX-02]
---

# Quick Task 260827-uf8: Switch PDLLMs Paper Link on Software Page to DOI Summary

**One-liner:** Single-href swap on the PDLLMs card in `_pages/software.md` (line 50): the cell.com fulltext URL (landed by quick task 260827-u7s, commit a6d140fb) replaced by the canonical DOI link `https://doi.org/10.1016/j.molp.2024.12.006` (verified PMID 39659015 / Crossref for the exact citation the card displays), proven on the live serve page and in regenerated artifacts, landed as one local `fix(quick/software)` commit (1 added / 1 deleted), not pushed.

## What Was Done

### Task 1 (tracer): the href swap + live-page proof

- Precondition met: `curl http://127.0.0.1:4000/software/` returned 200 (serve running; no `jekyll build` fallback needed).
- Exactly ONE Edit: old_string `https://www.cell.com/molecular-plant/fulltext/S1674-2052(24)00390-3` → new_string `https://doi.org/10.1016/j.molp.2024.12.006` (old string occurs exactly once, line 50). Only the href inside the Paper anchor changed — surrounding `btn-pill btn-paper` markup, the `fa-file-lines` icon, button label, and every other line byte-identical. DOI transcribed verbatim: no trailing slash, no `http://` downgrade, no percent-encoding (plain ASCII).
- Out-of-scope surfaces untouched by construction (single unique Edit): CrisprStitch Paper link (line 80, PubMed 38146164), Chorus2 Paper link (line 97, PubMed 33960617), `_pages/publications.md` (never opened for editing — entry #6 keeps its cell.com title link), news page cell.com link.
- Livereload regenerated within the poll window; live battery printed `LIVE-DOI-OK`: live /software/ HTML has the full DOI URL exactly 1, `cell.com/molecular-plant` 0, both sibling PMIDs exactly 1 each, `PDLLMs` present as the positive render guard — all counts scoped to the /software/ HTML response only (never a repo-wide grep). Source: old URL 0, DOI exactly 1, both sibling PMIDs 1 each, publications.md still exactly 2 `cell.com/molecular-plant` occurrences, file still 137 lines; `git diff --numstat` = 1 added / 1 deleted on `_pages/software.md` alone, `git diff --name-only` lists only that file.
- Tracer feedback gate (autonomous run): tracer `<verify>` re-ran end-to-end green before expansion — logged, continued.

### Task 2: validator + smoke battery + regenerated artifacts + single local commit

- `bash scripts/validate.sh` → exit 0, `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一` (YAML/BibTeX layers; software.md not in its file set — proves no collateral damage and pre-clears the CI Validate content step that runs the same validator).
- `bash scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor` (no assertion references the software page's link).
- Regenerated artifacts flipped as planned: `_site/software/index.html` `cell.com/molecular-plant` 1→0, DOI 0→1; `_site/assets/search.json` `cell.com` count 0 (planner-verified already 0 — the index carries card text, not hrefs — stays 0) with `PDLLMs` card text still indexed as the positive guard (no DOI match asserted there, as planned).
- Commit `c052f229` — `fix(quick/software): switch PDLLMs card Paper link to DOI (10.1016/j.molp.2024.12.006)` — touches exactly `_pages/software.md`, 1 added / 1 deleted, sits in the origin/main..HEAD ahead-set. **NOT pushed** (DEPLOY_ENABLED is live: push to main auto-deploys production zhangtaolab.org; push timing belongs to the user/orchestrator). Task 2 verify printed `SOFTWARE-DOI-SWAP-OK`.
- Post-commit checks: no tracked file deletions in the commit, no untracked files left in the tree.

## Verification Evidence

| Check | Result |
|-------|--------|
| Live `/software/` full DOI URL `https://doi.org/10.1016/j.molp.2024.12.006` | exactly 1 |
| Live `/software/` `cell.com/molecular-plant` | 0 (was 1) |
| Live `/software/` sibling PMIDs 38146164 / 33960617 | exactly 1 each (untouched) |
| Live `/software/` `PDLLMs` (positive render guard) | present |
| Source `_pages/software.md` old URL / DOI / siblings | 0 / 1 / 1 and 1 |
| `_pages/publications.md` `cell.com/molecular-plant` | exactly 2 (untouched, as scoped) |
| `_pages/software.md` line count | 137 (unchanged) |
| `git diff --numstat` pre-commit / `git show --numstat` post-commit | 1 added / 1 deleted, single file `_pages/software.md` |
| `_site/software/index.html` old URL / DOI | 0 / exactly 1 |
| `_site/assets/search.json` `cell.com` / PDLLMs text | 0 / present |
| `scripts/validate.sh` | exit 0 |
| `scripts/ci-smoke.sh _site` | PASS (sitemap=11, anchor ok, feed valid, no vendor) |
| Task verify sentinels | `LIVE-DOI-OK` (Task 1), `SOFTWARE-DOI-SWAP-OK` (Task 2) |
| Commit ahead-set (local-only) | `c052f229` in origin/main..HEAD; nothing pushed |

## Deviations from Plan

None - plan executed exactly as written. (No auth gates, no auto-fixes; sibling CrisprStitch/Chorus2 links, publications.md entry #6, and all other lines byte-identical.)

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Known Stubs

None.

## Next Steps

- Commit `c052f229` is local-only; the user/orchestrator decides push timing (push to main auto-deploys zhangtaolab.org via the live DEPLOY_ENABLED gate).
- No other consumer of the cell.com fulltext URL exists within `_pages/software.md` (planner-verified scoped grep: only line 50); publications.md (lines 32/134) and the news page legitimately keep their cell.com links and are out of scope.

---
*Quick task: 260827-uf8*
*Completed: 2026-08-27*

## Self-Check: PASSED

- SUMMARY file exists on disk at the required path
- Commit c052f229 present in git log (single fix(quick/software) commit)
- _pages/software.md modified file present
