---
layout: page
title: Blog
permalink: /blog/
---

Nesta seção pretendo incluir alguns pensamentos e análises não revisadas em uma variedade de assuntos, tendo intuito educativo e exploratório. Em geral os posts são escritos em português e acompanhados de scripts no R para replicar os resultados. Incluí dois posts do site antigo, mas infelizmente perdi todos os comentários ao remodelar o site. Atualmente, <a href="/categories">as categorias dos posts</a> (e o número de posts em cada categoria) incluem {% assign sorted_cats = site.categories | sort  %}{% for category in sorted_cats %}{% if forloop.last == true %}e {% endif %}<a href="/categories/#{{category[0]}}" style="font-weight:normal;"> {{category[0] | camelcase }}</a> ({{ category[1].size  }}){% if forloop.last == false %}, {% endif %}{% endfor %}.

<ul id="archive">
{% for post in site.posts %}
  {% capture y %}{{post.date | date:"%Y"}}{% endcapture %}
  {% if year != y %}
    {% assign year = y %}
    <h2 class="blogyear">{{ y}}</h2>
  {% endif %}
<li class="archiveposturl"><span><a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></span><br/>
<span class = "postlower">

<!--<strong>Author:</strong> {{post.author}} -->
<strong>Category:</strong>  {% if post.categories %}
 
  {% for cat in post.categories %}
  <a href="/categories/#{{ cat }}" title="{{ cat }}">{{ cat }}</a>&nbsp;
  {% endfor %}

{% endif %} <!-- {{ post.categories | first }} -->
<strong style="font-size:100%; font-family: 'Titillium Web', sans-serif; float:right; padding-right: .5em">{{ post.date | date: '%d %b %Y' }}</strong> 
</span> 

</li>
{% endfor %}
</ul>

<!-- {{ post.date | date: '%m %d, %Y' }} -->
