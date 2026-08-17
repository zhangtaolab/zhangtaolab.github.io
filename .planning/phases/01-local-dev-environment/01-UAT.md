---
status: diagnosed
phase: 1-本地开发环境
source: [01-VERIFICATION.md]
started: 2026-08-17T09:55:00+08:00
updated: 2026-08-17T18:10:00+08:00
---

## Current Test

[testing complete]

## Tests

### 1. 浏览器实际自动刷新（T12）

expected: 真实浏览器 WebSocket 连接建立，修改源文件后无需手动刷新页面即更新（机器探针仅证再生链路，未证浏览器端免手动刷新行为）
result: pass
source: automated
evidence: "Playwright 真实 Chromium（用户指示以 agent+playwright 完成）：① 页面加载 livereload 客户端 http://127.0.0.1:35729/livereload.js?snipver=1&port=35729（DOM script 实测）；② 编辑 _pages/home.md 插入 UAT_LIVERELOAD_PROBE 后，未执行任何 navigate/reload，page.getByText waitFor(visible) 在打开的同一标签页命中探针；③ 还原文件后 waitFor(hidden) 命中，探针自动消失——双向闭环，全程零手动刷新。测试后 serve 进程已停止"

### 2. 页面布局视觉正常（T13）

expected: 浏览器逐页检查样式加载（非裸 HTML 观感）、图片正常显示、布局无错乱；重点页：首页、/research/、/publications/、/team/、/news/。机器侧已证 /assets/main.css 返回 200 且 161,960 字节（>1000），但整体视觉超出机器证据能力
result: pass
source: automated
evidence: "Playwright 全页/视口截图 5 页逐页目检：首页（hero 渐变、4 卡片研究区、新闻、出版物预览、页脚）、/research/（4 个研究区块 + 标签 pills）、/publications/（年份徽章 2026/2025 + 期刊条目排版）、/team/（PI 与成员照片全部正常显示、校友年份分组）、/news/（日期分组时间线）。样式完整加载、图片正常、无布局错乱。截图文件 uat-01-home.png ~ uat-05-news.png（验证后已删除，不入库）"

### 3. 本地构建内容与参考站一致（用户复检报告）

expected: 理论上本地网站应该和 https://wmsd5fpo6kcfi.ok.kimi.link/ 展示出来的内容一致（用户视为内容权威基准）
result: issue
reported: "编译出来的内容和https://wmsd5fpo6kcfi.ok.kimi.link/ 不一致需要检查，理论上本地网站应该和 https://wmsd5fpo6kcfi.ok.kimi.link/ 展示出来的内容一致"
severity: major
source: automated-diff
evidence: "逐页文本级对比（参考站 8 页快照存 .planning/phases/01-local-dev-environment/reference-snapshot/）：①本地 about(3处)/team(23处) HTML 被 kramdown 转义为 Rouge plaintext 代码块（&lt;div&gt; 成可见文本，参考站 0 处）；②团队名单完全不同（本地: Ruimin Huang/Fangwei Guo/Yunhe Shen/Kangxin Hu/Han Liu/Jingwen Zhang；参考: Wu Yuechao-Research Scientist/Chen Long-PhD YZU/Dian Zhang-Master CIB + 校友表 Liu Guanqing 2017–2025）；③新闻条目集不同（本地 Latest+May-Aug 2026；参考 2026-03 tRNA+Trends Biotech/2024-12 PDLLMs-Mol Plant/2023-06 欢迎 Liu Guanqing & Wu Yuechao）；④首页 hero/研究/软件文案为不同年代版本（参考更具体：MCP 支持、Mol Plant 2025;18(2):175-178 引文、CrisprStitch 桌面应用描述）；⑤出版物 83 条目集一致仅排版差异（可接受）；⑥参考站自身缺陷不得对齐：{title} 未渲染占位符、扁平 .html URL、CDN 字体（fonts.loli.net 等）"

## Summary

total: 3
passed: 2
issues: 1
pending: 0
skipped: 0
blocked: 0

## Gaps

- gap_id: G-1-3
  truth: "本地 about/team 页面不得出现转义 HTML 代码块；嵌套 HTML 须按 HTML 渲染（与参考站一致为 0 处转义）"
  status: failed
  reason: "User reported: 编译出来的内容和参考站不一致；实测 loc-about.html 3 处、loc-team.html 23 处 &lt;div&gt; 出现在 Rouge language-plaintext 代码块中"
  severity: major
  test: 3
  root_cause: "kramdown 将 HTML 块内缩进 ≥4 空格的嵌套 HTML 解析为缩进代码块。home.md 的 hero-section 带 markdown=\"0\" 免疫；about.md 的 PI 卡片块与 team.md 的成员循环块未标记，内部 4 空格缩进的子 div 被当代码块渲染"
  artifacts:
    - path: "_pages/about.md"
      issue: "PI 卡片 section-card/pi-card 块无 markdown=\"0\"，内部缩进 HTML 变代码块"
    - path: "_pages/team.md"
      issue: "成员循环输出块同样缺 markdown=\"0\"，23 处转义"
  missing:
    - "为 about.md/team.md 的裸 HTML 卡片块加 markdown=\"0\"（对齐 home.md hero 的既有模式），或将子级 HTML 反缩进至块边界列"
    - "重建后断言：grep -c '&lt;div' _site/about/index.html _site/team/index.html 均为 0"
  debug_session: ""
- gap_id: G-1-4
  truth: "本地站点展示内容（团队名单、新闻条目、首页/研究/软件/关于文案）与参考站 https://wmsd5fpo6kcfi.ok.kimi.link/ 一致（内容基准；参考站自身的模板缺陷除外：{title} 占位符、扁平 URL、CDN 字体）"
  status: failed
  reason: "User reported: 编译出来的内容和参考站不一致；逐页对比证实 _data 与 _pages 内容为不同年代版本集"
  severity: major
  test: 3
  root_cause: "仓库内容数据与参考站内容集不同步：_data/team 成员（或 people.yml）为 Ruimin Huang 等名单，参考站为 Wu Yuechao/Chen Long/Dian Zhang + 校友 Liu Guanqing(2017–2025, PhD)；_data/news.yml 为 Latest+2026-05~08 条目，参考站为 2026-03/2024-12/2023-06 条目；_pages 首页 hero/研究区/软件卡文案为旧代版本（参考站含 MCP 支持、完整引文格式、CrisprStitch 桌面应用等更具体描述）"
  artifacts:
    - path: "_data/news.yml"
      issue: "新闻条目集与参考站不同（条目数量与内容均不同）"
    - path: "_data/team_members.yml 或 _data/people.yml + _data/alumni.yml"
      issue: "团队名单与参考站完全不同"
    - path: "_pages/index.md/home.md + _pages/research.md + _pages/software.md + _pages/about.md"
      issue: "文案年代与参考站不一致（参考站更具体/更新）"
    - path: ".planning/phases/01-local-dev-environment/reference-snapshot/ref-*.html"
      issue: "内容权威基准快照（8 页，已保存供对齐使用）"
  missing:
    - "以 reference-snapshot/ 为内容基准逐页对齐：团队名单（含校友表 Liu Guanqing 2017–2025 PhD）、新闻条目、首页 hero 与 PDLLMs/DNALLM-Suite 特色区文案、研究区描述、软件卡描述（含完整引文）"
    - "照片资产核对：参考站成员照片映射（liuguanqing.jpg、Wu Yuechao 等）在 images/team/ 是否存在，缺则用既有 placeholder 约定"
    - "不得引入参考站自身缺陷（{title} 占位符、扁平 .html 链接、外部 CDN 字体引用）；保留本地正确的 title 渲染、目录式 permalink、本地字体/CSS 资产"
    - "出版物页 83 条目集已一致，仅排版差异 —— 不动"
  debug_session: ""
