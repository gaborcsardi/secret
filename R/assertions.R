
#' @importFrom assertthat assert_that on_failure<-

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

on_failure(is_string) <- function(call, env) {
  paste0(deparse(call$x), " is not a string (length 1 character)")
}

#  --------------------------------------------------------------------

is_email_address <- function(x) {
  is_string(x) && grepl("^[-_\\.\\+@a-zA-Z0-9]+$", x)
}

on_failure(is_email_address) <- function(call, env) {
  paste0(deparse(call$x), " is not an email address")
}

#  --------------------------------------------------------------------

is_email_addresses <- function(x) {
  is.character(x) && all(vapply(x, is_email_address, TRUE))
}

on_failure(is_email_addresses) <- function(call, env) {
  paste0(deparse(call$x), " must be a vector of email addresses")
}

#  --------------------------------------------------------------------

is_valid_name <- function(x) {
  is_string(x) && nzchar(x) && grepl("^[-_\\.a-zA-Z0-9]+$", x)
}

on_failure(is_valid_name) <- function(call, env) {
  paste0(
    deparse(call$x),
    " is not a valid key. Keys may contain alphanumeric characters, ",
    " underscores, dashes and dots and the empty string is not a valid key."
  )
}

#  --------------------------------------------------------------------

is_valid_dir <- function(x) {
  is_string(x) && is_dir(x)
}

on_failure(is_valid_dir) <- function(call, env) {
  paste0(
    deparse(call$x),
    " does not exist, or is not a valid directory."
  )
}
