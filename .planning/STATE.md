---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
current_phase: 1
current_phase_name: 本地开发环境
status: executing
last_updated: "2026-08-17T07:01:09.450Z"
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 1
  completed_plans: 0
---

# 项目状态：Zhang Tao Lab 主页（全新版本）

**Updated:** 2026-08-17 after Phase 1 planning

## Project Reference

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

**Current Focus:** Phase 1 — 本地开发环境

## Current Position

**Phase:** 1 (本地开发环境) — EXECUTING
**Plan:** 1 of 1
**Status:** Executing Phase 1
**Progress Bar:** ▰▱▱▱▱▱▱▱▱▱ 10%

## Performance Metrics

**里程碑进度:** v1 - 环境跑通 + 自动部署上线
**阶段进度:** Phase 1 已规划（1 计划 / 4 任务），待执行
**需求覆盖:** 5/5 需求已映射到路线图（100%）；Phase 1 覆盖 ENV-01、ENV-02（2/2）

## Accumulated Context

### 关键决策点（已决策）

**Ruby/Jekyll 版本兼容性（2026-08-17 已决策）：**

- **生效级别：Step 0（最小改动）** — 首选级别直接成功，未动用 Step A（Jekyll 升级）/ Step B（系统级 ruby@3.4）
- **最终组合：** Ruby 4.0.6（Homebrew，`/opt/homebrew/bin/ruby`）+ Bundler 4.0.16 + Jekyll **4.3.3**（Gemfile 钉保持不变）
- **理由：** `bundle install` 与 `bundle exec jekyll build` 在本机 Ruby 4.0.6 下均退出码 0，无需升级 Jekyll 或安装系统级 Ruby —— 满足"最小改动、可长期维护"约束
- **配套补偿（达成绿色构建所需）：** ① jekyll-scholar/jekyll-sitemap 移入 Gemfile `:jekyll_plugins` group（否则插件不加载）；② `scholar.style: citesty → apa`（磁盘无 citesty.csl，citeproc 解析失败）；③ `feed.xml` 对 `_data/news.yml` 展示性日期标签 "Latest" 回退 `site.time`（原文对不可解析日期直接过滤引发构建失败）
- **Gemfile.lock 已生成：** jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 / sass-embedded 1.77.8（钉保留，压制 Bootstrap 告警）
- **剩余风险：** Ruby 4.0.6 超出 Jekyll 4.3.3 官方支持范围（≤3.1.x），属"实测可用"而非"官方支持"；Phase 2 CI 需钉 Ruby 4.0.6 + Jekyll 4.3.3 复现本机组合（`.ruby-version` 已入库作为事实源）；已知无害告警：`assets/main.css` 与 `assets/main.scss` 输出目标冲突（静态快照 161,960 字节胜出，>1000 字节，不影响验收）

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

- Phase 1 计划细节（Ruby/Jekyll 版本测试路径）
- GitHub Actions 工作流具体实现细节
- YAML/BibTeX 验证工具选型

## Session Continuity

**Last action:** Phase 1 / Task 1 完成 — Step 0 绿色构建（Jekyll 4.3.3 + Ruby 4.0.6），版本决策已记录
**Next action:** Task 2 文献链路对齐 `papers/ref.bib`（scholar.source → /papers/、删演示 bib、探针验证）
**Blockers:** 无
**Notes:** 这是一个 brownfield 项目，现有代码已完成开发。v1 重点是让新版本在本地可测试、内容可日常更新、推送后自动部署上线。

---
*State initialized: 2026-08-17*
