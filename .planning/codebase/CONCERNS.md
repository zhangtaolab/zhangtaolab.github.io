# Codebase Concerns

**Analysis Date:** 2026-08-17

## Tech Debt

**Dependency Management:**
- Issue: Mixed dependency management with Bundler (Gemfile) but no package-lock.json for JavaScript dependencies
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/Gemfile`, `/Users/forrest/Playground/zhangtaolab-jekyll/assets/javascript/popper/package.json`
- Impact: Cannot guarantee consistent JavaScript builds across environments; potential for dependency drift
- Fix approach: Generate package-lock.json using `npm install` or switch to using Bundler for all dependencies

**Large Bundled Assets:**
- Issue: Large minified files with 1,800+ lines (Popper.js distributions) committed to repository
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/javascript/popper/dist/umd/popper.js`, `/Users/forrest/Playground/zhangtaolab-jekyll/assets/js/site.min.js`
- Impact: Increased repository size, slower git operations, potential for including vulnerable dependencies
- Fix approach: Consider using npm/yarn for dependency management instead of committing large bundled files

## Known Bugs

**No known bugs identified**
- No TODO/FIXME/HACK comments found in the codebase
- No stub implementations or incomplete features detected

## Security Considerations

**Insecure HTTP References:**
- Risk: Mixed content warnings when site served over HTTPS; potential security vulnerabilities
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/_layouts/post.html` (line 5: `http://schema.org/BlogPosting`), `/Users/forrest/Playground/zhangtaolab-jekyll/_layouts/bibtemplate.html` (line 29: `http://doi.org/`), `/Users/forrest/Playground/zhangtaolab-jekyll/_pages/contact.md` (line 55: `http://www.cib.ac.cn/`)
- Current mitigation: None - insecure references remain in production code
- Recommendations: Replace all `http://` URLs with `https://` equivalents:
  - `http://schema.org/` → `https://schema.org/`
  - `http://doi.org/` → `https://doi.org/`
  - `http://www.cib.ac.cn/` → `https://www.cib.ac.cn/`

**Outdated Dependencies:**
- Risk: Potential security vulnerabilities in outdated packages
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/Gemfile`
- Current mitigation: None - no regular dependency updates apparent
- Recommendations: Regularly audit and update Ruby gems and JavaScript dependencies; consider using security scanning tools

## Performance Bottlenecks

**Large CSS Bundle:**
- Problem: Single large CSS file containing entire Bootstrap framework plus custom styles
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/main.css` (appears to be minified Bootstrap + custom styles)
- Cause: Full framework inclusion even if only subset of components needed
- Improvement path: Consider using Bootstrap's custom build process or purging unused CSS classes

**Search Functionality:**
- Problem: Client-side search relies on loading entire search index JSON
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/search.json`, `/Users/forrest/Playground/zhangtaolab-jekyll/assets/js/site.js` (lines 220-269)
- Cause: All page content indexed and loaded in browser
- Improvement path: Consider server-side search or limiting search index size/depth

## Fragile Areas

**Publication System:**
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/_layouts/bibtemplate.html`, `/Users/forrest/Playground/zhangtaolab-jekyll/_config.yml` (lines 77-94)
- Why fragile: Complex Jekyll Scholar plugin configuration; depends on specific BibTeX file structure and file existence checks
- Safe modification: Test bibliography changes in development environment first
- Test coverage: No automated tests detected for publication rendering logic

**Theme Customization:**
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/main.css` (CSS custom properties), `/Users/forrest/Playground/zhangtaolab-jekyll/_includes/head.html` (lines 35-39)
- Why fragile: Custom accent color injection via Liquid template; assumes specific CSS structure
- Safe modification: Test color changes in both light and dark modes
- Test coverage: No automated testing for theme rendering

## Scaling Limits

**Static Site Generation:**
- Current capacity: Suitable for small to medium academic sites (hundreds of pages)
- Limit: Jekyll build times increase significantly with thousands of pages; no dynamic content capabilities
- Scaling path: Consider migrating to dynamic site generator or headless CMS if site grows beyond ~1000 pages

**Search Performance:**
- Current capacity: Client-side search suitable for sites with <500 pages
- Limit: Browser memory usage increases with search index size; mobile performance affected
- Scaling path: Implement server-side search using Algolia, Lunr.js with pre-built index, or similar solutions

## Dependencies at Risk

**Popper.js:**
- Risk: Version 2.11.8 may have security vulnerabilities; package appears unmaintained (superseded by @floating-ui)
- Impact: Tooltip and dropdown positioning functionality
- Migration plan: Consider migrating to @floating-ui/core for active maintenance

**Ruby Gems:**
- Risk: Jekyll 4.3.3 and associated gems may become outdated or unsupported
- Impact: Site build process and compatibility
- Migration plan: Regular gem updates and monitoring of Jekyll release notes for breaking changes

## Missing Critical Features

**No Automated Testing:**
- Problem: No test framework or test files detected
- Blocks: Confidence in site redesigns, template changes, or plugin updates
- Impact: High risk of regression when making changes

**No Content Validation:**
- Problem: No automated checks for broken links, missing images, or malformed content
- Blocks: Early detection of content errors before publication
- Impact: Manual content review required for each change

**No Build Validation:**
- Problem: No automated verification that Jekyll build succeeds or output is valid
- Blocks: CI/CD pipeline implementation
- Impact: Potential for broken site deployments

## Test Coverage Gaps

**Template Rendering:**
- What's not tested: Layout templates, include files, and Liquid template logic
- Files: All files in `/Users/forrest/Playground/zhangtaolab-jekyll/_layouts/` and `/Users/forrest/Playground/zhangtaolab-jekyll/_includes/`
- Risk: Template changes may break site layout or functionality unnoticed
- Priority: High

**Publication Display:**
- What's not tested: Jekyll Scholar bibliography rendering, BibTeX parsing, publication links
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/_layouts/bibtemplate.html`
- Risk: Publication list may break with malformed BibTeX or plugin updates
- Priority: Medium

**JavaScript Functionality:**
- What's not tested: Dark mode toggle, search functionality, publication filtering, copy-to-clipboard
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/js/site.js`
- Risk: JavaScript errors may affect user experience
- Priority: Medium

**CSS/Theme Integrity:**
- What's not tested: Theme rendering, dark mode contrast, responsive design
- Files: `/Users/forrest/Playground/zhangtaolab-jekyll/assets/main.css`, `/Users/forrest/Playground/zhangtaolab-jekyll/_includes/head.html`
- Risk: Visual regressions and accessibility issues may go unnoticed
- Priority: Low

---

*Concerns audit: 2026-08-17*