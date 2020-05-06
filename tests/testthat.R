library(testthat)
library(secret)

if (Sys.getenv("NOT_CRAN", "") != "") {
  test_check("secret")
}
