# Walking Skeleton — Zhang Tao Lab 主页（全新版本）

**Phase:** 1
**Generated:** 2026-08-17
**Adaptation note:** 本项目为 brownfield Jekyll 静态站点，全部代码已存在。此处的"行走骨架"不是新脚手架，而是**既有站点最薄端到端链路的首次点亮证明**：`bundle install` → `bundle exec jekyll serve --livereload` → 13 个页面渲染 → 文献链路解析 `papers/ref.bib` → 修改文件浏览器自动刷新。

## Capability Proven End-to-End

维护者在仓库根执行 `bundle install && bundle exec jekyll serve --livereload`，浏览器打开 http://127.0.0.1:4000 即可预览站点全部 13 个页面（含 83 条手写文献的出版物页），修改任意源文件后页面自动刷新。

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| 静态生成器 | Jekyll 4.3.3（若版本阶梯升至 Step A 则为 ~> 4.4.0，落定后钉死于 Gemfile） | 大版本已完成，约束禁止框架重写；Jekyll 4.3.3 官方不支持 Ruby 4.x，是否需要升级由 Phase 1 决策阶梯实测决定 |
| Ruby 运行时 | Homebrew Ruby 4.0.6（阶梯 Step B 则为 brew ruby@3.4），版本写入仓库根 `.ruby-version` | 本机无版本管理器；`.ruby-version` 成为 Phase 2 CI（ruby/setup-ruby）与本地一致性的唯一事实源 |
| 插件加载机制 | Gemfile `group :jekyll_plugins`（jekyll-scholar、jekyll-sitemap 移入） | `bundle exec` 本地与 Phase 2 GitHub Actions 走同一条加载路径；修复现状中 jekyll-scholar 不被加载的缺口 |
| 文献数据源 | `papers/ref.bib`（真实实验室数据，12 条），`scholar.source: /papers/` | `assets/ref.bib` 为模板 Feynman 演示数据（24 条），已删除；papers/ref.bib 是 CLAUDE.md 与 ROADMAP 共同认定的权威文件（mtime 更晚、内容真实） |
| 出版物页形态 | `_pages/publications.md` 保持手写 markdown（83 条，2006–2026），**不**由 jekyll-scholar 生成 | papers/ref.bib 仅 12 条；替换会丢失 71 条内容。"出版物页 bib 化"是内容补全工作，待未来里程碑（需先把 83 条补入 bib） |
| 依赖锁定 | Gemfile.lock 生成并入库（`_config.yml` 的 exclude 已含 Gemfile.lock，不会发布） | Phase 2 Linux CI 复用同一 lockfile（届时需 `bundle lock --add-platform x86_64-linux`，属 Phase 2 动作） |
| 本地运行命令 | `bundle exec jekyll serve --livereload`（默认 127.0.0.1:4000） | Jekyll 4 的 livereload 需显式 `--livereload` flag，默认关闭；这是 ENV-01 判据 4 的标准命令 |

## Stack Touched in Phase 1

（brownfield 替换语义：无 DB/无 API，数据层 = YAML + BibTeX）

- [x] 项目骨架 — 既有（本阶段只改 Gemfile / _config.yml / 新增 .gitignore 与 .ruby-version，不新增脚手架）
- [x] 路由 — 13 个 permalink 页面全部渲染 200（/、/about/、/research/、/publications/、/software/、/team/、/news/、/contact/、/blogs/、/talks/、/teaching/、/allnews.html、/404.html）
- [x] 数据层 — 真实读取：`_data/*.yml` 6 个文件（people/news/pi/team_members/grants/alumni）+ `papers/ref.bib` 12 条 BibTeX 经 jekyll-scholar 渲染（探针验证 12 个 pub-entry）
- [x] UI 交互 — live reload：修改 `_pages/home.md` 后浏览器自动刷新（livereload.js 200 + 产物变更双证明）
- [x] 运行 — 完整本地运行命令（上方"本地运行命令"行），全栈经 `bundle exec` 闭环

## 已接受的已知空态（非静默失败，显式记录）

- `/talks/`：papers/ref.bib 无 @incollection 条目，两个 `{% bibliography %}` 查询渲染为空列表（页面 200、标题在）。真实 talks 数据属内容补全工作。
- `/blogs/`：无 `_posts` 目录，列表为空（页面结构正常）。

## Out of Scope（Deferred — 防止后续阶段重开 Phase 1 的最小性）

- CI/CD 与 GitHub Pages 部署、Gemfile.lock 加 Linux 平台条目（Phase 2）
- `_data/*.yml` 与 `papers/ref.bib` 的语法校验工具（Phase 3）
- 出版物页改为 jekyll-scholar 驱动（需先补全 bib 至 83 条，属未来内容工作）
- talks/teaching/blogs 的真实内容填充
- 生产模式本地构建验证（v2 ENV-03）、内容指南文档（v2 CONT-01/02）、CI 链接检查（v2 QUAL-01）
- DNS/HTTPS、PR 预览、多语言、视觉改版（REQUIREMENTS Out of Scope 表）

## Subsequent Slice Plan

- **Phase 2（自动部署）：** 在本骨架之上新增 GitHub Actions 垂直切片：push → Actions 用 `.ruby-version` 对齐的 Ruby + 入库的 Gemfile.lock 完整构建（含 jekyll-scholar）→ 发布 Pages。不改变本文件任何架构决策。
- **Phase 3（内容验证）：** 在同一构建链上加 yml/bib 语法拦截切片。不改变架构决策。

后续阶段若需推翻本表任一决策（如更换生成器、改用 Node 方案），视为架构变更，须回到规划层重新决策，不得在执行中静默改道。
