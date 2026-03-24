# Calculate Binomial Confidence Interval

Calculates the *joint* binomial confidence interval based on the
binomial variance given the data. Uses normal approximation of the
binomial.

## Usage

``` r
calc_ci_binom(p, n, ci = sqrt(0.95))
```

## Arguments

- p:

  `numeric(1)`. The classification metric in `[0, 1]`. Can also be a
  vector of values representing the metric of interest (sens or spec).

- n:

  `integer(1)`. The total number of counts in the denominator for the
  metric being calculated.

- ci:

  `numeric(1)`. The width of the confidence interval to be calculated.
  Must be in `[0.5, 1]`.

## Value

A `tibble` object of the upper and lower binomial confidence limits
corresponding to the value of `ci`.

## References

The Statistical Evaluation of Medical Tests for Classification and
Prediction. 2004. Margaret Pepe, Altman, DG, Bland, JM. 1994.
"Diagnostic tests 1: sensitivity and specificity", British Medical
Journal, vol 308, 1552. (I think?).

## See also

[`qnorm()`](https://rdrr.io/r/stats/Normal.html)

## Author

Stu Field

## Examples

``` r
tp <- 16
fn <- 4
sens <- tp / (tp + fn)
calc_ci_binom(sens, tp + fn)
#> # A tibble: 1 × 2
#>   lower upper
#>   <dbl> <dbl>
#> 1 0.600     1
```
