if(interactive()) library(testthat)

# Function to test for identical file path, after normalizing paths
expect_same_filepath <- function(object, expected){
  neat_path <- function(x){ normalizePath(x, winslash = "/", mustWork = FALSE) }
  expect_equal(neat_path(object), neat_path(expected))
}

# Create a "package" in tempdir to contain a new vault
{
  pkg_root <- file.path(tempdir(), "secret_test")
  if(dir.exists(pkg_root)) unlink(pkg_root, recursive = TRUE)
  dir.create(pkg_root, showWarnings = FALSE)
  writeLines("Package: test", file.path(pkg_root, "DESCRIPTION"))
}

# Define users and locations of keys
{
  user_1 <- "user_1"
  user_2 <- "user_2"
  user_keys_dir <- file.path(system.file(package = "secret"), "user_keys")
  user_1_public_key <- file.path(user_keys_dir, "r-secret-package-test-user1.pub")
  user_2_public_key <- file.path(user_keys_dir, "r-secret-package-test-user2.pub")
  user_1_private_key <- file.path(user_keys_dir, "r-secret-package-test-user1.pem")
  user_2_private_key <- file.path(user_keys_dir, "r-secret-package-test-user2.pem")
}

secret_to_keep <- list(a = 1, b = letters)

#  ------------------------------------------------------------------------

context("Create a vault")

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

test_that("can add and delete users", {
  expect_equal(
    basename(
      add_user(user_1, user_1_public_key, vault = pkg_root)
    ), 
    "user_1.pem"
  ) 
  
  expect_equal(
    list_users(pkg_root), 
    "user_1"
  )
  
  expect_error(
    delete_user(user_2, vault = pkg_root),
    "does not exist"
  )
  
  expect_null(
    delete_user(user_1, vault = pkg_root)
  )
  expect_equal(
    list_users(pkg_root), 
    character(0)
  )
})


# add and delete secrets --------------------------------------------------
test_that("can add secrets", {
  
  add_user(user_1, user_1_public_key, vault = pkg_root)
  
  expect_null(
    add_secret("secret_one", secret_to_keep, users = user_1, vault = pkg_root)
  )
  
  expect_error(
    add_secret("secret_one", secret_to_keep, users = user_1, vault = pkg_root),
    "Secret name already exists"
  )
  
  expect_equal(
    list_secrets(pkg_root),
    "secret_one"
  )
})


test_that("user_1 can decrypt secret", {
  # Error on public key
  expect_error(
    get_secret("secret_one", key = user_1_public_key, vault = pkg_root),
    "Access denied to secret"
  )
  # Success on private key
  expect_equal(
    get_secret("secret_one", key = user_1_private_key, vault = pkg_root),
    secret_to_keep
  )
})


test_that("user_2 can not decrypt secret", {
  expect_error(
    get_secret("secret_one", key = user_2_public_key, vault = pkg_root),
    "Access denied to secret"
  )
  expect_error(
    get_secret("secret_one", key = user_2_private_key, vault = pkg_root),
    "Access denied to secret"
  )
})


test_that("add second secret shared by multiple users", {
  expect_equal(
    basename(
      add_user(user_2, user_2_public_key, vault = pkg_root)
    ),
    "user_2.pem"
  )
  expect_null(
    add_secret("secret_two", iris, users = c(user_1, user_2), vault = pkg_root)
  )
  expect_equal(
    list_secrets(pkg_root),
    c("secret_one", "secret_two")
  )
  expect_error(
    get_secret("secret_two", key = user_1_public_key, vault = pkg_root)
  )
  expect_equal(
    get_secret("secret_two", key = user_1_private_key, vault = pkg_root),
    iris
  )
  
  expect_error(
    get_secret("secret_two", key = user_2_public_key, vault = pkg_root)
  )
  expect_equal(
    get_secret("secret_two", key = user_2_private_key, vault = pkg_root),
    iris
  )
  
  # delete user and try to access secret
  expect_null(
    delete_user(user_1, vault = pkg_root)
  )
  
  # This test should throw an error. Right now it doesn't - this is a bug
  # Solving this requires re-encrypting secrets after deleting a user
  expect_error(
    get_secret("secret_two", key = user_1_private_key, vault = pkg_root),
    "Access denied to secret"
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
    "user_2"
  )
})
