# 02-PUBLICATION-AUDIT — D-18 出版物逐条核对报告

**Plan:** 02-03 · **决策依据:** D-18（02-CONTEXT.md，2026-08-19 锁定） · **生成:** 2026-08-19，机器生成自 pub-extract.rb + pub-compare.rb（本目录，可复现）

## ① 方法

### 语料声明（纠偏）

- **新侧** = `_site/publications/index.html`——`_pages/publications.md` 手写 markdown 的构建产物（83 条）。**不是** papers/ref.bib 渲染：ref.bib 仅 12 条 @article，只被 `_pages/talks.md` 的两个 `{% bibliography %}` 查询引用，与本页无关（02-RESEARCH.md Pattern 4 语料纠偏表）。
- **旧侧** = `old-site-publication.html`——线上 `https://zhangtaolab.org/Publication` 的 byte 存档（2026-08-19 抢收，HTTP 200 前置检查通过，热切换前完成，commit a81b576）。
- **研究期计数 ~91 的解释**：91 = 89 条顶层条目 + 2 条嵌套子条目（Commentary/Cover 注记，见第⑥节）。fetch 摘要计数把嵌套 `<li>` 一并计入；机器提取以顶层条目为比对对象，子条目单独归类、不隐藏。

### 提取与规范化（pub-extract.rb，两侧同一脚本同一规则）

- 按 `<h2>YYYY</h2>` 年份桶分桶（两侧桶集合完全一致：19 个年份 2006–2026，无缺桶多桶）；深度感知解析 `<li>`（旧站存在嵌套 `<ul>` 子条目结构，顶层/嵌套分开归类）。
- 条目标题 = 条目内第一个 `<a>` 的文本；无链接条目 = 期刊斜体 `<em>` 前的最后一句（期刊是条目内**最后一个** `<em>`——标题自身可含斜体，如 *De Novo*）。first-author = 标题前文本的第一个「姓+缩写」词组。
- 规范化 = 去标签 → HTML 实体解码 → 转小写 → 去全部非字母数字字符 → 压空白。清单行格式 `YEAR | normalized-title | first-author | raw-title`。

### 匹配（pub-compare.rb，年份桶内 1:1 消耗制）

1. normalized-title 精确匹配 → 82 条
2. NFKC 兼容折叠后从 raw title 重新取键匹配（旧站排版连字 ﬁ U+FB01 → fi 等）→ 1 条
3. 残留 → executor 逐对人工阅读判定，全部记录于第③⑤节，无静默丢弃

### 模糊判定清单（全部判定理由）

| # | 年份 | 旧侧 raw title | 新侧 raw title | 判定 | 理由 |
|---|------|----------------|----------------|------|------|
| 1 | 2024 | An efﬁcient CRISPR-Cas12a-mediated MicroRNA knockoutstrategy in plants | An efficient CRISPR-Cas12a-mediated MicroRNA knockout strategy in plants. | MATCHED（NFKC） | 旧站用连字 ﬁ 且 "knockoutstrategy" 缺空格；NFKC 折叠后两侧键同为 `anefficientcrisprcas12amediatedmicrornaknockoutstrategyinplants`；首作者 Zheng XL / 年份 2024 双侧一致 |

## ② 总数

| 侧 | 条目数 | 年份桶 |
|----|--------|--------|
| 新侧（构建产物） | 83 | 19（2006–2026） |
| 旧侧（存档，顶层条目） | 89 | 19（2006–2026，集合与双侧一致） |
| 旧侧嵌套子条目 | 2 | —（注记，见⑥） |

- **差额：旧侧多 6 条 = MISSING 6（新侧缺）/ EXTRA 0（新侧多）**；旧侧 89 条中 83 条已对上（精确 82 + NFKC 1）。

## ③ 逐年对照表（旧侧每条一行——D-18「一条一条」的落地形态）

### 逐年汇总

| 年份 | 旧侧 | 新侧 | MATCHED | MISSING | EXTRA |
|------|------|------|---------|---------|-------|
| 2026 | 4 | 4 | 4 | 0 | 0 |
| 2025 | 3 | 3 | 3 | 0 | 0 |
| 2024 | 10 | 10 | 10 | 0 | 0 |
| 2023 | 8 | 8 | 8 | 0 | 0 |
| 2022 | 6 | 2 | 2 | 4 | 0 |
| 2021 | 9 | 9 | 9 | 0 | 0 |
| 2020 | 7 | 7 | 7 | 0 | 0 |
| 2019 | 7 | 7 | 7 | 0 | 0 |
| 2018 | 9 | 9 | 9 | 0 | 0 |
| 2017 | 4 | 4 | 4 | 0 | 0 |
| 2016 | 1 | 1 | 1 | 0 | 0 |
| 2015 | 3 | 3 | 3 | 0 | 0 |
| 2014 | 3 | 3 | 3 | 0 | 0 |
| 2013 | 5 | 3 | 3 | 2 | 0 |
| 2012 | 1 | 1 | 1 | 0 | 0 |
| 2011 | 3 | 3 | 3 | 0 | 0 |
| 2010 | 2 | 2 | 2 | 0 | 0 |
| 2009 | 3 | 3 | 3 | 0 | 0 |
| 2006 | 1 | 1 | 1 | 0 | 0 |
| 合计 | 89 | 83 | 83 | 6 | 0 |

### 逐条状态（89 行，每行一条旧侧条目；状态列后一列为匹配到的新侧条目或缺失证据）

| 年份 | 首作者 | 旧侧条目标题 | 状态 | 匹配证据（新侧标题 / 缺失证明） |
|------|--------|--------------|------|--------------------------------|
| 2026 | Bao Y | Telomere-to-telomere genome assembly of Oryza australiensis reveals transposon-driven centromere repositioning and shared EE–DD ancestry | MATCHED | Telomere-to-telomere genome assembly of Oryza australiensis reveals transposon-driven centromere repositioning and shared EE–DD ancestry |
| 2026 | Liao SY | Boosting genome editing of non-coding sequences in plants with glycosylase-mediated multi-nucleotide deletion editors | MATCHED | Boosting genome editing of non-coding sequences in plants with glycosylase-mediated multi-nucleotide deletion editors |
| 2026 | He Y | Harnessing diverse tRNAs and AI-guided mining for compact and efficient plant multiplex genome editing | MATCHED | Harnessing diverse tRNAs and AI-guided mining for compact and efficient plant multiplex genome editing |
| 2026 | Wang CY | Maize Anther Development Involves Translated Open Reading Frames From 3′ Untranslated Regions | MATCHED | Maize Anther Development Involves Translated Open Reading Frames From 3′ Untranslated Regions |
| 2025 | Zheng XL | Development and activity evaluation of a highly efficient CRISPR-Cas genome editing system in larch | MATCHED | Development and activity evaluation of a highly efficient CRISPR-Cas genome editing system in larch |
| 2025 | Liu GQ | PDLLMs: A group of tailored DNA large language models for analyzing plant genomes | MATCHED | PDLLMs: A group of tailored DNA large language models for analyzing plant genomes |
| 2025 | Yang QQ | Improving rice grain shape through upstream open reading frame editing-mediated translation regulation | MATCHED | Improving rice grain shape through upstream open reading frame editing-mediated translation regulation |
| 2024 | Yang QQ | CRISPR-Based Modulation of uORFs in DEP1 and GIF1 for Enhanced Rice Yield Traits | MATCHED | CRISPR-Based Modulation of uORFs in DEP1 and GIF1 for Enhanced Rice Yield Traits. |
| 2024 | Zheng XL | An efﬁcient CRISPR-Cas12a-mediated MicroRNA knockoutstrategy in plants | MATCHED | （NFKC 连字折叠匹配）An efficient CRISPR-Cas12a-mediated MicroRNA knockout strategy in plants. |
| 2024 | He Y | Versatile plant genome engineering using anti-CRISPR-Cas12a systems | MATCHED | Versatile plant genome engineering using anti-CRISPR-Cas12a systems. |
| 2024 | Zhao DS | A CRISPR/Cas9-mediated mutant library of seed-preferredgenes in rice | MATCHED | A CRISPR/Cas9-mediated mutant library of seed-preferred genes in rice. |
| 2024 | Fan TT | High performance TadA-8e derived cytosine and dual base editors with undetectable off-target effects in plants | MATCHED | High performance TadA-8e derived cytosine and dual base editors with undetectable off-target effects in plants. |
| 2024 | He Y | Expanding plant genome editing scope and profiles with CRISPR-FrCas9 systems targeting palindromic TA sites | MATCHED | Expanding plant genome editing scope and profiles with CRISPR-FrCas9 systems targeting palindromic TA sites |
| 2024 | Xin HY | Celine, a long interspersed nuclear element retrotransposon, colonizes in the centromeres of poplar chromosomes | MATCHED | Celine, a long interspersed nuclear element retrotransposon, colonizes in the centromeres of poplar chromosomes |
| 2024 | You HL | Chromosome ends initiate homologous chromosome pairing during rice meiosis | MATCHED | Chromosome ends initiate homologous chromosome pairing during rice meiosis |
| 2024 | Han YS | CrisprStitch: Fast evaluation of the efficiency of CRISPR editing systems | MATCHED | CrisprStitch: Fast evaluation of the efficiency of CRISPR editing systems |
| 2024 | Chen L | Integrating machine learning and genome editing for crop improvement | MATCHED | Integrating machine learning and genome editing for crop improvement |
| 2023 | Wang ZY | Male-Specific Sequence in Populus simonii Provides Insights into Gender Determination of Poplar | MATCHED | Male-Specific Sequence in Populus simonii Provides Insights into Gender Determination of Poplar |
| 2023 | Gurel F | On- and Off-Target Analyses of CRISPR-Cas12b Genome Editing Systems in Rice | MATCHED | On- and Off-Target Analyses of CRISPR-Cas12b Genome Editing Systems in Rice |
| 2023 | Zhong ZH | Efficient plant genome engineering using a probiotic sourced CRISPR-Cas9 system | MATCHED | Efficient plant genome engineering using a probiotic sourced CRISPR-Cas9 system |
| 2023 | Zhang YX | Genome-wide investigation of multiplexed CRISPR-Cas12a-mediated editing in rice | MATCHED | Genome-wide investigation of multiplexed CRISPR-Cas12a-mediated editing in rice |
| 2023 | Sretenovic S | Genome- and transcriptome-wide off-target analyses of a high-efficiency adenine base editor in tomato | MATCHED | Genome- and transcriptome-wide off-target analyses of a high-efficiency adenine base editor in tomato |
| 2023 | Chen C | Chromosome-specific painting in Thinopyrum species using bulked oligonucleotides | MATCHED | Chromosome-specific painting in Thinopyrum species using bulked oligonucleotides |
| 2023 | Bao Y | Genome-wide chromatin accessibility landscape and dynamics of transcription factor networks during ovule and fiber development in cotton | MATCHED | Genome-wide chromatin accessibility landscape and dynamics of transcription factor networks during ovule and fiber development in cotton. |
| 2023 | Zhou JP | An efficient CRISPR–Cas12a promoter editing system for crop improvement | MATCHED | An efficient CRISPR–Cas12a promoter editing system for crop improvement. |
| 2022 | Liu S | The Methylation Inhibitor 5-Aza-2′-Deoxycytidine Induces Genome-Wide Hypomethylation in Rice | MATCHED | The Methylation Inhibitor 5-Aza-2′-Deoxycytidine Induces Genome-Wide Hypomethylation in Rice. |
| 2022 | Xue C | De Novo Centromere Formation in Pericentromeric Region of Rice Chromosome 8. | MATCHED | De Novo Centromere Formation in Pericentromeric Region of Rice Chromosome 8. |
| 2022 | Wu YC | Genome-wide analyses of PAM-relaxed Cas9 genome editors reveal substantial off-target effects by ABE8e in rice. | MISSING | grep 'ABE8e' _pages/publications.md → 0 命中 |
| 2022 | Tao ST | Single-Cell Transcriptome and Network Analyses Unveil Key Transcription Factors Regulating Mesophyll Cell Development in Maize. | MISSING | grep 'Mesophyll' _pages/publications.md → 0 命中 |
| 2022 | Feng YL | Epigenomic features of DNA G-quadruplexes and their roles in regulating rice gene transcription. | MISSING | grep 'G-quadruplex' _pages/publications.md → 0 命中 |
| 2022 | Wu YC | CRISPR-BETS: A base editing design tool for generating stop codons. | MISSING | grep 'CRISPR-BETS' _pages/publications.md（正文条目区）→ 0 命中（仅旧站导航菜单提及） |
| 2021 | Ding Y | Targeting Cis -Regulatory Elements for Rice Grain Quality Improvement. | MATCHED | Targeting Cis -Regulatory Elements for Rice Grain Quality Improvement. |
| 2021 | Liu GQ | Single Copy Oligonucleotide Fluorescence In Situ Hybridization Probe Design Platforms: Development, Application and Evaluation. | MATCHED | Single Copy Oligonucleotide Fluorescence In Situ Hybridization Probe Design Platforms: Development, Application and Evaluation. |
| 2021 | Randall L.B | Genome- and transcriptome-wide off-target analyses of an improved cytosine base editor. | MATCHED | Genome- and transcriptome-wide off-target analyses of an improved cytosine base editor. |
| 2021 | Ren QR | Improved plant cytosine base editors with high editing activity, purity, and specificity. | MATCHED | Improved plant cytosine base editors with high editing activity, purity, and specificity. |
| 2021 | Zhang T | Chorus2: design of genome‐scale oligonucleotide‐based probes for fluorescence in situ hybridization. | MATCHED | Chorus2: design of genome–scale oligonucleotide–based probes for fluorescence in situ hybridization |
| 2021 | Meng FL | Genomic Editing of Intronic Enhancers Unveils Their Role in Fine-Tuning Tissue-Specific Gene Expression in Arabidopsis thaliana . | MATCHED | Genomic Editing of Intronic Enhancers Unveils Their Role in Fine-Tuning Tissue-Specific Gene Expression in Arabidopsis thaliana |
| 2021 | Zhang C | DEEP GREEN PANICLE1 suppresses GOLDEN2-LIKE activity to reduce chlorophyll synthesis in rice glumes. | MATCHED | DEEP GREEN PANICLE1 suppresses GOLDEN2-LIKE activity to reduce chlorophyll synthesis in rice glumes |
| 2021 | Liu GQ | Analysis of Off-Target Mutations in CRISPR-Edited Rice Plants Using Whole-Genome Sequencing. | MATCHED | Analysis of Off-Target Mutations in CRISPR-Edited Rice Plants Using Whole-Genome Sequencing |
| 2021 | Li GR | An efficient Oligo‐FISH painting system for revealing chromosome rearrangements and polyploidization in Triticeae. | MATCHED | An efficient Oligo–FISH painting system for revealing chromosome rearrangements and polyploidization in Triticeae |
| 2020 | Liu YL | Chromosome Painting Based on Bulked Oligonucleotides in Cotton. | MATCHED | Chromosome Painting Based on Bulked Oligonucleotides in Cotton |
| 2020 | Zhao HN | Genome-wide MNase hypersensitivity assay unveils distinct classes of open chromatin associated with H3K27me3 and DNA methylation in Arabidopsis thaliana . | MATCHED | Genome-wide MNase hypersensitivity assay unveils distinct classes of open chromatin associated with H3K27me3 and DNA methylation in Arabidopsis thaliana |
| 2020 | Song XY | Development and application of oligonucleotide-based chromosome painting for chromosome 4D of Triticum aestivum L. | MATCHED | Development and application of oligonucleotide-based chromosome painting for chromosome 4D of Triticum aestivum L. |
| 2020 | Braz G.T | A universal chromosome identification system for maize and wild Zea species. | MATCHED | A universal chromosome identification system for maize and wild Zea species |
| 2020 | Liu GQ | Computational approaches for effective CRISPR guide RNA design and evaluation. | MATCHED | Computational approaches for effective CRISPR guide RNA design and evaluation |
| 2020 | Liu XY | Dual‐color oligo‐FISH can reveal chromosomal variations and evolution in Oryza species. | MATCHED | Dual–color oligo–FISH can reveal chromosomal variations and evolution in Oryza species |
| 2020 | Xin HY | An extraordinarily stable karyotype of the woody Populus species revealed by chromosome painting. | MATCHED | An extraordinarily stable karyotype of the woody Populus species revealed by chromosome painting |
| 2019 | Liu S | Genome-wide Profiling of Histone Lysine Butyrylation Reveals its Role in the Positive Regulation of Gene Transcription in Rice. | MATCHED | Genome-wide Profiling of Histone Lysine Butyrylation Reveals its Role in the Positive Regulation of Gene Transcription in Rice |
| 2019 | Alvarez J.M | Local changes in chromatin accessibility and transcriptional networks underlying the nitrate response in Arabidopsis roots. | MATCHED | Local changes in chromatin accessibility and transcriptional networks underlying the nitrate response in Arabidopsis roots |
| 2019 | Ren QR | Bidirectional promoter based CRISPR-Cas9 systems for plant genome editing | MATCHED | Bidirectional promoter based CRISPR-Cas9 systems for plant genome editing |
| 2019 | Zhong ZH | Improving plant genome editing with high-fidelity xCas9 and non-canonical PAM-targeting Cas9-NG. | MATCHED | Improving plant genome editing with high-fidelity xCas9 and non-canonical PAM-targeting Cas9-NG |
| 2019 | Albert P.S | Whole-chromosome paints in maize reveal rearrangements, nuclear domains, and chromosomal relationships. | MATCHED | Whole-chromosome paints in maize reveal rearrangements, nuclear domains, and chromosomal relationships |
| 2019 | Malzahn AA | Application of CRISPR-Cas12a temperature sensitivity for improved genome editing in rice, maize, and Arabidopsis . | MATCHED | Application of CRISPR-Cas12a temperature sensitivity for improved genome editing in rice, maize, and Arabidopsis |
| 2019 | Tang X | Single transcript unit CRISPR 2.0 systems for robust Cas9 and Cas12a mediated plant genome editing. | MATCHED | Single transcript unit CRISPR 2.0 systems for robust Cas9 and Cas12a mediated plant genome editing |
| 2018 | Wu ZG | De novo genome assembly of Oryza granulata reveals rapid genome expansion and adaptive evolution. | MATCHED | De novo genome assembly of Oryza granulata reveals rapid genome expansion and adaptive evolution. |
| 2018 | Tang X | A large-scale whole-genome sequencing analysis reveals highly specific genome editing by both Cas9 and Cpf1(Cas12a) nucleases in rice. | MATCHED | A large-scale whole-genome sequencing analysis reveals highly specific genome editing by both Cas9 and Cpf1(Cas12a) nucleases in rice. |
| 2018 | You Q | CRISPRMatch: An Automatic Calculation And Visualization Tool For High-throughput CRISPR Genome-editing Data Analysis. | MATCHED | CRISPRMatch: An Automatic Calculation And Visualization Tool For High-throughput CRISPR Genome-editing Data Analysis. |
| 2018 | Yang XM | Amplification and adaptation of centromeric repeats in polyploid switchgrass species. | MATCHED | Amplification and adaptation of centromeric repeats in polyploid switchgrass species. |
| 2018 | Hou LL | Chromosome painting and its applications in cultivated and wild rice. | MATCHED | Chromosome painting and its applications in cultivated and wild rice. |
| 2018 | Dong ZB | Transcriptional and epigenetic adaptation of maize chromosomes in Oat-Maize addition lines. | MATCHED | Transcriptional and epigenetic adaptation of maize chromosomes in Oat-Maize addition lines. |
| 2018 | Zhong ZH | Plant genome editing using FnCpf1 and LbCpf1 nucleases at redefined and altered PAM sites. | MATCHED | Plant genome editing using FnCpf1 and LbCpf1 nucleases at redefined and altered PAM sites. |
| 2018 | Xin H | Chromosome painting and comparative physical mapping of the sex chromosomes in Populus tomentosa and Populus deltoides . | MATCHED | Chromosome painting and comparative physical mapping of the sex chromosomes in Populus tomentosa and Populus deltoides . |
| 2018 | Braz GT | Comparative oligo-FISH mapping: an efficient and powerful methodology to reveal karyotypic and chromosomal evolution. | MATCHED | Comparative oligo-FISH mapping: an efficient and powerful methodology to reveal karyotypic and chromosomal evolution. |
| 2017 | Zhang R | Segmental Duplication of Chromosome 11 and its Implications for Cell Division and Genome-wide Expression in Rice. | MATCHED | Segmental Duplication of Chromosome 11 and its Implications for Cell Division and Genome-wide Expression in Rice. |
| 2017 | Tang X | A CRISPR-Cpf1 system for efficient genome editing and transcriptional repression in plants. | MATCHED | A CRISPR-Cpf1 system for efficient genome editing and transcriptional repression in plants |
| 2017 | Marand AP | Towards genome-wide prediction and characterization of enhancers in plants. | MATCHED | Towards genome-wide prediction and characterization of enhancers in plants |
| 2017 | Zhou JP | CRISPR-Cas9 Based Genome Editing Reveals New Insights into MicroRNA Function and Regulation in Rice. | MATCHED | CRISPR-Cas9 Based Genome Editing Reveals New Insights into MicroRNA Function and Regulation in Rice. |
| 2016 | Zhang T | PlantDHS: A Database for DNase I Hypertensive Sites in Plants. | MATCHED | PlantDHS: A Database for DNase I Hypertensive Sites in Plants |
| 2015 | Zhang T | Genome-wide nucleosome occupancy and positioning and their impact on gene expression and evolution in plants. | MATCHED | Genome-wide nucleosome occupancy and positioning and their impact on gene expression and evolution in plants |
| 2015 | Han YH | Chromosome-specific painting in Cucumis species using bulked oligonucleotides. | MATCHED | Chromosome-specific painting in Cucumis species using bulked oligonucleotides |
| 2015 | Zhu B | Genome-wide prediction and validation of intergenic enhancers in Arabidopsis using open chromatin signature. | MATCHED | Genome-wide prediction and validation of intergenic enhancers in Arabidopsis using open chromatin signature |
| 2014 | Zhang T | Adaptive evolution of duplicated hsp17 genes in wild barley from microclimatically divergent sites of Israel. | MATCHED | Adaptive evolution of duplicated hsp17 genes in wild barley from microclimatically divergent sites of Israel. |
| 2014 | Zhang WL | Open Chromatin in Plant Genomes. | MATCHED | Open Chromatin in Plant Genomes. |
| 2014 | Yang LM | Next-generation sequencing, FISH mapping and synteny-based modeling reveal mechanisms of decreasing dysploidy in Cucumis . | MATCHED | Next-generation sequencing, FISH mapping and synteny-based modeling reveal mechanisms of decreasing dysploidy in Cucumis . |
| 2013 | Zhang T | The CentO satellite confers translational and rotational phasing on cenH3 nucleosomes in rice centromeres. | MATCHED | The CentO satellite confers translational and rotational phasing on cenH3 nucleosomes in rice centromeres |
| 2013 | Iovene M | Copy number variation in potato - an asexually propagated autotetraploid species. | MATCHED | Copy number variation in potato - an asexually propagated autotetraploid species. |
| 2013 | Wei W | Transcriptional abundance is not the single force driving the evolution of bacterial proteins. | MATCHED | Transcriptional abundance is not the single force driving the evolution of bacterial proteins. |
| 2013 | Yang ZJ | Transcriptome Comparative Profiling of Barley eibi1 Mutant Reveals Pleiotropic Effects of HvABCG31 Gene on Cuticle Biogenesis and Stress Responsive Pathways. | MISSING | grep 'eibi1'/'HvABCG31' _pages/publications.md → 0 命中 |
| 2013 | Dong ZB | Maize LAZY1 Mediates Shoot Gravitropism and Inflorescence Development through Regulating Auxin Transport, Auxin Signaling, and Light Response. | MISSING | grep 'LAZY1' _pages/publications.md → 0 命中 |
| 2012 | Zhang WL | Genome-Wide Identification of Regulatory DNA Elements and Protein-Binding Footprints Using Signatures of Open Chromatin in Arabidopsis . | MATCHED | Genome-Wide Identification of Regulatory DNA Elements and Protein-Binding Footprints Using Signatures of Open Chromatin in Arabidopsis |
| 2011 | Yang ZJ | Adaptive microclimatic evolution of the dehydrin 6 gene in wild barley at “Evolution Canyon”, Israel. | MATCHED | Adaptive microclimatic evolution of the dehydrin 6 gene in wild barley at “Evolution Canyon”, Israel. |
| 2011 | Wang XH | The chromosome number, karyotype and genome size of the desert plant diploid Reaumuria soongorica (Pall.) Maxim. | MATCHED | The chromosome number, karyotype and genome size of the desert plant diploid Reaumuria soongorica (Pall.) Maxim. |
| 2011 | Tang ZX | Diversity and evolution of four dispersed repetitive DNA sequences in the genus Secale . | MATCHED | Diversity and evolution of four dispersed repetitive DNA sequences in the genus Secale . |
| 2010 | Li GR | Sequence analysis of alpha-gliadin genes from Aegilops tauschii native to China. | MATCHED | Sequence analysis of alpha-gliadin genes from Aegilops tauschii native to China. |
| 2010 | Li GR | Molecular characterization and evolutionary analysis of alpha-gliadin genes from Eremopyrum bonaepartis (Triticeae). | MATCHED | Molecular characterization and evolutionary analysis of alpha-gliadin genes from Eremopyrum bonaepartis (Triticeae). |
| 2009 | Yang ZJ | Adaptive microclimatic structural and expressional dehydrin 1 evolution in wild barley, Hordeum spontaneum , at ‘Evolution Canyon’, Mount Carmel, Israel. | MATCHED | Adaptive microclimatic structural and expressional dehydrin 1 evolution in wild barley, Hordeum spontaneum , at ’Evolution Canyon’, Mount Carmel, Israel. |
| 2009 | Yang ZJ | Molecular cytogenetic characterization of wheat– Secale africanum amphiploids and derived introgression lines with stripe rust resistance. | MATCHED | Molecular cytogenetic characterization of wheat– Secale africanum amphiploids and derived introgression lines with stripe rust resistance. |
| 2009 | Li GR | Identification of α-gliadin genes in Dasypyrum in relation to evolution and breeding. | MATCHED | Identification of α-gliadin genes in Dasypyrum in relation to evolution and breeding. |
| 2006 | Hu GK | Molecular cloning of cDNAs for 14-3-3 and its protein interactions in a white-rot fungus Phanerochaete chrysosporium . | MATCHED | Molecular cloning of cDNAs for 14-3-3 and its protein interactions in a white-rot fungus Phanerochaete chrysosporium . |

## ④ 新侧多出条目（EXTRA，D-18 要求列报供用户确认）

**0 条**——新侧 83 条全部消耗于与旧侧的匹配，无任何多出条目。（新站出版物页未收录任何旧站没有的论文，2026-08-19 前新增论文情景不存在。）

## ⑤ 结论

- **MISSING = 6（>0）→ verdict: BLOCK**（D-18：新站缺失任何旧站条目即阻断上线）
- EXTRA = 0
- **verdict: BLOCK**（机器结论行；与检查点批准后追加的 `Verdict: APPROVED <date>` 标记行是两个不同字段）

### 放行条件（二选一，须用户在 D-18 检查点明确表态）

- **(a) 补录**：暂停本阶段后续计划，把下列 6 条按新站书写格式补录进 `_pages/publications.md`（对应年份桶内），重跑本 Plan（02-03）核对至 MISSING=0；
- **(b) 豁免**：逐条明确豁免并给出理由（例如非本实验室主导/已撤稿/重复收录），豁免清单与理由将随 `Verdict: APPROVED` 行一并落盘。
- 不做选择 = 部署保持阻断（D-16 的 DEPLOY_ENABLED 不设置，Plan 05 无法放行）。

### MISSING 6 条全文（自旧站存档逐字提取，供补录或豁免裁决）

1. Wu YC†, Ren QR†, Zhong ZH†, Liu GQ†, Han YS, Bao Y, Liu L, Xiang SY, Liu S, Tang X, Zhou JP, Zheng XL, Sretenovic S, Zhang T*, Qi YP*, Zhang Y*. Genome-wide analyses of PAM-relaxed Cas9 genome editors reveal substantial off-target effects by ABE8e in rice. *Plant Biotechnology Journal* 2022, 20(9): 1670-1682.
2. Tao ST†, Liu P†, Shi YN, Feng YL, Gao JJ, Chen LF, Zhang AC, Cheng XJ, Wei HR, Zhang T*, Zhang WL*. Single-Cell Transcriptome and Network Analyses Unveil Key Transcription Factors Regulating Mesophyll Cell Development in Maize. *Genes* 2022, 13(2):374.
3. Feng YL, Tao ST, Zhang PY, Sperti FR, Liu GQ, Cheng XJ, Zhang T, Yu HX, Wang XE, Cheng CY, Monchaud D, Zhang WL*. Epigenomic features of DNA G-quadruplexes and their roles in regulating rice gene transcription. *Plant Physiology* 2022, 188(3): 1632–1648.
4. Wu YC†, He Y†, Sretenovic S, Liu SS, Cheng YH, Han YS, Liu GQ, Bao Y, Fang Q, Zheng XL, Zhou JP, Qi YP*, Zhang Y*, Zhang T*. CRISPR-BETS: A base editing design tool for generating stop codons. *Plant Biotechnology Journal* 2022, 20(3):499-510.
5. Yang ZJ, Zhang T, Lang T, Li G, Chen G, Nevo E. Transcriptome Comparative Profiling of Barley eibi1 Mutant Reveals Pleiotropic Effects of HvABCG31 Gene on Cuticle Biogenesis and Stress Responsive Pathways. *International Journal of Molecular Sciences* 2013, 14(10):20478-20491.
6. Dong ZB, Jiang C, Chen X, Zhang T, Ding L, Song W, Luo H, Lai J, Chen H, Liu R, Jin WW. Maize LAZY1 Mediates Shoot Gravitropism and Inflorescence Development through Regulating Auxin Transport, Auxin Signaling, and Light Response. *Plant Physiology* 2013, 163(3):1306-1322.

## ⑥ 旧站嵌套子条目（Commentary/Cover 注记，2 条）

旧站把以下 2 条作为**父条目的嵌套注记**（非独立出版物条目），故不进入③的 89 行正表；在此完整列示，不隐藏任何旧站内容：

| 年份 | 父条目 | 子条目 | 新站处置 |
|------|--------|--------|----------|
| 2020 | An extraordinarily stable karyotype of the woody Populus species revealed by chromosome painting | Cover: The Plant Journal Volume 101, Issue 2（封面 PDF 链接） | 新站 #43 条目内已内联保留 "Cover: *The Plant Journal* Volume 101, Issue 2." |
| 2013 | The CentO satellite confers translational and rotational phasing on cenH3 nucleosomes in rice centromeres | Commentary: Heslop-Harrison, J.S. and Schwarzacher, T. Nucleosomes and centromeric DNA packaging. PNAS 2013, 110(50):19974-19975 | 新站无此注记（第三方评述；如需保留可作为豁免/补录裁决对象之一） |

## DEPLOY-01 落证（flagged assumption 兑现）

本报告即 DEPLOY-01「构建并部署的出版物页不丢条目」假设的显式证据：83 vs 91 的 8 条差额已全部定性——6 条 MISSING（待用户裁决）+ 2 条嵌套子条目（归类注记，父条目均已 MATCHED），**无任何未解释条目**。研究期摘要计数 91 与机器提取 89+2 的差异已对账。

