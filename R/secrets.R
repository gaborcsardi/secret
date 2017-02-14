
#' Add a new secret to the vault
#'
#' By default, the newly added secret is not shared with other
#' users. See the users argument if you want to change this.
#' You can also use [share_secret()] later, to specify the users that
#' have access to the secret.
#'
#' @param key Name of the secret.
#' @param value Value of the secret, an arbitrary R object that
#'   will be saved to a file using [base::save()].
#' @param vault Vault location. TODO
#'
#' @export
#' @importFrom openssl rsa_encrypt

add_secret <- function(key, value, vault = NULL) {

}

#' Retrieve a secret from the vault
#'
#' @param key Name of the secret.
#' @inheritParams add_secret
#'
#' @export
#' @importFrom openssl rsa_decrypt

get_secret <- function(key, vault = NULL) {


}

#' Update a secret in the vault.
#'
#' @inheritParams add_secret
#'
#' @export

update_secret <- function(key, vault = NULL) {

}

#' Remove a secret from the vault
#'
#' @param key Name of the secret to delete.
#' @inheritParams add_secret
#'
#' @export

delete_secret <- function(key, vault = NULL) {

}

#' List all secrets
#'
#' @inheritParams add_secret
#'
#' @export

list_secrets <- function(vault = NULL) {

}

#' Share a secret among some users
#'
#' Use this function to restrict or extend the set of users that
#' have access to a secret. The calling user must have access to
#' the secret as well.
#'
#' @param users Character vector of usernames or email addresses
#'   to share the secret with. The special values [everyone()] and
#'   [noone()] make it easy to share a secret with all users, or no
#'   users at all.
#' @inheritParams add_secret
#'
#' @export

share_secret <- function(key, users = everyone(), vault = NULL) {

}

#' @rdname share_secret
#' @export

everyone <- function() {

}

#' @rdname share_secret
#' @export

noone <- function() {

}
