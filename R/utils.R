
create_dir <- function(path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
}

`%||%` <- function(l, r) if (is.null(l)) r else l

is_dir <- function(x) {
  isTRUE(file.info(x)$isdir)
}

read_raw <- function(path) {
  readBin(path, "raw", n = file.info(path)$size)
}
