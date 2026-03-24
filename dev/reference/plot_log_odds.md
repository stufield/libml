# Create a Log-Odds Plot

Plot the log-odds, \$\$log(Prob / (1 - Prob))\$\$ for each sample. See
`Section` for note about extreme probabilities.

## Usage

``` r
plot_log_odds(
  truth,
  predicted,
  pos_class,
  cutoff = 0.5,
  y_lab = NULL,
  max_prob = NULL,
  scramble = FALSE
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

- cutoff:

  `numeric(1)`. A cutoff for the decision/operating point, predictions
  above which are considered the *positive* class.

- y_lab:

  `character(1)`. Optional label for the y-axis.

- max_prob:

  `numeric(1)`. Experimental. Maximum probability value cutoff for the
  log-odds plot. Removes extreme samples from the plot to avoid
  distorting x-axis.

- scramble:

  `logical(1)`. Should values be randomized to avoid monotonically
  decreasing probability scores (aesthetic)?

## Extreme probabilities

extreme values in `[0, 1]` are thresholded at `.Machine$double.eps^0.5`,
or `[1.490116119e-08, 0.9999999851]` to restrict the x-axis and avoid
`Inf` values in log-odds space (`0/1`).

## Author

Stu Field

## Examples

``` r
n <- 20
withr::with_seed(22, {
  true <- sample(c("control", "disease"), n, replace = TRUE)
  pred <- runif(n)
})
plot_log_odds(true, pred, "disease")

plot_log_odds(true, pred, "disease", scramble = TRUE)
```
