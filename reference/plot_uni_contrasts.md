# Contrast 2 Univariate Tables

Compare 2 `univariate` tables from any two analyses from the
[`calc_univariate()`](https://stufield.github.io/libml/reference/calc_univariate.md)
function.

## Usage

``` r
plot_uni_contrasts(
  x,
  y,
  cutoff = 0.05/nrow(x),
  ident = FALSE,
  label_size = 2.5
)
```

## Arguments

- x:

  The first univariate tibble to contrast (x-axis).

- y:

  The second univariate tibble to contrast (y-axis).

- cutoff:

  `numeric(1)`. A `p-value` cutoff for comparison of tables.

- ident:

  `logical(1)`. Should the points beyond the cutoff be identified?

- label_size:

  `numeric(1)`. The size for the labels if `ident = TRUE`.

## Value

A `ggplot` object.

## Author

Stu Field

## Examples

``` r
a <- calc_univariate(mtcars, var = "vs")
b <- calc_univariate(mtcars, var = "mpg", "lm")
plot_uni_contrasts(a, b, ident = TRUE, cutoff = 0.005)
```
