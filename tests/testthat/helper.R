
# Function to test for identical file path, after normalizing paths
expect_same_filepath <- function(object, expected){
  neat_path <- function(x){ normalizePath(x, winslash = "/", mustWork = FALSE) }
  expect_equal(neat_path(object), neat_path(expected))
}

# Create a "package" in tempdir to contain a new vault
make_pkg_root <- function(){
  pkg_root <- normalizePath(file.path(tempdir(), "secret_test"), 
                            winslash = "/", 
                            mustWork = FALSE
  )
  if(dir.exists(pkg_root)) unlink(pkg_root, recursive = TRUE)
  dir.create(pkg_root, showWarnings = FALSE)
  writeLines("Package: secret_test", file.path(pkg_root, "DESCRIPTION"))
  pkg_root
}
