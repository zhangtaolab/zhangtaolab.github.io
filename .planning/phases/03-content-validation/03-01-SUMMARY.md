---
phase: 03-content-validation
plan: 01
subsystem: content-validation (本地内容验证工具)
tags: [ruby, psych, bibtex-ruby, yaml-validation, jekyll, chinese-errors, cli]

requires:
  - phase: 02-auto-deploy
    provides: deploy.yml CI 步骤链（Plan 02 的 CI 半边插入点）+ ci-smoke.sh 脚本范式
provides:
  - scripts/validate.rb 五层校验引擎（YAML 语法层 + YAML 结构层 + BibTeX 解析层 + 必填层 + 原始正则键唯一层）
  - scripts/validate.sh 本地一条命令入口（exec bundle exec ruby 透传，chmod +x）
  - 中文错误输出契约（文件 + 行/列、条目序号、引用键/字段名三类定位，D-07）
  - PASS/FAIL + exit 0/1 契约（PASS 行逐文件计数动态计算 + 键唯一标记）
affects: [03-content-validation (Plan 02: CI 步骤 + D-08 提醒 + CONTENT-01-f/g)]

actuals:
  tokens: 2226      # chars/4 over scripts/validate.rb + validate.sh (实际产出 8906 字符)
  tasks: 3
  commits: 4        # 1 前置清场 docs 提交 + 3 任务提交（metadata 提交另计）

tech-stack:
  added: []          # D-06 零新增依赖：psych 为 Ruby default gem，bibtex-ruby 6.2.0 已在 Gemfile.lock
  patterns:
    - errors 数组全收集非 fail-fast（语法坏单文件只短路自身，其余文件继续）
    - 分层校验栈：语法 → 结构 → 解析 → 必填 → 键唯一（每层各拦截一类实测静默失败）
    - 原始文本正则 tally 查重（解析器静默改名销毁键信息，原始文本是唯一真相源）
    - PASS 汇总行计数动态计算（禁止硬编码，维护者加条目自动更新）

key-files:
  created:
    - scripts/validate.rb
    - scripts/validate.sh
  modified: []

key-decisions:
  - "BibTeX 查重只在原始文本上做（scan(/@\\w+\\{([^,\\s]+)\\s*,/).tally）：bibtex-ruby 对重复键静默改名（实测 k,k,k→k,l,m），解析结果里不存在重复"
  - "validate.rb 单文件单 errors 数组承载五层全部错误，末尾统一输出——维护者修 N 个错不用跑 N 遍（Pattern 3）"
  - "截断条目解析后以空键空字段存活（lexer 只 WARN），键为空时输出定位线索文案而非悬空冒号（Rule 1 修正）"

patterns-established:
  - "内容验证双入口约定：本地 scripts/validate.sh；CI 由 deploy.yml 直接 bundle exec ruby scripts/validate.rb（CI 步骤 Plan 02 落地）"
  - "probe 纪律：cp 备份 → printf/perl 破坏 → 断言 exit 1 + 中文消息 → cp 恢复 → git status --porcelain 证洁（全程零副作用实证）"
  - "Psych.parse_file(...).to_ruby 为 YAML 唯一解析入口（与 Jekyll 数据读取同路，禁反序列化式加载）"

requirements-completed: []   # CONTENT-01 由 03-01+03-02 共同实现；shared-ID gate 判定 0/1 ready（03-02 的 CI 半边 + CONTENT-01-f/g 未落地），留待 03-02 结项时标记

coverage:
  - id: D1
    description: "scripts/validate.rb 五层校验引擎：YAML 语法（行列号中文转译）/ YAML 结构（逐文件 schema + 顶层列表判定 + role 枚举 + date 规则 + Latest 仅首条）/ BibTeX 解析（ParseError 补文件名中文建议）/ 必填（title/author/year）/ 键唯一（原始正则 tally）"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 1/2/3 automated verify（03-01-PLAN.md <verify> 命令逐字执行）: 基线 PASS exit 0 + YAML 语法 probe（news.yml 第 1 行第 9 列）+ BibTeX 缺逗号 probe + role/date/Latest/映射化四结构 probe + 缺 year/重复键/截断三 BibTeX probe，全部 exit 1 且中文消息命中"
        status: pass
      - kind: integration
        ref: "全套装三连绿: scripts/validate.sh && bundle exec jekyll build --destination /tmp/_site_v3 && scripts/ci-smoke.sh /tmp/_site_v3 → PASS: sitemap=11（验证脚本不破坏正常构建链）"
        status: pass
    human_judgment: false
  - id: D2
    description: "scripts/validate.sh 本地维护者入口（exec bundle exec ruby 透传，可执行位，与 ci-smoke.sh 同目录同范式）"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "全部 probe 与基线运行均经 scripts/validate.sh 发起（wrapper → bundle exec → validate.rb 端到端）；运行耗时 0.17-0.20s（<1s 真值成立）"
        status: pass
    human_judgment: false

duration: 10min
completed: 2026-08-20
status: complete
---

# Phase 3 Plan 01: 验证脚本主体（tracer + 结构 schema 层 + BibTeX 深层校验）Summary

**validate.rb 五层校验引擎 + validate.sh 一条命令本地入口：5 个 _data/*.yml 与 papers/ref.bib 全部错误一次收集、中文定位到文件/行列/条目/引用键，基线全绿 0.17s，probe 矩阵 CONTENT-01-a~e 全过。**

## Performance
- **Duration:** 10min（617s）
- **Started:** 2026-08-20T03:13:57Z
- **Completed:** 2026-08-20T03:24:14Z
- **Tasks:** 3/3（1 tracer + 2 expansion）
- **Files modified:** 2（scripts/validate.rb 新建、scripts/validate.sh 新建）

## Accomplishments
- **一条命令端到端可用**：`scripts/validate.sh` → `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`（exit 0，0.17-0.20s，计数全部动态计算）
- **YAML 两层**：语法层中文转译 psych 行列号（probe: `news.yml 第 1 行第 9 列：YAML 语法错误（did not find expected ',' or ']'）`）；结构层拦截 jekyll build 静默吞掉的形态——映射化（`顶层结构应为列表…当前是 Hash`）、role 拼错（列出合法值 pi | member | student）、date 非法格式（报错附合法格式示例）、Latest 非首条、必填字段缺失
- **BibTeX 三层**：解析层（缺逗号 probe → `papers/ref.bib 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— …`）；必填层（`papers/ref.bib probeyear：year 字段缺失`）；键唯一层在原始文本 tally（`引用键 dupkey 重复出现 2 次`——解析器静默改名的唯一可靠拦截）
- **截断条目双路径实证**：`@article{probetrunc, title={截断` 追加后 lexer 只 WARN、条目以空键空字段存活，必填层以 `（引用键无法识别——多为截断或未闭合条目）` 定位报出 3 个缺失字段
- **基线 0 新失败（Pitfall 6 守住）**：8/12 条 bib 条目无 doi 仍全绿（DOI 非必填实证）；educationshort 死字段不检查；全套件（validate + jekyll build + ci-smoke）三连绿

## Task Commits
1. **Task 1: 端到端 tracer — validate.rb 语法层 + validate.sh 入口** - `bd52be02` (tracer)
2. **Task 2: YAML 结构层 — 逐文件 schema + news date 规则（D-01/D-02）** - `0d0b6f72` (auto)
3. **Task 3: BibTeX 必填层 + 原始正则键唯一层（D-03）** - `d3c40a5e` (auto)

**Plan metadata:** 见本次 docs 提交（SUMMARY + STATE + ROADMAP）

## Files Created/Modified
- `scripts/validate.rb`（新建）——五层校验引擎：errors 数组收集、Psych.parse_file YAML 语法层、逐文件 schema 结构层（含 T-03-03 逐文件 rescue 兜底）、BibTeX.parse 解析层、必填层、原始正则键唯一层、PASS/FAIL 汇总
- `scripts/validate.sh`（新建，可执行）——exec bundle exec ruby 透传包装，中文头注释写明双入口约定

## Decisions Made
- BibTeX 查重只在原始文本正则 tally（RESEARCH Pitfall 2 实证：解析器对重复键静默改名，解析结果不可用于查重）——按计划执行，无新决策
- 截断条目空键消息补定位线索（见 Deviations #2）

## Deviations from Plan

**1. [Rule 3 - blocking] 前置清场：planning 工件未提交导致工作区非全净**
- **Found during:** Task 1 precondition 检查
- **Issue:** 前置条件要求 `git status --porcelain` 为空（破坏性 probe 须证洁），但 plan 阶段留下未提交的 03-PATTERNS.md / milestone.lock / STATE.md 修改 / research cache
- **Fix:** 按 02-PATTERNS.md 既有先例（`docs(02): add pattern map`）提交为一笔 docs 提交 `da1552cb`，树全净后再开始 Task 1
- **Files modified:** .planning/（4 个工件）
- **Verification:** 提交后 porcelain 全空；probe 期间全部 scoped porcelain 检查为空
- **Commit:** da1552cb

**2. [Rule 1 - message quality] 截断条目空键的悬空冒号**
- **Found during:** Task 3 trunc probe 输出检查
- **Issue:** lexer 级截断条目以空 bibtex_key 存活，按计划消息模板输出 `papers/ref.bib ：title 字段缺失`（键位悬空，丢定位线索，违背 D-07 精神）
- **Fix:** 键为空时替换为 `（引用键无法识别——多为截断或未闭合条目）`
- **Files modified:** scripts/validate.rb
- **Verification:** Task 3 verify 重跑 TASK3-PASS；grep 'papers/ref.bib' 命中不变
- **Commit:** d3c40a5e（随 Task 3 一并提交）

**Total deviations:** 2 auto-fixed（1×Rule 3，1×Rule 1）。**Impact:** 均为零范围扩张；probe 矩阵与基线全绿不受影响。

## Issues Encountered
None — 两处 deviation 均当场解决。bibtex-ruby 的 Logger 在解析失败时向 stderr 打一行原生 ERROR/WARN（gem 自带行为，不影响断言与退出码，未按计划外沉默处理）。

## Known Stubs
None — CI 步骤与 D-08 提醒属 Plan 02 既定范围（本计划 objective 明确「CI 由 Plan 02 落地」），非本计划遗留 stub。

## Threat Mitigations Landed (threat_model)
- **T-03-01 (mitigate)**: YAML 解析唯一入口 `Psych.parse_file(...).to_ruby`；Task 1 verify 断言含 Psych.parse_file 且无反序列化式加载入口（正/负双 grep 命中）
- **T-03-03 (mitigate)**: errors 数组全收集 + 逐文件 rescue 兜底 + 非 Hash 条目防崩分支；截断条目 probe 证明坏输入得到明确中文判定而非崩溃
- **T-03-05 (mitigate)**: 脚本零写路径（只 File.read / Psych.parse_file）；每个 probe 恢复后 `git status --porcelain _data papers` 为空证洁
- **T-03-SC**: 零包安装（D-06），无可审对象

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
**Ready for 03-02.** validate.rb 的 CLI 契约（PASS/FAIL 输出 + exit 码）与中文头注释已为 CI 复用就绪：deploy.yml build job 在 Setup Ruby 后、Build with Jekyll 前插 `bundle exec ruby scripts/validate.rb`（D-04）；D-08 提醒层（git show HEAD 对比，警告不阻断）与 CONTENT-01-f/g 待 03-02 落地。flagged_assumption 提示：CONTENT-01 的 edge-probe 为 unclassified，/gsd-verify-work 时需人工确认 probe 矩阵（a~e）覆盖充分。

## Self-Check: PASSED
- scripts/validate.rb FOUND；scripts/validate.sh FOUND（可执行位 -rwxr-xr-x）
- 提交 bd52be02 / 0d0b6f72 / d3c40a5e 全部在 git log 命中
- 最终基线复跑：`PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`（exit 0）；`git status --porcelain _data papers` 为空
