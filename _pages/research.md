---
title: "Research"
layout: gridlay
permalink: /research/
---

<style>
:root { --accent: #2d6a4f; --accent-hover: #2d6a4f; }
  /* Override template's default research styles with high-specificity selectors */
  main .research-grid { display: grid !important; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)) !important; grid-auto-rows: 1fr !important; gap: 1.5rem !important; align-items: stretch !important; }
  main .research-grid .research-card { border: 2px solid var(--accent) !important; border-radius: var(--radius) !important; overflow: hidden !important; display: flex !important; flex-direction: column !important; background: var(--card-bg) !important; height: 100% !important; }
  main .research-grid .research-card .core-badge { background: var(--accent); color: white; font-size: 0.65rem; font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase; padding: 5px 10px; display: block; min-height: 22px; line-height: 12px; }
  main .research-grid .research-card .img-wrap { height: 180px !important; min-height: 180px !important; background: #f0f0eb !important; display: flex !important; align-items: center !important; justify-content: center !important; overflow: hidden !important; border-bottom: 1px solid var(--border) !important; margin: 0 !important; border-radius: 0 !important; padding: 10px !important; }
  main .research-grid .research-card .img-wrap img { width: 100% !important; height: 100% !important; object-fit: cover !important; border-radius: 6px !important; margin: 0 !important; }
  main .research-grid .research-card .research-body { padding: 1.25rem !important; flex: 1 !important; display: flex !important; flex-direction: column !important; }
  main .research-grid .research-card h4 { font-size: 1.05rem !important; font-weight: 700 !important; margin-bottom: 0.5rem !important; color: var(--text-primary) !important; }
  main .research-grid .research-card p { font-size: 0.88rem !important; color: var(--text-secondary) !important; line-height: 1.6 !important; flex: 1 !important; }
  /* Override template's default research-thumb/research-body styles */
  main .research-grid .research-thumb { display: none !important; }
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

<h1 class="page-title">Research</h1>

<p>Our laboratory is at the forefront of <strong>DNA Large Language Models (LLMs)</strong> and their applications in plant genomics. We develop foundation models for DNA sequence understanding and apply them to diverse biological questions, from regulatory element prediction to genome engineering. Below are our key research areas:</p>

<div class="research-grid" markdown="0">

<div class="research-card core">
<div class="core-badge">Core Focus</div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/dna-llm.jpg" alt="DNA LLM" loading="lazy">
</div>
<div class="research-body">
<h4>DNA Large Language Models</h4>
<p>We develop and apply large language models for DNA sequence analysis. This includes <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs (Plant DNA LLMs)</a> — a suite of foundation models tailored for plant genomes published in <em>Molecular Plant</em> — and <a href="https://github.com/zhangtaolab/DNALLM" target="_blank">DNALLM-Suite</a>, a comprehensive toolkit for fine-tuning and inference with DNA Language Models featuring CLI, Web UI, and MCP protocol support.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/ai-genomics.jpg" alt="AI-Driven Genomics" loading="lazy">
</div>
<div class="research-body">
<h4>AI-Driven Genomics</h4>
<p>We apply machine learning and deep learning to solve fundamental questions in genomics. This includes developing predictive models for gene regulation, chromatin accessibility, and genome evolution. Our work bridges the gap between cutting-edge AI methods and biological discovery.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/regulatory-elements.jpg" alt="Cis-regulatory Elements" loading="lazy">
</div>
<div class="research-body">
<h4><em>Cis</em>-regulatory Elements</h4>
<p><em>Cis</em>-regulatory elements (CRMs) control gene expression during specific developmental stages or under various biotic and abiotic stresses. We identify and characterize these elements based on their unique molecular signatures associated with open chromatin, leveraging LLM-based approaches for improved prediction accuracy.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/fish-probes.jpg" alt="Oligo-FISH Probe Design" loading="lazy">
</div>
<div class="research-body">
<h4>Oligo-FISH Probe Design</h4>
<p>Oligo probes designed from conserved DNA sequences can be used among genetically related species, enabling comparative cytogenetic mapping. We develop computational pipelines for genome-scale oligonucleotide-based probe design for fluorescence in situ hybridization (FISH), significantly expanding the applications of FISH in non-model plant species.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/crispr.jpg" alt="CRISPR/Cas Genome Editing" loading="lazy">
</div>
<div class="research-body">
<h4>CRISPR/Cas Genome Editing</h4>
<p>We develop and optimize CRISPR/Cas-based genome editing systems for plants, including base editors, prime editors, and multiplex editing strategies. Our work includes gRNA design algorithms, efficiency prediction models, and the development of <a href="https://github.com/zhangtaolab/CrisprStitch" target="_blank">CrisprStitch</a> for the research community.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/plant-genomics.jpg" alt="Plant Genomics and Comparative Genomics" loading="lazy">
</div>
<div class="research-body">
<h4>Plant Genomics &amp; Comparative Genomics</h4>
<p>We study the structure, function, and evolution of plant genomes using large-scale sequencing and comparative approaches. Our recent work includes telomere-to-telomere genome assemblies and the application of large language models for DNA sequence analysis in plants.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/epigenetics.jpg" alt="Epigenetics and Chromatin Biology" loading="lazy">
</div>
<div class="research-body">
<h4>Epigenetics &amp; Chromatin Biology</h4>
<p>We investigate the epigenetic regulation of gene expression in plants, focusing on DNA methylation, histone modifications, and chromatin accessibility. Our research explores how epigenetic changes contribute to plant development and stress responses.</p>
</div>
</div>

<div class="research-card">
<div class="core-badge"></div>
<div class="img-wrap">
<img src="{{ site.url }}{{ site.baseurl }}/images/research/bioinformatics-tools.jpg" alt="Bioinformatics Tool Development" loading="lazy">
</div>
<div class="research-body">
<h4>Bioinformatics Tool Development</h4>
<p>We develop and maintain open-source bioinformatics software for the plant science community, including tools for probe design (Chorus2), CRISPR analysis (CrisprStitch), and plant DNA language models (PDLLMs, DNALLM-Suite). All tools are freely available.</p>
</div>
</div>

</div>
