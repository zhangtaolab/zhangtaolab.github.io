---
phase: 01-local-dev-environment
reviewed: 2026-08-18T05:32:00Z
depth: standard
files_reviewed: 14
files_reviewed_list:
  - .gitignore
  - Gemfile.lock
  - _config.yml
  - _data/alumni.yml
  - _data/news.yml
  - _data/team_members.yml
  - _includes/head.html
  - _includes/sidebar.html
  - _pages/about.md
  - _pages/home.md
  - _pages/research.md
  - _pages/software.md
  - _pages/team.md
  - feed.xml
findings:
  critical: 1
  warning: 6
  info: 10
  total: 17
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-08-18T05:32:00Z
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Fresh adversarial review of the current state of the 14 phase files, after the plan-03 gap
closure (research/software relayout, dead repo link fixes). This report replaces the earlier
2026-08-18T01:09 round.

Findings were verified empirically, not just by reading:

- All 8 GitHub repos linked from `software.md`/`research.md`/`home.md`/`about.md` return
  HTTP 200 (DNALLM, Plant_DNA_LLMs, dnallmmark, MambaForSequenceClassification, CrisprStitch,
  Chorus2, rustkmer, SIF). The prior round's CR-01 (About page linking nonexistent
  `PDLLMs` repo) is **confirmed fixed** — `about.md:43,48` now point to `Plant_DNA_LLMs`.
- Liquid 4.0.4 (from `Gemfile.lock`) tested directly: `false | default: true` renders
  `"true"` — basis of WR-02.
- The freshly built `_site/` (built 13:23 today, after the last source edit) was inspected:
  `feed.xml` titles, `sitemap.xml` URL list, dark-mode script output, `rel` attribute counts,
  and `_site/papers/ref.bib`.
- All images referenced by `research.md`/`software.md`/`home.md`/`team.md` exist;
  `favicon.svg`/`favicon.ico` exist; `images/headshot.jpg` does **not** (IN-10).
- False positive avoided: under bare Liquid 4.0.4, `"May 2026" | date_to_rfc822` passes
  through unconverted, but Jekyll overrides the filter — the built `_site/feed.xml` emits
  valid RFC-822 dates (`Fri, 01 May 2026 00:00:00 +0800`). Not flagged.

High-level: the environment setup (lockfile, `.ruby-version` 4.0.6, Gemfile plugin group,
`.gitignore`) is sound and the plan-03 link fixes check out. The remaining defects are
concentrated in the feed (`feed.xml` news items publish escaped markup soup as titles),
latent config traps (`dark_mode: false` behaves incorrectly), metadata inconsistency
(sitemap excludes the homepage), and data duplication that will bite the lab's stated core
value of low-cost content maintenance.

## Narrative Findings (AI reviewer)

### Critical Issues

### CR-01: Every news item in the RSS feed publishes escaped HTML markup as its title and description

**File:** `feed.xml:23-24`
**Issue:** `<title>{{ article.headline | xml_escape }}</title>` and the matching
`<description>` run `xml_escape` on the raw headline markup from `_data/news.yml`, which is
authoring content as HTML (`<a href="…">…</a> — … <em>…</em>`). Verified in the built
`_site/feed.xml`:

```xml
<title>&lt;a href=&quot;https://doi.org/10.1038/s41467-026-73769-8&quot; target=&quot;_blank&quot;&gt;Telomere-to-telomere genome assembly of &lt;em&gt;Oryza australiensis&lt;/em&gt;&lt;/a&gt; published in &lt;em&gt;Nature Communications&lt;/em&gt;.</title>
```

RSS 2.0 `title` is plain text (HTML is not permitted there), so every subscriber sees
literal `<a href=…>` soup in their reader for all 6 items. The `&rarr;` entity in the
"Latest" item double-escapes to literal `&amp;rarr;`. This is shipped, user-visible
incorrect output of a public artifact (`feed.xml` is advertised via
`<link rel="alternate">` in `head.html:32`). The posts loop (lines 14-15) does it
correctly: `strip_html` before `xml_escape`.
**Fix:**
```liquid
<title>{{ article.headline | strip_html | xml_escape }}</title>
<description>{{ article.headline | strip_html | xml_escape }}</description>
```
(Optionally render `<description>` as entity-free HTML per RSS best practice, but
`strip_html` at minimum produces readable plain text.)

## Warnings

### WR-01: News feed items share one link and have no guid — items are indistinguishable

**File:** `feed.xml:21-30`
**Issue:** Verified in `_site/feed.xml`: every news `<item>` has the identical
`<link>https://zhangtaolab.org/allnews.html</link>` and no `<guid>` (blank lines where it
would be). RSS readers key items on guid, falling back to link+title; with a shared link
and no guid, readers commonly collapse or dedupe distinct items (the two May-2026 papers
differ only in escaped-markup title) and re-alert on every headline edit. The posts loop
(lines 13-19) emits `<guid isPermaLink="true">` correctly — the news loop omits it.
**Fix:**
```liquid
<guid isPermaLink="false">news-{{ forloop.index }}-{{ article.headline | strip_html | uri_escape | truncate: 60 }}</guid>
```
Or link each item to a per-article anchor (`/news/#news-{{ forloop.index }}` with matching
`id`s in the news templates).

### WR-02: `dark_mode: false` can never disable the pre-paint theme script

**File:** `_includes/head.html:44`
**Issue:** `var darkMode = {{ site.dark_mode | default: true }};` — Liquid's `default`
filter substitutes on nil, empty, **and `false`** (verified against the installed Liquid
4.0.4: `false | default: true` → `"true"`). A maintainer setting `dark_mode: false` per the
config comment (`_config.yml:26` — "show dark mode toggle in navbar") gets
`var darkMode = true;`: the early-return guard never fires, so the script still applies
`data-bs-theme="dark"` from `prefers-color-scheme`/localStorage, while `header.html:26`
(`{% if site.dark_mode %}`) correctly removes the toggle — visitors preferring OS-dark are
then stuck in dark mode with no visible way out. Latent today (config is `true`; built
output confirmed `var darkMode = true;`), but the documented setting is broken in one
direction.
**Fix:**
```liquid
{% assign dark_mode_enabled = site.dark_mode %}
{% if dark_mode_enabled == nil %}{% assign dark_mode_enabled = true %}{% endif %}
var darkMode = {{ dark_mode_enabled | json }};
```
(only `nil` falls back; explicit `false` then wins.)

### WR-03: Sitemap excludes homepage, About, Publications, News, Contact while including three sibling pages

**File:** `_pages/home.md:4`, `_pages/about.md:4`, `_pages/publications.md:4` (also `news.md`, `allnews.md`, `contact.md`, `blogs.md`, `talks.md`, `teaching.md`, `404.md`) vs `_pages/research.md:1-5`, `_pages/software.md:1-5`, `_pages/team.md:1-5`
**Issue:** Ten pages carry `sitemap: false`; the three pages rewritten in the gap-closure
work dropped the flag. Verified in the built `_site/sitemap.xml`: exactly 3 URLs —
`research/`, `software/`, `team/`. The site's most important URL
(`https://zhangtaolab.org/`) and About/Publications are missing, while `robots.txt`
advertises `Sitemap: …/sitemap.xml` and the `jekyll-sitemap` plugin is installed and
configured. This is accidental drift between sibling pages (not a policy), defeating the
plugin for the highest-value pages.
**Fix:** Remove `sitemap: false` from the canonical pages (at minimum `home.md`,
`about.md`, `publications.md`, `news.md`, `contact.md`) so all real pages appear in the
sitemap; keep it only on true duplicates/`404`/placeholder pages (`blogs`, `talks`,
`teaching` if they stay empty).

### WR-04: PI education stored in two data files, read by two different templates

**File:** `_pages/about.md:27-30` (reads `site.data.pi[0].education` from `_data/pi.yml:2`) vs `_pages/team.md:15,37-43` (reads the same fact from `_data/team_members.yml:10`)
**Issue:** The identical string "Ph.D. University of Electronic Science and Technology of
China" is stored in both `_data/pi.yml` and `_data/team_members.yml`; About reads one copy,
Team the other. A maintainer updating the documented roster file (`team_members.yml`) — the
project's core-value workflow — silently leaves the About page stale.
**Fix:** Point `about.md` at the same source `team.md` uses:
```liquid
{% assign pi = site.data.team_members | where: "role", "pi" | first %}
…
{% for edu in pi.education %}
```
(or migrate `_data/pi.yml` consumers and delete the file).

### WR-05: `vendor/` still not excluded from the site build (carried unfixed through two review rounds)

**File:** `_config.yml:93-103`
**Issue:** The `exclude:` list has no `vendor` entry. `.gitignore:8` covers git, not the
site copy. Phase 2 will deploy via GitHub Actions full builds (project constraint); CI
setups that install gems under `./vendor/bundle` (the common Bundler cache/deployment path)
will copy the entire gem tree into `_site/` and publish it to zhangtaolab.org. Flagged as
CR-01 on 2026-08-17 and again as WR-06 in the prior round — still unfixed after this
phase's config work.
**Fix:**
```yaml
exclude:
  - vendor
  - vendor/bundle
  # … existing entries
```

### WR-06: Two duplicate News pages at different URLs, with in-scope artifacts linking to different copies

**File:** `_pages/allnews.md:1-7` vs `_pages/news.md:1-7`; consumers `_includes/sidebar.html:26` (→ `/news/`) and `feed.xml:28` (→ `/allnews.html`)
**Issue:** Both pages render the identical `site.data.news` list; they differ only in a
`section-card` wrapper. Site visitors land on `/news/`, feed subscribers land on
`/allnews.html`. `head.html:29` emits a self-canonical for every page, so both URLs claim
to be canonical — duplicate-content signal for crawlers and a maintenance trap (edits to
one page's markup won't reach the other's audience). Upgraded from the prior round's Info
because both divergent consumers are in this review's scope.
**Fix:** Pick one canonical news URL (recommend `/news/`), point `feed.xml:28` at it, and
delete or redirect `_pages/allnews.md`.

## Info

### IN-01: `target="_blank"` links without `rel="noopener noreferrer"`

**File:** `_pages/software.md:9,34,49,64,77,92,109,124,139,149`, `_pages/home.md:28-29`, `_pages/about.md:43,48`, `_pages/research.md:36,80`, `_data/news.yml:2,5,8,11,14`
**Issue:** Verified in `_site/`: 13 bare `target="_blank"` anchors on the software page
alone, 5 on the home page, zero `rel` attributes anywhere. Modern browsers imply
`noopener`, so this is hygiene (reverse tabnabbing on older browsers), not an open vuln.
**Fix:** Add `rel="noopener noreferrer"` to external links (one-time pass, or a shared
link snippet).

### IN-02: Unescaped Liquid output in attribute and content contexts

**File:** `_includes/head.html:5,9,15` (`site.description` in meta/og/twitter `content` attrs), `_pages/team.md:25` (`alt="{{ pi.name }}"`)
**Issue:** No `| escape`, while sibling outputs in the same files (`{{ page.title | escape }}`)
are escaped. Maintainer-controlled values today, so no live bug; a future value containing
`"` or `>` breaks the attribute silently.
**Fix:** `content="{{ site.description | escape }}"`, `alt="{{ pi.name | escape }}"`.

### IN-03: JSON-LD uses HTML escaping inside JSON strings and mislabels Person fields

**File:** `_includes/head.html:65-83`
**Issue:** (a) `| escape` inside `<script type="application/ld+json">` emits HTML entities
as literal JSON text (script bodies are not entity-decoded) — harmless for current values,
wrong the day a title/description contains `&` or `"`. (b) Semantically the `Person` is
named "Zhang Tao Lab" with `jobTitle: "Bioinformatics, Epigenetics and Genomics"` —
`site.title` is a research field, not a job title.
**Fix:** Emit the object via a `to_json`-style filter or `| replace: '"', '\"'`; map real
person-name/job-title keys from dedicated config entries.

### IN-04: `papers/ref.bib` is published into the site output

**File:** `_config.yml:93-103` (exclude list)
**Issue:** Verified: `_site/papers/ref.bib` exists — the raw BibTeX source ships to
zhangtaolab.org. jekyll-scholar reads the bibliography at source-render time, so excluding
`papers` does not break citation rendering (re-verify the build after changing). Content
is public bibliography data — hygiene, not confidentiality.
**Fix:** Add `- papers` to `exclude:`.

### IN-05: News and alumni data contradict each other on Liu Guanqing's timeline

**File:** `_data/news.yml:17` vs `_data/alumni.yml:1-3`
**Issue:** June 2023 news welcomes "new PhD students Liu Guanqing and Wu Yuechao", but
`alumni.yml` records Liu Guanqing's period as 2017–2025 — a PhD starting four years before
its own "welcome" announcement. One record (or the wording) is wrong.
**Fix:** Correct the wrong record (e.g. reword the 2023 item as a milestone, or adjust the
alumni start year).

### IN-06: Recruitment card disappears when no students exist; singular section heading

**File:** `_pages/team.md:78-84` (nested inside `{% if students.size > 0 %}` at line 65), heading at `:50`
**Issue:** The "Join Us!" card is inside the students-only conditional — if the lab has
zero students, the recruiting CTA vanishes while the page still opens with "We are looking
for new team members!" (line 13). "Current Member" (line 50) is singular but loops over
`staff`.
**Fix:** Move the Join Us card outside the students conditional; use "Current Members" or
pluralize intentionally.

### IN-07: MathJax loaded on every page with single-dollar inline delimiters

**File:** `_includes/head.html:59` (unconditional `{% include mathjax.html %}`); `_includes/mathjax.html:4` (`inlineMath: [ ['$', '$'], … ]`)
**Issue:** Any future prose containing two lone dollar amounts ("costs $5 … budget $10")
will be silently typeset as math on every page (contact, team, news included).
**Fix:** `{% if page.math %}{% include mathjax.html %}{% endif %}` with `math: true` on
pages that need it, or narrow inline delimiters to `\(...\)`.

### IN-08: research.md hardcodes the accent color and keeps a dead CSS rule

**File:** `_pages/research.md:8,19`
**Issue:** Line 8 `:root { --accent: #2d6a4f; … }` duplicates `_config.yml:25`
(`accent_color`), which `head.html:35-39` already injects as `--accent` — if the config
color is ever changed, the research page silently keeps moss green. Line 19 hides
`.research-thumb`, a class that appears nowhere in the page's markup (cards use `.img-wrap`)
— leftover from the pre-relayout template.
**Fix:** Delete the `:root` override (the head-injected `--accent` already applies) and
drop the `.research-thumb` rule.

### IN-09: Config plugin list incomplete and include/exclude entries reference nonexistent paths

**File:** `_config.yml:50-52,75,93-103`
**Issue:** (a) `plugins: ["jekyll-sitemap"]` omits `jekyll-scholar`; it works only because
the Gemfile `:jekyll_plugins` group is auto-required under `bundle exec` — a direct
`jekyll build` (no Bundler) silently drops the bibliography. (b) `include:` lists
`.htaccess` (doesn't exist); `exclude:` lists `update_bootstrap.sh`, `switch_theme.sh`,
`tags`, `Rakefile`, `node_modules`, `package.json`, `package-lock.json`, `docs` — none
exist in the repo. Template-lineage leftovers that make the lists unauditable.
**Fix:** Add `jekyll-scholar` to `plugins:`; prune the no-op entries.

### IN-10: `site.photo` references `images/headshot.jpg`, which does not exist

**File:** `_config.yml:8`
**Issue:** `head.html:12,16` guards og:image/twitter:image on the file's presence in
`site.static_files`, so both meta tags are silently never emitted (verified:
`images/headshot.jpg` missing; only `banner.jpg`/`logo.png` present). Graceful, but the
config comment "place your photo in images/" is unfulfilled and social shares lose their
image. The Team page sidesteps it via `pi.photo: /images/logo.png`
(`_data/team_members.yml:5`).
**Fix:** Add a real `images/headshot.jpg`, or point `photo:` at an existing image (e.g.
`logo.png`), or remove the key and the dead meta-tag branches.

---

_Reviewed: 2026-08-18T05:32:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
