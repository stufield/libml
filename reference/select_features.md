# Select Model Features

Subsets a data frame to only the model predictor variables (columns),
aka the "model frame", for a given a *model*. Similar to
[`model.frame()`](https://rdrr.io/r/stats/model.frame.html), except a
*model* is passed rather than a *formula*.

## Usage

``` r
select_features(model, .data)
```

## Arguments

- model:

  A model with an S3
  [`get_model_features()`](https://stufield.github.io/helpr/reference/s3-generics.html)
  method. See description in
  [`helpr::get_model_features()`](https://stufield.github.io/helpr/reference/s3-generics.html).

- .data:

  A `data.frame`, typically containing a test data of samples to to
  subset down to the minimal set of features.

## Value

A `data.frame`-like object (depending on class of `.data`) subset to
only the variables/features contained in the `model`.

## Author

Stu Field

## Examples

``` r
# set up training and test data:
idx   <- sample.int(nrow(tr_iris), size = 90L)
train <- tr_iris[idx, ]
test  <- tibble::as_tibble(tr_iris[-idx, ])

lr <- fit_logistic(train)
select_features(lr, train)
#> ══ Training Data Object ═══════════════════════════════════════════════
#> • response        Species
#> • class labels    'setosa', 'virginica'
#> • counts          [50, 50]
#> • factor          TRUE
#> • n               2
#> ───────────────────────────────────────────────────────────────────────
#> # A tibble: 90 × 4
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>           <dbl>       <dbl>        <dbl>       <dbl>
#>  1         5.75        3.83        0.826     -0.570 
#>  2         7.08        3.73        6.54       3.07  
#>  3         5.23        3.14        1.23       1.08  
#>  4         6.73        3.01        4.13       2.89  
#>  5         7.76        1.73        7.75       1.93  
#>  6         4.93        3.81        1.97       0.955 
#>  7         4.78        3.09        1.61       1.02  
#>  8         4.99        3.35        1.06      -0.757 
#>  9         5.34        3.56        6.07       1.91  
#> 10         4.84        3.78        1.79       0.0803
#> # ℹ 80 more rows

select_features(lr, test)
#> # A tibble: 10 × 4
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>           <dbl>       <dbl>        <dbl>       <dbl>
#>  1         5.72        2.83         2.26      -0.248
#>  2         6.36        4.10         6.04       2.19 
#>  3         6.38        3.28         5.13       1.22 
#>  4         7.13        2.39         7.33       1.16 
#>  5         4.89        4.30         1.23      -0.730
#>  6         5.59        2.10         5.44       0.739
#>  7         6.25        3.62         4.50       1.87 
#>  8         6.72        2.64         4.92       0.933
#>  9         7.51        2.58         5.81       0.910
#> 10         6.95        3.68         5.84       1.71 

if (FALSE) { # \dontrun{
  select_features(lr, test[, -2L]) # throws error; missing feature
} # }

# Generalized Boosted Regression Model
gb <- fit_gbm(Species ~ ., data = train)
#> Distribution not specified, assuming bernoulli ...
select_features(gb, test)
#> # A tibble: 10 × 4
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>           <dbl>       <dbl>        <dbl>       <dbl>
#>  1         5.72        2.83         2.26      -0.248
#>  2         6.36        4.10         6.04       2.19 
#>  3         6.38        3.28         5.13       1.22 
#>  4         7.13        2.39         7.33       1.16 
#>  5         4.89        4.30         1.23      -0.730
#>  6         5.59        2.10         5.44       0.739
#>  7         6.25        3.62         4.50       1.87 
#>  8         6.72        2.64         4.92       0.933
#>  9         7.51        2.58         5.81       0.910
#> 10         6.95        3.68         5.84       1.71 

# Support Vector Machines
sm <- e1071::svm(Species ~ ., data = train, probability = TRUE)
select_features(sm, test)
#> # A tibble: 10 × 4
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>           <dbl>       <dbl>        <dbl>       <dbl>
#>  1         5.72        2.83         2.26      -0.248
#>  2         6.36        4.10         6.04       2.19 
#>  3         6.38        3.28         5.13       1.22 
#>  4         7.13        2.39         7.33       1.16 
#>  5         4.89        4.30         1.23      -0.730
#>  6         5.59        2.10         5.44       0.739
#>  7         6.25        3.62         4.50       1.87 
#>  8         6.72        2.64         4.92       0.933
#>  9         7.51        2.58         5.81       0.910
#> 10         6.95        3.68         5.84       1.71 

# KKNN
# note: test data passed during fitting
kknn <- fit_kknn(Species ~ ., train = train, test = test, k_neighbors = 10)
select_features(kknn, test)
#> # A tibble: 10 × 4
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>           <dbl>       <dbl>        <dbl>       <dbl>
#>  1         5.72        2.83         2.26      -0.248
#>  2         6.36        4.10         6.04       2.19 
#>  3         6.38        3.28         5.13       1.22 
#>  4         7.13        2.39         7.33       1.16 
#>  5         4.89        4.30         1.23      -0.730
#>  6         5.59        2.10         5.44       0.739
#>  7         6.25        3.62         4.50       1.87 
#>  8         6.72        2.64         4.92       0.933
#>  9         7.51        2.58         5.81       0.910
#> 10         6.95        3.68         5.84       1.71 
```
