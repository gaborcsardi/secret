
#' Create a vault, as a folder or in an R package.
#'
#' A vault is a folder that contains information about users and the secrets
#' they share. You can create a vault as either a standalone folder, or
#' as part of a package.
#'
#' @details
#'
#' A vault is a folder with a specific structure, containing two
#' directories: `users` and `secrets`.
#'
#' In `users`, each file contains a public key in PEM format. The name of
#' the file is the identifier of the key, an arbitrary name. We suggest
#' that you use email addresses to identify public keys. See also [add_user()].
#'
#' In `secrets`, each secret is stored in its own directory.
#' The directory of a secret contains
#' 1. the secret, encrypted with its own AES key, and
#' 2. the AES key, encrypted with the public keys of all users that
#'    have access to the secret, each in its own file.
#'
#' To add a secret, see [add_secret()]
#'
#' @section Creating a package folder:
#'
#' When you create a vault in a package, this vault is stored in the
#' `inst/vault` directory of the package during development. At package
#' install time, this folder is copied to the `vault` folder.
#'
#' @param path Path to the R package. A file or directory within the
#'   package is fine, too. If the vault directory already exists, a message
#'   is given, and the function does nothing.
#' @return The directory of the vault, invisibly.
#'
#' @importFrom rprojroot find_package_root_file
#'
#' @export
#' @seealso [add_user()], [add_secret()]

create_package_vault <- function(path = ".") {
  vault <- package_vault_directory(path, create = TRUE)
  if (file.exists(vault)) {
    message("Package vault already exists in ", sQuote(vault))
  } else {
    create_vault(vault)
  }
  invisible(vault)
}

#' @rdname create_package_vault
#' @export
#' @example inst/examples/example-secret.R
create_vault <- function(path) {
  create_dir(path)
  create_dir(file.path(path, "users"))
  create_dir(file.path(path, "secrets"))
  if (! file.exists(readme <- file.path(path, "README"))) {
    cat("This directory is a secret vault.", file = readme)
  }
  if (! file.exists(readme <- file.path(path, "users", "README"))) {
    cat("This directory is part of a secret vault.", file = readme)
  }
  if (! file.exists(readme <- file.path(path, "secrets", "README"))) {
    cat("This directory is part of a secret vault.", file = readme)
  }
  invisible(path)
}


# Internals -------------------------------------------------------------

package_vault_directory <- function(path, create = FALSE) {
  assert_that(is_valid_dir(path))
  root <- tryCatch(
    find_package_root_file(path = path),
    error = function(e) e
  )
  if (inherits(root, "error")) {
    stop("No package or package vault found", call. = FALSE)
  }
  if (create) {
    return(normalizePath(file.path(root, "inst", "vault"),
                         mustWork = FALSE))
  }
  v <- file.path(root, "vault")
  v <- if (dir.exists(v)) v else file.path(root, "inst", "vault")
  normalizePath(v, mustWork = FALSE)
}

is_vault <- function(vault) {
  dir.exists(vault) &&
    dir.exists(file.path(vault, "users")) &&
    dir.exists(file.path(vault, "secrets"))
}

#' @importFrom rprojroot find_package_root_file

find_vault <- function(vault) {
  if (is.null(vault)) {
    vault <- getOption("secret.vault", NA_character_)
    if (is.na(vault)) vault <- Sys.getenv("R_SECRET_VAULT", NA_character_)
    if (is.na(vault)) vault <- "."
  }

  if (is_vault(vault)) {
    vault
  } else {
    pkgroot <- tryCatch(
      find_package_root_file(path = vault),
      error = function(e) NA_character_
    )
    if (is.na(pkgroot)) {
      "."
    } else {
      file.path(pkgroot, "inst", "vault")
    }
  }
}

#' Get the file of a user (email)
#'
#' We assume that `vault` is a proper vault directory, and `email` is a
#' valid email address.
#' @param vault Vault directory.
#' @param email Email address (or user name, in general).
#' @return The path to the user's public key. (It might not exist yet.)
#'
#' @keywords internal

get_user_file <- function(vault, email) {
  file.path(vault, "users", paste0(email, ".pem"))
}

get_user_key <- function(vault, email) {
  read_pubkey(get_user_file(vault, email))
}

get_secret_file <- function(vault, name) {
  file.path(vault, "secrets", name, "secret.raw")
}

get_secret_user_file <- function(vault, name, email) {
  file.path(vault, "secrets", name, paste0(email, ".enc"))
}

get_secret_user_files <- function(vault, name) {
  dir(
    file.path(vault, "secrets", name),
    pattern = "\\.enc$",
    full.names = TRUE
  )
}

get_secret_user_emails <- function(vault, name) {
  sub(
    "\\.enc$", "",
    basename(get_secret_user_files(vault, name))
  )
}

list_user_secrets <- function(vault, email) {
  z <- list.files(vault, pattern = paste0("^", email, ".enc"),
                  full.names = TRUE, recursive = TRUE)
  normalizePath(z, winslash = "/")
}

list_all_secrets <- function(vault) {
  secrets <- normalizePath(
    dir(file.path(vault, "secrets"), full.names = TRUE),
    winslash = "/"
  )
  Filter(is_dir, secrets)
}
