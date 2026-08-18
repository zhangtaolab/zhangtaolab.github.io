---
phase: 01-local-dev-environment
verified: 2026-08-18T05:55:00Z
status: passed
score: 32/32 machine truths verified (11 this-round direct: 4 SC + 7 G-1-5/G-1-6 closure; 21 plan-01/02 regression all held), 0 gaps
behavior_unverified: 1 # final visual parity of relaid-out research/software pages vs live reference (G-1-5 residual — plan-03's designated /gsd-verify-work step)
overrides_applied: 0
requirements: [ENV-01, ENV-02]
prohibitions_violated: 0
re_verification:
  previous_status: human_needed
  previous_score: 21/21 machine truths + 1 backstop (D5 visual) → human_needed
  gaps_closed:

    - "G-1-5 (machine side): research/software 零转义（任意标签）+ 8+8 卡 DOM 平铺 + 徽章/占位真实元素 + 文案逐字保全（本报告独立复测全过；UAT 登记的 status: failed 待 /gsd-verify-work 视觉复跑后 reconcile）"
    - "G-1-6 (full): PDLLMs 死链清零 — _pages/ 0 处，about×2 + home×1 指向 Plant_DNA_LLMs，链接文字未变"
  gaps_remaining:

    - "G-1-5 视觉收尾：重排后两页与参考站并排目检（机器已证结构/转义/文案，像素级视觉待人工）"
  regressions: []
behavior_unverified_items:

  - truth: "重排后的 /research/ 与 /software/ 视觉渲染与线上参考站一致（机器门禁已证零转义 + 卡片平铺 + 真实徽章元素 + 文案保全，但像素/布局观感等价超出 grep/DOM 断言能力）"
    test: "本地 bundle exec jekyll serve 后，浏览器并排比对 /research/、/software/ 与参考站对应页（卡片栅格等高、Core Focus/Core Toolkit 徽章渲染、img-wrap 内衬圆角图、7 处 Screenshot 占位框样式）"
    expected: "两页版面与参考站一致，无嵌套大壳、无可见标签文本、无布局错乱；确认后由 /gsd-verify-work 将 01-UAT.md G-1-5/G-1-6 reconcile 为 resolved"
    why_human: "UAT round 2 的失败判定即来自用户目检（'页面混乱'）；机器只能证结构不变量（平铺/零转义），不能证最终视觉等价；03-SUMMARY coverage D1 已标 human_judgment: true"
human_verification:

  - test: "复跑 UAT 测试 4：bundle exec jekyll serve 后浏览器打开 /research/、/software/（可连同 /、/about/、/team/、/news/），与 https://wmsd5fpo6kcfi.ok.kimi.link/ 对应页并排目检"
    expected: "重排两页版面与参考站一致（卡片平铺等高、徽章正常渲染、图片/占位框正常）；通过后将 01-UAT.md 中 G-1-5/G-1-6 置 resolved"
    why_human: "grep/DOM/文案断言只证结构与内容，不证视觉等价；这是 03-PLAN <verification> 第 6 条与 success_criteria 明确指定的最终闭合步骤"

  - test: "裁定 01-REVIEW.md 新 CR-01（feed.xml 六条 news item 的 title/description 以 xml_escape 发布整段 HTML 标记，RSS 阅读器显示标签汤）：Phase 2 部署前小修（feed.xml:23-24 加 strip_html）或接受现状"
    expected: "人工二选一；不修则在 Phase 2 计划中纳入"
    why_human: "feed.xml 为既有文件、三个计划均以 prohibition 明确禁改（超出缺口范围）；不违任何本阶段 must-have（/feed.xml 200 且含 <rss 已证），但属公开产物的用户可见缺陷，部署前需人工决策"
---

# Phase 1 Re-Verification: 本地开发环境（G-1-5/G-1-6 机器闭合后）

**Phase Goal:** 维护者能在本地预览网站全部内容（含出版物列表）
**Verified:** 2026-08-18T05:55:00Z（验证者独立重跑 clean build / 两次自起自停 serve / DOM python 门禁 / 全量正反向 grep / git diff-log —— 全部新证据，未采信任何 SUMMARY 声明）
**Status:** `human_needed`
**Re-verification:** Yes — 第三轮。01-UAT.md round 2 缺口 G-1-3/G-1-4 已由 02-PLAN 闭合（上轮复验确认），本轮复验 03-PLAN（commits 8af4a82/ca3e7c6/6055212 + 923bc77，经 worktree merge 0f97a33 入 main）对 G-1-5/G-1-6 的闭合，并对 plan-01/02 全部机器事实回归。

**结论：** G-1-5 的全部机器可查成分与 G-1-6 全量**真实闭合**（证据见 §1，全部为本验证者 2026-08-18 独立实测）；plan-01 的 11 条与 plan-02 的 10 条机器 must_haves **零回归**；25 条禁制（6+12+7）**零违例**；ENV-01/ENV-02 全覆盖；git 干净、serve 生命周期无残留。机器范围内 **0 缺口**。唯一未决项为 03-PLAN 自己指定的最终步骤——重排两页的并排目检（coverage D1 `human_judgment: true`），按 escalate-gate 契约转人工，故整体 `human_needed` 而非 `gaps_found`。

---

## 0. User Flow Coverage（MVP mode）

ROADMAP 标注本阶段 `Mode: mvp`。沿用上轮记录：`user-story.validate` 的规范正则为英文（`/^As a .+, I want to .+, so that .+\.$/`），对 01-PLAN L23 的中文用户故事（"作为实验室维护者，我想……以便……"）返回 `valid: false` —— 工具语言限制而非格式缺失，语义用户故事完整，本表按其语义构建（信息级，不阻塞）。

| # | 用户故事步骤 | 预期 | 代码库证据（本轮实测） | 状态 |
|---|---|---|---|---|
| 1 | `bundle install` | 退出码 0，依赖锁定 | 本轮实跑 INSTALL_EXIT=0；Gemfile.lock：jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 | ✓ VERIFIED |
| 2 | `bundle exec jekyll serve --livereload` 启动 | 127.0.0.1:4000 可用 | 本轮自起 serve：16 URL 全 200；`Server address: http://127.0.0.1:4000/`、`LiveReload address: http://127.0.0.1:35729`；验后两次停服、端口释放 | ✓ VERIFIED |
| 3 | 预览全部页面（含出版物），布局正常 | 16 URL 200 + marker；出版物 83 条非空；research/software 重排后结构正确 | §1 T1-T7、§2 T4-T6、§3 spot-checks；布局的机器结构证据（零转义+平铺 DOM）全过，像素视觉 → 人工项 | ✓ VERIFIED（视觉部分 → 人工项） |
| 4 | 修改后浏览器自动刷新 | 免手动刷新 | 机制本轮实测：HTML 含 livereload 客户端引用、35729/livereload.js 200；浏览器端行为由 01-UAT.md 测试 1（Playwright 真实 Chromium 双向探针闭环，2026-08-17 pass）作行为证据——机制与页面内容无关，重排不使其失效 | ✓ VERIFIED（既有 UAT 行为证据） |
| 5 | 推送前确认改动 | 内容与参考站权威基准一致 | §2 GC3-GC8 回归全过 + 本轮 G-1-6 死链清零（8 个 GitHub 外链全 200，见 01-REVIEW 实证） | ✓ VERIFIED（D5 视觉 → 人工） |

## 1. 本轮直接验证：G-1-5/G-1-6 闭合（03-PLAN 7/7 VERIFIED）

| # | Truth | Status | Evidence（验证者 2026-08-18 独立实测） |
| --- | --- | --- | --- |
| T1 | `grep -c '&lt;'` research/software 均 0（任意标签升级断言）；全站其余页保持 0 | ✓ VERIFIED | fresh `rm -rf _site .jekyll-cache && build`（exit 0，0.233s，0 Unknown tag、0 Liquid error/warning）后：research=0、software=0、`grep -rl '&lt;' _site --include='*.html'`=**0 文件**、language-plaintext=0 文件（UAT 基线：research=1、software=9） |
| T2 | research 8 卡全部为 research-grid 直接子节点、零嵌套 | ✓ VERIFIED | 独立重跑 python html.parser 门禁：research-card ×8 全为 `(depth=0, parent='research-grid')` —— **DOM-FLAT-OK**（G-1-5 的 2969px 嵌套壳结构上不可能再现） |
| T3 | software 8 张 section-card 平铺（每卡恰 1 个 software-card）；徽章/7 占位/callout 为真实元素 | ✓ VERIFIED | section-card ×8 全为 `(0,'fade-in-section')`、software-card ×8 全为 `(1,'section-card')`（深度=1 因父卡本身是目标类——嵌套会得 ≥2 或非 section-card 父，SUMMARY 偏差 3 的修正逻辑经本验证者独立复核成立）；字面 `Core Toolkit</div>`=1、`Screenshot</div>`=7（真实元素才会产出该字面组合；转义版应为 `&lt;/div&gt;`）；`software-grid` 于源文件=0 |
| T4 | research 8 个 core-badge（首卡 Core Focus + 7 空占位），样式来自页内 main 前缀覆盖块 | ✓ VERIFIED | 源文件：填充徽章=1、空 `<div class="core-badge"></div>`=7；构建产物 core-badge ×8、填充 ×1、首卡 `research-card core` ×1；覆盖块（`main .research-grid … !important`）在源与产物中均在（产物含 9 处 main .research-grid 规则引用）；`_layouts/default.html` L10 `<main class="site-container">` 提供命中前提 |
| T5 | 两页可见文案与重排前逐字一致 | ✓ VERIFIED | 对基线 30a9e84 的 strip-tag 归一化 diff：research **RESEARCH-COPY-IDENTICAL**；software（按 SUMMARY 偏差 2 排除 `<style>` 块——计划同时强制整体替换该块，不排除则自相矛盾；可见文案才是 truth 所指）**SOFTWARE-COPY-IDENTICAL** |
| T6 | PDLLMs 死链 3 处全改指 Plant_DNA_LLMs，链接文字不变 | ✓ VERIFIED | `grep -rn 'zhangtaolab/PDLLMs' _pages/`=**0**、全站产物 0 文件；`Plant_DNA_LLMs` 于 _site/about=2、_site/index=2；`Get PDLLMs on GitHub`=1；源改动仅 about.md 2 行 + home.md 1 行（git diff 30a9e84..HEAD：4 files, 88+/85-，全部落在 _pages/ 4 个计划内文件） |
| T7 | 回环 serve 4 页 200、进程停止 | ✓ VERIFIED | 本轮自起 serve（默认绑定，log 仅 127.0.0.1:4000）：**16 URL 全 200**（4 页超集），research/software 浏览器标题 `Research/Software - Zhang Tao Lab` 各=1；停服后 curl 被拒、`lsof :4000`=0 |

**Score:** 7/7（全部为本轮新证据）

## 2. 回归：plan-02（10/10）与 plan-01（11/11 机器 + T12 行为闭项）

按再验证优化：上轮已全查项做快速回归（存在性 + 关键 marker 抽查），结果全部保持。

| 组 | 抽查项 | 结果 |
| --- | --- | --- |
| plan-02 GC1-GC2 | build exit 0 / 全站零转义 | 本轮 fresh build exit 0；sitewide escape files=0、language-plaintext=0 |
| plan-02 GC3-GC5 | team/news/home markers | /team/ Dr. Wu Yuechao=1（serve 实测）、alumni-table=1、旧名单（Xin Xiaoyue/Ding Yu/Liu Shuo）=0；news-item：/news/=6、首页=3；Featured: DNA Large Language Models=1、字面 `## News`=0 |
| plan-02 GC6-GC8 | about/research/software 文案 + 参考站缺陷零引入 | /about/ Start-up Fund=1（serve 实测）；`{title}`/fonts.loli.net/zstatic.net/jsdmirror 于 index+about=0、4 个改动页源文件=0；`href="./` 扁平链接=0；var(--border) 偏差经核为参考保真（ref-software.html 同样 12 处使用、双方 main.css 同为 161,960B 且均不定义 --border） |
| plan-02 GC9 | publications 83 条零改动 | `git diff c7c300e..HEAD -- _pages/publications.md papers/ref.bib _config.yml feed.xml contact/talks/teaching/blogs` **全空**；`grep -cE '^[0-9]+\. '`=83 |
| plan-02 GC10 / plan-01 T4 | serve 回环 + 停止 | 本轮 16-URL 全 200、绑定仅 127.0.0.1、两次干净停服 |
| plan-01 T1-T3 | install/lock/插件组 | bundle install exit 0；Gemfile L8-11 `group :jekyll_plugins` 含双插件；lock 三版本钉在 |
| plan-01 T5-T6 | 13 页 200 + 出版物三标记 | 13 permalink + feed/sitemap/css 全 200；Telomere-to-telomere=1、The CentO satellite=1、Nature Communications=3 |
| plan-01 T7/T9-T11 | scholar 链路 / .ruby-version / git 卫生 | `_config.yml` L82 `source: /papers/`；`assets/ref.bib` 不存在；.ruby-version 4.0.6 = runtime 4.0.6；.gitignore 三行在、`git check-ignore _site` 命中、porcelain=0、13 页跟踪；STATE.md L48-52 已决策记录在位 |
| plan-01 T12/T13 | live reload / 视觉（backstop） | T12：机制本轮实测（HTML 含 livereload 客户端引用 + 35729 端点 200）+ 01-UAT 测试 1 Playwright 行为证据闭项；T13：`/assets/main.css` 200 且 161,960B（机器部分），整体视觉 → 本轮人工项（重排后两页） |

## 3. Prohibitions（25 条：plan-01 6 + plan-02 12 + plan-03 7，零违例）

| 检查 | 结果 |
|---|---|
| sudo/全局 gem、掩盖错误、卸插件、演示 bib、裁剪 83 条 | 未违例（Gemfile/_config 无相关改动；error_mode 0 命中；双插件在 lock；assets/ref.bib 不存在；publications diff 空） |
| serve 绑定非回环 | 未违例（两次 serve log 均仅 `Server address: http://127.0.0.1:4000/`，未用 --host） |
| 改 _sass//assets/css//assets/main.scss/main.css | 未违例（git diff 30a9e84..HEAD 上述路径全空） |
| 虚构照片/新建图片/引用不存在图片 | 未违例（30a9e84..HEAD `--diff-filter=A -- images/`=0；产物本地 img src 破链检查=0；headshot 产物 0 引用——IN-10 的 site.photo 经 static_files 存在性守卫惰性化） |
| 改 publications/papers/ref.bib/contact/talks/teaching/blogs/_config/feed.xml | 未违例（c7c300e..HEAD 上述路径 diff 全空） |
| 复制参考站实体编码 alt（ref-research L137） | 未违例（源文件实体 alt=0，alt 均纯文本） |
| 引入参考站缺陷（CDN/扁平链接/{title}） | 未违例（4 页源文件与产物均 0 命中） |
| 并行执行/顺序 | 未违例（提交序列 8af4a82→ca3e7c6→6055212→923bc77 与 Task 1→4 一一对应） |

## 4. Behavioral Spot-Checks（验证者本轮实测）

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| 全新构建绿 | `rm -rf _site .jekyll-cache && bundle exec jekyll build` | exit 0，0.233s，0 Unknown tag / 0 Liquid error | ✓ PASS |
| G-1-5 升级转义门禁 | `grep -c '&lt;'` ×2 页 + `grep -rl` 全站 | 0 / 0 / 0 文件 | ✓ PASS |
| DOM 平铺门禁 | python html.parser 深度/父断言 | DOM-FLAT-OK（8/8/8，父子关系全对） | ✓ PASS |
| 文案保全 | 归一化 diff vs 30a9e84 | 两页均 IDENTICAL | ✓ PASS |
| G-1-6 死链清零 | grep _pages/ + 产物计数 | 0 死链；2/2 canonical；文字 1 | ✓ PASS |
| 复发条件 | `grep -En '^ {4,}.*<'` 两源文件 | 0 行 | ✓ PASS |
| serve 生命周期 | 自起 → 16 URL → 按 PID 停 | 全 200；SERVE-STOPPED；lsof=0 | ✓ PASS |
| live reload 机制 | `--livereload` 起服 + 端点探测 | 客户端引用=1；35729/livereload.js=200 | ✓ PASS |
| bundle install | 实跑 | exit 0 | ✓ PASS |
| git 卫生 | status/ls-files/check-ignore | porcelain=0；13 页跟踪；_site ignored | ✓ PASS |

## 5. Artifacts / Key Links / Data-Flow（03-PLAN）

**Artifacts（5/5）**

| Artifact | 状态 | 详情 |
|---|---|---|
| `_pages/research.md` | ✓ VERIFIED | 存在（L1）、实质（网格直通容器 + 8 卡参考结构 + 覆盖样式块，105 行重排）、接线（构建产物结构/标题/图片全对） |
| `_pages/software.md` | ✓ VERIFIED | 存在、实质（平铺 section-card ×8 + 逐卡直通 + 参考样式块）、接线（产物 8/8/7/1 计数全对） |
| `_pages/about.md` | ✓ VERIFIED | 2 处 href 修正，其余未动（diff 4 行：2+/2-） |
| `_pages/home.md` | ✓ VERIFIED | 1 处 href 修正（diff 2 行：1+/1-） |
| `03-SUMMARY.md` | ✓ VERIFIED | 199 行，闭合证据与偏差记录完整 |

**Key Links（3/3 WIRED）**

| From | To | Via | Status |
|---|---|---|---|
| research.md 页内 main 前缀覆盖块 | _layouts/default.html L10 `<main class="site-container">` | main 前缀选择器命中前提（gridlay 继承 default） | ✓ WIRED（产物含 9 处 main .research-grid 规则） |
| markdown="0" 直通包装 | kramdown `parse_block_html: true`（_config.yml L73） | 转义免疫机制 | ✓ WIRED（research-grid ×1 + software ×9 包装，产物零转义实证生效） |
| 卡片 img Liquid 绝对路径 | images/research/*.jpg（8 张）+ images/software/dnallm-suite.png | Liquid 先于 kramdown 解析 | ✓ FLOWING（产物引用的 9 个图片文件全部实存于磁盘） |

**Data-Flow（Level 4）**：两页图片 → 磁盘实存文件（FLOWING）；卡片文案 → _pages 源文件（经文案保全 diff 证逐字流动）；无任何值终止于静态占位/硬编码空数据。

## 6. Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| ENV-01 | 01/02/03-PLAN | bundle install + serve + live reload，本地预览全链路 | ✓ SATISFIED | §2 回归 T1-T4/T9-T11；UAT 测试 1（live reload 行为）；ROADMAP 判据 1/4 成立 |
| ENV-02 | 01/02-PLAN | 全页面正常渲染，出版物非空，scholar 正常解析 papers/ref.bib | ✓ SATISFIED | §1 T1-T4 + §2 T5-T7；判据 2 机器部分/3 成立；判据 2 的「布局正常」结构证据全过、视觉 → 人工项 |

REQUIREMENTS.md 追溯表仅 ENV-01/ENV-02 映射 Phase 1，均被 PLAN frontmatter 声明并闭环；**无缺失 ID、无孤儿 requirement**。

## 7. Anti-Patterns / 评审发现处置

| 来源 | 发现 | Severity | 处置 |
|---|---|---|---|
| 债务标记扫描 | 4 个改动文件 TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER | — | **0 命中** |
| 源码 | `software-thumb-placeholder`（"Screenshot" 占位框 ×7） | ℹ️ Info | 非桩：参考站同款设计（截图确未提供，参考站同样渲染虚线占位框），03-PLAN truth 3 明确要求；有真实按钮/链接/引文数据流 |
| 03-SUMMARY vs 历史 | Task 4 提交号 abb92dd 不在 main 祖先 | ℹ️ Info | worktree merge（0f97a33）等价落地为 923bc77（含 03-SUMMARY.md 199 行）；内容无损，工作树=HEAD |
| 01-REVIEW（2026-08-18T05:32 新轮） | **CR-01：feed.xml 六条 news item 的 title/description 以 xml_escape 发布整段 HTML 标记**（RSS 阅读器显示标签汤；&rarr; 双重转义） | ⚠️ Warning（人工决策） | 既有文件、三计划均以 prohibition 禁改（超范围）；不违任何本阶段 must_have（/feed.xml 200 且 <rss 在证）。属 Phase 2 上线前的公开产物质量缺陷 → 已列人工裁定项（修复仅需 feed.xml:23-24 加 `strip_html`） |
| 01-REVIEW WR-01..06 | feed 无 guid、dark_mode default 逻辑、sitemap 排除、教育数据双源、vendor 未排除、双 News 页 | ℹ️ Info | 均不推翻本阶段 must_haves，多数属 Phase 2 部署卫生 |
| 01-REVIEW IN-01..10 | noopener、JSON-LD、papers/ 入产物、headshot 引用等 | ℹ️ Info | IN-10 经本轮实测惰性化（产物 0 引用、0 破链 img）；其余超阶段范围备查 |

## 8. Human Verification Required（2 项）

### 1. 重排两页最终视觉确认（G-1-5 收尾，03-PLAN 指定步骤）

**Test:** `bundle exec jekyll serve` 后浏览器打开 `/research/`、`/software/`（可连同 `/`、`/about/`、`/team/`、`/news/`），与 https://wmsd5fpo6kcfi.ok.kimi.link/ 对应页并排目检。重点：8 卡栅格平铺等高（无嵌套大壳）、Core Focus / Core Toolkit 徽章真实渲染、img-wrap 内衬 10px 圆角图、7 处 Screenshot 虚线占位框样式。
**Expected:** 版面与参考站一致，无可见标签文本、无布局错乱。通过后由 `/gsd-verify-work` 将 01-UAT.md 的 G-1-5/G-1-6 reconcile 为 resolved。
**Why human:** 机器门禁证结构不变量（平铺/零转义/文案），不证像素级视觉等价；UAT round 2 的失败判定正来自用户目检；03-SUMMARY coverage D1 标 `human_judgment: true`。

### 2. CR-01 feed.xml 转义标题裁定（Phase 2 前置决策）

**Test:** 阅读 01-REVIEW.md CR-01（附 _site/feed.xml 实证标签汤），决定：Phase 2 部署前小修（`feed.xml:23-24` 对 headline 加 `strip_html |` 前置于 `xml_escape`）或接受现状延后。
**Expected:** 人工二选一；选择修复则并入 Phase 2 计划范围。
**Why human:** 超出本阶段三个计划的范围边界（prohibition 保护 feed.xml 不动），验证者无权替开发者扩scope；缺陷真实且用户可见，需在上线前决策。

## 9. 结论

Phase 1 目标「维护者能在本地预览网站全部内容（含出版物列表）」在机器可查范围内**完整达成且经三轮 gap closure 后零回归**：G-1-5 机器成分（零转义任意标签门禁 + DOM 平铺 + 真实徽章元素 + 文案逐字保全）与 G-1-6 全量（死链清零、链接文字不变）均由本验证者独立复测确认；G-1-3/G-1-4 保持闭合；publications 83 条未动；构建/serve/16-URL/live reload 链路全绿；25 条禁制零违例；git 干净。整体状态 **human_needed**：待重排两页并排目检通过（并裁定 CR-01 feed 事项）后即可记 passed；若目检失败则升级 gaps_found 重开缺口。

---
*Verified: 2026-08-18T05:55:00Z by gsd-verifier（独立重测：clean build、python DOM 门禁、两次自起自停 serve、16-URL 循环、livereload 端点、全量正反向 grep、git diff/log 范围核对、参考快照交叉验证 —— 全部新证据，未采信 SUMMARY 声明）*
