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
variables. In our case, we have an input
![x](https://latex.codecogs.com/png.latex?x "x") and an output
![y](https://latex.codecogs.com/png.latex?y "y"), but we do not know the
slope ![m](https://latex.codecogs.com/png.latex?m "m") or the intercept
![b](https://latex.codecogs.com/png.latex?b "b").

![y = mx + b](https://latex.codecogs.com/png.latex?y%20%3D%20mx%20%2B%20b "y = mx + b")

To build our model, we need to tune two parameters, namely
![m](https://latex.codecogs.com/png.latex?m "m") and
![b](https://latex.codecogs.com/png.latex?b "b"). To do so, we need to
use the mean squared error (MSE) as our loss function. This function
measures the average squared difference between the estimated values and
the actual value. We expect this to be 0 if our predicted values equal
our actual value.

$MSE = \_{i=1}<sup>{n}(Y\_{i}-Y\_{i})</sup>{2} $ Therefore, we will need
optimize the MSE for a linear regression using the gradient descent. A
gradient is defined as follows:

$ J() = \[, , …, \] $ The gradient descent is defined in the following
equation. The algorithm will iterate over and over using the gradient
descent to find new values of
![m](https://latex.codecogs.com/png.latex?m "m") and
![b](https://latex.codecogs.com/png.latex?b "b"). This will continue
until MSE converges to zero, letting us know that our predicted values
equal to our actual values.

$ *{n + 1} = *{n} - J(\_{n})$

Let’s first solve for
![\\nabla J(\\theta\_{n})](https://latex.codecogs.com/png.latex?%5Cnabla%20J%28%5Ctheta_%7Bn%7D%29 "\nabla J(\theta_{n})")
by plugging in the MSE equation and finding the partial derivatives with
respect to ![m](https://latex.codecogs.com/png.latex?m "m") and
![b](https://latex.codecogs.com/png.latex?b "b").

$MSE = \_{i=1}<sup>{n}(y\_{i}-(mx\_{i}+b))</sup>{2} $

$ f(m,b) = *{i=1}<sup>{n}(y\_{i}-(mx\_{i}+b))</sup>{2} $ $ =
*{i=1}^{n}-2(y\_{i}-(mx\_{i}+b)) (mx\_{i}+b))$ $ =
*{i=1}^{n}-2x*{i}(y\_{i}-(mx\_{i}+b))$

$ = *{i=1}^{n}-2(y*{i}-(mx\_{i}+b)) (mx\_{i}+b))$ $ =
*{i=1}^{n}-2(y*{i}-(mx\_{i}+b))$ Now we have our two final equations. We
can begin implementing them.

$ m = m - (*{i=1}^{n}-2x*{i}(y\_{i}-(mx\_{i}+b)))$

$ b = b - (*{i=1}^{n}-2(y*{i}-(mx\_{i}+b)))$ We will input two vectors
![x](https://latex.codecogs.com/png.latex?x "x") and
![y](https://latex.codecogs.com/png.latex?y "y") and solve for
![m](https://latex.codecogs.com/png.latex?m "m") and
![b](https://latex.codecogs.com/png.latex?b "b"). In addition, we set a
learning rate,
![\\eta](https://latex.codecogs.com/png.latex?%5Ceta "\eta") of 0.001.
This controls the magnitude of the gradient. If it is too large, we will
miss the minima, but if it is too small, the number of iterations will
increase. For this function, we will iterate 10,000 times and break the
loop if
![MSE \\le \\epsilon](https://latex.codecogs.com/png.latex?MSE%20%5Cle%20%5Cepsilon "MSE \le \epsilon"),
![\\epsilon = 0.001](https://latex.codecogs.com/png.latex?%5Cepsilon%20%3D%200.001 "\epsilon = 0.001").

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
    ##   0.737   0.393   1.141

``` r
res$m
```

    ## [1] 1.993511

``` r
res$b
```

    ## [1] 0.02342875

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 2.016939 4.01045 6.003961 7.997471 9.990982

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
![MSE \\le \\epsilon](https://latex.codecogs.com/png.latex?MSE%20%5Cle%20%5Cepsilon "MSE \le \epsilon").
Let’s repeat this with a larger data set. We would expect this to take
longer.

``` r
x = runif(10000)
y = 2 * x
ptm <- proc.time()
res <- gradient_descent(x,y)
proc.time() - ptm
```

    ##    user  system elapsed 
    ##   2.638   1.268   3.959

``` r
res$m
```

    ## [1] 1.717294

``` r
res$b
```

    ## [1] 0.151331

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 1.732556 0.9191655 0.8045655 0.9002924 0.5695432 0.7010812

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 1.841531 0.8942376 0.7607719 0.8722576 0.4870595 0.6402517

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
    ##   8.564   4.665  13.309

``` r
res$m
```

    ## [1] 1.965594

``` r
res$b
```

    ## [1] 0.01841738

``` r
cat('The predicted values are:', head(res$m * x + res$b))
```

    ## The predicted values are: 1.828268 0.8972714 0.7661017 0.8756695 0.497098 0.6476548

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 1.841531 0.8942376 0.7607719 0.8722576 0.4870595 0.6402517

``` r
df <- data.frame('iters' = 1:res$steps, 'mseloss' = res$mseloss)
ggplot(df, aes(x = iters, y = mseloss)) + geom_point() + theme_minimal() + ylab('MSE Loss')
```

![]({{ site.baseurl }}/images/Gradient-Descent_files/figure-markdown_github/unnamed-chunk-7-1.png)

Comparing to Stochastic Gradient Descent
----------------------------------------

Now it looks like we have converged and reached an optimal value.
However, the time it took was much longer. To wrap up, we were able to
determine a suitable ![m](https://latex.codecogs.com/png.latex?m "m")
and ![b](https://latex.codecogs.com/png.latex?b "b") to satisfy our
optimization problem. However, this algorithm can be slow if we are
working with large matrices. In that case, we can use *Stochastic
Gradient Descent* and use only a subset of the matrix with one sample at
a time for the optimization.

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
    ##   5.380   3.291   8.771

``` r
sgd_res$m
```

    ## [1] 1.96106

``` r
sgd_res$b
```

    ## [1] 0.02086175

``` r
cat('The predicted values are:', head(sgd_res$m * x + sgd_res$b))
```

    ## The predicted values are: 1.826538 0.8976887 0.7668216 0.8761367 0.4984383 0.6486479

``` r
cat('\nThe actual values are:', head(y))
```

    ## 
    ## The actual values are: 1.841531 0.8942376 0.7607719 0.8722576 0.4870595 0.6402517

As you can see, we nearly cut out run time in half by just using
stochastic gradient descent.

Additional Resources
--------------------

-   <https://towardsdatascience.com/gradient-descent-from-scratch-e8b75fa986cc>{:target="\_blank"}
-   <https://www.ocf.berkeley.edu/~janastas/stochastic-gradient-descent-in-r.html>{:target="\_blank"}
-   <https://www.r-bloggers.com/2017/02/implementing-the-gradient-descent-algorithm-in-r/>{:target="\_blank"}
