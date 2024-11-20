#' Mack-Wolfe Test
#'
#' Calculates the Mack-Wolfe test on a single vector
#'   of numeric data. The Jonckheere-Terpstra (JT) test
#'   or Jonckheere trend test is a special case of the
#'   Mack-Wolfe where the peak is set to one of the ends.
#'
#' @param x Numeric. A numeric _vector_ of values.
#'   If empty of parameters (see examples), the example
#'   from Hollander & Wolfe is computed.
#' @param formula A formula specifying the `lhs` and `rhs`.
#' @param data A `data.frame` containing variables in the `formula`.
#' @param group Factor. A vector of groupings matched to `x`.
#'   The factor levels are used as the grouping information.
#' @param peak `character(1)`. A string corresponding to the
#'   desired peak factor level.
#'   If `peak = "jt"` (default) a JT-test is performed.
#'   If `peak = NULL`, the "peak unknown" version of the
#'   Mack-Wolfe test is performed.
#' @param rm_outliers Logical. Should statistical outliers
#'   (\eqn{6 * mad} _and_ \eqn{5x}) be removed? See [remove_outliers()].
#' @param alpha Numeric. The desired significance level.
#' @param nperm `integer(1)`. The number of Monte-Carlo simulations
#'   to perform. If `NULL`, a p-value approximation is
#'   used (if `length(x) > 10`).
#' @param ... Additional arguments passed to downstream S3 methods.
#'
#' @return Returns a `mack_wolfe` class object:
#'   \item{Ap:}{The Mack-Wolfe test statistic (if peak known)}
#'   \item{Astar:}{The Normal approximation of the test statistic}
#'   \item{p_value:}{The __two-sided__ p-value associated with the
#'     Normal approximation ([pnorm()])}
#'   \item{Acrit:}{The critical value for the z-distribution at the
#'     requested significance level (`alpha`)}
#'   \item{alpha:}{The significance level at which the critical
#'     value was evaluated}
#'   \item{peak:}{The peak as determined by test statistic}
#'   \item{groups:}{The factor levels of supplied `group` parameter.}
#'
#' @author Stu Field, Michael Mehan
#' @references Myles Hollander and Douglas A. Wolfe (1973).
#'   *Nonparametric Statistical Methods*. New York: John Wiley & Sons.
#'   Pages 115-120, 215.
#' @examples
#' x <- c(36.0, 33.6, 26.9, 35.8, 30.1, 31.2, 35.3,   # g1
#'        39.9, 29.1, 43.4,                           # g2
#'        44.6, 54.4, 48.2, 55.7, 50,                 # g3
#'        53.8, 53.9, 62.5, 46.6,                     # g4
#'        44.3, 34.1, 35.7, 35.6,                     # g5
#'        31.7, 22.1, 30.7)                           # g6
#' months <- c(g1 = "Jan-Feb",
#'             g2 = "Mar-Apr",
#'             g3 = "May-Jun",
#'             g4 = "Jul-Aug",
#'             g5 = "Sep-Oct",
#'             g6 = "Nov-Dec")
#' group  <- rep(months, c(7, 3, 5, 4, 4, 3))
#' group  <- factor(group, months)
#' peak   <- "Jul-Aug"
#'
#' mack_wolfe(x, group, peak)
#'
#' # run example from text (same as above)
#' mack_wolfe()
#'
#' # use Monte-Carlo permutation to estimate p-value
#' mack_wolfe(NA, nperm = 100L)
#'
#' # S3 formula method
#' df <- data.frame(var = x, gr = group)
#' mack_wolfe(var ~ gr, data = df, peak = peak)
#' @importFrom utils combn
#' @importFrom stats qnorm pnorm
#' @export
mack_wolfe <- function(x, ...) UseMethod("mack_wolfe")

#' @noRd
#' @export
mack_wolfe.default <- function(x, ...) {
  # this runs the example from the text book: Hollander & Wolfe
  x <- c(36.0, 33.6, 26.9, 35.8, 30.1, 31.2, 35.3,   # g1
         39.9, 29.1, 43.4,                           # g2
         44.6, 54.4, 48.2, 55.7, 50,                 # g3
         53.8, 53.9, 62.5, 46.6,                     # g4
         44.3, 34.1, 35.7, 35.6,                     # g5
         31.7, 22.1, 30.7)                           # g6
  months <- c(g1 = "Jan-Feb",
              g2 = "Mar-Apr",
              g3 = "May-Jun",
              g4 = "Jul-Aug",
              g5 = "Sep-Oct",
              g6 = "Nov-Dec")
  group  <- factor(rep(months, c(7, 3, 5, 4, 4, 3)), levels = months)
  mack_wolfe(x, group = group, peak = "Jul-Aug", ...)
}

#' @rdname mack_wolfe
#' @export
mack_wolfe.formula <- function(formula, data, ...) {
  stopifnot(
    "`formula` missing or incorrect." =
      !missing(formula) || length(formula) == 3L
  )
  mack_wolfe(x     = eval(formula[[2L]], data),
             group = eval(formula[[3L]], data), ...)

}

#' @rdname mack_wolfe
#' @export
mack_wolfe.numeric <- function(x, group, peak = "jt", rm_outliers = FALSE,
                               alpha = 0.05, nperm = NULL, ...) {

  if ( !inherits(group, "factor") ) {
    stop(
      "The `group =` argument must be a factor type, the same length as `x`, ",
      "with levels corresponding to the classes.", call. = FALSE
    )
  }

  levels <- levels(group)
  L <- length(levels)  # nolint: object_usage_linter.
  n <- length(x)

  if ( n != length(group) ) {
    stop(
      "The `group =` argument must be the same length as `x`, ",
      "specifying the group for the corresponding elements of `x`.",
      call. = FALSE
    )
  }

  if ( rm_outliers ) {
    group_char <- as.character(group)
    tbl   <- remove_outliers(x = x, y = group_char)
    x     <- tbl$x
    group <- factor(tbl$y, levels = levels)
    if ( length(x) < n ) {
      warning(
        "Outliers removed during analysis ... ", value(n - length(x)),
        call. = FALSE
      )
    }
    n <- length(x)   # update `n` if outliers removed
  }

  if ( is.null(peak) ) {
    ret <- mack_wolfe_unknown()
  } else {
    ret <- mack_wolfe_known()
  }
  add_class(ret, "mack_wolfe")
}


# Peak known ----
mack_wolfe_known <- function() {
  # get everything from the calling env (parent)
  caller_ <- parent.frame()
  env_    <- environment()
  get_assign <- function(f, from) assign(f, get(f, from), env_)
  lapply(ls(caller_), get_assign, from = caller_)

  if ( peak == "jt" ) {
    peak <- levels[L]
  }

  if ( !peak %in% levels ) {
    stop(
      "Improper `peak =` value. ", value(peak),
      " is not in grouping vector!", call. = FALSE
    )
  }

  n_vec   <- c(table(group))
  peak_n  <- which(levels == peak)
  N1      <- sum(n_vec[1:peak_n])
  N2      <- sum(n_vec[peak_n:length(n_vec)])
  N_total <- sum(n_vec)
  group_index      <- list()
  group_index$up   <- as.numeric(group) <= peak_n
  group_index$down <- as.numeric(group) >= peak_n

  monotonic <- peak == levels[1L] || peak == levels[L]

  if ( monotonic ) {
    seqL <- ifelse(peak == levels[1L], 2L, 1L)
  } else {
    seqL <- 1:2L
  }

  mw_counts <- lapply(seqL, function(.count) {
      tmp_data  <- x[ group_index[[.count]] ]
      tmp_group <- group[group_index[[.count]], drop = TRUE]
      tmp_levs  <- levels(tmp_group)
      choose_2  <- t(utils::combn(length(tmp_levs), 2L)) # get combinations
      apply(choose_2, 1, function(.r) {  # across rows
        if ( .count == 1L ) {
          A <- tmp_data[tmp_group == tmp_levs[.r[1L]]]
          B <- tmp_data[tmp_group == tmp_levs[.r[2L]]]
        } else {
          A <- tmp_data[tmp_group == tmp_levs[.r[2L]]]
          B <- tmp_data[tmp_group == tmp_levs[.r[1L]]]
        }
        vapply(A, function(.i) sum(.i < B) + sum(.i == B) / 2, double(1))
      })
  }) |>
  setNames(names(group_index)[seqL])

  total_counts <- vapply(mw_counts, function(.x) sum(unlist(.x)), double(1))
  Ap <- sum(total_counts)

  # calculate Astar: large-sample approx -----
  np  <- n_vec[peak_n]  # sample size of peak
  E_o <- unname((N1^2 + N2^2 - sum(n_vec^2) - np^2) / 4)
  var_o <- (2 * (N1^3 + N2^3) + 3 * (N1^2 + N2^2) -
              sum(n_vec^2 * (2 * n_vec + 3)) -
              np^2 * (2 * np + 3) + 12 * np * N1 * N2 -
              12 * np^2 * N_total) / 72
  var_o  <- unname(var_o)
  A_star <- (Ap - E_o) / sqrt(var_o)

  if ( is.null(nperm) ) {
    p_value <- 2 * pnorm(abs(A_star), lower.tail = FALSE)  # two-tailed
  } else {
    # calculate p-value via Monte-Carlo simulation
    stopifnot("`nperm` must be a single integer value." = is_int(nperm))
    signal_info("Performing Monte-Carlo permutation estimate of p-value.")
    z_vec <- replicate(n = nperm, simplify = TRUE, {
        mack_wolfe(x       = sample(x, size = n),
                   group   = group,
                   peak    = peak,
                   nperm   = NULL)$Astar})
    p_value <- sum(z_vec >= A_star) / nperm   # overwrite p_value above
  }
  # note Acrit: some implementations use upper-tailed test only
  list(Ap      = Ap,
       Astar   = A_star,
       n       = n,
       p_value = p_value,
       Acrit   = qnorm(alpha, lower.tail = FALSE),
       alpha   = alpha,
       groups  = levels,
       peak    = sprintf("%s | k = %i", names(np), peak_n))
}


# Peak unknown ----
mack_wolfe_unknown <- function() {
  # get everything from the calling env (parent)
  caller_ <- parent.frame()
  env_    <- environment()
  get_assign <- function(f, from) assign(f, get(f, from), env_)
  lapply(ls(caller_), get_assign, from = caller_)

  Uq_stars <- vapply(levels, function(.x) {
    mack_wolfe(x, group, peak = .x)$Astar
  }, double(1))

  umbrella_max <- which(Uq_stars == max(Uq_stars))
  valley_min   <- which(Uq_stars == min(Uq_stars))
  umbrellas    <- sum(Uq_stars[umbrella_max])
  valleys      <- -sum(Uq_stars[valley_min])

  r <- ifelse(umbrellas >= valleys, umbrella_max, valley_min)

  if ( length(r) > 1L ) {
    print(r)
    warning(
      "Tie in peak unknown. Never thought this would happen.\n",
      "It's implemented so you can turn this exception off, ",
      "but pay close attention to what happens.", call. = FALSE
    )
  }

  if ( length(r) == 1L && r == 1L ) {
    r <- length(levels)
  }

  mw_sums <- vapply(r, function(.x) {
    mack_wolfe(x, group, peak = levels[.x])$Astar
  }, double(1))

  Ap_star <- 1 / length(r) * sum(mw_sums)
  # some implementations use upper-tailed test only
  p_value <- 2 * pnorm(abs(Ap_star), lower.tail = FALSE) # two-tailed

  list(Ap      = NA_integer_,
       Astar   = Ap_star,
       n       = n,
       p_value = p_value,
       Acrit   = qnorm(alpha, lower.tail = FALSE),
       alpha   = alpha,
       groups  = levels,
       peak    = sprintf("%s | k = %s", paste(levels[r], collapse = ", "),
                         paste(r, collapse = ", ")))
}


# S3 print ----

#' @noRd
#' @export
print.mack_wolfe <- function(x, ...) {
  txt <- paste("peak", ifelse(is.na(x$Ap), "unknown", "known"))
  signal_rule(
    paste0("Mack-Wolfe test for umbrella alternatives (", txt, ")"),
    line_col = "blue", lty = "double"
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
  signal_rule(line_col = "green", lty = "double")
  invisible(x)
}
