
# this wrapper is necessary following the deprecation of
# purrr::cross_df(). Recommended to use tidyr::expand_grid()
# but that function is slow and re-orders the rows by variable
# relative to either expand.grid() or cross_df()
# this is for internal use only
expand_grid <- function(...) {
  out <- expand.grid(..., KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  as_tibble(out)
}

# @param x a tr_data object
.get_response <- function(x) {
  attr(x, "response_var")
}

is.apt <- function(x) {
  grepl("[0-9]{4,5}[-.][0-9]{1,3}([._][0-9]{1,3})?$", x)
}

is.soma_adat <- function(x) {
  inherits(x, "soma_adat")
}

getAnalytes <- function(x) {
  if ( inherits(x, "data.frame") ) {
    x <- names(x)
  }
  x[is.apt(x)]
}

getMeta <- function(x) {
  if ( inherits(x, "data.frame") ) {
    x <- names(x)
  }
  setdiff(x, getAnalytes(x))
}

seqid2apt <- function(x) {
  stopifnot(inherits(x, "character"))
  x <- vapply(strsplit(x, "_", fixed = TRUE), `[[`, i = 1L, "")
  paste0("seq.", sub("-", ".", x))
}

#getSeqId <- getFromNamespace("getSeqId", "globalr")
#matchSeqIds <- getFromNamespace("matchSeqIds", "globalr")
#getSeqIdMatches <- getFromNamespace("getSeqIdMatches", "globalr")
