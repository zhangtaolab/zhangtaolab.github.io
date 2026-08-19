# Phase 2: 自动部署 - Context

**Gathered:** 2026-08-18
**Status:** Ready for planning

<domain>
## Phase Boundary

维护者推送到 GitHub 后，Actions 自动完成完整 Ruby 构建（含 jekyll-scholar）并发布到 GitHub Pages；本地与 CI 构建一致（Ruby/Jekyll 版本锁定）；**以原地接管现有线上仓库的方式完成热切换上线**（旧站正由该仓服务）；随车修复 Phase 1 代码评审遗留的 5 项问题（①vendor exclude ②sitemap 全量化 ③dark_mode 默认值 ④双新闻页收歗 ⑤RSS guid）。

实现需求：DEPLOY-01、DEPLOY-02。

</domain>

<decisions>
## Implementation Decisions

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

### 评审遗留随车修复（用户决策：5 项全修）
- **D-10:** ① `_config.yml` `exclude` 增 `vendor` + `.gitignore` 增 `vendor/`（防 CI 上 gem 树进 `_site` 发布）
- **D-11:** ② sitemap 全量化：翻掉内容页的 `sitemap: false`（现 10 页在黑名单，含 `home.md`/`publications.md`），仅 404 与重复页除外；`robots.txt` 的 Sitemap 广播行保留
- **D-12:** ③ `_includes/head.html` `dark_mode | default: true` 改为显式判断 false（Liquid `default` 过滤器不判 false，`dark_mode: false` 会失效）
- **D-13:** ④ 删除 `_pages/allnews.md`（与 `news.md` 内容 100% 相同：同一 `site.data.news` 全量循环），`feed.xml` channel link 从 `/allnews.html` 改指 `/news/`（sidebar 已指 `/news/`，无需动）
- **D-14:** ⑤ `feed.xml` 条目补唯一 `<guid>` 并修正条目级 `<link>`（WR-01：news 条目共享 link 且无 guid，聚合器无法区分条目）

### Claude's Discretion
- workflow 具体结构：job 拆分、`concurrency` 取消旧跑、bundler 缓存、runner 选型（ubuntu-latest）、断言脚本实现形式（shell/ruby）
- ~~远端备份 tag 是否创建（D-02）~~ 已不需要 — 远端 `backup` 分支已就位
- CNAME 文件是否入仓（Pages 设置里 cname 已存在且随仓库继承，工件模式通常无需 CNAME 文件；执行时若发现需要再加）
- CI 构建设 `JEKYLL_ENV=production`（analytics 仅生产输出；当前 `google_id` 为空，无实际差异但保持环境正确性）
- 切换 build_type 后确认 cname 域名验证状态不回退（HTTPS 由 Cloudflare 终结，`https_enforced=false` 现状维持）

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 项目规划事实源
- `.planning/PROJECT.md` — 部署约束（Actions 自定义构建）、Key Decisions 表、Context（本机环境实测记录）
- `.planning/REQUIREMENTS.md` — DEPLOY-01/DEPLOY-02 定义与 v2 推迟项（QUAL-01 html-proofer 明确不在本阶段）
- `.planning/ROADMAP.md` — Phase 2 目标与 4 条成功标准
- `.planning/STATE.md` — 「Phase 2 前置关注」5 项代码评审遗留（即 D-10~D-14）+ Ruby/Jekyll 版本决策全记录

### 代码库地图（2026-08-17 生成，版本号信息已过期，以 STATE.md 为准）
- `.planning/codebase/INTEGRATIONS.md` — 外部集成现状：GA4、Cloudflare CDN 链路、RSS、sitemap
- `.planning/codebase/CONCERNS.md` — 已知风险：无 CI 基础设施、无构建验证、http:// 混用引用

### 版本锁定与配置
- `Gemfile` / `Gemfile.lock` — Ruby 依赖锁定 + Linux 平台条目（CI 一致性事实源）
- `.ruby-version` — 4.0.6（CI Ruby 版本事实源）
- `_config.yml` — url/baseurl/exclude/plugins/scholar 配置（D-10 修改对象）

### 修复对象文件
- `feed.xml` — D-13/D-14 修改对象（Phase 1 已加 strip_html，本轮补 guid/link）
- `_pages/news.md` / `_pages/allnews.md` — D-13（删 allnews，news 保留）
- `_includes/head.html` — D-12 修改对象
- `robots.txt` — D-11 相关（Sitemap 广播行，保留不动）
- `_includes/sidebar.html` — ④ 链接现状参考（已指 `/news/`）

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Gemfile.lock`：22 平台条目齐备（含 x86_64-linux-gnu / aarch64-linux-gnu），CI 无需 `bundle lock --add-platform`
- `.ruby-version`：已被 setup-ruby 生态标准支持，直接读取
- `gh` CLI 已登录（账号 forrestzhang，对目标仓库 ADMIN 权限已核实）— 建仓/切 Pages build_type/触发 workflow 全部可脚本化
- 旧仓 Pages 配置现成：cname=zhangtaolab.org 已挂、status=built — 切 build_type 后域名链路继承

### Established Patterns
- 无任何 CI 基础设施（`.github/workflows/` 不存在）— 全新创建，无历史包袱
- Jekyll 环境感知：模板用 `jekyll.environment == 'production'` 分支（analytics）
- 已知无害告警：`assets/main.css` 与 `assets/main.scss` 输出冲突（静态快照胜出，不影响验收，勿在 CI 中当作失败）

### Integration Points
- push → workflow → Pages artifact → 现有 Cloudflare 代理链路（zhangtaolab.org 已在线服务）
- Cloudflare 缓存 `max-age=600` — 部署后约 10 分钟内全球可见切换

### Known Risks（供 researcher/planner 评估）
- Ruby 4.0.6 + Jekyll 4.4.1 组合仅在 arm64 macOS 实测；Linux runner 首跑属首次验证（超出 Jekyll 官方支持范围 ≤3.3.x 的"实测可用"路线）。若 CI 失败，应对属规划范畴（勿擅自改版本组合，回报用户）
- 首次 deploy 即替换线上站（热切换）；回滚路径：远端 `backup` 分支（与 master 同指 b09c9b31）或用户本地克隆重新推回

</code_context>

<specifics>
## Specific Ideas

- 用户原话："接管原有仓库，目前已经克隆到了本地 /Users/forrest/GitHub/zhangtaolab.github.io，可以进行完全覆盖" — 旧站无保留价值，覆盖无需额外确认
- 首次上线是**热切换**而非新站开通：zhangtaolab.org 当前正服务旧版（实测 200，title "Home | Zhang Tao lab"，last-modified 2026-05-29），首次 deploy 后立即替换（Cloudflare 缓存 ~10 分钟）
- `https_enforced=false` 是现状（TLS 由 Cloudflare 终结），不是待修项

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope（5 项评审遗留经用户决策全部随车修复，无推迟项、无范围外想法）

</deferred>

---
*Phase: 2-自动部署*
*Context gathered: 2026-08-18*
