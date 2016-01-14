---
layout: post
title: "macrodata"
subtitle: an R package for macroeconometrists
tags: [macrodata, cross country, macroeconometrics]
date: 2016-01-13 15:00:00 -0700
---

Everyone that works with cross country macroeconomic data and uses R should know [Quandl](http://quandl.com). The [Quandl package for R](https://cran.r-project.org/web/packages/Quandl/) is a nice way to gather data using the Quandl API, but it has some drawbacks. They currently do not suppport panel data and the search function Quandl.search does not allow for specific filters.

If one wants to quickly build a cross country panel data using macroeconomic time series variables available through Quandl there is a nice solution that I am developing: the [macrodata](https://github.com/regisely/macrodata) package. The development version currently works for almost all series from World Bank and OECD, and should work for other databases as well, but it is dependent in the pattern of the codes, which may change across datasets.

Use the following code in R (>= 3.2.2) to install the development version of the package:

{% highlight r linenos %}
install.packages("devtools") # install devtools if you don't have it yet
install_github("regisely/macrodata")
{% endhighlight %}

# Correlations between the time to start a business and the GDP per capita

In order to demonstrate the usage of the macrodata package let's check if countries where you can start a business in less time have higher GDP per capita.

First load the package, then authenticate the Quandl API: 

{% highlight r linenos %}
library(macrodata)
Quandl.api_key("YOUR_API_HERE")
{% endhighlight %}

Remember that you can easily get a key by registering at [quandl.com](http://quandl.com) for free.

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

There are two more arguments to the **`searchQ()`** function. You can specify the frequency as "annual", "quarterly", "monthly" or "daily", e.g. `frequency = "annual"`. You can specify the number of results, e.g. `n = 500` (the default is 300). And you can also use `view = FALSE` if you don't want to view the query after the search, which is the common behavior.

## Requesting cross country data

By looking at our search results we can see that the rows 9 and 11 contain the variables we are interested in. Now we can request all the data from G20 countries using the **`requestQ()`** function:

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

To see the first 5 rows and 5 columns of the Time to start a business variable you could type `head(data[[2]][,1:5])`. Since the first element of the list is the GDP per capita variable and the second element is the Time to start a business variable, we can rename the list as:

{% highlight r linenos %}
names(data) <- c("gdp", "business")
{% endhighlight %}

If you want to check all the information available from the data that was downloaded through the **`requestQ()`** function, type:

{% highlight r linenos %}
View(attributes(data)$meta[1]) # gdp metadata
View(attributes(data)$meta[2]) # business metadata
{% endhighlight %}

Note that the **`requestQ()`** function performs a search filtering for each country in G20, but sometimes there is no data available for a particular country, so the search may return a country not present in G20. If you want to be sure that you included only countries from G20 take a look at the name column of the metadata attributes above. If you do that you will see that there was no GDP data for Argentina, and there are two intruders in the G20: Macao and Hong Kong. We actually don't mind about that, so let's keep going.

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

The **`xtstopanel()`** function returns a data.table object. If you are no familiar to the [data.table](https://cran.r-project.org/web/packages/data.table/index.html) package in R, take a look at this [vignette](https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.pdf).

When running the **`xtstopanel()`** function, the following warning message may appear in your console:

~~~
## Warning message:
## In xtstopanel(data) :
##   Some countries will be dropped, since there are countries with no va##  lues for the selected variables.
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

{% highlight r linenos %}
reg1 <- lm(gdp ~ business, panel)
summary(reg1)

# install.packages("plm")
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

## Make a nice table of results

## Add additional control variables

---
