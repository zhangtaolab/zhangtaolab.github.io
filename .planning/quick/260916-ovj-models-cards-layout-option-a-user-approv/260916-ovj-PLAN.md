---
phase: quick-260916-ovj
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - _pages/models.md                               # card loop restructure (.model-row/.model-body wrappers) + page-local style block replacement
autonomous: true
requirements: [MODELS-02]
tags: [models, layout, flex-row, option-a, user-approved]

estimate:
  tokens: 18000
  raw_tokens: 9000
  tasks: 1
  confidence: medium   # pure CSS/markup restructure, no binary/data moves; visual-verify chain well rehearsed (ksu/lei/nl1/oh7/ooh)

must_haves:
  truths:
    - "_pages/models.md is the ONLY git path changed outside .planning/ (images/, _data/models.yml byte-untouched — verified by porcelain == 1 content entry and git diff --stat naming exactly one file)"
    - "Card DOM inside {% for model in site.data.models %} reads: section-card (markdown=\"0\") → [featured badge div unchanged] → <div class=\"model-row\"> → .model-banner div (inline featured margin-top REMOVED — .model-row owns the gap now) → <div class=\"model-body\"> wrapping the existing h4/tag/buttons/description/specs/tasks/note sequence BYTE-IDENTICAL → </div></div></div>; all new lines at column 0 (G-1-3)"
    - "Page-local style block contains exactly the option-A rules: .model-row{display:flex;gap:22px;align-items:flex-start;margin-top:var(--space-3)} / .model-banner{flex:0 0 56%;max-width:56%} / .model-banner img{width:100%;height:auto;display:block;border:1px solid var(--border);border-radius:10px} / .model-body{flex:1;min-width:0} / @media(max-width:767px){.model-row{flex-direction:column;gap:var(--space-3)} .model-banner{flex:none;max-width:100%;width:100%}} — old centered full-width .model-banner rules and all height caps GONE; .section-card / .section-card h4 / p,li,.pub-authors rules KEPT"
    - "NO 'Access: pip install dnallm' spec line exists on either card (user rejected) — grep 'Access:' count 0 in the card loop; the trailing dnallm callout with 'pip install dnallm' stays untouched (count 1 in whole file)"
    - "At 1280px viewport: for BOTH cards banner.right <= body.left (image LEFT of text), |banner.width − 0.56×row.width| <= 8px, img aspect drift |(dw/dh)/(nw/nh) − 1| < 1% (natural aspect, zero crop), featured badge bottom <= row top (badge above row)"
    - "At 375px viewport: banner.top < body.top for BOTH cards (stacked, image FIRST), banner width == row width (full-width, ~283px → HelixSeek ≈150 tall / PDLLMs ≈126 tall), aspect drift < 1%"
    - "scripts/validate.sh exits 0 and scripts/ci-smoke.sh _site prints PASS with sitemap=11"
    - "Screenshots at 1280px AND 375px saved in this task directory and DIRECTLY inspected: image left text right at desktop, image above text on mobile, complete figures, badge above row; Kimi bridge session models-page-check reloaded in the user's real browser with DOM measure matching"
    - "ONE atomic commit for _pages/models.md; .planning/ docs left uncommitted for the orchestrator"
  artifacts:
    - _pages/models.md   # option-A flex-row card layout
    - models-1280.png + models-375.png in this task directory (visual evidence)
  key_links:
    - "_data/models.yml image keys (UNTOUCHED) → .model-banner img natural 2372×1255 / 3656×1628 → displayed 56%-column natural-aspect (height:auto) → zero-crop proof at both widths"
    - ".model-row flex+basis 56% → banner.left column and body.right column at ≥768px; @media 767px → column stack with image first — single selector family owns both breakpoints"
---

<objective>
Implement the user-approved layout variant A ("方案 A —— 图左 · 文右") for the /models/ cards: image LEFT (56% flex column) + text RIGHT in a flex row inside each section-card; on mobile (≤767px) the row collapses to an image-above-text stack. The approved preview mockup lives at /tmp/layout-preview.html (served at http://127.0.0.1:8765/layout-preview.html) and is the look-and-feel reference.
</objective>

<execution_context>
@~/.claude/gsd-core/workflows/execute-plan.md
@~/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@_pages/models.md
@_data/models.yml

Preconditions (assert before starting; halt if unmet):
- Serve task bysvkf7vb running: `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/models/` returns 200
- /tmp/layout-preview.html exists (approved mockup reference, 方案 A block)
- Playwright: igv-rust 1.58.2 at /Users/forrest/Playground/igv_Refactoring/igv-rust via NODE_PATH (nl1 precedent — /tmp/pwrun has dangling links; drop the runner script in this task directory, remove after evidence capture)
- Kimi bridge daemon reachable at 127.0.0.1:10086, session "models-page-check" (user's real browser)

Grounding:
- Current template renders: badge → full-width .model-banner (featured gets inline margin-top var(--space-3)) → bare body sequence; style block has natural-aspect full-width banner rules (lei)
- Images are the user's own banners — plantelixseek-figure1.png 2372×1255, pdllms-figure1.png 3656×1628 — DO NOT touch images or _data/models.yml
- No global SCSS defines .model-row/.model-body/.model-banner (grepped — page-local block is the sole owner; /software/ page unaffected)
- Expected desktop geometry: content column ≈988px → banner ≈553px (56%) → HelixSeek ≈553×293, PDLLMs ≈553×246; card height ≈330–420px
- NO "Access: pip install dnallm" spec line exists or may be added (user rejected it in the preview review)
</context>

<tasks>

<task type="auto">
  <name>Task 1: Option-A card layout — .model-row flex wrapper + .model-body, style block swap, dual-width visual verification</name>
  <files>_pages/models.md</files>
  <action>
  ONE file, TWO edit clusters, ONE commit:

  1. STYLE BLOCK (replace the .model-banner rules; keep .section-card / h4 / p,li lines verbatim):
     - DROP: `.model-banner { width: 100%; height: auto; border-radius: 10px; overflow: hidden; border: 1px solid var(--border); margin-bottom: var(--space-3); }` and `.model-banner img { width: 100%; height: auto; display: block; }`
     - ADD (4-space indent matching file; media-query body at 8):
       `.model-row { display: flex; gap: 22px; align-items: flex-start; margin-top: var(--space-3); }`
       `.model-banner { flex: 0 0 56%; max-width: 56%; }`
       `.model-banner img { width: 100%; height: auto; display: block; border: 1px solid var(--border); border-radius: 10px; }`
       `.model-body { flex: 1; min-width: 0; }`
       `@media (max-width: 767px) {` + `.model-row { flex-direction: column; gap: var(--space-3); }` + `.model-banner { flex: none; max-width: 100%; width: 100%; }` + `}`
     - .model-row margin-top replaces the featured cards' inline badge gap — visual parity for the badge→content distance.

  2. CARD LOOP (only inside {% for model in site.data.models %}; everything column 0):
     - After the featured-badge {% endif %}, open `<div class="model-row">`
     - Banner line becomes `{% if model.image %}<div class="model-banner"><img src="{{ model.image | relative_url }}" alt="{{ model.image_alt }}" loading="lazy"></div>{% endif %}` — REMOVE the `{% if model.featured %} style="margin-top: var(--space-3);"{% endif %}` conditional (row margin owns the gap now)
     - After the banner line, open `<div class="model-body">`
     - The existing body sequence (h4 → tag div → pub-actions buttons block → description p → specs → tasks → note) stays BYTE-IDENTICAL inside .model-body
     - Close with `</div>` (model-body) then `</div>` (model-row) immediately before the existing section-card `</div>`
     - Keep markdown="0" on section-card only (inner wrappers follow existing no-markdown-attr pattern)

  3. Poll serve (≤30s) until the rendered /models/ contains class="model-row", then run verification below. Commit: `fix(quick-260916-ovj): models cards layout option A — image left, text right`.
  </action>
  <verify>
  <automated>
  # 1) static shape — file-level gates
  grep -c 'class="model-row"' _pages/models.md           # == 2 rendered? template has 1 occurrence; rendered page curl grep == 2
  grep -En '^ {4,}.*<' _pages/models.md                  # == 0 (G-1-3 column-0 discipline preserved)
  grep -c 'Access:' _pages/models.md                     # == 0 (rejected spec line absent)
  grep -c 'pip install dnallm' _pages/models.md          # == 1 (callout only)
  git diff --stat -- . ':!.planning'                     # exactly _pages/models.md
  git diff --name-only -- images/ _data/models.yml       # EMPTY (byte-untouched proof)

  # 2) rendered geometry — Playwright 1.58.2 via NODE_PATH=/Users/forrest/Playground/igv_Refactoring/igv-rust/node_modules (script in task dir)
  # 1280×800: per card (2 cards): banner.right <= body.left; |banner.width − 0.56×row.width| <= 8; |(dw/dh)/(nw/nh) − 1| < 0.01;
  #           badge.bottom <= row.top (featured card); screenshots → models-1280.png (full page)
  # 375×667: per card: banner.top < body.top; |banner.width − row.width| <= 2; aspect drift < 0.01;
  #           screenshots → models-375.png (full page)
  # both widths: DIRECTLY inspect the PNGs (image left/text right at 1280; image above text at 375; complete figures; badge above row)

  # 3) user's real browser — Kimi bridge 127.0.0.1:10086 session "models-page-check":
  #    reload http://127.0.0.1:4000/models/, DOM-measure banner/body rects (image left of text), screenshot for visual confirmation

  # 4) repo gates + changeset shape
  scripts/validate.sh && scripts/ci-smoke.sh _site && \
  [ "$(git status --porcelain | grep -v '\.planning/' | wc -l | tr -d ' ')" = "1" ] && \
  git status --porcelain | grep -v '\.planning/' | grep -q '_pages/models.md' && echo GATES-OK
  </automated>
  </verify>
  <done>
  - Rendered /models/ has 2 .model-row cards, 0 indented-HTML violations, 0 "Access:" lines, callout intact
  - 1280px: image column left of text column on both cards, banner ≈56% of row ±8px, natural aspect <1% drift, badge above row
  - 375px: image stacked ABOVE text on both cards, full-width banner, natural aspect <1% drift
  - Screenshots (both widths) directly inspected; Kimi real-browser DOM measure confirms geometry
  - validate.sh PASS; ci-smoke.sh _site PASS sitemap=11; porcelain exactly 1 content entry; images/ + models.yml untouched
  - Single commit; .planning/ docs left uncommitted
  </done>
</task>

</tasks>

<verification>
Task 1 <verify> gates all pass: static shape greps, dual-width DOM geometry + direct screenshot inspection, Kimi real-browser confirmation, validate.sh + ci-smoke.sh (sitemap=11), exactly-1-entry changeset, single atomic commit.
</verification>

<success_criteria>
The /models/ cards render the user-approved option-A layout: banner image left at 56% with text right on desktop, image-above-text stack on mobile, figures complete at natural aspect, badge above the row, no "Access:" spec line, images and models.yml untouched, all repo gates green.
</success_criteria>

<output>
Create `.planning/quick/260916-ovj-models-cards-layout-option-a-user-approv/260916-ovj-SUMMARY.md` when done (status: complete); update STATE.md (session + Quick Tasks row); leave .planning/ docs uncommitted.
</output>
