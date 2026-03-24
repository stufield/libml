# Calculate Model Predictions

Calculate the test set predictions of a given model and test set.

- For the `randomForest` model, if `newdata = NULL` (default), the
  out-of-bag sample predictions are returned, thus no test data are
  required.

- For KKNN models, the test set predictions are maintained with the
  model itself, thus you should *not* pass `test`.

- For `randomForest` and `gbm` models, there are out-of-bag samples that
  are used for predictions if `newdata = NULL`.

## Usage

``` r
# S3 method for class 'libml_nb'
calc_predictions(model, newdata, cutoff = 0.5, ...)

# S3 method for class 'naiveBayes'
calc_predictions(model, newdata, cutoff = 0.5, ...)

# S3 method for class 'randomForest'
calc_predictions(model, newdata = NULL, cutoff = 0.5, ...)

# S3 method for class 'gbm'
calc_predictions(model, newdata, cutoff = 0.5, ...)

# S3 method for class 'svm'
calc_predictions(model, newdata, cutoff = 0.5, ...)

# S3 method for class 'glm'
calc_predictions(model, newdata, cutoff = 0.5, ...)

# S3 method for class 'kknn'
calc_predictions(model, newdata = NULL, cutoff = 0.5, ...)
```

## Arguments

- model:

  A model object. Currently one of:

  - `glm` (for logistic regression)

  - `libml_nb`

  - `naiveBayes`

  - `randomForest`

  - `svm`

  - `gbm`

  - `kknn`

- newdata:

  The test set (`data.frame`) containing (features) corresponding to the
  model parameters. For some models, if `newdata = NULL`, training (or
  out-of-bag) predictions are returned.

- cutoff:

  `numeric(1)`. A cutoff for the decision/operating point, predictions
  above which are considered the *positive* class.

- ...:

  Used for extensibility of downstream S3 methods.

## Value

A `data.frame` with predicted class and class probabilities for each row
in `newdata`:

- `pred_class`:

  predicted class for each new observation. If there are more than two
  classes, the class with the *highest* predicted probability.
  Otherwise, class predictions are returned based on the value of
  `cutoff`.

- `prob_*`:

  probability of belonging to class `*` for each new observation.

- `pred_linear`:

  for linear models, the linear predictor for each new observation.

## Functions

- `calc_predictions(libml_nb)`: S3 method for "robust" Naive Bayes
  models.

- `calc_predictions(naiveBayes)`: S3 method for Naive Bayes models.

- `calc_predictions(randomForest)`: S3 method for Random Forest models.

- `calc_predictions(gbm)`: S3 method for Gradient Boosted Tree models.

- `calc_predictions(svm)`: S3 method for Support Vector Machines.

- `calc_predictions(glm)`: S3 method for Logistic Regression via `glm`.

- `calc_predictions(kknn)`: S3 method for Weighted k-Nearest Neighbor.
  kknn models have self-contained test predictions, so `newdata` can be
  `NULL` to return those predictions. If *actual* `newdata` is desired,
  must re-fit using original data and pull test predictions. This is
  built-in for
  [`fit_kknn()`](https://stufield.github.io/libml/dev/reference/fit_kknn.md)
  objects, so the standard syntax is possible.

## See also

[`fit_nb()`](https://stufield.github.io/libml/dev/reference/fit_nb.md),
[`randomForest::randomForest()`](https://rdrr.io/pkg/randomForest/man/randomForest.html),
[`fit_logistic()`](https://stufield.github.io/libml/dev/reference/fit_logistic.md),
[`fit_kknn()`](https://stufield.github.io/libml/dev/reference/fit_kknn.md)

## Author

Stu Field

## Examples

``` r
# Use training data from iris data set:
train <- head(tr_iris, -3L)
test  <- tibble::as_tibble(tail(tr_iris, 3L))

# Logistic Regression
lr <- fit_logistic(Species ~ ., data = train)
calc_predictions(lr, test)
#> # A tibble: 3 × 4
#>   pred_class pred_linear prob_setosa prob_virginica
#>   <chr>            <dbl>       <dbl>          <dbl>
#> 1 virginica        1.78        0.144          0.856
#> 2 setosa          -0.609       0.648          0.352
#> 3 setosa          -1.27        0.781          0.219
calc_predictions(lr, test, cutoff = 0.33)
#> # A tibble: 3 × 4
#>   pred_class pred_linear prob_setosa prob_virginica
#>   <chr>            <dbl>       <dbl>          <dbl>
#> 1 virginica        1.78        0.144          0.856
#> 2 virginica       -0.609       0.648          0.352
#> 3 setosa          -1.27        0.781          0.219

# Naive Bayes
nb <- fit_nb(Species ~ ., data = train)
calc_predictions(nb, test)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica    0.0000294      1.000    
#> 2 setosa       0.983          0.0166   
#> 3 setosa       1.000          0.0000550
calc_predictions(nb, test, cutoff = 0.01)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica    0.0000294      1.000    
#> 2 virginica    0.983          0.0166   
#> 3 setosa       1.000          0.0000550

# Random Forest
rf <- withr::with_seed(101, {
  randomForest::randomForest(Species ~ ., data = train,
                             importance = TRUE, proximity = TRUE,
                             keep.inbag = TRUE)
})
head(calc_predictions(rf))        # out-of-bag
#>   pred_class prob_setosa prob_virginica
#> 1     setosa  0.88823529      0.1117647
#> 2  virginica  0.31188119      0.6881188
#> 3  virginica  0.13372093      0.8662791
#> 4  virginica  0.05405405      0.9459459
#> 5  virginica  0.47120419      0.5287958
#> 6     setosa  0.78974359      0.2102564
calc_predictions(rf, test)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.292          0.708
#> 2 setosa           0.616          0.384
#> 3 setosa           0.844          0.156
calc_predictions(rf, test, cutoff = 0.39)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.292          0.708
#> 2 setosa           0.616          0.384
#> 3 setosa           0.844          0.156

# Generalized Boosted Regression Model
gb <- fit_gbm(Species ~ ., data = train)
#> Distribution not specified, assuming bernoulli ...
calc_predictions(gb, test)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.283          0.717
#> 2 setosa           0.555          0.445
#> 3 setosa           0.842          0.158
calc_predictions(gb, test, 0.48)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.283          0.717
#> 2 setosa           0.555          0.445
#> 3 setosa           0.842          0.158

# Support Vector Machines
sm <- e1071::svm(Species ~ ., data = train, probability = TRUE)
calc_predictions(sm, test)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.197          0.803
#> 2 setosa           0.640          0.360
#> 3 setosa           0.742          0.258
calc_predictions(sm, test, 0.35)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.197          0.803
#> 2 virginica        0.640          0.360
#> 3 setosa           0.742          0.258

# KKNN
# test data passed during fitting:
kknn <- fit_kknn(Species ~ ., train = train, test = test, k_neighbors = 10)
calc_predictions(kknn)                 # do NOT pass test data
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.236          0.764
#> 2 setosa           0.750          0.250
#> 3 setosa           0.516          0.484
calc_predictions(kknn, cutoff = 0.48)
#> # A tibble: 3 × 3
#>   pred_class prob_setosa prob_virginica
#>   <chr>            <dbl>          <dbl>
#> 1 virginica        0.236          0.764
#> 2 setosa           0.750          0.250
#> 3 virginica        0.516          0.484
```
