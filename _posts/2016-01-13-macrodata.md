---
layout: post
title: "macrodata"
subtitle: an R package for macroeconometrists
tags: [macrodata, cross country, macroeconometrics]
date: 2016-01-12 15:00:00 -0700
---

Everyone that works with cross country macroeconomic data and uses R should know [Quandl](http://quandl.com). The [Quandl package for R](https://cran.r-project.org/web/packages/Quandl/) is a nice way to gather data using the Quandl API, but it has some drawbacks. They currently do not suppport panel data and the search function Quandl.search does not allow for specific filters.

If one wants to quickly build a cross country panel data using macroeconomic time series variables available through Quandl there is a nice solution that I am developing: the [macrodata](https://github.com/regisely/macrodata) package. The development version currently works for almost all series from World Bank and OECD, and should work for other databases as well, but it is dependent in the pattern of the codes, which may change across datasets.

Use the following code in R (>= 3.2.2) to install the development version of the package:

{% highlight r linenos %}
install.packages("devtools") # install devtools if you don't have it yet
install_github("regisely/macrodata")
{% endhighlight %}

# Correlations between the time to start a business and the GDP per capita

In order to demonstrate the usage of the macrodata package let's check if countries where you can start a business in less time have highest GDPs.

First load the package with `library(macrodata)`, then authenticate the Quandl API with `Quandl.api_key("YOUR_API_HERE")`. Remember that you can easily get a key by registering at [quandl.com](http://quandl.com) for free.

## Searching for the variables

First we want to search for two specific time series: *time to start a business* and *gdp per capita*. We will be using the **`searchQ()`** function. This function improves **`Quandl.search()`** function in three ways:

1. It allows more than 100 results per query;
2. It allows filter for specific country or part of the name of a series;
3. It allows filter for specific frequencies.

If you want to build a cross country panel data, the best way to start is to search the variables first for a specific country and then select the variables of interest, requesting them for all countries wanted. You can search one variable at a time or maybe try to find them all in one search. Let's try the second by typing:

{% highlight r linenos %}
search <- searchQ("gdp per capita start business", country = "Brazil",
                  database = "WWDI")
{% endhighlight %}

Note that I saved the results in the search variable. This is important since you want to refer to that variable when requesting data from other countries. I also used the Wold Bank database by specifying `database = "WWDI"`, and I've filtered the results for the country of Brazil. If you do not filter by a specific country, the search will show the same variable for each country. We don't want that behavior, since we are only interested in selecting the variables of interest at the moment.

There are two more arguments to the **`searchQ()`** function. You can specify the frequency as "annual", "quarterly", "monthly" or "daily", e.g. `frequency = "annual"`. You can specify the number of results, e.g. `n = 500` (the default is 300). And you can also use `view = FALSE` if you don't want the view the query after the search, which is the common behavior.

## Requesting cross country data

By looking at our search results we can see that the rows 9 and 11 contains the variables we are interested in. Now we can request all the data from G20 countries using the **`requestQ()`** function:

{% highlight r linenos %}
data <- requestQ(search, c(9, 11), countries = "G20")
{% endhighlight %}

The **`requestQ()`** function also accepts all arguments of the original **`Quandl()`** function. It uses the following arguments as defaults: `type = "xts"`, `order = "asc"` and `collapse = "annual"`. Note that the first two arguments of this function are the result of **`searchQ()`** function and the rows indicating the variables of interest. The argument `countries` can contain any list of countries or specific group of countries such as: Europe, European Union, Euro Area, Eastern Europe, Western Europe, America, Latin America, North America, South America, Asia, Oceania, Africa, MENA, G20 and G7. 

Our data variable will now be a list of xts objects, with the first element containing the GDP per capita variable and the second element containing the Time to start a business variable. The rows indicate the year and the columns indicate the countries. This is what the first 5 rows and 5 columns of the GDP variable looks like:

{% highlight r linenos %}
`head(data[[1]][,1:5])`:
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

## Build a panel data

## Plot the relations between the two variables for each country

## Run panel data regressions

## Make a nice table of results

## Add additional control variables

---
