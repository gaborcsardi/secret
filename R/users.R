
#' Add a new user to the vault
#'
#' By default the new user does not have access to any secrets.
#' See [share_secret()] to give them access.
#'
#' @param email Email address of the user. This is used to identify
#'   users.
#' @param public_key Public key of the user. This is used to encrypt
#'   the secrets for the different users.
#' @inheritParams add_secret
#'
#' @export

add_user <- function(email, public_key, vault = NULL) {
  vault <- find_vault(vault)
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

}

#' List users
#'
#' @inheritParams add_secret
#'
#' @export

list_users <- function(vault = NULL) {

}
