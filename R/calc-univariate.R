#' Create Table of Univariate Results
#'
#' Iterates over features to compute univariate tests for each
#' given an appropriate response variable.
#' Currently supports:
#' \itemize{
#'   \item{t-tests for binary endpoints}
#'   \item{linear models for continuous endpoints}
#'   \item{log2FC for the ratio of group medians)}
#'   \item{Kruskal-Wallis for non-parametric multi-group comparisons}
#'   \item{KS for for non-parametric binary comparisons}
#'   \item{Wilcox for non-parametric binary comparisons (Mann-Whitney)}
#'   \item{Mack-Wolfe for non-parametric trends (JT-test)}
#' }
#'
#' @param data A `data.frame` object containing data for analysis.
#' @param var `character(1)`. A response variable, a column in `data`.
#' @param test `character(1)`. A statistical test to run.
#'   See above for currently supports tests.
#' @param ... Additional parameters passed to the statistic
#'   function defined in `test`.
#' @return A `tibble` of features and univariate test results.
#' Common columns are:
#' * `p_value`
#' * `FDR`
#' * `p_bonferroni`
#' * `rank`
#'
#' Test-specific statistics include the following:
#' * `t.test` returns the t statistic, `t`.
#' * `lm` returns the intercept, slope, and t statistic of the slope,
#'   `intercept`, `slope`, and `t_slope` respectively.
#' * `log2fc` returns the log2-fold-change of the ratio of group medians.
#' * `Kruskal-Wallis` returns the `H` test statistic.
#' * `KS` returns the `D` test statistic.
#' * `Wilcox` returns the `U` test statistic.
#' * `Mack-Wolfe` returns the `Ap` test statistic.
#'
#' @author Stu Field
#' @examples
#' calc_univariate(mtcars, "vs")
#'
#' calc_univariate(mtcars, "vs", "ks")
#'
#' calc_univariate(mtcars, "mpg", "lm")
#'
#' calc_univariate(mtcars, "cyl", "kw")
#'
#' calc_univariate(mtcars, "vs", "wilcox")
#'
#' calc_univariate(mtcars, "vs", "log2")
#'
#' # grouping variable must be factor for mack-wolfe
#' mtcars$carb <- as.factor(mtcars$carb)
#' calc_univariate(mtcars, "carb", "mack", peak = "jt")
#'
#' # for logistic: `var` is the LHS of the formula
#' calc_univariate(mtcars, "vs", "logistic")
#' @importFrom dplyr mutate arrange select row_number
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom stats lm p.adjust t.test kruskal.test
#' @importFrom tidyr unnest
#' @export
calc_univariate <- function(data, var,
                            test = c("t.test", "lm", "ks", "kw", "logistic",
                                     "wilcox", "mw", "mackwolfe", "log2fc"),
                            ...) {
  stopifnot(
    "`data` must be a `data.frame` object." = is.data.frame(data),
    " `var` must be a character string."    = is.character(var)
  )
  test <- match.arg(test)
  .fun <- switch(test,
                 t.test = stats::t.test,
                 lm     = stats::lm,
                 ks     = .ks.test,
                 mackwolfe = mack_wolfe,
                 logistic  = .logistic,
                 wilcox = stats::wilcox.test,
                 mw     = stats::wilcox.test,
                 kw     = stats::kruskal.test,
                 log2fc = .log2fc,
                 NA)

  if ( is_soma_adat(data) ) {
    tbl <- attr(data, "Col.Meta") |>
      mutate(feature = add_seq(SeqId)) |>
      select(feature, SeqId, Target = TargetFullName, EntrezGeneSymbol, UniProt)
  } else if ( any(is_seq(names(data))) ) {
    tbl <- tibble(feature = get_analytes(data))
  } else {
    idx <- names(which(vapply(data, is.numeric, NA)))
    tbl <- tibble(feature = setdiff(idx, var))
  }
  ret <- tbl |>
    mutate(formula = map(feature, ~ create_form(.x, var)), # create formula
           test    = map(formula, function(.x) .fun(.x, data = data, ...)), # fit
           stats   = map(test, .format_test)  # pull out statistic
    ) |>
    unnest(cols = stats) |>
    arrange(p_value)
  if ( identical(test, "log2fc") ) {
    ret$p_value <- NA_real_  # nuke p_value for logFC (after sorting)
  }
  ret |>
    mutate(fdr          = p.adjust(p_value, method = "fdr"),
           p_bonferroni = p.adjust(p_value, method = "bonferroni"),
           rank         = row_number()) |>
    select(-formula, -test) |>
    add_class("uni_tbl")
}



#' format_test
#'
#' Internal helper S3 method to extract desired
#' statistics from output of various univariate tests.
#'
#' @param obj Output of various tests such as [t.test()] and [lm()].
#' @return A tibble.
#' @noRd
.format_test <- function(obj) UseMethod(".format_test")

#' @noRd
.format_test.default <- function(obj) {
  stop(
    "No `format_test()` method for class: ", value(class(obj)),
    call. = FALSE
  )
}

#' @importFrom tibble tibble
#' @noRd
.format_test.htest <- function(obj) {
  # flip sign if class 2 is greater
  if ( grepl("t-test", obj$method) ) {
    stat <- "t"
    obj$statistic <- ifelse(obj$estimate[2L] > obj$estimate[1L],
                            -obj$statistic, obj$statistic)
  } else if ( grepl("Kruskal", obj$method) ) {
    stat <- "H"   # K-W test
  } else if ( grepl("Wilcoxon", obj$method) ) {
    stat <- "U"   # Mann-Whitney
  }
  setNames(tibble(unname(obj$statistic), obj$p.value), c(stat, "p_value"))
}

#' @importFrom tibble tibble
#' @noRd
.format_test.mack_wolfe <- function(obj) {
  tibble(Ap = obj$Ap, Astar = obj$Astar, n = obj$n,
         peak = obj$peak, p_value = obj$p_value)
}

#' @importFrom tibble tibble
#' @noRd
.format_test.ks.test <- function(obj) {
  tibble(ks_dist = obj$statistic, p_value = obj$p.value)
}

#' @importFrom tibble tibble
#' @noRd
.format_test.glm <- function(obj) {
  pars <- obj$coefficients
  var  <- setdiff(names(pars), "(Intercept)")
  p_value <- summary(obj)$coefficients[var, "Pr(>|z|)"]
  tibble(
    intercept  = pars["(Intercept)"],
    slope      = pars[var],
    odds_ratio = exp(slope),
    p_value    = p_value
  )
}

#' @importFrom dplyr bind_cols rename
#' @importFrom tibble as_tibble
#' @noRd
.format_test.lm <- function(obj) {
  coefs <- as_tibble(summary(obj)$coefficient)
  bind_cols(
    intercept = coefs[[1L, 1L]],
    coefs[2L, c(1L, 3L, 4L)]
  ) |>
    rename(slope   = "Estimate",
           t_slope = "t value",
           p_value = "Pr(>|t|)")
}

#' @noRd
.format_test.log2fc <- function(obj) {
  # add dummy p_value for sorting
  # in primary function; is nuked later
  obj$p_value <- -obj$abs_log2fc
  obj
}

# internal for log2-FC tables
#' @importFrom tibble tibble
#' @importFrom stats median
#' @noRd
.log2fc <- function(frmla, data) {
  chr <- as.character(frmla)
  stopifnot(length(chr) == 3L)
  response <- chr[2L]
  var <- chr[3L]
  groups <- split(data[[response]], data[[var]])
  y <- lapply(groups, stats::median, na.rm = TRUE)
  stopifnot(length(groups) == 2L)
  ret <- tibble(
    log2fc     = log2(y[[2L]] / y[[1L]]),
    abs_log2fc = abs(log2fc)
  )
  structure(ret, class = c("log2fc", class(ret)))
}

# internal for KS-distance tables
# necessary to get the sign correct
#' @importFrom tibble tibble
#' @importFrom stats ks.test median
#' @noRd
.ks.test <- function(frmla, data) {
  ks <- ks.test(frmla, data = data)
  response <- ks$response
  groups   <- split(data[[response]], data[[as.character(frmla)[3L]]])
  stopifnot(length(groups) == 2L)
  y <- lapply(groups, stats::median, na.rm = TRUE) |>
    vapply(base::mean, na.rm = TRUE, 0.1, USE.NAMES = FALSE)
  # flip sign if class 2 is greater
  ks$statistic <- ifelse(y[2L] > y[1L], ks$statistic, -ks$statistic) |> unname()
  ks
}

# this wrapper is necessary
# because for logistic regression
# the formula is reversed
.logistic <- function(frmla, data) {
  chr <- as.character(frmla)
  stopifnot(length(chr) == 3L)
  new_form <- create_form(chr[3L], chr[2L])
  fit_logistic(new_form, data)
}
