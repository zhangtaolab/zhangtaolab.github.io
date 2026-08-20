---
phase: 03-content-validation
plan: 03
subsystem: content-validation (本地内容验证工具)
tags: [ruby, psych, safe-load, bibtex-ruby, yaml-validation, encoding, chinese-errors, gap-closure]

requires:
  - phase: 03-content-validation
    provides: 03-VERIFICATION.md 两条 critical gap（CR-01/CR-02）missing 修法清单 + 03-REVIEW.md 补丁形状；03-01/03-02 落地的 validate.rb/sh 与 CI 双入口
provides:
  - validate.rb 抗崩收口：空/缺 _data/*.yml 与非 UTF-8/缺 papers/ref.bib 四类输入从英文回溯崩溃翻绿为中文报出 + 全收集 + FAIL 汇总 + exit 1
  - WR-01（任意 CWD 调用，ROOT = __dir__ 锚定）与 WR-02（Psych.safe_load 入口 + 注释纠偏）收口
  - IN-01（空格形态重复键漏检）正则同源化 + IN-02（三次读盘）+ IN-03（死初始化）顺带收口
affects: [03-content-validation (阶段 verify-work 人工确认面), 维护者日常更新流程]

actuals:
  tokens: 1928     # chars/4 over scripts/ diff 71dcea14..HEAD（7712 字符）；计划估 26000，实际远小——估计算的是读改证全链，非纯 diff
  tasks: 2
  commits: 3       # 1 前置清场 docs + 2 任务提交（metadata 提交另计）

tech-stack:
  added: []        # D-06 零新增依赖：psych 5.3.1 为 Ruby default gem（safe_load 入口切换非新依赖）
  patterns:
    - rescue 阶梯 specific→general（SyntaxError/DisallowedClass/ENOENT/StandardError），任何单文件异常只进 errors 数组
    - 解析前 valid_encoding? 预检（编码事故先于解析器判定，杜绝 ArgumentError 崩溃帧）
    - 路径双层约定：仓库相对字符串（消息字面量 + git spec）× File.join(ROOT, path) 锚定实际读取

key-files:
  created: []
  modified:
    - scripts/validate.rb

key-decisions:
  - "safe_load 接受面参数 permitted_classes: [Date], aliases: true（开发者 2026-08-20 gap-planning 裁定）：Date 许可使 unquoted ISO 日期标量与旧接受面行为一致——解析出的 Date 仍被结构层「date 格式不合法」拦截（设计拦截路径保留）；!ruby/object 标签被 Psych::DisallowedClass 拒绝（WR-02 行为面实证）"
  - "YAML_FILES 值与 BIB_PATH 保持仓库相对字符串、全部 File I/O 走 File.join(ROOT, path)（ROOT = File.expand_path(\"..\", __dir__)）：中文消息字面量不变（D-07）且 D-08 层 git spec HEAD:#{BIB_PATH} 必须仓库相对（git show HEAD: 后接绝对路径在任何 CWD 下失败，planner 实测）"
  - "层⑥ D-08 工作区计数 guard 从「raw 存在」扩为「raw 存在且 valid_encoding?」：对无效编码字节串做正则 scan 本身抛 ArgumentError（执行器实测三类正则全抛），计划原 nil-guard 不足以让 GBK probe 无回溯——guard 失败静默跳过沿用 A1 兜底语义，编码错误已由层③中文报出"
  - "IN-01 同源化只影响「看得见什么」不影响「什么合法」（P-03-2）：基线计数 12/12 不变，正则放宽仅使 @article {key, 空格形态重复键进入 tally"

patterns-established:
  - "probe 纪律沿用（03-01）：cp 备份 → printf/perl 破坏 → 断言 exit + 中文消息 + 无回溯 → cp 恢复 → git status --porcelain 证洁；本计划 14 条破坏性 probe 全程零残留"
  - "tracer 反馈闸门（auto mode）：Task 1 提交后完整重跑 tracer verify 再进 expansion——四类崩溃输入的翻绿在提交后状态复证"

requirements-completed: [CONTENT-01]

coverage:
  - id: D1
    description: "validate.rb 抗崩收口：层① Psych.safe_load 四级 rescue 阶梯（空文件走既有 NilClass 结构规则、缺文件/类型标签/兜底各得中文消息）；层③ raw 单次读入 + valid_encoding? 预检 + 三级 rescue；ROOT = __dir__ 锚定全部 File I/O（WR-01/WR-02/gap 1/gap 2）"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 1 automated verify（03-03-PLAN.md 逐字分步执行）: 基线单行 PASS exit 0 + 空 news.yml+坏 grants.yml 同跑双报 FAIL: 2 个问题 + 缺 news.yml（news.yml：文件不存在——请勿删除或改名数据文件）+ GBK ref.bib（含非 UTF-8 字节…请以 UTF-8 重新保存）+ 缺 ref.bib 四类 probe 全部 exit 1 零回溯 + (cd _data && ../scripts/validate.sh) 同 PASS 行 + 源码断言（safe_load/valid_encoding?/__dir__/双 ENOENT/无 to_ruby）"
        status: pass
      - kind: integration
        ref: "tracer 反馈闸门（提交后完整重跑）: TRACER-VERIFY-END-TO-END-PASS (RC=0 R1..R4=1 R5=0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "IN-01 正则同源化（层⑤ /@\\s*[a-zA-Z]\\w*\\s*\\{([^,\\s]+)\\s*,/ 与层⑥ /@\\s*[a-zA-Z]\\w*\\s*\\{/ 共享 opener 子模式，空格形态重复键不再漏检）+ IN-03 死初始化清除 + 设计内错误类零回归（spot-checks 1-14）"
    requirement: CONTENT-01
    verification:
      - kind: integration
        ref: "Task 2 automated verify: 双坏 YAML 行列定位 + role/date/映射化三结构 probe + !ruby/object 中文拒绝（WR-02 行为面）+ 缺 year/空格形态重复键（引用键 spacedup 重复出现 2 次）/截断/缺逗号 + D-08 提醒（条目数 12 → 13 + publications.md + exit 0）全部命中，基线 12/12 与单行 PASS 保持"
        status: pass
      - kind: integration
        ref: "阶段全套件三连绿: scripts/validate.sh && bundle exec jekyll build --destination /tmp/_site_v3g && scripts/ci-smoke.sh /tmp/_site_v3g → PASS: sitemap=11；变更面 git diff --name-only 71dcea14..HEAD -- scripts/ .github/ 仅 scripts/validate.rb（validate.sh/deploy.yml 字节不变，D-04）"
        status: pass
    human_judgment: false
  - id: D3
    description: "CONTENT-01 验收面充分性：RESEARCH probe 矩阵 a~g + 三个新发现边界输入类（空文件/缺文件/非 UTF-8）对需求是否全覆盖"
    requirement: CONTENT-01
    verification: []
    human_judgment: true
    rationale: "计划 flagged_assumptions 显式禁止自动视为已覆盖（承 03-VERIFICATION.md human_verification 第 3 条）；边界类的完备性判断无机器判据，须 /gsd-verify-work 人工确认（连同 P-03-1/2/3 prohibitions 背书与 safe_load 接受面行为变化裁定）"

duration: 16min
completed: 2026-08-20
status: complete
---

# Phase 3 Plan 03: Gap Closure（层①/③ 抗崩收口 + WR-01/WR-02 + IN-01/IN-03）Summary

**validate.rb 层① 换 Psych.safe_load 四级 rescue、层③ 编码预检 + 三级 rescue、__dir__ 路径锚定——空/缺 yml 与 GBK/缺 ref.bib 四类崩溃输入全部翻绿为中文报出 + 全收集 + exit 1，正则同源化补上空格形态重复键漏检，基线 12 条全绿零回归**

## Performance

- **Duration:** 16min（993s）
- **Started:** 2026-08-20T07:04:03Z
- **Completed:** 2026-08-20T07:20:36Z
- **Tasks:** 2/2（1 tracer + 1 expansion）
- **Files modified:** 1（scripts/validate.rb；validate.sh 与 deploy.yml 字节不变）

## Accomplishments

- **四类崩溃输入翻绿（03-VERIFICATION.md spot-checks 15-18，CR-01/CR-02 收口）**：空 `_data/news.yml` 走既有结构层路径（`顶层结构应为列表…当前是 NilClass`）且同跑的 grants.yml 错误照样报出（`FAIL: 2 个问题`）；缺 news.yml 报 `news.yml：文件不存在——请勿删除或改名数据文件`；GBK 字节 ref.bib 报 `含非 UTF-8 字节（多为编辑器以 GBK 等编码保存）——请以 UTF-8 重新保存`（已收集的 YAML 错误仍打印）；缺 ref.bib 报 `papers/ref.bib：文件不存在`——全部中文、无英文回溯、exit 1
- **WR-02 收口**：层① 加载入口换 `Psych.safe_load(File.read(...), permitted_classes: [Date], aliases: true)`，旧 AST 反序列化调用链连注释全文件消失（负向 grep 实证）；`!ruby/object:Kernel` 标签得到中文 `含不支持的 YAML 类型标签` 拒绝而非对象实例化（probe 实证）；误导注释重写为如实描述 safe 语义
- **WR-01 收口**：`ROOT = File.expand_path("..", __dir__)` 锚定全部 File I/O；`(cd _data && ../scripts/validate.sh)` 输出与仓库根调用逐字相同（同 PASS 行、exit 0）；YAML_FILES 值/BIB_PATH 保持仓库相对（D-07 消息字面量 + D-08 git spec 双用途）
- **IN-01 收口（空格形态重复键）**：`@article{spacedup,` + `@article {spacedup,` 混合形态被一个 tally 抓到（`引用键 spacedup 重复出现 2 次`）——bibtex-ruby 解析后静默改名，原始文本是唯一真相源；层⑤ 提键与层⑥ 计数正则自此共享 opener 子模式，基线计数 12/12 不变；IN-02（三次读盘→raw 单次复用）与 IN-03（counts 死初始化）一并清除
- **设计内错误类零回归（spot-checks 1-14）**：双坏 YAML 行列定位、role/date/映射化、!ruby/object 拒绝、缺 year、截断（空键定位线索）、缺逗号、D-08 提醒（12→13 + publications.md + exit 0 不阻断）、干净树单行静默——全部经 D-05 本地一条命令入口跑出，消息逐字同形
- **CI 双入口零改动继承（D-04）**：`git diff --name-only 71dcea14..HEAD -- scripts/ .github/` 仅 scripts/validate.rb；全套件三连绿（validate + jekyll build + ci-smoke `PASS: sitemap=11`）

## Task Commits

1. **Task 1: 抗崩 tracer — 层① safe_load + 四级 rescue、层③ 编码预检 + 三级 rescue + raw 单次读入、__dir__ 路径锚定** - `e28e6aa4` (fix, tracer)
2. **Task 2: IN-01 正则同源化 + IN-03 死代码清除 + 设计内错误类回归电池** - `4bd8f987` (fix)

**Plan metadata:** 见本次 docs 提交（SUMMARY + STATE + ROADMAP + REQUIREMENTS）
**前置清场:** `b50b583b`（docs: planning 工件同步，见 Deviations #1）

## Files Created/Modified

- `scripts/validate.rb`（修改，+50/-12 两笔任务提交）——层① 入口与 rescue 阶梯、层③ raw/编码预检/rescue 阶梯、ROOT 常量、层⑤⑥ 正则同源化与 guard、死初始化移除；六层引擎结构、PASS/FAIL 输出格式、exit 0/1 契约、D-08 提醒文案全部不变

## Decisions Made

（见 frontmatter key-decisions；均按计划或开发者既有裁定执行）计划外决策一条：层⑥ guard 扩至 valid_encoding?（执行器实测三类正则对无效编码字节串均抛 ArgumentError，计划原 nil-guard 不够——Rule 1，详见 Deviations #2）。

## Deviations from Plan

**1. [Rule 3 - blocking] 前置清场：planning 工件未提交导致工作区非全净**
- **Found during:** Task 1 precondition 检查
- **Issue:** 前置条件要求 `git status --porcelain` 为空（破坏性 probe 须证洁），但规划阶段留下未提交的 STATE.md 刷新与 milestone.lock 会话轮换
- **Fix:** 按 03-01 既有先例提交为一笔 docs 提交，树全净后开始 Task 1
- **Files modified:** .planning/STATE.md、.planning/milestone.lock
- **Verification:** 提交后 porcelain 全空；两任务全部 probe 的 scoped porcelain 检查为空
- **Commit:** b50b583b

**2. [Rule 1 - bug] 层⑥ D-08 工作区计数对 GBK 原文会崩（计划 guard 规格不足）**
- **Found during:** Task 1 实现前 Ruby 行为预检（分析 paralysis guard 之内的一次性探针）
- **Issue:** 计划只要求「raw 存在性 guard（nil 跳过）」；实测对含非 UTF-8 字节的字符串做正则 `scan` 本身抛 `ArgumentError: invalid byte sequence in UTF-8`（旧行锚定与两个新正则全抛）——GBK probe 会带 validate.rb 回溯帧，违反 spot-check 17 的无回溯断言
- **Fix:** guard 从 `head_bib && raw` 扩为 `head_bib && raw && raw.valid_encoding?`，注释写明理由；沿用「提醒属增强，guard 失败静默跳过」的 A1 兜底语义（编码错误已由层③中文报出，提醒缺位不是错误）
- **Files modified:** scripts/validate.rb（层⑥ 对比入口）
- **Verification:** GBK probe 输出恰两条错误 + FAIL 汇总、零回溯（`! grep -Eq 'validate\.rb:[0-9]+'` 通过）；tracer 提交后重跑全绿
- **Commit:** e28e6aa4（随 Task 1 一并提交）

---

**Total deviations:** 2 auto-fixed（1×Rule 3，1×Rule 1）。**Impact:** 均零范围扩张；#2 是计划补丁形状的正确性修正，方向与计划的「收集一切、永不崩溃」契约一致。

## Issues Encountered

None — 两处 deviation 均当场解决。bibtex-ruby Logger 对截断条目向 stderr 打一行 WARN（gem 既有行为，03-01 已记录，不影响断言与退出码）。

## Threat Mitigations Landed (threat_model)

- **T-03-01 (mitigate)**: 层① 唯一入口 `Psych.safe_load(permitted_classes: [Date], aliases: true)`；Task 1 源码断言含 safe_load 且 `to_ruby` 全文件（含注释）零命中 + Task 2 `!ruby/object:Kernel` 行为 probe（中文类型标签消息 + exit 1 + 无回溯）双证；误导注释已重写（缓解描述与实现一致）
- **T-03-03 (mitigate)**: 层① 四级 + 层③ 三级 rescue 阶梯 + 解析前 valid_encoding? 预检；四类原崩溃输入的翻绿 probe 为验收面（gap 1/2 收口）
- **T-03-05 (mitigate)**: 严格只读（全部 File.read，零写路径）；14 条破坏性 probe 恢复后 `git status --porcelain _data papers` 全空证洁
- **T-03-08 (mitigate)**: D-08 层 git 内插仍只有固定仓库相对常量 BIB_PATH 字面量；路径锚定改造未触碰该内插形态
- **T-03-SC**: 零包安装（D-06；safe_load 来自 psych——Ruby default gem）

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Phase 3 三计划全部完成（3/3 SUMMARY），可进入 /gsd-verify-work 人工确认面**：① CONTENT-01 验收面充分性（probe 矩阵 a~g + 空文件/缺文件/非 UTF-8 三边界类，本计划 D3 coverage 条目已路由人工）；② P-03-1/2/3 三条 judgment 级 prohibitions 最终背书（03-VERIFICATION.md human_verification 第 1 条）；③ safe_load 接受面行为变化裁定（冷门 YAML 类型标签由静默接受转中文拒绝——收紧而非放宽，开发者可否决回到 flagged_assumption 修订）；④ D-08 文案与 CI 步骤命名目检。线上与 CI 侧无待办：deploy.yml 字节未动，下次 push 自动继承修复后的脚本语义（truth 12/13 红绿拦截已端到端实证，无需重证）。

## Self-Check: PASSED

- scripts/validate.rb FOUND（修改后 241 行，ruby -c Syntax OK）
- 提交 e28e6aa4 / 4bd8f987 / b50b583b 全部在 git log 命中
- 最终基线复跑：`PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一`（exit 0 单行）；`git status --porcelain _data papers` 为空；全套件三连绿
