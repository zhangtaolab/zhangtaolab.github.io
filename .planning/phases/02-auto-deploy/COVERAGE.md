# API Coverage — Phase 02 (auto-deploy)

No external API integration: this phase configures GitHub's own platform (Pages build_type, repo default branch, repository variables, branch layout) via one-time `gh` CLI administrative calls on the project's own repository, and consumes only official first-party GitHub Actions — the static site itself embeds no external API/SDK capability surface (site external surface unchanged from Phase 1: GA4 tags with empty ID, Google Scholar/CDN links).
