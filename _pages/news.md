---
title: "News"
layout: gridlay
sitemap: false
permalink: /news/
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

## News

<div class="news-timeline" markdown="0">
{% for article in site.data.news %}
<div class="news-item">
<span class="news-date">{{ article.date }}</span>
<span class="news-headline">{{ article.headline }}</span>
</div>
{% endfor %}
</div>
