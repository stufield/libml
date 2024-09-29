
#' Internal for log-tranform warnings
#' in the calc.* family of functions
#' @param x String of the test being performed.
#' @noRd
logWarning <- function(x) {
  warning(
    "Are you sure you wanted to perform a ", value(x),
    " test without log10-transformation?", call. = FALSE
  )
}

#' Internal for printing calc* related diagnostic info to the console.
#'
#' @param apts The apts/features being used to generate the calc table.
#' @param response The response column variable (string).
#' @noRd
calc_msg <- function(x, apts, response) {
  signal_done(
    "Creating", value(length(apts)), x, "models with:", value(response)
  )
}

#' Column-wise KS-distance
#'
#' Used in wrapping a repeated KS-test
#' among the columns of an ADAT. Internal not exported to user.
#'
#' @param x A numeric vector of RFU values.
#' @param which numeric indices indicating one of the groups.
#' @param rm.outliers Logical. Should statistical outliers (6*mad) be removed?
#' @return A vector of the test statistic and associated p-value.
#' @importFrom stats ks.test
#' @noRd
column_ks <- function(x, which, rm.outliers = FALSE) {

  if ( rm.outliers ) {
    g1 <- removeOutliers(x[which])$x
    g2 <- removeOutliers(x[-which])$x
  } else {
    g1 <- x[which]
    g2 <- x[-which]
  }

  test <- stats::ks.test(g1, g2)
  test$statistic <- unname(test$statistic)

  if ( mean(g1, na.rm = TRUE) > mean(g2, na.rm = TRUE) ) {
    stat.signed <- test$statistic
  } else {
    stat.signed <- -test$statistic
  }

  out <- c(ks.dist = test$statistic, signed.ks.dist = stat.signed,
           p.value = test$p.value)
  if ( rm.outliers ) {
    out <- c(out, nGrp1 = length(g1), nGrp2 = length(g2))
  }
  out
}

#' Column-wise Log-ratio
#'
#' Used in wrapping a repeated calculation of log-ratios
#' among the columns of an ADAT. Internal not exported to user.
#'
#' @param x A numeric vector of RFU values.
#' @param which numeric indices indicating one of the groups.
#' @param paired Logical. Are the groups paired?
#' @param rm.outliers Logical. Should statistical outliers (6*mad) be removed?
#' @param do.mean Logical. Should the mean be used (rather than median)
#'   when calculating the log-ratio? Defaults to median.
#' @return A vector of the log2(FC) and its signed log2(FC)
#' @importFrom stats median
#' @noRd
column_lr <- function(x, which, paired, do.mean = FALSE, rm.outliers = FALSE) {

  .fun <- if ( do.mean ) base::mean else stats::median

  if ( rm.outliers ) {
    if ( paired )  {
      rez  <- removeOutliers(x[which], x[-which])
      stat <- .fun(log2(rez$x / rez$y), na.rm = TRUE)
      c(log2.fold.change = abs(stat),
        signed.log2.fold.change = stat,
        nGrp1 = length(rez$x),
        nGrp2 = length(rez$y))
    } else {
      top    <- removeOutliers(x[which])$x
      bottom <- removeOutliers(x[-which])$x
      stat   <- log2(.fun(top, na.rm = TRUE) / .fun(bottom, na.rm = TRUE))
      c(log2.fold.change = abs(stat),
        signed.log2.fold.change = stat,
        nGrp1 = length(top),
        nGrp2 = length(bottom))
    }
  } else {
    if ( paired )  {
      fc <- .fun(log2(x[which] / x[-which]), na.rm = TRUE)
      c(log2.fold.change = abs(fc),
        signed.log2.fold.change = fc)
    } else {
      stat <- log2(.fun(x[which], na.rm = TRUE) / .fun(x[-which], na.rm = TRUE))
      c(log2.fold.change = abs(stat),
        signed.log2.fold.change = stat)
    }
  }
}

#' Column-wise t-test
#'
#' Used in wrapping a repeated t-test among the columns of an ADAT.
#' Internal not exported to user.
#'
#' @param x A numeric vector of RFU values.
#' @param which numeric indices indicating one of the groups.
#' @param paired Logical. Are the groups paired?
#' @param rm.outliers Logical. Should statistical outliers (6 * mad) be removed?
#' @param ... Arguments passed to [t.test()].
#' @return A vector of the test statistic and its associated p-value.
#' @importFrom stats t.test
#' @keywords internal
#' @noRd
column_t <- function(x, which, paired, rm.outliers = FALSE, ...) {

  if ( rm.outliers )  {
    if ( paired ) {
      rez <- removeOutliers(x[which], x[-which])
      g1  <- rez$x
      g2  <- rez$y
    } else {
      g1 <- removeOutliers(x[which])$x
      g2 <- removeOutliers(x[-which])$x
    }
  } else {
    g1 <- x[which]
    g2 <- x[-which]
  }

  test <- stats::t.test(g1, g2, paired = paired, ...)
  test$statistic <- unname(test$statistic)

  out <- c(t.stat  = abs(test$statistic), signed.t.stat = test$statistic,
           p.value = test$p.value)
  if ( rm.outliers ) {
    out <- c(out, nGrp1 = length(g1), nGrp2 = length(g2))
  }
  out
}

#' Column-wise Wilcoxon/Mann-Whitney
#'
#' Used in wrapping a repeated Rank Sum (Mann-Whitney) or Signed Rank test
#' among the columns of an ADAT. Internal not exported to user.
#'
#' @param x A numeric vector of RFU values.
#' @param which numeric indices indicating one of the groups.
#' @param paired Logical. Are the groups paired?
#' @param rm.outliers Logical. Should statistical outliers (6 * mad) be removed?
#' @param ... Arguments passed to [wilcox.test()].
#' @return A vector of the test statistic and associated p-value.
#' @note For this test, consider not using the continuity for
#'   the normal approximation for the p-value.
#' @importFrom stats wilcox.test
#' @noRd
column_wilcox <- function(x, which, paired, rm.outliers = FALSE, ...) {

  if ( rm.outliers )  {
    if ( paired ) {
      rez <- removeOutliers(x[which], x[-which])
      g1  <- rez$x
      g2  <- rez$y
    } else {
      g1 <- removeOutliers(x[which])$x
      g2 <- removeOutliers(x[-which])$x
    }
  } else {
    g1 <- x[which]
    g2 <- x[-which]
  }

  test <- stats::wilcox.test(g1, g2, paired = paired, ...)
  out  <- c(U = as.integer(unname(test$statistic)), p.value = test$p.value)
  if ( rm.outliers ) {
    out <- c(out, nGrp1 = length(g1), nGrp2 = length(g2))
  }
  out
}
