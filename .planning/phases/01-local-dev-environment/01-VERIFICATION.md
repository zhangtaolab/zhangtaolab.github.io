---
phase: 01-local-dev-environment
verified: 2026-08-18T01:16:00Z
status: human_needed
score: 21/21 machine truths verified (10 gap-closure + 11 plan-01 regression), 0 gaps
behavior_unverified: 1 # visual parity of rewritten pages vs live reference (D5)
overrides_applied: 0
requirements: [ENV-01, ENV-02]
prohibitions_violated: 0
re_verification:
  previous_status: human_needed
  previous_score: 11/11 machine truths + 2 backstop → human_needed
  gaps_closed:
    - "G-1-3: kramdown-escaped HTML（&lt;div Rouge plaintext 代码块）in _site/about(3)/team(23)"
    - "G-1-4: 站点内容与参考快照为不同年代版本集（团队名单/新闻/首页/研究/软件/关于文案）"
  gaps_remaining: []
  regressions: []
behavior_unverified_items:
  - truth: "重写后的 6 个页面（home/about/team/research/software/news）视觉渲染与线上参考站 https://wmsd5fpo6kcfi.ok.kimi.link/ 一致（grep marker 只证内容存在，不证像素/布局等价）"
    test: "本地 bundle exec jekyll serve 后，浏览器并排比对本地页与参考站对应页（hero/卡片/表格/占位头像渐变/页内 pi-photo-placeholder 样式）"
    expected: "布局、样式、图片呈现与参考站一致，无错乱、无裸 HTML 观感"
    why_human: "渲染保真度超出 grep/HTTP 断言能力；02-SUMMARY coverage D5 已标 human_judgment: true"
human_verification:
  - test: "本地起 serve（bundle exec jekyll serve），浏览器打开首页/about/team/research/software/news，与 https://wmsd5fpo6kcfi.ok.kimi.link/ 对应页并排目检"
    expected: "视觉布局与参考站一致（含 team 页渐变图标占位、about 页绿色渐变 PI 占位框、4 列校友表）；样式加载完整、图片正常"
    why_human: "grep marker 证明内容逐字到位，不证明视觉等价（D5）；且 2026-08-17 UAT 目检通过的是重写前的旧页面，不覆盖本次重写后的新 DOM"
---

# Phase 1 Re-Verification: 本地开发环境（gap closure 后）

**Phase Goal:** 维护者能在本地预览网站全部内容（含出版物列表）
**Verified:** 2026-08-18T01:16:00Z（验证者独立重跑 build/serve/grep/git，不采信 SUMMARY 声明）
**Status:** `human_needed`
**Re-verification:** Yes — 01-UAT.md G-1-3/G-1-4 经 02-PLAN（commits c4d4eff..c7c300e）闭合并由本报告复验；plan-01 全部机器事实回归通过。

**结论：** 两个缺口 **G-1-3、G-1-4 均已在代码库/构建产物中真实闭合**（证据见下）；plan-01 的 11 条机器 must_haves **全部保持成立**（1 条 marker 集被 02-PLAN 有意更新，见裁定 1）；6+6 条禁制零违例；ENV-01/ENV-02 全覆盖。机器可查范围内 **0 缺口**。唯一未决项为 02-SUMMARY coverage D5（重写页面对参考站的视觉保真，`human_judgment: true`）——按 escalate-gate 契约转人工确认，故整体 `human_needed` 而非 `gaps_found`。

---

## 0. User Flow Coverage（MVP mode）

ROADMAP 标注本阶段 `Mode: mvp`。工具式说明：`user-story.validate` 的规范正则为英文（`/^As a .+, I want to .+, so that .+\.$/`），对 01-PLAN 内的中文用户故事（"作为实验室维护者，我想……以便……"）与中文阶段目标均返回 `valid: false` —— 属工具语言限制而非格式缺失；语义用户故事存在且完整（01-PLAN L23 / 02-PLAN L27），本表按其语义构建。工具正则问题已如实记录，建议后续为该 verb 补多语叙事等价判定（信息级，不阻塞）。

| # | 用户故事步骤 | 预期 | 代码库证据 | 状态 |
|---|---|---|---|---|
| 1 | 维护者执行 `bundle install` | 退出码 0，依赖锁定 | Gemfile.lock 在库（jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0，L84/L105/L110） | ✓ VERIFIED |
| 2 | `bundle exec jekyll serve --livereload` 启动 | 127.0.0.1:4000 服务可用 | 验证者自起 serve：log `Server address: http://127.0.0.1:4000/`；`/` 200 含 Zhang Tao Lab；验证后进程已停（4000/35729 无监听） | ✓ VERIFIED |
| 3 | 浏览器预览全部页面（含出版物列表），内容与参考站一致 | 15 URL 全 200 + marker；出版物 83 条非空；6 页内容对齐参考快照 | 见 §1 T-GC2..T-GC9 与 §2 回归 T5/T6 | ✓ VERIFIED（视觉部分 → 人工项 D5） |
| 4 | 修改内容后浏览器自动刷新 | 无需手动刷新页面更新 | 01-UAT.md 测试 1（Playwright 真实 Chromium，双向探针闭环，2026-08-17 pass）；机制与页面内容无关，重写不使其失效 | ✓ VERIFIED（既有 UAT 证据） |
| 5 | 推送前确认改动（内容=参考站权威基准） | 团队/新闻/首页/研究/软件/关于与 ref-*.html 一致 | §1 全部 G-1-4 marker 断言 | ✓ VERIFIED（D5 视觉 → 人工） |

---

## 1. Gap-closure must_haves（02-PLAN，10/10 VERIFIED）

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| GC1 | `bundle exec jekyll build` 退出码 0 | ✓ VERIFIED | 验证者全新构建：`BUILD_EXIT=0`（0.218s），输出 0 处 `Unknown tag 'bibliography'`、0 处 liquid error/warning |
| GC2 | G-1-3 清零：about/team `&lt;div` = 0，全站无 Rouge plaintext 转义块 | ✓ VERIFIED | `_site/about/index.html`=0、`_site/team/index.html`=0；`grep -rl '&lt;div' _site --include='*.html'` = **0 个文件**（基线 about=3/team=23）；`language-plaintext` 全站 0 文件。源头免疫：`grep -En '^ {4,}.*<'` 于 team.md/about.md/home.md 均 0 行（kramdown 缩进代码块复发条件已消除） |
| GC3 | G-1-4 team：PI + Current Member + Students + Join Us + 4 列校友表，无旧名单残留 | ✓ VERIFIED | `_site/team/index.html`：Dr. Wu Yuechao=1、Yangzhou University (YZU)=1、Chengdu Institute of Biology (CIB)=1、Chen Long/Dian Zhang 在 role 数据、Ph.D. UESTC=1、Professor, Bioinformatics, Epigenetics and Genomics=1、Join Us=1、alumni-table=1、Liu Guanqing=1、Bao Yu=1、`2017–2025` en-dash=1；反向：旧名单（Xin Xiaoyue/Ding Yu/Liu Shuo）=0、`images/team/team/`=0、avatar.jpg/placeholder.jpg=0。ref-team.html 对照：alumni 两行（Liu Guanqing/Bao Yu + 两个 en-dash 年份）逐项吻合；页内 `<img>` 仅 2 处 logo.png（navbar 品牌 + PI 卡照片，`images/logo.png` 37KB 实存），当前成员为学生渲染渐变图标占位（未虚构照片） |
| GC4 | G-1-4 news：6 条且顺序与 ref-news 一致；/news/ 与 /allnews.html 各 6；首页侧栏 3；feed 可构建 | ✓ VERIFIED | news.yml YAML 解析 6 条；日期序列 Latest→May 2026→May 2026→March 2026→December 2024→June 2023 与 ref-news.html `date">` 序列**逐位一致**；`class="news-item"`：/news/=6、/allnews.html=6、index=3；tibtech DOI=1、Molecular Plant fulltext=1、欢迎条目=1、Trends in Biotechnology=1；`_site/feed.xml` 含 `<rss` 且构建绿 |
| GC5 | G-1-4 home：hero/Featured/DNALLM-Suite/banner/About the Lab 对齐；无字面 ## News、无 headshot 破图、无重复 News 块 | ✓ VERIFIED | `_site/index.html`：Featured: DNA Large Language Models=1、CLI, UI, and MCP support=1、Overview of our research=1、home-hero=2、banner-caption=1；反向：`## News`=0、headshot.jpg=0（含 head.html og:image 已由 static_files 存在性守卫）、旧 intro "We are the "=0 |
| GC6 | G-1-4 about：PI 卡 + Research Interests + Featured Work + Grants 对齐；空壳 Education 与破损 grant-item 已消除 | ✓ VERIFIED | `_site/about/index.html`：We are at the intersection of AI and biology=1、unprecedented accuracy=1、Get PDLLMs on GitHub=1、Start-up Fund=1（经 `grant.name` 正确取数）、pi-photo-placeholder=2（占位 div + 页内样式）；反向：`Education`=0（空壳小节已删） |
| GC7 | G-1-4 research/software：8+8 卡描述/引文/标题对齐；浏览器标题正确 | ✓ VERIFIED | research：Below are our key research areas=1、leveraging LLM-based approaches=1、telomere-to-telomere genome assemblies=1、MCP protocol support=1，`<title>Research - Zhang Tao Lab</title>`；software：in-silico mutagenesis=1、Performs all calculations locally=1、Braz GT, Jiang J=1、Liu GQ, Chen L, Wu YC=1、ModelScope Hub=1、`et al.`=0，`<title>Software - Zhang Tao Lab</title>` |
| GC8 | 参考站缺陷零引入 | ✓ VERIFIED | `{title}` 于 index/about=0；fonts.loli.net/zstatic.net/jsdmirror=0；`href="./` 扁平链接于 index=0；目录式 permalink 保持（/research/ 等目录 URL 实测 200） |
| GC9 | publications.md 83 条零改动 | ✓ VERIFIED | `git diff --stat 7cac7e4 -- _pages/publications.md` 为空；`grep -cE '^[0-9]+\. '` = 83 |
| GC10 | 回环 serve（127.0.0.1:4000）抽检 6 页 200 含 marker；进程停止 | ✓ VERIFIED | 验证者自起 serve：6 个 gap 页全部 200，/team/ 含 Dr. Wu Yuechao=1、/about/ 含 Start-up Fund=1；`lsof -iTCP:4000 -sTCP:LISTEN` 空（已停）；serve log 仅 127.0.0.1（无 0.0.0.0）；`git status --porcelain` = 0 |

**Score:** 10/10（全部为验证者 2026-08-18 实机新证据）

## 2. Plan-01 must_haves 回归（11/11 成立，1 条 marker 集被后续计划有意更新）

| # | Truth（缩写） | Status | Evidence |
| --- | --- | --- | --- |
| T1 | bundle install exit 0 + Gemfile.lock 入库 | ✓ VERIFIED | `git ls-files` 含 Gemfile.lock/.ruby-version/papers/ref.bib（3/3）；lock：jekyll 4.4.1、jekyll-scholar 7.3.0、jekyll-sitemap 1.4.0 |
| T2 | build exit 0，无 Unknown tag 'bibliography' | ✓ VERIFIED | 本次全新构建 BUILD_EXIT=0，Unknown tag 计数 0 |
| T3 | Gemfile :jekyll_plugins 双插件 | ✓ VERIFIED | Gemfile L8-11：group 块内 jekyll-scholar + jekyll-sitemap |
| T4 | serve 200 且含 Zhang Tao Lab | ✓ VERIFIED | 本次 serve 实测通过（16-URL 循环首项） |
| T5 | 13 页 permalink 200 + marker | ✓ VERIFIED（marker 更新裁定，见裁定 1） | 15 URL 循环：13/15 marker 命中 + 2 项 superseded——/research/ 与 /software/ 均 **200**，但 plan-01 旧 marker（"Research Areas" h2 / "Software &amp; Tools" h2）已被 02-PLAN Task 5/6 按参考站有意替换为 `<h1 class="page-title">Research</h1>`/`Software`（与 ref-research/ref-software 的 page-title 逐字一致，标题 `Research/Software - Zhang Tao Lab` 正确）。属后续计划对旧断言的合法取代，非回归。第 16 项 main.css 200 / 161,960B |
| T6 | /publications/ 三标记全跨度 | ✓ VERIFIED | Telomere-to-telomere=1、The CentO satellite=1、Nature Communications=3（83 条完整，源文件条目数 83） |
| T7 | scholar.source=/papers/ + 探针 12/12 | ✓ VERIFIED（静态部分） | `_config.yml` L82 `source: /papers/`；assets/ref.bib 不存在（演示数据保持清除）。探针为 plan-01 期一次性产物，此前验证已独立复测 12/12 并清理；本侧保持静态链路事实成立 |
| T9 | .ruby-version = 运行时 | ✓ VERIFIED | 文件 4.0.6 = `bundle exec ruby -e 'puts RUBY_VERSION'` 4.0.6 |
| T10 | .gitignore + git status 干净 | ✓ VERIFIED | .gitignore 含 _site//.jekyll-cache//.bundle/；`git check-ignore _site` 命中；porcelain=0；`git ls-files _pages`=13 |
| T11 | STATE.md 版本决策记录 | ✓ VERIFIED | 「关键决策点（已决策）」在位；L75 新增 gap-closure 实测记录（对齐 + 清零 + 6 页 200） |
| T12/T13 | backstop：浏览器自动刷新 / 视觉 | ✓ 已由 UAT 闭项 → 新视觉人工项 | 01-UAT.md 测试 1（Playwright 双向探针，pass）闭 T12（机制与页面内容无关）；测试 2 pass 于**重写前**旧页面——新页面的视觉确认为本次人工项（见 frontmatter human_verification） |

## 3. Prohibitions（12/12 未违例）

| # | 禁制 | 检查 | 结果 |
|---|---|---|---|
| 1 | 无 sudo/全局 gem 绕过 | Gemfile/_config.yml 零命中 sudo gem / --user-install | 未违例 |
| 2 | 无掩盖错误换绿构建 | error_mode 零命中；talks.md 完整含 2 个 bibliography 标签；_pages 13 页无删 | 未违例 |
| 3 | 未移除两插件 | Gemfile group 内双插件 + lock 锁定 | 未违例 |
| 4 | 演示数据不在文献链 | `test ! -f assets/ref.bib` 通过；scholar.source 唯一 /papers/ | 未违例 |
| 5 | 未替换/裁剪 83 条手写列表 | publications.md diff 空；83 条目在 | 未违例 |
| 6 | serve 仅绑回环 | serve log `Server address: http://127.0.0.1:4000/`，未用 --host | 未违例 |
| 7 | 参考站缺陷零引入 | {title}/扁平链接/CDN 字体全 0（GC8） | 未违例 |
| 8 | 未动 _sass//assets/css//assets/main.scss | `git diff 7cac7e4 -- _sass/ assets/css/ assets/main.scss` 为空 | 未违例 |
| 9 | 未虚构照片/未引用不存在图片 | gap 区间 `git log --diff-filter=A -- images/` 0 新文件；images/ diff 0；headshot/avatar/placeholder.jpg 站内 0 引用；team 页 img 仅实存 logo.png | 未违例 |
| 10 | 未动 publications/papers/ref.bib/contact/talks/teaching/blogs/_config | `git diff 7cac7e4` 上述路径全空 | 未违例 |
| 11 | 严格顺序执行 | 提交序列 c4d4eff→a5ad988→c2bdd4f→a2966d2→23c3528→0cd731f→c7c300e 与 Task 1→7 一一对应 | 未违例 |
| 12 | （01-PLAN 继承 6 条） | 见 #1-#6 | 未违例 |

注：feed.xml 相对 7cac7e4 无改动（plan-01 的 Latest 回退在该基线之前已入库），符合 02-PLAN「不动 feed.xml」声明。

## 4. Behavioral Spot-Checks（验证者 2026-08-18 实测）

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| 全新构建绿 | `bundle exec jekyll build` | exit 0，0.218s，无 Unknown tag/liquid error | ✓ PASS |
| G-1-3 全站清零 | `grep -rl '&lt;div' _site --include='*.html'` | 0 文件（基线 about=3/team=23） | ✓ PASS |
| 16-URL serve 循环 | curl + marker 断言 | 13 marker 命中 + 2 superseded（页面均 200，新 marker/标题正确） | ✓ PASS |
| 出版物三标记 | grep on _site/publications | 1/1/3 | ✓ PASS |
| YAML 数据健康 | `YAML.load_file` ×3 | YAML_OK；news 长度 6 | ✓ PASS |
| serve 生命周期 | 起停全流程 | 6 gap 页 200+marker；停止后 4000/35729 无监听 | ✓ PASS |
| git 卫生 | status/ls-files/check-ignore | porcelain=0；13 页跟踪；_site ignored | ✓ PASS |

## 5. Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| ENV-01 | 01-PLAN + 02-PLAN | bundle install + jekyll serve + live reload，本地预览全链路 | ✓ SATISFIED | §2 T1-T4、T9-T11；UAT 测试 1（live reload）；ROADMAP 判据 1/4 成立 |
| ENV-02 | 01-PLAN + 02-PLAN | 全页面正常渲染，出版物非空，scholar 正常解析 papers/ref.bib，无静默失败 | ✓ SATISFIED | §2 T5-T7；§1 GC2-GC9；ROADMAP 判据 2（机器部分）/3 成立；判据 2 的「布局正常」→ 人工项 D5 |

REQUIREMENTS.md 追溯表将 ENV-01/ENV-02 映射 Phase 1，均被两个 PLAN frontmatter `requirements: [ENV-01, ENV-02]` 声明并闭环；**无缺失 ID、无孤儿 requirement**（CONTENT-01/DEPLOY-01/DEPLOY-02 属 Phase 2/3，不在本阶段）。

## 6. Anti-Patterns / 评审发现

| 来源 | 发现 | Severity | 处置 |
| --- | --- | --- | --- |
| 01-REVIEW.md CR-01 | about 页 2 处 PDLLMs 链接指向不存在仓库（验证者独立复核：`git ls-remote …/PDLLMs` 失败，`…/Plant_DNA_LLMs` 存在 HEAD a4bf59e） | ⚠️ Warning（人工决策） | **参考站自身同样链接该死链**（ref-about.html 2 处 `github.com/zhangtaolab/PDLLMs`），且 02-PLAN Task 2 目标内容逐字规定此 URL —— 执行者忠实对齐内容权威基准，未违任何 must_have/prohibition（GC6 的「与 ref-about.html 一致」反而要求保留）。属参考站继承缺陷，同类于 {title}/CDN 但未被计划列入排除清单。建议人工裁定：接受参考保真，或以 override/小修复改指 Plant_DNA_LLMs（其余页面 home/research/software 均用正确仓库） |
| 01-REVIEW.md WR-01..06 | feed 无 guid、转义 HTML、dark_mode default 逻辑、sitemap 排除、教育数据双源、vendor 未排除 | ℹ️ Info | 均不推翻本阶段 must_haves（feed/dark_mode/sitemap 为既有或超范围，多数属 Phase 2 部署卫生） |
| 01-REVIEW.md IN-01..09 | target=_blank 无 noopener、JSON-LD 转义、papers/ 发布进产物等 | ℹ️ Info | 超阶段范围，记录备查 |
| 本验证债务标记扫描 | 修改的 10 文件 TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER | — | 0 命中 |

## 7. 裁定与说明

**裁定 1（plan-01 T5 marker 集被 02-PLAN 有意取代，非回归）：** plan-01 断言 /research/ 含 "Research Areas"、/software/ 含 "Software &amp; Tools"（写于内容对齐之前）。02-PLAN Task 5/6 按参考站将两页标题改为 `<h1 class="page-title">Research</h1>`/`Software`（与 ref-*.html 逐字一致，浏览器标题正确）。两页实测均 200 且新标题/marker 全中。阶段目标（全页面可预览）不受影响，判 **PASS（后续计划合法取代）**，无需 override（同一 phase 内新计划覆盖旧断言属正常演进，已留档）。

**裁定 2（G-1-3 免疫模式从「markdown="0" 包装」升级为「列 0 平铺」）：** UAT gap 登记的修复建议是加 markdown="0"；02-PLAN 实际采用列 0 平铺 + 必要处 markdown="0"，且以可断言的 `grep -En '^ {4,}.*<'` = 0 落地。功能等价且更严格，判闭合。

**MVP 工具缝隙：** `user-story.validate` 对中文用户故事恒 false（英文正则），见 §0 说明。信息级，建议后续为 verb 补语言等价判定。

## 8. Human Verification Required（1 项）

### 1. 重写页面视觉保真（D5，G-1-4 的像素级收尾）

**Test:** `bundle exec jekyll serve` 后浏览器打开 `/`、`/about/`、`/team/`、`/research/`、`/software/`、`/news/`，与参考站 https://wmsd5fpo6kcfi.ok.kimi.link/ 对应页并排目检（重点：team 页渐变图标占位与 4 列校友表、about 页绿色渐变 PI 占位框与 Grants 卡、home hero/chips/banner、research/software 卡片栅格）。
**Expected:** 布局、样式加载、图片/占位呈现与参考站一致，无错乱、无裸 HTML 观感。
**Why human:** grep marker 与 200 断言只证内容存在与可达，不证视觉等价；2026-08-17 的 UAT 目检通过对象是重写前的旧页面。02-SUMMARY coverage D5 已标 `human_judgment: true`。

（可选一并裁定：CR-01 死链 — 接受参考保真还是改指 Plant_DNA_LLMs。）

## 9. 结论

Phase 1 目标「维护者能在本地预览网站全部内容（含出版物列表）」在机器可查范围内**完整达成且经 gap closure 后无回归**：G-1-3 全站清零、G-1-4 六页内容/数据与参考快照逐字对齐（顺序、en-dash、反向断言全过）、publications 83 条未动、构建/serve/16-URL/live reload 链路全绿、git 干净。整体状态 **human_needed**：待 D5（重写页面视觉保真，附 CR-01 死链裁定建议）人工确认后即可记 passed；若人工项失败则升级 gaps_found。

---
*Verified: 2026-08-18T01:16:00Z by gsd-verifier（独立重测：fresh build、自起自停 serve、16-URL 循环、全量 grep 正/反向断言、git diff/log、git ls-remote 外链复核 —— 全部新证据，未采信 SUMMARY 声明）*
