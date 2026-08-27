---
phase: quick-260827-lwq
plan: 01
subsystem: software-page
tags: [content-deletion, software-card, jekyll]
requires:
  - "jekyll serve --livereload running at 127.0.0.1:4000 (or bundle exec jekyll build fallback)"
provides:
  - "Software page with 7 cards; MambaForSequenceClassification fully retired from source and rendered surfaces"
affects:
  - _pages/software.md
  - _site/software/index.html (regenerated)
  - _site/assets/search.json (regenerated)
tech-stack:
  added: []
  patterns:
    - "single-anchor Edit spanning dnallmmark close → Genome Editing heading for surgical block deletion"
key-files:
  created: []
  modified:
    - _pages/software.md
decisions:
  - "Commit deferred to Task 2 per plan — one fix(quick/software) commit covers the single edit (both tasks touch the same deletion)"
metrics:
  duration: 2 min
  completed: 2026-08-27T07:52:50Z
status: complete
actuals:
  tokens: 165   # chars/4 over the realized diff (660 deleted chars, 0 added)
  tasks: 2
  commits: 1
---

# Quick Task 260827-lwq: Delete MambaForSequenceClassification Software Card Summary

**One-liner:** Pure 13-line deletion of the MambaForSequenceClassification section-card from `_pages/software.md` (one of four DNA LLM cards), proven gone from the live serve page, `_site/software/index.html`, and `_site/assets/search.json`, landed as one local `fix(quick/software)` commit (0 added / 13 deleted), not pushed.

## What Was Done

### Task 1 (tracer): the deletion + live-page proof

- Precondition met: `curl http://127.0.0.1:4000/software/` returned 200 (serve running; no `jekyll build` fallback needed).
- Pre-edit baseline confirmed the planner's map: 150 lines, `<div class="section-card"` = 8, `<div class="software-card"` = 8, live rendered `class="software-card"` = 8.
- Exactly ONE Edit: 16-line old_string (dnallmmark closing `</div>` → blank → the 12-line Mamba block → blank → Genome Editing fa-scissors heading) replaced by the 3-line run (close → one blank → heading verbatim). No other line touched; `<style>` block and all 7 sibling cards byte-identical.
- Livereload regenerated within the poll window; live battery printed `LIVE-DELETE-OK`: live page has 0 occurrences of the deleted title, exactly 7 `class="software-card"`, positive guards `dnallmmark` + `CrisprStitch` present; source: 0 title occurrences, both card-div counts = 7, file exactly 137 lines, line 70 = `</div>`, line 71 blank, line 72 = fa-scissors heading; `git diff --numstat` = 0 added / 13 deleted.
- Tracer feedback gate (autonomous run): tracer `<verify>` re-ran end-to-end green before expansion — logged, continued.

### Task 2: validator + smoke battery + single local commit

- `bash scripts/validate.sh` → exit 0 (YAML/BibTeX layers; no collateral damage).
- `bash scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor` (/software/ persists in the sitemap — only a card was removed).
- Regenerated artifacts clean: `_site/software/index.html` still contains `dnallmmark` but not the deleted title; `_site/assets/search.json` no longer matches `mamba` case-insensitively.
- Commit `335eb74c` — `fix(quick/software): remove MambaForSequenceClassification card` — touches exactly `_pages/software.md`, pure deletion (0/13), sits in the origin/main..HEAD ahead-set. **NOT pushed** (DEPLOY_ENABLED is live: push to main auto-deploys production zhangtaolab.org). Task 2 verify printed `SOFTWARE-CARD-DELETE-OK`.
- Post-commit checks: no tracked file deletions in the commit, no untracked files left in the tree.

## Verification Evidence

| Check | Result |
|-------|--------|
| Live page title count (deleted card) | 0 |
| Live page `class="software-card"` count | exactly 7 (was 8) |
| Live page positive guards (dnallmmark, CrisprStitch) | both present |
| Source title occurrences | 0 (was 2: h4 + GitHub URL, both inside the deleted block) |
| Source `<div class="section-card"` / `<div class="software-card"` | 7 / 7 (were 8 / 8) |
| File length / boundary shape | 137 lines; L70 `</div>`, L71 blank, L72 fa-scissors heading |
| `git diff --numstat` (and HEAD commit numstat) | 0 added / 13 deleted |
| `bash scripts/validate.sh` | exit 0 |
| `bash scripts/ci-smoke.sh _site` | `PASS: sitemap=11, anchor ok, feed valid, no vendor` |
| `_site/software/index.html` | dnallmmark present, deleted title absent |
| `_site/assets/search.json` | no `mamba` (case-insensitive) |
| Commit scope / push state | exactly `_pages/software.md`; local-only ahead of origin/main |

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-4 fixes needed; no auth gates; no fallback path taken.

## Known Stubs

None — pure deletion; nothing added that could introduce a stub.

## Threat Mitigations (per plan threat_model)

- **T-quick-01 (over-deletion / layout break), low:** mitigated — single-anchor Edit + full verify battery (137 lines, counts 7/7, blank-line shape, siblings live, numstat 0/13) all green.
- **T-quick-02 (unintended production deploy), medium:** mitigated — no `git push` invoked in any form; Task 2 verify confirms the commit is local-only in the origin/main..HEAD ahead-set. Push timing belongs to the user/orchestrator.

## Self-Check: PASSED

- `_pages/software.md` exists and is 137 lines with 0 title occurrences — FOUND
- Commit `335eb74c` exists on local main — FOUND
- `git diff --name-only HEAD~1 HEAD` = `_pages/software.md` only — FOUND
