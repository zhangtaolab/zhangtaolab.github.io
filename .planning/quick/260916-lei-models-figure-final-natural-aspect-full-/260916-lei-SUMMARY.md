---
phase: quick-260916-lei
plan: 01
subsystem: models-page
tags: [models, css, layout, natural-aspect, visual-verification]
requires:
  - "260916-ksu: /models/ cards render user-approved composed banners full-width at card top (fixed 260px/190px cover boxes)"
provides:
  - "/models/ banners display the COMPLETE single figure at NATURAL aspect on every viewport width — zero cropping, pure fluid scaling, no breakpoint rule involved"
  - "Page-local CSS declares .model-banner height auto + .model-banner img width 100%/height auto/display block (no object-fit) — the box derives its height from the image, not the reverse"
  - "Computed objectFit on both banner imgs is the CSS initial 'fill' and box aspect equals natural aspect (drift < 0.5% measured), so fill is identity — zero crop is structural"
affects:
  - "_pages/models.md (page-local style block only: .model-banner height 260px→auto, .model-banner img height 100%→auto + object-fit cover deleted, 767px media query block deleted)"
tech-stack:
  added: []
  patterns:
    - "Natural-aspect fluid banner: width-constrained block img with height auto — the banner box aspect follows the source image at every width, making media-query height overrides structurally unnecessary"
    - "Inert-overflow safety retained: overflow hidden stays on .model-banner as harmless defense even though a same-aspect child can never overflow it"
key-files:
  created: []
  modified:
    - _pages/models.md
  deleted: []
decisions:
  - "User-approved presentation option '单图完整展示' (single complete figure) implemented as pure CSS fluidity: 3 exact edits in the page-local style block, card DOM / models.yml / images / global SCSS all untouched from ksu"
  - "object-fit deleted rather than set to contain: with height auto the box aspect equals the natural aspect, so the property is moot — its computed value settling at the CSS initial 'fill' is itself the proof the page cover declaration is gone"
  - "767px breakpoint deleted outright: fluid natural scaling has no phone special case; cascade verified safe at planning time (no .model-banner selector anywhere in custom.scss/_sass/_includes/_layouts)"
metrics:
  duration: 8 min
  completed: 2026-09-16
estimate:
  tokens: 22000
  confidence: low
actuals:
  tokens: 232      # chars/4 over the realized diff (928 chars)
  tasks: 2
  commits: 1       # measured: git rev-list --count d616c144..HEAD
plan_head_before: d616c1446792f22b5e22df94c67a5424f65a13b6
status: complete
---

# Quick Task 260916-lei: Models figure final natural-aspect full display Summary

Switched the /models/ card banners from ksu's fixed-height cropped boxes (260px desktop / 190px phone, object-fit cover) to fluid natural-aspect display of the complete composed figures — three exact edits in the page-local style block of `_pages/models.md`, nothing else touched. Both banners (HelixSeek 1414x560, PDLLMs 980x300) now render their full source image uncropped at every viewport width, proven in dual-width DOM geometry (30/30 PASS, drift under 0.5%) AND directly inspectable screenshots.

## What Was Done

### Task 1: Natural-aspect style block — three exact edits, one file

- EDIT 1: `.model-banner` height `260px` → `auto` (width, border-radius, overflow, border, margin-bottom byte-identical; overflow kept as inert safety per plan).
- EDIT 2: `.model-banner img` → `width: 100%; height: auto; display: block;` (height `100%` replaced, `object-fit: cover` declaration deleted entirely).
- EDIT 3: the entire `@media (max-width: 767px) { .model-banner { height: 190px; } }` block deleted (3 lines: @media line, inner rule, closing brace).
- `.section-card`, `.section-card h4`, and `p, li, .pub-authors` rules byte-identical; card DOM, `_data/models.yml`, `images/models/`, global SCSS untouched.
- TASK1-GATES-GREEN: exactly 2 `height: auto` occurrences, zero hits for `height: 260px|height: 190px|object-fit: cover|767px`, exactly 1 hit of the full `.model-banner img` rule string, porcelain exactly ` M _pages/models.md`.
- Committed as 36d7cba2 (1 file, 2 insertions, 5 deletions).

### Task 2: Dual-width natural-aspect geometry proof + regression gates

- Watch regeneration confirmed in 0s (`_site/models/index.html` style block shows the new rules, no 260px residue); Playwright measured with a fresh context per viewport (hard load, empty cache), waiting for both imgs `complete && naturalWidth > 0`.
- 1280x800 — HelixSeek: natural 1414x560, banner 1006x398, drift 0.104%; PDLLMs: natural 980x300, banner 1008x309, drift 0.139%; computed objectFit `fill` on both; computed heights resolve in px (398.406px / 308.562px) equal to banner clientHeight within 1px; banners above h4 (747.8<=759.8, 1494.0<=1506.0); Featured badge above banner (335.3<=347.3).
- 375x667 — HelixSeek banner 281x111, drift 0.258%; PDLLMs 283x87, drift 0.424%; objectFit `fill` both; px-resolved heights match; banners above h4; badge above banner — pure fluid scaling, no breakpoint rule in the cascade.
- Full-page screenshots saved as models-1280.png and models-375.png in this directory — BOTH directly visually inspected this run (ksu precedent held, no CDN-relay block): each banner shows its complete composed figure (logo panel + architecture panel) uncropped at natural aspect, text below, Featured ribbon above the HelixSeek banner, at both widths.
- Regression: `scripts/validate.sh` exit 0; `scripts/ci-smoke.sh _site` PASS with sitemap=11, anchor ok, feed valid, no vendor.
- Change-set: commit contains exactly 1 path (`_pages/models.md`); porcelain shows only the two screenshot artifacts under `.planning/` (outside the content change set; orchestrator handles the docs commit).

## Verification Evidence

| Gate | Result |
|------|--------|
| Task 1 grep gates (2x height:auto, zero fixed-height/cover/767px residue, exact img rule string, porcelain 1 path) | TASK1-GATES-GREEN |
| Geometry 1280x800 (30-assertion battery, both cards) | 15/15 PASS |
| Geometry 375x667 (both cards) | 15/15 PASS |
| Natural sizes served (1414x560 / 980x300 at both widths) | PASS — yml→render chain intact |
| Aspect drift < 1% (4 measurements) | 0.104% / 0.139% / 0.258% / 0.424% |
| Zero-crop structural proof | computed objectFit exactly `fill` (CSS initial — page cover declaration gone) AND box aspect == natural aspect, so fill is identity |
| Auto-height chain proof | computed img heights resolve in px (398.406px, 308.562px, 111.281px, 86.625px), each equal to banner clientHeight within 1px |
| Ordering (both widths) | banner bottom <= h4 top on both cards; Featured badge bottom 335.3 / 450.6 above banner top 347.3 / 462.6 |
| Screenshots | models-1280.png, models-375.png in this directory — both visually inspected: complete figures, zero cropping, single layout at both widths |
| scripts/validate.sh | exit 0 (news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一) |
| scripts/ci-smoke.sh _site | PASS: sitemap=11, anchor ok, feed valid, no vendor |
| Change-set gate | exactly 1 content path committed (_pages/models.md); porcelain outside .planning/ clean |

Evidence files: `models-1280.png`, `models-375.png` (this directory), `/tmp/lei-geometry.cjs` (30-assertion measurement source).

Nothing pushed — DEPLOY_ENABLED is live on main and push timing belongs to the user.

## Deviations from Plan

### Auto-fixed Issues

None — plan executed exactly as written.

### Gate-equivalence note (informational)

The plan's Task 2 change-set gate was authored for a pre-commit working tree (` M _pages/models.md` uncommitted). Per the per-task atomic-commit protocol, Task 1 was committed before Task 2 ran, so the equivalent post-commit evidence was used instead: `git diff --name-only HEAD~1 HEAD` = exactly `_pages/models.md`, and `git status --porcelain` shows only the two `.planning/` screenshot paths (untracked, orchestrator's docs commit). Same invariant — exactly one content path changed — verified by adjusted instrument.

## Self-Check: PASSED

- _pages/models.md style block — FOUND (height auto x2, no object-fit, no 767px block)
- Commit 36d7cba2 — FOUND on main (local, not pushed)
- models-1280.png — FOUND in this directory
- models-375.png — FOUND in this directory
- validate.sh / ci-smoke.sh — both green (exit 0, PASS sitemap=11)
