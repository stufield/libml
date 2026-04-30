# Fit a Generalized Boosted Regression Model

A wrapper for fitting boosted binary regression models for binary
classification problems. Assumes a binary "Response" in `[0, 1]`.

## Usage

``` r
fit_gbm(x, ...)

# Default S3 method
fit_gbm(x, y, ...)

# S3 method for class 'formula'
fit_gbm(formula, data, ...)
```

## Arguments

- x:

  A `data.frame` containing feature data (predictors). If using the
  `formula` method, a "Response" column should be included. The simplest
  way to achieve this is a call to
  [`create_train()`](https://stufield.github.io/libml/reference/create_train.md).

- ...:

  Arguments passed to
  [`gbm::gbm()`](https://rdrr.io/pkg/gbm/man/gbm.html).

- y:

  `factor(n)`. If not passing a formula, a factor with true class names
  for each sample (row) in `x`.

- formula:

  A model formula of the form: \\class ~ x1 + x2 + ...+ xn\`\\, (no
  interactions).

- data:

  A data frame of predictors (categorical and/or numeric).

## Value

A `gbm` class object, as returned by
[`gbm::gbm()`](https://rdrr.io/pkg/gbm/man/gbm.html).

## Methods (by class)

- `fit_gbm(default)`: The S3 default method for `fit_gbm`.

- `fit_gbm(formula)`: The S3 formula method for `fit_gbm`.

## See also

[`gbm::gbm()`](https://rdrr.io/pkg/gbm/man/gbm.html),
[`create_train()`](https://stufield.github.io/libml/reference/create_train.md)

The `fit*()` family:
[`fit_kknn()`](https://stufield.github.io/libml/reference/fit_kknn.md),
[`fit_logistic()`](https://stufield.github.io/libml/reference/fit_logistic.md),
[`fit_nb()`](https://stufield.github.io/libml/reference/fit_nb.md)

## Author

Stu Field

## Examples

``` r
# formula method
model <- withr::with_seed(10, fit_gbm(Species ~ ., data = tr_iris))
#> Distribution not specified, assuming bernoulli ...

# data frame method
model <- withr::with_seed(10, fit_gbm(tr_iris[, -5L], y = tr_iris$Species))
#> Distribution not specified, assuming bernoulli ...
```
