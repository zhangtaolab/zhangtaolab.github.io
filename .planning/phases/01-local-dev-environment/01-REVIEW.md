---
status: issues
files_reviewed:
  - .gitignore
  - .ruby-version
  - Gemfile
  - Gemfile.lock
  - _config.yml
  - feed.xml
counts:
  critical: 0
  warning: 2
  info: 5
  total: 7
reviewer: gsd-code-reviewer
date: 2026-08-17
---

# Phase 1 Code Review — Local Dev Environment

Scope: the 6 config/source files changed by Phase 1. Site-source onboarding (460 files) is out of
scope except where it directly interacts with the reviewed configs; one adjacent-scope issue
surfaced during build verification and is flagged as such (CR-02).

Verification performed beyond static reading:

- `bundle exec jekyll build` — succeeds (0.224s), emits one conflict warning (see CR-02); `_site/`
  contains `feed.xml`, `sitemap.xml`, `allnews.html`, `talks/`, `publications/`; no dotfiles leak.
- Ruby/Liquid date parsing empirically tested for the news date formats (`"Latest"`, `"May 2026"`).
- Jekyll 4.4.1 default `exclude` confirmed `[]` via the installed gem (relevant to CR-01).
- jekyll-scholar 7.3.0 template resolution read from installed gem source
  (`lib/jekyll/scholar/utilities.rb`): `bibliography_template` resolves against `_layouts/`, not
  `_includes/`; `_layouts/bibtemplate.html` exists, so the scholar config is coherent.
- Lockfile dependency tree audited against Ruby 4.x default-gem removals — see verification notes.

## Findings

### CR-01 — `vendor` not excluded from site build (Phase 2 deploy-leak risk)

- **severity:** warning
- **file:** `_config.yml`
- **line:** 93-103
- **description:** Jekyll 4.4.1's default `exclude` is `[]` (verified against the installed gem),
  so this explicit list is the complete exclusion set, and it contains no `vendor` entry. Local
  builds are unaffected (Homebrew system gems), but if Phase 2 CI installs gems under `./vendor`
  (e.g. `bundle install --path vendor/bundle`, a common GitHub Actions pattern), the entire gem
  tree would be copied into `_site` and deployed to zhangtaolab.org. The `.gitignore` covers
  `vendor/bundle` for git but nothing covers it for the site copy.
- **suggested fix:** Add `vendor/bundle` (or `vendor`) to the `exclude:` list in `_config.yml`.
  One line, zero effect on local builds, closes the Phase 2 leak.

### CR-02 — Compiled/static CSS output conflict (adjacent scope, surfaced by build)

- **severity:** warning
- **file:** `_config.yml` (fix location); conflict is between `assets/main.scss` and
  `assets/main.css` (onboarded site source — outside this review's 6 files)
- **line:** 93 (exclude block)
- **description:** The verification build emits:
  `Conflict: _site/assets/main.css is shared by assets/main.scss and assets/main.css — the written
  file may end up with unexpected contents.` Jekyll writes static files after converted pages, so
  the committed static `assets/main.css` wins over the compiled SCSS output. Today the two are
  byte-identical (md5 `3fc61f201993510cf31d4f0f75100d00`), so there is no visible harm, but any
  future edit to `assets/main.scss` without recompiling and recommitting `assets/main.css` would
  silently ship the stale stylesheet in Phase 2 deploys.
- **suggested fix:** Either delete the committed `assets/main.css` build artifact (preferred — it
  is generated output), or add `assets/main.css` to `exclude:` so only the SCSS-compiled version
  ships. Route to whichever phase owns the site-source files if not fixable here.

### CR-03 — `rack` gem appears unused

- **severity:** info
- **file:** `Gemfile`
- **line:** 5
- **description:** `gem "rack", ">= 2.2.3"` locks to rack 3.2.7, but nothing in the dependency
  tree requires rack — Jekyll 4.4 serves via webrick. Dead weight in the bundle (harmless, just
  installed bytes in CI).
- **suggested fix:** Remove the line, or keep if Phase 2 tooling is expected to need it. No
  functional impact either way.

### CR-04 — Scholar chain is configured correctly but currently renders nothing

- **severity:** info
- **file:** `_config.yml`
- **line:** 77-91
- **description:** The post-surgery scholar config is coherent: `source: /papers/` resolves
  (build passes), `style: apa` is provided by csl-styles, `bibliography_template: bibtemplate`
  resolves to the existing `_layouts/bibtemplate.html` (jekyll-scholar looks in `_layouts/`, not
  `_includes/`), and the removed `details_*` keys have no dangling references. However,
  `papers/ref.bib` contains only 12 `@article` entries with no `keywords` fields, and the only
  `{% bibliography %}` consumers are `_pages/talks.md`'s two `@incollection[keywords ...]`
  queries — which match zero entries. So talks renders empty and no page currently exercises the
  scholar rendering path (publications are hardcoded markdown). Not a Phase 1 defect; flagging so
  content maintainers know talks will stay empty until `@incollection` entries with `keywords`
  are added to the bib.
- **suggested fix:** No config change needed. Optionally note in maintainer docs, or add a couple
  of `@incollection` talks entries when convenient.

### CR-05 — feed.xml date fallback: timezone varies with build machine

- **severity:** info
- **file:** `feed.xml`
- **line:** 25-27
- **description:** The `Latest` → `site.time` fallback works as intended (verified in built
  output: `Mon, 17 Aug 2026 17:18:20 +0800`). Month-year strings like `"May 2026"` parse
  deterministically to day 1 via Liquid (`Fri, 01 May 2026 00:00:00 +0800`) — valid RFC822. The
  only nondeterminism is the offset: local builds produce `+0800`, a UTC CI runner will produce
  `+0000`, shifting pubDates by 8h between builds. Valid RSS either way.
- **suggested fix:** None required. If byte-stable feeds across local/CI are ever wanted, parse
  with an explicit timezone (e.g. `| append: " +0800"` style normalization or a custom filter).

### CR-06 — feed.xml: news entry without `date` would emit empty `<pubDate/>`

- **severity:** info
- **file:** `feed.xml`
- **line:** 25-27
- **description:** The fallback handles the literal `"Latest"` sentinel only. If a future
  `_data/news.yml` entry omits `date` entirely, `date_to_rfc822` on nil produces an empty
  `<pubDate></pubDate>` (technically invalid RSS). All current entries have a `date` key, so
  this is latent robustness only. Note unparseable date strings would also pass through raw —
  but escaped headlines keep that XML-safe.
- **suggested fix:** Broaden the guard to `{% unless article.date %}{% assign article_date =
  site.time %}{% endunless %}` or omit the `<pubDate>` element when no date exists.

### CR-07 — `.gitignore`: optionally broaden vendor pattern

- **severity:** info
- **file:** `.gitignore`
- **line:** 8
- **description:** Coverage is otherwise correct and complete for the stated purposes: Jekyll
  artifacts (`_site/`, `.jekyll-cache/`, `.jekyll-metadata`), Bundler (`.bundle/`), macOS
  (`.DS_Store`), GSD state (`.gsd/`); and it correctly does NOT ignore `Gemfile.lock` (verified
  via `git check-ignore`), which Phase 2 CI needs for reproducible installs. Minor: `vendor/bundle`
  covers only one path variant — `vendor/cache` and `vendor/ruby` used by some CI setups would not
  be ignored. `.claude/` contains only the intentionally-committed CLAUDE.md, so nothing else
  needs adding there.
- **suggested fix:** Optionally change `vendor/bundle` to `vendor/`. Cosmetic.

## Verification Notes (things checked and found correct)

- **Gemfile plugin group**: `jekyll-scholar` + `jekyll-sitemap` in `:jekyll_plugins` — correct;
  both load via `bundle exec` (plugins list in `_config.yml` naming only sitemap is fine since the
  group covers scholar). Sitemap verified generated at `_site/sitemap.xml`.
- **Ruby 4.x default-gem removals fully covered**: every formerly-default gem in the dependency
  tree (csv, base64, bigdecimal, observer, logger, date, json, open-uri, set, singleton, stringio,
  time, uri, racc, rexml, forwardable) appears as a properly locked spec via declared dependencies
  of jekyll / jekyll-scholar's chain / google-protobuf. The explicit Gemfile entries (csv, base64,
  bigdecimal, observer, webrick) are partly redundant with those declared deps but are the right
  insurance against future dependency drops.
- **Gemfile.lock CI readiness**: PLATFORMS includes `aarch64-linux-gnu` and `x86_64-linux-gnu`
  (GitHub Actions ubuntu runners) plus a `ruby` fallback platform, and a CHECKSUMS section
  (supply-chain integrity). BUNDLED WITH 4.0.16 — Phase 2 CI must use a Ruby/Bundler pairing that
  can honor this (setup-ruby does); consistent with `.ruby-version` `4.0.6`. Unpinned
  jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 are locked with checksums, so CI installs are
  reproducible as long as the lockfile stays committed.
- **`.ruby-version`**: `4.0.6` matches local `ruby -v` (4.0.6, arm64-darwin25). Inert locally
  (Homebrew, no version manager) but correctly forward-looking for setup-ruby in Phase 2.
- **`_config.yml` url/baseurl**: `https://zhangtaolab.org` + empty baseurl — matches the custom
  domain constraint.
- **feed.xml overall**: builds cleanly; "Latest" fallback and month-year parsing both verified in
  `_site/feed.xml`; `site.name`/description escaped; `/allnews.html` link target exists in the
  built site. The `site.posts` loop is currently dead (no `_posts` directory) — harmless.
- **`exclude:` stale entries**: `update_bootstrap.sh`, `switch_theme.sh`, `Rakefile`,
  `package.json`, `package-lock.json`, `node_modules`, `docs` do not exist in the repo — harmless
  no-ops left from the template lineage; no action needed.
- **No dotfile leakage**: `.gitignore`, `.ruby-version`, `.gsd/`, `.planning/` are not copied into
  `_site` (Jekyll excludes dot entries by default; verified the built `_site` contains none).

## Verdict

No critical issues. The two warnings (CR-01, CR-02) are both Phase 2 deploy-hygiene items — a
one-line `exclude` addition each — and neither affects the Phase 1 goal of a working local
environment, which is demonstrably achieved (clean build, working feed fallback, coherent scholar
config, reproducible lockfile).
