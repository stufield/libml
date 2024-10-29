#' Create a Training Data Object
#'
#' Generate a training data set from a original parent data set
#' typically via some subset of the original parent. Final groups
#' _must_ be binary, and generate a 2 factor level "Response"
#' column used in many downstream statistical testing functions.
#'
#' When specifying filtering variables, the factor levels
#' will be ordered _alphabetically_ in the resulting "Response"
#' variable unless ordering is specified by the `classes`
#' argument. This is important, for example, when performing
#' repeated univariate statistics where \eqn{class2 - class1},
#' i.e. the positive class is 2!
#'
#' @param data A `data.frame` used to create a training data set.
#' @param ... Arguments passed to [filter()] used to subset *rows*.
#'   If passing to the S3 plot method for objects of class `tr_data`,
#'   additional arguments are passed to [SomaPlotr::plotCDFbyGroup()]
#'   via the `...`.
#' @param group.var Either a quoted or unquoted string.
#'   Must a column contained within `data`.
#' @param classes Either `NULL`, where no factor conversion will be
#'   performed (default), or a string `character(2)` indicating _first_
#'   and _second_ class labels respectively. See the Details section
#'   for more information about factor levels.
#' @return A `"tibble"` with a `tr_data` class added.
#'   This object contains the subset training data with a
#'   additional attributes about the groupings and the "Response" variable.
#' @author Stu Field
#' @seealso [dplyr::filter()]
#' @examples
#' # New "tr_data" object with default factor levels
#' classes <- c("setosa", "versicolor")
#' tr <- create_train(iris, Species %in% classes, group.var = Species)
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
#'                     group.var = Species, classes = rev(classes))
#' attr(tr2, "counts")
#' @importFrom stats setNames
#' @export
create_train <- function(data, ..., group.var, classes = NULL) {

  if ( is.tr_data(data) ) {
    warning(
      "This object is already a `tr_data` class object.",
      call. = FALSE
    )
    return(data)
  }

  gr_sym <- as.name(substitute(group.var))
  var    <- as.character(substitute(group.var))
  if ( identical(var, "") ) {
    stop("The `group.var` param must be passed.", call. = FALSE)
  }
  nms   <- names(attributes(data))         # remember atts order
  tdata <- dplyr::filter(data, ...) |> droplevels()
  tdata <- dplyr::arrange(tdata, !!gr_sym) # order by response
  levs  <- NULL

  if ( !is.null(classes) ) {
    stopifnot("`classes` param must be `character(2)`." =
                length(classes) == 2L && is.character(classes))
    neg.class <- classes[1L]
    pos.class <- classes[2L]
    levs  <- c(neg.class, pos.class)
    tdata <-tdata |>
      dplyr::mutate(!!gr_sym := factor(!!gr_sym, levels = levs))
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
#' is a `tr_data` class object.
#'
#' @rdname create_train
#' @return Logical. Whether `data` inherits from class `tr_data`.
#' @export
is.tr_data <- function(data) {
  inherits(data, "tr_data")
}

#' @noRd
#' @export
print.tr_data <- function(x, ...) {
  writeLines(
    signal_rule("Training Data Object", lty = "double", line_col = "green")
  )
  key <- c("response", "class labels", "counts", "factor", "n") |> pad(15)
  value <- list(response = .get_response(x),
                classes  = value(attr(x, "class_labels")),
                counts   = sprintf("[%s]", value(attr(x, "counts"))),
                factor   = attr(x, "is_factor"),
                n        = attr(x, "n_groups"))
  liter(key, value, function(.x, .y) {
    writeLines(paste(add_style$red(symbl$bullet), .x, .y))
  })
  writeLines(signal_rule(line_col = "blue"))
  NextMethod()
  invisible(x)
}

#' @describeIn create_train
#' Plots a CDF, and optionally an accompanying smoothed PDF
#'   for a specific feature (analyte) in a "tr_data" object.
#'
#' @param x A `tr_data` object.
#' @param ft Character. The name of a column in `data` containing values
#'   to generate CDFs or PDFs.
#' @param main Character. Title for the plot. See [ggplot2::ggtitle()].
#' @param do.log Logical. Should RFU values be log10-transformed prior to
#'   plotting?
#' @param do.pdfs Logical. Should smoothed densities PDF be plotted?
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
#' plot(tr, ft, do.pdfs = TRUE)
#'
#' plot(tr, ft, do.pdfs = TRUE, cols = c("blue", "red"))
#' @export
plot.tr_data <- function(x, ft, main = ft, do.pdfs = FALSE,
                         do.log = TRUE, ...) {
  if ( do.log ) {
    x[[ft]] <- log10(x[[ft]])
  }
  if ( do.pdfs ) {
    p_fun <- SomaPlotr::plotPDFbyGroup
  } else {
    p_fun <- SomaPlotr::plotCDFbyGroup
  }
  gr <- str2lang(attr(x, "response_var"))
  p_fun(data = x, apt = ft, group.var = !!gr, main = main, ...)
}
