# 项目路线图：Zhang Tao Lab 主页（全新版本）

**Milestone:** v1 - 环境跑通 + 自动部署上线
**Created:** 2026-08-17
**Mode:** mvp

## Phases

- [ ] **Phase 1: 本地开发环境** - 维护者能在本地预览网站全部内容（含出版物列表）
- [ ] **Phase 2: 自动部署** - 维护者推送后网站自动上线，跨平台构建一致
- [ ] **Phase 3: 内容验证** - 维护者更新内容时语法错误被拦截，避免静默失败

## Phase Details

### Phase 1: 本地开发环境

**Goal:** 维护者能在本地预览网站全部内容（含出版物列表）
**Mode:** mvp
**Depends on:** Nothing（首阶段）
**Requirements:** ENV-01, ENV-02
**Success Criteria** (what must be TRUE):

  1. 维护者在本机执行 `bundle install` 后 `bundle exec jekyll serve` 启动成功，无依赖错误
  2. 本地预览显示所有页面（首页、研究、团队、出版物、新闻、博客等），布局正常
  3. 出版物列表页面显示文献条目（非空），jekyll-scholar 正常解析 `papers/ref.bib`
  4. 修改内容后浏览器自动刷新（live reload）生效

**Plans:** 1/1 plans executed

- [x] 01-PLAN.md

### Phase 2: 自动部署

**Goal:** 维护者推送后网站自动上线，跨平台构建一致
**Mode:** mvp
**Depends on:** Phase 1
**Requirements:** DEPLOY-01, DEPLOY-02
**Success Criteria** (what must be TRUE):

  1. 维护者推送代码到 GitHub 仓库后，Actions 工作流自动触发并完成构建
  2. 构建产物自动发布到 GitHub Pages，站点通过 Pages URL 可访问
  3. CI 构建在 Linux runner 上成功，Ruby 版本与本地一致（通过 Gemfile.lock 版本锁定）
  4. 站点在线上的显示效果与本地预览一致，出版物列表正常显示

**Plans:** TBD

### Phase 3: 内容验证

**Goal:** 维护者更新内容时语法错误被拦截，避免静默失败
**Mode:** mvp
**Depends on:** Phase 2
**Requirements:** CONTENT-01
**Success Criteria** (what must be TRUE):

  1. 维护者编辑 `_data/*.yml` 文件时，YAML 语法错误在构建前被明确报出
  2. 维护者编辑 `papers/ref.bib` 时，BibTeX 语法错误在构建前被明确报出
  3. 构建失败时错误信息清晰指出具体文件与问题位置（非静默失败）
  4. 维护者能在发布前通过验证步骤确保内容语法正确

**Plans:** TBD

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. 本地开发环境 | 1/1 | In Progress | - |
| 2. 自动部署 | 0/0 | Not started | - |
| 3. 内容验证 | 0/0 | Not started | - |

## Summary

**Total Phases:** 3
**Requirements Coverage:** 5/5 (100%)

This roadmap follows the natural dependency chain for a brownfield Jekyll site: local environment first (critical path for Ruby/Jekyll compatibility), then deployment pipeline, then content validation. Each phase delivers a complete, end-to-end user capability aligned with the core value: "维护者能低成本地更新网站内容，本地预览确认后推送即自动发布"。

---
*Roadmap created: 2026-08-17*
