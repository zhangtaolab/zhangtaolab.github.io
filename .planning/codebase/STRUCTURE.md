# Codebase Structure

**Analysis Date:** 2026-08-17

## Directory Layout

```
/Users/forrest/Playground/zhangtaolab-jekyll/
├── _config.yml              # Jekyll site configuration
├── _data/                   # Structured data files
│   ├── alumni.yml           # Former lab members
│   ├── grants.yml           # Research funding information
│   ├── news.yml             # Lab news and announcements
│   ├── people.yml           # Current lab members
│   ├── pi.yml               # Principal investigator information
│   └── team_members.yml     # Extended team data
├── _includes/               # Reusable HTML components
│   ├── analytics.html       # Google Analytics integration
│   ├── csv_to_table.html    # CSV to HTML table converter
│   ├── footer.html          # Site footer with links
│   ├── head.html            # HTML head with meta tags and styles
│   ├── header.html          # Navigation bar and search
│   ├── mathjax.html         # MathJax for scientific notation
│   └── sidebar.html         # Sidebar for home page layout
├── _layouts/                # Page layout templates
│   ├── bibtemplate.html     # Bibliography entry layout
│   ├── default.html         # Base layout with header/footer
│   ├── gridlay.html         # Grid layout with fade-in animation
│   ├── homelay.html         # Home page layout with sidebar
│   ├── page.html            # Standard page layout
│   ├── piclay.html          # Photo-centric layout
│   ├── post.html            # Blog post layout
│   ├── publications.html    # Publications page layout
│   ├── research.html        # Research projects layout
│   ├── team.html            # Team members page layout
│   └── textlay.html         # Text-focused page layout
├── _pages/                  # Markdown page content
│   ├── 404.md              # Custom error page
│   ├── about.md            # About the lab page
│   ├── allnews.md          # All news listing page
│   ├── blogs.md            # Blog posts page
│   ├── contact.md          # Contact information page
│   ├── home.md             # Home page (landing page)
│   ├── news.md             # News overview page
│   ├── publications.md     # Publications list page
│   ├── research.md         # Research areas page
│   ├── software.md         # Software tools page
│   ├── talks.md            # Presentations and talks page
│   ├── teaching.md         # Teaching activities page
│   └── team.md             # Team members page
├── _sass/                   # SASS stylesheets
│   ├── bootstrap.scss       # Bootstrap framework entry point
│   ├── bootstrap/          # Bootstrap component styles
│   │   ├── _functions.scss
│   │   ├── _variables.scss
│   │   ├── _mixins.scss
│   │   ├── _navbar.scss
│   │   ├── _forms.scss
│   │   └── [other Bootstrap components]
│   ├── components/         # Custom UI components
│   ├── base/              # Base styles and resets
│   ├── layouts/           # Layout-specific styles
│   └── utilities/         # Utility classes
├── assets/                  # Static assets
│   ├── css/               # Custom CSS
│   │   └── custom.scss    # Site-specific custom styles
│   ├── javascript/        # Third-party JavaScript
│   │   ├── bootstrap/    # Bootstrap JavaScript framework
│   │   └── popper/        # Popper.js for Bootstrap
│   └── js/                # Custom JavaScript
│       ├── site.js        # Site functionality
│       └── site.min.js   # Minified site script
├── images/                 # Image assets
│   ├── research/          # Research area images
│   ├── software/          # Software tool screenshots
│   ├── team/              # Team member photos
│   ├── banner.jpg         # Site banner image
│   ├── logo.png           # Site logo
│   └── headshot.jpg       # PI headshot (referenced in config)
├── papers/                 # Academic publications
│   └── ref.bib           # BibTeX bibliography file
├── .planning/             # GSD planning directory
│   └── codebase/         # Codebase mapping documents
├── Gemfile               # Ruby dependencies
├── feed.xml              # RSS feed template
├── favicon.ico           # Site favicon (ICO format)
├── favicon.svg           # Site favicon (SVG format)
├── robots.txt            # Search engine directives
└── README.md             # Project documentation (if present)
```

## Directory Purposes

**_config.yml:**
- Purpose: Central Jekyll configuration and site metadata
- Contains: Site name, navigation structure, plugin settings, build configuration
- Key files: `_config.yml`

**_data:**
- Purpose: Structured data files for dynamic content
- Contains: YAML files with team information, news items, grants, alumni
- Key files: `people.yml`, `news.yml`, `team_members.yml`, `alumni.yml`

**_includes:**
- Purpose: Reusable HTML components for template composition
- Contains: Header, footer, analytics, utility components
- Key files: `head.html`, `header.html`, `footer.html`, `sidebar.html`

**_layouts:**
- Purpose: Page template hierarchy for different content types
- Contains: HTML templates with liquid template syntax
- Key files: `default.html`, `homelay.html`, `page.html`, `gridlay.html`

**_pages:**
- Purpose: User-facing markdown content with frontmatter configuration
- Contains: Site pages (research, team, publications, etc.)
- Key files: `home.md`, `research.md`, `team.md`, `publications.md`

**_sass:**
- Purpose: SASS stylesheets compiled to CSS
- Contains: Bootstrap framework, custom components, utilities
- Key files: `bootstrap.scss`, `bootstrap/_variables.scss`

**assets:**
- Purpose: Static assets for frontend functionality and styling
- Contains: Custom CSS, JavaScript, third-party libraries
- Key files: `css/custom.scss`, `js/site.js`

**images:**
- Purpose: Visual content organized by category
- Contains: Research area images, team photos, logos, banners
- Key files: `research/*.jpg`, `team/*.jpg`, `logo.png`

**papers:**
- Purpose: Academic bibliography management
- Contains: BibTeX file for publications
- Key files: `ref.bib`

## Key File Locations

**Entry Points:**
- `_config.yml`: Site configuration, navigation structure, plugin settings
- `_pages/home.md`: Landing page content
- `feed.xml`: RSS feed endpoint

**Configuration:**
- `_config.yml`: Primary Jekyll configuration file
- `Gemfile`: Ruby gem dependencies for build process

**Core Logic:**
- `_includes/header.html`: Navigation and search functionality
- `_includes/head.html`: Meta tags, styles, analytics
- `_layouts/default.html`: Base layout template
- `assets/js/site.js`: Interactive features (dark mode, search, filters)

**Testing:**
- No test files detected (static site with no backend logic)

## Naming Conventions

**Files:**
- Markdown pages: `kebab-case.md` (e.g., `home.md`, `research.md`)
- Layout templates: `lowercase-with-optional-suffix.html` (e.g., `homelay.html`, `page.html`)
- Includes: `kebab-case.html` (e.g., `header.html`, `footer.html`)
- Data files: `kebab-case.yml` (e.g., `team_members.yml`, `grants.yml`)
- JavaScript: `kebab-case.js` (e.g., `site.js`)
- SASS: `kebab-case.scss` (e.g., `custom.scss`)
- Images: `descriptive-name.jpg` (e.g., `dna-llm.jpg`, `crispr.jpg`)

**Directories:**
- Jekyll system directories: `_underscore` (e.g., `_layouts`, `_includes`)
- Content directories: `plural` (e.g., `images`, `papers`, `assets`)
- Asset subdirectories: `category` (e.g., `research`, `software`, `team`)

**Liquid Variables:**
- Site configuration: `site.*` (e.g., `site.name`, `site.data.news`)
- Page data: `page.*` (e.g., `page.title`, `page.layout`)
- Layout references: `layout: name` (lowercase, no extension)

## Where to Add New Code

**New Page:**
- Primary content: `_pages/[page-name].md` (markdown with YAML frontmatter)
- Layout selection: Specify existing layout in frontmatter (`layout: page`)
- Custom layout: Create in `_layouts/[layout-name].html` if new pattern needed
- Data access: Add to `_data/[data-name].yml` if structured content required

**New Component/Module:**
- Implementation: `_includes/[component-name].html` for reusable HTML
- Styling: Add to `_sass/components/[component].scss` or `assets/css/custom.scss`
- Interactivity: Add to `assets/js/site.js` or create new JS file

**Utilities:**
- Shared helpers: `_includes/[helper-name].html` for liquid template utilities
- SASS utilities: `_sass/utilities/[utility].scss`
- JavaScript utilities: `assets/js/[utility-name].js`

**Images:**
- Team photos: `images/team/[member-name].jpg`
- Research areas: `images/research/[area-name].jpg`
- Software screenshots: `images/software/[tool-name].jpg`
- Site assets: `images/[asset-name].[ext]` (logo, banner, etc.)

**Academic Content:**
- Publications: Add BibTeX entries to `papers/ref.bib`
- News items: Add to `_data/news.yml`
- Team members: Add to `_data/team_members.yml` or `_data/people.yml`
- Alumni: Add to `_data/alumni.yml`

## Special Directories

**_layouts:**
- Purpose: Jekyll template inheritance system
- Generated: No — hand-written templates
- Committed: Yes

**_includes:**
- Purpose: Reusable HTML components injected via Liquid includes
- Generated: No — hand-written components
- Committed: Yes

**_data:**
- Purpose: Structured YAML data accessed via `site.data.*`
- Generated: No — manually maintained data files
- Committed: Yes

**_sass:**
- Purpose: SASS compilation to CSS
- Generated: CSS output during Jekyll build
- Committed: Yes (source SASS files)

**assets/javascript:**
- Purpose: Third-party JavaScript libraries (Bootstrap, Popper)
- Generated: No — committed dependencies
- Committed: Yes

**_site:**
- Purpose: Jekyll build output directory
- Generated: Yes — created during `jekyll build`
- Committed: No (typically in `.gitignore`)

---

*Structure analysis: 2026-08-17*