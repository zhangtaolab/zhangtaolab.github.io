---
phase: 03-content-validation
plan: 02
subsystem: content-validation (CI 集成 + D-08 提醒层)
tags: [github-actions, deploy-yml, ci-gate, ruby, git-show, bibtex-ruby, d-08-reminder, red-path-proof]

requires:
  - phase: 02-auto-deploy
    provides: deploy.yml CI 步骤链（插入点）+ 「断言红→无工件→不部署」拦截语义 + gh CLI 运维通道
  - phase: 03-content-validation plan 01
    provides: scripts/validate.rb 五层校验引擎与 validate.sh 入口（本计划在其上追加提醒层与 CI 半边）
provides:
  - validate.rb D-08 提醒层：HEAD vs 工作区 ref.bib 原始文本条目计数对比，不等输出中文提醒（含 publications.md 字样），退出码零影响（CONTENT-01-f）
  - deploy.yml build job「Validate content」步骤（Setup Pages 之后、Build with Jekyll 之前）——同一脚本双入口收口（D-04，ROADMAP sc1/sc2 CI 半边 + sc4）
  - 红路径端到端实证：坏内容提交使 run 恰在 Validate content 步骤红、零新部署、线上保持旧版 200，revert 后流水线与稳态部署复绿（CONTENT-01-g，ROADMAP sc3/sc4）
  - 对比 probe 机器证明：同一份映射化 news.yml 下 validate exit 1 而 JEKYLL_ENV=production jekyll build exit 0（验证脚本是唯一防线）
affects: [03-content-validation 阶段验证（/gsd-verify-work）, CONTENT-01 结项]

actuals:
  tokens: 709       # chars/4 over scripts/validate.rb + deploy.yml + grants.yml(净零) 生产 diff（2837 字符）
  tasks: 3
  commits: 4        # 2c2d0476 + 2e0acc87 + a4e8096c + 71dcea14（metadata docs 提交另计）

tech-stack:
  added: []          # D-06 零新增依赖维持：psych/bibtex-ruby/git 均既有；runner git 可用性 A1 兑现为实证
  patterns:
    - D-08 提醒 = git show HEAD:path 与工作区原始文本计数对比（fetch-depth 1 天然无操作，零 CI 特判）
    - CI 拦截步骤复用 Phase 2 语义链：步骤红 → build job 红 → 无 upload-pages-artifact → deploy job 不跑 → 线上保持旧版
    - 红证纪律：快照 PRE deployment → 本地预检 exit 1 → 推红 → 断言失败步骤恰为验证步骤 + deployment 不变 + 线上 200 → 立即 revert → 复绿断言 POST2 > PRE

key-files:
  created: []
  modified:
    - scripts/validate.rb   # 追加 ⑥ D-08 提醒层（guard + 计数对比 + 中文提醒，退出码不动）
    - .github/workflows/deploy.yml  # 插入 Validate content 步骤（既有 6 步零改动）
    - _data/grants.yml      # 红证探针 +1 行后 revert -1 行（净变化为零，历史保留作 CONTENT-01-g 证据）

key-decisions:
  - "D-08 计数在原始文本上做（scan(/^@[a-zA-Z]+\\{/)）：不依赖 BibTeX 解析结果，bib 语法坏时计数仍可执行——与键唯一层同源纪律"
  - "CI 零特判：checkout fetch-depth 1 下工作区=HEAD、计数相等、提醒自动不触发；guard（非 git 目录/无 HEAD 历史）失败静默跳过（A1 兜底）"
  - "红证保留在 git 历史：red commit a4e8096c + revert 71dcea14 不做 squash——CONTENT-01-g 的可审计证据链"

patterns-established:
  - "提醒层模式：增强性输出永远不进 errors 数组、不动退出码——警告与阻断在结构上分离（D-08）"
  - "CI 步骤插入纪律：字面量 run 命令（无 ${{ }} 内联表达式）、既有步骤一字不改、位置由 grep 行号断言钉死（T-03-02/T-03-06）"
  - "不可逆操作分段执行：红证推送拆为 快照→红断言→恢复 三段，每段可独立恢复（10 分钟工具时限 + 中途可回滚）"

requirements-completed: [CONTENT-01]

coverage:
  - id: D1
    description: "validate.rb D-08 提醒层：ref.bib 条目数 12→13（未提交合法新条目）触发中文提醒（提醒 + publications.md + 「条目数 12 → 13」）且 exit 0；干净树零提醒（单行 PASS）；probe 恢复后 porcelain 证洁"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 1 automated verify（03-02-PLAN.md <verify> 逐字执行两次均 TASK1-PASS）：/tmp/v3-p2-base.txt 单行 PASS exit 0；/tmp/v3-p2-rem.txt 含提醒行 + PASS（bib=13）exit 0；AC4 grep -cE 'HEAD\\^|origin/main|ENV\\[' = 0"
        status: pass
    human_judgment: false
  - id: D2
    description: "deploy.yml「Validate content」步骤（Setup Pages 后、Build with Jekyll 前；字面量 bundle exec ruby scripts/validate.rb）绿跑实证：脚本在 CI bundler 环境运行（bibtex-ruby 解析、中文输出渲染），既有 6 步零改动，deploy job 稳态绿"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 2 automated verify（TASK2-PASS）：YAML-OK + 6 步骤名在位 + 行号 33 < 36 < 38 + run 行 -Fxq 精确匹配；push 2e0acc87 → run 32328680551 build+deploy 双 success，log 含 'Validate content'，新 deployment 5995276761"
        status: pass
    human_judgment: false
  - id: D3
    description: "红路径端到端证明：坏 grants.yml（unclosed flow sequence）提交推 main → run conclusion failure 且失败步骤恰为 Validate content（构建前拦截）→ 无新 deployment（5995276761 == PRE）→ 线上全程 200 → revert 推送 run success + 新 deployment 5995351307（POST2 > PRE）→ 树净"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 3 断言序列（全过）：本地预检 exit 1（grants.yml 第 3 行第 9 列）→ red run 32329006888 conclusion=failure、失败步骤名 'Validate content'、deployment 不变、https://zhangtaolab.org/?cb=N 200 → revert run 32329161540 success、POST2 5995351307 > PRE 5995276761、线上 200、git status --porcelain 空"
        status: pass
      - kind: integration
        ref: "对比 probe：perl 映射化 news.yml 后 scripts/validate.sh exit 1（顶层结构应为列表…当前是 Hash）而 JEKYLL_ENV=production jekyll build exit 0——同份坏内容构建静默通过，验证脚本唯一防线；恢复后 porcelain 证洁"
        status: pass
    human_judgment: false

duration: 16min
completed: 2026-08-20
status: complete
---

# Phase 3 Plan 02: 双入口收口（D-08 提醒层 + CI 构建前验证步骤 + 红路径端到端证明）Summary

**CI「Validate content」步骤绿跑实证 + 故意坏提交端到端证明拦截语义（run 恰在验证步骤红、零新部署、线上保持旧版 200、revert 复绿），D-08 条目数提醒警告不阻断、CI 天然静默——CONTENT-01 双入口全收口。**

## Performance
- **Duration:** 16min（947s）
- **Started:** 2026-08-20T03:28:44Z
- **Completed:** 2026-08-20T03:44:31Z
- **Tasks:** 3/3（全部 auto，无 checkpoint）
- **Files modified:** 3（validate.rb、deploy.yml、grants.yml 净零）

## Accomplishments
- **双入口收口（D-04/sc4）**：本地 `scripts/validate.sh` 与 CI `Validate content` 步骤运行同一 `scripts/validate.rb`——维护者发布前双保险
- **D-08 落地（CONTENT-01-f）**：未提交新增 bib 条目（12→13）触发「提醒：ref.bib 条目数 12 → 13 已变化；publications.md 为手写列表，请确认已同步新增/删除条目」且 exit 0；干净树零提醒；CI（fetch-depth 1，工作区=HEAD）天然静默、零特判代码
- **CI 构建前拦截（sc1/sc2 CI 半边）**：步骤位于 Setup Pages 与 Build with Jekyll 之间，绿跑 run 32328680511（build+deploy 双绿）证明脚本在 CI bundler 环境正常运行（bibtex-ruby 解析、中文渲染）
- **红路径端到端证明（CONTENT-01-g/sc3/sc4 反向）**：坏内容 run 32329006888 恰在 Validate content 步骤红（非 Build with Jekyll——构建前拦截）、无新 deployment、线上持续 200 服务旧版；revert run 32329161540 复绿 + 新 deployment 5995351307 稳态恢复
- **对比 probe（阶段存在理由的机器证明）**：同一份映射化 news.yml，validate exit 1 而 `JEKYLL_ENV=production jekyll build` exit 0——构建静默通过、验证脚本是唯一防线

## Task Commits
1. **Task 1: D-08 提醒层 — ref.bib 条目数变化提醒（警告不阻断）** - `2c2d0476` (feat)
2. **Task 2: CI 集成 — deploy.yml 插入 Validate content 步骤并推送实证绿跑** - `2e0acc87` (ci — 计划 verify 内嵌的指定提交信息)
3. **Task 3: 红路径端到端证明 — 坏提交推 main → 无部署 → revert 复绿** - `a4e8096c` (test 红证) + `71dcea14` (revert)

**Plan metadata:** 见本次 docs 提交（SUMMARY + STATE + ROADMAP + REQUIREMENTS）

## CI 实证证据表（CONTENT-01-g / ROADMAP sc3+sc4）

| 项目 | 值 | 断言结果 |
|------|-----|---------|
| 绿跑 run（Task 2，SHA 2e0acc87） | 32328680551 — build ✓ + deploy ✓，log 含 Validate content | PASS |
| 绿跑产生 deployment | 5995276761（= PRE 基线） | — |
| 红证 SHA / run | a4e8096c / 32329006888 — conclusion **failure** | PASS |
| 红跑失败步骤名 | **Validate content**（恰为验证步骤，非 Build with Jekyll） | PASS |
| 红跑新 deployment | 无（最新 id 5995276761 == PRE，未变） | PASS |
| 红窗口线上状态 | https://zhangtaolab.org/?cb=N → 200（旧 artifact 持续服务） | PASS |
| revert SHA / run | 71dcea14 / 32329161540 — conclusion success | PASS |
| revert 后 deployment | POST2 5995351307 > PRE 5995276761（稳态自动部署恢复） | PASS |
| 终态工作树 | `git status --porcelain` 空 | PASS |
| 对比 probe | 映射化 news.yml：validate exit 1 vs `JEKYLL_ENV=production jekyll build` exit 0 | PASS |

## Files Created/Modified
- `scripts/validate.rb`（修改）——追加 ⑥ D-08 提醒层：guard（`git rev-parse --git-dir` + `git cat-file -e HEAD:papers/ref.bib`，失败静默跳过）→ `git show HEAD` 与工作区 `scan(/^@[a-zA-Z]+\{/)` 计数对比 → 不等输出一行中文提醒；不写 errors、退出码不动
- `.github/workflows/deploy.yml`（修改）——插入 2 行步骤（name: Validate content / run: bundle exec ruby scripts/validate.rb），既有 6 步一字未改
- `_data/grants.yml`（红证探针）——+1 行（`- name: [unclosed`）后 revert -1 行，净变化为零；红证提交保留在历史作为 CONTENT-01-g 证据

## Decisions Made
- D-08 计数在原始文本做（不依赖 BibTeX 解析结果——bib 语法坏时计数仍可执行），与键唯一层同源纪律——按计划执行
- 红证与 revert 提交保留在 git 历史（不 squash）：CONTENT-01-g 的可审计证据链——按计划 reversibility 说明执行
- validate.rb 头注释双入口说明（「本地: scripts/validate.sh；CI: deploy.yml 直接 bundle exec ruby scripts/validate.rb」）与落地的步骤名天然一致，未再改注释（最小改动纪律，T-03-06）

## Deviations from Plan

**1. [Rule 1 - hygiene] Task 1 注释含被禁字面量**
- **Found during:** Task 1 AC4 检查
- **Issue:** 新增注释原文「禁止改用 HEAD^ / origin/main 对比写法」本身包含 `HEAD^`/`origin/main` 字面量——AC4 要求 grep-able absence，审查 grep 会命中注释
- **Fix:** 改写为「禁止改用父提交/远端分支对比写法（浅克隆 fetch-depth 1 下不存在）」，语义不变、grep 归零
- **Files modified:** scripts/validate.rb
- **Verification:** `grep -cE 'HEAD\^|origin/main|ENV\['` = 0；Task 1 verify 全套重跑 TASK1-PASS
- **Commit:** 2c2d0476（随 Task 1 一并提交）

**2. [Process] Task 3 红证验证分段执行**
- **Found during:** Task 3 执行
- **Issue:** 计划的 verify 为单一复合命令（含两次完整 CI watch + revert），超出单次命令 10 分钟工具时限；且红推送属不可逆操作，中途断链将丢失 $PRE 等断言上下文
- **Fix:** 拆为三段（快照+本地预检 → 红证断言 → revert+终态断言），每段断言与计划逐字等价，另加本地预检（推 main 前先证 validate.sh exit 1，防意外绿推）
- **Files modified:** 无（纯执行方式）
- **Verification:** 全部断言逐条执行并记录（见证据表）；TASK3-PASS
- **Commit:** a4e8096c + 71dcea14

**Total deviations:** 2（1×Rule 1 auto-fixed，1×process）。**Impact:** 零范围扩张；所有计划断言原样执行并留证。

## Issues Encountered
None — gh CLI 全程已认证（Phase 2 通道延续）；两次中途分类器误拦（transient）以更小粒度只读命令重试通过，不影响结果。

## Authentication Gates
None — `gh auth status` 启动即通过（forrestzhang，repo 权限），无需人工介入。

## Known Stubs
None — 无占位实现；D-08 反向提醒（publications.md→ref.bib）属 CONTEXT Deferred，非遗留 stub。

## Threat Mitigations Landed (threat_model)
- **T-03-02 (mitigate)**: 新步骤 run 为字面量 `bundle exec ruby scripts/validate.rb`（8 空格缩进整行 `-Fxq` 精确匹配钉死）；run 块无 `${{ }}` 内联表达式
- **T-03-06 (mitigate)**: 只插入不改既有步骤——6 个既有步骤名全部 grep 在位、新步骤行号严格居中（33 < 36 < 38）、推送后整 run 绿（build+deploy 双 success，稳态部署语义未损）
- **T-03-04 (accept)**: 红窗口分钟级（03:37 push → 03:41 revert），线上全程 200（旧 artifact 服务），revert 复绿 + 新 deployment 5995351307——接受理由兑现（零用户可见影响）
- **T-03-SC (mitigate)**: 零包安装（D-06 维持），无可审对象

## Prohibition Compliance
- **P-03-1/P-03-2/P-03-3**：publications.md 零触碰（本计划 4 个生产提交的文件清单 grep 计数 0）；D-08 仅输出提醒文本、方向 ref.bib→提醒，无任何替换/再生成/自动同步动作；反向提醒未做（Deferred）

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
**Phase 3 全部计划完成（2/2）——ready for phase verification（/gsd-verify-work）。**
- CONTENT-01 test map a~g 七项全部有机器真值：a~e 于 Plan 01、f 于本计划 Task 1、g 于本计划 Task 3（见证据表）
- 待人工背书：prohibitions 三条（P-03-1/2/3）无违反迹象（上方 Prohibition Compliance 段）、D-08 提醒文案可读性、CI 步骤位置合理性——/gsd-verify-work 收口
- flagged_assumption 延续：Plan 01 的 edge-probe 覆盖充分性（probe 矩阵 a~g）需人工确认

## Self-Check: PASSED
- scripts/validate.rb FOUND（含 D-08 层）；.github/workflows/deploy.yml FOUND（Validate content 在位）
- 提交 2c2d0476 / 2e0acc87 / a4e8096c / 71dcea14 全部在 git log 命中且已推送 origin main
- 最终基线复跑：`PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`（exit 0）；全套件三连绿；`git status --porcelain` 全空
