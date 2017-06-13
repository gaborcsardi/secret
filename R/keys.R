
#' Read local secret key.
#'
#' Reads a local secret key from disk. The location of this file can be
#' specified in the `USER_KEY` environment variable.
#' If this environment variable does not exist, then attempts to read the
#' key from:
#' * `~/.ssh/id_rsa`, and
#' * `~/.ssh/id_rsa.pem`.
#'
#' The location of the key is defined by:
#' ```
#' Sys.getenv("USER_KEY")
#' ```
#'
#' To use a local in a different location, set an environment variable:
#' ```
#' Sys.setenv(USER_KEY = "path/to/private/key")
#' ```
#'
#' @family secret functions
#' @export
#' @importFrom openssl read_key

local_key <- function() {
  path <- Sys.getenv("USER_KEY")
  if (nzchar(path)) {
    read_key(path)
  } else if (file.exists(path2 <- "~/.ssh/id_rsa")) {
    read_key(path2)
  } else if (file.exists(path3 <- "~/.ssh/id_rsa.pem")) {
    read_key(path3)
  } else {
    stop("No suitable user key found.")
  }
}
