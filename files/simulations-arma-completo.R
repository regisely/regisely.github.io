#######################################################
### Definição dos parâmetros
#######################################################
n <- 11000 ### Total de observações simuladas
nx <- 1000 ### Total de observações descartadas
c <- 0.3 ### Constante do AR
phi <- c(0.5,-0.8) ### Vetor de parâmetros do AR
mu <- 0.7 ### Média do MA
theta <- c(0.8,0.3,-0.2) ### Vetor de parâmetros do MA
ca <- 0.2 ### Constante do ARMA
phia <- c(0.6) ### Vetor de parâmetros AR do ARMA
thetaa <- c(0.3) ### Vetor de parâmetros MA do ARMA
#######################################################

### Criando vetor de dados e ruídos brancos
set.seed(12345)
rb <- rnorm(n)
yar <- numeric(n)
yma <- numeric(n)
yarma <- numeric(n)
p <- length(phi) ### Ordem do AR
q <- length(theta) ### Ordem do MA
pa <- length(phia) ### Ordem AR do ARMA
qa <- length(thetaa) ### Ordem MA do ARMA

### Ruído Branco
white_noise <- rb[-1:-nx]
par(mfrow=c(3,2))
ts.plot(white_noise, gpars=list(xlab="Observação", ylab="White Noise"))

### Passeio aleatório
rw <- cumsum(rb)
random_walk <- rw[-1:-nx]
ts.plot(random_walk, gpars=list(xlab="Observação", ylab="Random Walk"))

### AR(p)
for(i in (p+1):n) {
	psum <- 0
	for(j in 1:p){
		psum <- psum + phi[j]*yar[i-j]
	}
	yar[i] <- psum + c + rb[i]
}
ar <- yar[-1:-nx]
ts.plot(ar, gpars=list(xlab="Observação", ylab="AR(p)"))

### MA(q)
for(i in (q+1):n) {
	psum <- 0
	for(k in 1:q){
		psum <- psum + theta[k]*rb[i-k]
	}
	yma[i] <- psum + mu + rb[i]
}
ma <- yma[-1:-nx]
ts.plot(ma, gpars=list(xlab="Observação", ylab="MA(q)"))

### ARMA(p,q)
for(i in (pa+1):n) {
	psum <- 0
	for(j in 1:pa){
		psum <- psum + phia[j]*yarma[i-j]
	}
	for(k in 1:qa){
		psum <- psum + thetaa[k]*rb[i-k]
	}
	yarma[i] <- psum + ca + rb[i]
}
arma <- yarma[-1:-nx]
ts.plot(arma, gpars=list(xlab="Observação", ylab="ARMA(p,q)"))

### Gravar dados no arquivo "simulations.csv"
export <- cbind(white_noise,random_walk,ar,ma,arma)
write.csv(export, file="simulations.csv")

### Plota últimas 300 observações de cada processo
windows()
par(mfrow=c(3,2))
ts.plot(white_noise[9700:10000], gpars=list(xlab="Observação", ylab="White Noise"))
ts.plot(random_walk[9700:10000], gpars=list(xlab="Observação", ylab="Random Walk"))
ts.plot(ar[9700:10000], gpars=list(xlab="Observação", ylab="AR(p)"))
ts.plot(ma[9700:10000], gpars=list(xlab="Observação", ylab="MA(q)"))
ts.plot(arma[9700:10000], gpars=list(xlab="Observação", ylab="ARMA(p,q)"))

### Plota funções de autocorrelação e autocorrelação parcial
windows()
par(mfrow=c(2,2))
acf(white_noise)
pacf(white_noise)
acf(random_walk)
pacf(random_walk)
acf(ar)
pacf(ar)
acf(ma)
pacf(ma)
acf(arma)
pacf(arma)

##############################################################
	