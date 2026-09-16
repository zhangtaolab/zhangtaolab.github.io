---
phase: quick-260916-ksu
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - images/models/plantelixseek-banner.png
  - images/models/pdllms-banner.png
  - images/models/plantelixseek-architecture.png
  - images/models/pdllms-architecture.png
  - _data/models.yml
  - _pages/models.md
autonomous: true
requirements: [MODELS-02]
tags: [models, css, images, layout, visual-verification]

estimate:
  tokens: 48000
  raw_tokens: 24000
  tasks: 3
  confidence: low   # 3 comparable quick-task samples (cs1/d6y/dvz); n<5

must_haves:
  truths:
    - "At 1280px viewport every /models/ card renders a .model-banner div spanning the full section-card content width (banner width within 2px of the card content-box width; absolute expectation 1005-1015px per container math), height 260+/-5px, bottom edge ABOVE the h4 title top edge; computed object-fit on banner imgs is cover"
    - "At 375px viewport the same banner keeps full card content width (~283-287px) with height 190+/-5px, still above the title — ONE layout at all widths, no two-column/flip behavior anywhere"
    - "Rendered DOM contains ZERO elements carrying any legacy two-column card class at either width, and _pages/models.md contains no legacy two-column class tokens at all"
    - "Both banner files are byte-identical (cmp) to the staged /tmp/models_imgs sources on disk AND as served from http://127.0.0.1:4000 (HTTP 200); both retired figure files are deleted from the working tree and nothing references them"
    - "scripts/validate.sh exits 0 and scripts/ci-smoke.sh _site prints PASS with sitemap=11"
    - "Content change set is EXACTLY 6 paths (2 added banners, 2 deleted figures, _data/models.yml, _pages/models.md) and nothing else outside .planning/"
  artifacts:
    - images/models/plantelixseek-banner.png   # new, byte-identical copy of /tmp/models_imgs/hs-banner.png
    - images/models/pdllms-banner.png          # new, byte-identical copy of /tmp/models_imgs/pd-banner.png
    - _data/models.yml                         # image/image_alt repointed to banners on both entries + schema comment wording
    - _pages/models.md                         # card loop restructured + page-local style block replaced
  key_links:
    - "_data/models.yml image keys -> /images/models/*-banner.png -> models.md relative_url rendering -> served URL 200 + cmp identity (proves the whole chain)"
    - "page-local .model-banner rules -> measured geometry at 1280px and 375px (getBoundingClientRect evidence, never HTML grep)"
---

<objective>
Restructure the /models/ cards to the user's approved mockup: a full-width composed banner image at the top of each card with text content below — ONE layout for all viewport widths, replacing the two-column side-thumbnail layout and its responsive flip.

Purpose: the two-column card layout went through two rounds of visual fixes (natural aspect ratio, crop selection); the user has now composed dedicated banner images (ffmpeg hstack) and visually approved them for a simpler full-width-top layout.
Output: 6 git content paths (2 banner images added byte-identical, 2 superseded figures deleted, models.yml repointed, models.md restructured), rendered-geometry proof at 1280px and 375px, one local commit.
</objective>

<execution_context>
@~/.claude/gsd-core/workflows/execute-plan.md
@~/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@_pages/models.md
@_data/models.yml
@assets/css/custom.scss
@.planning/quick/260916-dvz-models-card-figures-round-2-keep-planthe/260916-dvz-SUMMARY.md
</context>

<background>
Ground truth verified at planning time (2026-09-16):

- Staged sources (sips-verified): `/tmp/models_imgs/hs-banner.png` 227933 B, 1414x560 (corpus/phylogeny | architecture stack | AUROC benchmark); `/tmp/models_imgs/pd-banner.png` 27054 B, 980x300 (promoter schematic | architecture comparison | token cloud). Both visually approved by the user.
- `images/models/` currently holds EXACTLY two PNGs (15287 B pdllms figure, 244679 B plantelixseek figure) — both slated for deletion. Repo-wide grep confirms `_data/models.yml` is their ONLY referencer (outside `_site/` and `.planning/`).
- Serve task bysvkf7vb is up: `curl http://127.0.0.1:4000/models/` returns 200. Jekyll 4.4 serve regenerates on edit within ~10s (STATE.md livereload note).
- Global `assets/css/custom.scss` lines 17-70 keep its own copies of the legacy card classes for the sibling tools page. DO NOT touch custom.scss — with the classes gone from this page's markup those rules are simply inert here (the brief mandates this explicitly).
- **Width-gate correction (brief assumption errata):** the brief says banner ~870+/-30px at 1280px, but the container math gives ~1010px: `.site-container` max-width 1100px (`_sass/base/_variables.scss` --container-max) minus 2x24px site padding = 1052px card width, minus 2x20px card padding (1.25rem) + 2x1px border = ~1010px content box. The gated invariant is therefore "banner spans the full card content-box width (within 2px)" with absolute expectation 1005-1015px at 1280, and ~283-287px at 375 (375-48-42). Same precedent as dvz's pixel-estimate errata.
- **Git-path reconciliation:** the brief header says "4 git paths" and its verify line says "exactly 4 content paths", but the mandated change set (2 banner adds + 2 figure deletions + 2 file edits) yields EXACTLY 6 porcelain paths. The gate below enumerates all 6 and asserts nothing else (outside `.planning/`). The d6y round recorded the identical shape as "6 paths". Follow the enumerated change list, not the count in the header.
- **h4 cascade finding (necessitates one extra CSS rule):** the tight title typography (margin-top 0, margin-bottom 0.5rem, font-size 1.05rem) currently comes from a descendant selector on the body wrapper (global custom.scss line 26). Dropping the wrapper orphans the h4 onto browser defaults (1rem, ~1.33em margins) — a visible regression the mockup does not show. The page-local block therefore gains one scoped `.section-card h4` rule carrying the exact same three declarations. This is the single addition beyond the brief's enumerated ADD list; same file, zero gate impact.
- **Featured spacing carry-over:** the old flex wrapper carried `margin-top: var(--space-3)` only when `model.featured` was true. That conditional moves onto the banner div so badge-to-banner spacing is preserved bit-for-bit on the PlantHelixSeek card.
- **No placeholder branch:** the brief's new DOM has a banner conditional with NO else-branch. Future imageless registry entries simply render without a banner (the dashed "Model" placeholder is gone for good). Do not re-add it.
- **Evidence mode (dvz precedent):** screenshots at both widths are the preferred evidence, but the CDN relay may make them non-inspectable; when that happens, DOM getBoundingClientRect geometry is the accepted authoritative evidence. HTML grep is NOT layout evidence.
</background>

<tasks>

<task type="auto">
  <name>Task 1: Stage composed banner images, retire superseded figures</name>
  <files>images/models/plantelixseek-banner.png, images/models/pdllms-banner.png, images/models/plantelixseek-architecture.png, images/models/pdllms-architecture.png</files>
  <precondition>/tmp/models_imgs/hs-banner.png and /tmp/models_imgs/pd-banner.png exist and are non-empty (staged, user-approved composites; /tmp is outside the repo — if missing, halt and report instead of regenerating).</precondition>
  <action>Copy (byte-identical, plain `cp`) /tmp/models_imgs/hs-banner.png to images/models/plantelixseek-banner.png and /tmp/models_imgs/pd-banner.png to images/models/pdllms-banner.png. Then remove the two pre-existing figure PNGs in images/models/ with `git rm --` (they are the directory's only two files before the copies; per the brief they are superseded by the composed banners). Do not touch any other file under images/, and do not re-encode, strip metadata, or "optimize" the banners — the identity contract is byte-identity against the staged sources.</action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io && cmp /tmp/models_imgs/hs-banner.png images/models/plantelixseek-banner.png && cmp /tmp/models_imgs/pd-banner.png images/models/pdllms-banner.png && [ ! -e images/models/plantelixseek-architecture.png ] && [ ! -e images/models/pdllms-architecture.png ] && [ "$(sips -g pixelWidth -g pixelHeight images/models/plantelixseek-banner.png | tail -2 | awk '{print $2}' | paste -sd x -)" = "1414x560" ] && [ "$(sips -g pixelWidth -g pixelHeight images/models/pdllms-banner.png | tail -2 | awk '{print $2}' | paste -sd x -)" = "980x300" ] && echo TASK1-PASS</automated>
  </verify>
  <done>Both banner PNGs exist in images/models/ byte-identical to the staged sources with dimensions 1414x560 and 980x300; both superseded figure files are gone from the working tree; no other image file touched.</done>
</task>

<task type="auto">
  <name>Task 2: Repoint models.yml entries to the banners</name>
  <files>_data/models.yml</files>
  <action>In _data/models.yml make exactly these edits. PlantHelixSeek entry: set image to "/images/models/plantelixseek-banner.png" and image_alt to "PlantHelixSeek: pretraining corpus, model architecture and AUROC benchmark". PDLLMs entry: set image to "/images/models/pdllms-banner.png" and image_alt to "PDLLMs: promoter architecture, model comparison and tokenizer". Also update the header schema comment line for the image field from "absolute site path to the card thumbnail" to "absolute site path to the full-width card banner" so the registry doc matches the new semantics (comment-only, same file). Keep double-quoted values with no embedded quotes (alt-attribute safety), keep every other key of both entries and the entry order untouched.</action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io && [ "$(grep -v '^\s*#' _data/models.yml | grep -c 'plantelixseek-banner.png')" = 1 ] && [ "$(grep -v '^\s*#' _data/models.yml | grep -c 'pdllms-banner.png')" = 1 ] && [ "$(grep -v '^\s*#' _data/models.yml | grep -c 'architecture.png')" = 0 ] && grep -q 'image_alt: "PlantHelixSeek: pretraining corpus, model architecture and AUROC benchmark"' _data/models.yml && grep -q 'image_alt: "PDLLMs: promoter architecture, model comparison and tokenizer"' _data/models.yml && scripts/validate.sh && echo TASK2-PASS</automated>
  </verify>
  <done>Both entries point at the new banner paths with the exact new alt texts, no retired figure path remains anywhere in the file, and the content validator passes.</done>
</task>

<task type="auto">
  <name>Task 3: Restructure models.md to full-width banner cards + verify end-to-end</name>
  <files>_pages/models.md</files>
  <precondition>Serve is up: `curl -sf http://127.0.0.1:4000/models/ -o /dev/null` succeeds (task bysvkf7vb). If it has died, restart `bundle exec jekyll serve` in the background from the repo root and wait for that curl to return 0 before measuring.</precondition>
  <action>Two edits in _pages/models.md; everything else on the page (frontmatter, h1, intro paragraph, More-models card, dnallm callout) stays verbatim.

EDIT 1 — replace the ENTIRE page-local style block (currently lines 11-25) with exactly these rules and nothing else: `.section-card { padding: 1.25rem !important; }` ; `.model-banner { width: 100%; height: 260px; border-radius: 10px; overflow: hidden; border: 1px solid var(--border); margin-bottom: var(--space-3); }` ; `.model-banner img { width: 100%; height: 100%; object-fit: cover; display: block; }` ; `.section-card h4 { margin-top: 0; margin-bottom: 0.5rem; font-size: 1.05rem; }` ; one `@media (max-width: 767px)` block containing only `.model-banner { height: 190px; }` ; and the existing `p, li, .pub-authors { max-width: none !important; }` rule kept verbatim. The h4 rule is the cascade companion documented in background: it preserves the exact prior title typography that the removed descendant selector used to provide.

EDIT 2 — restructure the card loop (currently lines 27-72). New card DOM order inside each section-card div: first the Featured badge conditional exactly as-is; then ONE column-0 single-line conditional rendering the banner when an image exists — a div of class model-banner carrying `style="margin-top: var(--space-3);"` only when `model.featured` is true, containing an img with `src="{{ model.image | relative_url }}"`, `alt="{{ model.image_alt }}"`, `loading="lazy"` — and NO else-branch; then the body content as a BARE sequence directly inside the section-card: the h4 name heading, the tag div, the pub-actions button block, the description paragraph, the specs loop, the tasks line, and the note paragraph, ALL kept byte-identical to their current markup. Delete the old two-column flex wrapper open/close tags, the old body-wrapper open/close tags, and the old trailing thumbnail/placeholder conditional line — after the edit no element or selector on this page carries any legacy card class. Preserve G-1-3 discipline throughout: flattened HTML at column 0, `markdown="0"` wrappers unchanged, no re-indentation of the kept lines.

After the edits, wait for serve regeneration (up to ~10s), then run the full verification battery below and save screenshots of the page at 1280px and 375px as evidence — save them under this task's .planning/quick/260916-ksu-models-cards-full-width-composed-banner-/ directory or /tmp, NEVER into the repo working tree (they would pollute the change-set gate).</action>
  <verify>
    <automated>cd /Users/forrest/GitHub/zhangtaolab.github.io && [ "$(grep -c 'software' _pages/models.md)" = 0 ] && grep -q 'class="model-banner"' _pages/models.md && curl -sf -o /tmp/ksu-hs-served.png http://127.0.0.1:4000/images/models/plantelixseek-banner.png && cmp /tmp/ksu-hs-served.png /tmp/models_imgs/hs-banner.png && curl -sf -o /tmp/ksu-pd-served.png http://127.0.0.1:4000/images/models/pdllms-banner.png && cmp /tmp/ksu-pd-served.png /tmp/models_imgs/pd-banner.png && scripts/validate.sh && scripts/ci-smoke.sh _site && git status --porcelain > /tmp/ksu-porcelain.txt && diff <(grep -v '\.planning' /tmp/ksu-porcelain.txt | awk '{$1=""; sub(/^ /,""); print}' | sort) <(printf '%s\n' _data/models.yml _pages/models.md images/models/pdllms-architecture.png images/models/pdllms-banner.png images/models/plantelixseek-architecture.png images/models/plantelixseek-banner.png | sort) && echo TASK3-SHELL-PASS</automated>
    Browser geometry gates (Playwright at http://127.0.0.1:4000/models/ — screenshots preferred; if not inspectable via relay, these getBoundingClientRect numbers are the authoritative evidence, dvz precedent):
    - Viewport 1280x900: `document.querySelectorAll('.model-banner').length === 2`; for each banner: rect.width within 2px of its section-card content-box width (absolute expectation 1005-1015px), `Math.abs(rect.height - 260) <= 5`, `rect.bottom <= h4Rect.top + 1` with gap `h4Rect.top - rect.bottom` in [0, 24], `getComputedStyle(img).objectFit === 'cover'`, `img.naturalWidth > 0`, and `img.src` ends with the expected `-banner.png` filename (proves the yml-to-render wiring).
    - Featured (PlantHelixSeek) card: the badge element's `rect.bottom <= bannerRect.top` (banner sits below the badge, above the title).
    - Viewport 375x812: banner count still 2; `Math.abs(rect.height - 190) <= 5`; banner still full card content width (~283-287px) and still above the h4.
    - Both widths: `document.querySelectorAll('.software-card, .software-body, .software-thumb, .software-thumb-placeholder').length === 0`.
  </verify>
  <done>Both cards render the composed banner full-width above their titles at 1280px (height 260) and 375px (height 190) with object-fit cover; zero legacy-class elements or tokens remain on the page or in the file; both banner URLs serve 200 and byte-identical to the staged sources; validate.sh and ci-smoke.sh (sitemap=11) pass; `git status` shows exactly the 6 enumerated content paths and nothing else outside .planning/; screenshots at both widths saved.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| none | Static content-only change (images, YAML data, page template). No untrusted input, no new dependencies, no secrets, no runtime code. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-ksu-01 | Tampering | staged /tmp source images copied into the repo | medium | mitigate | Byte-identity gate (`cmp`) enforced twice: on-disk after copy (Task 1) and as-served over HTTP after regeneration (Task 3) — any re-encoding/substitution fails the gate. |
| T-ksu-02 | Information disclosure | banner images + alt text published on the public site | low | accept | Both figures are already-published paper artwork the user explicitly composed and approved for this page; alt texts are static strings with no embedded quotes. |
</threat_model>

<verification>
1. Task 1/2/3 automated gates all green (byte-identity, dimensions, yml repoint, validator).
2. Playwright geometry battery at 1280px and 375px passes with screenshots saved as evidence (DOM geometry authoritative if relay blocks visual inspection).
3. `scripts/validate.sh` exit 0; `scripts/ci-smoke.sh _site` prints `PASS: sitemap=11`.
4. `git status --porcelain` (excluding `.planning`) is exactly the 6 enumerated content paths: 2 added banners, 2 deleted figures, `_data/models.yml`, `_pages/models.md`.
5. Single atomic commit of all 6 content paths at the end of the run (quick-task convention).
</verification>

<success_criteria>
- /models/ cards show the user-approved composed banners full-width at the top with text below, identically at desktop and mobile widths — no two-column layout, no responsive flip, no placeholder.
- Banner bytes in the repo and as served are identical to the staged, visually approved sources; superseded figures removed with no dangling references.
- Validator, smoke test, and the 6-path change-set gate all green; one local commit.
</success_criteria>

<output>
Create `.planning/quick/260916-ksu-models-cards-full-width-composed-banner-/260916-ksu-SUMMARY.md` when done
</output>
