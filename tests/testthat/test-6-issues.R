
context("Issues")

pkg_root <- make_pkg_root()
create_package_vault(pkg_root)
secret_to_keep <- list(a = 1, b = letters)
secret_to_keep2 <- list(a = 2, b = LETTERS)

({
  alice <- "alice"
  bob   <- "bob"
  user_keys_dir <- file.path(system.file(package = "secret"), "user_keys")
  key <- function(x) file.path(user_keys_dir, x)
  alice_public_key  <- key("alice.pub")
  alice_private_key <- key("alice.pem")
  bob_public_key    <- key("bob.pub")
  bob_private_key   <- key("bob.pem")
})

test_that("update a secret, deleted user has no access", {
  add_user(alice, alice_public_key, vault = pkg_root)
  add_user(bob, bob_public_key, vault = pkg_root)
  add_secret(
    "secret_one",
    secret_to_keep,
    users = c(alice, bob),
    vault = pkg_root
  )

  expect_equal(
    get_secret("secret_one", key = alice_private_key, vault = pkg_root),
    secret_to_keep
  )
  expect_equal(
    get_secret("secret_one", key = bob_private_key, vault = pkg_root),
    secret_to_keep
  )

  ## Bob get's the AES key of the secret, e.g. from the history of the repo
  aes <- try_get_aes_key(
    vault = find_vault(pkg_root),
    key = bob_private_key,
    name = "secret_one"
  )

  delete_user(bob, vault = pkg_root)

  update_secret(
    "secret_one",
    value = secret_to_keep2,
    key = alice_private_key,
    vault = pkg_root
  )

  expect_error(
    get_secret("secret_one", key = bob_private_key, vault = pkg_root),
    "Access denied to secret"
  )

  secret_file <- get_secret_file(
    vault = find_vault(pkg_root),
    name = "secret_one"
  )

  ## The old AES key of the secret is not good any more.
  secret <- unserialize(read_raw(secret_file))
  expect_error(
    openssl::aes_cbc_decrypt(secret, aes),
    "OpenSSL error"
  )
})

test_that("missing vault arguments", {
  if (!(alice %in% list_users(pkg_root))){
    add_user(alice, alice_public_key, vault = pkg_root)
  }

  if (!("secret_one" %in% list_secrets(pkg_root)$secret)){
    add_secret(
      "secret_one",
      secret_to_keep,
      users = c(alice, bob),
      vault = pkg_root
    )
  }

  old.o <- options(secret.vault = getOption("secret.vault", pkg_root))

  expect_equal(
    list_secrets(pkg_root),
    list_secrets() # Note the missing location argument
    )
  expect_equal(
    list_users(pkg_root),
    list_users() # Note the missing location argument
    )

  options(old.o)

  })
