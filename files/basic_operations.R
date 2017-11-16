### Google's R Style Guide: https://google.github.io/styleguide/Rguide.xml

### Leitura de dados
#read.table()
#read.csv("C:/Dados/arquivo.csv", sep = ";", dec = ",")
#library(xlsx)
#read.xlsx("C:/Dados/arquivo.xlsx", sheetIndex = 1)
#library(foreign)
#read.dta("C:/Dados/arquivo.dta") #Stata-12

### Operações básicas
x <- c(2, 5, 9)
x
y <- seq(from = 1,length = 3, by = 3)
?seq
y
x + y
x / y
x^y
x[1]
x[1:2]
x[-3]
x[-c(1, 2)]
z <- matrix(seq(1, 12), 4, 3)
z
z[3:4, 2:3]
z[, 2:3]
z[, 1]
z[, 1, drop = FALSE]
dim(z)
ls()
rm(y)
ls()

### Plotando gráficos
x <- rnorm(100)
y <- runif(100)
plot(x, y)
plot(x, y, xlab = "Variável Aleatória Uniforme",
     ylab = "Variável Aleatória Normal",
     pch = "*", col = "blue")
par(mfrow = c(2, 1))
plot(x, y)
hist(y)
dev.off()
plot(x, y)
dev.new()
hist(y)

### Criando séries temporais no R
timeseries <- ts(x, start = c(2008, 1), end = c(2016, 4), frequency = 12)
timeseries
plot(timeseries)
timeseries2 <- window(timeseries, start = c(2015, 1), end = c(2015, 12))
timeseries2
plot(timeseries2)

#install.packages("xts")
library(xts)
date <- seq(as.Date("2008-01-01"), as.Date("2016-04-01"), by = "months")
timeseries <- xts(x, order.by = date)
timeseries
str(timeseries)
index(timeseries)
plot(timeseries)

### Estatísticas descritivas
UKDriverDeaths
mean(UKDriverDeaths, na.rm = TRUE)
sd(UKDriverDeaths, na.rm = TRUE)
median(UKDriverDeaths, na.rm = TRUE)
quantile(UKDriverDeaths, probs = 0.25, na.rm = TRUE)

#install.packages("moments")
library(moments)
skewness(UKDriverDeaths, na.rm = TRUE)
kurtosis(UKDriverDeaths, na.rm = TRUE)
summary(UKDriverDeaths)
UKDriverDeaths[which(is.na(UKDriverDeaths))] <- 1600
seasdec <- stl(UKDriverDeaths, s.window = "period")
seasdec
plot(seasdec)
diff(UKDriverDeaths, differences = 2)
diff(UKDriverDeaths, lag = 2)

### Identificação e Remoção de Outliers
boxplot(UKDriverDeaths)
UKDriverDeaths[100] <- 13548
boxplot(UKDriverDeaths)
UKDriverDeaths[which(UKDriverDeaths == max(UKDriverDeaths))] <- NA
boxplot(UKDriverDeaths)
summary(UKDriverDeaths)
mean(UKDriverDeaths)
mean(UKDriverDeaths, na.rm = TRUE)
