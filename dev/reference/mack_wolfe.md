# Mack-Wolfe Test

Calculates the Mack-Wolfe test on a single vector of numeric data. The
Jonckheere-Terpstra (JT) test or Jonckheere trend test is a special case
of the Mack-Wolfe where the peak is set to one of the ends.

## Usage

``` r
mack_wolfe(x, ...)

# S3 method for class 'formula'
mack_wolfe(formula, data, ...)

# S3 method for class 'numeric'
mack_wolfe(
  x,
  group,
  peak = "jt",
  rm_outliers = FALSE,
  alpha = 0.05,
  nperm = NULL,
  ...
)
```

## Arguments

- x:

  `numeric(n)`. A numeric *vector* of values. If empty of parameters
  (see examples), the example from Hollander & Wolfe is computed.

- ...:

  Additional arguments passed to downstream S3 methods.

- formula:

  A formula specifying the `lhs` and `rhs`.

- data:

  A `data.frame` containing variables in the `formula`.

- group:

  `factor(n)`. A vector of groupings matched to `x`. The factor levels
  are used as the grouping information.

- peak:

  `character(1)`. A string corresponding to the desired peak factor
  level. If `peak = "jt"` (default) a JT-test is performed. If
  `peak = NULL`, the "peak unknown" version of the Mack-Wolfe test is
  performed.

- rm_outliers:

  `logical(1)`. Should statistical outliers (\\6 \* mad\\ *and* \\5x\\)
  be removed? See
  [`wranglr::remove_outliers()`](https://stufield.github.io/wranglr/reference/remove_outliers.html).

- alpha:

  `numeric(1)`. The desired significance level.

- nperm:

  `integer(1)`. The number of Monte-Carlo simulations to perform. If
  `NULL`, a p-value approximation is used (if `length(x) > 10`).

## Value

Returns a `mack_wolfe` class object:

- Ap::

  The Mack-Wolfe test statistic (if peak known)

- Astar::

  The Normal approximation of the test statistic

- p_value::

  The **two-sided** p-value associated with the Normal approximation
  ([`pnorm()`](https://rdrr.io/r/stats/Normal.html))

- Acrit::

  The critical value for the z-distribution at the requested
  significance level (`alpha`)

- alpha::

  The significance level at which the critical value was evaluated

- peak::

  The peak as determined by test statistic

- groups::

  The factor levels of supplied `group` parameter.

## References

Myles Hollander and Douglas A. Wolfe (1973). *Nonparametric Statistical
Methods*. New York: John Wiley & Sons. Pages 115-120, 215.

## Author

Stu Field, Michael Mehan

## Examples

``` r
x <- c(36.0, 33.6, 26.9, 35.8, 30.1, 31.2, 35.3,   # g1
       39.9, 29.1, 43.4,                           # g2
       44.6, 54.4, 48.2, 55.7, 50,                 # g3
       53.8, 53.9, 62.5, 46.6,                     # g4
       44.3, 34.1, 35.7, 35.6,                     # g5
       31.7, 22.1, 30.7)                           # g6
months <- c(g1 = "Jan-Feb",
            g2 = "Mar-Apr",
            g3 = "May-Jun",
            g4 = "Jul-Aug",
            g5 = "Sep-Oct",
            g6 = "Nov-Dec")
group  <- rep(months, c(7, 3, 5, 4, 4, 3))
group  <- factor(group, months)
peak   <- "Jul-Aug"

mack_wolfe(x, group, peak)
#> ══ Mack-Wolfe test for umbrella alternatives (peak known) ═════════════
#> 
#> • Ap       = '157'
#> • Ap*      = '4.1848'
#> • n        = '26'
#> • p_value  = '0.000028539'
#> • Acrit    = '1.6449'
#> • alpha    = '0.05'
#> • groups   = 'Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'
#> • peak     = 'Jul-Aug | k = 4'
#> 
#> ═══════════════════════════════════════════════════════════════════════

# run example from text (same as above)
mack_wolfe()
#> ══ Mack-Wolfe test for umbrella alternatives (peak known) ═════════════
#> 
#> • Ap       = '157'
#> • Ap*      = '4.1848'
#> • n        = '26'
#> • p_value  = '0.000028539'
#> • Acrit    = '1.6449'
#> • alpha    = '0.05'
#> • groups   = 'Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'
#> • peak     = 'Jul-Aug | k = 4'
#> 
#> ═══════════════════════════════════════════════════════════════════════

# use Monte-Carlo permutation to estimate p-value
mack_wolfe(NA, nperm = 100L)
#> ℹ Performing Monte-Carlo permutation estimate of p-value.
#> ══ Mack-Wolfe test for umbrella alternatives (peak known) ═════════════
#> 
#> • Ap       = '157'
#> • Ap*      = '4.1848'
#> • n        = '26'
#> • p_value  = '0'
#> • Acrit    = '1.6449'
#> • alpha    = '0.05'
#> • groups   = 'Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'
#> • peak     = 'Jul-Aug | k = 4'
#> 
#> ═══════════════════════════════════════════════════════════════════════

# S3 formula method
df <- data.frame(var = x, gr = group)
mack_wolfe(var ~ gr, data = df, peak = peak)
#> ══ Mack-Wolfe test for umbrella alternatives (peak known) ═════════════
#> 
#> • Ap       = '157'
#> • Ap*      = '4.1848'
#> • n        = '26'
#> • p_value  = '0.000028539'
#> • Acrit    = '1.6449'
#> • alpha    = '0.05'
#> • groups   = 'Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'
#> • peak     = 'Jul-Aug | k = 4'
#> 
#> ═══════════════════════════════════════════════════════════════════════
```
