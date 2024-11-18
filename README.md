# rieszvar

This is an implementation of the Riesz estimator algorithms from Aliprantis, Harris, and Tourky (2006b). By Ovchinnikov (2002) and Aliprantis, Harris, and Tourky (2006a), any piecewise linear function on n-dimensional Euclidean space can be represented as a Boolean polynomial of its affine (or linear) components. Riesz estimators are the analogue concept for multivariate piecewise linear regressions.

The documentation isn't finished, as I'm still working on paring down the mathematical content, but the 'how-to' presentation contains information on how to retrieve the Boolean representation for a 


## rieszvar1

RIESZVAR(i) (referred to as $rieszvar1$ from now on) To do so


I wrote a simple Sperner family calculator in C. Through R's C API, it 

The primary issue with the algorithm is its reliance on the Sperner family power set subroutine. The number of Sperner families of an n-set is:

1, 4, 18, 166, 7579, 7828352, 2414682040996...

I can just about get a full power set for $k = 5$ by parallelising the antichain computations, but I get erratic output for $$k = 6, \ q = 3$$ and empty list() objects for anything beyond that. This makes $rieszvar1$ feasible for most practical applications, but it would . Because of neural nets and ReLU, there have been many papers on reduced-dimension representations of piecewise linear functions

## rieszvar2

An alternative method of  is to optimize 

## Q&A

Q. How is this any better than MARS?
A. It's not, not at the moment at least. But it has potential . Retrieving  The estimators' underlying theory of Riesz spaces also 

Q. 
A.
