---
status: testing
phase: 02-auto-deploy
source: [02-VERIFICATION.md]
started: 2026-08-19T04:50:00Z
updated: 2026-08-19T04:50:00Z
---

## Current Test

number: 1
name: 在线视觉终检 — 浏览器打开 https://zhangtaolab.org/（连同 /publications/、/news/）目检，确认渲染效果与本地 `bundle exec jekyll serve` 预览一致
expected: |
  机器已证实线上输出与本地构建字节级一致（除 Cloudflare 邮箱混淆）；
  此项是"显示效果与本地预览一致"成功标准中字面意义上的视觉成分，需人眼确认
  （布局、字体、暗色模式切换均正常）。
awaiting: user response

## Tests

### 1. 在线视觉终检
expected: 浏览器对比 zhangtaolab.org 与本地预览，渲染效果一致（布局/字体/暗色模式）
result: [pending]

### 2. CR-01/CR-02 内容缺陷裁定
expected: 裁定 02-REVIEW.md 两个 critical 内容缺陷（均为 Phase-1 内容面、随部署曝光，非本阶段 must_haves 违例）：CR-01 teaching.md 模板占位课程已在线上（Feynman Lectures 等，实测 /teaching/ 命中 2 处）；CR-02 8 条 PDF 链接线上 404（实测 /pdf/2013/PNAS_2013.pdf=404）。决定修复（提供课程列表/PDF 文件）或暂时接受
result: [pending]

### 3. Prohibitions 复核确认
expected: 确认 4 条 judgment 级 prohibitions 复核结论（见 02-VERIFICATION.md Prohibitions 表，验证者裁定均为『未违反』）
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
