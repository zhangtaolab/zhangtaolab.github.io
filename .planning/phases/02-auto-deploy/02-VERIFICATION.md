---
phase: 02-auto-deploy
verified: 2026-08-19T04:49:10Z
status: passed
score: 31/31 must-have truths verified (4 roadmap SC + 27 plan truths), 0 gaps
behavior_unverified: 0
overrides_applied: 0
overrides_suggested:

  - must_have: "_includes/head.html contains \"allow_false: true\" (02-01-PLAN artifact literal check)"
    reason: "Literal syntax is Liquid 5.4+ only; locked stack runs liquid-4.0.4 (Jekyll 4.4.1 pins liquid ~> 4.0) where it raises ArgumentError. Equivalent explicit form {% if site.dark_mode == false %}false{% else %}true{% endif %} implemented and machine-proven both directions (override-config build renders 'var darkMode = false;', normal build renders 'var darkMode = true;'). The corresponding truth is VERIFIED; only the plan's literal grep pattern is unmet."
    note: "Pending user acceptance — suggested, NOT applied. Future audits should grep for 'site.dark_mode == false' instead."
requirements: [DEPLOY-01, DEPLOY-02]
prohibitions_reviewed: 4
human_verification:

  - test: "浏览器打开 https://zhangtaolab.org/（连同 /publications/、/news/）做一次目检，确认渲染效果与本地 bundle exec jekyll serve 预览一致"
    expected: "版面正常、出版物 89 条按年份显示、无样式错乱（机器已证部署 HTML 与本地构建逐字节一致，仅 Cloudflare 邮箱混淆注入与构建时间戳不同——此步是 SC4 显示效果的最终视觉确认）"
    why_human: "字节等价是显示等价的充分机器证据，但像素级渲染观感超出 grep/diff 能力；SC4 的『显示效果』字面含视觉成分"

  - test: "裁定 02-REVIEW.md 两个 critical 内容缺陷（均为 Phase-1 内容面、随部署曝光，非本阶段 must_haves 违例）：CR-01 teaching.md 模板占位课程已在线上（Feynman Lectures 等，实测 /teaching/ 命中 2 处）；CR-02 8 条 PDF 链接线上 404（实测 /pdf/2013/PNAS_2013.pdf=404）"
    expected: "人工决策修复或接受（本地预览与线上同样包含该缺陷——部署产物与本地一致，缺陷存在于两侧）；选择修复即走 /gsd-quick 或纳入后续计划"
    why_human: "内容取舍（PI 授课信息、PDF 分发权限）是领域决策；管道本身忠实部署了缺陷内容，无任何机器判据可代替内容审定"

  - test: "确认 4 条 judgment 级 prohibitions 复核结论（见 Prohibitions 表，验证者裁定均为『未违反』）"
    expected: "人工确认或提出异议：①断言四件套未被削弱（WR-03 仅诊断文案死代码，阻断语义完好）；②出版物 89/89 零丢弃；③Ruby 4.0.6/Jekyll 4.4.1 版本组合零漂移；④master 删除发生在新站验证上线 + D-18 批准之后"
    why_human: "judgment 级禁制的最终裁定权属开发者（ADR-550 D4）；验证者结论为非权威 LLM-judge，需人工背书"
re_verification: # no previous VERIFICATION.md existed — initial verification
  previous_status: none
  previous_score: none
  gaps_closed: []
  gaps_remaining: []
  regressions: []
previous_status: none
previous_score: none
gaps_closed: []
gaps_remaining: []
regressions: []
---

# Phase 2: 自动部署 Verification Report

**Phase Goal:** 维护者推送后网站自动上线，跨平台构建一致
**Verified:** 2026-08-19T04:49:10Z
**Status:** `human_needed`（31/31 机器真值全绿、0 缺口；3 项人工确认待决——最终视觉确认、两个已上线内容缺陷裁定、禁制复核背书）
**Re-verification:** No — initial verification

**验证方法声明：** 本验证者未采信任何 SUMMARY 声明。全部结论来自本轮独立实测：本地 fresh production 构建、冒烟正例/反例、dark_mode 双向 override 构建、gemfile 版本钉审计、`gh api`/`gh run view` 远端状态与 4 条 run 记录复查询、CI 日志 Ruby 版本串提取、线上 cache-buster 全电池（含 feed xmllint、sitemap 计数、DOI 锚点）、线上 HTML 与本地构建产物的逐字节 diff。

---

## 0. User Flow Coverage（MVP mode）

ROADMAP 标注本阶段 `Mode: mvp`，但 `user-story.validate` 的正则为英文（`/^As a .+, I want to .+, so that .+\.$/`），对 6 个 PLAN `<objective>` 中的中文用户故事返回 `valid: false` —— 工具语言限制而非格式缺失（Phase 1 验证已确立此先例），本表按语义构建。

| # | 用户故事步骤 | 预期 | 代码库/线上证据（本轮实测） | 状态 |
|---|---|---|---|---|
| 1 | 维护者 push 代码到 GitHub main | Actions 自动触发完整构建（含 jekyll-scholar） | run 32215293379：event=**push**、自动触发、build: success（`gh run view` 复查询）；Smoke assertions 在 CI 侧 PASS（sitemap=11, anchor ok, feed valid, no vendor）；另 run 32212189321（首跑 push）同绿 | ✓ VERIFIED |
| 2 | 构建产物自动发布 Pages | 站点经 Pages 可访问 | run 32215147077 deploy: **success**；pages API `{build_type: workflow, cname: zhangtaolab.org, status: built}`；线上 `/`=200、`/publications/`=200（锚点 s41467-026-73769-8 命中 1）、`/news/`=200、旧路径 `/Publication`=404（判别式成立）；Pages 直连域 301→zhangtaolab.org→200 | ✓ VERIFIED |
| 3 | 本地与 CI 构建一致 | Linux runner 绿 + Ruby 版本一致 | 4 条 run 全绿（ubuntu-latest）；CI 日志原文 `Using 4.0.6 as input from file .ruby-version` + `ruby 4.0.6 (2026-07-14 revision 03b6d3f889) +PRISM [x86_64-linux]`；本地 `.ruby-version`=4.0.6；Gemfile.lock jekyll 4.4.1/jekyll-scholar 7.3.0/liquid 4.0.4、x86_64-linux 条目 ×17；阶段内 Gemfile/Gemfile.lock/.ruby-version 零提交（版本钉零漂移） | ✓ VERIFIED |
| 4 | 推送即自动发布（稳态） | 普通 push 触发 build+deploy 全绿 | run 32215293379（push）deploy: **success**，与设闸前 run 32212189321（push）deploy: **skipped** 形成同工作流同事件对照——D-16 闸门常驻语义双向实证；`gh variable list` 实测 DEPLOY_ENABLED=true | ✓ VERIFIED |

---

## 1. Goal Achievement — Observable Truths

### ROADMAP Success Criteria（合同层，4/4）

| # | Truth | Status | Evidence（验证者独立实测） |
|---|---|---|---|
| SC1 | 维护者推送代码后 Actions 工作流自动触发并完成构建 | ✓ VERIFIED | run 32215293379 event=push、conclusion=success、build: success（`gh run view --json event,conclusion,jobs` 复查询）；自动触发零人工；jekyll-scholar 经 Gemfile `:jekyll_plugins` 组加载，构建含出版物锚点断言 |
| SC2 | 构建产物自动发布到 Pages，站点通过 Pages URL 可访问 | ✓ VERIFIED | run 32215147077 deploy: success（首次部署，04:16Z）；pages API status=built + cname=zhangtaolab.org + build_type=workflow；线上三页 200 + 判别式 200/404；Pages 直连域 `https://zhangtaolab.github.io/` 301 → zhangtaolab.org → 200 |
| SC3 | CI 构建在 Linux runner 上成功，Ruby 版本与本地一致（Gemfile.lock 锁定） | ✓ VERIFIED | 4/4 run 全绿（32212189321 push / 32212517131 dispatch 验证 / 32215147077 部署 / 32215293379 稳态 push）；CI build job 95955560593 日志逐字提取 Ruby 版本串（见上）；`.ruby-version`=4.0.6；`git log 48c0a45..HEAD -- Gemfile Gemfile.lock .ruby-version` 为空（阶段零版本改动）；lock 含 17 条 x86_64-linux 平台条目 |
| SC4 | 站点在线上的显示效果与本地预览一致，出版物列表正常显示 | ✓ VERIFIED（机器等价证明；最终视觉目检 → 人工项 1） | 线上 sitemap.xml 与本地 `_site/sitemap.xml` **逐字节一致**；线上 publications 页与本地构建 HTML **一致**（仅 Cloudflare 邮箱混淆注入 2 行差异——CDN 边缘行为，非构建分叉）；线上 feed.xml 与本地仅 build 时间戳不同；线上出版物条目 **89**（19 年份桶逐桶计数）= 本地 89 = 源 markdown 89 = 审计双侧 89；DOI 锚点线上命中 |

### Plan 01 truths（6/6）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1.1 | production 构建退出 0，五项修复全部落地 | ✓ VERIFIED | 本轮 `rm -rf _site .jekyll-cache && JEKYLL_ENV=production bundle exec jekyll build` exit 0（0.222s）；D-10 vendor exclude（_config.yml:104）+ .gitignore:8 `vendor/`；D-11 8 页翻出黑名单（8 页 `sitemap: false` 零命中，404.md 保留 1）；D-13 allnews 删除；D-14 feed guid |
| 1.2 | sitemap ≥10 `<loc>`（预期 11） | ✓ VERIFIED | 本地实测 **11**；线上实测 **11**；11 URL 逐条列出（8 翻转页 + research/software/team 3 原有）——与 D-11 推导一致 |
| 1.3 | `_site/allnews.html` 不存在、`_site/news/index.html` 存在 | ✓ VERIFIED | 两者实测（前者 No such file，后者存在）；全仓 allnews 引用 grep = **0** |
| 1.4 | feed news 条目唯一 guid + link 指 /news/ | ✓ VERIFIED | 渲染产物 6/6 guid 全唯一（news-1…news-6 + 日期，sort/uniq -c 计数全 1）；item link 全部 `https://zhangtaolab.org/news/` |
| 1.5 | `xmllint --noout _site/feed.xml` 通过 | ✓ VERIFIED | 本地与线上（下载后）均通过，0 错误 |
| 1.6 | dark_mode: false 渲染为 false | ✓ VERIFIED（实现形态偏离计划字面——见 D-12 偏差） | 本轮独立双侧构建证明：override 配置（dark_mode: false）产物含 `var darkMode = false;`；正常构建含 `var darkMode = true;`。实现为 Liquid 4 兼容显式判断（`{% if site.dark_mode == false %}`），计划字面 `allow_false: true` 语法在锁定栈 liquid-4.0.4 下 ArgumentError（Liquid 5.4+ 参数）——语义等价且更强（双侧机器证明 vs 单侧字面 grep） |

### Plan 02 truths（5/5）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 2.1 | ci-smoke.sh 本地正例退出 0 并打印 PASS 行含 sitemap 计数 | ✓ VERIFIED | 本轮实跑：`PASS: sitemap=11, anchor ok, feed valid, no vendor`，exit 0 |
| 2.2 | ci-smoke.sh 对含 vendor 的产物退出非 0（tripwire fail-first） | ✓ VERIFIED | 本轮独立复测：_site 副本造 vendor/ 后脚本退出非 0（TRIPWIRE-OK），临时目录已清理 |
| 2.3 | deploy.yml 合法 YAML + 双闸表达式逐字在位 | ✓ VERIFIED | ruby `YAML.parse_file` 通过；`vars.DEPLOY_ENABLED == 'true' \|\| inputs.deploy == true` 逐字命中（deploy.yml:48） |
| 2.4 | setup-ruby@v1 + bundler-cache + **无** ruby-version 输入；smoke 先于 upload；JEKYLL_ENV=production | ✓ VERIFIED | 文件逐行核对 + ruby 程序化断言 with 块无 ruby-version 键（RUBY-INPUT-OMITTED）；Smoke assertions（:40-43）先于 upload-pages-artifact@v3（:45）；build 步骤 env JEKYLL_ENV: production（:39） |
| 2.5 | 触发面 push[main] + workflow_dispatch typed boolean default false | ✓ VERIFIED | deploy.yml:3-11 逐字核对（type: boolean, default: false） |

### Plan 03 truths（5/5）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 3.1 | 旧站存档在任何远端变更之前入库 | ✓ VERIFIED | 存档 commit a81b576（2026-08-19T09:51:06+08:00 = 01:51Z）早于首次 push 触发的 run 32212189321（03:27:09Z）；存档文件非空且入库（git ls-files 确认） |
| 3.2 | 双侧逐条清单（机器提取建立精确数） | ✓ VERIFIED | pub-extract-new.txt = **89** 行、pub-extract-old.txt = **89** 行（研究期 ~91 对账为 89 顶层 + 2 嵌套子条目，机器提取为准——SUMMARY 决策记录在案） |
| 3.3 | 旧侧每条逐一分类（逐条状态行而非聚合） | ✓ VERIFIED | 审计报告状态行 = **89** = 旧侧清单行数（89 MATCHED + 0 MISSING，逐行正则计数）；round 1 BLOCK（6 MISSING）→ remedy (a) 逐字补录 → round 2 全对齐的轨迹留档 |
| 3.4 | 报告含双侧总数/逐年对照/missing/extra/verdict 五节 | ✓ VERIFIED | 32KB 报告实测含：verdict 机器结论行（:170 conditional-PASS）、轮次轨迹表（:190）、EXTRA 节、逐年对照表 |
| 3.5 | 批准标记 `Verdict: APPROVED <date>` 落盘且恰 1 处 | ✓ VERIFIED | `grep -cF` 实测 = **1**（第 212 行 `Verdict: APPROVED 2026-08-19`，commit 650bd3e）；报告正文标记字面量拆分书写护栏在位（防闸门污染） |

### Plan 04 truths（4/4）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 4.1 | origin 指向 zhangtaolab/zhangtaolab.github.io，push 为新增分支无 force | ✓ VERIFIED | `git remote -v` 实测 SSH remote；refs/heads/main 在远端；master 删除前快照（02-04-SUMMARY `[new branch]` + master/backup 原指 b09c9b31 未动）与当前终态一致 |
| 4.2 | push 触发首跑 build 绿（含 Smoke）、deploy skipped | ✓ VERIFIED | run 32212189321：event=push、conclusion=success、build: success、deploy: **skipped**（`gh run view` 复查询） |
| 4.3 | default_branch=main、build_type=workflow、cname 继承、切换期旧站 200 | ✓ VERIFIED | 当前 API 实测 default_branch=**main**、build_type=**workflow**、cname=**zhangtaolab.org**；切换期零停机由 02-04-SUMMARY 时序证据 + 存档 200 前置支撑（现 /Publication 404 为热切换后预期态） |
| 4.4 | dispatch 验证模式 run build 绿 deploy skipped + 日志含 Ruby 4.0.6 | ✓ VERIFIED | run 32212517131：event=workflow_dispatch、success、build: success、deploy: skipped；Ruby 4.0.6 日志串由验证者从 run 32215293379 build job（95955560593）日志直接提取（同一 workflow 同一步骤），SUMMARY 另记录 04 双 run 各一份 |

### Plan 05 truths（4/4）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 5.1 | DEPLOY_ENABLED 设闸前缺失、仅在用户批准后置 true | ✓ VERIFIED（时序机器支撑） | 变量 created=2026-08-19T04:16:04Z（`gh variable list` 实测）；此前两 run（03:27 push、03:32 dispatch）deploy 均 skipped——闸门在 04:16 前确为关闭的运行时证明；用户批准语料（"approved — deploy"）与 D-18 标记（03:16-03:25Z）均在设闸前落档 |
| 5.2 | 首次部署 run deploy job 绿 + environment 部署成功 | ✓ VERIFIED | run 32215147077：event=workflow_dispatch（deploy=true）、conclusion=success、build: success、deploy: **success**（04:16:15Z 创建）；github-pages deployment id 5975929344（SUMMARY 记录） |
| 5.3 | 判别式：/publications/ 200 且 /Publication 404 | ✓ VERIFIED | 本轮 cache-buster 实测：publications=**200**、Publication=**404**、home/news=200 |
| 5.4 | 后续普通 push 自动触发全绿 run（含 deploy） | ✓ VERIFIED | run 32215293379：event=**push**、success、build: success + deploy: **success**；与 4.2 的 skipped 构成唯一变量=闸门状态的对照实验 |

### Plan 06 truths（3/3）

| # | Truth | Status | Evidence |
|---|---|---|---|
| 6.1 | 远端分支终态恰为 main + backup | ✓ VERIFIED | `git ls-remote --heads origin` 实测恰两条：backup→b09c9b31、main→a22624c（master + 3 dependabot 已删，backup 未触碰） |
| 6.2 | 分支删除不影响线上：关键页 200、feed/sitemap 有效 | ✓ VERIFIED | 删除后（当前）全电池实测：三页 200、feed xmllint 通过、sitemap 11——workflow 模式 Pages 不依赖分支 |
| 6.3 | 终局验收电池全绿 | ✓ VERIFIED | home/publications(+DOI 锚点 1 处)/news 全 200；feed 下载 xmllint 0 错误；sitemap 线上 11 = 本地 11；pages API status=built + cname=zhangtaolab.org |

**Score:** 31/31 truths verified（4 SC + 27 plan truths）；0 present-but-behavior-unverified（全部行为类真值均有验证者独立复查询的 production run/日志/线上实测证据）

---

## 2. Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `_config.yml` | exclude 增 `- vendor` | ✓ VERIFIED | :104 在位（2 空格缩进风格与列表一致） |
| `.gitignore` | `vendor/` | ✓ VERIFIED | :8 在位 |
| `_includes/head.html` | dark_mode 显式 false 判断 | ✓ VERIFIED（字面 `allow_false: true` 有意不满足——D-12 偏差） | Liquid 4 兼容 `{% if site.dark_mode == false %}` 实现，双侧构建语义机器证明；**建议 override**（见 frontmatter overrides_suggested） |
| `feed.xml` | news 条目 guid + /news/ link | ✓ VERIFIED | :29 guid（isPermaLink="false", forloop.index + 日期）；渲染 6/6 唯一 |
| `_pages/allnews.md` | DELETED | ✓ VERIFIED | 文件不存在（工具报 File not found 即删除的预期态）；产物 allnews.html 同缺席；全仓引用 0 |
| `.github/workflows/deploy.yml` | 官方工件模式流水线 + 双闸 | ✓ VERIFIED | gsd-tools verify.artifacts 通过；全部结构断言逐条命中（见 2.3-2.5） |
| `scripts/ci-smoke.sh` | 四断言本地/CI 同源 | ✓ VERIFIED | gsd-tools 通过；bash -n + test -x + 正例绿 + tripwire 反例红 |
| `old-site-publication.html` / `pub-extract-{new,old}.txt` / `02-PUBLICATION-AUDIT.md` | D-18 审计产物 | ✓ VERIFIED | 全部入库（git ls-files）；89/89 行；89 状态行；标记恰 1 |
| `DEPLOY_ENABLED=true`（非文件） | 常驻闸门 | ✓ VERIFIED | `gh variable list` 实测 true（2026-08-19T04:16:04Z） |
| 远端分支布局（非文件） | {main, backup} | ✓ VERIFIED | ls-remote 实测 |

## 3. Key Link Verification

gsd-tools verify.key-links 因 from 字段为描述性文字（非文件路径）无法程序化解析（工具限制，非接线失败）；以下全部人工验证。

| From | To | Via | Status | Details |
|---|---|---|---|---|
| deploy.yml build job | scripts/ci-smoke.sh | Smoke 步骤（:43）先于 upload（:45） | ✓ WIRED | 4/4 CI run 的 Smoke assertions 步骤实际执行并 PASS——生产级接线证明 |
| deploy.yml setup-ruby step | .ruby-version | 省略输入自动读取 | ✓ WIRED | CI 日志原文 `Using 4.0.6 as input from file .ruby-version` |
| deploy job if 条件 | 仓库变量 DEPLOY_ENABLED | 双闸 kill-switch | ✓ WIRED | skipped（32212189321）vs success（32215293379）同事件对照实证 |
| feed.xml news loop | _data/news.yml | forloop.index + article_date 构建 guid | ✓ WIRED | feed.xml:29 源码 + 渲染产物 news-1…news-6 唯一性实证 |
| 8 翻转页 frontmatter | jekyll-sitemap 生成 | 移除排除键 | ✓ WIRED | sitemap 11 URL 逐条列出，8 翻转页全在 |
| push（本地 main → origin/main） | Actions 迦行时 | on.push 触发 | ✓ WIRED | run 32215293379 event=push 自动触发实证 |
| 审计报告 → Plan 05/06 前置 | Verdict: APPROVED 标记 | grep -F 机器断言 | ✓ WIRED | 标记恰 1 处（:212），下游前置可过且无闸门污染 |

## 4. Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| _site/publications/index.html | 89 条出版物 | _pages/publications.md 手写列表（非 ref.bib——语料纠偏在案） | 线上 89 = 本地 89 = 源 89 | ✓ FLOWING |
| _site/feed.xml | 6 条 news | _data/news.yml | guid/pubDate 实数据渲染 | ✓ FLOWING |
| _site/sitemap.xml | 11 URL | jekyll-sitemap 插件扫描 _pages | 线上与本地逐字节一致 | ✓ FLOWING |
| 线上站点整体 | 部署产物 | run 32215293379 构建的 github-pages artifact | 线上 HTML 与本地构建仅差 Cloudflare 邮箱混淆注入（CDN 行为）+ feed 构建时间戳 | ✓ FLOWING |

无任何值终止于静态返回/硬编码/mock。

## 5. Behavioral Spot-Checks（全部为本轮验证者实测）

| Behavior | Command | Result | Status |
|---|---|---|---|
| production 构建 | `rm -rf _site .jekyll-cache && JEKYLL_ENV=production bundle exec jekyll build` | exit 0（0.222s） | ✓ PASS |
| 冒烟正例 | `scripts/ci-smoke.sh _site` | `PASS: sitemap=11, anchor ok, feed valid, no vendor` | ✓ PASS |
| tripwire 反例 | 副本 + vendor/ → ci-smoke.sh | 退出非 0（TRIPWIRE-OK） | ✓ PASS |
| D-12 语义 | override 配置构建 vs 正常构建 | `var darkMode = false;` / `var darkMode = true;` | ✓ PASS |
| deploy.yml 结构 | ruby YAML 解析 + with 块断言 | YAML-OK + RUBY-INPUT-OMITTED | ✓ PASS |
| 四条关键 run | `gh run view --json event,conclusion,jobs` | push/dispatch×2 结论与 job 级 skipped/success 全部与闸门语义矩阵一致 | ✓ PASS |
| CI Ruby 版本 | build job 95955560593 日志提取 | `ruby 4.0.6 … [x86_64-linux]` + `input from file .ruby-version` | ✓ PASS |
| 线上判别式 | cache-buster curl | publications=200、Publication=404 | ✓ PASS |
| 线上验收电池 | 三页 200 + 锚点 + feed xmllint + sitemap 计数 + pages API | 全绿（11/11/11 三方同值） | ✓ PASS |
| 线上=本地等价 | diff 线上下载 vs _site 产物 | sitemap 逐字节一致；publications 仅 CDN 邮箱混淆 2 行；feed 仅时间戳 | ✓ PASS |
| 出版物计数链 | 源 md / 本地 HTML / 线上 HTML 逐年桶计数 | 89 = 89 = 89（19 年份桶） | ✓ PASS |

## 6. Probe Execution

本阶段无 `scripts/*/tests/probe-*.sh` 形态的 probe；其断言面由 `scripts/ci-smoke.sh` 承担并已在 CI 4 run + 本轮本地双例（正例/反例）中执行——见 §5。无 MISSING_PROBE。

## 7. Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| DEPLOY-01 | 01/02/03/04/05/06 | push 后 Actions 完整构建（含 jekyll-scholar）并发布 Pages，站点可访问 | ✓ SATISFIED | SC1+SC2+SC4：run 32215293379 push 全绿 + run 32215147077 部署 + 线上判别式/锚点/pages built；出版物 89/89 零丢弃（D-18 审计批准） |
| DEPLOY-02 | 02/04/06 | Linux runner 绿 + Gemfile.lock 跨平台条目 + Ruby 版本一致 | ✓ SATISFIED | SC3：4 run 绿、CI 日志 4.0.6 串、.ruby-version 事实源、17 条 linux 平台条目、版本钉零提交 |

REQUIREMENTS.md 追溯表映射到 Phase 2 的 ID 恰为 DEPLOY-01/DEPLOY-02，全部被 PLAN frontmatter 声明并闭环；**无缺失 ID、无孤儿 requirement**（CONTENT-01 属 Phase 3，正确未计入）。

## 8. Prohibitions（4 条 judgment 级——验证者裁定均未违反，待人工背书）

| Plan | Statement | 验证者裁定 | 证据 |
|---|---|---|---|
| 02 | 不得削弱/绕过/删除四条冒烟断言 | **未违反** | 四断言逐条在位且 exit 1 语义完好；tripwire 本轮 fail-first 复证有牙；WR-03 仅 sitemap 零值场景诊断文案不打印（`set -e` 先中止），**阻断行为不受影响**——质量 nit 非削弱 |
| 03 | 迁移/部署不得丢弃任何旧站出版物条目 | **未违反** | round 2 89/89 全 MATCHED、MISSING=0；线上 89 条实测；6 条曾缺已按 remedy (a) 逐字补录（零豁免）；2 条嵌套 Commentary 注记经用户决定接受不迁移（非顶层条目，留档在案） |
| 04 | 不得改 Ruby 4.0.6 / Jekyll 4.4.1 锁定组合自救 | **未违反** | `git log 48c0a45..HEAD -- Gemfile Gemfile.lock .ruby-version` 为空；lock 仍 jekyll 4.4.1/scholar 7.3.0/liquid 4.0.4；CI 绿跑证明无需漂移 |
| 06 | 不得在新站验证上线 + D-18 通过前删 master；backup 永不触碰 | **未违反**（终态 + 时序证据支撑） | 删除前置四断言（live 200 / 标记恰 1 / backup 在位 / build_type=workflow）在 02-06 verify 链中先于删除；时序：热切换确认 04:17Z → 删除 ~04:2xZ；终态 backup→b09c9b31 与本地克隆双保险实测在位 |

## 9. Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| （全部 16 个阶段改动文件） | — | TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER | — | **0 命中**（无阻断项） |
| _pages/teaching.md | 11-14 | 模板占位课程（Feynman Lectures 等）**已上线** | ⚠️ Warning（CR-01，Phase-1 内容面，非本阶段 must_haves 违例） | 线上 /teaching/ 实测命中；本地与线上同样包含（部署忠实）→ 人工裁定项 2 |
| _pages/publications.md | 166-206 | 8 条 PDF 链接线上 404 | ⚠️ Warning（CR-02，同上） | 实测 /pdf/2013/PNAS_2013.pdf=404；仓库零 PDF 文件 → 人工裁定项 2 |
| _config.yml | 93-104 | `scripts/` 未 exclude，ci-smoke.sh 公开可下载（实测 /scripts/ci-smoke.sh=200） | ⚠️ Warning（WR-02） | 信息暴露面 nit；不影响功能 |
| scripts/ci-smoke.sh | 8-9 | sitemap 零值/缺失场景 FAIL 诊断不打印（set -e 先中止） | ⚠️ Warning（WR-03） | 阻断语义完好，仅未来排障体验 |
| _config.yml:8 / head.html | — | photo 指向不存在文件 → 全站无 og:image（WR-01）；description 未转义（WR-04） | ℹ️ Info | 内容质量备查 |

**债务标记闸门：0 命中，无阻断。** CR-01/CR-02 为 Phase-1 范围内容缺陷被部署曝光——部署产物与本地预览一致（缺陷存在于两侧），不构成 Phase 2 任何 must-have 失败；已列入人工裁定。

## 10. Human Verification Required（3 项）

### 1. 线上显示效果最终目检（SC4 收尾）

**Test:** 浏览器打开 https://zhangtaolab.org/（连同 /publications/、/news/），与本地 `bundle exec jekyll serve` 预览对照。
**Expected:** 版面正常、89 条出版物按年份渲染、无样式错乱。机器已证线上 HTML 与本地构建逐字节一致（仅 Cloudflare 邮箱混淆与构建时间戳差异），本步为视觉终验。
**Why human:** 字节等价是显示等价的充分机器证据，但"显示效果"字面含视觉成分，像素级观感超出 diff 能力。

### 2. 已上线内容缺陷裁定（CR-01/CR-02 — Phase-1 内容面，随部署曝光）

**Test:** 审阅 02-REVIEW.md CR-01（/teaching/ 模板占位课程已公开）与 CR-02（8 条 PDF 链接 404），决定修复或接受。
**Expected:** 人工二选一；修复走 /gsd-quick 或纳入后续计划（若删 teaching 页，sitemap 阈值 ≥10 仍过——剩 10 URL）。
**Why human:** 内容取舍（PI 授课信息、PDF 分发权限）是领域决策；管道忠实部署了缺陷内容，机器无判据替代审定。

### 3. 四条 judgment 级禁制的复核背书

**Test:** 确认 §8 表中 4 条禁制的验证者裁定（均"未违反"）。
**Expected:** 人工背书或提出异议（重点可抽查：WR-03 是否视为断言削弱——验证者意见：否，阻断语义完好）。
**Why human:** judgment 级禁制最终裁定权属开发者（ADR-550 D4）；LLM-judge 结论为非权威。

## 11. Gaps Summary

**机器范围内 0 缺口。** 阶段目标"维护者推送后网站自动上线，跨平台构建一致"的全部可观测真值（4 条 ROADMAP 成功标准 + 27 条 plan truths）均经本轮独立实测证实：push 自动触发并全绿构建（run 32215293379）、产物经 Pages 发布且双域可访问（判别式 200/404 + pages API built）、Linux×Ruby 4.0.6 跨平台一致（CI 日志原文 + 版本钉零漂移）、线上与本地逐字节等价且出版物 89/89 零丢失。D-16 闸门常驻语义经同事件 skipped→success 对照实证。唯一计划字面偏离（D-12 `allow_false` 语法）以更强的双侧构建语义证明替代，已列 override 建议。整体状态 `human_needed` 而非 `passed`，仅因 3 项人工确认（视觉终验 + 两个 Phase-1 内容缺陷裁定 + 禁制背书）——若目检失败或缺陷裁定要求整改，升级为 gaps_found 重开。

**运维语义备注：** 本地 main 领先 origin/main 3 个 docs 提交（.planning 规划工件，不进站点产物）——下次 push 将随稳态管道自动部署，属预期稳态行为，非缺口。

---

_Verified: 2026-08-19T04:49:10Z_
_Verifier: Claude (gsd-verifier)（独立实测：fresh build、冒烟正反例、dark_mode 双向构建、4 run 复查询、CI 日志提取、线上 cache-buster 全电池、线上-本地逐字节 diff、分支/变量/Pages API 远端状态——未采信任何 SUMMARY 声明）_
