---
title: "Home"
layout: homelay
sitemap: false
permalink: /
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

<!-- Hero Section -->
<div class="hero-section" markdown="0">
  <div class="hero-content">
    <h1 class="hero-title">{{ site.name }}</h1>
    <p class="hero-subtitle">
      {{ site.title }}<br/>
      {{ site.institution }}
    </p>
  </div>
</div>

<!-- Research Tags -->
<div class="chip-container" markdown="0">
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip" style="background: var(--accent); color: white; border-color: var(--accent);">DNA Large Language Models</a>
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip">Plant Genomics</a>
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip"><em>Cis</em>-regulatory Elements</a>
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip">Oligo-FISH Probes</a>
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip">CRISPR Genome Editing</a>
  <a href="{{ site.url }}{{ site.baseurl }}/research" class="chip">Bioinformatics Tools</a>
</div>

<!-- Intro Section -->
<div class="home-intro" markdown="1">

We are the **{{ site.name }}** at the **{{ site.institution }}**. Our lab specializes in **DNA Large Language Models (DNA LLMs)** for plant genomics, combining deep learning with biological domain knowledge to decode the regulatory grammar of plant genomes. We develop open-source bioinformatics tools and resources that advance our understanding of gene regulation and accelerate crop improvement.

</div>

<!-- Featured Callout -->
<div class="callout callout-primary" markdown="1">

### Featured: PDLLMs & DNALLM-Suite

We recently developed **PDLLMs** (Plant DNA Large Language Models), a family of foundation models pretrained on plant genome sequences for versatile genomic prediction tasks. PDLLMs was published in ***Molecular Plant* (2025)**. Together with **DNALLM-Suite**, our comprehensive toolkit for DNA LLM training and inference, we provide an end-to-end solution for plant genomic sequence analysis.

[Learn more about our research]({{ site.url }}{{ site.baseurl }}/research){: .btn .btn-primary}
[View on GitHub]({{ site.links.github }}/PDLLMs){: .btn .btn-outline}

</div>

<!-- Banner Image -->
<div class="home-banner" markdown="0">
  <img src="{{ site.url }}{{ site.baseurl }}/images/banner.jpg" alt="Zhang Tao Lab banner" class="img-responsive"/>
</div>

<!-- About the Lab -->
<div class="home-about" markdown="1">

## About the Lab

The {{ site.name }} focuses on developing and applying **DNA Large Language Models** and other computational approaches to study plant genomes. Our research spans regulatory element prediction, oligo-FISH probe design, CRISPR-based genome editing, and the development of open-source bioinformatics tools. We are committed to building community resources that bridge the gap between artificial intelligence and plant biology.

Our flagship tools include [**PDLLMs**]({{ site.links.github }}/PDLLMs) (*Molecular Plant*, 2025) for plant DNA language modeling, [**Chorus2**]({{ site.links.github }}/ Chorus2) (*Plant Biotechnology Journal*, 2021) for oligo-FISH probe design, and [**CrisprStitch**]({{ site.links.github }}/CrisprStitch) (*Plant Communications*, 2024) for CRISPR editing analysis. Together, these tools form the [**DNALLM-Suite**]({{ site.links.github }}) — an integrated platform for genomic sequence analysis and genome engineering.

[More about us]({{ site.url }}{{ site.baseurl }}/about){: .btn .btn-primary}

</div>

<!-- News Sidebar -->
<div class="home-news" markdown="0">

## News

{% for article in site.data.news limit:3 %}
<div class="news-item">
<strong class="news-date">{{ article.date }}</strong>
<span class="news-headline">{{ article.headline }}</span>
</div>
{% endfor %}

<p><a href="{{ site.url }}{{ site.baseurl }}/news">See all news &rarr;</a></p>

</div>
