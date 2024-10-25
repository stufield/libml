#' Plot Empirical ROC Curve
#'
#' Plotting function to generate a receiver operator criterion
#' (ROC) curve for binary data and binary classifiers. This function is
#' a wrapper around [geom_roc()], with window dressing for commonly used
#' aesthetics and annotations.
#'
#' @family ROC
#' @inheritParams params
#' @inheritParams geom_roc
#' @param add Integer. The position in the plotting stack indicating where to
#'   add the ROC curve relative to an existing plot.
#'   Zero indexing is used, thus `add = 0L` (default) refers to a new plot
#'   and `add = 1L` will add a ROC layer to the existing plot and
#'   correctly position the `AUC` annotations shifted accordingly.
#' @param auc Logical. Should the AUC be printed on the plot?
#' @param auc.pos Numeric in \verb{[0, 1]} indicating where to place the AUC
#'   text. Must be of `length == 2L`, indicating the x-axis and y-axis positions,
#'   respectively. By default, the AUC will be placed slightly to the right
#'   of center of the plot.
#' @param auc.size Character size of the AUC text.
#' @param adj Numeric in \verb{[0, 1]}. Coordinates that are used to align
#'   the AUC text.
#' @param auc.shift The vertical (downward) shift between AUC text values if
#'   multiple ROCs are plotted.
#' @param ci95 Logical. Should any confidence intervals be plotted?
#' @param cutoff The decision cutoff, aka operating point, for the
#'   *positive* classes. By default, the operating point is set to 0.5.
#'    Alternatively, choosing a negative number calculates the cutoff
#'    corresponding to the maximum _perpendicular_ distance between the
#'    curve and the unit diagonal. The CI95 of the operating point (boxes)
#'    can be omitted by setting `cutoff = NA`.
#' @param cutoff.size Numeric in \verb{[0, 1]}, the character size for
#'   the cutoff point symbol.
#' @param cutoff.shape Numeric. The point symbol used for the cutoff point
#'   plotted on the ROC. Defaults to a diamond (`23`).
#' @param boxes Logical. Should confidence interval boxes be drawn (showing the
#'   joint CI95 of the sensitivity and specificity confidence intervals) at the
#'   cutoff point?
#' @param box.alpha Numeric in \verb{[0, 1]}, the shading transparency for
#'   the confidence interval box at a given cutoff.
#' @param auc.label Character string. Adds an additional label to the AUC text
#'   (Default: "AUC = 0.99", with label "Extra Text": "Extra Text AUC = 0.99").
#'   Must be added individually to each plot.
#' @param plot.fit Logical/Character. Should a maximum-likelihood
#'   (or least-squares if ML fails) fit of the curve be plotted?
#'   If `plot.fit = "both"`, a fit will be _added_ to the ROC.
#'   If `plot.fit = TRUE`, only the fit will be plotted, without the ROC.
#' @param debug Logical. Should debugging mode be activated? When activated,
#'   annotates the values of the plotting steps at each cutoff, prints the
#'   "positive class", prints the prediction data to the console, and
#'   various other internal objects useful for debugging.
#' @param boot.auc Logical. Should bootstrap confidence intervals of AUC
#'   be calculated?
#' @param do.grid Logical. Should grid lines be added to the ROC curve?
#' @param pch,pch.cex,pch.cutoff,cutoff.cex,auc.cex Deprecated. Now use
#'   `shape`, `size`, `cutoff.shape`, `cutoff.size`, or `auc.size`.
#' @param ... Deprecated. Maintained for backwards compatibility.
#' @return A ROC curve is plotted and its corresponding AUC is returned.
#' @author Michael R. Mehan, Stu Field
#' @seealso [create_roc_data()], [roc_xy()], [geom_roc()]
#' @examples
#' true <- rep(c("control", "disease"), each = 50)
#' pred <- withr::with_seed(8,
#'           c(rnorm(50, mean = 0.4, sd = 0.2),    # control predictions
#'             rnorm(50, mean = 0.6, sd = 0.2))    # disease predictions
#'         )
#'
#' plotEmpROC(true, pred, pos.class = "disease", col = "dodgerblue")
#' plotEmpROC(true, pred, pos.class = "disease", ci95 = TRUE, boxes = FALSE, col = "red")
#'
#' plotEmpROC(true, pred, pos.class = "disease", ci95 = FALSE, shape = 21, col = "green")
#' plotEmpROC(true, pred, pos.class = "disease", boot.auc = TRUE, col = "royalblue")
#'
#' plotEmpROC(true, pred, pos.class = "disease", plot.fit = "both", col = "purple")
#' plotEmpROC(true, pred, pos.class = "disease", plot.fit = TRUE, ci95 = FALSE,
#'            auc = FALSE, cutoff = NA, col = 2, lwd = 4) # curve only, no cutoff
#'
#' # Debugging with `debug = TRUE` displays
#' # curve points to the console
#' plotEmpROC(true, pred, pos.class = "disease", debug = TRUE, col = "firebrick3")
#'
#' # Multiple curves can be drawn on the same plot
#' true2 <- rep(c("control", "disease"), each = 50)
#' pred2 <- withr::with_seed(8,
#'           c(rnorm(50, mean = 0.5, sd = 0.3),
#'             rnorm(50, mean = 0.7, sd = 0.4))
#'         )
#' plotEmpROC(true, pred, pos.class = "disease", col = "firebrick3") +
#'   plotEmpROC(true2, pred2, pos.class = "disease", col = "forestgreen", add = 1)
#' @importFrom ggplot2 geom_ribbon geom_point geom_text geom_segment annotate
#' @importFrom lifecycle is_present deprecated
#' @export
plotEmpROC <- function(truth, predicted, pos.class, auc = TRUE, add = 0L,
                       boot.auc = FALSE, adj = c(0, 0), auc.pos = c(0.5, 0.5),
                       auc.shift = 1.25, auc.label = NULL, auc.size = 5,
                       shape = NULL, size = 2, cutoff = 0.5, cutoff.size = 5,
                       cutoff.shape = 23, col = 1, ci95 = TRUE, lwd = 2,
                       outline = TRUE, boxes = TRUE, box.alpha = 0.35,
                       debug = FALSE, plot.fit = FALSE, do.grid = TRUE,
                       pch = deprecated(),
                       pch.cex = deprecated(),
                       pch.cutoff = deprecated(),
                       auc.cex = deprecated(),
                       cutoff.cex = deprecated(),
                       ... = deprecated()) {

  if ( missing(pos.class) ) {
    stop(
      "You *must* pass a `pos.class =` argument to `plotEmpROC()`.",
      call. = FALSE
    )
  }

  # Deprecated arguments ----
  # Parameters deprecated via ggplot2 syntax
  if ( is_present(pch) ) {
    stop("pch = ", pch, ". Do you mean `shape`?", call. = )
  }

  if ( is_present(pch.cex) ) {
    stop("pch.cex = ", pch.cex, ". Do you mean `size`?", call. = )
  }

  if ( is_present(pch.cutoff) ) {
    stop("pch.cutoff = ", pch.cex, ". Do you mean `cutoff.shape`?", call. = )
  }

  if ( is_present(auc.cex) ) {
    stop("auc.cex", pch.cex, ". Do you mean `aux.size`?", call. = )
  }

  if ( is_present(cutoff.cex) ) {
    stop("cutoff.cex", pch.cex, ". Do you mean `cutoff.size`?", call. = )
  }

  plot_df <- data.frame(truth = truth, pred = predicted)
  plot_df <- plot_df[order(plot_df$pred, decreasing = TRUE), ]

  if ( debug ) {
    writeLines(signal_rule("Debugging", line_col = "blue", lty = "double"))
    writeLines(signal_rule("Values Top", line_col = "cyan", lty = "double"))
    print(plot_df[1:6, ])
    writeLines(signal_rule("Values Bottom", line_col = "cyan", lty = "double"))
    print(plot_df[(nrow(plot_df) - 6):nrow(plot_df), ]) # Replacement for utils::tail()
    writeLines(signal_rule("Parameters", line_col = "magenta", lty = "double"))
    left  <- pad(c("pos.class", "boot.auc", "outline", "pch.cutoff", "add"), 10)
    right <- add_color(c(pos.class, boot.auc, outline, pch.cutoff, add), "red")
    writeLines(
      paste(add_color("\u2020", "green"), left, add_color("\u276F", "cyan"), right)
    )
    writeLines(signal_rule(line_col = "green", lty = "double"))
  }

  # Calculates x & y coordinates of ROC curve
  xy <- roc_xy(plot_df$truth, plot_df$pred, pos.class)

  if ( is.numeric(cutoff) && cutoff < 0 ) {
    cutoff <- get_max_cutoff(plot_df$truth, plot_df$pred, pos.class)
  }

  # Creates vector of ROC evaluations for each cutoff value
  ci95_vec <- create_roc_data(truth     = plot_df$truth,
                              predicted = plot_df$pred,
                              do.ci     = TRUE,
                              cutoffs   = cutoff,
                              pos.class = pos.class) |> unlist()

  # Creates plot mapping (to be applied when add = FALSE)
  p <- ggplot(data = as.data.frame(xy), aes(x = x, y = y)) +
    labs(x = "1 - Specificity", y = "Sensitivity") +
    SomaPlotr::theme_soma() +
    theme(panel.grid = element_blank())

  if ( do.grid ) {
    # Adding in a set of custom gridlines, if specified by the user
    p <- p + geom_abline(slope = 1, intercept = 0, size = 0.2,
                         linetype = "dashed", color = "grey") +
    theme(panel.grid.minor = element_line(linetype = "dashed",
                                          color = "#B9BDBE", size = 0.2),
          panel.grid.major = element_line(linetype = "dashed",
                                          color = "#B9BDBE", size = 0.2))
  }

  g <- list() # Initializing list to store annotations

  # Stores ROC curve & additional annotation geoms as lists,
  # enabling layering w/ another ROC plot (when add = TRUE)
  r <- list(geom_roc(data = as.data.frame(xy), aes(x = x, y = y),
                     col      = col,
                     outline  = outline,
                     lwd      = lwd,
                     lty      = 1,
                     shape    = if ( debug ) 13 else shape,
                     size     = ifelse(debug, 2, size)))

  f <- list(geom_rocfit(data = as.data.frame(xy),
                        col = col, lwd = lwd, lty = 1))

  if ( tolower(plot.fit) == "both" ) {
    g <- c(g, r, f)
  } else if ( isFALSE(plot.fit) ) {
    g <- c(g, r)
  } else if ( plot.fit ) {
    g <- c(g, f)
  }

  if ( ci95 ) {

    if ( boxes ) {
      ci95_mat <- rbind(sens = ci95_vec[c("sens_lowerCI", "sens_upperCI")],
                        spec = ci95_vec[c("spec_lowerCI", "spec_upperCI")])

      # Plots a shaded box that corresponds to the 95% joint binomial CI
      g <- c(g, list(add_ss_box(ci95_mat, col = col, alpha = box.alpha)))
    } else {
      roc_df <- create_roc_data(truth     = plot_df$truth,
                                predicted = plot_df$pred,
                                pos.class = pos.class,
                                cutoffs   = plot_df$pred,
                                do.ci     = TRUE)

      ci_tab <- roc_df[, grep("sens|spec", names(roc_df))]

      # Adds a cloud of points & segments representing the 95% CI
      g <- c(g, list(geom_point(data  = ci_tab,
                                aes(x = 1 - specificity, y = sensitivity),
                                fill  = col, color = col, size = 1, shape = 19),
                     geom_segment(data  = ci_tab,
                                  aes(x    = 1 - specificity,
                                      y    = sens_lowerCI,
                                      xend = 1 - specificity,
                                      yend = sens_upperCI), color = col, lty = 2),
                     geom_segment(data     = ci_tab,
                                  aes(x    = 1 - spec_upperCI,
                                      y    = sensitivity,
                                      xend = 1 - spec_lowerCI,
                                      yend = sensitivity), color = col, lty = 2)
      ))
    }
  }

  if ( debug ) {

    if ( !"roc_df" %in% ls() ) {
      roc_df <- create_roc_data(truth     = plot_df$truth,
                                predicted = plot_df$pred,
                                cutoffs   = plot_df$pred,
                                do.ci     = FALSE,
                                pos.class = pos.class)
    }

    # Adds text annotation layer to indicate values at
    # each point, for debugging purposes
    g <- c(g, list(geom_text(data  = roc_df,
                          aes(x = 1 - specificity,
                              y = specificity),
                          adj   = -0.25, size = 3, angle = -45,
                          label = sprintf("%0.3f", roc_df$cutoff)))
    )
  }

  if ( !cutoff.shape %in% c(0, 21:25) ) {
    stop(
      "The `cutoff.shape =` argument must be 21 - 25 ... ",
      "currently is: ", value(cutoff.shape), call. = FALSE
    )
  } else if ( is.numeric(cutoff) ) {
    # Plots a single point to indicate the chosen cutoff
    g <- c(g, list(geom_point(data  = as.data.frame(t(data.frame(ci95_vec))),
                        aes(x = 1 - specificity,
                            y = sensitivity),
                        size  = cutoff.size, shape = cutoff.shape,
                        fill  = "white", color = col)
    )
    )
  }
  # Calculates AUC based on specified method (bootstrapped vs. empirical)
  if ( boot.auc ) {
    auc_data <- calcBootAUC(plot_df$truth, plot_df$pred,
                            pos.class = pos.class,
                            nboot     = 1000,
                            r.seed    = 1001)  # bootstrapped CI95
  } else {
    auc_data <- calcEmpAUC(plot_df$truth, plot_df$pred,
                           pos.class = pos.class,
                           ci95 = TRUE)   # se +/- CI95 (DeLong's method)
  }

  # Adds an annotation layer displaying the AUC
  if ( auc ) {
    adj[2L] <- adj[2L] + auc.shift * add        # adjust the AUC vertical positioning
    auc_vals <- sprintf("%0.3f (%0.3f, %0.3f)", # so no AUC text overlap
                        auc_data$auc,
                        auc_data$lower.limit,
                        auc_data$upper.limit)
    g <- c(g, list(annotate("text",
                         x     = auc.pos[1L],
                         y     = auc.pos[2L],
                         label = paste(auc.label, "AUC:", auc_vals),
                         col   = col, size = auc.size,
                         hjust = adj[1L],
                         vjust = adj[2L])
           )
    )
  }

  if ( debug ) {
    print(as_tibble(roc_df))
    message("Please note: the 'size' and 'shape' arguments are locked
            when in debugging mode and cannot be modified.")
    p + g
  } else if ( add ) {
    invisible(g) # Returns the "window dressing" (aka annotations) only
  } else {
    p + g # Returns base plot mapping & ROC curve with annotations
  }
}
