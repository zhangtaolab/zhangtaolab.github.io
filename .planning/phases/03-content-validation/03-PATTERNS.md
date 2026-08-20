# Phase 3: 内容验证 - Pattern Map

**Mapped:** 2026-08-20
**Files analyzed:** 3
**Analogs found:** 3 / 3

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `scripts/validate.rb` (new) | utility (validation script) | file-I/O + batch | `scripts/ci-smoke.sh` (输出范式) + RESEARCH.md Pattern 1/2 代码（本机实测） | role-match（无既有 Ruby 脚本，逻辑按 RESEARCH 已验证代码照抄） |
| `scripts/validate.sh` (new) | utility (2 行包装) | request-response (CLI) | `scripts/ci-smoke.sh` (shebang/头注释范式) | exact |
| `.github/workflows/deploy.yml` (modify) | config (CI) | batch (pipeline) | `.github/workflows/deploy.yml` 自身（追加一步） | exact |

## Pattern Assignments

### `scripts/validate.rb` (utility, file-I/O + batch)

**Analog:** `scripts/ci-smoke.sh`（输出风格）+ RESEARCH.md Pattern 1/2/3（核心逻辑，全部本机实测）

**脚本头 + 输出风格范式** — 仿 `scripts/ci-smoke.sh` 第 1-4、23 行：

```bash
#!/usr/bin/env bash
# scripts/ci-smoke.sh —— D-08 冒烟断言（本地: scripts/ci-smoke.sh _site；CI: 同）
set -euo pipefail
```
```bash
echo "PASS: sitemap=$COUNT, anchor ok, feed valid, no vendor"   # ci-smoke.sh:23
```

Ruby 版对应：中文头注释说明「本地: scripts/validate.sh；CI: deploy.yml Validate content 步骤」；末行 PASS 汇总仿 `PASS: news=6, team=4, pi=1, alumni=2, grants=2, bib=12, 键唯一, 基线全绿`（RESEARCH Code Examples §4）。

**FAIL 风格差异（勿照抄 ci-smoke.sh 的 fail-fast）** — ci-smoke.sh 是逐条 `|| { echo "FAIL: ..."; exit 1; }`（如第 9 行）；本脚本按 RESEARCH Pattern 3 收集全部错误到数组，末尾统一输出 + `exit 1`：

```ruby
errors = []
# ... 各层检查向 errors << 中文消息 ...
puts errors.empty? ? "PASS: ..." : "FAIL: #{errors.length} 个问题"
puts errors; exit(errors.empty? ? 0 : 1)
```

**核心逻辑直接采用 RESEARCH.md 已验证代码**（本机 probe 实测，勿凭记忆改写 API）：

- BibTeX 三层（RESEARCH Pattern 1，第 179-201 行）：`BibTeX.parse` + rescue 包装中文消息；原始正则 `File.read("papers/ref.bib").scan(/@\w+\{([^,\s]+)\s*,/).flatten.tally` 查重；必填用 `bib.to_a.each` + `e[:title]`（Hash 子类，无 `.title` 方法）+ `to_s.strip.empty?` 判空（字段值带大括号原样）
- YAML 两层（RESEARCH Pattern 2，第 207-216 行）：`Psych.parse_file(path).to_ruby`（勿用 `YAML.load`）+ `Psych::SyntaxError` 的 `e.line/e.column/e.problem` 组中文消息 + `data.is_a?(Array)` 结构判定
- schema 字段清单（RESEARCH Code Examples §1，基线实测 0 错误）：news 必填 date+headline（date 规则 `"Latest"` 仅首条 或月份全拼正则）；team_members 必填 name+role+position（role 枚举 pi/member/student）；pi 必填 education 非空数组；alumni 必填 name+period+degree+position；grants 必填 name
- D-08 提醒（RESEARCH Pattern 4，第 230-235 行）：`git show HEAD:papers/ref.bib` 与工作区 `grep -cE '^@[a-zA-Z]+\{'` 对比，guard 失败静默跳过，退出码不动

### `scripts/validate.sh` (utility, CLI 包装)

**Analog:** `scripts/ci-smoke.sh` 第 1-2 行（shebang + 中文头注释范式）

```bash
#!/usr/bin/env bash
# scripts/validate.sh —— 内容验证入口（本地维护者命令；CI 走 deploy.yml 直接调 validate.rb）
exec bundle exec ruby "$(dirname "$0")/validate.rb" "$@"
```

仅 2 行包装（RESEARCH 推荐结构）；不复制 ci-smoke.sh 的断言逻辑。

### `.github/workflows/deploy.yml` (config, CI pipeline — 修改)

**Analog:** 自身；插入点为现有步骤序列（第 26-45 行原文已核：Checkout → Setup Ruby → Setup Pages → Build with Jekyll → Smoke assertions → Upload artifact）

**插入模式** — 在 `Setup Pages`（33-35 行）之后、`Build with Jekyll`（36-39 行）之前（RESEARCH Open Question 4 推荐位置）：

```yaml
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v5   # ← 既有，第 33-35 行
      - name: Validate content             # ← 新增
        run: bundle exec ruby scripts/validate.rb
      - name: Build with Jekyll            # ← 既有，第 36 行起
```

既有风格约束（Security Domain）：新步骤 `run` 无 `${{ }}` 内联表达式（与现有 Smoke assertions 步骤 40-43 行风格一致）；依赖 bundler-cache（28-32 行 Setup Ruby 已提供 bibtex-ruby），无需 apt 安装。拦截语义复用 Phase 2：验证步骤红 → build job 红 → 无 upload-pages-artifact → 不部署。

## Shared Patterns

### 错误信息格式（D-07）
**Source:** CONTEXT specifics + RESEARCH Code Examples §2/§3
**Apply to:** validate.rb 全部错误消息
格式：「文件 第 N 行第 M 列：中文描述（problem）」/「news.yml 第 3 条：date 字段缺失」/「papers/ref.bib 引用键 X 重复出现 N 次」。bib 不承诺行号（Pitfall 3）。

### bundle exec 运行约定
**Source:** `.ruby-version` 单一事实源（deploy.yml:31 注释）+ Phase 2 先例
**Apply to:** validate.sh、deploy.yml 新步骤、一切手动验证命令
一律 `bundle exec ruby ...`；Ruby 版本读 `.ruby-version`。

### 零副作用验证纪律（fixture probe 用）
**Source:** RESEARCH Validation Architecture
**Apply to:** 执行/验证阶段的 CONTENT-01-a~f probe
`cp 备份 && printf 破坏 && 运行断言 exit=1 && cp 恢复 && git status --porcelain 证洁`。

## No Analog Found

无 — 3 个文件均有直接范式（validate.rb 的具体解析逻辑无既有 Ruby 脚本可抄，但 RESEARCH.md Pattern 1/2 提供本机实测可用代码，planner 应将其原样编入 plan）。

## Metadata

**Analog search scope:** `scripts/`、`.github/workflows/`
**Files scanned:** 2（ci-smoke.sh 全文、deploy.yml 全文；RESEARCH.md 已提供数据文件/bib 全文阅读结论）
**Pattern extraction date:** 2026-08-20
