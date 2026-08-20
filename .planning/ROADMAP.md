# 项目路线图：Zhang Tao Lab 主页（全新版本）

**Milestone:** v1 - 环境跑通 + 自动部署上线
**Created:** 2026-08-17
**Mode:** mvp

## Phases

- [x] **Phase 1: 本地开发环境** - 维护者能在本地预览网站全部内容（含出版物列表） (completed 2026-08-17)
- [x] **Phase 2: 自动部署** - 维护者推送后网站自动上线，跨平台构建一致 (completed 2026-08-20)
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

**Plans:** 3/3 plans complete

- [x] 02-PLAN.md

- [x] 01-PLAN.md

- [x] 03-PLAN.md — G-1-5 research/software 版式重排 + G-1-6 PDLLMs 死链修正

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

**Plans:** 6/6 plans complete

Plans:
**Wave 1**

- [x] 02-01-PLAN.md — D-10~D-14 评审遗留修复（vendor exclude / sitemap 全量化 / dark_mode / 双新闻页收敛 / RSS guid）

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 02-02-PLAN.md — CI 流水线工件：deploy.yml + ci-smoke.sh（D-05~D-09、D-16 双闸）
- [x] 02-03-PLAN.md — D-18 出版物逐条核对（旧站存档 + 83 vs ~91 逐条比对 + 阻断检查点）

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 02-04-PLAN.md — 原地接管 D-15①~④（push main → 默认分支 → build_type=workflow → 验证模式）

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 02-05-PLAN.md — 首次上线（人工闸门 → D-16 设闸 → 热切换 → 稳态自动部署证明）

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 02-06-PLAN.md — D-15⑥ 删 master + D-17 分支清理 + 终局验收扫描

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

**Plans:** 1/2 plans executed

Plans:
**Wave 1**

- [x] 03-01-PLAN.md — 验证脚本主体（tracer 一条命令两族文件 + YAML 结构 schema 层 D-01/D-02 + BibTeX 必填/键唯一层 D-03；本地入口 D-05/D-06/D-07）

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 03-02-PLAN.md — 双入口收口（D-08 提醒层 + deploy.yml 构建前 Validate content 步骤 D-04 + 红路径端到端证明 CONTENT-01-g）

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. 本地开发环境 | 3/3 | Complete    | 2026-08-18 |
| 2. 自动部署 | 6/6 | Complete    | 2026-08-20 |
| 3. 内容验证 | 1/2 | In Progress|  |

## Summary

**Total Phases:** 3
**Requirements Coverage:** 5/5 (100%)

This roadmap follows the natural dependency chain for a brownfield Jekyll site: local environment first (critical path for Ruby/Jekyll compatibility), then deployment pipeline, then content validation. Each phase delivers a complete, end-to-end user capability aligned with the core value: "维护者能低成本地更新网站内容，本地预览确认后推送即自动发布"。

---
*Roadmap created: 2026-08-17*
