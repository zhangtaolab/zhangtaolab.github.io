---
phase: quick-260916-p4i
plan: 01
subsystem: software-page
tags: [content-deletion, software-card, jekyll, pdllms]
requires:
  - "jekyll serve --livereload running at 127.0.0.1:4000 (pid 22649 — precondition met, no build fallback needed)"
provides:
  - "Software page with 6 cards; PDLLMs fully retired from /software/ source and rendered surfaces; /models/ is the single canonical PDLLMs card"
affects:
  - _pages/software.md
  - _site/software/index.html (regenerated)
  - _site/assets/search.json (regenerated, /software/ entry only)
tech-stack:
  added: []
  patterns:
    - "single-anchor Edit spanning DNALLM-Suite close → dnallmmark opening for surgical block deletion (260827-lwq procedure mirrored)"
    - "search.json per-entry scoping via python3 json parse when the deleted string legitimately survives in another page's entry"
key-files:
  created: []
  modified:
    - _pages/software.md
decisions:
  - "Commit deferred to Task 2 per plan — one fix(quick-260916-p4i) commit covers the single edit (both tasks touch the same deletion)"
  - "search.json PDLLMs assertion scoped to the /software/ entry only — the /models/ entry keeps PDLLMs by design (quick-260916-c21/ovj lineage); a whole-file negative grep would false-fail"
metrics:
  duration: 3 min
  completed: 2026-09-16T10:09:24Z
status: complete
actuals:
  tokens: 264    # chars/4 over the realized diff (1056 deleted chars, 0 added)
  tasks: 2
  commits: 1     # MEASURED: git rev-list --count 67b8515..HEAD
plan_head_before: 67b851545a6a7a5eec73422b3168e99e26aede0c
---

# Quick Task 260916-p4i: Remove PDLLMs Card from Software Page Summary

**One-liner:** Pure 15-line deletion of the PDLLMs section-card from `_pages/software.md` (duplicate of the /models/ card), proven gone from the live serve page, `_site/software/index.html`, and the search.json `/software/` entry — while the `/models/` entry retains PDLLMs — landed as one local `fix(quick-260916-p4i)` commit (0 added / 15 deleted), not pushed.

## What Was Done

### Task 1 (tracer): the deletion + live-page proof

- Precondition met: `curl http://127.0.0.1:4000/software/` returned 200 (serve running, pid 22649; no `jekyll build` fallback needed).
- Pre-edit baseline confirmed the plan's map: 137 lines, PDLLMs at lines 47 (h4) + 53 (Citation), DOI at line 50, source `<div class="section-card"` = 7, `<div class="software-card"` = 7; live rendered PDLLMs = 2, `class="software-card"` = 7, DOI = 1.
- Exactly ONE Edit: 18-line old_string (DNALLM-Suite closing `</div>` → blank → the 14-line PDLLMs block → blank → dnallmmark opening `<div class="section-card" markdown="0">`) replaced by the 3-line run (close → one blank → opening div verbatim). No other line touched; `<style>` block and all 6 sibling cards byte-identical.
- Livereload regenerated within the poll window; live battery printed `LIVE-DELETE-OK`: live page has 0 PDLLMs, exactly 6 `class="software-card"` (was 7), 0 DOI `10.1016/j.molp.2024.12.006`, positive guards `dnallmmark` + `CrisprStitch` + `rustkmer` all present; source: 0 PDLLMs occurrences, both card-div counts = 6, file exactly 122 lines, line 42 = `</div>`, line 43 blank, line 44 = dnallmmark section-card opening; `git diff --numstat` = 0 added / 15 deleted.
- Tracer feedback gate (auto mode active, `auto_advance: true`): tracer `<verify>` re-ran end-to-end green (`TRACER-GATE-RERUN-OK`) before expanding — logged, continued.

### Task 2: validator + smoke battery + single local commit

- `bash scripts/validate.sh` → exit 0 (YAML/BibTeX layers; no collateral damage).
- `bash scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor` (/software/ persists in the sitemap — only a card was removed).
- Regenerated artifacts clean and scoped: `_site/software/index.html` still contains `dnallmmark` but not `PDLLMs`; `_site/assets/search.json` — parsed with python3 and scoped to the `/software/` entry — has no PDLLMs in its indexed content, while the `/models/` entry still contains PDLLMs (canonical survivor guard, `SEARCH-SCOPE-OK`).
- Commit `de10963c` — `fix(quick-260916-p4i): remove PDLLMs card from Software page` — touches exactly `_pages/software.md`, pure deletion (0/15), sits in the origin/main..HEAD ahead-set. **NOT pushed** (DEPLOY_ENABLED is live: push to main auto-deploys production zhangtaolab.org). Task 2 verify printed `SOFTWARE-CARD-DELETE-OK`.
- Post-commit checks: no tracked file deletions in the commit, no untracked files left by the task (the `.planning/quick/*` dirs in the tree are the orchestrator's uncommitted docs artifacts, per constraints).

## Verification Evidence

| Check | Result |
|-------|--------|
| Live page PDLLMs count | 0 (was 2) |
| Live page `class="software-card"` count | exactly 6 (was 7) |
| Live page DOI `10.1016/j.molp.2024.12.006` count | 0 (was 1) |
| Live page positive guards (dnallmmark, CrisprStitch, rustkmer) | all present |
| Source PDLLMs occurrences | 0 (was 2: h4 + Citation, both inside the deleted block) |
| Source `<div class="section-card"` / `<div class="software-card"` | 6 / 6 (were 7 / 7) |
| File length / boundary shape | 122 lines; L42 `</div>`, L43 blank, L44 dnallmmark section-card opening |
| `git diff --numstat` (and HEAD commit numstat) | 0 added / 15 deleted |
| `bash scripts/validate.sh` | exit 0 |
| `bash scripts/ci-smoke.sh _site` | `PASS: sitemap=11, anchor ok, feed valid, no vendor` |
| `_site/software/index.html` | dnallmmark present, PDLLMs absent |
| `_site/assets/search.json` `/software/` entry | no PDLLMs; `/models/` entry retains PDLLMs |
| Commit scope / push state | exactly `_pages/software.md`; local-only ahead of origin/main |

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-4 fixes needed; no auth gates; no fallback path taken. (Plan-context estimate said "~12-13 lines"; the executor-verified block is 14 lines + 1 blank = 15, and the plan frontmatter/truths were written with the exact 15 before editing — the commit matches the plan's 0/15 gate.)

## Known Stubs

None — pure deletion; nothing added that could introduce a stub.

## Threat Mitigations (per plan threat_model)

- **T-quick-01 (over-deletion / layout break), low:** mitigated — single-anchor Edit + full verify battery (122 lines, counts 6/6, blank-line shape at lines 42-44, siblings live, numstat 0/15) all green.
- **T-quick-02 (unintended production deploy), medium:** mitigated — no `git push` invoked in any form; Task 2 verify confirms the commit is local-only in the origin/main..HEAD ahead-set. Push timing belongs to the user/orchestrator.

## Self-Check: PASSED

- `_pages/software.md` exists and is 122 lines with 0 PDLLMs occurrences — FOUND
- Commit `de10963c` exists on local main (`de10963c4e1b8bdeb277ce9fe0acb48547ab60dd`) — FOUND
- `git diff --name-only HEAD~1 HEAD` = `_pages/software.md` only — FOUND
