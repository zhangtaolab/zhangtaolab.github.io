# Phase 3: 内容验证 - Context

**Gathered:** 2026-08-20
**Status:** Ready for planning

<domain>
## Phase Boundary

维护者更新内容时语法错误被拦截，避免静默失败（CONTENT-01）。交付一套内容验证能力：本地手动命令 + CI 构建前独立步骤（同一脚本两处复用），验证 `_data/*.yml`（语法+结构）与 `papers/ref.bib`（解析+必填+键唯一），报错中文描述且明确到文件与位置；附带 ref.bib 条目数变化时的 publications.md 同步提醒（警告不阻断）。

不做：链接检查（QUAL-01，v2）、内容更新指南文档（CONT-01/02，v2）、图片路径存在性检查（本轮评估后不加）、pre-commit 钩子、任何数据文件或模板的改动。

实现需求：CONTENT-01。

</domain>

<decisions>
## Implementation Decisions

### 验证深度
- **D-01:** YAML 验证 = 语法解析 + 结构检查（每类数据的必填字段与格式）。不含图片路径存在性检查。理由：字段名写错（如 `headlin`）、必填项缺失这类维护错误 Jekyll 构建不报错、页面直接缺内容——结构级静默失败已有前科（Phase 1 feed 日期被静默过滤）；路径检查防护面窄且需随图片目录维护
- **D-02:** `news.yml` 的 `date` 字段按现状定规则：允许 `"Latest"`（特殊值）与 `"Month YYYY"` 展示格式（正则校验），其余格式报错。数据文件不动、`feed.xml` 的 `site.time` 回退逻辑不动 — **Reversibility:** costly — 若未来改主意转 ISO 日期，需同时改数据、feed.xml、news 页模板三处
- **D-03:** `papers/ref.bib` 验证 = BibTeX 解析成功 + 每条必填 title/author/year + 引用键唯一（重复键是静默覆盖的典型来源）。DOI 非必填（现状 wang2026maize 等条目本就无 doi，规则须宽容到不误报）

### 验证入口
- **D-04:** 本地 + CI 双入口，**同一脚本两处复用**：本地维护者手动命令；CI 在 `deploy.yml` build job 的 `Build with Jekyll` 步骤**之前**加独立验证步骤（路线图成功标准「构建前被明确报出」；错误信息不被 Jekyll 构建日志淹没；验证红 → build job 红 → 无工件 → 不部署，线上保持旧版——沿用 Phase 2 断言先于 upload-pages-artifact 的既有语义）
- **D-05:** 本地 = 手动一条命令（`scripts/validate.sh` 风格，与 ci-smoke.sh 同目录同范式），**不装 pre-commit 钩子**（跨机不可同步、单人维护收益有限）；忘了跑有 CI 兜底

### 工具与依赖
- **D-06:** 纯 Ruby 零新增依赖：YAML 解析用 Ruby 标准库 psych（零安装），BibTeX 用 bibtex-ruby（已随 jekyll-scholar 锁在 Gemfile.lock，本地/CI 均现成），`bundle exec` 运行。不引入 yamllint（Python 工具链）、不用 Schema 工具链（对 5 个小数据文件过重）— **Reversibility:** reversible
- **D-07:** 报错信息**中文描述**，文件名/字段名/行号保持原样（如「news.yml 第 3 条：date 字段缺失」）。维护者阅读成本最低，CI 日志同样可读

### bib 同步提醒
- **D-08:** 纳入验证但**警告不阻断**：git diff 检出 `ref.bib` 条目数变化时，输出中文提醒「publications.md 为手写列表，请确认已同步新增/删除条目」，退出码保持 0（不误伤正常提交）。背景：publications.md 是手写 89 条列表（页面实际内容源），只改 ref.bib 页面不显示新论文且构建不报错——本项目特有的静默失败陷阱。不做 bib↔markdown 硬校验对应（Phase 2 审计的 DOI 逐条比对属一次性人工流程，常规验证里易误报阻断）

### Claude's Discretion
- 5 个数据文件（news/team_members/pi/alumni/grants）逐文件的 schema 字段清单：从现有文件内容推导，**现有数据必须全绿**（基线不引入新失败）
- 验证脚本内部结构（单 Ruby 脚本 vs shell 包装调用 ruby）、输出排版（PASS/FAIL 行风格仿 ci-smoke.sh）
- CI 步骤命名与插入细节
- CI 端 diff 语义（对比上一提交或在 CI 跳过提醒）——提醒主要面向本地工作区未提交改动
- `"Latest"` 特殊值的约束细节（仅允许首条 vs 任意位置）

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### 项目规划事实源
- `.planning/REQUIREMENTS.md` — CONTENT-01 定义（Phase 3 唯一需求）+ v2 推迟项边界（QUAL-01 链接检查、CONT-01/02 文档均不在本阶段）
- `.planning/ROADMAP.md` — Phase 3 目标与 4 条成功标准（§ Phase Details）
- `.planning/PROJECT.md` — prohibitions（publications.md 手写 89 条不可替换）、Key Decisions 表、本机环境实测记录
- `.planning/STATE.md` — 待确认项「YAML/BibTeX 验证工具选型」（本 CONTEXT 已决策）；Ruby 4.0.6 + Jekyll 4.4.1 版本决策全记录

### 上游阶段产物
- `.planning/phases/02-auto-deploy/02-CONTEXT.md` — D-08 冒烟断言、D-09 验证模式、D-16 部署闸门：本阶段 CI 集成复用的决策链来源

### 代码集成点
- `scripts/ci-smoke.sh` — 现有断言脚本范式（`set -euo pipefail` + 逐条断言 + PASS 汇总行），新验证脚本的直接参照
- `.github/workflows/deploy.yml` — CI 插入点：build job 的 `Build with Jekyll` 步骤之前（D-04）
- `Gemfile` / `Gemfile.lock` — bundle exec 运行环境；bibtex-ruby 经 jekyll-scholar 依赖在列的证据（D-06）

### 验证对象与 schema 推导源
- `_data/news.yml`、`_data/team_members.yml`、`_data/pi.yml`、`_data/alumni.yml`、`_data/grants.yml` — 结构规则的推导源（现有内容即基线）
- `papers/ref.bib` — BibTeX 验证对象（现状 12 条 @article；wang2026maize 无 doi 为 DOI 非必填的实证）
- `feed.xml` — news 日期不可解析时的 `site.time` 回退现状（D-02 明确不动）

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `scripts/ci-smoke.sh`：断言脚本范式可直接套用（逐条检查 + FAIL 即 exit 1 + 末行 PASS 汇总）
- `Gemfile.lock` 中的 bibtex-ruby（jekyll-scholar 依赖链）：本地与 CI（bundler-cache: true）都现成可用，零安装
- Ruby 标准库 psych：YAML 解析自带行号报错（`Psych::SyntaxError`），结构检查可在此基础上叠加字段级断言

### Established Patterns
- Phase 2 断言先于 upload-pages-artifact：验证红 = 无工件 = 不部署 = 线上保持旧版（本阶段在 CI 构建前再加一道更早的拦截）
- `.ruby-version` 为本地/CI Ruby 版本单一事实源；一切 Ruby 脚本经 `bundle exec` 运行
- Jekyll 构建对 `_data/*.yml` 语法错误本就会红并报文件+行号——验证脚本的增量价值在**结构级检查**（Jekyll 静默吞掉的）与**独立快速入口**（不跑全站编译）

### Integration Points
- `deploy.yml` build job：`Setup Ruby` 之后、`Build with Jekyll` 之前插入验证步骤
- `scripts/` 目录：新增验证脚本，与 ci-smoke.sh 并列
- 本地维护者工作流：推送前 `scripts/validate.sh`（具体命令名由 planner 定）

</code_context>

<specifics>
## Specific Ideas

- 报错格式期望（用户认可的示例）：「news.yml 第 3 条：date 字段缺失」——中文描述 + 文件/条目定位
- news.yml 现状 date 值：`"Latest"`（首条）、`"May 2026"`、`"March 2026"` 等——规则按此现状制定
- 提醒文案方向（D-08）：「publications.md 为手写列表，请确认已同步新增/删除条目」

</specifics>

<deferred>
## Deferred Ideas

- 图片路径存在性检查（如 team 成员 photo 对应 images/ 文件存在）——讨论中评估后本轮不加；未来若错图/死图频发可再立项
- 反向同步提醒（publications.md 变化时提醒补 ref.bib）——D-08 仅锁 ref.bib 方向（可见的静默失败方向）；反向失败不可见（talks 页本就渲染空），收益低

</deferred>

---
*Phase: 3-内容验证*
*Context gathered: 2026-08-20*
