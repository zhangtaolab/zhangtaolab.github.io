---
phase: 01-local-dev-environment
plan: 01
subsystem: infra
tags: [jekyll, bundler, ruby, jekyll-scholar, jekyll-sitemap, livereload, local-dev]

# Dependency graph
requires: []
provides:
  - 可复现的本地开发环境（bundle install → jekyll serve --livereload 全链路绿色）
  - Gemfile.lock 锁定依赖事实源（jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0）
  - .ruby-version（4.0.6）作为 Phase 2 CI Ruby 对齐事实源
  - 站点源码全部入库（460 文件）+ .gitignore 构建产物隔离
  - jekyll-scholar 文献链路对齐 papers/ref.bib（12 条实测解析）
affects: [02-auto-deploy, 03-content-validation]

# Actuals (#2632) — pairs with the plan's `estimate` to calibrate future estimates.
# Same estimateTokens scale (chars/4 over the realized diff), never a harness token count.
actuals:
  tokens: 443731
  tasks: 4
  commits: 5

# Tech tracking
tech-stack:
  added: []  # 无新增 gem（jekyll 4.3.3 → 4.4.1 为既有依赖升级）
  patterns:
    - "Gemfile :jekyll_plugins group 承载 jekyll-scholar/jekyll-sitemap（插件加载的唯一正确位置）"
    - ".ruby-version 与 bundle exec ruby 实测输出对齐作为 CI 事实源"
    - "jekyll-scholar 文献源经 _config.yml scholar.source: /papers/ 指向 papers/ref.bib"

key-files:
  created:
    - Gemfile.lock
    - .ruby-version
    - .gitignore
  modified:
    - Gemfile
    - _config.yml
    - feed.xml

key-decisions:
  - "版本阶梯生效 Step 0 → Step A：Task 1 以 Step 0（Jekyll 4.3.3）达成绿色构建后，用户指令要求采用较新版本，后置升级为 ~> 4.4.0（resolver 取 4.4.1）"
  - "jekyll-scholar/jekyll-sitemap 不钉版本（resolver-latest 即兼容），sass-embedded ~> 1.77.0 钉保留（未被迫放宽）"
  - "scholar.style: citesty → apa（磁盘无 citesty.csl，citeproc 解析失败的既定回退）"
  - "publications.md 保持手写 83 条列表（prohibition：不得以 12 条 bib 列表替换而静默丢失 71 条）"
  - "feed.xml 对展示性日期 'Latest' 回退 site.time（原文对不可解析日期直接过滤引发构建失败）"

patterns-established:
  - "Plugin group pattern: Jekyll 插件必须位于 Gemfile :jekyll_plugins group 才会被加载"
  - "Version fact-source pattern: .ruby-version 内容必须等于 bundle exec ruby -e 'puts RUBY_VERSION' 实测输出"

requirements-completed: [ENV-01, ENV-02]

# Coverage metadata (#1602) — one entry per shipped deliverable.
coverage:
  - id: D1
    description: "绿色构建链路：bundle install 退出 0 + Gemfile.lock 含 jekyll-scholar/jekyll-sitemap + jekyll build 退出 0 且无 Unknown tag 'bibliography'"
    requirement: ENV-01
    verification:
      - kind: other
        ref: "bundle install && bundle exec jekyll build (exit 0, post-bump re-run on jekyll 4.4.1)"
        status: pass
      - kind: other
        ref: "grep -c \"Unknown tag 'bibliography'\" build output = 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "文献链路对齐 papers/ref.bib：scholar.source=/papers/，assets/ref.bib 演示数据删除，探针 12/12 条渲染"
    requirement: ENV-02
    verification:
      - kind: other
        ref: "grep -n 'source: /papers/' _config.yml && test ! -f assets/ref.bib"
        status: pass
      - kind: other
        ref: "bibprobe 构建产物 12 个 class=\"pub-entry\" 含 Telomere-to-telomere（Task 2 探针实测，验证后删除）"
        status: pass
    human_judgment: false
  - id: D3
    description: "本地 serve 全页面渲染：16 个 URL 全部 200 且含各自标记文本；/publications/ 含 Telomere-to-telomere + The CentO satellite + Nature Communications（Jekyll 4.4.1 升级后重验）"
    requirement: ENV-01
    verification:
      - kind: other
        ref: "16-URL curl 断言循环（PASS=16 FAIL=0，含 /assets/main.css 161,960B > 1000B）"
        status: pass
    human_judgment: false
  - id: D4
    description: "Live reload 生效：编辑 _pages/home.md 后 ≤10 秒页面反映改动，还原后标记消失"
    requirement: ENV-01
    verification:
      - kind: other
        ref: "LIVERELOAD_PROBE 注入 → 0s 出现于 /（serve 日志 Regenerating）→ 还原后 0s 消失（Jekyll 4.4.1 下重验）"
        status: pass
      - kind: other
        ref: "livereload.js HTTP 200（Jekyll 4.4.1 改由专用 reload 服务器 127.0.0.1:35729 提供；计划原文的 4000 端口路径为 4.3.3 行为）"
        status: pass
    human_judgment: true
    rationale: "计划 must_haves 将「浏览器实际自动刷新（无需手动刷新）」声明为 backstop 人工确认项；机器探针已证再生链路，真实浏览器中的自动刷新行为需人工在浏览器中确认"
  - id: D5
    description: "站点源码首次入库：.gitignore 隔离构建产物，git status 干净，13 个 _pages 文件被跟踪"
    requirement: ENV-01
    verification:
      - kind: other
        ref: "git check-ignore _site && git status --porcelain 为空 && git ls-files _pages | wc -l = 13"
        status: pass
    human_judgment: false
  - id: D6
    description: "页面布局视觉正常（样式加载、图片显示、无裸 HTML 观感）"
    requirement: ENV-02
    verification:
      - kind: other
        ref: "/assets/main.css 返回 200 且 161,960 字节 > 1000 字节（机器可查部分）"
        status: pass
    human_judgment: true
    rationale: "计划 must_haves 明示整体视觉属人工确认项；机器只能断言 CSS 资源可达，视觉呈现需人工浏览器确认"

# Metrics
duration: 40min
completed: 2026-08-17
status: complete
---

# Phase 1 Plan 01: 本地开发环境 Summary

**Jekyll 4.4.1 + Ruby 4.0.6 下 bundle install/build/serve --livereload 全链路绿色，jekyll-scholar 对齐 papers/ref.bib，460 文件站点源码首次入库（465 文件变更，16 URL + 出版物 + live reload 端到端实测）**

## Performance

- **Duration:** ~40 min（原执行 19 min + 续接执行 ~20 min；中间因 API 配额中断存在间隙）
- **Started:** 2026-08-17T07:03Z（原执行 agent）
- **Completed:** 2026-08-17T09:15Z（续接 agent 完成收尾）
- **Tasks:** 4
- **Files modified:** 465（含 460 个站点源码文件首次入库）

## Accomplishments
- 本地开发环境全链路跑通：`bundle install` → `bundle exec jekyll build` → `bundle exec jekyll serve --livereload`（127.0.0.1:4000）全部退出码 0
- jekyll-scholar/jekyll-sitemap 移入 `:jekyll_plugins` group，文献源对齐真实 `papers/ref.bib`（探针实测 12/12 条渲染），Feynman 演示 bib（assets/ref.bib）清除
- 站点源码 460 文件首次入库，`.gitignore` 隔离 `_site/`、`.jekyll-cache/` 等构建产物，`git status --porcelain` 干净
- 16 URL × 标记文本全 PASS、/publications/ 三标记全 PASS、live reload 编辑探针 ≤10s 生效并在版本升级后重验
- 用户版本指令后置应用：Jekyll 4.3.3 → `~> 4.4.0`（4.4.1），渲染链路全量重验通过

## Task Commits

Each task was committed atomically:

1. **Task 1: Ruby/Jekyll 版本决策阶梯 + 绿色构建（tracer）** - `9e2dd4f` (fix)
2. **Task 2: 文献链路对齐 papers/ref.bib + 演示数据清除** - `adcf93a` (fix)
3. **Task 3: 本地 serve 全页面渲染 + live reload 端到端验证** - 无代码变更（纯验证任务，验证后 serve 进程停止；版本升级后由续接 agent 重验）
4. **Task 4: .gitignore + 站点源码首次入库** - `14c83c2` (feat, 460 文件)
5. **版本指令后置应用: Jekyll ~> 4.4.0 + 渲染链路重验** - `383b7fa` (fix)

**Plan metadata:** 本 SUMMARY 所在提交 (docs)

## Files Created/Modified
- `Gemfile` - jekyll-scholar/jekyll-sitemap 移入 :jekyll_plugins group；jekyll 钉 4.3.3 → `~> 4.4.0`
- `Gemfile.lock` - 新增；jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 / sass-embedded 1.77.8
- `.ruby-version` - 新增；4.0.6（与 `bundle exec ruby -e 'puts RUBY_VERSION'` 实测一致）
- `.gitignore` - 新增；_site/、.jekyll-cache/、.jekyll-metadata、.bundle/、vendor/bundle、.DS_Store
- `_config.yml` - scholar.source /assets/ → /papers/；scholar.style citesty → apa；删除 details_dir/details_layout/details_link 死配置三键
- `feed.xml` - "Latest" 展示性日期回退 site.time（修复构建失败）
- `papers/ref.bib`、`_data/`、`_includes/`、`_layouts/`、`_pages/`（13 页）、`_sass/`、`assets/`、`images/`、`favicon.*`、`robots.txt` - 站点源码首次入库（Task 4）
- `assets/ref.bib` - 删除（Feynman 模板演示数据，避免随静态发布上线）

## Decisions Made
- **版本阶梯 Step 0 → Step A：** Task 1 按计划以 Step 0（Jekyll 4.3.3）达成绿色构建并提交；用户随后指令（2026-08-17：「根据Github 的要求，建议使用新版本的软件和软件包」）到达时 Task 1 已提交，故以后置独立提交应用 Step A（`~> 4.4.0` → 4.4.1）。resolver 无冲突，jekyll-scholar/jekyll-sitemap 维持 unpinned-latest，sass-embedded `~> 1.77.0` 钉无需放宽
- **Step B（brew ruby@3.4）未动用：** Step A 成功，且系统级变更按计划必须先征得用户同意
- **`.ruby-version` 内容以实测为准：** 升级后复测 `bundle exec ruby -e 'puts RUBY_VERSION'` 仍为 4.0.6，文件无需变更
- **publications.md 保持手写 83 条：** papers/ref.bib 仅 12 条，替换将静默丢失 71 条（prohibition 5）；scholar 链路以 source 对齐 + 探针渲染单独证明

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] feed.xml 展示性日期 "Latest" 引发构建失败**
- **Found during:** Task 1（绿色构建尝试）
- **Issue:** `feed.xml` 对 `_data/news.yml` 不可解析的展示性日期标签 "Latest" 直接过滤，导致构建失败
- **Fix:** `{% if article_date == "Latest" %}{% assign article_date = site.time %}{% endif %}` 回退
- **Files modified:** feed.xml
- **Verification:** `bundle exec jekyll build` 退出码 0；/feed.xml 返回 200 且含 `<rss`
- **Committed in:** feed.xml 在 Task 4 入库提交 `14c83c2` 中首次进入 git（编辑发生于 Task 1，文件当时未跟踪）

**2. [Rule 2 - Missing Critical] jekyll-scholar/jekyll-sitemap 未被加载（插件组缺失）**
- **Found during:** Task 1（计划预判的必然失败点，实测复现）
- **Issue:** 两插件位于 Gemfile 顶层而非 `:jekyll_plugins` group，`{% bibliography %}` 报 Unknown tag 构建失败
- **Fix:** 移入 `group :jekyll_plugins do ... end` 块
- **Files modified:** Gemfile
- **Verification:** 构建退出 0 且输出无 Unknown tag；talks/allnews 相关页面 200
- **Committed in:** `9e2dd4f`（Task 1 提交，计划行动项 1 的既定内容）

**3. [Rule 1 - User Directive] 版本指令后置应用：Jekyll ~> 4.4.0（Step A）**
- **Found during:** 收尾阶段（指令于 Task 1 提交后到达，原执行 agent 被配额中断前未及应用）
- **Issue:** 计划执行时保留 jekyll 4.3.3（Step 0），与用户新指令「采用较新版本」不符
- **Fix:** Gemfile `gem "jekyll", "4.3.3"` → `~> 4.4.0`，bundle install（resolver 取 4.4.1），全渲染链路重验（16 URL、出版物标记、livereload、.ruby-version 一致性）
- **Files modified:** Gemfile, Gemfile.lock
- **Verification:** install/build 退出 0；16/16 URL PASS；livereload 探针 0s 生效；`.ruby-version` = 实测 4.0.6
- **Committed in:** `383b7fa`

**4. [Rule 3 - Interruption] 原执行 agent 被 API 配额中断，收尾由续接 agent 完成**
- **Found during:** 收尾阶段（原 agent 报告 "Full phase verification: ALL PASS. Computing close-out metrics" 后被杀）
- **Issue:** SUMMARY.md 缺失、tracking 提交未完成、版本指令未应用 — 处于 execute-plan 协议定义的非法半完成态
- **Fix:** 续接 agent 应用版本指令 + 渲染链路重验 + 补写 SUMMARY + 完成 tracking 提交，恢复原子收尾不变量
- **Files modified:** .planning/phases/01-local-dev-environment/01-SUMMARY.md, .planning/ROADMAP.md, .planning/STATE.md
- **Verification:** `git status --porcelain` 为空；SUMMARY 与 tracking 同一提交落地
- **Committed in:** 本 SUMMARY 所在提交

---

**Total deviations:** 4 auto-fixed（1 blocking 构建失败、1 计划预判的插件缺口、1 用户指令后置应用、1 执行中断恢复）
**Impact on plan:** 全部为达成绿色构建与满足用户指令所必需；无范围蔓延。版本升级后已按计划验收标准全量重验。

## Issues Encountered
- **Jekyll 4.4 行为变化：livereload.js 端点迁移** — 4.3.3 经主服务 4000 端口提供 `/livereload.js`；4.4.1 改由专用 reload 服务器在 `127.0.0.1:35729` 提供（页面注入的 document.write loader 自动指向 35729，两端口均仅绑回环）。计划原文的 `http://127.0.0.1:4000/livereload.js` 断言在 4.4.1 下为 404，等价断言 `http://127.0.0.1:35729/livereload.js` 为 200（真实 livereload 客户端 JS），功能探针通过
- **已知空态（计划内记录）：** papers/ref.bib 无 @incollection 条目，/talks/ 两个查询渲染为空列表（页面 200、标题在）；`_pages/teaching.md` 仍含模板演示教学条目 — 属内容补全工作，不在本阶段
- **已知无害告警：** `assets/main.css` 与 `assets/main.scss` 输出目标冲突（静态快照 161,960 字节胜出，>1000 字节，满足验收）
- **API 配额中断：** 原执行 agent 在收尾计算阶段被杀（4 任务均已提交，验证均 PASS）；续接 agent 完成剩余收尾，无工作丢失

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Phase 2（自动部署）可直接开工：Gemfile.lock（jekyll 4.4.1 组合）与 .ruby-version（4.0.6）是 CI 对齐的事实源；jekyll-scholar 要求 GitHub Actions 完整 Ruby 构建（Pages 原生构建不可用）这一约束已在 STATE.md 记录
- Phase 2 CI 需注意：Ruby 4.0.6 超出 Jekyll 官方支持范围，属"实测可用"——CI 应复现本机组合而非假设官方支持矩阵
- 无阻塞项

---
*Phase: 01-local-dev-environment*
*Completed: 2026-08-17*
