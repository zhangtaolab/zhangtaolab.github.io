# Technology Stack

**Project:** Zhang Tao Lab Website (Jekyll Academic Lab)
**Researched:** 2026-08-17

## Recommended Stack

### Core Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **Jekyll** | 4.4.1 (upgrading from 4.3.3) | Static site generator | Latest stable release (Jan 2025) with bug fixes; 4.3.4 relaxed gem constraints, 4.4.x adds improvements |
| **Ruby** | 3.2.x (recommending 3.2.3) | Runtime | Optimal compatibility with Jekyll 4.x; avoids Ruby 3.4 compatibility issues while remaining current |
| **Bundler** | Latest (via rubygems) | Dependency management | Required for Gemfile.lock consistency; note current setup uses Bundler 4.0.16 |

### Academic Plugins
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **jekyll-scholar** | 7.3.0 (upgraded from unpinned) | Academic bibliography generation | Latest release (Jan 2026) with Ruby >= 3.0 requirement; resolves known compatibility issues |
| **bibtex-ruby** | ~> 4.5 (dependency) | BibTeX parsing | Required by jekyll-scholar; ensure compatibility with 7.3.0 |
| **citeproc-ruby** | ~ 1.1 (dependency) | Citation processing | Required by jekyll-scholar |

### Frontend Build
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **sass-embedded** | ~> 1.77.0 | SCSS compilation for Bootstrap | Pin maintained to avoid Bootstrap SCSS deprecation warnings; arm64 macOS compatible |
| **webrick** | ~> 1.7 | Local server | Required for Ruby 3.0+ (removed from stdlib) |

### CI/CD Deployment
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| **GitHub Actions** | Latest | Automated deployment | Required for jekyll-scholar (not on Pages native whitelist) |
| **setup-ruby** | Latest | Ruby environment in CI | Automatically reads .ruby-version file |

### Standard Library Gems (Ruby 3.4+ compatibility)
| Technology | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| **bigdecimal** | Latest | BigDecimal support | Ruby 3.4+ removed from stdlib; add if upgrading to Ruby 3.4 |
| **csv** | Latest | CSV parsing | Ruby 3.4+ removed from stdlib; add if upgrading to Ruby 3.4 |
| **base64** | Latest | Base64 encoding | Ruby 3.4+ removed from stdlib; add if upgrading to Ruby 3.4 |

## Ruby Version Management

### Recommendation: chruby or mise (NOT rbenv)

**For macOS arm64:**

| Manager | Recommendation | Why |
|---------|---------------|-----|
| **chruby** | ✅ RECOMMENDED for performance | Zero overhead, fastest execution, simplest setup |
| **mise** | ✅ RECOMMENDED for modern UX | Active development, great experience, similar to asdf |
| **rbenv** | ❌ AVOID for this use case | Shim architecture causes performance overhead |
| **asdf** | ⚠️ Only if multi-language needed | Good for multiple tools but shim overhead exists |

**Installation order for chruby:**
```bash
# Install chruby and ruby-install
brew install chruby ruby-install

# Install Ruby 3.2.3
ruby-install ruby 3.2.3

# Add to shell config (e.g., ~/.zshrc)
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
```

### Ruby Version File

**YES, commit `.ruby-version` file**
```bash
# Create file with recommended Ruby version
echo "3.2.3" > .ruby-version
git add .ruby-version
git commit -m "Add .ruby-version for CI consistency"
```

**Why:**
- GitHub Actions `setup-ruby` automatically reads this file
- Ensures team consistency across development environments
- Prevents version mismatches that cause production build failures
- Standard practice for Ruby projects in 2026

## Dependency Management

### Gemfile.lock Commit Strategy

**YES, commit Gemfile.lock** with platform-specific considerations:

```bash
# Generate Gemfile.lock on Linux for CI compatibility
# (or use deployment-specific platform flags)
bundle install

# Commit both files
git add Gemfile Gemfile.lock
git commit -m "Lock gem dependencies for deployment"
```

**Platform-specific workaround for macOS arm64 → Linux CI:**
```ruby
# In Gemfile, add:
platform :ruby do
  gem 'octokit', '4.20.0'
end
```

Or generate Gemfile.lock in Linux environment:
```bash
# Using Docker for platform consistency
docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:3.2 bundle install
```

### Recommended Gemfile Structure

```ruby
source "https://rubygems.org"

ruby "3.2.3"

# Core Jekyll
gem "jekyll", "~> 4.4.0"
gem "minima", "~> 2.5"

# Academic plugins
gem "jekyll-scholar", "~> 7.3.0"
gem "bibtex-ruby", "~> 4.5"
gem "citeproc-ruby", "~> 1.1"

# Frontend build
gem "sass-embedded", "~> 1.77.0"
gem "webrick", "~> 1.7"

# Standard library gems (for Ruby 3.4+ future-proofing)
# gem "bigdecimal"
# gem "csv"
# gem "base64"

# Jekyll plugins
gem "jekyll-sitemap"
gem "jekyll-feed"
gem "kramdown-parser-gfm"

# Development (in :jekyll_plugins group if needed)
# gem "jekyll-compose"
```

## Installation

### Local Development Setup

```bash
# 1. Install Ruby version manager
brew install chruby ruby-install

# 2. Install Ruby 3.2.3
ruby-install ruby 3.2.3

# 3. Switch to project Ruby
chruby 3.2.3

# 4. Install gems
bundle install

# 5. Run local server
bundle exec jekyll serve

# 6. Build for production
bundle exec jekyll build
```

### GitHub Actions Workflow

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true # runs bundle install and caches gems
          
      - name: Build site
        run: bundle exec jekyll build
        
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_site
```

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| **Jekyll Version** | 4.4.1 | Stay on 4.3.3 | 4.3.3 outdated (Sep 2024); 4.4.1 has bug fixes; upgrade path is smooth |
| **Ruby Version** | 3.2.3 | Ruby 3.4.0 | Too new; may cause stdlib gem issues; Jekyll compatibility unknown |
| **Ruby Manager** | chruby | rbenv | Shim overhead unnecessary for single-language projects |
| **Ruby Manager** | chruby | asdf/mise | Acceptable if multi-language needed, but chruby faster for Ruby-only |
| **Jekyll Build** | GitHub Actions | Pages native build | jekyll-scholar not on whitelist; no choice |
| **Gemfile.lock** | Commit | Don't commit | Breaks CI consistency; causes production failures |
| **Sass Compiler** | sass-embedded | dart-sass CLI | sass-embedded better integrated with Jekyll |

## Known Issues & Solutions

### Issue 1: Ruby 3.4 Compatibility
**Problem:** Ruby 3.4 removed gems from stdlib (csv, base64, bigdecimal)
**Solution:** Add explicit gems to Gemfile when upgrading to Ruby 3.4+
**Status:** Avoid Ruby 3.4 for now; use Ruby 3.2.3

### Issue 2: macOS arm64 → Linux CI Gemfile.lock
**Problem:** Platform-specific gems cause deployment failures
**Solution:** Generate Gemfile.lock on Linux or use platform groups
**Status:** Documented workaround; test thoroughly

### Issue 3: jekyll-scholar Ruby 3.3 Issues
**Problem:** Liquid exceptions with Ruby 3.3.0 + Jekyll 4.3.3 + jekyll-scholar 7.1.3
**Solution:** Upgrade to jekyll-scholar 7.3.0 and Jekyll 4.4.1
**Status:** Resolved in latest versions

### Issue 4: Bootstrap SCSS Deprecation Noise
**Problem:** Old sass-embedded versions show deprecation warnings
**Solution:** Maintain ~> 1.77.0 pin until confirmed resolved
**Status:** Monitor upstream; pin working for now

## Migration Path from Current Setup

### Step 1: Verify Current State
```bash
# Check actual Ruby version (not "4.0.6" which doesn't exist)
ruby --version

# Check current Jekyll version
bundle show jekyll

# Check jekyll-scholar version
bundle show jekyll-scholar
```

### Step 2: Install Correct Ruby Version
```bash
# Install Ruby 3.2.3
ruby-install ruby 3.2.3

# Switch to it
chruby 3.2.3
```

### Step 3: Update Gemfile
```bash
# Edit Gemfile to pin versions:
# - jekyll "~> 4.4.0"
# - jekyll-scholar "~> 7.3.0"
# - sass-embedded "~> 1.77.0"

# Install updated gems
bundle install
```

### Step 4: Add .ruby-version
```bash
echo "3.2.3" > .ruby-version
git add .ruby-version
```

### Step 5: Test Locally
```bash
# Test build
bundle exec jekyll build

# Test serve
bundle exec jekyll serve

# Verify bibliography works
curl http://localhost:4000/publications/
```

### Step 6: Commit and Deploy
```bash
git add Gemfile Gemfile.lock .ruby-version
git commit -m "Update stack to Jekyll 4.4.1, Ruby 3.2.3, jekyll-scholar 7.3.0"
git push
```

## Sources

### High Confidence (Official Documentation)
- [Jekyll RubyGems - All Versions](https://rubygems.org/gems/jekyll/versions) - Official release history
- [jekyll-scholar RubyGems v7.3.0](https://rubygems.org/gems/jekyll-scholar/versions/7.3.0) - Latest release requirements
- [GitHub Ruby Documentation - .ruby-version](https://docs.github.com/zh/actions/tutorials/build-and-test-code/ruby) - Official GitHub Actions Ruby setup
- [Jekyll News - 4.4.1 Release](https://jekyllrb.com/news/) - Official release announcement

### Medium Confidence (Community Knowledge)
- [Ruby Version Manager Discussion - Reddit](https://www.reddit.com/r/ruby/comments/1gbzsfu/which_ruby_version_manager_is_most_used_nowadays/) - 2026 community consensus
- [Gemfile.lock Commit Practice - Reddit](https://www.reddit.com/r/ruby/comments/cr5vwn/gems_should_you_add_gemfilelock_to_git/) - Community best practices
- [Jekyll Scholar GitHub Pages Tutorial](https://open-research.gemmadanks.com/tutorials/how-to-use-jekyll-scholar-with-github-pages/) - Deployment guidance
- [Bundler Platform Locking Issue - GitHub #5338](https://github.com/ruby/rubygems/issues/5338) - Cross-platform compatibility

### Low Confidence (Specific Issues)
- [GitHub Pages Custom Domain Pitfalls](https://github.com/github/pages-discussions) - Domain setup issues
- [jekyll-scholar Ruby 3.3 Compatibility - StackOverflow](https://stackoverflow.com/questions/77740472/jekyll-scholar-7-1-3-jekyll-4-3-3-issue-with-ruby-3-3-0-liquid-exception-un) - Specific compatibility issue
- [sass-embedded arm64 Performance - GitHub](https://github.com/sass/embedded-host-node/issues/140) - Architecture-specific behavior

**Overall Confidence:** HIGH for core stack decisions, MEDIUM for specific compatibility issues, LOW for edge cases and future-proofing claims.