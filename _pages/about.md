---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
.pi-photo-placeholder { width: 160px; height: 200px; border-radius: var(--radius); display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #2d6a4f 0%, #40916c 100%); color: white; font-size: 3rem; flex-shrink: 0; }
</style>

<h1 class="page-title">About</h1>

<div class="section-card" markdown="0">
<div class="pi-card">
<div class="pi-photo-placeholder"><i class="fa-solid fa-user"></i></div>
<div>
<h3 class="pi-name">Dr. Zhang Tao</h3>
<p style="font-style: italic; color: var(--text-secondary);">Professor, {{ site.title }}<br/>{{ site.institution }}</p>
<div class="pi-links">
<a class="icon-link" href="mailto:{{ site.email }}" title="Email"><i class="fa-solid fa-envelope"></i></a>
<a class="icon-link" href="{{ site.links.google_scholar }}" title="Google Scholar"><i class="ai ai-google-scholar"></i></a>
<a class="icon-link" href="{{ site.links.github }}" title="GitHub"><i class="fa-brands fa-github"></i></a>
</div>
<ul style="margin-top: var(--space-4);">
{% for edu in site.data.pi[0].education %}
<li>{{ edu }}</li>
{% endfor %}
</ul>
</div>
</div>
</div>

<h2 class="section-heading">Research Interests</h2>

<p>Our laboratory specializes in <strong>DNA Large Language Models</strong> and their applications in plant science. We are at the intersection of AI and biology, developing foundation models that learn the fundamental grammar of DNA to enable:</p>

<ul>
<li><strong>DNA Large Language Models</strong> — building and training foundation models for DNA sequence understanding</li>
<li><strong>Regulatory element prediction</strong> — using LLMs to identify <em>cis</em>-regulatory elements with unprecedented accuracy</li>
<li><strong>Genome engineering</strong> — applying AI to optimize CRISPR-based genome editing</li>
<li><strong>Open-source tool development</strong> — making our models and tools freely available via <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank">PDLLMs</a></li>
</ul>

<div class="callout callout-success" markdown="0">
<div class="callout-title"><i class="fa-solid fa-brain callout-icon"></i> Featured Work: PDLLMs</div>
<p>Our <strong>Plant DNA Large Language Models (PDLLMs)</strong> represent a new paradigm for plant genome analysis. Published in <em>Molecular Plant</em> 2025, PDLLMs provide a suite of tailored foundation models for analyzing plant genomes, predicting regulatory elements, and accelerating crop improvement. <a href="https://github.com/zhangtaolab/Plant_DNA_LLMs" target="_blank"><i class="fa-brands fa-github"></i> Get PDLLMs on GitHub</a></p>
</div>

<h2 class="section-heading">Grants &amp; Funding</h2>

<div class="section-card" markdown="0">
<ul>
{% for grant in site.data.grants %}
<li>{{ grant.name }}</li>
{% endfor %}
</ul>
</div>
