---
title: "Team"
layout: team
permalink: /team/
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

<h1 class="page-title">Team</h1>

<p><strong>We are looking for new team members!</strong></p>

{% assign pi = site.data.team_members | where: "role", "pi" | first %}
{% assign staff = site.data.team_members | where: "role", "member" %}
{% assign students = site.data.team_members | where: "role", "student" %}

<h2 class="section-heading">PI</h2>

{% if pi %}
<div class="section-card">
<div class="pi-card">
{% if pi.photo %}
<img src="{{ site.url }}{{ site.baseurl }}{{ pi.photo }}" class="pi-photo" alt="{{ pi.name }}" loading="lazy"/>
{% else %}
<div class="pi-photo-placeholder"><i class="fa-solid fa-user"></i></div>
{% endif %}
<div>
<h3 class="pi-name">{{ pi.name }}</h3>
<p style="font-style: italic; color: var(--text-secondary);">{{ pi.position }}</p>
<div class="pi-links">
{% if pi.email %}<a class="icon-link" href="mailto:{{ pi.email }}" title="Email"><i class="fa-solid fa-envelope"></i></a>{% endif %}
{% if pi.scholar %}<a class="icon-link" href="{{ pi.scholar }}" title="Google Scholar"><i class="ai ai-google-scholar"></i></a>{% endif %}
{% if pi.github %}<a class="icon-link" href="{{ pi.github }}" title="GitHub"><i class="fa-brands fa-github"></i></a>{% endif %}
</div>
{% if pi.education %}
<ul style="margin-top: var(--space-4);">
{% for edu in pi.education %}
<li>{{ edu }}</li>
{% endfor %}
</ul>
{% endif %}
</div>
</div>
</div>
{% endif %}

{% if staff.size > 0 %}
<h2 class="section-heading">Current Member</h2>

<div class="team-grid">
{% for member in staff %}
<div class="team-card">
<div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #40916c 0%, #52b788 100%);">
<i class="fa-solid fa-user" style="font-size: 2.5rem; color: white;"></i>
</div>
<h4 class="team-name">{{ member.name }}</h4>
<p class="team-info">{{ member.position }}</p>
</div>
{% endfor %}
</div>
{% endif %}

{% if students.size > 0 %}
<h2 class="section-heading">Current Students</h2>

<div class="team-grid">
{% for member in students %}
<div class="team-card">
<div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #52b788 0%, #74c69d 100%);">
<i class="fa-solid fa-user" style="font-size: 2.5rem; color: white;"></i>
</div>
<h4 class="team-name">{{ member.name }}</h4>
<p class="team-info">{{ member.position }}</p>
</div>
{% endfor %}
<div class="team-card">
<div class="team-photo" style="display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg, #d8f3dc 0%, #b7e4c7 100%); color: #2d6a4f;">
<i class="fa-solid fa-plus" style="font-size: 2.5rem;"></i>
</div>
<h4 class="team-name">Join Us!</h4>
<p class="team-info">We are recruiting postdocs and students. <a href="{{ site.url }}{{ site.baseurl }}/contact/">Contact us!</a></p>
</div>
</div>
{% endif %}

{% if site.data.alumni %}
<h2 class="section-heading">Alumni</h2>

<div class="section-card">
<table class="alumni-table">
<thead>
<tr><th>Name</th><th>Period</th><th>Degree</th><th>Current Position</th></tr>
</thead>
<tbody>
{% for alum in site.data.alumni %}
<tr>
<td><strong>{{ alum.name }}</strong></td>
<td>{{ alum.period }}</td>
<td>{{ alum.degree }}</td>
<td>{{ alum.position }}</td>
</tr>
{% endfor %}
</tbody>
</table>
</div>
{% endif %}
