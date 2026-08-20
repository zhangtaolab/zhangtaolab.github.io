---
gsd_state_version: 1.0
milestone: v1.0
current_phase: 3
current_phase_name: 内容验证
status: executing
stopped_at: Completed 03-03-PLAN.md（层①③ 抗崩收口 + WR-01/WR-02 + IN-01/IN-03，2/2 tasks）
last_updated: "2026-08-20T07:21:57.800Z"
state_head: 4bd8f987191ff0fb8c29b7e01a2fb19666d2b226
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

**Last session:** 2026-08-20T07:21:57.723Z
**Stopped at:** Completed 03-03-PLAN.md（层①③ 抗崩收口 + WR-01/WR-02 + IN-01/IN-03，2/2 tasks）
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
