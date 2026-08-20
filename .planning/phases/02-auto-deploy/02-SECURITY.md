---
phase: 2
slug: auto-deploy
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-08-19
---

# Phase 2 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| 维护者本地 → GitHub (push) | 本人 git push 到 main 触发流水线 | 源码 + 规划文档（无 secrets，仓库零 secrets 存量） |
| GitHub Actions runner → GitHub Pages | OIDC 短时令牌发布工件 | 静态站点产物（公开内容） |
| GitHub Pages → 公网访客 (zhangtaolab.org, Cloudflare 代理) | 静态 HTML/CSS/JS 分发 | 公开内容 |
| gh CLI (ADMIN) → GitHub Repos/Pages API | 接管操作序列（default_branch / build_type / 变量 / 分支删除） | 仓库配置变更（one-way 动作经用户闸门授权） |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-02-01 | Tampering/Elevation | 被劫持的第三方 action（供应链） | high | mitigate | 仅官方 org actions（actions/*、ruby/setup-ruby），starter 组合钉 major tag；`uses:` 全集 grep 证实零第三方 | closed |
| T-02-02 | Tampering | 不可信输入注入 run: 脚本 | medium | mitigate | 触发源限本人 push + typed boolean dispatch；run: 零用户可控插值；不用 pull_request_target | closed |
| T-02-03 | Elevation/Info Disclosure | GITHUB_TOKEN 越权或外泄 | high | mitigate | 显式最小 permissions（contents:read / pages:write / id-token:write，grep 在位）；OIDC 替代 PAT；仓库零 secrets | closed |
| T-02-04 | Tampering | 未授权/误触发部署 | high | mitigate | D-16 双闸（`vars.DEPLOY_ENABLED == 'true' \|\| inputs.deploy == true`，grep 在位）；首闸开启前置三条件机器断言；删变量即 kill-switch | closed |
| T-02-05 | DoS（回滚能力） | 误伤旧站/误删 master | high | mitigate | D-15 序列①~④全非破坏 + 删除前置四断言（含 `Verdict: APPROVED` 标记 grep -F 恰 1，已复证）；backup 永不触碰（终态 {backup, main} 实测）；本地克隆第二副本 | closed |
| T-02-06 | Tampering | Gemfile/Jekyll 供应链 | medium | accept | 本阶段零依赖变更；Gemfile.lock 锁定组合不变（`git log 48c0a45..HEAD -- Gemfile*`为空），风险面与 Phase 1 相同 | closed |
| T-02-07 | Tampering | feed.xml RSS 注入 | low | mitigate | guid/link 仅模板内变量 + 字面量前缀；strip_html ×3 在位；xmllint 校验绿 | closed |
| T-02-08 | Tampering/DoS | 参照物丢失（旧站被提前替换/存档不完整） | high | mitigate | Task 1 precondition 先验 200；存档 a81b576 先于一切远端操作入库（git 时序证实）；`test -s` + 年份断言 | closed |
| T-02-09 | Tampering | 提取脚本漏提/错提（假阴性） | high | mitigate | 行数断言（双侧 ≥80）+ 年份桶相等 + 报告状态行 89/89 = 旧侧总数（不可跳过，实测）+ 模糊判定列理由供人工抽查 | closed |
| T-02-10 | Elevation | gh api 误用（错误覆写） | medium | mitigate | PATCH/PUT 显式 --method；每次调用后回读（02-04 SUMMARY 存证：default_branch/build_type/cname 回读值） | closed |
| T-02-11 | Tampering | CI 失败被"版本漂移"自救掩盖 | high | mitigate | prohibitions 锁定版本组合；`git log 48c0a45..HEAD -- Gemfile Gemfile.lock .ruby-version` 为空（零漂移，实测）；失败即停即报 | closed |
| T-02-12 | DoS | 热切换后新站异常上线 | high | mitigate | D-08 四断言在 deploy 前把门（build job 内 smoke 先于 upload-pages-artifact）+ 双路径判别式线上复核 + 回滚路径在检查点明示 | closed |
| T-02-13 | Tampering | 验证被缓存伪影误导 | medium | mitigate | 判别式新旧路径互补（新 200 且旧 404，两次独立实测）+ cache-buster 强制回源 | closed |
| T-02-14 | DoS | 分支删除影响 Pages 服务 | medium | mitigate | 删后全面线上复查电池全绿（页面/锚点/feed/sitemap/pages API）；回滚路径（backup 重推）开放 | closed |
| T-02-SC | Tampering | registry 包安装 | high | mitigate | 零 registry 安装（workflow grep npm/pip/cargo = 0）；Actions 依赖官方闭集 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-02-01 | T-02-06 | Ruby/Jekyll 供应链风险随锁定组合继承自 Phase 1；本阶段零依赖变更，lockfile 未动，CI 与本地构建同源同版本 | 维护者（Phase 2 规划对齐 D-07 版本锁定决策） | 2026-08-19 |

*Accepted risks do not resurface in future audit runs.*

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-08-19 | 15 | 15 | 0 | plan-phase orchestrator (L1 grep-depth short-circuit: register_authored_at_plan_time=true, asvs_level=1, threats_open=0) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-08-19
