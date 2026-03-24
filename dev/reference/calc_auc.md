# Calculate Area Under Curve

Calculates the area under the curve (AUC).

## Usage

``` r
calc_auc(truth, predicted)

calc_emp_auc(truth, predicted, pos_class, ci95 = FALSE)

calc_pepe_auc(truth, predicted, pos_class)

calc_boot_auc(
  truth,
  predicted,
  pos_class,
  nboot = 1000,
  r_seed = sample(1000, 1)
)
```

## Arguments

- truth:

  `character(n)` or `factor(n)`. A vector of true class names. In most
  instances you will have to also pass a `pos_class` argument defining
  the positive/event class.

- predicted:

  `numeric(n)`. A numeric vector of class probabilities.

- pos_class:

  `character(1)`. Name of the "positive" or "event" class.

- ci95:

  `logical(1)`. Should DeLong's standard error based confidence limits
  be included with the AUC estimate?

- nboot:

  `integer(1)`. The number of bootstrap estimates to perform.

- r_seed:

  \`integer(1). The value of the random seed if reproducibility is
  desired.

## Value

All return a numeric scalar corresponding to the area under the curve.
For 95% confidence intervals (`ci95 = TRUE`), `calc_emp_auc()` returns a
`list` object with these elements:

- auc:

  The area under the curve (empirical).

- lower.limit:

  lower 95% confidence limit based on standard error AUC.

- upper.limit:

  upper 95% confidence limit based on standard error AUC.

A list containing bootstrap intervals based on the number of bootstraps
performed:

- auc:

  The raw Pepe AUC estimate from original data.

- lower.limit:

  The lower CI95 of the estimate.

- upper.limit:

  The upper CI95 of the estimate.

## Functions

- `calc_emp_auc()`: Calculate the *empirical* AUC, optionally with
  corresponding 95% confidence intervals according to the DeLong
  approach via the standard error of the AUC estimate. This empirical
  AUC estimate is calculated via the trapezoid area at each step along
  the x-axis of a ROC curve.

- `calc_pepe_auc()`: Calculate the AUC according to Margaret Pepe's
  book.

- `calc_boot_auc()`: Bootstrapped confidence intervals for the 95%
  limits are calculated via *empirical* bootstrap iterations and using
  Pepe's AUC calculation.

## Note

`calc_auc()` is designed specifically, and only (!), for binary 2-class
problems.

## References

DeLong et al. (1988) for the calculation of the Standard Error of the
Area Under the Curve (AUC) and of the difference between two AUCs.

`calc_pepe_auc()`: M. Pepe. The Statistical Evaluation of Medical Tests
for Classification and Prediction.

## See also

[`plot_emp_roc()`](https://stufield.github.io/libml/dev/reference/plot_emp_roc.md),
[`roc_xy()`](https://stufield.github.io/libml/dev/reference/roc_xy.md)

[`replicate()`](https://rdrr.io/r/base/lapply.html),
[`plot_emp_roc()`](https://stufield.github.io/libml/dev/reference/plot_emp_roc.md)

## Author

Stu Field

## Examples

``` r
n <- 20
withr::with_seed(22, {
  true <- sample(c("control", "disease"), n, replace = TRUE)
  pred <- runif(n)
})
calc_auc(true, pred)
#> [1] 0.5274725

# Empirical AUC
calc_emp_auc(true, pred, "disease")
#> [1] 0.4725275
calc_emp_auc(true, pred, "disease", ci95 = TRUE)  # with CI95
#> $auc
#> [1] 0.4725275
#> 
#> $lower.limit
#> [1] 0.1950289
#> 
#> $upper.limit
#> [1] 0.750026
#> 

# Pepe's AUC
calc_pepe_auc(true, pred, "disease")
#> [1] 0.4725275

# bootstrapped AUC
calc_boot_auc(true, pred, "disease")
#> $auc
#> [1] 0.4725275
#> 
#> $lower.limit
#> [1] 0.2186146
#> 
#> $upper.limit
#> [1] 0.75
#> 
calc_boot_auc(true, pred, "disease", nboot = 100, r_seed = 100)  # reproducible
#> $auc
#> [1] 0.4725275
#> 
#> $lower.limit
#> [1] 0.1752051
#> 
#> $upper.limit
#> [1] 0.7012083
#> 
```
