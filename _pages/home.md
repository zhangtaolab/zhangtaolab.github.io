---
title: "Home"
layout: homelay
sitemap: false
permalink: /
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

<h2 class="home-hero">{{ site.name }}</h2>
<p class="home-hero-sub">{{ site.title }}, {{ site.institution }}</p>

<div class="chip-container" markdown="0">
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/software/" style="background: var(--accent); color: white; border-color: var(--accent);">DNA Large Language Models</a>
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">Plant Genomics</a>
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/"><em>Cis</em>-regulatory Elements</a>
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">Oligo-FISH Probes</a>
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/research/">CRISPR Genome Editing</a>
<a class="chip" href="{{ site.url }}{{ site.baseurl }}/software/">Bioinformatics Tools</a>
</div>

<p><strong>We specialize in developing and applying DNA Large Language Models (LLMs) for plant genome analysis.</strong> Our lab is at the forefront of applying foundation models to decode complex DNA sequences, predict regulatory elements, and accelerate crop improvement. We build and maintain <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs">PDLLMs</a>, a suite of open-source plant DNA language models for the research community. Our work spans from fundamental algorithm development to real-world applications in genomics, epigenetics, and genome engineering.</p>

<div class="callout callout-success" markdown="0">
<div class="callout-title"><i class="fa-solid fa-brain callout-icon"></i> Featured: DNA Large Language Models</div>
<p><strong><a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs</a></strong> — Plant DNA Large Language Models published in <em>Molecular Plant</em>. Foundation models for analyzing plant genomes.</p>
<p style="margin-top: var(--space-2);"><strong><a href="https://github.com/zhangtaolab/DNALLM" target="_blank">DNALLM-Suite</a></strong> — A unified toolkit for fine-tuning and inference with DNA Language Models. CLI, UI, and MCP support. <a href="https://zhangtaolab.org/DNALLM/" target="_blank"><i class="fa-solid fa-globe"></i> Website</a></p>
</div>

<div class="banner-frame" markdown="0">
<img src="{{ site.url }}{{ site.baseurl }}/images/banner.jpg" alt="Plant genome research" loading="lazy"/>
<div class="banner-caption">Overview of our research in plant genomics, epigenetics, and genome engineering at Zhang Tao Lab, Chengdu Institute of Biology, Chinese Academy of Sciences</div>
</div>

<h3>About the Lab</h3>
<p>Our laboratory specializes in <strong>DNA Large Language Models</strong> and their applications in plant science. We develop and apply foundation models to understand, predict, and engineer plant genomes. Our work bridges the gap between cutting-edge AI and fundamental biology, spanning computational genomics, epigenetics, and genome editing. We are committed to building open-source tools that accelerate scientific discovery in the era of AI-driven biology.</p>
