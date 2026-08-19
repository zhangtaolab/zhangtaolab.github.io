---
phase: 02-auto-deploy
plan: "01"
subsystem: infra
tags: [jekyll, sitemap, rss, liquid, dark-mode, vendor-exclude, pre-deploy-fixes]

# Dependency graph
requires:
  - phase: 01-local-green
    provides: "绿色本地 production 构建基线（Ruby 4.0.6 + Jekyll 4.4.1 锁定组合）与 Phase 1 代码评审遗留清单（D-10~D-14 五项）"
provides:
  - "D-10: _config.yml exclude 增 vendor 条目 + .gitignore vendor/（防御层）"
  - "D-11: sitemap.xml 3→11 URL 全量化（8 页翻出黑名单），Plan 02 冒烟断言 ≥10 的基线"
  - "D-12: head.html dark_mode 显式 false 判断（Liquid 4 兼容形态）"
  - "D-13: /allnews.html 重复页删除，新闻收敛为 /news/ 单页"
  - "D-14: feed.xml news 条目唯一 guid（isPermaLink=false）+ 条目 link 改指 /news/"
affects: [02-02-deploy-workflow, 02-04-push-main, phase-2-verification]

# Actuals (#2632) — pairs with the plan's estimate (30000 tokens, confidence: low)
actuals:
  tokens: 959        # chars/4 over the realized diff (3836 chars across 3 task commits)
  tasks: 3
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Liquid 4 兼容的显式布尔判断：{% if x == false %}false{% else %}true{% endif %} 替代 default 过滤器（default 不判 false，allow_false 参数系 Liquid 5.4+ 专属）"
    - "sitemap 断言阈值化（-ge 10），精确数只记录不硬断言（内容页数将来会变）"

key-files:
  created: []
  modified:
    - _config.yml
    - .gitignore
    - _includes/head.html
    - feed.xml
    - _pages/home.md
    - _pages/about.md
    - _pages/publications.md
    - _pages/news.md
    - _pages/contact.md
    - _pages/blogs.md
    - _pages/teaching.md
    - _pages/talks.md
  deleted:
    - _pages/allnews.md

key-decisions:
  - "D-12 改用 Liquid 4 兼容的显式 {% if site.dark_mode == false %} 判断，放弃计划的 allow_false: true 语法（该参数 Liquid 5.4+ 才有，本仓 liquid-4.0.4 下构建直接 ArgumentError）"
  - "sitemap 实测精确值 11（8 翻转 + research/software/team 3 原有），与研究推导完全一致；断言面用 ≥10 阈值"

patterns-established:
  - "Pattern: 布尔开关渲染用显式 == false 判断，不用 default 过滤器（Liquid 4 语义下 default 对 false/nil/empty 一律回退）"

requirements-completed: [DEPLOY-01]

coverage:
  - id: D1
    description: "D-10 vendor 排除防御层（_config.yml exclude 条目 + .gitignore vendor/ 行）"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "grep -c '^  - vendor$' _config.yml = 1；grep -c '^vendor/$' .gitignore = 1；构建后 [ ! -d _site/vendor ]"
        status: pass
    human_judgment: false
  - id: D2
    description: "D-11 sitemap 全量化：8 内容页翻出黑名单，sitemap.xml 3→11 URL，404.md 保留排除"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "grep -c '<loc>' _site/sitemap.xml = 11（阈值 ≥10）；8 页 grep '^sitemap: false' 零命中；404.md 仍含该行"
        status: pass
    human_judgment: false
  - id: D3
    description: "D-12 dark_mode 显式 false 生效（Liquid 4 兼容实现）"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "override 构建（--config _config.yml,/tmp/dm-override.yml, dark_mode: false）产物含 'var darkMode = false;'；正常构建产物含 'var darkMode = true;'"
        status: pass
    human_judgment: false
  - id: D4
    description: "D-13/D-14 双新闻页收敛 + feed 条目唯一 guid 与 /news/ link"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "_site/allnews.html 不存在、_site/news/index.html 存在；xmllint --noout _site/feed.xml 通过；渲染后 6/6 guid 唯一；站源 allnews 引用清零"
        status: pass
    human_judgment: false

# Metrics
duration: 5min
completed: 2026-08-19
status: complete
---

# Phase 2 Plan 01: D-10~D-14 评审遗留随车修复 Summary

**五项 Phase 1 评审遗留全部落地：vendor 防御层、sitemap 3→11 URL、dark_mode 显式 false 语义（Liquid 4 兼容形态）、双新闻页收敛为 /news/、RSS 条目唯一 guid——production 构建全绿、工作树 clean，可被 Plan 04 推送**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-08-19T01:21:44Z
- **Completed:** 2026-08-19T01:28:00Z
- **Tasks:** 3/3
- **Files modified:** 12 modified + 1 deleted（_pages/allnews.md）

## Accomplishments

- **D-11 是本 Plan 的可观测主输出：sitemap.xml 从 3 URL 升至精确 11 URL**（home/about/publications/news/contact/blogs/teaching/talks 8 页翻出黑名单 + research/software/team 3 个原有），URL 全表与 D-11 决策逐一对齐；404.md 按决策保留排除。此基线直接供 Plan 02 ci-smoke.sh 的 `≥10` 断言消费
- **D-12 用 Liquid 4 兼容形态实现"显式判断 false"**：override 构建机器证明 `dark_mode: false` 渲染为 `var darkMode = false;`，正常配置渲染 `var darkMode = true;`，未设键回退 true（见 Deviations——计划原语法在本仓 liquid 版本下不可用）
- **D-13/D-14 feed 修复**：渲染产物 6/6 news 条目 guid 唯一（`news-{index}-{date}`，isPermaLink="false"），全部条目 link 指向 `/news/`；"Latest" 条目日期回退链路（既有逻辑）未被触碰且正常工作；`xmllint --noout` 通过
- **D-10 vendor 防御层**：_config.yml exclude 增 `vendor`、.gitignore `vendor/bundle`→`vendor/`；构建产物 `_site/vendor` 不存在（tripwire 式复核）。定性维持研究结论：Jekyll 4.4.1 DEFAULT_EXCLUDES 已默认排除，本项是零成本防御层而非阻断项
- 三任务各自 automated 验证全绿；收尾总检（production 构建 + sitemap 11 + xmllint + allnews 缺席 + vendor 防御在位）全绿；**工作树 clean**（Plan 04 push 的前置成立）

## Task Commits

Each task was committed atomically:

1. **Task 1: D-10 vendor 排除防御层 + D-12 dark_mode 显式 false 修复** - `523d1ac` (fix)
2. **Task 2: D-11 sitemap 全量化——8 页翻出黑名单** - `1d01543` (fix)
3. **Task 3: D-13 删除 allnews 重复页 + D-14 feed 条目 guid/link 修复** - `823ffac` (fix)

**Plan metadata:** 见下方最终 docs 提交

## Files Created/Modified

- `_config.yml` - exclude 列表追加 `- vendor`（D-10 防御层）
- `.gitignore` - `vendor/bundle` 收宽为 `vendor/`（D-10）
- `_includes/head.html` - 第 44 行改为 `{% if site.dark_mode == false %}false{% else %}true{% endif %}`（D-12，Liquid 4 兼容）
- `feed.xml` - news 条目 link 改 `/news/` + 新增 `<guid isPermaLink="false">news-{forloop.index}-{date}</guid>`（D-13/D-14）
- `_pages/{home,about,publications,news,contact,blogs,teaching,talks}.md` - 各删 frontmatter `sitemap: false` 一行（D-11）
- `_pages/allnews.md` - 整文件删除（D-13；与 news.md 正文 100% 重复，是评审④根因）

## Decisions Made

- **D-12 实现形态改判（执行期）：** 计划与 must_hives 写定的 `default: true, allow_false: true` 语法在锁定栈（Jekyll 4.4.1 → liquid ~> 4.0 → 实装 liquid-4.0.4）下直接构建失败——`default` 过滤器签名只收 1..2 参数（`allow_false` 是 Liquid 5.4+ 新增）。改用 CONTEXT D-12 决策原文本身就规定的"显式判断 false"形态 `{% if site.dark_mode == false %}`，语义完全等价且在所有取值下都产出合法 JS 字面量。升级 Liquid 到 5.x 不可行（Jekyll 4.4.1 依赖钉 `~> 4.0`，升 Liquid 需升 Jekyll 主版本，违反技术栈锁定约束）
- **sitemap 精确值记录为 11**（非断言值）：断言面维持 `-ge 10` 阈值（per RESEARCH Pitfall 5，内容页数将来会变，精确断言会脆断）
- **Task 3 验证前整删 `_site` 重建**：排除旧构建残留 `_site/allnews.html` 掩蔽"文件已删"假阴性的可能

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Task 1 验证断言的缩进失配**
- **Found during:** Task 1 验证步骤
- **Issue:** 计划 verify 写 `grep -c '^- vendor$'`（行首无缩进），但 `_config.yml` 的 exclude 列表全部条目都是 2 空格缩进（`  - Gemfile` … `  - docs`），按计划字面执行恒为 0，会把正确改动误判为失败
- **Fix:** 断言改为 `grep -c '^  - vendor$'`（匹配文件真实缩进风格）；代码改动本身与计划意图完全一致，未改文件格式去迁就断言
- **Files modified:** 无（仅验证命令调整）
- **Verification:** `grep -c '^  - vendor$' _config.yml` = 1 通过
- **Committed in:** 无需提交（验证命令修正，不产生 diff）

**2. [Rule 1 - Bug] D-12 计划语法 allow_false: true 与锁定 Liquid 版本不兼容**
- **Found during:** Task 1 首次 production 构建
- **Issue:** `{{ site.dark_mode | default: true, allow_false: true }}` 触发 `Liquid::ArgumentError: wrong number of arguments (given 3, expected 1..2)`——`allow_false` 参数 Liquid 5.4.0（2022-11）才引入，本仓 Jekyll 4.4.1 依赖钉 `liquid ~> 4.0`，实装 liquid-4.0.4。RESEARCH 引用的 Shopify 文档描述的是 Liquid 5 现行语义，未覆盖版本可用性。计划的 must_hives artifact 字面检查（`contains: "allow_false: true"`）因此**有意不满足**，但对应 truth（"head.html renders dark_mode: false as false"）以更强形式满足（双侧构建机器证明）
- **Fix:** 按 CONTEXT D-12 决策原文"改为显式判断 false"实现：`var darkMode = {% if site.dark_mode == false %}false{% else %}true{% endif %};`。取值矩阵：`false`→false（目标语义）、`true`/未设/空串→true（保留原 default 回退行为）；任何取值都输出合法 JS 字面量（原 filter 形态在空串取值下会渲染出 JS 语法错误的 `var darkMode = ;`）
- **Files modified:** `_includes/head.html`
- **Verification:** 正常构建产物含 `var darkMode = true;`；临时 override 构建（`--config _config.yml,/tmp/dm-override.yml` 且 `dark_mode: false`，产物落 /tmp 后已清理）含 `var darkMode = false;`；production 构建退出码 0
- **Committed in:** `523d1ac`（Task 1 commit）

---

**Total deviations:** 2 auto-fixed（1 Rule 3 blocking 验证命令、1 Rule 1 bug 计划语法与锁定栈不兼容）
**Impact on plan:** 两项均为必要修正，无范围蔓延。Deviation 2 使 must_hives 的一个字面 artifact 检查（`allow_false: true` 字符串）不可满足，但以机器证明的等价实现替代——后续 verifier/audit 检查该项时应以本节说明为准（truth 层面全绿）

## Issues Encountered

- Task 1 首次构建失败（Liquid ArgumentError，见 Deviation 2）——由计划语法与锁定依赖版本不兼容引起，非环境问题；修复后全绿。除此之外三任务均按计划一次通过
- 已知无害告警（assets/main.css 与 main.scss 输出目标冲突、静态快照胜出）在三次构建中如预期出现，未当作失败（per 计划 acceptance_criteria 注记）

## Known Stubs

None — 全部改动为真实实现，无占位符/TODO/空数据面。

## User Setup Required

None — 本 Plan 无外部服务配置。

## Next Phase Readiness

- **Plan 02（deploy.yml + ci-smoke.sh）就绪**：其断言三件套的基线已由本 Plan 落定——sitemap 11 URL（断言 `≥10`）、`xmllint --noout _site/feed.xml` 通过、publications 锚点未受影响（`s41467-026-73769-8` 仍在页面第 1 条）；vendor tripwire 断言对象 `_site/vendor` 确认不存在
- **Plan 04（push main）前置成立**：工作树 clean、三个任务提交全部入库
- **遗留提示给后续 wave**：D-12 的 Liquid 版本教训已入 STATE 决策（`allow_false` 系 Liquid 5.4+）；任何未来模板维护者想"升级回 filter 写法"需先升 Liquid/Jekyll 主版本，受技术栈锁定约束
- 无阻塞、无 blocker

## Self-Check: PASSED

All key files present (SUMMARY.md, 5 modified sources, news.md twin), `_pages/allnews.md` confirmed deleted, all 3 task commits (523d1ac / 1d01543 / 823ffac) found in git log.

---
*Phase: 02-auto-deploy*
*Completed: 2026-08-19*
