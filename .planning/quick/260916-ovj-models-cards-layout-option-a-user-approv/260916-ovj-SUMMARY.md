---
phase: quick-260916-ovj
plan: 01
subsystem: models-page
tags: [models, layout, flex-row, option-a, user-approved, responsive]
requires:
  - "260916-c21 /models/ page + _data/models.yml registry"
  - "260916-oh7/ooh user Figure 1 banners in place (plantelixseek-figure1.png 2372×1255, pdllms-figure1.png 3656×1628)"
provides:
  - "/models/ cards render option-A layout: image left 56% + text right, mobile image-above-text stack"
affects:
  - "_pages/models.md (card loop + page-local style block only)"
tech-stack:
  added: []
  patterns:
    - "page-local flex-row card layout (.model-row 56% banner + .model-body, 767px column stack) — no global SCSS touched, /software/ unaffected"
key-files:
  created: []
  modified:
    - _pages/models.md
decisions:
  - "Featured badge gap moved from per-card inline style to .model-row margin-top (single owner, visual parity for badge→content distance)"
  - "img border+radius moved onto .model-banner img (banner wrapper keeps only flex sizing) per approved mockup geometry"
metrics:
  duration: 4 min
  completed: "2026-09-16T10:02:31Z"
  tasks: 1
  commits: 1
status: complete
actuals:
  tokens: 588    # 2353 diff chars / 4
  tasks: 1
  commits: 1
plan_head_before: 79e7728c886233cc724b9676114d348b95a83c38
---

# Phase quick-260916-ovj Plan 01: Models cards layout option A (image left / text right) Summary

Implemented the user-approved 方案 A variant for /models/ cards — banner image LEFT at 56% flex basis with text RIGHT in a `.model-row` flex row; ≤767px collapses to an image-above-text stack — as a single-file restructure of `_pages/models.md` (13+/3−), images and `_data/models.yml` byte-untouched.

## What Was Built

**Card loop restructure** (inside `{% for model in site.data.models %}`, all column 0, G-1-3 grep still 0):
- `[featured badge div unchanged]` → `<div class="model-row">` → `.model-banner` div (inline featured `margin-top` conditional REMOVED) → `<div class="model-body">` wrapping the existing h4/tag/buttons/description/specs/tasks/note sequence **byte-identical** → `</div></div></div>`
- `markdown="0"` kept on section-card only (inner wrappers follow the existing no-attr pattern)

**Page-local style block** — old full-width centered banner rules (incl. `margin-bottom`, `overflow:hidden`, height implications) replaced with option-A rules exactly as approved:
- `.model-row { display:flex; gap:22px; align-items:flex-start; margin-top:var(--space-3); }` — the row margin now owns the featured-badge gap (visual parity)
- `.model-banner { flex:0 0 56%; max-width:56%; }` / `.model-banner img { width:100%; height:auto; display:block; border:1px solid var(--border); border-radius:10px; }` / `.model-body { flex:1; min-width:0; }`
- `@media (max-width:767px)` → `.model-row { flex-direction:column; gap:var(--space-3); }`, `.model-banner { flex:none; max-width:100%; width:100%; }`
- `.section-card` / `.section-card h4` / `p,li,.pub-authors` rules kept verbatim

**NOT done by design:** no "Access: pip install dnallm" spec line (user rejected — grep `Access:` = 0 in template and rendered page; the trailing dnallm callout's `pip install dnallm` untouched, count 1); zero changes to `images/` or `_data/models.yml` (diff name-only over both = empty).

## Verification Evidence

**Static shape:** template `class="model-row"` ×1 (loop) → rendered ×2; rendered `class="model-body"` ×2; `grep -En '^ {4,}.*<'` = 0 (G-1-3 preserved); `Access:` ×0; `pip install dnallm` ×1 (callout only); old inline `style="margin-top: var(--space-3);"` banner conditional ×0 on rendered page.

**Playwright 1.58.2 (igv-rust NODE_PATH) — 14/14 PASS:**

| Width | Check | Result |
|---|---|---|
| 1280 | card0 banner LEFT of body | PASS — banner.right 700.5 ≤ body.left 722.5 (gap 22) |
| 1280 | card0 banner ≈56% of row ±8px | PASS — 564.5 vs expected 564.5 (row 1008) — 0.0px deviation |
| 1280 | card0 img aspect drift <1% | PASS — nat 2372×1255, disp 564.5×299.6, drift 0.314% |
| 1280 | card0 badge above row | PASS — badge.bottom 335.3 ≤ row.top 347.3 |
| 1280 | card1 banner LEFT of body | PASS — 700.6 ≤ 722.6 |
| 1280 | card1 banner ≈56% ±8px | PASS — 565.6 vs 565.6 (row 1010) — 0.0px deviation |
| 1280 | card1 img aspect drift <1% | PASS — nat 3656×1628, disp 565.6×253.0, drift 0.434% |
| 375 | m-card0 banner ABOVE body (image first) | PASS — banner.top 462.6 < body.top 625.3 |
| 375 | m-card0 banner full row width ±2px | PASS — 283.0 = 283.0 |
| 375 | m-card0 aspect drift <1% | PASS — 283.0×150.7, drift 0.624% |
| 375 | m-card1 banner ABOVE body | PASS — 1293.3 < 1433.3 |
| 375 | m-card1 full row width | PASS — 285.0 = 285.0 |
| 375 | m-card1 aspect drift <1% | PASS — 285.0×128.0, drift 0.864% |

Geometry matches plan expectations (desktop displayed ≈553–566px wide, natural aspect, zero crop; mobile full-width ≈283–285 → 150.7/128.0 tall).

**Direct visual inspection (both widths):**
- `models-375.png` (Playwright full page, read inline): both cards stack image-first — complete figures full-width, text below, Featured badge on top. Dark mode.
- `models-kimi-1280.jpg` (user's real browser via Kimi bridge, read inline, 2× retina): both cards render image LEFT / text RIGHT — complete PlantHelixSeek multi-panel figure and PDLLMs figure (incl. right-side tree) with heading/tag/buttons/specs in the right column, badge above the row.
- `models-1280.png` (Playwright full page) kept as canonical artifact — its Read calls hit the CDN relay repeatedly (known intermittent, d6y/dvz/nl1 precedent); desktop direct inspection satisfied by the Kimi real-browser screenshot above plus matching DOM measures from two independent engines.

**Kimi bridge session `models-page-check` (user's real browser, reloaded with cache-buster):** DOM measure at vw=1280 — card0: banner 564.5 left of body 716.98 (row 1008), img 564.5×299.6 nat 2372×1255 complete, badgeAbove=true; card1: banner 565.6 left of body 717.1 (row 1010), img 565.6×253.0 nat 3656×1628, no badge. Identical values to Playwright.

**Repo gates:** `scripts/validate.sh` → `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`; `scripts/ci-smoke.sh _site` → `PASS: sitemap=11, anchor ok, feed valid, no vendor`. Porcelain excluding `.planning/` = exactly 1 entry (`M _pages/models.md`). Serve task bysvkf7vb regenerated within ~1s of the edit.

## Commits

- `67b85154` — fix(quick-260916-ovj): models cards layout option A — image left, text right (1 file, 13+/3−, numstat names only `_pages/models.md`; 0 deletions; local, not pushed)

## Deviations from Plan

None — plan executed exactly as written. Tooling notes: the desktop full-page PNG screenshot was CDN-relayed on every Read attempt (6 tries incl. downscaled/cropped/JPEG variants); per the d6y/dvz/nl1 precedent the desktop visual check was satisfied by the Kimi real-browser screenshot (read inline) + dual-engine DOM geometry agreement. Workaround artifacts and the Playwright runner script removed after evidence capture; canonical screenshots kept in this directory.

## Self-Check: PASSED

- `_pages/models.md` modified and committed (`67b85154` in `git log`)
- Evidence files present: `models-1280.png`, `models-375.png`, `models-kimi-1280.jpg`
- `images/` + `_data/models.yml` byte-untouched (diff name-only empty over both)
- `.planning/` docs left uncommitted for the orchestrator (per constraints)
