# Zhang Tao Lab 主页（全新版本）

## What This Is

Zhang Tao Lab（zhangtaolab.org）实验室主页的全新大版本，基于 Jekyll 4.3.3 静态站点生成。面向访客展示研究方向、论文出版物、团队成员、新闻动态等内容，由实验室成员日常维护。本项目的目标是让这个已完成开发的新版本在本地可测试、内容可日常更新、推送后自动部署上线。

## Core Value

维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

## Requirements

### Validated

（从现有代码推断 — brownfield）

- ✓ 完整站点页面已存在：首页、研究、团队、出版物、新闻、博客、教学、软件、联系、404（`_pages/*.md`）
- ✓ 学术出版物列表通过 jekyll-scholar + `papers/ref.bib` 自动生成
- ✓ 结构化数据管理：成员 `_data/people.yml`、PI `_data/pi.yml`、新闻 `_data/news.yml`、毕业生 `_data/alumni.yml`、经费 `_data/grants.yml`
- ✓ Bootstrap 5 响应式布局，深色模式与站内搜索（`assets/js/site.js`）
- ✓ RSS 订阅（`feed.xml`）、sitemap（jekyll-sitemap）、MathJax 公式渲染

### Active

- [ ] 本地开发环境跑通：本机完成 `bundle install` + `jekyll serve`，全部页面（含出版物列表）本地可预览，与线上构建一致
- [ ] 日常更新流程可用：新增论文（`papers/ref.bib`）、新闻（`_data/news.yml`）、成员（`_data/*.yml`）、页面内容（`_pages/*.md`）的操作步骤文档化，更新后本地预览验证
- [ ] GitHub Actions 自动构建部署：推送到新仓库后自动执行完整 Ruby 构建（含 jekyll-scholar）并发布到 GitHub Pages
- [ ] 新仓库就绪：全新 git 历史（旧仓库抛弃），`.gitignore` 与仓库配置完善，可对接 zhangtaolab.org 域名

### Out of Scope

- 视觉改版/重新设计 — 大版本的界面已完成，本次目标是跑通环境与流程，不是改设计
- 多语言/中文版站点 — 当前内容为英文，暂无 i18n 需求
- 后端功能（数据库、动态表单服务等）— 静态站点定位不变
- 旧版本仓库的数据迁移 — 旧版本全部抛弃，内容已在新版中

## Context

- **全新大版本**：旧 GitHub 仓库与部署将被抛弃；本仓库已用全新历史初始化（2026-08-17 `git init`，无远端）
- **本机环境**：Ruby 4.0.6 + Bundler 4.0.16（arm64 macOS），比 Jekyll 4.3.3 的官方支持范围新很多，预计有兼容性问题需要解决；仓库当前无 `Gemfile.lock`，`bundle install` 尚未在本机跑过
- **部署约束**：`jekyll-scholar` 不在 GitHub Pages 原生构建插件白名单内，必须用 GitHub Actions 自定义构建流程
- **站点配置**：`url: https://zhangtaolab.org`，`baseurl: ""`，自定义域名沿用
- 代码库地图见 `.planning/codebase/`（2026-08-17 生成，7 份文档：STACK / ARCHITECTURE / STRUCTURE / CONVENTIONS / TESTING / INTEGRATIONS / CONCERNS）

## Constraints

- **Tech stack**: 保持 Jekyll + 现有插件体系（jekyll-scholar、jekyll-sitemap）— 大版本已完成，不做框架重写
- **Compatibility**: 本机 Ruby 4.0.6 与 Jekyll 4.3.3 存在兼容风险 — 允许小版本升级 Jekyll 或钉住 Ruby 版本，以最小改动、可长期维护为准
- **Deployment**: GitHub Pages 必须走 GitHub Actions 完整构建 — jekyll-scholar 需要 Ruby 环境，Pages 原生构建不可用
- **Domain**: zhangtaolab.org 自定义域名沿用，`baseurl` 保持为空

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 部署采用 GitHub Actions 自定义构建（非 Pages 原生构建） | jekyll-scholar 不在 Pages 插件白名单 | — Pending |
| 旧版本仓库全部抛弃，新仓库全新历史 | 大版本重写，旧历史无保留价值 | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-08-17 after initialization*
