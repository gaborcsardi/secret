
context("local key")

test_that("can read local key", {

  mockery::stub(local_key, "Sys.getenv", "sdfqrtafgaetsgsfgqr")
  z <- tryCatch(local_key(), error = function(e) e)
  if (inherits(z, "error")) skip("No local key available")

  pth <- system.file("user_keys/alice.pem", package = "secret")
  z <- mockery::stub(local_key, "Sys.getenv", pth)
  
  expect_is(z, "key")
})

test_that("can read local key when setting env variable", {

  pth <- system.file("user_keys/alice.pem", package = "secret")
  z <- withr::with_envvar(
    c(USER_KEY = pth),
    local_key()
  )
  expect_is(z, "key")
  expect_is(z, "rsa")

  withr::with_envvar(
    c(USER_KEY = "path/does/not/exist"),
    expect_error(
      local_key(),
      "No suitable user key found."
    )
  )
})
