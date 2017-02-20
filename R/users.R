
#' Add a new user to the vault
#'
#' By default the new user does not have access to any secrets.
#' See [share_secret()] to give them access.
#'
#' @param email Email address of the user. This is used to identify
#'   users.
#' @param public_key Public key of the user. This is used to encrypt
#'   the secrets for the different users. It can be
#'   * a string containing a PEM,
#'   * a file name that points to a PEM file,
#'   * a `pubkey` object created via the `openssl` package.
#' @inheritParams add_secret
#'
#' @export
#' @importFrom openssl read_pubkey write_pem

add_user <- function(email, public_key, vault = NULL) {
  assert_that(is_email_address(email))
  vault <- find_vault(vault)

  user_file <- get_user_file(vault, email)
  if (file.exists(user_file)) {
    stop("User ", sQuote(email), " already exists in this vault. ",
         "To update it, remove the old key, and add the new one.")
  }

  key <- read_pubkey(public_key)
  write_pem(key, path = user_file)
}

#' Add a user via their GitHub username
#'
#' @param github_id User id on GitHub.
#' @param email Email address. This can be usually queried from GitHub.
#'   If not, then specify it here.
#' @inheritParams add_secret
#'
#' @export

add_github_user <- function(github_id, email = NULL, vault = NULL) {
  ## TODO
}

#' Delete a user
#'
#' It also removes access of the user to all secrets, so if the user
#' is re-added again, they will not have access to any secrets.
#'
#' @param email Email address of the user.
#' @inheritParams add_secret
#'
#' @export

delete_user <- function(email, vault = NULL) {
  assert_that(is_email_address(email))
  vault <- find_vault(vault)

  ## Check if user exists
  user_file <- get_user_file(vault, email)
  if (!file.exists(user_file)) {
    stop("User ", sQuote(email), " does not exist")
  }

  ## Get all secrets they have access to
  secrets <- list_user_secrets(vault, email)

  ## Remove everything in one go. This is still not atomic, of course...
  file.remove(user_file, secrets)

  invisible()
}

#' List users
#'
#' @inheritParams add_secret
#'
#' @export

list_users <- function(vault = NULL) {
  vault <- find_vault(vault)
  sub(
    "\\.pem$", "",
    dir(file.path(vault, "users"), pattern = "\\.pem$")
  )
}

## ----------------------------------------------------------------------
## Internals

users_exist <- function(vault, users) {
  tryCatch(
    { lapply(users, get_user_key, vault = vault) ; TRUE },
    error = function(e) FALSE
  )
}

on_failure(secret_exists) <- function(call, env) {
  paste0("Secret ", deparse(call$name), " does not exist")
}
