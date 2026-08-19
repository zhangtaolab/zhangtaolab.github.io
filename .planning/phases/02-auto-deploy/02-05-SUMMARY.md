---
phase: 02-auto-deploy
plan: 05
subsystem: deployment
tags: [first-deploy, hot-switch, deploy-gate, steady-state, github-pages]
requires:
  - "02-04: D-15①~④ 接管完成 (default_branch=main, build_type=workflow, 验证模式双绿)"
  - "02-03: D-18 审计 Verdict: APPROVED 标记行"
  - "Task 1 检查点: 用户批准 (approved — deploy, 2026-08-19)"
provides:
  - "线上新站: https://zhangtaolab.org (github-pages environment deployment id 5975929344)"
  - "常驻部署闸门 DEPLOY_ENABLED=true (push 即部署; 删变量即 kill-switch, per D-16)"
  - "DEPLOY-01 全套结项证据: dispatch 部署 run 32215147077 + push 稳态 run 32215293379 双绿 + 线上 200/404 判别式"
  - "Plan 06 前置: 首次部署绿 (master 删除的前置条件已满足)"
affects:
  - "GitHub 仓库变量 DEPLOY_ENABLED (非文件, 服务端状态)"
  - "线上站点内容 (旧站 master 快照 → 新站 main 构建产物, 热切换完成)"
tech-stack:
  added: []
  patterns:
    - "cache-buster 判别式 (?cb=$RANDOM) 强制绕过 Cloudflare 缓存 — 首查即权威, 无需等 max-age=600 过期"
key-files:
  created: []
  modified: []
decisions:
  - "D-16 闸门语义就位并实证: 设 DEPLOY_ENABLED=true 后, 同一 deploy.yml 在 push 事件下从 skipped (Plan 04 run 32212189321) 变为 success (本 plan run 32215293379) — 常驻闸门双向语义 (true=自动部署/删=停) 已向用户明示"
  - "稳态触发用真实待推提交 a22624c (plan 原文明示: 有未推真实提交则无需空提交)"
metrics:
  duration: 7min
  completed: 2026-08-19T04:21:00Z
status: complete
actuals:
  tokens: 3200
  tasks: 3
  commits: 1
---

# Phase 02 Plan 05: 首次上线 (人工闸门 → D-16 放行 → 热切换 → 稳态自动部署证明) Summary

**One-liner:** 用户批准后设 DEPLOY_ENABLED=true → dispatch deploy=true 完成首次部署 (run 32215147077, build+deploy 双绿, github-pages deployment 5975929344) → 线上热切换判别式首查即成立 (/publications/ 200 + /Publication 404) → 普通 push a22624c 自动触发全绿 run 32215293379 (deploy job 由 skipped 变 success), DEPLOY-01 端到端结项。

## What Was Done

三任务按 D-15⑤/D-16 锁定顺序完成。Task 1 为阻断检查点 (前一 session 暂停, 本次续起); Task 2/3 为本次连续执行, formal verify 双 PASS (TASK2-PASS / TASK3-PASS)。

### Task 1 — 上线放行检查点 (blocking, 已批准)

- 用户批准语料: **"approved — deploy"** (2026-08-19) — 授权热切换及后续清理序列 (Plan 06 删 master/dependabot 分支, 其自有机器前置把关)
- 批准前证据 (02-04-SUMMARY 供核阅项): 验证模式 run 32212517131 (build 绿含 Smoke PASS / deploy skipped)、artifact github-pages id 9351230636 (3.2MB 未部署)、审计报告 `Verdict: APPROVED 2026-08-19` 标记行 (本次续起时复核仍存在, 追溯链完整)
- 回滚路径已向用户知悉: 远端 backup 分支 (b09c9b31) + 本地克隆双保险

### Task 2 — D-16 设闸 + D-15⑤ 首次正式部署 + 线上切换验证

**前置断言 (三条件, 全过)**:
- 检查点已 approved (用户语料在案)
- `gh variable list` 为空 — DEPLOY_ENABLED 未设 (闸门初始态)
- Pages API: `build_type=workflow`, `cname=zhangtaolab.org`, `status=built`

**执行序列**:

| 步 | 操作 | 结果 |
|----|------|------|
| ① | `gh variable set DEPLOY_ENABLED --body true` | 设置于 2026-08-19T04:16:04Z, 回读确认 |
| ② | `gh workflow run deploy.yml -f deploy=true` | run **32215147077** 注册于 04:16:15Z (与 Plan 04 验证 run 32212517131 明确区分) |
| ③ | `gh run watch --exit-status` | exit 0; **build: success** (04:16:19→04:16:42Z) + **deploy: success** (04:16:46→04:16:54Z, 8s, 非 skipped); overall **success** |
| ④ | 双路径判别式 (cache-buster) | **首查即 SWITCHED** (04:17:30Z, 部署完成后 36s): `/publications/?cb=N` = **200** 且 `/Publication?cb=N` = **404** |
| ⑤ | `gh api .../pages` 回读 | `status=built`, `cname=zhangtaolab.org`, `build_type=workflow` |

**首次部署 run 证据**: https://github.com/zhangtaolab/zhangtaolab.github.io/actions/runs/32215147077
- event=workflow_dispatch, conclusion=**success**
- build job: success — 含 Smoke assertions 步骤输出 `PASS: sitemap=11, anchor ok, feed valid, no vendor` (D-08 断言在 deploy 前把门, 与 Plan 04 同值)
- deploy job: **success** (Deploy to GitHub Pages 步骤绿) — if 双条件第二分支 (inputs.deploy==true) 命中实证
- **github-pages environment deployment 记录**: id **5975929344** (created 04:16:43Z, updated 04:16:55Z)

**线上判别式明细 (T-02-13 缓解实证)**:
- 新站路径: `https://zhangtaolab.org/publications/?cb=<epoch>` → **200** (标题 `Publications - Zhang Tao Lab`)
- 旧站路径: `https://zhangtaolab.org/Publication?cb=<epoch>` → **404** (旧路径消失)
- 首页标题 `Home - Zhang Tao Lab` (新站标题分隔符 `-`, 旧站为 `|`, 辅证已换站)
- Pages 直连域: `https://zhangtaolab.github.io/` → 301 (location: zhangtaolab.org) → 跟随后最终 **200**
- 15 分钟容忍循环按设计就位, 实际首查通过 — cache-buster 强制 Cloudflare 回源, 判别式即时权威 (Pitfall 6 的最坏情况未出现, 但设计余量保留)

### Task 3 — 稳态证明 (普通 push 触发完整自动部署, DEPLOY-01 验收)

- 触发提交: **a22624c** (本地待推真实 docs 提交, `5c57e49..a22624c` push; plan 原文明示有真实提交则无需空提交)
- 自动触发 run: **32215293379** — https://github.com/zhangtaolab/zhangtaolab.github.io/actions/runs/32215293379
  - event=**push** (非 dispatch), created 04:18:39Z, 自动触发零人工
  - overall **success**: build: success (04:18:42→04:19:08Z) + **deploy: success** (04:19:11→04:19:19Z)
- **闸门常驻逻辑对照证明**: Plan 04 push run 32212189321 (DEPLOY_ENABLED 未设) deploy=**skipped** → 本 run (DEPLOY_ENABLED=true) deploy=**success** — 同一 workflow 同一触发事件, 唯一变量是闸门状态, D-16 行为矩阵 "push+变量=true=完整部署" 行实证
- 终验线上: `https://zhangtaolab.org/publications/?cb=N` → **200** (重部署后仍健康)

## Evidence for Plan 06 / 需求追溯

| 证据 | 值 |
|------|-----|
| 首次部署 run | 32215147077 (dispatch, success, build+deploy 双绿) |
| 稳态 push run | 32215293379 (push, success, build+deploy 双绿) |
| github-pages deployment | id 5975929344 (首次), environment=github-pages |
| 线上判别式 | /publications/ 200 + /Publication 404 (cache-buster, 首查通过 04:17:30Z) |
| Pages API 回读 | status=built, cname=zhangtaolab.org, build_type=workflow |
| 冒烟断言 (部署 run 内) | PASS: sitemap=11, anchor ok, feed valid, no vendor |
| 闸门终态 | DEPLOY_ENABLED=true (2026-08-19T04:16:04Z 设置, 回读在案) |
| 安全余量 | master/backup → b09c9b31 未动; 3 dependabot 分支未动 (删除属 Plan 06) |

## Requirements 处理

- **DEPLOY-01 → complete (本 plan 结项)**: 全链条证据齐备 — push 自动触发 (run 32215293379) → Actions 完整构建含 jekyll-scholar (build success, 冒烟断言含出版物锚点) → 发布到 GitHub Pages (deploy success, deployment 5975929344) → 站点可访问 (zhangtaolab.org 200 + Pages 直连域 200, 判别式证实为新站)
- **DEPLOY-02**: 已于 02-04 结项, 本 plan 无涉

## Deviations from Plan

None — 计划按原文执行。两点按 plan 内建分支/预期说明 (非偏差):
1. 稳态触发未制造空提交 — plan action 原文明示 "若本地尚有未推送的真实提交, 直接 push 它们即可" (a22624c 即此类提交)
2. 判别式首查即通过 (36s) — 15 分钟容忍循环为设计余量 (Pitfall 6), 未触发不构成偏差; cache-buster 强制回源使判别式即时权威

另: Pages 直连域 301 的 location 头为 `http://zhangtaolab.org/` (非 https) — `https_enforced=false` 系既有现状 (TLS 由 Cloudflare 终结, 边缘强制 https), 跟随后最终 200, 全链路正常, 非本 plan 范围。

## Notes (供 Plan 06 / 用户)

1. **闸门语义 (向用户明示, per T-02-04)**: 此后 push main 即自动部署上线; 想暂停发布, 删除 DEPLOY_ENABLED 变量即可 (`gh variable delete DEPLOY_ENABLED`), build 仍跑 (验证模式回退)
2. **Plan 06 前置已满足**: 本 plan 首次部署绿是其删 master 前置; master 删除前的再次机器断言由 Plan 06 自有把关
3. Cloudflare max-age=600: 未带 cache-buster 的浏览器访问最迟 ~10 分钟内全球切到新站; 带 cache-buster 或硬刷新即时
4. Actions 弃用告警 (非阻断): checkout@v4/configure-pages@v5/upload-artifact@v4 被 runner 强制跑在 Node 24 — GitHub 平台级行为, 不影响构建, 记录备查
5. 本 plan 不新增仓库文件; git 层面唯一推送 = a22624c (Plan 04 已存在的 docs 提交, 作稳态触发器顺带入远端)

## Known Stubs

None — 交付物为远端状态转换 + 线上站点 + 运行证据, 无代码产出。

## Threat Flags

None — 无新增代码面。threat_model 三项缓解全部按设计执行: T-02-04 (开闸前三条件机器断言, 均过), T-02-12 (D-08 冒烟在 deploy 前把门 + 双路径判别式线上复核 + 回滚路径已在检查点明示), T-02-13 (判别式新旧互补 + cache-buster 强制回源, 未被缓存伪影误导)。

## Self-Check: PASSED

- run 32215147077 (dispatch, success, deploy: success) — FOUND (gh run view 复核)
- run 32215293379 (push, success, deploy: success) — FOUND (gh run view 复核)
- 线上判别式 /publications/ 200 + /Publication 404 — FOUND (cache-buster 双查)
- Pages API status=built + cname=zhangtaolab.org — FOUND (回读)
- DEPLOY_ENABLED=true — FOUND (variable list 回读)
- master/backup → b09c9b31 + 3 dependabot 分支仍在 — FOUND (git ls-remote)
- 本 plan 无代码产物可查文件存在性 (不新增文件, by design)
