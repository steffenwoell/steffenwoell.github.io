---
layout: page
title: Publications
description: Publications on literature, culture, space, empire, maps, visual culture, and digital media by Steffen Wöll.
image: /img/cat/pub.webp
header_class: publications-header
integrated_header: true
hide_avatar: true
js:
  - "/js/citations.js"
---

<div class="publications-page">

<div class="publication-header">
<div class="publication-statement">
<h1 class="home-section-label"><i class="fas fa-book-open" aria-hidden="true"></i> Publications</h1>
<p>Research on literature, culture, space, and empire across print, maps, images, and digital media.</p>
<img class="publication-header-image" src="{{ page.image | relative_url }}" alt="">
</div>

<div class="publication-profiles" aria-label="External publication profiles">
<a href="https://www.researchgate.net/profile/Steffen-Woell" aria-label="ResearchGate profile"><i class="fab fa-researchgate" aria-hidden="true"></i><span class="profile-label-full">Research<wbr>Gate</span><span class="profile-label-short" aria-hidden="true">RG</span><i class="fas fa-external-link-alt" aria-hidden="true"></i></a>
<a href="https://orcid.org/0000-0003-1582-6078" aria-label="ORCID profile"><i class="fab fa-orcid" aria-hidden="true"></i><span class="profile-label-full">ORCID</span><span class="profile-label-short" aria-hidden="true">ORCID</span><i class="fas fa-external-link-alt" aria-hidden="true"></i></a>
<a href="https://catalog.loc.gov/vwebv/search?searchArg=Wo%CC%88ll,%20Steffen&searchCode=NAME%2B&searchType=1&recCount=25" aria-label="Library of Congress authority record"><i class="fas fa-landmark" aria-hidden="true"></i><span class="profile-label-full">Library of Congress</span><span class="profile-label-short" aria-hidden="true">LoC</span><i class="fas fa-external-link-alt" aria-hidden="true"></i></a>
<a href="https://d-nb.info/gnd/1225944139" aria-label="German National Library authority record"><i class="fas fa-landmark" aria-hidden="true"></i><span class="profile-label-full">DNB</span><span class="profile-label-short" aria-hidden="true">DNB</span><i class="fas fa-external-link-alt" aria-hidden="true"></i></a>
</div>

{% include publications/contents.html %}
</div>

{% for category in site.data.publications.categories %}
  {% include publications/category.html category=category entries=site.data.publications.entries last=forloop.last %}
{% endfor %}

</div>

{% include publications/structured-data.html entries=site.data.publications.entries %}
{% include publications/citation-dialog.html %}
