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

# ── ② BibTeX 解析层 ─────────────────────────────────────────────────────────
# 解析器异常消息不含文件名与行号（racc 只吐 token 碎片）——文件名与中文建议由
# 脚本补上，不承诺 bib 行号定位；键名/字段名定位见后续各层。
bib = nil
begin
  bib = BibTeX.parse(File.read(BIB_PATH))
rescue BibTeX::ParseError => e
  errors << "#{BIB_PATH} 解析失败（检查最近编辑：多为缺失逗号或未闭合大括号）—— #{e.message[0, 120]}"
end
counts["bib"] = bib.nil? ? 0 : bib.length

# ── 汇总输出 ────────────────────────────────────────────────────────────────
# PASS 行的逐文件计数由解析结果动态计算（维护者加条目后自动更新，勿硬编码）。
if errors.empty?
  puts "PASS: news=#{counts['news']}, team=#{counts['team']}, pi=#{counts['pi']}, " \
       "alumni=#{counts['alumni']}, grants=#{counts['grants']}, bib=#{counts['bib']}"
else
  puts "FAIL: #{errors.length} 个问题"
  errors.each { |msg| puts msg }
end
exit(errors.empty? ? 0 : 1)
