# qsexpand package
Fast q series expander program for Maxima Computer Algebra System

## Install
Assume you already install maxima-asdf available from [maxima-asdf](https://github.com/robert-dodier/maxima-asdf), the qsexpand can be installed directly from github:

	(%i0) install_github("YasuakiHonda","qsexpand","master")$
	(%i1) asdf_load("qsexpand");

## Example use
    (%i3) q*product((1-q^n)^24,n,1,inf);
                                     inf
                                    /===\
                                     ! !        n 24
    (%o3)                         q  ! !  (1 - q )
                                     ! !
                                    n = 1
    (%i4) qsexpand(%,1);
                  2        3         4         5         6          7          8
    (%o4) q - 24 q  + 252 q  - 1472 q  + 4830 q  - 6048 q  - 16744 q  + 84480 q
               9           10           11           12           13           14
     - 113643 q  - 115920 q   + 534612 q   - 370944 q   - 577738 q   + 401856 q

## Documentation
Function ***qsexpand(qexp, degree)***
> ***qexp:*** infinite product of a univariate polynomial of variable **q** and index variable **n**, and number of terms does not depende on **n**. 
>
> ***degree:*** natural number specifying the maxima degree of the expanded polynomial

***qsexpand*** expands the infinite product formula ***qexp*** into a finite degree polynomial up to ***degree***-1. As specified, the syntax of the ***qexp*** is quite limited, so use with caution.
