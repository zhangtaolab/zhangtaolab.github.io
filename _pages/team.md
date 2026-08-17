---
layout: team
title: Team
permalink: /team/
---

<style>
p, li, h1, h2, h3, h4 { max-width: none !important; }
</style>

{% if site.data.team_members %}
  {% for member in site.data.team_members %}
    {% assign is_pi = false %}
    {% if member.name == "Zhang Tao" or member.position contains "Professor" or member.position contains "PI" %}
      {% assign is_pi = true %}
    {% endif %}

    {% if is_pi %}
<!-- PI Section -->
<div class="section-card">
  <div class="pi-card">
    <img class="pi-photo fixed-size-img"
         src="{{ site.baseurl }}/images/team/{% if member.photo %}{{ member.photo }}{% else %}avatar.jpg{% endif %}"
         alt="{{ member.name }}" loading="lazy">
    <div>
      <h3 class="pi-name">{{ member.name }}</h3>
      <p style="font-style: italic; color: var(--text-secondary);">{{ member.position }}</p>
      {% if member.institution %}
      <p style="font-style: italic; color: var(--text-secondary);">{{ member.institution }}</p>
      {% endif %}
      <div class="pi-links">
        {% if member.email %}
          <a href="mailto:{{ member.email }}" class="icon-link" title="Email"><i class="fas fa-envelope"></i></a>
        {% endif %}
        {% if member.scholar %}
          <a href="{{ member.scholar }}" target="_blank" class="icon-link" title="Google Scholar"><i class="fas fa-graduation-cap"></i></a>
        {% endif %}
        {% if member.orcid %}
          <a href="https://orcid.org/{{ member.orcid }}" target="_blank" class="icon-link" title="ORCID"><i class="fab fa-orcid"></i></a>
        {% endif %}
        {% if member.github %}
          <a href="https://github.com/{{ member.github }}" target="_blank" class="icon-link" title="GitHub"><i class="fab fa-github"></i></a>
        {% endif %}
        {% if member.twitter %}
          <a href="https://twitter.com/{{ member.twitter }}" target="_blank" class="icon-link" title="Twitter"><i class="fab fa-twitter"></i></a>
        {% endif %}
        {% if member.website %}
          <a href="{{ member.website }}" target="_blank" class="icon-link" title="Website"><i class="fas fa-globe"></i></a>
        {% endif %}
      </div>
      {% if member.education %}
      <ul style="margin-top: var(--space-4);">
        {% for edu in member.education %}
        <li>{{ edu }}</li>
        {% endfor %}
      </ul>
      {% endif %}
    </div>
  </div>
</div>
    {% else %}

    {% assign mod = forloop.index0 | modulo: 3 %}
    {% if mod == 0 %}
      <div class="row team-row">
    {% endif %}

    <div class="col-sm-4">
      <div class="team-member student-card">
        <img class="img-responsive img-circle fixed-size-img"
             src="{{ site.baseurl }}/images/team/{% if member.photo %}{{ member.photo }}{% else %}avatar.jpg{% endif %}"
             alt="{{ member.name }}">
        <div class="team-info">
          <h4>{{ member.name }}</h4>
          <p class="text-muted">{{ member.position }}</p>
          {% if member.research_interests %}
            <p class="research-interests">{{ member.research_interests }}</p>
          {% endif %}
          <ul class="list-inline social-buttons">
            {% if member.email %}
              <li><a href="mailto:{{ member.email }}"><i class="fas fa-envelope"></i></a></li>
            {% endif %}
            {% if member.scholar %}
              <li><a href="{{ member.scholar }}" target="_blank"><i class="fas fa-graduation-cap"></i></a></li>
            {% endif %}
            {% if member.orcid %}
              <li><a href="https://orcid.org/{{ member.orcid }}" target="_blank"><i class="fab fa-orcid"></i></a></li>
            {% endif %}
            {% if member.github %}
              <li><a href="https://github.com/{{ member.github }}" target="_blank"><i class="fab fa-github"></i></a></li>
            {% endif %}
            {% if member.twitter %}
              <li><a href="https://twitter.com/{{ member.twitter }}" target="_blank"><i class="fab fa-twitter"></i></a></li>
            {% endif %}
            {% if member.website %}
              <li><a href="{{ member.website }}" target="_blank"><i class="fas fa-globe"></i></a></li>
            {% endif %}
          </ul>
        </div>
      </div>
    </div>

    {% if mod == 2 or forloop.last %}
      </div>
    {% endif %}
    {% endif %}
  {% endfor %}
{% endif %}

{% if site.data.alumni %}
  <div class="section-card">
    <h2 class="section-subtitle">Alumni</h2>
    <table class="alumni-table">
      <thead>
        <tr>
          <th>Name</th>
          <th>Duration</th>
          <th>Current Position</th>
        </tr>
      </thead>
      <tbody>
        {% for alum in site.data.alumni %}
          <tr>
            <td>{{ alum.name }}</td>
            <td>{{ alum.duration }}</td>
            <td>{{ alum.info }}</td>
          </tr>
        {% endfor %}
      </tbody>
    </table>
  </div>
{% endif %}

<div class="row" style="margin-top: 3rem;">
  <div class="col-sm-4 col-sm-offset-4">
    <div class="team-member join-us-card">
      <div class="join-icon"><i class="fas fa-user-plus"></i></div>
      <div class="team-info">
        <h4>Join Us!</h4>
        <p class="text-muted">We are always looking for motivated researchers. Please <a href="mailto:{{ site.email }}">contact us</a> to discuss opportunities.</p>
      </div>
    </div>
  </div>
</div>

<style>
.pi-card { display: flex; gap: 2rem; align-items: flex-start; flex-wrap: wrap; }
.pi-photo { width: 160px; height: 200px; object-fit: cover; border-radius: var(--radius); border: 1px solid var(--border); flex-shrink: 0; background: #f0f0eb; }
.pi-name { font-size: 1.5rem; font-weight: 700; font-family: 'Source Serif 4', serif; margin-bottom: 0.25rem; }
.pi-links { display: flex; gap: var(--space-2); margin-top: var(--space-3); }
.icon-link { color: var(--text-secondary); font-size: 1.1rem; transition: color 0.2s; }
.icon-link:hover { color: var(--accent); }
.team-row { margin-bottom: 2rem; }
.team-member { text-align: center; margin-bottom: 2rem; padding: 1.5rem; border-radius: 8px; transition: box-shadow 0.3s ease; }
.team-member:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
.fixed-size-img { width: 180px; height: 180px; object-fit: cover; border-radius: 50%; margin: 0 auto 1rem; }
.pi-card .fixed-size-img { width: 160px; height: 200px; border-radius: var(--radius); border: 1px solid var(--border); background: #f0f0eb; }
.team-info h4 { font-weight: 700; margin-bottom: 0.25rem; }
.team-info .text-muted { color: #777; font-size: 0.9rem; margin-bottom: 0.5rem; }
.research-interests { font-size: 0.85rem; color: #555; line-height: 1.4; margin-bottom: 0.75rem; }
.social-buttons { padding: 0; margin: 0; }
.social-buttons li { display: inline-block; margin: 0 4px; }
.social-buttons a { display: inline-block; width: 32px; height: 32px; line-height: 32px; border-radius: 50%; background: var(--accent); color: #fff; text-align: center; font-size: 0.85rem; transition: background 0.2s; }
.social-buttons a:hover { background: var(--accent-dark); }
.section-subtitle { font-size: 1.75rem; font-weight: 800; font-family: 'Source Serif 4', serif; margin-bottom: 1.5rem; color: var(--text-primary); border-bottom: 2px solid var(--accent); display: inline-block; padding-bottom: 0.25rem; }
.alumni-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
.alumni-table th, .alumni-table td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid #e0e0e0; }
.alumni-table th { font-weight: 700; color: var(--text-primary); }
.alumni-table tbody tr:hover { background: #f8f8f8; }
.join-us-card { border: 2px dashed var(--accent); border-radius: 12px; padding: 2rem; cursor: default; }
.join-us-card:hover { box-shadow: 0 4px 20px rgba(0,0,0,0.1); border-style: solid; }
.join-icon { font-size: 3rem; color: var(--accent); margin-bottom: 1rem; }
</style>
