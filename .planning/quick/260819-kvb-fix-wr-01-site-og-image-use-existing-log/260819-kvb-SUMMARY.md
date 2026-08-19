---
phase: quick-260819-kvb
plan: 01
subsystem: site-meta
tags: [og-image, twitter-image, seo, wr-01, config]
requires:
  - images/logo.png (pre-existing, 37,038 bytes, in-repo)
  - _includes/head.html static_files existence guard (Phase 1 Plan 02 pattern)
provides:
  - og:image + twitter:image emitting https://zhangtaolab.org/images/logo.png on every built HTML page
  - WR-01 (02-REVIEW.md:60) closed
affects:
  - Social preview rendering for every shared zhangtaolab.org link (after next deploy)
tech-stack:
  added: []
  patterns:
    - "config-only fix: point an existing guarded config key at an existing static file rather than adding assets or editing templates"
key-files:
  created: []
  modified:
    - _config.yml (line 8: photo: headshot.jpg -> photo: logo.png)
decisions:
  - "User directive supersedes 02-REVIEW WR-01's suggested remedies (add headshot.jpg / blank the value): point photo at existing images/logo.png"
  - "head.html NOT modified — planner probe + executor audit confirm the static_files guard matches logo.png (static-file drop name includes extension)"
metrics:
  duration: 2 min
  completed: 2026-08-19T07:09:49Z
  tasks: 2
status: complete
actuals:
  tokens: 141    # chars/4 over the realized diff (566 chars, _config.yml one-line change); plan estimated 22000 — the fix itself was a true one-liner, the estimate covered the audit/proof battery
  tasks: 2
  commits: 1
---

# Quick Task 260819-kvb: Fix WR-01 site og:image (use existing logo.png) Summary

One-line `_config.yml` fix pointing `site.photo` at the existing `images/logo.png`, unblocking the static_files guard in `_includes/head.html` so og:image and twitter:image now emit `https://zhangtaolab.org/images/logo.png` on all 12 built HTML pages (previously: zero social preview images site-wide).

## What Was Done

### Task 1: Audit site.photo usage, apply minimal config fix, prove og:image end-to-end (tracer)

- **Precondition:** `images/logo.png` present (37,038 bytes, matches plan) and `Gemfile.lock` present — both verified before any edit.
- **Usage audit re-proven BEFORE editing:** `grep -rn "site\.photo" _includes _layouts _pages assets` returned EXACTLY 2 hits, both in `_includes/head.html` (line 12 og:image meta, line 16 twitter:image meta), both behind the same `{% assign photo_file = site.static_files | where: "name", site.photo | first %}` existence guard. No template renders site.photo as a visible PI photo/headshot. Audit matched the locked 2-hit expectation, so the minimal path proceeded.
- **The edit (sole change):** `_config.yml` line 8: `photo: headshot.jpg  # place your photo in images/` → `photo: logo.png  # social preview image (og:image / twitter:image), sourced from images/`. Key name `photo` unchanged. `_includes/head.html` NOT modified; no image files created, copied, or renamed.
- **End-to-end proof:** `JEKYLL_ENV=production bundle exec jekyll build` exited 0; `_site/index.html` contains exactly 1 og:image meta with content `https://zhangtaolab.org/images/logo.png` (and the matching twitter:image). The known harmless `assets/main.css`/`main.scss` output-conflict warning (documented in STATE.md) appeared as expected and does not affect the build.
- **Tracer feedback gate (auto mode active):** tracer `<verify>` re-run end-to-end after commit — PASS, so execution expanded to Task 2.
- **Commit:** `2e20772`

### Task 2: Full-surface proof battery, smoke assertions, local commit — no push

Full battery, every assertion green before and after commit:

| # | Assertion | Result |
|---|-----------|--------|
| 1 | og:image coverage equals og:title coverage | og:image=12, og:title=12 (12/12 built HTML pages, 404.html included) |
| 2 | twitter:image emits the exact logo URL on the same pages | twitter:image=12, all `name="twitter:image" content="https://zhangtaolab.org/images/logo.png"` |
| 3 | Zero built HTML references headshot.jpg | headshot_refs=0 |
| 4 | `bash scripts/ci-smoke.sh _site` | `PASS: sitemap=11, anchor ok, feed valid, no vendor` (all 4 D-08 assertions unchanged and green) |
| 5 | Sole committed change is `_config.yml` | `git diff --stat HEAD~1 HEAD` → 1 file, `_config.yml`, +1/-1 |

- **No push:** `origin/main` unchanged at `a22624c`; `git log origin/main..HEAD` contains the fix commit `2e20772` (plus pre-existing unpushed docs commits from before this task — plan/review/verifier docs the orchestrator owns). No `git push` was invoked in any form.
- Working tree clean after commit; no untracked files left behind.

## Verification Evidence

Task 1 verify (verbatim from plan):

```
8:photo: logo.png  # social preview image (og:image / twitter:image), sourced from images/
usage_hits=2
head_html_hits=2
1                      # og:image count in _site/index.html
```

Task 2 verify (verbatim from plan):

```
og:image=12 og:title=12 twitter:image=12 headshot_refs=0
PASS: sitemap=11, anchor ok, feed valid, no vendor
1                      # _config.yml in commit diff
```

Emitted meta on the built home page (`_site/index.html:15,19`):

```html
<meta property="og:image" content="https://zhangtaolab.org/images/logo.png">
<meta name="twitter:image" content="https://zhangtaolab.org/images/logo.png">
```

## Commits

- `2e20772` fix(quick/260819-kvb): point site.photo at existing logo.png so og:image/twitter:image emit

## Deviations from Plan

None — plan executed exactly as written. Both verify blocks were run verbatim and passed on the first attempt; no auto-fix rules (1-3) were triggered and no Rule 4 architectural questions arose.

## Known Stubs

None. The fix is complete; no placeholder content was introduced.

## Threat Flags

None. No new trust-boundary surface: one config value now points at an existing in-repo static file; T-quick-01 (accept) and T-quick-02 (mitigate — no push performed) both resolved as planned.

## Notes for Verification

- The og:image benefit goes live on zhangtaolab.org only after the orchestrator/user pushes (push auto-deploys; executor deliberately did not push).
- Beneficial side effect (per plan): twitter:image activates on the same guard that previously suppressed both tags.
- WR-01 remedy follows the user directive (use existing logo.png), superseding the review's own suggested options of adding headshot.jpg or blanking the value.

## Self-Check: PASSED

- FOUND: `.planning/quick/260819-kvb-fix-wr-01-site-og-image-use-existing-log/260819-kvb-SUMMARY.md`
- FOUND: commit `2e20772` in git log
- FOUND: `images/logo.png` (precondition artifact, untouched)
- `_config.yml` line 8 confirmed: `photo: logo.png`
