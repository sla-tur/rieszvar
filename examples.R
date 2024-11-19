if (!require("devtools")) install.packages("devtools")
if (!require("rieszvar")) devtools::install_github("sla-tur/rieszvar")

# function of the form (4 + 0.2 x1 + 0.3 x2) ^ (x1 + 0.3 x2) on [0, 12]^2
# estimates well, not surprising given the simplicity of the function
# the OLS estimates approximate the true function well, and the combination
# chosen is correct
set.seed(123)
x <- cbind(runif(1000, 0, 12), runif(1000, 0, 12))
f1 <- 4 + 0.2*x[,1] + 0.3*x[,2]
f2 <- x[,1] + 0.3*x[,2]
y <- pmin(f1, f2) + rnorm(1000)
rieszvar::rieszvar_i(y, x, 2, 2)

# same function, misspecified model -- worse OLS estimates due to
# sample splitting but correct estimate in the end
set.seed(123)
x <- cbind(runif(1000, 0, 12), runif(1000, 0, 12))
f1 <- 4 + 0.2*x[,1] + 0.3*x[,2]
f2 <- x[,1] + 0.3*x[,2]
y <- pmin(f1, f2) + rnorm(1000)
rieszvar::rieszvar_i(y, x, 4, 3)

# worked example from github slide deck
# overall bad estimation, does poorly both with and without noise
# does not select the appropriate combination, despite it being in the set of
# options for k = 4, q = 6
# model misspecified on purpose to split sample into 4 cells rather than 3
set.seed(123)
x <- runif(1000, 0, 2)
f1 <- 2 + 0.5*x
f2 <- 1 + 2*x
f3 <- 4 - x
y <- pmax(pmin(f1, f3), pmin(f2, f3), pmin(f1, f2)) + rnorm(1000)
plot(x, y)
rieszvar::rieszvar_i(y, x, 4, 6)
