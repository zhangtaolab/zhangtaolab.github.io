---
phase: 02-auto-deploy
plan: "03"
subsystem: content-integrity
tags: [jekyll, publications, migration-audit, d-18, deploy-gate, nokogiri-free-extraction]

# Dependency graph
requires:
  - phase: 02-auto-deploy (02-01 评审遗留修复)
    provides: 干净的本地生产构建基线（sitemap/dark_mode/双新闻页修复后），本 Plan 的双侧提取在其上运行
provides:
  - 旧站 https://zhangtaolab.org/Publication 的 byte 存档（old-site-publication.html——热切换后唯一本地参照）
  - 双侧规范化条目清单（pub-extract-new.txt 89 条 / pub-extract-old.txt 89 条 + 嵌套子条目清单）
  - 逐条核对报告 02-PUBLICATION-AUDIT.md（MATCHED/MISSING/EXTRA 全分类 + 轮次轨迹）
  - 批准标记行 `Verdict: APPROVED 2026-08-19`（Plan 05 首次上线检查点前置 + Plan 06 删 master 前置的机器断言对象，grep -F 文件级检索）
  - D-16 首次设 DEPLOY_ENABLED 的前置条件（D-18 核对通过）已满足
affects: [02-05 (首次上线), 02-06 (删 master + 分支清理), DEPLOY-01]

# Actuals (#2632) — plan estimate was 40000 tokens / 3 tasks / confidence low
actuals:
  tokens: 61670   # chars/4 over the realized per-commit diffs (246,679 chars across 5 commits)
  tasks: 3        # Task 1, Task 2, Task 3 checkpoint (executed as 3a remedy backfill + 3b round 2 + approval marker)
  commits: 6      # 5 execution commits + 1 plan-closure docs commit

# Tech tracking
tech-stack:
  added: []       # 无新增依赖——提取/比对用 Ruby 标准库一次性脚本（pub-extract.rb / pub-compare.rb）
  patterns:
    - "远端变动前抢收参照物（byte 存档 + 入库），热切换后参照物消失则审计不可能"
    - "双侧同一脚本同一规范化规则（去标签/实体解码/小写/去非字母数字/压空白），年份桶内 1:1 消耗制匹配"
    - "NFKC 兼容折叠兜底匹配（旧站连字 ﬁ U+FB01 等排版差异），模糊判定必须列理由"
    - "闸门标记字面量拆分书写护栏：报告正文绝不出现批准标记完整字面量，杜绝 grep 假阳性通过"

key-files:
  created:
    - .planning/phases/02-auto-deploy/old-site-publication.html
    - .planning/phases/02-auto-deploy/pub-extract.rb
    - .planning/phases/02-auto-deploy/pub-extract-new.txt
    - .planning/phases/02-auto-deploy/pub-extract-old.txt
    - .planning/phases/02-auto-deploy/pub-extract-new-subentries.txt
    - .planning/phases/02-auto-deploy/pub-extract-old-subentries.txt
    - .planning/phases/02-auto-deploy/pub-compare.rb
    - .planning/phases/02-auto-deploy/compare-result.txt
    - .planning/phases/02-auto-deploy/02-PUBLICATION-AUDIT.md
  modified:
    - _pages/publications.md

key-decisions:
  - "Round 1 BLOCK（6 MISSING）→ 用户在检查点选 remedy (a) 全量补录，无豁免；6 条按旧站存档逐字补入并全列表重编号 1-89"
  - "2024 Zheng XL 连字条目按 NFKC 折叠匹配（ﬁ→fi + knockoutstrategy 缺空格），用户批准接受"
  - "2013 PNAS CentO 第三方评述系嵌套注记非顶层出版物条目，用户决定接受不迁移（父条目已 MATCHED）"
  - "研究期 ~91 计数对账为 89 顶层 + 2 嵌套子条目，机器提取为准"
  - "DEPLOY-01 本轮不 mark-complete：阶段级需求，线上锚点证明留给 02-05/02-06（沿 02-P01 既定决策）"

patterns-established:
  - "Pattern: 阻断闸门标记只由 executor 在用户批准后追加，且报告正文对标记字面量拆分书写（防闸门污染）"

requirements-completed: []   # DEPLOY-01 为阶段级需求，逐条审计是其证据的一半；线上锚点证明在 02-05/06，届时再 mark-complete

# Coverage metadata (#1602)
coverage:
  - id: D1
    description: "旧站 /Publication byte 存档 + 双侧规范化条目清单（新 89 / 旧 89，年份桶 19=19 对齐）"
    requirement: DEPLOY-01
    verification:
      - kind: other
        ref: "02-03-PLAN Task 1 <automated> 链（存档非空含年份标题；清单行数 new=89 old=89 ≥80；年份桶集合相等）→ TASK1-PASS"
        status: pass
    human_judgment: false
  - id: D2
    description: "逐条核对报告：旧侧 89 条每条一行 MATCHED/MISSING 状态 + EXTRA 表 + verdict（第 2 轮 89/89 全 MATCHED，MISSING=0 EXTRA=0）"
    requirement: DEPLOY-01
    verification:
      - kind: other
        ref: "02-03-PLAN Task 2 <automated> 链（状态行数 ≥ 旧侧清单行数；含 EXTRA 与 verdict 字段）→ TASK2-PASS"
        status: pass
    human_judgment: false
  - id: D3
    description: "D-18 审计用户批准落盘：02-PUBLICATION-AUDIT.md 末尾批准标记行（Verdict: APPROVED 2026-08-19 + approval scope 注记行）"
    requirement: DEPLOY-01
    verification:
      - kind: other
        ref: "grep -cF 'Verdict: APPROVED' .planning/phases/02-auto-deploy/02-PUBLICATION-AUDIT.md == 1（commit 650bd3e）"
        status: pass
    human_judgment: true
    rationale: "D-18 规定核对通过与否必须由用户在阻断检查点人工裁决（2026-08-19 用户回复 approved）；机器只可核对标记存在性，不可代替裁决本身。"

# Metrics
duration: 70min（两段：09:4x–10:40 +0800 主体执行；11:16–11:25 +0800 批准落盘续跑）
completed: 2026-08-19
status: complete
---

# Phase 02 Plan 03: D-18 出版物逐条核对 Summary

**89 vs 89 逐条出版物审计闭环：第 1 轮 BLOCK（缺 6 条）→ 用户裁决 remedy (a) 逐字补录 → 第 2 轮全对齐（88 精确 + 1 NFKC 连字）→ 用户批准，`Verdict: APPROVED 2026-08-19` 标记行入库——D-16 首次上线闸门的前置条件自此满足**

## Performance

- **Duration:** ~70 min active（2026-08-19 09:4x–10:40 +0800 主体执行 + 11:16–11:25 +0800 批准落盘续跑；中间为检查点等待用户裁决）
- **Started:** 2026-08-19 ~01:45Z
- **Completed:** 2026-08-19T03:19:09Z（标记落盘 + 本 SUMMARY）
- **Tasks:** 3（Task 1 存档/提取、Task 2 逐条比对报告、Task 3 阻断检查点——实际展开为 3a 补录 + 3b 复跑 + 批准标记落盘）
- **Files modified:** 11（10 创建 + 1 修改）+ 本 SUMMARY

## Accomplishments

- **抢收参照物**：旧站 `https://zhangtaolab.org/Publication` byte 存档入库（766 行 HTML，HTTP 200 前置检查通过，热切换后此文件是唯一回滚参照）
- **双侧机器提取**：同一脚本同一规范化规则（年份桶分桶、深度感知 `<li>` 解析、实体解码/小写/去非字母数字），新侧（构建产物）与旧侧（存档）各得 89 条顶层条目清单 + 嵌套子条目单独归类不隐藏
- **第 1 轮审计 BLOCK**：83 vs 89，逐条状态表暴露 6 条 MISSING（2022×4 + 2013×2）、EXTRA 0——正是研究期 83 vs ~91 差额的定性结果
- **remedy (a) 补录**：6 条按旧站存档逐字补入 `_pages/publications.md`，年份桶内按旧站顺序插入、全列表重编号 1-89、作者标记按新站书写约定转写，citation 字段逐字未动
- **第 2 轮全对齐**：89 vs 89，MISSING=0、EXTRA=0；88 条 normalized-title 精确匹配 + 1 条 NFKC 连字折叠匹配（2024 Zheng XL，旧站 ﬁ 连字 + 缺空格），判定理由全量留档
- **用户批准落盘**：用户 2026-08-19 明确回复 approved，报告末尾追加 `Verdict: APPROVED 2026-08-19` 标记行 + approval scope 注记行，grep 计数恰为 1——Plan 05 检查点前置与 Plan 06 删 master 前置的机器断言自此可过

## Task Commits

Each task was committed atomically:

1. **Task 1: 抢收旧站参照物 + 双侧条目提取** - `a81b576` (feat)
2. **Task 2: 逐条比对 + 审计报告（round 1: BLOCK, 6 MISSING）** - `c3381fe` (feat)
3. **Task 3a: remedy (a) 补录 6 条** - `66a5adf` (fix)
4. **Task 3b: round 2 复跑（89 vs 89, conditional-PASS）** - `8f44ef6` (feat)
5. **Task 3 续: 用户批准标记落盘** - `650bd3e` (docs)

**Plan metadata:** 见最终 docs 提交（SUMMARY + STATE + ROADMAP）

## Files Created/Modified

- `.planning/phases/02-auto-deploy/old-site-publication.html` - 旧站 /Publication byte 存档（唯一回滚参照）
- `.planning/phases/02-auto-deploy/pub-extract.rb` - 双侧提取脚本（年份桶分桶 + 深度感知 li 解析 + 规范化）
- `.planning/phases/02-auto-deploy/pub-extract-new.txt` / `pub-extract-old.txt` - 双侧规范化清单（各 89 条，`YEAR | normalized-title | first-author | raw-title`）
- `.planning/phases/02-auto-deploy/pub-extract-new-subentries.txt` / `pub-extract-old-subentries.txt` - 嵌套子条目清单（旧侧 2 条 Commentary/Cover 注记）
- `.planning/phases/02-auto-deploy/pub-compare.rb` - 逐条比对脚本（1:1 消耗制 + NFKC 折兜底 + 报告生成器）
- `.planning/phases/02-auto-deploy/compare-result.txt` - 比对机输出（可复现凭证）
- `.planning/phases/02-auto-deploy/02-PUBLICATION-AUDIT.md` - 逐条核对报告（第 2 轮正文 + 第 1 轮轨迹⑦ + 批准标记行）
- `_pages/publications.md` - 6 条补录 + 全列表重编号（83 → 89）

## Decisions Made

- **Round 1 BLOCK 处置**：6 条 MISSING 全量补录（用户选 remedy (a)，零豁免）——补录以旧站存档为逐字事实源，citation 内容字段一字未动
- **NFKC 连字匹配接受**：2024 Zheng XL 条目旧站排版用 ﬁ 连字且 "knockoutstrategy" 缺空格，NFKC 折叠后双侧键一致 + 首作者/年份双确认，用户批准接受
- **2013 PNAS CentO 第三方评述不迁移**：嵌套注记（Heslop-Harrison & Schwarzacher 评论）非顶层出版物条目、父条目 #75 已 MATCHED，不属 D-18 阻断对象，用户决定接受不迁移（如需保留可作后续处置）
- **~91 计数对账**：91 = 89 顶层 + 2 嵌套子条目，fetch 摘要把嵌套 `<li>` 一并计入——以机器提取为准，无隐藏条目
- **DEPLOY-01 不在本轮 mark-complete**：本审计只证"构建产物不丢条目"一半，"线上不丢"由 02-05/06 锚点检查证明后再结（沿 02-P01 既定决策）

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 批准标记字面量闸门污染（split-write 护栏修复）**
- **Found during:** Task 3b（第 2 轮报告再生成时自查发现）
- **Issue:** 第 1 轮报告在"豁免选项"说明正文中完整引用了批准标记字面量——Plan 06 以 `grep -F 'Verdict: APPROVED' <审计文件>` 为删 master 前置断言，正文含完整字面量会使未批准状态下断言假阳性通过（闸门污染）
- **Fix:** 第 2 轮生成器（pub-compare.rb）对所有标记指涉改拆分书写（`Verdict` + `: APPROVED <date>`），报告内并留"字面量护栏"说明；标记行只允许 executor 在用户批准后追加
- **Files modified:** `pub-compare.rb`、`02-PUBLICATION-AUDIT.md`
- **Verification:** 批准前 `grep -cF 'Verdict: APPROVED' 02-PUBLICATION-AUDIT.md` = 0（round 2 落盘时实测）；批准追加后 = 1 且仅第 212 行（commit 650bd3e 前 ASSERT 实测）
- **Committed in:** `8f44ef6`（护栏）、`650bd3e`（标记行本身）

---

**Total deviations:** 1 auto-fixed (Rule 1 bug)
**Impact on plan:** 修复的是 D-18 闸门自身的完整性（防假阳性放行），非范围蔓延。检查点 remedy (a) 属计划内选项（Task 3 how-to-verify 明列），不计偏差。

## Issues Encountered

- 旧站 HTML 存在嵌套 `<ul>` 子条目结构（Commentary/Cover 注记），初版提取若不深度感知会把子条目当顶层条目误报——提取脚本改为顶层/嵌套分开归类，2 条子条目单独成清单并在报告⑥节处置
- 旧站标题含 Unicode 连字（ﬁ U+FB01）与缺空格排版缺陷，精确匹配漏 1 条——加 NFKC 兼容折叠从 raw title 重新取键的兜底层，判定理由留档供检查点抽查
- 研究期 ~91 与机器提取 89 的计数差异：见上"~91 计数对账"决策，差异已完全解释

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- **D-18 闸门条件已满足**：审计批准标记在库，Wave 3（02-04 原地接管 D-15①~④）的前置完整
- **DEPLOY_ENABLED 仍未设置**：按 D-16 双闸设计，闸门保持关闭直到 02-05 首次上线计划（本 Plan 不越权触碰）
- 02-05 检查点与 02-06 删 master 前置的机器断言（`grep -F 'Verdict: APPROVED' 02-PUBLICATION-AUDIT.md`）现在可过且可追溯（commit 650bd3e）
- 下一动作：执行 02-04-PLAN.md（原地接管：push main → 默认分支 → build_type=workflow → 验证模式回退）

## Self-Check: PASSED

- 9/9 key files present on disk（存档、双侧清单、脚本×2、机输出、审计报告、publications.md、本 SUMMARY）
- 5/5 execution commits present（a81b576 / c3381fe / 66a5adf / 8f44ef6 / 650bd3e）
- 批准标记完整性：`grep -cF 'Verdict: APPROVED' 02-PUBLICATION-AUDIT.md` = 1（恰为标记行，无污染）

---
*Phase: 02-auto-deploy*
*Completed: 2026-08-19*
