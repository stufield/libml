#' Robustly Fit Naive Bayes Classifier
#'
#' Computes the conditional _a_-posterior probabilities of a
#'   categorical class variable given independent predictor
#'   variables using the Bayes rule.
#'   Parameter estimates are robustly calculated using approximations
#'   of the error function for a Gaussian density, see [fit_gauss()].
#'
#' When `mad = TRUE` (median absolute deviation), non-parametric
#'   calculation of Bayes' parameters are estimated,
#'   namely, `mu = median(x)` and `sd = IQR(x) / 1.349`.
#'   That is, `fit_gauss(..., mad = TRUE)`.
#'
#' @family fit
#'
#' @param x A numeric matrix, a `tr_data` class objects, or a data frame
#'   of predictors. If called from an S3 generic method (e.g.
#'   [plot.libml_nb()]) or [print.libml_nb()]), either a
#'   `libml_nb` or `naiveBayes` object.
#' @param y `factor(n)`. If not passing a formula, a factor with
#'   true class names for each sample (row) in `x`.
#' @param mad `logical(1)`. Should non-parametric approximations be
#'   applied during the parameter estimation procedure. See `Details`.
#' @param laplace `double(1)`. Positive controlling Laplace smoothing.
#'   The default (`0`) disables Laplace smoothing.
#' @param ... Additional arguments passed to the default [fit_nb()]
#'   default method. Currently not used in the `predict` or `print` S3 methods,
#'   but is used in the S3 plot method, arguments passed to
#'   [SomaPlotr::plotCDFlist()] or [SomaPlotr::plotPDFlist()].
#' @param keep.data Logical. Should the training data used to fit the model be
#'   included in the model object? When building thousands of models, this can
#'   become a memory issue and thus the default is `FALSE`.
#'
#' @return `libml_nb`: A naive Bayes model with robustly fit parameters.
#' @author Stu Field
#' @seealso [fit_gauss()]
#'
#' @references This function was _heavily_ influenced by [e1071::naiveBayes()]
#'   See David Meyer <email: David.Meyer@R-project.org>.
#'
#' @examples
#' head(tr_iris)
#' # standard naive Bayes
#' m1 <- e1071::naiveBayes(Species ~ ., data = tr_iris) # non-robust params
#' m2 <- fit_nb(Species ~ ., data = tr_iris)  # formula syntax
#' m3 <- fit_nb(tr_iris)                      # tr_data syntax
#' m4 <- data.frame(tr_iris[, -5L]) |>
#'   fit_nb(y = tr_iris$Species)              # default syntax
#'
#' # not same
#' identical(sapply(m1$tables, as.numeric), sapply(m2$tables, as.numeric))
#'
#' # same
#' identical(sapply(m2$tables, as.numeric), sapply(m3$tables, as.numeric))
#'
#' @importFrom stats predict sd
#' @export
fit_nb <- function(x, ...) UseMethod("fit_nb")


#' @describeIn fit_nb
#'   S3 `default` method for fit_nb.
#'
#' @export
fit_nb.default <- function(x, y, mad = FALSE, laplace = 0,
                           keep.data = FALSE, ...) {

  response <- .get_response(x) %||% "y"

  if ( !is.factor(y) ) {
    warning(
      "The `y` argument is a ", value(class(y)), " class vector, methods ",
      "will perform better if `y` is a factor.", call. = FALSE
    )
  }
  if ( is.null(dim(x)) ) {
    stop(
      "Argument `x` appears to be a vector.\n",
      "Are you trying to build a 1 marker model?\n",
      "Please ensure `x` is a 1 column, named, data frame or tibble.",
      call. = FALSE
    )
  }
  if ( !inherits(x, "data.frame") ) {
    x <- as.data.frame(x)
  }

  if ( response %in% names(x) ) {
    stop("The variable ", value(response), " is included in the predictors.\n",
         "It is unlikely this was intentional!", call. = FALSE)
  }

  # estimation local function
  .estimate <- function(var) {
    if ( is.numeric(var) && !is_int_vec(var) ) {
      do.call(
        "rbind",
        tapply(var, y, function(.x) fit_gauss(.x, mad = mad))
      )
    } else if ( is.numeric(var) && is_int_vec(var) ) {
      cbind(mu    = tapply(var, y, mean, na.rm = TRUE),
            sigma = tapply(var, y, sd, na.rm = TRUE))
    } else {
      # this part doesn't make sense to me; sgf
      # See ?e1071::naiveBayes documentation
      tab <- table(y, var)
      (tab + laplace) / (rowSums(tab) + laplace * nlevels(var))
    }
  }

  # create tables
  tables <- lapply(x, .estimate)

  # fix names of dimnames
  for ( i in seq_len(length(tables)) ) {
    names(dimnames(tables[[i]])) <- c(response, colnames(x)[i])
  }

  apriori <- table(y)
  names(dimnames(apriori)) <- response

  ret <- list()
  ret$apriori <- apriori
  ret$tables  <- tables
  ret$levels  <- levels(y)
  ret$response <- response
  resp_df     <- setNames(data.frame(y), response)
  ret$data    <- if ( keep.data ) cbind(x, resp_df) else FALSE # nolint
  ret$call    <- list(...)$orig_call %||% match.call(expand.dots = FALSE)
  add_class(ret, "libml_nb")
}


#' @describeIn fit_nb
#'   S3 `formula` method for fit_nb.
#'
#' @param formula A model formula of the form: `class ~ x1 + x2 + ...`
#'   (no interactions).
#' @param data A data frame of predictors (categorical and/or numeric), i.e.
#'   the ADAT used to train the model.
#'
#' @export
fit_nb.formula <- function(formula, data, ...) {
  if ( !inherits(data, "data.frame") ) {
    stop(
      "The robust naiveBayes formula interface handles data frames only.\n",
      "Please ensure the `data` argument is a `data.frame` class object.",
      call. = FALSE)
  }
  response <- as.character(formula[[2L]])
  X <- stats::model.frame(formula, data)
  idx <- which(names(X) %in% response)   # remove response
  call <- list(...)$orig_call %||% match.call(expand.dots = TRUE)
  fit_nb(
    structure(X[, -idx, drop = FALSE], response_var = response), # add for downstream
    X[[response]],
    orig_call = call,
    ...
  )
}


#' @describeIn fit_nb
#'   S3 `tr_data` method for fit_nb.
#'
#' @export
fit_nb.tr_data <- function(x, ...) {
  call <- match.call(expand.dots = FALSE)
  response <- .get_response(x)
  y    <- x[[response]]
  idx  <- names(x) %in% response
  x    <- as_tibble(x[, !idx])  # strip class but not attrs
  fit_nb(x = x, y = y, orig_call = call, ...)
}


#' @describeIn fit_nb
#'   S3 print method for `libml_nb`.
#'
#' @export
print.libml_nb <- function(x, ...) {
  cat("\nRobust Naive Bayes Classifier for Discrete Predictors\n\n")
  cat("Call:\n")
  print(x$call)
  cat("\nA-priori probabilities:\n")
  print(prop.table(x$apriori))
  cat("\nConditional densities:\n")
  l   <- length(x$levels)
  sum <- vapply(x$tables, as.vector, FUN.VALUE = numeric(l * 2))
  rownames(sum) <- paste0(rep(x$levels, 2L), "_", rep(c("mu", "sigma"), each = l))
  sum <- as_tibble(sum, rownames = "parameter")
  print(sum)
  cat("\n")
  invisible(sum)
}


#' @describeIn fit_nb
#'   S3 predict method for `libml_nb`.
#'
#' @param object A `libml_nb` model object.
#' @param newdata A `data.frame` with new predictors, containing at least
#'   the model covariates (possibly more columns than the training data).
#'   Note that the column names of `newdata` are matched against the
#'   training data.
#' @param type If `"class"` (default), the class name with maximal
#'   posterior probability is returned for each sample, otherwise the
#'   conditional *a-posterior* probabilities for each class are returned.
#'   Additionally, if called from within the S3 plot method, a character
#'   string determining the plot type, currently either CDF or PDF (default).
#'   Argument can be shortened and is matched.
#' @param threshold `numeric(1)`. Indicating the minimum probability
#'   a prediction can take.
#'
#' @return `predict.libml_nb`: depending on the `type` argument,
#'   either the predicted class name or the posterior probability
#'   of a robustly estimated naive Bayes model.
#'
#' @examples
#' # Predictions
#' table(predict(m1, iris), iris$Species) # benchmark
#' table(predict(m2, iris), iris$Species) # approx same for Gaussian data; no outliers
#'
#' @importFrom stats dnorm
#' @export
predict.libml_nb <- function(object, newdata,
                             type = c("class", "posterior", "raw"),
                             threshold = NULL, ...) {

  type <- match.arg(type)
  # map to either posterior or raw
  type      <- switch(type, class = "class", raw = , posterior = "posterior")
  newdata   <- as.data.frame(newdata)
  new_names <- names(newdata)
  features  <- match(names(object$tables), new_names)  # matched index col #
  features  <- new_names[features]

  if ( length(features) == 0L ) {
    stop("No common features between `model` and `newdata`.", call. = FALSE)
  }

  isnumeric <- vapply(newdata, is.numeric, FUN.VALUE = NA)
  stopifnot(
    "All features must be numeric." = all(isnumeric[features])
  )
  prior <- log(prop.table(c(object$apriori)))
  pars  <- object$tables[features] |> # ensure order
    do.call(what = rbind)
  levs  <- object$levels
  L     <- length(levs)

  LL <- apply(newdata[, features, drop = FALSE], 1, function(row) {
    mu_vec <- pars[, "mu"]
    sd_vec <- pars[, "sigma"]
    sd_vec[sd_vec == 0] <- 1e-06  # limit sd=0 (??? sgf???)
    sample_vec <- rep(row, each = L)
    probs <- dnorm(sample_vec, mean = mu_vec, sd = sd_vec)

    if ( !is.null(threshold) ) {
      stopifnot(
        "`threshold` must be a scalar double." = is_dbl(threshold)
      )
      probs[probs < threshold] <- threshold
      probs[probs > 1 - threshold] <- 1 - threshold
    }

    likelihood <- matrix(probs, nrow = L, dimnames = list(levs, features))

    # check excessive feature bias
    if ( !is.null(flag <- check_nb_bias(likelihood)) ) {
      warning(
        "Features heavily influencing the ",
        "Bayes likelihood: ", value(flag), call. = FALSE
      )
    }

    likelihood <- rowSums(log(likelihood))
    posterior  <- likelihood + prior

    if ( type != "class" ) {
      posterior <- exp(posterior) / sum(exp(posterior))
    }
    data.frame(as.list(posterior))
  }) |> dplyr::bind_rows()

  if ( type == "class" ) {
    maxprob <- apply(LL, 1, which.max)
    LL <- factor(object$levels[maxprob], levels = levs)
  }
  LL
}


#' @describeIn fit_nb
#'   S3 plot method for `libml_nb`.
#'
#' @param features An optional feature specifying which subset of model features
#'   to plot. If missing, all features are plotted.
#' @param plot_type `character(1)`. A string determining the plot type, currently
#'   either a probability density function (PDF, default), CDF, or log-odds
#'   plots. Matched via [match.arg()].
#' @param x_lab `character(1)`. Optional label for the x-axis.
#' @param id `integer(n)` or `character(n)`. Optional identifier of
#'   a specific sample to plot on top of either PDFs or CDFs.
#'   Either an index of the sample row in the `data`, or its `rowname`.
#'
#' @return `plot.libml_nb`: A plot, either a list of
#'   PDFs/CDFs, or a log-odds plot.
#' @seealso [plot_log_odds()], [SomaPlotr::plotPDFlist()], [SomaPlotr::plotCDFlist()]
#'
#' @examples
#' # Plotting
#' plot(m2, tr_iris)
#' plot(m2, tr_iris, id = 20)      # sample 20 is definitely "virginica"
#' plot(m1, tr_iris, plot_type = "cdf")  # plot type CDF
#' plot(m2, tr_iris, features = "Sepal.Length", id = 70)  # 1 feature
#' plot(m1, tr_iris, plot_type = "cdf", lty = "longdash") # pass-through of lty
#' @importFrom dplyr all_of
#' @export
plot.libml_nb <- function(x, data, features,
                          plot_type = c("pdf", "cdf", "log_odds"),
                          x_lab = "value", id, ...) {

  if ( missing(data) && inherits(x$data, "data.frame") ) {
    data <- x$data
  } else if ( missing(data) ) {
    stop(
      "Must provide `data =` argumnet to plot naive Bayes model results.",
      call. = FALSE
    )
  } else {
    stopifnot(inherits(data, "tr_data"))
  }

  response <- x$response %||% .get_response(data)

  if ( is_soma_adat(data) && !is.null(attr(data, "Col.Meta")) ) {
    col_meta <- attr(data, "Col.Meta")
    targets <- col_meta$TargetFullName %||% col_meta$Target
    tg <- setNames(as.list(targets), add_seq(col_meta$SeqId))
  } else {
    tg <- NULL
  }

  plot_type <- match.arg(plot_type)

  if ( missing(id) ) {
    id <- NULL
  }

  if ( missing(features) ) {
    features <- get_model_features(x)
  }

  data <- dplyr::select(data, all_of(c(features, response)))

  if ( plot_type == "pdf" ) {
    p <- lapply(features, function(ft) {
       if ( is.null(id) ) {
         ablines <- NULL
       } else {
         ablines <- data[id, ft, drop = TRUE]
       }
       title <- tg[[ft]] %||% ft
       split(data[[ft]], data[[response]]) |>
         SomaPlotr::plotPDFlist(x.lab = x_lab, ablines = ablines, ...,
                                main = title)
      })

  } else if ( plot_type == "cdf" ) {

    p <- lapply(features, function(ft) {
       if ( is.null(id) ) {
         ablines <- NULL
       } else {
         ablines <- data[id, ft, drop = TRUE]
       }
       title <- tg[[ft]] %||% ft
       split(data[[ft]], data[[response]]) |>
         SomaPlotr::plotCDFlist(x.lab = x_lab, ablines = ablines, ...,
                                main = title)
      }) |> invisible()

  } else if ( plot_type == "log_odds" ) {
    if ( length(x$levels) != 2L ) {
      stop(
        "Log-odds plots not supported for non-binary class predictions: ",
        value(x$levels), ".", call. = FALSE
      )
    }
    pred <- predict(x, newdata = data, type = "posterior")[, 2L]
    p    <- plot_log_odds(truth     = data[[response]],
                          predicted = pred,
                          pos_class = get_pos_class(x))
  }
  p
}


#' @describeIn fit_nb
#'   Plot a `naiveBayes` (`e1071`) model object.
#'
#' @export
plot.naiveBayes <- plot.libml_nb


#' Check Naive Bayes Feature Bias
#'
#' Catch (warning) for excessive feature bias in naiveBayes likelihoods
#'   during the prediction of a naive Bayes model for a single sample.
#'
#' @param likelihoods A `matrix` or `tibble` class object with the
#'   rows as the possible classes (>= 2) and the columns as the features.
#'   Likelihoods should not yet be log-transformed and entries should be as they
#'   come from [dnorm()].
#' @param max_lr `numeric(1)`. The threshold maximum allowed log-likelihood ratio.
#'
#' @return `check_nb_bias`: `NULL` if none are detected. If excessive influence
#'   on likelihoods are detected, the features responsible are returned.
#' @author Stu Field
#'
#' @examples
#' lik <- matrix(runif(6), ncol = 3)
#' rownames(lik) <- c("control", "disease")
#' colnames(lik) <- c("p1", "p2", "p3")
#' log(lik)
#' check_nb_bias(lik)
#' check_nb_bias(lik, max_lr = 1) # set a low threshold
#' @noRd
check_nb_bias <- function(likelihoods, max_lr = 1e04) {
  lr <- apply(log(likelihoods), 1L, function(.x) .x / .x[1L]) |>
    abs() |> t()
  if ( any(lr > max_lr) ) {
    names(keep_it(colSums(lr >= max_lr) > 0, function(x) x > 0))
  } else {
    invisible()
  }
}
