# rieszvar

This is an implementation of the Riesz estimator algorithms from Aliprantis, Harris, and Tourky (2006b). By Ovchinnikov (2002) and Aliprantis, Harris, and Tourky (2006a), any  can be represented as a Boolean polynomial of its affine (or linear) components. Riesz estimators are the analogue concept for multivariate piecewise linear regressions, i.e. they are Boolean  .



The classic threshold regression model can be 

Using Riesz estimators, we can

## rieszvar1

RIESZVAR(i) (referred to as $rieszvar1$ from now on) To do so


I wrote a simple Sperner family calculator in C. Through R's C API, it 

The primary issue with the algorithm is its reliance on the Sperner family power set subroutine. The number of Sperner families of an n-set is:

1, 4, 18, 166, 7579, 7828352, 2414682040996...

I can just about get a full power set for $k = 5$, but I get erratic output for $$k = 6, \ q = 3$$ and empty list() objects for anything beyond that. This makes $rieszvar1$ feasible for most practical applications, but it would

## rieszvar2

To be done.

An alternative method of  is to optimize 

## Q&A

Q. How is this any better than MARS?
A. It's not, not at the moment at least.

Q.
A.
