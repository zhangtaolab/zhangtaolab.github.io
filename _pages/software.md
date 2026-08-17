---
layout: gridlay
permalink: /software/
---

## Software & Tools

We develop and maintain open-source bioinformatics software and tools. Each software below is associated with peer-reviewed publications. All code is freely available on <a href="https://github.com/zhangtaolab" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>.

<style>
.software-card { display: flex; gap: 1.25rem; align-items: stretch; }
.software-body { flex: 1; min-width: 0; }
.software-body h4 { margin-top: 0; margin-bottom: 0.5rem; font-size: 1.05rem; }
.software-thumb { width: 260px; min-width: 260px; border-radius: 10px; overflow: hidden; border: 1px solid var(--border-color); display: flex; align-items: center; justify-content: center; background: #f8f8f6; }
.software-thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
.software-thumb-placeholder { width: 260px; min-width: 260px; border-radius: 10px; border: 2px dashed var(--border-color); display: flex; align-items: center; justify-content: center; color: var(--text-secondary); font-size: 0.8rem; background: #f8f8f6; }
.section-card { padding: 1.25rem !important; }
@media (max-width: 767px) {
  .software-card { flex-direction: column; align-items: flex-start; }
  .software-thumb, .software-thumb-placeholder { width: 100%; min-width: 0; height: 200px; }
}
p, li, .pub-authors { max-width: none !important; }
</style>

### <i class="fa-solid fa-brain"></i> DNA Large Language Models

<div class="software-grid">

<div class="section-card" style="border: 2px solid var(--accent);">
<div style="background: var(--accent); color: white; font-size: 0.7rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; padding: 4px 12px; display: inline-block; border-radius: 0 0 8px 0;">Core Toolkit</div>
<div class="software-card" style="margin-top: var(--space-3);">
<div class="software-body">
<h4>DNALLM-Suite</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A comprehensive toolkit for DNA large language model training, fine-tuning, and deployment. Provides end-to-end solutions for genomic sequence modeling and analysis.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/DNALLM" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
</div>
<div class="software-thumb">
<img src="{{ site.url }}{{ site.baseurl }}/images/software/dnallm-suite.png" alt="DNALLM-Suite screenshot" loading="lazy">
</div>
</div>
</div>

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>PDLLMs</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">Plant DNA Large Language Models — pre-trained foundation models and fine-tuned variants for plant genomic sequence analysis and functional element prediction.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://pubmed.ncbi.nlm.nih.gov/39733335/" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.78rem; color: #999; margin-top: 0.5rem;"><em>Citation: Liu GQ et al. Mol Plant 2025;18(2):175-178</em></p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>dnallmmark</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">Benchmarking framework for evaluating and comparing DNA large language models on standard genomic prediction tasks.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/dnallmmark" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>MambaForSequenceClassification</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">Mamba-based sequence classification models optimized for long genomic sequences, offering efficient linear-time attention for DNA analysis tasks.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/MambaForSequenceClassification" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

</div>

### <i class="fa-solid fa-scissors"></i> Genome Editing

<div class="software-grid">

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>CrisprStitch</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A computational pipeline for designing and analyzing multiplex CRISPR/Cas genome editing experiments. Streamlines guide RNA design and genotyping analysis for high-throughput editing studies.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/CrisprStitch" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://pubmed.ncbi.nlm.nih.gov/38146164/" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.78rem; color: #999; margin-top: 0.5rem;"><em>Citation: Han YS et al. Plant Commun 2024;5(3):100783</em></p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

</div>

### <i class="fa-solid fa-dna"></i> Oligo-FISH &amp; Genomics

<div class="software-grid">

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>Chorus2</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A high-throughput computational pipeline for designing oligonucleotide probes for fluorescence in situ hybridization (FISH). Enables efficient probe design for chromosome painting and targeted visualization across diverse plant genomes.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/Chorus2" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://pubmed.ncbi.nlm.nih.gov/33960617/" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.78rem; color: #999; margin-top: 0.5rem;"><em>Citation: Zhang T et al. Plant Biotechnol J 2021;19(10):1967-1978</em></p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>rustkmer</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A high-performance Rust-based toolkit for k-mer counting and analysis in large-scale genomic datasets. Optimized for speed and memory efficiency in next-generation sequencing data processing.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/rustkmer" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

</div>

### <i class="fa-solid fa-robot"></i> AI Infrastructure

<div class="software-grid">

<div class="section-card">
<div class="software-card">
<div class="software-body">
<h4>SIF</h4>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;"><strong>S</strong>emantic <strong>I</strong>ntelligence <strong>F</strong>ramework — an infrastructure toolkit for building and deploying AI-powered genomic sequence analysis pipelines with modular components.</p>
<div class="section-links">
<a href="https://github.com/zhangtaolab/SIF" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

</div>

<div class="callout callout-success" style="margin-top: var(--space-8);">
  <div class="callout-title"><i class="fa-brands fa-github callout-icon"></i> Open Source</div>
  <p>All software is freely available on our <a href="https://github.com/zhangtaolab" target="_blank"><i class="fa-brands fa-github"></i> GitHub organization</a>. Contributions, bug reports, and feature requests are welcome.</p>
</div>
