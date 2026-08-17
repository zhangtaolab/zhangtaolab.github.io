<!-- refreshed: 2026-08-17 -->
# Architecture

**Analysis Date:** 2026-08-17

## System Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                    User Browser (Client)                         │
└──────────────────────────────┬──────────────────────────────────┘
                               │ HTTP Request
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Jekyll Static Site Generator                   │
│              `/Users/forrest/Playground/zhangtaolab-jekyll`      │
├──────────────────┬──────────────────┬───────────────────────────┤
│   Content Layer  │   Template Layer │   Asset Layer              │
│  `_pages/*.md`   │  `_layouts/*.html`│  `_sass/`, `assets/`     │
│  `_data/*.yml`   │  `_includes/*.html`│  `assets/js/`            │
└────────┬─────────┴────────┬─────────┴──────────┬───────────────┘
         │                  │                     │
         ▼                  ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Built Static HTML Site                        │
│                    (Deployment Target)                            │
└─────────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **Jekyll Config** | Site metadata, navigation, plugin config, build settings | `_config.yml` |
| **Page Content** | Markdown content with frontmatter defining layout and metadata | `_pages/*.md` |
| **Layout Templates** | HTML structure and component hierarchy for different page types | `_layouts/*.html` |
| **Include Components** | Reusable UI components (header, footer, sidebar, analytics) | `_includes/*.html` |
| **Data Files** | Structured content for team members, news, grants, alumni | `_data/*.yml` |
| **SASS Stylesheets** | Bootstrap framework, custom styles, responsive design | `_sass/`, `assets/css/` |
| **JavaScript** | Interactive features (dark mode, search, publication filters) | `assets/js/site.js` |
| **Bibliography** | Academic publications managed through Jekyll-Scholar plugin | `papers/ref.bib` |
| **Static Assets** | Images organized by category (team, research, software) | `images/` |

## Pattern Overview

**Overall:** Static Site Generator with Template Inheritance

**Key Characteristics:**
- **Static generation**: All content processed at build time into HTML
- **Template inheritance**: Layouts extend each other (e.g., `homelay` → `default`)
- **Content-data separation**: Markdown for prose, YAML for structured data
- **Component-based architecture**: Reusable includes for common UI elements
- **Bootstrap integration**: Frontend framework for responsive design
- **Academic features**: Bibliography management through Jekyll-Scholar plugin

## Layers

**Content Layer:**
- Purpose: Author-facing content management and site structure
- Location: `_pages/`, `_data/`, `papers/`
- Contains: Markdown pages with YAML frontmatter, structured data files, bibliography
- Depends on: Jekyll frontmatter processing, Jekyll-Scholar plugin
- Used by: Template layer for rendering

**Template Layer:**
- Purpose: HTML structure and presentation logic
- Location: `_layouts/`, `_includes/`
- Contains: Page templates, reusable components, liquid template logic
- Depends on: Content layer (data), Bootstrap framework
- Used by: Jekyll build process

**Asset Layer:**
- Purpose: Styling, interactivity, and static resources
- Location: `_sass/`, `assets/css/`, `assets/js/`, `images/`
- Contains: SASS stylesheets, JavaScript functionality, image assets
- Depends on: Bootstrap framework, Font Awesome icons
- Used by: Template layer (referenced in HTML)

## Data Flow

### Primary Request Path

1. **User Request** (`https://zhangtaolab.org/`) — Browser requests page
2. **Jekyll Build** (`_config.yml` → `_pages/home.md` → `_layouts/homelay.html` → `_layouts/default.html`) — Static site generation processes templates and content
3. **Static HTML Response** (`_site/` directory) — Pre-built HTML served to user
4. **Client Interactivity** (`assets/js/site.js`) — JavaScript enhances UX (dark mode, search, etc.)

### Content Rendering Flow

1. **Markdown Processing** (`_pages/*.md`) — Jekyll processes markdown with YAML frontmatter
2. **Template Inheritance** (`_layouts/*.html`) — Layout selection via `layout:` frontmatter field
3. **Component Injection** (`_includes/*.html`) — Liquid template language inserts reusable components
4. **Data Access** (`site.data.*`) — YAML data files accessed via site.data object
5. **Static Asset Linking** — CSS, JS, images referenced via relative paths

**State Management:**
- **Server-side**: No runtime state — all content processed at build time
- **Client-side**: JavaScript manages UI state (theme preference, search, scroll position) via localStorage

## Key Abstractions

**Jekyll Frontmatter:**
- Purpose: Page-level configuration and metadata
- Examples: `layout: homelay`, `permalink: /research/`, `sitemap: false`
- Pattern: YAML block at top of Markdown files

**Liquid Template Language:**
- Purpose: Template logic and data access
- Examples: `{% for nav in site.nav_pages %}`, `{{ site.name }}`, `{% if page.title %}`
- Pattern: Jekyll-specific templating syntax

**Layout Hierarchy:**
- Purpose: Template inheritance and DRY principles
- Examples: `homelay` extends `default`, `gridlay` extends `default`
- Pattern: Nested layouts via `layout: parent` in frontmatter

**YAML Data Files:**
- Purpose: Structured content separation from presentation
- Examples: `_data/people.yml`, `_data/news.yml`
- Pattern: Access via `site.data.filename` in templates

## Entry Points

**Site Configuration:**
- Location: `_config.yml`
- Triggers: All Jekyll builds
- Responsibilities: Site metadata, navigation structure, plugin configuration, build settings

**Home Page:**
- Location: `_pages/home.md`
- Triggers: Root URL (`/`)
- Responsibilities: Landing page with hero section, research areas, news preview

**Navigation System:**
- Location: `_includes/header.html` + `nav_pages:` in `_config.yml`
- Triggers: All pages (header component)
- Responsibilities: Site navigation, search toggle, dark mode toggle

**RSS Feed:**
- Location: `feed.xml`
- Triggers: `/feed.xml` endpoint
- Responsibilities: RSS syndication of publications and news

## Architectural Constraints

- **Build-time generation**: All content must be processed during Jekyll build — no server-side rendering
- **Static hosting**: Deployment assumes static file serving (no backend required)
- **Plugin dependencies**: Requires specific Jekyll plugins (jekyll-scholar, jekyll-sitemap)
- **Ruby runtime**: Build environment requires Ruby and Jekyll gems
- **Bootstrap dependency**: Frontend assumes Bootstrap 5 framework and CSS variables
- **JavaScript requirements**: Modern browser features (localStorage, IntersectionObserver, fetch API)
- **File-based routing**: URL structure determined by file placement and frontmatter

## Anti-Patterns

### Hardcoded Content in Templates

**What happens:** Research area descriptions, team member details embedded directly in HTML templates
**Why it's wrong:** Violates content-data separation, makes updates difficult, bypasses Jekyll's data management
**Do this instead:** Use `_data/*.yml` files for structured content, reference via `site.data.*` in templates

### Deep Layout Nesting

**What happens:** Layouts extending more than 2-3 levels deep (e.g., specific → category → default)
**Why it's wrong:** Makes debugging difficult, obscures which layout is actually used
**Do this instead:** Keep layout hierarchy shallow (2 levels max), use includes for shared components

### Mixed Content in Layout Files

**What happens:** Page-specific content written directly into layout templates
**Why it's wrong:** Breaks template reusability, mixes concerns
**Do this instead:** Keep layouts pure HTML structure, put all content in markdown pages

## Error Handling

**Strategy:** Jekyll build-time validation with graceful fallbacks

**Patterns:**
- **Missing data**: Liquid conditional checks (`{% if site.data.team_members %}`)
- **Image fallbacks**: Default avatar images when member photos missing (`avatar.jpg`)
- **Build failures**: Jekyll shows detailed error messages for syntax issues
- **Plugin errors**: Graceful degradation if optional plugins unavailable

## Cross-Cutting Concerns

**SEO:** Meta tags in `_includes/head.html`, structured data (JSON-LD), sitemap generation
**Responsive Design:** Bootstrap grid system, mobile-first CSS, image lazy loading
**Accessibility:** Semantic HTML, ARIA labels on interactive elements, keyboard navigation support
**Performance:** Minified CSS/JS assets, optimized images, CDN for fonts and icons
**Internationalization:** Currently English-only, no i18n framework implemented

---

*Architecture analysis: 2026-08-17*