---
layout: post
title: "macrodata"
subtitle: an R package for macroeconometrists
tags: [macrodata, cross country, macroeconometrics, Quandl, R]
date: 2016-01-15 10:00:00 -0700
---

Everyone that works with cross country macroeconomic data and uses R should know [Quandl](http://quandl.com). The [Quandl package for R](https://cran.r-project.org/web/packages/Quandl/) is a nice way to gather data using the Quandl API, but it has some drawbacks. They currently do not suppport panel data and the search function **`Quandl.search()`** does not allow for specific filters.

If one wants to quickly build a cross country panel data using macroeconomic time series variables available through Quandl there is a nice solution that I am developing: the [macrodata](https://github.com/regisely/macrodata) package. The development version currently works for almost all series from World Bank and OECD, and should work for other databases as well, but it is dependent in the pattern of the codes, which may change across datasets. You can view the documentation [here](/files/macrodata-manual.pdf).

Use the following code in R (>= 3.2.2) to install the development version of the package:

{% highlight r linenos %}
install.packages("devtools") # install devtools if you don't have it yet
library(devtools)
install_github("regisely/macrodata")
{% endhighlight %}

# Correlations between Time to start a business and GDP per capita

In order to demonstrate the usage of the macrodata package let's check if countries where you can start a business in less time have higher GDP per capita.

First load the package, then authenticate the Quandl API: 

{% highlight r linenos %}
library(macrodata)
Quandl.api_key("YOUR_API_HERE")
{% endhighlight %}

Remember that you can easily get a key by registering at [quandl.com](http://quandl.com) for free.

## Searching the variables

First we want to search for two specific time series: *time to start a business* and *gdp per capita*. We will be using the **`searchQ()`** function. This function improves **`Quandl.search()`** function in three ways:

1. It allows more than 100 results per query;
2. It allows filter by specific countries or part of the name of a series;
3. It allows filter by specific frequencies.

If you want to build a cross country panel data, the best way to start is to search the variables first for a specific country and then select the variables of interest, requesting them for all countries wanted. You can search one variable at a time or maybe try to find them all in one search. Let's try the second by typing:

{% highlight r linenos %}
search <- searchQ("gdp per capita start business", country = "Brazil",
                  database = "WWDI")
{% endhighlight %}

Note that I saved the results in the search variable. This is important since you want to refer to that variable when requesting data from other countries. I also used the World Bank database by specifying `database = "WWDI"`, and I've filtered the results for the country of Brazil. If you do not filter by a specific country, the search will show the same variable for each country. We don't want that behavior, since we are only interested in selecting the variables of interest at the moment.

There are three more arguments to the **`searchQ()`** function. You can specify the frequency as "annual", "quarterly", "monthly" or "daily", e.g. `frequency = "annual"`. You can specify the number of results, e.g. `n = 500` (the default is 300). And you can also use `view = FALSE` if you don't want to view the query after the search, which is the common behavior.

## Requesting cross country data

By looking at our search results we can see that the variables we are interested in are:

- GDP per capita, PPP (constant 2005 international $)
- Time required  to start a business (days)

Those variables are in rows 9 and 11, respectively (it may be different for you, so in this case you need to adjust the row numbers in the code below). Now we can request all the data from G20 countries using the **`requestQ()`** function:

{% highlight r linenos %}
data <- requestQ(search, c(9, 11), countries = "G20")
{% endhighlight %}

The **`requestQ()`** function also accepts all arguments of the original **`Quandl()`** function. It uses the following arguments as defaults: `type = "xts"`, `order = "asc"` and `collapse = "annual"`. Note that the first two arguments of this function are the result of **`searchQ()`** function and the rows indicating the variables of interest. The argument `countries` can contain any list of countries or specific group of countries such as: Europe, European Union, Euro Area, Eastern Europe, Western Europe, America, Latin America, North America, South America, Asia, Oceania, Africa, MENA, G20 and G7. 

Our data variable will now be a list of xts objects, with the first element containing the GDP per capita variable and the second element containing the Time to start a business variable. The rows indicate the year and the columns indicate the countries. This is what the first 5 rows and 5 columns of the GDP variable looks like:

{% highlight r linenos %}
head(data[[1]][,1:5])
{% endhighlight %}

~~~
##                 MEX      AUS      CAN      CHN      TUR
## 1990-12-31 12479.33 28604.22 31163.07 1516.214 10670.17
## 1991-12-31 12737.93 28121.66 30090.16 1634.281 10567.63
## 1992-12-31 12925.46 27894.75 29977.04 1844.851 10920.01
## 1993-12-31 13172.19 28732.42 30423.88 2077.954 11569.41
## 1994-12-31 13516.49 29579.80 31505.09 2323.301 10856.97
## 1995-12-31 12490.94 30358.88 32100.90 2550.855 11530.42
~~~

To see the first 5 rows and 5 columns of the Time to start a business variable you could type `head(data[[2]][,1:5])`. Since the first element of the list is the GDP per capita variable and the second element is the Time to start a business variable, we can rename the list as:

{% highlight r linenos %}
names(data) <- c("gdp", "business")
{% endhighlight %}

If you want to check all the information available from the data that was downloaded through the **`requestQ()`** function, type:

{% highlight r linenos %}
View(attributes(data)$meta[1]) # gdp metadata
View(attributes(data)$meta[2]) # business metadata
{% endhighlight %}

Note that the **`requestQ()`** function performs a search filtering for each country in G20, but sometimes there is no data available for a particular country, so the search may return a country not present in G20. If you want to be sure that you included only countries from G20 take a look at the name column of the metadata attributes above. If you do that you will see that there was no GDP data for Argentina, and there are two intruders in the G20: Macao and Hong Kong. We actually don't mind about that at the moment, so let's keep going.

## Build a panel data

Before making any regressions, we want to build a panel using the data we have downloaded. What we want is to convert a list of xts objects into a data frame object organized as panel data. Luckily, the macrodata package includes a function that automatically does that: **`xtstopanel()`**.

{% highlight r linenos %}
panel <- xtstopanel(data)
{% endhighlight %}

This is what the first 20 lines of the panel variable looks like:

{% highlight r linenos %}
head(panel, 20)
{% endhighlight %}

~~~
##     country year      gdp business
##  1:     AUS 1990 28604.22       NA
##  2:     AUS 1991 28121.66       NA
##  3:     AUS 1992 27894.75       NA
##  4:     AUS 1993 28732.42       NA
##  5:     AUS 1994 29579.80       NA
##  6:     AUS 1995 30358.88       NA
##  7:     AUS 1996 31145.34       NA
##  8:     AUS 1997 32013.40       NA
##  9:     AUS 1998 33085.24       NA
## 10:     AUS 1999 34346.25       NA
## 11:     AUS 2000 35253.31       NA
## 12:     AUS 2001 35451.97       NA
## 13:     AUS 2002 36374.82       NA
## 14:     AUS 2003 37035.05      3.0
## 15:     AUS 2004 38129.81      3.0
## 16:     AUS 2005 38840.23      3.0
## 17:     AUS 2006 39416.03      3.0
## 18:     AUS 2007 40643.44      3.0
## 19:     AUS 2008 41311.93      2.5
## 20:     AUS 2009 41170.04      2.5
~~~

The **`xtstopanel()`** function returns a data.table object. If you are not familiar to the [data.table](https://cran.r-project.org/web/packages/data.table/index.html) package in R, take a look at this [vignette](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.pdf).

When running the **`xtstopanel()`** function, the following warning message may appear in your console:

~~~
## Warning message:
## In xtstopanel(data) :
##   Some countries will be dropped, since there are countries with no va
##  lues for the selected variables.
~~~

As a default behavior, this function will drop countries that are not present in both xts variables. To check which countries were dropped, type:

{% highlight r linenos %}
names <- lapply(data, names)
all_names <- Reduce(union, names)
common_names <- Reduce(intersect, names)
setdiff(all_names, common_names)
{% endhighlight %}

~~~
## [1] "MAC" "ARG"
~~~

There was no GDP per capita data from Argentina, so this country was dropped. Macao was also dropped so we got rid of one intruder. If you really want to work only with G20 countries, exclude the other intruder (Hong Kong) by typing:

{% highlight r linenos %}
panel <- panel[country != "HKG",]
{% endhighlight %}

Now we are ready to begin our analysis.

## Plot the relations between the two variables for each country

To begin our analysis, we can make a nice scatterplot with the [car](https://cran.r-project.org/web/packages/car/index.html) package: 

{% highlight r linenos %}
library(car)
scatterplotMatrix(~ gdp + business|country, data = panel,
                   main = "Gdp and Time to start a business by country from G20")
{% endhighlight %}

This is the result:

[![GDP and Time to start a business]({{ site.url }}/img/scatterplot.png)]({{ site.url }}/img/scatterplot.png)

It seems that countries with highest GDPs broke the barrier of less than 50 days to start a business. Let's do some regressions now.

## Run panel data regressions

Before running regressions we can check summary statistics for the two variables using the [doBy](https://cran.r-project.org/web/packages/doBy/index.html) package.

{% highlight r linenos %}
install.packages("doBy") # install if you don't have it
library(doBy)
summaryBy(gdp + business ~ country, data = panel, FUN = c(mean, sd), na.rm = TRUE)
{% endhighlight %}

~~~
##     country  gdp.mean business.mean   gdp.sd business.sd
##  1:     AUS 35965.016      2.708333 5260.827   0.2574643
##  2:     BRA 12335.045    131.350000 1765.537  26.1336599
##  3:     CAN 37023.115      4.166667 4461.664   1.0298573
##  4:     CHN  5476.628     38.983333 3438.063   6.0069404
##  5:     DEU 37362.008     21.625000 3608.889  11.2575732
##  6:     FRA 34271.140      9.375000 2994.923   9.9820862
##  7:     GBR 32905.809     11.000000 4295.592   1.8090681
##  8:     IDN  6861.430     90.333333 1531.486  44.2895090
##  9:     IND  3120.571     40.708333 1189.327  22.1723603
## 10:     ITA 34688.652     10.333333 2297.444   5.1581063
## 11:     JPN 32790.910     20.450000 1792.529   7.9461254
## 12:     KOR 22809.204     12.416667 6735.966   5.8225008
## 13:     MEX 14479.277     12.758333 1265.378  10.4417395
## 14:     RUS 17196.232     26.508333 4351.816   8.6315972
## 15:     SAU 40372.458     34.666667 5456.936  23.2499593
## 16:     TUR 14060.289      8.708333 2685.680   9.2256026
## 17:     USA 45395.743      5.566667 5240.247   0.5175701
## 18:     ZAF 10808.098     25.916667 1103.250   7.1789887
~~~

And now we can try to open a business in Brazil. Nah, just kidding!! Let's run some regressions. First we can run a pooled OLS regression with the **`lm()`** function:

{% highlight r linenos %}
reg1 <- lm(gdp ~ business, panel)
summary(reg1)
{% endhighlight %}

~~~
## Call:
## lm(formula = gdp ~ business, data = panel)
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -23049 -13650   4842   8908  23395 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 32923.31    1080.45  30.472  < 2e-16 ***
## business     -205.95      23.88  -8.623 1.47e-15 ***
## ---
## Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
## 
## Residual standard error: 12420 on 214 degrees of freedom
##   (234 observations deleted due to missingness)
## Multiple R-squared:  0.2579,	Adjusted R-squared:  0.2544 
## F-statistic: 74.36 on 1 and 214 DF,  p-value: 1.466e-15
~~~

For each day of delay to start a business there is a decrease of around 200 dollars in GDP per capita. This is a lot! There is probably some endogeneity problems with our regression, but we can easily estimate better models using the [plm](https://cran.r-project.org/web/packages/plm/index.html) package:  

{% highlight r linenos %}
install.packages("plm") # install if you don't have it
library(plm)
reg2 <- plm(gdp ~ business, panel, model = "within")
summary(reg2)

reg3 <- plm(gdp ~ business, panel, model = "within", effect = "twoways")
summary(reg3)

reg4 <- plm(gdp ~ business, panel, model = "random")
summary(reg4)

reg5 <- plm(gdp ~ business, panel, model = "random", effect = "twoways")
summary(reg5)
{% endhighlight %}

That is good enough for our exercise. Let's make a table of results.

## Make a nice table of results

We can group all of our regressions in a nice table of results by using latex and the [stargazer](https://cran.r-project.org/web/packages/stargazer/index.html) package:

{% highlight r linenos %}
install.packages("stargazer") # install if you don't have it 
library(stargazer)
stargazer(reg1, reg2, reg3, reg4, reg5,
          column.labels = c("Pooled OLS", "Fixed Effect",
                            "Fixed Effect Two-ways", "Random Effect",
                            "Random Effect Two-ways"),
          model.names = FALSE, table.placement = "p!",
          title = "Relation between Time to start a business and GDP per capita")
{% endhighlight %}

This is the **[result](/files/macrodata-table1.pdf)**!

## Add additional control variables

Something seems to be missing in those regressions. Often we want to add some macroeconomic control variables in our model. Let's add some more variables such as: consumer price index, human capital and openness.

{% highlight r linenos %}
search2 <- searchQ("openness human capital cpi", country = "Brazil")
data2 <- requestQ(search2, c(3, 17, 28), countries = "G20")
names(data2) <- c("openness", "human_capital", "cpi")
panel2 <- xtstopanel(c(data, data2))
{% endhighlight %}

Note that we built a new panel using the original data and the new one. We can check which countries were included in this new panel, and compare to the old one:

{% highlight r linenos %}
oldcountries <- unique(panel$country)
newcountries <- unique(panel2$country)
setdiff(oldcountries, newcountries)
{% endhighlight %}

~~~
## [1] "DEU"
~~~

It looks like Germany was dropped from the sample. When you request data with the **`requestQ()`** function, the columns are automatically renamed with the country code. The **`xtstopanel()`** function needs the columns to have the same names (ids). But the codes may change across different databases. If we look at the meta attributes of data2 variable we can see that the openness data comes from PENN World Tables, the human capital data comes from Groningen Growth and Development Centre, and the consumer price index data comes from World Bank. We can investigate what is happening by looking at the names of columns in the data2 variable:

{% highlight r linenos %}
names(data2[[1]])
{% endhighlight %}

~~~
##  [1] "BRA" "ITA" "ARG" "AUS" "MEX" "GER" "IND" "TUR" "CAN" "FRA" "IDN" "JPN"
## [13] "RUS" "USA" "SAU" "ZAF" "KOR" "GBR" "CHN" "CH2"
~~~

By looking at the first variable (openness), we see that Germany's code is "GER". That is different from "DEU". We can manually change the name and rebuild the panel:

{% highlight r linenos %}
names(data2[[1]])[6] <- "DEU"
panel2 <- xtstopanel(c(data, data2))
unique(panel2$country)
{% endhighlight %}

~~~
##  [1] "AUS" "BRA" "CAN" "CHN" "DEU" "FRA" "GBR" "IDN" "IND" "ITA" "JPN" "KOR"
## [13] "MEX" "RUS" "SAU" "TUR" "USA" "ZAF"
~~~

Now we are good to go. We need to run all the regressions again including the control variables and make our final table of results:

{% highlight r linenos %}
reg1.1 <- plm(gdp ~ business + openness + diff(human_capital) + diff(cpi),
             panel2, model = "pooling")
reg2.1 <- plm(gdp ~ business + openness + diff(human_capital) + diff(cpi),
              panel2, model = "within")
reg3.1 <- plm(gdp ~ business + openness + diff(human_capital) + diff(cpi),
              panel2, model = "within", effect = "twoways")
reg4.1 <- plm(gdp ~ business + openness + diff(human_capital) + diff(cpi),
              panel2, model = "random")
reg5.1 <- plm(gdp ~ business + openness + diff(human_capital) + diff(cpi),
              panel2, model = "random", effect = "twoways")
stargazer(reg1.1, reg2.1, reg3.1, reg4.1, reg5.1,
          column.labels = c("Pooled OLS", "Fixed Effect",
                            "Fixed Effect Two-ways", "Random Effect",
                            "Random Effect Two-ways"),
          model.names = FALSE, table.placement = "p!",
          title = "Relation between Time to start a business and GDP per capita with control variables")
{% endhighlight %}

And this is the final **[results](/files/macrodata-final.pdf)**! You can access the latex file **[here](/files/macrodata-final.tex)**.

So for each day of delay to start a business there is a decrease of around 30 to 35 dollars in GDP per capita. We always can do better, but that is enough for our exercise.  

## Limitations and TODO

As we saw in this post, sometimes there are issues that must be manually addressed in order to the **`macrodata`** package work as expected:

1. The **`requestQ()`** function may include countries not requested in the data. You may want to check and exclude countries from the sample manually.

2. Since the renaming of country columns in the **`requestQ()`** function is done using the code pattern of the series, if you are requesting data from different databases, this patterns may change. If this is the case, you need to rename the columns manually before running the **`xtstopanel()`** function. 

3. In some cases, the **`requestQ()`** function may fail to rename country columns. This happens when the code pattern does not contain expressions such as "_" or "." to separate the country codes. Again, in this case, you need to rename the columns manually before running the **`xtstopanel()`** function. This cases may be addressed in future versions of the **`macrodata`** package.

4. The **`xtstopanel()`** function is currently working only for annual data. More frequencies may be included in future versions of the **`macrodata`** package.

If you find some unexpected behavior of the **`macrodata`** package, please submit an issue [here](https://github.com/regisely/macrodata/issues/new). I'll try to fix as soon as I can.

---
