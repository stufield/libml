# Calculate confusion matrix

Calculate a confusion matrix from a series of predictions, true class
names and a decision cutoff. Returns a `2x2` confusion matrix. It is
imperative that the *positive* class is clearly defined to avoid
ambiguity with factor levels, therefore passing `pos_class` argument is
*not* optional. See `Details` for assumptions about the table layout.

## Usage

``` r
calc_confusion(truth, predicted, pos_class, cutoff = 0.5)

# S3 method for class 'confusion_matrix'
print(x, ...)

# S3 method for class 'confusion_matrix'
summary(object, ...)

# S3 method for class 'summary_confusion_matrix'
print(x, ...)
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

- x:

  A `confusion_matrix` or `summary_confusion_matrix` class object.

- ...:

  Arguments passed to the `print` and `summary` generics.

- object:

  A `confusion_matrix` object, created via `calc_confusion()`.

## Value

A `confusion_matrix` class object, with the *true* values along the
y-axis and *predicted* values along the x-axis.

Summary method returns a `summary_confusion_matrix` class object (list)
consisting of:

- confusion::

  The class counts based on the confusion matrix.

- metrics::

  Performance metric estimates, `n`, and associated binomial 95%
  confidence intervals. Note that `MCC` has a range in `[-1, 1]`,
  therefore confidence intervals are not calculated for this metric
  ([`calc_ci_binom()`](https://stufield.github.io/libml/reference/calc_ci_binom.md)
  expects a probability value).

- stats::

  F-measure, G-mean, and Weighted Accuracy.

## Details

Assume a `2x2` table with notation:

|          |           |          |
|----------|-----------|----------|
|          | Predicted |          |
| Truth    | negative  | positive |
| negative | *TN*      | *FP*     |
| positive | *FN*      | *TP*     |

where: \$\$TN = True Negative\$\$ \$\$TP = True Positive\$\$ \$\$FN =
False Negative\$\$ \$\$FP = False Positive\$\$

The `summary` calculations are: \$\$Sensitivity = Recall = TP / (TP +
FN)\$\$ \$\$Specificity = TN / (TN + FP)\$\$ \$\$Precision = PPV = TP /
(TP + FP)\$\$ \$\$NPV = TN / (TN + FN)\$\$ \$\$Accuracy = (TP + TN) /
(TP + FN + TN + FP)\$\$ \$\$Balanced Accuracy = (Sensitivity +
Specificity) / 2\$\$ \$\$Prevalence = (FN + TP) / (TP + FN + TN +
FP)\$\$ \$\$Matthew's Correlation Coefficient = TP x TN - FP x FN /
sqrt( (TP + FP) (TP + FN) (TN + FP) (TN + FN) )\$\$

## Functions

- `print(confusion_matrix)`: S3 print method for classes
  `confusion_matrix`.

- `summary(confusion_matrix)`: Calculates the confusion statistics from
  a confusion matrix.

- `print(summary_confusion_matrix)`: S3 print method for class
  `summary_confusion_matrix`.

## References

The Statistical Evaluation of Medical Tests for Classification and
Prediction. 2004. Margaret Pepe, Altman, DG, Bland, JM. 1994.
"Diagnostic tests 1: sensitivity and specificity", British Medical
Journal, vol 308, 1552.

## See also

`calc_confusion()`

## Author

Stu Field

## Examples

``` r
n <- 20
withr::with_seed(22, {
  true <- sample(c("control", "disease"), n, replace = TRUE)
  pred <- runif(n)
})
(c_mat <- calc_confusion(true, pred, pos_class = "disease"))
#> ── Confusion ──────────────────────────────────────────────────────────
#> 
#> Positive Class: disease
#> 
#>          Predicted
#> Truth     control disease
#>   control       4       3
#>   disease       7       6
#> 

calc_confusion(true, pred, pos_class = "disease", 0.75)    # specify cutoff
#> ── Confusion ──────────────────────────────────────────────────────────
#> 
#> Positive Class: disease
#> 
#>          Predicted
#> Truth     control disease
#>   control       5       2
#>   disease       8       5
#> 

# factor levels of `truth` are ignored
# The `pos_class` argument is respected always
true_a <- factor(true, levels = c("control", "disease"))
true_b <- factor(true, levels = c("disease", "control"))
a <- calc_confusion(true_a, pred, pos_class = "disease")
b <- calc_confusion(true_b, pred, pos_class = "disease")
identical(a, b)
#> [1] TRUE

# S3 summary method
summary(c_mat)
#> ══ Confusion Matrix Summary ═══════════════════════════════════════════
#> ── Confusion ──────────────────────────────────────────────────────────
#> 
#> Positive Class: disease
#> 
#>          Predicted
#> Truth     control disease
#>   control       4       3
#>   disease       7       6
#> 
#> ── Performance Metrics (CI95%) ────────────────────────────────────────
#> 
#> # A tibble: 10 × 5
#>    metric              n estimate CI95_lower CI95_upper
#>    <chr>           <int>    <dbl>      <dbl>      <dbl>
#>  1 Sensitivity        13   0.462      0.152       0.771
#>  2 Specificity         7   0.571      0.153       0.990
#>  3 PPV (Precision)     9   0.667      0.315       1    
#>  4 NPV                11   0.364      0.0393      0.688
#>  5 Accuracy           20   0.5        0.250       0.750
#>  6 Bal Accuracy       20   0.516      0.267       0.766
#>  7 Prevalence         20   0.65       0.411       0.889
#>  8 AUC                20   0.527      0.278       0.777
#>  9 Brier Score        20   0.370      0.128       0.611
#> 10 MCC                NA   0.0316    NA          NA    
#> 
#> ── Additional Statistics ──────────────────────────────────────────────
#> 
#> F_measure    G_mean    Wt_Acc 
#>     0.545     0.514     0.489 
```
