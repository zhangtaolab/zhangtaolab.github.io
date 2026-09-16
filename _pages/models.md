---
title: "Models"
layout: gridlay
permalink: /models/
---

<h1 class="page-title">Models</h1>

<p>We develop DNA language models for plant genomes — from large-scale foundation models to tailored model suites. This page collects the lab's model zoo. All model weights are openly available on <a href="https://huggingface.co/zhangtaolab" target="_blank">Hugging Face</a> and <a href="https://modelscope.cn/organization/zhangtaolab" target="_blank">ModelScope</a>.</p>

<style>
    .section-card { padding: 1.25rem !important; }
    .model-banner { width: 100%; height: 260px; border-radius: 10px; overflow: hidden; border: 1px solid var(--border); margin-bottom: var(--space-3); }
    .model-banner img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .section-card h4 { margin-top: 0; margin-bottom: 0.5rem; font-size: 1.05rem; }
    @media (max-width: 767px) {
      .model-banner { height: 190px; }
    }
    p, li, .pub-authors { max-width: none !important; }
</style>

{% for model in site.data.models %}
<div class="section-card"{% if model.featured %} style="border: 2px solid var(--accent);"{% endif %} markdown="0">
{% if model.featured %}
<div style="background: var(--accent); color: white; font-size: 0.7rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; padding: 4px 12px; display: inline-block; border-radius: 0 0 8px 0;">Featured</div>
{% endif %}
{% if model.image %}<div class="model-banner"{% if model.featured %} style="margin-top: var(--space-3);"{% endif %}><img src="{{ model.image | relative_url }}" alt="{{ model.image_alt }}" loading="lazy"></div>{% endif %}
<h4>{{ model.name }}</h4>
<div style="color: var(--accent); font-size: 0.72rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; margin-bottom: var(--space-2);">{{ model.tag }}</div>
<div class="pub-actions" style="margin-bottom: var(--space-3);">
{% if model.links.github %}
<a href="{{ model.links.github }}" class="btn-pill btn-git" target="_blank"><i class="fa-brands fa-github"></i> GitHub</a>
{% endif %}
{% if model.links.huggingface %}
<a href="{{ model.links.huggingface }}" class="btn-pill btn-website" target="_blank"><i class="ai ai-hugging-face"></i> Hugging Face</a>
{% endif %}
{% if model.links.modelscope %}
<a href="{{ model.links.modelscope }}" class="btn-pill btn-bib" target="_blank"><i class="fa-solid fa-cubes"></i> ModelScope</a>
{% endif %}
{% if model.links.docs %}
<a href="{{ model.links.docs }}" class="btn-pill btn-bib" target="_blank"><i class="fa-solid fa-globe"></i> Docs</a>
{% endif %}
{% if model.links.demo %}
<a href="{{ model.links.demo }}" class="btn-pill btn-website" target="_blank"><i class="fa-solid fa-globe"></i> Demo</a>
{% endif %}
{% if model.links.paper %}
<a href="{{ model.links.paper }}" class="btn-pill btn-paper" target="_blank"><i class="fa-solid fa-file-lines"></i> Paper</a>
{% endif %}
</div>
<p style="font-size: 0.88rem; color: var(--text-secondary); line-height: 1.6;">{{ model.description }}</p>
{% if model.specs %}
{% for spec in model.specs %}
<p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 0.25rem;"><strong>{{ spec[0] }}:</strong> {{ spec[1] }}</p>
{% endfor %}
{% endif %}
{% if model.tasks %}
<p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 0.25rem;"><strong>Tasks:</strong> {{ model.tasks | join: ", " }}</p>
{% endif %}
{% if model.note %}
<p class="pub-authors" style="font-size: 0.9rem;"><em>{{ model.note }}</em></p>
{% endif %}
</div>
{% endfor %}

<div class="section-card" markdown="0">
<p style="font-size: 0.88rem; color: var(--text-secondary);"><strong>More models:</strong> <a href="https://zhangtaolab.org/DNALLM/" target="_blank">Plant DNAGemma</a> · <a href="https://zhangtaolab.org/DNALLM/" target="_blank">Plant DNAGPT</a> · <a href="https://zhangtaolab.org/DNALLM/" target="_blank">Plant DNAMamba</a> · <a href="https://zhangtaolab.org/DNALLM/" target="_blank">CrossDNA</a> — see the <a href="https://zhangtaolab.org/DNALLM/" target="_blank">DNALLM documentation</a> for details.</p>
</div>

<div class="callout callout-success" style="margin-top: var(--space-8);" markdown="0">
<div class="callout-title"><i class="fa-solid fa-brain callout-icon"></i> dnallm Toolkit</div>
<p>All models are accessible through the unified <strong>dnallm</strong> toolkit — install with <code>pip install dnallm</code> — see <a href="https://github.com/zhangtaolab/DNALLM" target="_blank"><i class="fa-brands fa-github"></i> DNALLM on GitHub</a> and the <a href="https://zhangtaolab.org/DNALLM/" target="_blank"><i class="fa-solid fa-globe"></i> documentation</a>.</p>
</div>
