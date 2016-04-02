---
layout: post
title: "A árvore do Impeachment"
subtitle: Previsão do resultado do Impeachment brasileiro
tags: [classificação, regressão, árvores, Impeachment, previsão]
date: 2016-04-01 10:00:00 -0300
---


| **Câmera Federal:** | 74,85% |
| **Senado Federal:** | 53,09% |
| **Resultado da admissibilidade:** | A favor |
| **Resultado do julgamento:** | Contra |

> **Última atualização:** 02/04/2016

## Cenário do Impeachment

A favor ou contra? Parece que todo cidadão brasileiro já tem uma opinião formada sobre o Impeachment, com exceção dos políticos, que estão um tanto indecisos. O site **[vem pra rua](http://mapa.vemprarua.net/br/)** fez um serviço de utilidade pública ao elencar a intenção de voto de todos os deputados e senadores brasileiros. Mas a verdade é que ainda resta muita dúvida sobre qual será o resultado dessa votação. Uma vez que os dados estão disponíveis, podemos tentar realizar uma tarefa quase impossível: prever qual será o desfecho da situação política brasileira. Para isso vamos utilizar um simples modelo de regressão baseado em árvores, implementado no pacote [`rpart`](https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf) do **[R](https://www.r-project.org/)**. Primeiro vamos aos fatos:

1. Atualmente temos 513 deputados e 81 senadores no Brasil;

2. O processo de Impeachment pode ser dividido em duas etapas: o juízo de admissibilidade e o julgamento do impedimento;

3. Para o pedido ser admitido é necessário 2/3 de votos favoráveis na Câmara dos Deputados e 1/2 de votos favoráveis no Senado Federal;

4. Para o impedimento da Presidente é necessário 2/3 de votos favoráveis no Senado Federal;

5. Considerando os números, para termos um novo Presidente é necessário que 342 Deputados e 41 Senadores sejam favoráveis a admissibilidade, e que 54 Senadores sejam favoráveis ao impedimento (crédito ao Gabriel Torres por lembrar das recentes mudanças feitas pelo STF).

Para conhecer um pouco mais sobre o processo de Impeachment você pode ler a **[legislação](http://presrepublica.jusbrasil.com.br/legislacao/128811/lei-do-Impeachment-lei-1079-50)**.

## Obtendo os dados

Como a política brasileira é mais imprevisível que episódio de Game of Thrones, vale a pena automatizar a coleta de dados para podermos atualizar constantemente a previsão - neste exato momento em que escrevo este post já ocorreram mudanças na intenção de voto de 2 Deputados. Para isso, escrevi um pequeno script em **[python](https://www.python.org/)** que coleta os dados do site **[vem pra rua](http://mapa.vemprarua.net/br/)** e grava em um arquivo csv com o nome [`imp.csv`](/files/imp.csv), deixando-o pronto para ser analisado no R. Você ver este script **[aqui](https://gist.github.com/regisely/caefdf30313503bbf5d0bbae6e2a597d)**.

Uma vez obtidos os dados podemos carregá-lo no R digitando:

```r
data <- read.csv("imp.csv", sep = ";")
```

Aqui estão as primeiras 10 observações:

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

Para prevermos o resultado do Impeachment vamos utilizar o método de regressão com particionamento recursivo, implementado pelo pacote [`rpart`](https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf). A ideia é que podemos separar as decisões dos políticos em grupos baseados em seus Partidos e Estados. Esse método é ideal para o caso brasileiro, pois sabemos que existem cisões entre os partidos brasileiros dependendo do Estado.

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

Note que chamamos o conjunto dos Senadores e Deputados que já estão decididos de **train**, pois estes serão os dados utilizados para treinar nosso modelo. Posteriormente, aplicaremos os resultados do modelo nos dados denominados **test**, que é o conjunto dos políticos indecisos, e então teremos nossa previsão.

Para estimar o modelo digitamos:

```r
# Estimação do modelo
formula = Voto ~ Partido + Estado # o voto é função do Partido e Estado
fit_dep = rpart(formula, method = "class", data = train_dep)
fit_sen = rpart(formula, method = "class", data = train_sen)
fit_dep
fit_sen
```

Ao avaliar os resultados da variável `fit_dep`, obtemos os nódulos de divisão para os Deputados:

~~~
n= 384 

node), split, n, loss, yval, (yprob)
      * denotes terminal node

 1) root 384 119 A favor (0.69010417 0.30989583)  
   2) Partido=DEM,PEN,PHS,PMDB,PP,PPS,PR,PRB,PROS,PSB,PSC,PSD,PSDB,PSL,PTB,PTdoB,PTN,PV,REDE,SD 299  36 A favor (0.87959866 0.12040134)  
     4) Estado=AC,AL,DF,ES,GO,MG,MS,RJ,RO,RS,SC,SP 174   4 A favor (0.97701149 0.02298851) *
     5) Estado=AM,AP,BA,CE,MA,MT,PA,PB,PE,PI,PR,RN,RR,SE,TO 125  32 A favor (0.74400000 0.25600000)  
      10) Partido=DEM,PHS,PPS,PRB,PSB,PSC,PSD,PSDB,PSL,PV,REDE,SD 75   4 A favor (0.94666667 0.05333333) *
      11) Partido=PEN,PMDB,PP,PR,PROS,PTB,PTdoB,PTN 50  22 Contra (0.44000000 0.56000000)  
        22) Estado=AM,BA,CE,PE,PR,RN,TO 35  15 A favor (0.57142857 0.42857143)  
          44) Partido=PEN,PMDB,PR,PTB 20   5 A favor (0.75000000 0.25000000) *
          45) Partido=PP,PROS,PTdoB,PTN 15   5 Contra (0.33333333 0.66666667) *
        23) Estado=MA,MT,PA,PB,PI,RR,SE 15   2 Contra (0.13333333 0.86666667) *
   3) Partido=PCdoB,PDT,PSOL,PT 85   2 Contra (0.02352941 0.97647059) *> fit_dep
~~~

Parece complicado, mas uma maneira mais fácil de visualizar estes nódulos é graficamente. Para isso utilizamos a função `plot` no R. Para construirmos árvores mais bonitas utilizamos a função `text` com alguns argumentos especiais (digite `?plot.rpart` no R para mais informações).

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

Assim, obtemos os seguintes gráficos:

[![Árvore do Impeachment - Câmara (decididos)]({{ site.url }}/img/tree_dep.png)]({{ site.url }}/img/tree_dep.png)

[![Árvore do Impeachment - Senado (decididos)]({{ site.url }}/img/tree_sen.png)]({{ site.url }}/img/tree_sen.png)

Ainda assim não é tão simples, mas quem disse que a política brasileira era fácil de entender. Vamos primeiro analisar o Congresso. Repare que no primeiro nódulo há uma divisão partidária, com o grupo PCdoB, PDT, PSOL e PT de um lado, sendo que 2 Deputados são a favor e 83 contra o Impeachment. No resto dos partidos, existem divisões de acordo com o Estado. No grupo AC,AL,DF,ES,GO,MG,MS,RJ,RO,RS,SC,SP temos 170 Deputados a favor e apenas 4 contra, mas no restante dos Estados há divisões partidárias e por região. Resumindo, me parece que os partidos estão mais rachados nos Estados do Nordeste. No Senado a divisão é mais simples e parece ser explicada bastante pelo Estado do Senador.

## Previsão dos votos indecisos

Ao utilizar uma estrutura muito complicada para o nosso modelo, podemos acabar cometendo o erro de *overfitting* em nossa previsão. Para evitar isso, vamos utilizar as funções `printcp(fit_dep)` e `plotcp(fit_dep)` para verificar qual a estrutura de árvores que gera o menor erro de previsão em um conjunto independente, chamado *cross-validated*. No código abaixo faço essa seleção automaticamente e estimo o modelo novamente com a função `prune`. 


```r
# Seleção do modelo com menor erro
fit_dep <- prune(fit_dep,
                 cp = fit_dep$cptable[which.min(fit_dep$cptable[,"xerror"]),
                                      "CP"])
fit_sen <- prune(fit_sen,
                 cp = fit_sen$cptable[which.min(fit_sen$cptable[,"xerror"]),
                                      "CP"])
```

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

E o resultado será:

~~~
[1] 0.7465887 # Câmara dos Deputados
[1] 0.5308642 # Senado Federal
~~~

Parece que na situação atual, o Impeachment passa pela etapa de admissibilidade mas esbarra no julgamento do Senado Federal.

# Árvores com previsão

Para finalizar, vamos construir a árvore final que inclui os indecisos e utiliza o modelo simplificado com menor erro de previsão:

```r
# Altera os dados originais para incluir a previsão dos indecisos
new_dep <- deputados
new_dep[names(prev_dep), "Voto"] <- prev_dep
new_sen <- senadores
new_sen[names(prev_sen), "Voto"] <- prev_sen

# Constrõe a árvore com os indecisos
fit_dep_prev = rpart(formula, method = "class", data = new_dep)
fit_sen_prev = rpart(formula, method = "class", data = new_sen)

# Plota a árvore dos Deputados com os indecisos
plot(fit_dep_prev, uniform = TRUE,
    main = "Árvore do Impeachment - Câmara (com previsão de indecisos)",
    margin = 0.2)
text(fit_dep_prev, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)
mtext(paste0("Percentual previsto a favor: ",
             round(percentual_dep*100, digits = 2), "%"))

# Plota a árvore dos Senadores com os indecisos
plot(fit_sen_prev, uniform = TRUE,
    main = "Árvore do Impeachment - Senado (com previsão de indecisos)",
    margin = 0.3)
text(fit_sen_prev, use.n = TRUE, all = TRUE, cex = .8, pretty = TRUE,
     fancy = TRUE, minlength = 12, bg = "yellow")
mtext("Valores são: A favor/Contra", side = 1)
mtext(paste0("Percentual previsto a favor: ",
             round(percentual_sen*100, digits=2), "%"))
```

O resultado está abaixo:

[![Árvore do Impeachment - Câmara (com previsão de indecisos)]({{ site.url }}/img/tree_dep_prev.png)]({{ site.url }}/img/tree_dep_prev.png)

[![Árvore do Impeachment - Senado (com previsão de indecisos)]({{ site.url }}/img/tree_sen_prev.png)]({{ site.url }}/img/tree_sen_prev.png)

A árvore do Senado Federal nos mostra que a maior resistência ao Impeachment parece ser os partidos do PCdoB, PDT, PMDB, PP, PR, PRB, PSB, PSD, PT e PTB nos Estados AL, AM, AP, BA, MA, PA, PE, PI, PR, RJ, RN, RR, TO. O Impeachment precisa de 54 votos no Senado. Atualmente existem 36 Senadores com intenção de voto a favor e 26 contra. Assim, são necessários 18 votos dos 19 indecisos para a Presidente ser destituída do Cargo, ou então uma mudança no voto dos Senadores que se declararam contra o Impeachment.

Podemos visualizar a lista dos Senadores indecisos segundo o site **[vem pra rua](http://mapa.vemprarua.net/br/)** com o comando:

```r
senadores[which(is.na(senadores$Voto)), ]
```

O resultado nos dá:

~~~
447 <NA>             Acir Gurgacz         PDT     RO       1
448 <NA> Antonio Carlos Valadares         PSB     SE       1
449 <NA>            Ciro Nogueira          PP     PI       1
450 <NA>       Delcidio do Amaral Sem partido     MS       1
451 <NA>           Douglas Cintra         PTB     PE       1
452 <NA>            Elmano Ferrer         PTB     PI       1
453 <NA>  Fernando Bezerra Coelho         PSB     PE       1
454 <NA>               Helio Jose        PMDB     DF       1
455 <NA>       Joao Alberto Souza        PMDB     MA       1
456 <NA>            Jose Maranhao        PMDB     PB       1
457 <NA>              Lucia Vania         PSB     GO       1
458 <NA>         Marcelo Crivella         PRB     RJ       1
459 <NA>                Omar Aziz         PSD     AM       1
460 <NA>            Raimundo Lira        PMDB     PB       1
461 <NA>            Roberto Rocha         PSB     MA       1
462 <NA>                  Romario         PSB     RJ       1
463 <NA>              Romero Juca        PMDB     RR       1
464 <NA>             Sandra Braga        PMDB     AM       1
465 <NA>         Vicentinho Alves          PR     TO       1
~~~

## Atualizando as previsões

Como toda previsão é melhor a medida que incorpora a chegada de novas informações, fiz uma rotina para atualizar os resultados dessa previsão diariamente e publicar na tabela do início deste post.

*Nota:* A Tabela do início do post contém a previsão com os últimos dados, mas os gráficos, arquivo de dados e resultados ao longo do post se referem a data de 1º de abril, incluindo os nomes dos parlamentares indecisos. Para replicar os dados da tabela atualizada você precisar obter os novos dados a partir **[deste script](https://gist.github.com/regisely/caefdf30313503bbf5d0bbae6e2a597d)** escrito em Python. Para verificar a lista atualizada acesse o site [vem pra rua](http://mapa.vemprarua.net/br/).

Tem sugestões para melhorar o algoritmo? Tem dúvidas sobre a implementação? Encontrou algum typo no texto? Me avise nos comentários ou por email.
