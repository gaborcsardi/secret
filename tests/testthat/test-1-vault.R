if(interactive()) library(testthat)

context("vault")

pkg_root <- make_pkg_root()

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

