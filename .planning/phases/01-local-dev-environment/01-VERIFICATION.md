---
phase: 01-local-dev-environment
plan: 01
verifier: gsd-verifier
date: 2026-08-17
status: human_needed
score: 11/11 machine truths verified (1 with adjudicated deviation), 2 backstop truths → human_needed, 0 gaps
requirements: [ENV-01, ENV-02]
prohibitions_violated: 0
---

# Phase 1 Verification: 本地开发环境

**Phase goal:** 维护者能在本地预览网站全部内容（含出版物列表）
**Status:** `human_needed` — 全部 11 条机器可查 must_haves 以独立实测证据通过（其中 1 条按"功能等价"裁定，见 T8）；6 条禁制零违例；ENV-01/ENV-02 全覆盖。2 条 `verification: backstop` 真相（真实浏览器自动刷新、整体视觉正常）按诚实验证契约不由机器判定，转人工确认。

**Score:** 11/11 machine truths PASS（T8 含裁定偏差）+ 2/2 backstop → human_needed。**机器可查范围内无任何缺口（gaps: 0）。**

验证方式说明：本次验证不信任 SUMMARY 声明，全部证据由验证者于 2026-08-17 在仓库实机重测取得（含独立重跑已删除的 jekyll-scholar 探针、独立起停 serve 实例）。

---

## 1. Must-haves truths 逐条证据（11 机器可查 + 2 backstop）

### T1. `bundle install` 退出码 0，且生成被 git 跟踪的 Gemfile.lock — PASS

```
$ bundle install
... Bundle complete! ...
EXIT=0
$ git ls-files Gemfile.lock .ruby-version papers/ref.bib
.ruby-version
Gemfile.lock
papers/ref.bib
```

Gemfile.lock 中锁定版本：`jekyll (4.4.1)`、`jekyll-scholar (7.3.0)`、`jekyll-sitemap (1.4.0)`（Gemfile.lock L84/L105/L110）。

### T2. `bundle exec jekyll build` 退出码 0，无 Unknown tag 'bibliography' — PASS

```
$ bundle exec jekyll build 2>&1 | grep -c "Unknown tag 'bibliography'"
0
$ bundle exec jekyll build > /tmp/verify-build.log 2>&1
BUILD_EXIT=0
                    done in 0.236 seconds.
```

### T3. Gemfile 含 group :jekyll_plugins 块，块内同时有两个插件 — PASS

```
$ grep -n "group :jekyll_plugins" -A 4 Gemfile
8:group :jekyll_plugins do
9-  gem 'jekyll-scholar'
10-  gem 'jekyll-sitemap'
11-end
```

两行仅出现在 group 块内（全文件仅 L9/L10 两处命中），顶层无残留。

### T4. serve --livereload 启动后 `curl /` 返回 200 且含 Zhang Tao Lab — PASS

验证者自起 serve 实例（未复用任何遗留进程）：

```
$ bundle exec jekyll serve --livereload
LiveReload address: http://127.0.0.1:35729
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

`/` 在 16-URL 断言循环中以 marker `Zhang Tao Lab` 通过（见 T5）。

### T5. 13 个页面 permalink 全部 200 并含标记文本 — PASS（15/15 页面 URL + main.css = 16 项全过）

逐 URL 断言循环（`curl -w '%{http_code}'` + marker grep），结果 **PASS=15 FAIL=0**：

`/`(Zhang Tao Lab)、`/about/`(Dr. Zhang Tao)、`/research/`(Research Areas)、`/publications/`(Telomere-to-telomere)、`/software/`(Software &amp; Tools)、`/team/`(Alumni)、`/news/`(News)、`/contact/`(Contact)、`/blogs/`(Blog)、`/talks/`(Invited Talks)、`/teaching/`(Teaching)、`/allnews.html`(News)、`/404.html`(Page Not Found)、`/feed.xml`(<rss)、`/sitemap.xml`(urlset) — 全部 200 + marker 命中。

第 16 项 `main.css` 单独验证：`code=200 bytes=161960`（> 1000 字节）。

已知空态（计划内、非缺陷）：`/talks/` 200 且标题在，但两个 `@incollection` 查询渲染为空列表——`papers/ref.bib` 的 `grep -c '@incollection'` = 0，与 STATE.md 已记录的空态一致；`/blogs/` 同理（无 `_posts` 目录）。

### T6. /publications/ 含 Telomere-to-telomere + The CentO satellite（83 条全跨度、非截断） — PASS

```
$ curl -s :4000/publications/ | grep -c <marker>
Telomere-to-telomere   => 1
The CentO satellite    => 1
Nature Communications  => 3
```

### T7. scholar.source = /papers/；探针产物 12 个 pub-entry 且含 Telomere-to-telomere — PASS（验证者独立重跑探针）

静态部分：`grep -n "source: /papers/" _config.yml` → `82:  source: /papers/`；`source: /assets/` 命中数为 0。

探针部分：执行期探针已按计划删除，**验证者临时重建同规格探针独立复测**（frontmatter 同计划，正文 `{% bibliography %}`）：

```
$ bundle exec jekyll build   → BUILD_EXIT=0
$ grep -c 'class="pub-entry"' _site/bibprobe/index.html   → 12
$ grep -c "Telomere-to-telomere" _site/bibprobe/index.html → 3
```

12 与 `grep -c '^@' papers/ref.bib` = 12 一致——jekyll-scholar 经 `:jekyll_plugins` group 真实解析 `papers/ref.bib`，非静默失败。复测后删除探针并重建（`REBUILD_EXIT=0`，探针页与产物均消失，`git status --porcelain` = 0）。

### T8. livereload.js 200 + 编辑探针 ≤10s 反映 — PASS（按功能等价裁定；字面 URL 在 Jekyll 4.4.1 下 404）

**字面偏差（裁定为不构成缺口）：**

```
$ curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/livereload.js
404
$ curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:35729/livereload.js
200   （38,152 字节真实 livereload 客户端 JS，首行 (function e(t,n,r){...）
$ curl -s :4000/ | grep -o '35729[^"]*'
35729/livereload.js?snipver=1&port=35729
```

**裁定理由：** 计划原文的 `:4000/livereload.js` 断言写于 Jekyll 4.3.3 行为基线（livereload 客户端经主服务 4000 端口提供）。执行期按用户指令升级至 4.4.1 后，客户端改由专用 reload 服务器在 127.0.0.1:35729 提供，**页面注入的 loader 已自动指向 35729**（上列第三条证据），即浏览器侧机制完整且可达（200，真实 JS 资源）。该 truth 的意图是"live reload 生效"，其功能核心由下方功能探针独立证实；字面 URL 差异属版本行为漂移而非功能缺失。故判 **PASS（功能等价）**，偏差已由 SUMMARY/STATE.md 如实记录而非隐瞒。若坚持字面通过，唯一路径是降回 Jekyll 4.3.3——与用户"采用较新版本"指令直接冲突，不合理。

**功能探针（验证者独立重测）：**

```
注入 <p id="lr-probe">LIVERELOAD_PROBE</p> 于 _pages/home.md hero-section 后
PROBE_APPEARED after 1s        （≤10s 要求，serve 日志出现 Regenerating）
还原 home.md 后
PROBE_GONE after 1s            （标记消失，文件无残留 grep = 0）
```

### T9. .ruby-version 与 `bundle exec ruby -e 'puts RUBY_VERSION'` 完全一致 — PASS

```
$ cat .ruby-version → 4.0.6
$ bundle exec ruby -e 'puts RUBY_VERSION' → 4.0.6
RUBY_PIN_OK
```

### T10. .gitignore 含 _site/ .jekyll-cache/ .bundle/；git status --porcelain 为空 — PASS

`.gitignore` 实测含 `_site/`、`.jekyll-cache/`、`.jekyll-metadata`、`.bundle/`、`vendor/bundle`、`.DS_Store`。`git check-ignore _site` 命中（IGNORE_OK）；`git status --porcelain | wc -l` = **0**（验证者在删除自建探针并停止 serve 后复核）；`git ls-files _pages | wc -l` = **13**。

### T11. STATE.md 记录已生效版本决策（级别 + 理由） — PASS

`.planning/STATE.md`「关键决策点（已决策）」明示：**生效级别：Step 0 → Step A（用户指令后置升级）**、最终组合 Ruby 4.0.6 + Jekyll 4.4.1、理由（GitHub 版本支持要求 + 两命令退出码 0）、配套补偿三项、剩余风险（含 Ruby 4.0.6 超出官方支持矩阵、livereload 35729 迁移）。

### T12（backstop）. 浏览器实际自动刷新 — HUMAN_NEEDED

机器探针（35729 客户端 200、1s 内 Regenerating、页面 loader 指向 35729）是必要非充分证据：无法证明真实浏览器 WebSocket 连接建立且**无需手动刷新**完成页面更新。按诚实验证契约不由机器关闭。

### T13（backstop）. 页面布局视觉正常 — HUMAN_NEEDED

机器可查部分已过：`/assets/main.css` 200 且 161,960 字节 > 1000。但"图片显示、无裸 HTML 观感"整体视觉超出机器证据能力。按诚实验证契约不由机器关闭。

---

## 2. Prohibitions 检查（6/6 未违例）

| # | 禁制 | 检查方式 | 结果 |
|---|------|----------|------|
| 1 | 不得 sudo / 全局 gem install 绕过 Bundler | `grep -rn "sudo gem\|gem install --user-install" Gemfile _config.yml` 零命中；全部依赖经 Gemfile/Gemfile.lock（含 CHECKSUMS 段）；git 历史无任何环境绕过痕迹 | 未违例 |
| 2 | 不得掩盖错误换绿色构建 | `grep -rn "error_mode" _config.yml _pages/ _layouts/` 零命中；`_pages/talks.md` 完整存在且含 2 个 `{% bibliography %}` 标签；13 页无删除 | 未违例 |
| 3 | 不得移除两插件换取通过 | Gemfile L9-L10 双双在 group 内；Gemfile.lock 锁 jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0；探针实证 scholar 在渲染 | 未违例 |
| 4 | 演示数据不得留在文献链 | `test ! -f assets/ref.bib` 通过；`git ls-files assets/ref.bib` 为空（未入库）；`scholar.source: /papers/` 唯一生效 | 未违例 |
| 5 | 不得替换/裁剪手写 83 条出版物列表 | `grep -cE '^[0-9]+\. ' _pages/publications.md` = **83**（末条编号 83.）；`grep -c "bibliography"` = 0（页面不经 scholar 渲染，未被替换） | 未违例 |
| 6 | serve 不得绑定 127.0.0.1 以外地址 | serve 运行中 `lsof -nP -sTCP:LISTEN`：`TCP 127.0.0.1:4000` 与 `TCP 127.0.0.1:35729`，均为回环，无 0.0.0.0/*: 绑定 | 未违例 |

## 3. Flagged assumptions 判定（4/4 有了结）

| 假设 | 判定 | 证据 |
|------|------|------|
| ENV-01 主：Ruby 4.0.6 + Bundler 4.0.16 无版本管理器可跑 Jekyll 4.4.x | **VALIDATED** | Step A 生效：install/build 均 exit 0（T1/T2），Step B（brew ruby@3.4）未动用，无系统级变更 |
| ENV-01 附：Ruby 4 移出 default gems 的库可经 Gemfile 补钉 | **VALIDATED** | Gemfile 顶层 webrick/csv/base64/bigdecimal/observer 补钉行在位；01-REVIEW 复核 lockfile 覆盖全部被移除 default gems（含 logger/date/json 等传递依赖），构建绿 |
| ENV-02 主：手写 83 条 + scholar 链路对齐可在不重构内容流下满足 ROADMAP 判据 3 | **VALIDATED** | publications.md 83 条完整（T6 三标记跨 2026→2013）；scholar 解析 papers/ref.bib 由探针 12/12 独立复证（T7）； prohibition 5 未违例 |
| ENV-02 附：citesty 样式可被 citeproc-ruby 解析 | **FALSIFIED（计划内回退已执行）** | `_config.yml` L80 `style: apa`（计划 Step 0.c 既定回退路径，STATE.md 已记录；仅风格差异，不阻塞链路） |

## 4. Requirement coverage（2/2 全覆盖）

### ENV-01 — bundle install + jekyll serve + live reload
- **覆盖证据：** T1（install exit 0）、T3/T4（插件加载 + serve 200）、T8（livereload 客户端 200 + 1s 探针再生）
- **ROADMAP 判据对照：** 判据 1 ✅（install + serve 启动无依赖错误）；判据 4 机器部分 ✅、浏览器行为 → T12 人工项
- **状态：** machine-verified；浏览器自动刷新留人工（backstop）

### ENV-02 — 全页面渲染 + 出版物非空 + scholar 正常解析 papers/ref.bib
- **覆盖证据：** T5（15 URL 全 200 + marker）、T6（出版物非空全跨度）、T7（scholar 12/12 解析真实 bib）、T2（无 Unknown tag = 无静默失败）
- **ROADMAP 判据对照：** 判据 2 机器部分 ✅（全部页面 200、CSS 161,960B）、整体布局观感 → T13 人工项；判据 3 ✅（出版物非空 + 探针证解析）
- **状态：** machine-verified；整体视觉留人工（backstop）

REQUIREMENTS.md 中 ENV-01/ENV-02 两行均由本阶段 PLAN frontmatter `requirements: [ENV-01, ENV-02]` 声明并如上闭环，**无缺失 ID，无计划外认领**。

## 5. 代码评审警告对 must_haves 的效力判定（均不推翻）

- **CR-01（vendor 未入 exclude）：** 纯 Phase 2 CI 泄漏风险。本机构建经 Homebrew 系统 gems，仓库本地无 `vendor/` 目录，本次实测构建/serve/16 URL 全部不受影响。**不推翻任何 Phase 1 must_have。**
- **CR-02（assets/main.css 与 main.scss 输出冲突）：** 静态快照当前胜出且 161,960 字节 > 1000 字节，T5 第 16 项与 T13 机器部分仍成立；风险是未来 scss 改动后静态 css 过期，属 Phase 2 部署卫生。**不推翻任何 Phase 1 must_have。**
- CR-03..07 均为 info 级（rack 冗余、feed 时区、pubDate 空值防御、gitignore vendor 变体），无 Phase 1 效力。

## 6. Human verification（2 项待人工确认）

> 机器证据已把这两项推到"只差人眼"的边界；确认任一项失败即回退本验证结论。

- [ ] **H1（T12）真实浏览器自动刷新：** 在本机执行 `bundle exec jekyll serve --livereload`，用浏览器打开 http://127.0.0.1:4000 ，编辑任一源文件（如 `_pages/home.md`），确认**不手动刷新**的情况下页面数秒内自行更新。（机器已证：35729 客户端 200、loader 注入、1s 再生。）
- [ ] **H2（T13）整体视觉正常：** 浏览器浏览首页/研究/团队/出版物等主要页面，确认样式加载、图片显示、无裸 HTML 观感、深浅色模式切换正常。（机器已证：main.css 200 / 161,960B；16 URL 全 200。）

## 7. 结论

Phase 1 目标"维护者能在本地预览网站全部内容（含出版物列表）"在**机器可查范围内完整达成**：11/11 truths 通过、6/6 禁制未违例、4/4 假设了结（1 个计划内回退）、ENV-01/ENV-02 全覆盖、独立重测证据链完整（含探针与 serve 全流程重建重验）。唯一裁定的字面偏差（T8 livereload 端口迁移）为 Jekyll 4.4.1 版本行为漂移，功能等价成立且已被执行期文档如实披露。整体状态 **human_needed**：待 H1（浏览器自动刷新）与 H2（整体视觉）两项人工确认后即可记 passed；若任一人工项失败则升级为 gaps_found。

---
*Verified: 2026-08-17 by gsd-verifier (independent re-execution: build, probe, serve, edit-probe, git — all fresh evidence, no SUMMARY claims trusted)*
