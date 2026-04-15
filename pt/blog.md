---
layout: page
title: Posts
permalink: /pt/blog/
lang: pt
alt_lang: en
alt_url: /blog/
---

Esta página inclui análises, comunicados e textos sobre uma variedade de assuntos, tendo conteúdo educativo e exploratório. Os textos são disponibilizados na língua original, seja inglês ou português.

<section class="post-categories">
    <p class="post-categories__label">Categorias</p>
    <ul class="post-categories__cloud">
        {% assign sorted_cats = site.categories | sort %}
        {% for category in sorted_cats %}
        <li class="post-categories__item" style="--count: {{ category[1].size }}">
            <a href="/categories/#{{ category[0] }}" title="{{ category[1].size }} posts">{{ category[0] | capitalize }}</a>
        </li>
        {% endfor %}
    </ul>
</section>

<ul id="archive">
{% for post in site.posts %}
  {% capture y %}{{post.date | date:"%Y"}}{% endcapture %}
  {% if year != y %}
    {% assign year = y %}
    <h2 class="blogyear">{{ y}}</h2>
  {% endif %}
<li class="archiveposturl"><span><a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></span><br/>
<span class = "postlower">

<strong>Categoria:</strong>  {% if post.categories %}

  {% for cat in post.categories %}
  <a href="/categories/#{{ cat }}" title="{{ cat }}">{{ cat }}</a>&nbsp;
  {% endfor %}

{% endif %}
<strong style="font-size:100%; font-family: 'Titillium Web', sans-serif; float:right; padding-right: .5em">{{ post.date | date: '%d %b %Y' }}</strong>
</span>

</li>
{% endfor %}
</ul>
