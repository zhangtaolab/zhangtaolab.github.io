# Architecture Research

**Domain:** Jekyll GitHub Actions CI/CD Deployment Pipeline
**Researched:** 2026-08-17
**Confidence:** HIGH

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Developer Workflow                       │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Local Changes │  │ Content Edits │  │ Plugin Config│      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │              │
└─────────┼─────────────────┼─────────────────┼──────────────┘
          │                 │                 │
          ↓                 ↓                 ↓
┌─────────────────────────────────────────────────────────────┐
│                   Git Repository                              │
│  (Source code, content, plugins, configuration)             │
└──────────────────────────┬──────────────────────────────────┘
                           │ push to main branch
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   GitHub Actions Workflow                    │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────┐  ┌──────────────────┐  ┌─────────────┐ │
│  │ Checkout Code  │→│ Ruby Environment  │→│ Bundle Install│ │
│  │ actions/checkout│ │ ruby/setup-ruby   │ │ bundler-cache│ │
│  └────────────────┘  └──────────────────┘  └──────┬──────┘ │
│                                                     │         │
│                                                ┌────▼──────┐ │
│                                                │ Jekyll    │ │
│                                                │ Build     │ │
│                                                │ jekyll    │ │
│                                                │ build     │ │
│                                                └──────┬────┘ │
└───────────────────────────────────────────────────────┼──────┘
                                                        │
                                      ┌─────────────────▼─────────────┐
                                      │   Static Site Artifact (_site)  │
                                      │  actions/upload-pages-artifact │
                                      └─────────────────┬─────────────┘
                                                        │
                                       ┌─────────────────▼──────────────┐
                                       │  GitHub Pages Deployment        │
                                       │  actions/deploy-pages           │
                                       └─────────────────┬──────────────┘
                                                         │
┌─────────────────────────────────────────────────────────▼──────────┐
│                   GitHub Pages Infrastructure                         │
│  (SSL termination, CDN, static hosting)                              │
└─────────────────────────────────────────────────────────┬──────────┘
                                                          │
┌─────────────────────────────────────────────────────────▼──────────┐
│                      DNS Layer                                      │
│  apex domain: A/ALIAS records → GitHub Pages                       │
│  www subdomain: CNAME → username.github.io                          │
└─────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| **Git Repository** | Source of truth for site code, content, plugins, and CI/CD configuration | GitHub repository with main branch as source |
| **GitHub Actions Workflow** | Automated build pipeline that compiles Jekyll site with all custom plugins | `.github/workflows/pages.yml` with sequential job stages |
| **Ruby Environment** | Provides consistent Ruby runtime and gem management | `ruby/setup-ruby@v1` with version pinning and bundler cache |
| **Jekyll Build Process** | Generates static site with all plugins including non-whitelisted ones | `bundle exec jekyll build` producing `_site/` directory |
| **Pages Artifact** | Packages static site for deployment | `actions/upload-pages-artifact@v4` with gzip compression |
| **Pages Deployment** | Publishes artifact to GitHub Pages infrastructure | `actions/deploy-pages@v4` with OIDC authentication |
| **GitHub Pages Infrastructure** | Global CDN, SSL termination, static file serving | GitHub's managed Pages infrastructure |
| **DNS Configuration** | Routes domain traffic to GitHub Pages | A/ALIAS records for apex, CNAME for subdomains |

## Recommended Project Structure

```
zhangtaolab-jekyll/
├── .github/
│   └── workflows/
│       └── pages.yml          # GitHub Actions deployment workflow
├── _pages/                    # Site content pages
├── _data/                     # Structured data (people, news, etc.)
├── _posts/                    # Blog posts
├── papers/                    # Academic publications data
│   └── ref.bib               # Bibliography for jekyll-scholar
├── assets/                    # Static assets (CSS, JS, images)
├── _config.yml               # Jekyll configuration
├── Gemfile                   # Ruby dependencies including jekyll-scholar
├── Gemfile.lock              # Pinned dependency versions
└── README.md                 # Documentation
```

### Structure Rationale

- **`.github/workflows/`**: Separates CI/CD configuration from application code, following GitHub Actions conventions
- **Source organization**: Mirrors typical Jekyll structure with `_` prefixed directories for generated content
- **`Gemfile` + `Gemfile.lock`**: Ensures reproducible builds across environments and prevents plugin version drift
- **`papers/` directory**: Academic workflow separation for bibliography management

## Architectural Patterns

### Pattern 1: Artifact-Based Deployment (Recommended)

**What:** Build Jekyll site in CI environment, upload as artifact, then deploy artifact to Pages

**When to use:** Any Jekyll site with custom plugins or specific Ruby version requirements

**Trade-offs:** 
- ✅ Pros: Supports any Jekyll plugin, consistent Ruby environment, separate build/deploy concerns, faster iteration
- ❌ Cons: Requires workflow management, slightly more complex than branch-based deployment

**Example:**
```yaml
# .github/workflows/pages.yml
name: Build and Deploy Jekyll Site

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '4.0'
          bundler-cache: true
      
      - name: Build site
        run: bundle exec jekyll build
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v4

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Pattern 2: Branch-Based Deployment (Legacy)

**What:** Deploy by pushing built files to a dedicated branch (e.g., `gh-pages`)

**When to use:** Legacy projects, simple migration scenarios

**Trade-offs:**
- ✅ Pros: Simple workflow, familiar to many developers
- ❌ Cons: No custom plugin support, pollutes git history, deprecated approach

**Instead:** Use Pattern 1 (artifact-based deployment)

### Pattern 3: Ruby Environment Pinning

**What:** Specify exact Ruby and bundler versions to ensure reproducible builds

**When to use:** Production deployments, compatibility requirements

**Trade-offs:**
- ✅ Pros: Reproducible builds, prevents breaking changes, easier debugging
- ❌ Cons: Requires manual updates, potential security lag

**Example:**
```yaml
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '4.0'        # Pin specific major version
    bundler: '4.0'              # Pin bundler version
    bundler-cache: true         # Cache gems between runs
```

### Pattern 4: Concurrency Control

**What:** Cancel in-progress deployments when new commits arrive

**When to use:** Active development branches, rapid iteration

**Trade-offs:**
- ✅ Pros: Faster feedback loops, reduced CI resource usage
- ❌ Cons: May lose intermediate deployment states

**Example:**
```yaml
concurrency:
  group: "pages"
  cancel-in-progress: true
```

## Data Flow

### Deployment Flow

```
[Developer Push]
    ↓
[Git Repository (main branch)]
    ↓
[GitHub Actions Trigger]
    ↓
[Build Job]
    ↓
[actions/checkout@v4] → Source code
    ↓
[ruby/setup-ruby@v1] → Ruby runtime + gems
    ↓
[bundle exec jekyll build] → Static site (_site/)
    ↓
[actions/upload-pages-artifact@v4] → Compressed artifact
    ↓
[Deploy Job]
    ↓
[actions/deploy-pages@v4] → GitHub Pages
    ↓
[CDN Distribution] → Global edge nodes
    ↓
[User Access via zhangtaolab.org]
```

### Authentication Flow

```
[GITHUB_TOKEN]
    ↓ (pages: write, id-token: write, contents: read)
[actions/deploy-pages]
    ↓ (requests OIDC token)
[GitHub OIDC Provider]
    ↓ (issues time-limited token)
[GitHub Pages API]
    ↓ (validates deployment permissions)
[Deployment Complete]
```

### Key Data Flows

1. **Source to Build:** Git repository → Actions checkout → Ruby environment → Jekyll build process
2. **Build to Artifact:** `_site/` directory → Compressed gzip archive → Actions artifact storage
3. **Artifact to Pages:** OIDC authentication → Deployment API → Static file hosting
4. **DNS Resolution:** User query → DNS records → GitHub Pages CDN → SSL termination → Content delivery

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| **GitHub Pages** | `actions/deploy-pages@v4` with OIDC authentication | Requires repository Pages source set to "GitHub Actions" |
| **RubyGems.org** | `ruby/setup-ruby@v1` with `bundler-cache: true` | Automatic gem download and caching |
| **DNS Provider** | Manual DNS record configuration (A/ALIAS for apex, CNAME for www) | Changes can take 24-48 hours to propagate |
| **GitHub CDN** | Automatic through Pages infrastructure | Global edge caching, automatic SSL |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| **Build Job ↔ Deploy Job** | Artifact passing via GitHub Actions | Deploy job waits for build job completion |
| **Workflow ↔ Pages Infrastructure** | OIDC token + API calls | Secure, time-limited authentication |
| **Pages ↔ DNS** | Standard DNS resolution | No direct integration, relies on DNS configuration |

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k visitors/day | Single workflow, default runner, standard caching |
| 1k-100k visitors/day | Enhanced caching, CDN optimization, monitoring |
| 100k+ visitors/day | Multiple deployment environments, CDN preloading, analytics integration |

### Scaling Priorities

1. **First bottleneck:** Build time becomes slow with large content sets → optimize bundler cache, consider incremental builds
2. **Second bottleneck:** CDN propagation delays during rapid updates → implement cache invalidation strategies

## Anti-Patterns

### Anti-Pattern 1: Manual CNAME File Management

**What people do:** Manually create and commit `CNAME` file to repository root

**Why it's wrong:** Creates merge conflicts, gets overwritten by builds, not source-controlled properly

**Do this instead:** Configure custom domain through repository Settings interface, let GitHub manage CNAME file automatically

### Anti-Pattern 2: Branch-Based Deployment with Custom Plugins

**What people do:** Push to `gh-pages` branch hoping GitHub Pages will build with custom plugins

**Why it's wrong:** GitHub Pages only supports whitelisted plugins in branch-based deployment

**Do this instead:** Use GitHub Actions workflow with artifact-based deployment

### Anti-Pattern 3: Latest Ruby Version Without Testing

**What people do:** Use `ruby-version: 'latest'` in setup-ruby action

**Why it's wrong:** Jekyll 4.3.3 may have compatibility issues with newer Ruby versions

**Do this instead:** Pin specific Ruby version: `ruby-version: '4.0'` and test locally before deployment

### Anti-Pattern 4: Missing Permissions Block

**What people do:** Omit `permissions:` block in workflow, hoping default permissions work

**Why it's wrong:** `id-token: write` is required for Pages deployment but not in default permissions

**Do this instead:** Always specify exact permissions needed:
```yaml
permissions:
  contents: read
  pages: write
  id-token: write
```

### Anti-Pattern 5: No Concurrency Control

**What people do:** Allow multiple deployments to queue up during rapid development

**Why it's wrong:** Wastes CI resources, deploys stale content, creates confusing deployment states

**Do this instead:** Always include concurrency cancellation:
```yaml
concurrency:
  group: "pages"
  cancel-in-progress: true
```

## Build Order and Setup Sequence

### Recommended Setup Order

1. **Repository Initialization**
   - Initialize git repository
   - Create `.github/workflows/pages.yml` workflow
   - Configure `Gemfile` with Jekyll and jekyll-scholar
   - Run `bundle install` locally and commit `Gemfile.lock`

2. **GitHub Repository Setup**
   - Create GitHub repository
   - Push code to main branch
   - **Enable GitHub Pages** → Set source to "GitHub Actions"

3. **Custom Domain Configuration**
   - Go to repository Settings → Pages
   - Add custom domain: `zhangtaolab.org`
   - Wait for GitHub to generate CNAME file automatically
   - Enable "Enforce HTTPS" (will activate after DNS verification)

4. **DNS Configuration**
   - Configure apex domain (zhangtaolab.org):
     - **Option A:** A records pointing to GitHub Pages IPs:
       ```
       185.199.108.153
       185.199.109.153
       185.199.110.153
       185.199.111.153
       ```
     - **Option B:** ALIAS/ANAME record to `username.github.io` (if supported)
   - Configure www subdomain:
     ```
     CNAME: username.github.io
     ```

5. **Verification and Testing**
   - Push test commit to trigger workflow
   - Verify workflow runs successfully
   - Check Pages deployment status
   - Test domain access (may take 24-48 hours for DNS propagation)

### Dependencies Between Steps

```
[Repo Code] → [GitHub Repo] → [Pages Settings] → [Domain Config] → [DNS Records] → [Full Propagation]
     ↓              ↓               ↓                ↓              ↓              ↓
  Required       Required         Required         Required       Required      Final State
```

- **Can test immediately:** GitHub Actions workflow (without Pages deployment)
- **Can verify before DNS:** Pages functionality via `username.github.io`
- **Must wait for propagation:** Custom domain full functionality (24-48 hours)
- **Sequential requirements:** Each step depends on previous completion

### Pre-Deployment Validation

Before DNS cutover, you can verify:
- ✅ Workflow builds successfully
- ✅ Artifact uploads correctly
- ✅ Pages deployment works via `username.github.io`
- ✅ Site functionality is correct
- ✅ Custom plugins (jekyll-scholar) generate proper content

This allows full testing of the deployment pipeline before pointing the live domain at it.

## Current Best Practices (2026)

### Recommended Actions and Versions

| Action | Version | Purpose |
|--------|---------|---------|
| `actions/checkout` | `@v4` | Repository checkout |
| `ruby/setup-ruby` | `@v1` | Ruby environment setup with bundler cache |
| `actions/upload-pages-artifact` | `@v4` | Artifact packaging for Pages deployment |
| `actions/deploy-pages` | `@v4` | Pages deployment with OIDC authentication |

### Key Configuration Principles

1. **Artifact-based deployment** (not branch-based)
2. **Explicit permissions** (pages: write, id-token: write, contents: read)
3. **Concurrency cancellation** (cancel-in-progress: true)
4. **Version pinning** for Ruby and key actions
5. **Bundler caching** for faster builds
6. **Custom domain via Settings** (not manual CNAME files)

## Sources

### Official Documentation
- [GitHub Pages Documentation - Publishing Source](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
- [GitHub Pages Custom Domain Management](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)
- [GitHub Actions Workflow Syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [ruby/setup-ruby Repository](https://github.com/ruby/setup-ruby)
- [actions/upload-pages-artifact](https://github.com/actions/upload-pages-artifact)
- [Jekyll GitHub Actions Documentation](https://jekyllrb.com/docs/continuous-integration/github-actions/)

### Community Resources
- [How to use jekyll-scholar with GitHub Pages](https://open-research.gemmadanks.com/tutorials/how-to-use-jekyll-scholar-with-github-pages/)
- [GitHub Marketplace - Jekyll Build Pages](https://github.com/marketplace/actions/jekyll-build-pages)
- [Setting Up GitHub Pages with GitHub Actions](https://dev.to/jajera/setting-up-github-pages-with-github-actions-2o72)
- [Deploying Jekyll blog with GitHub Actions](https://sosedoff.com/2019/11/28/deploying-jekyll-blog-with-github-actions.html)

### GitHub Changelogs
- [GitHub Changelog - Pages Actions v4 Requirement (2025)](https://github.blog/changelog/2024-12-05-deprecation-notice-github-pages-actions-to-require-artifacts-actions-v4-on-github-com/)

### Tutorials
- [How to Add a Custom Domain to GitHub Pages (2026) - YouTube](https://www.youtube.com/watch?v=jz-NL6rhLtM)
- [Static blog using Jekyll 4.1.0 with GitHub Pages and Actions](https://davidstosik.me/2020/05/31/static-blog-jekyll-410-github-pages-actions)

---
*Architecture research for: Jekyll GitHub Actions CI/CD Deployment Pipeline*
*Researched: 2026-08-17*