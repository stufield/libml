# Create Table of Univariate Results

Iterates over features to compute univariate tests for each given an
appropriate response variable. Currently supported tests:

- t-tests for binary endpoints

- linear models for continuous endpoints

- log2FC for the ratio of group medians)

- Kruskal-Wallis for non-parametric multi-group comparisons

- KS for for non-parametric binary comparisons

- Wilcox for non-parametric binary comparisons (Mann-Whitney)

- Mack-Wolfe for non-parametric trends (JT-test)

## Usage

``` r
calc_univariate(
  data,
  var,
  test = c("t.test", "lm", "ks", "kw", "logistic", "wilcox", "mw", "mackwolfe", "log2fc",
    "cor"),
  ...
)
```

## Arguments

- data:

  A `data.frame` object containing data for analysis.

- var:

  `character(1)`. A response variable, a column in `data`.

- test:

  `character(1)`. A statistical test to run. See above for currently
  supports tests.

- ...:

  Additional parameters passed to the statistic function defined in
  `test`.

## Value

A `tibble` of features and univariate test results. Common columns are:

- `p_value`:

  The univariate p-value

- `FDR`:

  The false discovery rate corrected p-value

- `p_bonferroni`:

  The Bonferroni corrected p-value

- `rank`:

  The univariate rank of the feature

Test-specific statistics include the following:

- `t.test`:

  returns the t statistic, `t`

- `lm`:

  returns the intercept, slope, and t statistic of the slope,
  `intercept`, `slope`, and `t_slope` respectively

- `log2fc`:

  returns the log2-fold-change of the ratio of group medians

- `Kruskal-Wallis`:

  returns the `H` test statistic

- `KS`:

  returns the `D` test statistic

- `Wilcox`:

  returns the `U` test statistic

- `Mack-Wolfe`:

  returns the `Ap` test statistic

## Author

Stu Field

## Examples

``` r
calc_univariate(mtcars, "vs")
#> # A tibble: 10 × 6
#>    feature     t      p_value         fdr p_bonferroni  rank
#>  * <chr>   <dbl>        <dbl>       <dbl>        <dbl> <int>
#>  1 cyl     7.79  0.0000000112 0.000000112  0.000000112     1
#>  2 hp      6.29  0.00000182   0.00000826   0.0000182       2
#>  3 disp    5.94  0.00000248   0.00000826   0.0000248       3
#>  4 qsec    5.94  0.00000352   0.00000881   0.0000352       4
#>  5 mpg     4.67  0.000110     0.000220     0.00110         5
#>  6 carb    3.98  0.000413     0.000688     0.00413         6
#>  7 wt      3.76  0.000728     0.00104      0.00728         7
#>  8 drat    2.66  0.0129       0.0161       0.129           8
#>  9 gear    1.22  0.232        0.258        1               9
#> 10 am      0.927 0.362        0.362        1              10

calc_univariate(mtcars, "vs", "ks")
#> # A tibble: 10 × 6
#>    feature ks_dist     p_value        fdr p_bonferroni  rank
#>  * <chr>     <dbl>       <dbl>      <dbl>        <dbl> <int>
#>  1 qsec      0.929 0.000000136 0.00000136   0.00000136     1
#>  2 hp       -0.833 0.00000336  0.0000168    0.0000336      2
#>  3 cyl      -0.778 0.00000977  0.0000326    0.0000977      3
#>  4 disp     -0.778 0.0000217   0.0000544    0.000217       4
#>  5 mpg       0.730 0.000112    0.000224     0.00112        5
#>  6 wt       -0.611 0.00211     0.00322      0.0211         6
#>  7 carb     -0.579 0.00225     0.00322      0.0225         7
#>  8 drat      0.579 0.00544     0.00680      0.0544         8
#>  9 gear      0.452 0.0155      0.0172       0.155          9
#> 10 am        0.167 0.473       0.473        1             10

calc_univariate(mtcars, "mpg", "lm")
#> # A tibble: 10 × 8
#>    feature intercept    slope t_slope  p_value         fdr p_bonferroni
#>  * <chr>       <dbl>    <dbl>   <dbl>    <dbl>       <dbl>        <dbl>
#>  1 wt          6.05   -0.141    -9.56 1.29e-10     1.29e-9      1.29e-9
#>  2 cyl        11.3    -0.253    -8.92 6.11e-10     3.06e-9      6.11e-9
#>  3 disp      581.    -17.4      -8.75 9.38e-10     3.13e-9      9.38e-9
#>  4 hp        324.     -8.83     -6.74 1.79e- 7     4.47e-7      1.79e-6
#>  5 drat        2.38    0.0604    5.10 1.78e- 5     3.55e-5      1.78e-4
#>  6 vs         -0.678   0.0555    4.86 3.42e- 5     5.69e-5      3.42e-4
#>  7 am         -0.591   0.0497    4.11 2.85e- 4     4.07e-4      2.85e-3
#>  8 carb        5.78   -0.148    -3.62 1.08e- 3     1.36e-3      1.08e-2
#>  9 gear        2.51    0.0588    3.00 5.40e- 3     6.00e-3      5.40e-2
#> 10 qsec       15.4     0.124     2.53 1.71e- 2     1.71e-2      1.71e-1
#> # ℹ 1 more variable: rank <int>

calc_univariate(mtcars, "cyl", "kw")
#> # A tibble: 10 × 6
#>    feature     H    p_value       fdr p_bonferroni  rank
#>  * <chr>   <dbl>      <dbl>     <dbl>        <dbl> <int>
#>  1 disp    26.7  0.00000161 0.0000111    0.0000161     1
#>  2 mpg     25.7  0.00000257 0.0000111    0.0000257     2
#>  3 hp      25.2  0.00000334 0.0000111    0.0000334     3
#>  4 wt      22.8  0.0000112  0.0000279    0.000112      4
#>  5 vs      20.7  0.0000324  0.0000649    0.000324      5
#>  6 drat    14.4  0.000749   0.00125      0.00749       6
#>  7 carb    12.7  0.00173    0.00248      0.0173        7
#>  8 qsec    10.2  0.00623    0.00693      0.0623        8
#>  9 gear    10.2  0.00624    0.00693      0.0624        9
#> 10 am       8.47 0.0145     0.0145       0.145        10

calc_univariate(mtcars, "vs", "wilcox")
#> # A tibble: 10 × 6
#>    feature     U     p_value        fdr p_bonferroni  rank
#>  * <chr>   <dbl>       <dbl>      <dbl>        <dbl> <int>
#>  1 qsec     10   0.000000560 0.00000560   0.00000560     1
#>  2 cyl     237   0.00000178  0.00000891   0.0000178      2
#>  3 hp      236   0.00000344  0.0000115    0.0000344      3
#>  4 disp    232   0.0000104   0.0000260    0.000104       4
#>  5 mpg      22.5 0.0000195   0.0000389    0.000195       5
#>  6 carb    216.  0.000211    0.000351     0.00211        6
#>  7 wt      212   0.000658    0.000940     0.00658        7
#>  8 drat     60.5 0.0116      0.0145       0.116          8
#>  9 gear     88   0.110       0.123        1              9
#> 10 am      105   0.555       0.555        1             10

calc_univariate(mtcars, "vs", "log2")
#> # A tibble: 10 × 7
#>    feature  log2fc abs_log2fc p_value   fdr p_bonferroni  rank
#>  * <chr>     <dbl>      <dbl>   <dbl> <dbl>        <dbl> <int>
#>  1 am      Inf        Inf          NA    NA           NA     1
#>  2 carb     -1.42       1.42       NA    NA           NA     2
#>  3 disp     -1.37       1.37       NA    NA           NA     3
#>  4 cyl      -1          1          NA    NA           NA     4
#>  5 hp       -0.907      0.907      NA    NA           NA     5
#>  6 mpg       0.543      0.543      NA    NA           NA     6
#>  7 wt       -0.445      0.445      NA    NA           NA     7
#>  8 gear      0.415      0.415      NA    NA           NA     8
#>  9 drat      0.302      0.302      NA    NA           NA     9
#> 10 qsec      0.172      0.172      NA    NA           NA    10

# grouping variable must be factor for mack-wolfe
mtcars$carb <- as.factor(mtcars$carb)
calc_univariate(mtcars, "carb", "mack", peak = "jt")
#> # A tibble: 10 × 9
#>    feature    Ap  Astar     n peak   p_value     fdr p_bonferroni  rank
#>  * <chr>   <dbl>  <dbl> <int> <chr>    <dbl>   <dbl>        <dbl> <int>
#>  1 hp       319   4.32     32 8 | k… 1.53e-5 1.53e-4     0.000153     1
#>  2 qsec      81  -3.72     32 8 | k… 2.02e-4 7.70e-4     0.00202      2
#>  3 mpg       82  -3.68     32 8 | k… 2.31e-4 7.70e-4     0.00231      3
#>  4 disp     280.  3.02     32 8 | k… 2.50e-3 5.00e-3     0.0250       4
#>  5 vs       102. -3.02     32 8 | k… 2.50e-3 5.00e-3     0.0250       5
#>  6 cyl      274.  2.79     32 8 | k… 5.32e-3 8.86e-3     0.0532       6
#>  7 wt       272.  2.72     32 8 | k… 6.54e-3 9.34e-3     0.0654       7
#>  8 drat     170. -0.693    32 8 | k… 4.89e-1 6.11e-1     1            8
#>  9 gear     208   0.574    32 8 | k… 5.66e-1 6.29e-1     1            9
#> 10 am       182  -0.304    32 8 | k… 7.61e-1 7.61e-1     1           10

# for logistic: `var` is the LHS of the formula
calc_univariate(mtcars, "vs", "logistic")
#> # A tibble: 9 × 8
#>   feature intercept   slope odds_ratio p_value    fdr p_bonferroni
#> * <chr>       <dbl>   <dbl>      <dbl>   <dbl>  <dbl>        <dbl>
#> 1 cyl         9.29  -1.59        0.204 0.00192 0.0110       0.0173
#> 2 disp        4.14  -0.0216      0.979 0.00245 0.0110       0.0221
#> 3 mpg        -8.83   0.430       1.54  0.00659 0.0159       0.0593
#> 4 wt          5.71  -1.91        0.148 0.00867 0.0159       0.0781
#> 5 qsec      -56.4    3.12       22.7   0.00881 0.0159       0.0793
#> 6 hp          8.38  -0.0686      0.934 0.0123  0.0185       0.111 
#> 7 drat       -7.45   1.99        7.30  0.0218  0.0280       0.196 
#> 8 gear       -2.40   0.581       1.79  0.251   0.282        1     
#> 9 am         -0.539  0.693       2.00  0.344   0.344        1     
#> # ℹ 1 more variable: rank <int>

calc_univariate(mtcars, "mpg", "cor")
#> # A tibble: 9 × 6
#>   feature      r  p_value           fdr  p_bonferroni  rank
#> * <chr>    <dbl>    <dbl>         <dbl>         <dbl> <int>
#> 1 wt      -0.868 1.29e-10 0.00000000116 0.00000000116     1
#> 2 cyl     -0.852 6.11e-10 0.00000000275 0.00000000550     2
#> 3 disp    -0.848 9.38e-10 0.00000000281 0.00000000844     3
#> 4 hp      -0.776 1.79e- 7 0.000000402   0.00000161        4
#> 5 drat     0.681 1.78e- 5 0.0000320     0.000160          5
#> 6 vs       0.664 3.42e- 5 0.0000512     0.000307          6
#> 7 am       0.600 2.85e- 4 0.000366      0.00257           7
#> 8 gear     0.480 5.40e- 3 0.00608       0.0486            8
#> 9 qsec     0.419 1.71e- 2 0.0171        0.154             9

# method = 'spearman' can be passed via '...'
calc_univariate(mtcars, "mpg", "cor", method = "spear")
#> # A tibble: 9 × 6
#>   feature    rho  p_value      fdr p_bonferroni  rank
#> * <chr>    <dbl>    <dbl>    <dbl>        <dbl> <int>
#> 1 cyl     -0.911 4.69e-13 2.87e-12     4.22e-12     1
#> 2 disp    -0.909 6.37e-13 2.87e-12     5.73e-12     2
#> 3 hp      -0.895 5.09e-12 1.53e-11     4.58e-11     3
#> 4 wt      -0.886 1.49e-11 3.35e-11     1.34e-10     4
#> 5 vs       0.707 6.19e- 6 1.11e- 5     5.57e- 5     5
#> 6 drat     0.651 5.38e- 5 8.07e- 5     4.84e- 4     6
#> 7 am       0.562 8.16e- 4 1.05e- 3     7.34e- 3     7
#> 8 gear     0.543 1.33e- 3 1.49e- 3     1.20e- 2     8
#> 9 qsec     0.467 7.06e- 3 7.06e- 3     6.35e- 2     9
```
