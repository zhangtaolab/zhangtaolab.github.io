---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 2
current_phase_name: 自动部署
status: executing
stopped_at: Completed 02-01-PLAN.md (D-10~D-14 评审遗留修复全绿，工作树 clean)
last_updated: "2026-08-19T01:28:41.200Z"
progress:
  total_phases: 2
  completed_phases: 1
  total_plans: 9
  completed_plans: 4
---

# 项目状态：Zhang Tao Lab 主页（全新版本）

**Updated:** 2026-08-18 after Phase 1 gap closure round 3

## Project Reference

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

**Current Focus:** Phase 2 — 自动部署

## Current Position

**Phase:** 2 (自动部署) — EXECUTING
**Plan:** 2 of 6
**Status:** Ready to execute
**Progress Bar:** ▰▰▰▱▱▱▱▱▱▱ 33%（1/3 阶段）

## Performance Metrics

**里程碑进度:** v1 - 环境跑通 + 自动部署上线
**阶段进度:** Phase 1 ✓ 完成（3 轮验证/UAT 闭环：验证 32/32 机器真值 passed + UAT 7/7 + 安全 0 开放威胁 + 代码评审 1C/6W/10I 已决策处置）；Phase 2 待规划
**需求覆盖:** 5/5 需求已映射到路线图（100%）；Phase 1 覆盖 ENV-01、ENV-02（2/2）
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 1 P01 | 19 min | 4 tasks | 465 files |
| Phase 01 P02 | 8min | 7 tasks | 12 files |
| Phase 02 P01 | 5min | 3 tasks | 13 files |

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

- 本地内容已与 reference-snapshot 对齐（团队/新闻/首页/研究/软件/关于），publications 83 条未动；2026-08-18 Round 3：research/software 版式经 03-PLAN 重排后与参考站视觉一致（UAT 测试 6 用户确认），全站 0 转义
- **已知空态（2026-08-17，Phase 1 Task 2 实测）：** `papers/ref.bib` 无 @incollection 条目，`/talks/` 页两个 `{% bibliography --query @incollection[...] %}` 查询渲染为空列表（页面仍 200、标题"Invited Talks / Regular Talks"仍在）；真实 talks 数据属内容补全工作，不在本阶段。同类内容欠账：`_pages/teaching.md` 正文仍含 Feynman 模板演示教学条目（非文献链路，属页面内容补全）
- GitHub Actions 工作流具体实现细节
- YAML/BibTeX 验证工具选型
- **Phase 2 前置关注（2026-08-18 第三轮代码评审，01-REVIEW.md）：** ① `_config.yml` exclude 缺 `vendor`（CI bundle install 会把 gem 树带进构建产物）；② sitemap.xml 仅 3 URL（多数页 `sitemap: false` 漂移，robots.txt 却在广播 sitemap）；③ `head.html` `dark_mode | default: true` 使 `dark_mode: false` 失效（Liquid default 不判 false）；④ /news/ 与 /allnews.html 双页并存且 sidebar/feed 链接各指一处；⑤ RSS 条目共享 link 且无 guid（WR-01，未修——本轮仅修了 title/description 转义）

## Session Continuity

**Last session:** 2026-08-19T01:28:41.194Z
**Stopped at:** Completed 02-01-PLAN.md (D-10~D-14 评审遗留修复全绿，工作树 clean)
**Resume file:** .planning/phases/02-auto-deploy/02-02-PLAN.md

**Last action:** Phase 1 Round 3 闭环 — 03-PLAN 执行（research/software 重排 + PDLLMs 改链）→ 验证 32/32 机器真值 passed → UAT 7/7（测试 6 视觉确认用户通过；测试 7 决策 (a) feed.xml strip_html 已修 e8df062）→ 阶段转场至 Phase 2
**Next action:** 在新目录 `/Users/forrest/GitHub/zhangtaolab.github.io` 重启会话后执行 `/gsd-plan-phase 2`（Phase 2 自动部署；02-CONTEXT.md 已完备，含渐进式接管序列与部署闸门设计）
**Blockers:** 无
**Relocation:** 项目已从 `/Users/forrest/Playground/zhangtaolab-jekyll` 整体搬迁至 `/Users/forrest/GitHub/zhangtaolab.github.io`（2026-08-18；旧站本地克隆让位改名为 `~/GitHub/zhangtaolab.github.io-legacy-backup`；远端接管尚未开始，仓库无 remote）
**Notes:** 这是一个 brownfield 项目，现有代码已完成开发。v1 重点是让新版本在本地可测试、内容可日常更新、推送后自动部署上线。

---
*State initialized: 2026-08-17*

## Decisions

- [Phase 1]: Ruby/Jekyll 版本决策（Phase 1 Task 1）：生效级别 Step 0 → Step A（用户指令后置升级）— Ruby 4.0.6 + Jekyll 4.4.1 实测可构建；jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 锁入 Gemfile.lock，.ruby-version 入库作为 Phase 2 CI 事实源 — Step 0 先证绿色构建，后按用户指令（GitHub 版本支持要求）升级至 `~> 4.4.0`（resolver 取 4.4.1），bundle install 与 jekyll build 均退出码 0；剩余风险：Ruby 4.0.6 超出 Jekyll 官方支持范围，属实测可用；livereload.js 端点随 4.4 移至 127.0.0.1:35729
- [Phase ?]: Reference snapshot is content authority; its template defects ({title} placeholder, flat .html links, CDN fonts) deliberately not adopted (1-02)
- [Phase ?]: kramdown G-1-3 prevention pattern: column-0 flattened HTML + markdown="0" wrappers; assertable via grep -En '^ {4,}.*<' (1-02)
- [Phase ?]: Meta image tags existence-guarded via site.static_files instead of editing _config.yml (1-02)
- [Phase ?]: Phase 2 P01: Liquid allow_false 参数系 5.4+ 专属，锁定栈（Jekyll 4.4.1→liquid-4.0.4）下 default 过滤器只收 1..2 参数直接 ArgumentError；dark_mode 改用显式 {% if site.dark_mode == false %} 判断（D-12 决策原文形态），双侧 override 构建机器证明 true/false 各自正确渲染
- [Phase ?]: Phase 2 P01: sitemap.xml 实测 3→11 URL（8 翻转 + research/software/team），Plan 02 ci-smoke 断言面用 ≥10 阈值防脆断；DEPLOY-01 系阶段级需求，P01 仅落地部署前评审修复，requirements.mark-complete 留给真正交付部署的 plan 执行
