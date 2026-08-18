# Zhang Tao Lab 主页（全新版本）

## What This Is

Zhang Tao Lab（zhangtaolab.org）实验室主页的全新大版本，基于 Jekyll 4.4.1 静态站点生成（Ruby 4.0.6 实测可用）。面向访客展示研究方向、论文出版物、团队成员、新闻动态等内容，由实验室成员日常维护。本项目的目标是让这个已完成开发的新版本在本地可测试、内容可日常更新、推送后自动部署上线。

## Core Value

维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

## Requirements

### Validated

（从现有代码推断 — brownfield）

- ✓ 完整站点页面已存在：首页、研究、团队、出版物、新闻、博客、教学、软件、联系、404（`_pages/*.md`）
- ✓ 本地开发环境跑通：`bundle install` + `jekyll serve --livereload` 全链路绿色，16 URL + 出版物 + live reload 端到端实测 — Phase 1
- ✓ 全站版式与内容对齐参考站：5 页 + 3 数据文件对齐（G-1-3/G-1-4）→ research/software 重排为参考站结构（G-1-5，0 转义 + DOM 平铺 + 视觉确认）；全站 0 处 kramdown 转义 HTML — Phase 1（3 轮 gap closure，UAT 7/7）
- ✓ RSS 订阅可读：条目 title/description 剥离 HTML 标签后输出纯文本（feed.xml strip_html | xml_escape）— Phase 1（UAT 测试 7 决策 a）
- ✓ 新仓库就绪：全新 git 历史 + `.gitignore` + 460 文件站点源码入库（域名对接随 Phase 2 部署）— Phase 1
- ◐ 出版物数据流（Phase 1 澄清）：出版物页面为**手写 83 条 markdown 列表**（非 scholar 生成，替换将丢失 71 条，prohibition 保护）；jekyll-scholar 链路已对齐 `papers/ref.bib`（12 条，探针实证解析），目前唯一 `{% bibliography %}` 消费者是 talks 页的 @incollection 查询（bib 无此类条目，暂渲染为空）
- ✓ 结构化数据管理：成员 `_data/people.yml`、PI `_data/pi.yml`、新闻 `_data/news.yml`、毕业生 `_data/alumni.yml`、经费 `_data/grants.yml`
- ✓ Bootstrap 5 响应式布局，深色模式与站内搜索（`assets/js/site.js`）
- ✓ RSS 订阅（`feed.xml`）、sitemap（jekyll-sitemap）、MathJax 公式渲染

### Active

- [ ] 日常更新流程可用：新增论文（`papers/ref.bib`）、新闻（`_data/news.yml`）、成员（`_data/*.yml`）、页面内容（`_pages/*.md`）的操作步骤文档化，更新后本地预览验证
- [ ] GitHub Actions 自动构建部署：推送到新仓库后自动执行完整 Ruby 构建（含 jekyll-scholar）并发布到 GitHub Pages

### Out of Scope

- 视觉改版/重新设计 — 大版本的界面已完成，本次目标是跑通环境与流程，不是改设计
- 多语言/中文版站点 — 当前内容为英文，暂无 i18n 需求
- 后端功能（数据库、动态表单服务等）— 静态站点定位不变
- 旧版本仓库的数据迁移 — 旧版本全部抛弃，内容已在新版中

## Context

- **全新大版本**：旧 GitHub 仓库与部署将被抛弃；本仓库已用全新历史初始化（2026-08-17 `git init`，无远端）
- **本机环境**：Ruby 4.0.6 + Bundler 4.0.16（arm64 macOS）实测可跑 Jekyll 4.4.1 + jekyll-scholar 7.3.0；`Gemfile.lock` 已入库（含 Linux runner 平台条目与 CHECKSUMS），`.ruby-version` = 4.0.6 作为 Phase 2 CI 对齐事实源
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
| 部署采用 GitHub Actions 自定义构建（非 Pages 原生构建） | jekyll-scholar 不在 Pages 插件白名单 | — Pending（Phase 2） |
| 旧版本仓库全部抛弃，新仓库全新历史 | 大版本重写，旧历史无保留价值 | ✓ Phase 1（460 文件入库） |
| Jekyll 4.3.3 → `~> 4.4.0`（4.4.1） | 用户指令（2026-08-17）：按 GitHub 版本支持要求采用较新版本；Ruby 4.0.6 实测兼容 | ✓ Phase 1（livereload.js 随 4.4 迁移至 127.0.0.1:35729，功能等价已验） |
| jekyll-scholar/jekyll-sitemap 移入 Gemfile `:jekyll_plugins` 组 | Jekyll 插件加载的唯一正确位置（顶层声明不加载，`{% bibliography %}` 必挂） | ✓ Phase 1 |
| `scholar.source` 对齐 `/papers/`，删除 Feynman 演示 bib | 原配置指向模板演示数据；真实文献在 `papers/ref.bib` | ✓ Phase 1（探针 12/12 条实证） |
| publications.md 保持手写 83 条列表 | bib 仅 12 条，替换将静默丢失 71 条内容 | ✓ Phase 1（prohibition 固化） |
| research/software 重排采用参考站结构（`markdown="0"` 直通容器泛化到整网格/整卡片栈） | G-1-5：`文本</div>` 同行写法被 kramdown 转义 → 卡片嵌套 + 字面标签残留；CSS 不动，样式经页内 main 前缀覆盖块（参考站同款） | ✓ Phase 1（UAT 测试 6 视觉确认，页高与参考站一致/同量级） |
| PDLLMs 死链改指 `Plant_DNA_LLMs` 真实仓库（about ×2 + home ×1） | CR-01：原仓库 404；参考站继承缺陷，用户决策 (b) 修正、链接文字不变 | ✓ Phase 1（G-1-6） |
| RSS 条目 title/description 加 `strip_html` | CR-01（Round 3）：news headline 含 HTML，仅 `xml_escape` 会发布转义标记汤；用户决策 (a) 现在就修 | ✓ Phase 1（e8df062，feed 输出纯文本 + xmllint OK） |

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
*Last updated: 2026-08-18 after Phase 1（gap closure Round 3）*
