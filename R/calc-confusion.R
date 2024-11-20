#' Calculate confusion matrix
#'
#' Calculate a confusion matrix from a series of predictions,
#'   true class names and a decision cutoff. Returns a
#'   \verb{2x2} confusion matrix. It is imperative that the
#'   *positive* class is clearly defined to avoid  ambiguity
#'   with factor levels, therefore passing `pos.class =` argument
#'   is *not* optional.
#'   See `Details` for assumptions about the table layout.
#'
#' Assume a \verb{2x2} table with notation:
#'
#' \tabular{rcc}{
#'             \tab Predicted \tab \cr
#'    Truth    \tab negative  \tab positive \cr
#'    negative \tab _TN_      \tab _FP_ \cr
#'    positive \tab _FN_      \tab _TP_
#' }
#'
#' where:
#' \deqn{TN = True Negative}
#' \deqn{TP = True Positive}
#' \deqn{FN = False Negative}
#' \deqn{FP = False Positive}
#'
#' The `summary` calculations are:
#' \deqn{Sensitivity = Recall = TP / (TP + FN)}
#' \deqn{Specificity = TN / (TN + FP)}
#' \deqn{Precision = PPV = TP / (TP + FP)}
#' \deqn{NPV = TN / (TN + FN)}
#' \deqn{Accuracy = (TP + TN) / (TP + FN + TN + FP)}
#' \deqn{Balanced Accuracy = (Sensitivity + Specificity) / 2}
#' \deqn{Prevalence = (FN + TP) / (TP + FN + TN + FP)}
#' \deqn{Matthew's Correlation Coefficient = TP x TN - FP x FN /
#'                             sqrt( (TP + FP) (TP + FN) (TN + FP) (TN + FN) )}
#'
#' @inheritParams params
#' @author Stu Field
#'
#' @param ... Arguments passed to the `print` and `summary` generics.
#'
#' @return An object of class `confusion_matrix`, with the _True_ values
#'   along the y-axis and _Predicted_ values along the x-axis.
#'
#' @examples
#' n <- 20
#' withr::with_seed(22, {
#'   true <- sample(c("control", "disease"), n, replace = TRUE)
#'   pred <- runif(n)
#' })
#' (c_mat <- calc_confusion(true, pred, pos.class = "disease"))
#'
#' calc_confusion(true, pred, pos.class = "disease", 0.75)    # specify cutoff
#'
#' # factor levels of `truth` are ignored
#' # The `pos.class` argument is respected always
#' true_a <- factor(true, levels = c("control", "disease"))
#' true_b <- factor(true, levels = c("disease", "control"))
#' a <- calc_confusion(true_a, pred, pos.class = "disease")
#' b <- calc_confusion(true_b, pred, pos.class = "disease")
#' identical(a, b)
#'
#' @export
calc_confusion <- function(truth, predicted, pos.class, cutoff = 0.5) {

  stopifnot(length(truth) == length(predicted))

  if ( !inherits(truth, c("factor", "character", "integer")) ) {
    stop(
      "Please ensure 'truth' is a factor, or can easily be ",
      "coerced to one. Current class: ", value(class(truth)),
      call. = FALSE
    )
  }

  if ( missing(pos.class) ) {
    stop(
      "You must pass a `pos.class` argument specifying the event class.",
      call. = FALSE
    )
  }

  if ( length(unique(truth)) != 2L ) {
    stop(
      "There do not appear to be a binary classes: ",
      value(unique(truth)), call. = FALSE
    )
  }

  if ( !pos.class %in% truth ) {
    stop(
      "Your choice of `pos.class` is not contained in `truth`. ",
      "Please choose one of: ", value(unique(truth)), call. = FALSE
    )
  }

  # safe b/c binary check above
  neg  <- setdiff(truth, pos.class)
  # order: control/non-event class 1st
  levs <- c(neg, pos.class)
  truth_factor <- factor(truth, levels = levs)

  data.frame(
      # re-factoring here ensures that the pos.class argument is obeyed
      Truth     = truth_factor,
      Predicted = factor(ifelse(predicted >= cutoff, pos.class, neg),
                         levels = levs)
  ) |>
    table() |>
    structure(
      pos.class = as.character(pos.class),
      class     = c("confusion_matrix", "table"),
      auc       = calc_auc(truth, predicted),
      brier     = calc_brier(truth_factor, predicted)
    )
}

#' @describeIn calc_confusion
#'   S3 print method for classes `confusion_matrix`.
#'
#' @param x A `confusion_matrix` or `summary_confusion_matrix` class object.
#'
#' @export
print.confusion_matrix <- function(x, ...) {
  signal_rule("Confusion", line_col = "green")
  cat("\n")
  cat("Positive Class: ", attributes(x)$pos.class, "\n\n", sep  = "")
  NextMethod()
  cat("\n")
  invisible(x)
}


#' @describeIn calc_confusion
#'   Calculates the confusion statistics from a confusion matrix.
#'
#' @param object A `confusion_matrix` object, created via
#'   [calc_confusion()].
#'
#' @return Summary method returns a list object of class
#'   `summary_confusion_matrix` consisting of:
#'   \item{confusion:}{The class counts based on the confusion matrix.}
#'   \item{metrics:}{Performance metric estimates, `n`, and associated
#'     binomial 95% confidence intervals. Note that `MCC` has a range in
#'     \verb{[-1, 1]}, therefore confidence intervals are not calculated for this
#'     metric ([calc_ci_binom()] expects a probability value).}
#'   \item{stats:}{F-measure, G-mean, and Weighted Accuracy.}
#'
#' @seealso [calc_confusion()]
#' @references The Statistical Evaluation of Medical Tests for Classification
#'   and Prediction. 2004. Margaret Pepe, Altman, DG, Bland, JM. 1994.
#'   "Diagnostic tests 1: sensitivity and specificity", British Medical
#'   Journal, vol 308, 1552.
#'
#' @examples
#' # S3 summary method
#' summary(c_mat)
#' @importFrom tibble tribble
#' @importFrom dplyr rename bind_rows
#' @export
summary.confusion_matrix <- function(object, ...) {

  tn <- object[1L, 1L]
  tp <- object[2L, 2L]
  fn <- object[2L, 1L]
  fp <- object[1L, 2L]
  n  <- tn + fp
  p  <- tp + fn
  sensitivity <- tp / (tp + fn)    # true pos rate
  specificity <- tn / (tn + fp)    # true neg rate
  precision   <- tp / (tp + fp)    # PPV
  fpr         <- fp / (fp + tn)    # false pos rate # nolint: object_usage_linter.
  npv         <- tn / (tn + fn)    # NPV
  accuracy    <- (tp + tn) / (tp + fn + tn + fp)
  beta        <- 0.75

  # For MCC calculation
  d1 <- tp + fp
  d2 <- tp + fn
  d3 <- tn + fp
  d4 <- tn + fn

  if ( any(c(d1, d2, d3, d4) == 0L) ) {
    mcc <- NA_real_
  } else {
    mcc <- ((tp * tn) - (fp * fn)) / sqrt(prod(d1, d2, d3, d4))
  }

  stats <- c(F_measure = (2 * precision * sensitivity) / (precision + sensitivity),
             G_mean    = (specificity * sensitivity)^0.5,
             Wt_Acc    = beta * sensitivity + (1 - beta) * specificity)

  metrics <- tribble(
    ~metric,          ~n,             ~p,
    "Sensitivity",     p,              sensitivity,
    "Specificity",     n,              specificity,
    "PPV (Precision)", tp + fp,        precision,
    "NPV",             tn + fn,        npv,
    "Accuracy",        n + p,          accuracy,
    "Bal Accuracy",    n + p,          (sensitivity + specificity) / 2,
    "Prevalence",      n + p,          (fn + tp) / (tp + fn + tn + fp),
    "AUC",             n + p,          attr(object, "auc"),
    "Brier Score",     n + p,          attr(object, "brier"),
    "MCC",             NA_integer_,    mcc
  )
  ci <- liter(metrics$p, metrics$n, .f = calc_ci_binom) |>
    bind_rows()
  metrics$CI95_lower <- ci$lower  # pull lower CI95
  metrics$CI95_upper <- ci$upper  # pull upper CI95
  metrics <- rename(metrics, "estimate" = p)   # rename p -> estimate
  structure(
    list(confusion = object, metrics = metrics, stats = stats),
    class = c("summary_confusion_matrix", "list")
  )
}


#' @describeIn calc_confusion
#'   S3 print method for class `summary_confusion_matrix`.
#'
#' @export
print.summary_confusion_matrix <- function(x, ...) {
  signal_rule("Confusion Matrix Summary", line_col = "blue", lty = "double")
  print(x$confusion)
  signal_rule("Performance Metrics (CI95%)", line_col = "green")
  cat("\n")
  print(x$metrics)
  cat("\n")
  signal_rule("Additional Statistics", line_col = "green")
  cat("\n")
  print(round(x$stats, 3L))
  invisible(x)
}
