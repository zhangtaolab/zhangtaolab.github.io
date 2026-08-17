<!-- GSD:project-start source:PROJECT.md -->

## Project

**Zhang Tao Lab 主页（全新版本）**

Zhang Tao Lab（zhangtaolab.org）实验室主页的全新大版本，基于 Jekyll 4.3.3 静态站点生成。面向访客展示研究方向、论文出版物、团队成员、新闻动态等内容，由实验室成员日常维护。本项目的目标是让这个已完成开发的新版本在本地可测试、内容可日常更新、推送后自动部署上线。

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

### Constraints

- **Tech stack**: 保持 Jekyll + 现有插件体系（jekyll-scholar、jekyll-sitemap）— 大版本已完成，不做框架重写
- **Compatibility**: 本机 Ruby 4.0.6 与 Jekyll 4.3.3 存在兼容风险 — 允许小版本升级 Jekyll 或钉住 Ruby 版本，以最小改动、可长期维护为准
- **Deployment**: GitHub Pages 必须走 GitHub Actions 完整构建 — jekyll-scholar 需要 Ruby 环境，Pages 原生构建不可用
- **Domain**: zhangtaolab.org 自定义域名沿用，`baseurl` 保持为空

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Languages

- Ruby - Jekyll templating and site generation (`_config.yml`, `Gemfile`)
- JavaScript - Interactive frontend functionality (`assets/js/site.js`)
- SCSS/Sass - Styling and theming (`assets/main.scss`, `assets/css/custom.scss`)
- YAML - Site configuration and data (`_config.yml`, `_data/*.yml`)
- Markdown - Content authoring (`.md` files in `_pages/`)

## Runtime

- Ruby - Runtime for Jekyll static site generator
- Bundler (gem) - Ruby package management
- Lockfile: Not present (uses `Gemfile` without lock)

## Frameworks

- Jekyll 4.3.3 - Static site generator
- Bootstrap 5.3.3 - Frontend CSS framework (selective imports via `assets/main.scss`)
- Popper.js 2.11.8 - Tooltip and popover positioning engine
- Not applicable (no testing framework detected)
- Jekyll build system - Static site compilation
- Sass-embedded 1.77.0 - SCSS compilation with compressed output
- Kramdown-parser-gfm - GitHub Flavored Markdown processor
- Rouge - Syntax highlighting for code blocks

## Key Dependencies

- jekyll-scholar - Bibliography management and academic citation formatting
- jekyll-sitemap - Automatic sitemap.xml generation for SEO
- rack 2.2.3+ - Ruby web server interface
- webrick 1.7 - Local development web server
- csv - Data processing for publications/content
- base64 - Encoding utilities
- bigdecimal - Precision mathematics
- observer - Ruby observer pattern implementation

## Configuration

- Jekyll configuration via `_config.yml`
- Environment-aware build: `{% if jekyll.environment == 'production' %}` in templates
- Key configs required: Site URL, baseurl, analytics IDs (optional)
- Sass compression enabled (`style: compressed`)
- SCSS quiet dependencies to suppress Bootstrap warnings
- Markdown processing with Kramdown (GitHub Flavored)
- Plugin system enabled for jekyll-sitemap

## Platform Requirements

- Ruby runtime with Jekyll 4.3.3
- Bundler for dependency management
- Local web server (webrick)
- File system for static file generation
- Static file hosting (GitHub Pages, Netlify, Vercel, or any web server)
- No server-side Ruby required in production (fully static)
- HTTPS capability recommended for analytics and modern features

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## Naming Patterns

- Jekyll pages: lowercase with hyphens (e.g., `home.md`, `about.md`, `publications.md`)
- Layouts: descriptive names, some abbreviated (e.g., `default.html`, `gridlay.html`, `homelay.html`)
- SCSS partials: underscore prefix with hyphens (e.g., `_variables.scss`, `_navbar.scss`)
- Data files: lowercase with hyphens (e.g., `team_members.yml`, `news.yml`)
- Includes: lowercase with hyphens (e.g., `head.html`, `footer.html`)
- JavaScript: camelCase function names (e.g., `updateIcon()`, `openSearch()`, `renderResults()`)
- SCSS mixins: kebab-case when used (e.g., Bootstrap's `.border-radius()`)
- JavaScript: camelCase (e.g., `searchData`, `fadeElements`, `debounceTimer`)
- SCSS/CSS: kebab-case with `--` prefix for custom properties (e.g., `--accent`, `--bg-primary`, `--space-4`)
- YAML: lowercase with underscores (e.g., `google_scholar`, `dark_mode`)
- SCSS uses CSS custom properties as type system for theming
- Liquid templates use `site.` and `page.` variable namespaces

## Code Style

- SCSS: Standard indentation, 2-space or 4-space consistency within files
- JavaScript: Traditional function expressions, semicolon usage, strict mode wrapping
- YAML: Standard hyphen-separated lists, key-value pairs with colons
- HTML: Semantic HTML5 elements, lowercase attribute names
- No formal linting configuration detected (no `.eslintrc*`, `.prettierrc*`, `stylelint` files)
- Manual code formatting appears consistent across files

## Import Organization

- Jekyll uses `{{ site.url }}{{ site.baseurl }}` for asset paths
- SCSS uses relative imports for partials
- JavaScript uses direct DOM element references

## Error Handling

- JavaScript uses conditional checks for element existence before manipulation
- Example pattern: `if (!searchOverlay) return;`
- Fallback content for missing data in Liquid templates: `{% if site.data.pi %}...{% endif %}`
- Fetch errors handled with `.catch()` blocks and user feedback

## Logging

- No production logging detected (static site deployment)
- Development would use browser console for debugging
- No error tracking service integration (no Sentry, LogRocket, etc.)

## Comments

- SCSS files use section headers with `// =============================================================`
- JavaScript files include descriptive headers and function groupings
- Complex logic explanations in code comments
- No formal JSDoc usage detected
- Comments are plain text, function descriptions only

## Function Design

- JavaScript functions use parameters sparingly (0-3 parameters typical)
- Event handlers use DOM event objects
- Helper functions accept data callback patterns
- Functions focused on side effects (DOM manipulation) rather than return values
- Some callback patterns for async operations
- Example: `loadSearchData(callback)` pattern

## Module Design

- JavaScript uses IIFE (Immediately Invoked Function Expression) pattern:
- No ES6 module system detected
- SCSS uses `main.scss` as barrel file importing all components
- No JavaScript barrel files

## YAML Configuration

- All Jekyll pages use YAML front matter between `---` delimiters
- Consistent fields: `title`, `layout`, `sitemap`, `permalink`

## HTML/Liquid Template Conventions

- Conditionals: `{% if %}...{% endif %}`
- Loops: `{% for item in site.data.pi %}...{% endfor %}`
- Output: `{{ variable }}` with pipe filters like `| escape`, `| relative_url`
- Access control: `{% if site.data.pi %}` for optional data
- Semantic HTML5 elements (`<nav>`, `<main>`, `<article>`)
- ARIA attributes where appropriate (`aria-label`, `role`)
- Alt text for images
- Focus management for modals and interactive elements

## CSS Architecture Conventions

- CSS custom properties for theming (`--accent`, `--bg-primary`, `--text-secondary`)
- Dark mode support via `[data-bs-theme="dark"]` selector
- Spacing scale: `--space-1` through `--space-16`
- Border radius scale: `--radius-sm` through `--radius-full`
- BEM-like naming for components (`.card-academic`, `.pub-entry`, `.year-badge`)
- Utility-first approach for some styles (`.text-center`, `.mt-4`)
- Component-specific styles in dedicated SCSS files

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## System Overview

```text

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

- **Static generation**: All content processed at build time into HTML
- **Template inheritance**: Layouts extend each other (e.g., `homelay` → `default`)
- **Content-data separation**: Markdown for prose, YAML for structured data
- **Component-based architecture**: Reusable includes for common UI elements
- **Bootstrap integration**: Frontend framework for responsive design
- **Academic features**: Bibliography management through Jekyll-Scholar plugin

## Layers

- Purpose: Author-facing content management and site structure
- Location: `_pages/`, `_data/`, `papers/`
- Contains: Markdown pages with YAML frontmatter, structured data files, bibliography
- Depends on: Jekyll frontmatter processing, Jekyll-Scholar plugin
- Used by: Template layer for rendering
- Purpose: HTML structure and presentation logic
- Location: `_layouts/`, `_includes/`
- Contains: Page templates, reusable components, liquid template logic
- Depends on: Content layer (data), Bootstrap framework
- Used by: Jekyll build process
- Purpose: Styling, interactivity, and static resources
- Location: `_sass/`, `assets/css/`, `assets/js/`, `images/`
- Contains: SASS stylesheets, JavaScript functionality, image assets
- Depends on: Bootstrap framework, Font Awesome icons
- Used by: Template layer (referenced in HTML)

## Data Flow

### Primary Request Path

### Content Rendering Flow

- **Server-side**: No runtime state — all content processed at build time
- **Client-side**: JavaScript manages UI state (theme preference, search, scroll position) via localStorage

## Key Abstractions

- Purpose: Page-level configuration and metadata
- Examples: `layout: homelay`, `permalink: /research/`, `sitemap: false`
- Pattern: YAML block at top of Markdown files
- Purpose: Template logic and data access
- Examples: `{% for nav in site.nav_pages %}`, `{{ site.name }}`, `{% if page.title %}`
- Pattern: Jekyll-specific templating syntax
- Purpose: Template inheritance and DRY principles
- Examples: `homelay` extends `default`, `gridlay` extends `default`
- Pattern: Nested layouts via `layout: parent` in frontmatter
- Purpose: Structured content separation from presentation
- Examples: `_data/people.yml`, `_data/news.yml`
- Pattern: Access via `site.data.filename` in templates

## Entry Points

- Location: `_config.yml`
- Triggers: All Jekyll builds
- Responsibilities: Site metadata, navigation structure, plugin configuration, build settings
- Location: `_pages/home.md`
- Triggers: Root URL (`/`)
- Responsibilities: Landing page with hero section, research areas, news preview
- Location: `_includes/header.html` + `nav_pages:` in `_config.yml`
- Triggers: All pages (header component)
- Responsibilities: Site navigation, search toggle, dark mode toggle
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

### Deep Layout Nesting

### Mixed Content in Layout Files

## Error Handling

- **Missing data**: Liquid conditional checks (`{% if site.data.team_members %}`)
- **Image fallbacks**: Default avatar images when member photos missing (`avatar.jpg`)
- **Build failures**: Jekyll shows detailed error messages for syntax issues
- **Plugin errors**: Graceful degradation if optional plugins unavailable

## Cross-Cutting Concerns

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:

- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
