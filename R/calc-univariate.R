#' Create Table of Univariate Results
#'
#' Iterates over analytes to compute univariate tests for each one.
#' Currently supports:
#' \itemize{
#'   \item{t-tests for binary endpoints}
#'   \item{linear models for continuous endpoints}
#' }
#'
#' @param data A `soma_adat` object containing data for analysis.
#' @param var Character. A response variable, the column name in `data`.
#' @param test Character. A statistical test to run.
#'   See above for currently supports tests.
#' @param save.test Logical. Save a list column of the tests/models. Recommended
#'   default value of `FALSE` as storing the models lot of memory.
#'   The `model` term in an `lm` object, for example, can be very
#'   memory-intensive.
#' @return A `tibble`. Common columns across tests include analyte meta data:
#' * `AptName`
#' * `SeqId`
#' * `Target`
#' * `EntrezGeneSymbol`
#' * `UniProt`
#'
#' Common p-value columns are:
#' * `p.value`
#' * `FDR`
#' * `p.bonferroni`
#' * `rank`
#'
#' Test-specific statistics include the following:
#' * `t.test` returns the t statistic, `t`.
#' * `lm` returns the intercept, slope, and t statistic of the slope,
#' `intercept`, `slope`, and `t.slope` respectively.
#'
#' @author Stu Field
#' @examples
#' n3 <- head(getAnalytes(SomaDataIO::example_data), 3L)
#' small_dat <- SomaDataIO::example_data[, c("Sex", "Age", n3)] |>
#'   log10() |>
#'   centerScaleData()
#' tts <- calc_univariate(small_dat, "Sex", "t.test")
#' lms <- calc_univariate(small_dat, "Age", "lm")
#' @importFrom dplyr mutate arrange select row_number
#' @importFrom purrr map
#' @importFrom stats as.formula formula lm p.adjust t.test
#' @importFrom SomaDataIO getAnalyteInfo getAnalytes
#' @importFrom tidyr unnest
#' @export
calc_univariate <- function(data, var, test = c("t.test", "lm"),
                            save.test = FALSE) {
  stopifnot(
    "`data` must be an intact `soma_adat` object." = is_intact_attr(data),
    " `var` must be a character string."           = is.character(var)
  )
  test <- match.arg(test)
  .fun <- switch(test,
                 t.test = stats::t.test,
                 lm     = stats::lm,
                 NA)

  anno <- getAnalyteInfo(data) |>
    select(AptName, SeqId, Target = TargetFullName, EntrezGeneSymbol, UniProt)
           uni <- anno |>
             mutate(formula = map(AptName, ~ as.formula(paste(.x, "~", var))), # create formula
                    test    = map(formula, ~ .fun(.x, data = data)),           # fit tests
                    stats   = map(test, formatTest)                            # pull out statistic
                   ) |>
    unnest(cols = stats) |>
    arrange(p.value) |>
    mutate(fdr          = p.adjust(p.value, method = "BH"),
           p.bonferroni = p.adjust(p.value, method = "bonferroni"),
           rank         = row_number()) |>
    select(-formula)
    if ( !save.test ) {
      uni <- select(uni, -test)
    }
    uni
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

