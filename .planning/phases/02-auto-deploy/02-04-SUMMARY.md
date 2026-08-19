---
phase: 02-auto-deploy
plan: 04
subsystem: deployment
tags: [takeover, github-pages, github-actions, deployment-gate]
requires:
  - "02-02: deploy.yml workflow committed on main"
  - "02-03: D-18 publication audit approved (marker in 02-PUBLICATION-AUDIT.md)"
provides:
  - "origin remote + origin/main upstream tracking (唯一远端连接)"
  - "Remote default_branch=main; Pages build_type=workflow (cname zhangtaolab.org 继承)"
  - "DEPLOY-02 全套证据: Linux 绿跑 ×2 + Ruby 4.0.6 日志 + 版本组合未动"
  - "验证模式 run 32212517131 + github-pages artifact id 9351230636 (供 Plan 05 人工检查点核阅)"
affects:
  - "GitHub 服务端状态 (非文件): default_branch, pages.build_type"
  - "Plan 02-05: 首次正式部署的前置条件已全部就绪 (dispatch 可达 + build_type=workflow)"
tech-stack:
  added: []
  patterns:
    - "push 触发 + dispatch 验证模式双通道已在线上验证"
key-files:
  created: []
  modified: []
decisions:
  - "DEPLOY-01 刻意不结项: 触发链 (push→自动构建) 已证实, 但站点尚未部署上线 (闸门按 D-16 关闭) — 结项留给 02-05/06 线上锚点证明 (沿用 P01/P03 既有决策)"
  - "DEPLOY-02 结项: Linux runner 绿跑 ×2 + Ruby 4.0.6 本地/CI 一致 + 版本 pin 未动, 证据齐备"
metrics:
  duration: 10min
  completed: 2026-08-19T03:35:00Z
  tasks: 3
status: complete
actuals:
  tokens: 4500
  tasks: 3
  commits: 1
---

# Phase 02 Plan 04: 原地接管 D-15①~④ (push → 默认分支 → build_type → 验证模式) Summary

**One-liner:** D-15 前四步零 force push 零停机执行完毕: main 上远端 (master/backup 未动) → default_branch=main → Pages build_type=workflow (cname 继承) → 验证模式全绿, DEPLOY-02 (Linux + Ruby 4.0.6 一致) 落证, 部署闸门保持关闭。

## What Was Done

按 D-15 锁定顺序执行四步接管, 全程 additive/可逆, 三任务 automated verify 全绿 (TASK1-PASS / TASK2-PASS / TASK3-PASS)。

### Task 1 — D-15①: 配置 origin 并推送 main (首次 Linux 构建证明)

- 前置断言: `git remote -v` 空、工作树 clean、gh 登录 forrestzhang (active, git 协议 ssh)
- SSH 通道: `ssh -T git@github.com` → "Hi forrestzhang! You've successfully authenticated" → 使用 SSH remote
- `git remote add origin git@github.com:zhangtaolab/zhangtaolab.github.io.git`
- `git push -u origin main` → `* [new branch] main -> main` (纯新增分支推送, 无 force, 无覆盖)
- 远端分支前后对照 (证据):
  - BEFORE: `backup`, `dependabot/bundler/{addressable-2.8.1,kramdown-2.3.1,rexml-3.3.3}`, `master` (与 RESEARCH Runtime State Inventory 完全一致)
  - AFTER: 增加 `main → 5c57e49` (本地 HEAD); `master` 与 `backup` 均仍指 `b09c9b31` 原封未动
- **首跑 (push 触发): run 32212189321** — https://github.com/zhangtaolab/zhangtaolab.github.io/actions/runs/32212189321
  - event=push, headBranch=main, conclusion=**success** (03:27:09Z → 03:27:51Z, 42s, bundler cache 命中)
  - build job: **success**, 全步骤绿 — Checkout / Setup Ruby / Setup Pages / Build with Jekyll / **Smoke assertions / Upload artifact**
  - deploy job: **skipped** (DEPLOY_ENABLED 未设, 行为矩阵 "push+未设变量=验证模式回退" 行实证)
- Ruby 版本证据 (setup-ruby 日志, build job 95946906404):
  - `Using 4.0.6 as input from file .ruby-version`
  - `ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [x86_64-linux]`

### Task 2 — D-15②③: 切默认分支 + 切 Pages build_type (零停机接管)

- BEFORE Pages 态 (与 RESEARCH 一致): `build_type=legacy`, `source={branch:master,path:/}`, `cname=zhangtaolab.org`, `status=built`, `https_enforced=false`, `protected_domain_state=null`, `pending_domain_unverified_at=null`; 旧站 /Publication=200
- ② `gh api --method PATCH repos/zhangtaolab/zhangtaolab.github.io -f default_branch=main` → 回读 `main` ✓
- ③ `gh api --method PUT repos/zhangtaolab/zhangtaolab.github.io/pages -f build_type=workflow` → 响应体空 (204 式成功) → 回读验证
- AFTER Pages 态: `build_type=workflow` ✓, `cname=zhangtaolab.org` (继承, D-04 零 DNS 操作) ✓, `status=built` ✓, `protected_domain_state=null` ✓, `pending_domain_unverified_at=null` (域名验证状态未回退) ✓
- 零停机断言: 切换后 `https://zhangtaolab.org/Publication` = **200**, 首页 = **200** (旧快照继续服务, A2 假设实证)
- 两条 API 均显式 `--method` (T-02-10 缓解), 每次变更后回读确认

### Task 3 — D-15④: dispatch 验证模式 (build+断言绿, deploy 跳过)

- 闸门初始态断言: `gh variable list` 为空 (DEPLOY_ENABLED 未设)
- `gh workflow run deploy.yml -R zhangtaolab/zhangtaolab.github.io` (不带 -f deploy → input 默认 false → 验证模式; dispatch 可达本身证明 Task 2 的 default_branch=main 生效)
- **验证模式 run 32212517131** — https://github.com/zhangtaolab/zhangtaolab.github.io/actions/runs/32212517131
  - event=workflow_dispatch, conclusion=**success**
  - build job: **success** (build job id 95947843875), deploy job: **skipped** (D-16 闸门按设计拦住)
  - Smoke assertions 步骤输出: `PASS: sitemap=11, anchor ok, feed valid, no vendor` — sitemap 实测恰为 11 (RESEARCH Open Question 2 的预期机制值, 断言阈值 ≥10 防脆断), 本地/CI 同脚本最终证明
  - Ruby 证据: `Using 4.0.6 as input from file .ruby-version` + `ruby 4.0.6 ... [x86_64-linux]`
- 构建产物工件 (验证模式: 已上传未部署, **供 Plan 05 人工检查点核阅**):
  - artifact `github-pages`, id **9351230636**, size 3,201,957 bytes, expired=false
- 结束态闸门复核: `gh variable list` 仍为空 — 全程未设置 DEPLOY_ENABLED

## Evidence for Plan 05 (阻断检查点引用)

| 证据 | 值 |
|------|-----|
| push 触发首跑 | run 32212189321, success, build 绿/deploy skipped |
| 验证模式 run | run 32212517131, success, build 绿/deploy skipped |
| 验证模式 artifact | github-pages (id 9351230636, 3.2MB, 未部署) |
| Ruby 版本串 (两 run 各一份) | `Using 4.0.6 as input from file .ruby-version`; `ruby 4.0.6 ... [x86_64-linux]` |
| Pages 回读 JSON | build_type=workflow, cname=zhangtaolab.org, status=built, 域名验证字段 null |
| 冒烟断言输出 | `PASS: sitemap=11, anchor ok, feed valid, no vendor` |
| 闸门状态 | DEPLOY_ENABLED 从未设置 (前/中/后三次断言均空) |

## DEPLOY-02 落证 (flagged_assumptions 兑现)

- Linux runner 成功: ubuntu-latest 绿跑 ×2 (push + dispatch)
- 版本一致: setup-ruby 读 `.ruby-version` → 4.0.6, 与本地 (Homebrew Ruby 4.0.6) 一致; bundler 4.0.16 同本地
- Gemfile.lock 平台条目 (x86_64-linux-gnu, 已核实存在) 被直接使用 (bundler-cache 按 lock 解析, cache key 含 ruby-4.0.6)
- **版本组合未动**: Ruby 4.0.6 + Jekyll 4.4.1 锁定原样 (prohibition 遵守 — 无任何版本漂移自救)
- DEPLOY-02 已标记 complete (见 Requirements 处理)

## Requirements 处理

- **DEPLOY-02 → complete**: 本 Plan 为其显式落证现场, 证据齐备 (上述)
- **DEPLOY-01 → 刻意不结项**: 触发链 (push → Actions 自动完整构建) 已由 run 32212189321 显式证实, 但需求完整定义含 "发布到 GitHub Pages, 站点在 Pages URL 可访问" — 部署尚未发生 (D-16 闸门按设计关闭, 放行属 Plan 05)。沿用既有决策 (STATE.md: P01 "requirements.mark-complete 留给真正交付部署的 plan 执行"; P03 "DEPLOY-01 结项留给线上锚点证明 02-05/06")

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] gh api 首次调用 TLS handshake timeout**
- **Found during:** Task 1 before-state 采集
- **Issue:** `gh api .../branches` 与 `.../repos` 连续两次网络层失败 (net/http: TLS handshake timeout / EOF) — 环境瞬时网络问题, 非命令/权限问题 (SSH 通道同时正常)
- **Fix:** 带 backoff 重试 (sleep 3/5s, 第 2 次尝试成功), 后续全部 API 调用无复发
- **Files modified:** 无
- **Commit:** 无 (瞬时环境问题, 无代码变更)

其余按 plan 原文执行, 无其他偏差。

## Notes (供后续 Plan / 用户)

1. **push 时 GitHub 提示 "17 vulnerabilities on default branch (7 high, 8 moderate, 2 low)"**: 该提示在 push 瞬间基于**当时的默认分支 master** (旧站 Gemfile.lock 的 Dependabot 告警)。master 删除 (Plan 02-06) 后旧告警随分支消失; 新 main 的 Gemfile.lock 为全新锁定。非本 Plan 范围, 记录备查。
2. **pages API 的 `source` 字段仍显示 `{branch: master, path: /}`**: build_type=workflow 下该字段已 inert (不再被使用), 属 API 回显残留, 无需处理。RESEARCH "source 不再依赖任何分支" 判断成立。
3. **artifact 保留期**: github-pages artifact 默认保留 90 天; Plan 05 人工核阅应在合理时间内进行 (非阻塞, 失效可重新 dispatch 验证模式再生)。
4. 本 Plan 不新增仓库文件 (per plan Artifacts 声明); git 层面唯一持久变化 = 本地 `.git/config` 的 origin remote + origin/main 上游跟踪。

## Known Stubs

None — 本 Plan 无代码产出, 全部交付物为远端状态转换 + 运行证据 (已记录于上表)。

## Threat Flags

None — 无新增代码面。threat_model 中 T-02-05 (非破坏序列 + 每步回读 + 200 断言)、T-02-10 (显式 --method + 回读确认)、T-02-11 (失败即停, 版本锁定不动) 的缓解措施全部按设计执行并实证。

## Self-Check: PASSED

- 远端 refs/heads/main 存在 (git ls-remote 实测, → 5c57e49) — FOUND
- run 32212189321 (push, success) / 32212517131 (dispatch, success) — FOUND (gh run list 复核)
- default_branch=main / build_type=workflow / cname=zhangtaolab.org — FOUND (API 回读)
- master/backup → b09c9b31 未动; 3 dependabot 分支仍在 — FOUND
- DEPLOY_ENABLED 未设置 — FOUND (variable list 空 ×3 次)
- 本 SUMMARY 无代码产物可查文件存在性 (Plan 不新增文件, by design)
