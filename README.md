# rieszvar

This is an implementation of the Riesz estimator algorithms from Aliprantis, Harris, and Tourky (2006b). By Ovchinnikov (2002) and Aliprantis, Harris, and Tourky (2006a), any piecewise linear function on n-dimensional Euclidean space can be represented as a Boolean polynomial of its affine (or linear) components. Riesz estimators are the analogue concept for multivariate piecewise linear regressions. I implemented the first algorithm, $rieszvar\_i$, which 1) splits the support of the predictors into cells 2) estimates OLS on the cells to retrieve linear components 3) and finds the combination of components that yields the correct piecewise linear function.

The algorithm has a 'hidden' dimensionality problem: the number of combinations becomes very large once the number of components hits about 6. Obviously WIP, but works as a proof of concept.

The documentation isn't finished, as I'm still working on paring down the mathematical content, but the 'how-to' presentation contains information on how to retrieve the Boolean representation for a known piecewise linear function, and how to estimate a piecewise linear function using $rieszvar\_i$. The examples.R file contains code examples, as well as a link to download the package using $install\_github()$.
