# Requirements: Zhang Tao Lab 主页（全新版本）

**Defined:** 2026-08-17
**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### 本地开发环境（Local Environment）

- [x] **ENV-01**: 维护者能在本机完成 `bundle install` 并以 `bundle exec jekyll serve` 启动本地预览，修改内容后浏览器自动刷新（live reload）
- [x] **ENV-02**: 本地预览中全部页面正常渲染，出版物列表非空（jekyll-scholar 文献正常显示，无静默失败）——含为达成此点所需的 Ruby/Jekyll 版本决策与调整

### 内容数据（Content Data）

- [ ] **CONTENT-01**: 维护者能在发布前校验 `_data/*.yml` 与 `papers/ref.bib` 的语法，错误被明确报出而非静默失败

### 部署（Deployment）

- [ ] **DEPLOY-01**: 维护者推送到 GitHub 后，Actions 自动完成完整构建（含 jekyll-scholar）并发布到 GitHub Pages，站点在 Pages URL 可访问
- [x] **DEPLOY-02**: CI 构建在 Linux runner 上成功（Gemfile.lock 跨平台条目就绪），本地与 CI 的 Ruby 版本一致（版本 pin 落地）

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### 本地开发环境

- **ENV-03**: 生产模式本地构建验证（`JEKYLL_ENV=production bundle exec jekyll build`），确保本地预览与线上一致

### 内容流程

- **CONT-01**: 内容更新指南文档（新增论文/新闻/成员/页面的分步操作）
- **CONT-02**: 常见故障排查文档（文献不显示、图片不加载等）

### 质量保障

- **QUAL-01**: CI 链接检查（html-proofer 或等价方案），拦截死链

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| zhangtaolab.org DNS/HTTPS 配置操作 | 用户选择自行在 GitHub 后台配置，v1 不代做 |
| PR 预览部署 | 进阶协作功能，单人维护场景用不到 |
| Dependabot/Renovate 自动依赖更新 | 站点规模小，手动更新足够 |
| 视觉改版/重新设计 | 大版本界面已完成，本次目标是环境与流程 |
| 多语言/中文版站点 | 暂无 i18n 需求，双倍维护成本 |
| 后端功能（数据库、动态表单等） | 静态站点定位不变 |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| ENV-01 | Phase 1 | Complete |
| ENV-02 | Phase 1 | Complete |
| CONTENT-01 | Phase 3 | Pending |
| DEPLOY-01 | Phase 2 | Pending |
| DEPLOY-02 | Phase 2 | Complete |

**Coverage:**

- v1 requirements: 5 total
- Mapped to phases: 5 ✓
- Unmapped: 0

---
*Requirements defined: 2026-08-17*
*Last updated: 2026-08-17 after roadmap creation*
