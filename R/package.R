
#' Share Sensitive Information in R Packages.
#'
#' Allow sharing sensitive information, for example passwords, API keys,
#' or other information in R packages, using public key cryptography.
#'
#' A vault is a directory, typically inside an R package, that
#' stores a number of secrets. Each secret is shared among a group of
#' users. Users are identified using their public keys.
#'
#' The package implements the following operations:
#'
#' * Vault:
#'   - Creating a vault folder: [create_vault()]
#'   - Creating a package vault: [create_package_vault()]
#' * User management:
#'   - Adding a user: [add_user()], [add_github_user()].
#'   - Deleting a user: [delete_user()].
#'   - Listing users: [list_users()].
#' * Keys:
#'   - Reading local private key: [local_key()]
#' * Secrets:
#'   - Adding a secret: [add_secret()].
#'   - Retrieving a secret: [get_secret()].
#'   - Updating a secret: [update_secret()].
#'   - Deleting a secret: [delete_secret()].
#'   - List secrets: [list_secrets()].
#'   - Sharing a secret: [share_secret()]. Query or set the set of
#'   users that have access to a secret.
#'   - Unsharing a secret: [unshare_secret()]
#'
#' @docType package
#' @keywords package
#' @name secret-package
#' @aliases secret
#' @author Gábor Csárdi and Andrie de Vries
NULL
