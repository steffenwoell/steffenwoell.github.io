---
layout: page
title: Publications
description: Publications on literature, culture, space, empire, maps, visual culture, and digital media by Steffen Wöll.
image: /img/cat/pub.webp
header_class: publications-header
integrated_header: true
hide_avatar: true
js:
  - "/js/citations.js?v=20260729"
---

<div class="publications-page">

<div class="publication-header">
<div class="publication-statement">
<h1 class="home-section-label"><i class="fas fa-book-open" aria-hidden="true"></i> Publications</h1>
<p>Publications across print, maps, and digital media</p>
<img class="publication-header-image" src="{{ page.image | relative_url }}" alt="">
</div>

{% include publications/contents.html %}
</div>

{% assign habilitation_config = site.data.publications.featured.habilitation %}
{% assign habilitation_entries = site.data.publications.entries | where: "id", habilitation_config.entry_id %}
{% assign habilitation_entry = habilitation_entries | first %}
{% if habilitation_entry %}
<section class="publication-category publication-category--featured" aria-labelledby="habilitation-project-title">
  <header class="publication-category-header">
    <h2 id="habilitation-project-title">{{ habilitation_config.label }}</h2>
  </header>
  <div class="publication-category-body blue">
    {% include publications/entry.html entry=habilitation_entry title_only=true %}
  </div>
</section>
{% endif %}

{% for category in site.data.publications.categories %}
  {% include publications/category.html category=category entries=site.data.publications.entries featured_entry_id=habilitation_config.entry_id last=forloop.last %}
{% endfor %}

</div>

{% include publications/structured-data.html entries=site.data.publications.entries %}
{% include publications/citation-dialog.html %}
