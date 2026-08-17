# External Integrations

**Analysis Date:** 2026-08-17

## APIs & External Services

**Analytics:**
- Google Analytics 4 - Website traffic and user behavior tracking
  - SDK/Client: Google Tag Manager (`gtag/js`)
  - Auth: `google_id` environment variable (optional - blank in current config)
  - Implementation: `_includes/analytics.html`
  - Only active in production environment

**Academic Profiles:**
- Google Scholar - Academic publication profile linking
  - URL: `https://scholar.google.com/citations?user=fiqihP4AAAAJ&hl=en`
  - Implementation: Footer and sidebar links in `_includes/footer.html`, `_includes/sidebar.html`

**Development Platforms:**
- GitHub - Code repository and project showcase
  - URL: `https://github.com/zhangtaolab`
  - Additional project: `https://github.com/zhangtaolab/DNALLM`
  - Implementation: Footer links and sidebar icons

## Data Storage

**Databases:**
- None - Static site with file-based content storage
  - Bibliography: `assets/ref.bib` (BibTeX file for academic citations)
  - Content data: YAML files in `_data/` directory

**File Storage:**
- Local filesystem only
  - Images: `images/` directory
  - Assets: `assets/` directory
  - Static files compiled during build

**Caching:**
- Browser-based caching only
  - Font cache: MathJax SVG font cache set to 'global'
  - No server-side caching implementation

## Authentication & Identity

**Auth Provider:**
- None - Public static website with no authentication
  - No user login or account management
  - No protected/admin areas

**Academic Identity:**
- ORCID integration available (blank in current config)
  - Placeholder in `_includes/head.html` for structured data
  - Footer link implementation ready

## Monitoring & Observability

**Error Tracking:**
- None - No error tracking service configured

**Logs:**
- Local development logs only (Jekyll build output)
  - No production logging system
  - No error aggregation services

## CI/CD & Deployment

**Hosting:**
- Static hosting compatible
  - Domain: `https://zhangtaolab.org`
  - Likely GitHub Pages, Netlify, or similar static hosting
  - No server-side requirements

**CI Pipeline:**
- None detected - Manual deployment likely
  - No `.github/workflows/` or similar CI configuration
  - No automated build/deploy pipelines

## Environment Configuration

**Required env vars:**
- None strictly required (site functions without external services)
- Optional: `google_id` for Google Analytics

**Secrets location:**
- No secrets management required
  - All configuration in `_config.yml` (public)
  - No API keys or authentication tokens in use

## Webhooks & Callbacks

**Incoming:**
- None - No webhook endpoints configured

**Outgoing:**
- None - No outgoing webhook integrations

## Content Delivery Networks

**Font Services:**
- Google Fonts - Typography delivery
  - Fonts: DM Sans, Source Serif 4, JetBrains Mono
  - Preconnect optimization implemented

**Icon Libraries:**
- Font Awesome 6.5.1 - General icon set
  - CDN: `https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css`
  - Integrity check implemented

- Academicons - Academic-specific icons
  - CDN: `https://cdn.jsdelivr.net/gh/jpswalsh/academicons@1/css/academicons.min.css`
  - Used for Google Scholar, ORCID, etc.

**Mathematics Rendering:**
- MathJax 3 - Mathematical equation rendering
  - CDN: `https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js`
  - Inline math configuration: `['$', '$']` and `['\(', '\)']`

## Social Media & Sharing

**Open Graph Protocol:**
- Implemented in `_includes/head.html`
  - og:title, og:description, og:type, og:url
  - Twitter card metadata (summary type)
  - Dynamic image tags for social sharing

**RSS Feed:**
- Generated via `feed.xml` template
  - Includes both blog posts and news items
  - RFC822 date formatting
  - 20-item limit per feed type

**Structured Data:**
- JSON-LD schema.org implementation
  - WebSite/WebPage types based on URL
  - Author information with affiliation
  - SameAs links for academic profiles

## Search Functionality

**Site Search:**
- Client-side search implementation
  - Index: `/assets/search.json` (generated during build)
  - Algorithm: Simple string matching with case-insensitive search
  - Keyboard shortcut: Cmd/Ctrl+K
  - Debounced input (150ms delay)
  - No external search service required

---

*Integration audit: 2026-08-17*