---
layout: single
toc: true
mathjax: true
title: Gradient Descents
tags: tutorials R machine-learning
---

Gradient Descents
-----------------

In this post, we are going to discuss *Gradient Descents*; what it is
and how to use it. Gradient Descent is used in many machine learning
algorithms to find the local minimum in differentiable functions where
there is a linear relationship. It goes hand in hand with optimization
problems. In this tutorial, we will focus on linear regressions. A
linear regression is used to model the relationship between one or more
variables. In our case, we have an input *x* and an output *y*, but we
do not know the slope *m* or the intercept *b*.

*y* = *m**x* + *b*

To build our model, we need to tune two parameters, namely *m* and *b*.
To do so, we need to use the mean squared error (MSE) as our loss
function. This function measures the average squared difference between
the estimated values and the actual value. We expect this to be 0 if our
predicted values equal our actual value.

$MSE = \_{i=1}<sup>{n}(Y\_{i}-Y\_{i})</sup>{2} $ Therefore, we will need
optimize the MSE for a linear regression using the gradient descent. A
gradient is defined as follows:

$ J() = \[, , …, \] $ The gradient descent is defined in the following
equation. The algorithm will iterate over and over using the gradient
descent to find new values of *m* and *b*. This will continue until MSE
converges to zero, letting us know that our predicted values equal to
our actual values.

$ *{n + 1} = *{n} - J(\_{n})$

Let’s first solve for ∇*J*(*θ*<sub>*n*</sub>) by plugging in the MSE
equation and finding the partial derivatives with respect to *m* and
*b*.

$MSE = \_{i=1}<sup>{n}(y\_{i}-(mx\_{i}+b))</sup>{2} $

$ f(m,b) = *{i=1}<sup>{n}(y\_{i}-(mx\_{i}+b))</sup>{2} $ $ =
*{i=1}^{n}-2(y\_{i}-(mx\_{i}+b)) (mx\_{i}+b))$ $ =
*{i=1}^{n}-2x*{i}(y\_{i}-(mx\_{i}+b))$

$ = *{i=1}^{n}-2(y*{i}-(mx\_{i}+b)) (mx\_{i}+b))$ $ =
*{i=1}^{n}-2(y*{i}-(mx\_{i}+b))$ Now we have our two final equations. We
can begin implementing them.

$ m = m - (*{i=1}^{n}-2x*{i}(y\_{i}-(mx\_{i}+b)))$

$ b = b - (*{i=1}^{n}-2(y*{i}-(mx\_{i}+b)))$ We will input two vectors
*x* and *y* and solve for *m* and *b*. In addition, we set a learning
rate, *η* of 0.001. This controls the magnitude of the gradient. If it
is too large, we will miss the minima, but if it is too small, the
number of iterations will increase. For this function, we will iterate
10,000 times and break the loop if *M**S**E* ≤ *ϵ*, *ϵ* = 0.001.

``` r
gradient_descent <- function(x,y, epsilon = 0.001, lr = 0.001, steps = 10000){
  epsilon = 0.0001
  m = runif(1) #Initialize a random number
  b = runif(1) #Initialize a random number
  N = length(x)
  log = c()
  mseloss = c()
  for (step in 1:steps){
    f = y - (m*x + b) #Subtracting the estimated value from the actual value
    mseloss = c(mseloss, sum(f ** 2) / N)
    dm <- -2 / N * sum(x %*% f)
    db <- -2 / N * sum(f)
    m = m - lr * dm
    b = b - lr * db
    log = rbind(log, c(m,b))
    if (sum(f ** 2) / N <= epsilon){ #stop the algorithm once we have converged to zero
      break
    }
  }
  list = list('m' = m, 'b' = b, 'steps' = step, 'log' = log, 'mseloss' = mseloss)
  return(list)
}
```

We can initialize a simple example by setting `x = c(1,2,3,4,5)` and
`y = 2 * x`. We expect `m = 2` and `b = 0`.

``` r
x = c(1,2,3,4,5)
y = 2 * x
ptm <- proc.time()
res <- gradient_descent(x,y)
proc.time() - ptm
```

    ##    user  system elapsed 
    ##   0.679   0.423   1.105

``` r
res$m
```

    ## [1] 1.98692

``` r
res$b
```

    ## [1] 0.04722129

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 2.034142 4.021062 6.007983 7.994903 9.981824

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 2 4 6 8 10

We can observe convergence by plotting the MSE against the number of
iterations.

``` r
library(ggplot2)
df <- data.frame('iters' = 1:res$steps, 'mseloss' = res$mseloss)
ggplot(df, aes(x = iters, y = mseloss)) + geom_point() + theme_minimal() + ylab('MSE Loss')
```

![]({{ site.baseurl }}/images/Gradient-Descent_files/figure-markdown_github/unnamed-chunk-3-1.png)

It appears to converge early but continues on to meet our requirement of
*M**S**E* ≤ *ϵ*. Let’s repeat this with a larger data set. We would
expect this to take longer.

``` r
x = runif(10000)
y = 2 * x
ptm <- proc.time()
res <- gradient_descent(x,y)
proc.time() - ptm
```

    ##    user  system elapsed 
    ##   2.432   1.348   3.794

``` r
res$m
```

    ## [1] 1.521468

``` r
res$b
```

    ## [1] 0.2541463

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 0.8426236 0.8781545 1.249391 0.8346249 1.528974 1.134442

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 0.7735649 0.8202709 1.308268 0.7630504 1.675786 1.157166

``` r
df <- data.frame('iters' = 1:res$steps, 'mseloss' = res$mseloss)
ggplot(df, aes(x = iters, y = mseloss)) + geom_point() + theme_minimal() + ylab('MSE Loss')
```

![]({{ site.baseurl }}/images/Gradient-Descent_files/figure-markdown_github/unnamed-chunk-5-1.png)

As you can see, the predicted values don’t match the actual values. In
addition, the MSE loss does not converge. This suggests we may need more
iterations. Let’s try with 50,000 iterations.

``` r
ptm <- proc.time()
res <- gradient_descent(x,y, steps = 50000)
proc.time() - ptm
```

    ##    user  system elapsed 
    ##  10.926   6.617  17.845

``` r
res$m
```

    ## [1] 1.965626

``` r
res$b
```

    ## [1] 0.01825591

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 0.7785256 0.8244288 1.304039 0.7681918 1.66524 1.155534

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 0.7735649 0.8202709 1.308268 0.7630504 1.675786 1.157166

``` r
df <- data.frame('iters' = 1:res$steps, 'mseloss' = res$mseloss)
ggplot(df, aes(x = iters, y = mseloss)) + geom_point() + theme_minimal() + ylab('MSE Loss')
```

![]({{ site.baseurl }}/images/Gradient-Descent_files/figure-markdown_github/unnamed-chunk-7-1.png)

Comparing to Stochastic Gradient Descent
----------------------------------------

Now it looks like we have converged and reached an optimal value.
However, the time it took was much longer. To wrap up, we were able to
determine a suitable *m* and *b* to satisfy our optimization problem.
However, this algorithm can be slow if we are working with large
matrices. In that case, we can use *Stochastic Gradient Descent* and use
only a subset of the matrix with one sample at a time for the
optimization.

Let’s see what this would look like.

``` r
s_gradient_descent <- function(x,y, epsilon = 0.001, lr = 0.001, steps = 10000, batch_size = 1){
  epsilon = 0.0001
  m = runif(1) #Initialize a random number
  b = runif(1) #Initialize a random number
  log = c()
  mseloss = c()
  for (step in 1:steps){
    index <- sample.int(length(y), batch_size)
    N = length(index)
    Xs <- x[index]
    Ys <- y[index]
    f = Ys - (m*Xs + b) #Subtracting the estimated value from the actual value
    mseloss = c(mseloss, sum(f ** 2) / N)
    dm <- -2 / N * sum(Xs %*% f)
    db <- -2 / N * sum(f)
    m = m - lr * dm
    b = b - lr * db
    log = rbind(log, c(m,b))
    if (sum(f ** 2) / N <= epsilon){ #stop the algorithm once we have converged to zero
      break
    }
  }
  list = list('m' = m, 'b' = b, 'steps' = step, 'log' = log, 'mseloss' = mseloss)
  return(list)
}
```

With the above function, we will only be using a subset of our data for
optimization. In this case, I will set it to 100. Feel free to play
around with the parameters.

``` r
ptm <- proc.time()
sgd_res <- s_gradient_descent(x,y, steps = 50000, batch = 100)
proc.time() - ptm
```

    ##    user  system elapsed 
    ##   5.545   3.569   9.205

``` r
sgd_res$m
```

    ## [1] 1.959872

``` r
sgd_res$b
```

    ## [1] 0.0213372

``` r
cat('The predicted values are:', head(sgd_res$m * x + sgd_res$b))
```

    ## The predicted values are: 0.7793815 0.8251504 1.303357 0.769078 1.6635 1.155286

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 0.7735649 0.8202709 1.308268 0.7630504 1.675786 1.157166

As you can see, we nearly cut out run time in half by just using
stochastic gradient descent.

Additional Resources
--------------------

-   <https://towardsdatascience.com/gradient-descent-from-scratch-e8b75fa986cc>{:target="\_blank"}
-   <https://www.ocf.berkeley.edu/~janastas/stochastic-gradient-descent-in-r.html>{:target="\_blank"}
-   <https://www.r-bloggers.com/2017/02/implementing-the-gradient-descent-algorithm-in-r/>{:target="\_blank"}
