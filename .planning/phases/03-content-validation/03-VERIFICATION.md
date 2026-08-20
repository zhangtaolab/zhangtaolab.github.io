---
phase: 03-content-validation
verified: 2026-08-20T07:56:22Z
status: human_needed
score: 17/17 must-have truths verified (14 阶段 truths——含此前 partial 的 truth 10 收口——+ 3 条 gap-closure 计划新增 truths WR-01/WR-02/IN-01+IN-03)
behavior_unverified: 0 # 全部行为依赖型 truth 均由本验证者亲跑探针（26 条，一次性 /tmp git clone 内执行破坏性探针、真仓库只读探针）或既往端到端 CI 证据 + 不变契约链实证
overrides_applied: 0
requirements: [CONTENT-01]
prohibitions_reviewed: 3
re_verification:
  previous_status: gaps_found
  previous_score: 13/14
  gaps_closed:
    - "Gap 1（YAML 侧）：空/缺 _data/*.yml 崩溃掩盖他错 → 层① Psych.safe_load + 四级 rescue 阶梯；空文件走既有 NilClass 结构路径、缺文件得中文「文件不存在」——验证者沙箱 probe A/B 复现翻绿（跨文件全收集 + FAIL 汇总 + exit 1 + 零回溯）"
    - "Gap 2（BibTeX 侧）：非 UTF-8/缺 papers/ref.bib 崩溃于汇总前 → 层③ valid_encoding? 预检 + 三级 rescue 阶梯——probe C/D 复现翻绿（GBK 字节与缺文件各得中文消息，已收集 YAML 错误照常打印）"
  gaps_remaining: []
  regressions: [] # 13 条既往 VERIFIED truths 零回归：设计内错误类（YAML 语法/五类结构/bib 四类/D-08 提醒/干净树静默/动态计数）全部由本验证者重跑，消息逐字同形；validate.sh 与 deploy.yml 对 71dcea14 字节不变（diff 0 行）
human_verification:
  - test: "背书 3 条 judgment 级 prohibitions（P-03-1 脚本只读 / P-03-2 不拦合法内容 / P-03-3 不触碰 publications.md）"
    expected: "人工最终裁定。验证者非权威结论：三条均未违反——P-03-1 全文件零写路径（grep File.write/FileUtils/File.open/truncate/rm/mv/cp 零命中，探针后 porcelain 全洁）；P-03-2 基线（12 条中 8 条无 doi）在任何 locale 下全绿（LANG=C 实测 PASS，基线纯 ASCII）、rescue/编码变更未新增任何拒绝规则（BIB_REQUIRED 与全部结构规则零改动）；P-03-3 publications.md 仅出现于 2 处注释与 1 处提醒字符串字面量、零文件操作。P-03-2 附两项条件性关注待裁定：见下两条 locale 与 safe_load 收紧"
    why_human: "judgment 级禁制最终裁定权属开发者（ADR-550 D4）；LLM-judge 结论为非权威"
  - test: "裁定 locale 家族发现（03-REVIEW.md WR-01 + 本验证者新发现的第二个表面）：修复（须覆盖双表面）或书面接受（记录维护者环境要求 UTF-8 locale）"
    expected: "表面 ①（review 实证、本验证者复现）：LANG=C 下合法 UTF-8 中文 bib 被误判「含非 UTF-8 字节」exit 1——File.read 未指定编码模式，字符串 tag 随进程 locale。表面 ②（本验证者新发现并复现）：LANG=C + HEAD 版 ref.bib 含非 ASCII 且工作区版本纯 ASCII 时，行 210 对反引号读取的 head_bib（tag US-ASCII）做 scan 抛 ArgumentError 英文回溯——在全部 rescue 阶梯之外。注意 review 建议的一行修复（File.read 加 mode: \"r:UTF-8\"）只覆盖表面 ①，不覆盖表面 ②（head_bib 走反引号读取）；完整修复须另加 head_bib.force_encoding(\"UTF-8\") 或把 head_bib.valid_encoding? 纳入层⑥ guard。CI 不受影响（runner 固定 en_US.UTF-8）；本机 macOS 默认 UTF-8 亦不受影响；两表面均 exit 1 fail-closed 不会静默上线"
    why_human: "环境取舍与修复范围是领域决策；两项发现均不在本阶段任何 must-have truth 的字面范围（gap-closure 验收面为默认环境下的四类边界输入），但属「不拦合法内容」精神层面的条件性风险，不可静默吸收"
  - test: "裁定 SC3 坐标语义（03-REVIEW.md 新 WR-02，本验证者复现）：psych SyntaxError 的行列号是「外层构造起点」而非「错误位置」——块映射类错误在任何行报「第 1 行第 1 列」（实测：第 3 行错误报 1,1）"
    expected: "选择采纳 review 的改写（文案改为「第 N 行第 M 列开始的<结构>内…请检查该结构附近最近的编辑」——psych 5.3.1 无 problem-mark 访问器，只能限定措辞而非移动坐标）或接受现状。SC3 判定说明：文件归属无歧义、psych problem 短语真实在场、非静默、exit 1——truth 字面成立记 VERIFIED；坐标语义精度属 D-07 维护者体验裁量"
    why_human: "报错文案的可用性判断（维护者盯着第 1 行 boilerplate 是否可接受）无机器判据"
  - test: "确认 CONTENT-01 验收面充分性：probe 矩阵 a~g + 三个新发现边界输入类（空文件/缺文件/非 UTF-8）是否覆盖需求的全部行为边界（03-03-PLAN flagged_assumption 第 1 条、SUMMARY D3 coverage human_judgment=true）"
    expected: "人工确认覆盖充分或指出遗漏类别。本验证者补充证据：本轮再加 locale 条件类（上述表面 ①②）与空格后括号形态（下一条）两个残余边界——均为既有矩阵外新发现，可并入本次裁定"
    why_human: "需求行为边界完备性判断无机器判据；planner 显式留待人工、禁止自动视为已覆盖"
  - test: "裁定 safe_load 接受面收紧与 IN-01 残余形态是否收口（03-03-PLAN flagged_assumption 第 2 条 + review 新 IN-01 info，本验证者复现）"
    expected: "① safe_load(permitted_classes: [Date], aliases: true) 使未来冷门 YAML 类型标签由旧入口的静默接受转为中文拒绝——收紧而非放宽（实测 !ruby/object 被拒、unquoted ISO 日期 Date 许可后仍被结构层拦截）；开发者可否决回到 flagged_assumption 修订。② @article { key,（括号后也有空格）形态仍漏出键唯一 tally 而被计入条目数（实测 PASS 断言「键唯一」于不完整视图）——计划 truth 的既定形态 @article {key, 已被抓到（实测「引用键 spacedup 重复出现 2 次」）；一字符修复（键正则加 \\s*）可顺带收口"
    why_human: "接受面参数与残余形态是否值得再修属权衡决策（仓库现行风格统一为 @article{key,，无现实实例）"
  - test: "观察性：本地 main 领先 origin/main 9 个提交未推送——修复后脚本的首次 CI 运行将发生在下次 push（部署链 deploy.yml 字节不变、退出码契约本地全输入类实证、基线/探针全绿，预期直接继承既往红绿语义）；顺带目检 D-08 提醒文案与 CI 步骤名（既往 human_verification 第 4 条遗留目检项）"
    expected: "push 后 Validate content 步骤绿跑（log 含中文 PASS 行）；文案/步骤名目检通过"
    why_human: "CI 端到端行为最终以真实 run 为准；文案可读性属目检"
deferred: [] # Phase 3 为 ROADMAP 末位阶段——无后续阶段可承接，上述条目全部为真实待裁定/待观察项
---

# Phase 3: 内容验证 Verification Report（Re-verification after gap closure）

**Phase Goal:** 维护者更新内容时语法错误被拦截，避免静默失败
**Verified:** 2026-08-20T07:56:22Z
**Status:** human_needed（17/17 truths VERIFIED、0 gaps、0 行为未实证——但 3 条 judgment 级 prohibitions 背书 + 3 条 flagged_assumptions + 2 项 review 新警告裁定属设计上的人工确认面，不可静默吸收为 passed）
**Re-verification:** Yes — gap closure（03-03-PLAN，commits e28e6aa4 + 4bd8f987）后的复验；前次报告见 git 163da6ae（gaps_found 13/14）

**MVP mode note:** 沿用前次报告口径——ROADMAP 标注 `Mode: mvp` 但 goal 非 user-story 格式，以 goal 结果子句（「语法错误被拦截，避免静默失败」）做 goal-backward 验证。

## Goal Achievement

核心结论：**两个 critical gap 已实际收口，阶段目标在全部已验收输入类上成立，且 13 条既往 VERIFIED truths 零回归。** 四类此前以英文回溯崩溃的边界输入（空 yml / 缺 yml / GBK bib / 缺 bib）现在全部：中文报出 + 跨文件全收集 + FAIL 汇总 + exit 1 + 零回溯——全部由本验证者亲跑复现（一次性 /tmp git clone 内执行破坏性探针，真仓库 porcelain 全程干净）。WR-01/WR-02/IN-01/IN-03 同步收口且经行为面实证。validate.sh 与 deploy.yml 对 71dcea14 字节不变（diff 0 行），CI 拦截语义按 D-04 继承。剩余事项全部为计划显式设计的人工确认面（prohibitions 背书、flagged_assumptions、两项 review 新警告裁定），故记 human_needed 而非 passed。

### Observable Truths

**前次 14 条阶段 truths（复验：失败项全深检、通过项回归面复跑）**

| # | Truth | Status | Evidence（本验证者探针，除注明外均为本轮亲跑） |
|---|-------|--------|----------|
| 1 | SC1：YAML 语法错误构建前明确报出 | VERIFIED | probe E：news+grants 双坏 → 各报「第 N 行第 M 列：YAML 语法错误（…）」exit 1；deploy.yml 验证步骤仍位于 Build with Jekyll 之前（33<36<38 行，字节不变） |
| 2 | SC2：BibTeX 语法错误构建前明确报出 | VERIFIED | probe K/M/N：缺 year／截断／缺逗号 → 各以 papers/ref.bib + 键名/建议中文报出 exit 1 |
| 3 | SC3：错误信息清晰指出文件与位置 | VERIFIED（附坐标语义 caveat→human #3） | 四类定位全部在场：行列号（E）/条目序号（F/T）/引用键（K）/字段名（T）；文件归属无歧义、非静默。caveat：psych 行列号实为「外层构造起点」（review 新 WR-02，本验证者复现：第 3 行错误报 1,1）——psych 5.3.1 无 problem-mark 访问器，措辞限定属 D-07 体验裁量，已路由人工 |
| 4 | SC4：发布前经验证步骤确保语法正确 | VERIFIED | 双入口同脚本：本地 scripts/validate.sh（基线单行 PASS exit 0）+ CI Validate content（deploy.yml:36-37 字面量 run 不变）；注：修复后脚本的首个 CI run 待下次 push（human #6 观察项）——部署链字节不变、退出码契约本地全输入类实证 |
| 5 | P1-T1：一条命令 <1s、单行 PASS、动态计数、键唯一 | VERIFIED | 基线输出恰 1 行 exit 0；probe O 追加条目后 PASS 行自动变 bib=13（动态计算）；probe U 子目录同形 |
| 6 | P1-T2：YAML 语法中文报出文件+行+列、exit 1、先于构建 | VERIFIED | probe E；两脚本 grep 无 jekyll build 调用（仅头注释） |
| 7 | P1-T3：结构错误五类中文报出、exit 1 | VERIFIED | 本轮全五类重跑：role 拼错（F：列合法值 pi \| member \| student）、date 非法（G：附合法格式）、映射化（H：当前是 Hash）、Latest 非首条（S：仅允许首条）、必填缺失（T：name 字段缺失）+ 空文件走 NilClass 路径（A）——gap-closure diff 未触碰层②（diff 证），行为面复证一致 |
| 8 | P1-T4：BibTeX 错误中文报出 bib+键/字段、exit 1（四类） | VERIFIED | K（缺 year 按键名）/L（重复键「引用键 spacedup 重复出现 2 次」——原始文本 tally）/M（截断：键无法识别定位线索 ×3）/N（缺逗号：解析失败+中文建议）；N 中 bibtex-ruby gem logger 向 stderr 打一行 ERROR 属 03-01 已记录的 gem 既有行为，不影响 FAIL 行与退出码 |
| 9 | P1-T5：无 DOI 条目通过 | VERIFIED | 基线 12 条中 8 条无 doi 全绿（本轮基线 PASS 复跑）；BIB_REQUIRED 仅 title/author/year（validate.rb:173，diff 未触碰） |
| 10 | P1-T6：全部文件全部错误一次收集、单文件坏只短路自身 | **VERIFIED（前次 partial → 本轮收口）** | probe A（空 news.yml + 坏 grants.yml：「NilClass 结构消息 + grants 行列」同跑报出、FAIL: 2 个问题、exit 1、零回溯）/B（缺 news.yml：「文件不存在」+ grants 错误同跑）/C（GBK bib：编码中文消息 + 已收集 news YAML 错误照常打印）/D（缺 bib：「papers/ref.bib：文件不存在」+ news 错误照常）——四类此前崩溃输入全部翻绿，T-03-03 在层①③真正成立 |
| 11 | P2-T7：bib 条目数变化中文提醒（含 publications.md）且 exit 0 | VERIFIED | probe O：追加合法条目 → 「提醒：ref.bib 条目数 12 → 13 已变化；publications.md 为手写列表…」+ PASS exit 0；probe U 自 _data 子目录同样触发（git spec 仓库相对路径在非根 CWD 可用）；干净树零提醒 |
| 12 | P2-T8：CI 步骤位于 Setup Pages 后 Build 前、绿跑 log 可见 | VERIFIED（契约继承 + 既往端到端证据） | deploy.yml 对 71dcea14 字节不变：33(Setup Pages)<36(Validate content)<38(Build)、run 字面量不变；既往绿跑 32328680551（log 含中文 PASS 行）；修复只改脚本内部、退出码契约不变（本地全输入类实证）——修复后脚本首个 CI run 待 push（human #6） |
| 13 | P2-T9：坏提交恰在 Validate content 红、零新部署、线上旧版 | VERIFIED（契约继承 + 既往端到端证据） | 既往 gh 独立复核（run 32329006888 失败步骤恰 Validate content、deploy skipped、a4e8096c 零 deployment、revert 复绿）仍有效：CI 消费的唯一接口是退出码，修复前崩溃路径本就 exit 1（fail-closed），修复后为干净 exit 1，拦截语义只会更稳 |
| 14 | P2-T10：CI 下提醒天然静默、零 CI 特判 | VERIFIED | grep 两脚本无 HEAD^/origin/main/ENV 分支；干净树（工作区=HEAD）零提醒（设计如此非特判） |

**Gap-closure 计划（03-03）新增 truths**

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 15 | 基线单行 PASS（8 条无 doi 全绿，P-03-2 回归护栏） | VERIFIED | 真仓库 + /tmp clone 双环境基线：恰一行 `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一` exit 0 |
| 16-19 | 四类边界输入翻绿（=阶段 truth 10 的分解） | VERIFIED | probes A-D（见上表 #10）；另经 LANG=C 基线探针确认四类收口与 locale 无关（基线纯 ASCII：`LC_ALL=C grep -c -P '[\x80-\xFF]'` 对 ref.bib 与全部 _data/*.yml 计数均为 0） |
| 20 | 设计内错误类零回归、逐字同形 | VERIFIED | probes E/F/G/H/I/J/K/L/M/N/O/S/T + 干净树静默——全部经 validate.sh 入口跑出，消息与既往阶段逐字一致 |
| 21 | WR-01：任意 CWD 调用等价（ROOT=__dir__ 锚定） | VERIFIED | `(cd _data && ../scripts/validate.sh)` 与 `(cd papers && ../scripts/validate.sh)` 输出与根调用逐字相同（同 PASS 行 exit 0）；probe U 自子目录 D-08 提醒照常触发（git spec 仓库相对 key link 实证） |
| 22 | WR-02：safe_load 入口、to_ruby 彻底消失、类型标签中文拒绝 | VERIFIED | 源码：`Psych.safe_load(File.read(File.join(ROOT, path)), permitted_classes: [Date], aliases: true)`（validate.rb:46-47）、`to_ruby` 全文件含注释 0 命中；行为面：probe I `!ruby/object:Kernel` → 「news.yml：含不支持的 YAML 类型标签（Tried to load unspecified class: Kernel）…」exit 1 零回溯零实例化；probe J unquoted ISO 日期 `2026-05-01` → Date 许可解析后仍被结构层「date 格式不合法」拦截（接受面与设计拦截路径一致） |
| 23 | IN-01 空格形态重复键入 tally + IN-03 死初始化移除 | VERIFIED | probe L：`@article{spacedup,` + `@article {spacedup,` 混合 → 「引用键 spacedup 重复出现 2 次」exit 1（计划既定形态）；源码：两正则共享 opener 子模式 `@\s*[a-zA-Z]\w*\s*\{`（192/210 行）、`counts = {}` 0 命中（transform_values 唯一初始化）。残余 `@article { key,`（括号后空格）形态仍漏检（review 新 info，本验证者复现）——不在计划 truth 字面内，路由 human #5 |

**Score:** 17/17 truths verified（14 阶段 truths 含前次失败的 truth 10 收口 + 3 条 gap-closure 新增 truths）；0 present-behavior-unverified（全部行为依赖型 truth 有本验证者亲跑探针或既往端到端 CI 证据 + 字节不变契约链）

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `scripts/validate.rb` | 抗崩收口：safe_load 四级 rescue + 编码预检三级 rescue + ROOT 锚定 + 正则同源化 + 死代码清除；中文输出与 exit 契约不变 | VERIFIED | 241 行实质实现全量通读；diff 71dcea14..HEAD +49/−11 恰为计划变更面（层①入口/阶梯、层③ raw/预检/阶梯、ROOT、层⑤⑥正则、guard、死初始化、注释纠偏），层②结构与全部中文消息文案零改动；存在、实质、接线（validate.sh 与 deploy.yml 双入口消费）、数据流全四层通过 |
| `scripts/validate.sh` | 零改动（字节不变） | VERIFIED | `git diff 71dcea14..HEAD -- scripts/validate.sh` 0 行；3 行 exec 透传入口，全部探针经它发起 |
| `.github/workflows/deploy.yml` | 零改动（字节不变），Validate content 步骤原样 | VERIFIED | diff 0 行；33<36<38 步骤序、run 字面量、needs: build 拦截链原样 |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| validate.rb 全部 File I/O | _data/*.yml + papers/ref.bib | File.join(ROOT, path)，ROOT = File.expand_path("..", __dir__) | WIRED | 源码 3 处 File.join(ROOT（46/153 行锚定两族文件）；行为面：_data 与 papers 子目录调用输出与根调用逐字相同 |
| D-08 层 git 命令 | HEAD:papers/ref.bib | 仓库相对路径 spec（git 层禁绝对路径） | WIRED | validate.rb:215-216；行为面：probe U 自 _data 子目录触发 12→13 提醒（非根 CWD 下 spec 可用） |
| deploy.yml Validate content | bundle exec ruby scripts/validate.rb | 字面量 run 命令 | WIRED | deploy.yml:37；workflow 字节不变，CI 经脚本自身修复继承（退出码契约本地全类实证） |
| Validate content exit 1 | 无 artifact → deploy 不跑 → 线上旧版 | needs: build 拦截链 | WIRED（既往端到端 + 契约不变） | 既往 gh 复核证据有效；修复仅将崩溃式 exit 1 转为干净 exit 1 |
| validate.sh | validate.rb | exec bundle exec ruby 透传 | WIRED | validate.sh:3；26 条探针全走此链路 |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|--------------|--------|-------------------|--------|
| PASS 行 | counts（transform_values + bib.length） | 真实解析 5 yml + ref.bib | 是——probe O 追加条目自动 12→13 | FLOWING |
| FAIL 行与错误清单 | errors 数组 | 六层真实检查 + rescue 阶梯 | 是——18 类注入错误各自命中，四类边界输入也进数组 | FLOWING |
| D-08 提醒 | head_count/work_count | git show HEAD vs 工作区 raw 原文计数 | 是——未提交变化触发、干净树静默、子目录同触发 | FLOWING |

### Behavioral Spot-Checks（本验证者亲跑；A-U 于一次性 /tmp git clone，R0/R0b/R0c 于真仓库只读；真仓库 porcelain 全程 0）

| # | Behavior | Command 要点 | Result | Status |
|---|----------|-------------|--------|--------|
| R0 | 基线（真仓库） | scripts/validate.sh | 恰 1 行 PASS exit 0 | PASS |
| R0b | 子目录调用 ×2 | (cd _data / papers && ../scripts/validate.sh) | 与根调用逐字相同 PASS exit 0 | PASS |
| R0c | LANG=C 基线（真仓库，纯 ASCII） | env LANG=C LC_ALL=C scripts/validate.sh | PASS exit 0（locale 不影响现基线） | PASS |
| A | 空 news.yml + 坏 grants.yml | : > news.yml; 坏 grants | NilClass 结构消息 + grants 行列，FAIL: 2，exit 1，零回溯 | PASS（前 gap 1 翻绿） |
| B | 缺 news.yml + 坏 grants.yml | mv 移走 | 「news.yml：文件不存在——请勿删除或改名数据文件」+ grants 错误，exit 1 | PASS（前 gap 1 翻绿） |
| C | GBK 字节 ref.bib + 坏 news.yml | \xd6\xd0\xce\xc4 注入 | 「含非 UTF-8 字节…请以 UTF-8 重新保存」+ news YAML 错误照常打印，exit 1 | PASS（前 gap 2 翻绿） |
| D | 缺 ref.bib + 坏 news.yml | mv 移走 | 「papers/ref.bib：文件不存在…」+ news 错误，exit 1，零回溯 | PASS（前 gap 2 翻绿） |
| E | 双 YAML 语法错 | news+grants 同坏 | 各报行列，FAIL: 2，exit 1 | PASS |
| F | role 拼错 | student→studnet | 列合法值，exit 1 | PASS |
| G | date 非法 | May 2026→2026-05 | 附合法格式，exit 1 | PASS |
| H | 映射化 | 剥 "- " 前缀 | 当前是 Hash，exit 1 | PASS |
| I | !ruby/object:Kernel 标签 | 追加 | 中文类型标签拒绝，exit 1，零回溯零实例化 | PASS（WR-02 行为面） |
| J | unquoted ISO 日期 | date: 2026-05-01 | Date 许可解析 → 结构层「date 格式不合法」，exit 1 | PASS（接受面行为一致） |
| K | bib 缺 year | 追加 probeyear | 按键名报 year 字段缺失，exit 1 | PASS |
| L | 空格形态重复键 | {spacedup, + { spacedup, | 「引用键 spacedup 重复出现 2 次」，exit 1 | PASS（IN-01 既定形态） |
| M | bib 截断 | title={截断 | 无法识别键线索 ×3，exit 1 | PASS |
| N | bib 缺逗号 | title={t} author={a} | 解析失败+中文建议，exit 1（gem logger stderr ERROR 行为既有） | PASS |
| O | D-08 提醒 | 追加合法条目 | 提醒 12→13 + publications.md + PASS(bib=13) exit 0 | PASS（动态计数并证） |
| S | Latest 非首条 | 第 2/3 条 Latest | 仅允许首条，exit 1 | PASS |
| T | 必填缺失 | grants name→label | 「第 N 条：name 字段缺失」，exit 1 | PASS |
| U | D-08 自子目录 | (cd _data …) 追加条目 | 提醒照常触发 exit 0 | PASS |
| P | `@article { key,`（括号后空格）形态 | review IN-01 残余复现 | bib=13 计入但 tally 漏检 → PASS 断言「键唯一」于不完整视图，exit 0 | 确认 review 残余成立（→human #5，非 truth 违例） |
| Q | 合法 UTF-8 中文 bib × LANG=C | review WR-01 复现 | 正常 locale PASS；LANG=C 误判「含非 UTF-8 字节」exit 1 | 确认 review 警告成立（→human #2） |
| V | LANG=C + HEAD bib 非 ASCII + 工作区纯 ASCII | 本验证者新探针 | validate.rb:210 `String#scan: invalid byte sequence in US-ASCII (ArgumentError)` 英文回溯——rescue 阶梯之外（exit 1 fail-closed） | 新发现崩溃面（→human #2；review 一行修复不覆盖） |

### Probe Execution

无 `scripts/*/tests/probe-*.sh` 文件——本阶段探针为 PLAN `<verify>` 内联命令。验证者已在一次性 /tmp git clone 等效重跑 03-03-PLAN Task 1/2 的全部验收探针（上表 A-U）并追加 3 项裁定探针（P/Q/V），真仓库仅只读探针（R0 系列）；clone 已删除，真仓库 `git status --porcelain` 为 0。

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|------------|------------|-------------|--------|----------|
| CONTENT-01 | 03-01, 03-02, 03-03 | 发布前校验 _data/*.yml 与 papers/ref.bib 语法，错误明确报出而非静默失败 | SATISFIED | 17/17 truths：双入口全链路 + 四类边界输入收口 + 设计内错误类零回归；REQUIREMENTS.md Traceability（Phase 3/Complete）与实际一致。附注：验收面充分性与 prohibitions 背书按计划设计路由人工（human #1/#4） |

Orphaned requirements: 无——映射到 Phase 3 的仅 CONTENT-01，三个计划均声明。

### Anti-Patterns Found

三交付文件零 debt marker（TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER 全无）、零写路径、publications.md 仅存在于注释与提醒文案。纳入裁定项：

| Finding | File:Line | Pattern | Severity | Impact |
|---------|-----------|---------|----------|--------|
| locale 误拦（review WR-01） | validate.rb:153-157 | File.read 无编码模式 → LANG=C 下合法 UTF-8 非 ASCII 内容误判 | WARNING → human #2 | 本地维护者陷阱（CI/macOS 默认不受影响）；不影响现纯 ASCII 基线 |
| locale 崩溃面（本验证者新发现） | validate.rb:210,216-224 | 反引号 head_bib 在 LANG=C 下可带无效 tag 进入 scan，rescue 阶梯外抛 ArgumentError | WARNING → human #2 | 条件：LANG=C + HEAD/工作区 bib 编码分化；exit 1 fail-closed；review 建议修复不覆盖此面 |
| psych 坐标=构造起点（review WR-02） | validate.rb:48-49 | 块映射错误恒报 1,1，误导维护者 | WARNING → human #3 | 文案精度问题，不误拦不崩溃；SC3 字面成立 |
| tally 残余形态（review IN-01） | validate.rb:192 | `\{([^,\s]+)` 不跳括号后空格 | Info → human #5 | 潜在漏检，仓库无此形态实例 |
| deploy.yml 顶层 permissions（review IN-02） | deploy.yml:13-16 | build job 不需要 pages/id-token 写权 | Info（Phase 2 既有结构） | 记录在案，非本阶段缺陷 |

### Decision Coverage

D-01~D-08 全部在交付物中落地且 gap-closure diff 零违背：结构规则/必填集/提醒文案逐字未动（D-01/02/03/08），deploy.yml 与 validate.sh 字节不变（D-04/05），psych 仍为唯一"新"依赖面（default gem，D-06），中文消息与行列/条目/键/字段定位保留（D-07）。前次报告 8/8 honored 结论延续有效。

### Human Verification Required

见 frontmatter `human_verification`（6 项）：① P-03-1/2/3 prohibitions 背书（非权威结论：均未违反）；② locale 家族双表面裁定（修复须覆盖 File.read 编码模式 + head_bib tag/guard 两处，或书面接受并记录环境要求）；③ SC3 坐标措辞裁定（采纳 review 改写或接受构造起点语义）；④ CONTENT-01 验收面充分性确认（a~g + 3 边界类 + 本轮新补 locale 类/空格后括号形态）；⑤ safe_load 接受面收紧与 tally 残余形态是否再收口；⑥ push 后观察修复脚本首个 CI 绿跑 + D-08 文案/步骤名目检。

### Gaps Summary

无 gap。前次两个 critical gap（CR-01/CR-02）经代码实现与本验证者探针双重复核确认收口：层①四級、层③三級 rescue 阶梯使「收集一切、中文报出、永不崩溃」契约在全部计划内输入类上成立，四类崩溃输入翻绿且 13 条既往 truths 零回归、validate.sh/deploy.yml 字节不变。阶段目标「维护者更新内容时语法错误被拦截，避免静默失败」在本机一条命令与 CI 双入口、设计内错误类与边界输入类上全部实测成立。剩余 6 项均为计划显式设计或 review 裁定遗留的人工确认面（judgment 级 prohibitions、flagged_assumptions、两项新警告的处置、首推 CI 观察）——按裁决树规则 2 记 human_needed；其中 locale 家族（human #2）建议优先裁定，因其为唯一带行为影响的开放项（两表面均 fail-closed，无静默上线风险）。

---

_Verified: 2026-08-20T07:56:22Z_
_Verifier: Claude (gsd-verifier)_
