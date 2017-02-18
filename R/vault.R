
#' Create a vault in an R package
#'
#' @param path Path to the R package. A file or directory within the
#'   package is fine, too.
#' @return The directory of the vault, invisibly.
#'
#' @importFrom rprojroot find_package_root_file
#' @export

create_package_vault <- function(path = ".") {
  vault <- package_vault_directory(path)
  if (file.exists(vault)) {
    message("Package vault already exists in ", sQuote(vault))
    return()
  }
  create_vault_dir(vault)
  invisible(vault)
}

package_vault_directory <- function(path) {
  root <- find_package_root_file(path)
  normalizePath(file.path(root, "inst", "vault"), mustWork = FALSE)
}

create_vault_dir <- function(path) {
  create_dir(path)
  create_dir(file.path(path, "users"))
  create_dir(file.path(path, "secrets"))
  if (! file.exists(readme <- file.path(path, "README"))) {
    cat("This directory is a secret vault.", file = readme)
  }
  if (! file.exists(readme <- file.path(path, "users", "README"))) {
    cat("This directory is part of a secret vault.", file = readme)
  }
  if (! file.exists(readme <- file.path(path, "secrets", "README"))) {
    cat("This directory is part of a secret vault.", file = readme)
  }
  invisible(path)
}

find_vault <- function(vault) {
  package_vault_directory(vault %||% ".")
}
