#' Contrast 2 Analysis Tables
#'
#' Compare 2 `stat.table` objects from any two analyses
#' from the `calc.*` family of functions, determining the
#' common significant analytes.
#' Each table should have a "p-value" column and the row names of each
#' table _must_ be proper `"AptNames"` (e.g. `seq.SeqId`).
#'
#' @param x The first `stat.table` object to contrast (x-axis).
#' @param y The second `stat.table` object to contrast (y-axis).
#' @param ident Logical. Should the points beyond the cutoff be identified?
#' @param label.size The size for the labels if `ident = TRUE`.
#' @param main Optional. A title for the plot.
#' @param cutoff Numeric. Bonferroni corrects `p-value` cutoff to base
#'   the comparison of the two tables.
#' @return A comparison plot of 2 analyses.
#' @author Stu Field
#' @examples
#' a <- calc.t(log10(sim_test_data), response = "class_response")
#' b <- calc.ks(log10(sim_test_data), response = "class_response")
#' plotContrastTables(a, b, ident = TRUE, cutoff = 0.005, main = "Check this out!")
#' @importFrom ggplot2 geom_point ggplot geom_text
#' @importFrom ggplot2 labs aes geom_hline geom_vline
#' @export
plotContrastTables <- function(x, y, ident = FALSE, label.size = 2.5,
                               main = "Table p-value Contrasts",
                               cutoff = 0.05 / nrow(x)) {

  x <- x$stat.table
  y <- y$stat.table

  if ( !(inherits(x, "data.frame") && inherits(y, "data.frame")) ) {
    stop(
      "Check class of `x` and `y` objects. ",
      "Are they data frame `stat.tables` from separate analyses?",
      call. = FALSE
    )
  }

  common <- getSeqIdMatches(rownames(y), rownames(x))

  x <- x[common[, 2L], ]
  y <- y[common[, 1L], ]

  lab    <- bquote(~italic(log)[10] ~ (italic(p) - value))
  log_df <- data.frame(x = -log10(x[, grep("^p.value", names(x))]),
                       y = -log10(y[, grep("^p.value", names(y))]),
                       labels = common[, 1L])
  which1 <- which(log_df$x >= -log10(cutoff))
  which2 <- which(log_df$y >= -log10(cutoff))
  xy     <- intersect(which1, which2)
  xnoty  <- setdiff(which1, which2)
  ynotx  <- setdiff(which2, which1)
  xandy  <- union(which1, which2)

  log_df |>
    ggplot(aes(x = x, y = y)) +
    geom_point(alpha = 0.2) +
    geom_point(data = log_df[xnoty, ], pch = 21,
               colour = "navy", size = 2.5, fill = "darkred") +
    geom_point(data = log_df[ynotx, ], pch = 21,
               colour = "navy", size = 2.5, fill = "darkred") +
    geom_point(data = log_df[xy, ], pch = 21,
               colour = "darkred", size = 3.5, fill = "blue") +
    labs(x = lab, y = lab, title = main) + {
      if ( ident )
        geom_text(data = log_df[xandy, ],
                  aes(label = labels),
                  hjust = "inward",
                  size = label.size,
                  check_overlap = TRUE)
      } +
    geom_hline(yintercept = -log10(cutoff), linetype = "dashed",
               size = 0.25, colour = "red") +
    geom_vline(xintercept = -log10(cutoff), linetype = "dashed",
               size = 0.25, colour = "red") +
    SomaPlotr::theme_soma()
}
