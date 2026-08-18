---
phase: 01-local-dev-environment
plan: "02"
subsystem: content
tags: [jekyll, liquid, kramdown, yaml-data, gap-closure]

requires:
  - phase: 01-local-dev-environment/01
    provides: green local Jekyll 4.4.1 build environment, reference-snapshot content baseline, UAT gap register (G-1-3/G-1-4)
provides:
  - Site content aligned to reference snapshot (team roster, alumni, 6-entry news set, home/research/software/about copy)
  - G-1-3 eliminated site-wide (zero kramdown-escaped HTML blocks in _site output)
  - role-based team_members.yml schema (pi/member/student) and 4-column alumni.yml schema
  - Sidebar/head include hygiene (no broken image references, existence-guarded og/twitter meta)
affects: [phase-2-deploy, publications-page, talks-teaching-content-backfill]

actuals:
  tokens: 14100   # chars/4 over realized diff (56,376 diff chars across e3251c9..c7c300e)
  tasks: 7
  commits: 7

tech-stack:
  added: []
  patterns:
    - "Column-0 flattened HTML in kramdown pages (parse_block_html:true immune pattern) + markdown=\"0\" wrappers for mixed blocks"
    - "Data-driven team roster keyed by role field with Liquid where/first filters"
    - "Existence-guarded meta tags via site.static_files lookup in head.html"

key-files:
  created: []
  modified:
    - _pages/team.md
    - _pages/about.md
    - _pages/home.md
    - _pages/research.md
    - _pages/software.md
    - _data/team_members.yml
    - _data/alumni.yml
    - _data/news.yml
    - _includes/sidebar.html
    - _includes/head.html
  deleted:
    - _data/people.yml

key-decisions:
  - "Reference snapshot is the content authority; its own template defects ({title} placeholder, flat .html links, CDN fonts) deliberately NOT adopted"
  - "Current members/students render gradient icon placeholders (no fabricated photos); only PI gets a real photo (logo.png)"
  - "Orphan people.yml deleted after grep-proving zero template consumers"
  - "og:image/twitter:image guarded on static-file existence instead of editing _config.yml (plan forbade touching config)"

patterns-established:
  - "kramdown escape prevention: all HTML at column 0, no >=4-space-indented HTML lines (assertable via grep -En '^ {4,}.*<')"
  - "Content alignment verified by per-file grep markers on _site output, not source-only checks"

requirements-completed: [ENV-01, ENV-02]

coverage:
  - id: D1
    description: "G-1-3 cleared - zero escaped &lt;div / language-plaintext blocks across all _site/*.html (baseline: about=3, team=23)"
    requirement: ENV-02
    verification:
      - kind: integration
        ref: "grep -rl '&lt;div' _site --include='*.html' | wc -l => 0 after bundle exec jekyll build"
        status: pass
    human_judgment: false
  - id: D2
    description: "Team page aligned - PI card + Current Member (Dr. Wu Yuechao) + Current Students (Chen Long, Dian Zhang) + Join Us + 4-column alumni table (Liu Guanqing/Bao Yu), old roster absent"
    requirement: ENV-02
    verification:
      - kind: integration
        ref: "grep markers on _site/team/index.html (all pass) + curl 127.0.0.1:4000/team/ contains Dr. Wu Yuechao"
        status: pass
    human_judgment: false
  - id: D3
    description: "News set completed to 6 entries; /news/ and /allnews.html render 6 news-items each, home sidebar stays at 3, feed builds"
    requirement: ENV-01
    verification:
      - kind: integration
        ref: "grep -c 'class=\"news-item\"' _site/news/index.html => 6; _site/index.html => 3; jekyll build exit 0"
        status: pass
    human_judgment: false
  - id: D4
    description: "Home/about/research/software copy aligned to reference; literal '## News' and broken headshot.jpg references removed; correct page titles"
    requirement: ENV-02
    verification:
      - kind: integration
        ref: "grep markers on _site/index.html, _site/about/index.html, _site/research/index.html, _site/software/index.html (all pass); <title> assertions pass"
        status: pass
    human_judgment: false
  - id: D5
    description: "Visual parity of rewritten pages against live reference site (rendering fidelity beyond grep markers)"
    requirement: ENV-02
    verification: []
    human_judgment: true
    rationale: "Grep markers prove content presence, not visual equivalence; pixel/layout parity against wmsd5fpo6kcfi.ok.kimi.link needs human eyes or browser UAT"

duration: 8min
completed: 2026-08-18
status: complete
---

# Phase 1 Plan 02: Gap Closure Content Alignment Summary

**Team roster/alumni/news/home/about/research/software content aligned byte-for-marker with the reference snapshot, and the kramdown HTML-escaping defect (G-1-3) eliminated site-wide via column-0 flattened page rewrites**

## Performance

- **Duration:** 8 min (512s)
- **Started:** 2026-08-18T00:51:14Z
- **Completed:** 2026-08-18T00:59:46Z
- **Tasks:** 7 of 7
- **Files modified:** 12 (10 edited, 1 deleted, 1 planning state)

## Accomplishments

- G-1-3 zeroed: `grep -rl '&lt;div' _site --include='*.html'` returns 0 files (baseline: about=3, team=23 hits); `language-plaintext` blocks gone from about/team
- Team page rebuilt from role-based roster data (pi/member/student): PI card with real logo.png photo, Dr. Wu Yuechao as Current Member, Chen Long + Dian Zhang as Current Students, Join Us card, 4-column alumni table (Liu Guanqing 2017–2025 PhD, Bao Yu 2018–2025 PhD); old roster (Han Yangshuo/Yang Qiqi/Xin Xiaoyue/Ding Yu/Liu Shuo) fully gone; double-path `/images/team/team/` and nonexistent avatar.jpg/placeholder.jpg references gone
- News completed to reference's 6 entries; home sidebar stays at 3; feed.xml builds (Latest -> site.time fallback already in place)
- Home page: hero/chips/featured callout/banner-frame/About-the-Lab copy matches reference verbatim; literal `## News` text and duplicate news block removed; sidebar broken headshot.jpg image and educationshort list removed
- About page: PI card renders unescaped with in-page `.pi-photo-placeholder` gradient style (mirroring reference approach), correct `site.data.pi[0].education` indexing, grants list renders NSFC + CIB CAS Start-up Fund via `grant.name`; broken Education & Career shell section gone
- Research/Software pages: all 8+8 card descriptions aligned verbatim; 3 citations upgraded from "et al." abbreviations to full author lists; card 8 icon placeholder replaced with existing bioinformatics-tools.jpg; browser titles now "Research/Software - Zhang Tao Lab"
- Orphan `_data/people.yml` deleted after grep-proving zero consumers (content contradicted reference roster)
- Reference-site defects NOT introduced: zero `{title}` placeholders, zero flat `./xxx.html` links, zero fonts.loli.net/zstatic.net/jsdmirror CDN references; directory-style permalinks and local asset pipeline preserved
- `_pages/publications.md` (83 hand-written entries) untouched: `git diff 7cac7e4 -- _pages/publications.md` empty
- Serve loopback on 127.0.0.1:4000: all 6 spot-checked pages returned 200 with content markers; serve process stopped after verification

## Task Commits

Each task was committed atomically:

1. **Task 1: Team page rewrite + roster/alumni data alignment** - `c4d4eff` (fix)
2. **Task 2: About page rewrite (PI card unescape + copy/grants)** - `a5ad988` (fix)
3. **Task 3: News set completed to 6 entries** - `c2bdd4f` (fix)
4. **Task 4: Home hero/featured/banner + sidebar fixes** - `a2966d2` (fix)
5. **Task 5: Research page copy alignment** - `23c3528` (fix)
6. **Task 6: Software page titles/descriptions/citations** - `0cd731f` (fix)
7. **Task 7: Full rebuild + product assertions + serve spot-check + wrap-up** - `c7c300e` (fix; includes Rule-1 head.html fix and STATE.md record)

## Files Created/Modified

- `_pages/team.md` - Rewritten as column-0 flattened HTML mirroring ref-team DOM, data-driven from team_members.yml
- `_data/team_members.yml` - New role-based schema (pi/member/student); PI photo /images/logo.png; no fabricated photos
- `_data/alumni.yml` - New 4-column schema (name/period/degree/position) with en-dash periods
- `_pages/about.md` - Rewritten: PI card with markdown="0" wrapper, pi-photo-placeholder in-page style, data-driven education/grants
- `_data/news.yml` - 3 entries appended (March 2026 / December 2024 / June 2023), first 3 untouched
- `_pages/home.md` - Rewritten: home-hero/banner-frame/callout-success classes that exist in main.css; duplicate news block deleted
- `_includes/sidebar.html` - Broken headshot.jpg image block and educationshort list removed
- `_pages/research.md` - title frontmatter, h1+intro, 8 card bodies replaced, card 8 real image
- `_pages/software.md` - title frontmatter, h1, 4 h2 section headings, 8 card restructures, full citations
- `_includes/head.html` - og:image/twitter:image now guarded on static-file existence (Rule 1 fix)
- `_data/people.yml` - DELETED (orphan, zero consumers, contradicted reference)

## Decisions Made

- Reference snapshot treated as content authority; its own defects (unrendered `{title}`, flat .html links, loli/zstatic/jsdmirror CDN) deliberately excluded per plan prohibitions
- Current members/students use gradient icon placeholders exactly like the reference (no fabricated photos); images/team/*.jpg left on disk unreferenced
- Kept local inline size styles on research/software cards (visually verified local enhancement, per plan's flagged assumption)
- `pub-actions` used as software-card button container instead of unstyled `section-links` (see Deviations)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] og:image/twitter:image meta tags referenced nonexistent headshot.jpg**
- **Found during:** Task 7 (product assertions - `grep -c "headshot.jpg" _site/index.html` returned 2, expected 0)
- **Issue:** Plan Task 4 removed the sidebar `<img>` but missed `_includes/head.html`'s two meta tags driven by `site.photo: headshot.jpg` in _config.yml; images/headshot.jpg does not exist (broken social-preview references; plan prohibition explicitly forbids referencing nonexistent headshot.jpg)
- **Fix:** Guarded both meta tags on `site.static_files` lookup (`{% assign photo_file = site.static_files | where: "name", site.photo | first %}{% if site.photo and photo_file %}`) - no _config.yml change (plan forbids), no fabricated image, self-heals if a real photo is added later. Reference site has no og:image tags at all, so this matches reference output.
- **Files modified:** `_includes/head.html`
- **Verification:** Rebuild -> `grep -c "headshot.jpg" _site/index.html` = 0; build exit 0
- **Committed in:** `c7c300e` (Task 7 commit)

**2. [Rule 1 - Bug, minor] Software card button container switched from `section-links` to `pub-actions`**
- **Found during:** Task 6 (software card restructure)
- **Issue:** Plan required buttons "uniformly under h4, before description" aligned verbatim to ref-software.html, which wraps them in `pub-actions`; local `section-links` has no CSS definition in main.css (verified 0 hits) while `pub-actions` is defined (1 hit) - keeping section-links would render buttons unstyled
- **Fix:** Used `class="pub-actions" style="margin-bottom: var(--space-3);"` exactly as reference; button hrefs/text unchanged
- **Files modified:** `_pages/software.md` (all 8 cards)
- **Verification:** Task 6 acceptance criteria all pass; `grep -c 'section-links'` = 0
- **Committed in:** `0cd731f` (Task 6 commit)

---

**Total deviations:** 2 auto-fixed (2x Rule 1 bugs)
**Impact on plan:** Both fixes required to satisfy the plan's own acceptance criteria. No scope creep; no files outside plan scope touched (_config.yml/_sass/publications.md/papers untouched).

## Issues Encountered

- Pre-existing benign build warning: `assets/main.css` vs `assets/main.scss` output-target conflict (static snapshot wins, >1000 bytes) - documented in STATE.md since Phase 1, out of scope (plan forbids touching CSS assets)
- All Task 1-6 source-level acceptance criteria and Task 7 product-level assertions passed on first run except the headshot meta-tag issue above (fixed and re-verified)

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Local site content now matches the reference authority; Phase 2 (auto-deploy via GitHub Actions full Ruby build) can proceed with this content as the deploy payload
- publications.md 83-entry list intact for jekyll-scholar-free rendering; talks/teaching known-empty states still tracked in STATE.md (content backfill, out of scope)
- Coverage D5 (visual parity vs live reference) is flagged for human/browser UAT - grep markers prove content, not pixels

---
*Phase: 01-local-dev-environment*
*Completed: 2026-08-18*

## Self-Check: PASSED

All 7 task commits verified in git log; SUMMARY.md and all 10 modified source files present on disk.
