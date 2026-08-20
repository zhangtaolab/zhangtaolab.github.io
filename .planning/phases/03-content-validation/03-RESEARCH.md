# Phase 3: 内容验证 - Research

**Researched:** 2026-08-20
**Domain:** Jekyll 静态站点的内容验证工具（Ruby psych YAML 校验 + bibtex-ruby BibTeX 校验 + GitHub Actions CI 集成）
**Confidence:** HIGH

## Summary

本阶段的核心技术事实全部在本机（Ruby 4.0.6 / Jekyll 4.4.1 / bibtex-ruby 6.2.0，即 Gemfile.lock 锁定组合）以破坏性实验逐一证实。两个最重要的实证发现构成整个阶段的存在理由：① `papers/ref.bib` 末条目截断（未闭合大括号）时 `jekyll build` **退出码 0、零告警**，仅 stderr 打一行 Lexer WARN——完全静默通过；② `_data/news.yml` 被维护者写成映射而非列表时（丢掉 `- `），构建同样 **退出码 0、零告警**，新闻内容从所有页面直接消失。这两类就是 D-01/D-03 要拦截的静默失败，且**都无法依赖 Jekyll 构建本身发现**——验证脚本是唯一防线。

bibtex-ruby 6.2.0 的宽容解析行为已完整测绘：缺逗号/缺引用键会抛 `BibTeX::ParseError`（但消息无文件名无行号，只有 `$end` 之类 token 碎片）；lexer 级未闭合内容只 WARN 不抛异常，条目以**空字段**存活；**重复引用键被静默改名**（k,k,k → k,l,m）而非报错或丢弃——重复检测必须在原始文本上用正则做，不能依赖解析器。psych 则相反地友好：`Psych::SyntaxError` 自带 `file/line/column/problem/context` 五个属性，D-07 要求的「中文描述 + 文件/条目定位」可直接组装。按现有 5 个数据文件推导的 schema 原型已实测跑通，**当前基线 0 错误全绿**（D-01 的基线约束成立）。

CI 侧（D-04）插入点已确认：`deploy.yml` build job 的步骤序列为 Checkout → Setup Ruby（bundler-cache，bibtex-ruby 现成）→ Setup Pages → Build with Jekyll → Smoke assertions → Upload artifact，验证步骤放在 Setup Ruby 之后、Build with Jekyll 之前即可。D-08 的 ref.bib 条目数对比在 CI 上有 fetch-depth 陷阱（checkout@v4 默认 depth 1，`git diff HEAD^` 不可用），但用 `git show HEAD:papers/ref.bib` 对比工作区与 HEAD 的方案在 depth 1 下天然成立，且在 CI（工作区=HEAD）自动变为无操作，无需特判跳过。

**Primary recommendation:** 单一 Ruby 脚本 `scripts/validate.rb`（`bundle exec ruby` 运行，psych + bibtex-ruby，零新增依赖），外加 2 行 `scripts/validate.sh` 包装（维护者少敲 `bundle exec`）；BibTeX 校验做三层（parse 异常 + 每条必填 title/author/year + 原始正则键唯一），YAML 校验做两层（psych 语法 + 逐文件结构 schema）；收集全部错误一次性报告（非 fail-fast）；CI 在 `Setup Ruby` 后、`Build with Jekyll` 前插一步 `bundle exec ruby scripts/validate.rb`。

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** YAML 验证 = 语法解析 + 结构检查（每类数据的必填字段与格式）。不含图片路径存在性检查。
- **D-02:** `news.yml` 的 `date` 字段按现状定规则：允许 `"Latest"`（特殊值）与 `"Month YYYY"` 展示格式（正则校验），其余格式报错。数据文件不动、`feed.xml` 的 `site.time` 回退逻辑不动。
- **D-03:** `papers/ref.bib` 验证 = BibTeX 解析成功 + 每条必填 title/author/year + 引用键唯一。DOI 非必填。
- **D-04:** 本地 + CI 双入口，**同一脚本两处复用**：本地维护者手动命令；CI 在 `deploy.yml` build job 的 `Build with Jekyll` 步骤**之前**加独立验证步骤。
- **D-05:** 本地 = 手动一条命令（`scripts/validate.sh` 风格，与 ci-smoke.sh 同目录同范式），**不装 pre-commit 钩子**。
- **D-06:** 纯 Ruby 零新增依赖：YAML 用 Ruby 标准库 psych（零安装），BibTeX 用 bibtex-ruby（已随 jekyll-scholar 锁在 Gemfile.lock），`bundle exec` 运行。不引入 yamllint、不用 Schema 工具链。
- **D-07:** 报错信息**中文描述**，文件名/字段名/行号保持原样（如「news.yml 第 3 条：date 字段缺失」）。
- **D-08:** bib 同步提醒**警告不阻断**：git 检出 `ref.bib` 条目数变化时输出中文提醒「publications.md 为手写列表，请确认已同步新增/删除条目」，退出码保持 0。

### Claude's Discretion
- 5 个数据文件逐文件的 schema 字段清单：从现有文件内容推导，**现有数据必须全绿**（基线不引入新失败）
- 验证脚本内部结构（单 Ruby 脚本 vs shell 包装调用 ruby）、输出排版（PASS/FAIL 行风格仿 ci-smoke.sh）
- CI 步骤命名与插入细节
- CI 端 diff 语义（对比上一提交或在 CI 跳过提醒）
- `"Latest"` 特殊值的约束细节（仅允许首条 vs 任意位置）

### Deferred Ideas (OUT OF SCOPE)
- 图片路径存在性检查（评估后本轮不加）
- 反向同步提醒（publications.md 变化时提醒补 ref.bib）——仅锁 ref.bib 方向
- 链接检查（QUAL-01）、内容更新指南文档（CONT-01/02）— v2
- pre-commit 钩子、任何数据文件或模板的改动
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CONTENT-01 | 维护者能在发布前校验 `_data/*.yml` 与 `papers/ref.bib` 的语法，错误被明确报出而非静默失败 | 三层 BibTeX 校验 + 两层 YAML 校验设计（见 Architecture Patterns），全部基于本机实测的解析器行为测绘；schema 原型基线全绿；CI 插入点与本地入口（D-04/D-05）均已定位；两类静默失败（截断 bib、映射化 yml）经破坏性实验证实构建不拦截，验证脚本是唯一防线 |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

- **GSD Workflow Enforcement:** 文件变更必须走 GSD 入口（本阶段由 `/gsd-plan-phase` → `/gsd-execute-phase` 驱动，研究产物除外）
- **Tech stack 约束:** 保持 Jekyll + 现有插件体系（jekyll-scholar、jekyll-sitemap），不做框架重写 — D-06 零新增依赖与此一致
- **Deployment 约束:** GitHub Pages 必须走 GitHub Actions 完整构建 — 验证步骤加入现有 `deploy.yml`，不新建工作流
- **Domain:** `baseurl` 保持为空 — 与本阶段无关（脚本不产出 URL）
- **Conventions:** shell 脚本范式沿用 `scripts/ci-smoke.sh`（`set -euo pipefail` + 逐条断言 + 末行 PASS 汇总）；Ruby 侧无项目 lint 规则；错误信息中文（D-07 与项目文档语言一致）
- **无测试框架约定:** 项目无任何测试框架（CLAUDE.md 明示）— 验证脚本自身的正确性证明采用机器真值断言（Phase 1/2 先例），不引入测试框架

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| YAML 语法检查 | 本地/CI 构建工具层（Ruby psych） | — | 解析在构建管线内完成，浏览器/CDN 不参与；Jekyll 也会红但消息为英文回溯且需全量构建 |
| YAML 结构检查（schema） | 本地/CI 构建工具层 | — | Jekyll 对结构错误完全静默（实测），唯一防线是独立脚本 |
| BibTeX 解析与必填检查 | 本地/CI 构建工具层（bibtex-ruby） | — | jekyll-scholar 同样宽容（实测构建绿），脚本必须在 scholar 消费前拦截 |
| 引用键唯一性检查 | 本地/CI 构建工具层（原始正则） | — | bibtex-ruby 静默改名销毁信息（实测 k→l→m），只有原始文本可查 |
| CI 构建前拦截 | GitHub Actions build job | — | 验证红 → build job 红 → 无工件 → 不部署（Phase 2 既有语义，D-04） |
| bib 同步提醒（D-08） | 本地 git 工作区对比 | CI（天然无操作） | 提醒主要面向本地未提交改动（CONTEXT discretion 原文） |
| 错误信息本地化（D-07） | 脚本输出层 | — | psych/bibtex-ruby 原生消息为英文/token 碎片，中文化在脚本组装 |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| psych | Ruby 4.0.6 内置 default gem | YAML 语法解析 + 行列号错误 | Ruby 标准库，零安装；`Psych::SyntaxError` 自带 `file/line/column/problem/context` [VERIFIED: 本机 probe，bad.yml 报 `line: 3 col: 8`] |
| bibtex-ruby | 6.2.0（Gemfile.lock 锁定） | BibTeX 解析 + 条目字段访问 | jekyll-scholar 7.3.0 的依赖链，本地/CI（bundler-cache）均现成 [VERIFIED: Gemfile.lock:7-8 `bibtex-ruby (6.2.0)`、:105-106 `jekyll-scholar (7.3.0)` → `bibtex-ruby (~> 6.0)`] |
| Ruby | 4.0.6（`.ruby-version` 单一事实源） | 脚本运行时 | 本机/CI 一致（Phase 2 已证）；psych 在 `bundle exec` 下可用（不在 Gemfile.lock 亦无妨，default gem 恒在）[VERIFIED: 本机 `bundle exec ruby -e 'require "psych"'` 多次成功] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Logger（stdlib，经 `BibTeX.log`） | 内置 | 捕获 bibtex-ruby lexer 告警 | 可选增强：自定义 Logger 收集 WARN，作为截断检测的冗余信号（非必需——必填字段检查已覆盖） |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| psych 手写结构检查 | yamllint / json-schema 工具链 | D-06 已锁排除：Python 工具链跨环境、Schema 对 5 个小数据文件过重 |
| bibtex-ruby | bibtool / 外部 CLI | D-06 已锁排除：非 Ruby 原生、CI 需额外安装 |
| 原始正则提键 | 解析器 API 查重 | 解析器**不可用**于查重（静默改名销毁原始键，实测），正则是唯一可靠来源 |

**Installation:**
```bash
# 无 — D-06 锁定零新增依赖。psych 是 Ruby default gem；bibtex-ruby 6.2.0 已在 Gemfile.lock。
# 唯一"安装"动作是无：脚本以 bundle exec ruby scripts/validate.rb 运行，复用现有 bundle 环境。
```

**Version verification:** 无需 registry 查询——本阶段不安装任何包。bibtex-ruby 6.2.0 版本号经 Gemfile.lock 与本机 `BibTeX::Version::STRING` 双重确认 [VERIFIED: 本机 probe 输出 `gem: 6.2.0`]。

## Package Legitimacy Audit

**本阶段安装的外部包：无**（D-06 锁定零新增依赖，Gate 协议 N/A）。

| Package | Registry | Age | Downloads | Source Repo | Verdict | Disposition |
|---------|----------|-----|-----------|-------------|---------|-------------|
| bibtex-ruby 6.2.0（既有） | rubygems | 已在 lock | — | github.com/inukshuk/bibtex-ruby | OK（既有依赖，非新增） | 无需动作 |
| psych（既有） | Ruby 内置 default gem | 随 Ruby 4.0.6 | — | ruby/psych | OK（标准库） | 无需动作 |

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
维护者编辑内容                     验证层（本阶段交付）                结果
──────────────                 ──────────────────────        ─────────────
                               ┌──────────────────────────────┐
 _data/*.yml ────────┐         │ scripts/validate.rb          │
   (5 个数据文件)      │         │                              │
                     ├────────▶│ ① YAML 语法层                │──▶ 有错？
 papers/ref.bib ─────┤         │    Psych.parse_file          │      │
    (12 条 @article) │         │    → SyntaxError(行列号)      │      ▼ 是
                     │         │ ② YAML 结构层（逐文件 schema） │   全部错误
                     │         │    is Array? + 必填字段        │   中文汇总
                     │         │    + role 枚举 + date 正则     │   exit 1 ──┐
                     │         │ ③ BibTeX 层                  │             │
                     │         │    BibTeX.parse              │             │
                     │         │    → ParseError(补充文件名)    │             │
                     │         │ ④ BibTeX 必填层               │             │
                     │         │    每条 title/author/year     │             │
                     │         │ ⑤ 键唯一层（原始正则提键）      │             │
                     │         │    tally 查重 + 解析键集对比   │             │
                     │         │ ⑥ D-08 提醒层（警告不阻断）     │             │
                     │         │    git show HEAD vs 工作区     │──▶ 条目数变？│
                     │         └──────────────────────────────┘   ↓ 是      │
                     │                  │                            黄色提醒   │
                     │                  ↓ 无错                       (exit 0) │
                     │            PASS 汇总行 exit 0                        │
                     │                                                     │
  本地入口: scripts/validate.sh ──▶ 同一脚本 ────────────────────────────────┤
  CI 入口: deploy.yml 「Validate content」step ──▶ 同一脚本 ──┐              │
                                (Setup Ruby 之后、             │ exit 1     │
                                 Build with Jekyll 之前)        ▼            ▼
                                                  GitHub Actions job 红 → 无工件 → 不部署
                                                  （线上保持旧版，Phase 2 既有语义）
```

### Recommended Project Structure
```
scripts/
├── ci-smoke.sh        # 既有：构建后冒烟断言（范式参照）
├── validate.rb        # 新增：全部验证逻辑（单文件，零依赖）
└── validate.sh        # 新增：2 行包装（exec bundle exec ruby .../validate.rb "$@"）
.github/workflows/
└── deploy.yml         # 修改：build job 插一步验证（Setup Ruby 后、Build with Jekyll 前）
```

### Pattern 1: BibTeX 三层校验（缺一不可）
**What:** 解析异常捕获（第 1 层）+ 每条必填字段（第 2 层）+ 原始正则键唯一（第 3 层）。
**When to use:** 必须同时做——每层各覆盖一类实测确认的静默失败：

| 破坏形态 | bibtex-ruby 6.2.0 实测行为 | 构建结果 | 哪层拦截 |
|----------|---------------------------|---------|---------|
| 字段间缺逗号 | **抛** `BibTeX::ParseError`（"Failed to parse BibTeX on value..."） | 红 | 第 1 层 |
| 引用键缺失（`@article{,`） | **抛** `BibTeX::ParseError`（"cite-key missing"） | 红 | 第 1 层 |
| 条目内 EOF（大括号开至文件尾） | **抛** `BibTeX::ParseError`（消息只含 `$end` token，**无文件无行号**） | 红（消息不可读） | 第 1 层 + 脚本补文件名 |
| lexer 级未闭合内容 | **只 WARN**（Ruby Logger 到 stderr），条目以**空字段**存活，键可能被改名 | **绿（exit 0）** | 第 2 层（title 为 nil → FAIL）+ 第 3 层（原键从解析键集消失） |
| 重复引用键 | **静默改名**（k,k,k → k,l,m），无任何告警 | 绿 | 第 3 层（原始 tally 唯一） |
| 条目外的垃圾文本 | 静默跳过 | 绿 | 不拦（无害）或第 3 层键集对比 |
| 未知 @type（如 @banana） | 照常解析 | 绿 | 不拦（见 Open Question 2） |

[VERIFIED: 本机 probe 矩阵——上表 7 行均为 `bundle exec ruby -e` 直接实验输出，非文档转述；「绿」两行另经真实 `jekyll build` 证实 exit 0]

**Example:**
```ruby
# Source: 本机实测（bibtex-ruby 6.2.0），已验证
require "bibtex"

# 第 1 层：解析
begin
  bib = BibTeX.parse(File.read("papers/ref.bib"))
rescue BibTeX::ParseError => e
  puts "FAIL: papers/ref.bib 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— #{e.message[0, 120]}"
  exit 1
end

# 第 3 层：原始正则提键（解析器会改名，唯一真相在原文）
raw_keys = File.read("papers/ref.bib").scan(/@\w+\{([^,\s]+)\s*,/).flatten
raw_keys.tally.each { |k, c| errors << "papers/ref.bib：引用键 #{k} 重复出现 #{c} 次" if c > 1 }

# 第 2 层：每条必填（注意：条目是 Hash 子类，只有 [] 访问，无 .title 方法）
bib.to_a.each do |e|   # bib.entries 是 Hash 不是数组——必须 to_a
  %i[title author year].each do |f|
    errors << "papers/ref.bib #{e[:bibtex_key]}：#{f} 字段缺失" if e[f].to_s.strip.empty?
  end
end
```

### Pattern 2: YAML 两层校验 + 中文错误组装
**What:** psych 语法层直接转译 `Psych::SyntaxError` 属性；结构层按逐文件 schema 断言。
**When to use:** 全部 5 个数据文件。语法层消息组装公式（D-07）已验证可行。
**Example:**
```ruby
# Source: 本机实测（psych，Ruby 4.0.6 内置），已验证
require "psych"
begin
  data = Psych.parse_file(path).to_ruby   # parse_file → AST → to_ruby；错误带行列号
rescue Psych::SyntaxError => e
  errors << "#{path} 第 #{e.line} 行第 #{e.column} 列：YAML 语法错误（#{e.problem}）"
  next
end
errors << "#{path}：顶层结构应为列表（每条以 \"- \" 开头）" unless data.is_a?(Array)
```
[VERIFIED: 本机 probe——`e.line`=`3`、`e.column`=`8`、`e.problem`=`"did not find expected ',' or ']'"` 逐一打印确认]

### Pattern 3: 收集全部错误一次性报告（非 fail-fast）
**What:** 与 ci-smoke.sh 的逐条 exit 1 不同，内容验证把所有文件所有条目的错误收集到一个数组，末尾统一输出 + `exit 1`；无错输出单行 PASS 汇总（仿 `PASS: sitemap=11, ...` 风格）。
**When to use:** 维护者修 5 个错不该跑 5 遍脚本。YAML 语法崩了才对该文件短路（后续结构检查无从谈起），其他文件继续。

### Pattern 4: D-08 提醒的 git 语义（CI 天然无操作）
**What:** 对比**工作区 `papers/ref.bib`** 与 **`git show HEAD:papers/ref.bib`** 的 `@\w+\{` 条目计数，不等则输出中文提醒，退出码不动。
**When to use:** 本地未提交改动是主要场景（CONTEXT discretion 原文）；CI（checkout depth 1，工作区=HEAD）两值天然相等，**无需检测 CI 环境变量或特判跳过**。注意 `git diff HEAD^` 在 CI 不可用（checkout@v4 默认 fetch-depth: 1）[CITED: github.com/actions/checkout — "Only a single commit is fetched by default"]。
**Example:**
```bash
# Source: 本机实测（git 语义验证），已验证
if git rev-parse --git-dir >/dev/null 2>&1 && git cat-file -e HEAD:papers/ref.bib 2>/dev/null; then
  head_count=$(git show HEAD:papers/ref.bib | grep -cE '^@[a-zA-Z]+\{')
  work_count=$(grep -cE '^@[a-zA-Z]+\{' papers/ref.bib)
  [ "$head_count" != "$work_count" ] && echo "提醒：ref.bib 条目数 $head_count → $work_count 已变化；publications.md 为手写列表，请确认已同步新增/删除条目"
fi
# exit code 不受影响（D-08：警告不阻断）
```

### Pattern 5: CI 步骤插入（D-04）
**What:** 在 `deploy.yml` build job 现有步骤之间插入一步，无需 apt 安装。
**When to use:** 必须在 `Setup Ruby`（bundler-cache 提供全部 gem）**之后**，`Build with Jekyll` **之前**。现有步骤序列（原文逐字）[VERIFIED: .github/workflows/deploy.yml:26-45 — `Checkout` / `Setup Ruby` / `Setup Pages` / `Build with Jekyll` / `Smoke assertions` / `Upload artifact`]：
**Example:**
```yaml
# Source: deploy.yml 现有结构 + Phase 2 断言先于 Upload 的既有语义
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5
      - name: Validate content          # ← 新增（位置：Setup Pages 后 / Build with Jekyll 前，或紧随 Setup Ruby——均为 D-04 合法解读）
        run: bundle exec ruby scripts/validate.rb
      - name: Build with Jekyll
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
```

### Anti-Patterns to Avoid
- **用解析器 API 查重复键**：bibtex-ruby 静默改名后 `entries` Hash 里全是唯一键——查重必然漏报。必须在原始文本上 tally。
- **依赖 `e.title` 方法访问**：6.2.0 条目是 Hash 子类，`e.title` 抛 `NoMethodError` [VERIFIED: 本机 probe 实测 `undefined method 'title' for an instance of Hash`]；只有 `e[:title]`，且返回值**带大括号原样**（`"{Telomere-to-telomere...}"`），判空用 `to_s.strip.empty?`，别比对裸字符串。
- **把 `bib.entries` 当数组迭代**：它是 `Hash`（键→条目映射）[VERIFIED: 本机 probe `entries class: Hash`]；用 `bib.to_a`。
- **fail-fast 逐条退出**：维护者一次只想看到全部错误清单。
- **用 `YAML.load`**：反序列化面大；用 `Psych.parse_file(...).to_ruby`（与 Jekyll 数据读取行为一致，见 Security Domain）。
- **在验证脚本里跑 `jekyll build`**：违反「独立快速入口」的存在理由（CONTEXT Existing Code Insights 原文）；脚本只读数据文件。
- **改 `_config.yml` 或数据文件**：CONTEXT 明确「不做任何数据文件或模板的改动」。

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML 解析与行列号定位 | 正则/逐行扫描 YAML | psych `Psych::SyntaxError#line/column` | YAML 语法复杂度远超表面；psych 行列号免费且准确（实测） |
| BibTeX 解析 | 正则解析 BibTeX 语法 | `BibTeX.parse` | 嵌套大括号、@string、缩写等边角；6.2.0 已锁在 lock 里 |
| 引用键唯一性 | ——（例外：**允许**正则提键） | 原始文本 `scan(/@\w+\{([^,\s]+)\s*,/)` | 唯一合法的手写场景：解析器销毁原始键信息（实测改名），正则是唯一真相源；模式本身简单确定 |
| 错误行号计算（YAML） | 手动数行 | `e.line`/`e.column` 直接用 | 已验证属性存在且准确 |
| CI 拦截机制 | 新 workflow / 新 job / artifact 门 | build job 内步骤红 | 复用 Phase 2 语义：步骤红 → job 红 → 无 upload-pages-artifact → 不部署（D-04 原文引用的既有决策链） |

**Key insight:** 本阶段唯一"手写"的部分是结构 schema 与键提取正则——前者是本项目特有业务规则（无库可代劳，D-06 已否决 Schema 工具链），后者是解析器行为缺陷的必要补偿。其余全部复用标准库与已锁依赖。

## Runtime State Inventory

> 本阶段为纯新增工具（新脚本 + CI 插步），无 rename/refactor/migration——**省略此节**（Step 2.5: N/A，非重构阶段）。唯一触及的既有文件是 `deploy.yml`（追加一步，不改既有步骤）。

## Common Pitfalls

### Pitfall 1: 「Jekyll 会报错」的错觉——两类静默失败实测确证
**What goes wrong:** 截断的 BibTeX 条目与映射化的 `_data/*.yml` 都让 `jekyll build` 退出码 0、零告警通过；内容从页面消失，线上直接缺内容。
**Why it happens:** bibtex-ruby lexer 对未闭合内容只发 Logger WARN；Jekyll Liquid 对非预期结构（Hash 当列表迭代、nil 字段）静默渲染空。
**How to avoid:** 必填字段检查 + Array 结构检查是硬需求（Pattern 1 第 2 层、Pattern 2），不是锦上添花。
**Warning signs:** 验证脚本设计若只做「语法解析不抛异常」就算完，即掉入此坑。
[VERIFIED: 本机 `jekyll build` 破坏性实验——bib 截断 exit 0 仅 `W, ... Lexer: unterminated content`；news.yml 映射化 exit 0 且正文从 news/index.html 与 feed.xml 消失]

### Pitfall 2: 重复引用键的静默改名
**What goes wrong:** 维护者复制粘贴条目忘改键，bibtex-ruby 不报错不告警，把后续重复键改名（实测 k,k,k → k,l,m；keyA → keyB）。
**Why it happens:** Bibliography 内部是键→条目 Hash，加入重复键走改名逻辑保持键唯一。
**How to avoid:** 原始文本 `scan` 提键 + `tally` 查重（Pattern 1 第 3 层）。
**Warning signs:** 任何「从解析结果里查重」的实现都必然漏报——解析结果里没有重复。
[VERIFIED: 本机 probe `3x same key -> length=3 keys=["k", "l", "m"]`]

### Pitfall 3: BibTeX::ParseError 消息不含文件名与行号
**What goes wrong:** 抛出的消息形如 `Failed to parse BibTeX on value "$end" ($end) [...]`——对维护者完全不可读，且不知道哪个文件（虽然本阶段只有一个 .bib，但 D-07 要求文件定位）。
**Why it happens:** racc 生成 parser 的 on_error 只吐 token 上下文。
**How to avoid:** 脚本捕获后**自行包装**：文件名 + 中文建议（「检查最近编辑：多为缺失逗号或未闭合大括号」）+ 原始消息截断附后。行号无法从异常获得——不承诺 bib 的行号定位，靠键名/字段名定位。
**Warning signs:** 计划里若写了「bib 错误报行号」即超出解析器能力（psych 的 YAML 才有行号）。
[VERIFIED: 本机 probe——消息字段实测无 file/line 属性可用]

### Pitfall 4: bibtex-ruby 6.2.0 的 API 形状与常识文档不符
**What goes wrong:** 按老文档/训练记忆写 `entry.title`、`entry.type`、`entry.key`、遍历 `bib.entries`——分别抛 NoMethodError / ArgumentError / 拿到意外结构。
**Why it happens:** 6.x 把 Entry 重构为 Hash 子类；`bib.entries` 返回 Hash；字段访问只剩 `[]`。
**How to avoid:** 固定用 `e[:title]` / `e[:bibtex_key]` / `e[:bibtex_type]` / `bib.to_a` / `bib.length`（全部经本机 probe 验证）。
**Warning signs:** 执行器若「凭记忆」写 BibTeX 代码，第一轮就会在这里烧时间。
[VERIFIED: 本机 probe 矩阵——`e[:bibtex_key]`=`"bao2026oryza"`、`e[:bibtex_type]`=`:article`、`e.title` NoMethodError、`bib.entries` Hash]

### Pitfall 5: CI 端 git 对比写成 `git diff HEAD^`
**What goes wrong:** checkout@v4 默认 fetch-depth: 1，`HEAD^` 不存在，命令失败。
**Why it happens:** 浅克隆性能优化的官方默认。
**How to avoid:** D-08 用 `git show HEAD:papers/ref.bib` 对比工作区（depth 1 下 HEAD 恒在），CI 里天然相等自动跳过提醒；或干脆 CI 跳过（CONTEXT discretion 允许）。
**Warning signs:** 任何依赖 `HEAD^`/`origin/main` 的 CI 内 git 命令。
[CITED: github.com/actions/checkout README——"Only a single commit is fetched by default"]

### Pitfall 6: schema 检查意外引入基线失败
**What goes wrong:** 规则比现状严（如要求 doi、要求每条都有 photo），当前合法数据变红——违反 D-01「现有数据必须全绿」。
**Why it happens:** 按想象而非现状推导规则。
**How to avoid:** 用本次研究验证过的 schema 原型（下文 Code Examples §3，实测基线 0 错误）；新增任何规则前先对 5 个文件跑基线。
**Warning signs:** 「约」「应该」开头的字段规则。
[VERIFIED: 本机原型实测 `BASELINE GREEN (0 errors)`——news 6 条 / team 4（pi:1, member:1, student:2）/ pi 1 / alumni 2 / grants 2]

### Pitfall 7: 教条对待 `%` 注释行与 `educationshort` 死字段
**What goes wrong:** 正则或 schema 对 `papers/ref.bib` 第 1 行 `% Zhang Tao Lab Publications` 报错；或要求 `pi.yml` 的 `educationshort` 必填。
**Why it happens:** 不了解现状特例。
**How to avoid:** 提键正则 `@\w+\{` 天然跳过 `%` 行（实测 12/12 精确命中）；`educationshort` 在全部模板中零消费（grep 证实），schema 设为可选或忽略。
[VERIFIED: papers/ref.bib:1 `% Zhang Tao Lab Publications`；grep `educationshort` 全模板零命中]

## Code Examples

以下均在本机验证（非文档转述）。schema 原型整体跑通且基线全绿，planner 可直接沿用字段清单。

### 1. 逐文件 schema（基线实测 0 错误）
```ruby
# Source: 本机原型实测（bundle exec ruby，2026-08-20）——数据现状 [VERIFIED: _data/*.yml 全文已读]
# news.yml（6 条）——date 值逐字: "Latest"(仅首条), "May 2026", "March 2026", "December 2024", "June 2023"
#   必填: date, headline；date 规则: == "Latest" 或 /\A(January|February|March|April|May|June|July|August|September|October|November|December) \d{4}\z/（D-02）
#   "Latest" 建议仅允许首条（CONTEXT discretion——见 Open Question 3 推荐）
# team_members.yml（4 条: pi×1, member×1, student×2）
#   必填: name, role, position；role 枚举: ["pi", "member", "student"]（文件首行注释原文: "role: pi | member | student"）
#   可选(模板有 if 守卫): photo, email, scholar, github, education
# pi.yml（1 条）——必填: education（非空数组）；educationshort 可选（模板零消费，死字段）
# alumni.yml（2 条）——必填: name, period, degree, position（team.md 表格四列全部裸输出，无守卫）
# grants.yml（2 条）——必填: name
```
[VERIFIED: 字段消费点逐一核对——`_pages/news.md:14-19`、`_includes/sidebar.html:19-24`、`feed.xml:21-31`（date+headline）；`_pages/team.md:15-17`（role 为 where 判别键——写错 role 值人从页面消失）、:30-43（pi 字段守卫输出）、:58-59（member name/position 裸输出）、:97-104（alumni 四列）；`_pages/about.md:26`（`site.data.pi[0].education` 下标访问）、:54（grant.name）]

### 2. YAML 语法错误的中文转译（属性实测存在）
```ruby
# Source: 本机 probe，输出实测: line=3, column=8, problem="did not find expected ',' or ']'"
rescue Psych::SyntaxError => e
  errors << "#{e.file&.split("/")&.last} 第 #{e.line} 行第 #{e.column} 列：YAML 语法错误（#{e.problem}）"
```

### 3. 结构检查骨架（Array 判定是硬需求）
```ruby
data = Psych.parse_file(path).to_ruby rescue nil
if data && !data.is_a?(Array)
  errors << "#{path}：顶层结构应为列表（每条以 \"- \" 开头），当前是 #{data.class}——新增条目请复制既有条目的 \"- \" 前缀格式"
end
# 条目级: news.each_with_index { |a, i| errors << "news.yml 第 #{i+1} 条：date 字段缺失" unless a.key?("date") }
```

### 4. PASS 汇总行风格（仿 ci-smoke.sh:23）
```ruby
# Source: scripts/ci-smoke.sh:23 原文: echo "PASS: sitemap=$COUNT, anchor ok, feed valid, no vendor"
puts errors.empty? \
  ? "PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一, 基线全绿" \
  : "FAIL: #{errors.length} 个问题"
puts errors; exit(errors.empty? ? 0 : 1)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| 期望 Jekyll/scholar 报内容错误 | 实测两类静默通过（bib 截断、yml 映射化） | 本研究中实证（2026-08-20） | 验证脚本从"锦上添花"升级为"唯一防线"，三层/两层校验为硬需求 |
| （文档常识）bibtex-ruby Entry 有 .title 方法访问 | 6.x Entry 为 Hash 子类，仅 [] 访问 | bibtex-ruby 6.0 起 | 执行器禁止凭训练记忆写 API，按本研究 Pattern 1 清单写 |

**Deprecated/outdated:**
- `BibTeX::Entry::TYPES` 常量：6.2.0 中不存在（NameError 实测）；存在的是 `BibTeX::Entry::REQUIRED_FIELDS`（但 D-03 锁定 title/author/year 规则，不采用 per-type required——@article 的 REQUIRED_FIELDS 含 editor/journal 变体，比 D-03 严，会引入误报面）

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | GitHub ubuntu runner 自带 git 且 `git show HEAD:file` 可用（D-08 CI 端） | Pattern 4 | LOW——GitHub 托管 runner 预装 git 属平台常识，且脚本已建议 guard（`git rev-parse --git-dir` 失败即静默跳过提醒）；提醒本身不阻断，最坏情形是 CI 里少一条冗余提醒（CI 中两值天然相等，几乎不可能触发） |
| A2 | 维护者未来新增 news 的 date 沿用英文全拼月份（"September 2026" 而非 "Sept 2026"/"2026年9月"） | Pattern 2 / D-02 | LOW——规则按现状数据推导是 D-02 原文要求；若维护者想用缩写/中文日期，报错信息会明确指出格式要求，属"设计内拦截"而非误伤（但 planner 可选择在报错文案中附上合法格式示例降低摩擦） |
| A3 | `Psych.parse_file(...).to_ruby` 与 Jekyll 数据读取的接受面一致（unquoted 日期标量等边缘） | Pattern 2 | LOW——当前 5 文件全部为引号字符串，标量类型差异不会出现在基线；若维护者写了 unquoted ISO 日期，两路径都会得到非 "Month YYYY" 字符串（或 Date 对象 to_s 后同），验证按格式规则报错——行为正确 |

**除上述 3 条外，本研究全部关键技术主张均为本机实测（VERIFIED）或官方文档（CITED），无需用户确认即可供 planner 使用。**

## Open Questions

1. **journal 是否加入必填？** 现状 12/12 条全有 journal，但 D-03 锁定的必填是 title/author/year。
   - What we know: journal 在全部现有条目中出现；D-03 未列 journal。
   - What's unclear: 用户是否愿意对未带 journal 的新条目报错（如在线预印本）。
   - Recommendation: 按 D-03 字面执行（title/author/year），journal 不加——锁定决策不扩写；如 planner 想加须回到 discuss 确认。
2. **@type 白名单要不要？** 未知类型（@banana）实测静默接受；但 talks 页未来要收 @incollection（现查询空渲染，数据属内容补全欠账）。
   - Recommendation: **不做** type 白名单——白名单若按现状只收 @article 会阻断未来合法的 @incollection talks 数据；D-03 未锁此检查，收益低风险高。若 planner 坚持，白名单须含 article + incollection + inproceedings + book + phdthesis + misc 等标准集。
3. **"Latest" 仅允许首条？**（CONTEXT discretion 项）现状 "Latest" 恰为首条；feed.xml 的 `site.time` 回退对任意位置的 "Latest" 都生效。
   - Recommendation: 仅允许首条——sidebar/feed 都按时间序展示，非首条 "Latest" 属数据摆放错误，拦截成本一行代码。
4. **CI 步骤插在 Setup Ruby 后还是 Setup Pages 后？**（CONTEXT discretion 项）两者都在 Build with Jekyll 之前，均满足 D-04。
   - Recommendation: 紧跟 `Setup Pages` 之后、`Build with Jekyll` 之前（对 D-04 原文最直读；Setup Ruby 与验证之间隔一个 Pages 步骤无功能差异）。

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Ruby | validate.rb 运行时 | ✓ | 4.0.6（.ruby-version 与本机一致） | — |
| Bundler | bundle exec | ✓ | 4.0.16 | — |
| psych | YAML 解析 | ✓ | Ruby 4.0.6 default gem（`bundle exec` 下 require 成功实测） | — |
| bibtex-ruby | BibTeX 解析 | ✓ | 6.2.0（Gemfile.lock:7） | — |
| git | D-08 提醒对比 | ✓ | 本机在库；CI runner [ASSUMED A1] | guard 失败静默跳过提醒 |
| GitHub Actions | CI 入口 | ✓ | deploy.yml 现役（Phase 2 上线，push main 自动触发已实证） | — |
| xmllint | （本阶段不需要——ci-smoke.sh 既有依赖，不涉新脚本） | ✓ | 本机在库 | — |

**Missing dependencies with no fallback:** 无
**Missing dependencies with fallback:** 无

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | 无（项目零测试框架，CLAUDE.md 明示；Phase 1/2 先例 = gsd-verifier 机器真值断言） |
| Config file | none |
| Quick run command | `bundle exec ruby scripts/validate.rb`（< 1s，不跑 jekyll build） |
| Full suite command | `bundle exec ruby scripts/validate.rb && bundle exec jekyll build --destination /tmp/_site_v && scripts/ci-smoke.sh /tmp/_site_v` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CONTENT-01-a | 坏 YAML（_data）→ 中文报错含文件+行号，exit 1 | fixture probe | `cp _data/news.yml /tmp/bak && printf -- '- date: [unclosed\n' > _data/news.yml && bundle exec ruby scripts/validate.rb; echo "exit=$?"; cp /tmp/bak _data/news.yml`（断言 exit=1 且输出含「news.yml 第 1 行」） | ❌ Wave 0（脚本自身） |
| CONTENT-01-b | 坏 BibTeX（缺逗号/截断）→ 中文报错，exit 1 | fixture probe | 同型：向 `papers/ref.bib` 尾部追加 `@article{x, title={t} author={a}}`（缺逗号→ParseError 路径）与 `@article{y, title={截断`（静默路径→必填层拦）各验一次，断言 exit=1 | ❌ Wave 0 |
| CONTENT-01-c | 重复键 → 报键名，exit 1 | fixture probe | 追加两条同键条目，断言输出含「重复」 | ❌ Wave 0 |
| CONTENT-01-d | 结构错误（role 拼错/date 非法/映射化）→ 中文报错 | fixture probe | 改 role 为 `studnet`、date 为 `2026-05`、列表化文件各验一次 | ❌ Wave 0 |
| CONTENT-01-e | 基线全绿 | smoke | `bundle exec ruby scripts/validate.rb` → exit 0 + PASS 行 | ❌ Wave 0 |
| CONTENT-01-f | D-08 提醒不阻断 | fixture probe | 追加一条 bib 条目后运行 → 输出含「publications.md」提醒且 exit=0 | ❌ Wave 0 |
| CONTENT-01-g | CI 步骤红 → 不部署 | integration（push 观察） | 首次合入后推一个故意红的提交观察 build job 红 + 无 deployment，再修复（或按 Phase 2 惯例在 dispatch 验证模式下观察） | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `bundle exec ruby scripts/validate.rb`（秒级）
- **Per wave merge:** `bundle exec ruby scripts/validate.rb && bundle exec jekyll build --destination /tmp/_site_v && scripts/ci-smoke.sh /tmp/_site_v`
- **Phase gate:** Full suite green（上式）+ fixture probe 矩阵（a–f）全过，CI 集成（g）经 push 实证后才进 `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `scripts/validate.rb` — 被测主体本身（Wave 0 = 脚本落地 + 基线 PASS）
- [ ] fixture probe 命令集（CONTENT-01-a~f）— 可写入 plan 的验证 action 或 phase 验证清单
- [ ] CI 步骤（deploy.yml）— CONTENT-01-g 的前提
- 无需安装测试框架（项目约定零框架；fixture probe 用 cp/printf/restore 即可，注意每条 probe 后必须恢复现场并 `git status --porcelain` 证洁——本次研究中已全程遵循此纪律）

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | 静态站点无认证面；验证脚本不涉身份 |
| V3 Session Management | no | 无会话 |
| V4 Access Control | no | 脚本在维护者本机/CI 受信环境运行，只读仓库文件 |
| V5 Input Validation | yes | 验证脚本本身就是内容管线输入校验器；脚本侧要求：用 `Psych.parse_file` 而非 `YAML.load`（前者走 parser API，与 Jekyll 数据读取接受面一致；避免显式 `YAML.load` 的 ruby/object 反序列化教坏后续维护者）。被校验内容中 news headline 含维护者手写 HTML（现状既有属性，渲染进页面）——本阶段不改渲染链路，验证脚本只读不执行内容 |
| V6 Cryptography | no | 无密码学需求 |

### Known Threat Patterns for Jekyll 内容验证脚本

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| YAML 反序列化（`YAML.load` on `!ruby/object` tags） | Tampering / Elevation | `Psych.parse_file(...).to_ruby`（parser API 路线）；脚本处理的文件与 `jekyll build` 同信任域（维护者自己的仓库），风险面等同既有构建 |
| 恶意 bib/yml 触发脚本崩溃掩盖真错误 | Denial of Service | 收集全部错误 + 顶层 rescue 兜底，任何单文件异常不中断其余校验 |
| CI 注入（新步骤的 run 命令） | Tampering | 步骤仅 `bundle exec ruby scripts/validate.rb`，无 `${{ }}` 内联表达式（不复述仓库内容进 shell），与 deploy.yml 既有风格一致 |

## Sources

### Primary (HIGH confidence)
- 本机破坏性实验矩阵（Ruby 4.0.6 / Jekyll 4.4.1 / bibtex-ruby 6.2.0 / psych，全部 2026-08-20 当日实测）：psych SyntaxError 属性、bibtex-ruby 7 类破坏形态行为、重复键改名、API 形状（[] 访问 / entries=Hash / to_a）、两类 jekyll build 静默通过（exit 0）、schema 原型基线 0 错误、提键正则 12/12 命中
- 仓库源文件（Read 逐行）：`_data/*.yml` 全部 5 个、`papers/ref.bib`、`feed.xml`、`scripts/ci-smoke.sh`、`.github/workflows/deploy.yml`、`Gemfile`/`Gemfile.lock`、`_pages/team.md`、`_pages/news.md`、`_pages/about.md`、`_pages/talks.md`、`_includes/sidebar.html`、`_config.yml`（scholar 段）

### Secondary (MEDIUM confidence)
- [actions/checkout 官方 README](https://github.com/actions/checkout) — fetch-depth 默认值 1（经 WebSearch 核对官方源）

### Tertiary (LOW confidence)
- 无（A1/A2/A3 三条 ASSUMED 已列入 Assumptions Log，均低风险且有设计内兜底）

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 零新增依赖，两个核心库在本机锁定版本上逐 API 实测
- Architecture: HIGH — 插入点/入口/拦截语义全部基于仓库现文件与 Phase 2 既有决策链；schema 原型基线跑通
- Pitfalls: HIGH — 全部 pitfall 均有当日破坏性实验输出背书，无一条来自纯记忆

**Research date:** 2026-08-20
**Valid until:** 2026-09-19（stable；若 Gemfile.lock 的 bibtex-ruby/jekyll-scholar 升版，Pitfall 4 的 API 形状结论需复核）
