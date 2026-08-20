# Phase 3: 内容验证 - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-08-20
**Phase:** 3-内容验证
**Areas discussed:** 验证深度、验证入口、工具与依赖、bib 同步提醒

---

## 验证深度

### Q1: YAML 验证做到多深？

| Option | Description | Selected |
|--------|-------------|----------|
| 语法+结构检查 | 除语法外检查每类数据的必填字段与格式；Phase 1 feed 日期静默过滤是结构级失败前科 | ✓ |
| 仅语法解析 | 只验证能否解析；字段写错、必填缺失依然静默通过 | |
| 语法+结构+路径存在 | 再加图片路径存在性检查；防护全但需随图片目录维护 | |

**User's choice:** 语法+结构检查
**Notes:** 背景说明：Jekyll 构建对 YAML 语法错误本就会红（文件+行号），「仅语法」增值有限；结构级错误才是 Jekyll 静默吞掉的那类。

### Q2: news.yml 的 date 字段怎么验证？

| Option | Description | Selected |
|--------|-------------|----------|
| 按现状定规则 | 允许 "Latest"（特殊值）与 "Month YYYY" 正则；数据与 feed 回退不动 | ✓ |
| 数据改 ISO 双字段 | news.yml 改 ISO 日期 + display_date；要改数据、feed.xml、模板三处 | |
| 日期不检查 | 跳过 date 字段；日期写错依然静默 | |

**User's choice:** 按现状定规则
**Notes:** 现状数据全是展示字符串（"Latest"、"May 2026"），Phase 1 feed.xml 曾因此被动加 site.time 回退。

### Q3: papers/ref.bib 验证到什么程度？

| Option | Description | Selected |
|--------|-------------|----------|
| 解析+必填+键唯一 | title/author/year 必填 + 引用键唯一；直接对应新增论文最易犯的错 | ✓ |
| 仅解析 | 括号闭合、@类型合法；字段缺失、键重复不拦 | |
| 全字段严格 | 再查 DOI/URL 格式等；现有条目 DOI 本非全有，规则须宽松否则误报 | |

**User's choice:** 解析+必填+键唯一
**Notes:** 重复引用键在不少工具里是静默覆盖。

---

## 验证入口

### Q1: 验证在哪里跑？

| Option | Description | Selected |
|--------|-------------|----------|
| 本地+CI 双入口 | 本地推送前自查 + CI 构建前步骤，同一脚本两处复用；与 Phase 2 ci-smoke 模式一致 | ✓ |
| 仅 CI | 只在 deploy.yml 跑；零本地负担但反馈慢 | |
| 仅本地 | 只自查；忘跑时结构级错误无人把门 | |

**User's choice:** 本地+CI 双入口
**Notes:** CI 位置按路线图成功标准「构建前被明确报出」处理：deploy.yml 的 Build with Jekyll 之前独立步骤。

### Q2: 本地验证怎么触发？

| Option | Description | Selected |
|--------|-------------|----------|
| 手动命令即可 | scripts/validate.sh 一条命令几秒出结果；忘了跑有 CI 兜底 | ✓ |
| 命令+pre-commit 钩子 | 提交含 _data/papers 改动时自动跑；跨机不可同步、单人收益有限 | |
| 并入 jekyll build | 不加新命令；但构建慢且结构级错误仍不报 | |

**User's choice:** 手动命令即可
**Notes:** —

---

## 工具与依赖

### Q1: 验证工具怎么选？

| Option | Description | Selected |
|--------|-------------|----------|
| 纯 Ruby 零新增依赖 | psych 标准库 + bibtex-ruby（已锁入 Gemfile.lock）；零新增安装 | ✓ |
| yamllint + bibtex-ruby | YAML 用 yamllint；本机与 CI 都要装 Python 工具链 | |
| Schema 工具链 | CUE/JSON Schema 等；对 5 个小数据文件过重 | |

**User's choice:** 纯 Ruby 零新增依赖
**Notes:** STATE.md「待确认项」中的「YAML/BibTeX 验证工具选型」就此关闭。

### Q2: 验证报错信息用什么语言？

| Option | Description | Selected |
|--------|-------------|----------|
| 中文描述 | 如「news.yml 第 3 条：date 字段缺失」；文件/字段/行号原样 | ✓ |
| 英文 | 与工具链日志一致；中文维护者阅读稍慢 | |
| 中英双语 | 兼顾两边但输出冗长 | |

**User's choice:** 中文描述
**Notes:** —

---

## bib 同步提醒

### Q1: 要不要把「bib↔publications.md 双写遗漏」纳入验证？

| Option | Description | Selected |
|--------|-------------|----------|
| 提醒不阻断 | git diff 检出 ref.bib 条目数变化 → 中文提醒；退出码 0 不误伤 | ✓ |
| 不纳入，记入推迟 | 严守路线图语法验证边界；双写遗漏继续无人把门 | |
| 硬校验对应关系 | DOI 逐条比对（Phase 2 审计法）；手写 markdown 与 bib 非一一对应，易误报阻断 | |

**User's choice:** 提醒不阻断
**Notes:** 讨论中先摆明事实：publications.md 为手写 89 条（页面实际内容源），只改 ref.bib 页面不显示新论文且构建不报错——属本项目特有的静默失败，虽超出「语法验证」字面边界但正中阶段目标「避免静默失败」。

---

## Claude's Discretion

- 5 个数据文件逐文件 schema 字段清单（从现有内容推导；现有数据必须全绿）
- 验证脚本内部结构、输出排版（仿 ci-smoke.sh 的 PASS/FAIL 风格）
- CI 步骤命名与插入细节
- CI 端 diff 语义（对比上一提交或跳过提醒）——提醒主要面向本地工作区改动
- "Latest" 特殊值的约束细节

## Deferred Ideas

- 图片路径存在性检查——本轮评估后不加；错图/死图频发时可再立项
- 反向同步提醒（publications.md 变化提醒补 ref.bib）——失败不可见（talks 页本就渲染空），收益低
