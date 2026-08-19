# Phase 2: 自动部署 - Pattern Map

**Mapped:** 2026-08-19
**Files analyzed:** 12 (2 new, 10 modified/deleted)
**Analogs found:** 10 / 12 — the 2 new files (`deploy.yml`, `ci-smoke.sh`) have no in-repo analog (`.github/` and `scripts/` do not exist); their patterns come from RESEARCH.md's verified official starter workflow (Pattern 1) and assertion script (Pattern 2). All 10 modified/deleted files are their own analog — this phase is in-place edits with research-verified exact line targets.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `.github/workflows/deploy.yml` (new) | config (CI pipeline) | batch (build→deploy) | actions/starter-workflows `pages/jekyll.yml` (RESEARCH.md Pattern 1, cited verbatim) | external-exact |
| `scripts/ci-smoke.sh` (new) | utility (test) | batch (assertions) | RESEARCH.md Pattern 2 draft script | external-exact |
| `_config.yml` | config | — | itself (D-10 target: `exclude` list) | self |
| `.gitignore` | config | — | itself (line 8 `vendor/bundle`) | self |
| `feed.xml` | template (XML feed) | transform | itself; in-file posts loop lines 17-18 is the guid/link pattern to mirror | self |
| `_includes/head.html` | template (include) | — | itself (line 44) | self |
| `_pages/{home,about,publications,news,contact,blogs,teaching,talks}.md` (8 files) | content | — | `_pages/research.md` / `software.md` / `team.md` (the 3 pages already in sitemap — same frontmatter minus `sitemap: false`) | role-match |
| `_pages/allnews.md` | content | — | DELETED (D-13); `_pages/news.md` is the kept twin | self |
| (repo ops: branch/API changes, D-15/D-16/D-17/D-18) | operations | event-driven (push-triggered) | none — gh api commands per RESEARCH.md Runtime State Inventory | none |

## Pattern Assignments

### `.github/workflows/deploy.yml` (new, config/CI)

**No in-repo analog** — `.github/` does not exist (verified). Copy the official starter verbatim from RESEARCH.md Pattern 1 (lines 200-249 of 02-RESEARCH.md), with exactly these adaptations (each sourced in RESEARCH.md):

- `on.push.branches: [main]` (D-06)
- Delete `ruby-version: '3.1'` line — setup-ruby auto-reads `.ruby-version` (D-07)
- Add `workflow_dispatch.inputs.deploy` typed boolean (D-09/D-16):

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      deploy:
        description: 'Deploy after build+assert (bypasses DEPLOY_ENABLED for first launch)'
        type: boolean
        default: false
```

- Insert smoke-assert step at end of build job, before upload artifact:

```yaml
      - name: Smoke assertions
        run: |
          sudo apt-get install -y libxml2-utils
          scripts/ci-smoke.sh _site
```

- Deploy job gate (D-16):

```yaml
  deploy:
    if: vars.DEPLOY_ENABLED == 'true' || inputs.deploy == true
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub
        id: deployment
        uses: actions/deploy-pages@v5
```

- Keep `concurrency: group "pages", cancel-in-progress: false` (official value; do NOT cancel in-progress production deploys)
- Keep `--baseurl "${{ steps.pages.outputs.base_path }}"` and `JEKYLL_ENV: production`
- Action versions per starter combo: `checkout@v4` / `setup-ruby@v1` / `configure-pages@v5` / `upload-pages-artifact@v3` / `deploy-pages@v5`

### `scripts/ci-smoke.sh` (new, utility/test)

**No in-repo analog.** Copy RESEARCH.md Pattern 2 script (lines 296-318) as-is: `set -euo pipefail`, four assertions (sitemap `grep -c "<loc>"` `-ge 10`; publications anchor `grep -q "s41467-026-73769-8" _site/publications/index.html`; `xmllint --noout _site/feed.xml`; vendor tripwire `[ ! -d "$SITE/vendor" ]`). Must be executable (`chmod +x`) and runnable identically locally and in CI.

### `_config.yml` (config) — D-10

**Analog: itself.** Current `exclude` block at lines 93-103 (read this session). Change: append `- vendor` to the list (after `- docs`, line 103). Do not touch any other key. Reference lines 28-29 (`baseurl: ""` / `url: "https://zhangtaolab.org"`) confirm no path changes needed for CI.

### `.gitignore` (config) — D-10

**Analog: itself.** Line 7-8 currently:

```
# Bundler
vendor/bundle
```

Change `vendor/bundle` (line 8) to `vendor/`.

### `feed.xml` (template/transform) — D-13/D-14

**Analog: itself.** Two edits, both with in-file precedent:

1. News item link (line 28): `{{ site.url }}{{ site.baseurl }}/allnews.html` → `/news/`
2. Add guid after line 28, mirroring the posts-loop pattern at lines 17-18:

```liquid
{% for post in site.posts limit:20 %}
<link>{{ post.url | prepend: site.baseurl | prepend: site.url }}</link>
<guid isPermaLink="true">{{ post.url | prepend: site.baseurl | prepend: site.url }}</guid>
```

News items have no URL field (`_data/news.yml` = date + headline only), so use non-permalink guid per RESEARCH.md Pattern 3/D-14:

```liquid
<link>{{ site.url }}{{ site.baseurl }}/news/</link>
<guid isPermaLink="false">news-{{ forloop.index }}-{{ article_date | date_to_xmlschema | default: 'latest' }}</guid>
```

Keep existing `strip_html | xml_escape` filters and the `article_date == "Latest"` fallback (lines 25-26) untouched.

### `_includes/head.html` (template) — D-12

**Analog: itself.** Single-line edit at line 44:

```liquid
var darkMode = {{ site.dark_mode | default: true }};
```

→

```liquid
var darkMode = {{ site.dark_mode | default: true, allow_false: true }};
```

### 8 content pages `_pages/{home,about,publications,news,contact,blogs,teaching,talks}.md` — D-11

**Analog: `_pages/research.md` / `software.md` / `team.md`** — the 3 pages already emitting sitemap URLs. Their frontmatter is identical to the blacklisted pages minus the `sitemap: false` line. Target pattern per page: delete line 4 `sitemap: false` from frontmatter, keep all other fields (`title`, `layout`, `permalink`) exactly as-is. Example current frontmatter (`_pages/home.md` lines 1-6):

```yaml
---
title: "Home"
layout: homelay
sitemap: false      # ← delete this line
permalink: /
---
```

Keep `sitemap: false` in `_pages/404.md` (excluded from D-11). Expected result: sitemap 3 → 11 URLs.

### `_pages/allnews.md` — D-13 (DELETE)

**Analog: itself / `_pages/news.md`** (verified 100% same body: `site.data.news` full loop, lines 12-17). Delete the whole file. After deletion, `grep -r allnews` must return only the `feed.xml` link (fixed above) — sidebar already points at `/news/` (`_includes/sidebar.html:26`).

## Shared Patterns

### Frontmatter conventions
**Source:** all `_pages/*.md`
**Apply to:** any page touched this phase. YAML block order: `title` → `layout` → `sitemap` (optional) → `permalink`. No new pages are created this phase; only line deletions.

### Liquid safety filters
**Source:** `feed.xml` lines 23-24
**Apply to:** all XML output — `| strip_html | xml_escape` on any user-data string. New `<guid>` uses only `date_to_xmlschema` on `article_date` (already string data) — no escaping needed but do not introduce raw headlines.

### CI assertion philosophy
**Source:** RESEARCH.md Pattern 2 + Pitfalls 5/7
**Apply to:** `ci-smoke.sh` only. Threshold assertions (`-ge 10`), never exact counts; anchor proves publications page rendered, NOT that scholar ran (scholar failure = build error via unknown `{% bibliography %}` tag); do not assert on talks page list emptiness.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `.github/workflows/deploy.yml` | config | batch | No `.github/` in repo — greenfield; use RESEARCH.md Pattern 1 official starter (cited verbatim) |
| `scripts/ci-smoke.sh` | utility | batch | No `scripts/` in repo — greenfield; use RESEARCH.md Pattern 2 |
| Repo/ops tasks (D-15 sequence, D-16 variable, D-17 branch cleanup, D-18 publication audit) | operations | event-driven | Not files; commands fully specified in RESEARCH.md Runtime State Inventory + CONTEXT D-15~D-18. Order is locked and must not be rearranged |

## Metadata

**Analog search scope:** repo root, `_pages/`, `_includes/`, `_config.yml`, `feed.xml`, `.gitignore`; confirmed `.github/` and `scripts/` absent
**Files read this session:** `feed.xml`, `_config.yml`, `_includes/head.html`, `.gitignore`, `_pages/home.md`, `_pages/allnews.md`
**Pattern extraction date:** 2026-08-19
