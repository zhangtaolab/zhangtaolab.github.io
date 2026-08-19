# Phase 2: 自动部署 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-08-18
**Phase:** 2-自动部署
**Areas discussed:** 仓库接管与 Pages URL, 部署通道, 发布前验证强度, 评审遗留随车修复

**关键前置发现（讨论中实测核实）：** `zhangtaolab/zhangtaolab.github.io` 旧仓库已存在且正服务线上旧站（Cloudflare 代理 → GitHub Pages，cname=zhangtaolab.org，source=master，HTTPS 由 Cloudflare 终结）；账号对该仓 ADMIN。Phase 2 因此从"全新开站"变为"在线热切换"。

---

## 仓库接管与 Pages URL

**Q1: 如何接管线上仓库？**

| Option | Description | Selected |
|--------|-------------|----------|
| A. 原地接管（推荐） | 复用现有仓：推新历史 → Pages source 切 GitHub Actions → cname 继承，DNS 零改动，切换即上线 | ✓ |
| B. 旧仓改名新建 | rename 让出名字，新建同名仓重挂域名 — 有域名再验证/短时不可用风险 | |
| C. 新项目仓 | 如 zhangtaolab-jekyll — 默认 Pages URL 子路径与 baseurl "" 冲突，无净收益 | |

**User's choice:** A（附注：接管原有仓库，旧站已克隆到本地 /Users/forrest/GitHub/zhangtaolab.github.io，可完全覆盖）
**Notes:** 完全覆盖已授权；备份 = 用户本地克隆。

**Q2: 接管后的远端分支怎么布？**

| Option | Description | Selected |
|--------|-------------|----------|
| main 承接，删 master（推荐） | 新历史推 main 设为默认，删远端 master；可酌情加不可变 tag 双保险 | ✓ |
| main 承接，留 master | master 原样保留作双备份 — 多一个旧分支常驻 | |
| 沿用 master 名 | 本地 main 推到远端 master — 与本地分支名不一致易混淆 | |

**User's choice:** main 承接，删 master

---

## 部署通道

**Q1: 部署通道选哪条？**

| Option | Description | Selected |
|--------|-------------|----------|
| A. 官方工件机制（推荐） | configure-pages → build → upload-pages-artifact → deploy-pages；原子发布 + 权限最小化 | ✓ |
| B. gh-pages 分支 | build 后 force-push _site 到 gh-pages；产物可见但非原子、分支污染 | |

**User's choice:** A

**Q2: 工作流什么时候触发？**

| Option | Description | Selected |
|--------|-------------|----------|
| main push + 手动触发（推荐） | 推 main 自动部署；workflow_dispatch 手动入口（排障/验证模式） | ✓ |
| 仅 main push | 无手动入口，线上排障只能空 commit | |

**User's choice:** main push + 手动触发

---

## 发布前验证强度

**Q1: 发布前的验证强度？**

| Option | Description | Selected |
|--------|-------------|----------|
| A. 断言+验证模式（推荐） | deploy 前冒烟断言（sitemap 非空/出版物页非空/feed 合法）+ 手动只验证不部署模式 | ✓ |
| B. 断言+直发 | 同样有断言防线，推上即部署，无首次人工确认 | |
| C. 仅退出码 | jekyll build 退出码 0 即发布 — scholar 静默失败直接上线 | |

**User's choice:** A

---

## 评审遗留随车修复

**Q1: 哪些评审遗留随 Phase 2 修？**

| Option | Description | Selected |
|--------|-------------|----------|
| 推荐集：①②⑤ | vendor 卫生 + sitemap + RSS guid 随车；③dark_mode 与 ④双新闻页推迟 | |
| 全修：①②③④⑤ | 5 项全在 Phase 2 修 | ✓ |
| 最小集：仅① | 仅修部署链路直接相关的 vendor 卫生 | |

**User's choice:** 全修 ①②③④⑤（超出 Claude 推荐的 ①②⑤ 集合 — 用户选择把 ③④ 一并随车）

**Q2: ④ 双新闻页怎么收歗？（实测确认：news.md 与 allnews.md 内容 100% 相同，同一数据源全量循环；sidebar 指 /news/，feed.xml 指 /allnews.html）**

| Option | Description | Selected |
|--------|-------------|----------|
| 删 allnews，统一指 /news/（推荐） | 删 1 文件 + feed.xml 改 1 行链接 | ✓ |
| news 截断+allnews 归档 | 给两页造功能差异 — 小站过度设计 | |
| 两页都留只改链接 | 双内容 URL 并存（SEO 重复内容） | |

**User's choice:** 删 allnews，统一指 /news/

**Q3: ② sitemap 修法选哪个方向？（实测确认：10 页 sitemap: false，含 home/publications 等核心内容页）**

| Option | Description | Selected |
|--------|-------------|----------|
| 翻回 false，全量入 sitemap（推荐） | 内容页全部入 sitemap，404 与重复页除外；robots 广播保留 | ✓ |
| 摘 robots 的 Sitemap 行 | 最小改动但放弃 sitemap 价值 | |

**User's choice:** 翻回 false，全量入 sitemap

---

## Claude's Discretion

- workflow 具体结构（job 拆分、concurrency、bundler 缓存、runner 选型、断言脚本形式）
- 远端备份 tag 是否创建
- CNAME 文件是否入仓
- CI 设 JEKYLL_ENV=production
- 切 build_type 后确认 cname 验证状态不回退

## Deferred Ideas

None — 讨论全程未产生范围外想法。
