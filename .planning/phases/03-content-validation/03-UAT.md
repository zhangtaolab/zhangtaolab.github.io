---
status: testing
phase: 03-内容验证
source: [03-VERIFICATION.md]
started: 2026-08-20T07:58:38Z
updated: 2026-08-20T07:58:38Z
---

## Current Test

number: 1
name: 背书 3 条 judgment 级 prohibitions（P-03-1 脚本只读 / P-03-2 不拦合法内容 / P-03-3 不触碰 publications.md）
expected: |
  人工最终裁定。验证者非权威结论：三条均未违反——
  P-03-1：全文件零写路径（grep File.write/FileUtils/File.open/truncate/rm/mv/cp 零命中，探针后 porcelain 全洁）；
  P-03-2：基线（12 条 bib 中 8 条无 doi）任何 locale 下全绿（LANG=C 实测 PASS，基线纯 ASCII），rescue/编码变更未新增拒绝规则（BIB_REQUIRED 与结构规则零改动）；
  P-03-3：publications.md 仅出现于 2 处注释与 1 处提醒字符串字面量，零文件操作。
  P-03-2 附两项条件性关注：见测试 2（locale）与测试 5（safe_load 收紧）。
awaiting: user response

## Tests

### 1. 背书 3 条 judgment 级 prohibitions（P-03-1 / P-03-2 / P-03-3）
expected: 人工最终裁定（验证者非权威结论：均未违反，证据见 Current Test）。裁定权属开发者（ADR-550 D4）。
result: [pending]

### 2. 裁定 locale 家族发现（03-REVIEW WR-01 + 验证者新发现的第二表面）：修复（须覆盖双表面）或书面接受
expected: |
  表面 ①（review 实证 + 验证者复现）：LANG=C 下合法 UTF-8 中文 bib 被误判「含非 UTF-8 字节」exit 1——File.read 未指定编码模式，字符串 tag 随进程 locale。
  表面 ②（验证者新发现并复现）：LANG=C + HEAD 版 ref.bib 含非 ASCII 且工作区纯 ASCII 时，行 210 对反引号读取的 head_bib 做 scan 抛 ArgumentError 英文回溯——在全部 rescue 阶梯之外。
  注意：review 建议的一行修复（File.read 加 mode:"r:UTF-8"）只覆盖表面 ①；完整修复须另加 head_bib.force_encoding("UTF-8") 或把 head_bib.valid_encoding? 纳入层⑥ guard。
  CI 不受影响（runner 固定 en_US.UTF-8）；本机 macOS 默认 UTF-8 不受影响；两表面均 exit 1 fail-closed，不会静默上线。
result: [pending]

### 3. 裁定 SC3 坐标语义（03-REVIEW 新 WR-02，验证者复现）：psych 行列号是「外层构造起点」非「错误位置」
expected: |
  实测：第 3 行的块映射错误报「第 1 行第 1 列」。psych 5.3.1 无 problem-mark 访问器，只能限定措辞（review 建议：文案改为「第 N 行第 M 列开始的<结构>内…请检查该结构附近最近的编辑」）或接受现状。
  truth 字面成立（文件归属无歧义、problem 短语在场、非静默、exit 1，已记 VERIFIED）；坐标语义精度属 D-07 维护者体验裁量。
result: [pending]

### 4. 确认 CONTENT-01 验收面充分性：probe 矩阵 a~g + 三个新边界输入类（空文件/缺文件/非 UTF-8）覆盖全部行为边界
expected: |
  人工确认覆盖充分或指出遗漏类别（03-03-PLAN flagged_assumption 第 1 条、SUMMARY D3 human_judgment=true，禁止自动视为已覆盖）。
  验证者补充证据：本轮再加 locale 条件类（测试 2 表面 ①②）与空格后括号形态（测试 5 ②）两个残余边界，可并入本次裁定。
result: [pending]

### 5. 裁定 safe_load 接受面收紧与 IN-01 残余形态是否收口
expected: |
  ① safe_load(permitted_classes:[Date], aliases:true) 使未来冷门 YAML 类型标签由静默接受转为中文拒绝——收紧而非放宽（实测 !ruby/object 被拒；unquoted ISO 日期 Date 许可后仍被结构层拦截）；可否决回到 flagged_assumption 修订。
  ② @article { key,（括号后也有空格）形态仍漏出键唯一 tally 而被计入条目数（实测 PASS 断言「键唯一」于不完整视图）；计划既定形态 @article {key, 已被抓到；一字符修复（键正则加 \s*）可顺带收口。仓库现行风格统一为 @article{key,，无现实实例。
result: [pending]

### 6. 观察性：push 后首跑 CI + D-08 文案/步骤名目检
expected: |
  本地 main 领先 origin/main 9 个提交未推送——修复后脚本的首次 CI 运行将发生在下次 push（deploy.yml 字节不变、退出码契约本地全输入类实证，预期直接继承红绿语义）。
  push 后确认 Validate content 步骤绿跑（log 含中文 PASS 行）；顺带目检 D-08 提醒文案与 CI 步骤名。
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
