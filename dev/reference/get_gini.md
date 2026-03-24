# Calculate Sorted Gini Importance

Generate a table of sorted Gini importance scores for a random forest
model.

## Usage

``` r
get_gini(rf.model)
```

## Arguments

- rf.model:

  A random forest model object (see randomForest).

## Value

A `tibble` of the sorted importance(s). `MeanDecreaseAccuracy` is the
mean decrease in accuracy resulting from removing the feature.

## See also

[`randomForest::randomForest()`](https://rdrr.io/pkg/randomForest/man/randomForest.html)

## Author

Stu Field

## Examples

``` r
# Use tr_iris training data from iris data set
rf <- withr::with_seed(101, {
  randomForest::randomForest(
    Species ~ ., data = tr_iris, importance = TRUE,
    proximity = TRUE, keep.inbag = TRUE)
})
get_gini(rf)
#> # A tibble: 4 × 5
#>   Feature      Gini_Importance setosa virginica MeanDecreaseAccuracy
#>   <chr>                  <dbl>  <dbl>     <dbl>                <dbl>
#> 1 Sepal.Length           14.6  0.0585   0.0899               0.0726 
#> 2 Petal.Width            14.0  0.0382   0.0435               0.0395 
#> 3 Petal.Length           11.7  0.0365  -0.00261              0.0153 
#> 4 Sepal.Width             9.20 0.0107   0.00967              0.00982
```
