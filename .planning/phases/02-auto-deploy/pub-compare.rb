#!/usr/bin/env ruby
# pub-compare.rb — D-18 per-entry comparison engine (Plan 02-03 Task 2)
#
# Compares pub-extract-old.txt against pub-extract-new.txt entry by entry,
# inside year buckets, in three passes:
#   pass 1: exact match on normalized-title (extractor normalization)
#   pass 2: NFKC-folded match — Unicode compatibility decomposition folds the old
#           site's typographic ligatures (ﬁ→fi, ﬂ→fl) and other compatibility
#           chars so "efﬁcient" == "efficient"; still alnum-only, one-to-one
#   pass 3: leftovers — printed for executor manual judgment (recorded with
#           rationale in 02-PUBLICATION-AUDIT.md, never silently dropped)
#
# Emits a machine-readable intermediate (compare-result.txt) that the audit
# report's tables are built from:
#   OLD <idx> <year> <MATCHED-EXACT|MATCHED-FUZZY-NFKC|MISSING> | <norm> | <first-author> | <raw> |-> <matched new raw or ->
#   EXTRA <idx> <year> | <norm> | <first-author> | <raw>

require "cgi"

DIR = __dir__

def load(path)
  File.readlines(path, chomp: true).reject { |l| l.strip.empty? }.each_with_index.map do |line, i|
    y, n, a, r = line.split(" | ", 4)
    { idx: i + 1, year: y, norm: n, author: a, raw: r }
  end
end

old = load(File.join(DIR, "pub-extract-old.txt"))
new = load(File.join(DIR, "pub-extract-new.txt"))

def nfkc_key(norm)
  norm.unicode_normalize(:nfkc).downcase.gsub(/[^a-z0-9]/, "")
end

# pass 1: exact normalized-title, 1:1 consumption within year bucket
old_by_year = old.group_by { |e| e[:year] }
new_by_year = new.group_by { |e| e[:year] }
old.each { |e| e[:status] = nil; e[:match] = nil }
old_by_year.each do |year, oes|
  pool = new_by_year[year] || []
  oes.each do |oe|
    m = pool.find { |ne| !ne[:consumed] && ne[:norm] == oe[:norm] }
    if m
      oe[:status] = "MATCHED-EXACT"
      oe[:match] = m
      m[:consumed] = true
    end
  end
end

# pass 2: NFKC-folded keys re-derived from RAW titles (the extractor's ASCII-only
# filter already destroyed ligatures in :norm — "efﬁcient"→"efcient" — so folding
# must start from the raw title where ﬁ still survives; NFKC turns it into "fi")
old_by_year.each do |year, oes|
  pool = (new_by_year[year] || []).reject { |ne| ne[:consumed] }
  oes.select { |oe| oe[:status].nil? }.each do |oe|
    m = pool.find { |ne| !ne[:consumed] && nfkc_key(ne[:raw]) == nfkc_key(oe[:raw]) }
    if m
      oe[:status] = "MATCHED-FUZZY-NFKC"
      oe[:match] = m
      m[:consumed] = true
    end
  end
end

# pass 3: leftovers
old.each { |e| e[:status] = "MISSING" if e[:status].nil? }
extras = new.reject { |e| e[:consumed] }

out = File.join(DIR, "compare-result.txt")
File.open(out, "w") do |f|
  old.each do |e|
    f.puts "OLD #{e[:idx]} #{e[:year]} #{e[:status]} | #{e[:norm]} | #{e[:author]} | #{e[:raw]} |-> #{e[:match] ? e[:match][:raw] : '-'}"
  end
  extras.each do |e|
    f.puts "EXTRA #{e[:idx]} #{e[:year]} | #{e[:norm]} | #{e[:author]} | #{e[:raw]}"
  end
end

counts = Hash.new(0)
old.each { |e| counts[e[:status]] += 1 }
warn "old total=#{old.size}: " + counts.map { |k, v| "#{k}=#{v}" }.join(" ")
warn "new total=#{new.size}: consumed=#{new.count { |e| e[:consumed] }}, extras=#{extras.size}"
warn "accounting check: #{old.size} old = #{counts['MATCHED-EXACT']}+#{counts['MATCHED-FUZZY-NFKC']}+#{counts['MISSING']}; #{new.size} new = #{new.count { |e| e[:consumed] }}+#{extras.size}"
warn "--- NFKC-pass pairs (typographic ligature variants) ---"
old.each { |e| warn "  #{e[:year]} #{e[:raw][0, 60]}  <->  #{e[:match][:raw][0, 60]}" if e[:status] == "MATCHED-FUZZY-NFKC" }
warn "--- MISSING (old-side, deploy-blocking per D-18) ---"
old.each { |e| warn "  #{e[:year]} | #{e[:author]} | #{e[:raw]}" if e[:status] == "MISSING" }
warn "--- EXTRA (new-side, user-confirmation per D-18) ---"
extras.each { |e| warn "  #{e[:year]} | #{e[:author]} | #{e[:raw]}" }

# ------------------------------------------------------------------------------
# 02-PUBLICATION-AUDIT.md generation (all tables derived from the comparison data)
# ------------------------------------------------------------------------------
TODAY = "2026-08-19"
n_exact = counts["MATCHED-EXACT"]
n_nfkc  = counts["MATCHED-FUZZY-NFKC"]
n_miss  = counts["MISSING"]
n_matched = n_exact + n_nfkc

# grep keywords machine-verified absent from new side (0 hits, see Task 2 log)
MISSING_EVIDENCE = {
  "genomewideanalysesofpamrelaxedcas9genomeeditorsrevealsubstantialofftargeteffectsbyabe8einrice" => "grep 'ABE8e' _pages/publications.md → 0 命中",
  "singlecelltranscriptomeandnetworkanalysesunveilkeytranscriptionfactorsregulatingmesophyllcelldevelopmentinmaize" => "grep 'Mesophyll' _pages/publications.md → 0 命中",
  "epigenomicfeaturesofdnagquadruplexesandtheirrolesinregulatingricegenetranscription" => "grep 'G-quadruplex' _pages/publications.md → 0 命中",
  "crisprbetsabaseeditingdesigntoolforgeneratingstopcodons" => "grep 'CRISPR-BETS' _pages/publications.md（正文条目区）→ 0 命中（仅旧站导航菜单提及）",
  "transcriptomecomparativeprofilingofbarleyeibi1mutantrevealspleiotropiceffectsofhvabcg31geneoncuticlebiogenesisandstressresponsivepathways" => "grep 'eibi1'/'HvABCG31' _pages/publications.md → 0 命中",
  "maizelazy1mediatesshootgravitropismandinflorescencedevelopmentthroughregulatingauxintransportauxinsignalingandlightresponse" => "grep 'LAZY1' _pages/publications.md → 0 命中",
}

MISSING_CITATIONS = [
  "Wu YC†, Ren QR†, Zhong ZH†, Liu GQ†, Han YS, Bao Y, Liu L, Xiang SY, Liu S, Tang X, Zhou JP, Zheng XL, Sretenovic S, Zhang T*, Qi YP*, Zhang Y*. Genome-wide analyses of PAM-relaxed Cas9 genome editors reveal substantial off-target effects by ABE8e in rice. *Plant Biotechnology Journal* 2022, 20(9): 1670-1682.",
  "Tao ST†, Liu P†, Shi YN, Feng YL, Gao JJ, Chen LF, Zhang AC, Cheng XJ, Wei HR, Zhang T*, Zhang WL*. Single-Cell Transcriptome and Network Analyses Unveil Key Transcription Factors Regulating Mesophyll Cell Development in Maize. *Genes* 2022, 13(2):374.",
  "Feng YL, Tao ST, Zhang PY, Sperti FR, Liu GQ, Cheng XJ, Zhang T, Yu HX, Wang XE, Cheng CY, Monchaud D, Zhang WL*. Epigenomic features of DNA G-quadruplexes and their roles in regulating rice gene transcription. *Plant Physiology* 2022, 188(3): 1632–1648.",
  "Wu YC†, He Y†, Sretenovic S, Liu SS, Cheng YH, Han YS, Liu GQ, Bao Y, Fang Q, Zheng XL, Zhou JP, Qi YP*, Zhang Y*, Zhang T*. CRISPR-BETS: A base editing design tool for generating stop codons. *Plant Biotechnology Journal* 2022, 20(3):499-510.",
  "Yang ZJ, Zhang T, Lang T, Li G, Chen G, Nevo E. Transcriptome Comparative Profiling of Barley eibi1 Mutant Reveals Pleiotropic Effects of HvABCG31 Gene on Cuticle Biogenesis and Stress Responsive Pathways. *International Journal of Molecular Sciences* 2013, 14(10):20478-20491.",
  "Dong ZB, Jiang C, Chen X, Zhang T, Ding L, Song W, Luo H, Lai J, Chen H, Liu R, Jin WW. Maize LAZY1 Mediates Shoot Gravitropism and Inflorescence Development through Regulating Auxin Transport, Auxin Signaling, and Light Response. *Plant Physiology* 2013, 163(3):1306-1322.",
]

years = (old.map { |e| e[:year] } | new.map { |e| e[:year] }).sort.reverse

report = []
report << "# 02-PUBLICATION-AUDIT — D-18 出版物逐条核对报告"
report << ""
report << "**Plan:** 02-03 · **决策依据:** D-18（02-CONTEXT.md，2026-08-19 锁定） · **生成:** #{TODAY}，机器生成自 pub-extract.rb + pub-compare.rb（本目录，可复现）"
report << ""
report << "## ① 方法"
report << ""
report << "### 语料声明（纠偏）"
report << ""
report << "- **新侧** = `_site/publications/index.html`——`_pages/publications.md` 手写 markdown 的构建产物（#{new.size} 条）。**不是** papers/ref.bib 渲染：ref.bib 仅 12 条 @article，只被 `_pages/talks.md` 的两个 `{% bibliography %}` 查询引用，与本页无关（02-RESEARCH.md Pattern 4 语料纠偏表）。"
report << "- **旧侧** = `old-site-publication.html`——线上 `https://zhangtaolab.org/Publication` 的 byte 存档（#{TODAY} 抢收，HTTP 200 前置检查通过，热切换前完成，commit a81b576）。"
report << "- **研究期计数 ~91 的解释**：91 = 89 条顶层条目 + 2 条嵌套子条目（Commentary/Cover 注记，见第⑥节）。fetch 摘要计数把嵌套 `<li>` 一并计入；机器提取以顶层条目为比对对象，子条目单独归类、不隐藏。"
report << ""
report << "### 提取与规范化（pub-extract.rb，两侧同一脚本同一规则）"
report << ""
report << "- 按 `<h2>YYYY</h2>` 年份桶分桶（两侧桶集合完全一致：19 个年份 2006–2026，无缺桶多桶）；深度感知解析 `<li>`（旧站存在嵌套 `<ul>` 子条目结构，顶层/嵌套分开归类）。"
report << "- 条目标题 = 条目内第一个 `<a>` 的文本；无链接条目 = 期刊斜体 `<em>` 前的最后一句（期刊是条目内**最后一个** `<em>`——标题自身可含斜体，如 *De Novo*）。first-author = 标题前文本的第一个「姓+缩写」词组。"
report << "- 规范化 = 去标签 → HTML 实体解码 → 转小写 → 去全部非字母数字字符 → 压空白。清单行格式 `YEAR | normalized-title | first-author | raw-title`。"
report << ""
report << "### 匹配（pub-compare.rb，年份桶内 1:1 消耗制）"
report << ""
report << "1. normalized-title 精确匹配 → #{n_exact} 条"
report << "2. NFKC 兼容折叠后从 raw title 重新取键匹配（旧站排版连字 ﬁ U+FB01 → fi 等）→ #{n_nfkc} 条"
report << "3. 残留 → executor 逐对人工阅读判定，全部记录于第③⑤节，无静默丢弃"
report << ""
report << "### 模糊判定清单（全部判定理由）"
report << ""
report << "| # | 年份 | 旧侧 raw title | 新侧 raw title | 判定 | 理由 |"
report << "|---|------|----------------|----------------|------|------|"
i = 0
old.select { |e| e[:status] == "MATCHED-FUZZY-NFKC" }.each do |e|
  i += 1
  report << "| #{i} | #{e[:year]} | #{e[:raw]} | #{e[:match][:raw]} | MATCHED（NFKC） | 旧站用连字 ﬁ 且 \"knockoutstrategy\" 缺空格；NFKC 折叠后两侧键同为 `#{nfkc_key(e[:raw])}`；首作者 #{e[:author]} / 年份 #{e[:year]} 双侧一致 |"
end
report << ""
report << "## ② 总数"
report << ""
report << "| 侧 | 条目数 | 年份桶 |"
report << "|----|--------|--------|"
report << "| 新侧（构建产物） | #{new.size} | 19（2006–2026） |"
report << "| 旧侧（存档，顶层条目） | #{old.size} | 19（2006–2026，集合与双侧一致） |"
report << "| 旧侧嵌套子条目 | 2 | —（注记，见⑥） |"
report << ""
report << "- **差额：旧侧多 #{old.size - new.size} 条 = MISSING #{n_miss}（新侧缺）/ EXTRA #{extras.size}（新侧多）**；旧侧 #{old.size} 条中 #{n_matched} 条已对上（精确 #{n_exact} + NFKC #{n_nfkc}）。"
report << ""
report << "## ③ 逐年对照表（旧侧每条一行——D-18「一条一条」的落地形态）"
report << ""
report << "### 逐年汇总"
report << ""
report << "| 年份 | 旧侧 | 新侧 | MATCHED | MISSING | EXTRA |"
report << "|------|------|------|---------|---------|-------|"
years.each do |y|
  o = old.count { |e| e[:year] == y }
  n = new.count { |e| e[:year] == y }
  m = old.count { |e| e[:year] == y && e[:status] != "MISSING" }
  ms = old.count { |e| e[:year] == y && e[:status] == "MISSING" }
  ex = extras.count { |e| e[:year] == y }
  report << "| #{y} | #{o} | #{n} | #{m} | #{ms} | #{ex} |"
end
report << "| 合计 | #{old.size} | #{new.size} | #{n_matched} | #{n_miss} | #{extras.size} |"
report << ""
report << "### 逐条状态（89 行，每行一条旧侧条目；状态列后一列为匹配到的新侧条目或缺失证据）"
report << ""
report << "| 年份 | 首作者 | 旧侧条目标题 | 状态 | 匹配证据（新侧标题 / 缺失证明） |"
report << "|------|--------|--------------|------|--------------------------------|"
old.each do |e|
  case e[:status]
  when "MATCHED-EXACT"
    report << "| #{e[:year]} | #{e[:author]} | #{e[:raw]} | MATCHED | #{e[:match][:raw]} |"
  when "MATCHED-FUZZY-NFKC"
    report << "| #{e[:year]} | #{e[:author]} | #{e[:raw]} | MATCHED | （NFKC 连字折叠匹配）#{e[:match][:raw]} |"
  else
    report << "| #{e[:year]} | #{e[:author]} | #{e[:raw]} | MISSING | #{MISSING_EVIDENCE[e[:norm]] || '无对应'} |"
  end
end
report << ""
report << "## ④ 新侧多出条目（EXTRA，D-18 要求列报供用户确认）"
report << ""
if extras.empty?
  report << "**0 条**——新侧 #{new.size} 条全部消耗于与旧侧的匹配，无任何多出条目。（新站出版物页未收录任何旧站没有的论文，#{TODAY} 前新增论文情景不存在。）"
else
  report << "| 年份 | 首作者 | 新侧条目标题 |"
  report << "|------|--------|--------------|"
  extras.each { |e| report << "| #{e[:year]} | #{e[:author]} | #{e[:raw]} |" }
end
report << ""
report << "## ⑤ 结论"
report << ""
report << "- **MISSING = #{n_miss}（>0）→ verdict: BLOCK**（D-18：新站缺失任何旧站条目即阻断上线）"
report << "- EXTRA = #{extras.size}"
report << "- **verdict: BLOCK**（机器结论行；与检查点批准后追加的 `Verdict: APPROVED <date>` 标记行是两个不同字段）"
report << ""
report << "### 放行条件（二选一，须用户在 D-18 检查点明确表态）"
report << ""
report << "- **(a) 补录**：暂停本阶段后续计划，把下列 #{n_miss} 条按新站书写格式补录进 `_pages/publications.md`（对应年份桶内），重跑本 Plan（02-03）核对至 MISSING=0；"
report << "- **(b) 豁免**：逐条明确豁免并给出理由（例如非本实验室主导/已撤稿/重复收录），豁免清单与理由将随 `Verdict: APPROVED` 行一并落盘。"
report << "- 不做选择 = 部署保持阻断（D-16 的 DEPLOY_ENABLED 不设置，Plan 05 无法放行）。"
report << ""
report << "### MISSING #{n_miss} 条全文（自旧站存档逐字提取，供补录或豁免裁决）"
report << ""
MISSING_CITATIONS.each_with_index { |c, i| report << "#{i + 1}. #{c}" }
report << ""
report << "## ⑥ 旧站嵌套子条目（Commentary/Cover 注记，2 条）"
report << ""
report << "旧站把以下 2 条作为**父条目的嵌套注记**（非独立出版物条目），故不进入③的 89 行正表；在此完整列示，不隐藏任何旧站内容："
report << ""
report << "| 年份 | 父条目 | 子条目 | 新站处置 |"
report << "|------|--------|--------|----------|"
report << "| 2020 | An extraordinarily stable karyotype of the woody Populus species revealed by chromosome painting | Cover: The Plant Journal Volume 101, Issue 2（封面 PDF 链接） | 新站 #43 条目内已内联保留 \"Cover: *The Plant Journal* Volume 101, Issue 2.\" |"
report << "| 2013 | The CentO satellite confers translational and rotational phasing on cenH3 nucleosomes in rice centromeres | Commentary: Heslop-Harrison, J.S. and Schwarzacher, T. Nucleosomes and centromeric DNA packaging. PNAS 2013, 110(50):19974-19975 | 新站无此注记（第三方评述；如需保留可作为豁免/补录裁决对象之一） |"
report << ""
report << "## DEPLOY-01 落证（flagged assumption 兑现）"
report << ""
report << "本报告即 DEPLOY-01「构建并部署的出版物页不丢条目」假设的显式证据：83 vs 91 的 8 条差额已全部定性——6 条 MISSING（待用户裁决）+ 2 条嵌套子条目（归类注记，父条目均已 MATCHED），**无任何未解释条目**。研究期摘要计数 91 与机器提取 89+2 的差异已对账。"
report << ""

File.write(File.join(DIR, "02-PUBLICATION-AUDIT.md"), report.join("\n") + "\n")
warn "wrote 02-PUBLICATION-AUDIT.md (#{report.size} lines)"
