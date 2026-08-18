---
phase: 1
plan: 03
type: execute
wave: 2
depends_on: ["1-02"]
files_modified:
  - _pages/research.md
  - _pages/software.md
  - _pages/about.md
  - _pages/home.md
autonomous: true
requirements:
  - ENV-01
gap_closure: true
gap_ids: [G-1-5, G-1-6]
estimate:
  tokens: 35000
  raw_tokens: 35000
  tasks: 4
  confidence: low
must_haves:
  truths:
    - "`grep -c '&lt;' _site/research/index.html` = 0 且 `grep -c '&lt;' _site/software/index.html` = 0（升级断言：任意标签而非仅开标签；全站其余页保持 0）"
    - "research 页 8 张 .research-card 全部为 .research-grid 的直接子节点，无任何卡片嵌套于另一卡片内（首卡不再出现 2900px 级嵌套壳；参考站为平铺 ~535px/卡量级）"
    - "software 页 8 张 .section-card 平铺（每张恰含 1 个 .software-card）；徽章、7 处截图占位与页尾 callout 标题均渲染为真实 HTML 元素而非可见标签文本"
    - "research 页 8 卡各含 1 个 .core-badge（首卡填充 Core Focus、其余 7 卡空占位对齐卡顶），样式来自页内覆盖块（参考站第 50-61 行同款）"
    - "两页可见文案与重排前逐字一致（strip-tag 归一化文本 diff 为空）—— 文案保持 02-PLAN 已对齐状态不动"
    - "_pages/about.md 两处 + _pages/home.md 一处原失效仓库 href 全部指向 https://github.com/zhangtaolab/Plant_DNA_LLMs，链接文字与其余标记不变（G-1-6，用户决策 b）"
    - "回环 serve（仅 127.0.0.1:4000）/、/about/、/research/、/software/ 全部返回 200，验证后进程停止"
  artifacts:
    - _pages/research.md
    - _pages/software.md
    - _pages/about.md
    - _pages/home.md
    - .planning/phases/01-local-dev-environment/03-SUMMARY.md
  key_links:
    - "research.md 页内 main 前缀覆盖块 ↔ _layouts/default.html 第 10 行 main.site-container（gridlay 继承 default，main 前缀选择器命中前提）"
    - "markdown 属性直通包装 ↔ kramdown parse_block_html:true（转义免疫机制，about/home 已验证范式）"
    - "卡片 img 的 Liquid 绝对路径 ↔ images/research/*.jpg 与 images/software/dnallm-suite.png（Liquid 先于 kramdown 解析）"
  prohibitions:
    - "不得改动 _sass/、assets/css/、assets/main.scss、assets/main.css（CSS 与参考站逐字节同尺寸且类集合一致；G-1-5 是标记层问题，样式仅经页面自身 style 元素补充——参考站同款做法）"
    - "不得改动两页可见文案、图片文件、_data 数据（文案已对齐并验证；本计划仅改标记结构、class、行内样式与失效 href）"
    - "不得把参考快照 ref-research.html 第 137 行 alt 属性里的实体编码写法复制进本地源文件（会把转义实体带进构建产物、击穿零转义门槛；沿用本地现有纯文本 alt）"
    - "不得引入参考站自身缺陷：CDN 字体/图标（fonts.loli.net、zstatic.net、jsdmirror）、扁平 .html 链接、{title} 占位符"
    - "不得改动 _pages/publications.md、papers/ref.bib、contact/talks/teaching/blogs 页（超出缺口范围）"
    - "本地 serve 仅默认绑定 127.0.0.1（禁止 --host 0.0.0.0）"
    - "不得并行执行任务或并行构建（共享 _site/ 与 git 索引，严格按 1→4 顺序）"
---

# Phase 1 Gap Closure 计划 03：research/software 版式重排（G-1-5）+ PDLLMs 死链修正（G-1-6）

<objective>
关闭 01-UAT.md 中仅存的两个 failed 缺口：

- **G-1-5（major，测试 4）**：/research/ 与 /software/ 版面混乱 —— research 首卡闭合标签被 kramdown 转义丢失导致 8 卡嵌套（card0 实测 2969px 含 7 子卡，页高 3639px vs 参考站 2322px）；software 渲染 9 处字面转义标签文本（参考站 0 处）。两页按 ref-research.html / ref-software.html 结构重排，文案零改动。
- **G-1-6（minor，测试 5）**：about 页两处指向 CR-01 实证 404 的 PDLLMs 仓库死链，按用户 2026-08-18 决策 (b) 修正为真实仓库 Plant_DNA_LLMs，链接文字不变。

Purpose: Phase 1 成功标准 2（"本地预览显示所有页面……布局正常"）在 research/software 两页未达成；本计划以已验证的转义免疫范式（markdown 属性直通包装）重排两页，并升级验收断言（任意标签零转义 + DOM 平铺检查）堵住"只查开标签"的逃逸路径。

Output: 重排后的 _pages/research.md、_pages/software.md，修正死链的 _pages/about.md、_pages/home.md，以及 03-SUMMARY.md（G-1-5/G-1-6 闭合证据）。
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-local-dev-environment/01-UAT.md
@.planning/phases/01-local-dev-environment/reference-snapshot/ref-research.html
@.planning/phases/01-local-dev-environment/reference-snapshot/ref-software.html
@_pages/home.md
@_pages/about.md
</context>

## 决策锁定（无 CONTEXT.md；决策来自 UAT 测试 4/5 的用户确认）

1. **用户决策（2026-08-18，测试 4）**：research/software 两页"版面混乱，需参考 ref-research.html / ref-software.html 重新排版"——重排为参考站结构；内容文案保持 02-PLAN 已对齐状态不动（markup/layout 重构，非内容重构）。
2. **用户决策 (b)（2026-08-18，测试 5 / CR-01）**：about 页 PDLLMs 死链选修正——两处 href 改指真实存在的 Plant_DNA_LLMs 仓库，链接文字不变。
3. 02-PLAN 的 Flagged assumption #3（"保留 research/software 内联尺寸样式"）已被 G-1-5 证伪推翻，本计划按上述用户决策改为参考站类结构。

## 现状盘点（2026-08-18 planner 逐项实测，执行者以此为基准）

1. **构建产物现状**：`grep -c '&lt;' _site/research/index.html` = 1、`_site/software/index.html` = 9、其余页 0（与 UAT 证据一致）。9 处症状全部是"可见文字后紧跟闭合标签"的单行块：software 首卡 Core Toolkit 徽章（31 行）、7 处截图占位 div（57/70/83/104/125/138/157 行）、页尾开源 callout 标题（164 行）；research 首卡徽章（18 行）。
2. **免疫范式实证（仓库内已验证）**：`_config.yml` 设 kramdown `parse_block_html: true`；`_pages/about.md` 的 section-card/callout 与 `_pages/home.md` 的 hero/芯片容器/横幅均用 markdown 属性值为 0 的直通包装（02-PLAN 重写，2026-08-18 复验全站 0 转义）；配合列 0 平铺 HTML。单行"文字+闭合标签"写法在直通区内免疫（about.md 第 47 行 callout-title 即此类单行，构建产物干净）。
3. **CSS 事实**：`core-badge`、`img-wrap` 不在 assets/main.css（本地与参考站皆然，02-PLAN 盘点 + 本次复核：main.css 含 research-card ×7、research-grid ×1、section-card ×9，无 core-badge/img-wrap）；参考站在 ref-research.html 第 50-61 行以页内 style、main 前缀高特异性 + !important 覆盖块供样（含空 core-badge 的 min-height 22px 卡顶对齐、img-wrap 内衬 10px 圆角图片）。software 页 style 块与 ref-software.html 第 51-62 行逐条对齐，仅缺 `.software-card` 的 `margin-bottom: 0` 一条。
4. **布局链**：gridlay → default（第 10 行 `<main class="site-container">`）→ `main .research-grid ...` 页内覆盖选择器可命中。
5. **参考快照转义审计**：ref-research.html 全文仅第 137 行 alt 属性含实体编码（可见文本零残留）、ref-software.html 0 处——"Core Focus 徽章按参考站最终视觉效果"即干净渲染的真实徽章元素；第 137 行实体 alt 不得复制（见 prohibitions）。
6. **死链清单（grep 实测）**：about.md 第 43、48 行两处 + home.md 第 24 行一处（同一 CR-01 根因，UAT"home 已在用"表述不完整——home 同时存在正确与失效链接各一）。
7. **资产**：images/research/ 下 8 张卡片图与 images/software/dnallm-suite.png 本地齐全（UAT 实测），无需新建图片。
8. 无包安装任务（无 npm/pip/cargo install），Package Legitimacy Gate 不适用。

<tasks>

<task type="auto">
  <name>Task 1: research 页参考站重排 —— 直通包装 + core-badge/img-wrap 类结构（G-1-5）</name>
  <files>_pages/research.md</files>
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-research.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/research.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/about.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_layouts/default.html
  </read_first>
  <precondition>_layouts/default.html 提供 main.site-container 包裹（gridlay 继承之），images/research/ 下 8 张图齐全（UAT 已实测）。</precondition>
  <action>
    根因回顾（01-UAT.md G-1-5 root_cause）：现文件首卡徽章行是"可见文字后紧跟闭合标签"的单行写法，kramdown（parse_block_html: true）把它转义为可见文本并丢失真实闭合，后续 7 卡全部嵌套进首卡；内联 img 另被包成段落改变盒模型。重排策略 = 参考站类结构 + 直通免疫包装。

    重写 `_pages/research.md`（frontmatter、h1、导语段落原样保留）：
    1. **页内 style 块**：保留现有 max-width 规则，并把 ref-research.html 第 50-61 行（`:root` accent 钉扎一行 + 注释 "Override template's default research styles" 起的整段覆盖块，含 core-badge、img-wrap、img、research-body、h4、p 规则）**原样逐字并入**；max-width 规则置于最末（与参考站第 62 行位置一致）。不复制参考站第 13-49 行的搜索框样式（属布局层，本地已有）；不改任何 _sass/assets 文件。
    2. **卡片区**：整个网格改为单一容器 div（class 为 research-grid）并加 markdown 属性值为 0 —— 与 home.md hero、about.md section-card 同范式，容器内全部原样直通、不经 markdown 解析。容器内列 0 平铺 HTML，闭合标签独立成行，不依赖任何缩进。
    3. **8 张卡片**按 ref-research.html 第 112-198 行结构重排：首卡 class 为 `research-card core`，其余 7 卡为 `research-card`；每卡第一个子元素为 core-badge div（首卡内为文字 Core Focus，其余 7 卡为**空元素占位**以对齐卡顶，参考站同款）；img-wrap 去掉全部行内样式（高度/背景/内衬/圆角由覆盖块接管，视觉从满幅封面图变为参考站的内衬 10px 圆角图）；img 保留 `{{ site.url }}{{ site.baseurl }}` 绝对路径、本地现有 alt 文本与 `loading="lazy"`，去掉行内样式；research-body、h4、p 均去行内样式，由覆盖块供样。
    4. **文案零改动**：8 个 h4 标题与段落正文、两个链接（Plant_DNA_LLMs 与 DNALLM）的 href/文字/强调标记从现文件逐字照搬，含 em 强调与 ampersand 实体。明确不采纳参考站第 137 行的实体编码 alt（见 prohibitions），沿用本地纯文本 alt。
    5. 本任务提交前先跑 verify 中的文本保全校验（对照 HEAD 的重写前版本），确认仅标记结构变化后再以 `fix(1-03): relayout research page per reference snapshot (G-1-5)` 提交。
  </action>
  <verify>
    <automated>cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll build && \
echo "escapes=$(grep -c '&lt;' _site/research/index.html)" && \
echo "cards=$(grep -c 'class="research-card' _site/research/index.html)" && \
echo "badges=$(grep -c 'class="core-badge"' _site/research/index.html)" && \
echo "filled=$(grep -c 'class="core-badge">Core Focus</div>' _site/research/index.html)" && \
git show HEAD:_pages/research.md | sed -n '/<h1/,$p' | python3 -c "import sys,re; sys.stdout.write(re.sub(r'\s+',' ',re.sub(r'<[^>]*>',' ',sys.stdin.read())).strip())" > /tmp/g15-old-r.txt && \
sed -n '/<h1/,$p' _pages/research.md | python3 -c "import sys,re; sys.stdout.write(re.sub(r'\s+',' ',re.sub(r'<[^>]*>',' ',sys.stdin.read())).strip())" > /tmp/g15-new-r.txt && \
diff /tmp/g15-old-r.txt /tmp/g15-new-r.txt && echo RESEARCH-GATE-PASS</automated>
    <expected>escapes=0；cards=8；badges=8；filled=1；归一化文本 diff 为空并输出 RESEARCH-GATE-PASS。注意：此命令须在本任务 commit 之前运行（HEAD 才是重写前版本）。</expected>
  </verify>
  <done>_site/research/index.html 零转义实体（任意标签）；8 张卡片类结构与参考站一致（首卡 core + 填充徽章，7 空徽章占位）；可见文案与重写前逐字相同；页内含参考站同款 main 前缀覆盖块。</done>
</task>

<task type="auto">
  <name>Task 2: software 页参考站重排 —— 平铺 section-card + 直通包装（G-1-5）</name>
  <files>_pages/software.md</files>
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-software.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/software.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/home.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_layouts/gridlay.html
  </read_first>
  <action>
    本页 9 处症状（01-UAT.md G-1-5 artifacts）全部是"可见文字后紧跟闭合标签"的单行块；其余结构（8 张卡、4 个分组标题、按钮类）与参考站一致。重排策略 = 去分组容器 + 逐卡直通包装。

    重写 `_pages/software.md`（frontmatter、h1、导语段、4 个 h2 section-heading、全部卡片文案/三条完整 Citation/按钮 href/缩略图 原样保留）：
    1. **页内 style 块**：用 ref-software.html 第 51-62 行的 software 专用块**整体替换**现 style 内容（与现状仅差 `.software-card` 补 `margin-bottom: 0` 一条及顺序）；不复制参考站第 13-49 行搜索框样式。
    2. **去分组容器**：移除包裹各章节卡片的 4 组无样式分组网格容器 div（class 以 software 前缀、grid 结尾，main.css 与参考站均无定义；开/闭标签约在现文件 28/87、91/108、112/142、146/161 行）——参考站结构是 h2 后直接跟 section-card，卡片平铺。
    3. **逐卡直通**：8 张 section-card 每张加 markdown 属性值为 0（about.md 同范式）；首卡保留 border 行内样式与 Core Toolkit 徽章单行（直通区内免疫）；software-card / software-body / pub-actions / software-thumb / software-thumb-placeholder 层级照参考站第 112-229 行；7 处截图占位与缩略图 img 保留现有文字/路径/alt/loading 属性。
    4. **页尾 callout**：加 markdown 属性值为 0（home.md/about.md 的 callout 同范式），其标题单行写法在直通区内免疫。
    5. 容器内列 0 平铺、闭合标签独立成行；文案零改动；提交前先跑 verify 中的文本保全校验，通过后以 `fix(1-03): relayout software page per reference snapshot (G-1-5)` 提交。
  </action>
  <verify>
    <automated>cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll build && \
echo "escapes=$(grep -c '&lt;' _site/software/index.html)" && \
echo "sections=$(grep -c 'class="section-card"' _site/software/index.html)" && \
echo "cards=$(grep -c 'class="software-card"' _site/software/index.html)" && \
echo "placeholders=$(grep -c 'software-thumb-placeholder">Screenshot</div>' _site/software/index.html)" && \
echo "toolkit=$(grep -c 'Core Toolkit</div>' _site/software/index.html)" && \
echo "gridwrappers=$(grep -c 'software-grid' _pages/software.md)" && \
git show HEAD:_pages/software.md | sed -n '/<h1/,$p' | python3 -c "import sys,re; sys.stdout.write(re.sub(r'\s+',' ',re.sub(r'<[^>]*>',' ',sys.stdin.read())).strip())" > /tmp/g15-old-s.txt && \
sed -n '/<h1/,$p' _pages/software.md | python3 -c "import sys,re; sys.stdout.write(re.sub(r'\s+',' ',re.sub(r'<[^>]*>',' ',sys.stdin.read())).strip())" > /tmp/g15-new-s.txt && \
diff /tmp/g15-old-s.txt /tmp/g15-new-s.txt && echo SOFTWARE-GATE-PASS</automated>
    <expected>escapes=0；sections=8；cards=8；placeholders=7；toolkit=1；gridwrappers=0；归一化文本 diff 为空并输出 SOFTWARE-GATE-PASS。此命令须在本任务 commit 之前运行。</expected>
  </verify>
  <done>_site/software/index.html 零转义实体；8 张 section-card 平铺（每张恰含 1 个 software-card）；徽章/占位/callout 标题均为真实 HTML 元素；可见文案与重写前逐字相同。</done>
</task>

<task type="auto">
  <name>Task 3: PDLLMs 死链修正 —— about ×2 + home ×1（G-1-6，用户决策 b）</name>
  <files>_pages/about.md, _pages/home.md</files>
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/about.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/home.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/01-UAT.md
  </read_first>
  <action>
    用户 2026-08-18 决策 (b)（01-UAT.md 测试 5；01-REVIEW.md CR-01 以 git ls-remote 实证：旧仓库 404、目标仓库存在）：
    1. `_pages/about.md`：将第 43 行（Research Interests 列表项）与第 48 行（Featured Work callout 内）两处指向失效 PDLLMs 仓库的 href 替换为 `https://github.com/zhangtaolab/Plant_DNA_LLMs`；链接文字（"PDLLMs" 与 "Get PDLLMs on GitHub"）与其余标记一律不动。
    2. 同根源扩展（CR-01 同一根因，避免下轮审计复报）：`_pages/home.md` 第 24 行导语段内同一失效仓库 href（共 1 处）一并替换为同一目标 URL，链接文字不变。
    3. 不改动 research.md/software.md 内已正确的链接；不动其它任何内容。
    4. 以 `fix(1-03): point PDLLMs links to existing Plant_DNA_LLMs repo (G-1-6)` 提交。
  </action>
  <verify>
    <automated>cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll build && \
echo "dead-left=$(grep -rn 'zhangtaolab/PDLLMs' _pages/ | wc -l | tr -d ' ')" && \
echo "about-canonical=$(grep -o 'zhangtaolab/Plant_DNA_LLMs' _site/about/index.html | wc -l | tr -d ' ')" && \
echo "home-canonical=$(grep -o 'zhangtaolab/Plant_DNA_LLMs' _site/index.html | wc -l | tr -d ' ')" && \
echo "about-text=$(grep -c 'Get PDLLMs on GitHub' _site/about/index.html)"</automated>
    <expected>dead-left=0；about-canonical=2；home-canonical=2（第 24 行修正 + 原有 callout 各一）；about-text=1（链接文字未变）。</expected>
  </verify>
  <done>_pages/ 内不再有任何指向失效 PDLLMs 仓库的 href；about 两处与 home 一处均指向真实仓库 Plant_DNA_LLMs；链接文字与其余标记逐字未动。</done>
</task>

<task type="auto">
  <name>Task 4: 集成终验 —— 全站零转义 + DOM 平铺断言 + serve 冒烟 + SUMMARY（G-1-5/G-1-6 终验）</name>
  <files>.planning/phases/01-local-dev-environment/03-SUMMARY.md</files>
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/01-UAT.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/STATE.md
  </read_first>
  <action>
    1. 仓库根全新执行 `bundle exec jekyll build`（退出码必须 0，无 Unknown tag、无 Liquid 报错）。
    2. 跑 verify 中全部断言：(a) 全站任意页零转义实体（G-1-3/G-1-4 回归保护 + G-1-5 升级断言）；(b) 两页 DOM 平铺 python 断言（research-card ×8 全为 research-grid 直接子节点且零嵌套；section-card ×8 平铺于 fade-in-section、software-card ×8 各居其卡）；(c) 源文件复发条件检查（4 空格以上缩进 HTML 为 0 行，沿用 1-02 断言）；(d) 死链清零回归。
    3. 回环 serve 冒烟：后台启动 `bundle exec jekyll serve`（默认绑定 127.0.0.1:4000，禁止 --host 0.0.0.0），curl 断言后停止进程（不留后台服务，再 curl 应被拒）。
    4. 全部通过后写 `.planning/phases/01-local-dev-environment/03-SUMMARY.md`：记录 G-1-5/G-1-6 闭合证据（各断言命令与实测数值：转义计数 0、卡片计数 8/8/8、死链 0、serve 200 清单），注明"最终视觉一致性由 /gsd-verify-work 复跑 UAT 测试 4 确认"。
    5. 以 `test(1-03): integrated gate for G-1-5/G-1-6 closure` 提交；确认 `git status --porcelain` 为空、`_site/` 未被跟踪。
  </action>
  <verify>
    <automated>cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll build && \
echo "site-wide-escape-files=$(grep -rl '&lt;' _site --include='*.html' | wc -l | tr -d ' ')" && \
echo "indent-recurrence=$(grep -En '^ {4,}.*<' _pages/research.md _pages/software.md | wc -l | tr -d ' ')" && \
echo "dead-left=$(grep -rn 'zhangtaolab/PDLLMs' _pages/ | wc -l | tr -d ' ')" && \
python3 - <<'PY'
from html.parser import HTMLParser
class Flat(HTMLParser):
    def __init__(self, targets):
        super().__init__(); self.targets=set(targets); self.stack=[]; self.rows={t:[] for t in targets}
    def handle_starttag(self,tag,attrs):
        if tag!='div': return
        cls=dict(attrs).get('class') or ''
        toks=cls.split()
        for t in self.targets:
            if t in toks:
                depth=sum(1 for s in self.stack if s in self.targets)
                parent=self.stack[-1] if self.stack else ''
                self.rows[t].append((depth,parent))
        self.stack.append(cls)
    def handle_endtag(self,tag):
        if tag=='div' and self.stack: self.stack.pop()
r=Flat(['research-card']); r.feed(open('_site/research/index.html').read())
assert len(r.rows['research-card'])==8, r.rows
assert all(d==0 and p=='research-grid' for d,p in r.rows['research-card']), r.rows['research-card']
s=Flat(['section-card','software-card']); s.feed(open('_site/software/index.html').read())
assert len(s.rows['section-card'])==8 and len(s.rows['software-card'])==8, s.rows
assert all(d==0 and p=='fade-in-section' for d,p in s.rows['section-card']), s.rows['section-card']
assert all(d==0 and p=='section-card' for d,p in s.rows['software-card']), s.rows['software-card']
print('DOM-FLAT-OK')
PY
(bundle exec jekyll serve >/tmp/g15-serve.log 2>&1 & echo $! > /tmp/g15-serve.pid) && sleep 8 && \
for p in / /about/ /research/ /software/; do printf '%s:%s\n' "$p" "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000$p)"; done && \
kill $(cat /tmp/g15-serve.pid) 2>/dev/null; pkill -f 'jekyll serve' 2>/dev/null; sleep 1; \
curl -s -o /dev/null --max-time 2 http://127.0.0.1:4000/ && echo 'SERVE-STILL-UP-FAIL' || echo SERVE-STOPPED</automated>
    <expected>site-wide-escape-files=0；indent-recurrence=0；dead-left=0；python 输出 DOM-FLAT-OK（任何断言失败会抛异常终止）；4 个 URL 全部打印 :200；结尾输出 SERVE-STOPPED（serve 已停）。</expected>
  </verify>
  <done>全新构建退出码 0；全站 *.html 零转义实体；两页卡片 DOM 平铺断言全过；源文件无 4 空格以上缩进 HTML；死链清零；serve 冒烟 4 页 200 且进程已停；03-SUMMARY.md 已写入并提交，工作区干净。</done>
</task>

</tasks>

## Artifacts this plan produces

- **重排（markup-only）**：`_pages/research.md`、`_pages/software.md`（参考站 DOM 结构 + 页内 style 覆盖块 + 直通包装；文案/图片/数据零改动）
- **链接修正**：`_pages/about.md`（2 处 href）、`_pages/home.md`（1 处 href）
- **记录**：`.planning/phases/01-local-dev-environment/03-SUMMARY.md`
- **不动**：`_sass/`、`assets/`、`_data/`、`_layouts/`、`_includes/`、`_config.yml`、`_pages/publications.md`、`papers/ref.bib`、其余页面、图片文件
- **无**新依赖、新插件、新脚本文件、新图片

## Flagged assumptions

| 假设 | 依据 | 证伪后果 |
|---|---|---|
| markdown 属性直通包装对 research-grid/section-card/callout 生效（单行"文字+闭合标签"在直通区内免疫） | about.md 第 47 行 callout-title 同款单行在 02-PLAN 重写后构建产物 0 转义（2026-08-18 复验）；home.md hero/芯片/横幅同范式 | 若构建后仍现转义，改用"闭合标签独立成行"拆行写法重排（同样免疫），重跑 Task 1/2 verify |
| 参考"Core Focus 徽章最终视觉"= 快照的干净渲染（非字面残留） | ref-research.html 可见文本零转义残留（仅第 137 行 alt 属性含实体）；升级断言全站零转义与字面残留互斥 | 无需行动——若用户坚持复刻参考站的字面残留，需推翻升级断言并重新决策（与 G-1-5 missing 第 3 条冲突，默认不采纳） |
| home.md 第 24 行死链并入 G-1-6 修复 | 同一 CR-01 根因（git ls-remote 实证 404）；G-1-6 truth 要求"与 home/research/software 页一致"；UAT"home 已在用"实测不完整（home 同时存在正确与失效链接各一） | 若用户认为超出 G-1-6 范围，revert home.md 该行即可（不影响 about 两处主修复与断言 about-canonical=2） |
| kramdown 直通输出不剥 markdown 属性也无碍 | 属性在产物中为惰性布尔样式；about/home 已上线同款产物 | 无需行动；即便保留在 HTML 中也不影响渲染与断言 |

<threat_model>
asvs_level: 1
block_on: high

**资产**：公开学术站点内容文件、git 历史、本地 HTTP 开发服务。本计划只改 4 个内容文件的标记结构与出站 href，不加依赖、不加网络服务、不处理用户输入。无包安装任务，Package Legitimacy Gate 不适用（无 T-{phase}-SC 行）。

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|---|---|---|---|---|---|
| T-01-06 | Tampering | about.md/home.md 出站 href 替换 | low | mitigate | 仅替换为 CR-01 git ls-remote 实证存在的仓库 URL，不引入任何新域名；Task 3/4 断言失效仓库 URL 计数为 0 |
| T-01-07 | Information Disclosure | target="_blank" 无 rel 属性（反向标签劫持面） | low | accept | 全站既有基线与参考站均无 rel 属性；静态公开站点无会话/鉴权上下文可劫持；站点级加固应统一实施，单独给两页加会破坏与参考站的标记保真 |
| T-01-08 | Tampering | research.md 新增页内 style 覆盖块（CSS 注入面） | low | mitigate | CSS 逐字取自仓库内参考快照第 50-61 行，无 url()/import/expression，不经手任何用户输入 |

**结论**：无 high 级威胁，无阻断项（block_on: high 不触发）。
</threat_model>

<verification>
阶段级验证（Task 4 为机器门禁，此处为总览）：

1. **升级断言（G-1-5 核心）**：`grep -c '&lt;'` 对 `_site/research/index.html`、`_site/software/index.html` 均为 0 —— 任意标签（开/闭/自包含），堵住 1-02/Task 6 复验 D1"只查开标签"的逃逸路径；全站 `grep -rl '&lt;' _site --include='*.html'` 为空（回归保护）。
2. **DOM 平铺断言**：python html.parser 深度检查 —— research-card ×8 全为 research-grid 直接子节点、零嵌套；section-card ×8 平铺、software-card ×8 各居其卡。这是"首卡高 ≈ 后续卡（无 2000px+ 嵌套壳）"的结构性根因断言（嵌套即高度爆炸的充要条件）。
3. **文案保全**：strip-tag 归一化文本 old/new diff 为空（两页）。
4. **serve 冒烟**：127.0.0.1:4000 上 /、/about/、/research/、/software/ 全 200，验后停服。
5. **可选渲染探针（辅助证据，非门禁）**：若环境可用 Playwright（UAT 先例），加载两页并取全部 research-card / section-card 的 boundingBox 高度，断言 max/min < 2（首卡与兄弟卡同量级）。
6. **最终视觉闭合**：机器门禁全过后，由 `/gsd-verify-work` 复跑 UAT 测试 4（与参考站并排目检）确认 —— 本计划的 SUMMARY 需注明该后续步骤。
</verification>

<success_criteria>
- 01-UAT.md G-1-5 与 G-1-6 可置 resolved：两页零转义、卡片平铺、徽章真实渲染、文案未动；死链清零且链接文字未变。
- Task 1-4 全部 done 条件满足，4 个原子提交入库，工作区干净。
- Phase 1 成功标准 2（"本地预览显示所有页面……布局正常"）在 research/software 两页达成。
- 后续：用户运行 `/gsd-verify-work` 复跑 UAT 测试 4 做最终视觉确认（gap 状态由其 reconcile 为 resolved）。
</success_criteria>

<output>
Create `.planning/phases/01-local-dev-environment/03-SUMMARY.md` when done
</output>
