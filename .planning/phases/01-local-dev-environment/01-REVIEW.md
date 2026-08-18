---
phase: 01-local-dev-environment
reviewed: 2026-08-18T01:09:37Z
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
  info: 9
  total: 16
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-08-18T01:09:37Z
**Depth:** standard
**Files Reviewed:** 14
**Status:** issues_found

## Summary

Reviewed the 14 files from Phase 01's two workstreams: local dev environment (`.gitignore`,
`Gemfile.lock`, `_config.yml`, `feed.xml`) and the gap-closure content alignment
(`_pages/*.md`, `_data/*.yml`, `_includes/head.html`, `_includes/sidebar.html`).

Beyond static reading, findings were verified empirically:

- `git ls-remote` against both candidate PDLLMs repos (one 404s, one exists) — basis of CR-01.
- Ruby 4.0.6 + installed Liquid 4.0.4: `false | default: true` renders `"true"` — basis of WR-03.
- The freshly built `_site/` (built 09:01, after the last source edit) was inspected:
  `feed.xml`, `about/index.html`, `team/index.html`, `index.html`, `sitemap.xml`, `papers/`.
- Jekyll 4.4.1 gem source checked: `StaticFile#name` includes the file extension, so
  `head.html`'s `where: "name", site.photo` og:image guard is correct (no false positive raised).
- All images referenced by `research.md`/`software.md`/`home.md` exist; favicon.svg/ico exist;
  `images/headshot.jpg` is absent, which the `photo_file` guard handles gracefully.

High-level: the templates are coherent and render correctly, but (1) the About page links the
flagship project to a nonexistent GitHub repo while every other page uses the real one;
(2) `feed.xml` emits news items that are indistinguishable from each other (identical `<link>`,
no `<guid>`) with escaped HTML soup in titles; (3) a Liquid `default:` logic error makes
`dark_mode: false` unenforceable; (4) the prior review's `vendor` exclusion warning is still
unfixed in `_config.yml`.

Out-of-scope per phase context (not flagged): `assets/main.css`/`main.scss` output conflict,
empty talks/teaching bibliography queries, CDN font host choices, deliberately-unadopted
reference-site template defects.

## Critical Issues

### CR-01: About page links PDLLMs to a nonexistent GitHub repository

**File:** `_pages/about.md:43, 48`
**Issue:** Both PDLLMs links on the About page point to
`https://github.com/zhangtaolab/PDLLMs` (lines 43 and 48). Verified via `git ls-remote`:
that repository does not exist (404 / credential prompt), while
`https://github.com/zhangtaolab/Plant_DNA_LLMs.git` exists (HEAD `a4bf59e`). Every other
in-scope file uses the correct repo: `home.md:28`, `research.md:24`, `software.md:51`.
The About page is the page that introduces the lab's flagship project — both of its
prominent links (research-interests list + featured-work callout) are dead for visitors.
**Fix:**
```diff
- <li><strong>Open-source tool development</strong> — making our models and tools freely available via <a href="https://github.com/zhangtaolab/PDLLMs" target="_blank">PDLLMs</a></li>
+ <li><strong>Open-source tool development</strong> — making our models and tools freely available via <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs</a></li>

- ... <a href="https://github.com/zhangtaolab/PDLLMs" target="_blank"><i class="fa-brands fa-github"></i> Get PDLLMs on GitHub</a></p>
+ ... <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank"><i class="fa-brands fa-github"></i> Get PDLLMs on GitHub</a></p>
```

## Warnings

### WR-01: All news feed items share one link and have no guid — items are indistinguishable

**File:** `feed.xml:21-30`
**Issue:** Verified in `_site/feed.xml`: every news `<item>` has the identical
`<link>https://zhangtaolab.org/allnews.html</link>` and no `<guid>` element. RSS readers key
items on guid, falling back to link+title; with a shared link and no guid, readers commonly
collapse, dedupe, or mis-update items (e.g. treating the May-2026 Nature Comms item and the
March-2026 item as the same article, or re-alerting on every headline edit). The posts loop
(lines 13-19) does this correctly with `<guid isPermaLink="true">`; the news loop omits it.
**Fix:**
```liquid
{% for article in site.data.news limit:20 %}
<item>
  <title>{{ article.headline | strip_html | xml_escape }}</title>
  <description>{{ article.headline | strip_html | xml_escape }}</description>
  <guid isPermaLink="false">news-{{ forloop.index }}-{{ article.headline | strip_html | uri_escape | truncate: 60 }}</guid>
  ...
```
Or link each item to its anchor on the news page (`/allnews.html#news-{{ forloop.index }}`
with matching `id`s added in the news templates).

### WR-02: Feed titles/descriptions contain fully escaped HTML markup

**File:** `feed.xml:23-24`
**Issue:** Verified in `_site/feed.xml`: `<title>` for news items is the entire headline
markup HTML-escaped, e.g. `<title>&lt;a href=&quot;https://github.com/...&quot; ...&gt;DNALLM-Suite&lt;/a&gt; — ...`.
RSS readers render titles/descriptions as text, so subscribers see literal
`<a href="...">DNALLM-Suite</a> — ...` soup, and the `&rarr;` entity double-escapes to a
literal `&amp;rarr;`. Titles should be plain text.
**Fix:** Strip markup before escaping:
```liquid
<title>{{ article.headline | strip_html | xml_escape }}</title>
<description>{{ article.headline | strip_html | xml_escape }}</description>
```

### WR-03: `dark_mode: false` can never disable the pre-paint theme script

**File:** `_includes/head.html:44`
**Issue:** `var darkMode = {{ site.dark_mode | default: true }};` — Liquid's `default`
filter substitutes on `nil`, empty, **and `false`** (verified on the installed Liquid:
`false | default: true` renders `"true"`). So a maintainer setting `dark_mode: false` in
`_config.yml` gets `var darkMode = true;` — the early-return guard never fires and the
script still reads/applies `data-bs-theme` — while `header.html` (`{% if site.dark_mode %}`)
correctly hides the toggle. Config currently says `true`, so this is latent, but the config
comment ("show dark mode toggle in navbar") promises the setting works both ways.
**Fix:**
```liquid
{% assign dark_mode_enabled = site.dark_mode %}
{% if dark_mode_enabled == nil %}{% assign dark_mode_enabled = true %}{% endif %}
...
var darkMode = {{ dark_mode_enabled }};
```
(only `nil` falls back to the default; explicit `false` now wins).

### WR-04: Homepage and About excluded from sitemap while sibling pages are included

**File:** `_pages/home.md:4`, `_pages/about.md:4` (vs `_pages/research.md:1-5`, `_pages/software.md:1-5`, `_pages/team.md:1-5`)
**Issue:** `home.md` and `about.md` carry `sitemap: false`; the three pages rewritten in the
gap-closure work (`research.md`, `software.md`, `team.md`) dropped the flag. Verified in
`_site/sitemap.xml`: it contains exactly 3 URLs (research/, software/, team/) — the site's
most important URL (`https://zhangtaolab.org/`) and the About page are missing. This is
inconsistent metadata across sibling pages (accidental drift, not a policy) and hurts SEO
for the two highest-value pages.
**Fix:** Pick one policy. Recommended: remove `sitemap: false` from `home.md` and `about.md`
(and the other pages that carry it) so all canonical pages appear in the sitemap.

### WR-05: PI education maintained in two data files read by two different templates

**File:** `_pages/about.md:27-30` (reads `site.data.pi[0].education` from `_data/pi.yml`) vs `_pages/team.md:15, 37-43` (reads the same fact from `site.data.team_members.yml`)
**Issue:** The identical string "Ph.D. University of Electronic Science and Technology of
China" is stored in both `_data/pi.yml:2` and `_data/team_members.yml:10`, and the About
and Team pages each read a different copy. A maintainer updating the PI's education (per the
project's core value of low-cost content updates, the documented roster file is
`_data/team_members.yml`) will silently leave the About page stale. This predates the phase
but the rewrite cemented the split.
**Fix:** Point `about.md` at the same source `team.md` uses:
```liquid
{% assign pi = site.data.team_members | where: "role", "pi" | first %}
...
{% for edu in pi.education %}
```
(or migrate `_data/pi.yml` consumers and delete the file).

### WR-06: `vendor/` still not excluded from the site build (carried from prior review, unfixed)

**File:** `_config.yml:93-103`
**Issue:** The exclude list contains no `vendor` entry. This was flagged as CR-01 in the
previous review of this phase (2026-08-17) and remains unfixed. If Phase 2 CI installs gems
under `./vendor` (e.g. `bundle install --path vendor/bundle`), the entire gem tree gets
copied into `_site/` and deployed to zhangtaolab.org. `.gitignore:8` covers git, not the
site copy.
**Fix:** Add to the `exclude:` list:
```yaml
exclude:
  - vendor
  - vendor/bundle
  # ... existing entries
```

## Info

### IN-01: `target="_blank"` links without `rel="noopener noreferrer"`

**File:** `_pages/software.md:36` (and 9, 51, 66, 79, 98, 119, 134, 153), `_pages/home.md:28-29`, `_pages/about.md:43, 48`, `_pages/research.md:24, 64`, `_data/news.yml:2, 5, 8, 11, 14`
**Issue:** 25 rendered `target="_blank"` anchors across the built pages carry no `rel`
attribute (verified by grep of `_site/`). Modern browsers implicitly apply `noopener` to
`target="_blank"`, so this is hygiene only (older browsers allow reverse tabnabbing).
**Fix:** Add `rel="noopener noreferrer"` to external links, e.g. via a shared snippet or a
one-time pass over the pages/data files.

### IN-02: Unescaped Liquid output in attribute and content contexts

**File:** `_includes/head.html:5, 9, 15` (`site.description` in meta/og/twitter content attrs), `_pages/team.md:25` (`alt="{{ pi.name }}"`)
**Issue:** These outputs have no `| escape`. Values are maintainer-controlled config/data
today, so no live bug, but a future value containing `"` or `>` breaks the attribute/HTML
silently. The sibling outputs in the same files (`{{ page.title | escape }}`) are escaped,
so this is inconsistent rather than intentional.
**Fix:** `content="{{ site.description | escape }}"`, `alt="{{ pi.name | escape }}"`.

### IN-03: JSON-LD uses HTML escaping inside JSON strings and mislabels Person fields

**File:** `_includes/head.html:65-83`
**Issue:** (a) `{{ ... | escape }}` inside `<script type="application/ld+json">` emits HTML
entities (`&amp;`) as literal JSON text (script contents are not entity-decoded) — harmless
for current values but wrong if a title/description ever contains `&`. (b) Semantically, the
Person is named "Zhang Tao Lab" (an organization-style name) with
`jobTitle: "Bioinformatics, Epigenetics and Genomics"` (site.title is a research field, not
a job title).
**Fix:** Use `| json_escape`-style output (`{{ site.title | escape }}` →
`{{ site.title | replace: '"', '\"' }}` or a `| to_json` filter on the whole object), and
map the real person name / job title fields from dedicated config keys.

### IN-04: Sidebar and feed link to two different duplicate news pages

**File:** `_includes/sidebar.html:26` (→ `/news/`) vs `feed.xml:28` (→ `/allnews.html`)
**Issue:** `_pages/news.md` and `_pages/allnews.md` both exist and render the identical
`site.data.news` list at two URLs; in-scope files point at different copies. Both have
`sitemap: false` (mitigating SEO duplication), but it is confusing to maintain and dilutes
feed-item links (see WR-01).
**Fix:** Pick one canonical news URL (e.g. `/news/`), point `feed.xml` at it, and delete or
redirect the other page.

### IN-05: `papers/ref.bib` is published into the site output

**File:** `_config.yml:93-103` (exclude list)
**Issue:** Verified: `_site/papers/ref.bib` exists. The `papers/` directory is not excluded,
so the raw BibTeX source ships to zhangtaolab.org. jekyll-scholar reads the bibliography
directly from source regardless of `exclude`, so excluding it does not break rendering
(re-verify the build after the change). Content is public bibliography data — hygiene, not
confidentiality.
**Fix:** Add `- papers` to `exclude:`.

### IN-06: News and alumni data contradict each other on Liu Guanqing's timeline

**File:** `_data/news.yml:17` vs `_data/alumni.yml:1-3`
**Issue:** The June 2023 news item welcomes "new PhD students Liu Guanqing and Wu Yuechao",
but `alumni.yml` records Liu Guanqing's period as 2017–2025 (a 6-year PhD period starting
four years before the "welcome" announcement). One of the two records is wrong or the
wording predates his PhD start.
**Fix:** Correct whichever record is wrong (likely reword the 2023 item, e.g. passing
qualifying exam, or adjust the alumni start year).

### IN-07: Recruitment card disappears when no students exist; singular section heading

**File:** `_pages/team.md:78-84` (nested inside `{% if students.size > 0 %}` at line 65), heading at `:50`
**Issue:** The "Join Us!" recruiting card is inside the students-only conditional — if the
lab temporarily has zero students, the recruiting call-to-action vanishes even though the
page still opens with "We are looking for new team members!" (line 13). Also "Current
Member" (line 50) is singular while it loops over `staff` (multiple members would render
under a singular heading).
**Fix:** Move the Join Us card outside the `{% if students.size > 0 %}` block (render it
unconditionally, or gate on `staff.size == 0 or students.size == 0` logic that always
includes recruiting), and use "Current Members" / pluralize intentionally.

### IN-08: MathJax loaded on every page with single-dollar inline delimiters

**File:** `_includes/head.html:59` (includes `mathjax.html` unconditionally)
**Issue:** `mathjax.html` config enables `$...$` inline math and is included on every page
(contact, team, news included). Any future prose containing two lone dollar amounts
("costs $5 ... budget $10") will be silently typeset as math. CDN/weight concerns are out of
scope; the delimiter-misparse hazard is the correctness concern.
**Fix:** Restrict the include to pages that declare `math: true` in front matter
(`{% if page.math %}{% include mathjax.html %}{% endif %}`), or narrow inline delimiters to
`\(...\)`.

### IN-09: Dead include/exclude entries referencing nonexistent paths

**File:** `_config.yml:50-52, 93-103`
**Issue:** `include: [.htaccess]` — no `.htaccess` exists. `exclude:` lists
`update_bootstrap.sh`, `switch_theme.sh`, `tags`, `Rakefile`, `node_modules`, `package.json`,
`package-lock.json`, `docs` — none exist in the repo (template lineage leftovers, noted as
harmless in the prior review but still present after this phase's config work).
**Fix:** Prune the no-op entries (or leave `Gemfile`/`Gemfile.lock` which are intentional)
so the exclude list's meaning stays auditable.

---

_Reviewed: 2026-08-18T01:09:37Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
