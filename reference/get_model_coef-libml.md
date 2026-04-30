# Get Coefficients of a Model

Extract the coefficients for an arbitrary model.

## Usage

``` r
# S3 method for class 'glm'
get_model_coef(model, ...)

# S3 method for class 'lm'
get_model_coef(model, ...)

# S3 method for class 'lda'
get_model_coef(model, ...)

# S3 method for class 'libml_nb'
get_model_coef(model, ...)

# S3 method for class 'naiveBayes'
get_model_coef(model, ...)

# S3 method for class 'kknn'
get_model_coef(model, ...)

# S3 method for class 'randomForest'
get_model_coef(model, ...)

# S3 method for class 'gbm'
get_model_coef(model, ...)

# S3 method for class 'glmnet'
get_model_coef(model, lambda = NULL, ...)

# S3 method for class 'cv.glmnet'
get_model_coef(model, lambda = NULL, ...)

# S3 method for class 'train'
get_model_coef(model, lambda = NULL, ...)

# S3 method for class 'svm'
get_model_coef(model, ...)
```

## Arguments

- model:

  A model object, currently one of:

      #>  [1] get_model_coef.cv.glmnet
      #>  [2] get_model_coef.default*
      #>  [3] get_model_coef.gbm
      #>  [4] get_model_coef.glm
      #>  [5] get_model_coef.glmnet
      #>  [6] get_model_coef.kknn
      #>  [7] get_model_coef.lda
      #>  [8] get_model_coef.libml_nb
      #>  [9] get_model_coef.lm
      #> [10] get_model_coef.naiveBayes
      #> [11] get_model_coef.randomForest
      #> [12] get_model_coef.svm
      #> [13] get_model_coef.train
      #> see '?methods' for accessing help and source code

- ...:

  Additional parameters for extensibility.

- lambda:

  The value of the penalty parameter `lambda` which can either be `NULL`
  or `numeric`. If `NULL`, the default value depends on the underlying
  class:

  `glmnet`

  :   The first value of lambda.

  `cv.glmnet`

  :   The lambda where the cross validated error is minimized.

  `train`

  :   The optimal value of lambda. When given a numeric value of
      `lambda`, the closest value of `lambda` within the model will be
      used.

## Value

A named numeric vector of the coefficients of the model. If the model is
non-linear (e.g. random forest), `NULL`.

## Functions

- `get_model_coef(glm)`: S3 method for `glm` models.

- `get_model_coef(lm)`: S3 method for `lm` models.

- `get_model_coef(lda)`: S3 method for `lda` models.

- `get_model_coef(libml_nb)`: S3 method for `libml_nb` models.

- `get_model_coef(naiveBayes)`: S3 method for `naiveBayes` models.

- `get_model_coef(kknn)`: S3 method for `kknn` models.

- `get_model_coef(randomForest)`: S3 method for `randomForest` models.

- `get_model_coef(gbm)`: S3 method for `gbm` models.

- `get_model_coef(glmnet)`: S3 method for `glmnet` models.

- `get_model_coef(cv.glmnet)`: S3 method for `cv.glmnet` models.

- `get_model_coef(train)`: S3 method for `train` models.

- `get_model_coef(svm)`: S3 method for SVM models. If the model
  `kernel = linear`, coefficients are returned. Otherwise, `NULL`.

## See also

[`coef()`](https://rdrr.io/r/stats/coef.html)

## Examples

``` r
# set up training and test data:
iris2 <- droplevels(iris[iris$Species != "setosa", ])

# Logistic Regression
stats::glm(Species ~ ., data = iris2, family = "binomial") |>
  get_model_coef()
#>  (Intercept) Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>   -42.637804    -2.465220    -6.680887     9.429385    18.286137 
```
