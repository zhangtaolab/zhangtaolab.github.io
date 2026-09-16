---
phase: quick-260916-d6y
plan: 01
subsystem: models-page
tags: [models, images, css, responsive, visual-verification]
requires:
  - "260916-cs1: /models/ cards render paper-figure thumbnails via _data/models.yml image/image_alt"
provides:
  - "/models/ cards render the visually approved architecture-panel figures uncropped at desktop and mobile breakpoints"
  - "Mobile card layout contract: thumbnail above body text (column-reverse), contain fit for diagrams"
affects:
  - "images/models/ (two old figure PNGs removed, two architecture PNGs added)"
  - "_data/models.yml (both image/image_alt values)"
  - "_pages/models.md (page-local style block: padding, object-fit, mobile flex order)"
tech-stack:
  added: []
  patterns:
    - "column-reverse for DOM-order body-then-thumb cards on narrow viewports (image above text without reordering markup)"
    - "object-fit: contain + container padding for never-cropped diagram thumbnails"
key-files:
  created:
    - images/models/plantelixseek-architecture.png
    - images/models/pdllms-architecture.png
  modified:
    - _data/models.yml
    - _pages/models.md
  deleted:
    - images/models/plantelixseek-fig1.png
    - images/models/pdllms-fig1.png
decisions:
  - "Copy staged /tmp PNGs byte-identically (cmp-verified), never regenerate — the crops were visually approved by the user"
  - "object-fit: contain instead of cover — architecture diagrams must never be cropped, letterbox is acceptable"
  - "flex-direction: column-reverse (not markup reorder) — DOM stays body-then-thumb for desktop row layout; narrow screens visually flip to image-first without touching the G-1-3 column-0 markup"
metrics:
  duration: 8 min
  completed: 2026-09-16
estimate:
  tokens: 25000
  confidence: med
actuals:
  tokens: 710      # chars/4 over the realized text diff (2840 chars); PNG binaries add no authored chars
  tasks: 2
  commits: 1       # measured: git rev-list --count b9768846..HEAD
plan_head_before: b9768846
status: complete
---

# Quick Task 260916-d6y: Fix /models/ card image layout on mobile Summary

Swapped the too-busy full-paper Figure 1 thumbnails for the visually approved architecture-panel crops (byte-identical to the staged /tmp originals), switched `.software-thumb img` to `object-fit: contain` with 8px container padding so diagrams are never cropped, and flipped the 767px media query to `column-reverse` so the thumbnail renders ABOVE the card body text on mobile — proven this time with rendered screenshots and DOM geometry at both breakpoints, not curl greps (the failure mode of quick task 260916-cs1's verification).

## What Was Done

### Task 1: Image swap + models.yml + style block (commit f7d68596)

- `images/models/`: deleted `plantelixseek-fig1.png` and `pdllms-fig1.png` (260916-cs1's full-paper figures); copied `helixseek-arch-raw.png` → `plantelixseek-architecture.png` (244679 B) and `pdllms-arch-raw.png` → `pdllms-architecture.png` (24268 B). Plain `cp`/`rm`; `cmp` byte-identity against the staged originals passed for both (T-d6y-01 mitigation).
- `_data/models.yml`: PlantHelixSeek `image` → `/images/models/plantelixseek-architecture.png` with `image_alt` "PlantHelixSeek architecture: single-nucleotide tokenizer, interleaved attention/MLA/Delta layers, sparse MoE"; PDLLMs `image` → `/images/models/pdllms-architecture.png` with `image_alt` "PDLLMs architecture comparison with other DNA language models". Double-quoted, quote-free strings; nothing else in the file changed.
- `_pages/models.md` page-local style block, three edits inside the existing block only (`_sass/` and `assets/css/` untouched):
  - `.software-thumb` gained `padding: 8px;` so the contain-letterbox sits against the existing `#f8f8f6` background.
  - `.software-thumb img` `object-fit: cover` → `contain` (zero `cover` remaining in the file).
  - 767px media query `.software-card` `flex-direction: column` → `column-reverse` (DOM order is body-then-thumb, so narrow screens render thumb first).
- Live livereload serve picked the swap up on the first poll; new URLs 200, old figure URL 404.

### Task 2: Visual verification + machine gates + change-set audit

- Screenshots captured with the proven Playwright CLI (v1.63.0, cached Chromium):
  - `/tmp/d6y-1280.png` — `--viewport-size=1280,900 --full-page`
  - `/tmp/d6y-375.png` — `--viewport-size=375,700 --full-page`
- The 375px screenshot was visually inspected: Featured ribbon sits at the very top of the PlantHelixSeek card, the architecture figure renders directly below it spanning the full card width with visible contain letterbox padding, and the body text (name/tag/buttons/description/specs) follows BELOW the image. Complete figures, no cropping, no dashed placeholder box.
- The 1280px screenshot file could not be visually inspected through this environment's file-read path (image relayed to CDN instead of rendered), so per the plan's fallback chain 1280px acceptance was proven by DOM geometry (getBoundingClientRect via Playwright 1.63.0, `/tmp/d6y-geometry-check.js`), which also machine-asserted both cards at both widths:
  - 1280px: thumb is a right column (`thumb.right 1144/1145` > `body.right`, left edge ≈ 884/885), width exactly 260px, `objectFit: contain` computed, img rect fully inside the thumb rect (no overflow → no cropping), `.software-thumb-placeholder` count 0.
  - 375px: `thumb.top 462.6/1338.7` < `body.top 682.6/1558.7` (image above body on BOTH cards), thumb width 283/285 = full card width, height exactly 200px, Featured ribbon top 423 above thumb top 462.6.
  - Verdict: `GEOMETRY ALL PASS`.

## Verification Results

All gates green:

| Gate | Result |
|------|--------|
| `cmp` byte-identity both new PNGs vs /tmp/models_imgs/ staged originals | pass |
| Old figure PNGs gone from disk (`[ ! -f ... ]` ×2) | pass |
| `object-fit: contain` ≥1 / `object-fit: cover` = 0 in models.md | pass (1 / 0) |
| `flex-direction: column-reverse` + `padding: 8px` in models.md | pass |
| `architecture.png` ≥2 / `fig1` = 0 in models.yml | pass (2 / 0) |
| Live serve: both new image URLs HTTP 200 | pass |
| Live serve: old plantelixseek-fig1.png URL | 404 (pass) |
| Visual/geometry at 1280px | right-column 260px contain thumb, full figure, no placeholder (pass) |
| Visual/geometry at 375px | image above body text, full card width, 200px tall, ribbon on top (pass) |
| `scripts/validate.sh` | PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一 |
| `bundle exec jekyll build` + `scripts/ci-smoke.sh _site` | PASS: sitemap=11, anchor ok, feed valid, no vendor |
| Change-set audit (content-scoped) | exactly 6 paths: 2 D + 2 ?? in images/models/, M models.yml, M models.md (pass) |
| `_sass/` + `assets/css` scope | 0 changed paths (pass) |
| One local commit of exactly the 6 agreed paths | pass (f7d68596) |

Evidence files: `/tmp/d6y-1280.png`, `/tmp/d6y-375.png`, `/tmp/d6y-geometry-check.js` (geometry source), `/tmp/d6y-status.txt` (audit capture).

Nothing pushed — DEPLOY_ENABLED is live on main and push timing belongs to the user.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking verify-command fix] Change-set audit counted 7 lines instead of 6**
- **Found during:** Task 2, step 4
- **Issue:** the plan's audit asserts `git status --porcelain` = exactly 6 entries, but the orchestrator-owned untracked task workspace `?? .planning/quick/260916-d6y-fix-models-page-card-image-layout-mobile/` (created before execution began; docs artifacts the orchestrator commits in its Step 8) is also listed, making the count 7.
- **Fix:** re-ran the audit content-scoped (`git status --porcelain | grep -v '^?? \.planning/'`) — exactly the 6 agreed content paths remain (2 deletions, 2 new PNGs, models.yml, models.md), `_sass`/`assets/css` still 0. Strictly equivalent to the plan's intent; no tree state was changed.
- **Files modified:** none (verification command only)
- **Commit:** n/a

**2. [Evidence-path note] 1280px screenshot inspected via geometry instead of direct vision**
- **Found during:** Task 2, step 1
- **Issue:** this environment's file-read relayed `/tmp/d6y-1280.png` to a CDN link instead of rendering it, so direct visual inspection of the desktop screenshot was not possible (the 375px screenshot DID render and was visually verified).
- **Fix:** applied the plan's own documented fallback — DOM geometry via JS in Playwright (`thumb.right > body.right`, width 260±5 at 1280px; `thumb.top < body.top` at 375px), plus computed `object-fit`, img-inside-thumb containment, and placeholder-count assertions at both widths. Geometry is the plan-sanctioned visual-equivalent; HTML grep was NOT used.
- **Files modified:** none (read-only script `/tmp/d6y-geometry-check.js`)
- **Commit:** n/a

## Auth Gates

None encountered.

## Known Stubs

None. The `{% else %}` dashed-placeholder branch retained in source remains an intentional documented fallback for future image-less entries; the rendered DOM contains zero placeholder elements (machine-asserted at both viewports).

## Self-Check: PASSED

- images/models/plantelixseek-architecture.png — FOUND (tracked in f7d68596)
- images/models/pdllms-architecture.png — FOUND (tracked in f7d68596)
- _data/models.yml modified — FOUND (tracked in f7d68596)
- _pages/models.md modified — FOUND (tracked in f7d68596)
- Old figure PNGs absent from tree — FOUND (deleted in f7d68596)
- Commit f7d68596 — FOUND on local main (`git log --oneline --all` match)
