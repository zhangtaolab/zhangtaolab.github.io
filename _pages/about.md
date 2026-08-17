---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

<!-- PI Card -->
<div class="section-card">
  <div class="pi-card">
    <div class="pi-photo">
      <img src="{{ site.url }}{{ site.baseurl }}/images/logo.png" alt="Dr. Zhang Tao" class="pi-img"/>
    </div>
    <div class="pi-info">
      <h2 class="pi-name">Dr. Zhang Tao</h2>
      <p class="pi-title">{{ site.title }}</p>
      <p class="pi-institution">{{ site.institution }}</p>
      <div class="pi-links">
        <a href="mailto:{{ site.email }}" class="pi-link" title="Email">
          <i class="fas fa-envelope"></i> {{ site.email }}
        </a>
        <a href="{{ site.links.google_scholar }}" target="_blank" class="pi-link" title="Google Scholar">
          <i class="fas fa-graduation-cap"></i> Google Scholar
        </a>
        <a href="{{ site.links.github }}" target="_blank" class="pi-link" title="GitHub">
          <i class="fab fa-github"></i> GitHub
        </a>
      </div>
    </div>
  </div>
</div>

{% if site.data.pi %}
<!-- Education & Career -->
<div class="section-card">
  <div class="pi-background" markdown="1">

## Education & Career

{% for item in site.data.pi.education %}
- **{{ item.degree }}**, {{ item.institution }} ({{ item.year }})
{% endfor %}

{% if site.data.pi.positions %}
{% for pos in site.data.pi.positions %}
- **{{ pos.title }}**, {{ pos.institution }} ({{ pos.period }})
{% endfor %}
{% endif %}

  </div>
</div>
{% endif %}

<!-- Research Interests -->
<div class="research-interests" markdown="1">

## Research Interests

Our lab integrates **deep learning** and **genomics** to study the regulatory code of plant genomes. Our major research directions include:

### DNA Large Language Models
Development of foundation models pretrained on DNA sequences for versatile genomic prediction tasks. Our **PDLLMs** (*Molecular Plant*, 2025) represent the first family of plant-specific DNA large language models, capable of predicting <em>cis</em>-regulatory elements, chromatin accessibility, and transcription factor binding sites across multiple plant species.

### Regulatory Element Prediction
Computational identification and characterization of <em>cis</em>-regulatory elements (CREs) using deep learning approaches. We build models that decode the non-coding regulatory grammar to understand how gene expression is controlled at the transcriptional level.

### Genome Engineering & CRISPR Analysis
Development of computational tools for CRISPR-based genome editing. Our **CrisprStitch** (*Plant Communications*, 2024) enables high-throughput analysis of CRISPR editing outcomes, facilitating crop improvement through precision genome editing.

### Oligo-FISH Probe Design
Creation of bioinformatics pipelines for designing oligonucleotide probes used in fluorescence *in situ* hybridization (FISH). **Chorus2** (*Plant Biotechnology Journal*, 2021) is a widely-used tool for genome-scale oligo-FISH probe design in plants.

### Open-Source Bioinformatics Tools
We are committed to developing and maintaining open-source software that serves the plant genomics community. Our [**DNALLM-Suite**]({{ site.links.github }}) provides an integrated platform bringing together DNA LLMs, probe design, and genome editing analysis tools.

</div>

<!-- Featured Work -->
<div class="callout callout-primary" markdown="1">

### Featured Work: PDLLMs

**PDLLMs** (Plant DNA Large Language Models) — A family of foundation models for plant genomic sequence analysis, published in ***Molecular Plant* (2025)**.

- Pretrained on large-scale plant genome sequences
- Fine-tunable for diverse genomic prediction tasks
- Part of the DNALLM-Suite ecosystem

[Read the paper]({{ site.links.google_scholar }}){: .btn .btn-primary}
[Explore the code]({{ site.links.github }}/PDLLMs){: .btn .btn-outline}

</div>

<!-- Grants & Funding -->
{% if site.data.grants %}

## Grants & Funding

<div class="section-card" markdown="1">

{% for grant in site.data.grants %}
<div class="grant-item" markdown="1">

**{{ grant.title }}**  
{{ grant.agency }} | {{ grant.period }}  
{% if grant.role %}{{ grant.role }}{% endif %}

</div>
{% endfor %}

</div>
{% endif %}
