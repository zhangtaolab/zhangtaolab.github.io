---
phase: quick-260916-dvz
plan: 01
subsystem: models-page
tags: [models, images, css, responsive, visual-verification]
requires:
  - "260916-d6y: /models/ cards render architecture-panel figures, contain fit, image-above-text mobile order"
provides:
  - "/models/ PDLLMs card shows the visually approved landscape top-panel-A crop (core promoter + terminator architecture schematics)"
  - "Natural-aspect card thumbnails: thumb box hugs the image (no letterbox filler, no stretch to body height) at desktop and mobile"
  - "Mobile thumb: centered <=300px block above body text at natural height (fixed 200px height gone)"
affects:
  - "images/models/pdllms-architecture.png (replaced content, same filename)"
  - "_data/models.yml (PDLLMs image_alt only)"
  - "_pages/models.md (page-local style block: alignment keyword, img height, mobile thumb rule)"
tech-stack:
  added: []
  patterns:
    - "height: auto + width: 100% for natural-aspect thumbnails (letterboxing impossible; object-fit becomes inert)"
    - "page-local height:auto override to cancel a same-specificity global rule (assets/css/custom.scss also styles the shared .software-thumb class names)"
key-files:
  created: []
  modified:
    - images/models/pdllms-architecture.png
    - _data/models.yml
    - _pages/models.md
  deleted: []
decisions:
  - "PDLLMs image swapped by byte-identical cp of the visually approved /tmp crop (cmp-verified repo + served URL); PlantHelixSeek portrait architecture diagram byte-untouched (cmp vs git HEAD)"
  - "align-items: flex-start on .software-card + height: auto on .software-thumb img — thumb column sizes to its image, not the body; letterboxing becomes structurally impossible"
  - "Mobile .software-thumb: width 100% capped at 300px, margin auto centering, explicit height: auto — the neutral height declaration is required to cancel the global custom.scss mobile height: 200px (same-specificity cascade; see Deviation 1)"
metrics:
  duration: 12 min
  completed: 2026-09-16
estimate:
  tokens: 30000
  confidence: low
actuals:
  tokens: 627      # chars/4 over the realized text diff (2506 chars); PNG binary adds no authored chars
  tasks: 2
  commits: 1       # measured: git rev-list --count 9d94b7e4..HEAD
plan_head_before: 9d94b7e4
status: complete
---

# Quick Task 260916-dvz: Models card figures round 2 (keep PlantHelixSeek) Summary

Swapped the PDLLMs card image to the user-approved landscape top-panel-A crop (core promoter + terminator architecture schematics, byte-identical to the staged /tmp original), kept PlantHelixSeek on its already-approved portrait architecture diagram byte-untouched, and reworked the card thumbnail layout to natural aspect ratio — `align-items: flex-start` kills the stretch-to-body column, `height: auto` makes letterboxing structurally impossible, and the mobile thumb became a centered <=300px block at natural height above the text — all proven with rendered DOM geometry (getBoundingClientRect, 0.00% aspect drift) at 1280px and 375px.

## What Was Done

### Task 1: PDLLMs image + alt text + natural-aspect style block (commit 6f186341)

- `images/models/pdllms-architecture.png`: plain byte-identical `cp` of `/tmp/models_imgs/pdllms-topA-raw.png` (PNG 660x290, 15287 B, 8-bit RGBA) over the tracked filename (status M). `cmp` passed repo-side and against the served URL. `images/models/plantelixseek-architecture.png` untouched — `cmp` against `git show HEAD:` passed (790x1300 portrait diagram stays).
- `_data/models.yml`: PDLLMs entry only — `image_alt` → "Core promoter and terminator architecture analyzed by PDLLMs" (plain ASCII, double-quoted, no embedded quotes; T-dvz-02). `image` key unchanged (same path, new bytes). PlantHelixSeek entry untouched.
- `_pages/models.md` page-local style block only (3 planned scoped edits + 1 deviation-driven, see Deviation 1):
  - Base `.software-card`: `align-items: stretch` → `flex-start` (side thumb column no longer stretches to body height).
  - `.software-thumb img`: `{ width: 100%; height: 100%; object-fit: contain; display: block; }` → `{ width: 100%; height: auto; display: block; }` (natural aspect; object-fit declaration removed entirely).
  - 767px media query: combined `.software-thumb, .software-thumb-placeholder` rule SPLIT — `.software-thumb { width: 100%; max-width: 300px; min-width: 0; height: auto; margin: 0 auto var(--space-3); }` (centered compact block, `height: auto` per Deviation 1), `.software-thumb-placeholder { width: 100%; min-width: 0; height: 200px; }` (documented fallback, no card uses it). `flex-direction: column-reverse` and the mobile `.software-card` rule kept exactly as-is (image above text without reordering markup, per d6y decision).
- Committed exactly the 3 paths in one commit: `fix(quick/models): pdllms top-A architecture crop + natural-aspect card thumbnails`.

### Task 2: Rendered-geometry proof + machine gates + change-set audit

- Serve freshness: livereload picked everything up — new alt text exactly once in served HTML, both image URLs HTTP 200 and byte-identical to their sources (PDLLMs vs /tmp crop, HelixSeek vs `git show HEAD:`).
- Screenshots re-taken post-fix with Playwright CLI v1.63.0 (cached Chromium): `/tmp/dvz-models-1280-final.png` (1280x900 full-page), `/tmp/dvz-models-375-final.png` (375x700 full-page; grew 309806 → 341806 B vs pre-fix capture, consistent with the portrait figure now rendering at full 454px instead of being clipped to 200px). Both file-reads relayed to this environment's CDN (d6y precedent), so DOM geometry is the acceptance evidence per the plan's fallback.
- DOM geometry via fresh `/tmp/dvz-geometry-check.js` (Playwright JS, natural dims ground truth HelixSeek 790x1300 / PDLLMs 660x290), all-PASS at both widths:
  - 1280px BOTH cards: thumb right column (`thumb.right 1144/1145 > body.right 864/865`), outer width exactly 260.0 [255-265], aspect drift 0.00% (HelixSeek img 242.0x398.2, h/w 1.6455 vs natural 1.6456; PDLLMs img 242.0x106.3, h/w 0.4394 vs 0.4394), hug `thumb.height - img.height` = 18.0px = exactly the box chrome (16 padding + 2 border) — zero letterbox filler; HelixSeek box 416.2 [395-430], img 398.2 [391-411]; PDLLMs box 124.3 [100-140], img 106.3 [100-114]; applied `.software-thumb img` rule height is `auto`; neither box stretched to its body height (PDLLMs 124.3 vs body 183.7 — under stretch it would be 183.7); `.software-thumb-placeholder` count 0.
  - 375px BOTH cards: thumb renders ABOVE body text (`thumb.top < body.top`), horizontally centered (side-margin delta 0.0px < 8), width 283/285 <= 300, aspect drift 0.00% (HelixSeek img 265.0x436.1; PDLLMs img 267.0x117.3), hug 18.0px both, HelixSeek box 454.1 NOT within 200±5 (fixed height gone), placeholder count 0.
- Machine gates: `scripts/validate.sh` PASS (news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一); `bundle exec jekyll build` + `scripts/ci-smoke.sh _site` PASS (sitemap=11, anchor ok, feed valid, no vendor).
- Change-set audit (content-scoped per d6y precedent): `git status --porcelain | grep -v '^?? \.planning/'` empty after the commit; `git show --stat HEAD` = exactly 3 files changed; zero changed paths under `_sass/` and `assets/css/`.

## Verification Results

All gates green:

| Gate | Result |
|------|--------|
| `cmp` byte-identity pdllms-architecture.png vs /tmp/models_imgs/pdllms-topA-raw.png (repo + served URL) | pass |
| `cmp` byte-identity plantelixseek-architecture.png vs `git show HEAD:` (repo + served URL) | pass (untouched) |
| New alt text exactly once in models.yml and in served HTML | pass (1 / 1) |
| models.md greps: stretch=0, object-fit=0, height:100%=0, height:200px=1 (placeholder rule only), max-width:300px=1, margin 0 auto var(--space-3)=1, column-reverse=1, combined selector=0 | pass |
| Geometry 1280px (right column, 260px, 0.00% drift, hug 18, ranges, no stretch, rule height auto) | pass (both cards) |
| Geometry 375px (above text, centered 0.0px delta, <=300px, 0.00% drift, hug 18, not 200±5) | pass (both cards) |
| `.software-thumb-placeholder` rendered count | 0 at both widths |
| Live serve image URLs | 200 + byte-identical (both) |
| `scripts/validate.sh` | PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一 |
| `bundle exec jekyll build` + `scripts/ci-smoke.sh _site` | PASS: sitemap=11, anchor ok, feed valid, no vendor |
| Change-set audit | exactly 3 paths, all M; `_sass/` + `assets/css/` = 0 changed paths |
| One local commit of exactly the 3 agreed paths | pass (6f186341) |

Evidence files: `/tmp/dvz-models-1280-final.png`, `/tmp/dvz-models-375-final.png`, `/tmp/dvz-geometry-check.js` (geometry source), `/tmp/dvz-commit-stat.txt`, `/tmp/dvz-status.txt`.

Nothing pushed — DEPLOY_ENABLED is live on main and push timing belongs to the user.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking cascade] `height: auto` added to the mobile `.software-thumb` rule**
- **Found during:** Task 2, step 3 (first geometry run)
- **Issue:** the plan's edit 3c left the mobile `.software-thumb` with NO height declaration, assuming natural height would follow. But `assets/css/custom.scss` (global stylesheet created for the /software/ page) also styles the shared class names and its 767px media query contains `.software-thumb, .software-thumb-placeholder { ...; height: 200px; }` (line 65). Equal specificity + undeclared property in the page rule → the global 200px won: at 375px the portrait HelixSeek figure was CLIPPED (img 436px inside an `overflow: hidden` 200px box) and PDLLMs letterboxed (82.7px filler) — exactly the defects this task removes. d6y never saw this because its page rule declared the identical 200px itself, masking the global.
- **Fix:** declared `height: auto` (the neutral value, not a fixed height) in the page-local mobile `.software-thumb` rule. Satisfies the must-have truth "no fixed 200px height on .software-thumb" and every plan grep gate (still exactly one `height: 200px` in models.md — the placeholder fallback rule). Forbidden paths `_sass/` and `assets/css/` untouched; /software/ page unaffected.
- **Files modified:** `_pages/models.md` (one declaration inside the same mobile rule the plan already edited)
- **Commit:** folded into the single atomic commit via one local amend (0ca7deb4 → 6f186341, same message, still exactly 3 paths / 5 insertions / 4 deletions — the plan's success criteria mandate exactly 1 local commit, and 0ca7deb4 was never pushed)

**2. [Evidence-path note] Screenshots inspected via geometry instead of direct vision**
- **Found during:** Task 2, step 2
- **Issue:** both screenshot file-reads (pre-fix and post-fix, 1280px and 375px) relayed to this environment's CDN instead of rendering — the same d6y 1280px precedent, now hitting the 375px file too.
- **Fix:** applied the plan's own documented fallback — DOM geometry via Playwright `getBoundingClientRect` with printed measurements and per-check PASS lines (30 PASS lines total). Geometry is the plan-sanctioned visual-equivalent; HTML grep was NOT used as acceptance evidence.
- **Files modified:** none (read-only script `/tmp/dvz-geometry-check.js`)
- **Commit:** n/a

### Plan-Assumption Corrections (informational, no action required)

- **Mobile px estimates were ~18px high:** the plan derived mobile img heights (HelixSeek 465-470, PDLLMs 119-131) from the card inner width without subtracting the 18px box chrome. Measured: 436.1 / 117.3 with aspect drift 0.00% — the ratio assertion (within 3% of natural) is the authoritative natural-aspect proof and passes exactly.
- **"HelixSeek thumb box strictly less than body height" is unsatisfiable:** the portrait figure at 242px content width is 398.2px tall while the card body text needs only 379.3px, so the natural thumb box (416.2) necessarily exceeds the body. Equivalent anti-stretch evidence delivered instead: hug = 18px chrome exactly (box hugs the image, not the body), box height within the natural-derived range [395,430], and the generic not-stretched-to-body check (under `align-items: stretch` the discriminating PDLLMs card would have been 183.7; measured 124.3).
- **Computed `object-fit: cover` on the thumbs** is inherited from global `custom.scss` `.software-thumb img` (the page rule no longer declares object-fit, per the plan's own grep gate forbidding it). Inert under `height: auto` + `width: 100%` — proven by 0.00% aspect drift at both widths. No action; re-declaring it in models.md would violate the plan's object-fit=0 gate.

## Auth Gates

None encountered.

## Known Stubs

None. The `{% else %}` dashed-placeholder branch retained in source remains an intentional documented fallback for future image-less entries; the rendered DOM contains zero placeholder elements (machine-asserted at both viewports).

## Self-Check: PASSED

- images/models/pdllms-architecture.png — FOUND (tracked, replaced content in 6f186341)
- _data/models.yml modified — FOUND (tracked in 6f186341)
- _pages/models.md modified — FOUND (tracked in 6f186341)
- Commit 6f186341 — FOUND on local main (`git log --oneline --all` match), never pushed
