---
phase: quick-260827-f7z
plan: 01
subsystem: bibliography
tags: [bibtex, publications, jekyll-scholar, content-update]
status: complete
key-files:
  created: []
  modified:
    - papers/ref.bib
    - _pages/publications.md
commits:
  - "8df20a2f: fix(quick/bib-01): add volume/issue info for bao2026oryza (17:6877) and he2026trna (44(8):2446-2471)"
metrics:
  duration: 8 min
  completed: 2026-08-27
  tasks: 2
  commits: 1
actuals:
  tokens: 852      # chars/4 over the realized diff (3409 chars), vs estimate 18000
  tasks: 2
  commits: 1
requirements: [BIB-01]
---

# Quick Task 260827-f7z: Volume/issue info for two published 2026 papers

**One-liner:** Added finalized volume/issue info to `bao2026oryza` (`17:6877`) and `he2026trna` (`44(8):2446–2471`) in `papers/ref.bib` **and** in the hand-curated publications-page citations (the page renders Markdown, not the bib), with full validator/build/smoke proof.

## What Was Done

| Task | Description | Commit | Result |
|------|-------------|--------|--------|
| 1 (tracer) | Insert `volume`/`pages` into `bao2026oryza` and `volume`/`number`/`pages` into `he2026trna` in `papers/ref.bib`, pinned field order, parse gate | (working-tree edit; committed with Task 2 per plan topology) | `BIB-EDIT-OK` — adjacent-line grep battery passed, 12 entries intact, `validate.sh` exit 0 |
| 2 | Render proof battery + local commit, no push | `8df20a2f` | production build exit 0; `17:6877` and `44(8):2446–2471` render on `_site/publications/index.html`; `ci-smoke.sh` PASS (sitemap=11, DOI anchor `s41467-026-73769-8`, feed valid, no vendor leak); commit local-only |

### Exact changes

`papers/ref.bib` — `bao2026oryza` (Nature Communications, article-number journal, no `number` field per file convention cf. `yang2024crispr`):

```bibtex
  journal={Nature Communications},
  volume={17},
  pages={6877},
  year={2026},
```

`papers/ref.bib` — `he2026trna` (double-hyphen range preserved; BibTeX `--` → CSL en-dash):

```bibtex
  journal={Trends in Biotechnology},
  volume={44},
  number={8},
  pages={2446--2471},
  year={2026},
```

`_pages/publications.md` — the two hand-curated citation lines (entries 1 and 3):

- `*Nature Communications* 2026, 17:6877. DOI: …` (was `2026. DOI: …`)
- `*Trends in Biotechnology* 2026, 44(8):2446&ndash;2471. DOI: …` (was `2026. DOI: …`)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Publications page does not render from `papers/ref.bib` — hand-curated Markdown is the rendered source**

- **Found during:** Task 1 tracer feedback gate. Post-edit cold production build (`.jekyll-cache` and `_site` removed) still rendered `Nature Communications</em> 2026. DOI:` with no volume info.
- **Investigation:** jekyll-scholar's BibCache (`sha256(path+mtime)` key) contained the new `6877`/`2446` values, proving the edited bib was parsed — so data was fine, render was stale-looking. The only `{% bibliography %}` tags in the repo are the two empty `@incollection` queries in `_pages/talks.md` (grep: 0 occurrences in `publications.md`). `_pages/publications.md` is a 89-entry hand-written Markdown list; the planner's "proven render shapes" (`2024, 17:67.`, `18(2):175–178`) are literally Markdown text (`*Rice* 2024, 17:67.`), not CSL output. The page's DOI anchor that `ci-smoke.sh` greps also comes from this Markdown, not from the bib.
- **Fix:** Applied the same two citation updates to `_pages/publications.md` (lines 16 and 24 area, entries 1 and 3), matching the page's own formatting conventions exactly: article-number shape `YEAR, VOL:ARTICLE` (cf. `*Rice* 2024, 17:67.`) and issue shape `YEAR, VOL(ISSUE):START&ndash;END` (cf. `*Molecular Plant* 2025, 18(2):175&ndash;178.`). Kept the `ref.bib` edit (plan truths #1–#4; structured bib stays correct for scholar tags and validator).
- **Files modified:** `_pages/publications.md` (2 lines)
- **Commit:** `8df20a2f`
- **Plan-assertion adjustment:** Task 2's `[ "$(git diff --name-only HEAD~1 HEAD)" = "papers/ref.bib" ]` was adjusted to assert the exact two-file set `{_pages/publications.md, papers/ref.bib}` — passed.

No other deviations. No auth gates. No out-of-scope issues found.

## Verification

1. `bash scripts/validate.sh` → `PASS: … bib=12, 键唯一` (exit 0) — identical gate CI runs pre-build in `deploy.yml`.
2. `JEKYLL_ENV=production bundle exec jekyll build` → exit 0. Rendered page gains both strings (each had 0 occurrences pre-edit):
   - `<em>Nature Communications</em> 2026, 17:6877. DOI: https://doi.org/10.1038/s41467-026-73769-8.`
   - `<em>Trends in Biotechnology</em> 2026, 44(8):2446–2471. DOI: https://doi.org/10.1016/j.tibtech.2026.02.016.` (hexdump `e2 80 93` = U+2013 en-dash)
3. `bash scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor` (anchor = this task's DOI `s41467-026-73769-8`).
4. Commit `8df20a2f`: exactly 2 files, 7 insertions(+), 2 deletions(-), zero file deletions; entry count `grep -c '^@' papers/ref.bib` = 12. Working tree clean. Nothing pushed — `git log origin/main..HEAD` shows the commit among 13 local-only commits on `main` (push timing belongs to the user; DEPLOY_ENABLED auto-deploys on push).

## Known Stubs

None.

## Broken Windows Ledger

Deviation 1 recorded as `.planning/WINDOWS.md` entry 2 (kind: `deviation`) and marked `fixed` — resolved within commit `8df20a2f`. Pre-existing open entry 1 (Phase 2, D-12) untouched.

## Self-Check: PASSED

- Files: `papers/ref.bib` FOUND, `_pages/publications.md` FOUND
- Commit `8df20a2f` FOUND on `main` (local only)
- Render strings `17:6877` / `44(8):2446–2471` FOUND in `_site/publications/index.html`
- All battery commands re-run after commit: green
