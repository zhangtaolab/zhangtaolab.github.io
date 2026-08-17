# Project Research Summary

**Project:** Zhang Tao Lab Website (Jekyll Academic Lab)
**Domain:** Static academic lab website with maintenance workflow
**Researched:** 2026-08-17
**Confidence:** MEDIUM

## Executive Summary

This is an academic lab website maintenance workflow project - updating and deploying an existing Jekyll 4.3.3 site that's already built but needs a working local development environment and automated deployment pipeline. The site uses Jekyll with jekyll-scholar for academic bibliography management and Bootstrap for responsive layout.

The research reveals a critical path dependency: the local environment runs Ruby 4.0.6 (arm64 macOS), but Jekyll 4.3.3's compatibility with Ruby 4.x is unverified. The STACK researcher incorrectly claimed Ruby 4.0.6 doesn't exist; it does exist, but the real open question is whether Jekyll 4.3.x/jekyll-scholar work properly with Ruby 4.x, or whether we need to pin an older Ruby version or upgrade Jekyll. This is the primary execution-time decision that affects all subsequent work.

For deployment, jekyll-scholar's absence from GitHub Pages' plugin whitelist mandates GitHub Actions with artifact-based deployment. This is well-documented territory with established patterns. The major risks are Ruby/Jekyll version compatibility (unverified) and cross-platform Gemfile.lock issues (macOS arm64 → Linux CI), both resolvable through systematic testing and version pinning.

## Key Findings

### Recommended Stack

**Core technologies:**
- **Jekyll 4.4.1** (upgrade from 4.3.3) — Latest stable with bug fixes; resolves known Ruby 3.x compatibility issues
- **Ruby 3.2.3** (recommended) or Ruby 4.0.6 (local execution decision) — Optimal Jekyll 4.x compatibility vs local environment reality; this is the key open decision point
- **jekyll-scholar 7.3.0** — Latest release (Jan 2026) with Ruby ≥3.0 requirement; resolves known compatibility issues
- **GitHub Actions** — Required deployment method because jekyll-scholar isn't on Pages whitelist
- **chruby or mise** — Ruby version managers recommended over rbenv for better performance

**Execution decision needed:** The research shows two viable paths:
1. Pin Ruby ≤3.1.x (per STACK.md) for maximum Jekyll 4.3.3 compatibility
2. Upgrade to Jekyll 4.4.1 + test Ruby 4.0.6 compatibility (leverages local environment)
3. Downgrade local Ruby to 3.2.3 (matches STACK.md recommendation)

This must be resolved in Phase 1 through testing.

### Expected Features

**Must have (table stakes):**
- **Documented content update procedures** — Lab members need clear steps for BibTeX/YAML/markdown editing
- **Local preview with live reload** — Essential for content verification; `bundle exec jekyll serve`
- **YAML/BibTeX validation** — Prevents silent build failures from syntax errors
- **Production-mode local builds** — Ensures local preview matches production (`JEKYLL_ENV=production`)
- **Automated deployment on push** — Core value: push → publish workflow via GitHub Actions
- **Basic link checking in CI** — HTMLProofer integration for quality baseline

**Should have (competitive polish):**
- **PR preview deployments** — Safe collaborative editing; requires GitHub Actions setup
- **Scheduled dependency updates** — Dependabot/Renovate for security maintenance
- **Draft/staging patterns** — Content development without production impact

**Defer (v2+):**
- **CMS backends** — Overkill for static sites; well-documented YAML editing sufficient
- **Automated image optimization** — Nice-to-have performance improvement
- **Complex multi-language support** — Doubles maintenance burden for small labs

### Architecture Approach

The architecture follows GitHub Actions artifact-based deployment pattern: developers push to main branch → Actions builds Jekyll site with full Ruby environment → uploads `_site/` artifact → deploys to GitHub Pages infrastructure. This bypasses Pages' plugin whitelist limitations while maintaining static site benefits.

**Major components:**
1. **Git Repository** — Source of truth for code, content, plugins, CI/CD config
2. **GitHub Actions Workflow** — Automated build pipeline with Ruby environment + bundler cache
3. **Jekyll Build Process** — Generates static site with jekyll-scholar producing bibliography
4. **Pages Artifact & Deployment** — Compressed artifact uploaded via `actions/upload-pages-artifact`, deployed via `actions/deploy-pages`
5. **GitHub Pages Infrastructure** — Global CDN, SSL termination, static file serving
6. **DNS Configuration** — Custom domain routing via A/ALIAS records

**Key architectural pattern:** Artifact-based deployment (not branch-based) with explicit permissions, concurrency cancellation, and Ruby version pinning.

### Critical Pitfalls

**Top 5 pitfalls to avoid:**

1. **Ruby/Jekyll version incompatibility** — Verify Jekyll works with chosen Ruby version using `JEKYLL_ENV=production bundle exec jekyll build` before any deployment work. This is the primary unverified risk.

2. **jekyll-scholar silent failures** — Bibliography sections render empty without error messages. Must verify with jekyll-scholar ≥7.3.0 and test bibliography rendering in production builds.

3. **Gemfile.lock platform mismatches** — macOS arm64 lockfiles break Linux CI. Must run `bundle lock --add-platform ruby x86_64-linux aarch64-linux` before committing.

4. **GitHub Pages DNS/HTTPS delays** — SSL certificates take 24-48 hours after DNS propagation. Keep old deployment running until new HTTPS fully verified.

5. **CNAME file overwritten by deployments** — Custom domain config disappears after Actions deployments. Add CNAME preservation step to workflow or use GitHub Pages Settings interface.

## Implications for Roadmap

Based on research dependencies and architecture patterns, suggested phase structure:

### Phase 1: Local Environment Verification
**Rationale:** Everything depends on a working local Jekyll environment. The Ruby/Jekyll compatibility issue must be resolved first, as it affects all subsequent work. Content update procedures also require local preview functionality.

**Delivers:** Working local development environment with verified Ruby/Jekyll compatibility, production-mode builds, and bibliography rendering

**Addresses:**
- Local Ruby version decision (test Ruby 4.0.6 vs downgrade to 3.2.3 vs upgrade Jekyll)
- Jekyll + jekyll-scholar successful installation and build
- Production-mode local builds working (`JEKYLL_ENV=production bundle exec jekyll build`)
- Bibliography rendering verification (jekyll-scholar silent failure testing)

**Avoids:** Ruby version mismatch pitfalls, jekyll-scholar silent failures, local vs CI environment gaps

**Research flag:** HIGH — Ruby 4.0.6/Jekyll compatibility is unverified. This phase likely needs `/gsd-plan-phase --research-phase 1` to test different Ruby/Jekyll version combinations.

### Phase 2: GitHub Actions Deployment Pipeline
**Rationale:** Once local environment works, deployment automation enables the "push and publish" workflow. This phase implements the artifact-based deployment architecture and establishes CI/CD infrastructure.

**Delivers:** Automated GitHub Actions workflow that builds and deploys to GitHub Pages on push

**Uses:** GitHub Actions, ruby/setup-ruby, artifact-based deployment pattern
**Implements:** Build job (Ruby environment → Jekyll build → artifact upload) + Deploy job (Pages deployment)

**Addresses:**
- GitHub Actions workflow creation with proper permissions
- Cross-platform Gemfile.lock compatibility (add Linux platforms)
- CNAME file preservation in deployment workflow
- Production-mode builds in CI environment

**Avoids:** Gemfile.lock platform mismatches, CNAME overwrites, missing permissions

**Research flag:** MEDIUM — Well-documented GitHub Actions patterns for Jekyll exist, but jekyll-scholar integration needs validation.

### Phase 3: Content Update Documentation & Workflow Polish
**Rationale:** With working local preview and automated deployment, focus shifts to maintainability. Documented procedures enable lab members to update content independently.

**Delivers:** Clear documentation for adding papers/news/members/pages with validation steps

**Addresses:**
- Step-by-step guides for BibTeX additions, YAML updates, markdown editing
- YAML/BibTeX validation procedures
- Local preview verification steps
- Common troubleshooting scenarios

**Avoids:** Content update errors, silent build failures, maintenance workflow confusion

**Research flag:** LOW — Standard documentation patterns; no complex technical research needed.

### Phase 4: Domain Migration & Production Verification
**Rationale:** Final phase cuts over to production domain with proper DNS/HTTPS setup. This comes last because it involves production infrastructure and DNS changes.

**Delivers:** Live zhangtaolab.org domain with HTTPS and verified deployment

**Addresses:**
- Custom domain configuration via GitHub Pages Settings
- DNS record setup (A/ALIAS for apex, CNAME for www)
- HTTPS certificate verification and enforcement
- Full site functionality testing on production domain

**Avoids:** DNS/HTTPS certificate delays, premature old deployment removal

**Research flag:** MEDIUM — DNS/HTTPS setup is standard but has timing complexities; 24-48 hour certificate delays make verification important.

### Phase Ordering Rationale

The order follows dependency chains from the research:
- **Phase 1 first:** Ruby/Jekyll compatibility is the foundational risk; everything depends on verified local builds
- **Phase 2 second:** Deployment pipeline requires working local environment (Gemfile, tested Ruby version) but is independent of documentation
- **Phase 3 third:** Documentation requires both local preview (Phase 1) and automated deployment (Phase 2) to demonstrate the complete workflow
- **Phase 4 last:** Domain migration is production infrastructure work that should only happen after all development workflows are verified

This grouping separates concerns: environment setup → infrastructure → workflow → production deployment, minimizing cross-dependencies and allowing parallel work where possible.

### Research Flags

**Phases likely needing deeper research during planning:**
- **Phase 1:** Ruby 4.0.6/Jekyll 4.3.x compatibility is unverified. Need to test version combinations and validate bibliography rendering. Complex dependency matrix.
- **Phase 2:** jekyll-scholar with GitHub Actions integration needs practical validation despite existing documentation.

**Phases with standard patterns (skip research-phase):**
- **Phase 3:** Documentation and workflow patterns are well-established; no technical research needed
- **Phase 4:** DNS/HTTPS setup follows standard GitHub Pages patterns; documentation is comprehensive

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Core Jekyll/GitHub Actions patterns well-documented, but Ruby 4.0.6 compatibility specifically is unverified. STACK.md's claim about Ruby 4.0.6 not existing was incorrect. |
| Features | MEDIUM | Feature categorization based on clear academic use case analysis and competitor research. Implementation complexity estimates are reasonable. |
| Architecture | HIGH | GitHub Actions artifact-based deployment patterns are well-documented and established. Architecture diagrams and flows are verified. |
| Pitfalls | MEDIUM | Pitfall identification is strong and specific, but some Ruby version compatibility warnings were based on incorrect version assumptions. |

**Overall confidence:** MEDIUM — The architectural and CI/CD patterns are solid and well-researched. The primary uncertainty is Ruby/Jekyll version compatibility, which STACK.md got wrong but can be resolved through Phase 1 testing.

### Gaps to Address

**Ruby 4.0.6/Jekyll compatibility decision:**
- STACK.md incorrectly claimed Ruby 4.0.6 doesn't exist; it does (confirmed by orchestrator)
- Real issue: Jekyll 4.3.x/jekyll-scholar compatibility with Ruby 4.x is unverified
- **How to handle:** Phase 1 must test Ruby 4.0.6 with current Jekyll 4.3.3, and if incompatible, either upgrade Jekyll to 4.4.1 or downgrade Ruby to 3.2.3

**Cross-platform Gemfile.lock generation:**
- macOS arm64 → Linux CI platform compatibility is documented but needs validation
- **How to handle:** Phase 2 testing with `bundle lock --add-platform` and CI verification

**jekyll-scholar version compatibility:**
- ≥7.3.0 recommended, but practical compatibility with chosen Ruby/Jekyll combo needs testing
- **How to handle:** Verify bibliography rendering in Phase 1 production-mode builds

## Sources

### Primary (HIGH confidence)
- [Jekyll RubyGems - All Versions](https://rubygems.org/gems/jekyll/versions) - Official release history
- [jekyll-scholar RubyGems v7.3.0](https://rubygems.org/gems/jekyll-scholar/versions/7.3.0) - Latest release requirements
- [GitHub Pages Documentation - Publishing Source](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) - Official deployment patterns
- [ruby/setup-ruby Repository](https://github.com/ruby/setup-ruby) - Ruby environment setup patterns
- [GitHub Actions Workflow Syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions) - Official workflow documentation

### Secondary (MEDIUM confidence)
- [How to use jekyll-scholar with GitHub Pages](https://open-research.gemmadanks.com/tutorials/how-to-use-jekyll-scholar-with-github-pages/) - Deployment guidance
- [al-folio academic Jekyll theme](https://github.com/alshedivat/al-folio) - Academic website best practices
- [Gemfile.lock Commit Practice - Reddit](https://www.reddit.com/r/ruby/comments/cr5vwn/gems_should_you_add_gemfilelock_to_git/) - Community best practices
- [Ruby 3.2 Jekyll Compatibility - Jekyll Talk](https://talk.jekyllrb.com/t/liquid-4-0-3-tainted/7946) - Compatibility discussion

### Tertiary (LOW confidence)
- [GitHub Pages Custom Domain Pitfalls](https://github.com/github/pages-discussions) - Domain setup issues (anecdotal)
- [jekyll-scholar Ruby 3.3 Compatibility - StackOverflow](https://stackoverflow.com/questions/77740472/jekyll-scholar-7-1-3-jekyll-4-3-3-issue-with-ruby-3-3-0-liquid-exception-un) - Specific issue (but Ruby 3.3, not 4.0.6)
- [sass-embedded arm64 Performance - GitHub](https://github.com/sass/embedded-host-node/issues/140) - Architecture-specific behavior

---
*Research completed: 2026-08-17*
*Ready for roadmap: yes*
