---
phase: 01-local-dev-environment
plan: "03"
subsystem: ui
tags: [jekyll, kramdown, liquid, layout, gap-closure]

# Dependency graph
requires:
  - phase: 01-local-dev-environment/02
    provides: markdown="0" passthrough escape-immunity pattern (about/home) + reference-aligned copy for research/software
provides:
  - research/software pages relaid out to reference DOM structure (flat cards, real badge elements, zero kramdown escapes)
  - PDLLMs dead links (about x2, home x1) repointed to the existing Plant_DNA_LLMs repo
  - upgraded acceptance assertions (any-tag escape grep + DOM flatness python gate) closing the "open-tag-only" escape path
affects: [verify-work UAT test 4 (visual confirmation), phase-01 gap reconcile]

# Actuals (#2632) — pairs with the plan's estimate (35000 tokens, confidence low).
actuals:
  tokens: 6300    # chars/4 over the realized _pages/ diff (88+/85- lines across 4 files)
  tasks: 4
  commits: 4

# Tech tracking
tech-stack:
  added: []       # no new libraries, plugins, scripts, or images
  patterns:
    - "markdown=\"0\" passthrough container generalized from single cards to whole grids (research-grid) and section stacks"

key-files:
  created: []
  modified:
    - _pages/research.md
    - _pages/software.md
    - _pages/about.md
    - _pages/home.md

key-decisions:
  - "Research grid wrapped as ONE markdown=\"0\" passthrough container (cards pass through raw); software uses per-card markdown=\"0\" wrappers since h2 headings must stay markdown-parsed between cards"
  - "Inline card styles dropped in research; styling supplied by in-page main-prefixed !important override block copied verbatim from ref-research.html lines 50-61 (CSS lives in the page, _sass/assets untouched per prohibition)"
  - "Software style block replaced wholesale with ref-software.html lines 51-62 verbatim — this also switches var(--border-color) to var(--border) (2 rules) beyond the margin-bottom:0 delta the planner noted; main.css is byte-identical to the reference's and defines neither --border nor uses it, so rendering matches the reference exactly"
  - "Empty core-badge divs on cards 2-8 are the reference site's own top-alignment spacers (min-height 22px), not data stubs — required by must_haves"

patterns-established:
  - "Grid-level passthrough: single markdown=\"0\" wrapper around an entire card grid when no markdown content must remain parsed inside"
  - "Escape gate upgraded: grep '&lt;' (any tag) + python html.parser depth/parent assertions replace the open-tag-only grep that let G-1-5 escape"

requirements-completed: [ENV-01]

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "research + software pages relaid out per reference snapshots: 0 escaped tags, flat non-nested cards, real Core Focus/Core Toolkit badge elements, visible copy unchanged (G-1-5)"
    requirement: ENV-01
    verification:
      - kind: integration
        ref: "bundle exec jekyll build && grep -c '&lt;' _site/research/index.html _site/software/index.html (0/0)"
        status: pass
      - kind: integration
        ref: "python3 html.parser flatness gate: research-card x8 -> (0,'research-grid'); section-card x8 -> (0,'fade-in-section'); software-card x8 -> (1,'section-card') => DOM-FLAT-OK"
        status: pass
      - kind: integration
        ref: "strip-tag normalized text diff vs 30a9e84 baseline (style element excluded) => RESEARCH-GATE-PASS / SOFTWARE-GATE-PASS"
        status: pass
      - kind: e2e
        ref: "jekyll serve smoke: / /about/ /research/ /software/ all :200 on 127.0.0.1:4000, server stopped after"
        status: pass
    human_judgment: true
    rationale: "Machine gates prove structure/escapes/copy but not final visual parity with the reference site; plan designates /gsd-verify-work (UAT test 4 side-by-side) as the final visual closure step"
  - id: D2
    description: "PDLLMs dead links fixed: about x2 + home x1 hrefs now target https://github.com/zhangtaolab/Plant_DNA_LLMs, link text unchanged (G-1-6)"
    requirement: ENV-01
    verification:
      - kind: integration
        ref: "grep -rn 'zhangtaolab/PDLLMs' _pages/ => 0; _site/about 'Plant_DNA_LLMs' x2, _site/index.html x2, 'Get PDLLMs on GitHub' x1"
        status: pass
    human_judgment: false

# Metrics
duration: 8min
completed: 2026-08-18
status: complete
---

# Phase 1 Plan 03: research/software relayout (G-1-5) + PDLLMs dead-link fix (G-1-6) Summary

**Research/software pages rebuilt to reference DOM via markdown="0" passthrough containers (8 flat cards each, real badge elements, zero kramdown escapes, copy byte-identical) and 3 dead PDLLMs hrefs repointed to the real repo**

## Performance

- **Duration:** 8 min
- **Started:** 2026-08-18T05:11:53Z
- **Completed:** 2026-08-18T05:20:07Z
- **Tasks:** 4
- **Files modified:** 4 (+ this SUMMARY)

## G-1-5 / G-1-6 Closure Evidence (all values measured this run)

**G-1-5 (major, UAT test 4) — relayout:**

| Assertion | Command (essence) | Result |
|---|---|---|
| Escapes, research | `grep -c '&lt;' _site/research/index.html` | **0** (was 1) |
| Escapes, software | `grep -c '&lt;' _site/software/index.html` | **0** (was 9) |
| Escapes, site-wide | `grep -rl '&lt;' _site --include='*.html' \| wc -l` | **0 files** |
| Cards | research-card / section-card / software-card counts | **8 / 8 / 8** |
| Badges | `core-badge` count / filled `Core Focus` | **8 / 1** |
| Placeholders | `software-thumb-placeholder">Screenshot</div>` / `Core Toolkit</div>` | **7 / 1** (real elements) |
| Grid wrappers removed | `grep -c 'software-grid' _pages/software.md` | **0** |
| DOM flatness | python html.parser depth/parent gate | **DOM-FLAT-OK**: research-card x8 all (depth 0, parent `research-grid`); section-card x8 all (0, `fade-in-section`); software-card x8 all (1, `section-card`) — no nesting shell (the 2900px card0 structure is structurally impossible now) |
| Copy preservation | strip-tag normalized diff vs `30a9e84` | **empty** both pages (RESEARCH-GATE-PASS / SOFTWARE-GATE-PASS) |
| Recurrence guard | `grep -En '^ {4,}.*<'` on both sources | **0 lines** |

**G-1-6 (minor, UAT test 5, user decision b) — dead links:**

| Assertion | Result |
|---|---|
| `grep -rn 'zhangtaolab/PDLLMs' _pages/` | **0** |
| `Plant_DNA_LLMs` in `_site/about/index.html` | **2** (both fixed hrefs) |
| `Plant_DNA_LLMs` in `_site/index.html` | **2** (home.md line 24 fix + pre-existing callout link) |
| `Get PDLLMs on GitHub` in `_site/about/index.html` | **1** (link text unchanged) |

**Integration gate (Task 4):** fresh `rm -rf _site .jekyll-cache && bundle exec jekyll build` → exit 0, 0 Unknown-tag/Liquid errors. Serve smoke on 127.0.0.1:4000 (default binding, no `--host 0.0.0.0`): readiness 200, then `/`:200 `/about/`:200 `/research/`:200 `/software/`:200; server stopped via recorded PID only (41165), post-check `SERVE-STOPPED`.

**Final visual closure:** machine gates above prove structure, escapes, and copy; 最终视觉一致性由 `/gsd-verify-work` 复跑 UAT 测试 4（与参考站并排目检）确认 —— gap 状态由其 reconcile 为 resolved。

## Accomplishments
- research page: single `markdown="0"` grid passthrough + reference class structure (`research-card core` first card, 8 core-badges, img-wrap) + in-page main-prefixed override block (ref lines 50-61 verbatim); all inline card styles removed
- software page: 4 undefined software-grid wrappers removed, 8 section-cards + closing callout individually passthrough-wrapped, style block replaced with ref lines 51-62 verbatim
- 3 dead PDLLMs hrefs (about 43/48, home 24) repointed to the real repo; link text untouched
- acceptance upgraded: any-tag escape grep + DOM depth/parent assertions now block the "closing-tag escape" path that defeated 1-02's open-tag-only grep

## Task Commits

1. **Task 1: research 页参考站重排** - `8af4a82` (fix)
2. **Task 2: software 页参考站重排** - `ca3e7c6` (fix)
3. **Task 3: PDLLMs 死链修正** - `6055212` (fix)
4. **Task 4: 集成终验 + SUMMARY** - this commit (test)

## Files Created/Modified
- `_pages/research.md` - grid passthrough + reference card structure + override style block
- `_pages/software.md` - flat section-cards, per-card passthrough, reference style block
- `_pages/about.md` - 2 href fixes
- `_pages/home.md` - 1 href fix

## Decisions Made
- See key-decisions in frontmatter; all structural choices follow the plan's locked decisions (user 2026-08-18 test 4 relayout + test 5 option b). Empty core-badge divs on cards 2-8 are the reference's own alignment spacers, not stubs.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Verify commands executed in the worktree, not the main repo path**
- **Found during:** Task 1
- **Issue:** Plan verify blocks hardcode `cd /Users/forrest/Playground/zhangtaolab-jekyll` (main checkout); running builds there would pollute the main repo's `_site/` and test the wrong sources
- **Fix:** All builds/greps/diffs/serve ran from the worktree root (same git history, so `git show 30a9e84:...` baseline still resolved)
- **Files modified:** none
- **Verification:** all assertions green in worktree; worktree isolation preserved
- **Committed in:** n/a (execution-context adjustment)

**2. [Rule 1 - Bug] Software text-preservation gate included the style block the plan itself replaces**
- **Found during:** Task 2
- **Issue:** In software.md the `<style>` block sits after the h1, so the plan's `sed -n '/<h1/,$p'` extraction captures CSS text; the plan simultaneously mandates replacing that style block wholesale → normalized diff can never be empty as written (observed: `margin-bottom: 0` + `var(--border)` x2 deltas, all inside `<style>`)
- **Fix:** Excluded `<style>...</style>` from both old/new sides before tag-stripping (research page unaffected — its style block precedes the h1); protects exactly the "visible copy" the truth names
- **Files modified:** none (verification command only)
- **Verification:** diff empty → SOFTWARE-GATE-PASS; visible copy byte-identical
- **Committed in:** ca3e7c6 (verified pre-commit)

**3. [Rule 1 - Bug] DOM assertion for software-card was unsatisfiable as written**
- **Found during:** Task 4
- **Issue:** Plan asserts `d==0 and p=='section-card'` for software-card, but the script's `depth` counts target-class ancestors — the parent section-card is itself a target, so the correct flat structure yields d==1 for every software-card (verified empirically: 8 rows, all `(1,'section-card')`; d==0 is reachable only if software-card had NO section-card parent, i.e. the wrong structure)
- **Fix:** Assertion corrected to `d==1 and p=='section-card'` — exactly encodes "direct child of a section-card with no further target nesting" (nested cards would yield d>=2 or a non-section-card parent)
- **Files modified:** none (verification command only)
- **Verification:** DOM-FLAT-OK; research and section-card assertions ran plan-verbatim and passed unchanged
- **Committed in:** this commit (Task 4)

---

**Total deviations:** 3 auto-fixed (1 blocking-path, 2 verification-command bugs in plan)
**Impact on plan:** No scope creep; all three preserve the plan's stated truths. The two verification fixes tighten/repair the gate's expression, not its intent — both empirical checks proved the intended invariant holds.

## Issues Encountered
- None beyond the deviations above. Known harmless `assets/main.css` vs `main.scss` destination-conflict warning appeared in serve log (pre-existing, documented in STATE.md, no acceptance impact).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All Phase 1 machine gates green; G-1-5/G-1-6 machine closure evidence recorded above
- Remaining: `/gsd-verify-work` re-run of UAT test 4 for final side-by-side visual confirmation (then reconcile both gaps to resolved)

## Self-Check: PASSED

- All 5 artifacts exist on disk (4 pages + this SUMMARY)
- All 4 task commits present: 8af4a82 / ca3e7c6 / 6055212 / abb92dd
- `git status --porcelain` empty; `_site/` gitignored (not tracked)

---
*Phase: 01-local-dev-environment*
*Completed: 2026-08-18*
