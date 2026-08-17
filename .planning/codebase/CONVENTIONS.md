# Coding Conventions

**Analysis Date:** 2026-08-17

## Naming Patterns

**Files:**
- Jekyll pages: lowercase with hyphens (e.g., `home.md`, `about.md`, `publications.md`)
- Layouts: descriptive names, some abbreviated (e.g., `default.html`, `gridlay.html`, `homelay.html`)
- SCSS partials: underscore prefix with hyphens (e.g., `_variables.scss`, `_navbar.scss`)
- Data files: lowercase with hyphens (e.g., `team_members.yml`, `news.yml`)
- Includes: lowercase with hyphens (e.g., `head.html`, `footer.html`)

**Functions:**
- JavaScript: camelCase function names (e.g., `updateIcon()`, `openSearch()`, `renderResults()`)
- SCSS mixins: kebab-case when used (e.g., Bootstrap's `.border-radius()`)

**Variables:**
- JavaScript: camelCase (e.g., `searchData`, `fadeElements`, `debounceTimer`)
- SCSS/CSS: kebab-case with `--` prefix for custom properties (e.g., `--accent`, `--bg-primary`, `--space-4`)
- YAML: lowercase with underscores (e.g., `google_scholar`, `dark_mode`)

**Types:**
- SCSS uses CSS custom properties as type system for theming
- Liquid templates use `site.` and `page.` variable namespaces

## Code Style

**Formatting:**
- SCSS: Standard indentation, 2-space or 4-space consistency within files
- JavaScript: Traditional function expressions, semicolon usage, strict mode wrapping
- YAML: Standard hyphen-separated lists, key-value pairs with colons
- HTML: Semantic HTML5 elements, lowercase attribute names

**Linting:**
- No formal linting configuration detected (no `.eslintrc*`, `.prettierrc*`, `stylelint` files)
- Manual code formatting appears consistent across files

## Import Organization

**Order:**
1. Jekyll front matter (YAML) with `---` delimiters
2. HTML structure
3. CSS/SCSS imports: Bootstrap → Base → Components → Layouts → Utilities
4. JavaScript: DOM element selection → Event handlers → Helper functions

**Path Aliases:**
- Jekyll uses `{{ site.url }}{{ site.baseurl }}` for asset paths
- SCSS uses relative imports for partials
- JavaScript uses direct DOM element references

**Example import order from `assets/main.scss`:**
```scss
// Bootstrap 5.3.3 — selective imports
@import "bootstrap/functions";
@import "bootstrap/variables";
// ... more Bootstrap imports

// Base
@import "base/variables";
@import "base/reset";

// Components
@import "components/card";
@import "components/navbar";
```

## Error Handling

**Patterns:**
- JavaScript uses conditional checks for element existence before manipulation
- Example pattern: `if (!searchOverlay) return;`
- Fallback content for missing data in Liquid templates: `{% if site.data.pi %}...{% endif %}`
- Fetch errors handled with `.catch()` blocks and user feedback

**Example error handling pattern from `assets/js/site.js`:**
```javascript
fetch('/assets/search.json')
  .then(function (r) { return r.json(); })
  .then(function (data) {
    searchData = data;
    callback(data);
  })
  .catch(function () {
    searchResultsEl.innerHTML = '<div class="search-no-results">Could not load search index.</div>';
  });
```

## Logging

**Framework:** Console API (no structured logging framework)

**Patterns:**
- No production logging detected (static site deployment)
- Development would use browser console for debugging
- No error tracking service integration (no Sentry, LogRocket, etc.)

## Comments

**When to Comment:**
- SCSS files use section headers with `// =============================================================`
- JavaScript files include descriptive headers and function groupings
- Complex logic explanations in code comments

**JSDoc/TSDoc:**
- No formal JSDoc usage detected
- Comments are plain text, function descriptions only

**Example comment style from `assets/js/site.js`:**
```javascript
// =============================================================
// site.js — Dark mode, publication filter, toggles, scroll effects,
//           copy bibtex, back-to-top, year badges
// =============================================================
```

## Function Design

**Size:** Small, focused functions (5-50 lines typical)

**Parameters:**
- JavaScript functions use parameters sparingly (0-3 parameters typical)
- Event handlers use DOM event objects
- Helper functions accept data callback patterns

**Return Values:**
- Functions focused on side effects (DOM manipulation) rather than return values
- Some callback patterns for async operations
- Example: `loadSearchData(callback)` pattern

**Example function pattern:**
```javascript
function updateIcon() {
  if (!icon) return;
  var theme = document.documentElement.getAttribute('data-bs-theme');
  if (theme === 'dark') {
    icon.className = 'fa-solid fa-moon';
  } else {
    icon.className = 'fa-solid fa-sun';
  }
}
```

## Module Design

**Exports:**
- JavaScript uses IIFE (Immediately Invoked Function Expression) pattern:
  ```javascript
  (function () {
    'use strict';
    // all code here
  })();
  ```
- No ES6 module system detected

**Barrel Files:**
- SCSS uses `main.scss` as barrel file importing all components
- No JavaScript barrel files

**SCSS import pattern:**
```scss
// Bootstrap 5.3.3 — selective imports
@import "bootstrap/functions";
@import "bootstrap/variables";

// Base
@import "base/variables";
@import "base/reset";

// Components
@import "components/navbar";
```

## YAML Configuration

**Front Matter Pattern:**
- All Jekyll pages use YAML front matter between `---` delimiters
- Consistent fields: `title`, `layout`, `sitemap`, `permalink`

**Example front matter:**
```yaml
---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---
```

## HTML/Liquid Template Conventions

**Template Language:** Liquid (Jekyll templating)

**Patterns:**
- Conditionals: `{% if %}...{% endif %}`
- Loops: `{% for item in site.data.pi %}...{% endfor %}`
- Output: `{{ variable }}` with pipe filters like `| escape`, `| relative_url`
- Access control: `{% if site.data.pi %}` for optional data

**Accessibility:**
- Semantic HTML5 elements (`<nav>`, `<main>`, `<article>`)
- ARIA attributes where appropriate (`aria-label`, `role`)
- Alt text for images
- Focus management for modals and interactive elements

## CSS Architecture Conventions

**Design Token System:**
- CSS custom properties for theming (`--accent`, `--bg-primary`, `--text-secondary`)
- Dark mode support via `[data-bs-theme="dark"]` selector
- Spacing scale: `--space-1` through `--space-16`
- Border radius scale: `--radius-sm` through `--radius-full`

**Component Structure:**
- BEM-like naming for components (`.card-academic`, `.pub-entry`, `.year-badge`)
- Utility-first approach for some styles (`.text-center`, `.mt-4`)
- Component-specific styles in dedicated SCSS files

**Example CSS custom properties from `_sass/base/_variables.scss`:**
```scss
:root {
  --accent: #1a7a6d;
  --bg-primary: #f8f6f1;
  --text-primary: #2c2a25;
  --space-4: 1rem;
  --radius-lg: 0.75rem;
}
```

---

*Convention analysis: 2026-08-17*