
#' Add a new user to the vault
#'
#' By default the new user does not have access to any secrets.
#' See [add_secret()] or [share_secret()] to give them access.
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
#' @family user functions
#' @export
#' @importFrom openssl read_pubkey write_pem
#' @example inst/examples/example-secret.R

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

#' @importFrom curl new_handle handle_setheaders curl_fetch_memory

get_github_key <- function(github_user, i = 1) {
  url <- paste("https://api.github.com/users", github_user, "keys", sep = "/")

  ## Use GitHub token from GITHUB_PATH env var, if set
  pat <- Sys.getenv("GITHUB_PAT", "")
  if (pat != "") {
    h <- new_handle()
    handle_setheaders(h, Authorization = paste("token", pat))
    resp <- curl_fetch_memory(url, handle = h)
  } else {
    resp <- curl_fetch_memory(url)
  }

  k <- fromJSON(rawToChar(resp$content))
  key <- k$key
  key[i]
}

#' Add a user via their GitHub username.
#' 
#' On GitHub, a user can upload multiple keys. This function will download
#' the first key by default, but you can change this
#'
#' @param github_user User name on GitHub.
#' @param email Email address of the github user. If NULL, constructs an
#' email as `github-<<github_user>>`
#' @param i Integer, indicating which GitHub key to use (if more than one
#' GitHub key exists).
#' @inheritParams add_user
#'
#' @family user functions
#' @export
#' 
#' @importFrom assertthat is.count
#' @example inst/examples/example-github.R
#' @seealso [add_travis_user()]

add_github_user <- function(github_user, email = NULL, vault = NULL, 
                            i = 1) {
  assert_that(is.count(i))
  if(missing(email) || is.null(email)){
    email <- paste0("github-", github_user)
  }
  key <- get_github_key(github_user)
  add_user(email = email, public_key = key, vault = vault)
}


#' @importFrom curl curl
#' @importFrom  jsonlite fromJSON

get_travis_key <- function(travis_repo){
  url <- paste("https://api.travis-ci.org/repos", travis_repo, "key", sep = "/")
  r <- curl(url)
  k <- fromJSON(r)
  k <- k$key
  gsub(" RSA", "", k)
}


#' Add a user via their Travis repo.
#' 
#' On Travis, every repo has a private/public key pair. This function adds a 
#' user and downloads the public key from Travis.
#' 
#' @param travis_repo Name of Travis repository, usually in a format 
#' `<<username>>/<<repo>>`
#' @inheritParams add_user
#'
#' @family user functions
#' @export
#' @example inst/examples/example-travis.R

add_travis_user <- function(travis_repo, email, vault = NULL) {
  if(missing(email) || is.null(email)){
    email <- paste0("travis-", gsub("/", "-", travis_repo))
  }
  key <- get_travis_key(travis_repo)
  add_user(email = email, public_key = key, vault = vault)
}


#' Delete a user
#'
#' It also removes access of the user to all secrets, so if the user
#' is re-added again, they will not have access to any secrets.
#'
#' @param email Email address of the user.
#' @inheritParams add_secret
#'
#' @family user functions
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
#' @family user functions
#' @export

list_users <- function(vault = NULL) {
  vault <- find_vault(vault)
  sub(
    "\\.pem$", "",
    dir(file.path(vault, "users"), pattern = "\\.pem$")
  )
}

# Internals -------------------------------------------------------------

users_exist <- function(vault, users) {
  tryCatch(
    { lapply(users, get_user_key, vault = vault) ; TRUE },
    error = function(e) FALSE
  )
}

on_failure(secret_exists) <- function(call, env) {
  paste0("Secret ", deparse(call$name), " does not exist")
}
