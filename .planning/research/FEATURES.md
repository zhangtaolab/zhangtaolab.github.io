# Feature Landscape: Jekyll Academic Lab Website Maintenance Workflow

**Domain:** Academic lab website maintenance workflow (Jekyll-based static sites)
**Researched:** 2026-08-17
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Users Expect These)

Features that academic lab maintainers assume exist. Missing these = maintenance workflow feels broken.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Documented content update procedures** | Lab members need clear steps for adding papers/news/members without learning Jekyll internals | MEDIUM | Step-by-step guides for BibTeX additions, YAML updates, markdown editing |
| **Local preview with live reload** | Essential for content verification before pushing; prevents published errors | LOW | `bundle exec jekyll serve` with live reload functionality |
| **YAML/BibTeX validation before build** | Invalid syntax causes silent build failures; wastes time debugging | MEDIUM | Pre-commit hooks or CI checks for YAML front matter and BibTeX syntax |
| **Automated deployment on push** | Expected behavior for modern web projects; removes manual deployment step | MEDIUM | GitHub Actions workflow triggered on main branch pushes |
| **Production-mode local builds** | Ensures local preview matches production output (JEKYLL_ENV=production) | LOW | Critical for catching environment-specific issues |
| **Basic link checking** | Broken links damage academic credibility and user experience | LOW | HTMLProofer integration in CI pipeline |
| **Build-time strictness** | Catches content errors early rather than post-publication | LOW | `--strict_front_matter` flag for Jekyll builds |

### Differentiators (Competitive Polish)

Features that set the maintenance workflow apart. Not required, but highly valued by busy academics.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **PR preview deployments** | Enables safe collaborative editing; reduces publication risk | HIGH | GitHub Actions community solutions since GitHub Pages lacks native previews |
| **Automated image optimization** | Improves site performance without manual image processing | MEDIUM | Plugins or build scripts for WebP/AVIF conversion and compression |
| **Scheduled dependency updates** | Reduces security risks and maintenance burden | LOW | Dependabot or Renovate for automated Ruby/Gem dependency updates |
| **Draft/staging patterns** | Allows content development without affecting production | MEDIUM | Draft posts and branch-based preview workflows |
| **Atomic artifact deployment** | Eliminates downtime during updates; ensures consistent site state | MEDIUM | GitHub Actions with deployment artifacts rather than direct git pushes |
| **Content update notifications** | Lab members can verify their changes went live | LOW | Deployment status notifications or webhooks |
| **Editor tooling integration** | Lowers barrier for non-technical lab members | HIGH | VS Code extensions, text editor snippets, or web-based editors |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems for small academic lab websites.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **CMS backends (WordPress, etc.)** | Familiar interface; easier for non-technical users | Overkill for static lab sites; introduces security vulnerabilities, hosting costs, and maintenance complexity | Well-documented YAML/BibTeX editing procedures with validation |
| **Heavy test suites** | Ensures content quality | Static content doesn't need extensive testing; creates maintenance burden for small teams | Focused quality gates (link checking, HTML validation) rather than full test suites |
| **Real-time collaboration features** | Multiple lab members editing simultaneously | Unnecessary for publication workflows; adds complexity without solving actual needs | Git-based collaborative editing with PR workflow and preview deployments |
| **Dynamic content rendering** | Permits personalized or interactive content | Abandons static site benefits (security, speed, cost); adds server requirements | Static generation with periodic rebuilds for dynamic-like features |
| **Complex multi-language support** | International lab audiences | Doubles content maintenance burden; rarely fully utilized for small labs | Single language focus with translation services for specific content as needed |
| **Social media integration feeds** | Keeps site "fresh" with social content | Adds external dependencies; social media platforms change frequently | Manual curation of relevant social content in news sections |

## Feature Dependencies

```
[Content update procedures] ──requires──> [YAML/BibTeX validation]
                                        └──enhances──> [Local preview development]

[Local preview development] ──requires──> [Production-mode builds]
                                     └──enables──> [Draft/staging patterns]

[Automated deployment] ──requires──> [Production-mode builds]
                           └──enhanced by──> [Atomic artifact deployment]

[Quality gates (link checking, HTML validation)] ──requires──> [CI pipeline]
                                                        └──enables──> [PR preview deployments]

[PR preview deployments] ──requires──> [CI pipeline]
                              └──requires──> [Automated deployment]

[Scheduled dependency updates] ──requires──> [CI pipeline]
                                       └──enhances──> [Automated deployment]

[Automated image optimization] ──optional for──> [Content update procedures]
```

### Dependency Notes

- **Content update procedures requires YAML/BibTeX validation:** Documentation must include validation steps to prevent build failures; validation tools are prerequisite for effective procedures.
- **Local preview enhanced by YAML/BibTeX validation:** Faster feedback loop when errors are caught during editing rather than during builds.
- **Automated deployment requires production-mode builds:** Deployment pipeline must mirror production environment for accurate testing.
- **PR preview deployments require CI pipeline and automated deployment:** Both infrastructure components must exist before preview functionality can be added.
- **Quality gates require CI pipeline:** Automated validation needs continuous integration infrastructure.
- **Scheduled dependency updates enhance automated deployment:** Keeps deployment pipeline healthy and secure.

## MVP Definition

### Launch With (v1)

Minimum viable maintenance workflow for Zhang Tao Lab website.

- [ ] **Documented content update procedures** — Essential for enabling lab members to maintain content independently
- [ ] **Local preview with live reload** — Required for content verification and workflow usability
- [ ] **Basic YAML/BibTeX validation** — Prevents common build failures and reduces frustration
- [ ] **Production-mode local builds** — Ensures preview accuracy and catches environment issues
- [ ] **Automated deployment on push** — Core value: "push and publish" workflow
- [ ] **Basic link checking in CI** — Catches broken links before publication; quality baseline

### Add After Validation (v1.x)

Features to add once the basic workflow is proven and working.

- [ ] **PR preview deployments** — After GitHub Actions pipeline is stable and team is comfortable with PR workflow
- [ ] **Scheduled dependency updates** — Once deployment automation is reliable and team has capacity
- [ ] **Draft/staging patterns** — When lab members request more sophisticated content development workflows
- [ ] **Content update notifications** — After deployment automation is mature

### Future Consideration (v2+)

Features to defer until maintenance workflow is well-established and mature.

- [ ] **Automated image optimization** — Nice-to-have performance improvement; manual process sufficient initially
- [ ] **Advanced editor tooling integration** — Requires user demand to justify development investment
- [ ] **Atomic artifact deployment** — Current deployment approach likely sufficient; optimize if needed

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Documented content update procedures | HIGH | MEDIUM | P1 |
| Local preview with live reload | HIGH | LOW | P1 |
| YAML/BibTeX validation | HIGH | MEDIUM | P1 |
| Production-mode local builds | HIGH | LOW | P1 |
| Automated deployment on push | HIGH | MEDIUM | P1 |
| Basic link checking in CI | HIGH | LOW | P1 |
| PR preview deployments | MEDIUM | HIGH | P2 |
| Scheduled dependency updates | MEDIUM | LOW | P2 |
| Draft/staging patterns | MEDIUM | MEDIUM | P2 |
| Content update notifications | LOW | LOW | P2 |
| Automated image optimization | MEDIUM | MEDIUM | P3 |
| Editor tooling integration | MEDIUM | HIGH | P3 |
| Atomic artifact deployment | LOW | MEDIUM | P3 |

**Priority key:**
- P1: Must have for launch - core workflow functionality
- P2: Should have - important improvements added after validation
- P3: Nice to have - optimizations for mature workflow

## Competitor Feature Analysis

| Feature | Academic WordPress Sites | Commercial Academic CMS | Our Jekyll Approach |
|---------|------------------------|------------------------|---------------------|
| **Content updates** | Web-based CMS editor | Specialized academic interfaces | YAML/BibTeX files with validation |
| **Preview capability** | Built-in preview | Built-in staging | Local Jekyll serve + future PR previews |
| **Publication management** | Manual or plugins | Academic publication databases | Jekyll-Scholar with BibTeX automation |
| **Deployment** | Plugin/auto-save | Scheduled publishing | GitHub Actions automation on push |
| **Maintenance burden** | High (updates, security) | Medium (vendor dependence) | Low (static site, dependency updates) |
| **Cost** | Free hosting (often limited) | Expensive licensing | Free (GitHub Pages) |
| **Collaboration** | User management + permissions | Role-based workflows | Git-based collaboration with PRs |
| **Performance** | Database-dependent | Variable (optimization needed) | Excellent (static files) |

**Key Differentiator:** Our approach prioritizes low maintenance burden and zero hosting costs while maintaining academic functionality through automation rather than manual CMS management.

## Sources

- [al-folio academic Jekyll theme](https://github.com/alshedivat/al-folio) - Academic website best practices
- [Jekyll Talk: Best practices for automatically generated sites](https://talk.jekyllrb.com/t/best-practices-for-automatically-generated-sites/7772) - Automation workflows
- [Jekyll front matter validation discussion](https://talk.jekyllrb.com/t/how-to-validate-a-front-matter-in-markdown-file/1388) - YAML validation approaches
- [athackst/htmlproofer-action](https://github.com/athackst/htmlproofer-action) - Quality gates implementation
- [Jekyll CI/CD pipeline examples](https://mcgarrah.org/jekyll-github-actions-cicd-pipeline/) - Deployment workflow patterns
- [GitHub Pages deploy preview discussion](https://github.com/orgs/community/discussions/7730) - PR preview limitations
- [Jekyll image optimization approaches](https://jec.fish/blog/automating-image-optimization-workflow) - Image workflow options
- [Academia Stack Exchange on low-maintenance websites](https://academia.stackexchange.com/questions/24396/academic-home-page-with-low-maintenance-burden) - Anti-pattern insights
- [Dependabot vs Renovate comparison](https://devopsboys.com/blog/renovate-vs-dependabot-dependency-updates-2026) - Dependency management options
- [Jekyll-Scholar documentation](https://github.com/inukshuk/jekyll-scholar) - Academic publication workflow

**Confidence Assessment:**
- Stack and architecture findings: **MEDIUM** - Well-documented Jekyll patterns, some academic-specific variations
- Feature categorization: **MEDIUM** - Based on clear use case analysis and competitor research
- Implementation complexity: **MEDIUM** - Familiar patterns with some academic-specific considerations
- Anti-features identification: **MEDIUM** - Clear reasoning from static site philosophy and academic use cases

---
*Feature research for: Jekyll academic lab website maintenance workflow*
*Researched: 2026-08-17*