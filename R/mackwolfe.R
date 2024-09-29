#' Mack-Wolfe Test
#'
#' Calculates the Mack-Wolfe test on a single vector of numeric data.
#' The Jonckheere-Terpstra (JT) test or Jonckheere Trend test is a special
#' case of the Mack-Wolfe test where the peak is set to one of the end points.
#'
#' @param x Numeric. A _vector_ of values. If missing, the example
#'   from Hollander & Wolfe is computed.
#' @param group Factor. A vector of groupings matched to `x`.
#'   The factor levels are used as the grouping information.
#' @param peak Character. A string corresponding to the desired peak factor
#'   level (_not_ an integer, a string). If `peak = "jt"` a
#'   JT-test is performed. If `peak = NULL`, the "peak unknown" version of
#'   the Mack-Wolfe test is performed.
#' @param rm.outliers Logical. Should statistical outliers
#'   (\eqn{6 * mad} _and_ \eqn{5x}) be removed? See [getOutliers()] for
#'   outlier definition.
#' @param alpha Numeric. The desired significance level.
#' @param nperm Integer. The number of Monte-Carlo simulations to perform.
#'   If `NULL`, a p-value approximation is used (ensure `length(x) > 10`).
#' @param verbose Logical. Should checks of process be printed to the console?
#' @return Returns a list of:
#'   \item{Ap:}{The Mack-Wolfe test statistic (peak known)}
#'   \item{Astar:}{The Normal approximation of the test statistic}
#'   \item{p.value:}{The __two-sided__ p-value associated with the
#'     Normal approximation ([pnorm()])}
#'   \item{Acrit:}{The critical value for the z-distribution at the
#'     requested significance level (`alpha`)}
#'   \item{alpha:}{The significance level at which the critical
#'     value was evaluated}
#'   \item{peak:}{The peak as determined by test statistic}
#'   \item{groups:}{The factor levels of supplied `group` parameter.}
#' @author Stu Field, Michael Mehan
#' @seealso [calc.mackwolfe()]
#' @references  Myles Hollander and Douglas A. Wolfe (1973).
#'   *Nonparametric Statistical Methods*. New York: John Wiley & Sons.
#'   Pages 115-120, 215.
#' @examples
#' # pass no data -> run example
#' mackwolfe()
#'
#' # Use Monte-Carlo Permutation P-value estimation
#' mackwolfe(nperm = 100)
#' @importFrom utils combn
#' @importFrom stats qnorm pnorm wilcox.test
#' @export
mackwolfe <- function(x, group, peak = NULL, rm.outliers = FALSE,
                      alpha = 0.05, nperm = NULL, verbose = interactive()) {

  # Stock example -----
  if ( missing(x) ) {
    x <- c(36.0, 33.6, 26.9, 35.8, 30.1, 31.2, 35.3,   # group 1
           39.9, 29.1, 43.4,                           # 2
           44.6, 54.4, 48.2, 55.7, 50,                 # 3
           53.8, 53.9, 62.5, 46.6,                     # 4
           44.3, 34.1, 35.7, 35.6,                     # 5
           31.7, 22.1, 30.7)                           # 6
    months <- c("Jan-Feb", "Mar-Apr", "May-Jun", "Jul-Aug", "Sep-Oct", "Nov-Dec")
    group  <- rep(months, c(7, 3, 5, 4, 4, 3))
    group  <- factor(group, months)
    peak   <- "Jul-Aug"
  }

  if ( !inherits(group, "factor") ) {
    stop(
      "The `group =` argument must be a factor class, the same length as `x`, ",
      "with levels corresponding to the classes.", call. = FALSE
    )
  }

  n      <- length(x)
  levels <- levels(group)
  L      <- length(levels)

  if ( n != length(group) ) {
    stop(
      "The `group =` argument must be the same length as `x`, ",
      "giving the group for the corresponding elements of `x`.",
      call. = FALSE
    )
  }

  if ( rm.outliers ) {
    group_char <- as.character(group)
    res   <- removeOutliers(x = x, y = group_char)
    x     <- res$x
    group <- factor(res$y, levels = levels)
    if ( length(x) < n ) {
      warning(
        "Outliers removed during analysis ... ", value(n - length(x)),
        call. = FALSE
      )
    }
    n <- length(x)   # update `n` if outliers removed
  }

  # Peak unknown ----
  if ( is.null(peak) ) {
    if ( verbose ) {
      signal_oops("No peak provided ...")
      signal_done("Performing test with peak uknown.")
    }

    Uq_stars <- vapply(levels, function(.x) {
        mackwolfe(x, group, peak = .x, verbose = FALSE)$Astar
      }, FUN.VALUE = double(1))

    umbrella_max <- which(Uq_stars == max(Uq_stars))
    valley_min   <- which(Uq_stars == min(Uq_stars))
    umbrellas    <- sum(Uq_stars[umbrella_max])
    valleys      <- -sum(Uq_stars[valley_min])

    r <- if ( umbrellas >= valleys ) umbrella_max else valley_min

    if ( length(r) > 1L ) {
      print(r)
      warning(
        "Tie in peak unknown. Never thought this would happen.\n",
        "It's implemented so you can turn this exception off, ",
        "but pay close attention to what happens.", call. = FALSE
      )
    }

    if ( length(r) == 1L && r == 1 ) {
      r <- length(levels)
    }

    mw_sums <- vapply(r, function(.x) mackwolfe(x, group, peak = levels[.x])$Astar,
                      FUN.VALUE = double(1))

    Ap_star <- 1 / length(r) * sum(mw_sums)
    # some implementations use upper-tailed test only
    p_value <- 2 * pnorm(abs(Ap_star), lower.tail = FALSE)    # two-tailed
    Acrit   <- qnorm(alpha, lower.tail = FALSE)

    ret <- list(Ap      = NA,
                Astar   = Ap_star,
                n       = n,
                p.value = p_value,
                Acrit   = Acrit,
                alpha   = alpha,
                groups  = levels,
                peak    = sprintf("%s | k = %s",
                                  paste(levels[r], collapse = ", "),
                                  paste(r, collapse = ", ")))
  } else {
  # Peak known ----

    if ( peak == "jt" ) {
      peak <- levels[L]
    }

    if ( !peak %in% levels ) {
      stop(
        "Improper `peak =` value. ", value(peak),
        " is not in grouping vector!", call. = FALSE
      )
    }

    n_vec   <- table(group)
    peak_n  <- which(levels == peak)
    N1      <- sum(n_vec[1:peak_n])
    N2      <- sum(n_vec[peak_n:length(n_vec)])
    N_total <- sum(n_vec)
    group_index      <- list()
    group_index$up   <- as.numeric(group) <= peak_n
    group_index$down <- as.numeric(group) >= peak_n

    monotonic <- peak == levels[1L] || peak == levels[L]

    if ( monotonic ) {
      if ( peak == levels[1L] ) {
        if ( verbose ) {
          signal_done("Performing monotonic decreasing JT test ...")
        }
        seqL <- 2
      } else {
        if ( verbose ) {
          signal_done("Performing monotonic increasing JT test ...")
        }
        seqL <- 1
      }
    } else {
      seqL <- 1:2
    }

    mw_counts <- lapply(seqL, function(.mw) {
        tmp_data  <- x[ group_index[[.mw]] ]
        tmp_group <- group[group_index[[.mw]], drop = TRUE]
        tmp_levs  <- levels(tmp_group)

        if ( .mw == 1 ) {
          if ( verbose ) {
            signal_todo("Increasing groups ...", value(tmp_levs))
          }
        } else {
          if ( verbose ) {
            signal_todo("Decreasing groups ...", value(tmp_levs))
          }
        }

        choose_2 <- t(utils::combn(length(tmp_levs), 2L)) # get combinations

        apply(choose_2, 1, function(.x) {
          if ( .mw == 1 ) {
            A <- tmp_data[tmp_group == tmp_levs[.x[1L]]]
            B <- tmp_data[tmp_group == tmp_levs[.x[2L]]]
          } else {
            A <- tmp_data[tmp_group == tmp_levs[.x[2L]]]
            B <- tmp_data[tmp_group == tmp_levs[.x[1L]]]
          }
          vapply(A, function(A_i) sum(A_i < B) + sum(A_i == B) / 2,
                 FUN.VALUE = double(1))
        })
    }) |>
    setNames(names(group_index)[seqL])

    total_counts <- vapply(mw_counts, function(.x) sum(unlist(.x)),
                           FUN.VALUE = double(1))
    Ap <- sum(total_counts)

    # calculate significance: large-sample approx -----
    np    <- n_vec[peak_n]  # sample size of peak
    E_o   <- unname((N1^2 + N2^2 - sum(n_vec^2) - np^2) / 4)
    var_o <- (2 * (N1^3 + N2^3) + 3 * (N1^2 + N2^2) - sum(n_vec^2 * (2 * n_vec + 3)) -
              np^2 * (2 * np + 3) + 12 * np * N1 * N2   - 12 * np^2 * N_total) / 72
    peak_labl <- names(var_o)
    var_o  <- unname(var_o)
    A_star <- (Ap - E_o) / sqrt(var_o)

    # some implementations use upper-tailed test only
    p_value <- 2 * pnorm(abs(A_star), lower.tail = FALSE)  # two-tailed
    Acrit   <- qnorm(alpha, lower.tail = FALSE)

    # calculate significance: via Monte-Carlo simulation ----
    if ( !is.null(nperm) ) {
      signal_done(
        "Performing Monte-Carlo permutation estimate of P-value ..."
      )
      z_vec <- vapply(1:nperm, function(.x) {
          mackwolfe(x       = sample(x, size = n),
                    group   = group,
                    peak    = peak,
                    nperm   = NULL,
                    verbose = FALSE)$Astar}, FUN.VALUE = double(1))
      p_value <- sum(z_vec >= A_star) / nperm   # overwrite p_value above
      signal_done("p =", value(format(p_value, digits = 5)))
    }
    ret <- list(Ap      = Ap,
                Astar   = A_star,
                n       = n,
                p.value = p_value,
                Acrit   = Acrit,
                alpha   = alpha,
                groups  = levels,
                peak    = sprintf("%s | k = %i", peak_labl, peak_n))
  }
  structure(ret, class = c("mack_wolfe", "list"))
}


#' @noRd
#' @export
print.mack_wolfe <- function(x, ...) {
  cat("\n")
  txt <- paste("peak", ifelse(is.na(x$Ap), "unknown", "known"))
  writeLines(
    signal_rule(
      paste0("Mack-Wolfe test for umbrella alternatives (", txt, ")"),
      line_col = "blue", lty = "double"
    )
  )
  cat("\n")
  y <- x
  if ( is.na(y$Ap) ) y$Ap <- NULL
  y <- lapply(y, function(.x) {
    if ( is.numeric(.x) ) {
      format(.x, digits = 5, big.mark = ",", scientific = FALSE)
    } else {
      .x
    }
  })
  key <- sub("\\.", "-", names(y))
  key <- pad(sub("Astar", "Ap*", key), 8)
  liter(key, y, function(.x, .y) writeLines(paste("\u2022", .x, "=", value(.y))))
  cat("\n")
  writeLines(signal_rule(line_col = "green", lty = "double"))
  invisible(x)
}
