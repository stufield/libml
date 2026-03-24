# Iris Data Set as Training Data

Generate a fake `tr_data` object based on the
[datasets::iris](https://rdrr.io/r/datasets/iris.html) data set for use
in examples sections of the libml package. First, the `versicolor` class
observations are removed to make the result binary, then half (`n = 50`)
of the observations are class scrambled, and the feature data is
"jittered" to add some noise. This was because the original iris data
set has a distinct decision boundary across the 4 features, making
classification examples "too" perfect. The format is a 4 feature + 1
class variable "tibble" object recast as a `tr_data` object. Contains 50
setosa and 50 virginica samples.

## Usage

``` r
tr_iris
```

## Format

An object of class `tr_data` (inherits from `tbl_df`, `tbl`,
`data.frame`) with 100 rows and 5 columns.

## Note

This is the same as `fake_iris` pre-existing object.

## References

Fisher, R. A. (1936) The use of multiple measurements in taxonomic
problems. *Annals of Eugenics*, **7**, Part II, 179-188. The data were
collected by Anderson, Edgar (1935). The irises of the Gaspe Peninsula,
*Bulletin of the American Iris Society*, **59**, 2-5.

## Examples

``` r
if (FALSE) { # \dontrun{
  ?iris
} # }

# print
tr_iris
#> ══ Training Data Object ═══════════════════════════════════════════════
#> • response        Species
#> • class labels    'setosa', 'virginica'
#> • counts          [50, 50]
#> • factor          TRUE
#> • n               2
#> ───────────────────────────────────────────────────────────────────────
#> # A tibble: 100 × 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species  
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>    
#>  1         4.16        3.47         1.77       0.483 setosa   
#>  2         7.25        3.85         5.47       2.16  virginica
#>  3         6.82        3.20         6.35       1.96  virginica
#>  4         6.81        2.33         5.44       1.25  virginica
#>  5         7.31        2.58         4.77       3.26  setosa   
#>  6         5.72        2.83         2.26      -0.248 setosa   
#>  7         6.91        2.47         5.78       1.56  virginica
#>  8         6.16        2.77         4.77       2.61  virginica
#>  9         7.27        3.09         5.55       2.76  setosa   
#> 10         7.12        3.39         5.90       2.14  virginica
#> # ℹ 90 more rows
```
