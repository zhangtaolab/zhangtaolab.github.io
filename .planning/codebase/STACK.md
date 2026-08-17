# Technology Stack

**Analysis Date:** 2026-08-17

## Languages

**Primary:**
- Ruby - Jekyll templating and site generation (`_config.yml`, `Gemfile`)

**Secondary:**
- JavaScript - Interactive frontend functionality (`assets/js/site.js`)
- SCSS/Sass - Styling and theming (`assets/main.scss`, `assets/css/custom.scss`)
- YAML - Site configuration and data (`_config.yml`, `_data/*.yml`)
- Markdown - Content authoring (`.md` files in `_pages/`)

## Runtime

**Environment:**
- Ruby - Runtime for Jekyll static site generator

**Package Manager:**
- Bundler (gem) - Ruby package management
- Lockfile: Not present (uses `Gemfile` without lock)

## Frameworks

**Core:**
- Jekyll 4.3.3 - Static site generator
- Bootstrap 5.3.3 - Frontend CSS framework (selective imports via `assets/main.scss`)
- Popper.js 2.11.8 - Tooltip and popover positioning engine

**Testing:**
- Not applicable (no testing framework detected)

**Build/Dev:**
- Jekyll build system - Static site compilation
- Sass-embedded 1.77.0 - SCSS compilation with compressed output
- Kramdown-parser-gfm - GitHub Flavored Markdown processor
- Rouge - Syntax highlighting for code blocks

## Key Dependencies

**Critical:**
- jekyll-scholar - Bibliography management and academic citation formatting
- jekyll-sitemap - Automatic sitemap.xml generation for SEO
- rack 2.2.3+ - Ruby web server interface
- webrick 1.7 - Local development web server

**Infrastructure:**
- csv - Data processing for publications/content
- base64 - Encoding utilities
- bigdecimal - Precision mathematics
- observer - Ruby observer pattern implementation

## Configuration

**Environment:**
- Jekyll configuration via `_config.yml`
- Environment-aware build: `{% if jekyll.environment == 'production' %}` in templates
- Key configs required: Site URL, baseurl, analytics IDs (optional)

**Build:**
- Sass compression enabled (`style: compressed`)
- SCSS quiet dependencies to suppress Bootstrap warnings
- Markdown processing with Kramdown (GitHub Flavored)
- Plugin system enabled for jekyll-sitemap

## Platform Requirements

**Development:**
- Ruby runtime with Jekyll 4.3.3
- Bundler for dependency management
- Local web server (webrick)
- File system for static file generation

**Production:**
- Static file hosting (GitHub Pages, Netlify, Vercel, or any web server)
- No server-side Ruby required in production (fully static)
- HTTPS capability recommended for analytics and modern features

---

*Stack analysis: 2026-08-17*