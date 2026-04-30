# Pull a Classification Performance Metric/Statistic

Indexes into the S3 summary method for `confusion_matrix` class object.

## Usage

``` r
pull_stat(
  x,
  which = c("Sensitivity", "Recall", "Specificity", "Precision", "PPV", "NPV",
    "Accuracy", "MCC", "AUC", "Brier", "Error", "F_measure", "G_mean", "Wt_Acc")
)
```

## Arguments

- x:

  A `summary_confusion_matrix` class object, from a call to
  `summary(calc_confusion(...))`.

- which:

  `character(1)`. Matched string for the test desired statistic.

## Value

`double(1)`. The classification performance statistic.

## Details

Optional statistics are restricted to the output of the summary method.
One of:  

- "Sensitivity"

- "Recall"

- "Specificity"

- "Precision"

- "PPV"

- "NPV"

- "Accuracy"

- "Error"

- "F_measure"

- "G_mean"

- "Wt_Acc"

## See also

[`calc_confusion()`](https://stufield.github.io/libml/reference/calc_confusion.md)

## Author

Stu Field

## Examples

``` r
n <- 20
withr::with_seed(22, {
  true  <- sample(c("control", "disease"), n, replace = TRUE)
  pred  <- runif(n)
})

# Summary of confusion matrix
c_mat <- calc_confusion(true, pred, pos_class = "disease") |> summary()
class(c_mat)
#> [1] "summary_confusion_matrix" "list"                    

# pull out elements
pull_stat(c_mat, "Spec")
#> [1] 0.5714286
pull_stat(c_mat, "Sens")
#> [1] 0.4615385
pull_stat(c_mat, "Recall")    # same
#> [1] 0.4615385
pull_stat(c_mat, "Accuracy")
#> [1] 0.5
pull_stat(c_mat, "Error")     # 1 - accuracy
#> [1] 0.5
pull_stat(c_mat, "PPV")
#> [1] 0.6666667
pull_stat(c_mat, "NPV")
#> [1] 0.3636364
pull_stat(c_mat, "F_measure")
#> [1] 0.5454545
pull_stat(c_mat, "Wt_Acc")
#> [1] 0.489011
```
