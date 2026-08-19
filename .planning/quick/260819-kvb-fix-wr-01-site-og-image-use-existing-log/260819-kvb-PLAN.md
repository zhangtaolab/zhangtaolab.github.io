---
phase: quick-260819-kvb
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - _config.yml
autonomous: true
requirements: [WR-01]   # WR-01 = Phase 2 review finding (02-REVIEW.md:60): photo references a nonexistent file — entire site ships without og:image

estimate:
  tokens: 22000
  raw_tokens: 15000
  tasks: 2
  confidence: low   # no calibration samples for this repo; planner estimate only

must_haves:
  truths:
    - "A production build emits `<meta property=\"og:image\" content=\"https://zhangtaolab.org/images/logo.png\">` on every built HTML page (12/12, matching og:title coverage)"
    - "The same build emits `<meta name=\"twitter:image\" content=\"https://zhangtaolab.org/images/logo.png\">` on all 12 pages (same static_files guard unblocks both tags)"
    - "Zero built HTML files reference headshot.jpg"
    - "`bash scripts/ci-smoke.sh _site` prints its PASS line (all 4 assertions green)"
    - "The fix is committed locally and NOT pushed — push auto-deploys to production; orchestrator/user owns push timing"
  artifacts:
    - "_config.yml line 8 reads `photo: logo.png` (headshot.jpg value replaced)"
  key_links:
    - "_config.yml `photo` value → `_includes/head.html:12,16` static_files existence guard → emitted absolute og:image/twitter:image URL `https://zhangtaolab.org/images/logo.png` (verified live HTTP 200 per user directive)"
---

<objective>
Fix Phase 2 review WR-01 (`.planning/phases/02-auto-deploy/02-REVIEW.md:60`): `_config.yml` `photo: headshot.jpg` points to a nonexistent file, so the static_files guard in `_includes/head.html:12,16` suppresses og:image and twitter:image — the entire deployed site ships with zero social preview images.

Remedy (user directive, supersedes the review's suggested options of adding headshot.jpg or blanking the value): point `photo` at the EXISTING `images/logo.png` (37,038 bytes, in-repo; live at https://zhangtaolab.org/images/logo.png returning HTTP 200).

Planner audit result (locked-constraint check, re-provable in Task 1): `site.photo` is used ONLY at `_includes/head.html:12` (og:image) and `:16` (twitter:image) — both social-meta emissions behind the same guard. No template renders it as a visible PI headshot (the old sidebar `<img>` was removed in Phase 1 Plan 02). Therefore the minimal fix is the one-line `_config.yml` change; `_includes/head.html` is NOT modified. Mechanism pre-verified by planner probe: Jekyll static-file drop `name` for logo.png is `"logo.png"` (with extension), and `site.static_files | where: "name", "logo.png"` matches exactly 1 file, so the existing guard passes without template edits.

Purpose: every link shared from zhangtaolab.org renders with a preview image.
Output: one-line `_config.yml` change + production-build proof battery + local commit (no push).
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md

# Files this fix touches or depends on (all small; read once each)
@_config.yml
@_includes/head.html
@scripts/ci-smoke.sh

# Source finding (WR-01 entry; its suggested remedies are superseded by the user directive)
.planning/phases/02-auto-deploy/02-REVIEW.md (section "### WR-01")
</context>

<tasks>

<task type="tracer">
  <name>Task 1: Audit site.photo usage, apply minimal config fix, prove og:image end-to-end</name>
  <files>_config.yml</files>
  <precondition>images/logo.png exists in the working tree (planner verified: 37,038 bytes) and bundle install is functional (repo builds locally per Phase 1; Gemfile.lock present).</precondition>
  <action>
  Per user-locked constraint, FIRST re-prove the usage surface before editing: run
  `grep -rn "site\.photo" _includes _layouts _pages assets` — expected EXACTLY 2 hits, both in `_includes/head.html` (line 12 og:image meta, line 16 twitter:image meta), both behind the same `{% assign photo_file = site.static_files | where: "name", site.photo | first %}` existence guard. No visible/person-photo rendering exists anywhere (Phase 1 Plan 02 removed the sidebar img). If the audit unexpectedly shows MORE usages or any usage rendering site.photo as a visible PI photo/headshot, STOP — do not edit `_config.yml`; report back (fallback path would be an explicit logo.png og:image fallback inside head.html, which is out of scope for the minimal fix).
  If (and only if) the audit matches the 2-hit expectation, make the minimal edit per user directive: in `_config.yml` line 8 change the value `headshot.jpg` to `logo.png` and update the trailing comment to state it is the social preview image (og:image / twitter:image) sourced from images/. Keep the key name `photo` unchanged. Do NOT modify `_includes/head.html` — its static_files guard stays (Phase 1 decision pattern; planner probe confirmed the guard matches logo.png because a static-file drop's `name` is the filename WITH extension). Do NOT create, copy, or rename any image file — logo.png already exists. This supersedes 02-REVIEW.md WR-01's own suggested remedies per user directive.
  Then prove the fix end-to-end: run `JEKYLL_ENV=production bundle exec jekyll build` and confirm the emitted meta on the home page build output.
  </action>
  <verify>
    <automated>grep -n "^photo:" _config.yml && grep -rn "site\.photo" _includes _layouts _pages assets | wc -l && grep -rn "site\.photo" _includes | grep -c "head.html" && JEKYLL_ENV=production bundle exec jekyll build >/dev/null 2>&1 && grep -c 'property="og:image" content="https://zhangtaolab.org/images/logo.png"' _site/index.html</automated>
  </verify>
  <done>
  Audit re-proven (2 usages, both head.html social-meta tags, no visible-photo rendering). `_config.yml` line 8 reads `photo: logo.png` with an accurate comment. Production build exits 0 and `_site/index.html` contains exactly 1 og:image meta whose content is `https://zhangtaolab.org/images/logo.png`. No image files were touched; head.html is byte-identical to before.
  </done>
</task>

<task type="auto">
  <name>Task 2: Full-surface proof battery, smoke assertions, local commit — no push</name>
  <files>_site/ (regenerated build output only — gitignored; no source files modified in this task)</files>
  <action>
  With the Task 1 build in place, run the full proof battery. Every assertion must hold before committing:
  (1) og:image coverage equals og:title coverage — `grep -rl 'property="og:image"' _site --include="*.html" | wc -l` must equal `grep -rl 'property="og:title"' _site | wc -l` (both 12 on the current 11-page sitemap + allnews; 404.html included — planner confirmed all 12 built HTML pages render head.html);
  (2) twitter:image emits the same logo URL on the same 12 pages;
  (3) zero built HTML references headshot.jpg;
  (4) `bash scripts/ci-smoke.sh _site` prints its PASS line (sitemap>=10, publications DOI anchor, feed.xml xmllint-valid, no vendor leak — none of these touch og:image, so they must stay green unchanged);
  (5) `git diff --stat` shows exactly one changed file: `_config.yml`.
  Then commit ONLY `_config.yml` with a message in the established convention, e.g. `fix(quick/wr-01): point site.photo at existing logo.png so og:image/twitter:image emit`. Do NOT run git push in any form (including --dry-run is unnecessary — simply never invoke it): push to main auto-deploys to production and the orchestrator/user owns push timing. Leave the commit local.
  </action>
  <verify>
    <automated>O=$(grep -rl 'property="og:image"' _site --include="*.html" | wc -l | tr -d ' '); T=$(grep -rl 'property="og:title"' _site | wc -l | tr -d ' '); W=$(grep -rl 'name="twitter:image" content="https://zhangtaolab.org/images/logo.png"' _site --include="*.html" | wc -l | tr -d ' '); H=$(grep -rl "headshot.jpg" _site --include="*.html" | wc -l | tr -d ' '); echo "og:image=$O og:title=$T twitter:image=$W headshot_refs=$H"; [ "$O" = "$T" ] && [ "$W" = "$T" ] && [ "$H" = "0" ] && bash scripts/ci-smoke.sh _site && git diff --stat HEAD~1 HEAD | grep -c "_config.yml"</automated>
  </verify>
  <done>
  Battery green: og:image and twitter:image file counts each equal og:title coverage (12/12 pages), zero headshot.jpg references in built HTML, ci-smoke.sh prints PASS, the sole committed change is the one-line _config.yml fix, the commit exists locally, and `git log origin/main..HEAD` contains exactly the plan/fix commits with nothing pushed to origin.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| (none new) | One-line static-site config value change pointing at an existing in-repo image; no user input, no runtime, no dependency changes |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-quick-01 | Tampering | og:image URL composition (site.url + baseurl + photo) | low | accept | URL is assembled from committed config constants only; build-time proof battery pins the exact emitted absolute URL (https://zhangtaolab.org/images/logo.png), and the static_files guard prevents emitting a meta pointing at a missing file |
| T-quick-02 | Denial of Service | production deploy via unintended push | medium | mitigate | Hard constraint: executor never pushes; push auto-deploys to live zhangtaolab.org. Commit stays local; Task 2 asserts nothing left on origin beyond the pre-existing state |
</threat_model>

<verification>
1. `JEKYLL_ENV=production bundle exec jekyll build` exits 0 (same command shape as `.github/workflows/deploy.yml` line 37-39, which builds with JEKYLL_ENV=production and runs the same smoke script).
2. og:image + twitter:image emit `https://zhangtaolab.org/images/logo.png` on all 12 built HTML pages (equality with og:title coverage), zero headshot.jpg references.
3. `bash scripts/ci-smoke.sh _site` → PASS (all 4 D-08 assertions unchanged and green).
4. Exactly one source file changed (`_config.yml`), committed locally, not pushed.
</verification>

<success_criteria>
- `_config.yml` line 8: `photo: logo.png` (per user directive; 02-REVIEW WR-01 remedies superseded)
- Production build emits `<meta property="og:image" content="https://zhangtaolab.org/images/logo.png">` site-wide — WR-01 closed
- twitter:image activates on the same guard (beneficial side effect, documented)
- Smoke battery green; no push performed
</success_criteria>

<output>
Create `.planning/quick/260819-kvb-fix-wr-01-site-og-image-use-existing-log/260819-kvb-SUMMARY.md` when done
</output>
