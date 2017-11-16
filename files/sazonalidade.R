## Carregar pacotes
library(data.table)

## Testes de sazonalidade

## Decomposição da série temporal
nottem
str(nottem)
plot(nottem)
decomp <- stl(nottem, s.window = 'periodic')
decomp
plot(decomp)

### Kruskal-Wallis Test
group <- factor(rep(c(1:12), 20))
data <- data.frame(nottem, group)
data
kruskal.test(nottem ~ group, data=data)

### Friedman Test
data2 <- data[data$group == 1, ]$nottem
for (i in 2:12) {
  data2 <- cbind(data2, data[data$group==i,]$nottem)
}
data2
friedman.test(data2)

### Exponential Smoothing Model
library(forecast)
fit1 <- ets(nottem)
fit1
fit2 <- ets(nottem, model="ANN")
fit2

deviance <- 2*c(logLik(fit1) - logLik(fit2))
df <- attributes(logLik(fit1))$df - attributes(logLik(fit2))$df 
1-pchisq(deviance,df)

## Estimação de sazonalidade

### Método da regressão

dummies <- seasonaldummy(nottem)
dummies
reg <- lm(nottem ~ dummies)
summary(reg)
seasonadj <- reg$residuals
ts.plot(seasonadj)

### Método da média móvel

seasonmean <- aggregate(c(nottem), list(group = cycle(nottem)), mean)
seasonmean
seasonmean$const <- seasonmean$x - mean(data$nottem)

setDT(data)
seasonmean$group <- as.factor(seasonmean$group)
newdata <- merge(data, seasonmean[, c(1, 3)], by = "group", all.x = TRUE, sort = FALSE)
newdata
newdata[, adj := (newdata$nottem - newdata$const)]
ts.plot(newdata$adj)
