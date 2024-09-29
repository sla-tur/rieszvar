# rieszvar

This is an implementation of the Riesz estimator algorithms from Aliprantis, Harris, and Tourky (2006b). By Ovchinnikov (2002) and Aliprantis, Harris, and Tourky (2006a), any  can be represented as a Boolean polynomial of its affine (or linear) components. Riesz estimators are the analogue concept for multivariate piecewise linear regressions, i.e. 

Using Riesz estimators, we can

## rieszvar1

RIESZVAR(i) (referred to as $rieszvar1$ from now on) To do so

The primary issue with the algorithm is its reliance on the Sperner family power set subroutine. The number of Sperner families of an n-set is:

1, 4, 18, 166, 7579, 7828352, 2414682040996...

Calculating 

We only know nine terms of this sequence, so it follows that we won't be estimating ten-component functions using $rieszvar1$. Suggestions of improvements to the

I used openMP

## rieszvar2

To be done.

An alternative method of 

## Q&A

Q. How is this any better than MARS?
A. It's not. It has 

Q.
A.
