---
phase: 3
slug: content-validation
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-20
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | 无（项目零测试框架约定，CLAUDE.md 明示；Phase 1/2 先例 = 机器真值断言 + fixture probe） |
| **Config file** | none（fixture probe 用 cp/printf/perl 破坏 + 恢复 + git status --porcelain 证洁，不引入框架） |
| **Quick run command** | `scripts/validate.sh`（< 1s，不跑 jekyll build） |
| **Full suite command** | `scripts/validate.sh && bundle exec jekyll build --destination /tmp/_site_v3 && scripts/ci-smoke.sh /tmp/_site_v3` |
| **Estimated runtime** | ~1s（quick）/ ~60s（full suite，含 jekyll build） |

---

## Sampling Rate

- **After every task commit:** Run `scripts/validate.sh`（秒级，独立快速入口）
- **After every plan wave:** Run `scripts/validate.sh && bundle exec jekyll build --destination /tmp/_site_v3 && scripts/ci-smoke.sh /tmp/_site_v3`
- **Before `/gsd-verify-work`:** Full suite must be green + fixture probe 矩阵（CONTENT-01-a–f）全过 + CI 集成（g）push 实证完成
- **Max feedback latency:** ~1 秒（quick）/ ~60 秒（full suite）

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | CONTENT-01-a/e | T-03-01 / T-03-05 | parser API 路线解析 + 脚本只读（probe 恢复证洁） | fixture probe | PLAN 03-01 Task 1 `<automated>`（基线 PASS + 坏 YAML/坏 bib probe + 双 grep 安全断言） | ❌ W0 | ⬜ pending |
| 03-01-02 | 01 | 1 | CONTENT-01-d | T-03-03 | 畸形结构输入不崩溃、全错误收集 | fixture probe | PLAN 03-01 Task 2 `<automated>`（role/date/Latest 位置/映射化四 probe） | ❌ W0 | ⬜ pending |
| 03-01-03 | 01 | 1 | CONTENT-01-b/c | — | N/A | fixture probe | PLAN 03-01 Task 3 `<automated>`（缺 year/重复键/截断三 probe + 键唯一 PASS 标记） | ❌ W0 | ⬜ pending |
| 03-02-01 | 02 | 2 | CONTENT-01-f | — | N/A | fixture probe | PLAN 03-02 Task 1 `<automated>`（未提交新增条目 → 提醒 + exit 0） | ❌ W0 | ⬜ pending |
| 03-02-02 | 02 | 2 | CONTENT-01（CI 半边） | T-03-02 / T-03-06 | 新步骤字面量命令、既有 6 步零改动 | integration（push 观察） | PLAN 03-02 Task 2 `<automated>`（结构断言 + push 绿跑 + 日志含步骤名） | ❌ W0 | ⬜ pending |
| 03-02-03 | 02 | 2 | CONTENT-01-g | T-03-04 | 红跑无部署、线上保持旧版、revert 复绿 | integration（push 观察） | PLAN 03-02 Task 3 `<automated>`（红 run + 失败步骤名 + deployment id 不变 + revert 绿） | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `scripts/validate.rb` — 被测主体本身（Wave 0 = Plan 03-01 tracer 任务落地 + 基线 PASS）
- [ ] `scripts/validate.sh` — 本地入口包装
- [ ] fixture probe 命令集（CONTENT-01-a–f）— 已编入两个 PLAN 的 `<automated>` 验证块（cp 备份 + printf/perl 破坏 + 断言 + cp 恢复 + git status --porcelain 证洁）
- 不安装测试框架（项目零框架约定；RESEARCH Validation Architecture 明示无需安装）

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 报错中文可读性（D-07：维护者一眼看懂） | CONTENT-01 | 语义可读性无法机械断言 | 抽查 3 条 probe 输出：文件名/字段名/行号原样 + 中文描述清晰指明修法 |
| 三条 prohibitions 无违反（只读校验 / 不误报阻断 / 不再生成 publications.md） | CONTENT-01 | prohibition 为 judgment 级（无 wired check，descriptor-less 处置 flagged-unverified） | /gsd-verify-work 时逐条人工背书（Phase 2 同款流程） |

*其余行为均有 automated 验证（fixture probe 矩阵 a–f + CI push 实证 g）。*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < {N}s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
