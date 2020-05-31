---
layout: post
title: "Hello world 2"
author: "Regis"
category: [hello world]
date: 2020-05-30
---


```r
library(ggplot2)
ggplot(data.frame(x=1, y=1), aes(x, y, label = "Hello World!")) +
  geom_text(size = 20) +
  theme_void()
```

<img src="/figure/source/2020-05-29-hello-world-2/hello_world-1.png" title="plot of chunk hello_world" alt="plot of chunk hello_world" style="display: block; margin: auto;" />

Depois da minha tentativa frustada de manter um blog com posts regulares de análises econômicas usando o `R` em 2016, volto em 2020, em definitivo. Incluí dois posts antigos que tiveram um bom *feedback* para fins de registro. A partir de agora, a meta é tentar escrever pelo menos alguma coisa todo mês.

