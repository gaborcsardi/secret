
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

test_that("errors & messages", {

  expect_message(
    create_package_vault(pkg_root),
    "Package vault already exists"
  )

  dir.create(tmp <- tempfile())
  expect_error(
    package_vault_directory(tmp),
    "No package or package vault found"
  )
})

test_that("finding the vault", {

  mockery::stub(find_vault, "is_vault", TRUE)

  withr::with_options(
    list("secret.vault" = NULL),
    withr::with_envvar(
      c("R_SECRET_VAULT" = "/foo/bar"),
      expect_equal(find_vault(NULL), "/foo/bar")
    )
  )

  withr::with_envvar(
    c("R_SECRET_VAULT" = NA_character_),
    withr::with_options(
      list("secret.vault" = "/foo/foobar"),
      expect_equal(find_vault(NULL), "/foo/foobar")
    )
  )
})

test_that("finding the vault 2", {
  dir.create(tmp <- tempfile())
  withr::with_dir(
    tmp,
    withr::with_options(
      list("secret.vault" = NULL),
      withr::with_envvar(
        c("R_SECRET_VAULT" = NA_character_),
        expect_equal(find_vault(NULL), ".")
      )
    )
  )
})
