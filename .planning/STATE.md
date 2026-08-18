---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 01
current_phase_name: local-dev-environment
status: executing
stopped_at: Completed 01-02-PLAN.md (gap closure G-1-3/G-1-4, all 7 tasks, self-check PASSED)
last_updated: "2026-08-18T05:10:02.471Z"
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 3
  completed_plans: 2
---

# 项目状态：Zhang Tao Lab 主页（全新版本）

**Updated:** 2026-08-17 after Phase 1 completion

## Project Reference

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

**Current Focus:** Phase 01 — local-dev-environment

## Current Position

**Phase:** 01 (local-dev-environment) — EXECUTING
**Plan:** 1 of 3
**Status:** Executing Phase 01
**Progress Bar:** ▰▰▰▱▱▱▱▱▱▱ 33%（1/3 阶段）

## Performance Metrics

**里程碑进度:** v1 - 环境跑通 + 自动部署上线
**阶段进度:** Phase 1 ✓ 完成（验证 passed + UAT 2/2 + 安全 0 开放威胁）；Phase 2 待规划
**需求覆盖:** 5/5 需求已映射到路线图（100%）；Phase 1 覆盖 ENV-01、ENV-02（2/2）
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 1 P01 | 19 min | 4 tasks | 465 files |
| Phase 01 P02 | 8min | 7 tasks | 12 files |

## Accumulated Context

### 关键决策点（已决策）

**Ruby/Jekyll 版本兼容性（2026-08-17 已决策）：**

- **生效级别：Step 0 → Step A（用户指令后置升级）** — Task 1 实测 Step 0（Jekyll 4.3.3）已达成绿色构建；随后用户指令（2026-08-17：「根据Github 的要求，建议使用新版本的软件和软件包」）要求采用较新版本，故后置应用 Step A：Gemfile `gem "jekyll"` 钉改为 `~> 4.4.0`，未动用 Step B（系统级 ruby@3.4）
- **最终组合：** Ruby 4.0.6（Homebrew，`/opt/homebrew/bin/ruby`）+ Bundler 4.0.16 + Jekyll **4.4.1**（Gemfile `~> 4.4.0`，resolver 取最新 4.4.x）
- **理由：** GitHub 版本支持要求优先；`bundle install` 与 `bundle exec jekyll build` 在 Jekyll 4.4.1 下均退出码 0，无需放宽 `sass-embedded ~> 1.77.0` 钉、无需钉 jekyll-scholar/jekyll-sitemap（resolver-latest 即兼容）
- **配套补偿（达成绿色构建所需）：** ① jekyll-scholar/jekyll-sitemap 移入 Gemfile `:jekyll_plugins` group（否则插件不加载）；② `scholar.style: citesty → apa`（磁盘无 citesty.csl，citeproc 解析失败）；③ `feed.xml` 对 `_data/news.yml` 展示性日期标签 "Latest" 回退 `site.time`（原文对不可解析日期直接过滤引发构建失败）
- **Gemfile.lock 已生成：** jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 / sass-embedded 1.77.8（钉保留，压制 Bootstrap 告警）
- **剩余风险：** Ruby 4.0.6 超出 Jekyll 4.4.1 官方支持范围（≤3.3.x），属"实测可用"而非"官方支持"；Phase 2 CI 需钉 Ruby 4.0.6 + Jekyll 4.4.1 复现本机组合（`.ruby-version` 已入库作为事实源）；已知无害告警：`assets/main.css` 与 `assets/main.scss` 输出目标冲突（静态快照 161,960 字节胜出，>1000 字节，不影响验收）；**Jekyll 4.4 行为变化：** livereload.js 改由专用 reload 服务器在 `127.0.0.1:35729` 提供（4.3.3 时经主服务 4000 端口提供），页面注入的 loader 已适配，实测 35729 端点返回 200、编辑探针 ≤10s 生效

### 已确认约束

- **部署方式：** 必须使用 GitHub Actions 自定义构建（jekyll-scholar 不在 Pages 插件白名单）
- **技术栈：** 保持 Jekyll + 现有插件体系（大版本已完成，不做框架重写）
- **域名：** 沿用 zhangtaolab.org，`baseurl` 保持为空
- **仓库：** 全新 git 历史（旧仓库抛弃）

### 已排除范围（v1 不做）

- DNS/HTTPS 配置操作（用户自行在 GitHub 后台配置）
- PR 预览部署（单人维护场景用不到）
- 视觉改版/重新设计（大版本界面已完成）
- 多语言/中文版站点（暂无 i18n 需求）

### 待确认项

- 本地内容已与 reference-snapshot 对齐（团队/新闻/首页/研究/软件/关于），publications 83 条未动（2026-08-18，1-02 gap closure G-1-3/G-1-4 实测：`&lt;div` 转义全站清零、/news/ 渲染 6 条、首页侧栏 3 条、serve 回环 6 页 200）
- **已知空态（2026-08-17，Phase 1 Task 2 实测）：** `papers/ref.bib` 无 @incollection 条目，`/talks/` 页两个 `{% bibliography --query @incollection[...] %}` 查询渲染为空列表（页面仍 200、标题"Invited Talks / Regular Talks"仍在）；真实 talks 数据属内容补全工作，不在本阶段。同类内容欠账：`_pages/teaching.md` 正文仍含 Feynman 模板演示教学条目（非文献链路，属页面内容补全）
- GitHub Actions 工作流具体实现细节
- YAML/BibTeX 验证工具选型

## Session Continuity

**Last session:** 2026-08-18T01:00:29.096Z
**Stopped at:** Completed 01-02-PLAN.md (gap closure G-1-3/G-1-4, all 7 tasks, self-check PASSED)
**Resume file:** None

**Last action:** Phase 1 完成闭环 — verifier 11/11 机器事实 passed，UAT 2/2（Playwright 真实浏览器自动化：livereload 免手动刷新双向闭环 + 5 页视觉目检），SECURITY.md 5/5 威胁 closed，PROJECT.md/STATE.md 转场更新
**Next action:** `/gsd-discuss-phase 2` 或 `/gsd-plan-phase 2`（Phase 2 自动部署）
**Blockers:** 无
**Notes:** 这是一个 brownfield 项目，现有代码已完成开发。v1 重点是让新版本在本地可测试、内容可日常更新、推送后自动部署上线。

---
*State initialized: 2026-08-17*

## Decisions

- [Phase 1]: Ruby/Jekyll 版本决策（Phase 1 Task 1）：生效级别 Step 0 → Step A（用户指令后置升级）— Ruby 4.0.6 + Jekyll 4.4.1 实测可构建；jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 锁入 Gemfile.lock，.ruby-version 入库作为 Phase 2 CI 事实源 — Step 0 先证绿色构建，后按用户指令（GitHub 版本支持要求）升级至 `~> 4.4.0`（resolver 取 4.4.1），bundle install 与 jekyll build 均退出码 0；剩余风险：Ruby 4.0.6 超出 Jekyll 官方支持范围，属实测可用；livereload.js 端点随 4.4 移至 127.0.0.1:35729
- [Phase ?]: Reference snapshot is content authority; its template defects ({title} placeholder, flat .html links, CDN fonts) deliberately not adopted (1-02)
- [Phase ?]: kramdown G-1-3 prevention pattern: column-0 flattened HTML + markdown="0" wrappers; assertable via grep -En '^ {4,}.*<' (1-02)
- [Phase ?]: Meta image tags existence-guarded via site.static_files instead of editing _config.yml (1-02)
