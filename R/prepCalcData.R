#' Data prep for `calc.*` functions
#'
#' Prepares data and preforms checks for `calc.*` functions.
#' This is an internal function not exported to the user and in
#' meant to check and prepare the incoming data frame
#' for analysis. If `NA`s are detected in the response, those rows
#' are remove with a warning. If `NA`s are detected in the feature
#' set, those columns are removed.
#'
#' @param x A `soma_adat` or `tr_data` object containing RFU data.
#' @param feats Character. A vector of variables (usually aptamer names) to include.
#' @param response Character. The column name to use as the
#'   response/grouping variable. Expected to be a factor with 2 levels.
#' @param paired Logical. Indicating whether the data are paired or not.
#' @param binary Logical. Indicating whether the `response` is expected binary.
#' @return A list of the following:
#'   \item{data}{The "prepared" new training data set.}
#'   \item{feats}{The aptamers to use; categorical (factor) variables removed.}
#'   \item{which_disease}{Numeric indices of the disease rows.}
#' @keywords internal
#' @importFrom tibble tibble
#' @noRd
prepCalcData <- function(x, feats, response, paired = FALSE, binary = TRUE) {

  if ( any(na_lgl <- is.na(x[[response]])) ) {
    warning(
      "NAs detected in resoponse variable, n = ", value(sum(na_lgl)), ".\n",
      "They will be removed and the data subset.", call. = FALSE
    )
    x <- x[!na_lgl, ]   # drop NAs
  }

  if ( is.factor(x[[response]]) ) {
    x <- refactorData(x)
  } else {
    x[[response]] <- factor(x[[response]])
  }

  test_tab <- table(x[[response]])

  if ( binary && length(test_tab) != 2L ) {
    stop(
      "Inappropriate number of factor levels in the ",
      "response column: ", value(length(test_tab)), ".",
      call. = FALSE
    )
  }

  if ( is.null(feats) ) {
    feats <- getAnalytes(x)
  }

  disease_class <- levels(x[[response]])[2L] # disease/event class = level 2!
  disease_idx   <- which(x[[response]] == disease_class)

  if ( any(is.na(x[, feats])) ) {
    warning("NAs detected in feature matrix. Please check.", call. = FALSE)
  }
  if ( length(disease_idx) == 0L ) {
    stop("Response column is bad. No disease.", call. = FALSE)
  }
  if ( length(disease_idx) == nrow(x) ) {
    stop("Response column is bad. All disease.", call. = FALSE)
  }

  # -------------------- #
  # for paired analyses ----
  # -------------------- #
  if ( paired ) {
    tokens <- c("SubjectID", "SubjectId",
                "subjectId", "subject.id",
                "subjectID", "PID", "pid", "Pid")
    if ( any( tokens %in% names(x)) ) {
      tokens <- tokens[ tokens %in% names(x) ]
      for ( check in tokens ) {
        if ( any(x[ disease_idx, check] != x[-disease_idx, check]) ) {
          warning(
            "Subject IDs may not match in paired analysis ... please check.",
            call. = FALSE
          )
          signal_info("Disease class rows: {value(disease_idx)}")
          flag <- tibble(disease = x[disease_idx, check],
                         control = x[-disease_idx, check])
          flag$same <- flag$disease == flag$control
          print(flag)
        }
      }
    }
  }

  # do not analyze factor class variables!
  good_fts <- discard_it(feats,
                         vapply(x[, feats], is.factor, FUN.VALUE = NA))

  if ( length(feats) < length(feats) ) {
    warning(
      "Some features were factor class and were ",
      "removed from univariate table: ", value(setdiff(feats, good_fts)),
      call. = FALSE
    )
  }

  list(data          = x[, good_fts],   # no NA rows; select features
       feats         = good_fts,
       which_disease = disease_idx)
}
