#' Add a new secret to the vault
#'
#' By default, the newly added secret is not shared with other
#' users. See the users argument if you want to change this.
#' You can also use [share_secret()] later, to specify the users that
#' have access to the secret.
#'
#' @param name Name of the secret, a string that can contain alphanumeric
#'   characters, underscores, dashes and dots.
#' @param value Value of the secret, an arbitrary R object that
#'   will be serialized using [base::serialize()].
#' @param users Email addresses of users that will have access to the
#'   secret. (See [add_user()])
#' @param vault Vault location. To create a vault, use [create_vault()] or [create_package_vault()]
#'
#' @family secret functions
#' @export
#' @importFrom openssl aes_keygen aes_cbc_encrypt read_pubkey rsa_encrypt

add_secret <- function(name, value, users, vault = NULL) {
  assert_that(is_valid_name(name))
  assert_that(is_email_addresses(users))
  vault <- find_vault(vault)
  assert_that(secret_does_not_exist(vault, name))
  assert_that(users_exist(vault, users))

  ## Create an AES key for the secret, and store it
  key <- aes_keygen()
  store_secret_with_key(name, value, key, vault)

  ## Share it with the specified users
  share_secret_with_key(name, users, aeskey = key, vault = vault)

  invisible()
}

#' Retrieve a secret from the vault
#'
#' @param name Name of the secret.
#' @param key The private RSA key to use. It defaults to the current
#'   user's default key.
#' @inheritParams add_secret
#'
#' @family secret functions
#' @export
#' @importFrom openssl rsa_decrypt aes_cbc_decrypt

get_secret <- function(name, key = local_key(), vault = NULL) {
  assert_that(is_valid_name(name))
  vault <- find_vault(vault)

  secret_file <- get_secret_file(vault, name)
  if (! file.exists(secret_file)) {
    stop("secret ", sQuote(name), " does not exist")
  }

  ## Try to decrypt all AES encryptions, to see if user has access
  aeskey <- try_get_aes_key(vault, name, key)
  if (is.null(aeskey)) stop("Access denied to secret ", sQuote(name))

  secret <- unserialize(read_raw(secret_file))
  data <- aes_cbc_decrypt(secret, aeskey)
  unserialize(data)
}

#' Update a secret in the vault.
#'
#' @inheritParams get_secret
#' @inheritParams add_secret
#'
#' @family secret functions
#' @export

update_secret <- function(name, value, key = local_key(), vault = NULL) {
  assert_that(is_valid_name(name))
  vault <- find_vault(vault)

  secret_file <- get_secret_file(vault, name)
  if (! file.exists(secret_file)) {
    stop("secret ", sQuote(name), " does not exist")
  }

  ## Need the AES key, to encrypt the new value
  aeskey <- try_get_aes_key(vault, name, key)

  ## Store the secret
  store_secret_with_key(name, value, aeskey, vault)

  ## Give access to the same users
  users <- get_secret_user_emails(vault, name)
  share_secret_with_key(name, users, aeskey = aeskey, vault = vault)

  invisible()
}

#' Remove a secret from the vault
#'
#' @param name Name of the secret to delete.
#' @inheritParams add_secret
#'
#' @family secret functions
#' @export

delete_secret <- function(name, vault = NULL) {
  assert_that(is_valid_name(name))
  vault <- find_vault(vault)

  secret_file <- get_secret_file(vault, name)
  secret_dir <- dirname(secret_file)
  if (!file.exists(secret_dir)) {
    stop("Secret ", sQuote(name), " does not exist.")
  }

  unlink(secret_dir, recursive = TRUE)

  invisible()
}

#' List all secrets
#'
#' @inheritParams add_secret
#'
#' @family secret functions
#' @export

list_secrets <- function(vault = NULL) {
  vault <- find_vault(vault)
  basename(list_all_secrets(vault))
}

#' Share a secret among some users
#'
#' Use this function to extend the set of users that have access to a
#' secret. The calling user must have access to the secret as well.
#'
#' @param key Private key that has access to the secret. (I.e. its
#'   corresponding public key is among the vault users.)
#' @inheritParams add_secret
#'
#' @seealso [unshare_secret()]
#' 
#' @family secret functions
#' @export

share_secret <- function(name, users, key = local_key(), vault = NULL) {
  assert_that(is_valid_name(name))
  assert_that(is_email_addresses(users))
  vault <- find_vault(vault)
  assert_that(secret_exists(vault, name))
  assert_that(users_exist(vault, users))

  aeskey <- try_get_aes_key(vault, name, key)
  if (is.null(aeskey)) stop("Access denied to secret ", sQuote(name))
  share_secret_with_key(name, users, aeskey, vault)

  invisible()
}

#' Unshare a secret among some users
#'
#' Use this function to restrict the set of users that have access to a
#' secret. Note that users may still have access to the secret, through
#' version control history, or if they have a copy of the project. They
#' will not have access to future values of the secret, though.
#'
#' @inheritParams add_secret
#'
#' @seealso [share_secret()]
#' 
#' @family secret functions
#' @export

unshare_secret <- function(name, users, vault = NULL) {
  assert_that(is_valid_name(name))
  assert_that(is_email_addresses(users))
  vault <- find_vault(vault)
  assert_that(secret_exists(vault, name))
  assert_that(users_exist(vault, users))

  files <- vapply(users, get_secret_user_file, "",
                  vault = vault, name = name)
  files <- Filter(file.exists, files)
  file.remove(files)

  invisible()
}

## ----------------------------------------------------------------------
## Internals

secret_exists <- function(vault, name) {
  file.exists(get_secret_file(vault, name))
}

on_failure(secret_exists) <- function(call, env) {
  paste0("Secret ", deparse(call$name), " does not exist")
}

secret_does_not_exist <- function(vault, name) {
  ! secret_exists(vault, name)
}

on_failure(secret_does_not_exist) <- function(call, env) {
  paste0("Secret ", deparse(call$name), " already exists")
}


#' Share a secret, its AES key is known already
#'
#' @param name Name of the secret.
#' @param users Email addresses of users.
#' @param aeskey AES key of the secret.
#' @param vault Vault directory.
#'
#' @keywords internal

share_secret_with_key <- function(name, users, aeskey, vault) {
  lapply(users, share_secret_with_key1,
         name = name, aeskey = aeskey, vault = vault)
}

#' Share a secret with a single user, AES key is known
#'
#' @param name Name of the secret.
#' @param email Email address of the user.
#' @param aeskey The AES key of the secret.
#' @param vault Vault directory.
#'
#' @keywords internal

share_secret_with_key1 <- function(name, email, aeskey, vault) {
  secret_user_file <- get_secret_user_file(vault, name, email)
  rsa_key <- get_user_key(vault, email)
  encaes <- rsa_encrypt(serialize(aeskey, NULL), rsa_key)
  create_dir(dirname(secret_user_file))
  writeBin(encaes, secret_user_file)
}

#' Try to get the AES key of a secret, using a private RSA key
#'
#' We just try the private key against all encrypted copies of the
#' AES key. If none of the succeed, then we return `NULL`. Otherwise
#' we return the AES key, an `aes` object, from the `openssl` package.
#'
#' @keywords internal

try_get_aes_key <- function(vault, name, key) {
  files <- get_secret_user_files(vault, name)
  for (f in files) {
    aes <- tryCatch(
      unserialize(rsa_decrypt(read_raw(f), key = key)),
      error = function(e) NULL
    )
    if (!is.null(aes)) return(aes)
  }

  NULL
}

#' Store a secret, encrypted with its AES key
#'
#' @param name Name of secret.
#' @param value Value of secret.
#' @param key The AES key, an `aes` object from the `openssl` package.
#' @param vault Vault directory.
#'
#' @keywords internal

store_secret_with_key <- function(name, value, key, vault) {
  ## Encrypt the secret with it
  data <- serialize(value, NULL)
  enc <- aes_cbc_encrypt(data, key)

  ## Write it out
  secret_file <- get_secret_file(vault, name)
  create_dir(dirname(secret_file))
  writeBin(serialize(enc, NULL), secret_file)
}
