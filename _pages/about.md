---
title: "About"
layout: gridlay
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

<h2 class="section-heading">Contact</h2>

### Laboratory Address

<div class="section-card">
<div class="pi-card">
<div>
<h4>Zhang Tao Lab</h4>
<p><strong>Chengdu Institute of Biology, Chinese Academy of Sciences</strong><br>
<i class="fas fa-location-dot"></i> 23 Qunxian South Street, Tianfu New Area<br>
Chengdu, Sichuan 610213, P.R. China<br>
四川省成都市天府新区群贤南街23号</p>

<p><i class="fas fa-envelope"></i> <a href="mailto:{{ site.email }}">{{ site.email }}</a></p>

<p><strong>PI:</strong> Dr. Zhang Tao<br>
<i class="fas fa-envelope"></i> <a href="mailto:{{ site.email }}">{{ site.email }}</a></p>
</div>
</div>
</div>

### Join the Lab

<div class="section-card" markdown="1">

We are always looking for motivated students and postdoctoral researchers to join our team. If you are interested in bioinformatics, plant genomics, epigenetics, or genome editing, please contact us!

**Positions available:**

- PhD students (生物信息学、作物遗传育种方向)
- Master's students (生物信息学方向)
- Postdoctoral researchers

Please send your CV and a brief statement of research interests to [{{ site.email }}](mailto:{{ site.email }}).

</div>

### Links

<div class="section-card" markdown="1">

- <i class="fas fa-graduation-cap"></i> <a href="{{ site.links.google_scholar }}" target="_blank">Google Scholar</a>
- <i class="fab fa-github"></i> <a href="{{ site.links.github }}" target="_blank">GitHub Organization</a>
- <i class="fas fa-building-columns"></i> <a href="http://www.cib.ac.cn/" target="_blank">Chengdu Institute of Biology, Chinese Academy of Sciences</a>

</div>

<!-- Map Placeholder -->
<div class="map-section" markdown="0">
  <iframe
    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3438.0!2d104.0!3d30.5!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zMzDCsDMwJzAwLjAiTiAxMDTCsDAwJzAwLjAiRQ!5e0!3m2!1sen!2scn!4v1"
    width="100%"
    height="400"
    style="border:0;"
    allowfullscreen=""
    loading="lazy"
    referrerpolicy="no-referrer-when-downgrade">
  </iframe>
</div>
