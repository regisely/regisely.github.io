---
title: "Mercado de trabalho brasileiro pós-pandemia"
output:
  md_document:
    variant: gfm
    preserve_yaml: TRUE
knit: (function(inputFile, encoding) {
   rmarkdown::render(inputFile, encoding = encoding, output_dir = "../_posts") })
author: "Regis"
date: 2020-07-11
excerpt: "Como o mercado de trabalho no Brasil reagiu à pandemia e quais foram os grupos mais afetados? O auxílio emergencial foi bem focalizado? Neste post investigo algumas destas questões utilizando a edição especial da PNAD COVID19."
layout: post
categories:
  - R
  - mercado de trabalho
  - pandemia
  - home office
  - auxílio emergencial
---

Os efeitos da pandemia do COVID-19 e do isolamento social no mercado de trabalho brasileiro têm características peculiares. A maneira distinta como cada setor absorve este choque acaba gerando impactos heterogêneos no mercado de trabalho, e consequentemente os trabalhadores são afetados de maneira desigual.

Com o intuito de levantar informações sobre os impactos da pandemia para os diferentes grupos populacionais, o IBGE divulgou em de junho de 2020 os resultados da pesquisa [PNAD COVID19](https://covid19.ibge.gov.br/pnad-covid/). Esta pesquisa utiliza como base a amostra de domicílios da Pesquisa Nacional por Amostra de Domicílios Contínua ([PNAD Contínua](https://www.ibge.gov.br/estatisticas/sociais/populacao/17270-pnad-continua.html?edicao=18971&t=sobre)), sendo a amostra original obtida por um plano amostral conglomerado em dois estágios com estratificação das unidades primárias de amostragem (UPA).

Resumindo, a PNAD COVID19 é uma pesquisa com amostra complexa, e portanto, para se fazer generalizações sobre a população brasileira, devemos levar em conta o plano amostral e as ponderações. Maiores detalhes metodológicos sobre a amostragem da pesquisa PNAD COVID19 podem ser obtidos [aqui](https://biblioteca.ibge.gov.br/visualizacao/livros/liv101726.pdf).

Neste post, vamos utilizar esta pesquisa para responder algumas perguntas sobre como o mercado de trabalho brasileiro se comportou após a pandemia. As questões que vamos investigar são:

1. Quem pode fazer home office? Quais são as características socioeconômicas destes trabalhadores? Em quais Estados o trabalho remoto é mais comum?

2. Qual foi o efeito da pandemia no salário médio dos trabalhadores por tipo de vínculo empregatício? Os trabalhadores do setor privado foram mais afetados do que os funcionários públicos?

3. Quem recebe auxílio emergencial do governo? Este programa está alcançando pessoas de baixa renda? Em quais Estados as pessoas procuraram mais o auxílio? 

Para responder essas perguntas vamos primeiro ler alguns pacotes no `R`:


```r
library(tidyverse) ## Para manipulação de dados
library(srvyr) ## Para lidar com amostras complexas
library(readxl) ## Para ler dados do excel
library(viridis) ## Paleta de cores para gráficos
```

# Carregando os dados da PNAD COVID19

Vamos primeiro fazer o download dos dados da pesquisa. A *url* que contém a base de dados é salva na variável `pnad_url`, e então fazemos o download e descompactamos o arquivo:


```r
pnad_url <- paste0(
  "ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento",
  "/Pesquisa_Nacional_por_Amostra_de_Domicilios_PNAD_COVID19",
  "/Microdados/PNAD_COVID_052020_20200701.zip"
)
download.file(pnad_url, "pnad_covid.zip")
unzip("pnad_covid.zip")
```

Após estes comandos, alguns arquivos serão baixados no seu diretório de trabalho. Um deles será o arquivo de dados em formato *csv*, e o outro será um arquivo de dicionário com a descrição das variáveis, em formato *xls*.

Agora vamos ler os dados na varíavel `pnad`.


```r
pnad <- read_csv(
  "PNAD_COVID_052020.csv",
  col_types = cols(.default = "d")
)
```



Podemos sempre utilizar o dicionário para criar variáveis novas ou alterar o nome de algumas variáveis codificadas, como por exemplo, a variável `UF`. Vamos criar uma variável com o nome dos Estados para cada código da variável `UF`, e adicionar o nome dos Estados a base de dados original com o comando `left_join`:




```r
estados <- read_excel(
  "Dicionario_PNAD_COVID.xls", 
  sheet = "dicionário pnad covid",
  skip = 4, n_max = 27
) %>%
  select(UF = ...5, estado = ...6)

pnad <- pnad %>%
  left_join(estados, by = "UF")
```

Agora devemos especificar o desenho amostral complexo da pesquisa. Para isso utilizaremos o pacote `srvyr`, que permite utilizar a sintaxe do pacote `dplyr` em dados amostrais complexos.

Para especificar o desenho da amostra da PNAD COVID19, é necessário identificar a unidade primária de amostragem (UPA) no argumento `ids`, o estrato no argumento `strata`, e os pesos dos domicílios no argumento `weights`. Essas variáveis podem ser obtidas no dicionário. Note que existem dois pesos, o `V1031` e o `V1032`. O segundo é o peso pós-estratificação, que é o que utilizaremos. Se você utilizar o primeiro peso, deve realizar a estratificação manualmente através do comando `postStratify`.


```r
pnad_design <- pnad %>%
  as_survey_design(
    ids = UPA,
    strata = Estrato,
    weights = V1032,
    nest = TRUE
  )
```

Agora que definimos o desenho amostral complexo da PNAD, vamos criar algumas variavéis auxiliares para a nossa análise a partir dos códigos descritos no dicionário. Podemos utilizar a sintaxe do pacote `dplyr` para criação das variáveis.


```r
pnad_design <- pnad_design %>%
  mutate(
    one = 1,
    estado = fct_reorder(estado, desc(estado)),
    sexo = ifelse(A003 == 1, "Homem", "Mulher"),
    idade = case_when(
      A002 %in% 16:24 ~ "16-24",
      A002 %in% 25:34 ~ "25-34",
      A002 %in% 35:49 ~ "35-49",
      A002 %in% 50:64 ~ "50-64",
      A002 > 64 ~ "65+"
    ),
    cor = case_when(
      A004 == 1 ~ "Branca",
      A004 %in% c(2, 4) ~ "Preta ou Parda"
    ),
    escolaridade = factor(
      case_when(
        A005 %in% 1:2 ~ "Fundamental incompleto",
        A005 %in% 3:4 ~ "Fundamental completo",
        A005 %in% 5:6 ~ "Médio completo",
        A005 == 7 ~ "Superior completo",
        A005 == 8 ~ "Pós-graduação"
      ),
      levels = c(
        "Fundamental incompleto", "Fundamental completo",
        "Médio completo", "Superior completo", "Pós-graduação"
      )
    ),
    tipo_emprego = case_when(
      C007 == 2 ~ "Militar",
      C007 == 3 ~ "Policial ou bombeiro",
      C007 == 4 ~ "Setor privado",
      C007 == 5 ~ "Setor público",
      C007 == 6 ~ "Empregador",
      C007 == 7 ~ "Conta própria",
    ),
    tipo_emprego_curto = ifelse(
      tipo_emprego %in% c("Militar", "Policial ou bombeiro"),
      NA, tipo_emprego
    ),
    salario_usual = C01012,
    salario_maio = C011A12,
    home = ifelse(C013 == 1, "Home Office", "Presencial"),
    auxilio = ifelse(D0051 == 1, "Auxílio", "Sem auxílio"),
    faixa_renda = factor(
      case_when(
        C01012 < 1000 ~ "1000-",
        C01012 %in% c(1000:2999) ~ "1000-2999",
        C01012 %in% c(3000:4999) ~ "3000-4999",
        C01012 %in% c(5000:6999) ~ "5000-6999",
        C01012 %in% c(7000:9999) ~ "7000-9999",
        C01012 >= 10000 ~ "10000+"
      ),
      levels = c(
        "1000-", "1000-2999", "3000-4999",
        "5000-6999", "7000-9999", "10000+"
      )
    )
  )
```

Por fim, devemos conferir se o nosso desenho amostral está compatível com os dados reportados pelo IBGE. Vamos verificar o número de homens e mulheres na população brasileira e comparar com os resultados reportados na [tabela do IBGE](ftp://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_PNAD_COVID19/Mensal/Tabelas/pnad_covid19_202005_trabalho_BR_GR_UF_20200702.xlsx).


```r
pnad_design %>%
  group_by(sexo) %>%
  summarise(Total = survey_total(vartype = "ci"))
```

```
## # A tibble: 2 x 4
##   sexo        Total  Total_low  Total_upp
##   <chr>       <dbl>      <dbl>      <dbl>
## 1 Homem  103090474. 101888068. 104292880.
## 2 Mulher 107778927. 106547976. 109009878.
```

Os valores de 103 milhões de homens e 107 milhões de mulheres na população brasileira conferem com os valores das linhas 9 e 10 da tabela do IBGE. Podemos seguir realizando nossa análise, sempre levando em consideração o plano amostral complexo.

# Quem pode fazer home office?

Nem todo trabalho tem características que possibilitam os trabalhadores realizarem suas tarefas de casa. Alguns pessoas podem ter características que a fazem ser mais propensas a exercerem atividades em que o trabalho remoto é mais plausível. Quais são as características socioeconômicas destes trabalhadores?

Vamos primeiro olhar para os dados de home office divididos em grupos baseados no sexo e na cor dos indivíduos. Para isso, primeiro calculamos o total de indivíduos que estavam realizando trabalho remoto na semana anterior a pesquisa. Este dado pode ser obtido na variável `C013`. Depois obtemos o total de trabalhadores na variável `C001`, ou seja, indivíduos que realizaram algum tipo de trabalho na semana anterior a pesquisa. A razão destas duas variáveis corresponde a proporção de trabalhadores que realizaram trabalho remoto. Antes de fazermos este cálculo, iremos agrupar os indivíduos por sexo e cor.


```r
home_sexo_cor <- pnad_design %>%
  group_by(sexo, cor) %>%
  summarise(
    home_office = survey_total(C013 == 1, na.rm = TRUE),
    trabalhadores = survey_total(C001 == 1, na.rm = TRUE)
  ) %>%
  mutate("Home Office (%)" = (home_office / trabalhadores) * 100) %>%
  drop_na()
```

Com os dados calculados, podemos agora plotar um gráfico de barras com o sexo dos indivíduos no eixo vertical e a cor no preenchimento das barras.


```r
home_sexo_cor %>%
  ggplot(aes(fill = cor, y = `Home Office (%)`, x = sexo)) +
  geom_bar(position = "dodge", stat = "identity") +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  labs(
    x = "", fill = "Cor",
    title = "Percentual de trabalhadores em home office"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/sexo_cor_plot-1.png" title="plot of chunk sexo_cor_plot" alt="plot of chunk sexo_cor_plot" style="display: block; margin: auto;" />

Podemos tirar duas conclusões com estes dados:

1. As mulheres realizam trabalho remoto com mais frequência do que os homens,

2. A proporção de pessoas da cor branca que realizam trabalho remoto é muito maior em relação as pessoas de cor preta ou parda.

Parte desta diferença talvez possa ser explicada por outras variáveis, como a escolaridade. Vamos agrupar os dados por escolaridade e cor, e então plotar o mesmo gráfico de antes.


```r
home_edu_cor <- pnad_design %>%
  group_by(escolaridade, cor) %>%
  summarise(
    home_office = survey_total(C013 == 1, na.rm = TRUE),
    trabalhadores = survey_total(C001 == 1, na.rm = TRUE)
  ) %>%
  mutate("Home Office (%)" = (home_office / trabalhadores) * 100) %>%
  drop_na()

home_edu_cor %>%
  ggplot(aes(fill=escolaridade, y=`Home Office (%)`, x=cor)) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  labs(
    x = "", fill = "Escolaridade",
    title = "Percentual de trabalhadores em home office"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/edu_cor-1.png" title="plot of chunk edu_cor" alt="plot of chunk edu_cor" style="display: block; margin: auto;" />

Embora a diferença entre pessoas da cor branca e pessoas da cor preta ou parda ainda exista, boa parte da variação parece ser explicada pela escolaridade. Pessoas com nível mais alto de escolaridade tendem a ter atividades profissionais mais suscetíveis ao trabalho remoto.

Este gráfico mostra um retrato impiedoso das políticas de isolamento social. Profissionais com menores níveis de escolaridade têm possibilidades baixíssimas de realizar trabalho remoto, de modo que estão mais sujeitos a demissão ou redução salarial.

De maneira semelhante, podemos olhar para grupos separados por faixa etária e sexo.


```r
home_sexo_idade <- pnad_design %>%
  group_by(sexo, idade) %>%
  summarise(
    home_office = survey_total(C013 == 1, na.rm = TRUE),
    trabalhadores = survey_total(C001 == 1, na.rm = TRUE)
  ) %>%
  mutate("Home Office (%)" = (home_office / trabalhadores) * 100) %>%
  drop_na()

home_sexo_idade %>%
  ggplot(aes(fill=idade, y=`Home Office (%)`, x=sexo)) +
  geom_bar(position="dodge", stat="identity") +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  labs(
    x = "", fill = "Faixa etária",
    title = "Percentual de trabalhadores em home office"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/sexo_idade-1.png" title="plot of chunk sexo_idade" alt="plot of chunk sexo_idade" style="display: block; margin: auto;" />

Alguns padrões interessantes podem ser observados no gráfico acima:

1. Como visto anteriormente, os homens fazem menos trabalho remoto do que as mulheres, possivelmente por estarem em profissões que demandam mais presença física,

2. Jovens fazem menos trabalho remoto do que adultos e idosos, o que pode ser reflexo da falta de experiência profissional,

3. Homens idosos, com mais de 65 anos, fazem mais trabalho remoto do que homens de outras faixas etárias, entretanto, isso não é verdade para as mulheres. Uma possível explicação seria o fato de homens idosos alcançarem promoções em suas profissões com mais frequência do que mulheres idosas.

Outra possível variável que explica estas diferenças pode ser o Estado de residência do indivíduo. Vamos explorar quais as diferenças na realização de trabalho remoto entre os Estados.


```r
home_uf <- pnad_design %>%
  group_by(estado) %>%
  summarise(
    home_office = survey_total(C013 == 1, na.rm = TRUE),
    trabalhadores = survey_total(C001 == 1, na.rm = TRUE)
  ) %>%
  mutate("Home Office (%)" = (home_office / trabalhadores) * 100) %>%
  drop_na()

home_uf %>%
  ggplot(aes(fill = estado, y = `Home Office (%)`, x = estado)) + 
  geom_bar(position = "dodge", stat = "identity") +
  geom_text(
    aes(
      label = paste0(round(`Home Office (%)`, 2), "%"),
      y = `Home Office (%)` + 1.5, size = 4
    )
  ) +
  coord_flip() +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    legend.position = "none"
  ) +
  labs(
    x = "", y = "",
    title = "Percentual de trabalhadores em home office"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/home_estados-1.png" title="plot of chunk home_estados" alt="plot of chunk home_estados" style="display: block; margin: auto;" />

Os três Estados em que os trabalhadores mais realizam trabalho remoto são o Distrito Federal, o Rio de Janeiro e São Paulo. 

O Distrito Federal chama a atenção, pois lá existem muitos funcionários públicos. O tipo de vínculo empregatício pode ser uma variável relevante para explicar as diferenças observadas entre os grupos. Por isso vamos agrupar os dados por tipo de emprego e plotar um gráfico de barras com estas informações.


```r
home_emprego <- pnad_design %>%
  group_by(tipo_emprego) %>%
  summarise(
    home_office = survey_total(C013 == 1, na.rm = TRUE),
    trabalhadores = survey_total(C001 == 1, na.rm = TRUE)
  ) %>%
  mutate("Home Office (%)" = (home_office / trabalhadores) * 100) %>%
  drop_na()

home_emprego %>%
  ggplot(aes(fill=tipo_emprego, y=`Home Office (%)`, x=tipo_emprego)) + 
  geom_bar(position="dodge", stat="identity") +
  geom_text(
    aes(
      label = paste0(round(`Home Office (%)`, 2), "%"),
      y = `Home Office (%)` + 2, size = 5
    )
  ) +
  coord_flip() +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  theme(
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank(),
    legend.position = "none"
  ) +
  labs(
    x = "",
    title = "Percentual de trabalhadores em home office"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/emprego-1.png" title="plot of chunk emprego" alt="plot of chunk emprego" style="display: block; margin: auto;" />

Aqui um outro retrato particular do isolamento social surge. Trabalhadores da iniciativa pública são os que mais realizam trabalho remoto. A probabilidade de um trabalhador do setor público realizar trabalho remoto é mais do que o dobro da probabilidade de um trabalhador do setor privado realizar trabalho remoto. 

Por outro lado, há um percentual muito baixo de policiais, militares e trabalhadores conta própria que podem realizar trabalho remoto. Estes trabalhadores acabam tendo que decidir entre continuar exercendo suas atividades de forma presencial ou sofrer as consequências em termos de redução salarial ou demissão. Será que podemos observar algum padrão nas variações salariais pré e pós pandemia entre estes grupos?

# Quem perde mais renda com a pandemia?

Como vimos, alguns trabalhadores têm maiores possibilidades de realizar trabalho remoto. Isso pode criar uma margem de segurança para estes trabalhadores, uma vez que eles serão menos suscetíveis a demissões ou reduções salariais.

Podemos observar a variação de salário pré e pós pandemia para trabalhadores com diferentes tipos de vínculos. Isso é possível pois na PNAD COVID19 há duas perguntas relativas ao salário do indivíduo. A primeira pede sobre o salário que ele recebeu na semana de referência, e a segunda pede sobre o salário usual que ele costumava receber. Para obter maiores detalhes veja o [questionário](https://biblioteca.ibge.gov.br/visualizacao/instrumentos_de_coleta/doc5586.pdf).

Vamos construir um gráfico em que plotamos o salário antes e depois da pandemia para diversos tipos de emprego. O código para gerar o gráfico vai ser um pouco mais longo, pois faremos algumas anotações com a variação percentual do salário no gráfico.


```r
covid_salario <- pnad_design %>%
  group_by(tipo_emprego_curto) %>%
  summarise(
    salario_antes = survey_mean(salario_usual, na.rm = TRUE),
    salario_depois = survey_mean(salario_maio, na.rm = TRUE)
  ) %>%
  drop_na() %>%
  mutate(Variacao = (salario_depois / salario_antes) - 1)

covid_salario %>%
  ggplot() +
  geom_segment(
    aes(
      x = 1, xend = 2, y = salario_antes,
      yend = salario_depois, col = tipo_emprego_curto
    ),
    size = 0.75
  ) + 
  geom_vline(xintercept = 1, linetype = "dashed", size = .1) + 
  geom_vline(xintercept = 2, linetype = "dashed", size = .1) +
  geom_text(
    aes(
      label = round(salario_antes, 0), y = salario_antes,
      x = rep(1, length(salario_antes))
    ),
    hjust = 1.1, size = 5
  ) +
  geom_text(
    aes(
      label = round(salario_depois, 0),
      y = salario_depois,
      x = rep(2, length(salario_depois))
    ),
    hjust=-0.1, size=5
  ) + 
  geom_text(
    aes(
      label = "Antes", x = 1,
      y = 1.1*(max(salario_antes, salario_depois))
    ),
    hjust = 1.2, size = 6
  ) +
  geom_text(
    aes(
      label = "Depois", x = 2,
      y = 1.1*(max(salario_antes, salario_depois))
    ),
    hjust = -0.1, size = 6
  ) +
  geom_text(
    aes(
      label = paste0(round(Variacao*100, 2), "%"),
      y = (salario_antes + salario_depois)/2 - 300,
      x = rep(1.5, length(salario_depois)),
      col = tipo_emprego_curto
    ),
    size = 5,
    show.legend = FALSE
  ) +
  xlim(.8, 2.2) +
  theme_classic(base_size = 16) +
  theme(
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.line = element_blank(),
    plot.title = element_text(hjust = 0.5),
    legend.position = "bottom"
  ) +
  labs(
    x = "", y = "", color = "",
    title = "Salário médio pré e pós isolamento social no Brasil",
    caption = "Fonte dos dados: PNAD COVID19"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/salario-1.png" title="plot of chunk salario" alt="plot of chunk salario" style="display: block; margin: auto;" />

Observamos que os trabalhadores conta própria foram de fato os mais afetados pelo isolamento social, uma vez que a renda média deste grupo caiu mais de 40%. Em segundo lugar vem os empregadores, com uma queda de cerca de 30% em sua renda média. Parece que o único grupo que foi pouco afetado pelo isolamento social em termos de salário foram os funcionários públicos. Agora podemos entender o reflexo dos altos níveis de trabalho remoto no Distrito Federal em termos de salário. 

# Quem recebeu auxílio emergencial?

Como forma de atenuar os efeitos da crise econômica causada pela pandemia, o Governo Federal instituiu o [Auxílio Emergencial](https://auxilio.caixa.gov.br/), um benefício financeiro destinado aos trabalhadores informais, microempreendedores individuais, autônomos e desempregados.

O benefício do auxílio emergencial corresponde ao valor de R$ 600,00, que é pago por três meses para até duas pessoas da mesma família. Para ter acesso ao auxílio, a pessoa deve cumprir os seguintes requisitos:

1. Ser maior de 18 anos ou mãe adolescente,

2. Não ter emprego formal,

3. Não receber benefício previdenciário ou assistencial (como seguro-desemprego),

4. Ter renda familiar mensal per capita de até meio salário mínimo (R$ 522,50), ou renda familiar mensal total de até três salários mínimos (R$ 3.135,00),

5. Não ter recebido rendimento tributáveis acima de R$ 28.559,70 durante o ano de 2018,

6. Estar desempregado ou exercendo atividades de microempreendedor individual ou trabalho informal

Apesar de todos estes critérios, houve inúmeros relatos de casos em que pessoas solicitaram o auxílio mesmo não se enquadrando nos critérios para recebê-lo. Da mesma forma, algumas pessoas que necessitavam do auxílio acabaram não recebendo por problemas cadastrais ou falta de acesso aos bancos e aplicativos.

Com os dados da PNAD COVID19 podemos ter alguma ideia sobre a focalização destes benefícios, uma vez que os entrevistados respondem se receberam ou não o auxílio, além de reportarem a renda no caso em que exerceram algum tipo de atividade, mesmo que informal.

Vamos olhar para a proporção de indivíduos que receberam auxílio por faixa de renda. Neste caso, estamos olhando apenas para os beneficiários que exerceram algum tipo de trabalho na semana de referência.


```r
auxilio_renda <- pnad_design %>%
  group_by(faixa_renda) %>%
  summarise(
    auxilio = survey_total(D0051 == 1, na.rm = TRUE),
    total = survey_total(one, na.rm = TRUE)
  ) %>%
  mutate("Auxílio Emergencial (%)" = (auxilio / total) * 100) %>%
  drop_na()

auxilio_renda %>%
  ggplot(
    aes(
      fill = faixa_renda,
      y = `Auxílio Emergencial (%)`,
      x = faixa_renda
    )
  ) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_text(
    aes(
      label = paste0(round(`Auxílio Emergencial (%)`, 2), "%"),
      y = `Auxílio Emergencial (%)` + 6
    ),
    size = 6
  ) +
  coord_flip() +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  theme(
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  labs(
    x = "", fill = "Faixa de renda",
    title = "Percentual de trabalhadores que receberam auxílio emergencial"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/auxilio_renda-1.png" title="plot of chunk auxilio_renda" alt="plot of chunk auxilio_renda" style="display: block; margin: auto;" />

Como esperado, o percentual de beneficiários nos estratos inferiores de renda é significativamente maior, correspondendo a cerca de 2/3 da amostra. Note que, além da renda, há uma série de outros critérios que os indivíduos devem respeitar para receber o benefício, logo, não é esperado que todos aqueles que reportem renda baixa recebam o benefício. Mas, por outro lado, deve haver uma alta correlação entre receber auxílio e ter renda baixa caso o programa esteja bem focalizado.

Podemos olhar também para o percentual de pessoas em cada Estado que receberam o auxílio emergencial, considerando agora não só os trabalhadores, mas toda a população do Estado.


```r
auxilio_uf <- pnad_design %>%
  group_by(estado) %>%
  summarise(
    auxilio = survey_total(D0051 == 1, na.rm = TRUE),
    total = survey_total(one, na.rm = TRUE)
  ) %>%
  mutate("Auxílio Emergencial (%)" = (auxilio / total) * 100) %>%
  drop_na()

auxilio_uf %>%
  ggplot(
    aes(fill = estado, y = `Auxílio Emergencial (%)`, x = estado)
  ) +
  geom_bar(position = "dodge", stat = "identity") +
  geom_text(
    aes(
      label = paste0(round(`Auxílio Emergencial (%)`, 2), "%"),
      y = `Auxílio Emergencial (%)` + 3
    ),
    size = 4
  ) +
  coord_flip() +
  scale_fill_viridis(discrete = T) +
  theme_classic(base_size = 16) +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text.x = element_blank(),
    legend.position = "none"
  ) +
  labs(
    x = "",
    y = "",
    title = "Percentual de trabalhadores que receberam auxílio emergencial"
  )
```

<img src="/figure/source/2020-07-11-mercado-de-trabalho-covid/auxilio_estados-1.png" title="plot of chunk auxilio_estados" alt="plot of chunk auxilio_estados" style="display: block; margin: auto;" />

Os números são surpreendentemente grandes. De acordo com os dados do IBGE, o alcance do auxílio emergencial chegou a mais de 60% das pessoas em alguns Estados, como no Alagoas, Amapá, Amazonas, Bahia, Ceará, Maranhão, Pará e Piauí. Por outro lado, os Estados com o menor número de beneficiários são Santa Catarina, Rio Grande do Sul e Distrito Federal.

Acabamos por aqui! Ainda há bastante coisa para explorar nestes dados, mas acredito que este post pode ser útil para quem queira utilizar a PNAD COVID19 em suas análises no `R`. 
