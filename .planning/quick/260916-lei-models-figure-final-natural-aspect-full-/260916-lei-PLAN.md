---
phase: quick-260916-lei
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - _pages/models.md
autonomous: true
requirements: [MODELS-02]
tags: [models, css, layout, natural-aspect, visual-verification]

estimate:
  tokens: 22000
  raw_tokens: 11000
  tasks: 2
  confidence: low   # CSS-only subset of 4 comparable quick-task samples (cs1/d6y/dvz/ksu); n<5

must_haves:
  truths:
    - "At 1280px viewport both /models/ banners render at NATURAL aspect ratio: HelixSeek .model-banner box ~1010x400+/-10 (source 1414x560), PDLLMs ~1010x310+/-10 (source 980x300); aspect drift |(clientH/clientW) / (naturalH/naturalW) - 1| < 1% for both"
    - "At 375px viewport the same banners stay complete and uncropped at natural aspect (~285x113 HelixSeek, ~285x87 PDLLMs, drift < 1%) — pure fluid scaling, no breakpoint rule involved"
    - "Computed object-fit on both banner imgs is fill (CSS initial value, proving the page cover declaration is gone) and computed height resolves in px from height auto — with box aspect == natural aspect, fill is identity, so zero crop is structural, not incidental"
    - "Both banners render ABOVE their h4 titles at both widths; the Featured badge stays above the banner on the HelixSeek card"
    - "scripts/validate.sh exits 0 and scripts/ci-smoke.sh _site prints PASS with sitemap=11"
    - "Working-tree change set is EXACTLY 1 path (_pages/models.md) and nothing else outside .planning/"
  artifacts:
    - _pages/models.md   # page-local style block only: 2 rule edits + 1 media-query deletion; card DOM, _data/models.yml, images, global SCSS all untouched
    - .planning/quick/260916-lei-models-figure-final-natural-aspect-full-/models-1280.png   # screenshot evidence
    - .planning/quick/260916-lei-models-figure-final-natural-aspect-full-/models-375.png    # screenshot evidence
  key_links:
    - "_data/models.yml image keys (untouched) -> images/models/*-banner.png (untouched) -> models.md .model-banner rendering (edited CSS) -> measured natural-aspect geometry at 1280px + 375px (getBoundingClientRect evidence, never HTML grep)"
    - "cascade safety, verified at planning time: grep proves NO .model-banner selector exists in assets/css/custom.scss, _sass/, _includes/, or _layouts/ — deleting the page-local phone breakpoint cannot unmask any global rule, so the dvz round-2 failure mode (hidden global height surfacing after mask removal) is structurally impossible here"
---

<objective>
Final Models figure presentation per the user-approved option "单图完整展示" (single complete figure, zero cropping): switch the /models/ card banners from fixed-height cropped boxes (ksu state) to fluid natural-aspect display.

Purpose: the current fixed 260px/190px boxes with cover-fitting crop the composed banner figures; the user chose complete-figure presentation — every banner renders its full source image at natural aspect on all viewport widths.
Output: exactly 1 changed file (_pages/models.md, page-local style block only), dual-width natural-aspect geometry proof, screenshots, one local commit.
</objective>

<execution_context>
@~/.claude/gsd-core/workflows/execute-plan.md
@~/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@_pages/models.md
@assets/css/custom.scss
</context>

<tasks>

<task type="auto">
  <name>Task 1: Natural-aspect style block — three exact edits, one file</name>
  <files>_pages/models.md</files>
  <action>Edit ONLY the page-local style block of _pages/models.md (current ksu state: lines 11-20). Three changes, nothing else in the file moves:
  1. `.model-banner` rule: replace the fixed 260-pixel height value with `auto`. Keep width, border-radius, overflow, border, and margin-bottom exactly as-is — with a natural-aspect img inside, the overflow clip becomes inert but stays as harmless safety; do NOT remove it.
  2. `.model-banner img` rule: change the height value from `100%` to `auto` and delete the object-fit declaration entirely. The resulting rule declares exactly: width 100%, height auto, display block.
  3. Delete the entire 767-pixel breakpoint media query block that overrides the banner height on phones — the @media line, its inner rule line, and braces (fluid natural scaling needs no breakpoint).
  The `.section-card`, `.section-card h4`, and `p, li, .pub-authors` rules stay byte-identical. Card DOM structure, `_data/models.yml`, `images/models/`, and global SCSS are already correct from ksu and remain untouched. Cascade safety (verified at planning time): no `.model-banner` selector exists anywhere in assets/css/custom.scss, _sass/, _includes/, or _layouts/ — deleting the page-local breakpoint cannot unmask a global rule.</action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io &amp;&amp; \
grep -c 'height: auto' _pages/models.md | grep -qx 2 &amp;&amp; \
! grep -Eq 'height: 260px|height: 190px|object-fit: cover|767px' _pages/models.md &amp;&amp; \
grep -c 'model-banner img { width: 100%; height: auto; display: block; }' _pages/models.md | grep -qx 1 &amp;&amp; \
PORCELAIN="$(git status --porcelain)" &amp;&amp; \
[ "$(printf '%s\n' "$PORCELAIN" | wc -l | tr -d ' ')" = "1" ] &amp;&amp; \
printf '%s\n' "$PORCELAIN" | grep -qx ' M _pages/models.md' &amp;&amp; echo TASK1-GATES-GREEN
# models.md contains zero '#'-prefixed comment lines (verified at planning time), so the unfiltered negative grep cannot trip on prose/comments.
# PORCELAIN is captured once: if git itself fails, the assignment's exit status breaks the &amp;&amp; chain (fail-safe, not swallowed).</automated>
  </verify>
  <done>Style block shows height auto on both banner rules with no object-fit declaration and no phone breakpoint; the positive/negative grep gates are green; git porcelain reports exactly one modified path (_pages/models.md).</done>
</task>

<task type="auto">
  <name>Task 2: Dual-width natural-aspect geometry proof + regression gates</name>
  <files>.planning/quick/260916-lei-models-figure-final-natural-aspect-full-/models-1280.png, .planning/quick/260916-lei-models-figure-final-natural-aspect-full-/models-375.png</files>
  <action>The serve task bysvkf7vb is already running at http://127.0.0.1:4000/models/ (planning-time probe returned 200). After Task 1's edit, wait for Jekyll watch regeneration — poll `_site/models/index.html` until its style block contains `height: auto` (STATE-documented probe latency 10s or less; cap at 30s), then hard-reload with cache bypass before measuring.

  Playwright at viewport 1280x800 on http://127.0.0.1:4000/models/ — for both cards (card 1 = HelixSeek featured, card 2 = PDLLMs) measure clientWidth/clientHeight of each `.model-banner` and its `img`, `img.naturalWidth/naturalHeight`, `getComputedStyle(img).objectFit` and `.height`, plus the h4 and Featured badge rects. Assert, printing one numbered PASS/FAIL line per assertion (~20 assertions total):
  - HelixSeek: naturalWidth 1414 / naturalHeight 560 (proves yml-to-render chain intact); banner clientWidth 1000-1012; clientHeight 390-410 (nominal 1010x400); drift |(clientH/clientW)/(560/1414) - 1| under 0.01.
  - PDLLMs: naturalWidth 980 / naturalHeight 300; clientHeight 300-320 (nominal 1010x310); drift |(clientH/clientW)/(300/980) - 1| under 0.01.
  - Zero-crop proof, both imgs: computed objectFit is exactly 'fill' (the CSS initial value — proves the page cover declaration is gone; box aspect equals natural aspect, so fill is identity and nothing is cropped); computed height resolves to a px number equal to the banner clientHeight (proves the auto-height chain, not a percentage).
  - Ordering: banner rect.bottom is at or above h4 rect.top on both cards; Featured badge rect.bottom is at or above banner rect.top on card 1.

  Repeat at viewport 375x667 (reload at the new viewport): HelixSeek banner width 280-290, height 108-118 (nominal 285x113); PDLLMs height 82-92 (nominal 285x87); drift under 0.01 both; banner still above h4; badge still above banner.

  Capture full-page screenshots at both widths into .planning/quick/260916-lei-models-figure-final-natural-aspect-full-/ as models-1280.png and models-375.png for direct visual inspection (ksu precedent: local serve screenshots were directly inspectable, no CDN relay).

  Then regression and change-set gates: `scripts/validate.sh` exits 0; `scripts/ci-smoke.sh _site` prints PASS with sitemap=11; `git status --porcelain` shows exactly one line, ' M _pages/models.md' (screenshots live under .planning/, outside the content change set).</action>
  <verify>
    <automated>Playwright DOM-geometry script over http://127.0.0.1:4000/models/ at 1280x800 and 375x667 prints a numbered PASS summary with zero FAIL (natural size, box width, box height, aspect drift under 1%, objectFit fill, resolved px height, banner-above-title, badge-above-banner, per card per width); then scripts/validate.sh exit 0; scripts/ci-smoke.sh _site prints PASS sitemap=11; git status --porcelain | wc -l == 1.</automated>
  </verify>
  <done>Both banners render complete figures at natural aspect with under-1% drift at 1280 and 375, computed objectFit fill, banners above titles, badge above banner; screenshots saved; validate.sh and ci-smoke green with sitemap=11; working tree touches exactly one content path (_pages/models.md).</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| none | Static CSS presentation change to one page-local style block; no user input, no new packages, no external services, no auth surface |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-lei-01 | Tampering | rendered DOM measured at 127.0.0.1:4000 | low | accept | Local single-maintainer dev server; measurement endpoint is read-only and gates on git porcelain for change-set integrity |
</threat_model>

<verification>
- Task 1 grep gates prove the three edits landed and no fixed-height/cover/breakpoint residue remains (file has zero comment lines, so unfiltered greps are sound).
- Task 2 DOM geometry at 1280px and 375px is the authoritative zero-crop evidence (aspect drift under 1%, computed objectFit fill, px-resolved auto height, ordering) — HTML grep cannot prove presentation.
- Regression: scripts/validate.sh exit 0; scripts/ci-smoke.sh _site PASS with sitemap=11.
- Change set: git status --porcelain shows exactly one path (_pages/models.md); one local commit.
</verification>

<success_criteria>
- /models/ banners display the complete single figure (HelixSeek 1414x560, PDLLMs 980x300 sources) at natural aspect on desktop and mobile, above their titles, with zero cropping — drift under 1% at both 1280px and 375px.
- Exactly 1 file changed, 1 commit; validate.sh + ci-smoke green (sitemap=11); screenshots captured as visual evidence.
</success_criteria>

<output>
Create `.planning/quick/260916-lei-models-figure-final-natural-aspect-full-/260916-lei-SUMMARY.md` when done
</output>
