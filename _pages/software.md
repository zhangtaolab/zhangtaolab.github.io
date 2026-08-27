---
title: "Software"
layout: gridlay
permalink: /software/
---

<h1 class="page-title">Software</h1>

<p>We develop and maintain open-source bioinformatics software and tools. Each software below is associated with peer-reviewed publications. All code is freely available on <a href="https://github.com/zhangtaolab" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>.</p>

<style>
    .software-card { display: flex; gap: 1.25rem; align-items: stretch; margin-bottom: 0; }
    .software-body { flex: 1; min-width: 0; }
    .software-body h4 { margin-top: 0; margin-bottom: 0.5rem; font-size: 1.05rem; }
    .software-thumb { width: 260px; min-width: 260px; border-radius: 10px; overflow: hidden; border: 1px solid var(--border); display: flex; align-items: center; justify-content: center; background: #f8f8f6; }
    .software-thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .software-thumb-placeholder { width: 260px; min-width: 260px; border-radius: 10px; border: 2px dashed var(--border); display: flex; align-items: center; justify-content: center; color: var(--text-secondary); font-size: 0.8rem; background: #f8f8f6; }
    .section-card { padding: 1.25rem !important; }
    @media (max-width: 767px) {
      .software-card { flex-direction: column; align-items: flex-start; }
      .software-thumb, .software-thumb-placeholder { width: 100%; min-width: 0; height: 200px; }
    }
    p, li, .pub-authors { max-width: none !important; }
</style>

<h2 class="section-heading"><i class="fa-solid fa-brain" style="color: var(--accent);"></i> DNA Large Language Models</h2>

<div class="section-card" style="border: 2px solid var(--accent);" markdown="0">
<div style="background: var(--accent); color: white; font-size: 0.7rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; padding: 4px 12px; display: inline-block; border-radius: 0 0 8px 0;">Core Toolkit</div>
<div class="software-card" style="margin-top: var(--space-3);">
<div class="software-body">
<h4>DNALLM-Suite</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/DNALLM" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A unified toolkit for fine-tuning and inference with DNA Language Models. Provides CLI, Web UI, and MCP (Model Context Protocol) support for seamless LLM integration. Features include fine-tuning pipelines, in-silico mutagenesis analysis, and support for multiple model architectures.</p>
</div>
<div class="software-thumb">
<img src="{{ site.url }}{{ site.baseurl }}/images/software/dnallm-suite.png" alt="DNALLM-Suite screenshot" loading="lazy">
</div>
</div>
</div>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>PDLLMs — Plant DNA Large Language Models</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://www.cell.com/molecular-plant/fulltext/S1674-2052(24)00390-3" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A group of tailored DNA large language models for analyzing plant genomes. Published in <em>Molecular Plant</em> 2025.</p>
<p class="pub-authors" style="font-size: 0.9rem;"><strong>Citation:</strong> Liu GQ, Chen L, Wu YC, Han YS, Bao Y, Zhang T. PDLLMs: A group of tailored DNA large language models for analyzing plant genomes. <em>Mol Plant</em>. 2025;18(2):175-178.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>dnallmmark</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/dnallmmark" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">Benchmarking framework for DNA Large Language Models. Standardized evaluation metrics and datasets for comparing DNA LLM architectures.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<h2 class="section-heading"><i class="fa-solid fa-scissors" style="color: var(--accent);"></i> Genome Editing</h2>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>CrisprStitch</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/CrisprStitch" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://pubmed.ncbi.nlm.nih.gov/38146164/" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A fast, user-friendly tool to evaluate the efficiency of CRISPR-Cas editing systems. Available as a web application and desktop app. Performs all calculations locally on the user's computer without uploading data to remote servers.</p>
<p class="pub-authors" style="font-size: 0.9rem;"><strong>Citation:</strong> Han YS, Liu GQ, Wu YC, Bao Y, Zhang Y, Zhang T. CrisprStitch: Fast evaluation of the efficiency of CRISPR editing systems. <em>Plant Commun</em>. 2024;5(3):100783.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<h2 class="section-heading"><i class="fa-solid fa-dna" style="color: var(--accent);"></i> Oligo-FISH &amp; Genomics</h2>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>Chorus2</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/Chorus2" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
<a href="https://pubmed.ncbi.nlm.nih.gov/33960617/" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">A software pipeline to select genome-scale oligonucleotide-based probes for fluorescence in situ hybridization (Oligo-FISH). Highly effective at removing repetitive elements and selecting single-copy oligos. Supports probe design for species with or without assembled genomes.</p>
<p class="pub-authors" style="font-size: 0.9rem;"><strong>Citation:</strong> Zhang T, Liu G, Zhao H, Braz GT, Jiang J. Chorus2: design of genome-scale oligonucleotide-based probes for fluorescence in situ hybridization. <em>Plant Biotechnol J</em>. 2021;19(10):1967-1978.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>rustkmer</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/rustkmer" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">High-performance k-mer counting and analysis tool written in Rust for efficient processing of large genomic datasets.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<h2 class="section-heading"><i class="fa-solid fa-robot" style="color: var(--accent);"></i> AI Infrastructure</h2>

<div class="section-card" markdown="0">
<div class="software-card">
<div class="software-body">
<h4>SIF — Semantic Intelligence Framework</h4>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
<a href="https://github.com/zhangtaolab/SIF" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;"><strong>S</strong>emantic <strong>I</strong>ntelligence <strong>F</strong>ramework — a document semantic intelligence retrieval system. SIF provides collection management, hybrid search (BM25 + vector embeddings), and MCP server integration for AI-assisted document retrieval. Supports multiple embedding models including Sentence Transformers, GGUF, OpenAI-compatible APIs, and ModelScope Hub.</p>
</div>
<div class="software-thumb-placeholder">Screenshot</div>
</div>
</div>

<div class="callout callout-success" style="margin-top: var(--space-8);" markdown="0">
<div class="callout-title"><i class="fa-brands fa-github callout-icon"></i> Open Source</div>
<p>All software is freely available on our <a href="https://github.com/zhangtaolab" target="_blank"><i class="fa-brands fa-github"></i> GitHub organization</a>. Contributions, bug reports, and feature requests are welcome.</p>
</div>
