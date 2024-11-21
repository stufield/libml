#' Create a Training Data Object
#'
#' Generate a training data set from a original parent data set
#'   typically via some subset of the original parent. Final groups
#'   *must* be binary, and generate a 2 factor level "response"
#'   column used in many downstream statistical testing functions.
#'
#' When specifying filtering variables, the factor levels
#'   will be ordered *alphabetically* in the resulting "response"
#'   variable unless ordering is specified by the `classes`
#'   argument. This is important, for example, when performing
#'   repeated univariate statistics where \eqn{class2 - class1},
#'   i.e. the positive class is 2!
#'
#' @param data A `data.frame` used to create a training data set.
#' @param ... Arguments passed to [filter()] used to subset *rows*.
#'   If passing to the S3 plot method for `tr_data` class objects,
#'   additional arguments are passed to [SomaPlotr::plotCDFbyGroup()]
#'   via the `...`.
#' @param group_var `character(1)`. Can be quoted or unquoted.
#'   Must be a column name of `data`.
#' @param classes Either `NULL`, where no factor conversion will be
#'   performed (default), or a string `character(2)` indicating *first*
#'   and *second* class labels respectively. See the Details section
#'   for more information about factor levels.
#'
#' @return A `tibble` with an additional `tr_data` class.
#'   This object contains the subset training data with a
#'   additional attributes about the groupings and the
#'   "response" variable.
#'
#' @author Stu Field
#' @seealso [dplyr::filter()]
#'
#' @examples
#' # New "tr_data" object with default factor levels
#' classes <- c("setosa", "versicolor")
#' tr <- create_train(iris, Species %in% classes, group_var = Species)
#' tr
#'
#' # Getting Variables
#' attr(tr, "response_var")
#'
#' attr(tr, "class_labels")
#'
#' attr(tr, "counts")
#'
#' # with re-naming factors
#' tr2 <- create_train(iris, Species %in% classes,
#'                     group_var = Species, classes = rev(classes))
#' tr2
#' @importFrom stats setNames
#' @export
create_train <- function(data, ..., group_var, classes = NULL) {

  if ( is.tr_data(data) ) {
    warning(
      "This object is already a `tr_data` class object.",
      call. = FALSE
    )
    return(data)
  }

  gr_sym <- as.name(substitute(group_var))
  var    <- as.character(substitute(group_var))
  if ( identical(var, "") ) {
    stop("The `group_var` param must be passed.", call. = FALSE)
  }
  nms   <- names(attributes(data))         # remember atts order
  tdata <- dplyr::filter(data, ...) |> droplevels()
  tdata <- dplyr::arrange(tdata, !!gr_sym) # order by response
  tdata[[var]] <- factor(tdata[[var]])
  levs  <- levels(tdata[[var]])

  if ( !is.null(classes) ) {
    stopifnot("`classes` param must be `character(2)`." =
                length(classes) == 2L && is.character(classes))
    levs  <- c(classes[1L], classes[2L])
    levels(tdata[[var]]) <- levs
  }

  tdata    <- tibble::as_tibble(tdata)
  resp_vec <- tdata[[var]]

  if ( !is.null(classes) &&
       !isTRUE(all.equal(sort(unique(as.character(resp_vec))), levs)) ) {
    signal_todo(
      "Note: Class order is non-alphabetic:",
      value(paste(levs, collapse = " > "))
    )
  }

  tbl <- c(table(resp_vec))
  attributes(tdata) <- attributes(tdata)[nms] # orig order atts
  attr(tdata, "response_var") <- var
  attr(tdata, "is_factor")    <- is.factor(resp_vec)
  attr(tdata, "counts")       <- tbl
  attr(tdata, "class_labels") <- names(tbl)
  attr(tdata, "n_groups")     <- length(tbl)
  structure(tdata, class = c("tr_data", "tbl_df", "tbl", "data.frame"))
}


#' Test for Training Data objects
#'
#' [is.tr_data()] checks whether an object
#'   is a `tr_data` class object.
#'
#' @rdname create_train
#'
#' @return Logical. Whether `data` inherits from class `tr_data`.
#'
#' @export
is.tr_data <- function(data) {
  inherits(data, "tr_data")
}

#' @noRd
#' @export
print.tr_data <- function(x, ...) {
  signal_rule("Training Data Object", lty = "double", line_col = "green")
  key <- c("response", "class labels", "counts", "factor", "n") |> pad(15)
  value <- list(response = .get_response(x),
                classes  = value(attr(x, "class_labels")),
                counts   = sprintf("[%s]", value(attr(x, "counts"))),
                factor   = attr(x, "is_factor"),
                n        = attr(x, "n_groups"))
  liter(key, value, function(.x, .y) {
    writeLines(paste(add_style$red(symbl$bullet), .x, .y))
  })
  signal_rule(line_col = "blue")
  NextMethod()
  invisible(x)
}

#' @describeIn create_train
#'   Plots a CDF, and optionally an accompanying smoothed PDF
#'   for a specific feature (analyte) in a "tr_data" object.
#'
#' @param x A `tr_data` object.
#' @param ft `character(1)`. The name of a column in `data`
#'   containing values to generate CDFs or PDFs.
#' @param main `character(1)`. Title for the plot. See [ggplot2::ggtitle()].
#' @param do_log `logical(1)`. Should values be log10-transformed?
#' @param do_pdfs `logical(1)`. Should smoothed densities PDF be plotted?
#'
#' @seealso [SomaPlotr::plotCDFbyGroup()]
#' @examples
#' # S3 plot method
#' ft <- "Sepal.Length"  # random feature
#' plot(tr, ft)
#'
#' plot(tr, ft, cols = c("blue", "red"))
#'
#' plot(tr, ft, cols = c("black", "black"))   # b/w
#'
#' plot(tr, ft, do_pdfs = TRUE)
#'
#' plot(tr, ft, do_pdfs = TRUE, cols = c("blue", "red"))
#' @export
plot.tr_data <- function(x, ft, main = ft, do_pdfs = FALSE,
                         do_log = TRUE, ...) {
  if ( do_log ) {
    x[[ft]] <- log10(x[[ft]])
  }
  if ( do_pdfs ) {
    p_fun <- SomaPlotr::plotPDFbyGroup
  } else {
    p_fun <- SomaPlotr::plotCDFbyGroup
  }
  gr <- str2lang(attr(x, "response_var"))
  p_fun(data = x, apt = ft, group.var = !!gr, main = main, ...)
}
