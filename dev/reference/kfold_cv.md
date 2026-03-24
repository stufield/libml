# Calculate k-Fold Cross-Validation

Perform *k*-fold internal cross-validation on a `tr_data` class object.

## Usage

``` r
kfold_cv(
  data,
  k,
  kknn_args = list(k_neighbors = 9L),
  model_type = c("lr", "nb", "rf", "svm", "kknn", "gbm"),
  ...
)
```

## Arguments

- data:

  A training data set, for convenience should be created via
  [`create_train()`](https://stufield.github.io/libml/dev/reference/create_train.md),
  but *must* contain only the features to be used in fitting the model
  and `"Response"` column.

- k:

  `integer(1)`. The number of folds to perform (*k*-fold
  cross-validation). Passed to
  [`wranglr::create_kfold()`](https://stufield.github.io/wranglr/reference/create_kfold.html).

- kknn_args:

  Additional arguments as a pass-through to
  [`fit_kknn()`](https://stufield.github.io/libml/dev/reference/fit_kknn.md),
  since the `...` is already used. Ignored unless `type = "kknn"`.

- model_type:

  Which type of model to run.

- ...:

  Additional arguments passed to
  [`wranglr::create_kfold()`](https://stufield.github.io/wranglr/reference/create_kfold.html).

## Value

A `tibble` containing model predictions, true class names, and the fold
of the samples used to make the prediction. There should be a "test"
prediction for each sample in `data`.

## See also

[`fit_nb()`](https://stufield.github.io/libml/dev/reference/fit_nb.md),
[`fit_kknn()`](https://stufield.github.io/libml/dev/reference/fit_kknn.md)

[`randomForest::randomForest()`](https://rdrr.io/pkg/randomForest/man/randomForest.html),
[`fit_gbm()`](https://stufield.github.io/libml/dev/reference/fit_gbm.md),
[`fit_logistic()`](https://stufield.github.io/libml/dev/reference/fit_logistic.md)

## Author

Stu Field

## Examples

``` r
# naive Bayes
# Use fake training data from iris data set
k10_nb <- kfold_cv(tr_iris, k = 10L, model_type = "nb")
k10_nb
#> # A tibble: 100 × 3
#>    truth     predicted  fold
#>    <fct>         <dbl> <int>
#>  1 virginica   0.999       1
#>  2 setosa      0.00425     1
#>  3 setosa      0.00162     1
#>  4 setosa      0.00166     1
#>  5 virginica   0.996       1
#>  6 setosa      0.00183     1
#>  7 setosa      0.0198      1
#>  8 setosa      0.999       1
#>  9 virginica   0.999       1
#> 10 setosa      0.0608      1
#> # ℹ 90 more rows

# Boosted Regression Model
k10_b <- kfold_cv(tr_iris, k = 10L, model_type = "gbm")
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
#> Distribution not specified, assuming bernoulli ...
k10_b
#> # A tibble: 100 × 3
#>    truth     predicted  fold
#>    <fct>         <dbl> <int>
#>  1 setosa        0.346     1
#>  2 virginica     0.347     1
#>  3 virginica     0.731     1
#>  4 setosa        0.291     1
#>  5 setosa        0.644     1
#>  6 virginica     0.680     1
#>  7 virginica     0.673     1
#>  8 virginica     0.842     1
#>  9 virginica     0.640     1
#> 10 setosa        0.553     1
#> # ℹ 90 more rows

# Weighted K-Nearest-Neighbor
# Pass k_neighbors = 9 for number of neighbors in hood
k10_knn <- kfold_cv(tr_iris, k = 10L, model_type = "kknn")
k10_knn
#> # A tibble: 100 × 3
#>    truth     predicted  fold
#>    <fct>         <dbl> <int>
#>  1 virginica    0.574      1
#>  2 virginica    0.184      1
#>  3 virginica    0.548      1
#>  4 setosa       0.0420     1
#>  5 virginica    0.453      1
#>  6 setosa       0.168      1
#>  7 virginica    0.456      1
#>  8 setosa       0.299      1
#>  9 virginica    0.910      1
#> 10 setosa       0.592      1
#> # ℹ 90 more rows

# Random Forest
k10_rf <- kfold_cv(tr_iris, k = 10L, model_type = "rf")
k10_rf
#> # A tibble: 100 × 3
#>    truth     predicted  fold
#>    <fct>         <dbl> <int>
#>  1 setosa        0.53      1
#>  2 virginica     0.166     1
#>  3 setosa        0.638     1
#>  4 setosa        0.44      1
#>  5 virginica     0.754     1
#>  6 virginica     0.67      1
#>  7 setosa        0.18      1
#>  8 setosa        0.286     1
#>  9 virginica     0.536     1
#> 10 setosa        0.242     1
#> # ℹ 90 more rows
```
