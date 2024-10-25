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
#'   `intercept`, `slope`, and `t.slope` respectively.
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
   mutate(formula = map(feature, ~ as.formula(paste(.x, "~", var))), # create formula
          test    = map(formula, ~ .fun(.x, data = data)),           # fit tests
          stats   = map(test, formatTest)                            # pull out statistic
                   ) |>
    unnest(cols = stats) |>
    mutate(p_value      = p.value,
           fdr          = p.adjust(p_value, method = "fdr"),
           p.bonferroni = p.adjust(p_value, method = "bonferroni"),
           rank         = row_number()) |>
    select(-formula, -test, -p.value) |>
    arrange(p_value) |>
    add_class("uni_tbl")
}






#' formatTest
#'
#' Internal helper S3 method to extract desired statistics from output of
#' various univariate tests.
#'
#' @param test_obj Output of various tests such as [t.test()] and [lm()].
#' @return A tibble.
#' @noRd
formatTest <- function(test_obj) UseMethod("formatTest")

#' S3 formatTest default method
#' @noRd
formatTest.default <- function(test_obj) {
  stop(
    "No `formatTest` method for predicted probabilities of class: ",
    value(class(test_obj)), call. = FALSE
  )
}

#' S3 formatTest `t.test` method
#' @importFrom tibble tibble
#' @noRd
formatTest.htest <- function(test_obj) {
  tibble(t = unname(test_obj$statistic), p.value = test_obj$p.value)
}

#' S3 formatTest `lm` method
#' @importFrom dplyr bind_cols rename
#' @importFrom tibble as_tibble
#' @noRd
formatTest.lm <- function(test_obj) {
  coefs <- summary(test_obj)$coefficient |> as_tibble()
  bind_cols(
    intercept = coefs[[1L, 1L]],
    coefs[2L, c(1L, 3L, 4L)]
  ) |>
    rename(slope   = "Estimate",
           t.slope = "t value",
           p.value = "Pr(>|t|)")
}

