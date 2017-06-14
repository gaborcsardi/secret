
create_dir <- function(path) {
  dir.create(path, showWarnings = FALSE, recursive = TRUE)
}

is_dir <- function(x) {
  isTRUE(file.info(x)$isdir)
}

read_raw <- function(path) {
  readBin(path, "raw", n = file.info(path)$size)
}
