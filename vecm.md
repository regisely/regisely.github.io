---
layout: page
title: Teaching
subtitle: Econometria II (pós-graduação)
---

[<< Back to Econometria II](/timeseries)

Este código utiliza uma base de dados interna do R para testar a presença de cointegração nas séries e então estimar um modelo VECM. Os resultados são apresentados em uma tabela utilizando o pacote `stargazer` e também é feito o diagnóstico do modelo e a análise de impulso-resposta.

```r
## Pacotes
library(tsDyn)
library(urca)
library(vars)
library(stargazer)
library(MTS)

## Dados da Dinamarca de Johansen (1990)
data(denmark)

## Testes ADF nas 4 variáveis de interesse
adf_LRM <- ur.df(denmark$LRM, type = "drift", lags=10, selectlags="AIC")
summary(adf_LRM)

adf_LRY <- ur.df(denmark$LRY, type = "drift", lags=10, selectlags="AIC")
summary(adf_LRY)

adf_IBO <- ur.df(denmark$IBO, type = "drift", lags=10, selectlags="AIC")
summary(adf_IBO)

adf_IDE <- ur.df(denmark$IDE, type = "drift", lags=10, selectlags="AIC")
summary(adf_IDE)

## Testes ADF nas diferenças
x <- as.matrix(denmark[,c(2,3,5,6)])
denmark_diff <- diff(x, lag=1, differences=1)

adf_LRM_diff <- ur.df(denmark_diff[,1], type = "drift", lags=10, selectlags="AIC")
summary(adf_LRM_diff)
pp <- PP.test(denmark_diff[,1]) ## Teste de Phillips-Perron para confirmar
pp

adf_LRY_diff <- ur.df(denmark_diff[,2], type = "drift", lags=10, selectlags="AIC")
summary(adf_LRY_diff)

adf_IBO_diff <- ur.df(denmark_diff[,3], type = "drift", lags=10, selectlags="AIC")
summary(adf_IBO_diff)

adf_IDE_diff <- ur.df(denmark_diff[,4], type = "drift", lags=10, selectlags="AIC")
summary(adf_IDE_diff)

## Seleção de defasagem do VAR no nível
var_lags <- VARselect(denmark[,c(2,3,5,6)], lag.max = 4, type = "both", season = 4)
var_lags

## Teste de Johansen
jo_eigen <- ca.jo(denmark[,c(2,3,5,6)], type = "eigen", ecdet = "const", K = 2, spec = "longrun", season = 4)
jo_trace <- ca.jo(denmark[,c(2,3,5,6)], type = "trace", ecdet = "const", K = 2, spec = "longrun", season = 4)
summary(jo_eigen)
summary(jo_trace)

## Estimação do VECM pela função cajorls
vecm_cajo <- cajorls(jo_eigen, r = 1)
summary(vecm_cajo$rlm)

## Estimação do VECM pela função VECM (dummies sazonais não estão inclusas - deve ser feita através da opção exogen)
vecm <- VECM(denmark[,c(2,3,5,6)], lag=1, r=1, estim="ML")
vecm_results <- summary(vecm)

## Usa pacote stargazer para construir uma tabela bonita com os resultados da função VECM (pode ser feito para a cajorls também)
table_vecm <- stargazer(vecm_results$bigcoefficients, type = "text", flip = TRUE, font.size = "footnotesize")

## Teste de Ljung-Box multivariado (podemos fazer o teste Ljung-Box para o resíduo de cada equação com a função Box.test)
multi_q <- mq(vecm_cajo$rlm$residuals, lag=15)
multi_q <- mq(vecm$residuals, lag=15)

###Impulse response
vecvar <-vec2var(jo_eigen, r = 1)
causality(vecvar)
impulse_cajo <- irf(vecvar)
plot(impulse_cajo)

impulse_vecm <- irf(vecm)
plot(impulse_vecm)
```	

---