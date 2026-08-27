---
schema_version: 1
open_count: 2
waived_count: 0
fixed_count: 1
total_count: 3
last_updated: 2026-08-27T06:30:21.917Z
---

# Broken Windows Ledger

> Cross-phase defect register. With `workflow.windows_enforce` enabled, `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 02 | deviation | _includes/head.html | 44 | D-12 计划语法 allow_false: true 在 liquid-4.0.4 下构建失败（Liquid 5.4+ 参数），已改用显式 {% if site.dark_mode == false %} 等价实现并双侧构建验证；计划 must_haves 的 allow_false 字面检查因此有意不满足 | open |  | 2026-08-19T01:29:02.600Z |  |
| 2 | quick-260827-f7z | deviation | _pages/publications.md | 16 | Plan assumed publications page renders from papers/ref.bib via jekyll-scholar; page is hand-curated markdown — citation lines for bao2026oryza/he2026trna synced there in same commit 8df20a2f (resolved) | fixed |  | 2026-08-27T03:13:50.076Z | 2026-08-27T03:14:13.711Z |
| 3 | quick-260827-jvt | deviation | .planning/quick/260827-jvt-remove-doi-placeholders-from-two-entries/260827-jvt-PLAN.md |  | Task 1 verify one-liner added-line pattern ^+[^-] also matched the +++ diff header (counted 3 vs 2); corrected to ^+[^+] during execution, battery green | open |  | 2026-08-27T06:30:21.917Z |  |

````json
[
  {
    "id": 1,
    "kind": "deviation",
    "phase": "02",
    "file": "_includes/head.html",
    "line": 44,
    "description": "D-12 计划语法 allow_false: true 在 liquid-4.0.4 下构建失败（Liquid 5.4+ 参数），已改用显式 {% if site.dark_mode == false %} 等价实现并双侧构建验证；计划 must_haves 的 allow_false 字面检查因此有意不满足",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-08-19T01:29:02.600Z",
    "resolved_at": null
  },
  {
    "id": 2,
    "kind": "deviation",
    "phase": "quick-260827-f7z",
    "file": "_pages/publications.md",
    "line": 16,
    "description": "Plan assumed publications page renders from papers/ref.bib via jekyll-scholar; page is hand-curated markdown — citation lines for bao2026oryza/he2026trna synced there in same commit 8df20a2f (resolved)",
    "status": "fixed",
    "reason": "",
    "recorded_at": "2026-08-27T03:13:50.076Z",
    "resolved_at": "2026-08-27T03:14:13.711Z"
  },
  {
    "id": 3,
    "kind": "deviation",
    "phase": "quick-260827-jvt",
    "file": ".planning/quick/260827-jvt-remove-doi-placeholders-from-two-entries/260827-jvt-PLAN.md",
    "line": null,
    "description": "Task 1 verify one-liner added-line pattern ^+[^-] also matched the +++ diff header (counted 3 vs 2); corrected to ^+[^+] during execution, battery green",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-08-27T06:30:21.917Z",
    "resolved_at": null
  }
]
````
