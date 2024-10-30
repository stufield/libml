
#' @export
helpr::get_model_features

#' @noRd
#' @export
get_model_features.glm <- function(model, ...) {
  attributes(model$terms)$term.labels
}

#' @noRd
#' @export
get_model_features.lm <- get_model_features.glm

#' @noRd
#' @export
get_model_features.lda <- get_model_features.glm

#' @noRd
#' @export
get_model_features.libml_nb <- function(model, ...) {
  names(model$tables)
}

#' @noRd
#' @export
get_model_features.naiveBayes <- get_model_features.libml_nb

#' @noRd
#' @export
get_model_features.NaiveBayes <- get_model_features.libml_nb

#' @noRd
#' @export
get_model_features.kknn <- get_model_features.glm

#' @noRd
#' @export
get_model_features.svm <- get_model_features.glm

#' @noRd
#' @export
get_model_features.gbm <- function(model, ...) {
  model$var.names
}

#' @noRd
#' @export
get_model_features.randomForest <- function(model, ...) {
  if ( !is.null(model$terms) ) {
    attributes(model$terms)$term.labels
  } else if ( !is.null(model$importance) ) {
    rownames(model$importance)
  } else {
    stop(
      "Unable to determine the features in `randomForest` model.",
      call. = FALSE
    )
  }
}

#' @noRd
#' @export
get_model_features.glmnet <- function(model, ...) {
  extract_feats(rownames(model$beta))
}

#' @noRd
#' @export
get_model_features.coxnet2 <- get_model_features.glmnet

#' @noRd
#' @export
get_model_features.survregnet <- get_model_features.glmnet

#' @noRd
#' @export
get_model_features.survreg <- function(model, ...) {
  extract_feats(names(model$coefficients))
}

#' @noRd
#' @export
get_model_features.psm <- function(model, ...) {
  extract_feats(names(model$coefficients))
}

#' @noRd
#' @export
get_model_features.train <- function(model, ...) {
  out <- model$coefnames
  if ( is.null(out) ) {
    stop(
      "The 'coefnames' element of the train object was empty! ",
      "Could not find any features via `get_model_features()`.",
      call. = FALSE
    )
  }
  out
}


#' Extract specific features; remove Intercept() etc.
#' @noRd
extract_feats <- function(x) {
  grep("Intercept|Log\\(scale\\)|^\\*$", x, value = TRUE, invert = TRUE)
}
