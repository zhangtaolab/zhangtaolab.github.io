---
phase: 03-content-validation
verified: 2026-08-20T04:10:48Z
status: gaps_found
score: 13/14 must-have truths verified (4 roadmap SC + 6 Plan-01 truths + 4 Plan-02 truths), 2 gaps
behavior_unverified: 0
overrides_applied: 0
requirements: [CONTENT-01]
prohibitions_reviewed: 3
gaps:
  - truth: "全部文件的全部错误一次运行收集报出（非 fail-fast）——YAML 侧（Plan-01 truth 6 / T-03-03 mitigation claim）"
    status: partial
    reason: >-
      空文件或被删除/改名的 _data/*.yml 使脚本在结构层①崩溃（Psych.parse_file 对空文件返回 false，false.to_ruby 抛 NoMethodError；缺文件抛 Errno::ENOENT——均未被仅捕获 Psych::SyntaxError 的 rescue 接住），整次运行中断、其余全部文件的错误与 FAIL 汇总永不输出（验证者沙箱实测复现：空 news.yml + 语法坏 grants.yml → grants 错误 0 条报出、无 FAIL 行，英文回溯 exit 1）。与 03-01-SUMMARY 声称的「T-03-03 mitigate：逐文件 rescue 兜底」在层①不成立——即 03-REVIEW.md CR-01（critical，实测确认）。CI 仍 fail-closed（崩溃 exit 1，内容不会静默上线），但本地维护者拿到的是英文回溯而非 D-07 中文定位，且丢失其余文件诊断。
    artifacts:
      - path: "scripts/validate.rb"
        issue: "层①（第 33-39 行）rescue 仅覆盖 Psych::SyntaxError；无 respond_to?(:to_ruby) 守卫、无 Errno::ENOENT / StandardError 兜底"
    missing:
      - "Psych.parse_file 返回值加 respond_to?(:to_ruby) 守卫（或改用 Psych.safe_load——顺带解决 WR-02 并使空文件返回 nil 走既有「顶层结构应为列表，当前是 NilClass」路径）"
      - "层① 追加 rescue Errno::ENOENT（报「文件不存在——请勿删除或改名数据文件」）与 rescue StandardError 兜底，任何单文件异常只进 errors 数组不中断运行"
  - truth: "全部文件的全部错误一次运行收集报出（非 fail-fast）——BibTeX 侧（Plan-01 truth 6 / T-03-03 mitigation claim）"
    status: partial
    reason: >-
      papers/ref.bib 含非 UTF-8 字节（如 GBK 保存——中文实验室常见事故）或文件缺失时，层③（BibTeX.parse / File.read，第 130-134 行）抛 ArgumentError / Errno::ENOENT，rescue 仅捕获 BibTeX::ParseError——脚本崩溃于汇总输出之前，连已收集的 YAML 错误也不再打印（验证者沙箱实测复现：GBK 字节注入 → BibTeX.parse invalid byte sequence；移走 ref.bib → Errno::ENOENT，均英文回溯、无 FAIL 汇总）。即 03-REVIEW.md CR-02（critical，实测确认）。同样 fail-closed 但违背中文报出/全收集契约。
    artifacts:
      - path: "scripts/validate.rb"
        issue: "层③（第 129-134 行）rescue 仅覆盖 BibTeX::ParseError；无 valid_encoding? 预检、无 Errno::ENOENT / StandardError 兜底"
    missing:
      - "File.read 后加 raw.valid_encoding? 预检，非 UTF-8 时报「含非 UTF-8 字节（多为编辑器以 GBK 等编码保存）——请以 UTF-8 重新保存」"
      - "层③ 追加 rescue Errno::ENOENT 与 rescue StandardError 兜底；单次读入 raw 复用于解析/键扫描/D-08 计数（顺带消除 IN-02 三次读盘）"
human_verification: # surfaced for endorsement; overall status remains gaps_found (higher precedence)
  - test: "背书 3 条 judgment 级 prohibitions 复核结论（P-03-1 脚本只读 / P-03-2 不得拦合法内容 / P-03-3 不触碰 publications.md）"
    expected: "人工确认或提出异议。验证者非权威结论：P-03-1 未违反（全代码仅 File.read/Psych.parse_file，零写路径，grep 无 File.write/FileUtils/重定向写）；P-03-2 未违反（基线 12 条含 8 条无 doi 全绿，wang2026maize 通过，BIB_REQUIRED 仅 title/author/year）；P-03-3 未违反（publications.md 仅出现在提醒文案与注释，无任何文件操作）"
    why_human: "judgment 级禁制最终裁定权属开发者（ADR-550 D4）；LLM-judge 结论为非权威"
  - test: "裁定 03-REVIEW.md WR-02（parse_file(...).to_ruby 实为反序列化路径，与注释声称相反；恶意 PR + 维护者本地跑 validate.sh = 对象注入面）与 WR-01（CWD 相对路径，子目录调用即崩）的处置"
    expected: "选择修复（Psych.safe_load + __dir__ 锚定，两项修复与 gap 1 的推荐修法同源，可一并落地）或书面接受风险（仓库内容为维护者手写、恶意 PR 场景单人维护）"
    why_human: "安全风险取舍是领域决策；两条均非本阶段 must-have 逐字违例（计划字面要求「无 YAML.load 入口」成立、双入口使用方式均在仓库根），验证者无机器判据替开发者拍板"
  - test: "确认 Plan-01 flagged_assumption：CONTENT-01 edge-probe 为 unclassified，验证者改以 RESEARCH probe 矩阵 a~g 为验收面——人工确认该覆盖对 CONTENT-01 充分"
    expected: "确认 a（YAML 语法）/b（bib 解析）/c（重复键）/d（结构）/e（PASS 汇总）/f（D-08 提醒）/g（CI 红路径）七类已覆盖 CONTENT-01 全部行为边界，或指出遗漏类别（本次两个 gap 恰属补发现的边界输入：空文件/缺文件/编码错）"
    why_human: "需求行为边界的完备性判断无机器判据；planner 在计划中显式留待 /gsd-verify-work 人工确认"
deferred: [] # Phase 3 is the final roadmap phase — no later phase covers these gaps; both are real, actionable gaps
---

# Phase 3: 内容验证 Verification Report

**Phase Goal:** 维护者更新内容时语法错误被拦截，避免静默失败
**Verified:** 2026-08-20T04:10:48Z
**Status:** gaps_found
**Re-verification:** No — initial verification (no previous VERIFICATION.md)

**MVP mode note:** ROADMAP 标注 `Mode: mvp` 但 goal 不符合 user-story 格式（`user-story.validate` = false）。按 verify-mvp-mode 规则本应先 `/gsd mvp-phase 3` 重设 goal；沿用 Phase 2 先例（同为 mvp 模式、非 story 格式、正常验证），本报告以 goal 结果子句（「语法错误被拦截，避免静默失败」）做 goal-backward 验证。格式差异已在此 surfaced，不影响事实核验。

## Goal Achievement

核心结论：**阶段目标本体成立**——本地一条命令 + CI 构建前独立步骤双入口均实际拦截内容错误（红提交 run 恰在 Validate content 步骤红、零新部署、线上保持旧版，全部经 gh API 独立复核），基线全绿 0.21s。但 2 个 critical 代码评审发现（空文件/缺文件/非 UTF-8 输入使脚本崩溃并掩盖其余文件错误）经沙箱复现确认未修复，违背 Plan-01 truth 6 的全收集契约与 SUMMARY 声称的 T-03-03 缓解——按裁决树记 gaps_found。崩溃路径均 exit 1（fail-closed），坏内容不会静默上线。

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | ROADMAP SC1：YAML 语法错误构建前明确报出 | VERIFIED | 沙箱 probe：`- date: [unclosed` → exit 1、`news.yml 第 1 行第 9 列：YAML 语法错误（did not find expected ',' or ']'）`；本地不跑 jekyll；CI 步骤位于 Build with Jekyll 之前；红提交（grants.yml YAML 错）run 32329006888 恰在 Validate content 步骤失败 |
| 2 | ROADMAP SC2：BibTeX 语法错误构建前明确报出 | VERIFIED | 沙箱 probe 四类全 exit 1：缺逗号（`papers/ref.bib 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— …`）、缺 year、重复键、截断条目；CI 步骤位置 deploy.yml:36-37 |
| 3 | ROADMAP SC3：错误信息清晰指出文件与位置 | VERIFIED（设计错误类全部实证：行列号/条目序号/引用键/字段名四类定位；边界输入例外见 gap 1/2——崩溃类输入拿英文回溯，属 D-07 契约缺口已计 gaps） | 本报告 probe 表全量证据 |
| 4 | ROADMAP SC4：发布前经验证步骤确保语法正确 | VERIFIED | 双入口同一脚本：本地 `scripts/validate.sh`（exit 0/1 契约）+ CI `Validate content`（deploy.yml:36）；绿跑 run 32328680551 步骤 success，log 含 `PASS: …, 键唯一`（中文在 CI 正常渲染） |
| 5 | P1-T1：一条命令 <1s，基线单行 PASS、计数动态、键唯一标记 | VERIFIED | `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一` exit 0 单行；warm 0.21s/0.21s（冷启 1.48s 为沙箱磁盘缓存，CPU 0.24s）；追加条目后 PASS 行自动变 bib=13（动态计算实证） |
| 6 | P1-T2：YAML 语法错误中文报出文件+行+列、exit 1、先于任何构建 | VERIFIED | 同 truth 1 probe；validate.rb/sh 无 jekyll build 调用（grep 仅注释） |
| 7 | P1-T3：结构错误五类中文报出文件+条目号、exit 1 | VERIFIED | 沙箱五 probe 全过：name 缺失（`grants.yml 第 1 条：name 字段缺失`）、role=studnet（列合法值 pi \| member \| student）、date=2026-05（附合法格式）、Latest 非首条、映射化（`顶层结构应为列表…当前是 Hash`） |
| 8 | P1-T4：BibTeX 错误中文报出 bib+键/字段名、exit 1（缺逗号/截断/缺必填/原始文本重复键） | VERIFIED | 同 truth 2 四 probe；重复键 `引用键 dupkey 重复出现 2 次` 证原始正则 tally 生效 |
| 9 | P1-T5：无 DOI 条目通过（wang2026maize 实证） | VERIFIED | ref.bib 12 条中仅 4 条含 doi；基线全绿（8 条无 doi 全过）；代码 BIB_REQUIRED 仅 title/author/year（validate.rb:142） |
| 10 | P1-T6：全部文件全部错误一次收集（非 fail-fast），单文件坏只短路自身 | **FAILED (partial)** | 设计错误类成立：双文件同坏一次运行报出 2 条（news.yml+grants.yml 各报行列）。但空/缺 _data/*.yml 与非 UTF-8/缺 ref.bib 使脚本崩溃且掩盖其余全部错误（沙箱复现：空 news.yml + 坏 grants.yml → grants 0 条报出、无 FAIL 汇总）——CR-01/CR-02，见 gaps |
| 11 | P2-T7：未提交 bib 条目数变化触发中文提醒（含 publications.md）且 exit 0 | VERIFIED | 沙箱：追加合法条目 → `提醒：ref.bib 条目数 12 → 13 已变化；publications.md 为手写列表，请确认已同步新增/删除条目` + PASS exit 0；干净树单行 PASS 零提醒 |
| 12 | P2-T8：CI Validate content 步骤位于 Setup Pages 后 Build 前，绿跑 log 可见 | VERIFIED | deploy.yml 行号 33(Setup Pages) < 36(Validate content) < 38(Build with Jekyll)，run 命令字面量 `bundle exec ruby scripts/validate.rb`；run 32328680551（SHA 2e0acc87）conclusion=success，步骤 success，log 含 PASS 行 |
| 13 | P2-T9：坏提交 → 恰在 Validate content 红、零新部署、线上 200、revert 复绿+新部署 | VERIFIED | gh 独立复核：run 32329006888（a4e8096c）conclusion=failure、失败步骤名恰为 `Validate content`、deploy job skipped；deployments 列表 5995276761(2e0acc87@03:34) → 5995351307(71dcea14@03:42)，a4e8096c 无任何 deployment；revert run 32329161540 success；POST2>PRE；今日实测线上 200 |
| 14 | P2-T10：CI 下提醒天然静默、零 CI 特判、无 HEAD^/origin/main | VERIFIED | grep 两脚本 `HEAD\^|origin/main|ENV\[` 0 命中；绿跑 log `提醒` 0 次出现（工作区=HEAD 计数相等，设计如此非特判） |

**Score:** 13/14 truths verified (1 failed-partial; 0 present-behavior-unverified — 全部行为依赖型 truth 均有本验证者亲跑的探针或 gh API 实证)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `scripts/validate.rb` | 五层校验引擎 + D-08 层 + 中文输出 + exit 契约 | VERIFIED | 203 行实质实现；六层俱在（语法/结构/解析/必填/键唯一/提醒）；层②有 StandardError 兜底，层①③ rescue 过窄（gaps） |
| `scripts/validate.sh` | exec bundle exec ruby 透传入口 | VERIFIED | 3 行、可执行位 -rwxr-xr-x、`exec bundle exec ruby "$(dirname "$0")/validate.rb"`；全部探针经它发起 |
| `.github/workflows/deploy.yml` | build job 新增 Validate content（Setup Pages 后 Build 前），既有 6 步不动 | VERIFIED | 步骤在位（36-37 行）；Checkout/Setup Ruby/Setup Pages/Build/Smoke assertions/Upload artifact 六步全部原样在位；deploy job needs: build 不变 |

注：gsd-tools `verify.artifacts` 对 Plan-02 前言报 "File not found" 系 frontmatter 路径带中文注记（`deploy.yml（修改）`）的解析问题，非实际缺文件——已按真实路径人工核验。

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| scripts/validate.sh | validate.rb | exec bundle exec ruby 透传 | WIRED | validate.sh:3；探针全走此链路（bundle exec 下 bibtex-ruby 6.2.0 解析成功） |
| scripts/validate.rb | 5 个 _data/*.yml + papers/ref.bib | Psych.parse_file + BibTeX.parse(File.read) | WIRED | validate.rb:35/131；数据流为真——probe 变更真实文件即变更输出（bib=12→13 动态计数实证） |
| deploy.yml Validate content 步骤 | bundle exec ruby scripts/validate.rb | 字面量 run 命令 | WIRED | deploy.yml:37，无 ${{ }} 内联表达式；CI log 见 PASS 行 |
| Validate content exit 1 | 无 upload-pages-artifact → deploy 不跑 → 线上保持旧版 | needs: build 拦截链 | WIRED（行为实证） | deploy.yml:46-47/55；红 run deploy job conclusion=skipped、零新 deployment（gh 复核） |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|-------------------|--------|
| validate.rb PASS 行 | counts（逐文件 length + bib.length） | 真实解析 _data/*.yml + ref.bib | 是——追加条目后计数自动 12→13 | FLOWING |
| validate.rb FAIL 行 | errors 数组 | 六层真实检查 | 是——13 类 probe 各自注入真实错误均命中 | FLOWING |
| D-08 提醒 | head_count/work_count | git show HEAD vs 工作区原始文本 | 是——未提交改动触发、干净树静默 | FLOWING |

### Behavioral Spot-Checks（验证者沙箱亲跑，/tmp 全量备份恢复，真实仓库 porcelain 全程干净）

| # | Behavior | Command 要点 | Result | Status |
|---|----------|-------------|--------|--------|
| 1 | 基线 PASS | scripts/validate.sh | 单行 PASS exit 0，warm 0.21s | PASS |
| 2 | YAML 语法错 | news.yml ← `- date: [unclosed` | exit 1，中文+行列 | PASS |
| 3 | 跨文件全收集 | news.yml+grants.yml 同坏 | exit 1，一次报 2 条 | PASS |
| 4 | 映射化 | 剥 `- ` 前缀 | `顶层结构应为列表…当前是 Hash` exit 1 | PASS |
| 5 | role 拼错 | student→studnet | 列合法值 exit 1 | PASS |
| 6 | date 非法 | May 2026→2026-05 | 附合法格式 exit 1 | PASS |
| 7 | Latest 非首条 | May 2026→Latest | `仅允许首条` exit 1 | PASS |
| 8 | 必填缺失 | grants name 键改名 | `第 1 条：name 字段缺失` exit 1 | PASS |
| 9 | bib 缺 year | 追加 probeyear | `year 字段缺失` exit 1 | PASS |
| 10 | bib 重复键 | dupkey ×2 | `引用键 dupkey 重复出现 2 次` exit 1 | PASS |
| 11 | bib 截断 | `title={截断` 无闭合 | 中文定位（引用键无法识别）exit 1 | PASS |
| 12 | bib 缺逗号 | `title={t} author={a}` | `解析失败（…多为缺失逗号…）` exit 1 | PASS |
| 13 | D-08 提醒 | 追加合法条目 12→13 | 提醒行+publications.md+exit 0 | PASS |
| 14 | 干净树静默 | 基线复跑 | 单行无提醒 | PASS |
| 15 | **空 yml 崩溃（CR-01）** | `: > _data/news.yml` | NoMethodError 英文回溯，**掩盖同跑的 grants 错误（0 条报出）** | FAIL（gap 1） |
| 16 | **缺 yml 崩溃（CR-01）** | 移走 news.yml | Errno::ENOENT 英文回溯 | FAIL（gap 1） |
| 17 | **GBK bib 崩溃（CR-02）** | 注入非 UTF-8 字节 | ArgumentError 英文回溯（BibTeX.parse 帧） | FAIL（gap 2） |
| 18 | **缺 bib 崩溃（CR-02）** | 移走 ref.bib | Errno::ENOENT 英文回溯，已收集 YAML 错误不再打印 | FAIL（gap 2） |
| 19 | CI 绿跑 | gh run view 32328680551 | success；Validate content 步 success；log 含 PASS+键唯一 | PASS |
| 20 | CI 红跑 | gh run view 32329006888 | failure；失败步骤恰 Validate content；deploy skipped | PASS |
| 21 | 部署记录 | gh api deployments | a4e8096c 零部署；5995351307 > 5995276761 | PASS |

### Probe Execution

无 `scripts/*/tests/probe-*.sh` 文件——本阶段探针为 PLAN `<verify>` 内联命令。验证者已在沙箱副本等效重跑 14 条破坏性探针（上表 1-18）+ 3 项 CI 证据独立复核（19-21），等效履行 probe 执行契约。

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|------------|------------|-------------|--------|----------|
| CONTENT-01 | 03-01, 03-02 | 发布前校验 _data/*.yml 与 papers/ref.bib 语法，错误明确报出而非静默失败 | SATISFIED（附 robustness 例外） | 双入口全链路实证（truths 1-14）；REQUIREMENTS.md Traceability 标记 Phase 3/Complete 与实际一致。例外：空/缺/非 UTF-8 输入崩溃掩盖他错（gaps 1/2）——仍 exit 1 非静默，但「明确报出」不成立 |

Orphaned requirements: 无——REQUIREMENTS.md 映射到 Phase 3 的仅 CONTENT-01，两计划均声明。

### Anti-Patterns Found

三个交付文件零 debt marker（TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER 全无）。纳入 03-REVIEW.md（执行级验证的评审，本验证者已复现其两条 critical）：

| Finding | File:Line | Pattern | Severity | Impact |
|---------|-----------|---------|----------|--------|
| CR-01 | validate.rb:33-39 | rescue 过窄——空/缺 yml 崩溃掩盖他错 | BLOCKER（gap 1） | 违背全收集契约/T-03-03；本地拿英文回溯 |
| CR-02 | validate.rb:129-134 | rescue 过窄——非 UTF-8/缺 bib 崩溃 | BLOCKER（gap 2） | 同上；连已收集错误都不打印 |
| WR-01 | validate.rb:15-22, validate.sh:3 | CWD 相对路径，子目录调用即崩 | WARNING | 本地易踩坑；与 gap 1 修法同源（__dir__ 锚定） |
| WR-02 | validate.rb:29-35 | parse_file(...).to_ruby 实为反序列化路径，注释声称相反（T-03-01 缓解描述不准） | WARNING | 恶意 PR+本地运行=对象注入面；Psych.safe_load 可同源修复 |
| IN-01 | validate.rb:159,174-176 | 键提取与计数正则不一致，`@type {key,` 空格形态漏检（现状无实例） | Info | 潜在漏报，现基线无此形态 |
| IN-02 | validate.rb:131,159,186 | ref.bib 三次读盘 | Info | 无害冗余 |
| IN-03 | validate.rb:26,40 | counts 死初始化 | Info | 死代码 |

### Decision Coverage

All trackable CONTEXT.md decisions are honored by shipped artifacts.（gsd-tools check.decision-coverage-verify：8/8 honored，0 not_honored——D-01~D-08 全部在交付物中落地；本报告 gaps 不涉及决策未落地，而是 truth 6/T-03-03 的实现完备度缺口）

### Human Verification Required

（status 为 gaps_found，以下条目随 gap 修复后一并人工收口；frontmatter `human_verification` 已同步列出）

1. **背书 3 条 judgment 级 prohibitions**（P-03-1 只读 / P-03-2 不拦合法内容 / P-03-3 不触碰 publications.md）——验证者非权威结论均为「未违反」（证据见 frontmatter），需人工最终背书。
2. **裁定 WR-02（YAML 反序列化面）与 WR-01（子目录路径）处置**——修复（safe_load + __dir__，与 gap 1 修法同源可一并落地）或书面接受风险。
3. **确认 probe 矩阵 a~g 对 CONTENT-01 覆盖充分**（Plan-01 flagged_assumption 显式留待人工；本次两个 gap 恰属边界输入补发现）。
4. **D-08 提醒文案可读性与 CI 步骤命名**——计划留待人工目检（文案机器已证逐字命中 D-08 方向，含 publications.md 字样）。

### Gaps Summary

单一根因：**层①与层③ 的 rescue 面窄于「收集一切、中文报出、永不崩溃」的自我契约**。13/14 truths 全绿（含 CI 红路径端到端、D-08、双入口、全部设计错误类探针），阶段核心目标（拦截、避免静默失败）在所有实测路径上成立——崩溃路径也 exit 1，CI 照样拦下。但空文件/缺文件/非 UTF-8 三类维护者高概率事故输入会以英文回溯崩溃并掩盖其余文件错误，直接违背 Plan-01 truth 6 与 03-01-SUMMARY 声称的 T-03-03 缓解（「逐文件 rescue 兜底」仅在层②成立）。两 gap 修复面小且同源（03-REVIEW.md 已给出可用补丁形状；Psych.safe_load 一并消解 WR-02 与空文件 false 情形），建议走 `/gsd-plan-phase --gaps` 或 `/gsd-quick` 收口，随后重跑本验证。

Phase 3 为 ROADMAP 末位阶段，无后续阶段可承接——两 gap 均为真实待办，不可 defer。

---

_Verified: 2026-08-20T04:10:48Z_
_Verifier: Claude (gsd-verifier)_
