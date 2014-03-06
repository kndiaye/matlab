winner <- c('N', 'N', 'A', 'N', 'A', 'N')
market <- c('+', '-', '-', '+', '+', '+')
smat <- diag(2)
dimnames(smat) <- list(c('N', 'A'), c('+', '-'))

pt1 <- permutation.test.discrete(winner, market, smat)
print(pt1)
plot(pt1)

data(ToothGrowth)
pt2 <- permutation.test.fun(ToothGrowth[, -2], fun=cor)
print(pt2)
plot(pt2)

smat2 <- matrix(c(-3, -.5, 3, -1, 1, 0, 0, 1, -1, 3, -.5, -3),
        3, 4, dimnames=list(c('Up', 'Neut', 'Down'), 
        c('Q1', 'Q2', 'Q3', 'Q4')))
permutation.test.discrete(my.dataframe[, c("results", "quartile")], 
        score=smat2)