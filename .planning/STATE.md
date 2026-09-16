---
gsd_state_version: "1.0"
milestone: v1.0
current_phase: 3
current_phase_name: 内容验证
status: executing
stopped_at: "Completed quick task 260916-p4i（SW-DEL-02 /software/ 删 PDLLMs 卡——与 /models/ 卡重复：_pages/software.md 纯删除 15 行〔空行+14 行 section-card 块，h4/GitHub+Paper 按钮 DOI 10.1016/j.molp.2024.12.006/描述/Citation/占位缩略图〕，镜像 260827-lwq 流程；live /software/ PDLLMs 2→0、software-card 7→6、DOI 1→0、哨兵 dnallmmark/CrisprStitch/rustkmer 在；源 0 PDLLMs、div 计数 6/6、137→122 行；search.json 按 entry 作用域 /software/ 条目净、/models/ 条目保留；validate/ci-smoke 绿 sitemap=11；numstat 0/15 恰 1 路径 1 commit de10963c 本地未推送）"
last_updated: "2026-09-16T10:09:24Z"
state_head: de10963c4e1b8bdeb277ce9fe0acb48547ab60dd
progress:
  total_phases: 3
  completed_phases: 2
  total_plans: 12
  completed_plans: 12
milestone_name: milestone
---

# 项目状态：Zhang Tao Lab 主页（全新版本）

**Updated:** 2026-08-20 after 03-03 gap closure（层①③ 抗崩收口 + WR-01/WR-02 + IN-01/IN-03；Phase 3 计划 3/3 完成，待 verify-work 人工确认面）

## Project Reference

**Core Value:** 维护者能低成本地更新网站内容（论文/新闻/成员/页面），本地预览确认后推送即自动发布。

**Current Focus:** Phase 3 — 内容验证

## Current Position

**Phase:** 3 (内容验证) — 全计划执行完毕，待阶段验证
**Plan:** 3 of 3（03-03 gap closure 已完成；03-VERIFICATION 两 critical gap 收口，待重验）
**Status:** Awaiting /gsd-verify-work 3（人工确认面：probe 覆盖充分性 / P-03 prohibitions 背书 / safe_load 接受面裁定 / D-08 文案目检）
**Progress Bar:** ▰▰▰▰▰▰▰▱▱▱ 67%（2/3 阶段——Phase 3 经 verify-work 结项后转 3/3）

## Performance Metrics

**里程碑进度:** v1 - 环境跑通 + 自动部署上线
**阶段进度:** Phase 1 ✓ 完成（3 轮验证/UAT 闭环：验证 32/32 机器真值 passed + UAT 7/7 + 安全 0 开放威胁 + 代码评审 1C/6W/10I 已决策处置）；Phase 2 ✓ 完成（6/6 plans：02-01 评审修复 / 02-02 CI 工件 / 02-03 D-18 出版物审计 89/89 批准 / 02-04 原地接管 D-15①~④ 双 run 绿 / 02-05 首次上线热切换 / 02-06 清理收尾〔删 master + dependabot，终态 {backup, main}〕；验证 31/31 机器真值 + UAT 3/3 全过——favicon G-02-1 quick fix 线上字节级复核、CR-01/CR-02 内容欠账裁定接受（素材后补，见 02-UAT.md Deferred Follow-Ups）、4 条 prohibitions 人工背书；verification passed + 安全 0 开放威胁）；Phase 3 待规划
**需求覆盖:** 5/5 需求已映射到路线图（100%）；Phase 1 覆盖 ENV-01、ENV-02（2/2）；Phase 2 全结项——DEPLOY-02（02-04 Linux 绿跑 ×2 + Ruby 4.0.6 一致）+ DEPLOY-01（02-05 push→自动构建→发布→线上可访问端到端证明）
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 1 P01 | 19 min | 4 tasks | 465 files |
| Phase 01 P02 | 8min | 7 tasks | 12 files |
| Phase 02 P01 | 5min | 3 tasks | 13 files |
| Phase 02 P02 | 2min | 2 tasks | 2 files |
| Phase 02 P03 | 70min | 3 tasks | 11 files |
| Phase 02 P04 | 10min | 3 tasks | 0 files |
| Phase 02 P05 | 7min | 3 tasks | 0 files |
| Phase 02 P06 | 7min | 2 tasks | 0 files |
| Phase 03 P01 | 10min | 3 tasks | 2 files |
| Phase 03 P02 | 16min | 3 tasks | 3 files |
| Phase 03 P03 | 16min | 2 tasks | 1 files |

## Accumulated Context

### 关键决策点（已决策）

**Ruby/Jekyll 版本兼容性（2026-08-17 已决策）：**

- **生效级别：Step 0 → Step A（用户指令后置升级）** — Task 1 实测 Step 0（Jekyll 4.3.3）已达成绿色构建；随后用户指令（2026-08-17：「根据Github 的要求，建议使用新版本的软件和软件包」）要求采用较新版本，故后置应用 Step A：Gemfile `gem "jekyll"` 钉改为 `~> 4.4.0`，未动用 Step B（系统级 ruby@3.4）
- **最终组合：** Ruby 4.0.6（Homebrew，`/opt/homebrew/bin/ruby`）+ Bundler 4.0.16 + Jekyll **4.4.1**（Gemfile `~> 4.4.0`，resolver 取最新 4.4.x）
- **理由：** GitHub 版本支持要求优先；`bundle install` 与 `bundle exec jekyll build` 在 Jekyll 4.4.1 下均退出码 0，无需放宽 `sass-embedded ~> 1.77.0` 钉、无需钉 jekyll-scholar/jekyll-sitemap（resolver-latest 即兼容）
- **配套补偿（达成绿色构建所需）：** ① jekyll-scholar/jekyll-sitemap 移入 Gemfile `:jekyll_plugins` group（否则插件不加载）；② `scholar.style: citesty → apa`（磁盘无 citesty.csl，citeproc 解析失败）；③ `feed.xml` 对 `_data/news.yml` 展示性日期标签 "Latest" 回退 `site.time`（原文对不可解析日期直接过滤引发构建失败）
- **Gemfile.lock 已生成：** jekyll 4.4.1 / jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 / sass-embedded 1.77.8（钉保留，压制 Bootstrap 告警）
- **剩余风险：** Ruby 4.0.6 超出 Jekyll 4.4.1 官方支持范围（≤3.3.x），属"实测可用"而非"官方支持"；Phase 2 CI 需钉 Ruby 4.0.6 + Jekyll 4.4.1 复现本机组合（`.ruby-version` 已入库作为事实源）；已知无害告警：`assets/main.css` 与 `assets/main.scss` 输出目标冲突（静态快照 161,960 字节胜出，>1000 字节，不影响验收）；**Jekyll 4.4 行为变化：** livereload.js 改由专用 reload 服务器在 `127.0.0.1:35729` 提供（4.3.3 时经主服务 4000 端口提供），页面注入的 loader 已适配，实测 35729 端点返回 200、编辑探针 ≤10s 生效

### 已确认约束

- **部署方式：** 必须使用 GitHub Actions 自定义构建（jekyll-scholar 不在 Pages 插件白名单）
- **技术栈：** 保持 Jekyll + 现有插件体系（大版本已完成，不做框架重写）
- **域名：** 沿用 zhangtaolab.org，`baseurl` 保持为空
- **仓库：** 全新 git 历史（旧仓库抛弃）

### 已排除范围（v1 不做）

- DNS/HTTPS 配置操作（用户自行在 GitHub 后台配置）
- PR 预览部署（单人维护场景用不到）
- 视觉改版/重新设计（大版本界面已完成）
- 多语言/中文版站点（暂无 i18n 需求）

### 待确认项

- 本地内容已与 reference-snapshot 对齐（团队/新闻/首页/研究/软件/关于），publications 83 条未动；2026-08-18 Round 3：research/software 版式经 03-PLAN 重排后与参考站视觉一致（UAT 测试 6 用户确认），全站 0 转义
- **已知空态（2026-08-17，Phase 1 Task 2 实测）：** `papers/ref.bib` 无 @incollection 条目，`/talks/` 页两个 `{% bibliography --query @incollection[...] %}` 查询渲染为空列表（页面仍 200、标题"Invited Talks / Regular Talks"仍在）；真实 talks 数据属内容补全工作，不在本阶段。同类内容欠账：`_pages/teaching.md` 正文仍含 Feynman 模板演示教学条目（非文献链路，属页面内容补全）
- GitHub Actions 工作流具体实现细节
- YAML/BibTeX 验证工具选型
- **Phase 2 前置关注（2026-08-18 第三轮代码评审，01-REVIEW.md）：** ① `_config.yml` exclude 缺 `vendor`（CI bundle install 会把 gem 树带进构建产物）；② sitemap.xml 仅 3 URL（多数页 `sitemap: false` 漂移，robots.txt 却在广播 sitemap）；③ `head.html` `dark_mode | default: true` 使 `dark_mode: false` 失效（Liquid default 不判 false）；④ /news/ 与 /allnews.html 双页并存且 sidebar/feed 链接各指一处；⑤ RSS 条目共享 link 且无 guid（WR-01，未修——本轮仅修了 title/description 转义）

## Session Continuity

**Last session:** 2026-09-16T10:09:24Z
**Stopped at:** Completed quick task 260916-p4i（SW-DEL-02 /software/ 删 PDLLMs 卡——与 /models/ 卡重复：_pages/software.md 纯删除 15 行〔空行+14 行 section-card 块，h4/GitHub+Paper 按钮 DOI 10.1016/j.molp.2024.12.006/描述/Citation/占位缩略图〕，镜像 260827-lwq 流程；live /software/ PDLLMs 2→0、software-card 7→6、DOI 1→0、哨兵 dnallmmark/CrisprStitch/rustkmer 在；源 0 PDLLMs、div 计数 6/6、137→122 行；search.json 按 entry 作用域 /software/ 条目净、/models/ 条目保留；validate/ci-smoke 绿 sitemap=11；numstat 0/15 恰 1 路径 1 commit de10963c 本地未推送）
**Resume file:** None

**Last action:** Phase 2 验证/UAT 闭环结项 — Test 1 favicon 缺陷（G-02-1）修复随 push 36d23d5f 部署（run 32322876555 success）后线上字节级复核通过（favicon.ico = 旧站真图标 5430B、rel=icon → /images/logo.png、模板 favicon.svg 404）；Test 2 CR-01/CR-02 内容欠账用户裁定暂时接受（素材后补，见 02-UAT.md Deferred Follow-Ups）；Test 3 四条 prohibitions 人工背书成立；UAT 3/3 → verification 收编 passed → phase.complete 结项（6/6 plans）
**Next action:** Phase 3（内容验证，CONTENT-01 — 维护者更新内容时语法错误被拦截，避免静默失败）规划：/gsd-discuss-phase 3
**Blockers:** 无
**Relocation:** 项目已从 `/Users/forrest/Playground/zhangtaolab-jekyll` 整体搬迁至 `/Users/forrest/GitHub/zhangtaolab.github.io`（2026-08-18）；origin=zhangtaolab/zhangtaolab.github.io（SSH），default_branch=main，Pages build_type=workflow，旧站留底：远端 backup 分支 + 本地克隆 `~/GitHub/zhangtaolab.github.io-legacy-backup`
**Notes:** 这是一个 brownfield 项目，现有代码已完成开发。v1 重点是让新版本在本地可测试、内容可日常更新、推送后自动部署上线。

---
*State initialized: 2026-08-17*

## Decisions

- [Phase 1]: Ruby/Jekyll 版本决策（Phase 1 Task 1）：生效级别 Step 0 → Step A（用户指令后置升级）— Ruby 4.0.6 + Jekyll 4.4.1 实测可构建；jekyll-scholar 7.3.0 / jekyll-sitemap 1.4.0 锁入 Gemfile.lock，.ruby-version 入库作为 Phase 2 CI 事实源 — Step 0 先证绿色构建，后按用户指令（GitHub 版本支持要求）升级至 `~> 4.4.0`（resolver 取 4.4.1），bundle install 与 jekyll build 均退出码 0；剩余风险：Ruby 4.0.6 超出 Jekyll 官方支持范围，属实测可用；livereload.js 端点随 4.4 移至 127.0.0.1:35729
- [Phase ?]: Reference snapshot is content authority; its template defects ({title} placeholder, flat .html links, CDN fonts) deliberately not adopted (1-02)
- [Phase ?]: kramdown G-1-3 prevention pattern: column-0 flattened HTML + markdown="0" wrappers; assertable via grep -En '^ {4,}.*<' (1-02)
- [Phase ?]: Meta image tags existence-guarded via site.static_files instead of editing _config.yml (1-02)
- [Phase ?]: Phase 2 P01: Liquid allow_false 参数系 5.4+ 专属，锁定栈（Jekyll 4.4.1→liquid-4.0.4）下 default 过滤器只收 1..2 参数直接 ArgumentError；dark_mode 改用显式 {% if site.dark_mode == false %} 判断（D-12 决策原文形态），双侧 override 构建机器证明 true/false 各自正确渲染
- [Phase ?]: Phase 2 P01: sitemap.xml 实测 3→11 URL（8 翻转 + research/software/team），Plan 02 ci-smoke 断言面用 ≥10 阈值防脆断；DEPLOY-01 系阶段级需求，P01 仅落地部署前评审修复，requirements.mark-complete 留给真正交付部署的 plan 执行
- [Phase ?]: Phase 2 P02: 冒烟断言先于 upload-pages-artifact（断言红则无工件可部署），runner 需 apt libxml2-utils；setup-ruby@v1 省略 ruby-version 输入使 .ruby-version(4.0.6) 成为本地/CI 版本单一事实源；D-16 双闸表达式与 D-09 验证模式（deploy 默认 false）一体落地，首次 push main 自动回退验证模式
- [Phase ?]: Phase 2 P03: D-18 出版物审计闭环——round 1 BLOCK（6 MISSING）→ 用户 remedy (a) 逐字补录（66a5adf，83→89 重编号）→ round 2 全对齐 89/89（88 精确 + 1 NFKC 连字 2024 Zheng XL）→ 用户 2026-08-19 approved，标记行入库（650bd3e，grep 计数恰 1）；2013 PNAS CentO 嵌套评述经用户决定不迁移；~91 对账为 89 顶层 + 2 嵌套
- [Phase ?]: Phase 2 P03: 闸门标记拆分书写护栏——审计报告正文绝不出现批准标记完整字面量（round 1 曾在豁免选项正文完整引用，属 Plan 06 grep 假阳性污染隐患，round 2 生成器修正）；标记行只由 executor 在用户批准后追加，DEPLOY-01 结项留给线上锚点证明（02-05/06）
- [Phase ?]: Phase 2 P04: D-15①~④ 原地接管零停机完成——push main（新增分支，master/backup 未动 b09c9b31）→ default_branch=main → Pages build_type=workflow（cname zhangtaolab.org 继承、域名验证字段 null 未回退、旧站持续 200）；首跑 32212189321 + 验证模式 32212517131 双绿（build 绿含 Smoke PASS: sitemap=11、deploy skipped），DEPLOY_ENABLED 全程未设
- [Phase ?]: Phase 2 P04: DEPLOY-02 结项（Linux 绿跑 ×2 + setup-ruby 读 .ruby-version=4.0.6 与本地一致 + 版本组合未动）；DEPLOY-01 刻意留待 02-05/06 线上锚点证明（触发链已证实，站点尚未部署）
- [Phase ?]: Phase 2 P05: 首次上线热切换完成——用户批准后设 DEPLOY_ENABLED=true (04:16:04Z) → dispatch run 32215147077 build+deploy 双绿 (deployment 5975929344) → 判别式首查即 SWITCHED (/publications/ 200 + /Publication 404, cache-buster 强制回源即时权威) → push run 32215293379 deploy 由 skipped 变 success, D-16 常驻闸门实证; DEPLOY-01 端到端结项
- [Phase ?]: Phase 2 P05: 闸门运维语义——此后 push main 即自动上线; 暂停发布删 DEPLOY_ENABLED 变量即可 (build 仍跑, 验证模式回退); master/backup b09c9b31 与 3 dependabot 分支未动, 删除属 Plan 06
- [Phase ?]: Phase 2 P06: D-15⑥/D-17 完结——四机器前置断言全绿（线上 200 / 审计 Verdict: APPROVED 精确 grep 命中恰 1 / backup 在位 / build_type=workflow）后删 master + 3 dependabot 分支，终态经 git ls-remote 与 gh api 双源确证恰为 {backup, main}，回滚双保险（远端 backup b09c9b31 + 本地克隆）复核在位
- [Phase ?]: Phase 2 P06: 终局验收电池全绿，四条成功标准逐条落证——push 自动触发 run 32215293379、线上 home/publications(DOI 锚点)/news 200、CI Ruby 4.0.6 日志逐字对齐 .ruby-version、feed xmllint 过 + sitemap 线上=本地=CI 冒烟三方同值 11、Pages API built+cname；分支删除对线上零影响（T-02-14 实证）
- [Phase 3]: Phase 3 P01: 内容验证引擎落地——validate.rb 五层校验（YAML 语法+结构 / BibTeX 解析+必填+键唯一）单 errors 数组非 fail-fast 全收集，中文报错定位文件/行列/条目/引用键；validate.sh exec 透传 0.17s；BibTeX 查重只在原始文本正则 tally（解析器静默改名 k,k,k→k,l,m）；基线全绿（8/12 条无 doi 通过，DOI 非必填）
- [Phase 3]: Phase 3 P02: CI 双入口收口——deploy.yml 插入 Validate content 步骤（Setup Pages 后、Build with Jekyll 前，字面量命令零内联表达式），同一 validate.rb 本地/CI 两处复用；红证提交 a4e8096c 端到端证明拦截语义（run 32329006888 恰在验证步骤红、零新 deployment、线上 200 保持旧版），revert 71dcea14 复绿 + 新 deployment 5995351307
- [Phase 3]: Phase 3 P02: D-08 提醒层落地——git show HEAD 与工作区 ref.bib 原始文本条目计数对比（不依赖 BibTeX 解析），不等输出中文提醒（publications.md 字样）但退出码零影响；guard 失败静默跳过；CI fetch-depth 1 天然静默零特判
- [Phase 03]: Phase 3 P03: gap closure 收口——validate.rb 层① 换 Psych.safe_load(permitted_classes: [Date], aliases: true) 四级 rescue、层③ raw 单次读入 + valid_encoding? 预检三级 rescue、ROOT = __dir__ 锚定全部 File I/O（WR-01/WR-02 + CR-01/CR-02 四类崩溃输入翻绿中文全收集）；YAML_FILES 值/BIB_PATH 保持仓库相对（D-07 消息字面量 + D-08 git spec 双用途）
- [Phase 03]: Phase 3 P03: 层⑥ D-08 工作区计数 guard 扩为 raw 存在且 valid_encoding?——对无效编码字节串做正则 scan 本身抛 ArgumentError（执行器实测三类正则全抛，计划原 nil-guard 不足）；编码错误已由层③中文报出，guard 静默跳过沿用 A1 兜底
- [Phase 03]: Phase 3 P03: IN-01 正则同源化（层⑤提键与层⑥计数共享 opener 子模式 @\s*[a-zA-Z]\w*\s*\{）——空格形态 @article {key, 重复键进入 tally（bibtex-ruby 解析后静默改名，原始文本唯一真相源）；基线计数 12/12 不变，只放宽看得见什么、不收紧什么合法（P-03-2）

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260819-kvb | Fix WR-01: site og:image — use existing logo.png | 2026-08-19 | 2e20772 | [260819-kvb-fix-wr-01-site-og-image-use-existing-log](./quick/260819-kvb-fix-wr-01-site-og-image-use-existing-log/) |
| 260827-f7z | BIB-01: volume/issue info for bao2026oryza (17:6877) + he2026trna (44(8):2446–2471) — ref.bib + publications.md (page is hand-curated markdown, plan assumption corrected) | 2026-08-27 | 8df20a2f | [260827-f7z-update-volume-issue-info-for-two-publish](./quick/260827-f7z-update-volume-issue-info-for-two-publish/) |
| 260827-jvt | BIB-02: remove DOI placeholders from bao2026oryza + he2026trna — publications.md trailing suffixes + ref.bib doi fields (title hrefs retained, ci-smoke ② green; liao2026glycosylase/zheng2025larch placeholders kept, volume pending) | 2026-08-27 | 772d23c5 | [260827-jvt-remove-doi-placeholders-from-two-entries](./quick/260827-jvt-remove-doi-placeholders-from-two-entries/) |
| 260827-lwq | SW-DEL-01: remove MambaForSequenceClassification card from _pages/software.md — pure 13-line deletion (blank + 12-line section-card block); 7 sibling cards + shared style block untouched; live page/index.html/search.json all drop the title; validate.sh + ci-smoke green | 2026-08-27 | 335eb74c | [260827-lwq-delete-mambaforsequenceclassification-so](./quick/260827-lwq-delete-mambaforsequenceclassification-so/) |
| 260827-u7s | SW-FIX-01: fix wrong Paper link on PDLLMs card in _pages/software.md — line 50 href swapped from pubmed PMID 39733335 (unrelated paper) to Molecular Plant fulltext S1674-2052(24)00390-3 (byte-identical to publications.md entry #6, parentheses unencoded); CrisprStitch/Chorus2 links untouched; numstat 1/1 one file; live page + index.html flip old-PMID 1→0, search.json stays 0; validate.sh + ci-smoke green | 2026-08-27 | a6d140fb | [260827-u7s-fix-wrong-paper-link-on-pdllms-card-in-p](./quick/260827-u7s-fix-wrong-paper-link-on-pdllms-card-in-p/) |
| 260827-uf8 | SW-FIX-02: switch PDLLMs card Paper link to DOI in _pages/software.md — line 50 href swapped from cell.com fulltext S1674-2052(24)00390-3 (u7s 遗留) to canonical DOI https://doi.org/10.1016/j.molp.2024.12.006（验证自 PMID 39659015 / Crossref，即卡片所示引用）；CrisprStitch/Chorus2 链接与 publications.md entry #6（保留 cell.com 标题链接）未动；numstat 1/1 一文件；live page + index.html 同步翻转 cell.com 1→0 / DOI 0→1，search.json 保持 0；validate.sh + ci-smoke 绿 | 2026-08-27 | c052f229 | [260827-uf8-switch-pdllms-paper-link-on-software-pag](./quick/260827-uf8-switch-pdllms-paper-link-on-software-pag/) |
| 260915-k1b | NAV-01: 导航重排 About 收尾 + Contact 并页 — _config.yml nav_pages 7→6（research/publications/software/team/news/about，header.html/404.md 未动自动继承）；about.md 58→118 行并入 Contact 全节（Laboratory Address/Join the Lab/Links/地图，逐字复制保 G-1-3 column-0 模式，style 规则不重复）；contact.md 69→16 行重定向 stub（无 title/layout，meta refresh 0s + canonical → /about/，sitemap:false 出 sitemap、无 title 出搜索索引，sitemap 11→10、search 11→10）；team.md "Contact us!" 改指 /about/；Rule 1 修复：stub DOCTYPE 行被 kramdown 转义成可见文本 → 换成 robots noindex meta（16 行形状与全部断言保持）；validate.sh + ci-smoke（PASS sitemap=10）绿；4 文件 1 commit 本地未推送 | 2026-09-15 | 86021023 | [260915-k1b-nav-reorder-about-last-contact-removed-m](./quick/260915-k1b-nav-reorder-about-last-contact-removed-m/) |
| 260916-c21 | MODELS-01: 新增 /models/ 模型库页 — _data/models.yml（NEW，2 条目注册表带 schema 注释：PlantHelixSeek featured·"Foundation Model · MoE"·specs 4 键·8 tasks·links 恰 github/huggingface/modelscope 无 paper（投稿中）；PDLLMs — Plant DNA Large Language Models·Model Suite·links 恰 github/docs/demo/paper）+ _pages/models.md（NEW，gridlay，G-1-3 column-0 + markdown="0"，复用 software.md 卡片解剖与页内 style 块逐字复制，6 条件按钮固定序 github/huggingface/modelscope/docs/demo/paper，hugging face 用 academicons ai ai-hugging-face；More models 行 Plant DNAGemma·DNAGPT·DNAMamba·CrossDNA 全链 DNALLM 文档；收尾 dnallm callout 含 pip install dnallm CTA）+ _config.yml nav_pages 6→7（models 居 software/team 间，header.html/404.md 未动自动继承）；sitemap 10→11、search 10→11、8 锚点导航含 Models；Rule 1 偏差：Task 2 href 允许清单门按原文全页匹配误伤 head/footer 共享外链 → 收窄至内容区后零命中（与 software 页 chrome 逐字一致，新增仅 3 条已验证 URL）；validate.sh + ci-smoke（PASS sitemap=11）绿；3 文件 1 commit 本地未推送 | 2026-09-16 | e8dfffa7 | [260916-c21-new-models-page-models-with-navbar-entry](./quick/260916-c21-new-models-page-models-with-navbar-entry/) |
| 260916-cs1 | MODELS-02: /models/ 卡片缩略图 — 虚线 "Model" 占位框换为两论文 Fig 1 真图；images/models/（NEW，research/software/team 同级）入库 byte-identical 两 PNG（plantelixseek-fig1.png 306244B 800×647 · pdllms-fig1.png 66162B 660×990，cmp 对 /tmp/models_imgs/ 全过）；_data/models.yml 加可选 image/image_alt schema（header 注释文档化，两条目各 +2 键，双引号无内嵌引号保 alt 属性安全）；_pages/models.md L68 单行 column-0 条件渲染（image → .software-thumb img relative_url/alt/loading=lazy，else 分支与原占位 div byte-identical 保未来无图条目回退）；零 SCSS/零配置改动；线上 /models/ 恰 2 img + 2 lazy、元素形占位 0、两图 URL 200；validate.sh + ci-smoke（PASS sitemap=11 不变）绿；4 文件 1 commit 7a79e5d6 本地未推送 | 2026-09-16 | 7a79e5d6 | [260916-cs1-add-paper-figures-as-card-images-on-mode](./quick/260916-cs1-add-paper-figures-as-card-images-on-mode/) |
| 260916-d6y | MODELS-02 缺陷修复: /models/ 卡片图版式（cs1 遗留视觉缺陷）— 架构面板图替换过密论文 Fig1：删 plantelixseek-fig1.png + pdllms-fig1.png，入 plantelixseek-architecture.png 244679B + pdllms-architecture.png 24268B（cmp 对 /tmp/models_imgs/ byte-identical，架构图不裁剪）；models.yml 两条目 image/image_alt 改指架构图（新 alt 文案）；models.md 页内 style 块三处改动（.software-thumb +padding 8px、img object-fit cover→contain 图表永不裁剪、767px 媒体查询 column→column-reverse 图上文下）；_sass/assets/css 零改动；验证升级为渲染证据：Playwright 截图 1280px+375px（375 目检：Featured 缎带最顶、图全宽 contain 信箱完整、正文在下）+ DOM 几何断言双宽度（1280 右栏 260px thumb.right>body.right、375 thumb.top<body.top 高恰 200、占位元素 0）；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 6 路径 1 commit f7d68596 本地未推送；偏差 Rule 3×2：变更集审计按内容域计数（编排器 .planning 任务目录致 7 行）、1280 截图经 CDN 中继不可目检改用计划许可的几何等价证据 | 2026-09-16 | f7d68596 | [260916-d6y-fix-models-page-card-image-layout-mobile](./quick/260916-d6y-fix-models-page-card-image-layout-mobile/) |
| 260916-dvz | MODELS-02 round-2: /models/ 卡片图二审修复 — PDLLMs 换用户批准的 top-A 横版 crop（核心启动子+终止子架构示意，pdllms-architecture.png 同名替换 24268→15287B，cmp byte-identical 仓库+serve URL）；PlantHelixSeek 竖版架构图 cmp 对 git HEAD 证未动；models.yml 仅 PDLLMs image_alt 改 "Core promoter and terminator architecture analyzed by PDLLMs"；models.md 页内 style 自然宽高比改版（.software-card stretch→flex-start 不再拉伸至正文高、.software-thumb img height:100%+object-fit→height:auto 信箱结构性不可能、767px 拆分合并选择器：thumb 居中 width:100% max-width:300px margin auto + 高度自然、placeholder 保留 200px 兜底、column-reverse 原样）；Rule 3 关键偏差：全局 assets/css/custom.scss L65 同名类移动端 height:200px 级联（d6y 页内同值声明掩蔽、本轮删除后浮现，375px 竖图被 overflow:hidden 裁 236px）→ 页内 thumb 规则补 height:auto 中性声明中和（禁止路径未动、全部 grep 门保持）；截图双宽度经 CDN 中继不可目检（d6y 先例）→ DOM 几何为验收证据：双宽度双卡片 0.00% 宽高比漂移、hug 恰 18px 盒饰边（16 padding+2 border）零填充、1280 右栏 260px、375 居中 0px 偏差 ≤300px 图上文下、非 200±5、占位 0（30 PASS）；计划假设勘误：移动端像素估值未减 18px 盒饰边、helix 竖图 398px 高于正文 379px 使 "thumb 严格小于 body" 不可满足（等价反拉伸证据 hug==18+自然区间+PDLLMs 卡 124.3≠183.7）；computed object-fit=cover 继承自全局在 height:auto 下惰性（0.00% 漂移证明）；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 3 路径 1 commit 6f186341（0ca7deb4 一次本地 amend 折入 Rule 3 修复，保持单提交约束）本地未推送 | 2026-09-16 | 6f186341 | [260916-dvz-models-card-figures-round-2-keep-planthe](./quick/260916-dvz-models-card-figures-round-2-keep-planthe/) |
| 260916-ksu | MODELS-02 定版: /models/ 卡片全宽合成横幅改版（用户批准 mockup）— 删两栏缩略图版式及其响应式翻转，改为一版式全宽度：每卡顶部全宽横幅 + 文字在下；images/models/ 换血（删 plantelixseek-architecture.png 244679B + pdllms-architecture.png 15287B，入 plantelixseek-banner.png 227933B 1414×560 + pdllms-banner.png 27054B 980×300，均为 /tmp/models_imgs/ 用户 ffmpeg hstack 合成图 cp byte-identical，磁盘 cmp + serve URL cmp 双绿）；models.yml 双条目 image/image_alt 改指 banner + 头部 schema 注释 "card thumbnail"→"full-width card banner"；models.md 卡片循环重构（Featured 徽章原样 → 单行 column-0 banner 条件渲染〔featured 时 margin-top var(--space-3) 保徽章间距、无 else 分支占位框永久移除〕→ 正文裸序列逐字保留；删 flex wrapper/body wrapper/尾部缩略图行）+ 页内 style 块整体替换（.model-banner 260px cover、767px 仅 height:190px、scoped .section-card h4 排版补偿〔背景已文档化的级联伴生规则，防 h4 落回浏览器默认〕、p/li/.pub-authors 原样）；全局 custom.scss 未动（同名类在本页惰性，/software/ 页不受影响）；验证双证据：DOM 几何 42 项全过（1280: 横幅宽 1008/1010 与卡片 content-box 差 0px、高恰 260、徽章底 335.3<横幅顶 347.3、gap 12、object-fit cover、naturalWidth 1414/980 证 yml→渲染链；375: 宽 283/285、高恰 190、仍在标题上；legacy 类 0）+ 截图双宽度首次可直接目检（d6y/dvz CDN 中继阻断未复发）；Rule 3 偏差：porcelain 6 路径门首跑因未跟踪目录折叠为 images/models/ 失败 → 提前 stage 两 banner 后过（终局提交本就需 stage，纯门序调整）；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 6 路径 1 commit 1b9b7a5d 本地未推送 | 2026-09-16 | 1b9b7a5d | [260916-ksu-models-cards-full-width-composed-banner-](./quick/260916-ksu-models-cards-full-width-composed-banner-/) |
| 260916-lei | MODELS-02 收尾: /models/ 横幅 natural-aspect 完整显示 — _pages/models.md 页内 style 块恰 3 处编辑（.model-banner 由 ksu 固定高 260px/190px cover 改 width:100% + height:auto 自然宽高比、img 同步、删 767px 断点高度规则），其余零改动；双宽度 DOM 几何 30/30 PASS（drift <0.5%，objectFit=fill 恒等映射）+ 截图双宽度直接目检（CDN 中继未复发）；validate/ci-smoke 绿 sitemap=11；恰 1 路径 1 commit 36d7cba2 本地未推送 | 2026-09-16 | 36d7cba2 | [260916-lei-models-figure-final-natural-aspect-full-](./quick/260916-lei-models-figure-final-natural-aspect-full-/) |
| 260916-nl1 | MODELS-02: /models/ 横幅换完整面板版（用户合成 v2）— 删 plantelixseek-banner.png 227933B + pdllms-banner.png 27054B（截断裁剪版），入 plantelixseek-banner-full.png 258618B 1536×620 + pdllms-banner-full.png 55515B 1368×310（/tmp/models_imgs/ hs-banner-v2/pd-banner-v2 cp byte-identical，磁盘 cmp + serve URL cmp 双绿，新 URL 兼防旧横幅浏览器缓存）；models.yml 双条目 image/image_alt 改指（恰 4 行，双引号无内嵌引号）；零 markup/CSS 改动（lei natural-aspect 规则自动适配新宽高比）；旧 URL 404、渲染页零旧引用、恰 2 banner img；双宽度几何 aspect-drift ≤0.008% 零裁剪（1280: 1006.0×406.1 / 1008.0×228.4；375: 281.0×113.4 / 283.0×64.1）；证据路径：截图中继间歇〔~4/14 直达〕— 全页双宽度 + 两横幅 2× 裁剪直接目检〔完整多面板图、无边距缺失/截断、PDLLMs 右侧系统发育树可见〕+ Vision OCR 字级佐证（HS: "Single base" 分词器 A/T/G/C、语料统计、Model Overview 470M/8192bp/MLM、"Masked Token Prediction/FFN MoE/Router/RMSNorm/LM Head/Output Logits"、AUROC 轴 4.58–7.81 + HelixSeekDelta/LinAttn 对比标签、Liliops/Marchantia/Fabids 物种面板；PD: "core pro-"/ncRNAs/models compared）；观察项：计划引用标题 "Plant DNA assembly corpus" 非图内字面文本（OCR 实读 "Plant genomes/Diverse taxa"，用户合成为权威源不替换）；Rule 3×2：porcelain 目录折叠 ksu 先例提前 stage 两 banner、/tmp/pwrun 沙盒悬空链接改 igv-rust playwright 1.58.2（脚本落任务目录 NODE_PATH 运行）+ 选择器修正 .model-banner img（lei 版包装 div）；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 5 路径 1 commit 444f54e4 本地未推送 | 2026-09-16 | 444f54e4 | [260916-nl1-models-banners-rebuilt-from-complete-pan](./quick/260916-nl1-models-banners-rebuilt-from-complete-pan/) |
| 260916-oh7 | MODELS-02: /models/ PlantHelixSeek 卡图换用户 Figure 1（VERBATIM）— 删 plantelixseek-banner-full.png 258618B（nl1 合成版），入 plantelixseek-figure1.png 1663157B 2372×1255（/tmp/models_imgs/user-helixseek.png cp 零处理，磁盘 + staged blob + serve URL 三重 cmp 全绿，另提交 blob cmp 亦绿；新 URL 兼防旧横幅浏览器缓存）；models.yml PlantHelixSeek image/image_alt 改指（恰 2 行 "PlantHelixSeek paper Figure 1: pretraining corpus, model architecture and benchmarks"，PDLLMs 条目与 schema 头注释未动）；零 markup/CSS 改动（lei natural-aspect 规则自动适配 2372×1255）；旧 URL 404、渲染页新路径恰 1× 旧路径 0×；1280px 几何 7/7 PASS（natural 2372×1255、显示 1006.0×532.25、aspect-drift 0.003%<1%、src 正确）；截图双源直接目检（Playwright models-1280.png + Kimi 用户真浏览器 session models-page-check，CDN 中继阻断未复发）— 用户图内容完整、全宽、零截断；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 3 路径 1 commit 0c5a92ab 本地未推送 | 2026-09-16 | 0c5a92ab | [260916-oh7-swap-planthelixseek-card-image-to-the-us](./quick/260916-oh7-swap-planthelixseek-card-image-to-the-us/) |
| 260916-ooh | MODELS-02: /models/ PDLLMs 卡图换用户第二张 Figure 1（VERBATIM，oh7 镜像）— 删 pdllms-banner-full.png 55515B（nl1 合成版），入 pdllms-figure1.png 1896484B 3656×1628（/tmp/models_imgs/user-pdllms.png cp 零处理，磁盘 + staged blob + serve URL + 提交 blob 四重 cmp 全绿；新 URL 兼防旧横幅浏览器缓存）；models.yml PDLLMs image/image_alt 改指（恰 2 行 "PDLLMs paper Figure 1: model overview"，PlantHelixSeek 条目与 schema 头注释未动）；零 markup/CSS 改动（lei natural-aspect 规则自动适配 3656×1628）；旧 URL 404、渲染页新路径恰 1× 旧路径 0× plantelixseek-figure1 恰 1×；1280px 几何 GEOMETRY-PASS（natural 3656×1628、显示 1008×448.84、aspect-drift 0.003%<1%）；截图双源直接目检（Playwright models-1280.png + Kimi 用户真浏览器 session models-page-check DOM 实测同值 1008×448.85，暗色模式）— 用户图内容完整、全宽、零截断；validate.sh + ci-smoke（PASS sitemap=11）绿；恰 3 路径 1 commit 79e7728c 本地未推送 | 2026-09-16 | 79e7728c | [260916-ooh-swap-pdllms-card-image-to-the-second-use](./quick/260916-ooh-swap-pdllms-card-image-to-the-second-use/) |
| 260916-ovj | MODELS-02: /models/ 卡片版式定稿方案 A（用户批准 mockup 图左·文右）— _pages/models.md 单文件重构（恰 1 git 路径 13+/3−，images/ 与 _data/models.yml 字节未动）：卡片循环包 .model-row flex 行（.model-banner 56% + .model-body 文字列，正文序列逐字保留 column-0；banner 行内 featured margin-top 条件删除，改由 .model-row margin-top 拥有徽章间距视觉等价）+ 页内 style 块换方案 A 规则（gap 22px / flex 0 0 56% / img 自然宽高比带边框圆角 / 767px column 堆叠图上文下全宽）；无 Access: pip install spec 行（用户否决 grep 0，dnallm callout 保持恰 1）；验证：Playwright 14/14 PASS（1280 双卡图左文右 banner.right 700.5/700.6 ≤ body.left 722.5/722.6、56% 偏差 0.0px、aspect-drift 0.314%/0.434% 零裁剪、徽章在上；375 图上文下堆叠全宽 283/285、drift ≤0.864%）+ 截图双宽度直接目检（375 Playwright inline；1280 Kimi 用户真浏览器 2× retina inline——全页 PNG 六次 CDN 中继，按 d6y/dvz/nl1 先例以真浏览器目检 + Playwright/Kimi 双引擎 DOM 同值等效）+ Kimi session models-page-check reload DOM 实测同值；validate.sh + ci-smoke（PASS sitemap=11）绿；porcelain 恰 1 内容路径 1 commit 67b85154 本地未推送 | 2026-09-16 | 67b85154 | [260916-ovj-models-cards-layout-option-a-user-approv](./quick/260916-ovj-models-cards-layout-option-a-user-approv/) |
| 260916-p4i | SW-DEL-02: /software/ 删 PDLLMs 卡（与 /models/ 卡重复，c21/ovj 血统后 Models 页为唯一主）— _pages/software.md 纯删除 15 行（空行 + 14 行 section-card 块：h4 标题、GitHub/Paper 按钮〔DOI 10.1016/j.molp.2024.12.006〕、描述、Citation、占位缩略图），镜像 260827-lwq 成熟流程；live /software/ PDLLMs 2→0、software-card 7→6、DOI 1→0、正向哨兵 dnallmmark/CrisprStitch/rustkmer 在；源 0 PDLLMs、卡 div 计数 6/6、137→122 行、L42/L43/L44 边界形状正确；search.json 按 entry 作用域（python3 json 解析）：/software/ 条目无 PDLLMs、/models/ 条目保留 PDLLMs（整文件负 grep 会假失败）；validate.sh + ci-smoke（PASS sitemap=11）绿；numstat 0/15 恰 1 路径 1 commit de10963c 本地未推送 | 2026-09-16 | de10963c | [260916-p4i-remove-pdllms-card-from-software-page-du](./quick/260916-p4i-remove-pdllms-card-from-software-page-du/) |
