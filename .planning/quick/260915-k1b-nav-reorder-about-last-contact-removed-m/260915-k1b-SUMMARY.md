---
phase: quick-260915-k1b
plan: 01
subsystem: site-navigation
tags: [nav, redirect, content-merge, jekyll, kramdown]
requires: []
provides:
  - "Navbar order Home/Research/Publications/Software/Team/News/About on every page (header.html + 404.md inherit reconfigured nav_pages, themselves unmodified)"
  - "Legacy /contact/ URL resolves via chrome-less meta-refresh + canonical redirect stub to https://zhangtaolab.org/about/"
affects:
  - "_config.yml (nav_pages 7 → 6)"
  - "_pages/about.md (+Contact section, 58 → 118 lines)"
  - "_pages/contact.md (full page → 16-line redirect stub)"
  - "_pages/team.md (Contact us! link retarget)"
tech-stack:
  added: []
  patterns:
    - "kramdown raw-HTML block: a leading <!DOCTYPE> line in a .md page is escaped as text — raw blocks start at the first element tag (e.g. <html>), never at <!DOCTYPE"
key-files:
  created: []
  modified:
    - _config.yml
    - _pages/about.md
    - _pages/contact.md
    - _pages/team.md
decisions:
  - "Stub DOCTYPE line replaced with <meta name=\"robots\" content=\"noindex\"> (Rule 1 auto-fix): kramdown escapes a leading <!DOCTYPE> into visible text; swap keeps 16-line shape, all plan assertions, and strengthens T-k1b-02 search-index exclusion"
metrics:
  duration: 6 min
  completed: 2026-09-15
  tasks: 3
status: complete
actuals:
  tokens: 1565      # chars/4 over realized diff (git show --patch = 6260 chars); plan estimate was 30000 — planner sized from sibling quick tasks; actual diff is far smaller
  tasks: 3
  commits: 1        # 86021023 (plus this docs commit handled by orchestrator)
---

# Quick Task 260915-k1b: Nav reorder (About last) + Contact merged into About Summary

Navbar reordered to Home/Research/Publications/Software/Team/News/About (Contact dropped from nav), former Contact page content merged verbatim into About as a new Contact section, /contact/ converted to a chrome-less meta-refresh+canonical redirect stub (noindex) pointing at /about/, and the team page's "Contact us!" link retargeted — 4 files, one local commit, nothing pushed.

## What Was Built

1. **`_config.yml`** — `nav_pages` reduced 7 → 6 in the order research/publications/software/team/news/about (contact entry deleted, about moved first → last). No other line changed.
2. **`_pages/about.md`** (58 → 118 lines) — new `<h2 class="section-heading">Contact</h2>` section after Grants & Funding; contact.md lines 13-69 copied verbatim (Laboratory Address pi-card, Join the Lab + Links markdown="1" cards, map-section markdown="0" iframe, all Liquid variables intact, column-0 HTML preserved per the G-1-3 kramdown pattern). Style rule NOT duplicated (max-width: none count stays 1).
3. **`_pages/contact.md`** (69 → 16 lines) — redirect stub: frontmatter exactly `permalink: /contact/` + `sitemap: false` (no title → self-excludes from search.json; no layout → emitted without site chrome), body one continuous raw-HTML block: charset meta, robots noindex, 0s meta refresh to `{{ site.url }}/about/`, canonical to `{{ site.url }}/about/`, `<title>Contact — moved</title>`, fallback link. `{{ site.url }}/about/` appears exactly 3 times.
4. **`_pages/team.md`** line 83 — "Contact us!" anchor href `/contact/` → `/about/`; zero contact-path occurrences remain in the file.

## Verification

All three tasks' automated batteries passed end-to-end:

- **Task 1 (tracer + auto-mode gate re-run):** `TRACER-NAV-ORDER-OK` — source nav_pages exact 6-entry order; fresh production build (after `rm -rf _site` of the stale dev-mode artifacts) renders the exact 7-anchor navbar sequence `https://zhangtaolab.org/` → `/research` → `/publications` → `/software` → `/team` → `/news` → `/about`; 0 contact hrefs in `_site/index.html` and `_site/404.html`; contact page provably untouched at that stage (5 navbar-class lines, sitemap 11).
- **Task 2:** `CONTENT-MERGE-OK` (re-run after the Rule 1 fix as `CONTENT-MERGE-OK-FIXED`) — all source-shape counts (118/1/3/1/1/1/2/1 on about.md; 16-line stub with exact frontmatter and 3 Liquid refs; team.md 0 contact paths + 1 retargeted anchor) and all built transitions (about: Laboratory Address + Join the Lab + map-section 1; contact: 0 navbar lines, 1 refresh, 1 canonical, 3 rendered /about/ URLs; sitemap 11 → 10 with 0 contact; search.json 11 → 10 titles, Contact gone, About kept; team Contact us! at /about/).
- **Task 3:** fresh-build battery — `validate.sh` exit 0; `ci-smoke.sh` prints `PASS: sitemap=10, anchor ok, feed valid, no vendor` (10 is the expected drop, within the script's -ge 10 threshold); full regression sweep green; commit `86021023` touches exactly the 4 task files and sits local-only in `origin/main..HEAD` alongside b54eadd8 and 3922068f.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Stub DOCTYPE line escaped by kramdown into visible text**
- **Found during:** Task 2 (post-build inspection of `_site/contact/index.html`)
- **Issue:** The plan-mandated `<!DOCTYPE html>` first body line is not a raw-HTML block start for kramdown — the block starts at `<html lang="en">` — so kramdown escaped it to `<p>&lt;!DOCTYPE html&gt;</p>`, rendering the literal text "<!DOCTYPE html>" above the fallback link whenever meta-refresh is disabled, and the served page had no usable doctype.
- **Fix:** Replaced the DOCTYPE line with `<meta name="robots" content="noindex">`. Every plan assertion stays green (still exactly 16 lines, exact 2-line frontmatter, `{{ site.url }}/about/` ×3, required strings present, no blank lines); the built stub is now clean chrome-less HTML. The noindex meta additionally strengthens T-k1b-02 (keeps the dead entry out of search indexes; jekyll-sitemap exclusion covers sitemap, this covers indexing of the stub itself).
- **Trade-off:** The served stub has no DOCTYPE (quirks mode) — a literal leading DOCTYPE is unachievable through kramdown on a `.md` page; irrelevant for a page containing only metas and one fallback link.
- **Files modified:** `_pages/contact.md`
- **Commit:** 86021023

Otherwise the plan executed exactly as written. No auth gates, no checkpoints (auto mode; tracer gate passed by end-to-end verify re-run), no fix-attempt overruns.

## Known Stubs

None.

## Self-Check: PASSED

- Files: `_config.yml`, `_pages/about.md`, `_pages/contact.md`, `_pages/team.md` — all FOUND
- Commit 86021023 — FOUND (exactly 4 files in `git show --name-only`; local-only ahead-set confirmed)
- Full hash: 86021023b697f77ed664a3ebf99020b64d771cc3
- Working tree clean after commit; nothing pushed (DEPLOY_ENABLED live — push timing belongs to the user)
