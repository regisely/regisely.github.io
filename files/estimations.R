##############################
## Processo MA(1)
##############################

#Criando um MA(1)
set.seed(12345)
n <- 11000
nx <- 1000
rb <- rnorm(n)
yma <- numeric(n)
mu <- 0.7
theta <- 0.8
for(i in 2:n){
        yma[i] <- mu + rb[i] + theta*rb[i-1]
}
ma <- yma[-1:-nx]

#Função de log-verossimilhança do MA(1)

log.lik.ma <- function(param, data) {
        T <- length(data)
        res <- numeric(T)
        res[1] <- ma[1] - param[1]
        c1 <- -(T/2)*log(2*pi)
        for(i in 2:T) {
                res[i] <- ma[i] - param[1] - param[2]*res[i-1]
        }
        c2 <- -(T/2)*log(param[3])
        c3 <- -sum((res^2)/(2*param[3]))
        L <- c1 + c2 + c3
        -L
}

#Estimação do MA(1)
#NaNs produzidos devido ao fato do BFGS tentar valores negativos para sigma^2
param_ma <- c(0.5, 0.7, 0.8)
estma <- optim(par = param_ma, fn = log.lik.ma, method = "BFGS", hessian = TRUE, data = ma)
#Cálculo do erro padrão dos coeficientes
estma_se <- diag(sqrt(solve(estma$hessian)))
#Comparação do resultado com a função arima
estma_arima <- arima(ma, order = c(0,0,1))
result_ma <- list("Parâmetros" = estma$par, "Erros" = estma_se, "arima" = estma_arima); result_ma

#############################
## Processo AR(1)
#############################

#Criando um AR(1)
set.seed(12345)
yar <- numeric(n)
c <- 0.7
phi <- 0.8
for(i in 2:n){
        yar[i] <- c + phi*yar[i-1] + rb[i]
}
ar <- yar[-1:-nx]

#Função de log-verossimilhança do AR(1)
log.lik.ar <- function(param, data) {
        T <- length(data)
        res <- numeric(T)
        res[1] <- ar[1] - param[1]
        c1 <- -(T/2)*log(2*pi)
        for(i in 2:T) {
                res[i] <- ar[i] - param[1] - param[2]*ar[i-1]
        }
        c2 <- -(T/2)*log(param[3])
        c3 <- -sum((res^2)/(2*param[3]))
        L <- c1 + c2 + c3
        -L
}

#Estimação do AR(1)
#NaNs produzidos devido ao fato do BFGS tentar valores negativos para sigma^2
param_ar <- c(0.5, 0.7, 0.8)
estar <- optim(par = param_ar, fn = log.lik.ar, method = "BFGS", hessian = TRUE, data = ar)
#Cálculo do erro padrão dos coeficientes
estar_se <- diag(sqrt(solve(estar$hessian)))
#Comparação do resultado com a função arima
estar_arima <- arima(ar, order = c(1,0,0), method="ML")
intercept_ar <- estar_arima$coef[2]*(1-estar_arima$coef[1])
result_ar <- list("Parâmetros" = estar$par, "Erros" = estar_se, "arima" = estar_arima, "Intercepto" = intercept_ar); result_ar

#Diagnóstico do AR(1)
Box.test(ar, lag = 10, type = "Ljung-Box")
Box.test(estar_arima$residuals, lag = 10, type = "Ljung-Box")

#Previsão do AR(1)
library(forecast)
prev_ar <- forecast.Arima(estar_arima, h = 10); prev_ar
plot(prev_ar, include = 100)

test <- Arima(ma, order = c(0, 0, 1))
prev_ma <- forecast.Arima(test, h = 10); prev_ma
plot(prev_ma, include = 100)


#SARIMA
library(astsa)
data(saltemp)
plot(saltemp)
acf2(saltemp, max.lag = 40)
saltemp.L12 <- diff(saltemp, lag = 12)
plot(saltemp.L12)
acf2(saltemp.L12, max.lag = 40)
