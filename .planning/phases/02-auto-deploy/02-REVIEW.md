---
phase: 02-auto-deploy
reviewed: 2026-08-19T04:55:00Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - .github/workflows/deploy.yml
  - .gitignore
  - _config.yml
  - _includes/head.html
  - _pages/about.md
  - _pages/blogs.md
  - _pages/contact.md
  - _pages/home.md
  - _pages/news.md
  - _pages/publications.md
  - _pages/talks.md
  - _pages/teaching.md
  - feed.xml
  - scripts/ci-smoke.sh
findings:
  critical: 2
  warning: 4
  info: 5
  total: 11
status: issues_found
---

# Phase 2: Code Review Report

**Reviewed:** 2026-08-19T04:55:00Z
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Reviewed all 14 phase files at standard depth, with build-level verification: ran `bundle exec jekyll build` locally, ran `scripts/ci-smoke.sh _site` (PASS: sitemap=11), inspected the `_site` artifact, verified all action refs in `deploy.yml` exist upstream (`checkout@v4`, `setup-ruby@v1`, `configure-pages@v5`, `upload-pages-artifact@v3`, `deploy-pages@v5`), confirmed `Gemfile.lock` platform coverage includes `x86_64-linux-gnu` (portable to ubuntu runners) and `.ruby-version` (4.0.6) is committed, and confirmed the `^=` query operator in `talks.md` is valid bibtex-ruby 6.2.0 syntax. Also probed the live production domain to establish which defects are already shipped.

The pipeline itself is sound: the workflow permissions are minimal, the D-16 kill-switch gate is correct (`inputs.deploy` is empty on push events, so only `vars.DEPLOY_ENABLED == 'true'` arms auto-deploy), and the smoke assertions pass. `jekyll-scholar` loads correctly via the Gemfile `:jekyll_plugins` group despite being absent from the `plugins:` whitelist.

However, **the deploy is already live at zhangtaolab.org** (verified: the new-only path `/scripts/ci-smoke.sh` returns 200), and the shipped site contains two production-grade content defects: a placeholder "Teaching" page claiming the PI taught the Feynman Lectures (1953–88), and 8 publication PDF links that 404 on the live domain. The pipeline did its job — it faithfully deployed broken content with no gate to catch it.

## Critical Issues

### CR-01: Template placeholder content is live in production at /teaching/

**File:** `_pages/teaching.md:11-14`
**Issue:** The page ships verbatim template placeholder content: "Physics 1, 2, 3: The Feynman Lectures on Physics (1961–63)", "Physics 219: Quantum Computing (1986)", "Graduate QED Seminar (1953–88)", "Physics X (1961–78)". None of this is the lab's teaching record, and the dates predate the lab and PI's career by decades. Verified live: `https://zhangtaolab.org/teaching/` currently serves this content (grep confirmed "Feynman", "Quantum Computing" on the production page), and the URL is in `sitemap.xml`. The auto-deploy pipeline shipped and will keep re-publishing a page that misrepresents the PI publicly.
**Fix:** Replace with the lab's actual courses, or remove the page entirely (delete `_pages/teaching.md`; the smoke threshold `-ge 10` still passes with the remaining 10 URLs). Do not leave placeholder filler on a deployed page reachable via sitemap.

### CR-02: 8 publication PDF links 404 on the live production domain

**File:** `_pages/publications.md:166,168,174,178,180,182,194,206`
**Issue:** Eight entries link to `https://zhangtaolab.org/pdf/**.pdf` (2017_Nature_Plants, BBE_2016_inpress, NAR_2016, Plant_Physiol_2015, Genetics_2015, Plant_Cell_2015, PNAS_2013, Plant_Cell_2012). The repository contains **zero PDF files** (verified via `find . -name "*.pdf"`), `_site/papers/` contains only `ref.bib`, and spot checks on the live domain return `HTTP/2 404` for these URLs (e.g. `/pdf/2017/2017_Nature_Plants.pdf`, `/pdf/2013/PNAS_2013.pdf`). Every "PDF" click on the publications page — the highest-value page for an academic site — is a dead link.
**Fix:** Either (a) commit the PDFs to a top-level `pdf/` directory matching the existing URL structure, or (b) rewrite the 8 hrefs to `/papers/pdf/...` and commit PDFs under `papers/pdf/`, or (c) if the PDFs are not freely redistributable, replace the links with the DOI links already used by the other 81 entries.

## Warnings

### WR-01: `photo:` references a nonexistent file — entire site ships without og:image

**File:** `_config.yml:8` (guarded at `_includes/head.html:12,16`)
**Issue:** `photo: headshot.jpg  # place your photo in images/` points to a file that does not exist (`images/headshot.jpg` missing; `images/` contains `banner.jpg`). The `photo_file` guard in `head.html` prevents breakage, but as a result **zero pages emit `og:image`/`twitter:image`** (verified: `grep -c "og:image" _site/index.html` → 0). Every link shared from the deployed site renders without a preview image. The config comment shows this is an unfilled setup TODO that auto-deploy published anyway.
**Fix:** Add `images/headshot.jpg`, or set `photo: ""` until a real photo exists so the intent is explicit.

### WR-02: Dev tooling `scripts/` (and `papers/ref.bib`) deployed to production

**File:** `_config.yml:93-104`
**Issue:** The `exclude:` list omits `scripts/`, so `scripts/ci-smoke.sh` is copied into the site and publicly deployed — verified live at `https://zhangtaolab.org/scripts/ci-smoke.sh` (HTTP 200). `papers/ref.bib` also ships in `_site/papers/`. This is inconsistent with the same list excluding `Rakefile`, `update_bootstrap.sh`, and `switch_theme.sh`, which shows the intent to keep tooling out of the artifact. (The D-10 vendor tripwire covers `vendor/` only.)
**Fix:** Add `scripts` to `exclude:` in `_config.yml` (CI runs the script from the checkout, so exclusion does not affect `deploy.yml`), and add `papers/ref.bib` if the bibliography source should not be public.

### WR-03: ci-smoke.sh sitemap assertion never prints its FAIL diagnostic on the zero/missing case

**File:** `scripts/ci-smoke.sh:8-9`
**Issue:** Under `set -euo pipefail`, `COUNT=$(grep -c "<loc>" "$SITE/sitemap.xml")` aborts the script before line 9 runs whenever grep exits nonzero — exactly when the assertion should fire. Verified: with an empty sitemap the script exits 1 with **no output at all** (no "FAIL: sitemap only 0 URLs"); with a missing sitemap it prints grep's raw stderr and exits 2. CI still blocks correctly, but the intended diagnostic message is dead code for precisely the failure cases it was written to explain, which will make a future red build unnecessarily cryptic.
**Fix:**
```bash
COUNT=$(grep -c "<loc>" "$SITE/sitemap.xml" || true)
[ "$COUNT" -ge 10 ] || { echo "FAIL: sitemap only $COUNT URLs"; exit 1; }
```

### WR-04: `site.description` interpolated into HTML attributes without `| escape`

**File:** `_includes/head.html:5,9,15`
**Issue:** `<meta name="description" content="{{ site.description }}">`, `og:description`, and `twitter:description` are unescaped, while the adjacent title/name fields on the same lines use `| escape`. The current value is safe, but any future description containing `"` or `&` breaks out of the attribute / produces invalid markup — and the same file already established the escaping convention everywhere else.
**Fix:** Append `| escape` to the three `site.description` outputs (mirroring `site.name | escape` on lines 4/8/13).

## Info

### IN-01: talks.md renders two headers with permanently empty sections

**File:** `_pages/talks.md:12-16`
**Issue:** Both queries (`@incollection[keywords ^= invited]` / `@incollection[keywords != invited]`) match nothing: `papers/ref.bib` contains 12 entries, none of type `@incollection` and none with a `keywords` field. (The `^=` operator itself is valid — verified in bibtex-ruby 6.2.0 `Element#meets_condition?`.) The live page at `/talks/` shows "Invited Talks" and "Regular Talks" headings with no content. Documented as a known content state in D-08; recorded because the page is publicly reachable and sitemapped.
**Fix:** Populate `ref.bib` with talk entries (`@incollection` + `keywords`), or temporarily hide the page until content exists.

### IN-02: blogs/teaching/talks are orphan pages — built and sitemapped but absent from nav

**File:** `_config.yml:38-45`
**Issue:** `nav_pages` lists 7 sections (about/research/publications/software/team/news/contact) while `_pages/blogs.md`, `_pages/teaching.md`, and `_pages/talks.md` are built, permalanked, and in the sitemap (11 URLs — matches the smoke comment). They are unreachable via navigation, only by direct URL or sitemap. Appears deliberate (D-11), but if not, visitors have no path to them.
**Fix:** If intentional, no action; otherwise add nav entries or remove the pages.

### IN-03: contact.md ships a placeholder Google Maps embed

**File:** `_pages/contact.md:60-68` (and `:54`)
**Issue:** The iframe uses a null place ID (`!1s0x0:0x0`) and round-number coordinates (30.5N/104.0E — Chengdu city center, not the stated Tianfu New Area address), so it shows an approximate city map rather than the lab's location. Line 54 also links `http://www.cib.ac.cn/` over plain http.
**Fix:** Generate a real embed URL from Google Maps for "Chengdu Institute of Biology, CAS", and use `https://www.cib.ac.cn/`.

### IN-04: feed.xml news guids are unstable

**File:** `feed.xml:29`
**Issue:** `news-{{ forloop.index }}-{{ article_date | ... }}` — the guid embeds the item's position in `_data/news.yml`, so prepending a new item shifts every index and feed readers will treat previously-seen entries as new.
**Fix:** Derive the guid from stable content, e.g. hash of date+headline: `news-{{ article.headline | strip_html | url_encode | truncate: 60 }}-{{ article_date | date_to_xmlschema | default: 'latest' }}`.

### IN-05: Month-granular news dates serialize with fabricated day precision

**File:** `feed.xml:26-27` (data from `_data/news.yml`)
**Issue:** Dates like `"May 2026"` parse via `Time.parse` and emit `<pubDate>Fri, 01 May 2026 00:00:00 +0800</pubDate>` — an invented day-of-month and local-midnight timestamp. Harmless but misleading in feed readers.
**Fix:** Use explicit dates (`2026-05-15`) in `_data/news.yml` for new entries, keeping `"Latest"` as the only special value.

---

_Reviewed: 2026-08-19T04:55:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
