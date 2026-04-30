# Get Distance Cutoffs

For given true class names and predictions, calculate the maximal
perpendicular distance to the unit line, its corresponding specificity,
then the cutoff corresponding to that specificity.

For a given specificity, calculate the corresponding cutoff (operating
point) from a set of predictions.

## Usage

``` r
get_max_cutoff(truth, predicted, pos_class)

get_spec_cutoff(truth, predicted, spec, pos_class)
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

- spec:

  `numeric(1)`. The desired specificity.

## Value

`get_max_cutoff()`: a numeric cutoff representing the operating point at
the maximal perpendicular distance from the unit line.

`get_spec_cutoff()`: a numeric cutoff representing the operating point
for a given specificity.

## See also

[`calc_roc_perpendicular()`](https://stufield.github.io/libml/reference/create_roc_data.md),
[`roc_xy()`](https://stufield.github.io/libml/reference/roc_xy.md)

## Author

Stu Field

## Examples

``` r
n <- 20
withr::with_seed(122, {
  true <- sample(c("control", "disease"), n, replace = TRUE)
  pred <- runif(n)
})
get_max_cutoff(true, pred, "disease")
#> [1] 0.763952

# via specificity
get_spec_cutoff(true, pred, 0.4, "disease")
#> [1] 0.5366686
```
