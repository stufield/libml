#' Create Training Data Object
#'
#' Generate a training data set from a original parent data set
#' typically via some subset of the original parent. Final groups
#' _must_ be binary, and generate a 2 factor level "Response"
#' column used in many downstream statistical testing functions
#' throughout the \pkg{somaverse} environment.
#'
#' @param data A `soma_adat` object used to create a training data set.
#' @param ... Arguments passed to [filter()] used to
#'   subset unwanted rows from the data set.
#'
#' __Note:__ that when specifying filtering variables, the factor levels
#'   will be ordered _alphabetically_ in the resulting "Response"
#'   variable unless ordering is specified by the `class1` and
#'   `class2` arguments. This is important when performing
#'   [calc.t()], which performs t-tests as \eqn{level2 - level1}.
#'
#'   If passing to the S3 plot method for objects of class `tr_data`,
#'   additional arguments are passed to [SomaPlotr::plotCDFbyGroup()]
#'   via the `...`.
#' @param group.var Either a quoted or unquoted string for the `Response` column.
#'   Must a column contained within `data`.
#' @param class1 Character. The string to be mapped to the _first_
#'   class/level if a _new_ class name is desired. No mapping is performed
#'   by default.
#' @param class2 Character. The string to be mapped the _second_
#'   class/level if a _new_ class name is desired. No mapping is performed
#'   by default.
#' @return A "grouped tibble" table (class "tbl"), with a `tr_data`
#'   class added. This object contains the subset training data with a
#'   "Response" column appended that contains the _binary_ groupings.
#' @author Stu Field
#' @seealso [dplyr::filter()],
#' @examples
#' # Creating new "tr_data" object
#' # with default factor levels
#' trda <- createTrainingData(sim_test_data, gender %in% c("F", "M"),
#'                            group.var = gender)
#' trda$Response
#'
#' # Getting Variables
#' dplyr::group_vars(trda)
#' splyr::group_labels(trda)
#'
#' # with re-naming factors
#' trda2 <- createTrainingData(sim_test_data, gender %in% c("F", "M"),
#'                             group.var = gender,
#'                             class1 = "Female", class2 = "Male")
#' trda2$Response
#'
#' # with re-naming factors AND re-ordering
#' trda3 <- createTrainingData(sim_test_data, gender %in% c("F", "M"),
#'                             group.var = gender,
#'                             class1 = "Male", class2 = "Female")
#' trda3$Response
#'
#' @importFrom stats setNames
#' @export
createTrainingData <- function(data, ..., group.var = SampleGroup,
                               class1 = NULL, class2 = NULL) {

  if ( is.tr_data(data) ) {
    stop(
      "The `data =` object is already a `tr_data` class object.",
      call. = FALSE
    )
  }

  re_name <- !(is.null(class1) | is.null(class2))

  tdata <- dplyr::filter(data, ...)
  tdata$Response <- factor(eval(as.name(substitute(group.var)), envir = tdata))
  if ( re_name ) {
    old_levels <- levels(tdata$Response)
    key <- setNames(c(class1, class2), old_levels)
    tdata$Response <- dplyr::recode_factor(tdata$Response, !!!key)
  }

  nms   <- names(attributes(data))          # remember atts order
  tdata <- tdata[order(tdata$Response), ]   # order by Response

  levs <- levels(tdata$Response)
  if ( !isTRUE(all.equal(sort(unique(as.character(tdata$Response))), levs)) ) {
    signal_todo(
      "Note: Class order is non-alphabetic:",
      value(paste(levs, collapse = " > "))
    )
  }
  tdata <- dplyr::group_by(tdata, Response)
  attributes(tdata) <- attributes(tdata)[c(nms, "groups")]   # orig order atts
  addClass(tdata, "tr_data")
}


#' Test for Training Data objects
#'
#' [is.tr_data()] checks whether an object
#' is a `tr_data` class object.
#'
#' @rdname createTrainingData
#' @return Logical. Whether `data` inherits from class `tr_data`.
#' @export
is.tr_data <- function(data) {
  inherits(data, "tr_data")
}


#' Convert to training data
#'
#' Convert a standard data frame object with a "Response"
#' field into a `tr_data` object. This is a bypass
#' around the typical [createTrainingData()] process
#' if the training data was filtered via other methods.
#'
#' @rdname createTrainingData
#' @author Stu Field
#' @examples
#' # Converting -> `tr_data`
#' convert2TrainingData(iris, Species)               # Can be un-quoted
#' new_td <- convert2TrainingData(iris, "Species")   # or quoted
#' new_td
#' class(new_td)
#'
#' @export
convert2TrainingData <- function(data, group.var) {
  stopifnot(inherits(data, c("soma_adat", "data.frame")))
  is_adat <- is.soma_adat(data)
  gr_sym  <- as.name(substitute(group.var))
  data    <- data[order(eval(gr_sym, data)), ]   # order by group var
  out_class <- if ( is_adat ) c("tr_data", "soma_adat") else "tr_data"
  data |>
    dplyr::mutate(Response = !!gr_sym) |>
    dplyr::mutate(Response = droplevels(factor(Response))) |>
    dplyr::group_by(Response) |>
    addClass(out_class)
}


#' @describeIn createTrainingData
#' Plots a CDF, and optionally an accompanying smoothed PDF
#'   for a specific feature (analyte) in a "tr_data" object.
#'
#' @param x A `tr_data` object created via either
#'   [createTrainingData()] or [convert2TrainingData()].
#' @param apt Character. The name of a column in `data` containing RFU values
#'   to generate CDFs or PDFs.
#' @param main Character. Title for the plot. See [ggplot2::ggtitle()].
#' @param do.log Logical. Should RFU values be log10-transformed prior to
#'   plotting?
#' @param do.pdfs Logical. Should smoothed densities PDF be plotted?
#' @seealso [SomaPlotr::plotCDFbyGroup()], [createTrainingData()]
#' @examples
#' # S3 plot method
#' apt <- "seq.1130.49"  # random feature
#' plot(trda, apt)
#'
#' plot(trda, apt, cols = c("blue", "red"))
#'
#' plot(trda, apt, cols = c("black", "black"))   # b/w
#'
#' plot(trda, apt, do.pdfs = TRUE)
#'
#' plot(trda, apt, do.pdfs = TRUE, cols = c("blue", "red"))
#' @export
plot.tr_data <- function(x, apt, do.log = TRUE, main = apt,
                         do.pdfs = FALSE, ...) {
  if ( do.log ) {
    x <- log10(x)
  }
  if ( do.pdfs ) {
    p_fun <- SomaPlotr::plotPDFbyGroup
  } else {
    p_fun <- SomaPlotr::plotCDFbyGroup
  }
  p_fun(data = x, apt = apt, group.var = Response, main = main, ...)
}
