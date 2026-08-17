# Testing Patterns

**Analysis Date:** 2026-08-17

## Test Framework

**Runner:** Not detected (No testing framework configured)

**Assertion Library:** Not applicable

**Config:** No test configuration files found (no `jest.config.*`, `vitest.config.*`, `cypress.config.*`, or similar)

**Run Commands:**
```bash
# No test commands available
# This is a static Jekyll site with no formal testing infrastructure
```

## Test File Organization

**Location:** Not applicable (no test directory structure)

**Naming:** Not applicable (no test files present)

**Structure:**
```
# No test directory structure detected
# Traditional Jekyll project structure without testing layer
```

## Test Structure

**Suite Organization:** Not applicable

**Patterns:**
- No formal testing patterns detected
- Manual testing likely performed through Jekyll's built-in server: `bundle exec jekyll serve`
- Visual testing through browser preview
- No automated testing infrastructure

## Mocking

**Framework:** Not applicable

**Patterns:** No mocking patterns detected

**What to Mock:** Not applicable

**What NOT to Mock:** Not applicable

## Fixtures and Factories

**Test Data:**
- Static data files in `_data/` directory serve as fixtures
- Examples: `_data/team_members.yml`, `_data/news.yml`, `_data/grants.yml`
- YAML structure provides consistent test data format

**Location:**
- `/Users/forrest/Playground/zhangtaolab-jekyll/_data/` directory

**Example fixture pattern:**
```yaml
# _data/team_members.yml
- name: Liu Guanqing
  photo: team/liuguanqing.jpg
  info: PhD Student, Bioinformatics & Genomics
  email: liuguanqing@zhangtaolab.org
```

## Coverage

**Requirements:** None enforced (no testing infrastructure)

**View Coverage:** Not applicable (no coverage tools configured)

## Test Types

**Unit Tests:** Not implemented

**Integration Tests:** Not implemented

**E2E Tests:** Not implemented

**Manual Testing:**
- Local Jekyll development server: `bundle exec jekyll serve`
- Browser-based visual inspection
- Content verification through page navigation
- Link checking through manual browsing
- Responsive design testing through browser DevTools

## Static Site Testing Considerations

**Jekyll Build Verification:**
```bash
# Test build process
bundle exec jekyll build

# Check for build errors and warnings
# Verify _site directory generation
```

**Content Validation:**
- Manual verification of page rendering
- YAML data file structure validation
- Liquid template syntax checking through Jekyll error messages

**Deployment Testing:**
- Static site deployment (likely to GitHub Pages or similar)
- Post-deployment smoke testing through live site verification

## Development Workflow

**No Formal Testing Gates:**
- No pre-commit hooks for testing
- No CI/CD testing pipelines detected
- No automated quality gates

**Manual Validation Process:**
1. Local development with Jekyll server
2. Visual inspection of changes
3. Manual content verification
4. Direct deployment or commit to main branch

## Missing Testing Infrastructure

**What's Missing:**
- JavaScript unit testing framework (Jest, Vitest, Mocha, etc.)
- CSS testing/validation framework
- HTML validation tools
- Link checking automation
- Visual regression testing
- Accessibility testing (axe-core, pa11y, etc.)
- Performance testing (Lighthouse CI)
- SEO validation
- Content consistency testing

**Recommended Additions:**
- JavaScript testing: Jest or Vitest for `assets/js/site.js` coverage
- HTML validation: HTMLHint or similar
- Link checking: markdown-link-check or similar
- Accessibility: axe-core integration
- Visual testing: Percy or similar for regression detection
- Performance: Lighthouse CI for performance budget monitoring

## Build Process Testing

**Jekyll Build Process:**
- Configuration: `_config.yml`
- Build command: `bundle exec jekyll build`
- Output: `_site/` directory
- Error detection: Jekyll build failure messages

**Ruby Dependencies:**
- Gemfile specifies Jekyll 4.3.3 and related gems
- No test dependencies detected in Gemfile

**Example build verification:**
```bash
# Verify build succeeds
bundle exec jekyll build

# Check for common Jekyll errors
# - YAML syntax errors in front matter
# - Liquid template syntax errors
# - Missing includes or layouts
# - Invalid config in _config.yml
```

## Content Testing Patterns

**YAML Data Validation:**
- Manual verification of YAML syntax
- Jekyll provides error messages for malformed YAML
- Data file structure consistency

**Liquid Template Testing:**
- Manual verification of template rendering
- Jekyll build process catches syntax errors
- No formal template testing framework

**Static Asset Testing:**
- Manual verification of CSS/JS file loading
- No asset pipeline testing automation
- Image optimization and loading verification

---

*Testing analysis: 2026-08-17*