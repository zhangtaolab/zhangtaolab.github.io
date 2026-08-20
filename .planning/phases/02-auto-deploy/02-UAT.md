---
status: testing
phase: 02-auto-deploy
source: [02-VERIFICATION.md]
started: 2026-08-19T04:50:00Z
updated: 2026-08-19T04:50:00Z
---

## Current Test

number: 3
name: Prohibitions 复核确认
expected: |
  确认 4 条 judgment 级 prohibitions 复核结论（见 02-VERIFICATION.md Prohibitions 表，
  验证者裁定均为『未违反』）。
awaiting: user response

## Tests

### 1. 在线视觉终检
expected: 浏览器对比 zhangtaolab.org 与本地预览，渲染效果一致（布局/字体/暗色模式）
result: issue
reported: "icon 不对"
severity: major

### 2. CR-01/CR-02 内容缺陷裁定
expected: 裁定 02-REVIEW.md 两个 critical 内容缺陷（均为 Phase-1 内容面、随部署曝光，非本阶段 must_haves 违例）：CR-01 teaching.md 模板占位课程已在线上（Feynman Lectures 等，实测 /teaching/ 命中 2 处）；CR-02 8 条 PDF 链接线上 404（实测 /pdf/2013/PNAS_2013.pdf=404）。决定修复（提供课程列表/PDF 文件）或暂时接受
result: pass

### 3. Prohibitions 复核确认
expected: 确认 4 条 judgment 级 prohibitions 复核结论（见 02-VERIFICATION.md Prohibitions 表，验证者裁定均为『未违反』）
result: [pending]

## Summary

total: 3
passed: 1
issues: 1
pending: 1
skipped: 0
blocked: 0

## Deferred Follow-Ups

- test: 2
  idea: "CR-01 teaching.md 占位课程待真实课程列表替换（用户 pass = 暂时接受，素材后补）"
  deferred_at: 2026-08-19
- test: 2
  idea: "CR-02 8 条 PDF 链接待 PDF 文件入库（pdf/ 目录）或摘除链接（用户 pass = 暂时接受，素材后补）"
  deferred_at: 2026-08-19

## Gaps

- gap_id: G-02-1
  truth: "线上站点图标正确（浏览器标签 favicon 与导航栏品牌图标应为站点自身的 logo，与本地预览一致）"
  status: failed
  reason: "User reported: icon 不对 — 这里应该使用 zhangtaolab 的 logo 而不是这个（附截图，指浏览器标签图标）"
  severity: major
  test: 1
  root_cause: "favicon.svg 是模板生成的『ZL』字母组合图标（accent 色圆角方块 + Georgia 衬线首字母，Liquid 由 site.name 派生），favicon.ico 同源；二者均非实验室 logo。导航栏品牌图标已正确使用 images/logo.png（live HTML 验证），仅 favicon 错误。"
  artifacts:
    - path: "favicon.svg"
      issue: "模板 monogram 而非 logo"
    - path: "favicon.ico"
      issue: "同源的模板图标"
    - path: "_includes/head.html"
      issue: "icon/alternate-icon link 指向上述两个文件（第 30-31 行）"
  missing:
    - "favicon.ico ← 复制旧站备份 ~/GitHub/zhangtaolab.github.io-legacy-backup/assets/images/favicon.ico（32×32+16×16 双尺寸，用户指定素材，2026-08-19 指示）覆盖根目录 favicon.ico"
    - "head.html:30 icon 链接改为 /images/logo.png（type image/png，现代浏览器高清晰度主图标）；head.html:31 alternate icon 保持指向 favicon.ico（现已是旧站真图标）；删除不再被引用的模板 favicon.svg"
  debug_session: ""
