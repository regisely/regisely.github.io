---
layout: page
title: Séries de Tempo (pós-graduação)
permalink: /timeseries/
---

Aqui você encontrará a ementa, lista de exercícios, notas de aula e outros arquivos e informações para a disciplina de Séries de Tempo, ministrada para os cursos de Mestrado e Doutorado em Economia da Universidade Federal de Pelotas.

Ao clicar no título você acessará o PDF de cada arquivo. Os ícones a direita são links para o diretório dos arquivos no Github (<i class="fab fa-github"></i>), o documento em R Markdown que gerou o pdf da aula (<i class="fab fa-r-project"></i>), e o arquivo PDF da aula acessado pelo Github (<i class="fas fa-file-pdf"></i>).

<ul id="archive">
{% for lectures in site.data.timeseries %}
      <li class="archiveposturl">
        <span><a href="{{ site.url }}/{{ lectures.dirname }}/{{ lectures.filename }}.pdf">{{ lectures.title }}</a></span><br>
<span class = "postlower">
<strong>Descrição:</strong> {{ lectures.tldr }}</span>
<strong style="font-size:100%; font-family: 'Titillium Web', sans-serif; float:right; padding-right: .5em">
	<a href="https://github.com/{{ site.githubdir}}/tree/master/{{ lectures.dirname }}"><i class="fab fa-github"></i></a>&nbsp;&nbsp;
<a href="https://github.com/{{ site.githubdir}}/tree/master/{{ lectures.dirname }}/{{ lectures.filename}}.Rmd"><i class="fab fa-r-project"></i></a>&nbsp;&nbsp;
<a href="https://github.com/{{ site.githubdir}}/blob/master/{{ lectures.dirname }}/{{ lectures.filename}}.pdf"><i class="fas fa-file-pdf"></i></a>
</strong> 
      </li>
{% endfor %}
</ul>
