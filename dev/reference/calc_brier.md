# Calculate the Brier Score

Calculates the Brier Score, i.e. MSE of probabilities in `[0, 1]` of a
vector of probabilities. The brier score attempts to account for not
only wither a prediction correctly predicts a class label at some
arbitrary evaluation cutoff, but also *how close* the prediction is to
predicting the label, i.e. distinguishing between \\p = 0.51\\ and \\p =
0.99\\, despite both predicting a positive class label.

## Usage

``` r
calc_brier(x, p)
```

## Arguments

- x:

  `numeric(n)`. A vector of binary class data representing the true
  classes. Must be all 0 or 1 or numeric coercible.

- p:

  `numeric(n)`. A vector of the predicted probabilities, i.e. in
  `[0, 1]`.

## Value

The Brier Score, a value in `[0, 1]`, representing the error in
predictions, `0` being best possible score.

## References

<https://en.wikipedia.org/wiki/Brier_score>

## Author

Stu Field

## Examples

``` r
withr::with_seed(1, {
  n <- 100L
  p <- runif(n)
  x <- sample(0:1, n, replace = TRUE)
})
calc_brier(x, p)
#> [1] 0.3005455
```
