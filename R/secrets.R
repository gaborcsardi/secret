
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
#'   will be saved to a file using [base::save()].
#' @param email User that will have access to the secret.
#' @param vault Vault location. TODO
#'
#' @export
#' @importFrom openssl aes_keygen aes_cbc_encrypt read_pubkey rsa_encrypt

add_secret <- function(name, value, email, vault = NULL) {
  assert_that(is_valid_name(name))
  assert_that(is_email_address(email))
  vault <- find_vault(vault)

  secret_file <- get_secret_file(vault, name)
  if (file.exists(secret_file)) {
    stop("secret ", sQuote(name), " already exists. Use 'update_secret' ",
         "to update it.")
  }

  user_file <- get_user_file(vault, email)
  if (!file.exists(user_file)) {
    stop("User with email ", sQuote(email), " does not exist")
  }
  rsa_key <- read_pubkey(user_file)

  ## Create an AES key for the secret
  key <- aes_keygen()

  ## Encrypt the secret with it
  data <- serialize(value, NULL)
  enc <- aes_cbc_encrypt(data, key)

  ## Write it out
  create_dir(dirname(secret_file))
  writeBin(serialize(enc, NULL), secret_file)

  ## Also write out the encrypted AES key
  secret_user_file <- get_secret_user_file(vault, name, email)
  myaes <- rsa_encrypt(serialize(key, NULL), rsa_key)
  create_dir(dirname(secret_user_file))
  writeBin(myaes, secret_user_file)

  invisible()
}

#' Retrieve a secret from the vault
#'
#' @param name Name of the secret.
#' @param key The private RSA key to use. It defaults to the current
#'   user's default key.
#' @inheritParams add_secret
#'
#' @export
#' @importFrom openssl my_key rsa_decrypt aes_cbc_decrypt

get_secret <- function(name, key = my_key(), vault = NULL) {
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
#' @inheritParams add_secret
#'
#' @export

update_secret <- function(name, vault = NULL) {

}

#' Remove a secret from the vault
#'
#' @param name Name of the secret to delete.
#' @inheritParams add_secret
#'
#' @export

delete_secret <- function(name, vault = NULL) {

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

share_secret <- function(name, users = everyone(), vault = NULL) {

}

#' @rdname share_secret
#' @export

everyone <- function() {

}

#' @rdname share_secret
#' @export

noone <- function() {

}

## ----------------------------------------------------------------------
## Internals

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
