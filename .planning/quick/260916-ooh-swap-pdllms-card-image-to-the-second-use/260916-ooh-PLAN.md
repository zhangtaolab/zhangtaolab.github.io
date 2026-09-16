---
phase: quick-260916-ooh
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - images/models/pdllms-figure1.png              # added (VERBATIM copy of /tmp/models_imgs/user-pdllms.png, zero processing)
  - images/models/pdllms-banner-full.png          # deleted
  - _data/models.yml                              # PDLLMs image/image_alt repointed (2 lines); PlantHelixSeek entry untouched
autonomous: true
requirements: [MODELS-02]
tags: [models, images, banner-swap, byte-identity]

estimate:
  tokens: 20000
  raw_tokens: 10000
  tasks: 1
  confidence: low   # banner quick-task series (cs1/d6y/dvz/ksu/nl1/oh7) each surfaced verify surprises; keep buffer

must_haves:
  truths:
    - "images/models/pdllms-figure1.png is BYTE-IDENTICAL (cmp exit 0) to /tmp/models_imgs/user-pdllms.png in FOUR places: working tree vs source, staged blob (git show :path) vs source, served http://127.0.0.1:4000/images/models/pdllms-figure1.png (HTTP 200) vs source, and committed blob (git show HEAD:path) vs source — no resample, no recompress, no metadata strip (VERBATIM per user demand)"
    - "images/models/pdllms-banner-full.png is deleted; its served URL returns 404; the rendered /models/ page references pdllms-figure1.png EXACTLY once and the old pdllms-banner-full path ZERO times (plantelixseek-figure1.png for the PlantHelixSeek card is NOT touched)"
    - "_data/models.yml PDLLMs entry has image \"/images/models/pdllms-figure1.png\" + image_alt \"PDLLMs paper Figure 1: model overview\" (exact strings, double-quoted, no embedded quotes); PlantHelixSeek entry and the schema header comment are untouched"
    - "At 1280px viewport the PDLLMs banner img (selector .model-banner img whose src contains pdllms-figure1.png, second card) has naturalWidth 3656 / naturalHeight 1628 and displayed size ≈1010×450±8 with |displayed aspect / natural aspect − 1| < 1% — the existing lei natural-aspect CSS (height:auto) adapts with ZERO markup/CSS edits"
    - "Screenshot at 1280px inspected: the user's image content renders complete, full-width, no truncation"
    - "scripts/validate.sh exits 0 and scripts/ci-smoke.sh _site prints PASS with sitemap=11"
    - "Content changeset is EXACTLY 3 git entries outside .planning/ (added figure1 png, deleted banner-full png, modified models.yml) in ONE commit; untracked .planning/quick/ evidence (nl1/oh7 dirs) and the orchestrator's uncommitted .planning/STATE.md edit are excluded from the gate and not committed"
  artifacts:
    - images/models/pdllms-figure1.png   # 1896484 B, 3656×1628 PNG, cmp-identical to /tmp/models_imgs/user-pdllms.png
    - _data/models.yml                   # PDLLMs image/image_alt repointed; nothing else changed
    - screenshot at 1280px saved in this quick task directory as visual evidence
  key_links:
    - "_data/models.yml image key → /images/models/pdllms-figure1.png → _pages/models.md relative_url rendering → served URL 200 + cmp identity (proves the whole yml→render chain without touching the template)"
    - "existing natural-aspect .model-banner rules (height:auto, quick-260916-lei, NOT modified) → displayed aspect == natural aspect within 1% (zero-crop proof with zero CSS change)"
---

<objective>
Swap the PDLLMs card banner on /models/ to the user's second prepared wide banner PNG — VERBATIM, byte-identical, zero processing. The user prepared /tmp/models_imgs/user-pdllms.png (3656×1628, 1896484 B) themselves and demanded it be used as-is. Mirror of quick-260916-oh7 (PlantHelixSeek swap, commit 0c5a92ab) — same procedure, PDLLMs card.

Purpose: The current pdllms-banner-full.png (nl1 composite, 55515 B) is replaced by the user's own prepared figure; the live natural-aspect full-width CSS already displays 3656×1628 correctly as a ~1010×450 banner, so NO CSS/markup changes are needed or permitted.
Output: 3 git entries — new images/models/pdllms-figure1.png (byte-identical copy), deleted images/models/pdllms-banner-full.png, _data/models.yml PDLLMs image/image_alt repointed. Single commit.
</objective>

<execution_context>
@~/.claude/gsd-core/workflows/execute-plan.md
@~/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@_data/models.yml
@_pages/models.md

Preconditions (assert before starting; halt if unmet):
- /tmp/models_imgs/user-pdllms.png exists and is exactly 1896484 B, PNG 3656×1628 8-bit RGBA (`file` + `stat -f%z`) — VERIFIED at plan time
- Jekyll serve is running: `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/models/` returns 200 — VERIFIED at plan time
- Kimi bridge daemon reachable at 127.0.0.1:10086 with session "models-page-check" (for the user's-real-browser visual check) — daemon reachable at plan time

Grounding:
- Current yml state: PDLLMs entry lines 50–51 hold `image: "/images/models/pdllms-banner-full.png"` and its image_alt; PlantHelixSeek entry lines 39–40 (plantelixseek-figure1.png, oh7) MUST NOT be touched
- Template (_pages/models.md) renders `image` through relative_url into `.model-banner img` with natural-aspect CSS (height:auto, lei/nl1/oh7 final state) — file gets ZERO edits this task
- Playwright precedent (nl1/oh7): igv-rust playwright 1.58.2 at /Users/forrest/Playground/igv_Refactoring/igv-rust with NODE_PATH (script dropped in this task directory)
- Porcelain precedent (ksu/nl1/oh7): stage binary additions before counting paths
</context>

<tasks>

<task type="auto">
  <name>Task 1: VERBATIM image swap — copy user PNG byte-identical, delete old banner, repoint models.yml</name>
  <files>images/models/pdllms-figure1.png, images/models/pdllms-banner-full.png, _data/models.yml</files>
  <action>
  Three changes, ONE commit:

  1. COPY (do not `cp -p`-then-edit, never ImageMagick/sips — NO resampling, NO recompression, NO metadata stripping):
     `cp /tmp/models_imgs/user-pdllms.png images/models/pdllms-figure1.png`
     Gate immediately: `cmp /tmp/models_imgs/user-pdllms.png images/models/pdllms-figure1.png` — exit 0 mandatory; ANY byte difference is a HARD FAILURE (the user demanded verbatim use of their file).

  2. DELETE the old banner: `git rm images/models/pdllms-banner-full.png`
     New URL also dodges any browser cache of the old banner path.

  3. EDIT `_data/models.yml` PDLLMs entry ONLY (2 lines, keep double-quoted style, no embedded quotes):
     - line 50: `image: "/images/models/pdllms-figure1.png"`
     - line 51: `image_alt: "PDLLMs paper Figure 1: model overview"`
     PlantHelixSeek entry (lines 39–40) and the schema header comment: UNTOUCHED. `_pages/models.md` and all SCSS: UNTOUCHED (the lei natural-aspect rules auto-fit the new 3656×1628 aspect).

  Stage the new PNG (`git add images/models/pdllms-figure1.png`), then verify (below). Commit all three paths in ONE commit: `fix(quick-260916-ooh): swap PDLLMs card image to the user's Figure 1 banner`.
  </action>
  <verify>
  <automated>
  # 1) byte identity — disk, staged, served (serve regenerates on yml/image change; poll ≤30s until 200), and committed blob
  cmp /tmp/models_imgs/user-pdllms.png images/models/pdllms-figure1.png && \
  git show :images/models/pdllms-figure1.png > /tmp/ooh-staged.png && \
  cmp /tmp/models_imgs/user-pdllms.png /tmp/ooh-staged.png && \
  curl -s http://127.0.0.1:4000/images/models/pdllms-figure1.png > /tmp/ooh-served.png && \
  cmp /tmp/models_imgs/user-pdllms.png /tmp/ooh-served.png && \
  git show HEAD:images/models/pdllms-figure1.png > /tmp/ooh-committed.png && \
  cmp /tmp/models_imgs/user-pdllms.png /tmp/ooh-committed.png && echo IDENTICAL

  # 2) old asset gone + reference swap on rendered page
  [ "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/images/models/pdllms-banner-full.png)" = "404" ] && \
  [ "$(curl -s http://127.0.0.1:4000/models/ | grep -c 'pdllms-figure1.png')" = "1" ] && \
  [ "$(curl -s http://127.0.0.1:4000/models/ | grep -c 'pdllms-banner-full')" = "0" ] && \
  grep -q 'image: "/images/models/pdllms-figure1.png"' _data/models.yml && \
  grep -q 'image_alt: "PDLLMs paper Figure 1: model overview"' _data/models.yml && \
  grep -q 'image: "/images/models/plantelixseek-figure1.png"' _data/models.yml && echo SWAP-OK

  # 3) rendered geometry at 1280px (igv-rust playwright 1.58.2, NODE_PATH pattern per nl1/oh7; script in task dir):
  #    selector ".model-banner img" match by src containing pdllms-figure1.png (PDLLMs is the second card):
  #    assert naturalWidth==3656 && naturalHeight==1628;
  #    displayed width in [1002,1018] && displayed height in [442,458];
  #    |(dw/dh)/(3656/1628) - 1| < 0.01
  #    save screenshot to this task directory (models-1280.png) and inspect: user's image content complete, full-width, no truncation

  # 4) user's real browser via Kimi bridge 127.0.0.1:10086 session "models-page-check":
  #    open http://127.0.0.1:4000/models/, screenshot, visually confirm the PDLLMs banner renders the user's image complete

  # 5) repo gates + changeset shape (pre-commit: staged changeset = exactly 3 content entries; post-commit: porcelain clean outside .planning/)
  scripts/validate.sh && scripts/ci-smoke.sh _site && \
  [ "$(git status --porcelain | grep -v '\.planning/' | wc -l | tr -d ' ')" = "3" ] && \
  [ "$(git status --porcelain | grep -v '\.planning/' | grep -c 'images/models/\|_data/models.yml')" = "3" ] && echo GATES-OK
  </automated>
  </verify>
  <done>
  - cmp exit 0 in all four places (disk / staged blob / served URL / committed blob) — user's PNG used VERBATIM
  - Old banner deleted, its URL 404, rendered page: new path ×1, old path ×0, PlantHelixSeek card untouched
  - naturalWidth 3656; displayed ≈1010×450±8; aspect drift <1% at 1280px — zero CSS/markup edits
  - Screenshot (Playwright + Kimi user-browser) shows the user's image content complete and full-width
  - validate.sh PASS; ci-smoke.sh _site PASS with sitemap=11
  - git status (excluding .planning/) exactly 3 entries pre-commit → 0 after; single commit
  </done>
</task>

</tasks>

<verification>
All gates in Task 1 <verify> pass: quadruple byte-identity cmp, URL swap counts, rendered geometry + visual inspection, validate.sh + ci-smoke.sh (sitemap=11), exactly-3-entry changeset in one commit (porcelain clean outside .planning/ afterwards).
</verification>

<success_criteria>
The /models/ PDLLMs card displays the user's 3656×1628 Figure 1 banner verbatim (byte-identical on disk, staged, as served, and in the commit), old composite banner fully removed, models.yml is the only text change, no CSS/markup touched, all repo gates green.
</success_criteria>

<output>
Create `.planning/quick/260916-ooh-swap-pdllms-card-image-to-the-second-use/260916-ooh-SUMMARY.md` when done
</output>
