#########################################################
# Definindo dados iniciais - rodar somente primeira vez
alunos <- c("Victor", "Marcio", "Silvio", "Thais", "Dianifer",
            "Mairton", "Caio", "Raquel")
probs <- c(rep(1/8, 8))
sum(probs)
#########################################################

# Ler dados de sorteio anterior - nao rodar na primeira vez
load("sorteio.RData")
probs
sum(probs)

# Simulando 10000 sorteios e plotando a distribuicao
sims <- numeric(10000)
for(i in 1:10000) {
  sims[i] <- sample(alunos, replace = TRUE, size = 1, prob = probs)
}
sims <- as.factor(sims)
plot(sims)

# Sorteio
(sorteio <- sample(alunos, replace = TRUE, size = 1, prob = probs))

# Atualizar pesos
probs[which(alunos == sorteio)] <- probs[which(alunos == sorteio)]/2
probs <- probs/sum(probs)
probs
save.image("sorteio.RData")
