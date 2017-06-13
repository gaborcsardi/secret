
pkg_root <- make_pkg_root()
create_package_vault(pkg_root)
if(interactive()) unlink(pkg_root, recursive = TRUE)


context("travis and github")

test_that("can add travis user",{
  skip_on_cran()
  skip_on_travis()
  expect_equal(
    basename(
      add_travis_user("gaborcsardi/secret", vault = pkg_root)
    ),
    "travis-gaborcsardi-secret.pem"
  )
  expect_true(
    file.exists(
      file.path(pkg_root, 
                "inst", "vault", "users", "travis-gaborcsardi-secret.pem"
      )
    )
  )
})

test_that("can add github user",{
  skip_on_cran()
  expect_equal(
    basename(
      add_github_user("gaborcsardi", vault = pkg_root)
    ),
    "github-gaborcsardi.pem"
  )
  expect_true(
    file.exists(
      file.path(pkg_root, "inst", "vault", "users", "github-gaborcsardi.pem"
      )
    )
  )
})
