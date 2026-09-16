---
phase: quick-260916-ksu
plan: 01
subsystem: models-page
tags: [models, css, images, layout, visual-verification]
requires:
  - "260916-dvz: /models/ cards render architecture figures as natural-aspect side thumbnails"
provides:
  - "/models/ cards show the user-approved composed banners (ffmpeg hstack triptychs) full-width at the top with all text below"
  - "ONE card layout at every viewport width (260px banner >=768px, 190px below) — two-column side-thumbnail layout and its responsive flip are gone"
  - "No placeholder branch: future imageless registry entries render text-only (dashed Model placeholder removed for good)"
affects:
  - "images/models/plantelixseek-banner.png (added, byte-identical to /tmp/models_imgs/hs-banner.png)"
  - "images/models/pdllms-banner.png (added, byte-identical to /tmp/models_imgs/pd-banner.png)"
  - "images/models/plantelixseek-architecture.png (deleted — superseded by composed banner)"
  - "images/models/pdllms-architecture.png (deleted — superseded by composed banner)"
  - "_data/models.yml (image/image_alt repointed on both entries + schema comment wording)"
  - "_pages/models.md (card loop restructured, page-local style block replaced)"
tech-stack:
  added: []
  patterns:
    - "Full-width top banner: .model-banner width 100% + fixed height + object-fit cover inside section-card (no flex columns)"
    - "Featured spacing as conditional inline style on the banner div (margin-top var(--space-3)) replacing the old wrapper's conditional"
    - "Scoped .section-card h4 typography rule preserving title metrics the removed .software-body descendant selector used to provide"
key-files:
  created:
    - images/models/plantelixseek-banner.png
    - images/models/pdllms-banner.png
  modified:
    - _data/models.yml
    - _pages/models.md
  deleted:
    - images/models/plantelixseek-architecture.png
    - images/models/pdllms-architecture.png
decisions:
  - "Byte-identity contract honored with plain cp (no re-encode/optimize): on-disk cmp AND served-URL cmp both green for both banners — the T-ksu-01 mitigation"
  - "Single .section-card h4 rule added to the page-local style block (the plan's documented cascade companion): without it the h4 fell to browser defaults after the .software-body wrapper dropped"
  - "Global assets/css/custom.scss untouched per plan mandate — its legacy .software-* rules are now simply inert on this page (they remain live for /software/)"
metrics:
  duration: 4 min
  completed: 2026-09-16
estimate:
  tokens: 48000
  confidence: low
actuals:
  tokens: 1322     # chars/4 over the realized text diff (5286 chars); PNG binaries add no authored chars
  tasks: 3
  commits: 1       # measured: git rev-list --count a7922a70..HEAD
plan_head_before: a7922a70
status: complete
---

# Quick Task 260916-ksu: Models cards full-width composed banner Summary

Swapped the /models/ two-column card layout (text + side thumbnail with responsive flip) for the user's approved mockup: one full-width composed banner at the top of each card with all text below, identical structure at desktop and mobile — banners are the user-composed ffmpeg hstack triptychs (PlantHelixSeek corpus/architecture/AUROC 1414x560; PDLLMs promoter/comparison/token-cloud 980x300), staged byte-identical, proven in rendered geometry AND visually inspectable screenshots at both widths.

## What Was Done

### Task 1: Stage composed banner images, retire superseded figures

- Precondition met: both /tmp/models_imgs/ sources present (227933 B / 27054 B).
- `cp` (byte-identical) hs-banner.png → images/models/plantelixseek-banner.png, pd-banner.png → images/models/pdllms-banner.png; `git rm --` removed both pre-existing architecture figures (the directory's only two files before the copies).
- TASK1-PASS: cmp green for both, dimensions sips-verified 1414x560 and 980x300, retired files gone from working tree, no other image touched.

### Task 2: Repoint models.yml entries to the banners

- PlantHelixSeek: image → /images/models/plantelixseek-banner.png, image_alt → "PlantHelixSeek: pretraining corpus, model architecture and AUROC benchmark".
- PDLLMs: image → /images/models/pdllms-banner.png, image_alt → "PDLLMs: promoter architecture, model comparison and tokenizer".
- Header schema comment: "card thumbnail" → "full-width card banner". All other keys, entry order, and the image_alt comment line untouched.
- TASK2-PASS: exactly 1 banner-path grep hit per entry, 0 architecture.png hits, both alt strings exact, validate.sh PASS (news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一).

### Task 3: Restructure models.md to full-width banner cards + verify end-to-end

- EDIT 1: page-local style block replaced with exactly the six enumerated rules (.section-card padding, .model-banner 260px cover box, .model-banner img, scoped .section-card h4 typography, 767px media query with only height 190px, and the kept p/li/.pub-authors max-width rule).
- EDIT 2: card loop flattened — badge conditional as-is, then ONE column-0 single-line banner conditional (conditional margin-top only when featured, NO else-branch), then the body content byte-identical as a bare sequence; old flex wrapper, body wrapper, and trailing thumbnail/placeholder line deleted. G-1-3 grep `^ {4,}.*<` = 0 matches.
- TASK3-SHELL-PASS: zero 'software' tokens in models.md, class="model-banner" present, both banner URLs serve HTTP 200 and cmp byte-identical to staged sources, validate.sh PASS, ci-smoke.sh PASS (sitemap=11, anchor ok, feed valid, no vendor), porcelain gate = exactly the 6 enumerated paths.

## Verification Evidence

| Gate | Result |
|------|--------|
| Byte-identity, on-disk (cmp, both banners) | pass |
| Byte-identity, as-served over HTTP (cmp vs /tmp sources, both) | pass |
| Banner pixel dimensions (sips) | 1414x560 / 980x300 as planned |
| models.yml repoint greps + validate.sh | pass |
| Geometry 1280x900 (count 2; widths 1008.0/1010.0 within 2px of content-box and inside [1005,1015]; heights exactly 260.0; banner bottom above h4 top, gap 12.0 in [0,24]; object-fit cover; naturalWidth 1414/980 > 0; src = expected -banner.png per card) | pass (both cards) |
| Geometry 1280 Featured card (badge bottom 335.3 <= banner top 347.3) | pass |
| Geometry 375x812 (count 2; widths 283.0/285.0 within 2px and inside [283,287]; heights exactly 190.0; still above h4, gap 12.0) | pass (both cards) |
| Legacy-class elements (.software-card/.software-body/.software-thumb/.software-thumb-placeholder) at both widths | 0 |
| Screenshots | /tmp/ksu-models-1280.png, /tmp/ksu-models-375.png — BOTH visually inspected this run (unlike d6y/dvz CDN-relay blocks): full-width banner under the Featured ribbon, text below, identical single-column arrangement at mobile, no two-column/flip/placeholder anywhere |
| Change-set gate | exactly 6 paths, nothing outside .planning/ |
| scripts/ci-smoke.sh _site | PASS: sitemap=11 |

Evidence files: `/tmp/ksu-models-1280.png`, `/tmp/ksu-models-375.png`, `/tmp/ksu-geometry-check.js` (42-line ALL-GEOMETRY-PASS source), `/tmp/ksu-hs-served.png`, `/tmp/ksu-pd-served.png`, `/tmp/ksu-porcelain.txt`.

Nothing pushed — DEPLOY_ENABLED is live on main and push timing belongs to the user.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - gate mechanics] Untracked-directory collapse in the porcelain change-set gate**
- **Found during:** Task 3 shell battery (first run)
- **Issue:** with both new banner PNGs untracked, `git status --porcelain` collapses the wholly-untracked directory to `?? images/models/` — the plan's literal gate diff then showed `images/models/` instead of the two individual banner paths and failed (4d2/4a4/5a6 against the expected list).
- **Fix:** staged the two banners before re-running the gate (they required staging for the single end-of-run commit regardless, per the quick-task convention). Gate then enumerated all 6 paths individually and passed. No change-set change — the same 6 paths, just staged earlier than the gate's first invocation assumed.
- **Files modified:** none (index state only)
- **Commit:** n/a (pre-commit ordering)

### Evidence-quality note (informational)

Both screenshots relayed AND rendered for direct visual inspection this run — the d6y/dvz CDN-relay block did not recur, so the plan's preferred evidence mode (screenshots) was satisfied directly, with the DOM geometry battery as independent corroboration (42 PASS lines). HTML grep was not used as layout evidence.

## Self-Check: PASSED

- images/models/plantelixseek-banner.png — FOUND (tracked, commit 1b9b7a5d)
- images/models/pdllms-banner.png — FOUND (tracked, commit 1b9b7a5d)
- _data/models.yml changes — FOUND (git log -1 --name-only)
- _pages/models.md changes — FOUND (git log -1 --name-only)
- Commit 1b9b7a5d — FOUND on main (local, not pushed)
- Retired figures absent from working tree — VERIFIED ([ ! -e ] gates in TASK1-PASS)
