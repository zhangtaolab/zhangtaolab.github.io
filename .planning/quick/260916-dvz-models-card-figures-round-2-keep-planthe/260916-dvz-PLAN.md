---
phase: quick-260916-dvz
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - images/models/pdllms-architecture.png
  - _data/models.yml
  - _pages/models.md
autonomous: true
requirements: [MODELS-02]
tags: [models, images, css, responsive, visual-verification]

estimate:
  tokens: 30000
  raw_tokens: 15000
  tasks: 2
  confidence: low   # 2 comparable quick-task samples (cs1, d6y); derived from sample count

must_haves:
  truths:
    - "Desktop 1280px: each /models/ card's right thumb column shows the image at its NATURAL aspect ratio (HelixSeek portrait ~401px tall, PDLLMs landscape strip ~107px tall at 244px content width) — thumb box hugs the image (box height minus img height <= 22px, no filler/letterbox) and is NOT stretched to body height"
    - "Mobile 375px: thumb block renders ABOVE the body text, horizontally centered (side-margin delta < 8px), width <= 300px, natural height (no fixed 200px height on .software-thumb)"
    - "images/models/pdllms-architecture.png is byte-identical to /tmp/models_imgs/pdllms-topA-raw.png (cmp); images/models/plantelixseek-architecture.png is byte-identical to git HEAD (untouched)"
    - "Rendered DOM contains zero .software-thumb-placeholder elements at both widths"
    - "scripts/validate.sh PASS and bundle exec jekyll build + scripts/ci-smoke.sh _site PASS with sitemap=11"
    - "Content-scoped git change set is exactly 3 paths, all M (no other file touched)"
  artifacts:
    - images/models/pdllms-architecture.png   # replaced content, same filename
    - _data/models.yml                        # PDLLMs image_alt only
    - _pages/models.md                        # page-local <style> block only
  key_links:
    - "_data/models.yml PDLLMs image key (unchanged path /images/models/pdllms-architecture.png) -> live URL http://127.0.0.1:4000/images/models/pdllms-architecture.png returns 200 and is byte-identical to the staged crop after serve regeneration"
    - "_pages/models.md style-block rules -> rendered geometry at 1280px and 375px (proven via getBoundingClientRect, not HTML grep)"
---

<objective>
Round-2 fix of the /models/ card figures per user visual review: (1) swap the PDLLMs card image to the visually approved landscape top-panel-A crop (core promoter + terminator architecture schematics), (2) keep PlantHelixSeek on its already-approved portrait architecture diagram UNTOUCHED, (3) rework the card thumbnail layout to natural aspect ratio so the portrait figure is no longer letterboxed inside a stretched fixed-height box and stops eating card space.

Purpose: the previous contain-in-stretched-box layout wasted vertical space (portrait figure letterboxed in a body-height column) and the PDLLMs figure choice needed revision; the user explicitly specified the PlantHelixSeek architecture diagram stays.
Output: 3 modified git paths (image bytes, one YAML alt line, page-local CSS), one local commit, rendered-geometry proof at 1280px and 375px.
</objective>

<execution_context>
@~/.claude/gsd-core/workflows/execute-plan.md
@~/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@_pages/models.md
@_data/models.yml
@.planning/quick/260916-d6y-fix-models-page-card-image-layout-mobile/260916-d6y-SUMMARY.md
</context>

<background>
Ground truth verified at planning time (2026-09-16):

- Staged crop `/tmp/models_imgs/pdllms-topA-raw.png`: PNG 660x290, 15287 B, 8-bit RGBA. NOTE: the task brief says "660x287" — that dimension note is stale; the identity contract is byte-identity (`cmp`) against the staged file, and geometry follows the actual file (aspect h/w = 290/660 = 0.4394).
- Current `images/models/plantelixseek-architecture.png`: PNG 790x1300 (aspect h/w = 1.6456), byte-identical to git HEAD — stays UNTOUCHED.
- Serve task bysvkf7vb is live: http://127.0.0.1:4000/models/ returns 200 (Jekyll livereload regenerates on file change; d6y saw first-poll pickup).
- Probed verification toolchain from quick-260916-d6y: Playwright CLI v1.63.0 with cached Chromium for screenshots (`--viewport-size=1280,900 --full-page` and `375,700`), plus a Node geometry script using Playwright's `getBoundingClientRect` and computed styles (d6y's was `/tmp/d6y-geometry-check.js`). A Playwright MCP browser session is open at the models URL; reuse whichever tooling is available. If a screenshot cannot be visually inspected through the file-read path (d6y hit a CDN relay), DOM geometry is the sanctioned visual-equivalent evidence — HTML grep is NOT evidence.
- Derived geometry targets (from source dims + CSS: thumb outer width 260, padding 8, border 1 → content width 244; box = img + 18):
  - Desktop 1280px: HelixSeek img ~= 244x401, box ~= 419; PDLLMs img ~= 244x107, box ~= 125.
  - Mobile 375px (card inner width ~283-285): HelixSeek img ~= 465-470 tall, box ~= 484; PDLLMs img ~= 124-126, box ~= 143.
</background>

<tasks>

<task type="auto">
  <name>Task 1: Replace PDLLMs image, update alt text, natural-aspect style block</name>
  <files>images/models/pdllms-architecture.png, _data/models.yml, _pages/models.md</files>
  <precondition>/tmp/models_imgs/pdllms-topA-raw.png exists (15287 B, 660x290 PNG) and http://127.0.0.1:4000/models/ responds 200 — halt and report if either fails.</precondition>
  <action>
    Exactly 3 git paths change. Do NOT touch `images/models/plantelixseek-architecture.png` (already the user-approved architecture diagram), the PlantHelixSeek YAML entry, `_sass/`, or `assets/css/`.

    1. Image replace — plain byte-identical copy, never regenerate or re-encode (the crop was visually approved): copy `/tmp/models_imgs/pdllms-topA-raw.png` over `images/models/pdllms-architecture.png` (same filename, new content; the file is git-tracked so status shows M, not ??).

    2. `_data/models.yml` — PDLLMs entry ONLY: change the `image_alt` value to "Core promoter and terminator architecture analyzed by PDLLMs". Keep double-quoted YAML with no embedded quotes (alt-text attribute safety per cs1 decision). The `image` key is UNCHANGED (same path, new bytes). PlantHelixSeek entry untouched.

    3. `_pages/models.md` — page-local `<style>` block ONLY, three scoped edits (current block is lines 11-24; keep the G-1-3 column-0 flattened shape):
       a. Base `.software-card` rule: change the cross-axis alignment keyword from stretch to flex-start, so the side thumb column no longer stretches to the body's height.
       b. `.software-thumb img` rule: replace the percentage height and the contain-fit declaration with `height: auto` (keep `width: 100%` and `display: block`). Image height then follows its natural aspect ratio — letterboxing becomes impossible.
       c. 767px media query: SPLIT the combined thumb/placeholder rule into two separate rules. The `.software-thumb` mobile rule becomes: `width: 100%; max-width: 300px; min-width: 0; margin: 0 auto var(--space-3);` — a centered compact block; DELETE the fixed 200px height from the thumb (no height declaration at all). The `.software-thumb-placeholder` mobile rule keeps its own sizing (`width: 100%; min-width: 0;` plus its fixed 200px height — no card uses it, kept as documented fallback). Keep `flex-direction: column-reverse` and the mobile `.software-card` rule exactly as-is (image above text without reordering markup, per d6y decision). `var(--space-3)` is an existing design-system token already used inline in this file.

    4. Commit exactly the 3 paths in one commit: `fix(quick/models): pdllms top-A architecture crop + natural-aspect card thumbnails`.
  </action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io && cmp /tmp/models_imgs/pdllms-topA-raw.png images/models/pdllms-architecture.png && git show HEAD:images/models/plantelixseek-architecture.png > /tmp/dvz-helix-head.png && cmp /tmp/dvz-helix-head.png images/models/plantelixseek-architecture.png && [ "$(grep -c 'Core promoter and terminator architecture analyzed by PDLLMs' _data/models.yml)" = 1 ] && [ "$(grep -c 'plantelixseek-architecture' _data/models.yml)" = 1 ] && [ "$(grep -v '^\s*#' _pages/models.md | grep -c 'align-items: stretch')" = 0 ] && [ "$(grep -v '^\s*#' _pages/models.md | grep -c 'object-fit')" = 0 ] && [ "$(grep -v '^\s*#' _pages/models.md | grep -cF 'height: 100%')" = 0 ] && [ "$(grep -v '^\s*#' _pages/models.md | grep -cF 'height: 200px')" = 1 ] && [ "$(grep -cF 'max-width: 300px' _pages/models.md)" = 1 ] && [ "$(grep -cF 'margin: 0 auto var(--space-3)' _pages/models.md)" = 1 ] && [ "$(grep -c 'flex-direction: column-reverse' _pages/models.md)" = 1 ] && [ "$(grep -cF '.software-thumb, .software-thumb-placeholder' _pages/models.md)" = 0 ] && git show --stat HEAD > /tmp/dvz-commit-stat.txt && grep -E '3 files changed' /tmp/dvz-commit-stat.txt && git status --porcelain > /tmp/dvz-status.txt && [ -z "$(grep -v '^?? \.planning/' /tmp/dvz-status.txt)" ]</automated>
  </verify>
  <done>
    All three edits in place and committed: staged crop byte-identical in repo; PlantHelixSeek image byte-identical to HEAD; new alt text exactly once in models.yml; style block has no stretch alignment, no fit-mode declaration, no percentage img height, exactly one fixed-200px height (placeholder rule only), the 300px-capped centered mobile thumb rule, column-reverse retained, combined selector gone; exactly 3 files changed vs HEAD.
  </done>
</task>

<task type="auto">
  <name>Task 2: Rendered-geometry proof + machine gates + change-set audit</name>
  <files></files>
  <action>
    Read-only verification (evidence artifacts go to /tmp only). HTML grep is NOT acceptance evidence for layout — geometry is.

    1. Serve freshness: `curl -s http://127.0.0.1:4000/models/ | grep -c 'Core promoter and terminator architecture analyzed by PDLLMs'` must be 1 (confirms livereload picked up models.yml). Then `curl -s -o /tmp/dvz-pdllms-live.png -w '%{http_code}' http://127.0.0.1:4000/images/models/pdllms-architecture.png` must be 200 and `cmp /tmp/dvz-pdllms-live.png /tmp/models_imgs/pdllms-topA-raw.png` must pass; same byte check for the HelixSeek URL against `git show HEAD:images/models/plantelixseek-architecture.png`. If serve has NOT regenerated after the edits, wait one poll cycle; regeneration is required before geometry.

    2. Screenshots at 1280x900 and 375x700 (full-page, Playwright CLI v1.63.0 cached Chromium per d6y; or the open Playwright MCP session). Visually inspect if the file-read path renders them; if not (d6y CDN-relay precedent), DOM geometry below is the sanctioned equivalent.

    3. DOM geometry via Playwright JS (model on d6y's script; assert per card, both viewport widths) — write a fresh /tmp script, do not assume /tmp/d6y-geometry-check.js still exists:
       - 1280px BOTH cards: thumb is a right column (`thumbRect.right > bodyRect.right`); thumb outer width 255-265; img rendered h/w ratio within 3% of natural (HelixSeek 1300/790=1.6456 → img height 391-411; PDLLMs 290/660=0.4394 → img height 100-114); anti-letterbox hug: `thumbRect.height - imgRect.height <= 22`; HelixSeek thumb box height 395-430 and strictly LESS than its body height (not stretched); PDLLMs thumb box height 100-140; computed style of img has no fixed height applied from the thumb rule; `.software-thumb-placeholder` count 0.
       - 375px BOTH cards: `thumbRect.top < bodyRect.top` (image above text); centered: `|(thumbRect.left - cardRect.left) - (cardRect.right - thumbRect.right)| < 8`; thumb width <= 300; img h/w ratio within 3% of natural (HelixSeek img height ~460-480; PDLLMs ~119-131); hug rule `thumbRect.height - imgRect.height <= 22` and HelixSeek thumb box height NOT within 200 +/- 5 (fixed height gone); placeholder count 0.
       Print each measured value and a final verdict line.

    4. Machine gates: `scripts/validate.sh` (expect PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12); then `bundle exec jekyll build && scripts/ci-smoke.sh _site` (expect PASS sitemap=11; this also guarantees _site freshness independent of the serve task).

    5. Change-set audit (d6y deviation precedent — content-scoped): `git status --porcelain | grep -v '^?? \.planning/'` must list EXACTLY 3 paths after the Task 1 commit (working tree clean of content changes; the commit itself shows `git show --stat HEAD` = 3 files). Confirm zero changed paths under `_sass/` and `assets/css/`.
  </action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io && scripts/validate.sh && bundle exec jekyll build && scripts/ci-smoke.sh _site && node /tmp/dvz-geometry-check.js | grep -c 'PASS' </automated>
  </verify>
  <done>
    Geometry verdict all-PASS at both widths with printed measurements inside the stated ranges (natural aspect, hug not letterbox, mobile centered/compact/above-text, placeholder 0); both image URLs 200 and byte-identical to their sources; validate.sh PASS; ci-smoke PASS sitemap=11; content-scoped change set exactly 3 paths; nothing pushed (DEPLOY_ENABLED is live on main — push timing belongs to the user).
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| local /tmp staged file -> repo asset | binary content entering the deployed site |
| _data/models.yml values -> rendered HTML | YAML string interpolated into an HTML attribute (alt) |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-dvz-01 | Tampering | images/models/pdllms-architecture.png | medium | mitigate | byte-identity `cmp` against the visually approved staged crop, repo copy and served URL both; HelixSeek asset `cmp` against git HEAD proves untouched |
| T-dvz-02 | XSS (Injection) | _data/models.yml image_alt -> alt attribute | low | mitigate | new alt string is plain ASCII with no quotes/HTML metacharacters, double-quoted YAML; render check confirms single clean occurrence |
| T-dvz-03 | Supply chain | none — no package installs in this task | low | accept | no new dependencies; Playwright uses the already-cached v1.63.0 Chromium from d6y |
</threat_model>

<verification>
- Task 1 automated gate: all cmp/grep/git-stat assertions in one chain (see task verify).
- Task 2: rendered geometry all-PASS at 1280px and 375px with printed measurements; validate.sh PASS; build + ci-smoke _site PASS sitemap=11; live image URLs 200 + byte-identical; content-scoped change set exactly 3 paths (M images/models/pdllms-architecture.png, M _data/models.yml, M _pages/models.md).
</verification>

<success_criteria>
- PDLLMs card shows the approved landscape core-promoter/terminator architecture crop; HelixSeek card still shows its approved portrait architecture diagram, byte-untouched.
- Desktop: natural-aspect right-column thumbnails, no letterbox filler, no stretch to body height.
- Mobile: centered <= 300px image block above the text at natural height.
- All machine gates green; exactly 3 paths, 1 local commit, nothing pushed.
</success_criteria>

<output>
Create `.planning/quick/260916-dvz-models-card-figures-round-2-keep-planthe/260916-dvz-SUMMARY.md` when done
</output>
