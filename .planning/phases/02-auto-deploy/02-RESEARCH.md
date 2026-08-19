# Phase 2: 自动部署 - Research

**Researched:** 2026-08-19
**Domain:** GitHub Actions CI/CD → GitHub Pages 工件部署（Jekyll 4.4.1 + jekyll-scholar 完整 Ruby 构建）；仓库原地接管与热切换上线
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### 仓库接管与上线方式
- **D-01:** 原地接管现有仓库 `zhangtaolab/zhangtaolab.github.io`（已存在、PUBLIC、正服务线上旧站：Cloudflare 代理 → GitHub Pages，cname=zhangtaolab.org，source=master 分支）。用户已明确授权**完全覆盖**（"旧版本全部抛弃，可以进行完全覆盖"）— **Reversibility:** one-way — 远端旧历史（master 分支）将被删除；旧内容留底于远端 `backup` 分支（D-02）+ 用户本地克隆 `/Users/forrest/GitHub/zhangtaolab.github.io`
- **D-02:** 旧站备份已就位（用户 2026-08-18 操作）：远端 `backup` 分支已推上 GitHub，与 `master` 同指 `b09c9b31`（旧站最后一次提交，已核实）；用户本地克隆（见 D-01）为第二副本。**双保险已成立，执行时无需再打 tag**
- **D-03:** 分支布局：本地 `main` 推为远端默认分支，**删除远端 `master`**（Pages 切到 Actions 构建后不依赖任何分支）
- **D-04:** 上线链路零 DNS 操作：DNS（Cloudflare→Pages）已在正确状态，cname=zhangtaolab.org 配置随仓库继承；需将 Pages `build_type` 从 master 分支模式切到 workflow（gh api `PUT /repos/zhangtaolab/zhangtaolab.github.io/pages`，账号对该仓 ADMIN 已核实）

### 部署通道
- **D-05:** 官方 Actions 工件机制：`actions/checkout` → Ruby setup → `bundle exec jekyll build` → `actions/upload-pages-artifact` → `actions/deploy-pages`；权限最小化（`contents: read` + `pages: write` + `id-token: write`）；不用 gh-pages 分支模式
- **D-06:** 触发：`push` 到 `main` 自动构建部署 + `workflow_dispatch` 手动触发（排障/重建/验证模式入口）

### CI 环境一致性（继承 Phase 1 锁定决策）
- **D-07:** Ruby 版本以仓库根 `.ruby-version`（4.0.6）为事实源，CI 用 `ruby/setup-ruby` 读取；`Gemfile.lock` 已含 `x86_64-linux-gnu` 等 Linux 平台条目，直接 `bundle install` 使用锁定版本（Jekyll 4.4.1 / jekyll-scholar 7.3.0）。**不**为 CI 单独降级 Ruby 版本 — DEPLOY-02 要求本地与 CI 一致

### 发布前验证
- **D-08:** deploy 前冒烟断言把门（防 Phase 1 式 scholar 静默失败直接上线）：① `_site/sitemap.xml` 存在且含 URL（D-11 生效后应接近全站页数）；② 出版物页产物含文献条目（非空正文，锚点由 planner 选取稳定值）；③ `_site/feed.xml` 通过 `xmllint --noout` 校验
- **D-09:** `workflow_dispatch` 支持**验证模式**（只 build + 断言，不 deploy）。首次热切换上线流程：先跑验证模式人工确认产物 → 再正式部署
- **D-18:** （2026-08-19 plan-phase 期间用户补充）首次上线前（D-16 设置 `DEPLOY_ENABLED` 放行之前）增加**出版物逐条核对**环节：将本地构建产物（`_site` 出版物页，源自 `papers/ref.bib`）与现线上旧站 `https://zhangtaolab.org/Publication` **一条一条逐一比对**（每条的标题/作者/年份及条目总数）。新站**缺失**任何旧站条目 → 阻断上线并回报；新站**多出**条目（迁移后新增论文）→ 列出供用户确认后放行。核对必须发生在热切换前（旧站被替换后参照物消失），归入 D-09 验证模式产物的人工确认闸门；核对通过是 D-16 首次设闸放行的前置条件

### 评审遗留随车修复（用户决策：5 项全修）
- **D-10:** ① `_config.yml` `exclude` 增 `vendor` + `.gitignore` 增 `vendor/`（防 CI 上 gem 树进 `_site` 发布）
- **D-11:** ② sitemap 全量化：翻掉内容页的 `sitemap: false`（现 10 页在黑名单，含 `home.md`/`publications.md`），仅 404 与重复页除外；`robots.txt` 的 Sitemap 广播行保留
- **D-12:** ③ `_includes/head.html` `dark_mode | default: true` 改为显式判断 false（Liquid `default` 过滤器不判 false，`dark_mode: false` 会失效）
- **D-13:** ④ 删除 `_pages/allnews.md`（与 `news.md` 内容 100% 相同：同一 `site.data.news` 全量循环），`feed.xml` channel link 从 `/allnews.html` 改指 `/news/`（sidebar 已指 `/news/`，无需动）
- **D-14:** ⑤ `feed.xml` 条目补唯一 `<guid>` 并修正条目级 `<link>`（WR-01：news 条目共享 link 且无 guid，聚合器无法区分条目）

### 接管操作序列（2026-08-18 与用户对齐，planner 必须遵循）
- **D-15:** 渐进式接管，**全程无 force push**：① `git push -u origin main`（新增分支非覆盖，master 原封不动）→ ② `gh api PATCH .../repos -f default_branch=main` → ③ `gh api PUT .../pages -f build_type=workflow`（旧站快照继续服务，无停机窗口）→ ④ 验证确认 → ⑤ 正式部署 → ⑥ **最后** `git push origin --delete master`（唯一破坏性动作，且时点在新站已验证上线之后）
- **D-16:** 部署闸门机制：deploy job 条件 `vars.DEPLOY_ENABLED == 'true' || inputs.deploy == true` —— `DEPLOY_ENABLED` 仓库变量同时充当首次上线闸门（D-09 的人工确认环节）与常驻 kill-switch（删变量即停部署）；首次正式切换 = 设变量后 `gh workflow run deploy.yml -f deploy=true`；此后 push main 自动部署
- **D-17:** 顺手清理旧仓 3 个 dependabot 分支（addressable-2.8.1 / kramdown-2.3.1 / rexml-3.3.3）；98 个旧 PR ref 由 GitHub 托管不可删也无需删

### Claude's Discretion
- workflow 具体结构：job 拆分、`concurrency` 取消旧跑、bundler 缓存、runner 选型（ubuntu-latest）、断言脚本实现形式（shell/ruby）
- ~~远端备份 tag 是否创建（D-02）~~ 已不需要 — 远端 `backup` 分支已就位
- CNAME 文件是否入仓（Pages 设置里 cname 已存在且随仓库继承，工件模式通常无需 CNAME 文件；执行时若发现需要再加）
- CI 构建设 `JEKYLL_ENV=production`（analytics 仅生产输出；当前 `google_id` 为空，无实际差异但保持环境正确性）
- 切换 build_type 后确认 cname 域名验证状态不回退（HTTPS 由 Cloudflare 终结，`https_enforced=false` 现状维持）

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope（5 项评审遗留经用户决策全部随车修复，无推迟项、无范围外想法）
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEPLOY-01 | 维护者推送到 GitHub 后，Actions 自动完成完整构建（含 jekyll-scholar）并发布到 GitHub Pages，站点在 Pages URL 可访问 | 官方 starter workflow 全文已取证（CITED）；live Pages 配置已读取（build_type=legacy, source=master, cname=zhangtaolab.org）；接管序列每步的 gh api/git 命令已验证；D-08 冒烟断言三件套已有实证基线（sitemap 3 URL / feed xmllint 通过 / 出版物锚点存在） |
| DEPLOY-02 | CI 构建在 Linux runner 上成功（Gemfile.lock 跨平台条目就绪），本地与 CI 的 Ruby 版本一致（版本 pin 落地） | Gemfile.lock 22 平台条目含 `x86_64-linux-gnu`/`aarch64-linux-gnu` 已核实（VERIFIED）；`.ruby-version`=4.0.6 + setup-ruby 自动读取已核实（README 原文）；Ruby 4.0.6 在 setup-ruby MRI 支持范围（"all versions from 2.3.0 until 4.0.6"）已核实 |
</phase_requirements>

## Summary

本阶段是在一个**已在线服务的仓库上做原地热切换**：远端 `zhangtaolab/zhangtaolab.github.io` 当前以 legacy 分支模式（source=master）服务旧站，本阶段用本地 `main`（全新历史、Jekyll 4.4.1 全量内容）接管，并把 Pages 从分支模式切到 GitHub Actions 工件模式。研究期间通过 `gh api` 读取了远端 live 状态，全部接管前提已被机器证实：`build_type: "legacy"`、`source: {branch: master}`、`cname: zhangtaolab.org`、`https_enforced: false`、默认分支 `master`、远端分支恰为 `backup` + 3 个 dependabot + `master`（与 D-02/D-17 完全吻合）。本地仓库当前**无 remote**（`git remote -v` 为空），D-15 步骤①的 `git push -u origin main` 是全新分支推送，不覆盖任何东西。

技术通道完全走官方路径：官方 starter workflow（actions/starter-workflows `pages/jekyll.yml`）已逐行取证，恰好覆盖 D-05/D-06/D-07 的全部要求（push+dispatch 触发、最小权限、bundler-cache、JEKYLL_ENV=production、upload-pages-artifact 默认取 `_site`、deploy-pages@v5 + environment）。四项关键机制均经权威源验证：① `ruby/setup-ruby` 省略 `ruby-version` 时自动读 `.ruby-version`，MRI 支持到 4.0.6（含 ubuntu 全系 runner）；② Jekyll 4.4.1 源码级证实 `DEFAULT_EXCLUDES` 是**追加**到用户 `exclude` 之上（含 `vendor/bundle/`），且本地实验证实 gems 装进 `vendor/bundle` 后 `_site` 不含 vendor —— D-10 的"CI 会把 gem 树带进产物"前提在 4.4.1 下**不成立**，但修复本身零成本、保留为防御层；③ Liquid `default` 过滤器对 `false` 也回退（D-12 bug 实锤），官方修复参数 `allow_false: true` 已取证；④ jekyll-sitemap 排除规则（sitemap:false、仅 .htm/.html/.xhtml/.pdf/.xml 静态文件、repo 自有 robots.txt 时不注入）已从源码+本地构建双证实，D-11 后 sitemap 应从 3 URL 升到 11 URL。

两个研究发现显著影响规划：**(A) D-18 的比对语料需要纠偏** —— 新站出版物页是**手写 markdown 83 条**（`_pages/publications.md`），并非"源自 `papers/ref.bib`"（ref.bib 仅 12 条、只喂给 talks.md 的两个空查询）；旧站 `/Publication` 现读为 91 条（fetch 摘要计数，逐年标题两头 19 个年份完全一致，2026 前 3 条逐字吻合）。83 vs 91 的 8 条差额必须由 executor 在热切换前逐条对账。**(B) D-15 的步骤顺序不仅是安全设计，还是功能硬约束** —— `workflow_dispatch` 只能在**默认分支**上的 workflow 触发，所以必须先 PATCH default_branch=main 再 dispatch 验证模式；deploy-pages 在 build_type 未切 workflow 前会直接失败，所以步骤③必须在步骤⑤前。

**Primary recommendation:** 单 workflow 双 job（build+assert → gate → deploy）复刻官方 starter 结构，以 `inputs.deploy`（boolean）+ `vars.DEPLOY_ENABLED` 双闸实现 D-09 验证模式与 D-16 kill-switch；D-15 六步序列原样落成任务序列（顺序不可重排）；D-18 比对以"手写 83 条 markdown vs 旧站 91 条"为语料并在删除 master 之前完成。

## Project Constraints (from CLAUDE.md)

- **Tech stack**: 保持 Jekyll + 现有插件体系（jekyll-scholar、jekyll-sitemap）— 大版本已完成，不做框架重写（研究全部遵循：不引入任何新框架/语言）
- **Deployment**: GitHub Pages 必须走 GitHub Actions 完整构建 — jekyll-scholar 需要 Ruby 环境，Pages 原生构建不可用（与 D-05 一致）
- **Domain**: zhangtaolab.org 自定义域名沿用，`baseurl` 保持为空（`_config.yml:28-29` 已是 `baseurl: ""` / `url: "https://zhangtaolab.org"` [VERIFIED: _config.yml:28-29]）
- **注意 CLAUDE.md 陈旧项**: CLAUDE.md Technology Stack 段写 "Jekyll 4.3.3"，实际锁定为 **Jekyll 4.4.1**（Gemfile `~> 4.4.0` [VERIFIED: Gemfile:3] + Gemfile.lock `jekyll (4.4.1)` [VERIFIED: Gemfile.lock]）。规划以 STATE.md/Gemfile.lock 为准
- **GSD Workflow Enforcement**: 代码改动须经 GSD 入口（本阶段由 `/gsd-execute-phase` 承载，天然满足）
- 无 lint/测试框架约定、无强制格式化工具 —— workflow 中的冒烟断言即本阶段的"测试"

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| 触发部署（push/dispatch） | 维护者本地 → GitHub Repo | — | 单人维护，push main 即发布意图（D-06） |
| Ruby 环境置备 + 依赖安装 | Actions runner（ruby/setup-ruby） | — | `.ruby-version` 为唯一事实源（D-07），runner 上装 Ruby 4.0.6 + 锁定 gems |
| Jekyll 完整构建（含 jekyll-scholar） | Actions runner | 维护者本地（同一命令复现） | `bundle exec jekyll build` + JEKYLL_ENV=production；本地与 CI 同命令同版本 |
| 冒烟断言（sitemap/锚点/feed） | Actions runner build job | 本地（同一脚本可跑） | 断言在 deploy 之前把门（D-08），必须可本地复现 |
| 工件上传与 Pages 发布 | GitHub Pages 服务（官方 actions） | — | upload-pages-artifact/deploy-pages 处理 tar、工件命名、deployment API、OIDC |
| 部署闸门 / kill-switch | GitHub 仓库变量（vars.DEPLOY_ENABLED） | workflow_dispatch inputs.deploy | D-16：变量即常驻开关，dispatch 一次性放行 |
| 域名与 DNS | Cloudflare + Pages cname（用户已配好） | — | 零 DNS 操作（D-04）；Cloudflare 缓存 ~10min 属外部观测延迟 |
| 旧站参照与回滚 | 远端 `backup` 分支 + 用户本地克隆 | 线上旧站快照（切换前仍在服务） | D-02 双保险；D-18 比对必须在切换前做完 |

## Standard Stack

### Core（GitHub Actions 官方 actions，非 registry 包）

| Action | 版本（取证） | Purpose | Why Standard |
|--------|-------------|---------|--------------|
| `actions/checkout` | starter 钉 `@v4`；最新 release `v7.0.1` [VERIFIED: gh api releases/latest, 2026-07-20] | 检出 main | 官方 starter 组合的一部分 |
| `ruby/setup-ruby` | 官方推荐 `@v1`（滚动 major）；starter 用全 SHA 钉 v1.207.0；最新 `v1.321.0` [VERIFIED: gh api] | 装 Ruby 4.0.6 + bundler-cache | 读 `.ruby-version` + gem 缓存的事实标准（D-07） |
| `actions/configure-pages` | starter 钉 `@v5`；最新 `v6.0.0` [VERIFIED: gh api] | 输出 base_path 等 Pages 配置 | 官方链路必需环节 |
| `actions/upload-pages-artifact` | starter 钉 `@v3`；最新 `v5.0.0` [VERIFIED: gh api] | 打包 `_site` 为 `github-pages` 工件 | 工件模式部署的官方打包器 |
| `actions/deploy-pages` | `@v5`（starter 与最新一致）[VERIFIED: gh api] | 通过 OIDC 发布工件到 Pages | 官方发布器，替代一切 gh-pages 分支推送 |

**版本策略建议（Claude's Discretion 行使）:** 按官方 starter 的组合钉 major tag（`checkout@v4` / `setup-ruby@v1` / `configure-pages@v5` / `upload-pages-artifact@v3` / `deploy-pages@v5`）—— 这是 GitHub 自己维护并持续测试的组合，且 `deploy-pages@v5` 恰为当前最新。追求更强供应链安全可升级到全 SHA 钉（starter 对 setup-ruby 即如此，附 release 链接注释），但 major-tag 组合已是官方模板默认姿势。若执行者想用各 action 最新 major（v7/v6/v5/v5），`deploy-pages@v5` 与 `upload-pages-artifact@v3→v5` 的组合变更需要一次验证跑，收益有限。

### Supporting（本机/命令行工具）

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| `gh` CLI | 已登录 `forrestzhang`，对目标仓 ADMIN [VERIFIED: gh auth status 本会话] | 接管序列全部 API 操作（PATCH default_branch、PUT pages build_type、variable set、workflow run） | D-15/D-16/D-17 全部步骤 |
| `xmllint` | macOS 本机有（libxml 21309）[VERIFIED: 本会话]；**ubuntu runner 默认无** [CITED: github.com/actions/runner-images/issues/423] | D-08③ feed.xml 校验 | runner 上需 `sudo apt-get install -y libxml2-utils`，或改用 Ruby REXML（零依赖，见 Don't Hand-Roll） |
| Ruby + Bundler | 本机 4.0.6 / Bundler 4.0.16；Gemfile.lock `BUNDLED WITH 4.0.16` [VERIFIED: 本会话] | 本地复现 CI 同命令 | 验证模式产物的本地对照 |

**Installation:** 无 registry 包安装（本阶段零 npm/PyPI/crates 依赖）。workflow 文件与可选 `scripts/ci-smoke.sh` 是仅有的新增文件。

**Version verification:** 本阶段核心"依赖"是 GitHub Actions 官方 actions，其版本经 `gh api repos/<action>/releases/latest` 逐个核实（2026-08-19）：checkout v7.0.1、configure-pages v6.0.0、upload-pages-artifact v5.0.0、deploy-pages v5.0.0、setup-ruby v1.321.0。

## Package Legitimacy Audit

本阶段**不安装任何 registry 包**（npm/PyPI/crates 均无），故 Package Legitimacy Gate 无 registry 对象可查。

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| actions/checkout | —（GitHub Actions，非 registry） | ~10 yrs | — | github.com/actions/checkout | OK | Approved |
| ruby/setup-ruby | —（同上） | ~7 yrs | — | github.com/ruby/setup-ruby | OK | Approved |
| actions/configure-pages | —（同上） | ~6 yrs | — | github.com/actions/configure-pages | OK | Approved |
| actions/upload-pages-artifact | —（同上） | ~5 yrs | — | github.com/actions/upload-pages-artifact | OK | Approved |
| actions/deploy-pages | —（同上） | ~5 yrs | — | github.com/actions/deploy-pages | OK | Approved |

以上均属 GitHub 官方 `actions/*` org 或 Ruby 官方 org，发布 tag 本会话经 GitHub API 核实存在 [VERIFIED: gh api releases/latest]。无一来自个人/第三方仓库 —— 供应链面为官方闭集。

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none
*未验证 registry 包：无（本阶段无任何 [ASSUMED] 包引用）。*

## Architecture Patterns

### System Architecture Diagram

```
维护者本地（macOS, Ruby 4.0.6）
   │  git push origin main（D-15①，新分支，无覆盖）
   ▼
GitHub Repo zhangtaolab/zhangtaolab.github.io
   │  默认分支 master → PATCH → main（D-15②）
   │  Pages build_type legacy(master) → PUT → workflow（D-15③）
   │  〔旧站快照继续服务，无停机窗口〕
   ▼
on: push(main) / workflow_dispatch(deploy: boolean)
   ▼
┌─────────────── build job（ubuntu-latest）───────────────┐
│ checkout@v4 → setup-ruby@v1（读 .ruby-version 4.0.6，   │
│   bundler-cache: true → gems 落 vendor/bundle，已默认排除）│
│ configure-pages@v5                                      │
│ JEKYLL_ENV=production bundle exec jekyll build          │
│ 冒烟断言：sitemap ≥10 URL ／ 出版物锚点 ／ feed.xml 校验  │
│ （断言失败 → job 红 → 永远到不了 deploy）                 │
└──────────────────────┬──────────────────────────────────┘
                       ▼
        gate: vars.DEPLOY_ENABLED == 'true' || inputs.deploy == true
           │未放行（验证模式，D-09/D-18 闸门）→ 到此为止，产物留在 run artifact 供人工核
           │放行
           ▼
┌─────────────── deploy job ──────────────────────────────┐
│ upload-pages-artifact@v3（默认打包 ./_site）             │
│ deploy-pages@v5（OIDC id-token，environment github-pages）│
└──────────────────────┬──────────────────────────────────┘
                       ▼
GitHub Pages（cname=zhangtaolab.org 继承，D-04）
   → Cloudflare 代理（max-age=600，~10 分钟全球生效）
   → 访客 https://zhangtaolab.org（新站替换旧站）
                       ▼
   （新站验证上线之后，最后）git push origin --delete master
   + 删 3 个 dependabot 分支（D-15⑥/D-17）
```

决策点：① deploy gate（D-16）；② 断言三连（D-08）；③ D-18 人工核对闸门在"验证模式跑完 → 设 DEPLOY_ENABLED"之间。

### Recommended Project Structure

```
.github/
└── workflows/
    └── deploy.yml        # 全新创建（现无 .github 目录 [VERIFIED: 本会话 ls]）：D-05/06/08/09/16
scripts/
└── ci-smoke.sh          # 可选但推荐：冒烟断言脚本，本地与 CI 同一份（D-08 三断言）
```

（其余 D-10~D-14 均为既有文件的原地修改，不新增目录。）

### Pattern 1: 官方 Pages 工件工作流 + 双闸验证模式

**What:** 单 workflow、build 与 deploy 两 job；deploy job 用 `if` 闸门控制。
**When to use:** 本阶段唯一通道（D-05/D-09/D-16）。

官方 starter 全文（取证原文，逐行）[CITED: raw.githubusercontent.com/actions/starter-workflows/main/pages/jekyll.yml]：

```yaml
name: Deploy Jekyll site to Pages

on:
  push:
    branches: [$default-branch]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Ruby
        uses: ruby/setup-ruby@4a9ddd6f338a97768b8006bf671dfbad383215f4
        with:
          ruby-version: '3.1' # Not needed with a .ruby-version file
          bundler-cache: true # runs 'bundle install' and caches installed gems automatically
          cache-version: 0
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5
      - name: Build with Jekyll
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub
        id: deployment
        uses: actions/deploy-pages@v5
```

本阶段适配点（全部有出处）：
- `on.push.branches: [main]`（D-06；仓库默认分支将切为 main）
- 删掉 `ruby-version: '3.1'` 行 —— README 原文："If the `ruby-version` input is not specified, `.ruby-version` is tried first" [CITED: github.com/ruby/setup-ruby README]（D-07）
- `concurrency.cancel-in-progress: false` 维持官方值 —— 官方注释明确说"Do NOT cancel in-progress runs as we want to allow these production deployments to complete"。CONTEXT 把"取消旧跑"列为 discretion：**建议不取消进行中的部署**（中断 deploy job 可能留下半完成 deployment），并发压制的收益已由 group "pages" 兑现
- upload-pages-artifact 默认路径即 `./_site`（starter 注释原文："Automatically uploads an artifact from the './_site' directory by default"）—— 无需 `with: path`
- `--baseurl "${{ steps.pages.outputs.base_path }}"`：本站 baseurl 为空、自定义域，输出为空串，命令等价于无参 —— 保留无害、与官方一致

双闸实现（D-09 + D-16 一体）：

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      deploy:
        description: 'Deploy after build+assert (bypasses DEPLOY_ENABLED for first launch)'
        type: boolean
        default: false

jobs:
  build:
    # …（断言步骤加在 build 末尾、upload 之前）
  deploy:
    if: vars.DEPLOY_ENABLED == 'true' || inputs.deploy == true
    # needs: build … environment: github-pages … deploy-pages@v5
```

行为矩阵：

| 触发 | inputs.deploy | vars.DEPLOY_ENABLED | 结果 |
|------|---------------|---------------------|------|
| push main | （空） | 未设 | 只 build+断言（= 回退为验证模式） |
| push main | （空） | 'true' | 完整部署（常态） |
| dispatch | false | 任意 | 验证模式（D-09；D-18 人工核对在此之后） |
| dispatch | true | 任意 | 强制部署（首次上线：D-16 `gh workflow run deploy.yml -f deploy=true`） |

首次上线次序硬约束（研究结论，planner 必须遵守）：`workflow_dispatch` 只能触发**默认分支上**存在的 workflow —— 所以 D-15 的 ①push main → ②PATCH default_branch → ③PUT build_type 必须先于 ④dispatch 验证模式；而 `deploy-pages` 在 `build_type != workflow` 时会失败，③ 必须先于 ⑤正式部署。D-15 的原始顺序恰好同时满足这两条，**不可重排** [ASSUMED — dispatch-仅默认分支为 Actions 通识，未在本次官方文档直接取证；但 D-15 用户已锁定该顺序，风险只在于"为什么"，不在于"做什么"]。

### Pattern 2: 冒烟断言（D-08 三件套 + vendor tripwire）

**What:** build 末尾、upload 之前的 3+1 断言；同一脚本本地可跑。
**When to use:** 每次 CI 构建；验证模式即"只跑这些"。

```bash
#!/usr/bin/env bash
# scripts/ci-smoke.sh —— D-08 冒烟断言（本地: scripts/ci-smoke.sh _site；CI: 同）
set -euo pipefail
SITE="${1:-_site}"

# ① sitemap.xml 存在且含足够 URL（D-11 后应为 11：home/about/research/publications/
#    software/team/news/contact/blogs/teaching/talks；用 -ge 10 防脆断）
COUNT=$(grep -c "<loc>" "$SITE/sitemap.xml")
[ "$COUNT" -ge 10 ] || { echo "FAIL: sitemap only $COUNT URLs"; exit 1; }

# ② 出版物页含文献条目锚点（锚点建议见 Pattern 4；DOI 子串最稳）
grep -q "s41467-026-73769-8" "$SITE/publications/index.html" \
  || { echo "FAIL: publications anchor missing"; exit 1; }

# ③ feed.xml 为合法 XML（xmllint 在 runner 上需先 apt 装 libxml2-utils，
#    或整段替换为 Ruby REXML 版本，见 Don't Hand-Roll）
xmllint --noout "$SITE/feed.xml" || { echo "FAIL: feed.xml invalid"; exit 1; }

# + vendor tripwire（D-10 的断言面：即便排除机制失效也拦得住发布）
[ ! -d "$SITE/vendor" ] || { echo "FAIL: vendor leaked into _site"; exit 1; }

echo "PASS: sitemap=$COUNT, anchor ok, feed valid, no vendor"
```

基线（本会话实测，改动前）[VERIFIED: 本地 `JEKYLL_ENV=production bundle exec jekyll build` 本会话]：`_site/sitemap.xml` = **3** URL（research/software/team）；`xmllint --noout _site/feed.xml` 通过；`_site` 6.0 MB；`grep s41467-026-73769-8 _site/publications/index.html` 命中。

### Pattern 3: D-10~D-14 修复的精确现状与改法

**D-10（exclude + .gitignore）** —— 现状 [VERIFIED: _config.yml:93-103]：

```yaml
exclude:
  - Gemfile
  - Gemfile.lock
  - update_bootstrap.sh
  - switch_theme.sh
  - tags
  - Rakefile
  - node_modules
  - package.json
  - package-lock.json
  - docs
```

改法：列表加一行 `- vendor`。`.gitignore` 现有行 `vendor/bundle`（第 8 行）[VERIFIED: .gitignore:8] 改/增为 `vendor/`。
**研究修正（重要）**：评审前提"CI bundle install 会把 gem 树带进 `_site`"在 Jekyll 4.4.1 下**不成立** —— v4.4.1 源码 [VERIFIED: github.com/jekyll/jekyll@v4.4.1 lib/jekyll/configuration.rb:255-268，经 gh api 原文取证]：

```ruby
DEFAULT_EXCLUDES = %w(
  .sass-cache .jekyll-cache
  gemfiles Gemfile Gemfile.lock
  node_modules
  vendor/bundle/ vendor/cache/ vendor/gems/ vendor/ruby/
).freeze

def add_default_excludes
  config = clone
  return config if config["exclude"].nil?

  config["exclude"].concat(DEFAULT_EXCLUDES).uniq!
  config
end
```

用户自定义 `exclude` 是被 `concat(DEFAULT_EXCLUDES).uniq!` **追加**而非替换；`setup-ruby` bundler-cache 恰把 gems 装到 `$PWD/vendor/bundle` [CITED: setup-ruby README]，落在默认排除内。本会话实验复现：`bundle config set --local path vendor/bundle && bundle install` 后构建，`_site/vendor` 不存在、`_site` 仍 6.0M [VERIFIED: 本地实验，已清理现场]。**结论：D-10 照做（零成本防御层，且 `.gitignore` 的 `vendor/` 对本地同类操作有实义），但规划中不得把它表述为"不修就会泄漏"的阻断项**；真正的保险是 Pattern 2 的 vendor tripwire 断言。

**D-11（sitemap 全量化）** —— 黑名单现状恰 10 页 [VERIFIED: grep 本会话]：`news.md, contact.md, blogs.md, allnews.md, 404.md, teaching.md, talks.md, home.md, about.md, publications.md`（全在 `_pages/`，各文件第 4 行 `sitemap: false`）。改法：除 `404.md`（保留）与 `allnews.md`（D-13 删除）外，其余 **8 页**删掉 `sitemap: false` 行：home/about/publications/news/contact/blogs/teaching/talks。预期 sitemap = 11 URL。机制依据：jekyll-sitemap 仅收 HTML 页（排除带 `sitemap: false` 的）+ 扩展名为 `.htm .html .xhtml .pdf .xml` 的静态文件 [VERIFIED: github.com/jekyll/jekyll-sitemap master lib/jekyll/jekyll-sitemap.rb:19-25 gh api 原文：`INCLUDED_EXTENSIONS = %w(.htm .html .xhtml .pdf .xml)`]；本仓无 .pdf/.xhtml 静态文件、feed.xml 是带 front matter 的 Liquid 页（实测不在 sitemap），故 11 为准 [VERIFIED: 本地构建基线 + 源码推理]。`robots.txt` 保留不动（见下方 jekyll-sitemap 注记）。

**D-12（dark_mode）** —— 现状 [VERIFIED: _includes/head.html:44]：

```
var darkMode = {{ site.dark_mode | default: true }};
```

依据 [CITED: shopify.dev/docs/api/liquid/filters/default]：`default` 的回退条件是 `empty`、`false`、`nil` 三者 —— 即 `dark_mode: false` 会渲染成 `true`，站点主人永远关不掉暗色开关。官方修复参数 `allow_false`：

```liquid
var darkMode = {{ site.dark_mode | default: true, allow_false: true }};
```

（`_config.yml:26` 现为 `dark_mode: true` [VERIFIED: _config.yml:26]，故当前行为无错；此修复是让开关真正可关。）

**D-13（删 allnews + feed channel link）** —— `allnews.md` 现状 [VERIFIED: _pages/allnews.md:1-6]：`title: "News"` / `layout: gridlay` / `sitemap: false` / `permalink: /allnews.html`，正文与 `news.md` 同为 `site.data.news` 全量循环 [VERIFIED: 两文件正文对照]。直接删文件。`feed.xml` 需改的 link 见 D-14。sidebar 已指 `/news/` 无需动 [VERIFIED: _includes/sidebar.html:26 `<a href="{{ site.url }}{{ site.baseurl }}/news/">See all news`]。

**D-14（guid + 条目 link）** —— news 循环现状 [VERIFIED: feed.xml:21-30]：

```liquid
{% for article in site.data.news limit:20 %}
<item>
  <title>{{ article.headline | strip_html | xml_escape }}</title>
  <description>{{ article.headline | strip_html | xml_escape }}</description>
  {% assign article_date = article.date %}
  {% if article_date == "Latest" %}{% assign article_date = site.time %}{% endif %}
  <pubDate>{{ article_date | date_to_rfc822 }}</pubDate>
  <link>{{ site.url }}{{ site.baseurl }}/allnews.html</link>
</item>
{% endfor %}
```

同文件 posts 循环已有 guid 写法可对齐 [VERIFIED: feed.xml:17-18]：

```liquid
<link>{{ post.url | prepend: site.baseurl | prepend: site.url }}</link>
<guid isPermaLink="true">{{ post.url | prepend: site.baseurl | prepend: site.url }}</guid>
```

news 数据无独立 URL 字段（`_data/news.yml` 仅 `date` + `headline`（headline 内含外链），共 6 条）[VERIFIED: _data/news.yml 本会话]。RSS 2.0 对无 permalink 的条目惯例：`<guid isPermaLink="false">` 唯一串。建议形态：

```liquid
<link>{{ site.url }}{{ site.baseurl }}/news/</link>
<guid isPermaLink="false">news-{{ forloop.index }}-{{ article_date | date_to_xmlschema | default: 'latest' }}</guid>
```

（`forloop.index` + 日期组合保证条目唯一；`news-` 前缀 + `isPermaLink="false"` 明示非永久链接。planner 可微调具体串，唯一性是硬要求。）

### Pattern 4: D-18 出版物逐条核对（语料纠偏 + 流程设计）

**研究发现 —— D-18 括号内"（`_site` 出版物页，源自 `papers/ref.bib`）"不准确，planner 必须按实际语料比对：**

| 语料 | 条目数 | 取证 |
|------|--------|------|
| 新站 `_pages/publications.md`（**手写 markdown**，非 scholar 渲染） | **83** 条编号条目，19 个年份标题（## 2026 … ## 2006） | [VERIFIED: `grep -cE "^[0-9]+\. " _pages/publications.md` = 83 本会话] |
| 旧站 `https://zhangtaolab.org/Publication`（live） | **91** 条（fetch 摘要计数，不含封面/评述类子条目），同年份标题 19 个（2006–2026）完全一致 | [CITED: 本会话 WebFetch 线上页；计数由摘要器给出，executor 需精确复核] |
| `papers/ref.bib` | 仅 **12** 条 @article，只被 `_pages/talks.md` 的两个 `{% bibliography --query @incollection[...] %}` 引用（当前为空渲染，已知内容欠账） | [VERIFIED: grep 本会话；talks.md:13,17] |

全站 `{% bibliography %}` 使用点仅 talks.md 两处 [VERIFIED: 全仓 grep 本会话]；`_pages/publications.md` 是纯手写列表（2026 前 3 条与旧站逐字吻合：Bao Y / Liao SY / He Y）。**因此 D-18 比对对象 = 手写 83 条 vs 旧站 91 条**；ref.bib 不参与比对（它甚至不含大部分历史论文）。

83 vs 91 的 8 条差额在逐条核对前无法定性（可能是：旧站摘要器把子条目计入、新旧分类差异、或真实缺漏 —— D-18 规则：缺失阻断、多出列报）。流程建议：

1. **抢收参照物**：核对发生在热切换前（D-18 明确要求）；执行时先把旧站页 `curl https://zhangtaolab.org/Publication -o .planning/phases/02-auto-deploy/old-site-publication.html` 存档，防中途被切。
2. 提取两侧（标题, 首作者, 年份）三元组，按年份标题对齐（两侧 19 个年份完全一致，天然分桶）。
3. 缺失（旧有新无）→ 阻断回报；多出（新有旧无，迁移后新增论文如 2026 新条目）→ 列表给用户确认。
4. 通过后才能设 `DEPLOY_ENABLED`（D-16 前置条件）。

**D-08② 锚点建议（planner 选取稳定值，研究提供候选）**：`s41467-026-73769-8`（2026 Nature Commun. DOI，手写页 [VERIFIED: _pages/publications.md:22 附近] 与 ref.bib `bao2026oryza` 双存在、且是页面第 1 条，最稳）；备选 `PDLLMs`（STATE 记录的 Round-3 改链条目）。注意锚点证明的是"出版物页渲染出了内容"，**不是** scholar 在跑 —— scholar 是否加载由构建本身保证：若 `:jekyll_plugins` 组未加载，`talks.md` 的 `{% bibliography %}` 未知标签会直接**构建失败**（fail loud，不会静默）。[ASSUMED — 未知 Liquid 标签致 Jekyll 构建失败为通识，未本会话实验；风险低，因为 CI 用 `bundle exec` 天然加载插件组]

### Anti-Patterns to Avoid

- **手搓部署（gh-pages 分支推送 / rsync / curl upload API）**：官方工件链已处理 tar、工件命名、deployment API、OIDC —— 一律不用（D-05）。
- **断言写成 `== 11` 精确数**：内容页数量会变（将来加页/删页），`-ge 10` 类阈值断言才能常驻不误报。
- **在 runner 上裸调 `xmllint`**：ubuntu 镜像默认无 xmllint [CITED: actions/runner-images#423]，不装就跑必挂。
- **把 `assets/main.css` vs `main.scss` 输出冲突告警当 CI 失败**：Phase 1 已定性为无害（静态快照胜出），构建退出码 0，断言别去碰它。
- **`gh api` 省略 `--method`**：gh api 默认 GET；PUT/PATCH 必须显式 `gh api --method PUT …` / `--method PATCH`（D-15②③ 的直接踩坑点）。
- **重排 D-15 顺序**：dispatch 依赖默认分支=main，deploy-pages 依赖 build_type=workflow，删 master 必须最后 —— 见 Pattern 1。

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pages 工件上传/发布 | 手动 tar + upload-artifact + deployment API 调用 | `actions/upload-pages-artifact@v3` + `actions/deploy-pages@v5` | 官方 action 处理工件命名（`github-pages`）、tar 规范、deployment 状态机、OIDC —— 手搓必踩版本地雷 |
| Ruby 安装 + gem 缓存 | apt 装 ruby / 手写 cache 步骤 | `ruby/setup-ruby@v1` + `bundler-cache: true` | 自动读 `.ruby-version`、按 lockfile 哈希缓存、deployment 模式安装（README 原文取证） |
| 部署鉴权 | 存 PAT secret 到仓库 | OIDC `id-token: write` + deploy-pages | D-05 权限最小化；无 secret 可泄 |
| XML 校验 | 正则/字符串包含 | `xmllint --noout`（apt 装 libxml2-utils）或 Ruby REXML | XML 合法性有现成解析器；REXML 是 Ruby 默认 gem，runner 与 macOS 本地零差异 |
| baseurl/base_path 处理 | 硬编码空串绕过 | `configure-pages` 输出透传（starter 原样） | 官方语义，未来开 Pages 子路径也不用改 |

**REXML 替代形态（若不想在 runner 上 apt 装包）：**

```bash
ruby -r rexml/document -e 'REXML::Document.new(File.read(ARGV[0])); puts "feed.xml OK"' _site/feed.xml
```

（Ruby 经 setup-ruby 必在；本地 `bundle exec ruby` 同跑。二选一即可，D-08 写的是 xmllint —— 用 xmllint + apt 最贴合决策原文，apt 步骤 ~2s。）

**Key insight:** 本阶段一切"机制"皆有官方构件；自定义只允许出现在两处 —— 断言脚本内容、闸门布尔式。其余全是配置。

## Runtime State Inventory

> 本阶段为**迁移/接管型**（repo takeover + 线上热切换），按协议完整盘点五类。远端状态全部经 `gh api` 本会话实读 [VERIFIED: gh api repos/zhangtaolab/zhangtaolab.github.io/pages 与 /branches 本会话]。

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data（远端 git 存储） | 远端分支恰为：`backup`、`dependabot/bundler/addressable-2.8.1`、`dependabot/bundler/kramdown-2.3.1`、`dependabot/bundler/rexml-3.3.3`、`master`；本地仓库 **无 remote、仅 main 分支** | 代码/分支操作：push main（新增）→ PATCH 默认分支 → 最后删 master + 3 个 dependabot 分支（D-15①②⑥/D-17）。backup 分支不动（回滚锚点） |
| Live service config（服务端配置，不在 git） | Pages：`build_type: "legacy"`、`source: {"branch":"master","path":"/"}`、`cname: "zhangtaolab.org"`、`status: "built"`、`https_enforced: false`、`protected_domain_state: null`、`pending_domain_unverified_at: null`；仓库默认分支 = `master`；`DEPLOY_ENABLED` 变量未设 | **API patch（非代码）**：① `gh api --method PATCH repos/zhangtaolab/zhangtaolab.github.io -f default_branch=main`；② `gh api --method PUT repos/zhangtaolab/zhangtaolab.github.io/pages -f build_type=workflow`；③ `gh variable set DEPLOY_ENABLED --body true`（首跑闸门放行时才设）。切后复查 cname 未回退（D-04 discretion）。`https_enforced: false` 是现状维持，不是待修 |
| OS-registered state | None — verified：纯云端仓库 + 本地 git 工作副本，无 pm2/Task Scheduler/launchd 等注册物 | 无 |
| Secrets/env vars | None — verified：仓库无 secrets 需求（GITHUB_TOKEN 由 Actions 运行时签发，OIDC 短时令牌）；无 SOPS/.env 依赖 | 无（保持零 secret 是 D-05 的自然结果） |
| Build artifacts | 本地 `_site/`、`.jekyll-cache/`（gitignored）；远端 Pages 当前部署的旧站快照（build_type 切换后继续服务直至首次 workflow 部署替换） | 本地产物无需处理；远端快照为"无停机窗口"的保障，首次 deploy 即自然替换 |

**The canonical question 的回答**：repo 文件全部更新后，仍持有旧状态的运行时系统 = ① GitHub 服务端 Pages 配置（build_type/source/default_branch —— 三个 API patch）② 远端分支布局（delete master/dependabot）③ `DEPLOY_ENABLED` 仓库变量（设置时机 = 上线闸门）④ 线上正在服务的旧站快照（首次 deploy 替换，Cloudflare 缓存 ~10 分钟）。

## Common Pitfalls

### Pitfall 1: build_type 未切就 deploy
**What goes wrong:** `deploy-pages` 在 Pages 仍为 legacy 分支模式时直接失败（无 workflow 构建源）。
**Why:** 工件部署通道要求 `build_type=workflow`。
**How to avoid:** D-15 步骤③（PUT pages）必须在任何 deploy 前完成；验证模式 dispatch 也应在③之后（否则 build job 能绿但 deploy 不可测）。
**Warning signs:** deploy job 报 Pages 未启用 workflow 构建类错误。

### Pitfall 2: dispatch 不到 workflow
**What goes wrong:** `gh workflow run deploy.yml` 报 workflow 不存在/不可触发。
**Why:** workflow_dispatch 只认**默认分支**上的 workflow 文件；main 未成为默认分支前 dispatch 不到。
**How to avoid:** D-15 顺序 ①push → ②PATCH default_branch → 之后才 dispatch。
**Warning signs:** `gh workflow run` 找不到 deploy.yml。

### Pitfall 3: runner 上没有 xmllint
**What goes wrong:** 断言③在本地绿、在 CI 红（command not found）。
**Why:** ubuntu runner 镜像默认不带 libxml2-utils [CITED: actions/runner-images#423]。
**How to avoid:** build job 前置 `sudo apt-get install -y libxml2-utils`，或整段换 Ruby REXML（见 Don't Hand-Roll）。
**Warning signs:** 本地 macOS（自带 xmllint [VERIFIED: 本会话 /Users/forrest/miniconda3/bin/xmllint]）与 CI 行为分叉。

### Pitfall 4: 把 vendor 泄漏当成已成立的事实
**What goes wrong:** 规划/执行基于"不修 D-10 就会泄漏 gem 树"的错误前提，浪费排查或误设断言。
**Why:** Jekyll 4.4.1 `DEFAULT_EXCLUDES` 追加 `vendor/bundle/` 等（源码取证 + 本地实验双重证实，见 Pattern 3/D-10）。
**How to avoid:** D-10 照做但定性为防御层；用 `! -d _site/vendor` tripwire 断言兜底（无论排除机制如何变化都拦得住）。
**Warning signs:** 任何"因为 vendor 会泄漏所以…"的推导。

### Pitfall 5: sitemap 断言脆断
**What goes wrong:** `== 11` 精确断言在后续内容页增删时误报，deploy 被自己人挡住。
**Why:** 页数是内容属性，不是构建正确性属性。
**How to avoid:** `-ge 10` 阈值；上线验收单上人工确认"11 = 8 翻转 + 3 原有"即可。
**Warning signs:** D-11 落地后 sitemap 计数与 11 不符（那是排错信号，不是断言值）。

### Pitfall 6: 部署后立即验证线上而扑空
**What goes wrong:** deploy 绿后 curl zhangtaolab.org 拿到旧内容，误判失败。
**Why:** Cloudflare 代理缓存 max-age=600，全球生效 ~10 分钟（CONTEXT 已知）。
**How to avoid:** 验证走 GitHub deployment 状态（`gh api repos/.../pages` 或 run 结论）+ 带 cache-buster 的 curl；把"10 分钟内新旧混杂"写进验收预期。
**Warning signs:** 部署成功但线上内容滞后。

### Pitfall 7: talks 页空列表被误当 scholar 失败
**What goes wrong:** 看到 `/talks/` 文献列表为空，以为 jekyll-scholar 静默失败，耽误上线。
**Why:** ref.bib 无 @incollection 条目（内容欠账，STATE 已记录；页面 200、标题在 [VERIFIED: 本地构建 _site/talks/index.html 含 "Invited Talks"]）。
**How to avoid:** scholar 失败的真信号是构建错误（插件未加载 → `{% bibliography %}` 未知标签 → build 红）或出版物页锚点缺失；talks 空列表是已知内容态。
**Warning signs:** 把 talks 空列表写进断言（会永久绿不了也挡不住真问题）。

### Pitfall 8: Liquid `default` 过滤器的 false 陷阱（D-12 的机制面）
**What goes wrong:** 任何 `{{ x | default: y }}` 在 `x: false` 时拿到 y。
**Why:** Shopify 官方语义：回退条件为 empty/false/nil [CITED: shopify.dev/docs/api/liquid/filters/default]。
**How to avoid:** 需要"显式 false 生效"处加 `allow_false: true`（本次 D-12 修法）。
**Warning signs:** 未来任何布尔开关经 default 过滤器输出。

### Pitfall 9: 并发取消打断进行中的部署
**What goes wrong:** `cancel-in-progress: true` 把跑到一半的 deploy job 杀掉，留下半完成 deployment。
**Why:** 官方 starter 注释明确对生产部署选择不取消。
**How to avoid:** concurrency group "pages" 保留 + `cancel-in-progress: false`（官方值）。
**Warning signs:** 连续快速 push 时 deployment 状态异常。

### Pitfall 10: 删 master 时机错误（不可逆操作）
**What goes wrong:** 提前删 master 丢掉旧站 git 历史（backup 之外唯一远端副本），且若新站未验证，回滚只剩本地克隆。
**Why:** 唯一破坏性步骤（D-15⑥）。
**How to avoid:** 严格最后执行，前置条件 = 新站线上已验证（Pages URL + 自定义域 + 关键页抽查）+ D-18 已通过。
**Warning signs:** 计划里删 master 出现在验证步骤之前。

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Pages "deploy from a branch"（legacy，source=master/doc 仓根） | GitHub Actions 工件模式（build_type=workflow + upload/deploy-pages） | deploy-pages GA 后官方主推；jekyllrb.com 官方指南现以 Actions 模板为准 [CITED: jekyllrb.com/docs/continuous-integration/github-actions/] | 非 白名单插件（jekyll-scholar）唯一可行通道；legacy 模式对自定义 Ruby 版本/插件零支持 |
| gh-pages 分支推送 / personal token | OIDC（id-token: write）短时令牌 | deploy-pages GA 起 | 仓库零长期 secret；权限面最小化（D-05） |
| setup-ruby 手动指定版本 | `.ruby-version` 自动读取（输入省略即生效） | setup-ruby 现行 README [CITED] | 版本事实源单一化，本地/CI 漂移风险消除（DEPLOY-02） |

**Deprecated/outdated:**
- `actions/setup-ruby`（旧 v1）：已弃用，用 `ruby/setup-ruby`。
- CLAUDE.md 中 "Jekyll 4.3.3" 描述：已过时，实际 4.4.1（以 Gemfile.lock 为准）。

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | workflow_dispatch 只能触发默认分支上的 workflow（故 D-15 ②须先于 ④） | Pattern 1 | 低 —— D-15 顺序本身是用户锁定决策，本条只影响"为什么"；若错误，dispatch 仍按锁定顺序执行 |
| A2 | 切 build_type 后旧站快照继续服务直至首次 workflow 部署（"无停机窗口"的技术依据） | Runtime State Inventory | 中 —— 若切换即下线旧站，窗口期 = 切换到首部署之间（分钟级）；缓解：D-15 把正式部署紧跟在切换+验证之后 |
| A3 | `gh api PUT pages -f build_type=workflow` 参数名与取值（endpoint 已 live 实读证实，参数语义来自文档常识，docs.github.com 本会话被网络策略拦截未能直引） | Runtime State Inventory | 低 —— 执行时 API 响应即时报错可纠；planner 可在任务里放 `gh api repos/.../pages` 复查回显 |
| A4 | 旧站 91 条计数（fetch 摘要器给出；年份结构 19/19 吻合、首 3 条逐字吻合已独立证实） | Pattern 4 / D-18 | 低 —— D-18 本就要求逐条精确比对，executor 会得到精确数；此处仅影响预期管理 |
| A5 | 未加载 jekyll-scholar 时 `{% bibliography %}` 未知标签导致构建失败（fail-loud 论断） | Pattern 4 | 低 —— CI `bundle exec` 天然加载 :jekyll_plugins 组；即便假设错，D-08② 锚点断言独立把门 |

**其余全部论断均有 VERIFIED（本会话 Read/gh api/本地实验）或 CITED（官方文档/官方仓库原文）出处。**

## Open Questions

1. **83 vs 91 的 8 条差额定性**
   - What we know: 两侧年份标题 19/19 完全一致；2026 前 3 条逐字吻合；新站手写 83 条，旧站摘要计数 91 条。
   - What's unclear: 差额是摘要计数口径（封面/评述子条目）还是真实缺漏。
   - Recommendation: 按 D-18 逐条核对解决 —— 这正是 D-18 存在的意义；执行时先 curl 存档旧站页。
2. **sitemap 11 的精确值**
   - What we know: 机制上应为 11（8 翻转 + 3 原有）；断言建议 `-ge 10`。
   - What's unclear: 是否有边角（如 feed.xml 意外入图 —— 实测未入）。
   - Recommendation: 执行时以实测数为准记录，断言阈值化防脆断。
3. **actions 用 starter 版本组合还是各最新 major**
   - What we know: starter 组合（v4/v1/v5/v3/v5）为官方测试组合；各最新 major 已核实存在（v7/v1/v6/v5/v5）。
   - What's unclear: upload-pages-artifact v3→v5 跨两个 major 的兼容性。
   - Recommendation: 按 starter 组合落地（本研究的 Standard Stack 建议），首跑绿后如需再升。

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| gh CLI（已登录 forrestzhang，repo scope，ADMIN@目标仓） | D-15/D-16/D-17 全部 API 操作 | ✓ | 本会话实测 [VERIFIED: gh auth status] | — |
| git（本地，无 remote 现状） | push main / 删远端分支 | ✓ | — | — |
| Ruby + Bundler（本地） | 本地复现 CI 命令、验证模式产物对照 | ✓ | ruby 4.0.6 / Bundler 4.0.16 [VERIFIED: 本会话] | — |
| xmllint（本地 macOS） | D-08③ 本地断言 | ✓ | libxml 21309 [VERIFIED] | — |
| xmllint（CI ubuntu runner） | D-08③ CI 断言 | ✗（默认不装） | — | `sudo apt-get install -y libxml2-utils` 或 Ruby REXML [CITED: runner-images#423] |
| GitHub Actions ubuntu runner + Ruby 4.0.6 预编译 | DEPLOY-02 Linux 构建 | ✓（外部服务） | setup-ruby README："all versions from 2.3.0 until 4.0.6"，ubuntu-22.04…26.04 [CITED] | Gemfile.lock 同时含 x86_64/aarch64-linux-gnu，arm runner 亦覆盖 [VERIFIED: Gemfile.lock PLATFORMS] |
| Cloudflare 代理 + DNS（用户管理） | 线上域名链路 | ✓（现状即正确，D-04 零操作） | — | — |

**Missing dependencies with no fallback:** none
**Missing dependencies with fallback:** runner xmllint（apt 装 2 秒或 REXML 零依赖）

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | none —— 静态站点项目无测试框架；本阶段的"测试"= 构建退出码 + 冒烟断言脚本 + workflow 验证模式 + 线上 HTTP 抽查 |
| Config file | none — 见 Wave 0 |
| Quick run command | `JEKYLL_ENV=production bundle exec jekyll build && scripts/ci-smoke.sh _site`（本会话实测构建 ~1s，断言 <2s，全链 <10s） |
| Full suite command | `gh workflow run deploy.yml`（验证模式：build+断言，不 deploy）→ `gh run watch` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DEPLOY-01a | push main 自动触发构建 | e2e (CI) | push 后 `gh run list --workflow=deploy.yml` | ❌ Wave 0（deploy.yml 即被测物与测试载体） |
| DEPLOY-01b | 产物发布 Pages 且 URL 可访问 | e2e (线上) | `curl -fsS https://zhangtaolab.org/publications/`（部署后 + 容忍 ~10min Cloudflare 缓存） | ❌ Wave 0（验收步骤） |
| DEPLOY-01c | 断言把门（sitemap/锚点/feed） | smoke | `scripts/ci-smoke.sh _site` | ❌ Wave 0 |
| DEPLOY-02a | Linux runner 构建绿 | e2e (CI) | 验证模式 run 结论 | ❌ Wave 0 |
| DEPLOY-02b | Ruby 版本一致（pin 落地） | unit | CI 日志含 "Ruby 4.0.6"（setup-ruby 输出）+ `.ruby-version` 已入库 | 部分（.ruby-version ✓ [VERIFIED]；CI 侧随 deploy.yml） |
| D-10~D-14 | 修复正确性 | smoke/目检 | 断言①③覆盖 D-11/D-14；D-12/D-13 目检（dark_mode 关断语义 / allnews 404） | ❌ Wave 0 |
| D-18 | 出版物逐条核对 | manual（人工闸门） | 核对清单（见 Pattern 4 流程） | ❌ Wave 0（清单生成属执行任务） |

### Sampling Rate
- **Per task commit:** `JEKYLL_ENV=production bundle exec jekyll build && scripts/ci-smoke.sh _site`
- **Per wave merge:** `gh workflow run deploy.yml`（验证模式）+ `gh run watch`
- **Phase gate:** full suite green + 首次正式部署 + 线上抽查（Pages URL 与 zhangtaolab.org 双通道）+ D-18 核对通过 —— 全部先于 `/gsd-verify-work` 与删 master

### Wave 0 Gaps
- [ ] `.github/workflows/deploy.yml` —— 本阶段核心交付物，兼作 DEPLOY-01/02 测试载体
- [ ] `scripts/ci-smoke.sh` —— D-08 断言（本地/CI 同源）
- [ ] 无需安装测试框架（保持零依赖，符合项目"无测试框架"现状）

## Security Domain

### Applicable ASVS Categories（Level 1）

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | 静态站点无用户认证；Actions 由 GitHub 托管身份触发 |
| V3 Session Management | no | 无会话 |
| V4 Access Control | yes（CI 面） | GITHUB_TOKEN 最小权限块：`contents: read` + `pages: write` + `id-token: write`（官方 starter 原文 [CITED]）；deploy 闸门 = `vars.DEPLOY_ENABLED`（kill-switch） |
| V5 Input Validation | yes | workflow_dispatch 输入用 **typed boolean**（`type: boolean`，非自由字符串）；断言脚本校验构建产物（sitemap/feed/锚点）；所有 `run:` 步骤零插值用户可控字符串（防 script injection） |
| V6 Cryptography | no | 无自研加密；传输安全由 GitHub/Cloudflare TLS 提供 |
| V14 Configuration | yes | actions 全部来自官方 org（见 Legitimacy Audit）；可选用全 SHA 钉强化供应链；`https_enforced=false` 为 TLS-由-Cloudflare-终结的现状架构决策（非缺陷） |

### Known Threat Patterns for GitHub Actions + Pages

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| 恶意/被劫持 action 版本（supply chain） | Tampering/Elevation | 仅用官方 `actions/*` 与 `ruby/setup-ruby`；major tag 钉版（可升 SHA 钉）；不引入任何第三方 action |
| Script injection（不可信输入进 `run:`） | Tampering | 触发源仅 push（本人）+ dispatch typed boolean；断言全用静态字面量；不用 `pull_request_target` |
| Token 越权/外泄 | Elevation/Info Disclosure | 显式最小 `permissions:` 块；OIDC 短时令牌替代 PAT；仓库零 secrets 存量 |
| 未授权部署（误触发发布） | Tampering | D-16 双闸：常驻变量开关 + 单次 dispatch 放行；删变量即停部署 |
| 误删旧站历史（DoS on rollback） | Denial of Service | D-15 把唯一破坏动作（删 master）排在最后，前置 = 新站线上验证 + D-18 通过；backup 分支 + 本地克隆双保险（D-02） |

## Sources

### Primary (HIGH confidence)
- 本仓文件本会话 Read 取证：`Gemfile`、`Gemfile.lock`、`.ruby-version`、`_config.yml`、`feed.xml`、`.gitignore`、`_includes/head.html`、`_includes/sidebar.html`、`_pages/news.md`、`_pages/allnews.md`、`_pages/publications.md`、`robots.txt`、`_data/news.yml`
- 本会话命令实测：本地 production 构建（sitemap=3/feed 合法/锚点命中/_site 6.0M）、vendor/bundle 泄漏实验（负结果）、`gh api` live Pages 配置与分支表、`gh api` releases/latest 五个 action、`gh variable set --help`
- Jekyll v4.4.1 tag 源码（gh api raw）：`lib/jekyll/configuration.rb` DEFAULT_EXCLUDES/add_default_excludes
- jekyll-sitemap master 源码（gh api raw）：`lib/jekyll/jekyll-sitemap.rb`（注入条件、INCLUDED_EXTENSIONS）

### Secondary (MEDIUM confidence)
- [actions/starter-workflows pages/jekyll.yml](https://raw.githubusercontent.com/actions/starter-workflows/main/pages/jekyll.yml) — 官方 Jekyll workflow 全文
- [ruby/setup-ruby README](https://github.com/ruby/setup-ruby) — .ruby-version 自动读取、bundler-cache 行为、版本支持范围（"2.3.0 until 4.0.6"）
- [Shopify Liquid default filter](https://shopify.dev/docs/api/liquid/filters/default) — false/nil/empty 回退与 allow_false
- [jekyllrb.com GitHub Actions 指南](https://jekyllrb.com/docs/continuous-integration/github-actions/) — Pages 源须先切 Actions、选 "Jekyll" 而非 "GitHub Pages Jekyll" 模板、Gemfile.lock 旧 Bundler 告诫
- [Configuring a publishing source (GitHub Docs)](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) — branch→Actions 切换与自定义域保留
- [actions/runner-images #423](https://github.com/actions/runner-images/issues/423) — xmllint 非预装
- 线上旧站 [zhangtaolab.org/Publication](https://zhangtaolab.org/Publication)（本会话 live fetch）— 91 条/19 年份结构

### Tertiary (LOW confidence)
- websearch 综合结论中"custom domain 独立于 build mode 保留"的表述（与官方 docs 页标题关联，但 docs.github.com 正文本会话被网络策略拦截未直引）—— 已用 live API + D-04 切后复查兜底

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 全部为官方构件，版本经 GitHub API 本会话核实；starter 组合逐行取证
- Architecture: HIGH — 官方链路 + live 远端状态实读 + D-15 顺序的功能性约束被识别
- Pitfalls: HIGH — 4 项实证（vendor 负结果/xmllint 缺位/default-false/sitemap 基线），其余官方注释与文档直引
- D-18 语料: MEDIUM-HIGH — 新侧机器计数；旧侧摘要计数待执行时精确定（D-18 流程本就覆盖）

**Research date:** 2026-08-19
**Valid until:** 2026-09-18（基础设施稳定型；唯 starter-workflows 与 action tag 演进较快，执行前可 30 秒复查 releases）
