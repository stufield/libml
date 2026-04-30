# Fit Multivariate Logistic Regression Model

A wrapper around [`glm()`](https://rdrr.io/r/stats/glm.html) for fitting
multivariate logistic regression models for binary classification
problems.

## Usage

``` r
fit_logistic(x, ..., strip)

# S3 method for class 'formula'
fit_logistic(formula, ..., strip = FALSE)

# S3 method for class 'data.frame'
fit_logistic(x, y = NULL, strip = FALSE, ...)

# S3 method for class 'tr_data'
fit_logistic(x, ..., strip = FALSE)

# S3 method for class 'matrix'
fit_logistic(x, y, strip = FALSE, ...)
```

## Arguments

- strip:

  `logical(1)`. Should certain entries of the model object be stripped
  via
  [`stripLMC()`](https://stufield.github.io/libml/reference/stripLMC.md)
  to reduce object size? If true, some downstream functionality is
  compromised, e.g. [`summary()`](https://rdrr.io/r/base/summary.html)
  and [`residuals()`](https://rdrr.io/r/stats/residuals.html), however
  when iterating over 1000s of models this may be an acceptable
  trade-off to limit runaway memory consumption.

- formula, x, ...:

  Either a formula, data frame, or matrix. If a `formula` (preferred)
  should be a model of the form: \\class ~ x_1 + x_2 + ... + x_n\\. If a
  data frame (preferably a `tr_data` object), containing features or
  predictors. If a matrix object containing ONLY predictors, in which
  case `y` *must* be passed (see examples below). Unmatched arguments
  eventually be passed to [`glm()`](https://rdrr.io/r/stats/glm.html)
  via the `...`.

- y:

  Can be one of *two* options:

  character

  :   A `character(1)` indicating the column in `x` containing the true
      class names.

  vector

  :   A vector `factor(n)` of true class names for each sample (row) in
      `x`.

## Value

A `glm` model object as returned by
[`glm()`](https://rdrr.io/r/stats/glm.html), logistic regression model.

## Methods (by class)

- `fit_logistic(formula)`: S3 formula method for `fit`.

- `fit_logistic(data.frame)`: S3 `data.frame` method for `fit_logistic`.

- `fit_logistic(tr_data)`: S3 `tr_data` method for `fit_logistic`.

- `fit_logistic(matrix)`: S3 matrix method for `fit_logistic`.

## See also

[`glm()`](https://rdrr.io/r/stats/glm.html)

The `fit*()` family:
[`fit_gbm()`](https://stufield.github.io/libml/reference/fit_gbm.md),
[`fit_kknn()`](https://stufield.github.io/libml/reference/fit_kknn.md),
[`fit_nb()`](https://stufield.github.io/libml/reference/fit_nb.md)

## Author

Stu Field

## Examples

``` r
# formula S3 method
# This is the preferred syntax
class(tr_iris)
#> [1] "tr_data"    "tbl_df"     "tbl"        "data.frame"

df <- tibble::as_tibble(tr_iris)  # strip tr_data class

# tr_data S3 method:
model <- fit_logistic(tr_iris)

# data frame S3 method:
model <- fit_logistic(df, "Species")

# formula S3 method:
model <- fit_logistic(Species ~ ., data = df)

# data frame S3 method (2):
model <- fit_logistic(df[, -5L], y = df$Species)  # vector of class names

# matrix S3 method:
model <- fit_logistic(as.matrix(df[, -5L]), y = df$Species)  # 'glmnet' syntax
```
