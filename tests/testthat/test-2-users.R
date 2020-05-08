
pkg_root <- make_pkg_root()
create_package_vault(pkg_root)

({
  alice <- "alice"
  bob   <- "bob"
  user_keys_dir <- file.path(system.file(package = "secret"), "user_keys")
  key <- function(x)file.path(user_keys_dir, x)
  alice_public_key  <- key("alice.pub")
  alice_private_key <- key("alice.pem")
  bob_public_key    <- key("bob.pub")
  bob_private_key   <- key("bob.pem")
  carl_private_key   <- key("carl.pem")
})

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

test_that("error messages", {
  unlink(pkg_root, recursive = TRUE)
  pkg_root <- make_pkg_root()
  create_package_vault(pkg_root)
  add_user(alice, alice_public_key, vault = pkg_root)

  expect_error(
    add_user(alice, alice_public_key, vault = pkg_root),
    paste0("User .*", alice, ".* already exists in this vault")
  )
})

test_that("lookup_user() warns on duplicated user-fingerprints", {
  unlink(pkg_root, recursive = TRUE)
  pkg_root <- make_pkg_root()
  create_package_vault(pkg_root)
  
  add_user(alice, alice_public_key, vault = pkg_root)
  add_user(bob, bob_public_key, vault = pkg_root)
  expect_silent(lookup_user(alice_private_key, vault = find_vault(pkg_root)))
  
  add_user("alyce", alice_public_key, vault = pkg_root)
  expect_warning(
    lookup_user(alice_private_key, vault = find_vault(pkg_root)),
    "alyce"
  )
})
