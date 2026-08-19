---
phase: 2
slug: auto-deploy
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-19
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
> Filled by plan-phase (2026-08-19) from 02-01~02-06 PLAN.md automated gates.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | none（静态站点，无测试框架；本阶段"测试"= 构建退出码 + 冒烟断言脚本 + CI 验证模式 + 线上 HTTP 断言） |
| **Config file** | none — 测试载体即 `.github/workflows/deploy.yml` + `scripts/ci-smoke.sh`（02-02 交付，非独立 Wave 0） |
| **Quick run command** | `JEKYLL_ENV=production bundle exec jekyll build && scripts/ci-smoke.sh _site` |
| **Full suite command** | `gh workflow run deploy.yml`（验证模式）→ `gh run watch <id>`（build+断言绿、deploy skipped） |
| **Estimated runtime** | 本地全链 <10s；CI 全跑 ~2-4 min；线上缓存窗口（Cloudflare max-age=600）≤15 min 重试预算 |

---

## Sampling Rate

- **After every task commit:** Run `JEKYLL_ENV=production bundle exec jekyll build && scripts/ci-smoke.sh _site`（02-01 期间用各任务内嵌 grep/xmllint 断言；02-02 起统一走 smoke 脚本）
- **After every plan wave:** Run `gh workflow run deploy.yml`（验证模式）+ `gh run watch`（02-04 接管完成后可用；之前波次以本地全链代替）
- **Before `/gsd-verify-work`:** Full suite green + 首次正式部署 + 线上抽查（双路径判别式）+ D-18 核对通过 —— 全部先于删 master（02-06）
- **Max feedback latency:** 本地 <10s；CI ~4 min

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | DEPLOY-01 (enabler) | T-02-06/07 | N/A（本地配置修复） | smoke | `grep -c '^- vendor$' _config.yml` 等（见 PLAN 01 Task 1） | ✅（被改文件本身） | ⬜ pending |
| 02-01-02 | 01 | 1 | DEPLOY-01 (enabler) | — | N/A | smoke | sitemap 黑名单清零断言 + `grep -c '<loc>' _site/sitemap.xml -ge 10` | ✅ | ⬜ pending |
| 02-01-03 | 01 | 1 | DEPLOY-01 (enabler) | T-02-07 | feed 输出仅模板内变量 | smoke | allnews 引用清零 + `xmllint --noout _site/feed.xml` | ✅ | ⬜ pending |
| 02-02-01 | 02 | 2 | DEPLOY-01 | T-02-04 | 断言不可绕过 | smoke | `scripts/ci-smoke.sh _site`（正例绿 + vendor tripwire 反例红） | ❌ 本任务创建 | ⬜ pending |
| 02-02-02 | 02 | 2 | DEPLOY-01/02 | T-02-01/02/03/SC | 最小权限/官方 actions/双闸 | structure | YAML parse + gate 表达式/版本组合/断言位次 grep（见 PLAN 02 Task 2） | ❌ 本任务创建 | ⬜ pending |
| 02-03-01 | 03 | 2 | DEPLOY-01 (D-18) | T-02-08/09 | 参照物先行 + 提取完整 | smoke | 存档非空 + 双侧清单行数 ≥80 + 年份桶集合相等 | ❌ 本任务创建 | ⬜ pending |
| 02-03-02 | 03 | 2 | DEPLOY-01 (D-18) | T-02-09 | 逐条不可跳过 | smoke | 报告状态行数 ≥ 旧侧清单行数 + EXTRA/verdict 节存在 | ❌ 本任务创建 | ⬜ pending |
| 02-03-03 | 03 | 2 | DEPLOY-01 (D-18) | — | 人工闸门 | manual（checkpoint:human-verify, blocking） | 报告审阅 + resume-signal | ✅（报告） | ⬜ pending |
| 02-04-01 | 04 | 3 | DEPLOY-01/02 | T-02-11 | 失败即停不改版本 | e2e (CI) | `git ls-remote` + push run `build: success`（deploy skipped） | ✅（远端状态） | ⬜ pending |
| 02-04-02 | 04 | 3 | DEPLOY-01/02 | T-02-05/10 | API 显式 --method + 回读 | e2e (API) | default_branch=main + build_type=workflow + cname + 旧站 200 | ✅ | ⬜ pending |
| 02-04-03 | 04 | 3 | DEPLOY-02 | T-02-11 | 闸门保持关闭 | e2e (CI) | dispatch run `build: success` + `deploy: skipped` + 日志含 4.0.6 | ✅ | ⬜ pending |
| 02-05-01 | 05 | 4 | DEPLOY-01 | T-02-04/12 | 开闸前置三断言 | manual（checkpoint:human-verify, blocking） | 证据清单核对 + resume-signal | ✅ | ⬜ pending |
| 02-05-02 | 05 | 4 | DEPLOY-01 | T-02-04/12/13 | 双路径判别式防缓存伪影 | e2e (线上) | deploy run 绿 + /publications/ 200 且 /Publication 404（cache-buster 重试 ≤15min） | ✅ | ⬜ pending |
| 02-05-03 | 05 | 4 | DEPLOY-01 | — | N/A | e2e (CI) | push 事件 run `build: success` + `deploy: success` | ✅ | ⬜ pending |
| 02-06-01 | 06 | 5 | DEPLOY-01/02 | T-02-05/14 | one-way 前置四断言 | e2e (API) | 删 master/dependabot 后分支终态恰为 backup,main | ✅ | ⬜ pending |
| 02-06-02 | 06 | 5 | DEPLOY-01/02 | T-02-14 | 删后线上复查 | e2e (线上) | home/publications(锚点)/news 200 + feed xmllint + sitemap ≥10 + pages API built/cname | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠ flaky*

---

## Wave 0 Requirements

- [x] 无独立 Wave 0 —— 测试载体（`scripts/ci-smoke.sh`、`.github/workflows/deploy.yml`）由 02-02 作为交付物创建，且创建任务自带正例/反例（tripwire fail-first）验证；不安装任何测试框架（保持零依赖，符合项目现状）

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| D-18 出版物逐条核对裁决 | DEPLOY-01 | 缺失/多出的定性需用户裁决（缺失阻断、多出确认、豁免记录） | 02-03 Task 3 blocking checkpoint：读 02-PUBLICATION-AUDIT.md，按 resume-signal 批准或回报 |
| 首次上线放行（D-09 产物确认） | DEPLOY-01 | 用户明确要求人工确认后再正式部署（D-09/D-16 前置） | 02-05 Task 1 blocking checkpoint：核对验证模式 run + 审计结论 + 覆盖授权，resume "approved — deploy" |
| 线上视觉与本地一致性 | DEPLOY-01 (成功标准 4) | 浏览器目检（布局/字体/暗色模式）非机器可判 | 阶段收尾 `/gsd-verify-work` UAT：浏览 zhangtaolab.org 关键页对照本地预览（human_verify_mode=end-of-phase） |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or are declared manual-only（2 个 blocking checkpoint + 1 项 end-of-phase UAT，其余全自动化）
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references（无 MISSING——载体随 02-02 交付）
- [x] No watch-mode flags
- [x] Feedback latency < 10s（本地）/ ~4 min（CI）
- [ ] `nyquist_compliant: true` set in frontmatter（由 validate-phase §6 判定）

**Approval:** pending（validate-phase 待跑）
