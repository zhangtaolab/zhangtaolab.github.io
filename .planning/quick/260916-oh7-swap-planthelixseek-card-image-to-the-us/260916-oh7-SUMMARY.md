---
phase: quick-260916-oh7
plan: 01
subsystem: models-page
tags: [models, images, banner-swap, byte-identity, cache-bust]
requires: [quick-260916-nl1]
provides: [models-page-user-figure1-banner]
affects: [_data/models.yml, images/models/]
key-files:
  created:
    - images/models/plantelixseek-figure1.png
  modified:
    - _data/models.yml
  deleted:
    - images/models/plantelixseek-banner-full.png
decisions:
  - New filename plantelixseek-figure1.png doubles as a cache-buster for the old nl1 composite banner URL
  - Zero markup/CSS change — lei natural-aspect rules (width:100% + height:auto) absorb the user's 2372x1255 aspect with zero crop (measured drift 0.003%)
metrics:
  duration: 5 min
  completed: 2026-09-16
actuals:
  tokens: 174   # chars/4 over the realized TEXT diff (696 chars, _data/models.yml only); binary PNG swap excluded from token scale
  tasks: 1
  commits: 1    # measured: git rev-list --count 71f67ca8..HEAD
  plan_head_before: 71f67ca8e6c2302e928175549c97d372abb83644
status: complete
requirements: [MODELS-02]
---

# Quick Task 260916-oh7: Swap PlantHelixSeek card image to the user's Figure 1 Summary

Swapped the /models/ PlantHelixSeek card banner to the user's own prepared wide figure — `/tmp/models_imgs/user-helixseek.png` (1663157 B, PNG 2372×1255) copied VERBATIM as `images/models/plantelixseek-figure1.png` (`cmp` exit 0 in all three places: working tree vs source, staged blob vs source, served URL vs source), the nl1 composite `plantelixseek-banner-full.png` `git rm`'d (URL now 404, new URL dodges browser cache of the old path), and `_data/models.yml` PlantHelixSeek `image`/`image_alt` repointed (exactly 2 lines; PDLLMs entry and schema header untouched). Exactly 3 content paths in one local commit (0c5a92ab); zero markup/CSS changes — the lei natural-aspect `.model-banner` rules render the 2372×1255 figure uncropped at ~1006×532 (aspect drift 0.003%), proven by DOM geometry plus directly inspected screenshots (Playwright AND the user's real browser via Kimi bridge).

## What Was Done

### Task 1: VERBATIM image swap — copy user PNG byte-identical, delete old banner, repoint models.yml

- All three preconditions held at execution: source file exactly 1663157 B / PNG 2372×1255 8-bit RGB non-interlaced (`stat -f%z` + `file`); `jekyll serve` (task bysvkf7vb) answering 200 on `/models/`; Kimi bridge daemon reachable at 127.0.0.1:10086 with live session "models-page-check" (tab already open on the models page).
- COPY with `cp` only — no ImageMagick/sips, no resample, no recompress, no metadata strip. Immediate gate: `cmp` source vs working-tree copy → exit 0.
- `git rm images/models/plantelixseek-banner-full.png`; staged the new PNG before the changeset-count gate (ksu/nl1 porcelain precedent — prevents untracked-dir collapse).
- `_data/models.yml`: exactly the two PlantHelixSeek lines swapped — `image: "/images/models/plantelixseek-figure1.png"`, `image_alt: "PlantHelixSeek paper Figure 1: pretraining corpus, model architecture and benchmarks"` (double-quoted, no embedded quotes). PDLLMs entry (`pdllms-banner-full.png` + its alt) and the schema header comment byte-untouched; `_pages/models.md` and all SCSS untouched.
- Single commit `fix(quick-260916-oh7): swap PlantHelixSeek card image to the user's Figure 1 banner` = 0c5a92ab (3 files, 2 insertions, 2 deletions). Not pushed (DEPLOY_ENABLED gate is live — push timing belongs to the user).

## Verification Evidence

| Gate | Result |
|------|--------|
| Disk byte identity | `cmp` exit 0 — working tree vs /tmp/models_imgs/user-helixseek.png |
| Staged byte identity | `git show :images/models/plantelixseek-figure1.png` → `cmp` exit 0 vs source |
| Served byte identity | HTTP 200 on `/images/models/plantelixseek-figure1.png` → `cmp` exit 0 vs source |
| Old asset gone | `/images/models/plantelixseek-banner-full.png` → 404 |
| Rendered HTML | `/models/` references `plantelixseek-figure1.png` exactly 1×, `plantelixseek-banner-full` 0× |
| models.yml strings | both new PlantHelixSeek strings grep-exact; PDLLMs `image`/`image_alt` unchanged |
| Geometry 1280px | `.model-banner img` first match: natural 2372×1255, displayed 1006.0×532.25, aspect drift 0.003% (<1%), img complete, src = figure1 path — 7/7 PASS |
| Screenshots | models-1280.png in this directory (Playwright, full-page) — directly inspected: user's image content complete, full-width, no truncation |
| User's real browser | Kimi bridge session "models-page-check" reloaded + screenshot — same confirmation: Figure 1 renders complete and uncropped |
| validate.sh / ci-smoke | exit 0 (news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一) / PASS sitemap=11, anchor ok, feed valid, no vendor |
| Changeset | exactly 3 porcelain entries outside `.planning/` (A figure1 png, D banner-full png, M models.yml), all under `images/models/` + `_data/models.yml`; one commit 0c5a92ab |

## Deviations from Plan

None — plan executed exactly as written. (The plan's own anticipated-tooling notes were followed as specified: igv-rust playwright 1.58.2 via NODE_PATH with the runner script in this task directory, selector `.model-banner img` with a scroll pass; working script removed after evidence capture per nl1 precedent, canonical screenshot kept. Screenshot reads returned inline images both times this run — the d6y/dvz/nl1 CDN-relay breakage did not recur.)

## Self-Check: PASSED

- images/models/plantelixseek-figure1.png — FOUND (1663157 B, 2372×1255, in commit 0c5a92ab, byte-identical to source)
- images/models/plantelixseek-banner-full.png — deleted (intentional, plan-directed; URL 404)
- _data/models.yml — repointed (PlantHelixSeek only), in commit 0c5a92ab
- Commit 0c5a92ab — FOUND on main (local, not pushed)
- models-1280.png — FOUND in this directory
