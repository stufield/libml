# Strip Linear Model Components

Strips linear model (`"lm"` or `"glm"`) object components down the bare
essentials to reduce size. Used typically when building thousands of
models, e.g. during cross-validation to manage memory.

## Usage

``` r
stripLMC(x)
```

## Arguments

- x:

  A model object, either `lm` or `glm` class.

## Value

A stripped down (size) `"lm"` or `"glm"` object. For `"lm"` class,
removes or sets -\> 0 these elements: - `model` - `fitted` - `assign` -
`effects` - `xlevels` For `"glm"` class, removes or sets to `0` these
elements: - `linear.predictors` - `terms` - `formula` - `family`
(`family`, `link`, `linkfun`, and `linkinv` remain)

## See also

[`glm()`](https://rdrr.io/r/stats/glm.html),
[`lm()`](https://rdrr.io/r/stats/lm.html),
[`summary()`](https://rdrr.io/r/base/summary.html),
[`residuals()`](https://rdrr.io/r/stats/residuals.html)

## Author

Stu Field

## Examples

``` r
fat_lm <- function() {
  junk <- runif(1e5)
  stats::lm(vs ~ ., data = mtcars)
}
fat_glm <- function() {
  junk <- runif(1e5)   # excessive junk in envir
  stats::glm(vs ~ wt + disp, data = mtcars, family = "binomial")
}

# LM
lobstr::obj_size(fat_lm())
#> 823 kB
lobstr::obj_size(stripLMC(fat_lm()))
#> 17.94 kB

# GLM
lobstr::obj_size(fat_glm())
#> 883.91 kB
lobstr::obj_size(stripLMC(fat_glm()))
#> 37.74 kB
```
