## Carregando s?rie do PIB mensal brasileiro

data <- read.csv("pib-brasil.csv", sep = ";", dec = ",")
pib <- ts(log(data$pib), start = c(1996, 01), end = c(2016, 02), frequency = 4)
plot(pib)
pib.diff <-  diff(pib, differences = 1)
plot(pib.diff)
decomp <- stl(pib, s.window = "periodic")
plot(decomp)

## Testes de tend?ncia
library(randtests)

### Wald-Wolfowitz Test
runs.test(pib, alternative = "left.sided")
runs.test(pib.diff, alternative = "left.sided")

### Cox-Stuart Test
cox.stuart.test(pib)
cox.stuart.test(pib.diff)

### Mann-Kendall Rank Test
rank.test(pib)
rank.test(pib.diff)

## Estima??o de tend?ncia

### Tend?ncia linear e polinomial

trimestre <- seq(1, length(pib))
trimestre
reg1 <- lm(pib ~ trimestre)
summary(reg1)
reg2 <- lm(pib ~ poly(trimestre, degree = 2))
summary(reg2)
ts.plot(reg1$residuals)
ts.plot(reg2$residuals)
ts.plot(reg1$fitted.values)

### M?dia m?vel

ma5 <- filter(pib, rep(1/5, 5), sides = 2)
ma5
plot(pib)
lines(ma5, col = "blue")
ma10 <- filter(pib, rep(1/10, 10), sides = 2)
ma10
plot(pib)
lines(ma10, col = "blue")

### Lowess

trend_lowess <- lowess(pib)
trend_lowess
plot(pib)
lines(trend_lowess, col = "blue")
