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
  return(list).
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
R <- rmatrix(5,6).
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2572934 0.7850774 0.1964726 0.89460898 0.5124385 0.6538741
    ## [2,] 0.4548971 0.7619701 0.4504754 0.04016496 0.1973834 0.9347442
    ## [3,] 0.8251736 0.3744436 0.5294228 0.79247087 0.5080712 0.3198328
    ## [4,] 0.9600582 0.5075759 0.1684872 0.95316732 0.4352644 0.5006196
    ## [5,] 0.3160396 0.5518905 0.2720268 0.01742472 0.1015410 0.3987225

``` r
nmf_mu_results <- nmf_mu(R)
cat('\fMatrix W is:\n')
```

    ## Matrix W is:

``` r
print(nmf_mu_results$W)
```

    ##              [,1]        [,2]         [,3]         [,4]         [,5]
    ## [1,] 1.248983e-07 0.378515344 1.318960e-01 2.780618e-02 9.292941e-01
    ## [2,] 2.947557e-01 0.927749513 1.211089e-01 5.765705e-01 6.761024e-07
    ## [3,] 5.287462e-01 0.004320335 6.874418e-01 1.083155e-11 7.077161e-01
    ## [4,] 5.904350e-01 0.009073315 9.627698e-06 9.538376e-02 9.592665e-01
    ## [5,] 2.025896e-01 0.668434477 2.968120e-28 1.535730e-13 1.154320e-03

``` r
cat('Matrix H is:\n')
```

    ## Matrix H is:

``` r
print(nmf_mu_results$H)
```

    ##             [,1]         [,2]         [,3]         [,4]         [,5]
    ## [1,] 1.237671420 1.418457e-02 2.791433e-01 7.841158e-02 5.989354e-08
    ## [2,] 0.096085379 8.172298e-01 3.225888e-01 5.855245e-09 1.527530e-01
    ## [3,] 0.002640661 2.122093e-04 5.518361e-01 1.179900e-01 2.745037e-01
    ## [4,] 0.000131951 1.638545e-06 2.627534e-03 1.515055e-03 3.591244e-02
    ## [5,] 0.237396251 5.120855e-01 1.347844e-08 9.453276e-01 4.488068e-01
    ##              [,6]
    ## [1,] 1.323084e-02
    ## [2,] 5.933110e-01
    ## [3,] 3.825011e-08
    ## [4,] 6.572912e-01
    ## [5,] 4.411818e-01

Let’s see if we can reconstruct our original matrix and compare it to
the `nmf` function.

``` r.
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2572934 0.7850774 0.1964726 0.89460898 0.5124385 0.6538741
    ## [2,] 0.4548971 0.7619701 0.4504754 0.04016496 0.1973834 0.9347442
    ## [3,] 0.8251736 0.3744436 0.5294228 0.79247087 0.5080712 0.3198328
    ## [4,] 0.9600582 0.5075759 0.1684872 0.95316732 0.4352644 0.5006196
    ## [5,] 0.3160396 0.5518905 0.2720268 0.01742472 0.1015410 0.3987225

``` r
nmf_mu_results$W %*% nmf_mu_results$H
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2573328 0.7852400 0.1949629 0.89409185 0.5120974 0.6528417
    ## [2,] 0.4543499 0.7623925 0.4499079 0.03827608 0.1956677 0.9333189
    ## [3,] 0.8246536 0.3735878 0.5283449 0.79159463 0.5069931 0.3217905
    ## [4,] 0.9593752 0.5070167 0.1679989 0.95326369 0.4353395 0.4991011
    ## [5,] 0.3152401 0.5497293 0.2721810 0.01697658 0.1026234 0.3997792

## Comparing to nmf()

We get the same results using the `nmf` function with the `lee` method.

``` r
nmf <- nmf(R, dim(R)[1], method = 'lee')
basis(nmf) %*% coefficients(nmf)
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2571071 0.7851170 0.1966876 0.89544068 0.5106587 0.6540914
    ## [2,] 0.4550240 0.7620104 0.4504028 0.03931272 0.1972511 0.9347751
    ## [3,] 0.8253166 0.3744389 0.5294810 0.79280535 0.5072254 0.3198603
    ## [4,] 0.9601864 0.5075281 0.1682418 0.95196013 0.4378507 0.5005094
    ## [5,] 0.3152430 0.5518350 0.2720400 0.02431452 0.1037512 0.3984364

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

The final update rules for both $W$ and $H$.

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
  return(sqrt(norm)).
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
  return(list).
```

``` r
nmf_sgd_results <- nmf_sgd(R).
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2572934 0.7850774 0.1964726 0.89460898 0.5124385 0.6538741
    ## [2,] 0.4548971 0.7619701 0.4504754 0.04016496 0.1973834 0.9347442
    ## [3,] 0.8251736 0.3744436 0.5294228 0.79247087 0.5080712 0.3198328
    ## [4,] 0.9600582 0.5075759 0.1684872 0.95316732 0.4352644 0.5006196
    ## [5,] 0.3160396 0.5518905 0.2720268 0.01742472 0.1015410 0.3987225

The reconstructed method using our NMF function looks like this:

``` r
nmf_sgd_results[[1]] %*% t(nmf_sgd_results[[2]])
```

    ##           [,1]      [,2]      [,3]       [,4]      [,5]      [,6]
    ## [1,] 0.2620366 0.7804305 0.1970252 0.88902520 0.5092941 0.6512767
    ## [2,] 0.4535915 0.7608638 0.4476562 0.04331351 0.1972235 0.9260586
    ## [3,] 0.8216679 0.3759426 0.5219099 0.78968437 0.5042836 0.3215420
    ## [4,] 0.9526964 0.5071181 0.1730190 0.94912249 0.4359087 0.4988104
    ## [5,] 0.3136085 0.5434768 0.2704516 0.02022789 0.1030468 0.4015469

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
