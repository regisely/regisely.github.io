library(vars)
data(Canada)
list_Canada <- split(Canada, col(Canada))
adf <- list()
adf <- lapply(list_Canada, ur.df, type = "drift", lags = 5, selectlags = "AIC")
N <- ncol(Canada)
adf_table <- matrix(NA, N, 2)
for(i in 1:N){
    adf_table[i,] <- adf[[i]]@testreg$coefficients[2,3:4]
}
colnames(adf_table) <- c("t value", "p-value")
adf_table

Ident <- VARselect(Canada, lag.max=10)
Estim <- vars::VAR(Canada, p = 2, type="const")
Ident
summary(Estim)

library(MTS)
multi_q <- mq(resid(Estim), lag=15)
resid <- residuals(Estim)
Box.test(resid[,4], lag = 10, type = "Ljung-Box")

causality(Estim, cause = "prod")
impulse <- irf(Estim, impulse = "prod", response = c("e", "rw", "U"))
plot(impulse)



var.2c <- vars::VAR(Canada, p = 2, type = "const")
amat <- diag(4)
diag(amat) <- NA
amat[2, 1] <- NA
amat[4, 1] <- NA
## Estimation method scoring
SVAR(x = var.2c, estmethod = "scoring", Amat = amat, Bmat = NULL,
     max.iter = 100, maxls = 1000, conv.crit = 1.0e-8) 
## Estimation method direct
SVAR(x = var.2c, estmethod = "direct", Amat = amat, Bmat = NULL,
     hessian = TRUE, method="BFGS") 
