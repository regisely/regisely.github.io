---
layout: post
title: "Example post"
tags: [post, example]
date: 2015-07-01 15:00:00 -0700
---

> Here is a citation in my [page](http://regisely.github.io)

Here is a function in R `write.csv()`, and here is a file name in bold **`script.R`**. Let's make a list:

* **This is an item** beginning with bold
* *This is an item* beginning with italic
* This is a link to jump to the [results](#results)

## Table of contents

- [Introduction](#intro)
- [Review of literature](#literature)
- [Methodology](#methodology)
  - [Data](#data)
  - [Econometric model](#model)
- [Results](#results)
- [Conclusion](#conclusion)

# Introduction {#intro}

Here is a introduction with a numbered list:

1. be concise 
2. be clear 
3. get the job done 

# Review of literature {#literature}

Here is a bunch of code:

{% highlight r linenos %}
library(forecast)

# Run arima forecast
data <- read.csv("table.csv")
model <- auto.arima(data)
model.predict <- forecast(model)
plot(model.predict)
{% endhighlight %}

And here is a code without numbering lines:

```r
updateColourInput(session, "col", label = "COLOUR:", value = "orange",
  showColour = "background", allowTransparent = TRUE, transparentText = "None")
```

# Methodology {#method}

## Data {#data}

Here is the data.

## Econometric model {#model}

I need to put some equation here: $x^2 = \frac{3x}{\sqrt{3-y}}$.

# Results {#results}

Now my final table.

| Method            |       Data type      | Local storage | Remote storage | R package    |
|-------------------|----------------------|:-------------:|:--------------:|--------------|
| Local file system | Arbitrary data       |      YES      |                | -            |
| Dropbox           | Arbitrary data       |               |       YES      | rdrop2       |
| Amazon S3         | Arbitrary data       |               |       YES      | RAmazonS3    |
| SQLite            | Structured data      |      YES      |                | RSQLite      |
| MySQL             | Structured data      |      YES      |       YES      | RMySQL       |
| Google Sheets     | Structured data      |               |       YES      | googlesheets |
| MongoDB           | Semi-structured data |      YES      |       YES      | rmongodb     |

# Conclusion {#conclusion}

My conclusion will have numbered subsections

## Subsectioned conclusion

### 1. This is item one

Here I will insert an image:

[![colourInput demo]({{ site.url }}/img/colourInputDemo.gif)]({{ site.url }}/img/colourInputDemo.gif)

Now a separator

---

And i think that's it.
