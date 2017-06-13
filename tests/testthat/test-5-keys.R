
context("local key")

test_that("can read local key", {
  skip_on_cran()
  z <- tryCatch(local_key(), error = function(e)e)
  if (inherits(z, "error")) skip("No local key available")
  
  expect_is(local_key(), "key")
})

test_that("can read local key when setting env variable", {
  old_env <- Sys.getenv("USER_KEY")
  on.exit(Sys.setenv(USER_KEY = old_env))
  
  pth <- system.file("user_keys/alice.pem", package = "secret")
  Sys.setenv(USER_KEY = pth)
  z <- local_key()
  expect_is(z, "key")
  expect_is(z, "rsa")
  
  Sys.setenv(USER_KEY = "path/does/not/exist")
  expect_error(
    local_key(),
    "No suitable user key found."
  )
  
})
