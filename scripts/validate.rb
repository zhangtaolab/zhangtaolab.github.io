#!/usr/bin/env ruby
# frozen_string_literal: true

# scripts/validate.rb —— 内容验证引擎（本地: scripts/validate.sh；CI: deploy.yml 直接
#   bundle exec ruby scripts/validate.rb，CI 步骤由 Plan 02 落地）。
# 校验 _data/*.yml 与 papers/ref.bib 的语法错误，全部错误一次收集、中文报出；
# 只读数据文件（不运行 jekyll build、不修改任何被校验内容），退出码 0=全绿 / 1=有错。
# 依赖零新增：psych 为 Ruby default gem，bibtex-ruby 已随 jekyll-scholar 锁在 Gemfile.lock。

require "psych"
require "bibtex"

# 数据文件清单：label 用于 PASS 汇总行（team 来自 team_members.yml）
YAML_FILES = {
  "news"   => "_data/news.yml",
  "team"   => "_data/team_members.yml",
  "pi"     => "_data/pi.yml",
  "alumni" => "_data/alumni.yml",
  "grants" => "_data/grants.yml",
}.freeze

BIB_PATH = "papers/ref.bib"

# Pattern 3（非 fail-fast）：全部错误收集到同一数组，末尾统一输出
errors = []
counts = {}

# ── ① YAML 语法层 ────────────────────────────────────────────────────────────
# 一律走 Psych.parse_file(...).to_ruby（parser API，与 Jekyll 数据读取同路；
# 不使用对象反序列化式加载入口）。Psych::SyntaxError 自带行号/列号（D-07）。
# 语法坏的文件只短路自身（跳过后续结构检查），其余文件继续。
parsed = {}
YAML_FILES.each do |label, path|
  begin
    parsed[label] = Psych.parse_file(path).to_ruby
  rescue Psych::SyntaxError => e
    errors << "#{File.basename(path)} 第 #{e.line} 行第 #{e.column} 列：YAML 语法错误（#{e.problem}）"
  end
end
counts = parsed.transform_values { |data| data.respond_to?(:length) ? data.length : 0 }

# ── ② YAML 结构层（逐文件 schema；语法坏的文件只短路自身，其余继续） ──────────
# jekyll build 对本层错误全部静默通过（实测）：必填字段缺失/拼错 → 页面缺内容；
# 顶层丢 "- " 变映射 → 整文件内容从页面消失。schema 字段清单按现有数据推导
# （基线实测 0 错误），规则不得比现状严（Pitfall 6：现有数据必须全绿）。

# D-02：date 允许 "Latest"（仅首条）或英文全拼月份 + 4 位年份
NEWS_DATE_RE = /\A(January|February|March|April|May|June|July|August|September|October|November|December) \d{4}\z/
# team_members.yml 首行注释原文「role: pi | member | student」；role 是 team 页
# where 判别键，拼错则人从页面消失
TEAM_ROLES = %w[pi member student].freeze

REQUIRED_FIELDS = {
  "news"   => %w[date headline],
  "team"   => %w[name role position],
  "pi"     => [], # education 有非空列表专项检查
  "alumni" => %w[name period degree position], # team 页表格四列全部裸输出
  "grants" => %w[name],
}.freeze

# 每条必填字段：缺失或空白即报（D-07：「<文件> 第 N 条：<字段> 字段缺失」）
def check_required(basename, entries, fields, errors)
  entries.each_with_index do |entry, i|
    unless entry.is_a?(Hash)
      errors << "#{basename} 第 #{i + 1} 条：条目应为键值对，当前是 #{entry.class}——请复制既有条目的 \"- 键: 值\" 格式"
      next
    end
    fields.each do |f|
      errors << "#{basename} 第 #{i + 1} 条：#{f} 字段缺失" if entry[f].to_s.strip.empty?
    end
  end
end

YAML_FILES.each do |label, path|
  next unless parsed.key?(label) # 语法坏的文件跳过结构检查，其余文件继续

  basename = File.basename(path)
  data = parsed[label]
  begin
    unless data.is_a?(Array)
      errors << "#{basename}：顶层结构应为列表（每条以 \"- \" 开头），当前是 #{data.class}——新增条目请复制既有条目的 \"- \" 前缀格式"
      next
    end

    check_required(basename, data, REQUIRED_FIELDS[label], errors)

    case label
    when "news"
      data.each_with_index do |entry, i|
        next unless entry.is_a?(Hash)
        ds = entry["date"].to_s.strip
        if ds == "Latest"
          if i.positive?
            errors << "#{basename} 第 #{i + 1} 条：\"Latest\" 仅允许首条（sidebar/feed 按时间序展示，非首条 Latest 属数据摆放错误）"
          end
        elsif !ds.empty? && ds !~ NEWS_DATE_RE
          errors << "#{basename} 第 #{i + 1} 条：date 格式不合法（#{ds}），合法格式：May 2026 或首条 Latest"
        end
      end
    when "team"
      data.each_with_index do |entry, i|
        next unless entry.is_a?(Hash)
        role = entry["role"].to_s.strip
        next if role.empty? # 缺失已由必填检查报出
        unless TEAM_ROLES.include?(role)
          errors << "#{basename} 第 #{i + 1} 条：role 取值不合法（#{role}），合法值：pi | member | student"
        end
      end
    when "pi"
      # about 页下标访问 site.data.pi[0].education；educationshort 为模板零消费
      # 死字段，不检查（Pitfall 7）
      data.each_with_index do |entry, i|
        next unless entry.is_a?(Hash)
        edu = entry["education"]
        unless edu.is_a?(Array) && !edu.empty?
          errors << "#{basename} 第 #{i + 1} 条：education 字段缺失或为空（须为非空列表）"
        end
      end
    end
  rescue StandardError => e
    # 兜底（T-03-03）：畸形输入不得使脚本崩溃或掩盖其余文件的错误
    errors << "#{basename} 结构检查异常（#{e.class}）：#{e.message[0, 80]}——请人工检查该文件"
  end
end

# ── ③ BibTeX 解析层 ─────────────────────────────────────────────────────────
# 解析器异常消息不含文件名与行号（racc 只吐 token 碎片）——文件名与中文建议由
# 脚本补上，不承诺 bib 行号定位；键名/字段名定位见后续各层。
bib = nil
begin
  bib = BibTeX.parse(File.read(BIB_PATH))
rescue BibTeX::ParseError => e
  errors << "#{BIB_PATH} 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— #{e.message[0, 120]}"
end
counts["bib"] = bib.nil? ? 0 : bib.length

# ── ④ BibTeX 必填层（D-03：每条 title/author/year；DOI/journal 非必填） ──────
# 仅在解析成功后运行（解析失败时本层与键唯一层跳过，exit 已由解析层置 1）。
# API 形状（bibtex-ruby 6.2.0 实测，勿凭记忆改写）：bib.to_a 迭代（bib.entries
# 是 Hash）；条目是 Hash 子类，字段只有 e[:field] 下标访问；字段值带大括号
# 原样，判空用 to_s.strip.empty?。无 doi 的条目（如 wang2026maize）必须通过。
BIB_REQUIRED = %i[title author year].freeze

if bib
  bib.to_a.each do |entry|
    key = entry[:bibtex_key].to_s.strip
    # lexer 级截断条目（未闭合大括号）只 WARN 不抛异常，条目以空键+空字段存活
    # ——键为空时给出定位线索，避免消息里只剩悬空冒号
    key = "（引用键无法识别——多为截断或未闭合条目）" if key.empty?
    BIB_REQUIRED.each do |field|
      errors << "#{BIB_PATH} #{key}：#{field} 字段缺失" if entry[field].to_s.strip.empty?
    end
  end

  # ── ⑤ 键唯一层（原始正则提键——唯一真相源） ──────────────────────────────
  # 解析器对重复引用键静默改名（实测 k,k,k → k,l,m），解析结果里不存在重复，
  # 查重必须在原始文本上做（Don't Hand-Roll 表中唯一允许的手写正则场景）。
  # % 注释行（如首行「% Zhang Tao Lab Publications」）天然不匹配该正则。
  File.read(BIB_PATH).scan(/@\w+\{([^,\s]+)\s*,/).flatten.tally.each do |k, c|
    errors << "#{BIB_PATH}：引用键 #{k} 重复出现 #{c} 次" if c > 1
  end
end

# ── ⑥ D-08 提醒层（ref.bib 条目数变化提醒——警告不阻断） ─────────────────────
# 对比 HEAD 与工作区的 ref.bib 条目数（RESEARCH Pattern 4 同款原始文本计数，
# 不依赖 BibTeX 解析结果——bib 语法坏时计数仍可执行）。不等 → 输出一行中文
# 提醒（D-08 锁定文案，含 publications.md 字样），但不写入 errors、对退出码
# 零影响（「不误伤正常提交」）。guard（非 git 目录 / 无 HEAD 历史 / ref.bib
# 不在 HEAD）失败时静默跳过——提醒属增强，guard 失败不算错误（A1 兜底）。
# CI（checkout fetch-depth 1）工作区=HEAD，两计数天然相等，提醒自动不触发，
# 零 CI 特判；禁止改用父提交/远端分支对比写法（浅克隆 fetch-depth 1 下不存在）。
# 提醒是纯文本输出，不触碰 publications.md 本身（手写列表不替换/不再生成/
# 不自动同步，prohibition P-03-3；反向提醒属 Deferred，不做）。
def bib_entry_count(text)
  text.scan(/^@[a-zA-Z]+\{/).length
end

head_bib = nil
if system("git rev-parse --git-dir", out: File::NULL, err: File::NULL) &&
   system("git cat-file -e HEAD:#{BIB_PATH}", out: File::NULL, err: File::NULL)
  head_bib = `git show HEAD:#{BIB_PATH} 2>/dev/null`
  head_bib = nil unless $?.success?
end
if head_bib
  head_count = bib_entry_count(head_bib)
  work_count = bib_entry_count(File.read(BIB_PATH))
  if head_count != work_count
    puts "提醒：ref.bib 条目数 #{head_count} → #{work_count} 已变化；" \
         "publications.md 为手写列表，请确认已同步新增/删除条目"
  end
end

# ── 汇总输出 ────────────────────────────────────────────────────────────────
# PASS 行的逐文件计数由解析结果动态计算（维护者加条目后自动更新，勿硬编码）；
# 「键唯一」标记表示原始文本无重复引用键（有重复会进 errors 走 FAIL 分支）。
if errors.empty?
  puts "PASS: news=#{counts['news']}, team=#{counts['team']}, pi=#{counts['pi']}, " \
       "alumni=#{counts['alumni']}, grants=#{counts['grants']}, bib=#{counts['bib']}, 键唯一"
else
  puts "FAIL: #{errors.length} 个问题"
  errors.each { |msg| puts msg }
end
exit(errors.empty? ? 0 : 1)
