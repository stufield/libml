#' Create Table of Univariate Results
#'
#' Iterates over features to compute univariate tests for each
#' given an appropriate response variable.
#' Currently supports:
#' \itemize{
#'   \item{t-tests for binary endpoints}
#'   \item{linear models for continuous endpoints}
#' }
#'
#' @param data A `data.frame` object containing data for analysis.
#' @param var `character(1)`. A response variable, a column in `data`.
#' @param test `character(1)`. A statistical test to run.
#'   See above for currently supports tests.
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
#'
#' @author Stu Field
#' @examples
#' calc_univariate(mtcars, "vs")
#'
#' calc_univariate(mtcars, "mpg", "lm")
#' @importFrom dplyr mutate arrange select row_number
#' @importFrom purrr map
#' @importFrom stats as.formula formula lm p.adjust t.test
#' @importFrom tidyr unnest
#' @export
calc_univariate <- function(data, var, test = c("t.test", "lm")) {
  stopifnot(
    "`data` must be a `data.frame` object." = is.data.frame(data),
    " `var` must be a character string."    = is.character(var)
  )
  test <- match.arg(test)
  .fun <- switch(test,
                 t.test = stats::t.test,
                 lm     = stats::lm,
                 NA)

  if ( is.soma_adat(data) ) {
    tbl <- attr(data, "Col.Meta") |>
      mutate(feature = seqid2apt(SeqId)) |>
      select(feature, SeqId, Target = TargetFullName, EntrezGeneSymbol, UniProt)
  } else {
    idx <- names(which(vapply(data, is.numeric, NA)))
    tbl <- tibble(feature = setdiff(idx, var))
  }
  tbl |>
   mutate(formula = map(feature, ~ create_form(.x, var)),  # create formula
          test    = map(formula, ~ .fun(.x, data = data)), # fit tests
          stats   = map(test, .format_test)                # pull out statistic
    ) |>
    unnest(cols = stats) |>
    mutate(fdr          = p.adjust(p_value, method = "fdr"),
           p_bonferroni = p.adjust(p_value, method = "bonferroni"),
           rank         = row_number()) |>
    select(-formula, -test) |>
    arrange(p_value) |>
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
  tibble(t = unname(obj$statistic), p_value = obj$p.value)
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

