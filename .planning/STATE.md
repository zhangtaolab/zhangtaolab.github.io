# 项目状态：Zhang Tao Lab 主页（全新版本）

**Updated:** 2026-08-17 after roadmap creation

## Project Reference

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

**Current Focus:** 实现 v1 里程碑的三个核心能力：能本地预览 → 能推送上线 → 能放心改内容

## Current Position

**Phase:** Phase 1 - 本地开发环境（准备启动）
**Plan:** 尚未创建计划（需要 `/gsd-plan-phase 1`）
**Status:** Not started
**Progress Bar:** ▱▱▱▱▱▱▱▱▱▱ 0%

## Performance Metrics

**里程碑进度:** v1 - 环境跑通 + 自动部署上线
**阶段进度:** Phase 1 准备启动
**需求覆盖:** 5/5 需求已映射到路线图（100%）

## Accumulated Context

### 关键决策点（待执行时解决）

**Ruby/Jekyll 版本兼容性：**
- 本机环境：Ruby 4.0.6 + Bundler 4.0.16（arm64 macOS）
- Jekyll 4.3.3 官方支持 Ruby ≤3.1.x，Ruby 4.x 兼容性未验证
- Phase 1 需要测试并决策：
  1. 保持 Ruby 4.0.6 + 升级 Jekyll 到 4.4.1
  2. 或降级本地 Ruby 到 3.2.3
  3. 或其他兼容方案
- 这是关键路径风险，影响所有后续工作

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

**Last action:** 创建路线图（3 阶段，覆盖 5 个需求）
**Next action:** `/gsd-plan-phase 1` - 制定 Phase 1 详细计划
**Blockers:** 无
**Notes:** 这是一个 brownfield 项目，现有代码已完成开发。v1 重点是让新版本在本地可测试、内容可日常更新、推送后自动部署上线。

---
*State initialized: 2026-08-17*
