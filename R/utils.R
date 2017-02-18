
create_dir <- function(path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
}

`%||%` <- function(l, r) if (is.null(l)) r else l
