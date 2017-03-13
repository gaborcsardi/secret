if(interactive()) library(testthat)

# Function to test for identical file path, after normalizing paths
expect_same_filepath <- function(object, expected){
  neat_path <- function(x){ normalizePath(x, winslash = "/", mustWork = FALSE) }
  expect_equal(neat_path(object), neat_path(expected))
}

# Create a "package" in tempdir to contain a new vault
{
  pkg_root <- normalizePath(file.path(tempdir(), "secret_test"), winslash = "/", mustWork = FALSE)
  if(dir.exists(pkg_root)) unlink(pkg_root, recursive = TRUE)
  dir.create(pkg_root, showWarnings = FALSE)
  writeLines("Package: secret_test", file.path(pkg_root, "DESCRIPTION"))
}

# Define users and locations of keys
{
  alice <- "alice"
  bob   <- "bob"
  user_keys_dir <- file.path(system.file(package = "secret"), "user_keys")
  alice_public_key  <- file.path(user_keys_dir, "alice.pub")
  alice_private_key <- file.path(user_keys_dir, "alice.pem")
  bob_public_key    <- file.path(user_keys_dir, "bob.pub")
  bob_private_key   <- file.path(user_keys_dir, "bob.pem")
  carl_private_key   <- file.path(user_keys_dir, "charile.pem")
}

secret_to_keep <- list(a = 1, b = letters)

#  ------------------------------------------------------------------------

context("vault")

test_that("Can create a vault in a package", {
  proj_root <- rprojroot::find_package_root_file(path = pkg_root)
  expect_is(proj_root, "character")
  expect_equal(basename(proj_root), "secret_test")
  
  res <- create_package_vault(pkg_root)
  expect_equal(basename(res), "vault")
  
  expect_equal(
    dir(res), 
    c("README", "secrets", "users")
  )
  
  expect_same_filepath(
    find_vault(pkg_root), 
    file.path(tempdir(), "secret_test", "inst", "vault")
  )
  
  
  expect_equal(
    list_users(pkg_root),
    character(0)
  )
  
})


# add and delete users ----------------------------------------------------

context("users")

test_that("can add and delete users", {
  expect_equal(
    basename(
      add_user(alice, alice_public_key, vault = pkg_root)
    ), 
    "alice.pem"
  ) 
  
  expect_equal(
    list_users(pkg_root), 
    "alice"
  )
  
  expect_error(
    delete_user(bob, vault = pkg_root),
    "does not exist"
  )
  
  expect_null(
    delete_user(alice, vault = pkg_root)
  )
  expect_equal(
    list_users(pkg_root), 
    character(0)
  )
})


# add and delete secrets --------------------------------------------------

context("secrets")

test_that("can add secrets", {
  
  add_user(alice, alice_public_key, vault = pkg_root)
  
  expect_null(
    add_secret("secret_one", secret_to_keep, users = alice, vault = pkg_root)
  )
  
  expect_error(
    add_secret("secret_one", secret_to_keep, users = alice, vault = pkg_root),
    "Secret name already exists"
  )
  
  expect_equal(
    list_secrets(pkg_root),
    "secret_one"
  )
})


test_that("alice can decrypt secret", {
  # Error on public key
  expect_error(
    get_secret("secret_one", key = alice_public_key, vault = pkg_root),
    "Access denied to secret"
  )
  # Success on private key
  expect_equal(
    get_secret("secret_one", key = alice_private_key, vault = pkg_root),
    secret_to_keep
  )
})


test_that("bob can not decrypt secret", {
  expect_error(
    get_secret("secret_one", key = bob_public_key, vault = pkg_root),
    "Access denied to secret"
  )
  expect_error(
    get_secret("secret_one", key = bob_private_key, vault = pkg_root),
    "Access denied to secret"
  )
})


test_that("add second secret shared by multiple users", {
  expect_equal(
    basename(
      add_user(bob, bob_public_key, vault = pkg_root)
    ),
    "bob.pem"
  )
  expect_null(
    add_secret("secret_two", iris, users = c(alice, bob), vault = pkg_root)
  )
  expect_equal(
    list_secrets(pkg_root),
    c("secret_one", "secret_two")
  )
  expect_error(
    # alice can not decrypt with public key
    get_secret("secret_two", key = alice_public_key, vault = pkg_root)
  )
  expect_equal(
    # alice can decrypt with private key
    get_secret("secret_two", key = alice_private_key, vault = pkg_root),
    iris
  )
  
  expect_error(
    # bob can not decrypt with public key
    get_secret("secret_two", key = bob_public_key, vault = pkg_root)
  )
  expect_equal(
    # bob can decrypt with private key
    get_secret("secret_two", key = bob_private_key, vault = pkg_root),
    iris
  )
  expect_error(
    # carl can not decrypt with private key
    get_secret("secret_two", key = carl_private_key, vault = pkg_root)
  )
  
  # delete user and try to access secret
  expect_null(
    delete_user(alice, vault = pkg_root)
  )
  
  # User 1 should not be able to access the secret
  expect_error(
    get_secret("secret_two", key = alice_private_key, vault = pkg_root),
    "Access denied to secret"
  )

  # user 2 should still see the secret
  expect_equal(
    get_secret("secret_two", key = bob_private_key, vault = pkg_root),
    iris
  )
  
  
  expect_null(
    delete_secret("secret_two", vault = pkg_root)
  )
  
  expect_equal(
    list_secrets(pkg_root),
    "secret_one"
  )
  expect_equal(
    list_users(pkg_root),
    "bob"
  )
})


# travis and github ---------------------------------------------------

context("travis")

test_that("can add travis user",{
  expect_null(
    cat(add_travis_user("gaborcsardi/secret", vault = pkg_root))
  )
  expect_true(
    file.exists(file.path(pkg_root, "inst", "vault", "users", "travis-gaborcsardi-secret.pem"))
  )
})

test_that("can add github user",{
  expect_null(
    cat(add_github_user("gaborcsardi", vault = pkg_root))
  )
  expect_true(
    file.exists(file.path(pkg_root, "inst", "vault", "users", "github-gaborcsardi.pem"))
  )
})
