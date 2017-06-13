
context("local key")

test_that("can read local key", {

  mockery::stub(local_key, "Sys.getenv", "sdfqrtafgaetsgsfgqr")
  expect_error(local_key(), "No such file or directory")

  pth <- system.file("user_keys/alice.pem", package = "secret")
  mockery::stub(local_key, "Sys.getenv", pth)
  
  expect_is(local_key(), "key")
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
    expect_error(local_key(), "No such file or directory")
  )
})
