---
phase: 1
slug: local-dev-environment
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
created: 2026-08-17
---

# Phase 1 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| rubygems.org → 本地依赖树 | bundle install 拉取的第三方 gem 供应链 | gem 包（jekyll-scholar 7.3.0 等传递依赖） |
| 本地开发服务 ↔ 浏览器 | jekyll serve --livereload 的回环 HTTP/WebSocket | 站点内容 + 再生信号（仅 127.0.0.1） |
| 工作区 → git 历史 | 站点源码首次全量入库 | 公开学术内容（无密钥类文件，analytics id 为空） |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-1-01 | Tampering (供应链) | Gemfile 传递依赖 | medium | mitigate | Gemfile.lock 锁定精确版本并入库（含 CHECKSUMS 段）；Gemfile 仅 source rubygems.org，无新增 gem source。L1 实证：`git ls-files Gemfile.lock` 命中；`grep -c "^CHECKSUMS" Gemfile.lock` = 1 | closed |
| T-1-02 | Information Disclosure (serve 暴露) | 本地开发服务 | low | mitigate | serve 默认绑定 127.0.0.1:4000；livereload 独立服务器亦仅 127.0.0.1:35729（Jekyll 4.4.1 行为）；plan prohibition 6 禁止 --host 0.0.0.0。L1 实证：Gemfile/_config.yml 中 0.0.0.0 零命中；verifier lsof 实测双端口均回环 | closed |
| T-1-03 | 敏感/生成物误入库 | git 历史 | low | mitigate | .gitignore 覆盖 _site/、.jekyll-cache/、.jekyll-metadata、.bundle/、vendor/bundle、.DS_Store、.gsd/、.playwright-mcp/。L1 实证：`git check-ignore _site` 退出 0；`git status --porcelain` 为空 | closed |
| T-1-04 | 演示数据上线（Tampering/Repudiation） | 文献链路 | medium | mitigate | assets/ref.bib（Feynman 模板演示数据 24 条）已删除；scholar.source 对齐 papers/ref.bib；plan prohibition 4。L1 实证：`test ! -f assets/ref.bib` 通过 | closed |
| T-1-05 | 系统级变更影响（Step B） | 本机 Ruby 环境 | low | mitigate | 版本阶梯在 Step A 收敛，Step B（brew ruby@3.4）未执行；STATE.md 决策记录确认。L1 实证：STATE.md 生效级别 = Step 0 → Step A，ruby@3.4 未安装 | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|

No accepted risks.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-08-17 | 5 | 5 | 0 | orchestrator (L1 快速路径：register_authored_at_plan_time=true + asvs_level=1 + threats_open=0，按工作流 §3 短路规则免 auditor 深扫) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-08-17
