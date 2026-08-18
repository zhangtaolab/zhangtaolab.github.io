---
status: testing
phase: 1-本地开发环境
source: [01-VERIFICATION.md]
started: 2026-08-17T09:55:00+08:00
updated: 2026-08-18T09:18:00+08:00
---

## Current Test

number: 4
name: 重写页面对参考站的视觉一致性（D5）
expected: |
  本地起 serve（bundle exec jekyll serve），浏览器打开首页/about/team/research/software/news，
  与 https://wmsd5fpo6kcfi.ok.kimi.link/ 对应页并排目检：视觉布局与参考站一致
  （含 team 页渐变图标占位、about 页绿色渐变 PI 占位框、4 列校友表）；样式加载完整、图片正常。
  grep marker 已证内容逐字到位（复验 21/21），本项证视觉等价；
  2026-08-17 的 UAT 目检通过的是重写前旧页面，不覆盖本次重写后的新 DOM。
awaiting: user response

## Round 2（gap closure 后复验，2026-08-18）

G-1-3 / G-1-4 已经 02-PLAN（commits c4d4eff..c7c300e）闭合，并由 01-VERIFICATION.md（2026-08-18 复验）
以独立重跑 build/serve/grep/git 的证据确认：21/21 机器真值通过（10 gap-closure + 11 plan-01 回归）、
0 缺口、0 禁制违例、ENV-01/ENV-02 全覆盖。剩余 2 项人工事项见测试 4（视觉一致性）与测试 5（CR-01 决策）。

## Tests

### 1. 浏览器实际自动刷新（T12）

expected: 真实浏览器 WebSocket 连接建立，修改源文件后无需手动刷新页面即更新（机器探针仅证再生链路，未证浏览器端免手动刷新行为）
result: pass
source: automated
evidence: "Playwright 真实 Chromium（用户指示以 agent+playwright 完成）：① 页面加载 livereload 客户端 http://127.0.0.1:35729/livereload.js?snipver=1&port=35729（DOM script 实测）；② 编辑 _pages/home.md 插入 UAT_LIVERELOAD_PROBE 后，未执行任何 navigate/reload，page.getByText waitFor(visible) 在打开的同一标签页命中探针；③ 还原文件后 waitFor(hidden) 命中，探针自动消失——双向闭环，全程零手动刷新。测试后 serve 进程已停止"

### 2. 页面布局视觉正常（T13，重写前旧页面）

expected: 浏览器逐页检查样式加载（非裸 HTML 观感）、图片正常显示、布局无错乱；重点页：首页、/research/、/publications/、/team/、/news/。机器侧已证 /assets/main.css 返回 200 且 161,960 字节（>1000），但整体视觉超出机器证据能力
result: pass
source: automated
evidence: "Playwright 全页/视口截图 5 页逐页目检（注：通过时为重写前旧 DOM；重写后页面的视觉确认为本轮测试 4）。样式完整加载、图片正常、无布局错乱。截图文件 uat-01-home.png ~ uat-05-news.png（验证后已删除，不入库）"

### 3. 本地构建内容与参考站一致（用户复检报告）

expected: 理论上本地网站应该和 https://wmsd5fpo6kcfi.ok.kimi.link/ 展示出来的内容一致（用户视为内容权威基准）
result: pass
resolution: "2026-08-17 报 issue（severity: major）→ 产生 G-1-3/G-1-4 → 02-PLAN 重写 5 页 + 3 数据文件对齐参考快照 → 2026-08-18 复验确认闭合（_site 全站 0 处转义 HTML；团队/新闻/文案逐字对齐 ref-*.html）。本轮改记 pass；Gaps 区两条 gap 状态同步置 resolved"
source: automated-diff
evidence: "Round 1 证据留存：①本地 about(3处)/team(23处) HTML 被 kramdown 转义为 Rouge plaintext 代码块；②团队名单不同；③新闻条目集不同；④首页/研究/软件文案为不同年代版本；⑤出版物 83 条目集一致（可接受）；⑥参考站自身缺陷不得对齐。Round 2 复验（01-VERIFICATION.md 2026-08-18）：全部反向归零，详见 Gaps 区 resolution"

### 4. 重写页面对参考站的视觉一致性（D5）

expected: 本地 serve 后，/、/about/、/team/、/research/、/software/、/news/ 与 https://wmsd5fpo6kcfi.ok.kimi.link/ 并排目检视觉一致（team 渐变图标占位、about PI 占位框、4 列校友表、hero/卡片网格）；样式完整、图片正常
result: [pending]
source: human
why_human: "grep marker 证明内容逐字到位，不证明视觉等价（02-SUMMARY coverage D5，human_judgment: true）"

### 5. CR-01 决策：About 页 PDLLMs 死链（参考站继承缺陷）

expected: 人工决策二选一：(a) 接受参考保真——保留 _pages/about.md 两处 github.com/zhangtaolab/PDLLMs 死链（ref-about.html 同样链向该失效 URL，02-PLAN 按快照逐字对齐所致）；或 (b) 修正——将两处链接重定向到真实存在的 github.com/zhangtaolab/Plant_DNA_LLMs（home/research/software 页已在用）。复验裁定：非 must-have 违例，不阻断阶段完成
result: [pending]
source: human
evidence: "01-REVIEW.md CR-01（git ls-remote 实证 PDLLMs 仓库 404、Plant_DNA_LLMs 存在）；VERIFICATION.md 裁定 2（继承自参考基准）"

## Summary

total: 5
passed: 3
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps

- gap_id: G-1-3
  truth: "本地 about/team 页面不得出现转义 HTML 代码块；嵌套 HTML 须按 HTML 渲染（与参考站一致为 0 处转义）"
  status: resolved
  resolution: "02-PLAN Task 1/2/4 以列 0 平铺 HTML + markdown=\"0\" 重写 about/team/home；2026-08-18 复验：fresh build 后 grep -rl '&lt;div' _site --include='*.html' = 0 文件（基线 about=3、team=23），language-plaintext 全站 0；重写源文件 0 行 ≥4 空格缩进 HTML（复发条件消除）"
  severity: major
  test: 3
- gap_id: G-1-4
  truth: "本地站点展示内容（团队名单、新闻条目、首页/研究/软件/关于文案）与参考站 https://wmsd5fpo6kcfi.ok.kimi.link/ 一致（内容基准；参考站自身的模板缺陷除外：{title} 占位符、扁平 URL、CDN 字体）"
  status: resolved
  resolution: "02-PLAN Task 1–6 重写 5 页 + team_members/alumni/news 数据对齐参考快照（people.yml 孤儿数据删除）；2026-08-18 复验：PI/Wu Yuechao/Chen Long/Dian Zhang/Join Us/4 列校友表（Liu Guanqing 2017–2025 PhD、Bao Yu 2018–2025 PhD en-dash 逐字匹配）；新闻 6 条顺序与 ref-news.html 一致、首页侧栏 3 条；反向断言（旧名单/双路径/假图/{title}/扁平链接/CDN 字体）全部 0 命中；publications.md diff 7cac7e4 为空（83 条未动）"
  severity: major
  test: 3
