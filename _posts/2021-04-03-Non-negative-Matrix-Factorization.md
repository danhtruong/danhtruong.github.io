---
layout: single
toc: true
mathjax: true
title: Non-negative Matrix Factorization
tags: tutorials R machine-learning
---


## Non-negative Matrix Factorization

In this post, I will be discussing Non-negative Matrix Factorization
(NMF). NMF is a low-rank approximation algorithm that discovers latent
features in your data. It is similar to PCA in the sense that they both
reduce high-dimensional data into lower dimensions for better
understanding of the data. The major difference is that PCA projects
data onto a subspace that maximizes variability for the discovered
features, while NMF discovers non-negative features that are additive in
nature.

NMF is formally defined as:

$$V\approx{WH}$$

where $V$ is a non-negative matrix and both $W$ and $H$ are unique and non-negative matrices. In other words, the matrix $V$ is factorized into two matrices $W$ and $H$, where $W$ is the features matrix or the basis and $H$ is the coefficient matrix. Typically, this means that $H$ represents a coordinate system that uses $W$ to reconstruct $V$. We can consider that $V$ is a linear combination of column vectors of $W$ using the coordinate system in $H$, $v_{i} = Wh_{i}$.

## Solving for NMF

Here, I will describe two algorithms to solve for NMF using iterative
updates of $W$ and $H$. First, we will consider the cost function. A cost function is a
function that quantifies or measures the error between the predicted
values and the expected values. The Mean Squared Error (MSE), or L2 loss
is one of the most popular cost functions in linear regressions. Given
an linear equation $y = mx + b$
, MSE is:

$$MSE =\frac{1}{N}\Sigma_{i=1}^{n}(y_{i}-(mx_{i}+b))^{2}$$


For the cost function in NMF, we use a similar function called the
Frobenius Norm. It is defined as:

$$||A||_{F} =\sqrt{\Sigma_{i=1}^{m}\Sigma_{j=1}^{n} |a_{ij}|^{2}}$$

In the case of NMF, we are using the square of the Forbenius norm to
measure how good of an approximation $WH$ is for $V$.

$$||V - WH||_{F}^{2} =\Sigma_{i,j}(V - WH)^{2}_{ij}$$


## Optimization

We can see that as $WH$ approaches $V$
, then the equation will slowly converge to zero. Therefore, the
optimization can be defined as the following:

Minimize $||V - WH||_{F}^{2}$ with respect to $W$ and $H$, subject to the constraints $W,H\ge 0$
In the paper by Lee & Seung, they introduced the multiplicative update
rule to solve for NMF. Please see their original paper for details on
the proof. Essentially the update causes the function value to be
non-increasing to converge to zero.

$$H_{ik}\leftarrow H_{ik}\frac{(W^{T}V)_{ik}}{(W^{T}WH)_{ik}}$$

$$W_{kj}\leftarrow W_{kj}\frac{(VH^{T})_{kj}}{(WHH^{T})_{kj}}$$


## Multiplicative Update Rule

Here we will implement NMF using the multiplicative update rule. To get
started, make sure you have installed both
[R](https://www.r-project.org/) and [RStudio](https://rstudio.com/). In
addition, we will also be using the package
[NMF](https://cran.r-project.org/web/packages/NMF/index.html) to
benchmark our work.

Here I write a function to solve for NMF using the multiplicative update
rule. I added a `delta` variable to the denominator update rule to
prevent division by zero. `K` specifies the column length of $W$ and the row length of $H$. `K` can also be considered as the number of hidden features we are
discovering in $V$. `K` is less than $n$ in a $n\times m$ matrix. After iterating for `x` number of `steps`, the function returns
a `list` containing `W` and `H` for $W$ and $H$
respectively.

``` r
nmf_mu <- function(R, K, delta = 0.001, steps = 5000){
  N = dim(R)[1]
  M = dim(R)[2]
  K = N
  W <- rmatrix(N,K) #Random initialization of W
  H <- rmatrix(K,M) #Random initialization of H
  for (step in 1:steps){
    W_TA = t(W) %*% R
    W_TWH = t(W) %*% W %*% H + delta
    for (i in 1:dim(H)[1]){
      for (j in 1:dim(H)[2]){
        H[i, j] = H[i, j] * W_TA[i, j] / W_TWH[i, j] #Updating H
      }
    }
    RH_T = R %*% t(H)
    WHH_T = W %*% H %*% t(H) + delta
    for (i in 1:dim(W)[1]){
      for (j in 1:dim(W)[2]){
        W[i, j] = W[i, j] * RH_T[i, j] / WHH_T[i, j] #Updating W
      }
    }
  }
  list <- list('W'=W, 'H'=H)
  return(list)
}
```

Let’s initialize a random $n\times m$
matrix and test our function.

``` r
require(NMF)
```

    ## Loading required package: NMF

    ## Loading required package: pkgmaker

    ## Loading required package: registry

    ## Loading required package: rngtools

    ## Loading required package: cluster

    ## NMF - BioConductor layer [OK] | Shared memory capabilities [NO: bigmemory] | Cores 11/12

    ##   To enable shared memory capabilities, try: install.extras('
    ## NMF
    ## ')

    ##
    ## Attaching package: 'NMF'

    ## The following object is masked from 'package:rmarkdown':
    ##
    ##     run

``` r
R <- rmatrix(5,6)
R
```

    ##           [,1]        [,2]      [,3]       [,4]       [,5]       [,6]
    ## [1,] 0.2654792 0.999808523 0.2205756 0.37758622 0.60422780 0.47795002
    ## [2,] 0.3483290 0.914457421 0.9823033 0.17167403 0.03328926 0.76176664
    ## [3,] 0.2151737 0.009164434 0.7778007 0.67275036 0.07443182 0.18584774
    ## [4,] 0.8040504 0.691110502 0.5477322 0.63334282 0.30461300 0.07827993
    ## [5,] 0.3298089 0.229627712 0.4505342 0.09935264 0.29061525 0.79473661

``` r
nmf_mu_results <- nmf_mu(R)
cat('\fMatrix W is:\n')
```

    ## Matrix W is:

``` r
print(nmf_mu_results$W)
```

    ##              [,1]         [,2]         [,3]         [,4]         [,5]
    ## [1,] 1.401996e-01 1.031005e+00 4.888448e-01 1.009283e-01 5.907953e-16
    ## [2,] 1.352905e+00 8.450852e-04 6.288241e-03 3.374402e-02 3.885390e-01
    ## [3,] 1.338529e-02 6.028721e-43 1.814912e-01 9.011644e-01 2.400931e-01
    ## [4,] 1.584792e-06 7.858847e-01 2.635584e-29 3.616356e-01 6.726390e-01
    ## [5,] 3.395663e-01 1.250900e-07 6.931389e-01 1.149180e-12 3.679404e-01

``` r
cat('Matrix H is:\n')
```

    ## Matrix H is:

``` r
print(nmf_mu_results$H)
```

    ##              [,1]         [,2]         [,3]         [,4]         [,5]
    ## [1,] 3.237081e-10 6.747615e-01 5.836394e-01 4.297091e-02 2.210281e-02
    ## [2,] 2.569625e-01 8.777521e-01 8.235903e-09 2.931030e-01 3.883205e-01
    ## [3,] 2.220118e-09 5.544948e-06 1.347266e-01 1.167679e-11 4.078395e-01
    ## [4,] 3.898739e-12 3.972138e-08 7.117763e-01 6.837224e-01 7.378500e-13
    ## [5,] 8.943226e-01 5.006893e-04 4.306573e-01 2.303535e-01 6.962892e-32
    ##              [,6]
    ## [1,] 5.256046e-01
    ## [2,] 2.760492e-10
    ## [3,] 8.262573e-01
    ## [4,] 7.389619e-07
    ## [5,] 1.158574e-01

Let’s see if we can reconstruct our original matrix and compare it to
the `nmf` function.

``` r
R
```

    ##           [,1]        [,2]      [,3]       [,4]       [,5]       [,6]
    ## [1,] 0.2654792 0.999808523 0.2205756 0.37758622 0.60422780 0.47795002
    ## [2,] 0.3483290 0.914457421 0.9823033 0.17167403 0.03328926 0.76176664
    ## [3,] 0.2151737 0.009164434 0.7778007 0.67275036 0.07443182 0.18584774
    ## [4,] 0.8040504 0.691110502 0.5477322 0.63334282 0.30461300 0.07827993
    ## [5,] 0.3298089 0.229627712 0.4505342 0.09935264 0.29061525 0.79473661

``` r
nmf_mu_results$W %*% nmf_mu_results$H
```

    ##           [,1]        [,2]      [,3]       [,4]       [,5]       [,6]
    ## [1,] 0.2649296 0.999570717 0.2195248 0.37722203 0.60282936 0.47760123
    ## [2,] 0.3476964 0.913824594 0.9818012 0.17095611 0.03279576 0.76130392
    ## [3,] 0.2147207 0.009153129 0.7770892 0.67202773 0.07431513 0.18481102
    ## [4,] 0.8034991 0.690149862 0.5470814 0.63254828 0.30517519 0.07793128
    ## [5,] 0.3290575 0.229314422 0.4500247 0.09934785 0.29019484 0.79381727

## Comparing to nmf()

We get the same results using the `nmf` function with the `lee` method.

``` r
nmf <- nmf(R, dim(R)[1], method = 'lee')
basis(nmf) %*% coefficients(nmf)
```

    ##           [,1]        [,2]      [,3]       [,4]       [,5]       [,6]
    ## [1,] 0.2654815 0.999785218 0.2205801 0.37758346 0.60426373 0.47794145
    ## [2,] 0.3482878 0.914442520 0.9822751 0.17162950 0.03560715 0.76172497
    ## [3,] 0.2151834 0.009286328 0.7778134 0.67275913 0.07408714 0.18590587
    ## [4,] 0.8040623 0.691129518 0.5477324 0.63335313 0.30454127 0.07831037
    ## [5,] 0.3298253 0.229725799 0.4505534 0.09936135 0.29043154 0.79476070

## Stochastic Gradient Descent Method

Now we will take a look at another method of implementing NMF. This one
is called Stochastic Gradient Descent (SGD). A gradient descent is a
first-order iterative optimization algorithm to finding a local minimum
for a function that is differentiable. In fact, we used the Block
Coordinate Descent in the multiplicative update rule. In SGD, we take
the derivative of the cost function like before. However, we will now be
focusing on taking the derivative of each variable, setting them to zero
or lower, solving for the feature variables, and finally updating each
feature. We also add a regularization term in the cost function to
control for over fitting.

$$||V - WH||_{F}^{2} =\Sigma_{i,j}(V - WH)^{2}_{ij}$$

$$e_{ij}^{2} =\Sigma_{i,j}(v_{ij}-\hat v_{ij})^{2} = (v_{ij} -\Sigma_{k=1}^{K} w_{ik}h_{kj})^{2}$$

$$e_{ij}^{2}  = (v_{ij} -\Sigma_{k=1}^{K}w_{ik}h_{kj})^{2} +\lambda\Sigma_{k=1}^{K}(||W||^{2} + ||H||^{2})$$
 $\lambda$ is used to control the magnitudes of $w$ and $h$ such that they would provide a good approximation of $v$. We will update each feature with each sample. We choose a small $\lambda$
, such as 0.01. The update is given by the equations below:

$$w_{ik}\leftarrow w_{ik} -\eta\frac{\partial}{\partial w_{ik}}e_{ij}^{2}$$

$$h_{kj}\leftarrow h_{kj} -\eta\frac{\partial}{\partial h_{kj}}e_{ij}^{2}$$
 $\eta$ is the learning rate and modifies the magnitude that we update the
features. We first solve for $\frac{\partial}{\partial h_{kj}}e_{ij}^{2}$.

Using the chain rule, $\frac{\partial}{\partial h_{kj}}(v_{ij} -\Sigma_{k=1}^{K}w_{ik}h_{kj}) =\frac{\partial u^{2}}{\partial v}\frac{\partial u}{\partial v}$, where $u = (v_{ij} -\Sigma_{k=1}^{K}w_{ik}h_{kj}) and\frac{\partial u^{2}}{\partial v} = 2u$ $$\frac{\partial}{\partial h_{kj}}e_{ij}^{2} = 2(v_{ij} -\Sigma_{k=1}^{K}w_{ik}h_{kj})\frac{\partial}{\partial h_{kj}}(v_{ij} -\Sigma_{k=1}^{K}w_{ik}h_{kj}) + 2\lambda h_{kj} $$

$$\frac{\partial}{\partial h_{kj}}e_{ij}^{2} = -2e_{ij}w_{ik} + 2\lambda h_{kj} $$

The final update rules for both $W$ and $H$:

$$\frac{\partial}{\partial h_{kj}}e_{ij}^{2} = -2e_{ij}w_{ik} + 2\lambda h_{kj} $$

$$\frac{\partial}{\partial w_{ik}}e_{ij}^{2} = -2e_{ij}h + 2\lambda w_{ik} $$


``` r
frob_norm <- function(M){
  norm = 0
  for (i in 1:dim(M)[1]){
    for (j in 1:dim(M)[2]){
      norm = norm + M[i,j] ** 2
    }
  }
  return(sqrt(norm))
}
nmf_sgd <- function(A,steps = 50000, lam = 1e-2, lr = 1e-3){
  N = dim(A)[1]
  M = dim(A)[2]
  K = N
  W <- rmatrix(N,K)
  H <- rmatrix(K,M)
  for (step in 1:steps){
    R =  A - W %*% H
    dW = R %*% t(H) - W*lam
    dH = t(W) %*% R - H*lam
    W = W + lr * dW
    H = H + lr * dH
    if (frob_norm(A - W %*% H) < 0.01){
      print(frob_norm(A - W %*% H))
      break
    }
  }
  list <- list(W, t(H))
  return(list)
}
```

``` r
nmf_sgd_results <- nmf_sgd(R)
R
```

    ##           [,1]        [,2]      [,3]       [,4]       [,5]       [,6]
    ## [1,] 0.2654792 0.999808523 0.2205756 0.37758622 0.60422780 0.47795002
    ## [2,] 0.3483290 0.914457421 0.9823033 0.17167403 0.03328926 0.76176664
    ## [3,] 0.2151737 0.009164434 0.7778007 0.67275036 0.07443182 0.18584774
    ## [4,] 0.8040504 0.691110502 0.5477322 0.63334282 0.30461300 0.07827993
    ## [5,] 0.3298089 0.229627712 0.4505342 0.09935264 0.29061525 0.79473661

The reconstructed method using our NMF function looks like this:

``` r
nmf_sgd_results[[1]] %*% t(nmf_sgd_results[[2]])
```

    ##           [,1]       [,2]      [,3]      [,4]       [,5]      [,6]
    ## [1,] 0.2681854 0.99401198 0.2227126 0.3749699 0.59870008 0.4760952
    ## [2,] 0.3487419 0.90904861 0.9762124 0.1742213 0.03726270 0.7588021
    ## [3,] 0.2174286 0.01242527 0.7720973 0.6657916 0.07389233 0.1857447
    ## [4,] 0.7956266 0.68896989 0.5468757 0.6309005 0.30421298 0.0813123
    ## [5,] 0.3261383 0.23288393 0.4499075 0.1006391 0.28742367 0.7868103

As you can see, it is a near approximation of the original matrix. In
another post, I will go into detail the differences between each
dimensional reduction technique. See below for more information on NMF.

## Additional Resources

\-[Algorithms for non-negative matrix
factorization](https://papers.nips.cc/paper/1861-algorithms-for-non-negative-matrix-factorization.pdf)

\-[Non-negative matrix
factorization](https://github.com/hpark3910/nonnegative-matrix-factorization)

\-[Non-negative matrix
factorization](https://www.almoststochastic.com/2013/06/nonnegative-matrix-factorization.html)
-[NMF from scratch using
SGD](https://github.com/carriexu24/NMF-from-scratch-using-SGD) -[Python
Matrix
Factorization](https://albertauyeung.github.io/2017/04/23/python-matrix-factorization.html)
