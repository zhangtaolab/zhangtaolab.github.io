---
phase: 1
plan: 01
wave: 1
depends_on: []
files_modified:
  - Gemfile
  - Gemfile.lock
  - .ruby-version
  - .gitignore
  - _config.yml
  - assets/ref.bib
  - .planning/STATE.md
  - .planning/phases/01-local-dev-environment/SKELETON.md
autonomous: true
requirements:
  - ENV-01
  - ENV-02
---

# Phase 1 计划：本地开发环境（brownfield 环境跑通）

**用户故事（MVP）：** 作为实验室维护者，我想在本机依次执行 `bundle install` 与 `bundle exec jekyll serve --livereload`，在浏览器 http://127.0.0.1:4000 预览站点全部内容（含出版物列表），以便推送上线前确认改动、修改后页面自动刷新。

本阶段**不开发新功能**：站点代码已全部写完。本阶段交付的是"让既有站点在本机可运行、可预览、可提交"的最小环境改动 + 既有渲染链路的端到端证明。

## 现状盘点（2026-08-17 磁盘实测事实）

执行者必须以下列实测事实为基准，不要凭假设：

1. **Gemfile**（已跟踪）：`gem "jekyll", "4.3.3"` 精确钉住；`gem 'jekyll-scholar'` 与 `gem 'jekyll-sitemap'` 位于顶层，**不在** `:jekyll_plugins` group；另有 `sass-embedded ~> 1.77.0`、`rack >= 2.2.3`、`kramdown-parser-gfm`、`webrick ~> 1.7`、`csv`、`base64`、`bigdecimal`、`observer`。**无 Gemfile.lock**。
2. **本机环境**：Ruby 4.0.6（arm64-darwin25，Homebrew `/opt/homebrew/bin/ruby`）+ Bundler 4.0.16；未安装 rbenv/asdf/mise；无 `.ruby-version` 文件。
3. **git 状态**：仅 `Gemfile`、`_config.yml`、`.planning/*`、`.claude/*` 被跟踪；全部站点代码（`_data/ _includes/ _layouts/ _pages/ _sass/ assets/ images/ papers/ favicon.* feed.xml robots.txt`）**未跟踪**；**无 `.gitignore`**。
4. **插件加载缺口（必然的构建失败点）**：`_config.yml` 的 `plugins: ["jekyll-sitemap"]` 不含 jekyll-scholar，Gemfile 也没有 `:jekyll_plugins` group → jekyll-scholar **不会被加载**，`_pages/talks.md` 的 `{% bibliography %}` 将报 `Unknown tag 'bibliography'` 构建失败。
5. **文献链路现状（与 ROADMAP 判据的关键差异）**：
   - `_config.yml` `scholar.source: /assets/` + `bibliography: ref.bib` → 实际解析的是 `assets/ref.bib` = **Feynman 模板演示数据**（24 条，含 @incollection talks 条目）。
   - 真实实验室文献在 `papers/ref.bib`（12 条，2024–2026，mtime 17:12 晚于 assets/ref.bib 的 17:04），**当前没有任何配置指向它**。
   - `_pages/publications.md` 出版物页是**手写 markdown 列表（83 条，2006–2026）**，不经 jekyll-scholar 渲染。
   - 全站只有 `_pages/talks.md` 使用 `{% bibliography %}`（2 个 `@incollection[keywords...]` 查询，消费的是演示数据）。
   - `scholar` 配置含 `details_dir: bibliography` / `details_layout: bibtex.html` / `details_link: Details`，但 `_layouts/` 中**不存在 bibtex.html**，且 `bibtemplate.html` 不渲染任何 Details 链接 —— 三键为模板遗留死配置。
   - `scholar.style: citesty`，磁盘上无 `citesty.csl`；能否被 citeproc-ruby 解析待构建验证，失败则回退 `apa`。
6. **页面清单**：13 个 `_pages/*.md`（home/about/research/publications/software/team/news/contact/blogs/talks/teaching/allnews/404），`nav_pages` 含 7 个；无 `_posts` 目录（blogs/allnews 渲染为空列表，属正常）；`feed.xml` 与 `robots.txt` 位于仓库根。

## 任务

```xml
<tasks>

<task id="1" name="Ruby/Jekyll 版本决策阶梯 + 绿色构建（tracer 切片）" type="tracer">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/Gemfile
    - /Users/forrest/Playground/zhangtaolab-jekyll/_config.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/papers/ref.bib
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/talks.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/STATE.md
  </read_first>
  <action>
    1. 修复插件加载（无条件执行）：编辑 Gemfile，把顶层的 `gem 'jekyll-scholar'` 与 `gem 'jekyll-sitemap'` 两行移入新增的 `group :jekyll_plugins do ... end` 块；其余行不动。
    2. 按决策阶梯逐级尝试，首个成功级别即停，并在 STATE.md 记录每级尝试结果：
       - Step 0（最小改动，优先）：保留 `gem "jekyll", "4.3.3"`，运行 `bundle install`；若 resolver 报 Ruby 版本约束不满足 → Step A。安装成功后运行 `bundle exec jekyll build`：
         a. 报 `LoadError` 指向某个被 Ruby 4 移出 default gems 的库（如 ostruct/logger/drb/mutex_m/abbrev/pstore）→ 在 Gemfile 顶层补 `gem "<报错的库名>"` 后重试；
         b. 报 `Unknown tag 'bibliography'` → 说明插件组修复未生效，检查 Gemfile 语法与 bundle 环境；
         c. scholar 相关失败：若 style 解析失败（citesty）→ `_config.yml` 中 `style: citesty` 改为 `style: apa`；若出现 Layout 'bibtex.html' 不存在的警告/错误 → 删除 `_config.yml` scholar 段的 `details_dir`、`details_layout`、`details_link` 三键（bibtemplate.html 不使用 Details 链接，属死配置）；
         d. 原生扩展编译失败（sass-embedded 等）且无法通过补 gem 解决 → Step A。
       - Step A（小版本升级 Jekyll）：`gem "jekyll", "4.3.3"` 改为 `gem "jekyll", "~> 4.4.0"`；若 jekyll-scholar 与之 resolver 冲突，按 bundle 报错把 jekyll-scholar 钉到最新兼容版本（形如 `gem 'jekyll-scholar', '~> 7.0'`）；尽量保留 `sass-embedded ~> 1.77.0` 钉（存在意义是压制 Bootstrap SCSS 弃用告警），仅当 resolver 强制时放宽为 `>= 1.77`。重跑 `bundle install` 与 `bundle exec jekyll build`（Step 0 的 a–c 补偿规则继续适用）。
       - Step B（系统级变更，执行前必须暂停并向用户确认）：`brew install ruby@3.4`，按 brew caveats 将其加入 PATH（keg-only，不覆盖系统 Ruby），随后重跑 install/build。本级别改变机器全局状态，不得自主执行。
    3. 构建通过后：将 `bundle exec ruby -e 'puts RUBY_VERSION'` 的精确输出（三段版本号）写入仓库根 `.ruby-version`。
    4. 更新 `.planning/STATE.md` 的「关键决策点（待执行时解决）」：把 Ruby/Jekyll 兼容性条目改写为已决策记录（生效级别 0/A/B、Gemfile 最终 jekyll 钉、日期、一行理由、剩余风险），并同步「Session Continuity」。
  </action>
  <acceptance_criteria>
    - 在仓库根执行 `bundle install` 退出码为 0
    - 仓库根存在 Gemfile.lock，且其中包含 jekyll-scholar 与 jekyll-sitemap 的具体版本条目
    - `bundle exec jekyll build` 退出码为 0，输出中不出现 `Unknown tag 'bibliography'`
    - `grep -n "group :jekyll_plugins" -A 4 Gemfile` 同时命中 jekyll-scholar 与 jekyll-sitemap 两行，且 Gemfile 顶层不再出现这两行
    - `.ruby-version` 存在，且 `test "$(cat .ruby-version)" = "$(bundle exec ruby -e 'puts RUBY_VERSION')"` 通过
    - `.planning/STATE.md` 包含标记为已决策的版本记录，含生效级别（0/A/B）
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && bundle install && bundle exec jekyll build && echo BUILD_OK
    grep -n "group :jekyll_plugins" -A 4 Gemfile
    test "$(cat .ruby-version)" = "$(bundle exec ruby -e 'puts RUBY_VERSION')" && echo RUBY_PIN_OK
  </verify>
</task>

<task id="2" name="文献链路对齐 papers/ref.bib + 演示数据清除" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/_config.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/papers/ref.bib
    - /Users/forrest/Playground/zhangtaolab-jekyll/assets/ref.bib
    - /Users/forrest/Playground/zhangtaolab-jekyll/_layouts/bibtemplate.html
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/talks.md
  </read_first>
  <action>
    1. `_config.yml` scholar 段：`source: /assets/` 改为 `source: /papers/`，使 jekyll-scholar 解析真实文献 `papers/ref.bib`。
    2. 确认无残留引用后删除演示数据：先运行 `grep -rn "assets/ref.bib" . --exclude-dir=_site --exclude-dir=.jekyll-cache --exclude-dir=.git --exclude-dir=.planning --exclude-dir=.claude`（排除规划/文档目录中的字符串提及，仅检查功能性引用），除 `_config.yml` 旧值外无其他引用 → `rm assets/ref.bib`（Feynman 模板演示数据，避免随静态站点发布到线上）。
    3. 临时探针验证（验证后删除，不提交）：创建 `_pages/bibprobe.md`，frontmatter 为 `title: "BibProbe"` / `layout: page` / `permalink: /bibprobe/` / `sitemap: false`，正文仅一行 `{% bibliography %}`；执行 `bundle exec jekyll build`；校验 `_site/bibprobe/index.html` 后删除 `_pages/bibprobe.md` 并再次 build 确认退出码 0。
    4. 在 `.planning/STATE.md` 待确认项中记录已知空态：`papers/ref.bib` 无 @incollection 条目，`/talks/` 两个查询将渲染为空列表（页面仍 200、标题仍在）；真实 talks 数据属内容补全工作，不在本阶段。
  </action>
  <acceptance_criteria>
    - `grep -n "source: /papers/" _config.yml` 命中，且 `_config.yml` 中不再出现 `source: /assets/`
    - `test ! -f assets/ref.bib` 通过（演示 bib 已删除）
    - 探针产物 `_site/bibprobe/index.html` 中 `grep -c 'class="pub-entry"'` 输出为 12（等于 `grep -c '^@' papers/ref.bib` 的条目数），且页面文本包含 `Telomere-to-telomere`（papers/ref.bib 首条 bao2026oryza 的标题词）
    - `test ! -f _pages/bibprobe.md` 通过，且删除探针后的 `bundle exec jekyll build` 退出码为 0
    - `.planning/STATE.md` 含 talks 空态记录
  </acceptance_criteria>
  <verify>
    grep -n "source: /papers/" _config.yml && test ! -f assets/ref.bib && bundle exec jekyll build && echo ALIGN_OK
  </verify>
</task>

<task id="3" name="本地 serve 全页面渲染 + live reload 端到端验证" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/_config.yml
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/home.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/_pages/publications.md
    - /Users/forrest/Playground/zhangtaolab-jekyll/feed.xml
  </read_first>
  <action>
    1. 后台启动 `bundle exec jekyll serve --livereload`（使用默认绑定 127.0.0.1:4000；禁止追加 `--host 0.0.0.0`），等待服务就绪（日志出现 `Server address: http://127.0.0.1:4000/`）。
    2. 逐项 curl 校验下表全部 URL 返回 200 且包含标记文本：`/`→`Zhang Tao Lab`；`/about/`→`Dr. Zhang Tao`；`/research/`→`Research Areas`；`/publications/`→`Telomere-to-telomere`；`/software/`→`Software &amp; Tools`（Kramdown 会将正文标题 `## Software & Tools` 中的 `&` 转义为 `&amp;`，grep 断言须匹配渲染后的 HTML 文本）；`/team/`→`Alumni`；`/news/`→`News`；`/contact/`→`Contact`；`/blogs/`→`Blog`；`/talks/`→`Invited Talks`；`/teaching/`→`Teaching`；`/allnews.html`→`News`；`/404.html`→`Page Not Found`；`/feed.xml`→`<rss`；`/sitemap.xml`→`urlset`；`/assets/main.css`→200 且响应体大于 1000 字节。
    3. 出版物页完整性：`curl -s http://127.0.0.1:4000/publications/` 同时包含 `Telomere-to-telomere`（2026）与 `The CentO satellite`（2013）与 `Nature Communications`，证明 83 条手写列表全时间跨度渲染、未被截断。
    4. live reload 验证：`curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:4000/livereload.js` 返回 200；编辑 `_pages/home.md` 在 hero-section 结束标签后插入一行 `<p id="lr-probe">LIVERELOAD_PROBE</p>`，等待至多 10 秒后 `curl -s http://127.0.0.1:4000/ | grep LIVERELOAD_PROBE` 命中；随后还原 `_pages/home.md`（`git diff _pages/home.md` 为空，因为该文件本阶段未跟踪，故以文件内容不含 LIVERELOAD_PROBE 为准），确认 serve 日志在改动后出现 `Regenerating`。
    5. 验证全部通过后停止 serve 进程，不留后台服务。
  </action>
  <acceptance_criteria>
    - 上表 16 个 URL 全部返回 HTTP 200 且包含各自标记文本（可用单条 shell 循环逐项断言）
    - `/publications/` 同时包含 `Telomere-to-telomere`、`The CentO satellite`、`Nature Communications`
    - `curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:4000/livereload.js` 输出 200
    - 修改 `_pages/home.md` 后 ≤10 秒，`curl -s http://127.0.0.1:4000/` 的 HTML 包含 `LIVERELOAD_PROBE`；还原后该标记消失
    - serve 进程已停止（`curl` 连接被拒绝即证明）
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && (bundle exec jekyll serve --livereload >/tmp/jekyll-serve.log 2>&1 &) && sleep 5 && curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:4000/ && curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:4000/livereload.js
  </verify>
</task>

<task id="4" name=".gitignore + 站点源码首次入库" type="expansion">
  <read_first>
    - /Users/forrest/Playground/zhangtaolab-jekyll/Gemfile.lock
    - /Users/forrest/Playground/zhangtaolab-jekyll/.ruby-version
    - /Users/forrest/Playground/zhangtaolab-jekyll/.planning/STATE.md
  </read_first>
  <action>
    1. 创建仓库根 `.gitignore`，至少包含以下行：`_site/`、`.jekyll-cache/`、`.jekyll-metadata`、`.bundle/`、`vendor/bundle`、`.DS_Store`。
    2. `git add -A` 将全部站点源码纳入跟踪（`_data/ _includes/ _layouts/ _pages/ _sass/ assets/ images/ papers/ favicon.ico favicon.svg feed.xml robots.txt` 以及本阶段产物 `.gitignore`、`.ruby-version`、`Gemfile.lock`、`_config.yml`、`Gemfile` 的改动）；提交前确认 `git status` 中没有 `_site` 或 `.jekyll-cache` 相关待跟踪项。
    3. 以单条原子提交完成（信息形如 `feat: onboard site source with working local dev environment`）。不执行 push（远端发布属 Phase 2 范围）。
  </action>
  <acceptance_criteria>
    - `.gitignore` 存在且包含 `_site/`、`.jekyll-cache/`、`.bundle/` 三行
    - `git status --porcelain` 输出为空（工作区全部已提交）
    - `git ls-files _pages | wc -l` 输出 13
    - `git ls-files` 包含 `Gemfile.lock`、`.ruby-version`、`papers/ref.bib`，且不包含 `assets/ref.bib`
    - `git check-ignore _site` 退出码为 0（构建产物被忽略）
  </acceptance_criteria>
  <verify>
    cd /Users/forrest/Playground/zhangtaolab-jekyll && git check-ignore _site && git ls-files Gemfile.lock .ruby-version papers/ref.bib && git status --porcelain | wc -l
  </verify>
</task>

</tasks>
```

任务依赖：1 → 2 → 3 → 4（严格顺序，单一 plan 内按序执行，无并行波次）。

## must_haves

```yaml
must_haves:
  truths:
    - "仓库根执行 `bundle install` 退出码 0，且生成被 git 跟踪的 Gemfile.lock"
    - "`bundle exec jekyll build` 退出码 0，构建输出不含 Unknown tag 'bibliography'（证明 jekyll-scholar 经 :jekyll_plugins group 正确加载）"
    - "Gemfile 含 group :jekyll_plugins 块，块内同时有 gem \"jekyll-scholar\" 与 gem \"jekyll-sitemap\""
    - "`bundle exec jekyll serve --livereload` 启动后，curl http://127.0.0.1:4000/ 返回 200 且 HTML 含 Zhang Tao Lab"
    - "13 个页面 permalink 全部返回 200 并含各自标记文本（/、/about/、/research/、/publications/、/software/、/team/、/news/、/contact/、/blogs/、/talks/、/teaching/、/allnews.html、/404.html）"
    - "/publications/ 同时包含 Telomere-to-telomere 与 The CentO satellite（83 条手写文献全跨度渲染、非截断、非空）"
    - "_config.yml 中 scholar.source 为 /papers/；探针构建产物含 12 个 class=\"pub-entry\" 元素且含 Telomere-to-telomere 文本（jekyll-scholar 正常解析 papers/ref.bib，非静默失败）"
    - "curl http://127.0.0.1:4000/livereload.js 返回 200；修改 _pages/home.md 后 ≤10 秒 curl / 的 HTML 反映改动（live reload 生效）"
    - ".ruby-version 存在且与 bundle exec ruby -e 'puts RUBY_VERSION' 输出完全一致"
    - ".gitignore 含 _site/、.jekyll-cache/、.bundle/；git status --porcelain 为空（站点源码全部入库）"
    - ".planning/STATE.md 记录已生效的版本决策（级别 0/A/B）与理由"
    - statement: "浏览器实际自动刷新：维护者在真实浏览器中打开本地预览，修改源文件后无需手动刷新页面即更新"
      verification: backstop
    - statement: "页面布局视觉正常（样式加载、图片显示、无裸 HTML观感）—— /assets/main.css 返回 200 且 >1000 字节为机器可查部分，整体视觉需人工确认"
      verification: backstop
  prohibitions:
    - "不得以 sudo 或全局 gem install 绕过 Bundler 修复环境：一切依赖必须经 Gemfile/Gemfile.lock 表达"
    - "不得通过掩盖错误换取绿色构建：不得引入 liquid error_mode: lax/warn、不得删除或清空报错页面（如 talks.md）、不得静默卸载插件"
    - "不得移除 jekyll-scholar 或 jekyll-sitemap 插件来让构建通过"
    - "不得让模板演示数据（assets/ref.bib 的 Feynman 条目）留在文献渲染链中被当作正常功能"
    - "本阶段不得把 publications.md 手写 83 条列表替换或裁剪为 jekyll-scholar 生成列表（papers/ref.bib 仅 12 条，替换会静默丢失 71 条内容）"
    - "本地 serve 不得绑定 127.0.0.1 以外地址（禁止 --host 0.0.0.0 暴露局域网）"
```

## Flagged assumptions（探针未分类边的显式假设，不静默丢弃）

规格探针将 ENV-01/ENV-02 两行标记为 `unclassified/unresolved`，本计划将其显式抬升为下列假设；执行与验证阶段如证伪，按偏差流程上报而非擅自改道：

| requirement_id | 探针状态 | 显式假设 | 计划内处置 | 证伪后果 |
|---|---|---|---|---|
| ENV-01 | unclassified / unresolved | Homebrew Ruby 4.0.6 + Bundler 4.0.16 无需版本管理器即可运行 Jekyll 4.3.3 或 4.4.x（阶梯 Step 0/A 可达） | Task 1 决策阶梯实测 | 需 Step B 安装系统级 ruby@3.4（机器全局变更，必须先征得用户同意，超出"最小改动"须用户知情） |
| ENV-02 | unclassified / unresolved | ROADMAP 判据 3 的表述（"出版物列表由 jekyll-scholar 解析 papers/ref.bib"）可在不重构内容流的前提下满足：出版物页保持手写 83 条（非空、全跨度），jekyll-scholar 链路通过 `scholar.source: /papers/` + 12 条探针渲染证明解析真实 bib | Task 2 对齐 + 探针；prohibition 5 防内容丢失 | 若用户期望出版物页完全由 bib 驱动，需先把 83 条全部补入 papers/ref.bib —— 属后续内容补全工作，须重排 ROADMAP，不在 Phase 1 |
| ENV-02（附加） | unclassified / unresolved | `scholar.style: citesty` 能被 citeproc-ruby 解析（磁盘无 citesty.csl） | Task 1 Step 0.c：解析失败则回退 `style: apa` 并记录 | 仅影响条目格式风格，不阻塞链路 |
| ENV-01（附加） | unclassified / unresolved | Ruby 4 移出 default gems 的库仅限可经 Gemfile 补钉的少量 gem | Task 1 Step 0.a 补钉规则 | 补钉数量过多/无效时升入 Step A/B |

## Artifacts this phase produces

后续阶段的源符号清单（drift 校验时应排除这些**本阶段新增**符号）：

- **新文件**：`Gemfile.lock`（依赖锁定）、`.ruby-version`（Ruby 版本 pin，Phase 2 CI 对齐的事实源）、`.gitignore`
- **Gemfile 结构变化**：新增 `group :jekyll_plugins` 块（jekyll-scholar、jekyll-sitemap 移入）；`gem "jekyll"` 的钉可能由 `4.3.3` 变为 `~> 4.4.0`（阶梯 Step A 结果）；可能新增 default-gem 补钉行（ostruct 等）
- **_config.yml 键变化**：`scholar.source: /assets/` → `/papers/`；删除 `scholar.details_dir`、`scholar.details_layout`、`scholar.details_link` 三键；（条件性）`scholar.style: citesty` → `apa`
- **删除文件**：`assets/ref.bib`（Feynman 演示数据）
- **临时文件（验证后删除，不入库）**：`_pages/bibprobe.md`（jekyll-scholar 解析探针页）
- **文档更新**：`.planning/STATE.md` 版本决策记录；`.planning/phases/01-local-dev-environment/SKELETON.md`
- **无**新脚本、新布局、新 Rake task、新页面、新 gem source

## Verification criteria（阶段验证脚本骨架）

验证者按序执行，全部通过方可判定阶段达成：

```bash
cd /Users/forrest/Playground/zhangtaolab-jekyll
bundle install                                                # 退出码 0
bundle exec jekyll build                                      # 退出码 0，无 Unknown tag
test "$(cat .ruby-version)" = "$(bundle exec ruby -e 'puts RUBY_VERSION')"
grep -n "source: /papers/" _config.yml
test ! -f assets/ref.bib
bundle exec jekyll serve --livereload >/tmp/jekyll-serve.log 2>&1 &
sleep 5
for path in / /about/ /research/ /publications/ /software/ /team/ /news/ /contact/ /blogs/ /talks/ /teaching/ /allnews.html /404.html /feed.xml /sitemap.xml; do
  test "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000${path})" = "200" || echo "FAIL ${path}"
done
curl -s http://127.0.0.1:4000/publications/ | grep -c -e "Telomere-to-telomere" -e "The CentO satellite"   # >= 2
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:4000/livereload.js                                  # 200
# live reload：编辑 _pages/home.md 注入标记 → ≤10s → curl / 应含标记 → 还原
git check-ignore _site && git status --porcelain | wc -l   # 0
```

<threat_model>
asvs_level: 1
block_on: high

**资产**：Gemfile 依赖供应链、本地 HTTP 开发服务、git 仓库内容（将首次全量入库）。

| # | 威胁 | 等级 | 缓解（落在哪个任务） | 残余风险 |
|---|---|---|---|---|
| 1 | 依赖供应链：bundle install 从 rubygems.org 拉取未钉版本的 jekyll-scholar 等传递依赖 | medium | Task 1 生成 Gemfile.lock 并在 Task 4 入库锁定精确版本；不新增 gem source | low |
| 2 | 本地 serve 暴露：绑定非回环地址导致局域网可访问开发服务 | low | Task 3 强制默认 127.0.0.1 + prohibition 6 禁止 --host 0.0.0.0 | low |
| 3 | 敏感/生成物误入库：_site、.jekyll-cache、.bundle 提交进 git 历史 | low | Task 4 .gitignore 前置 + `git check-ignore _site` 验收；本仓库内容为公开学术站点，无密钥类文件（analytics id 为空） | low |
| 4 | 模板演示数据（Feynman bib）随静态发布上线，被误当实验室真实文献 | medium | Task 2 删除 assets/ref.bib + prohibition 4 | low |
| 5 | Step B 系统级 Ruby 安装影响机器其他 Ruby 项目 | low | 必须 keg-only 安装（ruby@3.4 不覆盖系统 Ruby）且执行前征得用户确认 | low |

**结论**：无 high 级威胁，无阻断项（block_on: high 不触发）。本阶段不引入网络服务、不处理用户输入、不部署公网。
</threat_model>
