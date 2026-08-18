---
status: testing
phase: 1-本地开发环境
source: [01-VERIFICATION.md]
started: 2026-08-17T09:55:00+08:00
updated: 2026-08-18T13:35:00+08:00
---

## Current Test

number: 6
name: 重排后 research/software 页面对参考站的最终视觉确认（G-1-5 闭合步骤，03-PLAN 指定）
expected: |
  bundle exec jekyll serve 后打开 /research/、/software/，与 https://wmsd5fpo6kcfi.ok.kimi.link/ 并排目检：
  平铺等高卡片网格（无嵌套壳）、真实 Core Focus/Core Toolkit 徽章元素、内衬圆角图片、虚线 Screenshot
  占位框；版式匹配参考站、无可见标签文本。
awaiting: user response

## Round 3（gap closure G-1-5/G-1-6 后复验，2026-08-18）

G-1-5 / G-1-6 已经 03-PLAN（commits 8af4a82/ca3e7c6/6055212/923bc77）闭合，并由 01-VERIFICATION.md
（2026-08-18 第三轮复验）以独立重跑的 build/serve/grep/python-DOM/git 证据确认：32/32 机器真值通过
（11 本轮直查：4 条 roadmap SC + 7 条 G-1-5/G-1-6 闭合真值；21 条 plan-01/02 回归全数保持）、0 缺口、
0 禁制违例、ENV-01/ENV-02 全覆盖。剩余 2 项人工事项见测试 6（重排页最终视觉确认，03-PLAN 指定的
G-1-5 闭合认定步骤）与测试 7（新 CR-01：feed.xml RSS 转义决策）。G-1-5/G-1-6 在 Gaps 区仍登记
failed，待测试 6 通过后由 /gsd-verify-work 归零。

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
result: issue
reported: "automated visual verification: /software/ 渲染 9 处字面转义标签文本（参考站 0 处）。用户目检确认（2026-08-18）：'http://localhost:4000/research/ 和 /software/ 页面混乱，建议参考参考站对应页重新排版' —— research 页同样判定失败（自动检查低估：kramdown 对内联 <img> 的 <p> 包裹 + 首卡未闭合导致外层卡片框包住全部 8 卡、页高 3639px vs 参考站 2322px，视觉混乱；Core Focus</div> 字面文本参考站亦有但整体版式差异显著）"
severity: major
source: automated
user_confirmed: "research + software 两页版面混乱，需参考 ref-research.html / ref-software.html 重新排版"
evidence: "①grep -rc '&lt;' _site：software=9、research=1、其余页 0。②根因：'文本</div>' 同行写法被 kramdown（parse_block_html:true）转义为可见文本；kramdown 另将内联 <img> 包成 <p> 改变盒模型；首卡 div 因转义丢失闭合 → 后续 7 卡嵌套其内（DOM 实测 card0 高 2969px 含 7 子卡，参考站卡片平铺 535px/卡）。③既有断言 grep '&lt;div' 只匹配开标签，闭合标签逃过 Task 6/复验 D1。④software 其余结构（16 卡/标题/按钮类）与参考站一致；research 8 图片本地全存在"

### 5. CR-01 决策：About 页 PDLLMs 死链（参考站继承缺陷）

expected: 人工决策二选一：(a) 接受参考保真——保留 _pages/about.md 两处 github.com/zhangtaolab/PDLLMs 死链（ref-about.html 同样链向该失效 URL，02-PLAN 按快照逐字对齐所致）；或 (b) 修正——将两处链接重定向到真实存在的 github.com/zhangtaolab/Plant_DNA_LLMs（home/research/software 页已在用）。复验裁定：非 must-have 违例，不阻断阶段完成
result: pass
decision: "(b) 修正——用户 2026-08-18 确认选 b；改链并入本轮 gap-closure 修复计划（G-1-6）"
source: human
evidence: "01-REVIEW.md CR-01（git ls-remote 实证 PDLLMs 仓库 404、Plant_DNA_LLMs 存在）；VERIFICATION.md 裁定 2（继承自参考基准）"

### 6. 重排后 research/software 页面对参考站的最终视觉确认（G-1-5 闭合步骤，03-PLAN 指定）

expected: bundle exec jekyll serve 后打开 /research/、/software/，与 https://wmsd5fpo6kcfi.ok.kimi.link/ 并排目检：平铺等高卡片网格（无嵌套壳）、真实 Core Focus/Core Toolkit 徽章元素（非字面文本）、内衬圆角图片、虚线 Screenshot 占位框；版式匹配参考站、无可见标签文本。机器侧已证 0 转义 + DOM 平铺（DOM-FLAT-OK），最终视觉对齐超出机器证据能力
result: [pending]
source: human
evidence: "机器前置证据（01-VERIFICATION.md 第三轮独立重跑）：_site/research/index.html 与 _site/software/index.html 转义计数 0/0、全站 0；python html.parser DOM 门 DOM-FLAT-OK（8 张 research-card 均为 research-grid 直接子节点、8 张 section-card 平铺、8 张 software-card 各自独占其 section-card）；文案 strip-tag 归一化 diff 为空；16-URL serve 回环全 200"

### 7. CR-01（新，第三轮 01-REVIEW.md）：feed.xml RSS 转义决策

expected: 人工决策二选一：(a) Phase 2 部署前小修——feed.xml:23-24 在 xml_escape 前加 strip_html，消除 6 条 RSS 条目 title/description 中的转义 HTML 标记汤（&amp;lt;a href=&amp;quot;…&amp;gt;…，_site/feed.xml 实证）；或 (b) 接受现状并延后（feed.xml 为参考站继承的既有文件，三个 PLAN 均受禁制保护未改动，不违例任何 phase must-have，但属公开可见产物）。复验裁定：非 must-have 违例，不阻断阶段完成
result: [pending]
source: human
evidence: "01-REVIEW.md（2026-08-18 第三轮）CR-01：feed.xml:23-24 每条新闻以转义 HTML 标记汤作为 &lt;title&gt;/&lt;description&gt; 发布（RSS title 为纯文本字段，6 条条目在阅读器中不可读）；修复方案 strip_html | xml_escape"

## Summary

total: 7
passed: 4
issues: 1
pending: 2
skipped: 0
blocked: 0

## Gaps

- gap_id: G-1-5
  truth: "research 与 software 两页版式与参考站一致：0 处可见转义标签文本、卡片平铺不嵌套、无 kramdown <p> 包裹引起的盒模型漂移；整体视觉对齐 ref-research.html / ref-software.html"
  status: failed
  reason: "User reported + automated verification: /research/ 与 /software/ 页面混乱 —— software 渲染 9 处字面转义标签（Core Toolkit</div>、Screenshot</div> ×7、Open Source</div>，参考站 0 处）；research 首卡闭合标签被转义丢失 → 后续 7 卡嵌套进首卡（card0 高 2969px 含 7 子卡 vs 参考站卡片平铺 535px/卡；页高 3639px vs 2322px），另 Core Focus</div> 字面文本（该条参考站亦有）与内联 <img> 被 <p> 包裹的盒模型漂移"
  severity: major
  test: 4
  root_cause: "_pages/research.md 与 _pages/software.md 采用 '文本</div>' 同行写法的徽章/标签行 —— kramdown parse_block_html:true 将紧跟文本的闭合 div 转义为可见文本并丢掉真实闭合 → 卡片嵌套 + 字面残留；kramdown 同时将内联 <img> 包成 <p> 引入额外 margin。既有断言 grep '&lt;div' 只匹配开标签，闭合标签逃过 Task 5/6 验收与复验 D1 检查"
  artifacts:
    - path: "_pages/software.md"
      issue: "9 处 '文本</div>' 同行写法（Core Toolkit、Screenshot ×7、Open Source）被 kramdown 转义为可见文本"
    - path: "_pages/research.md"
      issue: "首卡 'Core Focus</div>' 闭合被转义 → 8 卡嵌套结构 + 字面残留；内联 img 被 <p> 包裹"
    - path: ".planning/phases/01-local-dev-environment/reference-snapshot/ref-research.html"
      issue: "重排目标基准（8 卡平铺，535px/卡）"
    - path: ".planning/phases/01-local-dev-environment/reference-snapshot/ref-software.html"
      issue: "重排目标基准（16 卡、徽章正常渲染、零转义）"
  missing:
    - "参考 ref-research.html / ref-software.html 重新排版两页：全部闭合标签独立成行或块级 markdown=\"0\"（免疫 '文本</div>' 转义）；确保卡片平铺不嵌套、img 不被 <p> 包裹（或以 CSS 抵消）；内容文案保持已对齐状态不动"
    - "验收断言升级：grep -c '&lt;' _site/research/index.html 与 _site/software/index.html 均为 0（任意标签，不限开标签）；DOM 断言 research-card/software-card 首卡高 ≈ 后续卡（无 2000px+ 嵌套壳）；页高与参考站同量级"
    - "research 页 'Core Focus' 徽章按参考站样式正常渲染（参考站亦有该字面残留，重排时按参考站最终视觉效果为准）"
  debug_session: ""
- gap_id: G-1-6
  truth: "About 页 PDLLMs 两处链接指向真实存在的仓库 github.com/zhangtaolab/Plant_DNA_LLMs（与 home/research/software 页一致）"
  status: failed
  reason: "CR-01（01-REVIEW.md Critical）：_pages/about.md 两处指向 github.com/zhangtaolab/PDLLMs（git ls-remote 实证 404）；用户 2026-08-18 决策选 (b) 修正"
  severity: minor
  test: 5
  root_cause: "02-PLAN 按参考快照逐字对齐，ref-about.html 本身链向该失效 URL（参考站自身缺陷）"
  artifacts:
    - path: "_pages/about.md"
      issue: "两处 PDLLMs href 指向不存在的 PDLLMs 仓库"
  missing:
    - "将 _pages/about.md 两处 PDLLMs href 改为 https://github.com/zhangtaolab/Plant_DNA_LLMs（链接文字不变）"
  debug_session: ""

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
