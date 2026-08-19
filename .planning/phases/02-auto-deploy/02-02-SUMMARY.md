---
phase: 02-auto-deploy
plan: "02"
subsystem: infra
tags: [github-actions, github-pages, ci-pipeline, smoke-assertions, deploy-gate, jekyll]

# Dependency graph
requires:
  - phase: 02-auto-deploy/01
    provides: "绿色本地 production 构建基线（sitemap 11 URL、feed.xml xmllint 通过、publications 锚点在位、_site/vendor 不存在）——断言①③④的通过前提"
provides:
  - "scripts/ci-smoke.sh：D-08 冒烟断言四件套（sitemap ≥10 / DOI 锚点 / xmllint feed / vendor tripwire），本地与 CI 同一份，fail-first 已证"
  - ".github/workflows/deploy.yml：官方工件模式 Pages 流水线（build→gate→deploy），D-16 双闸（vars.DEPLOY_ENABLED || inputs.deploy）与 D-09 验证模式（deploy 默认 false）"
  - "D-07 落地：setup-ruby@v1 省略 ruby-version 输入，CI 自动读仓库根 .ruby-version（4.0.6）"
affects: [02-03-publication-audit, 02-04-takeover-push, 02-05-first-launch, 02-06-cleanup, phase-2-verification]

# Actuals (#2632) — pairs with the plan's estimate (24000 tokens, confidence: low)
actuals:
  tokens: 709        # chars/4 over the realized diff (2836 chars across 2 task commits)
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added:
    - "GitHub Actions 工件模式 Pages 流水线（官方 action 闭集：checkout@v4 / setup-ruby@v1 / configure-pages@v5 / upload-pages-artifact@v3 / deploy-pages@v5）"
  patterns:
    - "部署闸门 = job 级 if 双布尔式：常驻仓库变量（kill-switch）+ typed-boolean dispatch 输入（一次性放行），验证模式即双闸都不放行的自然回退态"
    - "冒烟断言本地/CI 同源单脚本（scripts/ci-smoke.sh [SITE_DIR]），断言在 upload-pages-artifact 之前把门——build 红则永远到不了 deploy"

key-files:
  created:
    - .github/workflows/deploy.yml
    - scripts/ci-smoke.sh
  modified: []
  deleted: []

key-decisions:
  - "冒烟步骤位次钉在 build job 末尾、upload-pages-artifact@v3 之前（D-08 语义：断言失败则无工件可部署），且前置 apt 安装 libxml2-utils（ubuntu runner 默认无 xmllint，Pitfall 3）"
  - "setup-ruby 用 @v1 major tag（非 starter 的全 SHA 钉）并保留 starter 的 cache-version: 0——版本策略取 RESEARCH Standard Stack 建议的官方组合钉 major；ruby-version 输入行删除，.ruby-version 成为版本单一事实源"
  - "concurrency 维持官方值 cancel-in-progress: false（生产部署不取消进行中的跑，Pitfall 9）"

patterns-established:
  - "Pattern: 部署开关用 vars.X == 'true' || inputs.y == true 双闸表达式——删仓库变量即全局停部署，dispatch 输入用于首次上线单次放行"
  - "Pattern: 冒烟断言脚本参数化站点目录（SITE=\"${1:-_site}\"），同一命令本地复现 CI 断言链"

requirements-completed: []   # DEPLOY-01/DEPLOY-02 为阶段级需求：本 Plan 交付流水线文件与本地验证，Linux runner 首跑与线上发布属 Plan 04/05，届时再 mark-complete

coverage:
  - id: D1
    description: "D-08 冒烟断言脚本四件套，正例绿 + tripwire fail-first 反例红"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "bash -n 通过、test -x 通过；production 构建后 scripts/ci-smoke.sh _site 退出 0 且输出 'PASS: sitemap=11, anchor ok, feed valid, no vendor'；_site 副本含 vendor/ 时退出 1（FAIL: vendor leaked into _site）"
        status: pass
    human_judgment: false
  - id: D2
    description: "deploy.yml 结构：gate 表达式、版本组合、断言步骤位次、权限块、触发面、并发策略"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "ruby YAML.parse_file 通过（YAML-OK/RUBY-INPUT-OMITTED）；grep 命中 gate 表达式、setup-ruby@v1、bundler-cache: true、scripts/ci-smoke.sh _site、JEKYLL_ENV: production、upload-pages-artifact@v3、deploy-pages@v5、cancel-in-progress: false；Smoke assertions（第 40 行）先于 upload（第 45 行）"
        status: pass
    human_judgment: false
  - id: D3
    description: "D-07 版本事实源：workflow 不带 ruby-version 输入，CI 从仓库根 .ruby-version（4.0.6）读取"
    requirement: DEPLOY-02
    verification:
      - kind: unit
        ref: "Ruby 解析 workflow 后断言 setup-ruby 步骤 with 块无 ruby-version 键（RUBY-INPUT-OMITTED）；.ruby-version 内容 4.0.6"
        status: pass
    human_judgment: false
  - id: D4
    description: "D-05/D-06/D-09/D-16：最小权限三件套、push[main]+dispatch 触发、验证模式默认、双闸 kill-switch"
    requirement: DEPLOY-01
    verification:
      - kind: unit
        ref: "permissions 恰为 contents: read / pages: write / id-token: write；on.push.branches [main] + workflow_dispatch inputs.deploy type boolean default false；deploy job if 双闸表达式逐字命中"
        status: pass
    human_judgment: false

# Metrics
duration: 2min
completed: 2026-08-19
status: complete
---

# Phase 2 Plan 02: CI 流水线工件 deploy.yml + ci-smoke.sh Summary

**阶段 tracer 落地：官方工件模式 Pages 流水线（build→smoke 把门→D-16 双闸→deploy）与本地/CI 同源的四断言冒烟脚本全部入库；断言正例绿（sitemap=11）+ vendor tripwire fail-first 反例红，工作树 clean，远端零触碰（推送属 Plan 04）**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-08-19T01:31:18Z
- **Completed:** 2026-08-19T01:33:30Z
- **Tasks:** 2/2
- **Files created:** 2（`.github/workflows/deploy.yml`、`scripts/ci-smoke.sh`——仓库首个 .github/ 与 scripts/）

## Accomplishments

- **scripts/ci-smoke.sh（Task 1，`1d94730`）**：D-08 四断言逐字照 RESEARCH Pattern 2 落地——① sitemap `<loc>` 计数 `-ge 10`（阈值防脆断，实测 11）；② publications 页 DOI 锚点 `s41467-026-73769-8`（证明页面渲染出内容，非 scholar 在跑）；③ `xmllint --noout feed.xml`；④ vendor tripwire（产物含 vendor 目录即失败）。正例退出 0 输出 `PASS: sitemap=11, anchor ok, feed valid, no vendor`；**fail-first 反例**：_site 副本造 vendor/ 后退出 1（`FAIL: vendor leaked into _site`）——证明断言真有牙，临时目录已清理
- **.github/workflows/deploy.yml（Task 2，`a91bdb4`）**：以官方 starter（actions/starter-workflows pages/jekyll.yml，RESEARCH 逐行取证）为底本，六项适配全部落地且仅此六项——① 触发 push[main] + workflow_dispatch typed-boolean `deploy` 输入（default false，验证模式即默认态）；② setup-ruby@v1 + bundler-cache 且**删除 ruby-version 输入行**（.ruby-version 4.0.6 自动读取，D-07）；③ 最小权限 contents:read/pages:write/id-token:write（D-05）；④ concurrency "pages" + cancel-in-progress: false（官方值，Pitfall 9）；⑤ build job 步骤序 checkout→setup-ruby→configure-pages→build(JEKYLL_ENV=production)→Smoke assertions(apt libxml2-utils + ci-smoke.sh)→upload-pages-artifact（断言先于上传）；⑥ deploy job 双闸 `vars.DEPLOY_ENABLED == 'true' || inputs.deploy == true` + environment github-pages + deploy-pages@v5（D-16）
- **结构验证全绿**：ruby YAML 解析通过 + 8 条 grep 断言逐条命中 + 机器证明 setup-ruby 的 with 块无 ruby-version 键 + 冒烟步骤位次（40 行）先于上传（45 行）
- **零第三方 action、零 registry 包、零 secret**：供应链面为官方闭集（T-02-01/SC 处置落地）；所有 `run:` 零用户可控插值（T-02-02）
- **远端零触碰**：未创建任何 workflow run、未 push 任何分支——与阶段指令一致（接管序列属 Plan 04，D-15）

## Task Commits

Each task was committed atomically:

1. **Task 1: scripts/ci-smoke.sh——D-08 冒烟断言脚本（本地/CI 同源）** - `1d94730` (feat)
2. **Task 2: .github/workflows/deploy.yml——官方工件模式流水线 + D-16 双闸** - `a91bdb4` (feat)

**Plan metadata:** 见下方最终 docs 提交

## Files Created/Modified

- `scripts/ci-smoke.sh` - 新建（可执行）。CLI `scripts/ci-smoke.sh [SITE_DIR]`（默认 `_site`），四断言 + PASS 行带 sitemap 计数
- `.github/workflows/deploy.yml` - 新建。workflow "Deploy Jekyll site to Pages"；jobs `build`（Checkout/Setup Ruby/Setup Pages/Build with Jekyll/Smoke assertions/Upload artifact）与 `deploy`（Deploy to GitHub，id deployment）；`inputs.deploy` typed boolean default false；仓库首条 workflow

## Decisions Made

- **冒烟步骤必须先于 upload-pages-artifact**（计划明文）：断言红则 build 失败、无工件可传——"永远到不了 deploy"的机制保证，而非仅靠 deploy 闸门
- **runner 上 xmllint 需 apt 前置**（Pitfall 3）：Smoke assertions 步骤先 `sudo apt-get update -qq && sudo apt-get install -y -qq libxml2-utils` 再跑脚本，避免本地绿/CI 红的分叉
- **setup-ruby 版本钉法取 @v1 major tag**（RESEARCH Standard Stack 版本策略建议的 starter 组合：v4/v1/v5/v3/v5），保留 starter 的 `cache-version: 0` 行；不混用各 action 最新 major（v7/v6/v5 组合未经官方组合测试）
- **首次 push 到 main 的预期行为确认**：DEPLOY_ENABLED 未设 + dispatch 输入空 → deploy job 被闸（自动回退验证模式）——这正是 D-15④ 验证模式的入口形态，Plan 04 接管序列可直接消费

## Deviations from Plan

None - plan executed exactly as written.（两任务各自的 automated verify 命令均按计划原文一次通过；执行期唯一追加动作是位次复核——grep 行号证明 Smoke assertions(40) 先于 upload(45)，属补充证据而非修正）

## Issues Encountered

None — 前置检查（Plan 01 基线：sitemap 11 / feed 合法 / 锚点在位 / 无 vendor）一次通过；两任务零重试。

## Known Stubs

None — 两个文件均为完整真实实现（可执行脚本 + 可解析 workflow），无占位符/TODO/空数据面。

## User Setup Required

None — 本 Plan 仅落文件。`DEPLOY_ENABLED` 仓库变量由 Plan 05 在 D-18 核对通过后首次设置，本 Plan 不碰任何远端配置。

## Next Phase Readiness

- **Plan 03（D-18 出版物逐条核对）**：核对对象 `_site/publications/index.html` 的生产链路已由本 Plan 的断言脚本锁定（锚点断言保证页面渲染）；先抓存档旧站 /Publication 再比对
- **Plan 04（D-15①~④ 接管）**：工作树 clean、deploy.yml/ci-smoke.sh 已入库；push main 后首跑会自动落在验证模式（DEPLOY_ENABLED 未设）；dispatch 需等默认分支切到 main 之后（Pitfall 2）
- **Plan 05（首次上线）**：双闸表达式已就位——设 `DEPLOY_ENABLED=true` 或 `gh workflow run deploy.yml -f deploy=true` 即放行；删变量即全局停部署
- **Linux runner 首跑属 Plan 04 的验证模式**：Ruby 4.0.6 + Jekyll 4.4.1 组合在 Linux 上的首次实测在那里发生（DEPLOY-02 的收口点）；若 CI 红，处置属排障范畴，勿擅自改版本组合（CONTEXT Known Risks 原文）
- 无阻塞、无 blocker

## Self-Check: PASSED

Both key files present on disk (`scripts/ci-smoke.sh` executable, `.github/workflows/deploy.yml`), both task commits (`1d94730` / `a91bdb4`) found in git log, working tree clean.

---
*Phase: 02-auto-deploy*
*Completed: 2026-08-19*
