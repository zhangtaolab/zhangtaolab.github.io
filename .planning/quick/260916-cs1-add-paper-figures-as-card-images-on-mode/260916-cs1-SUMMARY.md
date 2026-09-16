---
phase: quick-260916-cs1
plan: 01
subsystem: models-page
tags: [models, images, data-schema, liquid, jekyll]
requires:
  - "260916-c21: /models/ page exists with card loop + .software-thumb CSS already in place"
provides:
  - "Optional image/image_alt schema on _data/models.yml — future model cards get a thumbnail by adding two YAML keys, no template edit"
  - "images/models/ asset directory for model card figures"
affects:
  - "_pages/models.md (card loop thumb rendering)"
  - "/models/ rendered page (two real paper-figure thumbnails replace dashed placeholders)"
tech-stack:
  added: []
  patterns:
    - "Data-driven optional-field conditional in Liquid card loop ({% if model.image %} … {% else %} byte-identical fallback {% endif %}) with relative_url + alt + loading=lazy"
key-files:
  created:
    - images/models/plantelixseek-fig1.png
    - images/models/pdllms-fig1.png
  modified:
    - _data/models.yml
    - _pages/models.md
decisions:
  - "Copy staged PNGs byte-identically (cmp-verified) instead of re-extracting from PDF/PPTX — regeneration risks silent drift from the approved crops"
  - "Optional image/image_alt YAML keys + conditional template branch (not unconditional img) — dashed placeholder fallback preserved byte-identically for future image-less entries"
  - "Alt strings pinned quote-free so the unescaped {{ model.image_alt }} output cannot break out of the attribute (T-cs1-02 mitigation)"
metrics:
  duration: 3 min
  completed: 2026-09-16
estimate:
  tokens: 18000
  confidence: low
actuals:
  tokens: 500      # chars/4 over the realized text diff (2002 chars); the two PNG binaries add no authored chars
  tasks: 2
  commits: 1       # measured: git rev-list --count 00212fa6..HEAD
plan_head_before: 00212fa6
status: complete
---

# Quick Task 260916-cs1: Paper figures as card images on /models/ Summary

Replaced the two dashed "Model" placeholder thumbnails on /models/ with the staged paper Fig 1 images (PlantHelixSeek: pretraining corpus + HelixSeek architecture + benchmarks; PDLLMs: promoter/terminator architecture overview) via a new optional `image`/`image_alt` schema on `_data/models.yml` and a single-line conditional thumb in the `_pages/models.md` card loop — zero SCSS, zero config changes, 4 content paths in one local commit (7a79e5d6), nothing pushed.

## What Was Done

### Task 1: Stage figures + register image/image_alt (commit 7a79e5d6)

- Created `images/models/` (sibling of images/research, images/software, images/team) and copied — not re-extracted — both staged PNGs from `/tmp/models_imgs/`: `plantelixseek-fig1.png` (306244 B, 800×647 RGBA) and `pdllms-fig1.png` (66162 B, 660×990 RGBA). `cmp` byte-identity against the staged copies passed for both; PNG magic confirmed by `file`.
- `_data/models.yml`: header schema comment extended with `image` (absolute site path to card thumbnail, rendered through relative_url) and `image_alt` (accessibility alt text) after the existing `note` line; PlantHelixSeek entry gained `image: "/images/models/plantelixseek-fig1.png"` + `image_alt: "PlantHelixSeek overview: pretraining corpus, HelixSeek architecture and benchmarks"` after `note`; PDLLMs entry gained `image: "/images/models/pdllms-fig1.png"` + `image_alt: "PDLLMs overview: promoter and terminator architecture, model comparison and pretraining corpus"` after `paper`. Both double-quoted, quote-free text (T-cs1-02).
- Syntax gate: `YAML.safe_load(..., permitted_classes: [Date], aliases: true)` parses the file as a 2-entry array where every entry has `image` + `image_alt` — this ruby parse is the models.yml gate since `scripts/validate.sh` covers only news/team_members/pi/alumni/grants.

### Task 2: Conditional card thumbnail + end-to-end verification (commit 7a79e5d6)

- `_pages/models.md` line 68: the unconditional `<div class="software-thumb-placeholder">Model</div>` replaced by a single column-0 line inside the `markdown="0"` card wrappers: `{% if model.image %}<div class="software-thumb"><img src="{{ model.image | relative_url }}" alt="{{ model.image_alt }}" loading="lazy"></div>{% else %}<div class="software-thumb-placeholder">Model</div>{% endif %}` — else branch byte-identical to the placeholder it replaced. G-1-3 kramdown pattern preserved; no SCSS edits (`.software-thumb` / `.software-thumb img` already exist in the page-local style block and assets/css/custom.scss:31-47).
- Live livereload server regenerated on first poll (well under the 60 s budget).

## Verification Results

All gates green, no retries needed:

| Gate | Result |
|------|--------|
| `cmp` byte-identity both PNGs vs /tmp/models_imgs/ | pass |
| PNG magic on both files (`file`) | pass (2× PNG image data) |
| Exactly one `image:` key per path string, two `image_alt:` keys | pass |
| models.yml safe_load = 2-entry array, image+image_alt on both | pass |
| Served /models/: exactly 1× `src="/images/models/plantelixseek-fig1.png"` | pass |
| Served /models/: exactly 1× `src="/images/models/pdllms-fig1.png"` | pass |
| Served /models/: 1× `alt="PlantHelixSeek overview…`, 1× `alt="PDLLMs overview…` | pass |
| Served /models/: exactly 2× `loading="lazy"` | pass |
| Element-form `<div class="software-thumb-placeholder"` count on served HTML | 0 (pass; raw class-token grep reads 2 by design — style-block selectors for the fallback) |
| Both image URLs HTTP 200 on 127.0.0.1:4000 | pass |
| `bash scripts/validate.sh` | PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一 |
| `bash scripts/ci-smoke.sh _site` | PASS: sitemap=11 (unchanged — static images add no sitemap URLs) |
| Git audit excluding .planning/.claude | exactly the 4 content paths (sorted-diff clean) |
| One local commit, exactly 4 paths, no deletions, origin/main..HEAD +1 | pass (7a79e5d6) |

Nothing pushed — DEPLOY_ENABLED is live on main and push timing belongs to the user.

## Deviations from Plan

None - plan executed exactly as written.

## Auth Gates

None encountered.

## Known Stubs

None. The `{% else %}` dashed-placeholder branch retained in source is an intentional documented fallback for future image-less entries, not a stub — the served page renders zero placeholder elements.

## Self-Check: PASSED

- images/models/plantelixseek-fig1.png — FOUND (tracked in 7a79e5d6)
- images/models/pdllms-fig1.png — FOUND (tracked in 7a79e5d6)
- _data/models.yml modified — FOUND
- _pages/models.md modified — FOUND
- Commit 7a79e5d6 — FOUND on local main (`git log --oneline --all` match)
