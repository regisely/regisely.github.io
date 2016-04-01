---
layout: post
title: "A árvore do impeachment"
subtitle: Prevendo o resultado do impeachment brasileiro
tags: [classificação, regressão, árvores, impeachment, previsão]
date: 2016-04-03 10:00:00 -0300
---

## Cenário do impeachment

A favor ou contra? Parece que todo cidadão brasileiro já tem uma opinião formada sobre o impeachment, com exceção dos políticos, que estão um tanto indecisos. O site **[vem pra rua](http://mapa.vemprarua.net/br/)** fez um serviço de utilidade pública ao elencar a intenção de voto de todos os deputados e senadores brasileiros. Mas a verdade é que ainda resta muita dúvida sobre qual será o resultado dessa votação. Uma vez que os dados estão disponíveis, podemos tentar realizar uma tarefa quase impossível: tentar prever qual será o desfecho da situação política brasileira. Para isso vamos utilizar um simples modelo de regressão baseado em árvores, utilizando o pacote [`rpart`](https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf) no **[R](https://www.r-project.org/)**. Vamos aos fatos:

1. Atualmente temos 513 deputados e 81 senadores no Brasil;

2. Na Câmara dos Deputados ocorre o juízo de admissibilidade do processo de impeachment;

3. No Senado Federal ocorre o julgamento do impeachment;

4. Para autorização do processo é necessário votação favorável de dois terços dos Deputados Federais e para a condenação é necessária votação de dois terços dos Senadores;

5. Considerando os números, é necessário que 342 Deputados e 54 Senadores sejam favoráveis ao impeachment para que tenhamos um novo Presidente.

Para conhecer um pouco mais sobre o processo de impeachment você pode ler a **[legislação](http://presrepublica.jusbrasil.com.br/legislacao/128811/lei-do-impeachment-lei-1079-50)**.

## Obtendo os dados

Como a política brasileira é mais imprevisível que episódio de Game of Thrones, vale a pena automatizar a coleta de dados para podermos atualizar constantemente a previsão - neste exato momento que escrevo o post já ocorrem mudanças na intenção de voto de 2 Deputados. Para isso, escrevi um pequeno script em **[python](http://wiki.python.org.br/)** que coleta os dados do site **[vem pra rua](http://mapa.vemprarua.net/br/)** e grava em um arquivo csv com o nome [`imp.csv`](/files/imp.csv), deixando-o pronto para ser analisado no R. Você ver este script **[aqui](https://gist.github.com/regisely/caefdf30313503bbf5d0bbae6e2a597d)**.

Uma vez obtidos os dados podemos carregá-lo no R digitando:

```r
data <- read.csv("imp.csv", sep = ";")
```

Aqui está as primeiras 10 observações:

~~~
      Voto                   Nome Partido Estado Senador
1  A favor            Aecio Neves    PSDB     MG       1
2  A favor Aloysio Nunes Ferreira    PSDB     SP       1
3  A favor            Alvaro Dias      PV     PR       1
4  A favor             Ana Amelia      PP     RS       1
5  A favor      Antonio Anastasia    PSDB     MG       1
6  A favor       Ataides Oliveira    PSDB     TO       1
7  A favor           Blairo Maggi      PR     MT       1
8  A favor      Cassio Cunha Lima    PSDB     PB       1
9  A favor      Cristovam Buarque     PPS     DF       1
10 A favor          Dalirio Beber    PSDB     SC       1
~~~

A variável *Voto* contém três possíveis valores: "A favor", "Contra" ou em branco (indecisos). Já a variável *Senador* é uma dummy que é igual a um quando o político é Senador e zero quando é Deputado. As outras três variáveis são o *Nome*, o *Partido* e o *Estado*.

Para prevermos o resultado do impeachment vamos utilizar o método de regressão com particionamento recursivo, implementado pelo pacote [`rpart`](https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf). A ideia é que podemos separar as decisões dos políticos em grupos baseados em seus Partidos e Estados. Esse método é ideal para o caso brasileiro, pois sabemos que existem cisões entre os partidos brasileiros dependendo do Estado.

## Implementação do modelo

Uma vez carregados os dados na variável `data`, vamos ler o pacote `rpart`, criar algumas novas variáveis que serão úteis e fazer pequenos ajustes: 

```r
install.packages("rpart") # instale o pacote rpart caso não o tenha feito
library(rpart)

# Transforma os indecisos em NA
data[which(data$Voto == ''),"Voto"] <- NA
data$Voto <- droplevels(data$Voto)

# Cria variáveis para os senadores e deputados
senadores <- data[which(data$Senador == 1),]
deputados <- data[which(data$Senador == 0),]
n_sen <- nrow(senadores) # número de senadores
n_dep <- nrow(deputados) # número de deputados

# Separa deputados indecisos e decididos
train_dep <- na.omit(deputados) # deputados decididos
test_dep <- deputados[which(is.na(deputados$Voto)),] # deputados indecisos
train_sen <- na.omit(senadores) # senadores decididos
test_sen <- senadores[which(is.na(senadores$Voto)),] # senadores indecisos
```

Note que chamamos o conjunto dos Senadores e Deputados que já estão decididos de **train**, pois estes serão os dados utilizados para treinar nosso modelo. Posteriormente, aplicaremos os resultados do modelo nos dados denominados **test**, que é o conjunto dos políticos indecisos. A partir daí teremos nossa previsão.

Agora podemos treinar o modelo:

```r
# Estimação do modelo
formula = Voto ~ Partido + Estado # o voto é função do Partido e Estado
fit_dep = rpart(formula, method = "class", data = train_dep)
fit_sen = rpart(formula, method = "class", data = train_sen)

# Seleção do modelo com menor erro
fit_dep <- prune(fit_dep,
                 cp = fit_dep$cptable[which.min(fit_dep$cptable[,"xerror"]),
                                      "CP"])
fit_sen <- prune(fit_sen,
                 cp = fit_sen$cptable[which.min(fit_sen$cptable[,"xerror"]),
                                      "CP"])
fit_dep
fit_sen
```

Após estimar o modelo, você pode utilizar as funções `printcp(fit_dep)` e `plotcp(fit_dep)` para verificar qual a combinação de árvores que gera o menor erro no conjunto de previsão. No código acima, faço essa seleção automaticamente e estimo o modelo novamente com a função `prune`. 

## Gerando a árvore de decisão para os decididos

Uma vez que estimamos nosso modelo, podemos verificar na prática qual é a separação entre Partidos e Estados que ele está utilizando. Com isso utilizamos a função `plot` no R. Para construirmos árvores mais bonitas utilizamos a função `text` com alguns argumentos especiais (digite `?plot.rpart` no R para mais informações).

```r
# Plota árvore dos deputados decididos
plot(fit_dep, uniform = TRUE,
     main = "Árvore do Impeachment - Câmara (decididos)", margin = 0.2)
text(fit_dep, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)

# Plota árvore dos senadores decididos
plot(fit_sen, uniform = TRUE,
     main = "Árvore do Impeachment - Senado (decididos)", margin = 0.2)
text(fit_sen, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)
```

Este é o resultado das duas árvores, lembrando que elas ainda não incluem os parlamentares indecisos:

[![Árvore do Impeachment - Câmara (decididos)]({{ site.url }}/img/tree_dep.png)]({{ site.url }}/img/tree_dep.png)

[![Árvore do Impeachment - Senado (decididos)]({{ site.url }}/img/tree_sen.png)]({{ site.url }}/img/tree_sen.png)

## Previsão dos votos indecisos

Uma vez obtido o modelo com o menor erro, podemos utilizar os dados referentes aos parlamentares indecisos para realizar a previsão do voto e calcular o percentual de votos a favor com essas novas previsões:

```r
# Previsão do modelo
prev_dep <- predict(fit_dep, test_dep, type = "class")
prev_sen <- predict(fit_sen, test_sen, type = "class")

# Previsão do percentual de votação a favor
n_dep_favor <- nrow(train_dep[which(train_dep$Voto == "A favor"),])
n_sen_favor <- nrow(train_sen[which(train_sen$Voto == "A favor"),])
n_dep_favor_prev <- length(which(prev_dep == "A favor"))
n_sen_favor_prev <- length(which(prev_sen == "A favor"))
percentual_dep <- (n_dep_favor + n_dep_favor_prev)/n_dep
percentual_sen <- (n_sen_favor + n_sen_favor_prev)/n_sen
percentual_dep
percentual_sen
```

# Árvores com previsão

```r
new_dep <- deputados
new_dep[names(prev_dep), "Voto"] <- prev_dep
new_sen <- senadores
new_sen[names(prev_sen), "Voto"] <- prev_sen
fit_dep_prev = rpart(formula, method = "class", data = new_dep)
fit_sen_prev = rpart(formula, method = "class", data = new_sen)

plot(fit_dep_prev, uniform = TRUE,
    main = "Árvore do Impeachment - Câmara (com previsão de indecisos)",
    margin = 0.2)
text(fit_dep_prev, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)
mtext(paste0("Percentual previsto a favor: ",
             round(percentual_dep*100, digits = 2), "%"))

plot(fit_sen_prev, uniform = TRUE,
    main = "Árvore do Impeachment - Senado (com previsão de indecisos)",
    margin = 0.3)
text(fit_sen_prev, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)
mtext(paste0("Percentual previsto a favor: ",
             round(percentual_sen*100, digits=2), "%"))
```

[![Árvore do Impeachment - Câmara (com previsão de indecisos)]({{ site.url }}/img/tree_dep_prev.png)]({{ site.url }}/img/tree_dep_prev.png)

[![Árvore do Impeachment - Senado (com previsão de indecisos)]({{ site.url }}/img/tree_sen_prev.png)]({{ site.url }}/img/tree_sen_prev.png)
