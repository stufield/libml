# Create ROC Data Table

Create a data frame of ROC performance at various predefined operating
points or cutoffs, one row per cutoff evaluation.

## Usage

``` r
create_roc_data(
  truth,
  predicted,
  pos_class,
  do.ci = FALSE,
  cutoffs = seq(1e-05, 0.99999, length.out = length(truth)),
  include.auc = FALSE
)

filter_roc_data(
  roc_data,
  metric = c("YoudenJ", "sensitivity", "specificity", "ppv", "npv", "mcc", "perpD",
    "cutoff"),
  method = c("max", "min", "value"),
  value = NULL
)

calc_roc_perpendicular(xy)

calc_roc_corner(xy)
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

- do.ci:

  `logical(1)`. Should binomial confidence limits be calculated and
  added to the return value?

- cutoffs:

  `numeric(n)`. Cutoffs at which to evaluate performance.

- include.auc:

  `logical(1)`. Should AUC also be calculated and added as a column to
  the returned data frame?

- roc_data:

  The result of a call to `create_roc_data()`, a `roc_data` object.

- metric:

  Character. The metric (a column of the `roc_data` object) on which to
  filter the ROC data.

- method:

  `character(1)`. The filtering method. Can be either the maximum
  ("max") or minimum ("min") of your metric, or can be a specific value
  ("value") on which to filter (e.g. `sensitivity = 0.8`).

- value:

  If `method == "value"`, the value in \\\[-1, 1\]\\ on which to filter.

- xy:

  `numeric(2)`. An `(x, y)` coordinate on the ROC curve.

## Value

`create_roc_data()`: A `roc_data` class object, a `tibble`, of the ROC
data evaluated at each of the cutoff evaluation points. AUC is the area
under the ROC curve, with values in \\\[0, 1\]\\. Youden's J is a method
for choosing the "optimal" cut-off based on highest total sensitivity
and specificity and is calculated via: \$\$ Youden_J = sensitivity +
specificity - 1 \$\$ For details on other classification metrics, see
[`calc_confusion()`](https://stufield.github.io/libml/reference/calc_confusion.md).

`filter_roc_data()`: A filtered `roc_data` data frame.

`calc_roc_perpendicular()`: the perpendicular distance between the curve
and the unit line.

`calc_roc_corner()`: the distance from the ROC curve to the top-left
corner of the ROC.

## Functions

- `filter_roc_data()`: A filtering method for class `roc_data`.

- `calc_roc_perpendicular()`: In receiver operating criterion curves,
  calculate the optimal operating point for a binary test given a series
  of \\(x, y)\\ coordinates of the ROC curve, by calculating the
  *perpendicular* distance between the curve and the unit \\x = y\\
  line. The Youden distance is similar but differs in that it
  corresponds to the *vertical* distance between the ROC curve and the
  unit line, see `create_roc_data()`.

- `calc_roc_corner()`: An alternative optimal operating point is the
  *minimal* distance from the ROC curve to the \\(0, 1)\\ point of the
  operating space, the "top-left" corner.

## Note

`calc_roc_perpendicular()` differs slightly from the Youden's Index (J),
see `create_roc_data()`.

## References

Schisterman, et al. 2005. Optimal Cut-point and its Corresponding Youden
Index to Discriminate Individuals Using Pooled Blood Samples.
Epidemiology. 16: 73-81.

## See also

`calc_roc_perpendicular()`,
[`calc_confusion()`](https://stufield.github.io/libml/reference/calc_confusion.md)

[`stats::dist()`](https://rdrr.io/r/stats/dist.html)

Other ROC:
[`calc_roc_fit()`](https://stufield.github.io/libml/reference/calc_roc_fit.md),
[`geom_roc()`](https://stufield.github.io/libml/reference/geom_roc.md),
[`plot_boot_roc()`](https://stufield.github.io/libml/reference/plot_boot_roc.md),
[`plot_emp_roc()`](https://stufield.github.io/libml/reference/plot_emp_roc.md),
[`roc_xy()`](https://stufield.github.io/libml/reference/roc_xy.md)

## Author

Stu Field

## Examples

``` r
n <- 200
withr::with_seed(22, {
  true <- sample(c("control", "disease"), n, replace = TRUE)
  pred <- runif(n)
})
roc_data <- create_roc_data(true, pred, "disease")
roc_data
#> # A tibble: 200 × 12
#>     cutoff    tp    fn    fp    tn sensitivity specificity   ppv
#>  *   <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl>
#>  1 0.00001    98     0   102     0       1          0      0.49 
#>  2 0.00504    98     0   102     0       1          0      0.49 
#>  3 0.0101     97     1   102     0       0.990      0      0.487
#>  4 0.0151     97     1   102     0       0.990      0      0.487
#>  5 0.0201     97     1   100     2       0.990      0.0196 0.492
#>  6 0.0251     97     1   100     2       0.990      0.0196 0.492
#>  7 0.0302     97     1    98     4       0.990      0.0392 0.497
#>  8 0.0352     97     1    98     4       0.990      0.0392 0.497
#>  9 0.0402     96     2    98     4       0.980      0.0392 0.495
#> 10 0.0452     94     4    97     5       0.959      0.0490 0.492
#> # ℹ 190 more rows
#> # ℹ 4 more variables: npv <dbl>, mcc <dbl>, perpD <dbl>, YoudenJ <dbl>

create_roc_data(true, pred, "disease", do.ci = TRUE)
#> # A tibble: 200 × 16
#>     cutoff    tp    fn    fp    tn sensitivity specificity   ppv
#>  *   <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl>
#>  1 0.00001    98     0   102     0       1          0      0.49 
#>  2 0.00504    98     0   102     0       1          0      0.49 
#>  3 0.0101     97     1   102     0       0.990      0      0.487
#>  4 0.0151     97     1   102     0       0.990      0      0.487
#>  5 0.0201     97     1   100     2       0.990      0.0196 0.492
#>  6 0.0251     97     1   100     2       0.990      0.0196 0.492
#>  7 0.0302     97     1    98     4       0.990      0.0392 0.497
#>  8 0.0352     97     1    98     4       0.990      0.0392 0.497
#>  9 0.0402     96     2    98     4       0.980      0.0392 0.495
#> 10 0.0452     94     4    97     5       0.959      0.0490 0.492
#> # ℹ 190 more rows
#> # ℹ 8 more variables: npv <dbl>, mcc <dbl>, perpD <dbl>,
#> #   YoudenJ <dbl>, sens_lowerCI <dbl>, sens_upperCI <dbl>,
#> #   spec_lowerCI <dbl>, spec_upperCI <dbl>
create_roc_data(true, pred, "disease", include.auc = TRUE)
#> # A tibble: 200 × 13
#>      auc  cutoff    tp    fn    fp    tn sensitivity specificity   ppv
#>  * <dbl>   <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl>
#>  1 0.559 0.00001    98     0   102     0       1          0      0.49 
#>  2 0.559 0.00504    98     0   102     0       1          0      0.49 
#>  3 0.559 0.0101     97     1   102     0       0.990      0      0.487
#>  4 0.559 0.0151     97     1   102     0       0.990      0      0.487
#>  5 0.559 0.0201     97     1   100     2       0.990      0.0196 0.492
#>  6 0.559 0.0251     97     1   100     2       0.990      0.0196 0.492
#>  7 0.559 0.0302     97     1    98     4       0.990      0.0392 0.497
#>  8 0.559 0.0352     97     1    98     4       0.990      0.0392 0.497
#>  9 0.559 0.0402     96     2    98     4       0.980      0.0392 0.495
#> 10 0.559 0.0452     94     4    97     5       0.959      0.0490 0.492
#> # ℹ 190 more rows
#> # ℹ 4 more variables: npv <dbl>, mcc <dbl>, perpD <dbl>, YoudenJ <dbl>

# filter method
filter_roc_data(roc_data)
#> # A tibble: 1 × 12
#>   cutoff    tp    fn    fp    tn sensitivity specificity   ppv   npv
#>    <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl> <dbl>
#> 1  0.693    32    66    16    86       0.327       0.843 0.667 0.566
#> # ℹ 3 more variables: mcc <dbl>, perpD <dbl>, YoudenJ <dbl>
filter_roc_data(roc_data, "sensitivity", "value", 0.8)
#> # A tibble: 18 × 12
#>    cutoff    tp    fn    fp    tn sensitivity specificity   ppv   npv
#>     <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl> <dbl>
#>  1  0.126    83    15    85    17       0.847       0.167 0.494 0.531
#>  2  0.131    82    16    85    17       0.837       0.167 0.491 0.515
#>  3  0.136    80    18    85    17       0.816       0.167 0.485 0.486
#>  4  0.141    79    19    85    17       0.806       0.167 0.482 0.472
#>  5  0.146    79    19    85    17       0.806       0.167 0.482 0.472
#>  6  0.151    79    19    85    17       0.806       0.167 0.482 0.472
#>  7  0.156    79    19    84    18       0.806       0.176 0.485 0.486
#>  8  0.161    79    19    84    18       0.806       0.176 0.485 0.486
#>  9  0.166    79    19    84    18       0.806       0.176 0.485 0.486
#> 10  0.171    79    19    84    18       0.806       0.176 0.485 0.486
#> 11  0.176    79    19    83    19       0.806       0.186 0.488 0.5  
#> 12  0.181    78    20    82    20       0.796       0.196 0.488 0.5  
#> 13  0.186    78    20    82    20       0.796       0.196 0.488 0.5  
#> 14  0.191    77    21    82    20       0.786       0.196 0.484 0.488
#> 15  0.196    77    21    82    20       0.786       0.196 0.484 0.488
#> 16  0.201    77    21    81    21       0.786       0.206 0.487 0.5  
#> 17  0.206    74    24    80    22       0.755       0.216 0.481 0.478
#> 18  0.211    74    24    79    23       0.755       0.225 0.484 0.489
#> # ℹ 3 more variables: mcc <dbl>, perpD <dbl>, YoudenJ <dbl>

# watch out for rounding rules when trying to return a specific value!
filter_roc_data(roc_data, "sensitivity", "value", 0.85)
#> # A tibble: 1 × 12
#>   cutoff    tp    fn    fp    tn sensitivity specificity   ppv   npv
#>    <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl> <dbl>
#> 1  0.126    83    15    85    17       0.847       0.167 0.494 0.531
#> # ℹ 3 more variables: mcc <dbl>, perpD <dbl>, YoudenJ <dbl>
filter_roc_data(roc_data, "cutoff", method = "value", value = 0.5)
#> # A tibble: 20 × 12
#>    cutoff    tp    fn    fp    tn sensitivity specificity   ppv   npv
#>     <dbl> <dbl> <dbl> <dbl> <dbl>       <dbl>       <dbl> <dbl> <dbl>
#>  1  0.452    50    48    46    56       0.510       0.549 0.521 0.538
#>  2  0.457    50    48    45    57       0.510       0.559 0.526 0.543
#>  3  0.462    50    48    44    58       0.510       0.569 0.532 0.547
#>  4  0.467    50    48    43    59       0.510       0.578 0.538 0.551
#>  5  0.472    50    48    43    59       0.510       0.578 0.538 0.551
#>  6  0.477    50    48    43    59       0.510       0.578 0.538 0.551
#>  7  0.482    50    48    43    59       0.510       0.578 0.538 0.551
#>  8  0.487    49    49    43    59       0.5         0.578 0.533 0.546
#>  9  0.492    49    49    41    61       0.5         0.598 0.544 0.555
#> 10  0.497    49    49    41    61       0.5         0.598 0.544 0.555
#> 11  0.503    48    50    41    61       0.490       0.598 0.539 0.550
#> 12  0.508    47    51    41    61       0.480       0.598 0.534 0.545
#> 13  0.513    46    52    41    61       0.469       0.598 0.529 0.540
#> 14  0.518    46    52    39    63       0.469       0.618 0.541 0.548
#> 15  0.523    46    52    38    64       0.469       0.627 0.548 0.552
#> 16  0.528    46    52    37    65       0.469       0.637 0.554 0.556
#> 17  0.533    44    54    37    65       0.449       0.637 0.543 0.546
#> 18  0.538    43    55    37    65       0.439       0.637 0.538 0.542
#> 19  0.543    43    55    37    65       0.439       0.637 0.538 0.542
#> 20  0.548    42    56    36    66       0.429       0.647 0.538 0.541
#> # ℹ 3 more variables: mcc <dbl>, perpD <dbl>, YoudenJ <dbl>

# distance from unit line
calc_roc_perpendicular(c(0.5, 0.5)) # on the line
#> [1] 0
calc_roc_perpendicular(c(0, 0))     # bottom-left corner
#> [1] 0
calc_roc_perpendicular(c(0, 1))     # top-left corner
#> [1] 0.7071068
calc_roc_perpendicular(c(1, 0))     # bottom-right corner
#> [1] 0.7071068
calc_roc_perpendicular(c(1, 1))     # top-right corner
#> [1] 0
```
