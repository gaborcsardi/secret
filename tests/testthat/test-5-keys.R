if(interactive()) library(testthat)

context("local key")

test_that("can read local key", {
  skip_on_cran()
  expect_silent(
    z <- local_key()
  )
  expect_is(z, "key")
})

test_that("can read local key when setting env variable", {
  old_env <- Sys.getenv("USER_KEY")
  on.exit(Sys.setenv(USER_KEY = old_env))
  
  pth <- system.file("inst/user_keys/alice.pem", package = "secret")
  Sys.setenv(USER_KEY = pth)
  expect_silent(
    z <- "local_key"()
  )
  expect_is(z, "key")
  expect_is(z, "rsa")
  
  Sys.setenv(USER_KEY = "path/does/not/exist")
  expect_error(
    local_key(),
    "No suitable user key found."
  )
  
  
})