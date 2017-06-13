
pkg_root <- make_pkg_root()
create_package_vault(pkg_root)
if(interactive()) unlink(pkg_root, recursive = TRUE)

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
