---
status: testing
phase: 1-本地开发环境
source: [01-VERIFICATION.md]
started: 2026-08-17T09:55:00+08:00
updated: 2026-08-17T09:55:00+08:00
---

## Current Test

number: 1
name: 浏览器实际自动刷新（T12, backstop）
expected: |
  在真实浏览器中打开本地预览（http://127.0.0.1:4000），修改源文件后无需手动刷新，页面即自动更新。

  操作步骤：
  1. cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll serve --livereload
  2. 浏览器打开 http://127.0.0.1:4000
  3. 编辑 _pages/home.md（例如在 hero 区后加一行文字并保存）
  4. 不刷新浏览器，观察页面在数秒内自动出现改动
  5. 测试完还原 _pages/home.md 并停掉 serve 进程

  机器侧已证（不足以关闭本项）：livereload 客户端 JS 在 127.0.0.1:35729 返回 200（Jekyll 4.4.1 专用 reload 服务器，仅回环）；serve 日志 Regenerating ≤1s；页面注入的 loader 指向 35729。
awaiting: user response

## Tests

### 1. 浏览器实际自动刷新（T12）

expected: 真实浏览器 WebSocket 连接建立，修改源文件后无需手动刷新页面即更新（机器探针仅证再生链路，未证浏览器端免手动刷新行为）
result: [pending]

### 2. 页面布局视觉正常（T13）

expected: 浏览器逐页检查样式加载（非裸 HTML 观感）、图片正常显示、布局无错乱；重点页：首页、/research/、/publications/、/team/、/news/。机器侧已证 /assets/main.css 返回 200 且 161,960 字节（>1000），但整体视觉超出机器证据能力
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
