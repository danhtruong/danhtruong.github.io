---
layout: single
toc: true
mathjax: true
title: Non-negative Matrix Factorization
tags: tutorials R machine-learning
---


Non-negative Matrix Factorization
---------------------------------

In this post, I will be discussing Non-negative Matrix Factorization
(NMF). NMF is a low-rank approximation algorithm that discovers latent
features in your data. It is similar to PCA in the sense that they both
reduce high-dimensional data into lower dimensions for better
understanding of the data. The major difference is that PCA projects
data onto a subspace that maximizes variability for the discovered
features, while NMF discovers non-negative features that are additive in
nature.

NMF is formally defined as:

*V* ≈ *W**H*

where *V* is a non-negative matrix and both *W* and *H* are unique and
non-negative matrices. In other words, the matrix *V* is factorized into
two matrices *W* and *H*, where *W* is the features matrix or the basis
and *H* is the coefficient matrix. Typically, this means that *H*
represents a coordinate system that uses *W* to reconstruct *V*. We can
consider that *V* is a linear combination of column vectors of *W* using
the coordinate system in *H*, *v*<sub>*i*</sub> = *W**h*<sub>*i*</sub>.

Solving for NMF
---------------

Here, I will describe two algorithms to solve for NMF using iterative
updates of *W* and *H*. First, we will consider the cost function. A
cost function is a function that quantifies or measures the error
between the predicted values and the expected values. The Mean Squared
Error (MSE), or L2 loss is one of the most popular cost functions in
linear regressions. Given an linear equation *y* = *m**x* + *b*, MSE is:

$$MSE = \\frac{1}{N}\\Sigma\_{i=1}^{n}(y\_{i}-(mx\_{i}+b))^{2} $$

For the cost function in NMF, we use a similar function called the
Frobenius Norm. It is defined as:

$$\|\|A\|\|\_{F} = \\sqrt{\\Sigma\_{i=1}^{m}\\Sigma\_{j=1}^{n} \|a\_{ij}\|^{2}}$$

In the case of NMF, we are using the square of the Forbenius norm to
measure how good of an approximation *W**H* is for *V*.

\|\|*V* − *W**H*\|\|<sub>*F*</sub><sup>2</sup> = *Σ*<sub>*i*, *j*</sub>(*V* − *W**H*)<sub>*i**j*</sub><sup>2</sup>

Optimization
------------

We can see that as *W**H* approaches *V*, then the equation will slowly
converge to zero. Therefore, the optimization can be defined as the
following:

Minimize \|\|*V* − *W**H*\|\|<sub>*F*</sub><sup>2</sup> with respect to
*W* and *H*, subject to the constraints *W*, *H* ≥ 0

In the paper by Lee & Seung, they introduced the multiplicative update
rule to solve for NMF. Please see their original paper for details on
the proof. Essentially the update causes the function value to be
non-increasing to converge to zero.

$$H\_{ik} \\leftarrow H\_{ik}\\frac{(W^{T}V)\_{ik}}{(W^{T}WH)\_{ik}}$$

$$W\_{kj} \\leftarrow W\_{kj}\\frac{(VH^{T})\_{kj}}{(WHH^{T})\_{kj}}$$

Multiplicative Update Rule
--------------------------

Here we will implement NMF using the multiplicative update rule. To get
started, make sure you have installed both
[R](https://www.r-project.org/) and [RStudio](https://rstudio.com/). In
addition, we will also be using the package
[NMF](https://cran.r-project.org/web/packages/NMF/index.html) to
benchmark our work.

Here I write a function to solve for NMF using the multiplicative update
rule. I added a `delta` variable to the denominator update rule to
prevent division by zero. `K` specifies the column length of *W* and the
row length of *H*. `K` can also be considered as the number of hidden
features we are discovering in *V*. `K` is less than *n* in a *n* × *m*
matrix. After iterating for `x` number of `steps`, the function returns
a `list` containing `W` and `H` for *W* and *H* respectively.

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

Let’s initialize a random *n* × *m* matrix and test our function.

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

``` r
R <- rmatrix(5,6)
R
```

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09905736 0.2478429 0.04375564 0.1950761 0.405054093 0.2530112
    ## [2,] 0.54500282 0.2224704 0.18141923 0.8524384 0.002520487 0.6324748
    ## [3,] 0.32894659 0.9509463 0.85749386 0.2958201 0.364320588 0.7016630
    ## [4,] 0.33408402 0.7937827 0.74916835 0.9226052 0.408974110 0.9003786
    ## [5,] 0.29078914 0.5180659 0.36904535 0.6418668 0.395588249 0.4618191

``` r
nmf_mu_results <- nmf_mu(R)
cat('\fMatrix W is:\n')
```

    ## Matrix W is:

``` r
print(nmf_mu_results$W)
```

    ##              [,1]       [,2]       [,3]         [,4]         [,5]
    ## [1,] 2.691750e-01 0.01385374 0.06198269 1.836271e-02 6.716942e-01
    ## [2,] 4.930224e-01 1.05188609 0.01643810 4.243030e-04 6.268145e-18
    ## [3,] 1.161688e-01 0.00583856 1.24543959 2.767930e-06 7.984387e-05
    ## [4,] 4.261867e-03 0.28319823 0.97779889 8.984428e-01 4.426755e-02
    ## [5,] 8.123287e-06 0.52221786 0.41160731 1.914287e-02 4.752637e-01

``` r
cat('Matrix H is:\n')
```

    ## Matrix H is:

``` r
print(nmf_mu_results$H)
```

    ##              [,1]         [,2]         [,3]         [,4]         [,5]      [,6]
    ## [1,] 2.954934e-01 8.303074e-02 5.591606e-05 0.0003950417 6.819028e-21 0.4884581
    ## [2,] 3.744435e-01 1.598566e-01 1.614739e-01 0.8065089938 5.775985e-24 0.3632584
    ## [3,] 2.331770e-01 7.540462e-01 6.879758e-01 0.2341713079 2.928191e-01 0.5159816
    ## [4,] 1.958999e-12 5.597541e-05 3.298071e-02 0.5048889321 1.071230e-01 0.3169910
    ## [5,] 9.893344e-09 2.608269e-01 1.726926e-13 0.2377586707 5.721401e-01 0.1143221

Let’s see if we can reconstruct our original matrix and compare it to
the `nmf` function.

``` r
R
```

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09905736 0.2478429 0.04375564 0.1950761 0.405054093 0.2530112
    ## [2,] 0.54500282 0.2224704 0.18141923 0.8524384 0.002520487 0.6324748
    ## [3,] 0.32894659 0.9509463 0.85749386 0.2958201 0.364320588 0.7016630
    ## [4,] 0.33408402 0.7937827 0.74916835 0.9226052 0.408974110 0.9003786
    ## [5,] 0.29078914 0.5180659 0.36904535 0.6418668 0.395588249 0.4618191

``` r
nmf_mu_results$W %*% nmf_mu_results$H
```

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09917982 0.2464991 0.04550027 0.1947663 0.404419944 0.2511054
    ## [2,] 0.54338978 0.2214821 0.18120271 0.8526139 0.004858843 0.6315435
    ## [3,] 0.32692123 0.9497187 0.85778165 0.2964213 0.364734438 0.7014984
    ## [4,] 0.33530133 0.7945269 0.74806260 0.9215148 0.407889290 0.8993411
    ## [5,] 0.29152086 0.5178142 0.36813176 0.6402231 0.394494552 0.4624870

Comparing to nmf()
------------------

We get the same results using the `nmf` function with the `lee` method.

``` r
nmf <- nmf(R, dim(R)[1], method = 'lee')
basis(nmf) %*% coefficients(nmf)
```

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09924246 0.2475790 0.04434053 0.1949551 0.405163397 0.2530105
    ## [2,] 0.54497749 0.2223666 0.18147312 0.8523970 0.007434532 0.6325049
    ## [3,] 0.32893939 0.9509209 0.85750687 0.2958630 0.364292099 0.7016847
    ## [4,] 0.33413698 0.7937349 0.74925030 0.9226050 0.409027875 0.9003006
    ## [5,] 0.29071181 0.5183639 0.36875245 0.6419320 0.395366817 0.4618959

Stochastic Gradient Descent Method
----------------------------------

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

\|\|*V* − *W**H*\|\|<sub>*F*</sub><sup>2</sup> = *Σ*<sub>*i*, *j*</sub>(*V* − *W**H*)<sub>*i**j*</sub><sup>2</sup>

*e*<sub>*i**j*</sub><sup>2</sup> = *Σ*<sub>*i*, *j*</sub>(*v*<sub>*i**j*</sub> − *v̂*<sub>*i**j*</sub>)<sup>2</sup> = (*v*<sub>*i**j*</sub> − *Σ*<sub>*k* = 1</sub><sup>*K*</sup>*w*<sub>*i**k*</sub>*h*<sub>*k**j*</sub>)<sup>2</sup>

*e*<sub>*i**j*</sub><sup>2</sup> = (*v*<sub>*i**j*</sub> − *Σ*<sub>*k* = 1</sub><sup>*K*</sup>*w*<sub>*i**k*</sub>*h*<sub>*k**j*</sub>)<sup>2</sup> + *λ**Σ*<sub>*k* = 1</sub><sup>*K*</sup>(\|\|*W*\|\|<sup>2</sup> + \|\|*H*\|\|<sup>2</sup>)

*λ* is used to control the magnitudes of *w* and *h* such that they
would provide a good approximation of *v*. We will update each feature
with each sample. We choose a small *λ*, such as 0.01. The update is
given by the equations below:

$$w\_{ik} \\leftarrow w\_{ik} - \\eta \\frac{\\partial}{\\partial w\_{ik}}e\_{ij}^{2}$$

$$h\_{kj} \\leftarrow h\_{kj} - \\eta \\frac{\\partial}{\\partial h\_{kj}}e\_{ij}^{2}$$

*η* is the learning rate and modifies the magnitude that we update the
features. We first solve for
$\\frac{\\partial}{\\partial h\_{kj}}e\_{ij}^{2}$.

Using the chain rule,
$\\frac{\\partial}{\\partial h\_{kj}}(v\_{ij} - \\Sigma\_{k=1}^{K}w\_{ik}h\_{kj}) = \\frac{\\partial u^{2}}{\\partial v} \\frac{\\partial u}{\\partial v}$,
where
$u = (v\_{ij} - \\Sigma\_{k=1}^{K}w\_{ik}h\_{kj}) and \\frac{\\partial u^{2}}{\\partial v} = 2u$

$$ \\frac{\\partial}{\\partial h\_{kj}}e\_{ij}^{2} = 2(v\_{ij} - \\Sigma\_{k=1}^{K}w\_{ik}h\_{kj}) \\frac{\\partial}{\\partial h\_{kj}}(v\_{ij} - \\Sigma\_{k=1}^{K}w\_{ik}h\_{kj}) + 2\\lambda h\_{kj} $$

$$ \\frac{\\partial}{\\partial h\_{kj}}e\_{ij}^{2} = -2e\_{ij}w\_{ik} + 2\\lambda h\_{kj} $$

The final update rules for both *W* and *H*:

$$ \\frac{\\partial}{\\partial h\_{kj}}e\_{ij}^{2} = -2e\_{ij}w\_{ik} + 2\\lambda h\_{kj} $$

$$ \\frac{\\partial}{\\partial w\_{ik}}e\_{ij}^{2} = -2e\_{ij}h + 2\\lambda w\_{ik} $$

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

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09905736 0.2478429 0.04375564 0.1950761 0.405054093 0.2530112
    ## [2,] 0.54500282 0.2224704 0.18141923 0.8524384 0.002520487 0.6324748
    ## [3,] 0.32894659 0.9509463 0.85749386 0.2958201 0.364320588 0.7016630
    ## [4,] 0.33408402 0.7937827 0.74916835 0.9226052 0.408974110 0.9003786
    ## [5,] 0.29078914 0.5180659 0.36904535 0.6418668 0.395588249 0.4618191

The reconstructed method using our NMF function looks like this:

``` r
nmf_sgd_results[[1]] %*% t(nmf_sgd_results[[2]])
```

    ##            [,1]      [,2]       [,3]      [,4]        [,5]      [,6]
    ## [1,] 0.09863228 0.2473362 0.04798037 0.1964412 0.397647806 0.2489619
    ## [2,] 0.53861011 0.2248965 0.18254488 0.8479491 0.005006116 0.6281894
    ## [3,] 0.32577982 0.9463503 0.85143306 0.2996603 0.363407073 0.6991135
    ## [4,] 0.33856887 0.7905435 0.74707837 0.9176033 0.409385845 0.8949819
    ## [5,] 0.28771615 0.5155300 0.36740090 0.6363319 0.390869158 0.4669974

As you can see, it is a near approximation of the original matrix. In
another post, I will go into detail the differences between each
dimensional reduction technique. See below for more information on NMF.

Additional Resources
--------------------

-[Algorithms for non-negative matrix
factorization](https://papers.nips.cc/paper/1861-algorithms-for-non-negative-matrix-factorization.pdf)

-[Non-negative matrix
factorization](https://github.com/hpark3910/nonnegative-matrix-factorization)

-[Non-negative matrix
factorization](https://www.almoststochastic.com/2013/06/nonnegative-matrix-factorization.html)
-[NMF from scratch using
SGD](https://github.com/carriexu24/NMF-from-scratch-using-SGD) -[Python
Matrix
Factorization](https://albertauyeung.github.io/2017/04/23/python-matrix-factorization.html)
