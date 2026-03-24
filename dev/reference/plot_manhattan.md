# Create Manhattan Plot

Creates a Manhattan plot of the differences or log-ratios of the
training set for each feature.

## Usage

``` r
plot_manhattan(
  data,
  x.lab = "Feature",
  type = c("t.test", "log2fc", "ks.test"),
  as_pvalue = FALSE
)
```

## Arguments

- data:

  A training data `tr_data` object.

- x.lab:

  `character(1)`. Set the x-axis label.

- type:

  `character(1)`. The type measure used to evaluate expression change.
  One of: "log2fc", "t.test", or "ks.test". Pattern is matched.

- as_pvalue:

  `logical(1)`. Should p-values be plotted in linear space or
  log10-space?

## Author

Stu Field

## Examples

``` r
tr <- create_train(simdata,
                   class_response %in% c("control", "disease"),
                   group_var = class_response,
                   classes = c("control", "disease"))

# Various options for plotting
plot_manhattan(tr, type = "t")

plot_manhattan(tr, type = "log2")

plot_manhattan(tr, type = "ks")

plot_manhattan(tr, type = "t", as_pvalue = TRUE)
```
