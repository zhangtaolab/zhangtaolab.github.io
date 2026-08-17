---
phase: 1
plan: 02
wave: 1
depends_on: []
files_modified:
  - _pages/team.md
  - _pages/about.md
  - _pages/home.md
  - _pages/research.md
  - _pages/software.md
  - _data/team_members.yml
  - _data/alumni.yml
  - _data/news.yml
  - _data/people.yml
  - _includes/sidebar.html
autonomous: true
requirements:
  - ENV-01
  - ENV-02
gap_closure: true
gap_ids: [G-1-3, G-1-4]
---

# Phase 1 Gap Closure 计划：本地内容与参考站对齐（G-1-3 + G-1-4）

**用户故事：** 作为实验室维护者，我在本地 `bundle exec jekyll build` 后看到的站点内容（团队名单、新闻、首页/研究/软件/关于文案）必须与参考站 https://wmsd5fpo6kcfi.ok.kimi.link/ 一致，且 about/team 页面不得出现被转义成代码块的 HTML —— 参考站是内容权威基准（其自身模板缺陷除外）。

**关联缺口（来自 01-UAT.md，测试 3，severity: major）：**

- **G-1-3**：本地 `_site/about/index.html`（3 处）、`_site/team/index.html`（23 处）出现 `&lt;div` 转义进 Rouge `language-plaintext` 代码块；参考站 0 处。
- **G-1-4**：本地内容数据/页面与参考站为不同年代版本集（团队名单、新闻条目集、首页/研究/软件/关于文案均不一致）。

## 现状盘点（2026-08-17 磁盘实测事实，执行者以此为基准）

执行者不要凭假设；以下全部为本次规划时逐项实测：

1. **CSS 事实（对齐策略的根基）**：本地源文件 `assets/main.css`（161,960 字节）与参考站 `https://wmsd5fpo6kcfi.ok.kimi.link/assets/main.css` **逐字节同尺寸、类名集合一致**（`_site/assets/main.css` 为由 `assets/main.scss` 编译出的 160,119 字节产物，类名集合与之相同——本计划的"类名存在性"结论对两者同等成立）。该 CSS **包含**参考站页面所用的 `home-hero`、`home-hero-sub`、`banner-frame`、`banner-caption`、`callout-success`、`callout-title`、`callout-icon`、`team-grid`、`team-card`、`team-photo`、`team-name`、`team-info`、`pi-card`、`pi-photo`、`pi-name`、`pi-links`、`icon-link`、`research-grid`、`research-card`、`research-body`、`section-card`、`news-timeline`、`news-item`、`alumni-table`、`profile-card`、`pub-authors`、`btn-pill`、`chip-container`、`home-grid` 类；**不包含**（两个站点都不包含，属无样式装饰类，照用无害）：`page-title`、`section-heading`、`core-badge`、`img-wrap`、`pi-photo-placeholder`（后者在 about 页由 Task 2 以页内 `<style>` 补齐——参考站同款做法；team 页该占位分支因 PI 有照片不渲染）。而本地现有 `_pages` 使用的 `hero-section`、`hero-title`、`hero-subtitle`、`home-banner`、`home-intro`、`home-about`、`home-news`、`callout-primary`、`section-subtitle`、`software-card`（后者由 software.md 页内 `<style>` 自定义）在 CSS 中**不存在**。结论：把页面 DOM 改成参考站结构/类名即可获得与参考站一致的渲染，无需改任何 SCSS。
2. **G-1-3 根因实据**：`_config.yml` 设 `kramdown.parse_block_html: true`；`_pages/about.md` PI 卡片块（13–35 行）内部子 div 缩进 4 空格、`_pages/team.md` 成员循环体缩进 ≥4 空格，kramdown 将其解析为缩进代码块。仓库内两种已验证免疫模式：`_pages/home.md` hero 的 `markdown="0"` 包装；`_pages/research.md`/`software.md` 的**全列 0 平铺 HTML**（0 处转义）。本计划重写的页面一律采用"列 0 平铺 HTML + 必要处 `markdown="0"` 包装"。
3. **team 页实际缺陷比 UAT 摘要更多（全部在本计划 Task 1 一并修复）**：
   - 模板读 `member.position` 但 `_data/team_members.yml` 字段是 `info` → 渲染出 `<p class="text-muted"></p>` 空职位；
   - 模板前缀 `/images/team/` + 数据 `photo: team/liuguanqing.jpg` → 双重路径 `/images/team/team/liuguanqing.jpg`；`placeholder.jpg`/`avatar.jpg` 在 `images/team/` 中**不存在**（该目录仅有 baoyu.jpg、liuguanqing.jpg、yangqiqi.jpg）；
   - `_data/team_members.yml` 无名为 "Zhang Tao"/职位含 Professor 的条目 → PI 分支整个不渲染，页面无 "Team" 标题、无 PI 卡片；
   - `_data/alumni.yml` 为 Xin Xiaoyue/Ding Yu/Liu Shuo 旧名单，3 列表；参考站为 4 列表（Name/Period/Degree/Current Position）2 行：**Liu Guanqing 2017–2025 PhD —、Bao Yu 2018–2025 PhD —**（注意：UAT 摘要只提了 Liu Guanqing，快照 ref-team.html 实际有 Bao Yu 第二行 —— 以快照为准）。
4. **参考站 team 页结构**（ref-team.html）：h1 "Team" → p "**We are looking for new team members!**" → h2 "PI" + section-card/pi-card（logo.png 照片、"Dr. Zhang Tao"、"Professor, Bioinformatics, Epigenetics and Genomics"、envelope/scholar(fiqihP4AAAAJ)/github 图标、ul "Ph.D. University of Electronic Science and Technology of China"）→ h2 "Current Member" + team-grid（Dr. Wu Yuechao，Research Scientist, CIB CAS，渐变图标占位照片）→ h2 "Current Students" + team-grid（Chen Long "PhD Student, Yangzhou University (YZU)"、Dian Zhang "Master's Student, Chengdu Institute of Biology (CIB)"、Join Us! 卡片 fa-plus 渐变占位）→ h2 "Alumni" + section-card 4 列 alumni-table。
5. **数据消费者实测**（grep 全仓模板）：`team_members.yml`/`alumni.yml` 仅 `_pages/team.md` 消费；`people.yml` **零消费者**（孤儿数据，且与参考名单矛盾：把 Bao Yu 标为 M.S. Candidate 2024-，而参考站 Bao Yu 是 2018–2025 PhD 校友）；`grants.yml` 仅 `_pages/about.md` 消费（模板读 `grant.title/agency/period`，数据只有 `name` → 渲染成 `<hr/> |` 破损；数据内容本身已与参考站一致：NSFC + CIB CAS Start-up Fund）；`pi.yml` 被 about.md（错误索引 `site.data.pi.education`，pi 是列表 → "Education & Career" 渲染为空壳标题）与 sidebar.html（正确索引 `site.data.pi[0].educationshort`）消费；`news.yml` 被 news.md、allnews.md、home.md、feed.xml、sidebar.html 消费 —— **改 news.yml 自动传播到新闻页/allnews/首页侧栏/feed**。
6. **参考站 news 页共 6 条**（ref-news.html，按序）：Latest（DNALLM-Suite）、May 2026（T2T *Oryza australiensis*，Nat Commun）、May 2026（Glycosylase-mediated genome editing，Science Bulletin）、March 2026（tRNAs + AI-guided mining，Trends in Biotechnology）、December 2024（PDLLMs paper，Molecular Plant）、June 2023（Welcome Liu Guanqing & Wu Yuechao）。本地 news.yml 已有前 3 条（与 ref-index.html 首页侧栏 limit:3 完全一致），**只需追加后 3 条**，首页侧栏自动保持 3 条不变。
7. **home 页现有缺陷**（Task 4 一并修复）：`home-news` 块在 `markdown="0"` div 内含 `## News` → 构建产物出现**字面 "## News" 文本**（实测 `_site/index.html` grep 命中 1），且与 homelay 侧栏（sidebar.html 渲染 News）**重复**；sidebar.html 引用 `images/headshot.jpg` **不存在** → 首页个人卡片破图；sidebar 的 educationshort 列表参考站没有；首页 Chorus2 链接拼错（`{{ site.links.github }}/ Chorus2`，含空格）。
8. **参考站缺陷，禁止对齐**：标题 `{title}` 未渲染占位符（本地 head.html 渲染正确，实测各页 `<title>` 正常，仅 research.md/software.md 缺 `title:` frontmatter → 补上即得 "Research - Zhang Tao Lab"/"Software - Zhang Tao Lab"，与参考站浏览器标题一致且无占位符）；扁平 `./about.html` 链接（保留本地目录式 permalink 与站内链接）；CDN 字体（fonts.loli.net/zstatic.net/jsdmirror —— 本地 head.html 用 fonts.googleapis.com/cdnjs/jsdelivr，不动）。
9. **基线数据**（执行后对比用）：`grep -c "&lt;div"` 实测 about=3、team=23、其余页面=0；`grep -c "## News" _site/index.html`=1；下述验收 marker 当前在 `_site/` 中除注明外均为 0 命中（"Braz GT" 与 "S1674-2052(24)00390-3" 已在 publications 页出现，故验收一律**按指定文件路径** grep）。
10. **out of scope**：`_pages/publications.md`（83 条已一致，禁动）；`_sass/`（CSS 已与参考站一致，禁动）；contact 页；talks/teaching 已知空态（STATE.md 另行跟踪）；模板/视觉重设计。

## 内容基准

`.planning/phases/01-local-dev-environment/reference-snapshot/ref-{index,about,research,software,team,news,contact,publications}.html` 为内容权威基准。下文任务中的目标文案均已从快照逐字提取，执行者照抄即可；如与快照冲突，以快照为准。

## 任务

任务在单一 plan 内**严格顺序执行**（1 → 7，无并行波次；共享 `_site/` 与 git 索引，禁止并行构建/提交）。Task 1–6 为纯源文件编辑（各自的验收是源文件级断言），Task 7 统一重建 + 全量产物断言 + serve 抽检 + 提交收尾。每个 Task 完成后按 GSD 惯例原子提交（信息形如 `fix(content): <一句话>`）。

```xml
<tasks>

<task id="1" name="Team 页重写 + 花名册/校友数据对齐（G-1-3 team + G-1-4 名单）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-team.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/team.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/team_members.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/alumni.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/people.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/home.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_layouts/team.html
  </read_first>
  <action>
    1. 用以下内容**整体替换** `_data/team_members.yml`（schema 变更：`role` + `position`，删除 `info`/旧 `photo` 相对前缀；PI 照片用 `/images/logo.png`，当前成员/学生一律无 photo 字段 → 模板渲染渐变图标占位，与参考站一致，不虚构照片）：
       ```yaml
       # Team roster. role: pi | member | student
       - name: Dr. Zhang Tao
         role: pi
         position: Professor, Bioinformatics, Epigenetics and Genomics
         photo: /images/logo.png
         email: zhangtao@cib.ac.cn
         scholar: https://scholar.google.com/citations?user=fiqihP4AAAAJ&hl=en
         github: https://github.com/zhangtaolab
         education:
           - "Ph.D. University of Electronic Science and Technology of China"

       - name: Dr. Wu Yuechao
         role: member
         position: Research Scientist, Chengdu Institute of Biology, CAS

       - name: Chen Long
         role: student
         position: "PhD Student, Yangzhou University (YZU)"

       - name: Dian Zhang
         role: student
         position: "Master's Student, Chengdu Institute of Biology (CIB)"
       ```
    2. 用以下内容**整体替换** `_data/alumni.yml`（4 列 schema：name/period/degree/position；period 用 U+2013 en-dash，与 ref-team.html 逐字一致）：
       ```yaml
       - name: Liu Guanqing
         period: "2017–2025"
         degree: PhD
         position: "—"

       - name: Bao Yu
         period: "2018–2025"
         degree: PhD
         position: "—"
       ```
    3. **整体重写** `_pages/team.md`：镜像 ref-team.html 的 main 内容 DOM（列 0 平铺 HTML + Liquid 过滤循环；所有 HTML 行必须从行首列 0 开始，任何子元素缩进 ≥4 空格都会复发 G-1-3）。完整目标内容：
       ```markdown
       ---
       title: "Team"
       layout: team
       permalink: /team/
       ---

       <style>
       p, li, h1, h2, h3, h4 { max-width: none !important; }
       </style>

       <h1 class="page-title">Team</h1>

       <p><strong>We are looking for new team members!</strong></p>

       {% assign pi = site.data.team_members | where: "role", "pi" | first %}
       {% assign staff = site.data.team_members | where: "role", "member" %}
       {% assign students = site.data.team_members | where: "role", "student" %}

       <h2 class="section-heading">PI</h2>

       {% if pi %}
       <div class="section-card">
       <div class="pi-card">
       {% if pi.photo %}
       <img src="{{ site.url }}{{ site.baseurl }}{{ pi.photo }}" class="pi-photo" alt="{{ pi.name }}" loading="lazy"/>
       {% else %}
       <div class="pi-photo-placeholder"><i class="fa-solid fa-user"></i></div>
       {% endif %}
       <div>
       <h3 class="pi-name">{{ pi.name }}</h3>
       <p style="font-style: italic; color: var(--text-secondary);">{{ pi.position }}</p>
       <div class="pi-links">
       {% if pi.email %}<a class="icon-link" href="mailto:{{ pi.email }}" title="Email"><i class="fa-solid fa-envelope"></i></a>{% endif %}
       {% if pi.scholar %}<a class="icon-link" href="{{ pi.scholar }}" title="Google Scholar"><i class="ai ai-google-scholar"></i></a>{% endif %}
       {% if pi.github %}<a class="icon-link" href="{{ pi.github }}" title="GitHub"><i class="fa-brands fa-github"></i></a>{% endif %}
       </div>
       {% if pi.education %}
       <ul style="margin-top: var(--space-4);">
       {% for edu in pi.education %}
       <li>{{ edu }}</li>
       {% endfor %}
       </ul>
       {% endif %}
       </div>
       </div>
       </div>
       {% endif %}

       {% if staff.size > 0 %}
       <h2 class="section-heading">Current Member</h2>

       <div class="team-grid">
       {% for member in staff %}
       <div class="team-card">
       <div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #40916c 0%, #52b788 100%);">
       <i class="fa-solid fa-user" style="font-size: 2.5rem; color: white;"></i>
       </div>
       <h4 class="team-name">{{ member.name }}</h4>
       <p class="team-info">{{ member.position }}</p>
       </div>
       {% endfor %}
       </div>
       {% endif %}

       {% if students.size > 0 %}
       <h2 class="section-heading">Current Students</h2>

       <div class="team-grid">
       {% for member in students %}
       <div class="team-card">
       <div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #52b788 0%, #74c69d 100%);">
       <i class="fa-solid fa-user" style="font-size: 2.5rem; color: white;"></i>
       </div>
       <h4 class="team-name">{{ member.name }}</h4>
       <p class="team-info">{{ member.position }}</p>
       </div>
       {% endfor %}
       <div class="team-card">
       <div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #d8f3dc 0%, #b7e4c7 100%); color: #2d6a4f;">
       <i class="fa-solid fa-plus" style="font-size: 2.5rem;"></i>
       </div>
       <h4 class="team-name">Join Us!</h4>
       <p class="team-info">We are recruiting postdocs and students. <a href="{{ site.url }}{{ site.baseurl }}/contact/">Contact us!</a></p>
       </div>
       </div>
       {% endif %}

       {% if site.data.alumni %}
       <h2 class="section-heading">Alumni</h2>

       <div class="section-card">
       <table class="alumni-table">
       <thead>
       <tr><th>Name</th><th>Period</th><th>Degree</th><th>Current Position</th></tr>
       </thead>
       <tbody>
       {% for alum in site.data.alumni %}
       <tr>
       <td><strong>{{ alum.name }}</strong></td>
       <td>{{ alum.period }}</td>
       <td>{{ alum.degree }}</td>
       <td>{{ alum.position }}</td>
       </tr>
       {% endfor %}
       </tbody>
       </table>
       </div>
       {% endif %}
       ```
       说明：删除旧文件底部的大段 `<style>` 块（它样式化旧标记 team-member/student-card/fixed-size-img/join-us-card/section-subtitle，新标记全部由 main.css 的既有类覆盖，与参考站一致）；保留顶部 `p, li, h1…` style 块（参考站每页同款）。
    4. 删除孤儿数据 `_data/people.yml`：删除前先跑 `grep -rn "data.people" /Users/forrest/Playground/zhangtaolab-jekyll/_pages /Users/forrest/Playground/zhangtaolab-jekyll/_includes /Users/forrest/Playground/zhangtaolab-jekyll/_layouts /Users/forrest/Playground/zhangtaolab-jekyll/feed.xml /Users/forrest/Playground/zhangtaolab-jekyll/_config.yml`，确认零命中后 `rm _data/people.yml`（其内容与参考名单矛盾且无任何模板消费）。
    5. `images/team/` 下的 baoyu.jpg/liuguanqing.jpg/yangqiqi.jpg 保留在磁盘（校友表无照片列、当前成员参考站即占位图），不引用、不删除、不新增任何照片文件。
  </action>
  <acceptance_criteria>
    - `bundle exec ruby -e "require 'yaml'; YAML.load_file('_data/team_members.yml'); YAML.load_file('_data/alumni.yml'); puts :YAML_OK"` 输出 YAML_OK
    - `grep -c "^  role: pi" _data/team_members.yml` = 1（锚定条目行首两空格缩进，避开文件头注释 `# Team roster. role: pi | member | student` 中的同段子串）；`grep -c "role: member" _data/team_members.yml` = 1；`grep -c "role: student" _data/team_members.yml` = 2
    - `grep -c "Wu Yuechao\|Chen Long\|Dian Zhang" _data/team_members.yml` = 3；`grep -c "Bao Yu" _data/alumni.yml` ≥ 1；`grep -c "2017–2025" _data/alumni.yml` = 1
    - `test ! -f _data/people.yml` 通过，且上一步 grep 消费者检查零命中已先行执行
    - `_pages/team.md` 含 `page-title">Team`、`We are looking for new team members!`、`Current Member`、`Current Students`、`<th>Degree</th>`、`fa-solid fa-plus`；不再含 `team-member student-card`、`fixed-size-img`、`info }}`（旧字段引用）、`images/team/{%`（旧照片路径拼接）
    - `awk 'length($0) - length(gensub(/^ +/, "", 1, $0)) >= 4 && /</' _pages/team.md | wc -l` = 0（无任何 ≥4 空格缩进且含 HTML 的行；gensub 需 gawk，macOS 可用 `grep -En '^ {4,}.*<' _pages/team.md | wc -l` = 0 替代断言）
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && grep -En '^ {4,}.*<' _pages/team.md | wc -l && grep -c "role:" _data/team_members.yml && test ! -f _data/people.yml && echo TASK1_SRC_OK
  </verify>
</task>

<task id="2" name="About 页重写：PI 卡片修复转义 + 文案/资助对齐参考站（G-1-3 about + G-1-4 about）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-about.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/about.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/pi.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/grants.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_includes/sidebar.html
  </read_first>
  <action>
    1. **整体重写** `_pages/about.md` 为以下内容（镜像 ref-about.html main DOM；页内 `<style>` 除 max-width 覆盖外，还需逐字引入 ref-about.html head 中的 `.pi-photo-placeholder` 规则——该类在 main.css 中无定义、参考站即以页内样式渲染绿色渐变头像框，不加则本地 /about/ 渲染为无框裸图标；PI 卡片数据驱动自 `_data/pi.yml`（正确索引 `site.data.pi[0].education`）与 `_config.yml`（site.email/site.links/site.title/site.institution）；资助数据驱动自 `_data/grants.yml` 的 `name` 字段；全列 0 平铺 HTML + `markdown="0"` 包装，杜绝 G-1-3 复发）：
       ```markdown
       ---
       title: "About"
       layout: gridlay
       sitemap: false
       permalink: /about/
       ---

       <style>
       p, li, h1, h2, h3, h4 { max-width: none !important; }
       .pi-photo-placeholder { width: 160px; height: 200px; border-radius: var(--radius); display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #2d6a4f 0%, #40916c 100%); color: white; font-size: 3rem; flex-shrink: 0; }
       </style>

       <h1 class="page-title">About</h1>

       <div class="section-card" markdown="0">
       <div class="pi-card">
       <div class="pi-photo-placeholder"><i class="fa-solid fa-user"></i></div>
       <div>
       <h3 class="pi-name">Dr. Zhang Tao</h3>
       <p style="font-style: italic; color: var(--text-secondary);">Professor, {{ site.title }}<br/>{{ site.institution }}</p>
       <div class="pi-links">
       <a class="icon-link" href="mailto:{{ site.email }}" title="Email"><i class="fa-solid fa-envelope"></i></a>
       <a class="icon-link" href="{{ site.links.google_scholar }}" title="Google Scholar"><i class="ai ai-google-scholar"></i></a>
       <a class="icon-link" href="{{ site.links.github }}" title="GitHub"><i class="fa-brands fa-github"></i></a>
       </div>
       <ul style="margin-top: var(--space-4);">
       {% for edu in site.data.pi[0].education %}
       <li>{{ edu }}</li>
       {% endfor %}
       </ul>
       </div>
       </div>
       </div>

       <h2 class="section-heading">Research Interests</h2>

       <p>Our laboratory specializes in <strong>DNA Large Language Models</strong> and their applications in plant science. We are at the intersection of AI and biology, developing foundation models that learn the fundamental grammar of DNA to enable:</p>

       <ul>
       <li><strong>DNA Large Language Models</strong> — building and training foundation models for DNA sequence understanding</li>
       <li><strong>Regulatory element prediction</strong> — using LLMs to identify <em>cis</em>-regulatory elements with unprecedented accuracy</li>
       <li><strong>Genome engineering</strong> — applying AI to optimize CRISPR-based genome editing</li>
       <li><strong>Open-source tool development</strong> — making our models and tools freely available via <a href="https://github.com/zhangtaolab/PDLLMs" target="_blank">PDLLMs</a></li>
       </ul>

       <div class="callout callout-success" markdown="0">
       <div class="callout-title"><i class="fa-solid fa-brain callout-icon"></i> Featured Work: PDLLMs</div>
       <p>Our <strong>Plant DNA Large Language Models (PDLLMs)</strong> represent a new paradigm for plant genome analysis. Published in <em>Molecular Plant</em> 2025, PDLLMs provide a suite of tailored foundation models for analyzing plant genomes, predicting regulatory elements, and accelerating crop improvement. <a href="https://github.com/zhangtaolab/PDLLMs" target="_blank"><i class="fa-brands fa-github"></i> Get PDLLMs on GitHub</a></p>
       </div>

       <h2 class="section-heading">Grants &amp; Funding</h2>

       <div class="section-card" markdown="0">
       <ul>
       {% for grant in site.data.grants %}
       <li>{{ grant.name }}</li>
       {% endfor %}
       </ul>
       </div>
       ```
    2. 删除项（旧文件内容随整体重写消失）：破损的旧 PI 卡片块（G-1-3 的 3 处转义来源）、空壳 "Education & Career" 小节（错误索引 `site.data.pi.education`，参考站无此小节——学历在 PI 卡片 ul 内）、旧版 5 小节式 Research Interests 文案、旧 Featured Work 文案、读错字段的 grant-item 循环。
    3. `_data/grants.yml` 与 `_data/pi.yml` **不动**（数据内容已与参考站一致：NSFC + CIB CAS Start-up Fund；Ph.D. UESTC）。
  </action>
  <acceptance_criteria>
    - `grep -c "page-title\">About" _pages/about.md` = 1
    - `grep -c "We are at the intersection of AI and biology" _pages/about.md` = 1；`grep -c "unprecedented accuracy" _pages/about.md` = 1
    - `grep -c "Featured Work: PDLLMs" _pages/about.md` = 1；`grep -c "Get PDLLMs on GitHub" _pages/about.md` = 1
    - `grep -c "pi-photo-placeholder" _pages/about.md` = 2（占位 div + 页内样式规则各 1）；`grep -c "linear-gradient(135deg, #2d6a4f 0%, #40916c 100%)" _pages/about.md` = 1
    - `grep -c "site.data.pi\[0\].education" _pages/about.md` = 1；`grep -c "grant.name" _pages/about.md` = 1
    - `grep -c "Education" _pages/about.md` = 0（空壳小节已删；PI 卡片 ul 由 education 数据渲染）
    - `grep -En '^ {4,}.*<' _pages/about.md | wc -l` = 0
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && grep -En '^ {4,}.*<' _pages/about.md | wc -l && grep -c "site.data.pi\[0\].education" _pages/about.md && echo TASK2_SRC_OK
  </verify>
</task>

<task id="3" name="新闻条目集补齐至参考站 6 条（G-1-4 news）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-news.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-index.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_data/news.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/news.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/allnews.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_includes/sidebar.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/feed.xml
  </read_first>
  <action>
    1. 编辑 `_data/news.yml`：**保留现有前 3 条不动**（Latest / May 2026 T2T / May 2026 Glycosylase，与 ref-index.html 首页侧栏 limit:3 一致），在文件末尾**追加以下 3 条**（逐字取自 ref-news.html，保持既有 yml schema：`date` + 单引号 HTML `headline`）：
       ```yaml
       - date: "March 2026"
         headline: '<a href="https://doi.org/10.1016/j.tibtech.2026.02.016" target="_blank">Harnessing diverse tRNAs and AI-guided mining</a> for compact and efficient plant multiplex genome editing, published in <em>Trends in Biotechnology</em>.'

       - date: "December 2024"
         headline: '<a href="https://www.cell.com/molecular-plant/fulltext/S1674-2052(24)00390-3" target="_blank">PDLLMs paper</a> — Plant DNA Large Language Models published in <em>Molecular Plant</em>!'

       - date: "June 2023"
         headline: 'Welcome to new PhD students Liu Guanqing and Wu Yuechao!'
       ```
    2. 不改任何模板：news.md、allnews.md、home.md、sidebar.html、feed.xml 全部按条目循环渲染，数据补齐自动传播（首页侧栏与 feed 各自 limit:3 / limit:20，首页新闻预览自动保持参考站的 3 条不变）。feed.xml 已有 "Latest" → `site.time` 的展示日期回退，"March 2026" 等字符串可被 `date_to_rfc822` 解析（现有 "May 2026" 同理），无需改动。
  </action>
  <acceptance_criteria>
    - `bundle exec ruby -e "require 'yaml'; n=YAML.load_file('_data/news.yml'); puts n.length"` 输出 6
    - `grep -c 'date: "' _data/news.yml` = 6；`grep -c "tibtech.2026.02.016" _data/news.yml` = 1；`grep -c "fulltext/S1674-2052(24)00390-3" _data/news.yml` = 1；`grep -c "Liu Guanqing and Wu Yuechao" _data/news.yml` = 1
    - `grep -c "Trends in Biotechnology" _data/news.yml` = 1
    - 现有前 3 条未被改动：`grep -c "s41467-026-73769-8" _data/news.yml` = 1 且 `grep -c "DNALLM-Suite" _data/news.yml` = 1
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec ruby -e "require 'yaml'; puts YAML.load_file('_data/news.yml').length" && grep -c 'date: "' _data/news.yml
  </verify>
</task>

<task id="4" name="首页 hero/特色区/About the Lab 对齐 + 修复字面 ## News、破图、Chorus2 链接（G-1-4 home）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-index.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/home.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_includes/sidebar.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_layouts/homelay.html
  </read_first>
  <action>
    1. **整体重写** `_pages/home.md` 为以下内容（镜像 ref-index.html 左列 DOM；类名换成 CSS 中真实存在的 `home-hero`/`home-hero-sub`/`banner-frame`/`banner-caption`/`callout-success`；删除旧 hero-section/home-intro/home-banner/home-about/home-news 包装；**home-news 块整个删除**——侧栏 sidebar.html 已渲染 News，旧块是重复且产生字面 `## News` 文本）：
       ```markdown
       ---
       title: "Home"
       layout: homelay
       sitemap: false
       permalink: /
       ---

       <style>
       p, li, h1, h2, h3, h4 { max-width: none !important; }
       </style>

       <h2 class="home-hero">{{ site.name }}</h2>
       <p class="home-hero-sub">{{ site.title }}, {{ site.institution }}</p>

       <div class="chip-container" markdown="0">
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/software/" style="background: var(--accent); color: white; border-color: var(--accent);">DNA Large Language Models</a>
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">Plant Genomics</a>
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/"><em>Cis</em>-regulatory Elements</a>
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">Oligo-FISH Probes</a>
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">CRISPR Genome Editing</a>
       <a class="chip" href="{{ site.url }}{{ site.baseurl }}/software/">Bioinformatics Tools</a>
       </div>

       <p><strong>We specialize in developing and applying DNA Large Language Models (LLMs) for plant genome analysis.</strong> Our lab is at the forefront of applying foundation models to decode complex DNA sequences, predict regulatory elements, and accelerate crop improvement. We build and maintain <a href="https://github.com/zhangtaolab/PDLLMs">PDLLMs</a>, a suite of open-source plant DNA language models for the research community. Our work spans from fundamental algorithm development to real-world applications in genomics, epigenetics, and genome engineering.</p>

       <div class="callout callout-success" markdown="0">
       <div class="callout-title"><i class="fa-solid fa-brain callout-icon"></i> Featured: DNA Large Language Models</div>
       <p><strong><a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs</a></strong> — Plant DNA Large Language Models published in <em>Molecular Plant</em>. Foundation models for analyzing plant genomes.</p>
       <p style="margin-top: var(--space-2);"><strong><a href="https://github.com/zhangtaolab/DNALLM" target="_blank">DNALLM-Suite</a></strong> — A unified toolkit for fine-tuning and inference with DNA Language Models. CLI, UI, and MCP support. <a href="https://zhangtaolab.org/DNALLM/" target="_blank"><i class="fa-solid fa-globe"></i> Website</a></p>
       </div>

       <div class="banner-frame" markdown="0">
       <img src="{{ site.url }}{{ site.baseurl }}/images/banner.jpg" alt="Plant genome research" loading="lazy"/>
       <div class="banner-caption">Overview of our research in plant genomics, epigenetics, and genome engineering at Zhang Tao Lab, Chengdu Institute of Biology, Chinese Academy of Sciences</div>
       </div>

       <h3>About the Lab</h3>
       <p>Our laboratory specializes in <strong>DNA Large Language Models</strong> and their applications in plant science. We develop and apply foundation models to understand, predict, and engineer plant genomes. Our work bridges the gap between cutting-edge AI and fundamental biology, spanning computational genomics, epigenetics, and genome editing. We are committed to building open-source tools that accelerate scientific discovery in the era of AI-driven biology.</p>
       ```
       注意：`{{ site.title }}, {{ site.institution }}` 渲染结果与 ref-index 的 hero-sub 逐字一致（"Bioinformatics, Epigenetics and Genomics, Chengdu Institute of Biology, Chinese Academy of Sciences"）。
    2. 编辑 `_includes/sidebar.html`：删除破图块（`<a href=".../about"><img src=".../images/{{ site.photo }}" class="profile-photo" ...></a>` 三行——`images/headshot.jpg` 不存在，参考站 profile-card 无照片）与 educationshort 列表块（`{% if site.data.pi[0].educationshort %}…{% endif %}` 整段——参考站 profile-card 无学历列表）。其余（profile 文本、图标链接、News 卡片、See all news 链接）**保持不动**；Google Scholar 图标继续用 `site.links.google_scholar`（真实 ID fiqihP4AAAAJ；ref-index 侧栏的 `user=zhangtao` 是参考站占位缺陷，不引入）。
  </action>
  <acceptance_criteria>
    - `grep -c "home-hero" _pages/home.md` ≥ 2；`grep -c "Featured: DNA Large Language Models" _pages/home.md` = 1
    - `grep -c "CLI, UI, and MCP support" _pages/home.md` = 1；`grep -c "Overview of our research" _pages/home.md` = 1
    - `grep -c "We are the " _pages/home.md` = 0（旧 intro 已删）
    - `grep -c "## News" _pages/home.md` = 0（重复且字面渲染的 News 块已删）
    - `grep -c "home-news\|home-intro\|home-banner\|hero-section\|home-about\|callout-primary" _pages/home.md` = 0（CSS 中不存在的旧类已清除）
    - `grep -c "headshot.jpg" _includes/sidebar.html` = 0；`grep -c "educationshort" _includes/sidebar.html` = 0
    - `_includes/sidebar.html` 仍含 `site.data.news limit:3` 与 `profile-institution`
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && grep -c "## News" _pages/home.md; grep -c "headshot.jpg" _includes/sidebar.html; grep -c "Featured: DNA Large Language Models" _pages/home.md
  </verify>
</task>

<task id="5" name="Research 页文案对齐 + 标题/引言补齐（G-1-4 research）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-research.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/research.md
  </read_first>
  <action>
    编辑 `_pages/research.md`（保留文件结构、本地图片路径、img-wrap/img 的内联尺寸样式与 Core Focus 徽章内联样式——这些是已通过视觉验证的本地增强，非内容差异；只改内容文本与缺失区块）：
    1. frontmatter 增加 `title: "Research"`（浏览器标题变为 "Research - Zhang Tao Lab"，与参考站一致且无 {title} 占位符缺陷）。
    2. 将 `## Research Areas` 替换为参考站的 h1 + 引言：
       `<h1 class="page-title">Research</h1>`
       `<p>Our laboratory is at the forefront of <strong>DNA Large Language Models (LLMs)</strong> and their applications in plant genomics. We develop foundation models for DNA sequence understanding and apply them to diverse biological questions, from regulatory element prediction to genome engineering. Below are our key research areas:</p>`
    3. 将 8 张卡片的正文 `<p>` 文本逐字替换为 ref-research.html 对应文本（保留各卡片原有的内联样式、链接 href、`<em>` 等标记）：
       - **DNA Large Language Models**（Core Focus 卡）："We develop and apply large language models for DNA sequence analysis. This includes <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs (Plant DNA LLMs)</a> — a suite of foundation models tailored for plant genomes published in <em>Molecular Plant</em> — and <a href="https://github.com/zhangtaolab/DNALLM" target="_blank">DNALLM-Suite</a>, a comprehensive toolkit for fine-tuning and inference with DNA Language Models featuring CLI, Web UI, and MCP protocol support."
       - **AI-Driven Genomics**："We apply machine learning and deep learning to solve fundamental questions in genomics. This includes developing predictive models for gene regulation, chromatin accessibility, and genome evolution. Our work bridges the gap between cutting-edge AI methods and biological discovery."
       - **<em>Cis</em>-regulatory Elements**："<em>Cis</em>-regulatory elements (CRMs) control gene expression during specific developmental stages or under various biotic and abiotic stresses. We identify and characterize these elements based on their unique molecular signatures associated with open chromatin, leveraging LLM-based approaches for improved prediction accuracy."
       - **Oligo-FISH Probe Design**："Oligo probes designed from conserved DNA sequences can be used among genetically related species, enabling comparative cytogenetic mapping. We develop computational pipelines for genome-scale oligonucleotide-based probe design for fluorescence in situ hybridization (FISH), significantly expanding the applications of FISH in non-model plant species."
       - **CRISPR/Cas Genome Editing**："We develop and optimize CRISPR/Cas-based genome editing systems for plants, including base editors, prime editors, and multiplex editing strategies. Our work includes gRNA design algorithms, efficiency prediction models, and the development of <a href="https://github.com/zhangtaolab/CrisprStitch" target="_blank">CrisprStitch</a> for the research community."
       - **Plant Genomics & Comparative Genomics**："We study the structure, function, and evolution of plant genomes using large-scale sequencing and comparative approaches. Our recent work includes telomere-to-telomere genome assemblies and the application of large language models for DNA sequence analysis in plants."
       - **Epigenetics & Chromatin Biology**："We investigate the epigenetic regulation of gene expression in plants, focusing on DNA methylation, histone modifications, and chromatin accessibility. Our research explores how epigenetic changes contribute to plant development and stress responses."
       - **Bioinformatics Tool Development**："We develop and maintain open-source bioinformatics software for the plant science community, including tools for probe design (Chorus2), CRISPR analysis (CrisprStitch), and plant DNA language models (PDLLMs, DNALLM-Suite). All tools are freely available."
    4. 第 8 张卡片的 img-wrap：将 `<i class="fa-solid fa-code" ...>` 图标占位替换为与参考站一致的图片（资产已存在）：`<img src="{{ site.url }}{{ site.baseurl }}/images/research/bioinformatics-tools.jpg" alt="Bioinformatics Tool Development" style="width: 100%; height: 100%; object-fit: cover;" loading="lazy">`（沿用其他卡片的 img 内联样式）。
    5. 8 张卡片的 h4 标题、卡片顺序、图片文件名均与现状一致（与参考站一致），不动。
  </action>
  <acceptance_criteria>
    - `grep -c 'title: "Research"' _pages/research.md` = 1；`grep -c "page-title\">Research" _pages/research.md` = 1
    - `grep -c "Below are our key research areas" _pages/research.md` = 1
    - `grep -c "MCP protocol support" _pages/research.md` = 1；`grep -c "leveraging LLM-based approaches" _pages/research.md` = 1；`grep -c "telomere-to-telomere genome assemblies" _pages/research.md` = 1；`grep -c "for the research community" _pages/research.md` = 1
    - `grep -c "fa-solid fa-code" _pages/research.md` = 0（第 8 卡已换真实图片）
    - `grep -c "bioinformatics-tools.jpg" _pages/research.md` = 1
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && grep -c "Below are our key research areas" _pages/research.md && grep -c "MCP protocol support" _pages/research.md
  </verify>
</task>

<task id="6" name="Software 页描述/引文对齐 + 标题对齐（G-1-4 software）" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-software.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/software.md
  </read_first>
  <action>
    编辑 `_pages/software.md`（保留页内 `<style>` 块、software-grid 包装、全部 GitHub/Paper 按钮链接、缩略图结构与底部 Open Source callout——这些与参考站一致；只改标题层级、卡片标题、描述文本与引文格式）：
    1. frontmatter 增加 `title: "Software"`。
    2. `## Software & Tools` 替换为 `<h1 class="page-title">Software</h1>`（引言段落文本已与参考站逐字一致，不动）。
    3. 四个分区标题 `### <i class="fa-solid fa-brain"></i> DNA Large Language Models` 等替换为参考站的 h2 形式（图标加 accent 色）：
       `<h2 class="section-heading"><i class="fa-solid fa-brain" style="color: var(--accent);"></i> DNA Large Language Models</h2>`
       `<h2 class="section-heading"><i class="fa-solid fa-scissors" style="color: var(--accent);"></i> Genome Editing</h2>`
       `<h2 class="section-heading"><i class="fa-solid fa-dna" style="color: var(--accent);"></i> Oligo-FISH &amp; Genomics</h2>`
       `<h2 class="section-heading"><i class="fa-solid fa-robot" style="color: var(--accent);"></i> AI Infrastructure</h2>`
    4. 卡片内容逐字对齐 ref-software.html（按钮统一放在 h4 之下、描述之前；引文统一为 `<p class="pub-authors" style="font-size: 0.9rem;"><strong>Citation:</strong> …</p>` 完整格式）：
       - **DNALLM-Suite**（Core Toolkit 卡）：描述改为 "A unified toolkit for fine-tuning and inference with DNA Language Models. Provides CLI, Web UI, and MCP (Model Context Protocol) support for seamless LLM integration. Features include fine-tuning pipelines, in-silico mutagenesis analysis, and support for multiple model architectures."
       - **PDLLMs**：h4 改为 `PDLLMs — Plant DNA Large Language Models`；描述改为 "A group of tailored DNA large language models for analyzing plant genomes. Published in <em>Molecular Plant</em> 2025."；引文改为 `<strong>Citation:</strong> Liu GQ, Chen L, Wu YC, Han YS, Bao Y, Zhang T. PDLLMs: A group of tailored DNA large language models for analyzing plant genomes. <em>Mol Plant</em>. 2025;18(2):175-178.`
       - **dnallmmark**：描述改为 "Benchmarking framework for DNA Large Language Models. Standardized evaluation metrics and datasets for comparing DNA LLM architectures."
       - **MambaForSequenceClassification**：描述改为 "HuggingFace integration for Mamba state-space models applied to DNA sequence classification. Enables efficient training for genomic sequences."
       - **CrisprStitch**：描述改为 "A fast, user-friendly tool to evaluate the efficiency of CRISPR-Cas editing systems. Available as a web application and desktop app. Performs all calculations locally on the user's computer without uploading data to remote servers."；引文改为 `<strong>Citation:</strong> Han YS, Liu GQ, Wu YC, Bao Y, Zhang Y, Zhang T. CrisprStitch: Fast evaluation of the efficiency of CRISPR editing systems. <em>Plant Commun</em>. 2024;5(3):100783.`
       - **Chorus2**：描述改为 "A software pipeline to select genome-scale oligonucleotide-based probes for fluorescence in situ hybridization (Oligo-FISH). Highly effective at removing repetitive elements and selecting single-copy oligos. Supports probe design for species with or without assembled genomes."；引文改为 `<strong>Citation:</strong> Zhang T, Liu G, Zhao H, Braz GT, Jiang J. Chorus2: design of genome-scale oligonucleotide-based probes for fluorescence in situ hybridization. <em>Plant Biotechnol J</em>. 2021;19(10):1967-1978.`
       - **rustkmer**：描述改为 "High-performance k-mer counting and analysis tool written in Rust for efficient processing of large genomic datasets."
       - **SIF**：h4 改为 `SIF — Semantic Intelligence Framework`；描述改为 "<strong>S</strong>emantic <strong>I</strong>ntelligence <strong>F</strong>ramework — a document semantic intelligence retrieval system. SIF provides collection management, hybrid search (BM25 + vector embeddings), and MCP server integration for AI-assisted document retrieval. Supports multiple embedding models including Sentence Transformers, GGUF, OpenAI-compatible APIs, and ModelScope Hub."
    5. 所有 GitHub/Paper 链接 href 保持本地现状（github.com/zhangtaolab/*、pubmed 39733335/38146164/33960617 —— 与参考站一致）；缩略图 dnallm-suite.png 与 "Screenshot" 占位保持现状。
  </action>
  <acceptance_criteria>
    - `grep -c 'title: "Software"' _pages/software.md` = 1；`grep -c "page-title\">Software" _pages/software.md` = 1；`grep -c "Software & Tools" _pages/software.md` = 0
    - `grep -c "section-heading" _pages/software.md` = 4
    - `grep -c "in-silico mutagenesis" _pages/software.md` = 1；`grep -c "Performs all calculations locally" _pages/software.md` = 1
    - `grep -c "Braz GT, Jiang J" _pages/software.md` = 1；`grep -c "Liu GQ, Chen L, Wu YC" _pages/software.md` = 1；`grep -c "ModelScope Hub" _pages/software.md` = 1
    - `grep -c "et al." _pages/software.md` = 0（缩写引文已升级为完整引文）
    - `grep -c "pubmed.ncbi.nlm.nih.gov/39733335/\|pubmed.ncbi.nlm.nih.gov/38146164/\|pubmed.ncbi.nlm.nih.gov/33960617/" _pages/software.md` = 3（三个 Paper 链接保持）
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && grep -c "in-silico mutagenesis" _pages/software.md && grep -c "et al." _pages/software.md
  </verify>
</task>

<task id="7" name="全量重建 + 产物断言 + 回环 serve 抽检 + 提交收尾（G-1-3/G-1-4 终验）" type="verification">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-team.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/phases/01-local-dev-environment/reference-snapshot/ref-about.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/STATE.md
  </read_first>
  <action>
    1. 在仓库根执行 `bundle exec jekyll build`（退出码必须 0，无 Unknown tag、无 Liquid 报错）。
    2. 执行下方 acceptance_criteria 中的全部产物断言（G-1-3 清零断言 + G-1-4 内容 marker 断言 + 反向断言）。
    3. 回环 serve 抽检：后台启动 `bundle exec jekyll serve`（默认绑定 127.0.0.1:4000，**禁止 --host 0.0.0.0**），curl 断言后停止进程（不留后台服务）。
    4. 全部通过后：`git add -A && git commit`（单条原子提交，信息形如 `fix(content): align site content with reference snapshot (G-1-3, G-1-4)`）；确认 `git status --porcelain` 为空、`_site/` 未被跟踪。
    5. 在 `.planning/STATE.md` 的「Accumulated Context / 待确认项」追加一行记录：本地内容已与 reference-snapshot 对齐（团队/新闻/首页/研究/软件/关于），publications 83 条未动；不改其它段落。
  </action>
  <acceptance_criteria>
    - `bundle exec jekyll build` 退出码 0
    - 【G-1-3 清零】`grep -c "&lt;div" _site/about/index.html` = 0 且 `grep -c "&lt;div" _site/team/index.html` = 0；且对 `_site/` 下全部 `*.html` 执行同一 grep，无任何文件命中（基线：about=3、team=23，其余 0）
    - `grep -c "language-plaintext" _site/team/index.html` = 0 且 `grep -c "language-plaintext" _site/about/index.html` = 0
    - 【home】`grep -c "## News" _site/index.html` = 0；`grep -c "headshot.jpg" _site/index.html` = 0；`grep -c "Featured: DNA Large Language Models" _site/index.html` = 1；`grep -c "CLI, UI, and MCP support" _site/index.html` = 1；`grep -c "Overview of our research" _site/index.html` = 1；`grep -c "We are the " _site/index.html` = 0
    - 【team】`grep -c "Dr. Wu Yuechao" _site/team/index.html` ≥ 1；`grep -c "Yangzhou University (YZU)" _site/team/index.html` = 1；`grep -c "Chengdu Institute of Biology (CIB)" _site/team/index.html` = 1；`grep -c "Liu Guanqing" _site/team/index.html` ≥ 1；`grep -c "Bao Yu" _site/team/index.html` ≥ 1；`grep -c "Ph.D. University of Electronic Science and Technology of China" _site/team/index.html` = 1；反向：`grep -c "Xin Xiaoyue\|Ding Yu\|Liu Shuo" _site/team/index.html` = 0；`grep -c "images/team/team/" _site/team/index.html` = 0；`grep -c "avatar.jpg\|placeholder.jpg" _site/team/index.html` = 0
    - 【about】`grep -c "We are at the intersection of AI and biology" _site/about/index.html` = 1；`grep -c "unprecedented accuracy" _site/about/index.html` = 1；`grep -c "Get PDLLMs on GitHub" _site/about/index.html` = 1；`grep -c "Start-up Fund" _site/about/index.html` = 1；`grep -c "pi-photo-placeholder" _site/about/index.html` = 2（样式规则 + 占位 div）；`grep -c "Education" _site/about/index.html` = 0
    - 【news】`grep -c 'class="news-item"' _site/news/index.html` = 6；`grep -c 'class="news-item"' _site/allnews.html` = 6；`grep -c "tibtech.2026.02.016" _site/news/index.html` = 1；`grep -c "fulltext/S1674-2052(24)00390-3" _site/news/index.html` = 1；`grep -c "Liu Guanqing and Wu Yuechao" _site/news/index.html` = 1；首页侧栏仍 3 条：`grep -c 'class="news-item"' _site/index.html` = 3
    - 【research】`grep -c "Below are our key research areas" _site/research/index.html` = 1；`grep -c "leveraging LLM-based approaches" _site/research/index.html` = 1；`grep -c "telomere-to-telomere genome assemblies" _site/research/index.html` = 1；`grep -o "<title>[^<]*</title>" _site/research/index.html` 输出 `<title>Research - Zhang Tao Lab</title>`
    - 【software】`grep -c "in-silico mutagenesis" _site/software/index.html` = 1；`grep -c "Performs all calculations locally" _site/software/index.html` = 1；`grep -c "Braz GT, Jiang J" _site/software/index.html` = 1；`grep -o "<title>[^<]*</title>" _site/software/index.html` 输出 `<title>Software - Zhang Tao Lab</title>`
    - 【不引入参考站缺陷】`grep -c "{title}" _site/index.html _site/about/index.html` 均 = 0；`grep -c "fonts.loli.net\|zstatic.net\|jsdmirror" _site/index.html _site/about/index.html` 均 = 0；`grep -c 'href="./' _site/index.html` = 0（无扁平 .html 链接）
    - 【publications 未动】`git diff --stat 7cac7e4 -- _pages/publications.md` 为空（7cac7e4 为本 plan 执行前 HEAD，覆盖 Task 1–6 及 7 的全部提交，而非仅最后一次提交）
    - 【serve 抽检】127.0.0.1:4000 上 `/`、`/about/`、`/team/`、`/news/`、`/research/`、`/software/` 全部返回 200，且 `/team/` 响应含 `Dr. Wu Yuechao`、`/about/` 响应含 `Start-up Fund`；抽检后 serve 进程已停止（再 curl 连接被拒绝）
    - `git status --porcelain | wc -l` = 0；`git check-ignore _site` 退出码 0
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle exec jekyll build && grep -c "&lt;div" _site/about/index.html _site/team/index.html && grep -c 'class="news-item"' _site/news/index.html _site/index.html && echo GAP_BUILD_OK
  </verify>
</task>

</tasks>
```

## must_haves

```yaml
must_haves:
  truths:
    - "`bundle exec jekyll build` 退出码 0"
    - "G-1-3 清零：`grep -c '&lt;div' _site/about/index.html _site/team/index.html` 均为 0，且全站无 Rouge language-plaintext 转义块残留于 about/team"
    - "G-1-4 团队：/team/ 渲染 PI（Dr. Zhang Tao, Professor…, Ph.D. UESTC）+ Current Member（Dr. Wu Yuechao, Research Scientist, CIB CAS）+ Current Students（Chen Long, PhD Student, Yangzhou University (YZU)；Dian Zhang, Master's Student, Chengdu Institute of Biology (CIB)）+ Join Us + 4 列校友表（Liu Guanqing 2017–2025 PhD；Bao Yu 2018–2025 PhD），无旧名单（Ruimin/Xin Xiaoyue/Ding Yu/Liu Shuo）残留"
    - "G-1-4 新闻：news.yml 共 6 条且顺序与 ref-news.html 一致；/news/ 与 /allnews.html 各渲染 6 条；首页侧栏保持 3 条（Latest + 2×May 2026）；feed.xml 可构建"
    - "G-1-4 首页：hero/引言/Featured: DNA Large Language Models/DNALLM-Suite（CLI, UI, and MCP support）/banner 说明/About the Lab 文案与 ref-index.html 逐字一致；无字面 ## News、无 headshot.jpg 破图、无重复 News 块"
    - "G-1-4 关于：PI 卡片 + 4 条 Research Interests 要点 + Featured Work: PDLLMs callout + Grants（NSFC + CIB CAS Start-up Fund）与 ref-about.html 一致；空壳 Education & Career 小节与破损 grant-item 渲染已消除"
    - "G-1-4 研究/软件：8 张研究卡与 8 张软件卡的描述/引文/标题与参考快照一致（含 MCP protocol support、telomere-to-telomere genome assemblies、in-silico mutagenesis、Performs all calculations locally、三条完整 Citation）；research/software 页浏览器标题为 Research/Software - Zhang Tao Lab"
    - "参考站缺陷零引入：无 {title} 占位符、无 ./xxx.html 扁平链接、无 fonts.loli.net/zstatic.net/jsdmirror CDN 引用；本地目录式 permalink 与自有资产管线保持"
    - "_pages/publications.md 的 83 条手写列表零改动（git diff 为空）"
    - "回环 serve（127.0.0.1:4000）抽检 6 个页面 200 且含 marker；验证后进程停止"
  prohibitions:
    - "不得以 sudo 或全局 gem install 绕过 Bundler 修复环境：一切依赖必须经 Gemfile/Gemfile.lock 表达"
    - "不得通过掩盖错误换取绿色构建：不得引入 liquid error_mode: lax/warn、不得删除或清空报错页面（如 talks.md）、不得静默卸载插件"
    - "不得移除 jekyll-scholar 或 jekyll-sitemap 插件来让构建通过"
    - "不得让模板演示数据（assets/ref.bib 的 Feynman 条目）留在文献渲染链中被当作正常功能"
    - "本阶段不得把 publications.md 手写 83 条列表替换或裁剪为 jekyll-scholar 生成列表（papers/ref.bib 仅 12 条，替换会静默丢失 71 条内容）"
    - "本地 serve 不得绑定 127.0.0.1 以外地址（禁止 --host 0.0.0.0 暴露局域网）"
    - "不得对齐参考站自身缺陷：{title} 未渲染占位符、扁平 .html URL 方案、外部 CDN 字体/图标（fonts.loli.net、zstatic.net、jsdmirror）——本地保持正确 title 渲染、目录式 permalink、现有自托管/官方 CDN 资产"
    - "不得改动 `_sass/`、`assets/css/`、`assets/main.scss`（本地 CSS 与参考站逐字节同尺寸且类集合一致，样式层无差距）"
    - "不得虚构成员照片：当前成员一律使用参考站的渐变图标占位；不得新建图片文件，不得引用不存在的 headshot.jpg/avatar.jpg/placeholder.jpg"
    - "不得改动 `_pages/publications.md`、`papers/ref.bib`、contact/talks/teaching/blogs 页（超出本缺口范围）"
    - "不得并行执行任务或并行构建（共享 _site/ 与 git 索引，严格按 1→7 顺序）"
```

## Flagged assumptions

| 假设 | 依据 | 证伪后果 |
|---|---|---|
| 参考快照即内容基准，其中 ref-team 的第二行校友 Bao Yu（UAT 摘要未提）也需入库 | ref-team.html 实测含 Bao Yu 2018–2025 PhD 行；快照是规划上下文指定的权威源 | 若用户否认 Bao Yu 行，从 alumni.yml 删除该条并重跑 Task 7 断言（`grep -c "Bao Yu" _site/team/index.html` 改期望 ≥0） |
| ref-index 侧栏 Google Scholar `user=zhangtao` 属参考站占位缺陷 | 合法 Scholar ID 形如 fiqihP4AAAAJ（参考站 team/about 页与本地 _config.yml 均用真实 ID）；gap 指令明确禁止引入参考站缺陷 | 无需行动；保留 site.links.google_scholar |
| 现有本地 research/software 卡片的内联尺寸样式（img-wrap 高度、object-fit）与 Core Focus 徽章内联样式保留 | 二页构建产物 0 转义且 Phase 1 UAT 视觉通过；属呈现增强而非内容年代差异 | 用户若要求像素级 DOM 一致，再去掉内联样式（单独小任务） |
| `Liquid where` 过滤 + `.size` 在当前 Jekyll 4.4.1/Liquid 版本可用 | Liquid 标准过滤器；仓库 feed.xml 已用 assign/date 组合无碍 | 改用 for+if 内联过滤，重跑 Task 7 |
| "March 2026"/"December 2024"/"June 2023" 字符串可被 `date_to_rfc822` 解析 | 现有 "May 2026" 同格式条目已通过 Phase 1 构建与 feed 渲染 | feed.xml 对不可解析日期回退 site.time（Latest 已有同款回退），不阻塞 |

## Artifacts this phase produces

- **重写**：`_pages/team.md`、`_pages/about.md`、`_pages/home.md`（参考站 DOM + 数据驱动）
- **文本对齐**：`_pages/research.md`、`_pages/software.md`（标题层级/卡片文案/完整引文）
- **数据**：`_data/team_members.yml`（新 schema：name/role/position/photo/education/links）、`_data/alumni.yml`（新 schema：name/period/degree/position）、`_data/news.yml`（6 条）；**删除** `_data/people.yml`（孤儿且矛盾）
- **include**：`_includes/sidebar.html`（移除破图 headshot.jpg 与 educationshort 列表）
- **不动**：`_data/pi.yml`、`_data/grants.yml`、`_sass/`、`_pages/publications.md`、`papers/ref.bib`、`_config.yml`、feed.xml、其余页面
- **无**新布局、新插件、新脚本、新图片文件

## Verification criteria（阶段验证脚本骨架）

```bash
cd /Users/forrest/Playground/zhangtaolab-jekyll
bundle exec jekyll build                                              # 退出码 0
# G-1-3 清零
grep -c "&lt;div" _site/about/index.html _site/team/index.html        # 均为 0
grep -c "language-plaintext" _site/team/index.html                    # 0
# G-1-4 关键 marker（按文件路径断言）
grep -c "Dr. Wu Yuechao" _site/team/index.html                        # >=1
grep -c "Yangzhou University (YZU)" _site/team/index.html             # 1
grep -c "Bao Yu" _site/team/index.html                                # >=1
grep -c 'class="news-item"' _site/news/index.html                     # 6
grep -c "Liu Guanqing and Wu Yuechao" _site/news/index.html           # 1
grep -c 'class="news-item"' _site/index.html                          # 3（首页侧栏）
grep -c "Featured: DNA Large Language Models" _site/index.html        # 1
grep -c "## News" _site/index.html                                    # 0
grep -c "Start-up Fund" _site/about/index.html                        # 1
grep -c "Below are our key research areas" _site/research/index.html  # 1
grep -c "in-silico mutagenesis" _site/software/index.html             # 1
grep -c "Performs all calculations locally" _site/software/index.html # 1
# 反向：旧内容与参考站缺陷零残留
grep -c "Xin Xiaoyue\|Ding Yu\|Liu Shuo\|images/team/team/" _site/team/index.html   # 0
grep -c "{title}\|fonts.loli.net\|zstatic.net\|jsdmirror" _site/index.html _site/about/index.html   # 0
# serve 回环抽检
bundle exec jekyll serve >/tmp/jekyll-serve.log 2>&1 &
SERVE_PID=$!                                                          # 记录 PID（非交互 shell 无 job control）
sleep 5
for p in / /about/ /team/ /news/ /research/ /software/; do
  test "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000${p})" = "200" || echo "FAIL ${p}"
done
curl -s http://127.0.0.1:4000/team/ | grep -c "Dr. Wu Yuechao"        # >=1
curl -s http://127.0.0.1:4000/about/ | grep -c "Start-up Fund"       # 1
kill "${SERVE_PID}" 2>/dev/null                                        # 停止 serve
git status --porcelain | wc -l                                        # 0（全部已提交）
```

<threat_model>
asvs_level: 1
block_on: high

**资产**：公开学术站点内容文件、git 历史、本地 HTTP 开发服务。本计划只改内容文件与数据，不改依赖、不加网络服务、不处理用户输入。

| # | 威胁 | 等级 | 缓解（落在哪个任务） | 残余风险 |
|---|---|---|---|---|
| 1 | 内容回退/错删：重写页面时意外丢失本地正确内容（publications 83 条、正确 title 渲染、目录式 permalink） | medium | prohibition 明确禁改 publications.md/_sass/_config；Task 7 断言 publications git diff 为空、无 {title}/扁平链接/CDN 引用 | low |
| 2 | 数据 schema 变更破坏构建（YAML 语法/字段错配） | low | Task 1/3 验收先跑 YAML.load_file；Task 7 全量 build 断言退出码 0 | low |
| 3 | 删除 people.yml 误伤消费者 | low | Task 1 删除前 grep 模板目录零命中才删 | low |
| 4 | serve 暴露局域网 | low | Task 7 仅默认 127.0.0.1 绑定 + prohibition 禁 --host 0.0.0.0 | low |
| 5 | 外链内容注入（news/software 的 HTML headline） | low | 全部链接逐字取自参考快照（可信实验室自述），无用户输入面 | low |

**结论**：无 high 级威胁，无阻断项（block_on: high 不触发）。
</threat_model>
