---
title: "Mercados financeiros e a COVID-19: um comparativo das respostas à crise"
output:
  md_document:
    variant: gfm
    preserve_yaml: TRUE
knit: (function(inputFile, encoding) {
   rmarkdown::render(inputFile, encoding = encoding, output_dir = "../_posts") })
author: "Regis"
date: 2020-05-31
excerpt: "O Brasil parece ter sido um dos países mais afetados pela depreciação do câmbio e pela desvalorização do mercado acionário durante a crise da COVID-19. Neste post investigo algumas razões para isso."
layout: post
categories:
  - R
  - monetary policy
  - finance
  - foreign exchange markets
  - stock markets
---

Os efeitos de crises econômicas costumam ser heterogêneos entre países com características institucionais distintas. Isto não deve ser exceção para a crise atual gerada pela pandemia do COVID-19. O Brasil parece ter sido um dos países mais afetados pela depreciação do câmbio e pela desvalorização do mercado acionário. As razões disso ainda não são claras, mas talvez duas hipóteses podem ser levantadas:

1. A resposta da política monetária foi muito agressiva, ocasionando uma saída de capital maior em relação a outros países;

2. A depreciação do câmbio e a desvalorização no mercado acionário é reflexo de expectativas relativas à crise política e/ou à situação fiscal das contas públicas.

O ponto 1 parece ser relativamente fácil de verificarmos comparando a resposta da política monetária no Brasil em relação a outros países. Já o ponto 2 parece ser uma hipótese teórica razoável caso 1 não seja válido, uma vez que é natural pensar que países mais endividados e com situação política mais agravada sofram de maneira mais intensa durante esta crise.

Podemos utilizar o `R` para inferir sobre a validade da hipótese 1. Vamos verificar quais foram as consequências desta crise no mercado acionário e cambial para diversos países, bem como analisar a resposta da política monetária.

Primeiro vamos carregar alguns pacotes que serão necessários na análise. Para replicar os resultados é necessário instalar estes pacotes no `R`.


```r
library(tidyverse) ## Para manipulação de dados
library(lubridate) ## Para lidar com datas no R
library(tidyquant) ## Para baixar dados dos mercados acionários
library(Quandl) ## Para baixar dados das taxas de câmbio
library(OECD) ## Para baixar dados das taxas de juros
library(slider) ## Para criar médias móveis de séries de tempo
```

# Efeito da crise nos mercados acionários

Com o pacote `tidyquant` podemos baixar os dados dos principais índices do mercado acionário disponíveis no [Yahoo! Finance](https://finance.yahoo.com/). Uma lista completa dos índices e códigos desta base de dados pode ser obtida [aqui](https://finance.yahoo.com/world-indices). Vamos primeiro criar um `tibble` com os códigos e nomes dos índices que utilizaremos e depois baixar os dados de janeiro de 2020 a maio de 2020.


```r
indexes <- tibble(
  symbol = c(
    "^BVSP", "^GSPC", "^DJI", "^IXIC", "^FTSE", "^GDAXI", "^FCHI",
    "^STOXX50E", "IMOEX.ME", "^N225", "^HSI", "000001.SS", "^STI",
    "^AXJO", "^BSESN", "^JKSE", "^KLSE", "^NZ50", "^KS11", "^TWII",
    "^GSPTSE", "^MXX", "^MERV", "^TA125.TA", "^JN0U.JO"
  ),
  exchange = c(
    "Ibovespa", "S&P 500", "Dow Jones", "Nasdaq", "FTSE 100", "DAX",
    "CAC 40", "Euro Stoxx 50", "MOEX Russia", "Nikkei 225",
    "Hang Seng Index", "SSE Index", "STI Index", "S&P/ASX 200",
    "S&P BSE SENSEX", "Jakarta Index", "FBM KLCI", "S&P/NZX 50",
    "KOSPI Index", "TSEC Index", "S&P/TSX", "IPC Mexico", "Merval",
    "TA-125", "South Africa Top 40"
  )
)
  
ind_quotes <- tq_get(
  indexes$symbol, get  = "stock.prices", from = "2020-01-01", to = "2020-05-29"
)
```

Podemos adicionar os nomes das bolsas de valores à variável `ind_quotes` com o comando `left_join` e então comparar a evolução dos índices calculando o retorno acumulado a partir de janeiro de 2020. Para suavizar os dados, vamos tirar uma média móvel de 5 dias desse retorno acumulado. É importante removermos os dados faltantes dos valores ajustados dos índices e agruparmos as observações por índice antes de fazermos este cálculo.


```r
ind_ret <- ind_quotes %>%
  left_join(indexes, by = "symbol") %>%
  drop_na(adjusted) %>%
  group_by(symbol) %>%
  mutate(cumret = adjusted / first(adjusted) - 1) %>%
  mutate(MA = slide_dbl(cumret, mean, .before = 5, .complete = TRUE)) %>%
  ungroup()
```

Agora plotamos a média móvel de 5 dias do retorno acumulado de todos os índices para compararmos os países, destacando o Ibovespa no gráfico.


```r
ind_ret %>%
  drop_na(MA) %>%
  ggplot(aes(x = date, y = MA, color = exchange, size = exchange)) +
  geom_line() +
  scale_size_manual(values = c(rep(0.5, 7), 1.5, rep(0.5, dim(indexes)[1]-8))) +
  theme_bw(base_size = 18) +
  theme(
    legend.justification = c(0, 0),
    legend.position = c(0, 0),
    legend.background = element_rect("transparent"),
    legend.key = element_rect("transparent")
  ) +
  labs(
    x = "", y = "Cumulative percent return",
    color = "Stock Exchanges",
    size = "Stock Exchanges",
    title = "5-day Moving Average of Cumulative Percent Returns of Stock Exchanges in 2020",
    caption = "Source: Yahoo! Finance"
  )
```

![plot of chunk ind_plot](/figure/source/2020-05-28-covid-economic-responses/ind_plot-1.png)

Dentre as 26 bolsas analisadas, a Ibovespa foi a que teve o pior retorno acumulado durante o ano de 2020. Talvez esse resultado negativo também esteja associado as movimentações no mercado cambial. 

# Efeito da crise nos mercados cambiais

Vamos tentar fazer um gráfico semelhante para os mercados cambiais. Para isso utilizaremos a base de dados do banco central americano, [*Federal Reserve Economic Data (FRED)*](https://fred.stlouisfed.org/). Os dados serão acessados através da plataforma [Quandl](https://www.quandl.com/). Para você replicar este estudo, deve fazer um login no site e obter um código de acesso à API do Quandl. Com o código em mãos, basta rodar o seguinte comando no `R`:


```r
Quandl.api_key("your_api_here")
```



Para carregar os dados das taxas de câmbio de vários países em relação ao dólar, vamos primeiro criar um `tibble` com os códigos e nomes das moedas e em seguida baixar os dados com o comando `Quandl`. Uma lista detalhada das taxas de câmbio disponíveis para download no `Quandl` pode ser encontrada [aqui](https://blog.quandl.com/api-for-currency-data).


```r
currs <- tibble(
  code = c("DEXUSAL", "DEXBZUS", "DEXUSUK", "DEXCAUS", "DEXCHUS", "DEXDNUS",
           "DEXUSEU", "DEXHKUS", "DEXINUS", "DEXJPUS", "DEXMAUS", "DEXMXUS",
           "DEXTAUS", "DEXUSNZ", "DEXNOUS", "DEXSIUS", "DEXSFUS", "DEXKOUS",
           "DEXSLUS", "DEXSDUS", "DEXSZUS", "DEXTHUS"),
  Currency = c("Australian Dollar (AUD)", "Brazilian Real (BRL)",
               "British Pound (GBP)", "Canadian Dollar (CAD)",
               "Chinese Yuan (CNY)", "Denish Krone (DKK)", "Euro (EUR)",
               "Hong Kong Dollar (HKD)", "Indian Rupee (INR)",
               "Japanese Yen (JPY)", "Malaysian Ringgit (MYR)",
               "Mexican Peso (MXN)", "New Taiwan Dollar (TWD)",
               "New Zealand Dollar (NZD)", "Norwegian Krone(NOK)",
               "Singapore Dollar (SGD)", "South African Rand(ZAR)",
               "South Korean Won (KRW)", "Sri Lankan Rupee(LKR)",
               "Swedish Krona (SEK)", "Swiss Franc (CHF)", "Thai Baht (THB)")
)

fx_rates <- Quandl(
  paste0("FRED/", currs$code), type = "raw", order = "asc",
  start_date = "2020-01-01", end_date = "2020-05-29"
)
colnames(fx_rates) <- c("date", currs$code)
```

É importante observar que algumas moedas têm relação inversa com o dólar. Mais precisamente, são quatro moedas na base do `FRED` que devem ser corrigidas: *Australian Dollar (AUD)*, *British Pound (GBP)*, *Euro (EUR)* e *New Zealand Dollar (NZD)*.

Vamos corrigir estes detalhes, adicionar o nome completo das moedas, calcular a variação acumulada a partir de janeiro de 2020 e tirar uma média móvel de 5 dias dessa variação. Tudo em alguns simples comandos no `R`:


```r
inverted <- c("DEXUSAL", "DEXUSUK", "DEXUSEU", "DEXUSNZ")
fx_rates <- fx_rates %>%
  pivot_longer(-date, names_to = "code", values_to = "rate") %>%
  left_join(currs, by = "code") %>%
  mutate(rate = if_else(code %in% inverted, 1/rate, rate)) %>%
  drop_na() %>%
  group_by(code) %>%
  mutate(cumrate = (rate / first(rate)) - 1) %>%
  mutate(MA = slide_dbl(cumrate, mean, .before = 5, .complete = TRUE)) %>%
  ungroup()
```

Agora vamos fazer um gráfico semelhante ao dos mercados acionários, destacando o Brasil.


```r
fx_rates %>%
  drop_na(MA) %>%
  ggplot(aes(x = date, y = MA, color = Currency, size = Currency)) +
  geom_line() +
  scale_size_manual(values = c(0.5, 1.5, rep(0.5, dim(currs)[1]-2))) +
  theme_bw(base_size = 18) +
  theme(
    legend.justification = c(0, 1),
    legend.position = c(0, 1),
    legend.background = element_rect("transparent"),
    legend.key = element_rect("transparent")
  ) +
  labs(
    x = "", y = "Cumulative percent change",
    title = "5-day Moving Average of Cumulative Percent Change of Exchange Rates in 2020",
    caption = "Source: Federal Reserve Economic Data (FRED)"
  )
```

![plot of chunk fx_plot](/figure/source/2020-05-28-covid-economic-responses/fx_plot-1.png)

Entre as taxas de câmbio disponíveis na base de dados do `FRED`, o Brasil teve a maior depreciação da moeda durante o ano de 2020. Os dados até aqui comprovam que o Brasil foi provavelmente o país mais afetado em termos do mercado acionário e cambial. Ambos os mercados refletem expectativas dos agentes econômicos. Agora resta verificarmos se a hipótese 1 faz sentido, ou seja, será que as expectativas dos agentes foram afetadas negativamente em resposta a uma política monetária muito agressiva por parte do Banco Central do Brasil durante a crise?

# Respostas da política monetária ao COVID-19

Para verificarmos como os Bancos Centrais atuaram durante a crise, vamos baixar os dados de taxa de juros da [*OECD Main Economic Indicators (MEI)*](https://stats.oecd.org/index.aspx?queryid=86). Podemos obter os dados com o pacote `OECD`. Primeiro verificamos a estrutura dos dados através da função `get_data_structure`.


```r
info_oecd <- get_data_structure("MEI_FIN")
info_oecd$VAR_DESC
```

```
##                 id        description
## 1          SUBJECT            Subject
## 2         LOCATION            Country
## 3        FREQUENCY          Frequency
## 4             TIME               Time
## 5        OBS_VALUE  Observation Value
## 6      TIME_FORMAT        Time Format
## 7       OBS_STATUS Observation Status
## 8             UNIT               Unit
## 9        POWERCODE    Unit multiplier
## 10 REFERENCEPERIOD   Reference period
```

As variáveis disponíveis estão descritas em `SUBJECT`. Vamos utilizar a variável *Immediate interest rates (per cent per annum)*, que reflete as mudanças de curtíssimo prazo que ocorreram na definição da taxa de juros. Esta variável tem frequência mensal, reportando a média da taxa de juros relativa a todos os dias do mês, sendo que a última atualização é referente ao mês de abril, não contendo as últimas mudanças que ocorreram na taxa de juros durante o mês de maio.

É importante ressaltar que, no início de maio, ocorreu a [230º reunião do Copom](https://www.bcb.gov.br/detalhenoticia/17067/nota), que decidiu por reduzir a taxa Selic para 3,00% ao ano, adicionando um corte de 0,75 pontos percentuais. Para não precisarmos esperar pela atualização da base de dados por parte da OCDE, podemos adicionar essa informação manualmente. Entretanto, outros países também podem ter reduzido suas taxas de juros. Para manter a comparação razoável, vamos utilizar os dados referentes a abril mesmo. Posteriormente é possível atualizar os dados com as novas informações.


```r
tibble(info_oecd$SUBJECT)
```

```
## # A tibble: 12 x 2
##    id       label                                                               
##    <chr>    <chr>                                                               
##  1 MANM     Narrow Money (M1) Index, SA                                         
##  2 IRLT     Long-term interest rates, Per cent per annum                        
##  3 IR       Interest Rates                                                      
##  4 CCUS     Currency exchange rates, monthly average                            
##  5 IR3TIB   Short-term interest rates, Per cent per annum                       
##  6 MABM     Broad Money (M3) Index, SA                                          
##  7 CCRETT01 Relative consumer price indices                                     
##  8 IRSTCI   Immediate interest rates, Call Money, Interbank Rate, Per cent per …
##  9 MA       Monetary Aggregates                                                 
## 10 CCRETT02 Relative unit labour costs                                          
## 11 SP       Share Prices, Index                                                 
## 12 CC       Exchange Rates
```

Os países disponíveis na base de dados da OCDE podem ser visualizados em `LOCATION`.


```r
tibble(info_oecd$LOCATION)
```

```
## # A tibble: 51 x 2
##    id    label         
##    <chr> <chr>         
##  1 AUS   Australia     
##  2 AUT   Austria       
##  3 BEL   Belgium       
##  4 CAN   Canada        
##  5 CHL   Chile         
##  6 COL   Colombia      
##  7 CZE   Czech Republic
##  8 DNK   Denmark       
##  9 EST   Estonia       
## 10 FIN   Finland       
## # … with 41 more rows
```

Vamos salvar o código e o nome de todos os países em um `tibble` para fazermos o download dos dados.


```r
intrates <- info_oecd$LOCATION %>%
  rename(code = id, Country = label)
```

Agora utilizamos o comando `get_dataset` para baixar todos os dados, filtrando pelo código das séries que desejamos (`IRSTCI`), pelos países disponíveis (`intrates$code`), e selecionando a frequência mensal (`M`). Aproveitamos para renomear as variáveis, definir uma variável do tipo data, selecionar as colunas relevantes e adicionar o nome completo dos países.


```r
interest_rates <- get_dataset(
  "MEI_FIN",
  filter = list("IRSTCI", intrates$code, "M")
) %>%
  rename(code = LOCATION, date = obsTime, rate = obsValue) %>%
  mutate(date = ymd(paste0(date, "-01"))) %>%
  select(date, code, rate) %>%
  left_join(intrates, by = "code")
```

Na variável `interest_rates` está todo o histórico das taxas de juros para um conjunto de 31 países, em formato de painel. Para nós, o interessante é apenas a variação na taxa de juros que ocorreu após a crise. Por isso vamos criar uma variável que contém as taxas de juros antes da crise, em fevereiro de 2020, e após a crise, em abril de 2020. Também removemos os países que não possuem dados para algum destes dois meses e os ordenamos pelo tamanho da diferença entre essas duas taxas.


```r
int_changes <- interest_rates %>%
  filter(date %in% c(ymd("2020-02-01"), ymd("2020-04-01"))) %>%
  pivot_wider(names_from = "date", values_from = rate) %>%
  mutate(before = `2020-02-01`, after = `2020-04-01`, diff = after - before) %>%
  drop_na() %>%
  arrange(desc(diff)) %>%
  select(Country, before, after)
```

Com a variável `int_changes` pronta, podemos plotar um gráfico para descrever as mudanças que ocorreram nas taxas de juros antes e depois da crise para diversos países. Os países estão ordenados pelo maior corte de juros em pontos percentuais.


```r
ggplot(
  int_changes %>%
  mutate(Country = factor(Country, levels = int_changes$Country)),
  aes(x = before, xend = after, y = Country, color = c("Feb 2020", "Apr 2020"))
) + 
  geom_segment(
    aes(x = before, xend = after, y = Country, yend = Country),
    color = "grey", size = 1.5
  ) +
  geom_point(aes(x = before, y = Country, color = "Apr 2020"), size = 6) +
  geom_point(aes(x = after, y = Country, color = "Feb 2020"), size = 6) +
  geom_text(
    aes(
      x = before, label = format(round(before, 2), nsmall = 2),
      hjust = -0.5 + if_else(sign(before - after) > 0, 0, 2)
    ), color = "black", size = 5
  ) +
  geom_text(
    aes(
      x = after, label = format(round(after, 2), nsmall = 2),
      hjust = 1.5 + if_else(sign(before - after) > 0, 0, -2)
    ), color = "black", size = 5
  ) +
  scale_x_continuous(limits = c(-1.5, 7), breaks = -1:7) +
  scale_color_manual(
    name = element_blank(),
    labels = c("Feb 2020", "Apr 2020"),
    values = c("#33B31A80", "#B3331A80")
  ) +
  theme_bw(base_size = 18) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank()) +
  labs(
    x = NULL, y = NULL, 
    title = "Interest rate changes in response to COVID-19",
    subtitle = "Monthly average of interest rates (per cent per annum)", 
    caption = "Source: OECD - Main Economic Indicators"
  )
```

<img src="/figure/source/2020-05-28-covid-economic-responses/intrate_plot-1.png" title="plot of chunk intrate_plot" alt="plot of chunk intrate_plot" style="display: block; margin: auto;" />

O Brasil está perto da mediana dos países, ou seja, parece que a resposta do Banco Central do Brasil não foi tão agressiva. Os países com o maior corte em pontos percentuais são a África do Sul e os Estados Unidos.

Como a magnitude das taxas se diferenciam, podemos calcular o tamanho do corte dos juros em termos percentuais para cada país e verificar se o Brasil ainda se encontra perto da mediana dos países. Nos comandos abaixo calculamos este percentual, deixamos apenas os países que tiveram cortes na taxa de juros e então plotamos um gráfico de barras ordenando os países pelo tamanho do corte em termos percentuais.


```r
int_changes %>%
  mutate(percent = (after / before - 1) * 100) %>%
  filter(percent < -0.5) %>%
  ggplot(aes(y = reorder(Country, -percent), x = -percent)) +
  geom_bar(stat = "identity", fill = "#2297E6") +
  theme_bw(base_size = 18) +
  theme(legend.position = "none") +
  labs(
    x = "Negative Percent Change", y = NULL, 
    title = "Negative percent changes in interest rates after COVID-19",
    subtitle = "Monthly average of interest rates from Feb 2020 to Apr 2020", 
    caption = "Source: OECD - Main Economic Indicators"
  )
```

<img src="/figure/source/2020-05-28-covid-economic-responses/intrate_percent-1.png" title="plot of chunk intrate_percent" alt="plot of chunk intrate_percent" style="display: block; margin: auto;" />

Agora os Estados Unidos aparecem no topo, como o país que mais reduziu juros em termos percentuais. O Brasil se encontra no final, reafirmando a rejeição da nossa hipótese 1, ou seja, a política de juros parece não ter sido agressiva após a crise.

Entretanto, é importante salientar que o Brasil já estava reduzindo sua taxa de juros consistentemente ao longo dos anos. Com isso, a crise pode ter intensificado a saída de capital estrangeiro que já estava naturalmente acontecendo. No gráfico abaixo plotamos o histórico da taxa de juros no Brasil ao longo dos últimos 20 anos.


```r
interest_rates %>%
  filter(Country == "Brazil" & date >= "2000-01-01") %>%
  ggplot(aes(x = date, y = rate)) +
  geom_line() +
  theme_bw(base_size = 18) +
  labs(
    x = NULL, y = "Interest rate", 
    title = "Interest rate in Brazil since 2000",
    subtitle = "Monthly average of interest rates (per cent per annum)", 
    caption = "Source: OECD - Main Economic Indicators"
  )
```

<img src="/figure/source/2020-05-28-covid-economic-responses/brazil_plot-1.png" title="plot of chunk brazil_plot" alt="plot of chunk brazil_plot" style="display: block; margin: auto;" />

Para finalizar, podemos concluir que a resposta da política monetária no Brasil após a crise parece não ter sido desproporcional. Entretanto, a tendência de queda nos juros, o aumento do grau de incerteza dos agentes econômicos, a instabilidade política e institucional, e a situação fiscal do país, podem ser algumas das razões que explicam o fato de o mercado acionário e cambial brasileiro estarem entre os mais afetados durante a pandemia da COVID-19.
