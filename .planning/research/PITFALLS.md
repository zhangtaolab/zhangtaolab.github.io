# Domain Pitfalls

**Domain:** Jekyll local-setup and GitHub Pages Actions migration
**Researched:** 2026-08-17
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Ruby Version Mismatch with Jekyll 4.3.3

**What goes wrong:**
Running Jekyll 4.3.3 on too-new Ruby versions (3.2+) causes cryptic errors from removed stdlib gems, native extension build failures, and Liquid compatibility issues. The site may work locally in development mode but fail in production builds.

**Why it happens:**
Jekyll 4.3.3 was released before Ruby 3.2+ existed. Liquid 4.0.3 (used by Jekyll 4.x) has known incompatibilities with Ruby 3.2 that were only fixed in April 2023. Developers assume "newer Ruby = better" without checking compatibility.

**How to avoid:**
- Pin Ruby to ≤3.1.x in `.ruby-version` file
- Use `gem 'jekyll', '~> 4.3.3'` in Gemfile
- Test with `JEKYLL_ENV=production bundle exec jekyll build` locally before pushing
- Never use system Ruby on macOS; use rbenv/rvm/chruby

**Warning signs:**
- Errors like "tainted" or "Liquid::RangeError" 
- Native extension build failures during `bundle install`
- Works with `jekyll serve` but fails with `jekyll build`

**Phase to address:**
Phase 1 (Local Environment Setup) - Ruby version must be correct before any development begins

---

### Pitfall 2: jekyll-scholar Silent Failures

**What goes wrong:**
Bibliography sections render empty or partially populated with no error messages. Publications list disappears silently, making the site appear complete but missing critical academic content.

**Why it happens:**
jekyll-scholar has complex dependencies (bibtex-ruby, citeproc-ruby) that fail silently with version mismatches. Ruby 3.2+ compatibility issues with Liquid cause jekyll-scholar 7.1.3 to fail during bibliography generation without raising build errors.

**How to avoid:**
- Pin jekyll-scholar to ≥7.3.0 (latest compatible version)
- Update bibtex-ruby to latest version
- Verify bibliography output in production builds locally
- Add sample bibliography entries to test rendering

**Warning signs:**
- Publications pages show no content despite .bib file existing
- No error messages during build but bibliography missing
- jekyll-scholar warnings in build logs that don't fail the build

**Phase to address:**
Phase 1 (Local Environment Setup) - Must verify bibliography rendering works before proceeding

---

### Pitfall 3: Gemfile.lock Platform Mismatches

**What goes wrong:**
CI builds fail with "could not find gem" or platform-specific errors despite `bundle install` succeeding locally. GitHub Actions deployments fail while local development works perfectly.

**Why it happens:**
Gemfile.lock built on macOS arm64 doesn't include linux x86_64/arm64 platforms needed for GitHub Actions runners. Committing a platform-specific lockfile from Apple Silicon creates cross-platform incompatibility.

**How to avoid:**
- Never commit initial Gemfile.lock from macOS arm64 without adding platforms
- Run `bundle lock --add-platform ruby x86_64-linux aarch64-linux` before committing
- Use identical Ruby versions in local and CI environments
- Consider `bundle config set --local deployment true` for CI

**Warning signs:**
- CI fails with "platform mismatch" or "could not find gem" errors
- `bundle install` works locally but fails in GitHub Actions
- Different dependency resolutions between local and CI

**Phase to address:**
Phase 2 (CI Pipeline Setup) - Gemfile.lock must be cross-platform compatible before first deployment

---

### Pitfall 4: GitHub Pages DNS/HTTPS Certificate Delays

**What goes wrong:**
Custom domain (zhangtaolab.org) shows "SSL certificate retrying" for 24-48 hours, site works only on HTTP, or certificate generation fails completely. Old deployment broken before new one is verified.

**Why it happens:**
GitHub Pages SSL provisioning takes 24-48 hours after DNS propagation. Certificates fail if DNS records aren't perfect (including conflicting records, Cloudflare proxy, or incorrect CNAME/A records). Developers enable HTTPS prematurely or break old deployment before new one is verified.

**How to avoid:**
- Keep old deployment running until new site fully verified with HTTPS
- Use only required DNS records (remove conflicting A, AAAA, CAA records)
- Set DNS to "DNS-only" (grey cloud) if using Cloudflare during setup
- Wait 48 hours after DNS propagation before enabling HTTPS
- Test with `curl -I https://zhangtaolab.org` to verify certificate

**Warning signs:**
- GitHub Pages shows "SSL certificate retrying" for >48 hours  
- HTTPS redirects to certificate error pages
- Site works on HTTP but not HTTPS
- DNS check passes but certificate generation fails

**Phase to address:**
Phase 3 (Domain Migration) - DNS/HTTPS setup must be complete and verified before considering migration complete

---

### Pitfall 5: sass-embedded/arm64 CI Failures

**What goes wrong:**
GitHub Actions builds fail with dart-sass-embedded installation errors on arm64 runners. Native Sass compilation fails or produces performance issues, preventing successful Jekyll builds.

**Why it happens:**
GitHub Actions lacks full support for compiling Sass for Apple Silicon (M1/M2) architectures. sass-embedded has higher startup overhead on arm64 vs x64. Jekyll actions have compatibility issues with dart-sass-embedded.

**How to avoid:**
- Use `jekyll-sass-converter` v2 instead of v3 if dart-sass-embedded fails
- Specify non-Alpine Ruby Docker images in GitHub Actions
- Consider explicit sass-embedded version pinning
- Use x64 runners if arm64 compilation fails

**Warning signs:**
- GitHub Actions fails during gem installation with sass-related errors
- Build timeouts during Sass compilation steps  
- Performance issues specifically on arm64 architectures

**Phase to address:**
Phase 2 (CI Pipeline Setup) - Sass compilation must work in Actions before deployment begins

---

### Pitfall 6: CNAME File Overwritten by Deploy Actions

**What goes wrong:**
Custom domain configuration disappears after GitHub Actions deployments. CNAME file gets deleted or overwritten, causing site to revert to default github.io domain or break entirely.

**Why it happens:**
GitHub Actions deployment actions (especially ones that rebuild entire sites) overwrite or delete the CNAME file during deployment. The file isn't preserved between deployments unless explicitly handled in the workflow.

**How to avoid:**
- Add CNAME recreation step to GitHub Actions workflow after deployment
- Include CNAME file in source repository (not just in build output)
- Use deployment actions that preserve existing files
- Verify CNAME exists after each successful deployment

**Warning signs:**
- Custom domain works after manual setup but breaks after subsequent deployments
- Site occasionally reverts to username.github.io address
- Domain settings in GitHub Pages show "custom domain missing"

**Phase to address:**
Phase 2 (CI Pipeline Setup) - CNAME preservation must be part of deployment workflow from first deploy

---

### Pitfall 7: Local vs CI Environment Parity Gaps

**What goes wrong:**
Site works perfectly locally but fails in GitHub Actions. Builds pass locally with `bundle exec jekyll serve` but CI produces different output or fails completely.

**Why it happens:**
Local development uses different Ruby versions, gem versions, or environment variables than CI. `JEKYLL_ENV=production` exposes different code paths. Developers skip production mode testing locally.

**How to avoid:**
- Always test with `JEKYLL_ENV=production bundle exec jekyll build` locally
- Use Docker containers to match local and CI environments exactly
- Pin Ruby and gem versions in both Gemfile and GitHub Actions
- Run `bundle exec jekyll build` locally and compare output with CI

**Warning signs:**
- `jekyll serve` works but `jekyll build` produces different output
- Different behavior between development and production modes
- CI fails for reasons that can't be reproduced locally

**Phase to address:**
Phase 1 (Local Environment Setup) - Production build verification must be established before any deployment work

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Skip Gemfile.lock platform entries | Faster initial setup | CI failures, deployment blockers | Never - always add platforms |
| Use system Ruby on macOS | No Ruby manager needed | Unreliable builds, hard to reproduce | Never - always use Ruby manager |
| Deploy without HTTPS verification | Site appears "done" faster | Security issues, broken redirects | Only in testing, never in production |
| Ignore jekyll-scholar warnings | Build completes faster | Silent bibliography failures | Never - academic content critical |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| GitHub Pages Custom Domain | Enable HTTPS before certificate ready | Wait 48hrs after DNS propagation before HTTPS |
| GitHub Actions Deployment | Let actions overwrite CNAME file | Add CNAME preservation step in workflow |
| Cloudflare DNS | Use orange-cloud (proxy) during setup | Use grey-cloud (DNS-only) until HTTPS verified |
| jekyll-scholar | Assume any version works with Jekyll 4.x | Pin to ≥7.3.0 and verify bibliography rendering |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| arm64 Sass compilation | Slow builds, timeouts in CI | Use x64 runners or jekyll-sass-converter v2 | Immediately in GitHub Actions |
| Large .bib files | Slow build times, memory issues | Split bibliography, use jekyll-scholar caching | At 1000+ publications |
| Production vs dev builds | Different content, broken links | Always test with JEKYLL_ENV=production | Every deployment |

## "Looks Done But Isn't" Checklist

- [ ] **Ruby Version:** Often wrong — verify `ruby -v` shows ≤3.1.x
- [ ] **Gemfile.lock Platforms:** Often missing — verify `bundle lock --add-platform ruby`
- [ ] **Bibliography Rendering:** Often silent failures — verify publications appear in production build
- [ ] **HTTPS Certificate:** Often not ready — verify with curl before enabling
- [ ] **CNAME Persistence:** Often overwritten — verify after multiple deployments
- [ ] **CI Environment Parity:** Often assumed — verify Ruby/gem versions match local

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Ruby Version Mismatch | MEDIUM | Downgrade Ruby, run `bundle clean && bundle install`, retest production build |
| jekyll-scholar Failure | LOW | Update jekyll-scholar to ≥7.3.0, verify bibliography, rebuild |
| Gemfile.lock Platforms | LOW | Run `bundle lock --add-platform ruby x86_64-linux aarch64-linux`, commit |
| DNS/HTTPS Issues | HIGH | Remove all conflicting DNS records, wait 48hrs, force certificate re-issuance |
| CNAME Overwritten | LOW | Recreate CNAME file, add preservation step to workflow |
| CI Environment Gaps | MEDIUM | Dockerize local environment, match Ruby/gem versions exactly |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Ruby Version Mismatch | Phase 1 (Local Environment Setup) | `ruby -v` shows ≤3.1.x, production build succeeds |
| jekyll-scholar Silent Failures | Phase 1 (Local Environment Setup) | Bibliography renders correctly in production build |
| Gemfile.lock Platforms | Phase 2 (CI Pipeline Setup) | CI builds match local builds exactly |
| sass-embedded/arm64 Issues | Phase 2 (CI Pipeline Setup) | GitHub Actions builds succeed without Sass errors |
| CNAME File Overwritten | Phase 2 (CI Pipeline Setup) | CNAME persists after multiple deployments |
| Local vs CI Parity | Phase 1 (Local Environment Setup) | Production builds work locally and in CI |
| DNS/HTTPS Certificate Delays | Phase 3 (Domain Migration) | HTTPS works with valid certificate before considering complete |

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Phase 1: Local Environment | Ruby version too new, jekyll-scholar silent failures | Pin Ruby ≤3.1.x, verify bibliography rendering early |
| Phase 2: CI Pipeline | Gemfile.lock platforms, CNAME overwrites, arm64 Sass issues | Add platforms to lockfile, preserve CNAME, test Sass compilation |
| Phase 3: Domain Migration | HTTPS certificate delays, DNS misconfiguration | Keep old deployment until new verified, wait 48hrs for HTTPS |

## Sources

- [Ruby 3.2 Jekyll Compatibility - Jekyll Talk](https://talk.jekyllrb.com/t/liquid-4-0-3-tainted/7946) - HIGH confidence (official community discussion)
- [jekyll-scholar GitHub Pages Compatibility - Open Research Tutorial](https://open-research.gemmadanks.com/tutorials/how-to-use-jekyll-scholar-with-github-pages/) - MEDIUM confidence (community tutorial)
- [jekyll-scholar Ruby 3.3.0 Issues - Stack Overflow](https://stackoverflow.com/questions/77740472/jekyll-scholar-7-1-3-jekyll-4-3-3-issue-with-ruby-3-3-0-liquid-exception-un) - HIGH confidence (specific issue documented)
- [sass-embedded arm64 GitHub Issues - sass/dart-sass#1125](https://github.com/sass/dart-sass/issues/1125) - HIGH confidence (official repository)
- [Gemfile.lock Platform Solutions - Jekyll Talk](https://talk.jekyllrb.com/t/using-github-actions-to-deploy-and-met-platform-error/5006) - HIGH confidence (official community solution)
- [GitHub Pages SSL Certificate Timing - GitHub Community](https://github.com/orgs/community/discussions/184514) - HIGH confidence (official GitHub documentation)
- [CNAME File Overwrite Issues - GitHub Community](https://github.com/orgs/community/discussions/159544) - MEDIUM confidence (community discussion)
- [GitHub Actions Environment Parity - Jekyll Talk](https://talk.jekyllrb.com/t/better-github-pages-experience-with-jekyll/4140) - MEDIUM confidence (community best practices)
- [Local Testing Importance - GitHub Docs](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll) - HIGH confidence (official documentation)
- [Cloudflare Proxy Issues - Cloudflare Community](https://community.cloudflare.com/t/github-pages-keep-saying-it-cant-enforce-https/397570) - MEDIUM confidence (community experience)